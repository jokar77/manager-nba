import 'dart:math';

import 'package:drift/drift.dart' show Value;
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
      'la clase de draft 2026 ya no se descarta: tiene atributos reales, '
      'no solo el mock draft', () async {
    // Hasta la sesión del 24 de agosto de 2026 los ~60 prospectos de la
    // clase de draft 2026 solo traían `media`/`potencial` de un mock
    // draft; sin atr_tiro3/atr_ataque/atr_defensa/pts_pg/ast_pg/trb_pg/
    // factor_longevidad, `_camposObligatorios` los descartaba enteros del
    // import. Eso tapaba sin querer un bug de Rising Stars (ver
    // docs/plan.md, Lista 15 punto 1): al arreglar la clasificación de
    // rookies, el juego se quedó sin ningún novato de verdad jugable.
    // Se completaron con datos reales de un CSV, y ahora entran todos.
    await importarJugadoresSiHaceFalta(db);
    final filas = await db.select(db.jugadores).get();
    final boozer = filas.where((j) => j.nombreReal == 'Cameron Boozer');
    expect(boozer, isNotEmpty,
        reason: 'antes se descartaba por no tener atributos reales');
    expect(boozer.first.draftYear, 2026);
    expect(boozer.first.temporadasPrevias, 0);
  });

  test('las estrellas que se perdieron la temporada entera por lesión '
      'siguen estando en su equipo', () async {
    // El dataset se genera de las estadísticas de una temporada con un
    // mínimo de partidos, así que quien no jugó NINGUNO desaparecía del
    // juego: Kyrie Irving no salía en Dallas. Se añadieron a mano (ver
    // `docs/plan.md`), y esto vigila que una regeneración del dataset no
    // los vuelva a dejar fuera sin que nadie se entere.
    await importarJugadoresSiHaceFalta(db);
    final filas = await db.select(db.jugadores).get();
    final porNombreReal = {for (final j in filas) j.nombreReal: j};

    const esperados = {
      'Kyrie Irving': 'DAL',
      'Damian Lillard': 'POR',
      'Tyrese Haliburton': 'IND',
      'Fred VanVleet': 'HOU',
    };
    for (final entrada in esperados.entries) {
      final jugador = porNombreReal[entrada.key];
      expect(jugador, isNotNull,
          reason: '${entrada.key} tiene que estar en el dataset');
      expect(jugador!.equipo, entrada.value,
          reason: '${entrada.key} juega en ${entrada.value}');
      // Sin atributos no lo dejaría pasar el filtro del importador, así
      // que si llega aquí es que están; lo que se comprueba es que no
      // sean un relleno absurdo.
      expect(jugador.media, inInclusiveRange(70, 99));
    }
  });

  test('la cuenta de jugadores del dataset está al día', () async {
    // `jugadoresUtilizablesDelDataset` es la salida barata del relleno: si
    // se queda desfasado al cambiar el asset, el relleno deja de dispararse
    // y las partidas viejas se vuelven a quedar sin los jugadores nuevos,
    // en silencio y sin que nada falle. De ahí este test.
    await importarJugadoresSiHaceFalta(db);
    final filas = await db.select(db.jugadores).get();
    expect(filas.length, jugadoresUtilizablesDelDataset,
        reason: 'ha cambiado jugadores.json: sube '
            'jugadoresUtilizablesDelDataset a ${filas.length}');
  });

  test('una partida ya empezada recupera a los jugadores que el dataset '
      'ganó después', () async {
    // El caso real: se añadió a Kyrie Irving al dataset y en una carrera ya
    // en marcha seguía sin aparecer, porque `importarJugadoresSiHaceFalta`
    // se sale en cuanto ve la tabla con datos.
    await importarJugadoresSiHaceFalta(db);
    // Se simula la partida vieja borrándolo, que es exactamente el estado
    // en el que se quedaron las carreras empezadas antes del arreglo.
    await (db.delete(db.jugadores)
          ..where((t) => t.nombreReal.equals('Kyrie Irving')))
        .go();
    expect(
        await (db.select(db.jugadores)
              ..where((t) => t.nombreReal.equals('Kyrie Irving')))
            .getSingleOrNull(),
        isNull);

    // Volver a llamar al import normal NO lo arregla: es el bug.
    await importarJugadoresSiHaceFalta(db);
    expect(
        await (db.select(db.jugadores)
              ..where((t) => t.nombreReal.equals('Kyrie Irving')))
            .getSingleOrNull(),
        isNull,
        reason: 'el import normal no toca una tabla que ya tiene datos');

    final anadidos = await anadirJugadoresQueFaltenDelDataset(db);
    expect(anadidos, 1);
    final kyrie = await (db.select(db.jugadores)
          ..where((t) => t.nombreReal.equals('Kyrie Irving')))
        .getSingleOrNull();
    expect(kyrie, isNotNull);
    expect(kyrie!.equipo, 'DAL');

    // Y es idempotente: llamarla otra vez no lo duplica.
    expect(await anadirJugadoresQueFaltenDelDataset(db), 0);
  });

  test('pasada la primera temporada ya no se rellena: la liga ha cambiado',
      () async {
    await importarJugadoresSiHaceFalta(db);
    await (db.delete(db.jugadores)
          ..where((t) => t.nombreReal.equals('Kyrie Irving')))
        .go();

    // Una carrera por la temporada 4: meter ahí a alguien con la edad y la
    // media del dataset original sería inventarse un fichaje, no restaurar
    // lo que faltaba.
    await db.into(db.temporada).insertOnConflictUpdate(
        const TemporadaCompanion(
            id: Value(0), numero: Value(4), anioInicio: Value(2029)));

    expect(await anadirJugadoresQueFaltenDelDataset(db), 0);
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
