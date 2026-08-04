import 'package:flutter/material.dart';

/// Identidad de cada equipo real: ciudad real (no está protegida) + un
/// apodo ficticio "parecido" al real (mismo criterio que ya se usa para
/// los nombres de jugadores: cambiar un par de letras), y sus dos colores
/// principales (dato público).
class EquipoInfo {
  final String ciudad;
  final String apodo;
  final Color colorPrimario;
  final Color colorSecundario;

  const EquipoInfo({
    required this.ciudad,
    required this.apodo,
    required this.colorPrimario,
    required this.colorSecundario,
  });

  String get nombreCompleto => '$ciudad $apodo';
}

const equiposInfo = <String, EquipoInfo>{
  'ATL': EquipoInfo(
    ciudad: 'Atlanta',
    apodo: 'Hewks',
    colorPrimario: Color(0xFFE03A3E),
    colorSecundario: Color(0xFFC1D32F),
  ),
  'BOS': EquipoInfo(
    ciudad: 'Boston',
    apodo: 'Celtacs',
    colorPrimario: Color(0xFF007A33),
    colorSecundario: Color(0xFFBA9653),
  ),
  'BRK': EquipoInfo(
    ciudad: 'Brooklyn',
    apodo: 'Nats',
    colorPrimario: Color(0xFF000000),
    colorSecundario: Color(0xFFFFFFFF),
  ),
  'CHI': EquipoInfo(
    ciudad: 'Chicago',
    apodo: 'Bolls',
    colorPrimario: Color(0xFFCE1141),
    colorSecundario: Color(0xFF000000),
  ),
  'CHO': EquipoInfo(
    ciudad: 'Charlotte',
    apodo: 'Hornits',
    colorPrimario: Color(0xFF1D1160),
    colorSecundario: Color(0xFF00788C),
  ),
  'CLE': EquipoInfo(
    ciudad: 'Cleveland',
    apodo: 'Cavaleers',
    colorPrimario: Color(0xFF860038),
    colorSecundario: Color(0xFFFDBB30),
  ),
  'DAL': EquipoInfo(
    ciudad: 'Dallas',
    apodo: 'Maverecks',
    colorPrimario: Color(0xFF00538C),
    colorSecundario: Color(0xFF002B5E),
  ),
  'DEN': EquipoInfo(
    ciudad: 'Denver',
    apodo: 'Nuggits',
    colorPrimario: Color(0xFF0E2240),
    colorSecundario: Color(0xFFFEC524),
  ),
  'DET': EquipoInfo(
    ciudad: 'Detroit',
    apodo: 'Pistans',
    colorPrimario: Color(0xFFC8102E),
    colorSecundario: Color(0xFF1D42BA),
  ),
  'GSW': EquipoInfo(
    ciudad: 'Golden State',
    apodo: 'Warriers',
    colorPrimario: Color(0xFF1D428A),
    colorSecundario: Color(0xFFFFC72C),
  ),
  'HOU': EquipoInfo(
    ciudad: 'Houston',
    apodo: 'Rackets',
    colorPrimario: Color(0xFFCE1141),
    colorSecundario: Color(0xFF000000),
  ),
  'IND': EquipoInfo(
    ciudad: 'Indiana',
    apodo: 'Pacars',
    colorPrimario: Color(0xFF002D62),
    colorSecundario: Color(0xFFFDBB30),
  ),
  'LAC': EquipoInfo(
    ciudad: 'Los Ángeles',
    apodo: 'Clappers',
    colorPrimario: Color(0xFFC8102E),
    colorSecundario: Color(0xFF1D428A),
  ),
  'LAL': EquipoInfo(
    ciudad: 'Los Ángeles',
    apodo: 'Lakars',
    colorPrimario: Color(0xFF552583),
    colorSecundario: Color(0xFFFDB927),
  ),
  'MEM': EquipoInfo(
    ciudad: 'Memphis',
    apodo: 'Grizzlias',
    colorPrimario: Color(0xFF5D76A9),
    colorSecundario: Color(0xFF12173F),
  ),
  'MIA': EquipoInfo(
    ciudad: 'Miami',
    apodo: 'Heet',
    colorPrimario: Color(0xFF98002E),
    colorSecundario: Color(0xFFF9A01B),
  ),
  'MIL': EquipoInfo(
    ciudad: 'Milwaukee',
    apodo: 'Buks',
    colorPrimario: Color(0xFF00471B),
    colorSecundario: Color(0xFFEEE1C6),
  ),
  'MIN': EquipoInfo(
    ciudad: 'Minnesota',
    apodo: 'Timberwelves',
    colorPrimario: Color(0xFF0C2340),
    colorSecundario: Color(0xFF236192),
  ),
  'NOP': EquipoInfo(
    ciudad: 'New Orleans',
    apodo: 'Pelicens',
    colorPrimario: Color(0xFF0C2340),
    colorSecundario: Color(0xFFC8102E),
  ),
  'NYK': EquipoInfo(
    ciudad: 'New York',
    apodo: 'Knecks',
    colorPrimario: Color(0xFF006BB6),
    colorSecundario: Color(0xFFF58426),
  ),
  'OKC': EquipoInfo(
    ciudad: 'Oklahoma City',
    apodo: 'Thundir',
    colorPrimario: Color(0xFF007AC1),
    colorSecundario: Color(0xFFEF3B24),
  ),
  'ORL': EquipoInfo(
    ciudad: 'Orlando',
    apodo: 'Magik',
    colorPrimario: Color(0xFF0077C0),
    colorSecundario: Color(0xFFC4CED4),
  ),
  'PHI': EquipoInfo(
    ciudad: 'Philadelphia',
    apodo: '67ers',
    colorPrimario: Color(0xFF006BB6),
    colorSecundario: Color(0xFFED174C),
  ),
  'PHO': EquipoInfo(
    ciudad: 'Phoenix',
    apodo: 'Sonns',
    colorPrimario: Color(0xFF1D1160),
    colorSecundario: Color(0xFFE56020),
  ),
  'POR': EquipoInfo(
    ciudad: 'Portland',
    apodo: 'Trail Blazars',
    colorPrimario: Color(0xFFE03A3E),
    colorSecundario: Color(0xFF000000),
  ),
  'SAC': EquipoInfo(
    ciudad: 'Sacramento',
    apodo: 'Kengs',
    colorPrimario: Color(0xFF5A2D81),
    colorSecundario: Color(0xFF63727A),
  ),
  'SAS': EquipoInfo(
    ciudad: 'San Antonio',
    apodo: 'Spors',
    colorPrimario: Color(0xFFC4CED4),
    colorSecundario: Color(0xFF000000),
  ),
  'TOR': EquipoInfo(
    ciudad: 'Toronto',
    apodo: 'Raptirs',
    colorPrimario: Color(0xFFCE1141),
    colorSecundario: Color(0xFF000000),
  ),
  'UTA': EquipoInfo(
    ciudad: 'Utah',
    apodo: 'Jezz',
    colorPrimario: Color(0xFF002B5C),
    colorSecundario: Color(0xFFF9A01B),
  ),
  'WAS': EquipoInfo(
    ciudad: 'Washington',
    apodo: 'Wizerds',
    colorPrimario: Color(0xFF002B5C),
    colorSecundario: Color(0xFFE31837),
  ),
  // Las dos selecciones del All-Star. No son franquicias, pero pasan por
  // los mismos widgets (logo, cabecera del boxscore), así que necesitan su
  // identidad y sus colores como cualquier otro "equipo".
  'Este': EquipoInfo(
    ciudad: 'Conferencia',
    apodo: 'Este',
    colorPrimario: Color(0xFF1D428A),
    colorSecundario: Color(0xFF64B5F6),
  ),
  'Oeste': EquipoInfo(
    ciudad: 'Conferencia',
    apodo: 'Oeste',
    colorPrimario: Color(0xFFC8102E),
    colorSecundario: Color(0xFFEF9A9A),
  ),
  // Y los dos del Rising Stars, el partido de los jóvenes del mismo fin de
  // semana.
  'Novatos': EquipoInfo(
    ciudad: 'Rising Stars',
    apodo: 'Novatos',
    colorPrimario: Color(0xFF2E9E5B),
    colorSecundario: Color(0xFFA5D6A7),
  ),
  'Sophomores': EquipoInfo(
    ciudad: 'Rising Stars',
    apodo: 'Sophomores',
    colorPrimario: Color(0xFF7A5AF8),
    colorSecundario: Color(0xFFC5B3FF),
  ),
};

EquipoInfo infoDe(String codigoEquipo) =>
    equiposInfo[codigoEquipo] ??
    const EquipoInfo(
      ciudad: '',
      apodo: '',
      colorPrimario: Colors.grey,
      colorSecundario: Colors.blueGrey,
    );

/// Franquicias que ya no existen o que cambiaron de ciudad y de nombre.
///
/// Salen en las carreras reales de Kaggle: los Sonics de Durant, los Nets de
/// Nueva Jersey, los Bullets de Washington... Son 30 códigos más que no
/// están en [equiposInfo] —ahí solo viven los 30 equipos de tu liga— y sin
/// esto la ficha de una leyenda dejaba esas etapas con el nombre en blanco.
///
/// Aquí van con su nombre real y no con uno ficticio a propósito: no juegan
/// en tu partida, son historia de la NBA de verdad, igual que los puntos y
/// los anillos que se enseñan al lado.
const nombresHistoricos = <String, String>{
  'BAL': 'Baltimore Bullets',
  'BLB': 'Baltimore Bullets',
  'BUF': 'Buffalo Braves',
  'CAP': 'Capital Bullets',
  'CHH': 'Charlotte Hornets',
  'CHP': 'Chicago Packers',
  'CHS': 'Chicago Stags',
  'CHZ': 'Chicago Zephyrs',
  'CIN': 'Cincinnati Royals',
  'DNN': 'Denver Nuggets',
  'FTW': 'Fort Wayne Pistons',
  'INO': 'Indianapolis Olympians',
  'KCK': 'Kansas City Kings',
  'KCO': 'Kansas City-Omaha Kings',
  'MLH': 'Milwaukee Hawks',
  'MNL': 'Minneapolis Lakers',
  'NJN': 'New Jersey Nets',
  'NOH': 'New Orleans Hornets',
  'NOJ': 'New Orleans Jazz',
  'NOK': 'New Orleans/Oklahoma City Hornets',
  'NYN': 'New York Nets',
  'PHW': 'Philadelphia Warriors',
  'ROC': 'Rochester Royals',
  'SDC': 'San Diego Clippers',
  'SDR': 'San Diego Rockets',
  'SEA': 'Seattle SuperSonics',
  'SFW': 'San Francisco Warriors',
  'STB': 'St. Louis Bombers',
  'STL': 'St. Louis Hawks',
  'SYR': 'Syracuse Nationals',
  'TRI': 'Tri-Cities Blackhawks',
  'WSB': 'Washington Bullets',
  'WSC': 'Washington Capitols',
};

/// Cómo se llama [codigoEquipo] en una ficha de carrera: el nombre de tu
/// liga si es uno de los 30, el histórico real si es una franquicia
/// desaparecida, y el propio código como último recurso.
String nombreDeEquipoEnFicha(String codigoEquipo) {
  final info = equiposInfo[codigoEquipo];
  if (info != null) return info.nombreCompleto;
  return nombresHistoricos[codigoEquipo] ?? codigoEquipo;
}
