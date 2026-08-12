import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database/app_database.dart';

const _rutaAsset = 'assets/data/entrenadores.json';

/// Importa los 30 entrenadores de la liga más los que están libres, solo si
/// la tabla está vacía. Idempotente, igual que el de jugadores.
///
/// Con [forzar] se borra y se reimporta: hace falta al empezar una partida
/// nueva, cuando los de la anterior están envejecidos y repartidos por otros
/// equipos.
///
/// Ojo con el orden: esto no se puede llamar antes de que existan los
/// jugadores, porque los entrenadores se colocan por código de equipo y el
/// asset da por hecho las 30 franquicias del dataset.
Future<void> importarEntrenadoresSiHaceFalta(
  AppDatabase db, {
  bool forzar = false,
}) async {
  if (forzar) {
    await db.delete(db.entrenadores).go();
  } else {
    final yaHay = await (db.select(db.entrenadores)..limit(1)).get();
    if (yaHay.isNotEmpty) return;
  }

  final lista = jsonDecode(await rootBundle.loadString(_rutaAsset)) as List;

  final companions = lista.cast<Map<String, dynamic>>().map((mapa) {
    return EntrenadoresCompanion.insert(
      nombreFicticio: mapa['nombre_ficticio'] as String,
      nombreReal: mapa['nombre_real'] as String,
      equipo: mapa['equipo'] as String,
      edad: mapa['edad'] as int,
      atrAtaque: mapa['atr_ataque'] as int,
      atrDefensa: mapa['atr_defensa'] as int,
      atrDesarrollo: mapa['atr_desarrollo'] as int,
      anillos: Value(mapa['anillos'] as int? ?? 0),
      premios: Value(mapa['premios'] as int? ?? 0),
      temporadas: Value(mapa['temporadas'] as int? ?? 0),
    );
  }).toList();

  await db.batch((batch) {
    batch.insertAll(db.entrenadores, companions);
  });
}
