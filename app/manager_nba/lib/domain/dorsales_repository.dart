import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'progresion_repository.dart';

/// Rango de dorsales que se sortean para los jugadores sin número real
/// conocido. Los reales pueden salirse de aquí — hay quien lleva el 0, el
/// 00 o el 77.
const _dorsalMinimo = 1;
const _dorsalMaximo = 55;

/// Asigna dorsal a todo jugador en activo que no lo tenga, único dentro de
/// su equipo y sin pisar ningún número que esa franquicia haya retirado.
///
/// Los números reales llegan ya puestos desde el importador
/// (assets/data/datos_reales.json); aquí solo se rellenan los huecos. Se
/// llama al crear la franquicia y después de cada draft, para los rookies.
Future<void> asignarDorsalesQueFalten(AppDatabase db, {Random? random}) async {
  final rng = random ?? Random();

  await _liberarDorsalesDuplicados(db);
  await liberarDorsalesDeNumerosRetirados(db);

  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();
  final retiradas = await db.select(db.camisetasRetiradas).get();

  final ocupados = <String, Set<int>>{};
  for (final c in retiradas) {
    ocupados.putIfAbsent(c.equipo, () => {}).add(c.dorsal);
  }
  for (final j in jugadores) {
    if (j.dorsal != null) {
      ocupados.putIfAbsent(j.equipo, () => {}).add(j.dorsal!);
    }
  }

  final sinDorsal = jugadores.where((j) => j.dorsal == null).toList();
  if (sinDorsal.isEmpty) return;

  await db.transaction(() async {
    for (final j in sinDorsal) {
      if (j.equipo == equipoRetirados) continue;
      final usados = ocupados.putIfAbsent(j.equipo, () => {});

      final libres = [
        for (var n = _dorsalMinimo; n <= _dorsalMaximo; n++)
          if (!usados.contains(n)) n,
      ];
      // Con 55 números y plantillas de 18 siempre queda alguno libre; la
      // salvaguarda es por si una franquicia acabara retirando muchísimos.
      final elegido = libres.isEmpty
          ? _dorsalMaximo + usados.length
          : libres[rng.nextInt(libres.length)];
      usados.add(elegido);

      await (db.update(db.jugadores)..where((t) => t.id.equals(j.id)))
          .write(JugadoresCompanion(dorsal: Value(elegido)));
    }
  });
}

/// Deja sin dorsal a los que lo repiten dentro de su equipo, para que el
/// reparto de después les dé uno libre.
///
/// Pasa con los números reales: un jugador puede traer el suyo de la
/// franquicia en la que juega de verdad y acabar en otra dentro del juego,
/// chocando con quien ya lo llevaba. Se queda con el número el de mejor
/// media (es el que el aficionado asocia a ese dorsal).
Future<void> _liberarDorsalesDuplicados(AppDatabase db) async {
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();

  final porEquipoYDorsal = <String, List<Jugador>>{};
  for (final j in jugadores) {
    if (j.dorsal == null || j.equipo == equipoRetirados) continue;
    porEquipoYDorsal.putIfAbsent('${j.equipo}#${j.dorsal}', () => []).add(j);
  }

  final aLiberar = <int>[];
  for (final grupo in porEquipoYDorsal.values) {
    if (grupo.length < 2) continue;
    final ordenados = [...grupo]..sort((a, b) => b.media.compareTo(a.media));
    aLiberar.addAll(ordenados.skip(1).map((j) => j.id));
  }
  if (aLiberar.isEmpty) return;

  await (db.update(db.jugadores)..where((t) => t.id.isIn(aLiberar)))
      .write(const JugadoresCompanion(dorsal: Value(null)));
}

/// Deja sin dorsal a cualquier jugador en activo que esté llevando un
/// número que su equipo tiene retirado — real (ver
/// `legado_historico_repository.dart`) o ganado dentro de la propia
/// partida—, para que el reparto de después le dé uno libre.
///
/// Hace falta porque una franquicia puede retirar un número (o el juego
/// puede importar el legado real) en cualquier momento, con jugadores ya
/// en plantilla que llevaban puesto justo ese dorsal: sin esto, sería
/// posible ver a alguien vistiendo un número que ya está en la pared del
/// pabellón.
Future<void> liberarDorsalesDeNumerosRetirados(AppDatabase db) async {
  final retiradas = await db.select(db.camisetasRetiradas).get();
  if (retiradas.isEmpty) return;

  final bloqueados = <String, Set<int>>{};
  for (final c in retiradas) {
    bloqueados.putIfAbsent(c.equipo, () => {}).add(c.dorsal);
  }

  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();
  final aLiberar = [
    for (final j in jugadores)
      if (j.dorsal != null &&
          (bloqueados[j.equipo]?.contains(j.dorsal) ?? false))
        j.id,
  ];
  if (aLiberar.isEmpty) return;

  await (db.update(db.jugadores)..where((t) => t.id.isIn(aLiberar)))
      .write(const JugadoresCompanion(dorsal: Value(null)));
}
