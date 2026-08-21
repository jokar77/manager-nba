import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/features/roster/roster_config_screen.dart';

/// El selector de sexto hombre en la pantalla de alineación: se ve junto a
/// las estrellas de ataque y defensa, y lo que elijas ahí de verdad se
/// guarda en la rotación.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
  });

  tearDown(() => db.close());

  testWidgets(
      'alinear automáticamente marca un sexto hombre, y guardar lo deja en '
      'la rotación', (tester) async {
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

    expect(find.text('SEXTO HOMBRE'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('GUARDAR ROTACIÓN'));
    await tester.tap(find.text('GUARDAR ROTACIÓN'));
    await tester.pumpAndSettle();

    final guardada = await leerRotacion(db);
    final sextos = guardada.where((f) => f.esSextoHombre).toList();
    expect(sextos, hasLength(1),
        reason: 'alinear automáticamente ya elige uno, y guardar lo '
            'conserva');
    expect(sextos.first.esTitular, isFalse);
  });
}
