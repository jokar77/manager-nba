import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/features/mercado/agencia_libre_screen.dart';

/// El filtro de puesto de la Agencia Libre: sin chip de "Todos" (por
/// defecto ya se ven todos) y tocar un puesto ya elegido lo destoca en vez
/// de necesitar un botón aparte para volver a ver a todo el mundo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
  });

  tearDown(() => db.close());

  Future<void> asentar(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('no hay chip de "Todos", y tocar un puesto ya elegido vuelve '
      'a enseñar a todos', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AgenciaLibreScreen(db: db, equipoUsuario: 'DEN'),
    ));
    await asentar(tester);

    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(ChoiceChip, 'Todos'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'PG'), findsOneWidget);

    // El contador de arriba refleja el estado real del filtro (visibles de
    // total), a diferencia de contar filas pintadas: la lista es una
    // ListView, así que solo cuenta lo que quepa en pantalla y no serviría
    // para comprobar cuántas hay de verdad.
    expect(find.textContaining('(hay filtros puestos)'), findsNothing,
        reason: 'sin tocar nada, se ven todos: no hay filtro puesto');

    await tester.tap(find.widgetWithText(ChoiceChip, 'PG'));
    await asentar(tester);
    expect(find.textContaining('(hay filtros puestos)'), findsOneWidget,
        reason: 'con PG elegido, el contador avisa de que hay un filtro');

    await tester.tap(find.widgetWithText(ChoiceChip, 'PG'));
    await asentar(tester);
    expect(find.textContaining('(hay filtros puestos)'), findsNothing,
        reason: 'tocar el mismo puesto otra vez destoca el filtro y vuelve '
            'a enseñar a todos');
  });
}
