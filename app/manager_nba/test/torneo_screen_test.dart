import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/features/torneo/torneo_screen.dart';

Future<void> _guardarRotacionAutomatica(AppDatabase db, String equipo) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo))
        ..orderBy([(t) => OrderingTerm.desc(t.media)]))
      .get();
  await guardarRotacion(db, generarRotacionAutomatica(plantilla));
}

Future<void> _simularHasta(AppDatabase db, String equipo, DateTime diaObjetivo) async {
  int? ignorar;
  while (true) {
    final tramo =
        await simularTramo(db, equipo, diaObjetivo, eventoIdAIgnorar: ignorar);
    if (tramo.eventoBloqueante == null) break;
    ignorar = tramo.eventoBloqueante!.id;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TorneoScreen es solo consulta: enseña el cuadro con cuartos y '
      'semifinal ya resueltos y no ofrece ningún botón de simular (la Final '
      'se juega desde el calendario)', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    // Todo esto es E/S real (carga de asset, muchos partidos simulados de
    // los 30 equipos) — hace falta runAsync para salir de la zona
    // "fake async" en la que corre el cuerpo de testWidgets; si no, se
    // queda colgado indefinidamente en vez de completarse.
    await tester.runAsync(() async {
      await importarJugadoresSiHaceFalta(db);
      await crearFranquicia(db, 'DEN');
      await _guardarRotacionAutomatica(db, 'DEN');

      final partidos = await leerPartidos(db, 'DEN');
      final anioTemporada = partidos.first.fecha.year;
      await _simularHasta(db, 'DEN', DateTime(anioTemporada, 12, 17));
    });

    tester.view.physicalSize = const Size(1024, 1366);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: TorneoScreen(db: db, equipoUsuario: 'DEN'),
    ));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    // El cuadro se lee como un bracket: cada mitad dice de qué conferencia
    // es y las columnas llevan el nombre de su ronda (una por lado).
    expect(find.text('CONFERENCIA OESTE'), findsOneWidget);
    expect(find.text('CONFERENCIA ESTE'), findsOneWidget);
    expect(find.text('Cuartos'), findsNWidgets(2));
    expect(find.text('Semifinal'), findsNWidgets(2));
    expect(find.text('Final'), findsOneWidget);

    // Nada de simular desde aquí.
    expect(find.widgetWithText(OutlinedButton, 'Simular ronda completa'),
        findsNothing);
    expect(find.widgetWithText(FilledButton, 'Simular todo'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Simular'), findsNothing);

    // Cuartos y semis (6 series) ya están decididos: cada uno marca a su
    // ganador.
    expect(find.byIcon(Icons.check), findsAtLeastNWidgets(6));

    await db.close();
  });
}
