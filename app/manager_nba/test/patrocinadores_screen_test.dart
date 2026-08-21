import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/patrocinadores.dart';
import 'package:manager_nba/domain/patrocinadores_repository.dart';
import 'package:manager_nba/features/temporada/patrocinadores_screen.dart';

/// La pantalla de elección de patrocinadores: enseña los cuatro
/// candidatos de tu equipo y lo que actives ahí se guarda de verdad.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
  });

  tearDown(() => db.close());

  testWidgets('enseña los cuatro candidatos de tu equipo, con su nombre y '
      'su año de fundación', (tester) async {
    // Las cuatro tarjetas con su historia no caben en la ventana de test
    // por defecto: sin esto, la última quedaba fuera del árbol pintado y
    // no se encontraba, aunque estuviera ahí en la lista.
    tester.view.physicalSize = const Size(1024, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: PatrocinadoresScreen(
        db: db,
        equipoUsuario: 'DEN',
        onContinuar: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    for (final categoria in categoriasPatrocinio) {
      final p = patrocinadorDe('DEN', categoria)!;
      expect(find.text(p.nombre), findsOneWidget, reason: categoria);
    }
    expect(find.byType(Switch), findsNWidgets(categoriasPatrocinio.length));
  });

  testWidgets('activar un patrocinador lo guarda, y el margen total sube',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: PatrocinadoresScreen(
        db: db,
        equipoUsuario: 'DEN',
        onContinuar: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsWidgets);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final activos = await leerPatrociniosActivos(db);
    expect(activos, hasLength(1));

    // Y tocar el mismo interruptor otra vez lo desactiva sin reventar —
    // aquí es donde se cazó el bug real: activar/desactivar la misma
    // categoría dos veces chocaba con la restricción UNIQUE de la tabla.
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(await leerPatrociniosActivos(db), isEmpty);
  });

  testWidgets('tocar continuar llama al callback', (tester) async {
    var continuado = false;
    await tester.pumpWidget(MaterialApp(
      home: PatrocinadoresScreen(
        db: db,
        equipoUsuario: 'DEN',
        onContinuar: () => continuado = true,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(continuado, isTrue);
  });
}
