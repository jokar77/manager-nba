import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/features/inicio/start_menu_screen.dart';
import 'package:manager_nba/main.dart' show routeObserver;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() {
    // Las ranuras del menú son ficheros SQLite en la carpeta de documentos;
    // en un test no hay ni carpeta ni `path_provider`, así que se sustituye
    // el almacén por uno en memoria que se comporta igual.
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
  });

  tearDown(() async {
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  /// Deja la ranura [slot] con una partida de [equipo] ya empezada. Es E/S
  /// real (asset + sqlite), así que va fuera de la zona "fake async" de
  /// testWidgets — dentro de ella un await sobre E/S real nunca completa.
  Future<void> partidaEn(int slot, String equipo) async {
    final db = abrirSlot(slot);
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, equipo);
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 1366);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [routeObserver],
      home: const StartMenuScreen(),
    ));
    await tester.pump();
    await tester.pump();
  }

  /// Las ranuras ya no están a la vista de entrada: el menú son tres
  /// opciones y hay que pedirlas. Esto abre la lista.
  /// Los botones del rediseño rotulan en MAYÚSCULAS (ver `mayus` en
  /// shared/estilo.dart); por dentro siguen siendo los de Material, así que
  /// el tipo de widget sigue valiendo para señalarlos.
  Future<void> abrirRanuras(WidgetTester tester, String desde) async {
    await tester.tap(find.widgetWithText(
        desde == 'NUEVA PARTIDA' ? FilledButton : OutlinedButton, desde));
    await tester.pump();
  }

  testWidgets('sin ninguna partida el menú solo ofrece empezar y ajustes; '
      'las ranuras aparecen al pedir una nueva partida',
      (WidgetTester tester) async {
    await pump(tester);

    // El menú corto: nada de ranuras a la vista.
    expect(find.text('Ranura vacía'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'CONTINUAR'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'CARGAR PARTIDA'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'NUEVA PARTIDA'), findsOneWidget);

    await abrirRanuras(tester, 'NUEVA PARTIDA');
    expect(find.text('Ranura vacía'), findsNWidgets(numeroDeSlots));
    expect(find.widgetWithText(OutlinedButton, 'EMPEZAR'),
        findsNWidgets(numeroDeSlots));
  });

  testWidgets('con una partida guardada el menú ofrece continuar y cargar, y '
      'cargar enseña equipo, temporada y récord',
      (WidgetTester tester) async {
    await tester.runAsync(() => partidaEn(2, 'DEN'));
    await pump(tester);

    expect(find.widgetWithText(FilledButton, 'CONTINUAR'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'CARGAR PARTIDA'),
        findsOneWidget);

    await abrirRanuras(tester, 'CARGAR PARTIDA');
    expect(find.text('PARTIDA 2'), findsOneWidget);
    expect(find.textContaining('DENVER'), findsOneWidget);
    expect(find.textContaining('temporada 1'), findsOneWidget);
    // El récord ya no es una frase: es un rótulo y una cifra grande.
    expect(find.text('RÉCORD'), findsOneWidget);
    expect(find.text('0-0'), findsOneWidget);
    expect(find.text('Ranura vacía'), findsNWidgets(numeroDeSlots - 1));
  });

  testWidgets('empezar una partida en otra ranura no toca la que ya tenías',
      (WidgetTester tester) async {
    await tester.runAsync(() async {
      await partidaEn(1, 'DEN');
      await partidaEn(2, 'BOS');
    });
    await pump(tester);
    await abrirRanuras(tester, 'CARGAR PARTIDA');

    expect(find.textContaining('DENVER'), findsOneWidget);
    expect(find.textContaining('BOSTON'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'CONTINUAR'), findsNWidgets(2));
  });

  testWidgets('borrar una ranura pide confirmación y la deja libre sin '
      'tocar la otra partida', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await partidaEn(1, 'DEN');
      await partidaEn(3, 'BOS');
    });
    await pump(tester);
    await abrirRanuras(tester, 'CARGAR PARTIDA');

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    expect(find.text('¿Borrar la partida 1?'), findsOneWidget);

    // Cancelar no borra nada.
    // También en mayúsculas: es un BotonDialogoSecundario.
    await tester.tap(find.text('CANCELAR'));
    await tester.pump();
    expect(find.textContaining('DENVER'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pump();
    // El botón de confirmar borrado va en mayúsculas desde que se
    // convirtió a `BotonDialogoPrincipal` (ver shared/estilo.dart).
    await tester.tap(find.widgetWithText(FilledButton, 'BORRAR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('DENVER'), findsNothing);
    expect(find.textContaining('BOSTON'), findsOneWidget,
        reason: 'la otra partida es intocable');
  });

  testWidgets('continuar entra al menú principal de esa partida',
      (WidgetTester tester) async {
    await tester.runAsync(() => partidaEn(1, 'DEN'));
    await pump(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'CONTINUAR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // El menú principal rotula sus destinos en mayúsculas.
    expect(find.text('CALENDARIO'), findsOneWidget);
  });
}
