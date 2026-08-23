import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/entrenadores_importer.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/entrenadores_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/permisos.dart';
import 'package:manager_nba/features/calendario/calendario_screen.dart';
import 'package:manager_nba/features/hub/home_hub_screen.dart';

/// "Simular temporada entera": el botón vive en el menú, pero la simulación
/// se ve en el Calendario.
///
/// La idea es que ochenta partidos no se simulen a ciegas desde un botón
/// del menú que se queda pensando: te lleva al calendario y ahí lo ves
/// avanzar sobre las fechas, con su barra de progreso.

/// Ver la nota de `tarjeta_proximo_partido_test.dart`: las pantallas leen
/// la base al abrirse y esos son futures REALES, que `pumpAndSettle` no
/// espera porque solo adelanta el reloj falso. Rendirse en silencio al
/// agotar las vueltas es correcto: lo que quede lo remata el pumpAndSettle.
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

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await importarEntrenadoresSiHaceFalta(db);
    await asignarEntrenadoresQueFalten(db);
    final plantilla = await (db.select(
      db.jugadores,
    )..where((t) => t.equipo.equals('DEN'))).get();
    await guardarRotacion(db, generarRotacionAutomatica(plantilla));
  });

  tearDown(() async {
    await db.close();
    permisos = Permisos();
  });

  Future<void> abrirHub(WidgetTester tester, {Size? pantalla}) async {
    tester.view.physicalSize = pantalla ?? const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeHubScreen(db: db, equipo: 'DEN', random: Random(1)),
      ),
    );
    await _esperarA(tester, find.text('SIMULAR 1 PARTIDO'));
  }

  testWidgets('el botón está en el menú, junto al de un partido', (
    tester,
  ) async {
    permisos = Permisos();
    await abrirHub(tester);

    expect(find.text('TEMPORADA ENTERA'), findsOneWidget);
    expect(find.byIcon(Icons.fast_forward), findsOneWidget);
  });

  testWidgets('en la versión gratuita sale con candado y no responde', (
    tester,
  ) async {
    permisos = Permisos(edicion: Edicion.gratis);
    await abrirHub(tester);

    expect(
      find.text('TEMPORADA ENTERA'),
      findsOneWidget,
      reason: 'se enseña bloqueado, no se esconde: es lo que se vende',
    );
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byIcon(Icons.fast_forward), findsNothing);

    // Tocarlo no lleva a ninguna parte.
    await tester.tap(find.text('TEMPORADA ENTERA'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarioScreen), findsNothing);
  });

  testWidgets('comprar lo desbloquea', (tester) async {
    permisos = Permisos(edicion: Edicion.gratis)..registrarCompra();
    await abrirHub(tester);

    expect(find.byIcon(Icons.fast_forward), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
  });

  testWidgets('tocarlo lleva al Calendario y allí simula el año entero', (
    tester,
  ) async {
    permisos = Permisos();

    Future<int> jugados() async {
      final r = await (db.select(
        db.resultadoTemporada,
      )..where((t) => t.equipo.equals('DEN'))).getSingle();
      return r.victorias + r.derrotas;
    }

    expect(await jugados(), 0);

    // A 390 px como los demás casos. Aquí hubo que poner una pantalla
    // ancha una temporada: simular el año entero pasa por el aviso del
    // campeón de la Copa, y su fila de botones se desbordaba 92 px en un
    // móvil. Arreglado en `campeon_dialog.dart` (los botones se apilan si
    // no caben) y vigilado por `dialogo_campeon_test.dart`, así que este
    // test vuelve a correr donde de verdad se juega.
    await abrirHub(tester);

    await tester.tap(find.text('TEMPORADA ENTERA'));

    // Primero: se cambia de pantalla. Es la mitad de la gracia — no se
    // simula a ciegas desde el menú.
    await _esperarA(tester, find.byType(CalendarioScreen));
    expect(find.byType(CalendarioScreen), findsOneWidget);

    // Y segundo: allí arranca solo, sin tener que tocar nada más.
    await tester.runAsync(() async {
      for (var i = 0; i < 200; i++) {
        if (await jugados() > 0) return;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    expect(
      await jugados(),
      greaterThan(0),
      reason:
          'entrar al calendario con la intención de simular el año '
          'tiene que empezar a simular solo',
    );
  });

  testWidgets('entrar al calendario a mano NO simula nada', (tester) async {
    permisos = Permisos();

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarioScreen(db: db, equipoUsuario: 'DEN', random: Random(1)),
      ),
    );
    await _esperarA(tester, find.text('1 SEMANA'));

    final r = await (db.select(
      db.resultadoTemporada,
    )..where((t) => t.equipo.equals('DEN'))).getSingle();
    expect(
      r.victorias + r.derrotas,
      0,
      reason: 'abrir el calendario para mirarlo no puede jugarte el año',
    );
  });

  group('la barra de saltos del calendario', () {
    Future<void> abrirCalendario(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: CalendarioScreen(
            db: db,
            equipoUsuario: 'DEN',
            random: Random(1),
          ),
        ),
      );
      await _esperarA(tester, find.text('1 SEMANA'));
    }

    testWidgets('ya no lleva "1 partido": eso se hace desde el menú', (
      tester,
    ) async {
      permisos = Permisos();
      await abrirCalendario(tester);

      expect(find.text('1 PARTIDO'), findsNothing);
      expect(
        find.text('SIMULAR 1 PARTIDO'),
        findsNothing,
        reason: 'el mismo botón dos veces le quitaba sitio al calendario',
      );
    });

    testWidgets('son tres saltos y «temporada» va a la derecha del todo', (
      tester,
    ) async {
      permisos = Permisos();
      await abrirCalendario(tester);

      final semana = tester.getCenter(find.text('1 SEMANA')).dx;
      final mes = tester.getCenter(find.text('1 MES')).dx;
      final temporada = tester.getCenter(find.text('TEMPORADA ENTERA')).dx;

      // De menos a más, y el salto más gordo el último: es el único que
      // puede acabar el año de un toque.
      expect(semana, lessThan(mes));
      expect(mes, lessThan(temporada));
    });

    testWidgets('en la gratuita sale con candado y no simula nada', (
      tester,
    ) async {
      permisos = Permisos(edicion: Edicion.gratis);
      await abrirCalendario(tester);

      // Se enseña igualmente: esconderlo dejaría sin ver lo que se ofrece.
      expect(find.text('TEMPORADA ENTERA'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);

      await tester.tap(find.text('TEMPORADA ENTERA'));
      await tester.pumpAndSettle();

      final r = await (db.select(
        db.resultadoTemporada,
      )..where((t) => t.equipo.equals('DEN'))).getSingle();
      expect(r.victorias + r.derrotas, 0, reason: 'bloqueado es bloqueado');
    });

    testWidgets('con la versión completa, el botón simula el año entero', (
      tester,
    ) async {
      permisos = Permisos();
      await abrirCalendario(tester);
      expect(find.byIcon(Icons.fast_forward), findsOneWidget);

      Future<int> jugados() async {
        final r = await (db.select(
          db.resultadoTemporada,
        )..where((t) => t.equipo.equals('DEN'))).getSingle();
        return r.victorias + r.derrotas;
      }

      expect(await jugados(), 0);
      await tester.tap(find.text('TEMPORADA ENTERA'));

      // Con esperas de VERDAD, no solo adelantando el reloj falso: la
      // simulación es asíncrona y necesita tiempo real para avanzar.
      await tester.runAsync(() async {
        for (var i = 0; i < 200; i++) {
          if (await jugados() > 20) return;
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();

      // Veinte partidos y no los 82: lo que se prueba aquí es que el botón
      // dispara la simulación del AÑO y no un partido suelto, y para eso
      // basta verla arrancar y correr. Esperar al último partido serían
      // veinte segundos de test sin comprobar nada nuevo.
      expect(
        await jugados(),
        greaterThan(20),
        reason:
            'el botón del calendario tiene que simular el año entero, '
            'no un partido',
      );
    });
  });

  testWidgets('«temporada entera» no juega el play-in ni los playoffs', (
    tester,
  ) async {
    // La regla: la simulación de temporada es de la LIGA REGULAR. El
    // play-in y el bracket se juegan desde el panel de playoffs, uno a
    // uno o de golpe, pero siempre porque el jugador lo pide — nunca de
    // rebote al simular el año.
    permisos = Permisos();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarioScreen(db: db, equipoUsuario: 'DEN', random: Random(7)),
      ),
    );
    await _esperarA(tester, find.text('1 SEMANA'));

    Future<int> jugados() async {
      final r = await (db.select(
        db.resultadoTemporada,
      )..where((t) => t.equipo.equals('DEN'))).getSingle();
      return r.victorias + r.derrotas;
    }

    await tester.tap(find.text('TEMPORADA ENTERA'));
    await tester.runAsync(() async {
      for (var i = 0; i < 400; i++) {
        // Si un evento para la simulación, se le contesta «seguir». Es
        // parte de lo que se comprueba: simular el año no se salta las
        // decisiones del camino.
        final seguir = find.text('SEGUIR SIMULANDO');
        if (seguir.evaluate().isNotEmpty) await tester.tap(seguir);
        await Future<void>.delayed(const Duration(milliseconds: 30));
        await tester.pump();
      }
    });
    await tester.pumpAndSettle();

    expect(
      await jugados(),
      greaterThan(40),
      reason: 'tiene que haber simulado media temporada larga',
    );

    // Y ni un solo partido de postemporada. Da igual dónde se haya
    // quedado la liga regular: lo que no puede es haber tocado el cuadro.
    final series = await db.select(db.seriesPlayoffs).get();
    for (final s in series) {
      expect(
        s.victoriasA + s.victoriasB,
        0,
        reason:
            'ronda ${s.ronda}: simular la temporada no puede jugar la '
            'postemporada por su cuenta',
      );
    }
  });
}
