import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/modo_carrera_repository.dart';
import 'package:manager_nba/features/modo_carrera/crear_jugador_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<EstadoCarrera?> pump(WidgetTester tester) async {
    // Con la camiseta grande, el formulario entero no cabe en el tamaño de
    // pantalla por defecto de los tests (800x600) sin desplazarse — mismo
    // motivo que start_menu_screen_test.dart usa un tamaño más alto.
    tester.view.physicalSize = const Size(1024, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    EstadoCarrera? creado;
    await tester.pumpWidget(MaterialApp(
      home: CrearJugadorScreen(
        db: db,
        onCreado: (estado) => creado = estado,
      ),
    ));
    await tester.pump();
    return creado;
  }

  testWidgets('el botón de confirmar empieza apagado sin apellido',
      (WidgetTester tester) async {
    await pump(tester);
    final boton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(boton.onPressed, isNull);
  });

  testWidgets(
      'rellenar apellido y dorsal, elegir posición y nacionalidad, y '
      'confirmar crea la carrera a los 16 años en fase juvenil',
      (WidgetTester tester) async {
    final creado = await pump(tester);
    expect(creado, isNull);

    await tester.enterText(find.byType(TextField).first, 'Pérez');
    await tester.pump();

    // La posición por defecto ya viene marcada (PG); se elige otra para
    // comprobar que la selección de verdad cambia el estado del formulario.
    await tester.tap(find.widgetWithText(ChoiceChip, 'SF'));
    await tester.pump();

    // La cadencia por defecto es "cada año"; se elige "cada 2 años" para
    // comprobar que también viaja hasta la partida guardada.
    await tester.tap(find.widgetWithText(ChoiceChip, 'Cada 2 años'));
    await tester.pump();

    final boton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(boton.onPressed, isNotNull);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final estado = await leerPartidaCarrera(db);
    expect(estado, isNotNull);
    expect(estado!.apellido, 'Pérez');
    expect(estado.posicion, 'SF');
    expect(estado.edad, 16);
    expect(estado.fase, FaseCarrera.juvenil);
    expect(estado.organizacionActual, isNull);
    expect(estado.cadenciaAnios, 2);
  });
}
