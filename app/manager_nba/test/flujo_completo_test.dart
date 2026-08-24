import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/features/roster/roster_config_screen.dart'
    show claveRolAtaque, claveRolDefensa, claveRolSextoHombre;
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
    await tester.tap(find.widgetWithText(FilledButton, 'NUEVA PARTIDA'));
    await tester.pump();
    await esperarTexto('Ranura vacía');
    await tester.tap(find.widgetWithText(OutlinedButton, 'EMPEZAR').first);
    await tester.pump();

    // 2) Selección de equipo (import real del dataset) -> Denver. La
    // rejilla rotula la ciudad en mayúsculas.
    await esperarTexto('DENVER', contiene: true);
    await tester.tap(find.textContaining('DENVER'));
    await tester.pump();

    // 3) Vista previa de la plantilla -> confirmar.
    await esperarTexto('ELEGIR ESTE EQUIPO');
    await tester.tap(find.text('ELEGIR ESTE EQUIPO'));
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

    // 4.5) Los tres roles: estrella de ataque, estrella de defensa y sexto
    // hombre. Son obligatorios para empezar, igual que los diez huecos —
    // sin ellos el botón avisa y no arranca la temporada.
    //
    // A 1024 px de ancho la banda de roles va siempre desplegada, así que
    // los tres desplegables están a la vista sin tener que abrirla.
    // Por su clave y no por posición: un finder indexado (`.at(i)`)
    // revienta dentro de `tap`, que por debajo busca el `View` que lo
    // contiene y le aplica el mismo índice — y `View` solo hay uno.
    for (final clave in [
      claveRolAtaque,
      claveRolDefensa,
      claveRolSextoHombre,
    ]) {
      // Sin `ensureVisible`: la banda de roles es un pie fijo y siempre
      // está a la vista. Y llamarlo hacía daño — sube buscando un
      // `Scrollable` y el primero que encuentra es el `PageView` del
      // `TabBarView`, así que con el campo de más a la derecha cambiaba de
      // pestaña y la banda entera desaparecía del árbol.
      final desplegable = find.byKey(clave);
      await tester.tap(desplegable);
      await tester.pumpAndSettle();

      // Un item con jugador de verdad: "Ninguna" lleva value null.
      //
      // ONSTAGE, no `skipOffstage: false`: `skipOffstage: false` metería
      // también el propio valor ya elegido de un campo YA CERRADO de una
      // vuelta anterior (que enseña su elegido aunque esté cerrado), y con
      // solo lo que hay EN PANTALLA y cogiendo el ÚLTIMO, se coge del menú
      // recién abierto de verdad: ese "ya elegido" de un campo cerrado, si
      // aparece, es siempre el primero de la lista, nunca el último.
      //
      // Se toca por su `key` (`opcion-rol-$id`, puesta en `itemJugador` de
      // roster_config_screen.dart) y no extrayendo el texto de un `Text`:
      // desde que cada opción es una fila con placa de media + nombre, el
      // hijo del `DropdownMenuItem` ya no es un `Text` suelto.
      final item = tester
          .widgetList<DropdownMenuItem<int?>>(find.byType(DropdownMenuItem<int?>))
          .lastWhere((it) => it.value != null);
      // `ensureVisible` SÍ hace falta aquí, a diferencia del de arriba: el
      // menú desplegado es su propio overlay, con su propio scroll interno
      // — no comparte árbol con el `TabBarView` de la pantalla de debajo,
      // así que no hay riesgo de que suba y cambie de pestaña. Con la fila
      // de dos líneas (Lista 15 punto 6 + el rediseño de hoy) ya no caben
      // todas las opciones a la vez dentro de `menuMaxHeight`.
      await tester.ensureVisible(find.byKey(item.key!));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(item.key!));
      await tester.pumpAndSettle();
    }

    // 5) Guardar rotación -> arranca la temporada -> menú principal.
    // Los títulos y los botones del rediseño van en MAYÚSCULAS (ver
    // `mayus` en shared/estilo.dart), y el botón de guardar ya no es un
    // FilledButton de Material sino una pieza propia con la esquina
    // cortada; lo pulsable de dentro sigue siendo un InkWell.
    final botonEmpezar =
        find.widgetWithText(InkWell, 'EMPEZAR TEMPORADA');
    expect(tester.widget<InkWell>(botonEmpezar).onTap, isNotNull);
    await tester.tap(botonEmpezar);
    await tester.pump();

    // 5.5) Patrocinadores: paso de pretemporada también el primer año. Sin
    // elegir ninguno a propósito (aquí solo se comprueba que el flujo
    // completo sigue adelante, no las decisiones de patrocinio).
    await esperarTexto('Patrocinadores');
    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));
    await tester.pump();

    await esperarTexto('CALENDARIO');
    expect(find.text('TU EQUIPO'), findsOneWidget);
    expect(find.text('CLASIFICACIÓN'), findsOneWidget);

    // Premios y Playoffs existen pero están deshabilitados hasta terminar
    // la temporada regular (82 partidos) — aquí solo se ha creado la
    // franquicia, ninguno se ha jugado todavía.
    await esperarTexto('PREMIOS');
    expect(
      find.text('Se desbloquea al terminar la temporada regular'),
      findsNWidgets(2), // Premios y Playoffs
    );

    // 6) Entrar al calendario.
    await tester.tap(find.text('CALENDARIO'));
    await tester.pump();
    await esperarTexto('SIMULAR 1 PARTIDO');

    // 7) Simular el primer partido programado.
    await tester.tap(find.text('SIMULAR 1 PARTIDO'));
    await tester.pump();
    await esperarTexto('1 partido(s) simulados');

    expect(find.textContaining('DEN'), findsWidgets);
  });
}
