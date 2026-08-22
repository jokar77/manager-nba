import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/entrenadores_importer.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/entrenadores_repository.dart';
import 'package:manager_nba/domain/equipos_info.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/features/calendario/resumen_simulacion_screen.dart';
import 'package:manager_nba/features/hub/home_hub_screen.dart';

// La tarjeta de próximo partido del menú principal: qué enseña, cuándo
// desaparece, y que tocar "Simular" de verdad simula sin salir del hub.
//
// OJO CON `pumpAndSettle` EN ESTE FICHERO. Era EL test inestable de la
// suite: pasaba siempre en local y tumbó la publicación en CI.
//
// El motivo: `testWidgets` corre en una zona de *fake async*, y
// `pumpAndSettle` solo adelanta los temporizadores FALSOS. Pero cargar el
// hub y simular un partido son futures de VERDAD contra SQLite, que se
// resuelven fuera de esa zona. En una máquina rápida y sin carga daba
// tiempo a que resolvieran solos antes del primer pump y todo parecía
// determinista; en la de CI —más lenta y con treinta ficheros de test a la
// vez— no llegaban, y el resumen todavía no estaba pintado cuando se
// comprobaba.
//
// Media solución es `_esperarA`: salir de la zona de fake async con
// `runAsync` y dar vueltas hasta que lo que se espera esté de verdad en
// pantalla. Es el mismo patrón que `flujo_completo_test.dart`.
//
// LA OTRA MEDIA, Y LA QUE DE VERDAD LO ARREGLÓ (2026-08-22), ES EL
// `random: Random(1)`. NO LO QUITES.
//
// Mientras simulas, el juego decide al azar si te llega una oferta de
// traspaso o si salta un evento de vestuario. Las dos cosas abren un
// diálogo y PARAN la simulación esperando respuesta; en un test no hay
// nadie que conteste, así que se queda ahí colgado y ninguna espera del
// mundo lo salva. Con `Random()` sin semilla pasaba unas veces sí y otras
// no: de ahí la fama de inestable de este fichero.
//
// La semilla viaja HomeHubScreen -> simularHastaConDialogo -> las dos
// funciones que tiran el dado. En el juego se deja a null, que es lo que
// hace que cada partida sea distinta.

/// Espera a que [queSalga] esté pintado de verdad, dándole tiempo al
/// trabajo real contra la base de datos. Ver la nota de arriba.
///
/// Que el bucle se rinda EN SILENCIO al agotar las vueltas parece un
/// descuido, pero es lo correcto: solo le está dando margen a la parte
/// REAL del trabajo. La otra mitad —la animación del diálogo de
/// simulación, la transición a la pantalla de resumen— cuelga de
/// temporizadores FALSOS, que dentro de `runAsync` no avanzan por mucho
/// que se espere. Quien la remata es el `pumpAndSettle` de abajo. Agotar
/// las vueltas significa "hasta aquí llegó lo real, sigue tú".
///
/// Dos cosas comprobadas al intentar mejorar esto (2026-08-22):
///
///  - Pasarle una duración a ese `pump()`, para mover el reloj falso desde
///    dentro, CUELGA el test para siempre: `pump` con duración no está
///    soportado en `runAsync`. No lo intentes otra vez.
///  - Convertir el agotamiento en un `fail()` hace que el test falle en
///    esta espera en vez de en el `expect`. Puede ser preferible para
///    diagnosticar, pero no arregla nada por sí solo.
Future<void> _esperarA(WidgetTester tester, Finder queSalga) async {
  await tester.runAsync(() async {
    for (var i = 0; i < 100; i++) {
      if (queSalga.evaluate().isNotEmpty) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }
  });
  // Y ya dentro de la zona falsa otra vez, se rematan las animaciones.
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    // Sin esto, el primer intento de simular te manda a fichar un
    // entrenador (ver `_asegurarQueHayEntrenador` en simulacion_ui.dart):
    // sería una interstitial que estos tests no están probando.
    await importarEntrenadoresSiHaceFalta(db);
    await asignarEntrenadoresQueFalten(db);

    // Sin una rotación completa, `simularTramo` revienta con "La rotación
    // de DEN no está completa" (construirEquipoUsuarioParaFecha lo exige):
    // la pantalla de alineación es paso obligatorio del onboarding, y aquí
    // se salta directo al hub, así que hay que dejarla puesta a mano.
    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('DEN')))
        .get();
    await guardarRotacion(db, generarRotacionAutomatica(plantilla));
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
      'con partidos pendientes, la tarjeta enseña el rival y si es en '
      'casa o fuera', (tester) async {
    final pendientes = (await leerPartidos(db, 'DEN'))
        .where((p) => !p.jugado)
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final proximo = pendientes.first;

    await tester.pumpWidget(MaterialApp(
      home: HomeHubScreen(db: db, equipo: 'DEN', random: Random(1)),
    ));
    await _esperarA(tester, find.textContaining('PRÓXIMO PARTIDO'));

    expect(find.textContaining('PRÓXIMO PARTIDO'), findsOneWidget);
    expect(find.text(infoDe(proximo.rival).apodo.toUpperCase()),
        findsOneWidget);
    expect(find.textContaining(proximo.esLocal ? 'EN CASA' : 'FUERA'),
        findsOneWidget,
        reason:
            'el rótulo tiene que coincidir con dónde se juega de verdad, '
            'no decir siempre "en casa"');
    expect(find.text('SIMULAR 1 PARTIDO'), findsOneWidget);
  });

  testWidgets(
      'sin partidos pendientes, la tarjeta no aparece (no hay nada que '
      'simular)', (tester) async {
    // Se marcan todos los partidos como jugados sin simular nada de
    // verdad: lo único que se está probando aquí es que la tarjeta lee
    // bien el estado "no queda nada pendiente", no el motor de partidos.
    await db.batch((batch) {
      batch.update(
        db.partidosCalendario,
        const PartidosCalendarioCompanion(jugado: Value(true)),
        where: (t) => t.equipoPropietario.equals('DEN'),
      );
    });

    await tester.pumpWidget(MaterialApp(
      home: HomeHubScreen(db: db, equipo: 'DEN', random: Random(1)),
    ));
    // Aquí se comprueba una AUSENCIA, así que hay que esperar a que el hub
    // haya terminado de cargar: si no, "no está la tarjeta" sería cierto
    // simplemente porque todavía no se ha pintado nada.
    await _esperarA(tester, find.byType(HomeHubScreen));
    await _esperarA(tester, find.text('CALENDARIO'));

    expect(find.textContaining('PRÓXIMO PARTIDO'), findsNothing);
    expect(find.text('SIMULAR 1 PARTIDO'), findsNothing);
  });

  testWidgets(
      'tocar "Simular 1 partido" en la tarjeta simula sin salir del menú '
      'y el récord se actualiza', (tester) async {
    Future<int> partidosJugadosDeDen() async {
      final r = await (db.select(db.resultadoTemporada)
            ..where((t) => t.equipo.equals('DEN')))
          .getSingle();
      return r.victorias + r.derrotas;
    }

    final antes = await partidosJugadosDeDen();

    await tester.pumpWidget(MaterialApp(
      home: HomeHubScreen(db: db, equipo: 'DEN', random: Random(1)),
    ));
    await _esperarA(tester, find.text('SIMULAR 1 PARTIDO'));

    await tester.tap(find.text('SIMULAR 1 PARTIDO'));
    // Simular un partido es trabajo real contra SQLite: aquí es donde
    // `pumpAndSettle` se quedaba corto en CI.
    await _esperarA(tester, find.byType(ResumenSimulacionScreen));

    // Un partido jugado te lleva directo al resumen, sin pasar por el
    // Calendario: es justo lo que permite no tener que salir del menú.
    expect(find.byType(ResumenSimulacionScreen), findsOneWidget,
        reason: 'tras simular hay resultado, así que se enseña el resumen');

    await tester.pageBack();
    await _esperarA(tester, find.byType(HomeHubScreen));

    expect(await partidosJugadosDeDen(), antes + 1,
        reason: 'de vuelta en el hub, el récord ya cuenta el partido nuevo');
    expect(tester.takeException(), isNull);
  });
}
