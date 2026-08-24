import 'dart:async';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/entrenadores_importer.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart'
    show fechaActualDeLaLiga, leerPartidos, simularTramo;
import 'package:manager_nba/domain/entrenadores_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/permisos.dart';
import 'package:manager_nba/features/calendario/calendario_screen.dart';
import 'package:manager_nba/features/calendario/simulacion_ui.dart'
    show simularHastaConDialogo;

/// "Simular temporada entera": el botón vive en la barra de saltos del
/// Calendario, a la derecha del todo (Lista 15 punto 3 — antes se
/// duplicaba en el menú principal, y sobraba ahí: la simulación siempre
/// se ve en el Calendario, así que solo tiene sentido que el botón viva
/// donde se ve avanzar).

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

/// Contesta el diálogo que haya en pantalla con la opción que deja
/// SEGUIR simulando —nunca la que navega a otra pantalla— y devuelve si
/// había alguno.
///
/// Con el paceo por semanas ya arreglado, una simulación larga puede
/// cruzarse con varios tipos de diálogo por el camino: la fecha límite,
/// una oferta entrante, el All-Star, el campeón de la Copa... Cada uno
/// tiene su propio texto de "seguir" y de "ir a ver/hacer otra cosa", y
/// las dos NO son intercambiables — la fecha límite, por ejemplo, tiene el
/// "seguir" como botón PRINCIPAL y el "ir a Traspasos" como secundario, al
/// revés que los demás. Por eso se buscan los textos conocidos de "seguir"
/// explícitamente, antes que nada genérico.
///
/// El evento de vestuario (narrativo) es distinto: sus opciones son
/// decisiones de guion sin un "correcto" fijo, así que ahí vale cualquiera
/// — se coge la primera que haya.
Future<bool> _avanzarUnDialogoSiHay(WidgetTester tester) async {
  // Ojo a las mayúsculas: los `BotonDialogo*` de `estilo.dart` pasan su
  // texto por `mayus()`, pero el diálogo de campeón (`campeon_dialog.dart`)
  // pinta "Cerrar" y "Ver estadísticas" directamente, sin mayus. Se
  // buscan las dos formas.
  for (final boton in ['SEGUIR SIMULANDO', 'MÁS TARDE', 'CERRAR', 'Cerrar']) {
    final finder = find.text(boton);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder.first);
      return true;
    }
  }
  final dialogo = find.byType(AlertDialog);
  if (dialogo.evaluate().isEmpty) return false;
  final opciones = find.descendant(
    of: dialogo.first,
    matching: find.byWidgetPredicate(
      (w) => w is FilledButton || w is TextButton,
    ),
  );
  if (opciones.evaluate().isEmpty) return false;
  await tester.tap(opciones.first);
  return true;
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
      // simulación es asíncrona y necesita tiempo real para avanzar. Y con
      // el paceo por semanas ya arreglado —que es justo lo que se acaba de
      // corregir en esta sesión: antes la primera vuelta se tragaba el año
      // entero de golpe—, puede cruzarse con algún diálogo (fecha límite,
      // oferta, All-Star, campeón) antes de llegar al puñado de partidos
      // que aquí se exige: se contesta con la opción de seguir, nunca la
      // que navega a otra pantalla.
      await tester.runAsync(() async {
        for (var i = 0; i < 400; i++) {
          if (await jugados() > 8) return;
          await _avanzarUnDialogoSiHay(tester);
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();

      // Un puñado de partidos y no los 82: lo que se prueba aquí es que el
      // botón dispara la simulación del AÑO y no un partido suelto, y para
      // eso basta verla arrancar y correr varias semanas. El número es
      // deliberadamente bajo —antes se pedían 20— porque con el paceo
      // semanal arreglado cada partido cuesta una llamada real a la base
      // de datos, y pedir de más aquí es alargar el test sin comprobar
      // nada que no compruebe ya el resto del fichero.
      expect(
        await jugados(),
        greaterThan(8),
        reason:
            'el botón del calendario tiene que simular el año entero, '
            'no un partido',
      );
    });
  });
  testWidgets(
    'el primer tramo pacea semana a semana, sin tragarse el mes entero de '
    'golpe',
    (tester) async {
      // Aquí estaba el bug real de "temporada entera se planta sin avisar
      // a mitad de año": `cursor` arrancaba en `null`, y con `cursor ==
      // null` la primera vuelta del bucle saltaba derecha al `diaObjetivo`
      // completo, sin pasar por ninguna semana intermedia. Un "simular 1
      // mes" tragaba el mes entero en una sola llamada a `simularTramo`,
      // así que cualquier oferta o evento de esa semana intermedia no te
      // paraba ahí — se amontonaba hasta el primer tope real (una fecha
      // límite) o hasta el final del tramo.
      //
      // Se pide solo diez días —poco más de una semana— para no arriesgar
      // a tropezar con una oferta o un evento real: eso abriría un
      // diálogo que aquí nadie contesta. Con diez días bastan dos vueltas
      // para probar el paceo sin ese riesgo.
      permisos = Permisos();

      final contextCompletado = Completer<BuildContext>();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              if (!contextCompletado.isCompleted) {
                contextCompletado.complete(context);
              }
              return const SizedBox();
            },
          ),
        ),
      );
      final context = await contextCompletado.future;

      final hoy = await fechaActualDeLaLiga(db);
      expect(hoy, isNotNull);

      var vueltas = 0;
      // `simularHastaConDialogo` hace trabajo asíncrono de verdad (E/S
      // contra la base). Igual que en el resto del fichero, hay que
      // envolverlo en `runAsync`: awaitar Futures reales directamente en
      // el cuerpo de `testWidgets` se cuelga para siempre, porque el reloj
      // falso del test nunca los hace avanzar.
      await tester.runAsync(
        () => simularHastaConDialogo(
          context,
          db,
          'DEN',
          hoy!.add(const Duration(days: 10)),
          random: Random(3),
          onProgreso: (_) => vueltas++,
        ),
      );

      // Diez días son más de un `pasoDeParada` (siete): con el paceo
      // arreglado hacen falta al menos dos vueltas —una para la primera
      // semana, otra para los tres días que sobran—. Antes del arreglo,
      // con `cursor == null`, la primera vuelta saltaba derecha a los diez
      // días completos y `onProgreso` solo se llamaba una vez.
      expect(
        vueltas,
        greaterThan(1),
        reason:
            'la primera vuelta debería pacear en semanas, no tragarse '
            'todo el rango pedido en una sola llamada a simularTramo',
      );
    },
  );

  test('«temporada entera» simula la liga regular sin tocar el play-in ni los '
      'playoffs', () async {
    // La regla: la simulación de temporada es de la LIGA REGULAR. El
    // play-in y el bracket se juegan desde el panel de playoffs, uno a
    // uno o de golpe, pero siempre porque el jugador lo pide — nunca de
    // rebote al simular el año.
    //
    // A nivel de repositorio y no de pantalla, con el mismo patrón que
    // `temporada_con_mercado_test.dart`: contestar "seguir simulando" a
    // cada fecha límite es simplemente ignorar su evento y seguir. Así
    // se evita tener que interactuar con los otros diálogos de la UI
    // (ofertas, All-Star, campeón de Copa), que no son parte de lo que
    // se está comprobando aquí.
    final fechas = (await leerPartidos(db, 'DEN')).map((p) => p.fecha).toList();
    final ultima = fechas.last;

    int? ignorar;
    while (true) {
      final tramo = await simularTramo(
        db,
        'DEN',
        ultima,
        eventoIdAIgnorar: ignorar,
      );
      if (tramo.eventoBloqueante == null) break;
      ignorar = tramo.eventoBloqueante!.id;
    }

    final r = await (db.select(
      db.resultadoTemporada,
    )..where((t) => t.equipo.equals('DEN'))).getSingle();
    // Al menos los 82 de la liga regular. Puede haber algún partido más
    // si el equipo llegó a la Final de la NBA Cup —esa sí es un partido
    // extra de verdad, fuera de los 82—, así que no se fija el número
    // exacto: lo que importa aquí es que la liga regular terminó y que la
    // postemporada de verdad (play-in y playoffs) sigue sin tocar.
    expect(
      r.victorias + r.derrotas,
      greaterThanOrEqualTo(82),
      reason: 'tiene que acabar la liga regular entera',
    );

    // Ni un solo partido de postemporada jugado.
    final series = await db.select(db.seriesPlayoffs).get();
    expect(
      series,
      isNotEmpty,
      reason: 'al acabar la regular se siembra el cuadro',
    );
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
