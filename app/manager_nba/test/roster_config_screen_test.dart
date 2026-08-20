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

    await tester.tap(find.text('ALINEAR AUTOMÁTICAMENTE'));
    await tester.pumpAndSettle();

    // Cada hueco y cada nombre llevan clave propia, que no depende ni del
    // idioma ni de cómo esté maquetada la fila.
    Finder hueco(String posicion, String clave) =>
        find.byKey(ValueKey('hueco-$posicion-$clave'));

    String nombreEn(String posicion, String clave) => tester
        .widget<Text>(find.byKey(ValueKey('nombre-$posicion-$clave')))
        .data!;

    for (final posicion in ['PG', 'SG', 'SF', 'PF', 'C']) {
      expect(hueco(posicion, 'titular'), findsOneWidget);
    }

    final titularPg = nombreEn('PG', 'titular');
    final titularSg = nombreEn('SG', 'titular');
    expect(titularPg, isNot(titularSg));

    // En el hueco de titular escolta, elige al que ahora mismo es el base
    // titular: deben intercambiarse.
    await tester.tap(hueco('SG', 'titular'));
    await tester.pumpAndSettle();

    // El diálogo escribe el nombre tal cual ("Yamal Mulray (PG, 89)") y la
    // pantalla en mayúsculas, así que se compara sin distinguir caja.
    final opcion = find
        .byWidgetPredicate((w) =>
            w is Text &&
            w.data != null &&
            w.data!.toUpperCase().contains(titularPg))
        .last;
    await tester.ensureVisible(opcion);
    await tester.pumpAndSettle();
    await tester.tap(opcion);
    await tester.pumpAndSettle();

    expect(nombreEn('SG', 'titular'), titularPg,
        reason: 'el base titular debería haber pasado a escolta titular');
    expect(nombreEn('PG', 'titular'), titularSg,
        reason: 'y el escolta titular debería haber ocupado su hueco');

    // La rotación sigue completa: el intercambio no deja huecos vacíos, así
    // que el botón de guardar tiene que seguir pulsable.
    expect(
        tester
            .widget<InkWell>(
                find.widgetWithText(InkWell, 'GUARDAR ROTACIÓN'))
            .onTap,
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

    await tester.tap(find.text('ESTADÍSTICAS'));
    await tester.pumpAndSettle();

    expect(find.textContaining('pts ·'), findsWidgets);
    expect(find.textContaining('20.0 pts'), findsOneWidget);
  });
}
