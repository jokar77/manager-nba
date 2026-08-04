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

  final companions = utilizables.map((mapa) {
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
              posicion: posicion, astPg: astPg, trbPg: trbPg)),
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
  }).toList();

  await db.batch((batch) {
    batch.insertAll(db.jugadores, companions);
  });
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
