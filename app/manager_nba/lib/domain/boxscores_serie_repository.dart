import 'package:drift/drift.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/database/app_database.dart';
import 'boxscore_serializacion.dart';

/// Guarda el boxscore de un partido de serie (playoffs o NBA Cup) recién
/// simulado, para poder volver a consultarlo desde la UI ("ver
/// estadísticas") igual que un partido de temporada regular.
Future<void> guardarBoxscoreDeSerie(
  AppDatabase db, {
  required String origen,
  required int serieId,
  required sim.Boxscore boxscore,
}) async {
  await db.into(db.boxscoresSerie).insert(BoxscoresSerieCompanion.insert(
        origen: origen,
        serieId: serieId,
        fecha: DateTime.now(),
        boxscoreJson: boxscoreAJson(boxscore),
      ));
}

/// Los boxscores de todos los partidos jugados de la serie [serieId] (de
/// [origen] 'playoffs' o 'torneo'), en el orden en que se jugaron.
Future<List<sim.Boxscore>> leerBoxscoresDeSerie(
  AppDatabase db, {
  required String origen,
  required int serieId,
}) async {
  final filas = await (db.select(db.boxscoresSerie)
        ..where((t) => t.origen.equals(origen) & t.serieId.equals(serieId))
        ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
      .get();
  return filas.map((f) => boxscoreDesdeJson(f.boxscoreJson)).toList();
}
