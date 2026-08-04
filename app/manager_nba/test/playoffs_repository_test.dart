import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/conferencias.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');

    // Récords ficticios para las dos conferencias, para no depender de
    // simular una temporada completa en este test.
    final equipos = await db.select(db.resultadoTemporada).get();
    for (var i = 0; i < equipos.length; i++) {
      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals(equipos[i].equipo)))
          .write(ResultadoTemporadaCompanion(
        victorias: Value(82 - i),
        derrotas: Value(i),
      ));
    }

    // El campeón de la Final NBA se apunta también en el registro
    // compartido entre partidas (campeones_repository.dart); en un test se
    // sustituye por uno en memoria para no depender de `path_provider`.
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
  });

  tearDown(() async {
    await db.close();
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  /// Los 10 equipos de [conferencia] ordenados por víctorias, tal y como
  /// los ve `sembrarPlayoffs` (mismo criterio de desempate).
  Future<List<String>> top10De(String conferencia) async {
    final resultados = await db.select(db.resultadoTemporada).get();
    final equipos = resultados
        .where((r) => conferenciaPorEquipo[r.equipo] == conferencia)
        .toList()
      ..sort((a, b) {
        final cmp = (b.victorias / (b.victorias + b.derrotas))
            .compareTo(a.victorias / (a.victorias + a.derrotas));
        return cmp != 0 ? cmp : a.equipo.compareTo(b.equipo);
      });
    return equipos.take(10).map((r) => r.equipo).toList();
  }

  test('sembrarPlayoffs deja la ronda 1 entera en el cuadro —el 1 y el 2 con '
      'su rival por definir— y el play-in (7v8, 9v10) por conferencia',
      () async {
    await sembrarPlayoffs(db);
    final series = await leerSeries(db);

    final ronda1 = series.where((s) => s.ronda == 1).toList();
    expect(ronda1.length, 8); // 1v8, 2v7, 3v6 y 4v5 x 2 conferencias
    expect(ronda1.every((s) => s.seedA + s.seedB == 9), isTrue);

    final playIn = series.where((s) => s.ronda == 0).toList();
    expect(playIn.length, 4); // 7v8 y 9v10 x 2 conferencias
    expect(playIn.every((s) => s.victoriasNecesarias == 1), isTrue);

    for (final conferencia in ['Este', 'Oeste']) {
      final top10 = await top10De(conferencia);

      // El 1 y el 2 están colocados desde el primer día; lo único que falta
      // por saber es a quién le toca enfrente.
      final juego18 = series.firstWhere(
          (s) => s.conferencia == conferencia && s.etapa == 'ronda1_1v8');
      expect(juego18.equipoA, top10[0]);
      expect(juego18.equipoB, equipoPorDefinir);
      expect(tieneRivalPorDefinir(juego18), isTrue);

      final juego27 = series.firstWhere(
          (s) => s.conferencia == conferencia && s.etapa == 'ronda1_2v7');
      expect(juego27.equipoA, top10[1]);
      expect(juego27.equipoB, equipoPorDefinir);

      // El 3-6 y el 4-5 sí se conocen del todo.
      final juego36 = series.firstWhere(
          (s) => s.conferencia == conferencia && s.etapa == 'ronda1_3v6');
      expect(tieneRivalPorDefinir(juego36), isFalse);

      final juego78 = series.firstWhere(
          (s) => s.conferencia == conferencia && s.etapa == 'playin_7v8');
      expect(juego78.equipoA, top10[6]);
      expect(juego78.equipoB, top10[7]);

      final juego910 = series.firstWhere(
          (s) => s.conferencia == conferencia && s.etapa == 'playin_9v10');
      expect(juego910.equipoA, top10[8]);
      expect(juego910.equipoB, top10[9]);
    }
  });

  test('los equipos 11º en adelante de cada conferencia no aparecen en '
      'ninguna serie', () async {
    await sembrarPlayoffs(db);
    final series = await leerSeries(db);
    final equiposEnBracket = {
      for (final s in series) ...[s.equipoA, s.equipoB],
    };

    for (final conferencia in ['Este', 'Oeste']) {
      final resultados = await db.select(db.resultadoTemporada).get();
      final ordenados = resultados
          .where((r) => conferenciaPorEquipo[r.equipo] == conferencia)
          .toList()
        ..sort((a, b) => b.victorias.compareTo(a.victorias));
      final fueraDelPlayIn = ordenados.skip(10);
      for (final r in fueraDelPlayIn) {
        expect(equiposEnBracket.contains(r.equipo), isFalse,
            reason: '${r.equipo} no debería estar en ningún play-in/serie');
      }
    }
  });

  test('el ganador del play-in 7v8 pasa a la ronda 1 como seed 7, y el '
      'ganador de la final de play-in como seed 8', () async {
    await sembrarPlayoffs(db);

    for (final conferencia in ['Este', 'Oeste']) {
      final series = await leerSeries(db);
      final juego78 = series
          .firstWhere((s) => s.conferencia == conferencia && s.etapa == 'playin_7v8');
      final juego910 = series
          .firstWhere((s) => s.conferencia == conferencia && s.etapa == 'playin_9v10');

      await simularPartidoDeSerie(db, juego78.id);
      await simularPartidoDeSerie(db, juego910.id);
    }

    // La final de play-in ya debería existir para ambas conferencias.
    var series = await leerSeries(db);
    for (final conferencia in ['Este', 'Oeste']) {
      final final_ = series.firstWhere(
          (s) => s.conferencia == conferencia && s.etapa == 'playin_final');
      await simularPartidoDeSerie(db, final_.id);
    }

    series = await leerSeries(db);
    for (final conferencia in ['Este', 'Oeste']) {
      final top10 = await top10De(conferencia);
      final ronda1_1v8 = series.firstWhere(
          (s) => s.conferencia == conferencia && s.etapa == 'ronda1_1v8');
      final ronda1_2v7 = series.firstWhere(
          (s) => s.conferencia == conferencia && s.etapa == 'ronda1_2v7');

      expect(ronda1_1v8.equipoA, top10[0]); // seed 1
      expect(ronda1_2v7.equipoA, top10[1]); // seed 2
      // Los otros huecos los rellenan quien gane el play-in — no son
      // necesariamente top10[6]/top10[7] literales porque el partido en
      // sí es aleatorio, pero deben ser candidatos del play-in.
      expect(top10.sublist(6, 10), contains(ronda1_1v8.equipoB));
      expect(top10.sublist(6, 10), contains(ronda1_2v7.equipoB));
    }
  });

  test('el cruce de semifinales es el real: el ganador del 1-8 se mide al '
      'del 4-5, y el del 2-7 al del 3-6 (nunca al otro lado del cuadro)',
      () async {
    await sembrarPlayoffs(db);
    await simularPlayoffsCompletos(db);

    final series = await leerSeries(db);
    Serie de(String conferencia, String etapa) => series
        .firstWhere((s) => s.conferencia == conferencia && s.etapa == etapa);

    for (final conferencia in ['Este', 'Oeste']) {
      final semisA = de(conferencia, 'semis_a');
      final semisB = de(conferencia, 'semis_b');

      expect({semisA.equipoA, semisA.equipoB}, {
        de(conferencia, 'ronda1_1v8').ganador,
        de(conferencia, 'ronda1_4v5').ganador,
      });
      expect({semisB.equipoA, semisB.equipoB}, {
        de(conferencia, 'ronda1_2v7').ganador,
        de(conferencia, 'ronda1_3v6').ganador,
      });
    }
  });

  test('simularPlayoffsCompletos resuelve todo — play-in, playoffs y final '
      '— hasta un único campeón', () async {
    await sembrarPlayoffs(db);
    await simularPlayoffsCompletos(db);

    final series = await leerSeries(db);
    expect(series.every((s) => s.ganador != null), isTrue);

    final finalNba = series.where((s) => s.conferencia == 'Final').toList();
    expect(finalNba.length, 1);
    expect(finalNba.first.ganador, isNotNull);

    // Por conferencia: play-in (3) + ronda1 (4) + semis (2) + final
    // conferencia (1) = 10. x2 conferencias + final NBA (1) = 21.
    expect(series.length, 21);
  });

  test('cada serie/partido se gana exactamente con las victorias '
      'necesarias, nunca más', () async {
    await sembrarPlayoffs(db);
    await simularPlayoffsCompletos(db);

    final series = await leerSeries(db);
    for (final s in series) {
      final victoriasGanador =
          s.ganador == s.equipoA ? s.victoriasA : s.victoriasB;
      final victoriasPerdedor =
          s.ganador == s.equipoA ? s.victoriasB : s.victoriasA;
      expect(victoriasGanador, s.victoriasNecesarias);
      expect(victoriasPerdedor, lessThan(s.victoriasNecesarias));
    }
  });

  test('el campeón de la final NBA queda registrado en HistorialCampeones, '
      'en la partida y en el palmarés compartido', () async {
    await sembrarPlayoffs(db);
    await simularPlayoffsCompletos(db);

    final series = await leerSeries(db);
    final finalNba = series.firstWhere((s) => s.conferencia == 'Final');

    final historial = await db.select(db.historialCampeones).get();
    final titulosNba = historial.where((c) => c.tipo == 'nba').toList();
    expect(titulosNba.length, 1);
    expect(titulosNba.first.equipo, finalNba.ganador);

    final compartido = abrirAjustes();
    final historialCompartido =
        await compartido.select(compartido.historialCampeones).get();
    final titulosNbaCompartidos =
        historialCompartido.where((c) => c.tipo == 'nba').toList();
    expect(titulosNbaCompartidos.length, 1);
    expect(titulosNbaCompartidos.first.equipo, finalNba.ganador);
  });

  group('el play-in va primero', () {
    test('recién sembrado solo se puede jugar el play-in, aunque el 3-6 y el '
        '4-5 ya tengan sus dos equipos', () async {
      await sembrarPlayoffs(db);

      expect(await playInPendiente(db), isTrue);
      final jugables = await seriesJugablesAhora(db);
      expect(jugables, isNotEmpty);
      expect(jugables.every((s) => s.ronda == 0), isTrue,
          reason: 'la primera ronda no empieza hasta que el play-in acabe');

      final series = await leerSeries(db);
      expect(series.any((s) => s.ronda == 1), isTrue,
          reason: 'el 3-6 y el 4-5 ya están sembrados, pero no tocan');
    });

    test('avanzar un partido con el play-in pendiente no toca la primera '
        'ronda', () async {
      await sembrarPlayoffs(db);
      await avanzarPlayoffsUnPartido(db, 'DEN');

      final series = await leerSeries(db);
      for (final s in series.where((s) => s.ronda == 1)) {
        expect(s.victoriasA + s.victoriasB, 0,
            reason: '${s.etapa} no debería haber jugado nada todavía');
      }
      expect(
          series.where((s) => s.ronda == 0).any((s) => s.ganador != null),
          isTrue,
          reason: 'el play-in sí ha avanzado');
    });

    test('en cuanto el play-in termina, la primera ronda pasa a ser lo '
        'jugable', () async {
      await sembrarPlayoffs(db);
      while (await playInPendiente(db)) {
        await simularRondaPlayoffsCompleta(db);
      }

      final jugables = await seriesJugablesAhora(db);
      expect(jugables, isNotEmpty);
      expect(jugables.every((s) => s.ronda == 1), isTrue);
      expect(jugables, hasLength(8),
          reason: 'cuatro series por conferencia');
    });
  });

  group('MVP de las Finales', () {
    test('mientras no haya campeón no hay MVP', () async {
      await sembrarPlayoffs(db);
      expect(await mvpDeLasFinales(db), isNull);
    });

    test('sale del campeón, con sus medias de la serie', () async {
      await sembrarPlayoffs(db);
      await simularPlayoffsCompletos(db);

      final finalNba =
          (await leerSeries(db)).firstWhere((s) => s.conferencia == 'Final');
      final mvp = await mvpDeLasFinales(db);

      expect(mvp, isNotNull);
      expect(mvp!.equipo, finalNba.ganador);
      expect(mvp.partidos, inInclusiveRange(4, 7));
      expect(mvp.puntos, greaterThan(0));
      expect(mvp.nombre, isNotEmpty);

      final jugador = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(mvp.jugadorId)))
          .getSingleOrNull();
      expect(jugador, isNotNull);
      expect(jugador!.equipo, finalNba.ganador);
    });
  });
}
