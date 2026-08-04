/// Mapeo fijo de los 30 equipos reales a su conferencia (el dataset no
/// trae este dato). Se usa solo para sembrar los playoffs (8 por
/// conferencia).
const conferenciaPorEquipo = <String, String>{
  // Este
  'ATL': 'Este', 'BOS': 'Este', 'BRK': 'Este', 'CHI': 'Este',
  'CHO': 'Este', 'CLE': 'Este', 'DET': 'Este', 'IND': 'Este',
  'MIA': 'Este', 'MIL': 'Este', 'NYK': 'Este', 'ORL': 'Este',
  'PHI': 'Este', 'TOR': 'Este', 'WAS': 'Este',
  // Oeste
  'DAL': 'Oeste', 'DEN': 'Oeste', 'GSW': 'Oeste', 'HOU': 'Oeste',
  'LAC': 'Oeste', 'LAL': 'Oeste', 'MEM': 'Oeste', 'MIN': 'Oeste',
  'NOP': 'Oeste', 'OKC': 'Oeste', 'PHO': 'Oeste', 'POR': 'Oeste',
  'SAC': 'Oeste', 'SAS': 'Oeste', 'UTA': 'Oeste',
};
