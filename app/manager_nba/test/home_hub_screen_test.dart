import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/features/hub/home_hub_screen.dart';
import 'package:manager_nba/main.dart' show routeObserver;

// Los destinos del menú se pintan en MAYÚSCULAS desde el rediseño: Flutter
// no tiene el `text-transform` de CSS, así que la mayúscula va en la cadena
// (ver `mayus` en shared/estilo.dart) y es lo que ve `find.text`.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('volver al menú principal desde otra pantalla lo recarga sin '
      'romper la navegación', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [routeObserver],
      home: HomeHubScreen(db: db, equipo: 'DEN'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('CALENDARIO'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    Future<void> abrirOtraPantalla() async {
      navigator.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('otra pantalla')),
      ));
      await tester.pumpAndSettle();
    }

    await abrirOtraPantalla();
    expect(find.text('otra pantalla'), findsOneWidget);

    navigator.pop();
    await tester.pumpAndSettle();

    // El hub notifica al RouteObserver al volver. Si esa notificación
    // revienta (p. ej. un setState que devuelve un Future), la excepción
    // deja el Navigator bloqueado y a partir de ahí no se puede navegar:
    // exactamente el bug de "no me deja volver al menú principal".
    expect(tester.takeException(), isNull);
    expect(find.text('CALENDARIO'), findsOneWidget);

    await abrirOtraPantalla();
    expect(tester.takeException(), isNull);
    expect(find.text('otra pantalla'), findsOneWidget,
        reason: 'la navegación tiene que seguir funcionando tras volver');
  });

  /// El botón de "volver a inicio" (flecha, arriba a la izquierda de la
  /// cabecera) tiene que sacarte del hub y dejarte en lo que hubiera
  /// debajo en la pila — la pantalla de arranque en el juego de verdad
  /// (`StartMenuScreen`, ver `start_menu_screen.dart`), aquí un doble
  /// sencillo. Es un `pop` normal, no un `popUntil` con nombre de ruta:
  /// esto comprueba justo eso, que basta con lo que hay debajo.
  testWidgets('el botón de volver a inicio saca del hub y deja lo de debajo',
      (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [routeObserver],
      home: const Scaffold(body: Text('pantalla de inicio')),
    ));

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => HomeHubScreen(db: db, equipo: 'DEN'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('pantalla de inicio'), findsNothing);
    final boton = find.widgetWithIcon(IconButton, Icons.arrow_back);
    expect(boton, findsOneWidget);

    await tester.tap(boton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('pantalla de inicio'), findsOneWidget);
  });

  /// La cabecera pinta logo, nombre, récord y masa salarial en una franja de
  /// alto fijo: en un móvil estrecho es donde se desborda si algo crece.
  testWidgets('el menú principal cabe en una pantalla de móvil estrecha',
      (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [routeObserver],
      home: HomeHubScreen(db: db, equipo: 'DEN'),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('DEN'), findsWidgets);
    expect(find.text('CALENDARIO'), findsOneWidget);

    // Y todo el menú se recorre con scroll sin que nada desborde.
    for (final destino in ['OFERTAS RECIBIDAS', 'PLAYOFFS', 'LEGADO']) {
      // Se busca la fila pulsable y no el texto suelto: "LEGADO" aparece
      // dos veces, como rótulo de su sección y como destino dentro de ella,
      // y solo el destino es un InkWell.
      final fila = find.widgetWithText(InkWell, destino);
      await tester.dragUntilVisible(
        fila,
        find.byType(CustomScrollView),
        const Offset(0, -120),
      );
      expect(tester.takeException(), isNull, reason: 'al llegar a $destino');
    }
  });
}
