import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/database/app_database.dart';
import 'boxscores_serie_repository.dart';
import 'carrera_repository.dart';
import 'conferencias.dart';
import 'forma_repository.dart';
import 'jugador_mapping.dart';
import 'posiciones.dart';
import 'tipo_premio.dart';

/// Los dos "equipos" del All-Star. No son franquicias: se guardan en
/// `equipos_info.dart` con sus propios colores para que el boxscore se vea
/// igual de bien que el de un partido normal.
const equipoAllStarEste = 'Este';
const equipoAllStarOeste = 'Oeste';

/// Y los dos del Rising Stars, que enfrenta a los rookies con los de
/// segundo año.
const equipoNovatos = 'Novatos';
const equipoSophomores = 'Sophomores';

/// Identificadores de los partidos del fin de semana dentro de
/// `BoxscoresSerie`. No hay ninguna serie detrás: son partidos sueltos, uno
/// por temporada, así que basta un origen propio con un id fijo.
const _origenAllStar = 'allstar';
const _origenRisingStars = 'risingstars';
const _idPartidoSuelto = 0;

/// Convocados por conferencia: 5 titulares y 5 suplentes.
const titularesPorConferencia = 5;
const convocadosPorConferencia = 10;

/// Minutos de cada uno de los 5 titulares y 5 suplentes de cada
/// conferencia. Reparto plano a propósito: en el All-Star real nadie se
/// deja la piel y los minutos están muy repartidos.
const _minutosAllStar = [26, 26, 26, 26, 26, 22, 22, 22, 22, 22];

/// Cuánto ayuda ganar el partido a llevarse el MVP. En el All-Star de verdad
/// el MVP sale casi siempre del equipo ganador, pero una exhibición de 40
/// puntos del perdedor también se lo lleva.
const _bonusMvpGanador = 1.12;

// ---------------------------------------------------------------------------
// Convocatoria y votación
// ---------------------------------------------------------------------------

/// Un jugador convocado al All-Star, con el porqué: lo que está haciendo
/// esta temporada y los votos que ha reunido.
class ConvocadoAllStar {
  final Jugador jugador;
  final String conferencia;
  final bool titular;

  /// Puntos + asistencias + rebotes por partido, ponderados. Es el criterio
  /// que decide quién va: lo que está haciendo este año, no su fama.
  final double valoracion;

  /// Votos del público, en miles. Salen de la valoración, así que el orden
  /// es el mismo: no hay sorteo, solo una forma de contarlo.
  final int votos;

  const ConvocadoAllStar({
    required this.jugador,
    required this.conferencia,
    required this.titular,
    required this.valoracion,
    required this.votos,
  });
}

/// Lo que están haciendo todos esta temporada, para ordenar la convocatoria:
/// puntos + asistencias + rebotes por partido, ponderados.
///
/// Con la temporada ya empezada manda el rendimiento y punto: quien no ha
/// jugado ni un partido no es All-Star por mucha fama que traiga. Antes del
/// primer partido no hay nada que mirar y se cae de vuelta a la media del
/// dataset — para todos a la vez, que es lo importante: mezclar las dos
/// escalas en la misma lista dejaba fuera a quien estaba haciendo la
/// temporada de su vida solo porque su media de partida era baja.
class _Valoraciones {
  final Map<int, double> porJugador;
  final bool temporadaEmpezada;

  /// Qué parte de la temporada regular se lleva jugada, de 0 a 1. Es lo que
  /// hace que el recuento suba solo: en noviembre los votos son los que son
  /// en noviembre, no los de febrero.
  final double avance;

  const _Valoraciones(this.porJugador, this.temporadaEmpezada, this.avance);

  double de(Jugador j) => temporadaEmpezada
      ? (porJugador[j.id] ?? 0)
      : j.media.toDouble();
}

/// Partidos de temporada regular que juega cada equipo. Se usa solo para
/// saber por dónde va la votación, no para simular nada.
const _partidosDeTemporadaRegular = 82;

Future<_Valoraciones> _valoracionesDeLaTemporada(AppDatabase db) async {
  final estadisticas = await db.select(db.estadisticasTemporadaJugador).get();

  // Ganar cuenta, igual que en los premios de fin de temporada
  // (calcularPremios, mismo peso *10): entre dos números parecidos, el de
  // un equipo con más victorias tira más. Sin esto, un buen jugador en un
  // equipo de 20 victorias competía en igualdad con uno igual de bueno en
  // un equipo de 55, cuando en la NBA real eso también pesa en la votación.
  final jugadores = await db.select(db.jugadores).get();
  final equipoDeJugador = {for (final j in jugadores) j.id: j.equipo};
  final resultados = await db.select(db.resultadoTemporada).get();
  final winPctPorEquipo = {
    for (final r in resultados)
      r.equipo: (r.victorias + r.derrotas) == 0
          ? 0.0
          : r.victorias / (r.victorias + r.derrotas),
  };

  final porJugador = {
    for (final e in estadisticas)
      if (e.partidosJugados > 0)
        e.jugadorId: (e.puntosTotales +
                    e.asistenciasTotales * 1.5 +
                    e.rebotesTotales * 1.2) /
                e.partidosJugados +
            (winPctPorEquipo[equipoDeJugador[e.jugadorId]] ?? 0.0) * 10,
  };
  final jugadosMax = estadisticas.isEmpty
      ? 0
      : estadisticas
          .map((e) => e.partidosJugados)
          .reduce((a, b) => a > b ? a : b);
  final avance =
      (jugadosMax / _partidosDeTemporadaRegular).clamp(0.0, 1.0).toDouble();
  return _Valoraciones(porJugador, porJugador.isNotEmpty, avance);
}

/// ¿Hay ya votación que enseñar? Antes del primer partido no: un recuento
/// completo el día de la presentación no es una votación, es un adorno — la
/// pantalla lo dice y espera a que ruede el balón.
Future<bool> hayVotacionAllStar(AppDatabase db) async =>
    (await _valoracionesDeLaTemporada(db)).temporadaEmpezada;

/// Por dónde va la temporada regular, de 0 a 1.
Future<double> avanceDeLaTemporada(AppDatabase db) async =>
    (await _valoracionesDeLaTemporada(db)).avance;

/// La convocatoria de [conferencia]: los 10 mejores por lo que están
/// haciendo esta temporada, sin cuotas por puesto. Los 5 primeros son
/// titulares — el mejor de la conferencia es titular aunque sea el quinto
/// base, que es justo lo que fallaba antes.
Future<List<ConvocadoAllStar>> convocatoriaDe(
  AppDatabase db,
  String conferencia,
) async {
  final valoraciones = await _valoracionesDeLaTemporada(db);
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();

  final candidatos = jugadores
      .where((j) => conferenciaPorEquipo[j.equipo] == conferencia)
      .toList()
    ..sort((a, b) => valoraciones.de(b).compareTo(valoraciones.de(a)));

  return [
    for (var i = 0; i < candidatos.length && i < convocadosPorConferencia; i++)
      ConvocadoAllStar(
        jugador: candidatos[i],
        conferencia: conferencia,
        titular: i < titularesPorConferencia,
        valoracion: valoraciones.de(candidatos[i]),
        votos: _votosDe(valoraciones.de(candidatos[i]), i, valoraciones.avance),
      ),
  ];
}

/// Los votos que reúne un candidato, en miles. Es una cuenta determinista
/// sobre su valoración con una curva que premia mucho estar arriba: el
/// primero se va a los dos millones y el décimo se queda en unos cientos de
/// miles, como en la votación real.
///
/// [avance] es la parte de temporada disputada: las urnas se van llenando a
/// medida que se juega, en vez de aparecer con el recuento cerrado antes del
/// primer partido. Se deja un suelo para que en cuanto haya un par de
/// jornadas ya se vea algo.
int _votosDe(double valoracion, int puesto, double avance) {
  final base = valoracion * 42000;
  final tiron = 1.9 - puesto * 0.13;
  final urnas = 0.15 + 0.85 * avance;
  return (base * tiron * urnas).round().clamp(1000, 5000000);
}

/// Los que se han quedado a las puertas: del 11 al 15 de cada conferencia.
/// Solo sirven para que la pantalla de votación enseñe una lista con algo de
/// tensión, no entran al partido.
Future<List<ConvocadoAllStar>> aspirantesDe(
  AppDatabase db,
  String conferencia, {
  int cuantos = 5,
}) async {
  final valoraciones = await _valoracionesDeLaTemporada(db);
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();
  final candidatos = jugadores
      .where((j) => conferenciaPorEquipo[j.equipo] == conferencia)
      .toList()
    ..sort((a, b) => valoraciones.de(b).compareTo(valoraciones.de(a)));

  return [
    for (var i = convocadosPorConferencia;
        i < candidatos.length && i < convocadosPorConferencia + cuantos;
        i++)
      ConvocadoAllStar(
        jugador: candidatos[i],
        conferencia: conferencia,
        titular: false,
        valoracion: valoraciones.de(candidatos[i]),
        votos: _votosDe(valoraciones.de(candidatos[i]), i, valoraciones.avance),
      ),
  ];
}

// ---------------------------------------------------------------------------
// El partido
// ---------------------------------------------------------------------------

/// El boxscore del All-Star de esta temporada, si ya se ha jugado.
Future<sim.Boxscore?> leerBoxscoreAllStar(AppDatabase db) =>
    _leerPartidoSuelto(db, _origenAllStar);

/// El del Rising Stars.
Future<sim.Boxscore?> leerBoxscoreRisingStars(AppDatabase db) =>
    _leerPartidoSuelto(db, _origenRisingStars);

Future<sim.Boxscore?> _leerPartidoSuelto(AppDatabase db, String origen) async {
  final boxscores = await leerBoxscoresDeSerie(db,
      origen: origen, serieId: _idPartidoSuelto);
  return boxscores.isEmpty ? null : boxscores.first;
}

/// Juega el All-Star de esta temporada (si no se ha jugado ya) y devuelve
/// su boxscore: los 10 mejores jugadores de cada conferencia, elegidos por
/// lo que están haciendo esta temporada y no por su media del dataset — así
/// el partido refleja quién está siendo protagonista de verdad este año.
///
/// De paso concede el MVP del partido, que se guarda como un premio más de
/// la temporada.
///
/// No cuenta para nada: ni récord, ni estadísticas de temporada, ni
/// lesiones. Es puro escaparate.
Future<sim.Boxscore?> jugarAllStarSiHaceFalta(AppDatabase db) async {
  final yaJugado = await leerBoxscoreAllStar(db);
  if (yaJugado != null) return yaJugado;

  final este = await _seleccionDe(db, 'Este');
  final oeste = await _seleccionDe(db, 'Oeste');
  if (este == null || oeste == null) return null;

  final boxscore = sim.simularPartido(local: este, visitante: oeste);
  await guardarBoxscoreDeSerie(db,
      origen: _origenAllStar,
      serieId: _idPartidoSuelto,
      boxscore: boxscore);
  await _concederMvp(db, boxscore, TipoPremio.mvpAllStar);
  return boxscore;
}

/// El Rising Stars: los mejores rookies contra los mejores de segundo año.
/// Mismo trato que el All-Star — exhibición, no cuenta para nada— y con su
/// propio MVP.
Future<sim.Boxscore?> jugarRisingStarsSiHaceFalta(AppDatabase db) async {
  final yaJugado = await leerBoxscoreRisingStars(db);
  if (yaJugado != null) return yaJugado;

  final novatos = await _seleccionJoven(db,
      nombre: equipoNovatos, temporadasJugadas: 0);
  final sophomores = await _seleccionJoven(db,
      nombre: equipoSophomores, temporadasJugadas: 1);
  if (novatos == null || sophomores == null) return null;

  final boxscore = sim.simularPartido(local: novatos, visitante: sophomores);
  await guardarBoxscoreDeSerie(db,
      origen: _origenRisingStars,
      serieId: _idPartidoSuelto,
      boxscore: boxscore);
  await _concederMvp(db, boxscore, TipoPremio.mvpRisingStars);
  return boxscore;
}

/// Los convocados de [conferencia] puestos sobre la cancha. Los 5 titulares
/// se reparten los puestos por afinidad —el que menos penalización arrastre
/// en cada sitio— porque la convocatoria ya no lleva cuota por posición: si
/// el Este tiene a los tres mejores aleros de la liga, van los tres.
Future<sim.EquipoPartido?> _seleccionDe(
  AppDatabase db,
  String conferencia,
) async {
  final convocados = await convocatoriaDe(db, conferencia);
  if (convocados.length < convocadosPorConferencia) return null;
  final formas = await leerFormas(db);

  final titulares = convocados.take(titularesPorConferencia).toList();
  final suplentes = convocados.skip(titularesPorConferencia).toList();
  final puestos = [
    ..._repartirPuestos(titulares.map((c) => c.jugador).toList()),
    ..._repartirPuestos(suplentes.map((c) => c.jugador).toList()),
  ];

  final enPartido = <sim.JugadorEnPartido>[];
  for (var i = 0; i < convocados.length; i++) {
    final jugador = convocados[i].jugador;
    enPartido.add(sim.JugadorEnPartido(
      jugador: jugador.toSimJugador(),
      minutos: _minutosAllStar[i],
      // Sin estrellas designadas: en el All-Star están todos, y así el
      // reparto de puntos sale más igualado, como en el partido real.
      penalizacionFueraDePosicion: factorDePuesto(jugador, puestos[i]),
      factorForma: formas[jugador.id] ?? 1.0,
    ));
  }

  return sim.EquipoPartido(
    nombre: conferencia == 'Este' ? equipoAllStarEste : equipoAllStarOeste,
    jugadores: enPartido,
  );
}

/// Un quinteto del Rising Stars: los 10 mejores de la liga que llevan
/// exactamente [temporadasJugadas] temporadas a sus espaldas.
///
/// La experiencia se mide con [experienciaEnLaLiga], no con la columna
/// `temporadasPrevias` a secas: esa columna se congela al importar el
/// dataset, así que filtrando por ella los rookies de tu temporada 1
/// seguían saliendo como rookies en la 2, en la 3 y para siempre — el
/// partido repetía exactamente los mismos nombres cada año.
Future<sim.EquipoPartido?> _seleccionJoven(
  AppDatabase db, {
  required String nombre,
  required int temporadasJugadas,
}) async {
  final valoraciones = await _valoracionesDeLaTemporada(db);
  final experiencia = await experienciaEnLaLiga(db);
  final jugadores = (await (db.select(db.jugadores)
            ..where((t) => t.retirado.equals(false)))
          .get())
      .where((j) => (experiencia[j.id] ?? 0) == temporadasJugadas)
      .toList();
  if (jugadores.length < convocadosPorConferencia) return null;

  jugadores.sort((a, b) => valoraciones.de(b).compareTo(valoraciones.de(a)));
  final elegidos = jugadores.take(convocadosPorConferencia).toList();
  final formas = await leerFormas(db);

  final puestos = [
    ..._repartirPuestos(elegidos.take(titularesPorConferencia).toList()),
    ..._repartirPuestos(elegidos.skip(titularesPorConferencia).toList()),
  ];

  return sim.EquipoPartido(
    nombre: nombre,
    jugadores: [
      for (var i = 0; i < elegidos.length; i++)
        sim.JugadorEnPartido(
          jugador: elegidos[i].toSimJugador(),
          minutos: _minutosAllStar[i],
          penalizacionFueraDePosicion: factorDePuesto(elegidos[i], puestos[i]),
          factorForma: formas[elegidos[i].id] ?? 1.0,
        ),
    ],
  );
}

/// Reparte los 5 puestos entre 5 jugadores dejando a cada uno donde menos
/// incómodo esté. Voraz por puesto: para cada sitio se coge al que mejor lo
/// cubra de los que quedan libres.
List<String> _repartirPuestos(List<Jugador> quinteto) {
  final puestos = List<String>.filled(quinteto.length, posicionesEquipo.first);
  final libres = List<int>.generate(quinteto.length, (i) => i);

  for (final puesto in posicionesEquipo) {
    if (libres.isEmpty) break;
    var mejor = libres.first;
    for (final i in libres) {
      if (factorDePuesto(quinteto[i], puesto) >
          factorDePuesto(quinteto[mejor], puesto)) {
        mejor = i;
      }
    }
    puestos[mejor] = puesto;
    libres.remove(mejor);
  }
  return puestos;
}

// ---------------------------------------------------------------------------
// MVP
// ---------------------------------------------------------------------------

/// El MVP de un partido del fin de semana: el que más ha hecho sobre la
/// cancha, con ventaja para el equipo que gana.
sim.EstadisticasJugador? mvpDelPartido(sim.Boxscore boxscore) {
  final ganaLocal = boxscore.marcadorLocal > boxscore.marcadorVisitante;

  double puntuar(sim.EstadisticasJugador e, bool esLocal) {
    final bruto = e.puntos + e.asistencias * 1.5 + e.rebotes * 1.2;
    return esLocal == ganaLocal ? bruto * _bonusMvpGanador : bruto;
  }

  sim.EstadisticasJugador? mejor;
  var mejorNota = -1.0;
  for (final (stats, esLocal) in [
    ...boxscore.statsLocal.map((e) => (e, true)),
    ...boxscore.statsVisitante.map((e) => (e, false)),
  ]) {
    final nota = puntuar(stats, esLocal);
    if (nota > mejorNota) {
      mejorNota = nota;
      mejor = stats;
    }
  }
  return mejor;
}

Future<void> _concederMvp(
  AppDatabase db,
  sim.Boxscore boxscore,
  TipoPremio tipo,
) async {
  final mvp = mvpDelPartido(boxscore);
  final jugadorId = int.tryParse(mvp?.jugadorId ?? '');
  if (jugadorId == null) return;
  await (db.delete(db.premiosTemporada)..where((t) => t.tipo.equals(tipo.name)))
      .go();
  await db.into(db.premiosTemporada).insert(
      PremiosTemporadaCompanion.insert(tipo: tipo.name, jugadorId: jugadorId));
}

/// El jugador que se llevó el MVP de [tipo] esta temporada, si ya se ha
/// jugado ese partido.
Future<Jugador?> mvpDeLaTemporada(AppDatabase db, TipoPremio tipo) async {
  final premio = await (db.select(db.premiosTemporada)
        ..where((t) => t.tipo.equals(tipo.name)))
      .getSingleOrNull();
  if (premio == null) return null;
  return (db.select(db.jugadores)..where((t) => t.id.equals(premio.jugadorId)))
      .getSingleOrNull();
}
