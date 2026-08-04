import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/features/playoffs/playoffs_screen.dart';

/// Verifica que el bracket visual (Stack + CustomPainter con geometría a
/// mano) se pueda pintar sin errores de layout, tanto a mitad de playoffs
/// (con huecos todavía sin resolver, etiquetados con el nombre de su
/// ronda) como con la Final NBA ya decidida — son los dos casos que
/// `flutter analyze` no puede detectar (overflows, off-by-one en las
/// coordenadas del CustomPainter, etc.).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');

    // El campeón de la Final NBA se apunta también en el registro
    // compartido entre partidas (campeones_repository.dart); en un test se
    // sustituye por uno en memoria para no depender de `path_provider`.
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;

    final equipos = await db.select(db.resultadoTemporada).get();
    for (var i = 0; i < equipos.length; i++) {
      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals(equipos[i].equipo)))
          .write(ResultadoTemporadaCompanion(
        victorias: Value(82 - i),
        derrotas: Value(i),
      ));
    }

    // DEN, el equipo del usuario, con el peor récord de la liga: así queda
    // fuera del play-in de forma determinista y los tests pueden dar por
    // hecho que no es campeón (el diálogo tiene una versión distinta,
    // efusiva, cuando ganas tú).
    await (db.update(db.resultadoTemporada)
          ..where((t) => t.equipo.equals('DEN')))
        .write(const ResultadoTemporadaCompanion(
            victorias: Value(5), derrotas: Value(77)));
  });

  tearDown(() async {
    await db.close();
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: PlayoffsScreen(db: db, equipoUsuario: 'DEN'),
    ));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('el bracket se pinta sin excepciones justo tras sembrar '
      'los playoffs (con huecos todavía pendientes de play-in)',
      (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Play-In'), findsOneWidget);
    expect(find.text('Bracket'), findsOneWidget);
    // Las cajas todavía sin resolver muestran el nombre de su ronda en vez
    // de una etiqueta genérica.
    expect(find.textContaining('Semifinal de conferencia'), findsWidgets);
    expect(find.textContaining('Final de conferencia'), findsWidgets);
  });

  testWidgets('el bracket se pinta sin excepciones con los playoffs '
      'completos y muestra el campeón', (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await simularPlayoffsCompletos(db);
    await pump(tester);

    expect(tester.takeException(), isNull);
    // El titular es del equipo y en plural: "Campeones de la NBA 2026-27".
    expect(find.textContaining('Campeones de la NBA'), findsOneWidget);
  });

  testWidgets('tocar una serie ya jugada abre sus estadísticas: el partido '
      'suelto del play-in va directo al boxscore y una serie al mejor de 7 '
      'enseña antes la lista', (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await simularPlayoffsCompletos(db);
    await pump(tester);

    final series = await leerSeries(db);

    final playIn = series.firstWhere((s) => s.ronda == 0);
    await tester.tap(find.byKey(ValueKey('playin-${playIn.id}')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Resultado del partido'), findsOneWidget);

    // La transición de vuelta tiene que terminar del todo: mientras la
    // pantalla anterior se desvanece sigue capturando los toques.
    await tester.pageBack();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final finalNba = series.firstWhere((s) => s.conferencia == 'Final');
    await tester.tap(find.byKey(ValueKey('serie-${finalNba.id}')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Partidos de la serie'), findsOneWidget);
  });

  testWidgets('al decidirse la Final NBA en pantalla, sale el diálogo de '
      'campeón (no solo el banner)', (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await pump(tester);

    // DEN no está implicado en los playoffs de este fixture (récords
    // ficticios que no le dan un puesto), así que solo hace falta
    // "Simular todo" para llegar al campeón dentro del propio widget test.
    await tester.tap(find.widgetWithText(FilledButton, 'Simular todo'));
    await tester.pump();
    // Deja completar la animación de entrada del diálogo.
    await tester.pump(const Duration(milliseconds: 300));

    // DEN no es el campeón en este fixture, así que sale la versión
    // informativa del diálogo (la efusiva, con confeti, es solo para tu
    // equipo). El titular sale dos veces: en el diálogo y en el banner.
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.textContaining('Campeones de la NBA'), findsWidgets);
    expect(find.text('¡CAMPEONES!'), findsNothing);
  });

  testWidgets('la primera ronda no se puede jugar mientras quede play-in',
      (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await pump(tester);

    expect(find.textContaining('no empieza hasta que el Play-In'),
        findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Resolver el Play-In'),
        findsOneWidget);
  });
}
