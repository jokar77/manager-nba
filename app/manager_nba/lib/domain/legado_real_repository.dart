import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Decide con la carrera REAL de un jugador (no la simulada en tu partida)
/// si un equipo le retira la camiseta o si entra en el Hall of Fame.
///
/// Los pesos y umbrales de abajo son un calco exacto de
/// `nba_legacy_scoring.js` (el sistema de scoring del usuario) — no se han
/// retocado ni un número. Los datos de carrera real (temporadas por
/// equipo, premios, campeonatos...) salen de Kaggle
/// (sumitrodatta/nba-aba-baa-stats + gregoirebenedetti/nba-champions),
/// cruzados por `build_legacy_dataset.py` y recortados a los 582 de los 641
/// jugadores del juego que tienen carrera NBA real (los que faltan son
/// prospectos de draft que en la vida real todavía no han debutado, así
/// que no hay estadística que Kaggle pueda tener de ellos).
const _rutaAsset = 'assets/data/legado_real_scoring.json';

const _pesosCamiseta = {
  'yearsWithTeam': 3,
  'allStarWithTeam': 8,
  'championshipWithTeam': 20,
  'finalsMvpWithTeam': 15,
  'mvpWithTeam': 15,
  'dpoyWithTeam': 10,
  'allNbaWithTeam': 5,
  'franchiseLegendBonus': 25,
  'minYearsRequired': 3,
};
const _umbralCamiseta = 55;

const _pesosHof = {
  'allStarSelections': 6,
  'championships': 12,
  'mvpAwards': 25,
  'finalsMvpAwards': 20,
  'dpoyAwards': 10,
  'allNbaFirstTeam': 10,
  'allNbaSecondTeam': 6,
  'allNbaThirdTeam': 4,
  'scoringTitles': 8,
  'careerPpgBonus': 0.5,
  'careerApgBonus': 0.8,
  'careerRpgBonus': 0.6,
  'longevityBonus': 1.5,
  'iconicPlayerBonus': 30,
};
const _umbralHof = 100;

Map<String, dynamic>? _cache;

Future<Map<String, dynamic>> _cargar() async {
  final cache = _cache;
  if (cache != null) return cache;
  final crudo = await rootBundle.loadString(_rutaAsset);
  final decodificado = jsonDecode(crudo) as Map<String, dynamic>;
  _cache = decodificado;
  return decodificado;
}

/// Los datos reales (Kaggle) de [nombreReal], si el juego los trae. Null si
/// no hay carrera NBA real registrada.
Future<Map<String, dynamic>?> datosRealesDe(String nombreReal) async {
  final todos = await _cargar();
  return todos[nombreReal] as Map<String, dynamic>?;
}

/// Lo que hizo de verdad un jugador con UN equipo concreto. Es lo que pide
/// la ficha de una camiseta retirada: no su carrera entera, sino sus años y
/// su producción con la franquicia que le honra.
class EtapaReal {
  final String equipo;
  final int anios;
  final int partidos;
  final double puntosPorPartido;
  final double asistenciasPorPartido;
  final double rebotesPorPartido;
  final int primeraTemporada;
  final int ultimaTemporada;
  final int allStar;
  final int anillos;
  final int mvpFinales;
  final int mvp;
  final int mejorDefensor;
  final int quintetos;

  const EtapaReal({
    required this.equipo,
    required this.anios,
    required this.partidos,
    required this.puntosPorPartido,
    required this.asistenciasPorPartido,
    required this.rebotesPorPartido,
    required this.primeraTemporada,
    required this.ultimaTemporada,
    required this.allStar,
    required this.anillos,
    required this.mvpFinales,
    required this.mvp,
    required this.mejorDefensor,
    required this.quintetos,
  });

  bool get tieneAlgunTrofeo =>
      anillos > 0 || mvpFinales > 0 || mvp > 0 || mejorDefensor > 0;
}

/// La carrera real completa, para la ficha del Hall of Fame.
class CarreraReal {
  final int partidos;
  final int puntos;
  final int asistencias;
  final int rebotes;
  final double puntosPorPartido;
  final double asistenciasPorPartido;
  final double rebotesPorPartido;
  final int temporadas;
  final int allStar;
  final int anillos;
  final int mvp;
  final int mvpFinales;
  final int mejorDefensor;
  final int primerQuinteto;
  final int segundoQuinteto;
  final int tercerQuinteto;
  final int titulosDeAnotacion;

  /// En qué temporadas ganó cada uno de los premios que no se repiten en
  /// rachas largas — el año real (el del dataset, ej. 1998 para la
  /// 1997-98), no el número de temporada de la partida. All-Star y
  /// quintetos se quedan solo en cantidad a propósito: con carreras de
  /// 15+ apariciones, la lista de años sería ruido, no información.
  final List<int> aniosMvp;
  final List<int> aniosMvpFinales;
  final List<int> aniosMejorDefensor;
  final List<int> aniosMaximoAnotador;

  const CarreraReal({
    required this.partidos,
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
    required this.puntosPorPartido,
    required this.asistenciasPorPartido,
    required this.rebotesPorPartido,
    required this.temporadas,
    required this.allStar,
    required this.anillos,
    required this.mvp,
    required this.mvpFinales,
    required this.mejorDefensor,
    required this.primerQuinteto,
    required this.segundoQuinteto,
    required this.tercerQuinteto,
    required this.titulosDeAnotacion,
    this.aniosMvp = const [],
    this.aniosMvpFinales = const [],
    this.aniosMejorDefensor = const [],
    this.aniosMaximoAnotador = const [],
  });
}

/// La temporada tal y como la nombra el dataset (el año en que TERMINA:
/// 1998 es la 1997-98), traducida al formato del juego.
String etiquetaTemporadaReal(int anioFinal) {
  final inicio = anioFinal - 1;
  return '$inicio-${(anioFinal % 100).toString().padLeft(2, '0')}';
}

EtapaReal _etapaDesde(Map<String, dynamic> s) => EtapaReal(
      equipo: s['team'] as String,
      anios: (s['yearsWithTeam'] as num).toInt(),
      partidos: (s['gamesWithTeam'] as num?)?.toInt() ?? 0,
      puntosPorPartido: (s['ppgWithTeam'] as num?)?.toDouble() ?? 0,
      asistenciasPorPartido: (s['apgWithTeam'] as num?)?.toDouble() ?? 0,
      rebotesPorPartido: (s['rpgWithTeam'] as num?)?.toDouble() ?? 0,
      primeraTemporada: (s['firstSeasonWithTeam'] as num?)?.toInt() ?? 0,
      ultimaTemporada: (s['lastSeasonWithTeam'] as num?)?.toInt() ?? 0,
      allStar: (s['allStarSelectionsWithTeam'] as num).toInt(),
      anillos: (s['championshipsWithTeam'] as num).toInt(),
      mvpFinales: (s['finalsMvpWithTeam'] as num).toInt(),
      mvp: (s['mvpWithTeam'] as num).toInt(),
      mejorDefensor: (s['dpoyWithTeam'] as num).toInt(),
      quintetos: (s['allNbaSelectionsWithTeam'] as num).toInt(),
    );

/// Lo que hizo [nombreReal] con [equipo] en la NBA de verdad, o null si no
/// hay datos suyos o nunca jugó ahí.
Future<EtapaReal?> etapaRealCon(String nombreReal, String equipo) async {
  final datos = await datosRealesDe(nombreReal);
  if (datos == null) return null;
  final stints = (datos['teamStints'] as List).cast<Map<String, dynamic>>();
  for (final s in stints) {
    if (s['team'] == equipo) return _etapaDesde(s);
  }
  return null;
}

/// Todas sus etapas reales, en orden cronológico: del primer equipo al
/// último. Antes iban de la etapa más larga a la más corta, y en la ficha
/// eso se leía como si la carrera hubiera empezado por donde jugó más
/// partidos — a Jordan le salía Chicago, Washington y sus años de Bulls
/// mezclados sin ningún hilo temporal.
Future<List<EtapaReal>> etapasRealesDe(String nombreReal) async {
  final datos = await datosRealesDe(nombreReal);
  if (datos == null) return const [];
  final stints = (datos['teamStints'] as List).cast<Map<String, dynamic>>();
  return stints.map(_etapaDesde).toList()
    ..sort((a, b) => a.primeraTemporada.compareTo(b.primeraTemporada));
}

/// Su carrera real completa, o null si el juego no tiene datos suyos.
Future<CarreraReal?> carreraRealDe(String nombreReal) async {
  final datos = await datosRealesDe(nombreReal);
  if (datos == null) return null;
  return _carreraDesde(datos);
}

/// Todas las carreras reales que trae el asset, por nombre real. Son los
/// jugadores del dataset del juego MÁS las leyendas ya retiradas (Jordan,
/// Bird, Kareem...), que no existen como fila de `Jugadores` pero cuyos
/// totales sí cuentan para los líderes históricos de la liga.
Future<Map<String, CarreraReal>> todasLasCarrerasReales() async {
  final todos = await _cargar();
  return {
    for (final entrada in todos.entries)
      entrada.key: _carreraDesde(entrada.value as Map<String, dynamic>),
  };
}

CarreraReal _carreraDesde(Map<String, dynamic> datos) {
  final c = datos['careerTotals'] as Map<String, dynamic>;
  return CarreraReal(
    partidos: (c['gamesPlayed'] as num?)?.toInt() ?? 0,
    puntos: (c['careerPoints'] as num?)?.toInt() ?? 0,
    asistencias: (c['careerAssists'] as num?)?.toInt() ?? 0,
    rebotes: (c['careerRebounds'] as num?)?.toInt() ?? 0,
    puntosPorPartido: (c['careerPpg'] as num).toDouble(),
    asistenciasPorPartido: (c['careerApg'] as num).toDouble(),
    rebotesPorPartido: (c['careerRpg'] as num).toDouble(),
    temporadas: (c['yearsPlayed'] as num).toInt(),
    allStar: (c['allStarSelections'] as num).toInt(),
    anillos: (c['championships'] as num).toInt(),
    mvp: (c['mvpAwards'] as num).toInt(),
    mvpFinales: (c['finalsMvpAwards'] as num).toInt(),
    mejorDefensor: (c['dpoyAwards'] as num).toInt(),
    primerQuinteto: (c['allNbaFirstTeam'] as num).toInt(),
    segundoQuinteto: (c['allNbaSecondTeam'] as num).toInt(),
    tercerQuinteto: (c['allNbaThirdTeam'] as num).toInt(),
    titulosDeAnotacion: (c['scoringTitles'] as num).toInt(),
    aniosMvp: _anios(c['mvpSeasons']),
    aniosMvpFinales: _anios(c['finalsMvpSeasons']),
    aniosMejorDefensor: _anios(c['dpoyAwardSeasons']),
    aniosMaximoAnotador: _anios(c['scoringTitleSeasons']),
  );
}

List<int> _anios(dynamic crudo) =>
    (crudo as List?)?.map((a) => (a as num).toInt()).toList() ?? const [];

int _scoreCamiseta(Map<String, dynamic> stint) {
  final w = _pesosCamiseta;
  num score = 0;
  score += (stint['yearsWithTeam'] as num) * (w['yearsWithTeam'] as num);
  score += (stint['allStarSelectionsWithTeam'] as num) *
      (w['allStarWithTeam'] as num);
  score += (stint['championshipsWithTeam'] as num) *
      (w['championshipWithTeam'] as num);
  score += (stint['finalsMvpWithTeam'] as num) * (w['finalsMvpWithTeam'] as num);
  score += (stint['mvpWithTeam'] as num) * (w['mvpWithTeam'] as num);
  score += (stint['dpoyWithTeam'] as num) * (w['dpoyWithTeam'] as num);
  score += (stint['allNbaSelectionsWithTeam'] as num) *
      (w['allNbaWithTeam'] as num);
  if (stint['isFranchiseLegend'] == true) {
    score += w['franchiseLegendBonus'] as num;
  }
  return score.round();
}

/// El equipo (código, ej. "CHI") que de verdad debería retirarle la
/// camiseta a [nombreReal] según su carrera real, o null si ninguno cruza
/// el umbral (o si no hay datos suyos). Si hay más de uno elegible —una
/// leyenda que jugó en varios equipos, tipo LeBron con Cleveland, Miami y
/// Los Angeles— se queda con [preferido] si está entre los elegibles
/// (normalmente el equipo donde ha jugado en tu partida), o si no con el
/// de mayor puntuación.
Future<String?> equipoQueRetiraCamisetaReal(
  String nombreReal, {
  String? preferido,
}) async {
  final equipos =
      await equiposQueRetiranCamisetaReal(nombreReal, preferido: preferido);
  return equipos.isEmpty ? null : equipos.first;
}

/// TODOS los equipos que deberían retirarle la camiseta a [nombreReal], de
/// más a menos importante en su carrera, con [preferido] al frente si está
/// entre ellos.
///
/// Una leyenda que hizo historia en varios sitios recibe el homenaje en
/// todos: LeBron tiene que colgar del techo en Cleveland, en Miami y en Los
/// Angeles, no solo en uno. Antes se retiraba una sola camiseta por jugador
/// —el resto de franquicias donde fue igual de decisivo se quedaban sin
/// nada— porque la elegibilidad se calculaba equipo a equipo y luego se
/// tiraba todo menos el primero.
Future<List<String>> equiposQueRetiranCamisetaReal(
  String nombreReal, {
  String? preferido,
}) async {
  final datos = await datosRealesDe(nombreReal);
  if (datos == null) return const [];
  final stints = (datos['teamStints'] as List).cast<Map<String, dynamic>>();

  final elegibles = <String, int>{};
  for (final stint in stints) {
    if ((stint['yearsWithTeam'] as num) <
        (_pesosCamiseta['minYearsRequired'] as num)) {
      continue;
    }
    final score = _scoreCamiseta(stint);
    if (score >= _umbralCamiseta) {
      final equipo = stint['team'] as String;
      // Dos etapas en el mismo equipo (se fue y volvió) cuentan como una:
      // se queda con la mejor de las dos.
      final previo = elegibles[equipo];
      if (previo == null || score > previo) elegibles[equipo] = score;
    }
  }
  if (elegibles.isEmpty) return const [];

  final ordenados = elegibles.entries.toList()
    ..sort((a, b) {
      if (preferido != null) {
        if (a.key == preferido) return -1;
        if (b.key == preferido) return 1;
      }
      final porScore = b.value.compareTo(a.value);
      return porScore != 0 ? porScore : a.key.compareTo(b.key);
    });
  return ordenados.map((e) => e.key).toList();
}

/// ¿La carrera real de [nombreReal] cruza el umbral del Hall of Fame? False
/// tanto si no llega como si no hay datos reales suyos.
Future<bool> entraEnHofReal(String nombreReal) async {
  final datos = await datosRealesDe(nombreReal);
  if (datos == null) return false;
  final career = datos['careerTotals'] as Map<String, dynamic>;
  final w = _pesosHof;

  num score = 0;
  score += (career['allStarSelections'] as num) * (w['allStarSelections'] as num);
  score += (career['championships'] as num) * (w['championships'] as num);
  score += (career['mvpAwards'] as num) * (w['mvpAwards'] as num);
  score += (career['finalsMvpAwards'] as num) * (w['finalsMvpAwards'] as num);
  score += (career['dpoyAwards'] as num) * (w['dpoyAwards'] as num);
  score += (career['allNbaFirstTeam'] as num) * (w['allNbaFirstTeam'] as num);
  score += (career['allNbaSecondTeam'] as num) * (w['allNbaSecondTeam'] as num);
  score += (career['allNbaThirdTeam'] as num) * (w['allNbaThirdTeam'] as num);
  score += (career['scoringTitles'] as num) * (w['scoringTitles'] as num);
  score += (career['careerPpg'] as num) * (w['careerPpgBonus'] as num);
  score += (career['careerApg'] as num) * (w['careerApgBonus'] as num);
  score += (career['careerRpg'] as num) * (w['careerRpgBonus'] as num);
  score += (career['yearsPlayed'] as num) * (w['longevityBonus'] as num);
  if (career['isIconicPlayer'] == true) score += w['iconicPlayerBonus'] as num;

  return score >= _umbralHof;
}
