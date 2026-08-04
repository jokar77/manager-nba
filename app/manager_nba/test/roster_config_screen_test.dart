import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/features/roster/roster_config_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  // El import lee un asset (E/S real): va en setUp, que corre fuera de la
  // zona "fake async" de testWidgets.
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('elegir para un puesto a un jugador que ya está en otro los '
      'intercambia, sin tener que vaciar huecos a mano',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: RosterConfigScreen(
        db: db,
        equipo: 'LAL',
        esConfiguracionInicial: false,
        onGuardado: () {},
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alinear automáticamente'));
    await tester.pumpAndSettle();

    final titulares = find.byWidgetPredicate((w) =>
        w is ListTile &&
        w.title is Text &&
        (w.title as Text).data!.startsWith('Titular:'));
    expect(titulares, findsNWidgets(5));

    String textoTitular(int i) =>
        ((tester.widgetList<ListTile>(titulares).elementAt(i)).title as Text)
            .data!;

    final titularPgAntes = textoTitular(0);
    final titularSgAntes = textoTitular(1);
    expect(titularPgAntes, isNot(titularSgAntes));

    // El nombre va antes del paréntesis de posición.
    String soloNombre(String texto) =>
        texto.substring(texto.indexOf(': ') + 2, texto.lastIndexOf(' (')).trim();
    final nombrePg = soloNombre(titularPgAntes);

    // En el hueco de titular escolta, elige al que ahora mismo es el base
    // titular: deben intercambiarse.
    await tester.tap(titulares.at(1));
    await tester.pumpAndSettle();

    final opcion = find.textContaining(nombrePg).last;
    await tester.ensureVisible(opcion);
    await tester.pumpAndSettle();
    await tester.tap(opcion);
    await tester.pumpAndSettle();

    expect(soloNombre(textoTitular(1)), nombrePg,
        reason: 'el base titular debería haber pasado a escolta titular');
    expect(soloNombre(textoTitular(0)), soloNombre(titularSgAntes),
        reason: 'y el escolta titular debería haber ocupado su hueco');

    // La rotación sigue completa: el intercambio no deja huecos vacíos.
    expect(
        tester.widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Guardar rotación')).onPressed,
        isNotNull);
  });

  testWidgets(
      'las estadísticas de la temporada viven en su propia pestaña, no '
      'como subtítulo bajo el nombre en Alineación',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final jugador = (await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('LAL')))
        .get())
      .first;
    await db.into(db.estadisticasTemporadaJugador).insert(
        EstadisticasTemporadaJugadorCompanion.insert(
          jugadorId: Value(jugador.id),
          partidosJugados: const Value(10),
          puntosTotales: const Value(200),
          asistenciasTotales: const Value(50),
          rebotesTotales: const Value(80),
        ));

    await tester.pumpWidget(MaterialApp(
      home: RosterConfigScreen(
        db: db,
        equipo: 'LAL',
        esConfiguracionInicial: false,
        onGuardado: () {},
      ),
    ));
    await tester.pumpAndSettle();

    // En la pestaña de Alineación (la que se ve por defecto) no debería
    // aparecer ninguna línea de "pts · ast · reb".
    expect(find.textContaining('pts ·'), findsNothing);

    await tester.tap(find.text('Estadísticas'));
    await tester.pumpAndSettle();

    expect(find.textContaining('pts ·'), findsWidgets);
    expect(find.textContaining('20.0 pts'), findsOneWidget);
  });
}
