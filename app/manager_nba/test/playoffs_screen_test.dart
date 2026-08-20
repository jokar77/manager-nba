import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/features/partido/serie_boxscores_screen.dart';
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

  /// El Play-In ocupa una tarjeta grande encima del cuadro, y en cuanto
  /// decide quién es el 7 y el 8 no aporta nada: lo único que hacía era
  /// empujar el bracket hacia abajo cada vez que entrabas a mirar cómo iban
  /// tus playoffs. Sus resultados no se pierden — quedan en las cabezas de
  /// serie del propio cuadro.
  testWidgets('el Play-In desaparece del bracket en cuanto se resuelve',
      (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await pump(tester);
    expect(find.text('Play-In'), findsOneWidget);

    // Por el camino real (el botón), no tocando la base de datos por
    // detrás: así se comprueba también que la pantalla se refresca sola.
    await tester.tap(
        find.widgetWithText(OutlinedButton, 'Resolver el Play-In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Play-In'), findsNothing);
    expect(find.text('Bracket'), findsOneWidget);

    // Y lo que decidía el play-in ya está en el cuadro: la primera ronda
    // tiene rivales de verdad en vez de huecos "por definir".
    final ronda1 = (await leerSeries(db)).firstWhere((s) => s.ronda == 1);
    expect(ronda1.equipoA, isNot(equipoPorDefinir));
    expect(ronda1.equipoB, isNot(equipoPorDefinir));
  });

  testWidgets('tocar una serie ya jugada del cuadro abre la lista de sus '
      'partidos', (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await simularPlayoffsCompletos(db);
    await pump(tester);

    final series = await leerSeries(db);
    final finalNba = series.firstWhere((s) => s.conferencia == 'Final');
    await tester.tap(find.byKey(ValueKey('serie-${finalNba.id}')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('PARTIDOS DE LA SERIE'), findsOneWidget);
  });

  /// Una serie a partido único (el play-in) salta la lista y va directa al
  /// boxscore. Se prueba llamando al helper y no tocando la pantalla porque
  /// el panel del play-in desaparece en cuanto se juega, así que ya no hay
  /// ningún sitio en la UI de playoffs desde donde llegar aquí — pero el
  /// mismo helper lo usa la NBA Cup, que sí tiene eliminatorias a un
  /// partido, y esa bifurcación hay que seguir vigilándola.
  testWidgets('una serie a partido único abre el boxscore directamente',
      (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await simularPlayoffsCompletos(db);
    final playIn = (await leerSeries(db)).firstWhere((s) => s.ronda == 0);

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => abrirEstadisticasDeSerie(context, db,
                origen: 'playoffs', serieId: playIn.id),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('RESULTADO DEL PARTIDO'), findsOneWidget);
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
