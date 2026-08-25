import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/main.dart';

void main() {
  testWidgets(
      'importa el dataset, muestra el menú de partidas y al empezar una, '
      'la selección de equipo', (WidgetTester tester) async {
    // Las partidas son ficheros en la carpeta de documentos; en un test se
    // sustituyen por bases en memoria.
    final almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
    addTearDown(() async {
      await almacen.cerrarTodo();
      almacenDeSlots = AlmacenDeSlotsEnDisco();
    });

    await tester.pumpWidget(ManagerNbaApp(ajustesDb: abrirAjustes()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // No usamos pumpAndSettle: el spinner de carga tiene una animación
    // indefinida que nunca deja de programar frames y haría que
    // pumpAndSettle expire por timeout aunque todo funcione bien.
    //
    // La carga del asset (rootBundle.loadString) es E/S real y testWidgets
    // corre en una zona de "fake async"; runAsync se sale de esa zona para
    // que la E/S real pueda completarse de verdad.
    await tester.runAsync(() async {
      for (var i = 0; i < 50; i++) {
        if (find
            .widgetWithText(FilledButton, 'Nueva partida')
            .evaluate()
            .isNotEmpty) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      }
    });
    expect(find.text('MANAGER NBA'), findsOneWidget);

    // Las ranuras viven detrás de "Modo Franquicia": el menú son opciones
    // directas (Modo Jugador, del 25 de agosto de 2026, es la otra), no la
    // lista de guardados.
    await tester.tap(find.widgetWithText(FilledButton, 'MODO FRANQUICIA'));
    await tester.pump();
    expect(find.text('Ranura vacía'), findsNWidgets(numeroDeSlots));

    await tester.tap(find.widgetWithText(OutlinedButton, 'EMPEZAR').first);
    await tester.pump();

    await tester.runAsync(() async {
      for (var i = 0; i < 50; i++) {
        // El dataset real trae Denver entre sus 30 equipos.
        if (find.textContaining('DENVER').evaluate().isNotEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      }
    });

    expect(find.text('ELIGE TU EQUIPO'), findsOneWidget);
    expect(find.textContaining('DENVER'), findsOneWidget);
  });
}
