import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/modo_carrera_repository.dart';
import 'package:manager_nba/features/modo_carrera/modo_carrera_hub_screen.dart';

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
    await importarJugadoresSiHaceFalta(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pump(WidgetTester tester, EstadoCarrera estado) async {
    await tester.pumpWidget(MaterialApp(
      home: ModoCarreraHubScreen(db: db, estadoInicial: estado),
    ));
    await tester.pump();
  }

  testWidgets(
      'en fase juvenil el botón avanza la temporada y avisa del resultado',
      (WidgetTester tester) async {
    final rng = Random(1);
    await crearPartidaCarrera(db, identidad, random: rng);
    await elegirOrganizacionJuvenil(
        db, ofertasJuvenilesIniciales('ESP').first);
    final estado = (await leerPartidaCarrera(db))!;
    expect(estado.fase, FaseCarrera.juvenil);

    await pump(tester, estado);
    expect(find.text('AVANZAR TEMPORADA'), findsOneWidget);

    await tester.tap(find.text('AVANZAR TEMPORADA'));
    await tester.pumpAndSettle();

    // El resumen se cierra con el botón "Continuar" del diálogo.
    expect(find.text('CONTINUAR'), findsOneWidget);
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();

    final actualizado = await leerPartidaCarrera(db);
    expect(actualizado!.edad, 17);
  });

  testWidgets('en fase predraft el botón entra al draft y crea la fila real',
      (WidgetTester tester) async {
    final rng = Random(3);
    await crearPartidaCarrera(db, identidad, random: rng);
    await elegirOrganizacionJuvenil(
        db, ofertasJuvenilesIniciales('ESP').first);
    for (var i = 0; i < edadDeDraft - edadInicialCarrera; i++) {
      await avanzarTemporadaJuvenil(db, random: rng);
    }
    final estado = (await leerPartidaCarrera(db))!;
    expect(estado.fase, FaseCarrera.predraft);

    await pump(tester, estado);
    expect(find.text('ENTRAR AL DRAFT'), findsOneWidget);

    await tester.tap(find.text('ENTRAR AL DRAFT'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();

    final actualizado = await leerPartidaCarrera(db);
    expect(actualizado!.fase, FaseCarrera.nba);
    expect(actualizado.jugadorId, isNotNull);
  });

  testWidgets(
      'en fase nba el botón simula la temporada y actualiza la ficha',
      (WidgetTester tester) async {
    final rng = Random(5);
    await crearPartidaCarrera(db, identidad, random: rng);
    await elegirOrganizacionJuvenil(
        db, ofertasJuvenilesIniciales('ESP').first);
    for (var i = 0; i < edadDeDraft - edadInicialCarrera; i++) {
      await avanzarTemporadaJuvenil(db, random: rng);
    }
    await entrarAlDraft(db, random: rng);
    final estado = (await leerPartidaCarrera(db))!;
    expect(estado.fase, FaseCarrera.nba);

    await pump(tester, estado);
    expect(find.text('AVANZAR TEMPORADA'), findsOneWidget);

    await tester.tap(find.text('AVANZAR TEMPORADA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();

    final actualizado = await leerPartidaCarrera(db);
    expect(actualizado!.temporadaNba, 1);
  });

  testWidgets(
      'en fase retirado no hay botón de acción y se enseña el resumen de '
      'carrera', (WidgetTester tester) async {
    final rng = Random(2024);
    await crearPartidaCarrera(db, identidad, random: rng);
    await elegirOrganizacionJuvenil(
        db, ofertasJuvenilesIniciales('ESP').first);
    for (var i = 0; i < edadDeDraft - edadInicialCarrera; i++) {
      await avanzarTemporadaJuvenil(db, random: rng);
    }
    await entrarAlDraft(db, random: rng);

    var resumen = await avanzarTemporadaNba(db, random: rng);
    var temporadas = 0;
    while (!resumen.seRetira && temporadas < 40) {
      resumen = await avanzarTemporadaNba(db, random: rng);
      temporadas++;
    }
    expect(resumen.seRetira, isTrue);

    final estado = (await leerPartidaCarrera(db))!;
    expect(estado.fase, FaseCarrera.retirado);

    await pump(tester, estado);
    await tester.pumpAndSettle();

    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('PTS'), findsOneWidget);
    expect(find.text('AST'), findsOneWidget);
    expect(find.text('REB'), findsOneWidget);
  });
}
