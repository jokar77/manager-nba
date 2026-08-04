import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/main.dart';

/// Prueba de extremo a extremo del flujo completo, sin necesitar un
/// emulador: menú de partidas -> empezar en una ranura -> elegir equipo ->
/// vista previa de plantilla -> rellena la alineación por posiciones (10
/// huecos) -> empieza la temporada -> menú principal -> Calendario ->
/// "Simular 1 partido" -> resumen con el resultado.
void main() {
  testWidgets('flujo completo: menú de inicio, onboarding, alineación por '
      'posiciones, calendario y simulación', (WidgetTester tester) async {
    // Viewport tipo iPad, igual que en el resto de pruebas de UI: el
    // tamaño de test por defecto (800x600) se queda corto para la
    // cuadrícula del calendario y la lista de 5 puestos.
    tester.view.physicalSize = const Size(1024, 1366);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Las partidas guardadas son ficheros en la carpeta de documentos; en
    // un test se sustituyen por bases en memoria.
    final almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
    addTearDown(() async {
      await almacen.cerrarTodo();
      almacenDeSlots = AlmacenDeSlotsEnDisco();
    });

    await tester.pumpWidget(ManagerNbaApp(ajustesDb: abrirAjustes()));

    // Siempre via runAsync: testWidgets corre en una zona de "fake async"
    // donde un Future.delayed real nunca llega a completarse salvo que se
    // salga de esa zona (afecta tanto a la carga real del asset como a
    // cualquier E/S real posterior).
    Future<void> esperarTexto(String texto, {bool contiene = false}) async {
      await tester.runAsync(() async {
        for (var i = 0; i < 50; i++) {
          final encontrado = contiene
              ? find.textContaining(texto).evaluate().isNotEmpty
              : find.text(texto).evaluate().isNotEmpty;
          if (encontrado) break;
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        }
      });
    }

    // 1) Menú de inicio: se pide partida nueva y ahí salen las ranuras; se
    // estrena la primera.
    await esperarTexto('Nueva partida');
    await tester.tap(find.widgetWithText(FilledButton, 'Nueva partida'));
    await tester.pump();
    await esperarTexto('Ranura vacía');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Empezar').first);
    await tester.pump();

    // 2) Selección de equipo (import real del dataset) -> Denver.
    await esperarTexto('Denver', contiene: true);
    await tester.tap(find.textContaining('Denver'));
    await tester.pump();

    // 3) Vista previa de la plantilla -> confirmar.
    await esperarTexto('Elegir este equipo');
    await tester.tap(find.text('Elegir este equipo'));
    await tester.pump();

    // 4) Alineación por posiciones: 10 huecos (titular+suplente x 5
    // puestos), todos vacíos al principio.
    await esperarTexto('Empezar temporada');
    expect(find.textContaining('elegir jugador'), findsNWidgets(10));

    for (var i = 0; i < 10; i++) {
      // El hueco que toca puede haber quedado fuera de pantalla según cómo
      // de larga sea la lista, y entonces el tap no llega al widget y el
      // diálogo no se abre. Se sube a la vista primero: sin esto el test
      // dependía de la composición del dataset (al actualizarlo contra
      // 2kratings.com el último hueco caía fuera y el diálogo salía vacío).
      final hueco = find.textContaining('elegir jugador').first;
      await tester.ensureVisible(hueco);
      await tester.pumpAndSettle();
      await tester.tap(hueco);
      await tester.pumpAndSettle();

      final opciones = find.byType(SimpleDialogOption);
      final widgets = tester.widgetList<SimpleDialogOption>(opciones).toList();
      // Ya no hay opciones deshabilitadas: elegir a alguien que está en
      // otro hueco simplemente los intercambia. Por eso aquí se coge un
      // jugador distinto en cada vuelta (la lista va ordenada por media).
      widgets[i].onPressed!();
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('elegir jugador'), findsNothing);

    // 5) Guardar rotación -> arranca la temporada -> menú principal.
    final botonEmpezar =
        find.widgetWithText(FilledButton, 'Empezar temporada');
    expect(tester.widget<FilledButton>(botonEmpezar).onPressed, isNotNull);
    await tester.tap(botonEmpezar);
    await tester.pump();

    await esperarTexto('Calendario');
    expect(find.text('Tu equipo'), findsOneWidget);
    expect(find.text('Clasificación'), findsOneWidget);

    // Premios y Playoffs existen pero están deshabilitados hasta terminar
    // la temporada regular (82 partidos) — aquí solo se ha creado la
    // franquicia, ninguno se ha jugado todavía.
    await esperarTexto('Premios');
    expect(
      find.text('Se desbloquea al terminar la temporada regular'),
      findsNWidgets(2), // Premios y Playoffs
    );

    // 6) Entrar al calendario.
    await tester.tap(find.text('Calendario'));
    await tester.pump();
    await esperarTexto('Simular 1 partido');

    // 7) Simular el primer partido programado.
    await tester.tap(find.text('Simular 1 partido'));
    await tester.pump();
    await esperarTexto('1 partido(s) simulados');

    expect(find.textContaining('DEN'), findsWidgets);
  });
}
