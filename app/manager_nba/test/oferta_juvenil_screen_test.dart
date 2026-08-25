import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/modo_carrera_repository.dart';
import 'package:manager_nba/features/modo_carrera/oferta_juvenil_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  const identidad = IdentidadCarrera(
    apellido: 'Testigo',
    dorsal: 7,
    posicion: 'PG',
    nacionalidad: 'ESP',
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await crearPartidaCarrera(db, identidad, random: Random(1));
  });

  tearDown(() async {
    await db.close();
  });

  Future<EstadoCarrera?> pump(WidgetTester tester) async {
    final estadoInicial = await leerPartidaCarrera(db);
    EstadoCarrera? elegida;
    await tester.pumpWidget(MaterialApp(
      home: OfertaJuvenilScreen(
        db: db,
        estado: estadoInicial!,
        onElegida: (estado) => elegida = estado,
      ),
    ));
    await tester.pump();
    return elegida;
  }

  testWidgets('enseña las tres ofertas del país de la identidad',
      (WidgetTester tester) async {
    await pump(tester);
    for (final organizacion in ofertasJuvenilesIniciales('ESP')) {
      expect(find.text(organizacion), findsOneWidget);
    }
  });

  testWidgets('elegir una oferta la guarda como organización actual y '
      'avisa con el estado actualizado', (WidgetTester tester) async {
    await pump(tester);
    final primeraOferta = ofertasJuvenilesIniciales('ESP').first;

    // Los botones del rediseño rotulan en MAYÚSCULAS (ver `mayus` en
    // shared/estilo.dart).
    await tester.tap(find.text('FICHAR POR ${primeraOferta.toUpperCase()}'));
    await tester.pumpAndSettle();

    final estado = await leerPartidaCarrera(db);
    expect(estado!.organizacionActual, primeraOferta);
  });
}
