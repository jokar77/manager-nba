import 'dart:convert';

import 'package:sim_engine/sim_engine.dart' as sim;

/// Serializa un [sim.Boxscore] a JSON para guardarlo en
/// `BoxscoresSerie.boxscoreJson` — los partidos de series (playoffs y NBA
/// Cup) no tienen una fila de `PartidosCalendario` donde vivir.
String boxscoreAJson(sim.Boxscore b) {
  return jsonEncode({
    'equipoLocal': b.equipoLocal,
    'equipoVisitante': b.equipoVisitante,
    'marcadorLocal': b.marcadorLocal,
    'marcadorVisitante': b.marcadorVisitante,
    'parcialesLocal': b.parcialesLocal,
    'parcialesVisitante': b.parcialesVisitante,
    'statsLocal': b.statsLocal.map(_statsAMapa).toList(),
    'statsVisitante': b.statsVisitante.map(_statsAMapa).toList(),
  });
}

Map<String, dynamic> _statsAMapa(sim.EstadisticasJugador s) => {
      'jugadorId': s.jugadorId,
      'nombreFicticio': s.nombreFicticio,
      'minutos': s.minutos,
      'puntos': s.puntos,
      'asistencias': s.asistencias,
      'rebotes': s.rebotes,
    };

sim.Boxscore boxscoreDesdeJson(String json) {
  final mapa = jsonDecode(json) as Map<String, dynamic>;

  List<sim.EstadisticasJugador> stats(String clave) =>
      (mapa[clave] as List).map((e) {
        final m = e as Map<String, dynamic>;
        return sim.EstadisticasJugador(
          jugadorId: m['jugadorId'] as String,
          nombreFicticio: m['nombreFicticio'] as String,
          minutos: m['minutos'] as int,
          puntos: m['puntos'] as int,
          asistencias: m['asistencias'] as int,
          rebotes: m['rebotes'] as int,
        );
      }).toList();

  return sim.Boxscore(
    equipoLocal: mapa['equipoLocal'] as String,
    equipoVisitante: mapa['equipoVisitante'] as String,
    marcadorLocal: mapa['marcadorLocal'] as int,
    marcadorVisitante: mapa['marcadorVisitante'] as int,
    statsLocal: stats('statsLocal'),
    statsVisitante: stats('statsVisitante'),
    parcialesLocal: (mapa['parcialesLocal'] as List).cast<int>(),
    parcialesVisitante: (mapa['parcialesVisitante'] as List).cast<int>(),
  );
}
