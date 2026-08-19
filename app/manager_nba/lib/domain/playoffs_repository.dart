import 'dart:math';

import 'package:drift/drift.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/database/app_database.dart';
import 'boxscores_serie_repository.dart';
import 'calendario_repository.dart';
import 'campeones_repository.dart';
import 'conferencias.dart';
import 'franquicia_repository.dart';

/// Hueco de un rival que todavía no se conoce: el 1 y el 2 de cada
/// conferencia están en el cuadro desde el primer día, pero su rival sale
/// del play-in. El bracket lo pinta como "Por definir".
const equipoPorDefinir = '';

/// ¿A esta serie le falta todavía saber contra quién se juega?
bool tieneRivalPorDefinir(Serie serie) =>
    serie.equipoA == equipoPorDefinir || serie.equipoB == equipoPorDefinir;

/// Siembra el play-in y la primera ronda parcial (8 equipos por
/// conferencia se saben directamente; los otros 4 juegan el play-in para
/// decidir los puestos 7 y 8). Sustituye cualquier bracket anterior.
///
/// Formato de play-in (igual que la NBA real):
/// - Partido 7 vs 8: el ganador entra directo como seed 7.
/// - Partido 9 vs 10: el ganador sigue vivo, el perdedor queda eliminado.
/// - Partido final de play-in: perdedor del 7-8 vs ganador del 9-10; el
///   ganador entra como seed 8.
Future<void> sembrarPlayoffs(AppDatabase db) async {
  final resultados = await db.select(db.resultadoTemporada).get();
  final porConferencia = <String, List<ResultadoTemporadaData>>{};
  for (final r in resultados) {
    final conferencia = conferenciaPorEquipo[r.equipo];
    if (conferencia == null) continue;
    porConferencia.putIfAbsent(conferencia, () => []).add(r);
  }

  final series = <SeriesPlayoffsCompanion>[];
  for (final conferencia in ['Este', 'Oeste']) {
    final equipos = [...?porConferencia[conferencia]]..sort(_compararPorRecord);
    if (equipos.length < 10) continue;
    final top10 = equipos.take(10).toList();

    // El 1 y el 2 de cada conferencia ya están clasificados y ya tienen su
    // sitio en el cuadro: lo único que falta por saber es contra quién
    // juegan. Se siembran desde el principio con el rival vacío —que el
    // bracket pinta como "Por definir"— y el play-in solo rellena ese hueco
    // (ver _crearRonda1DesdePlayIn). Antes no existían siquiera como serie,
    // así que el cuadro arrancaba con media conferencia en blanco, como si
    // el mejor equipo del año todavía tuviera que clasificarse.
    series.add(_serie(
      conferencia: conferencia,
      ronda: 1,
      etapa: 'ronda1_1v8',
      equipoA: top10[0].equipo,
      equipoB: equipoPorDefinir,
      seedA: 1,
      seedB: 8,
    ));
    series.add(_serie(
      conferencia: conferencia,
      ronda: 1,
      etapa: 'ronda1_2v7',
      equipoA: top10[1].equipo,
      equipoB: equipoPorDefinir,
      seedA: 2,
      seedB: 7,
    ));

    // Ronda 1 ya conocida del todo: 3 vs 6 y 4 vs 5.
    series.add(_serie(
      conferencia: conferencia,
      ronda: 1,
      etapa: 'ronda1_3v6',
      equipoA: top10[2].equipo,
      equipoB: top10[5].equipo,
      seedA: 3,
      seedB: 6,
    ));
    series.add(_serie(
      conferencia: conferencia,
      ronda: 1,
      etapa: 'ronda1_4v5',
      equipoA: top10[3].equipo,
      equipoB: top10[4].equipo,
      seedA: 4,
      seedB: 5,
    ));

    series.add(_serie(
      conferencia: conferencia,
      ronda: 0,
      etapa: 'playin_7v8',
      equipoA: top10[6].equipo,
      equipoB: top10[7].equipo,
      seedA: 7,
      seedB: 8,
      victoriasNecesarias: 1,
    ));
    series.add(_serie(
      conferencia: conferencia,
      ronda: 0,
      etapa: 'playin_9v10',
      equipoA: top10[8].equipo,
      equipoB: top10[9].equipo,
      seedA: 9,
      seedB: 10,
      victoriasNecesarias: 1,
    ));
  }

  await db.delete(db.seriesPlayoffs).go();
  if (series.isNotEmpty) {
    await db.batch((batch) => batch.insertAll(db.seriesPlayoffs, series));
  }
}

SeriesPlayoffsCompanion _serie({
  required String conferencia,
  required int ronda,
  required String etapa,
  required String equipoA,
  required String equipoB,
  required int seedA,
  required int seedB,
  int victoriasNecesarias = 4,
}) {
  return SeriesPlayoffsCompanion.insert(
    conferencia: conferencia,
    ronda: ronda,
    etapa: etapa,
    equipoA: equipoA,
    equipoB: equipoB,
    seedA: seedA,
    seedB: seedB,
    victoriasNecesarias: Value(victoriasNecesarias),
  );
}

int _compararPorRecord(ResultadoTemporadaData a, ResultadoTemporadaData b) {
  double winPct(ResultadoTemporadaData r) {
    final total = r.victorias + r.derrotas;
    return total == 0 ? 0.0 : r.victorias / total;
  }

  final cmp = winPct(b).compareTo(winPct(a));
  if (cmp != 0) return cmp;
  return a.equipo.compareTo(b.equipo); // desempate determinista
}

/// ¿Sigue [equipo] vivo en el play-in o el bracket de playoffs? (false si
/// quedó fuera de los 10 primeros de su conferencia, o si ya fue
/// eliminado).
Future<bool> equipoImplicadoEnPlayoffs(AppDatabase db, String equipo) async {
  final todas = await db.select(db.seriesPlayoffs).get();
  return todas.any((s) =>
      (s.equipoA == equipo || s.equipoB == equipo) &&
      (s.ganador == null || s.ganador == equipo));
}

Future<List<Serie>> leerSeries(AppDatabase db) {
  return (db.select(db.seriesPlayoffs)
        ..orderBy([
          (t) => OrderingTerm.asc(t.ronda),
          (t) => OrderingTerm.asc(t.id),
        ]))
      .get();
}

/// ¿Queda algún partido de play-in por jugar?
///
/// Importa porque el 3-6 y el 4-5 de primera ronda se siembran desde el
/// principio (se saben sin esperar a nadie), y sin esta comprobación se
/// podían jugar antes de que el play-in decidiera quién era el 7 y el 8.
/// En la NBA la primera ronda no empieza hasta que el play-in termina.
Future<bool> playInPendiente(AppDatabase db) async {
  final pendientes = await (db.select(db.seriesPlayoffs)
        ..where((t) => t.ronda.equals(0) & t.ganador.isNull()))
      .get();
  return pendientes.isNotEmpty;
}

/// Las series que se pueden jugar ahora mismo: las de la ronda más baja que
/// siga pendiente. Es lo que impone el orden real de la eliminatoria — no se
/// juega una semifinal antes de que acabe la primera ronda, ni la primera
/// ronda antes de que acabe el play-in.
Future<List<Serie>> seriesJugablesAhora(AppDatabase db) async {
  final pendientes =
      (await leerSeries(db)).where((s) => s.ganador == null).toList();
  if (pendientes.isEmpty) return const [];
  final ronda = pendientes.map((s) => s.ronda).reduce(min);
  return pendientes.where((s) => s.ronda == ronda).toList();
}

/// Simula un partido más de la serie/partido [serieId] (equipoUsuario, si
/// se pasa, usa tu rotación real; el resto de equipos, auto-lineup). Si
/// con este partido se llega a `victoriasNecesarias`, se marca ganador y
/// se genera lo que toque a continuación (siguiente partido de play-in,
/// siguiente ronda, o la final NBA).
/// [semilla] hace el partido reproducible. Sin ella el resultado es
/// distinto en cada ejecución, que es lo que se quiere jugando — pero no en
/// un test: tres "tests inestables" distintos han salido de que los
/// playoffs no se pudieran repetir. Quien quiera un resultado repetible que
/// la pase.
Future<Serie> simularPartidoDeSerie(
  AppDatabase db,
  int serieId, {
  String? equipoUsuario,
  int? semilla,
}) async {
  final serie =
      await (db.select(db.seriesPlayoffs)..where((t) => t.id.equals(serieId)))
          .getSingle();
  if (serie.ganador != null) return serie;
  // El 1 y el 2 esperan rival del play-in: su serie existe en el cuadro
  // desde el primer día, pero no se puede jugar hasta que se sepa contra
  // quién.
  if (tieneRivalPorDefinir(serie)) return serie;

  // No hay fechas reales en playoffs/play-in (no se muestran en el
  // calendario visual), así que para consultar lesiones se usa el "hoy" de
  // la partida — el último día jugado de la temporada regular. Con
  // DateTime.now() se comparaba contra el reloj del ordenador, que va por
  // detrás del calendario del juego: cualquiera lesionado durante el año
  // seguía contando como lesionado en playoffs, por mucho que se hubiera
  // recuperado en enero.
  final fechaPartido = await fechaActualDeLaLiga(db) ?? DateTime.now();

  Future<sim.EquipoPartido> construir(String equipo) {
    return equipo == equipoUsuario
        ? construirEquipoUsuarioParaFecha(db, equipo, fechaPartido)
        : construirAutoParaFecha(db, equipo, fechaPartido);
  }

  final equipoA = await construir(serie.equipoA);
  final equipoB = await construir(serie.equipoB);

  final numeroPartido = serie.victoriasA + serie.victoriasB;
  final aEsLocal = numeroPartido.isEven;
  final boxscore = sim.simularPartido(
    local: aEsLocal ? equipoA : equipoB,
    visitante: aEsLocal ? equipoB : equipoA,
    // Se mezcla con el número de partido para que los siete de una serie no
    // salgan todos idénticos con la misma semilla.
    seed: semilla == null ? null : semilla + serieId * 101 + numeroPartido,
  );
  final ganaA = aEsLocal
      ? boxscore.marcadorLocal > boxscore.marcadorVisitante
      : boxscore.marcadorVisitante > boxscore.marcadorLocal;

  final victoriasA = serie.victoriasA + (ganaA ? 1 : 0);
  final victoriasB = serie.victoriasB + (ganaA ? 0 : 1);
  String? ganador;
  if (victoriasA == serie.victoriasNecesarias) ganador = serie.equipoA;
  if (victoriasB == serie.victoriasNecesarias) ganador = serie.equipoB;

  await guardarBoxscoreDeSerie(db,
      origen: 'playoffs', serieId: serieId, boxscore: boxscore);

  await (db.update(db.seriesPlayoffs)..where((t) => t.id.equals(serieId)))
      .write(SeriesPlayoffsCompanion(
    victoriasA: Value(victoriasA),
    victoriasB: Value(victoriasB),
    ganador: Value(ganador),
  ));

  final actualizada = await (db.select(db.seriesPlayoffs)
        ..where((t) => t.id.equals(serieId)))
      .getSingle();

  if (ganador != null) {
    await _trasConcluirSerie(db, actualizada);
  }

  return actualizada;
}

/// Simula un partido más de tu serie actual (si sigues implicado en el
/// play-in o el bracket) y, a la par, un partido más de cada otra serie
/// todavía pendiente — así el resto del bracket avanza al mismo ritmo que
/// el tuyo, un partido cada vez, igual que el calendario normal. La usan
/// tanto `PlayoffsScreen` como el panel de playoffs integrado en
/// `CalendarioScreen`, para no duplicar esta lógica.
Future<void> avanzarPlayoffsUnPartido(AppDatabase db, String equipoUsuario) async {
  // La foto se toma antes de jugar nada: así un click es un partido por
  // serie, y una eliminatoria que se decida por el camino no arrastra a la
  // siguiente en el mismo click.
  final jugables = await seriesJugablesAhora(db);
  if (jugables.isEmpty) return;

  final tuSerie = jugables
      .where((s) => s.equipoA == equipoUsuario || s.equipoB == equipoUsuario)
      .firstOrNull;
  if (tuSerie != null) {
    await simularPartidoDeSerie(db, tuSerie.id, equipoUsuario: equipoUsuario);
  }

  for (final s in jugables.where((s) => s.id != tuSerie?.id)) {
    await simularPartidoDeSerie(db, s.id, equipoUsuario: equipoUsuario);
  }
}

/// Simula hasta que todas las series de la ronda actual (la más baja entre
/// las que todavía no tienen ganador) queden decididas — varios partidos
/// por serie si hace falta (al mejor de 7), o el enlace del play-in
/// (7v8/9v10 -> final de play-in) dentro de la misma ronda 0.
Future<void> simularRondaPlayoffsCompleta(AppDatabase db) async {
  final series = await leerSeries(db);
  final pendientes = series.where((s) => s.ganador == null).toList();
  if (pendientes.isEmpty) return;
  final rondaActual = pendientes.map((s) => s.ronda).reduce((a, b) => a < b ? a : b);

  while (true) {
    final actuales = await leerSeries(db);
    final pendientesRonda =
        actuales.where((s) => s.ronda == rondaActual && s.ganador == null).toList();
    if (pendientesRonda.isEmpty) break;
    for (final serie in pendientesRonda) {
      await simularPartidoDeSerie(db, serie.id);
    }
  }
}

/// Simula partidos hasta que TODO — play-in, playoffs y final NBA — tenga
/// un ganador, es decir, hasta que se conozca el campeón de la temporada.
/// Con [semilla] los playoffs enteros son reproducibles. Es lo que permite
/// que un test que cierra varias temporadas dé siempre el mismo resultado.
Future<void> simularPlayoffsCompletos(AppDatabase db, {int? semilla}) async {
  var vuelta = 0;
  while (true) {
    // Ronda a ronda, respetando el orden: el play-in primero.
    final jugables = await seriesJugablesAhora(db);
    if (jugables.isEmpty) break;
    for (final serie in jugables) {
      await simularPartidoDeSerie(db, serie.id,
          semilla: semilla == null ? null : semilla + vuelta * 7919);
    }
    vuelta++;
  }
}

/// El mejor de las Finales, con sus medias de la serie. Es el MVP: sale
/// siempre del campeón, como en la NBA (un MVP de Finales del perdedor ha
/// pasado una vez en la historia y no merece la pena modelarlo).
class MvpDeLasFinales {
  final int jugadorId;
  final String nombre;
  final String equipo;
  final int partidos;
  final double puntos;
  final double asistencias;
  final double rebotes;

  const MvpDeLasFinales({
    required this.jugadorId,
    required this.nombre,
    required this.equipo,
    required this.partidos,
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
  });
}

/// Calcula el MVP de las Finales sumando lo que hizo cada jugador del
/// campeón en los partidos de la serie. Devuelve null mientras la Final no
/// tenga ganador.
Future<MvpDeLasFinales?> mvpDeLasFinales(AppDatabase db) async {
  final finalNba = await _buscarSerie(db, 'Final', 'finalNBA');
  if (finalNba?.ganador == null) return null;
  final campeon = finalNba!.ganador!;

  final partidos = await leerBoxscoresDeSerie(db,
      origen: 'playoffs', serieId: finalNba.id);
  if (partidos.isEmpty) return null;

  // El campeón juega unas veces de local y otras de visitante dentro de la
  // misma serie, así que hay que mirar de qué lado está en cada partido.
  final totales = <String, List<int>>{};
  final nombres = <String, String>{};
  var jugados = 0;
  for (final b in partidos) {
    final suyas = b.equipoLocal == campeon
        ? b.statsLocal
        : (b.equipoVisitante == campeon ? b.statsVisitante : null);
    if (suyas == null) continue;
    jugados++;
    for (final e in suyas) {
      nombres[e.jugadorId] = e.nombreFicticio;
      final acumulado = totales.putIfAbsent(e.jugadorId, () => [0, 0, 0]);
      acumulado[0] += e.puntos;
      acumulado[1] += e.asistencias;
      acumulado[2] += e.rebotes;
    }
  }
  if (jugados == 0 || totales.isEmpty) return null;

  double nota(List<int> t) => t[0] + t[1] * 1.5 + t[2] * 1.2;
  final mejor = totales.entries.reduce((a, b) =>
      nota(a.value) >= nota(b.value) ? a : b);
  final jugadorId = int.tryParse(mejor.key);
  if (jugadorId == null) return null;

  return MvpDeLasFinales(
    jugadorId: jugadorId,
    nombre: nombres[mejor.key] ?? '',
    equipo: campeon,
    partidos: jugados,
    puntos: mejor.value[0] / jugados,
    asistencias: mejor.value[1] / jugados,
    rebotes: mejor.value[2] / jugados,
  );
}

Future<Serie?> _buscarSerie(
  AppDatabase db,
  String conferencia,
  String etapa,
) {
  return (db.select(db.seriesPlayoffs)
        ..where((t) =>
            t.conferencia.equals(conferencia) & t.etapa.equals(etapa)))
      .getSingleOrNull();
}

Future<void> _trasConcluirSerie(AppDatabase db, Serie serie) async {
  switch (serie.etapa) {
    case 'playin_7v8':
    case 'playin_9v10':
      await _intentarCrearPlayInFinal(db, serie.conferencia);
    case 'playin_final':
      await _crearRonda1DesdePlayIn(db, serie);
    case 'ronda1_3v6':
    case 'ronda1_4v5':
    case 'ronda1_1v8':
    case 'ronda1_2v7':
      await _intentarGenerarSemis(db, serie.conferencia);
    case 'semis_a':
    case 'semis_b':
      await _intentarGenerarFinalConferencia(db, serie.conferencia);
    case 'finalConferencia':
      await _intentarGenerarFinalNba(db);
    case 'finalNBA':
      await registrarCampeon(db, equipo: serie.ganador!, tipo: 'nba');
    default:
      break;
  }
}

Future<void> _intentarCrearPlayInFinal(AppDatabase db, String conferencia) async {
  final juegoAlto = await _buscarSerie(db, conferencia, 'playin_7v8');
  final juegoBajo = await _buscarSerie(db, conferencia, 'playin_9v10');
  if (juegoAlto?.ganador == null || juegoBajo?.ganador == null) return;

  final yaExiste = await _buscarSerie(db, conferencia, 'playin_final');
  if (yaExiste != null) return;

  final perdedorAlto =
      juegoAlto!.ganador == juegoAlto.equipoA ? juegoAlto.equipoB : juegoAlto.equipoA;
  final seedPerdedorAlto =
      juegoAlto.ganador == juegoAlto.equipoA ? juegoAlto.seedB : juegoAlto.seedA;

  await db.into(db.seriesPlayoffs).insert(_serie(
        conferencia: conferencia,
        ronda: 0,
        etapa: 'playin_final',
        equipoA: perdedorAlto,
        equipoB: juegoBajo!.ganador!,
        seedA: seedPerdedorAlto,
        seedB: juegoBajo.ganador == juegoBajo.equipoA
            ? juegoBajo.seedA
            : juegoBajo.seedB,
        victoriasNecesarias: 1,
      ));
}

/// El play-in no crea las series del 1 y el 2: esas ya existían desde la
/// siembra, con el 1 y el 2 en su sitio. Aquí solo se rellena el rival que
/// faltaba por conocer.
Future<void> _crearRonda1DesdePlayIn(AppDatabase db, Serie playInFinal) async {
  final juegoAlto = await _buscarSerie(db, playInFinal.conferencia, 'playin_7v8');
  if (juegoAlto?.ganador == null) return;
  final seed7 = juegoAlto!.ganador!;
  final seed8 = playInFinal.ganador!;

  Future<void> ponerRival(String etapa, String equipo) async {
    await (db.update(db.seriesPlayoffs)
          ..where((t) =>
              t.conferencia.equals(playInFinal.conferencia) &
              t.etapa.equals(etapa)))
        .write(SeriesPlayoffsCompanion(equipoB: Value(equipo)));
  }

  await ponerRival('ronda1_1v8', seed8);
  await ponerRival('ronda1_2v7', seed7);
}

Future<void> _intentarGenerarSemis(AppDatabase db, String conferencia) async {
  const etapasRonda1 = ['ronda1_1v8', 'ronda1_2v7', 'ronda1_3v6', 'ronda1_4v5'];
  final series = await Future.wait(
      etapasRonda1.map((e) => _buscarSerie(db, conferencia, e)));
  if (series.any((s) => s == null || s.ganador == null)) return;

  final yaExiste = await _buscarSerie(db, conferencia, 'semis_a');
  if (yaExiste != null) return;

  Serie porEtapa(String etapa) =>
      series.firstWhere((s) => s!.etapa == etapa)!;

  await db.batch((batch) => batch.insertAll(db.seriesPlayoffs, [
        _serie(
          conferencia: conferencia,
          ronda: 2,
          etapa: 'semis_a',
          equipoA: porEtapa('ronda1_1v8').ganador!,
          equipoB: porEtapa('ronda1_4v5').ganador!,
          seedA: 0,
          seedB: 0,
        ),
        _serie(
          conferencia: conferencia,
          ronda: 2,
          etapa: 'semis_b',
          equipoA: porEtapa('ronda1_2v7').ganador!,
          equipoB: porEtapa('ronda1_3v6').ganador!,
          seedA: 0,
          seedB: 0,
        ),
      ]));
}

Future<void> _intentarGenerarFinalConferencia(
  AppDatabase db,
  String conferencia,
) async {
  final semisA = await _buscarSerie(db, conferencia, 'semis_a');
  final semisB = await _buscarSerie(db, conferencia, 'semis_b');
  if (semisA?.ganador == null || semisB?.ganador == null) return;

  final yaExiste = await _buscarSerie(db, conferencia, 'finalConferencia');
  if (yaExiste != null) return;

  await db.into(db.seriesPlayoffs).insert(_serie(
        conferencia: conferencia,
        ronda: 3,
        etapa: 'finalConferencia',
        equipoA: semisA!.ganador!,
        equipoB: semisB!.ganador!,
        seedA: 0,
        seedB: 0,
      ));
}

Future<void> _intentarGenerarFinalNba(AppDatabase db) async {
  final finalEste = await _buscarSerie(db, 'Este', 'finalConferencia');
  final finalOeste = await _buscarSerie(db, 'Oeste', 'finalConferencia');
  if (finalEste?.ganador == null || finalOeste?.ganador == null) return;

  final yaExiste = await _buscarSerie(db, 'Final', 'finalNBA');
  if (yaExiste != null) return;

  await db.into(db.seriesPlayoffs).insert(_serie(
        conferencia: 'Final',
        ronda: 4,
        etapa: 'finalNBA',
        equipoA: finalEste!.ganador!,
        equipoB: finalOeste!.ganador!,
        seedA: 0,
        seedB: 0,
      ));
}
