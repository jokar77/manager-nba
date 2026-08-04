import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/database/app_database.dart';
import 'dorsales_repository.dart';

const _rutaAssetCamisetas = 'assets/data/retired_numbers.json';
const _rutaAssetHallDeLaFama = 'assets/data/hof_players_simple.json';

/// Nombre real de franquicia -> código de la liga (ver `equipos_info.dart`
/// para la identidad ficticia, que es la que se usa en el resto del juego).
/// Hace falta para leer los assets que traen el nombre real de cada equipo:
/// los dos de este archivo y el de camisetas por retirar
/// (`camisetas_repository.dart`).
///
/// Incluye franquicias que hoy no existen con ese nombre, como los New
/// Orleans Hornets: las carreras reales de Kaggle las usan y por ahí salen
/// camisetas a retirar (Chris Paul tiene la suya con ellos). Sin la entrada,
/// su número no se encontraba y acababa retirándose el dorsal sorteado
/// dentro de la partida — el 43 en vez del 3.
const codigoPorNombreReal = {
  'Atlanta Hawks': 'ATL',
  'Boston Celtics': 'BOS',
  'Brooklyn Nets': 'BRK',
  'Charlotte Hornets': 'CHO',
  'Chicago Bulls': 'CHI',
  'Cleveland Cavaliers': 'CLE',
  'Dallas Mavericks': 'DAL',
  'Denver Nuggets': 'DEN',
  'Detroit Pistons': 'DET',
  'Golden State Warriors': 'GSW',
  'Houston Rockets': 'HOU',
  'Indiana Pacers': 'IND',
  'Los Angeles Clippers': 'LAC',
  'Los Angeles Lakers': 'LAL',
  'New Orleans Hornets': 'NOH',
  'Memphis Grizzlies': 'MEM',
  'Miami Heat': 'MIA',
  'Milwaukee Bucks': 'MIL',
  'Minnesota Timberwolves': 'MIN',
  'New Orleans Pelicans': 'NOP',
  'New York Knicks': 'NYK',
  'Oklahoma City Thunder': 'OKC',
  'Orlando Magic': 'ORL',
  'Philadelphia 76ers': 'PHI',
  'Phoenix Suns': 'PHO',
  'Portland Trail Blazers': 'POR',
  'Sacramento Kings': 'SAC',
  'San Antonio Spurs': 'SAS',
  'Toronto Raptors': 'TOR',
  'Utah Jazz': 'UTA',
  'Washington Wizards': 'WAS',
};

/// Importa el legado real —camisetas retiradas de las 30 franquicias y el
/// Hall of Fame de verdad— la primera vez que se llama en cada partida.
/// Idempotente: en sucesivos arranques no vuelve a insertar nada.
///
/// Son hechos de antes de que existiera tu partida: no hay ningún jugador
/// simulado detrás, así que cada fila se guarda con un `jugadorId`
/// negativo. Nunca puede coincidir con uno real (los del juego son
/// autoincrementales y siempre positivos), y las pantallas que buscan un
/// jugador por id ya saben tratar un "no existe" con elegancia —
/// `leerCarreraParaFicha` cae de vuelta al nombre guardado en la propia
/// fila en vez de romperse.
Future<void> importarLegadoHistoricoSiHaceFalta(AppDatabase db) async {
  await _importarCamisetasRetiradasReales(db);
  await _importarHallDeLaFamaReal(db);
}

Future<void> _importarCamisetasRetiradasReales(AppDatabase db) async {
  final yaImportado = await (db.select(db.camisetasRetiradas)
        ..where((t) => t.jugadorId.isSmallerThanValue(0))
        ..limit(1))
      .get();
  if (yaImportado.isNotEmpty) return;

  final crudo = await rootBundle.loadString(_rutaAssetCamisetas);
  final lista = jsonDecode(crudo) as List<dynamic>;

  final filas = <CamisetasRetiradasCompanion>[];
  var siguienteId = -1;
  for (final entrada in lista) {
    final mapa = entrada as Map<String, dynamic>;
    final equipo = codigoPorNombreReal[mapa['team'] as String];
    if (equipo == null) continue;
    final dorsal = _dorsalValido(mapa['number'] as String);
    // Sin número no hay nada que bloquear: directivos, locutores o el
    // propio público honrados sin un dorsal real (el dato trae "-" para
    // esos casos) se quedan fuera de esta tabla — es de camisetas, no de
    // banderas del pabellón.
    if (dorsal == null) continue;

    filas.add(CamisetasRetiradasCompanion.insert(
      equipo: equipo,
      jugadorId: siguienteId,
      nombreJugador: nombreRealLimpio(mapa['name'] as String),
      dorsal: dorsal,
      // 0 marca que es historia real, de antes de tu partida: ninguna
      // temporada jugada de verdad llega nunca a valer 0. Lo distingue
      // `camisetas_retiradas_screen.dart` al pintar la ficha.
      temporada: 0,
    ));
    siguienteId--;
  }
  if (filas.isEmpty) return;

  await db.batch((batch) => batch.insertAll(db.camisetasRetiradas, filas));

  // Puede que algún jugador de la plantilla actual, por puro azar del
  // reparto de dorsales, llevara puesto un número que la historia real
  // acaba de bloquear justo ahora.
  await asignarDorsalesQueFalten(db);
}

/// El nombre de un jugador tal y como debe verse en pantalla, a partir de
/// lo que trae el dato de origen.
///
/// Hace dos cosas, las dos por culpa del mismo fichero:
///
/// - Repara la codificación rota. El asset del Hall of Fame se guardó con
///   los bytes UTF-8 leídos como si fueran Windows-1252, así que las
///   comillas tipográficas llegan convertidas en `â€œ`. Sin esto,
///   `Charles “Chuck” Cooper` se ve literalmente como
///   `Charles â€œChuckâ€ Cooper`.
/// - Quita el apodo entrecomillado. Un nombre con apodo en medio no casa
///   con ninguna otra fuente (las carreras reales de Kaggle van por nombre
///   y apellido), así que su ficha salía vacía.
String nombreRealLimpio(String bruto) {
  const reparaciones = {
    'â€œ': '"',
    'â€': '"',
    'â€™': "'",
    'â€˜': "'",
    'â€"': '-',
    'Ã¡': 'á', 'Ã©': 'é', 'Ã­': 'í', 'Ã³': 'ó', 'Ãº': 'ú', 'Ã±': 'ñ',
    'Ä‡': 'ć', 'Ä': 'č', 'Å¡': 'š', 'Å¾': 'ž',
  };
  var texto = bruto;
  for (final entrada in reparaciones.entries) {
    texto = texto.replaceAll(entrada.key, entrada.value);
  }
  // Cualquier apodo entre comillas (rectas o tipográficas) fuera.
  texto = texto.replaceAll(RegExp(r'[“"“”][^“”"]*[”"“”]'), ' ');
  return texto.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Del número tal y como viene en el dato de origen a un dorsal válido
/// (0-99), o null si no representa un número de verdad: "-" son honores sin
/// camiseta (directivos, locutores) y valores como "432" o "1223" son
/// victorias de un entrenador coladas por error en el campo del número.
int? _dorsalValido(String bruto) {
  final texto = bruto.trim();
  if (texto == '00') return 0;
  final numero = int.tryParse(texto);
  if (numero == null || numero < 0 || numero > 99) return null;
  return numero;
}

Future<void> _importarHallDeLaFamaReal(AppDatabase db) async {
  final yaImportado = await (db.select(db.hallDeLaFama)
        ..where((t) => t.jugadorId.isSmallerThanValue(0))
        ..limit(1))
      .get();
  if (yaImportado.isNotEmpty) return;

  final crudo = await rootBundle.loadString(_rutaAssetHallDeLaFama);
  final lista = jsonDecode(crudo) as List<dynamic>;

  final filas = <HallDeLaFamaCompanion>[];
  var siguienteId = -1;
  for (final entrada in lista) {
    final mapa = entrada as Map<String, dynamic>;
    final anio = int.parse(mapa['Year'] as String);
    final pts = double.tryParse(mapa['PTS'] as String? ?? '') ?? 0;
    final trb = double.tryParse(mapa['TRB'] as String? ?? '') ?? 0;
    final ast = double.tryParse(mapa['AST'] as String? ?? '') ?? 0;

    filas.add(HallDeLaFamaCompanion.insert(
      jugadorId: siguienteId,
      nombreJugador: nombreRealLimpio(mapa['Name'] as String),
      // Negativo: es el año real de ingreso (1959-2026), no una temporada
      // de tu partida — esas siempre son positivas. Lo distingue
      // `hall_fama_screen.dart` al pintar la ficha.
      temporadaIngreso: -anio,
      // Sin el desglose de premios/anillos reales no se puede replicar la
      // fórmula exacta de `puntuacionDeCarrera`; esto es solo una
      // aproximación a partir de su producción de carrera, de modo que
      // entren cómodamente por encima del umbral y se entremezclen por
      // puntuación con los que entran jugando de verdad.
      puntuacion: 80 + pts + trb * 1.2 + ast * 1.5,
    ));
    siguienteId--;
  }
  if (filas.isEmpty) return;

  await db.batch((batch) => batch.insertAll(db.hallDeLaFama, filas));
}
