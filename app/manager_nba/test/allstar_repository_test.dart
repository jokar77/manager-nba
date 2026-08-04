import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/allstar_repository.dart';
import 'package:manager_nba/domain/carrera_repository.dart';
import 'package:manager_nba/domain/conferencias.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/premios_repository.dart';
import 'package:manager_nba/domain/tipo_premio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
  });

  tearDown(() async {
    await db.close();
  });

  /// Le inventa a [jugadorId] una temporada de escándalo para que no haya
  /// duda de que es el mejor de su conferencia.
  Future<void> temporadaDeEscandalo(int jugadorId,
      {int partidos = 50, int puntosPorPartido = 40}) async {
    await db.into(db.estadisticasTemporadaJugador).insertOnConflictUpdate(
        EstadisticasTemporadaJugadorCompanion.insert(
          jugadorId: Value(jugadorId),
          partidosJugados: Value(partidos),
          puntosTotales: Value(partidos * puntosPorPartido),
          asistenciasTotales: Value(partidos * 10),
          rebotesTotales: Value(partidos * 12),
        ));
  }

  test('jugar el All-Star no deja ningún rastro guardado aparte del propio '
      'partido y su MVP', () async {
    // El fin de semana de las estrellas se calcula al vuelo y punto. Hubo
    // una tabla de convocatorias apuntando quién iba cada año, para una
    // pantalla que nunca se pidió; se borró entera, y esto vigila que no
    // vuelva a colarse un historial por la puerta de atrás.
    final antes = db.allTables.map((t) => t.actualTableName).toSet();
    expect(antes, isNot(contains('historial_convocatorias_all_star')));

    await jugarAllStarSiHaceFalta(db);

    final premios = await db.select(db.premiosTemporada).get();
    expect(premios.map((p) => p.tipo), contains(TipoPremio.mvpAllStar.name));
  });

  test('el All-Star enfrenta a 10 jugadores del Este contra 10 del Oeste, '
      'nunca acaba en empate y se guarda para poder verlo', () async {
    expect(await leerBoxscoreAllStar(db), isNull);

    final boxscore = await jugarAllStarSiHaceFalta(db);
    expect(boxscore, isNotNull);
    expect(boxscore!.equipoLocal, equipoAllStarEste);
    expect(boxscore.equipoVisitante, equipoAllStarOeste);
    expect(boxscore.statsLocal, hasLength(10));
    expect(boxscore.statsVisitante, hasLength(10));
    expect(boxscore.marcadorLocal, isNot(boxscore.marcadorVisitante));

    final jugadores = await db.select(db.jugadores).get();
    final conferenciaPorId = {
      for (final j in jugadores) j.id.toString(): conferenciaPorEquipo[j.equipo],
    };
    for (final s in boxscore.statsLocal) {
      expect(conferenciaPorId[s.jugadorId], 'Este');
    }
    for (final s in boxscore.statsVisitante) {
      expect(conferenciaPorId[s.jugadorId], 'Oeste');
    }

    // Queda guardado, y volver a llamar no lo vuelve a jugar.
    final guardado = await leerBoxscoreAllStar(db);
    expect(guardado, isNotNull);
    expect(guardado!.marcadorLocal, boxscore.marcadorLocal);

    final segundoIntento = await jugarAllStarSiHaceFalta(db);
    expect(segundoIntento!.marcadorLocal, boxscore.marcadorLocal);
    expect(segundoIntento.marcadorVisitante, boxscore.marcadorVisitante);
  });

  test('el All-Star no toca el récord ni las estadísticas de temporada',
      () async {
    await jugarAllStarSiHaceFalta(db);

    final resultados = await db.select(db.resultadoTemporada).get();
    expect(resultados.every((r) => r.victorias == 0 && r.derrotas == 0), isTrue);
    expect(await db.select(db.estadisticasTemporadaJugador).get(), isEmpty);
    expect(await db.select(db.lesiones).get(), isEmpty);
  });

  group('convocatoria', () {
    test('los titulares son los mejores de la conferencia por lo que están '
        'haciendo esta temporada, no un sorteo ni la media del dataset',
        () async {
      // Un jugador cualquiera del Este, de los flojos del dataset, hace la
      // temporada de su vida: tiene que salir de titular igualmente.
      final delEste = (await db.select(db.jugadores).get())
          .where((j) => conferenciaPorEquipo[j.equipo] == 'Este')
          .toList()
        ..sort((a, b) => a.media.compareTo(b.media));
      final donNadie = delEste.first;
      await temporadaDeEscandalo(donNadie.id);

      final convocatoria = await convocatoriaDe(db, 'Este');
      expect(convocatoria, hasLength(convocadosPorConferencia));
      expect(convocatoria.first.jugador.id, donNadie.id,
          reason: 'promediando 40+10+12 es el mejor del Este, cobre lo que '
              'cobre y tenga la media que tenga');
      expect(convocatoria.first.titular, isTrue);
      expect(convocatoria.take(titularesPorConferencia).every((c) => c.titular),
          isTrue);
      expect(convocatoria.skip(titularesPorConferencia).any((c) => c.titular),
          isFalse);
    });

    test('entre dos jugadores con las mismas estadísticas, gana la '
        'convocatoria el del equipo con más victorias', () async {
      // Mismo criterio que ya usan los premios de fin de temporada
      // (calcularPremios): las victorias del equipo cuentan como
      // desempate, no solo lo que promedias tú solo.
      final delEste = (await db.select(db.jugadores).get())
          .where((j) => conferenciaPorEquipo[j.equipo] == 'Este')
          .toList();
      final peorEquipo = delEste[0];
      final mejorEquipo = delEste.firstWhere((j) => j.equipo != peorEquipo.equipo);

      await temporadaDeEscandalo(peorEquipo.id, puntosPorPartido: 30);
      await temporadaDeEscandalo(mejorEquipo.id, puntosPorPartido: 30);

      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals(peorEquipo.equipo)))
          .write(const ResultadoTemporadaCompanion(
              victorias: Value(10), derrotas: Value(60)));
      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals(mejorEquipo.equipo)))
          .write(const ResultadoTemporadaCompanion(
              victorias: Value(60), derrotas: Value(10)));

      final convocatoria = await convocatoriaDe(db, 'Este');
      final puestoMejor =
          convocatoria.indexWhere((c) => c.jugador.id == mejorEquipo.id);
      final puestoPeor =
          convocatoria.indexWhere((c) => c.jugador.id == peorEquipo.id);
      expect(puestoMejor, lessThan(puestoPeor),
          reason: 'con las mismas estadísticas, gana quien más ha ganado');
    });

    test('la convocatoria va ordenada por valoración y los votos con ella',
        () async {
      final convocatoria = await convocatoriaDe(db, 'Oeste');
      final valoraciones = convocatoria.map((c) => c.valoracion).toList();
      final votos = convocatoria.map((c) => c.votos).toList();

      for (var i = 1; i < valoraciones.length; i++) {
        expect(valoraciones[i], lessThanOrEqualTo(valoraciones[i - 1]));
        expect(votos[i], lessThanOrEqualTo(votos[i - 1]),
            reason: 'quien rinde más reúne más votos');
      }
    });

    test('los aspirantes son los siguientes de la lista, y ninguno repite '
        'con los convocados', () async {
      final convocados = await convocatoriaDe(db, 'Este');
      final aspirantes = await aspirantesDe(db, 'Este');

      expect(aspirantes, isNotEmpty);
      final idsConvocados = convocados.map((c) => c.jugador.id).toSet();
      expect(aspirantes.any((a) => idsConvocados.contains(a.jugador.id)),
          isFalse);
      expect(aspirantes.first.valoracion,
          lessThanOrEqualTo(convocados.last.valoracion));
    });

    test('un retirado no puede ser All-Star', () async {
      final convocados = await convocatoriaDe(db, 'Este');
      final estrella = convocados.first.jugador;
      await (db.update(db.jugadores)..where((t) => t.id.equals(estrella.id)))
          .write(const JugadoresCompanion(retirado: Value(true)));

      final ahora = await convocatoriaDe(db, 'Este');
      expect(ahora.any((c) => c.jugador.id == estrella.id), isFalse);
    });
  });

  group('MVP', () {
    test('el MVP del All-Star sale del partido y se guarda como premio de la '
        'temporada', () async {
      expect(await mvpDeLaTemporada(db, TipoPremio.mvpAllStar), isNull);

      final boxscore = await jugarAllStarSiHaceFalta(db);
      final mvp = await mvpDeLaTemporada(db, TipoPremio.mvpAllStar);

      expect(mvp, isNotNull);
      final linea = [...boxscore!.statsLocal, ...boxscore.statsVisitante]
          .where((e) => e.jugadorId == mvp!.id.toString());
      expect(linea, hasLength(1),
          reason: 'el MVP tiene que haber jugado el partido');
      expect(mvpDelPartido(boxscore)!.jugadorId, mvp!.id.toString());
    });

    test('el MVP casi siempre sale del ganador, pero lo decide lo que hizo',
        () async {
      final boxscore = await jugarAllStarSiHaceFalta(db);
      final mvp = mvpDelPartido(boxscore!)!;
      final mejorDelPartido = [
        ...boxscore.statsLocal,
        ...boxscore.statsVisitante
      ].reduce((a, b) =>
          (a.puntos + a.asistencias * 1.5 + a.rebotes * 1.2) >=
                  (b.puntos + b.asistencias * 1.5 + b.rebotes * 1.2)
              ? a
              : b);

      final notaMvp =
          mvp.puntos + mvp.asistencias * 1.5 + mvp.rebotes * 1.2;
      final notaMejor = mejorDelPartido.puntos +
          mejorDelPartido.asistencias * 1.5 +
          mejorDelPartido.rebotes * 1.2;
      // O es el mejor del partido, o está a un 12% (la ventaja del ganador).
      expect(notaMvp, greaterThanOrEqualTo(notaMejor / 1.12));
    });

    test('calcular los premios de fin de temporada no borra el MVP del '
        'All-Star', () async {
      await jugarAllStarSiHaceFalta(db);
      final antes = await mvpDeLaTemporada(db, TipoPremio.mvpAllStar);
      expect(antes, isNotNull);

      // Con algo de temporada por detrás, para que haya premios que calcular.
      final jugadores = await db.select(db.jugadores).get();
      for (final j in jugadores.take(60)) {
        await temporadaDeEscandalo(j.id, partidos: 40, puntosPorPartido: 20);
      }
      await calcularPremios(db);

      final despues = await mvpDeLaTemporada(db, TipoPremio.mvpAllStar);
      expect(despues, isNotNull, reason: 'se ganó en febrero, sigue en pie');
      expect(despues!.id, antes!.id);
      final premios = await leerPremios(db);
      expect(premios[TipoPremio.mvp], isNotEmpty,
          reason: 'y los de fin de temporada sí se han calculado');
    });
  });

  group('Rising Stars', () {
    test('enfrenta a los novatos con los de segundo año, y ninguno lleva más '
        'de una temporada a sus espaldas', () async {
      final boxscore = await jugarRisingStarsSiHaceFalta(db);
      expect(boxscore, isNotNull);
      expect(boxscore!.equipoLocal, equipoNovatos);
      expect(boxscore.equipoVisitante, equipoSophomores);
      expect(boxscore.statsLocal, hasLength(convocadosPorConferencia));
      expect(boxscore.statsVisitante, hasLength(convocadosPorConferencia));

      final porId = {
        for (final j in await db.select(db.jugadores).get())
          j.id.toString(): j,
      };
      for (final s in boxscore.statsLocal) {
        expect(porId[s.jugadorId]!.temporadasPrevias, 0);
      }
      for (final s in boxscore.statsVisitante) {
        expect(porId[s.jugadorId]!.temporadasPrevias, 1);
      }
    });

    test('tiene su propio MVP, distinto del premio del All-Star', () async {
      await jugarAllStarSiHaceFalta(db);
      await jugarRisingStarsSiHaceFalta(db);

      final mvpAllStar = await mvpDeLaTemporada(db, TipoPremio.mvpAllStar);
      final mvpJovenes = await mvpDeLaTemporada(db, TipoPremio.mvpRisingStars);
      expect(mvpAllStar, isNotNull);
      expect(mvpJovenes, isNotNull);
      expect(mvpJovenes!.temporadasPrevias, lessThanOrEqualTo(1));
    });

    test('no se vuelve a jugar si ya se jugó', () async {
      final primero = await jugarRisingStarsSiHaceFalta(db);
      final segundo = await jugarRisingStarsSiHaceFalta(db);
      expect(segundo!.marcadorLocal, primero!.marcadorLocal);
      expect(segundo.marcadorVisitante, primero.marcadorVisitante);
    });

    test('al año siguiente los novatos son otros: los de este año pasan a '
        'ser los de segundo', () async {
      // El bug: la convocatoria salía de `temporadasPrevias`, una columna
      // que se escribe al importar y no crece nunca, así que el partido
      // repetía exactamente los mismos nombres temporada tras temporada.
      final todos = await db.select(db.jugadores).get();
      for (final j in todos) {
        await temporadaDeEscandalo(j.id, partidos: 40, puntosPorPartido: 10);
      }

      final primera = await jugarRisingStarsSiHaceFalta(db);
      final novatosAnio1 = primera!.statsLocal.map((s) => s.jugadorId).toSet();
      expect(novatosAnio1, hasLength(convocadosPorConferencia));

      // Pasa un año, como en el cambio de temporada: se archiva lo jugado,
      // se borra el partido de exhibición y entra una hornada de draft.
      await archivarEstadisticasDeTemporada(db, 1);
      await db.delete(db.boxscoresSerie).go();
      for (var i = 0; i < convocadosPorConferencia + 5; i++) {
        await db.into(db.jugadores).insert(JugadoresCompanion.insert(
              nombreFicticio: 'Novato $i',
              nombreReal: '',
              posicion: 'Alero',
              equipo: 'DEN',
              edad: 19,
              media: 70,
              potencial: 85,
              atrTiro3: 70,
              atrAtaque: 70,
              atrDefensa: 70,
              ptsPg: 10,
              astPg: 3,
              trbPg: 4,
              factorLongevidad: 1,
              edadRetiro: 38,
            ));
      }

      final segunda = await jugarRisingStarsSiHaceFalta(db);
      expect(segunda, isNotNull);
      final novatosAnio2 = segunda!.statsLocal.map((s) => s.jugadorId).toSet();
      final sophomoresAnio2 =
          segunda.statsVisitante.map((s) => s.jugadorId).toSet();

      expect(novatosAnio2.intersection(novatosAnio1), isEmpty,
          reason: 'quien fue novato el año pasado ya no puede serlo');
      expect(sophomoresAnio2.intersection(novatosAnio1), isNotEmpty,
          reason: 'los novatos del año pasado son los de segundo año de este');
    });
  });

  group('experiencia en la liga', () {
    test('suma las temporadas previas al arranque y las jugadas dentro de '
        'la partida', () async {
      final veterano = (await db.select(db.jugadores).get())
          .firstWhere((j) => j.temporadasPrevias > 0);
      final previas = veterano.temporadasPrevias;

      expect((await experienciaEnLaLiga(db))[veterano.id], previas,
          reason: 'sin nada jugado todavía, solo cuenta lo de antes');

      await temporadaDeEscandalo(veterano.id);
      await archivarEstadisticasDeTemporada(db, 1);

      expect((await experienciaEnLaLiga(db))[veterano.id], previas + 1);
    });
  });
}
