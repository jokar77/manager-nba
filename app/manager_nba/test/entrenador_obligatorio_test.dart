import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/entrenadores_importer.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/entrenadores_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/features/mercado/entrenador_screen.dart';

/// Lo que vigila este fichero: que quedarse sin entrenador sea un trámite
/// del que no se sale sin fichar a alguien, y que ese trámite tenga siempre
/// una salida.
///
/// Es el punto 2 de la lista: antes, si te quedabas sin entrenador, la
/// partida seguía como si nada (jugabas sin la ayuda del banquillo y sin
/// que nadie te lo dijera) y lo que se abría era la agencia libre de
/// JUGADORES, que no tiene nada que ver.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  Future<void> montar(WidgetTester tester, {required VoidCallback? seguir}) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    return tester.pumpWidget(MaterialApp(
      home: EntrenadorScreen(
        db: db,
        equipoUsuario: 'DEN',
        onContinuar: seguir,
      ),
    ));
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  testWidgets('sin entrenador, el botón de seguir está apagado y aparece el '
      'de fichar por el mínimo', (tester) async {
    await tester.runAsync(() async {
      await importarJugadoresSiHaceFalta(db);
      await crearFranquicia(db, 'DEN');
      await importarEntrenadoresSiHaceFalta(db);
      await despedirEntrenador(db, 'DEN');
    });

    var seguido = false;
    await montar(tester, seguir: () => seguido = true);
    await tester.pump();
    await tester.pump();

    final seguir = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Continuar'),
          matching: find.byType(FilledButton),
        ));
    expect(seguir.onPressed, isNull,
        reason: 'no se puede salir de aquí sin entrenador');
    expect(find.text('Fichar por el mínimo'), findsOneWidget,
        reason: 'tiene que haber una salida que no dependa del presupuesto');
    expect(seguido, isFalse);
  });

  testWidgets('con entrenador se puede seguir y el botón del mínimo sobra',
      (tester) async {
    await tester.runAsync(() async {
      await importarJugadoresSiHaceFalta(db);
      await crearFranquicia(db, 'DEN');
      await importarEntrenadoresSiHaceFalta(db);
    });

    var seguido = false;
    await montar(tester, seguir: () => seguido = true);
    await tester.pump();
    await tester.pump();

    expect(find.text('Fichar por el mínimo'), findsNothing);
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    expect(seguido, isTrue);
  });

  testWidgets('abierta desde el menú (sin trámite) no sale la barra de abajo',
      (tester) async {
    await tester.runAsync(() async {
      await importarJugadoresSiHaceFalta(db);
      await crearFranquicia(db, 'DEN');
      await importarEntrenadoresSiHaceFalta(db);
      await despedirEntrenador(db, 'DEN');
    });

    await montar(tester, seguir: null);
    await tester.pump();
    await tester.pump();

    expect(find.text('Continuar'), findsNothing);
    expect(find.text('Fichar por el mínimo'), findsNothing);
  });
}
