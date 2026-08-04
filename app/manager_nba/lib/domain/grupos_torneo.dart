/// Los 30 equipos repartidos en 6 grupos de 5 (3 por conferencia) para la
/// fase de grupos de la NBA Cup. Simplificación deliberada: en la NBA real
/// los grupos se sortean cada temporada; aquí se fijan siempre igual,
/// porque el juego solo lleva una franquicia a la vez y no hay datos
/// previos con los que ponderar un sorteo (ver docs/plan.md).
const grupoTorneoPorEquipo = <String, String>{
  // Este
  'ATL': 'E1', 'BOS': 'E1', 'BRK': 'E1', 'CHI': 'E1', 'CHO': 'E1',
  'CLE': 'E2', 'DET': 'E2', 'IND': 'E2', 'MIA': 'E2', 'MIL': 'E2',
  'NYK': 'E3', 'ORL': 'E3', 'PHI': 'E3', 'TOR': 'E3', 'WAS': 'E3',
  // Oeste
  'DAL': 'O1', 'DEN': 'O1', 'GSW': 'O1', 'HOU': 'O1', 'LAC': 'O1',
  'LAL': 'O2', 'MEM': 'O2', 'MIN': 'O2', 'NOP': 'O2', 'OKC': 'O2',
  'PHO': 'O3', 'POR': 'O3', 'SAC': 'O3', 'SAS': 'O3', 'UTA': 'O3',
};

/// Los otros 4 equipos del grupo de [equipo] (sin incluirlo).
List<String> rivalesDeGrupo(String equipo) {
  final grupo = grupoTorneoPorEquipo[equipo];
  if (grupo == null) return const [];
  return grupoTorneoPorEquipo.entries
      .where((e) => e.value == grupo && e.key != equipo)
      .map((e) => e.key)
      .toList();
}

/// Todos los equipos del grupo [grupo] (los 5, incluido cualquiera que se
/// pase).
List<String> equiposDelGrupo(String grupo) => grupoTorneoPorEquipo.entries
    .where((e) => e.value == grupo)
    .map((e) => e.key)
    .toList();

/// Los 3 grupos de una conferencia ('Este' u 'Oeste').
List<String> gruposDeConferencia(String conferencia) =>
    conferencia == 'Este' ? const ['E1', 'E2', 'E3'] : const ['O1', 'O2', 'O3'];

String conferenciaDelGrupo(String grupo) => grupo.startsWith('E') ? 'Este' : 'Oeste';
