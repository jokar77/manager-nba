import 'dart:math';

import '../data/database/app_database.dart';
import 'forma_repository.dart';
import 'tipo_premio.dart';

class _Candidato {
  final int jugadorId;
  final bool esRookieEstaTemporada;
  final double scoreDefensivo;
  final double scoreCombinado;
  final double deltaPuntos;

  const _Candidato({
    required this.jugadorId,
    required this.esRookieEstaTemporada,
    required this.scoreDefensivo,
    required this.scoreCombinado,
    required this.deltaPuntos,
  });
}

/// Calcula los premios de fin de temporada regular a partir de las
/// `EstadisticasTemporadaJugador` acumuladas de los 582 jugadores
/// simulables. Sustituye cualquier cálculo anterior (llamarla dos veces no
/// duplica premios).
///
/// Simplificaciones (ver plan de la fase): sin Entrenador del Año (no hay
/// entrenadores); Rookie del Año exige no haber jugado ninguna temporada
/// simulada antes (sin fila en `HistorialEstadisticasJugador`) y no venir
/// del dataset inicial con experiencia real (`temporadasPrevias == 0`) —
/// así un jugador que sigue siendo joven en su segunda o tercera temporada
/// ya no puede colarse; Más Mejorado compara la media de puntos
/// simulada contra la `pts_pg` real del dataset (única referencia "antes"
/// disponible, al no haber temporada previa simulada); Mejor Defensor
/// combina el `atrDefensa` real del jugador con lo que ha hecho esta
/// temporada — rebotes y récord de su equipo — y con su estado de forma
/// (el boxscore simulado no registra robos/tapones). Ese estado de forma
/// (ver forma_repository.dart) es lo que evita que el premio caiga
/// siempre en el mismo jugador partida tras partida.
Future<void> calcularPremios(AppDatabase db) async {
  final estadisticas = await db.select(db.estadisticasTemporadaJugador).get();
  if (estadisticas.isEmpty) return;

  final maxPartidos =
      estadisticas.map((e) => e.partidosJugados).fold(0, max);
  if (maxPartidos == 0) return;
  final umbralPartidos = max(1, (maxPartidos * 0.5).ceil());

  final jugadoresRows = await db.select(db.jugadores).get();
  final jugadoresPorId = {for (final j in jugadoresRows) j.id: j};

  final resultados = await db.select(db.resultadoTemporada).get();
  final winPctPorEquipo = {
    for (final r in resultados)
      r.equipo: (r.victorias + r.derrotas) == 0
          ? 0.0
          : r.victorias / (r.victorias + r.derrotas),
  };

  final formas = await leerFormas(db);

  // Cualquiera con una fila en el histórico (de cualquier temporada
  // anterior) ya jugó una temporada simulada: no puede ser rookie ahora,
  // por joven que siga siendo.
  final yaJugaronAntes = (await db.select(db.historialEstadisticasJugador).get())
      .map((h) => h.jugadorId)
      .toSet();

  final candidatos = <_Candidato>[];
  for (final e in estadisticas) {
    if (e.partidosJugados < umbralPartidos) continue;
    final jugador = jugadoresPorId[e.jugadorId];
    if (jugador == null) continue;

    final ptsProm = e.puntosTotales / e.partidosJugados;
    final astProm = e.asistenciasTotales / e.partidosJugados;
    final rebProm = e.rebotesTotales / e.partidosJugados;
    final winPct = winPctPorEquipo[jugador.equipo] ?? 0.0;

    final forma = formas[e.jugadorId] ?? 1.0;
    // La forma cuenta la mitad en defensa que en ataque, y los rebotes
    // pesan poco: un año bueno anotando no convierte a un mal defensor en
    // Defensor del Año, y coger muchos rebotes tampoco — el premio lo tiene
    // que decidir su capacidad defensiva real (robos, tapones y ayudas, que
    // el boxscore simulado no registra, están dentro de `atrDefensa`).
    final formaDefensiva = 1 + (forma - 1) * 0.5;

    candidatos.add(_Candidato(
      jugadorId: e.jugadorId,
      esRookieEstaTemporada: jugador.temporadasPrevias == 0 &&
          !yaJugaronAntes.contains(e.jugadorId),
      scoreDefensivo:
          jugador.atrDefensa * formaDefensiva + rebProm * 0.35 + winPct * 4,
      scoreCombinado: ptsProm + astProm * 1.5 + rebProm * 1.2 + winPct * 10,
      deltaPuntos: ptsProm - jugador.ptsPg,
    ));
  }
  if (candidatos.isEmpty) return;

  final premios = <PremiosTemporadaCompanion>[];

  final porScore = [...candidatos]
    ..sort((a, b) => b.scoreCombinado.compareTo(a.scoreCombinado));
  premios.add(_premio(TipoPremio.mvp, porScore.first.jugadorId));

  final porDefensa = [...candidatos]
    ..sort((a, b) => b.scoreDefensivo.compareTo(a.scoreDefensivo));
  premios.add(_premio(TipoPremio.mejorDefensor, porDefensa.first.jugadorId));

  final rookies = candidatos.where((c) => c.esRookieEstaTemporada).toList()
    ..sort((a, b) => b.scoreCombinado.compareTo(a.scoreCombinado));
  if (rookies.isNotEmpty) {
    premios.add(_premio(TipoPremio.rookieDelAno, rookies.first.jugadorId));
  }

  final porMejora = [...candidatos]
    ..sort((a, b) => b.deltaPuntos.compareTo(a.deltaPuntos));
  premios.add(_premio(TipoPremio.masMejorado, porMejora.first.jugadorId));

  final quintetos = porScore.take(10).toList();
  for (var i = 0; i < quintetos.length; i++) {
    final tipo = i < 5 ? TipoPremio.primerQuinteto : TipoPremio.segundoQuinteto;
    premios.add(_premio(tipo, quintetos[i].jugadorId));
  }

  // Solo los suyos: los MVP del fin de semana de las estrellas viven en esta
  // misma tabla y se concedieron en febrero, no se recalculan aquí.
  await (db.delete(db.premiosTemporada)
        ..where((t) =>
            t.tipo.isIn(premiosDeFinDeTemporadaRegular.map((p) => p.name))))
      .go();
  await db.batch((batch) => batch.insertAll(db.premiosTemporada, premios));
}

PremiosTemporadaCompanion _premio(TipoPremio tipo, int jugadorId) {
  return PremiosTemporadaCompanion.insert(tipo: tipo.name, jugadorId: jugadorId);
}

/// Los premios ya calculados, agrupados por tipo.
Future<Map<TipoPremio, List<PremiosTemporadaData>>> leerPremios(
    AppDatabase db) async {
  final filas = await db.select(db.premiosTemporada).get();
  final mapa = <TipoPremio, List<PremiosTemporadaData>>{};
  for (final fila in filas) {
    mapa.putIfAbsent(TipoPremio.desdeNombre(fila.tipo), () => []).add(fila);
  }
  return mapa;
}
