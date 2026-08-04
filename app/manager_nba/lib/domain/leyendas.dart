/// Franquicias con las que una leyenda real hizo historia, más allá de
/// dónde acabe jugando en tu partida.
///
/// Hace falta porque la simulación arranca con las plantillas de hoy: si
/// Chris Paul se retira vistiendo la camiseta del equipo que le fichó en su
/// último año, honrarle *ahí* no tiene ningún sentido. La camiseta la retira
/// quien tiene motivos para hacerlo.
///
/// La clave es el `nombre_real` del dataset (los nombres que se ven en el
/// juego son ficticios). Solo están los casos claros: quien no aparezca aquí
/// se rige por dónde jugó en tu partida, que para un jugador que empieza su
/// carrera contigo es lo correcto.
const franquiciasHistoricas = <String, List<String>>{
  // Los que ya tienen una carrera larga a sus espaldas cuando empieza tu
  // partida: su historia está escrita fuera del juego.
  'LeBron James': ['CLE', 'LAL', 'MIA'],
  'Stephen Curry': ['GSW'],
  'Kevin Durant': ['OKC', 'GSW'],
  'James Harden': ['HOU'],
  'Chris Paul': ['LAC', 'NOP'],
  'Russell Westbrook': ['OKC'],
  'Klay Thompson': ['GSW'],
  'Draymond Green': ['GSW'],
  'Jimmy Butler': ['MIA'],
  'Kawhi Leonard': ['SAS', 'TOR'],
  'Paul George': ['IND'],
  'DeMar DeRozan': ['TOR'],
  'Al Horford': ['BOS'],
  'Rudy Gobert': ['UTA'],
  'Anthony Davis': ['NOP', 'LAL'],
  'Giannis Antetokounmpo': ['MIL'],
  'Khris Middleton': ['MIL'],
  'Jrue Holiday': ['NOP', 'MIL'],
  'Joel Embiid': ['PHI'],
  'Nikola Jokić': ['DEN'],
  'Bradley Beal': ['WAS'],
  'Zach LaVine': ['CHI'],
  'Karl-Anthony Towns': ['MIN'],
  'Devin Booker': ['PHO'],
  'Trae Young': ['ATL'],
  'Luka Dončić': ['DAL'],
  'Ja Morant': ['MEM'],
  'Jayson Tatum': ['BOS'],
  'Jaylen Brown': ['BOS'],
  'Donovan Mitchell': ['UTA'],
  'Pascal Siakam': ['TOR'],
  'Domantas Sabonis': ['IND'],
  'De\'Aaron Fox': ['SAC'],
  'Anthony Edwards': ['MIN'],
  'Brandon Ingram': ['NOP'],
  'Julius Randle': ['NYK'],
  'Victor Wembanyama': ['SAS'],
  'Cade Cunningham': ['DET'],
  'Evan Mobley': ['CLE'],
  'Paolo Banchero': ['ORL'],
  'Scottie Barnes': ['TOR'],
};

/// La franquicia que debería honrar a [nombreReal], eligiendo entre las que
/// tienen motivos históricos la que además sea [preferida] (normalmente,
/// donde jugó más en tu partida). Null si no es una leyenda conocida.
String? franquiciaHistoricaDe(String nombreReal, {String? preferida}) {
  final candidatas = franquiciasHistoricas[nombreReal];
  if (candidatas == null || candidatas.isEmpty) return null;
  if (preferida != null && candidatas.contains(preferida)) return preferida;
  return candidatas.first;
}

/// ¿Es [nombreReal] una leyenda real con historia previa al juego?
bool esLeyendaReal(String nombreReal) =>
    franquiciasHistoricas.containsKey(nombreReal);
