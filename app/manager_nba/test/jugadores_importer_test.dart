import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test(
      'importa el dataset real, descartando jugadores sin atributos '
      '(prospectos de draft aún no jugado)', () async {
    await importarJugadoresSiHaceFalta(db);
    final filas = await db.select(db.jugadores).get();

    // El JSON trae 641 jugadores; ~59 son prospectos sin stats reales.
    expect(filas.length, greaterThan(560));
    expect(filas.length, lessThan(641));
  });

  test('normaliza posiciones con espacio no separable ("SG / PG" -> "SG")',
      () async {
    await importarJugadoresSiHaceFalta(db);
    final filas = await db.select(db.jugadores).get();
    for (final j in filas) {
      expect(j.posicion, isNot(contains('/')));
      expect(j.posicion.trim(), j.posicion);
    }
  });

  test('es idempotente: llamarla dos veces no duplica jugadores', () async {
    await importarJugadoresSiHaceFalta(db);
    final primeraVez = await db.select(db.jugadores).get();

    await importarJugadoresSiHaceFalta(db);
    final segundaVez = await db.select(db.jugadores).get();

    expect(segundaVez.length, primeraVez.length);
  });

  test(
      'la edad de retiro se echa a suertes en cada partida, no viene fija '
      'del dataset (si no, los mismos jugadores se retirarían siempre en '
      'el mismo momento en toda partida nueva)', () async {
    final db2 = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db, random: Random(1));
    await importarJugadoresSiHaceFalta(db2, random: Random(2));

    final edades1 = {
      for (final j in await db.select(db.jugadores).get())
        j.nombreReal: j.edadRetiro
    };
    final edades2 = {
      for (final j in await db2.select(db2.jugadores).get())
        j.nombreReal: j.edadRetiro
    };
    await db2.close();

    final distintos =
        edades1.keys.where((n) => edades1[n] != edades2[n]).length;
    expect(distintos, greaterThan(edades1.length ~/ 2));
  });

  test('la edad de retiro se queda en un rango realista (34 a 42 años)',
      () async {
    await importarJugadoresSiHaceFalta(db, random: Random(42));
    final filas = await db.select(db.jugadores).get();
    for (final j in filas) {
      expect(j.edadRetiro, inInclusiveRange(34, 42));
    }
  });
}
