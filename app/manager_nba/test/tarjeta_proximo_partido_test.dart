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

/// La tarjeta de próximo partido del menú principal: qué enseña, cuándo
/// desaparece, y que tocar "Simular" de verdad simula sin salir del hub.
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
      home: HomeHubScreen(db: db, equipo: 'DEN'),
    ));
    await tester.pumpAndSettle();

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
      home: HomeHubScreen(db: db, equipo: 'DEN'),
    ));
    await tester.pumpAndSettle();

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
      home: HomeHubScreen(db: db, equipo: 'DEN'),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SIMULAR 1 PARTIDO'));
    await tester.pumpAndSettle();

    // Un partido jugado te lleva directo al resumen, sin pasar por el
    // Calendario: es justo lo que permite no tener que salir del menú.
    expect(find.byType(ResumenSimulacionScreen), findsOneWidget,
        reason: 'tras simular hay resultado, así que se enseña el resumen');

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(await partidosJugadosDeDen(), antes + 1,
        reason: 'de vuelta en el hub, el récord ya cuenta el partido nuevo');
    expect(tester.takeException(), isNull);
  });
}
