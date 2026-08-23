import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/anuncios.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/patrocinadores_repository.dart'
    show leerPatrociniosActivos;
import 'package:manager_nba/domain/permisos.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/features/temporada/patrocinadores_screen.dart';

/// Los bloqueos de la versión gratuita, enchufados de verdad a la capa de
/// permisos (paso 3 del plan de monetización).
///
/// Todos estos tests sustituyen `permisos` a mano. Por defecto la edición
/// es `completa`, así que sin hacerlo no habría nada bloqueado y los tests
/// pasarían sin probar nada.

/// Espera a que [queSalga] esté pintado de verdad.
///
/// Misma historia que en `tarjeta_proximo_partido_test.dart`: la pantalla
/// de patrocinadores lee la base al abrirse, y esos son futures REALES que
/// `pumpAndSettle` no espera porque solo adelanta el reloj falso. Que el
/// bucle se rinda en silencio al agotarse es correcto: lo que quede de
/// animación lo remata el `pumpAndSettle` de después.
Future<void> _esperarA(WidgetTester tester, Finder queSalga) async {
  await tester.runAsync(() async {
    for (var i = 0; i < 100; i++) {
      if (queSalga.evaluate().isNotEmpty) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    permisos = Permisos();
    anuncios = AnunciosDeMentira();
  });

  group('las ranuras de guardado', () {
    late AlmacenDeSlotsEnMemoria almacen;

    setUp(() {
      almacen = AlmacenDeSlotsEnMemoria();
      almacenDeSlots = almacen;
    });

    tearDown(() async {
      await almacen.cerrarTodo();
      almacenDeSlots = AlmacenDeSlotsEnDisco();
    });

    test('en la versión completa hay tres', () {
      permisos = Permisos();
      expect(ranurasDisponibles(), numeroDeSlots);
    });

    test('en la gratuita, solo la primera', () {
      permisos = Permisos(edicion: Edicion.gratis);
      expect(ranurasDisponibles(), 1);
    });

    test('comprar abre las otras dos en el acto', () {
      permisos = Permisos(edicion: Edicion.gratis);
      expect(ranurasDisponibles(), 1);

      permisos.registrarCompra();
      expect(ranurasDisponibles(), numeroDeSlots);
    });

    test('las bloqueadas se enseñan, no se esconden', () async {
      permisos = Permisos(edicion: Edicion.gratis);
      final resumenes = await leerResumenDeSlots();

      // Siguen siendo tres fichas: el jugador tiene que ver que las otras
      // dos carreras existen, que es justo lo que se le está ofreciendo.
      expect(resumenes, hasLength(numeroDeSlots));
      expect(resumenes[0].bloqueada, isFalse);
      expect(resumenes[1].bloqueada, isTrue);
      expect(resumenes[2].bloqueada, isTrue);
    });

    test('una ranura bloqueada no se abre ni por error', () async {
      permisos = Permisos(edicion: Edicion.gratis);
      await leerResumenDeSlots();

      // Leer el menú no puede crear la base de datos de una ranura que no
      // se puede jugar: si la abriera, "existe" pasaría a ser cierto y la
      // ranura quedaría ocupada sin que nadie empezara nada.
      expect(await almacen.existe(2), isFalse);
      expect(await almacen.existe(3), isFalse);
    });

    test('con la completa sí se leen las tres', () async {
      permisos = Permisos();
      final resumenes = await leerResumenDeSlots();
      expect(resumenes.every((r) => !r.bloqueada), isTrue);
    });
  });

  group('los patrocinadores', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await importarJugadoresSiHaceFalta(db);
      await crearFranquicia(db, 'DEN');
    });

    tearDown(() async => db.close());

    Future<void> abrir(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: PatrocinadoresScreen(
          db: db,
          equipoUsuario: 'DEN',
          onContinuar: () {},
        ),
      ));
      await _esperarA(tester, find.byType(PatrocinadoresScreen));
    }

    testWidgets('en la completa no hay aviso ni botón de vídeo',
        (tester) async {
      permisos = Permisos();
      await abrir(tester);

      expect(find.byIcon(Icons.lock_outline), findsNothing);
      expect(find.byIcon(Icons.play_circle_outline), findsNothing);
    });

    testWidgets('en la gratuita salen bloqueados, con su vídeo',
        (tester) async {
      permisos = Permisos(edicion: Edicion.gratis);
      await abrir(tester);

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget,
          reason: 'sin salida, un bloqueo no es una oferta');

      // Desplegar SÍ se puede: ver lo que te estás perdiendo es la mitad
      // de por qué alguien vería el vídeo. Lo que no se puede es firmar.
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.radio_button_unchecked), findsWidgets);

      await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsNothing,
          reason: 'bloqueado es bloqueado');
      expect(await leerPatrociniosActivos(db), isEmpty,
          reason: 'no se puede firmar nada sin permiso');
    });

    testWidgets('ver el vídeo entero los desbloquea', (tester) async {
      permisos = Permisos(edicion: Edicion.gratis);
      final falsos = AnunciosDeMentira();
      anuncios = falsos;
      await abrir(tester);

      await tester.tap(find.byIcon(Icons.play_circle_outline));
      await _esperarA(tester, find.byIcon(Icons.expand_more));

      expect(falsos.recompensadosPedidos, 1,
          reason: 'un vídeo abre los cuatro; uno por patrocinador '
              'convertiría la decisión en "verlos todos"');
      expect(find.byIcon(Icons.lock_outline), findsNothing);

      // Y ahora sí se firma.
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(await leerPatrociniosActivos(db), isNotEmpty);
    });

    testWidgets('cerrarlo antes de tiempo los deja bloqueados',
        (tester) async {
      permisos = Permisos(edicion: Edicion.gratis);
      anuncios = AnunciosDeMentira()..concedeRecompensa = false;
      await abrir(tester);

      await tester.tap(find.byIcon(Icons.play_circle_outline));
      await _esperarA(tester, find.byType(SnackBar));

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget,
          reason: 'hay que contarle por qué no se ha desbloqueado');
    });

    testWidgets('comprada la versión completa, ni aviso ni vídeo',
        (tester) async {
      permisos = Permisos(edicion: Edicion.gratis)..registrarCompra();
      await abrir(tester);

      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });
  });
}
