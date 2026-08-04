import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/lesiones_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('tirarLesionesPartido produce aproximadamente la tasa configurada '
      'en una muestra grande', () async {
    final ids = List.generate(2000, (i) => i);

    await tirarLesionesPartido(db, ids, DateTime(2026, 10, 21),
        random: Random(42));

    final lesiones = await db.select(db.lesiones).get();
    final tasaEsperada = probabilidadLesionLeve + probabilidadLesionGrave;
    final tasaObservada = lesiones.length / ids.length;

    // Margen generoso: es una tirada aleatoria, no un valor exacto.
    expect(tasaObservada, closeTo(tasaEsperada, 0.015));
  });

  test('las lesiones graves duran más que las leves', () async {
    await tirarLesionesPartido(db, List.generate(8000, (i) => i),
        DateTime(2026, 10, 21), random: Random(7));

    final lesiones = await db.select(db.lesiones).get();
    final duracionesLeves = lesiones
        .where((l) => l.gravedad == 'leve')
        .map((l) => l.fechaFin.difference(DateTime(2026, 10, 21)).inDays);
    final duracionesGraves = lesiones
        .where((l) => l.gravedad == 'grave')
        .map((l) => l.fechaFin.difference(DateTime(2026, 10, 21)).inDays);

    expect(duracionesLeves, isNotEmpty);
    expect(duracionesGraves, isNotEmpty);
    expect(
      duracionesGraves.reduce((a, b) => a + b) / duracionesGraves.length,
      greaterThan(
          duracionesLeves.reduce((a, b) => a + b) / duracionesLeves.length),
    );
  });

  test('cada lesión nueva trae motivo y partidos estimados coherentes',
      () async {
    final nuevas = await tirarLesionesPartido(
        db, List.generate(3000, (i) => i), DateTime(2026, 10, 21),
        random: Random(3));

    expect(nuevas, isNotEmpty);
    for (final n in nuevas) {
      expect(n.motivo, isNotEmpty);
      expect(n.partidosEstimados, greaterThanOrEqualTo(1));
      final diasReales = n.fechaFin.difference(DateTime(2026, 10, 21)).inDays;
      // partidosEstimados se calcula a partir de los días de baja a razón
      // de un partido cada ~2 días.
      expect(n.partidosEstimados, closeTo(diasReales / 2, 1));
    }
  });

  test('lesionesActivasEn devuelve motivo y gravedad de la lesión activa',
      () async {
    await db.into(db.lesiones).insert(LesionesCompanion.insert(
          jugadorId: 5,
          fechaFin: DateTime(2026, 11, 1),
          gravedad: 'grave',
          motivo: const Value('Rotura de ligamento cruzado'),
          partidosEstimados: const Value(15),
        ));

    final activas = await lesionesActivasEn(db, DateTime(2026, 10, 25));
    expect(activas[5]?.gravedad, 'grave');
    expect(activas[5]?.motivo, 'Rotura de ligamento cruzado');
    expect(activas[5]?.partidosEstimados, 15);
  });

  test('jugadoresLesionadosEn excluye a quien ya cumplió su lesión', () async {
    await db.into(db.lesiones).insert(LesionesCompanion.insert(
          jugadorId: 1,
          fechaFin: DateTime(2026, 10, 25),
          gravedad: 'leve',
        ));

    expect(
      await jugadoresLesionadosEn(db, DateTime(2026, 10, 22)),
      {1},
    );
    expect(
      await jugadoresLesionadosEn(db, DateTime(2026, 10, 26)),
      isEmpty,
    );
  });
}
