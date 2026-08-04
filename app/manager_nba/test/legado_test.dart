import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/camisetas_repository.dart';
import 'package:manager_nba/domain/carrera_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/hall_fama_repository.dart';
import 'package:manager_nba/domain/legado_real_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/progresion_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

/// Cierra la temporada sin simular los 82 partidos: récords ficticios,
/// estadísticas inventadas para poder construir carreras, y playoffs
/// resueltos. Lo que interesa aquí es el legado, no la simulación.
Future<void> _cerrarTemporada(AppDatabase db, Random rng) async {
  final equipos = await db.select(db.resultadoTemporada).get();
  for (final e in equipos) {
    await (db.update(db.resultadoTemporada)
          ..where((t) => t.equipo.equals(e.equipo)))
        .write(ResultadoTemporadaCompanion(
      victorias: Value(20 + rng.nextInt(43)),
      derrotas: Value(20 + rng.nextInt(43)),
    ));
  }

  // Estadísticas de la temporada para todos los jugadores en activo, a
  // partir de sus promedios de referencia.
  final activos = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();
  await db.batch((batch) {
    batch.insertAll(
      db.estadisticasTemporadaJugador,
      activos.where((j) => j.equipo != 'FA').map((j) =>
          EstadisticasTemporadaJugadorCompanion.insert(
            jugadorId: Value(j.id),
            partidosJugados: const Value(70),
            puntosTotales: Value((j.ptsPg * 70).round()),
            asistenciasTotales: Value((j.astPg * 70).round()),
            rebotesTotales: Value((j.trbPg * 70).round()),
          )),
      mode: InsertMode.insertOrReplace,
    );
  });

  await sembrarPlayoffs(db);
  await simularPlayoffsCompletos(db);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');

    // Cerrar la temporada resuelve los playoffs, y eso apunta al campeón en
    // el registro compartido entre partidas (campeones_repository.dart); en
    // un test se sustituye por uno en memoria para no depender de
    // `path_provider`.
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
  });

  tearDown(() async {
    await db.close();
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  test('al crear la franquicia todos los jugadores tienen dorsal, único '
      'dentro de su equipo', () async {
    final jugadores = await (db.select(db.jugadores)
          ..where((t) => t.retirado.equals(false)))
        .get();
    expect(jugadores.every((j) => j.dorsal != null), isTrue);

    final porEquipo = <String, List<int>>{};
    for (final j in jugadores) {
      if (j.equipo == 'FA') continue;
      porEquipo.putIfAbsent(j.equipo, () => []).add(j.dorsal!);
    }
    for (final entry in porEquipo.entries) {
      expect(entry.value.toSet().length, entry.value.length,
          reason: '${entry.key} repite dorsal');
    }
  });

  test('una camiseta retirada bloquea ese dorsal en su equipo para siempre',
      () async {
    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('LAL')))
        .get();
    final leyenda = plantilla.first;

    await retirarCamiseta(db,
        equipo: 'LAL', jugadorId: leyenda.id, temporada: 1);

    final retiradas = await leerCamisetasRetiradas(db, 'LAL');
    expect(retiradas, hasLength(1));
    expect(retiradas.first.dorsal, leyenda.dorsal);

    // Aunque el jugador desaparezca de la plantilla, nadie hereda su número.
    await (db.update(db.jugadores)..where((t) => t.id.equals(leyenda.id)))
        .write(const JugadoresCompanion(
            equipo: Value(equipoRetirados), retirado: Value(true)));

    final rng = Random(3);
    for (var t = 1; t <= 6; t++) {
      await _cerrarTemporada(db, rng);
      await empezarNuevaTemporada(db, random: rng);
    }

    final actuales = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('LAL')))
        .get();
    expect(actuales.any((j) => j.dorsal == leyenda.dorsal), isFalse,
        reason: 'el dorsal retirado no se puede reutilizar');

    // Y retirar dos veces la misma no duplica. Se cuenta lo de ESTE jugador,
    // no lo del equipo entero: en seis temporadas los Lakers cuelgan más
    // camisetas de otras leyendas que se van retirando.
    await retirarCamiseta(db,
        equipo: 'LAL', jugadorId: leyenda.id, temporada: 3);
    expect(
        (await leerCamisetasRetiradas(db, 'LAL'))
            .where((c) => c.jugadorId == leyenda.id),
        hasLength(1));
  });

  test('el mismo jugador puede tener camiseta retirada en varios equipos: '
      'ya la tenga en uno no impide colgarla en otro', () async {
    final leyenda = (await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals('CLE')))
            .get())
        .first;

    await retirarCamiseta(db,
        equipo: 'CLE', jugadorId: leyenda.id, temporada: 1);
    await retirarCamiseta(db,
        equipo: 'MIA', jugadorId: leyenda.id, temporada: 1);
    await retirarCamiseta(db,
        equipo: 'LAL', jugadorId: leyenda.id, temporada: 1);

    // El caso de LeBron: la comprobación de "ya retirada" no miraba el
    // equipo, así que en cuanto colgaba en el primero los otros dos se
    // quedaban sin nada.
    for (final equipo in ['CLE', 'MIA', 'LAL']) {
      expect(
          (await leerCamisetasRetiradas(db, equipo))
              .where((c) => c.jugadorId == leyenda.id),
          hasLength(1),
          reason: '$equipo tendría que haberle retirado la camiseta');
    }

    // Y sigue sin duplicar dentro del mismo equipo.
    await retirarCamiseta(db,
        equipo: 'MIA', jugadorId: leyenda.id, temporada: 2);
    expect(
        (await leerCamisetasRetiradas(db, 'MIA'))
            .where((c) => c.jugadorId == leyenda.id),
        hasLength(1));
  });

  test('la camiseta se retira con el número real del jugador en ESE equipo, '
      'no con el que le tocara en tu partida', () async {
    // El caso que reportó el usuario: a Westbrook, Oklahoma le retiraba el
    // 34 —un número que le había sorteado el juego, porque el dataset no
    // trae el suyo— en vez del 0 que llevó de verdad allí.
    final westbrook = await (db.select(db.jugadores)
          ..where((t) => t.nombreReal.equals('Russell Westbrook')))
        .getSingle();
    await (db.update(db.jugadores)..where((t) => t.id.equals(westbrook.id)))
        .write(const JugadoresCompanion(dorsal: Value(34)));

    await retirarCamiseta(db,
        equipo: 'OKC', jugadorId: westbrook.id, temporada: 2);

    final retirada = (await leerCamisetasRetiradas(db, 'OKC'))
        .firstWhere((c) => c.jugadorId == westbrook.id);
    expect(retirada.dorsal, 0);
  });

  test('las medias de carrera cuadran con lo archivado temporada a '
      'temporada, incluidas las etapas por equipo', () async {
    final rng = Random(11);
    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('LAL'))
          ..orderBy([(t) => OrderingTerm.desc(t.media)]))
        .get();
    final seguido = plantilla.first;

    for (var t = 1; t <= 4; t++) {
      await _cerrarTemporada(db, rng);
      await empezarNuevaTemporada(db, random: rng);
    }

    final carrera = await leerCarrera(db, seguido.id);
    expect(carrera, isNotNull);

    final archivadas = await (db.select(db.historialEstadisticasJugador)
          ..where((t) => t.jugadorId.equals(seguido.id)))
        .get();
    expect(carrera!.partidos,
        archivadas.fold<int>(0, (a, t) => a + t.partidosJugados));
    expect(carrera.puntos,
        archivadas.fold<int>(0, (a, t) => a + t.puntosTotales));
    expect(carrera.temporadas, archivadas.length);
    expect(carrera.puntosPorPartido,
        closeTo(carrera.puntos / carrera.partidos, 0.001));

    // Las etapas cubren todas las temporadas, sin solaparse.
    final temporadasEnEtapas = <int>{};
    for (final e in carrera.etapas) {
      for (var t = e.desdeTemporada; t <= e.hastaTemporada; t++) {
        expect(temporadasEnEtapas.add(t), isTrue, reason: 'temporada $t repetida');
      }
    }
    expect(temporadasEnEtapas.length, archivadas.length);
  });

  test('los dorsales reales se respetan: las estrellas conocidas llevan su '
      'número de verdad', () async {
    final jugadores = await db.select(db.jugadores).get();
    Jugador porNombreReal(String nombre) =>
        jugadores.firstWhere((j) => j.nombreReal == nombre);

    expect(porNombreReal('LeBron James').dorsal, 23);
    expect(porNombreReal('Stephen Curry').dorsal, 30);
    expect(porNombreReal('Nikola Jokić').dorsal, 15);
    expect(porNombreReal('Luka Dončić').dorsal, 77);
    // Los números salen de la plantilla real actual, no de la histórica:
    // Durant lleva el 7 en Houston y Antetokounmpo el 7 en Miami.
    expect(porNombreReal('Kevin Durant').dorsal, 7);
    expect(porNombreReal('Giannis Antetokounmpo').dorsal, 7);
  });

  test('las leyendas que ya venían hechas entran en el Hall of Fame aunque '
      'solo jueguen unas pocas temporadas contigo', () async {
    final rng = Random(21);
    // 10 temporadas: suficiente para que se retiren LeBron (41 años),
    // Curry y Durant (37) y Antetokounmpo (31).
    for (var t = 1; t <= 10; t++) {
      await _cerrarTemporada(db, rng);
      await empezarNuevaTemporada(db, random: rng);
    }

    final miembros = await leerHallDeLaFama(db);
    final nombres = miembros.map((m) => m.nombreJugador).toSet();
    final jugadores = await db.select(db.jugadores).get();

    for (final leyenda in const [
      'LeBron James',
      'Stephen Curry',
      'Kevin Durant',
      'Giannis Antetokounmpo',
    ]) {
      final j = jugadores.firstWhere((j) => j.nombreReal == leyenda);
      // A los mejores ya no los retira el calendario, así que en diez años
      // alguno puede seguir jugando (ver mediaQueAguantaElRetiro). Lo que
      // no puede pasar es que se haya retirado y no esté en el Hall.
      if (!j.retirado) {
        // Sigue jugando por una de dos razones, las dos legítimas: aún no
        // le ha llegado su edad de retiro, o le ha llegado pero todavía es
        // de los mejores (ver mediaQueAguantaElRetiro). Exigir solo lo
        // segundo estaba mal: a Giannis le tocó una edad de retiro alta y
        // seguía en activo con media 69, que es lo normal.
        expect(
            j.edad <= j.edadRetiro || j.media >= mediaQueAguantaElRetiro,
            isTrue,
            reason: '$leyenda sigue en activo con ${j.edad} años, media '
                '${j.media} y edad de retiro ${j.edadRetiro}');
        continue;
      }
      expect(nombres, contains(j.nombreFicticio),
          reason: '$leyenda debería estar en el Hall of Fame');
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('el Hall of Fame es exigente: entran unos pocos y siempre retirados '
      'con carrera larga', () async {
    final rng = Random(5);
    for (var t = 1; t <= 15; t++) {
      await _cerrarTemporada(db, rng);
      await empezarNuevaTemporada(db, random: rng);
    }

    final miembros = await leerHallDeLaFama(db);
    expect(miembros, isNotEmpty, reason: 'en 15 temporadas debería entrar alguien');

    final retirados = await (db.select(db.jugadores)
          ..where((t) => t.retirado.equals(true)))
        .get();
    final idsRetirados = retirados.map((j) => j.id).toSet();

    for (final m in miembros) {
      expect(idsRetirados, contains(m.jugadorId),
          reason: '${m.nombreJugador} sigue en activo');

      // Dos caminos de entrada: lo hecho en tu partida (el umbral de
      // siempre), o su carrera NBA real de verdad (ver
      // legado_real_repository.dart) — ese segundo camino puede admitir a
      // alguien cuya `puntuacion` simulada se quede corta, así que no basta
      // con mirar `m.puntuacion` sola.
      final jugador = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(m.jugadorId)))
          .getSingleOrNull();
      final porReal =
          jugador != null && await entraEnHofReal(jugador.nombreReal);
      expect(m.puntuacion >= umbralHallDeLaFama || porReal, isTrue,
          reason: '${m.nombreJugador} no cumple ni por partida ni por '
              'carrera real');

      if (!porReal) {
        final carrera = await leerCarrera(db, m.jugadorId);
        expect(carrera!.temporadasTotales, greaterThanOrEqualTo(6));
      }
    }

    // No puede entrar cualquiera: como mucho una fracción pequeña de los
    // que se han retirado.
    expect(miembros.length / idsRetirados.length, lessThan(0.25),
        reason: '${miembros.length} de ${idsRetirados.length} retirados es '
            'demasiado para un Hall of Fame');
  }, timeout: const Timeout(Duration(minutes: 3)));
}
