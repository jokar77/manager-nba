import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/jugador_mapping.dart';
import '../../domain/posiciones.dart';
import '../../domain/salarios.dart';
import '../database/app_database.dart';

const _rutaAssetJugadores = 'assets/data/jugadores.json';
const _rutaAssetDatosReales = 'assets/data/datos_reales.json';

/// Cuántos jugadores del asset pasan el filtro de [_camposObligatorios] y
/// acaban en una partida nueva.
///
/// **Hay que subirlo al cambiar `jugadores.json`.** Es lo que permite saber
/// con UNA cuenta barata si a una partida vieja le faltan jugadores, sin
/// tener que leer y parsear los 300 KB del asset en cada arranque (ver
/// [anadirJugadoresQueFaltenDelDataset]). Si se queda desfasado no se rompe
/// nada, simplemente el relleno deja de dispararse — por eso hay un test
/// que lo compara con el asset de verdad y falla si no cuadran.
const jugadoresUtilizablesDelDataset = 586;

/// Campos que deben venir informados para poder simular con un jugador.
/// Unos ~59 jugadores del dataset (prospectos de un draft aún no jugado,
/// ej. Cameron Boozer) solo traen `media`/`potencial`/`edad_retiro` y
/// tienen el resto de atributos y estadísticas a null: se descartan del
/// import porque el motor de simulación no tiene con qué calcular su
/// aportación a un partido.
const _camposObligatorios = [
  'atr_tiro3',
  'atr_ataque',
  'atr_defensa',
  'pts_pg',
  'ast_pg',
  'trb_pg',
  'factor_longevidad',
];

/// Importa jugadores_manager_30_07.json (empaquetado como asset) a la tabla
/// `jugadores`, solo si la tabla está vacía. Idempotente: llamarla varias
/// veces en sucesivos arranques de la app no duplica datos.
///
/// Con [forzar] se borra y se reimporta todo. Hace falta al empezar una
/// franquicia nueva después de una carrera larga: para entonces los
/// jugadores están envejecidos, retirados y mezclados con rookies
/// generados, y una partida nueva tiene que arrancar con el dataset
/// original.
Future<void> importarJugadoresSiHaceFalta(AppDatabase db,
    {bool forzar = false, Random? random}) async {
  final rng = random ?? Random();
  if (forzar) {
    await db.delete(db.jugadores).go();
  } else {
    final yaHayDatos = await (db.select(db.jugadores)..limit(1)).get();
    if (yaHayDatos.isNotEmpty) return;
  }

  final crudo = await rootBundle.loadString(_rutaAssetJugadores);
  final lista = jsonDecode(crudo) as List<dynamic>;

  // Dorsal, salario y equipo actual reales, sacados de Basketball-Reference
  // y RealGM y cruzados por `nombre_real`. No cubre a todo el mundo (los
  // que ya no están en ninguna plantilla no aparecen): lo que falte se
  // deduce.
  final reales = jsonDecode(await rootBundle.loadString(_rutaAssetDatosReales))
      as Map<String, dynamic>;

  final utilizables = lista
      .cast<Map<String, dynamic>>()
      .where((mapa) => _camposObligatorios.every((c) => mapa[c] != null));

  final companions =
      utilizables.map((mapa) => _companionDe(mapa, reales, rng)).toList();

  await db.batch((batch) {
    batch.insertAll(db.jugadores, companions);
  });
}

/// Añade al vuelo los jugadores del dataset que NO estén ya en la partida.
///
/// Hace falta porque [importarJugadoresSiHaceFalta] se sale en cuanto ve la
/// tabla con datos: una carrera ya empezada no vuelve a mirar el asset
/// nunca más. Así que cuando el dataset gana jugadores —como pasó con los
/// cuatro que se habían perdido la temporada entera por lesión, Kyrie
/// Irving entre ellos— las partidas en curso se quedaban sin ellos para
/// siempre, aunque la actualización sí llegara.
///
/// **Solo en la primera temporada.** Más adelante la liga ya no se parece
/// al dataset: todo el mundo ha envejecido, alguno se ha retirado y ha
/// habido traspasos. Meter ahí a un jugador con la edad y la media del
/// asset original no sería restaurar lo que faltaba, sería inventarse un
/// fichaje caído del cielo con cinco años menos de los que le tocan. Si tu
/// carrera va por la temporada 4, la forma de tenerlos es empezar una
/// partida nueva.
///
/// Devuelve cuántos se han añadido.
Future<int> anadirJugadoresQueFaltenDelDataset(AppDatabase db,
    {Random? random}) async {
  final temporada = await (db.select(db.temporada)..where((t) => t.id.equals(0)))
      .getSingleOrNull();
  if (temporada != null && temporada.numero > 1) return 0;

  // Salida barata, y es la que importa: esto corre en CADA "continuar
  // partida". Contar filas es una consulta; leer y parsear los 300 KB del
  // asset no, y sería un peaje en el arranque de todas las partidas para
  // atrapar un caso que se da una vez en la vida de cada una. Es el mismo
  // patrón que usan los otros backfills de esta pantalla (ver
  // `_importarCamisetasRetiradasReales`): comprobar antes de leer.
  final cuantosHay = await db.jugadores.count().getSingle();
  if (cuantosHay >= jugadoresUtilizablesDelDataset) return 0;

  final yaEstan = (await db.select(db.jugadores).get())
      .map((j) => j.nombreReal)
      .toSet();

  final crudo = await rootBundle.loadString(_rutaAssetJugadores);
  final lista = jsonDecode(crudo) as List<dynamic>;
  final reales = jsonDecode(await rootBundle.loadString(_rutaAssetDatosReales))
      as Map<String, dynamic>;

  final rng = random ?? Random();
  final faltan = lista
      .cast<Map<String, dynamic>>()
      .where((mapa) => _camposObligatorios.every((c) => mapa[c] != null))
      .where((mapa) => !yaEstan.contains(mapa['nombre_real'] as String))
      .map((mapa) => _companionDe(mapa, reales, rng))
      .toList();
  if (faltan.isEmpty) return 0;

  await db.batch((batch) {
    batch.insertAll(db.jugadores, faltan);
  });
  return faltan.length;
}

/// Una fila de la tabla `jugadores` a partir de su entrada del dataset.
JugadoresCompanion _companionDe(
  Map<String, dynamic> mapa,
  Map<String, dynamic> reales,
  Random rng,
) {
  {
    final posicionCruda = mapa['posicion'] as String;
    final posicion = normalizarPosicion(posicionCruda);
    final astPg = (mapa['ast_pg'] as num).toDouble();
    final trbPg = (mapa['trb_pg'] as num).toDouble();
    final edad = mapa['edad'] as int;
    final media = mapa['media'] as int;

    final real = reales[mapa['nombre_real']] as Map<String, dynamic>?;
    final dorsal = real?['dorsal'] as int?;
    final salario = real?['salario'] as int? ??
        salarioEstimado(media: media, edad: edad);
    final anios = real?['anios_contrato'] as int? ??
        aniosContratoEstimados(edad: edad);

    return JugadoresCompanion.insert(
      nombreFicticio: mapa['nombre_ficticio'] as String,
      nombreReal: mapa['nombre_real'] as String,
      posicion: posicion,
      dorsal: Value(dorsal),
      salario: Value(salario),
      aniosContrato: Value(anios),
      // Si el dataset trae segunda posición se respeta; si no (el caso
      // normal), se deriva del juego del jugador.
      posicionSecundaria: Value(posicionSecundariaDeclarada(posicionCruda) ??
          derivarPosicionSecundaria(
              posicion: posicion,
              astPg: astPg,
              trbPg: trbPg,
              media: media)),
      // El equipo del dataset es de la 2025-26; si sabemos dónde está
      // ahora de verdad, manda ese.
      equipo: (real?['equipo'] as String?) ?? mapa['equipo'] as String,
      edad: edad,
      media: media,
      potencial: mapa['potencial'] as int,
      atrTiro3: mapa['atr_tiro3'] as int,
      atrAtaque: mapa['atr_ataque'] as int,
      atrDefensa: mapa['atr_defensa'] as int,
      ptsPg: (mapa['pts_pg'] as num).toDouble(),
      astPg: (mapa['ast_pg'] as num).toDouble(),
      trbPg: (mapa['trb_pg'] as num).toDouble(),
      factorLongevidad: (mapa['factor_longevidad'] as num).toDouble(),
      // El dataset trae una edad de retiro ya fijada de fábrica: es la
      // misma en toda partida nueva, así que los mismos jugadores se
      // retiraban siempre en el mismo momento. Se vuelve a echar a
      // suertes aquí, con el azar de esta partida, para que cada carrera
      // tenga sus propias retiradas.
      edadRetiro: _edadRetiroAleatoria(rng),
      draftYear: Value(mapa['draft_year'] as int?),
      temporadasPrevias: Value(_temporadasPrevias(mapa)),
      prestigioPrevio: Value(_prestigioPrevio(mapa)),
    );
  }
}

/// Misma distribución triangular (min 34, moda 37, max 42) que usaba el
/// script que generó el dataset, pero tirada con el azar de esta partida
/// en vez de una vez para siempre al preparar el asset.
int _edadRetiroAleatoria(Random rng) {
  const min = 34.0, max = 42.0, moda = 37.0;
  final u = rng.nextDouble();
  final f = (moda - min) / (max - min);
  final valor = u < f
      ? min + sqrt(u * (max - min) * (moda - min))
      : max - sqrt((1 - u) * (max - min) * (max - moda));
  return valor.round();
}

/// Temporada de referencia del dataset (2025-26). Sirve para deducir
/// cuántos años lleva ya jugados cada uno a partir de su año de draft.
const _anioDelDataset = 2026;

int _temporadasPrevias(Map<String, dynamic> mapa) {
  final draft = mapa['draft_year'] as int?;
  // Sin año de draft (unos cuantos del dataset), se estima suponiendo que
  // se debutó a los 20.
  final anos = draft != null
      ? _anioDelDataset - draft
      : (mapa['edad'] as int) - 20;
  return anos.clamp(0, 24);
}

/// Crédito de carrera anterior a tu partida. Solo cuenta lo que pasa de 82
/// de media (por debajo de ahí no hay carrera de Hall of Fame que valorar)
/// multiplicado por los años que ya llevaba jugados: una leyenda veterana
/// llega con el pase casi hecho, un veterano de rotación con nada.
double _prestigioPrevio(Map<String, dynamic> mapa) {
  final media = mapa['media'] as int;
  final porEncima = (media - 82).clamp(0, 20);
  return porEncima * _temporadasPrevias(mapa) * 0.30;
}
