import 'package:drift/drift.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/calendario/generador_calendario.dart';
import '../data/database/app_database.dart';
import 'boxscores_serie_repository.dart';
import 'calendario_repository.dart';
import 'campeones_repository.dart';
import 'franquicia_repository.dart';
import 'grupos_torneo.dart';

/// Récord de un equipo en sus 4 partidos de grupo de la NBA Cup: victorias,
/// derrotas y diferencia de puntos (para desempatar).
class _RecordDeGrupo {
  int victorias = 0;
  int derrotas = 0;
  int diferencial = 0;
}

Future<Map<String, _RecordDeGrupo>> _recordDeGrupoPorEquipo(AppDatabase db) async {
  final partidos = await (db.select(db.partidosCalendario)
        ..where((t) =>
            t.esTorneoTemporada.equals(true) &
            t.jugado.equals(true) &
            t.fase.equals(faseRegular)))
      .get();

  final registros = <String, _RecordDeGrupo>{};
  for (final p in partidos) {
    final registro =
        registros.putIfAbsent(p.equipoPropietario, () => _RecordDeGrupo());
    if (p.marcadorPropietario! > p.marcadorRival!) {
      registro.victorias++;
    } else {
      registro.derrotas++;
    }
    registro.diferencial += p.marcadorPropietario! - p.marcadorRival!;
  }
  return registros;
}

Future<bool> _faseDeGruposCompleta(AppDatabase db) async {
  final partidosDeGrupo = await (db.select(db.partidosCalendario)
        ..where((t) =>
            t.esTorneoTemporada.equals(true) & t.fase.equals(faseRegular)))
      .get();
  if (partidosDeGrupo.isEmpty) return false;
  return partidosDeGrupo.every((p) => p.jugado);
}

/// Lo que ha pasado con la NBA Cup durante una simulación, para que la UI
/// pueda avisar sin tener que recalcular nada.
class NovedadesCopa {
  /// Fecha en la que se ha programado *tu* Final de la NBA Cup en el
  /// calendario (solo si eres finalista). Null si no llegaste a la final.
  final DateTime? finalDelUsuario;

  /// Campeón recién coronado (solo la vez que se decide), y el id de su
  /// serie para poder abrir el boxscore del partido.
  final String? campeon;
  final int? serieIdFinal;

  const NovedadesCopa({
    this.finalDelUsuario,
    this.campeon,
    this.serieIdFinal,
  });

  static const ninguna = NovedadesCopa();

  bool get hayAlgoQueContar => finalDelUsuario != null || campeon != null;
}

/// Si la fase de grupos de la NBA Cup (4 partidos por equipo) ya se ha
/// jugado por completo en los 30 equipos y los cuartos todavía no se han
/// sembrado esta franquicia, calcula los 6 cabezas de grupo + 2 comodines,
/// siembra los 4 cuartos de final (2 por conferencia) y los resuelve junto
/// con la semifinal automáticamente — cuentan para la temporada regular
/// como un partido más, así que no hace falta visitar ninguna pantalla
/// aparte para jugarlos, igual que el resto de la temporada se simula en
/// bloques sin intervenir partido a partido.
///
/// La Final es la única excepción y no cuenta para el récord:
/// - si eres uno de los dos finalistas, se te programa como un partido más
///   del calendario (en el primer día libre tras la fase de grupos), para
///   que la juegues desde ahí sin salir de la pantalla;
/// - si no lo eres, se juega sola al momento y lo único que verás es el
///   aviso del campeón, con acceso a las estadísticas de ese partido.
///
/// Idempotente: llamadas posteriores no vuelven a sembrar ni resolver nada.
Future<NovedadesCopa> sembrarCuartosDeTorneoSiToca(
  AppDatabase db, {
  String? equipoUsuario,
}) async {
  final estado = await (db.select(db.istTemporada)..where((t) => t.id.equals(0)))
      .getSingleOrNull();
  if (estado != null && !estado.faseGruposActiva) return NovedadesCopa.ninguna;
  if (!await _faseDeGruposCompleta(db)) return NovedadesCopa.ninguna;

  final registros = await _recordDeGrupoPorEquipo(db);

  double winPct(String equipo) {
    final r = registros[equipo];
    if (r == null) return 0.0;
    final total = r.victorias + r.derrotas;
    return total == 0 ? 0.0 : r.victorias / total;
  }

  int comparar(String a, String b) {
    final porRecord = winPct(b).compareTo(winPct(a));
    if (porRecord != 0) return porRecord;
    final diferencialA = registros[a]?.diferencial ?? 0;
    final diferencialB = registros[b]?.diferencial ?? 0;
    final porDiferencial = diferencialB.compareTo(diferencialA);
    if (porDiferencial != 0) return porDiferencial;
    return a.compareTo(b); // desempate determinista
  }

  final series = <SeriesTorneoCompanion>[];
  for (final conferencia in ['Este', 'Oeste']) {
    final ganadoresDeGrupo = <String>[];
    final segundosDeGrupo = <String>[];
    for (final grupo in gruposDeConferencia(conferencia)) {
      final equiposDeEseGrupo = equiposDelGrupo(grupo)..sort(comparar);
      ganadoresDeGrupo.add(equiposDeEseGrupo[0]);
      segundosDeGrupo.add(equiposDeEseGrupo[1]);
    }
    segundosDeGrupo.sort(comparar);
    final comodin = segundosDeGrupo.first;

    final clasificados = [...ganadoresDeGrupo, comodin]..sort(comparar);
    series.add(_serieTorneo(
      conferencia: conferencia,
      ronda: 1,
      etapa: 'cuartos_a',
      equipoA: clasificados[0],
      equipoB: clasificados[3],
      seedA: 1,
      seedB: 4,
    ));
    series.add(_serieTorneo(
      conferencia: conferencia,
      ronda: 1,
      etapa: 'cuartos_b',
      equipoA: clasificados[1],
      equipoB: clasificados[2],
      seedA: 2,
      seedB: 3,
    ));
  }

  await db.delete(db.seriesTorneo).go();
  await db.batch((batch) => batch.insertAll(db.seriesTorneo, series));
  await db.into(db.istTemporada).insertOnConflictUpdate(
        IstTemporadaCompanion.insert(
          id: const Value(0),
          faseGruposActiva: const Value(false),
        ),
      );

  // Cuartos y semifinal se resuelven ya mismo (cuentan para el récord,
  // como cualquier otro partido); la final se trata aparte.
  while (true) {
    final pendientes = await (db.select(db.seriesTorneo)
          ..where((t) => t.ronda.isSmallerThanValue(3) & t.ganador.isNull()))
        .get();
    if (pendientes.isEmpty) break;
    for (final serie in pendientes) {
      await simularPartidoDeSerieTorneo(db, serie.id,
          equipoUsuario: equipoUsuario);
    }
  }

  final finalCopa = await _buscarSerieTorneo(db, 'Final', 'final');
  if (finalCopa == null) return NovedadesCopa.ninguna;

  final eresFinalista = equipoUsuario != null &&
      (finalCopa.equipoA == equipoUsuario || finalCopa.equipoB == equipoUsuario);

  if (eresFinalista) {
    final fecha = await _programarFinalDeCopaEnCalendario(
        db, equipoUsuario, finalCopa);
    return NovedadesCopa(finalDelUsuario: fecha);
  }

  // No eres finalista: la Final se juega sola y solo te enteras del
  // campeón (con sus estadísticas a un toque).
  await simularPartidoDeSerieTorneo(db, finalCopa.id,
      equipoUsuario: equipoUsuario);
  final resuelta = await (db.select(db.seriesTorneo)
        ..where((t) => t.id.equals(finalCopa.id)))
      .getSingle();
  return NovedadesCopa(campeon: resuelta.ganador, serieIdFinal: resuelta.id);
}

/// Mete la Final de la NBA Cup en el calendario del usuario como un partido
/// más, en el primer día libre después de todo lo que ya tiene jugado o
/// programado de la fase de grupos. Va con `fase = faseFinalCopa`: se juega
/// desde el calendario igual que cualquier otro día, pero no suma al récord
/// ni a las estadísticas de temporada.
Future<DateTime> _programarFinalDeCopaEnCalendario(
  AppDatabase db,
  String equipoUsuario,
  SerieTorneo finalCopa,
) async {
  final yaProgramada = await (db.select(db.partidosCalendario)
        ..where((t) =>
            t.equipoPropietario.equals(equipoUsuario) &
            t.fase.equals(faseFinalCopa)))
      .getSingleOrNull();
  if (yaProgramada != null) return yaProgramada.fecha;

  final partidos = await (db.select(db.partidosCalendario)
        ..where((t) => t.equipoPropietario.equals(equipoUsuario)))
      .get();
  DateTime soloDia(DateTime f) => DateTime(f.year, f.month, f.day);
  final ocupadas = partidos.map((p) => soloDia(p.fecha)).toSet();

  final referencias = [
    ...partidos.where((p) => p.esTorneoTemporada).map((p) => p.fecha),
    ...partidos.where((p) => p.jugado).map((p) => p.fecha),
  ];
  var cursor = soloDia(referencias.reduce((a, b) => a.isAfter(b) ? a : b))
      .add(const Duration(days: 1));
  while (ocupadas.contains(cursor)) {
    cursor = cursor.add(const Duration(days: 1));
  }

  final rival = finalCopa.equipoA == equipoUsuario
      ? finalCopa.equipoB
      : finalCopa.equipoA;
  await db.into(db.partidosCalendario).insert(PartidosCalendarioCompanion.insert(
        equipoPropietario: equipoUsuario,
        fecha: cursor,
        rival: rival,
        esLocal: finalCopa.equipoA == equipoUsuario,
        esTorneoTemporada: const Value(true),
        fase: const Value(faseFinalCopa),
      ));
  return cursor;
}

/// Juega la Final de la NBA Cup que estaba programada en el calendario del
/// usuario (la fila [partido]) y marca esa fila como jugada. No toca el
/// récord ni las estadísticas de temporada: eso lo decide la ronda dentro
/// de [simularPartidoDeSerieTorneo], y la final es la ronda que no suma.
Future<sim.Boxscore?> jugarFinalDeCopaDelCalendario(
  AppDatabase db,
  PartidosCalendarioData partido, {
  required String equipoUsuario,
}) async {
  final finalCopa = await _buscarSerieTorneo(db, 'Final', 'final');
  if (finalCopa == null || finalCopa.ganador != null) return null;

  final resultado = await simularPartidoDeSerieTorneo(db, finalCopa.id,
      equipoUsuario: equipoUsuario);
  final boxscore = resultado.boxscore;
  if (boxscore == null) return null;

  final marcadorPropietario = partido.esLocal
      ? boxscore.marcadorLocal
      : boxscore.marcadorVisitante;
  final marcadorRival =
      partido.esLocal ? boxscore.marcadorVisitante : boxscore.marcadorLocal;

  await (db.update(db.partidosCalendario)..where((t) => t.id.equals(partido.id)))
      .write(PartidosCalendarioCompanion(
    jugado: const Value(true),
    marcadorPropietario: Value(marcadorPropietario),
    marcadorRival: Value(marcadorRival),
  ));

  return boxscore;
}

SeriesTorneoCompanion _serieTorneo({
  required String conferencia,
  required int ronda,
  required String etapa,
  required String equipoA,
  required String equipoB,
  required int seedA,
  required int seedB,
}) {
  return SeriesTorneoCompanion.insert(
    conferencia: conferencia,
    ronda: ronda,
    etapa: etapa,
    equipoA: equipoA,
    equipoB: equipoB,
    seedA: seedA,
    seedB: seedB,
  );
}

Future<List<SerieTorneo>> leerSeriesTorneo(AppDatabase db) {
  return (db.select(db.seriesTorneo)
        ..orderBy([
          (t) => OrderingTerm.asc(t.ronda),
          (t) => OrderingTerm.asc(t.id),
        ]))
      .get();
}

/// Simula el (único) partido de la serie [serieId] de la NBA Cup
/// (equipoUsuario, si se pasa, usa tu rotación real; el resto de equipos,
/// auto-lineup), guarda su boxscore para poder consultarlo después y marca
/// ganador. Cuartos y semifinal además suman esta victoria/derrota a
/// `ResultadoTemporada` y las estadísticas de los jugadores a
/// `EstadisticasTemporadaJugador` — cuentan para la temporada regular; la
/// final no. Si con este partido se decide la serie, genera lo que toque a
/// continuación (siguiente ronda, o corona campeón en la final).
Future<({SerieTorneo serie, sim.Boxscore? boxscore})> simularPartidoDeSerieTorneo(
  AppDatabase db,
  int serieId, {
  String? equipoUsuario,
}) async {
  final serie = await (db.select(db.seriesTorneo)..where((t) => t.id.equals(serieId)))
      .getSingle();
  if (serie.ganador != null) return (serie: serie, boxscore: null);

  // No hay fechas reales en la fase eliminatoria de la Cup (no se muestra
  // en el calendario visual), así que para consultar lesiones se usa el
  // "hoy" de la partida y no el reloj del ordenador: ese va por detrás del
  // calendario del juego, y comparando contra él todo lesionado del año
  // parecía seguir lesionado.
  final fechaPartido = await fechaActualDeLaLiga(db) ?? DateTime.now();

  Future<sim.EquipoPartido> construir(String equipo) {
    return equipo == equipoUsuario
        ? construirEquipoUsuarioParaFecha(db, equipo, fechaPartido)
        : construirAutoParaFecha(db, equipo, fechaPartido);
  }

  final equipoA = await construir(serie.equipoA);
  final equipoB = await construir(serie.equipoB);

  // Partido único, sin ida y vuelta (no hay fechas reales que decidan
  // quién juega en casa): A siempre local.
  final boxscore = sim.simularPartido(local: equipoA, visitante: equipoB);
  final ganaA = boxscore.marcadorLocal > boxscore.marcadorVisitante;
  final ganador = ganaA ? serie.equipoA : serie.equipoB;

  await guardarBoxscoreDeSerie(db,
      origen: 'torneo', serieId: serieId, boxscore: boxscore);

  await (db.update(db.seriesTorneo)..where((t) => t.id.equals(serieId)))
      .write(SeriesTorneoCompanion(ganador: Value(ganador)));

  // Cuartos (ronda 1) y semifinal (ronda 2) cuentan para la temporada
  // regular; la final (ronda 3) no.
  if (serie.ronda < 3) {
    await actualizarResultadoTemporada(db, serie.equipoA, ganaA);
    await actualizarResultadoTemporada(db, serie.equipoB, !ganaA);
    await actualizarEstadisticasJugadores(db, boxscore.statsLocal);
    await actualizarEstadisticasJugadores(db, boxscore.statsVisitante);
  }

  final actualizada =
      await (db.select(db.seriesTorneo)..where((t) => t.id.equals(serieId)))
          .getSingle();
  await _trasConcluirSerieTorneo(db, actualizada);
  return (serie: actualizada, boxscore: boxscore);
}

Future<SerieTorneo?> _buscarSerieTorneo(
  AppDatabase db,
  String conferencia,
  String etapa,
) {
  return (db.select(db.seriesTorneo)
        ..where((t) =>
            t.conferencia.equals(conferencia) & t.etapa.equals(etapa)))
      .getSingleOrNull();
}

Future<void> _trasConcluirSerieTorneo(AppDatabase db, SerieTorneo serie) async {
  switch (serie.etapa) {
    case 'cuartos_a':
    case 'cuartos_b':
      await _intentarGenerarSemisTorneo(db, serie.conferencia);
    case 'semis':
      await _intentarGenerarFinalTorneo(db);
    case 'final':
      await registrarCampeon(db, equipo: serie.ganador!, tipo: 'ist');
      await db.into(db.istTemporada).insertOnConflictUpdate(
            IstTemporadaCompanion.insert(
              id: const Value(0),
              faseGruposActiva: const Value(false),
              campeonAnunciado: const Value(true),
              equipoCampeon: Value(serie.ganador),
            ),
          );
    default:
      break;
  }
}

Future<void> _intentarGenerarSemisTorneo(AppDatabase db, String conferencia) async {
  final a = await _buscarSerieTorneo(db, conferencia, 'cuartos_a');
  final b = await _buscarSerieTorneo(db, conferencia, 'cuartos_b');
  if (a?.ganador == null || b?.ganador == null) return;

  final yaExiste = await _buscarSerieTorneo(db, conferencia, 'semis');
  if (yaExiste != null) return;

  await db.into(db.seriesTorneo).insert(_serieTorneo(
        conferencia: conferencia,
        ronda: 2,
        etapa: 'semis',
        equipoA: a!.ganador!,
        equipoB: b!.ganador!,
        seedA: 0,
        seedB: 0,
      ));
}

Future<void> _intentarGenerarFinalTorneo(AppDatabase db) async {
  final este = await _buscarSerieTorneo(db, 'Este', 'semis');
  final oeste = await _buscarSerieTorneo(db, 'Oeste', 'semis');
  if (este?.ganador == null || oeste?.ganador == null) return;

  final yaExiste = await _buscarSerieTorneo(db, 'Final', 'final');
  if (yaExiste != null) return;

  await db.into(db.seriesTorneo).insert(_serieTorneo(
        conferencia: 'Final',
        ronda: 3,
        etapa: 'final',
        equipoA: este!.ganador!,
        equipoB: oeste!.ganador!,
        seedA: 0,
        seedB: 0,
      ));
}

/// Resuelve de golpe lo que quede de la NBA Cup — cuartos, semifinal y
/// final — hasta que se conozca el campeón. En el juego normal no hace
/// falta (cuartos y semis se resuelven al sembrarse, y la final o la juegas
/// desde el calendario o se resuelve sola); existe para poder forzar el
/// desenlace desde tests.
Future<void> simularTorneoCompleto(AppDatabase db) async {
  while (true) {
    final pendientes = await (db.select(db.seriesTorneo)
          ..where((t) => t.ganador.isNull()))
        .get();
    if (pendientes.isEmpty) break;
    for (final serie in pendientes) {
      await simularPartidoDeSerieTorneo(db, serie.id);
    }
  }
}
