/// Línea de estadísticas de un jugador en un partido simulado.
class EstadisticasJugador {
  final String jugadorId;
  final String nombreFicticio;
  final int minutos;
  final int puntos;
  final int asistencias;
  final int rebotes;

  const EstadisticasJugador({
    required this.jugadorId,
    required this.nombreFicticio,
    required this.minutos,
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
  });
}

/// Resultado completo de un partido simulado.
class Boxscore {
  final String equipoLocal;
  final String equipoVisitante;
  final int marcadorLocal;
  final int marcadorVisitante;
  final List<EstadisticasJugador> statsLocal;
  final List<EstadisticasJugador> statsVisitante;

  /// Puntos de cada periodo jugado: siempre empieza con los 4 cuartos y,
  /// si el partido llegó a empate en el marcador de esos 4 cuartos, sigue
  /// con uno o más periodos de prórroga (nunca hay empate en el marcador
  /// final). Cada lista suma exactamente el marcador final de ese equipo.
  final List<int> parcialesLocal;
  final List<int> parcialesVisitante;

  const Boxscore({
    required this.equipoLocal,
    required this.equipoVisitante,
    required this.marcadorLocal,
    required this.marcadorVisitante,
    required this.statsLocal,
    required this.statsVisitante,
    required this.parcialesLocal,
    required this.parcialesVisitante,
  });

  String get ganador =>
      marcadorLocal >= marcadorVisitante ? equipoLocal : equipoVisitante;
}
