import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

/// Límites del multiplicador de forma. Un jugador puede tener un año de
/// explosión (hasta +16% de producción) o uno flojo (hasta -16%); la
/// mayoría se queda cerca de 1.0. El techo es deliberadamente moderado:
/// con márgenes más anchos, un anotador top se iba por encima de los 40
/// puntos de media y rompía el realismo que ya se ajustó en
/// pesos_atributos.dart.
const formaMinima = 0.84;
const formaMaxima = 1.16;

/// Desviación típica del sorteo. Con 0.07, ~2 de cada 3 jugadores quedan
/// entre 0.93 y 1.07, y los extremos son raros pero existen. Sigue siendo
/// diferencia de sobra para que el MVP y el resto de premios cambien de
/// temporada en temporada en vez de caer siempre en el mismo jugador: entre
/// un año grande y uno flojo hay más de un 30% de distancia relativa.
const _sigmaForma = 0.07;

/// Sortea el estado de forma de esta temporada para todos los jugadores y
/// lo guarda, sustituyendo el anterior. Se llama al crear la franquicia (y
/// se llamará al empezar cada temporada nueva).
Future<void> sortearFormaDeTemporada(AppDatabase db, {Random? random}) async {
  final rng = random ?? Random();
  final jugadores = await db.select(db.jugadores).get();

  final filas = jugadores.map((j) {
    final factor = (1.0 + _ruidoGaussiano(rng) * _sigmaForma)
        .clamp(formaMinima, formaMaxima)
        .toDouble();
    return FormaTemporadaJugadorCompanion.insert(
      jugadorId: Value(j.id),
      factor: Value(factor),
    );
  }).toList();

  await db.transaction(() async {
    await db.delete(db.formaTemporadaJugador).go();
    await db.batch((batch) => batch.insertAll(db.formaTemporadaJugador, filas));
  });
}

/// El factor de forma de cada jugador que lo tenga sorteado. Los que no
/// aparezcan se tratan como forma neutra (1.0) allá donde se use.
Future<Map<int, double>> leerFormas(AppDatabase db) async {
  final filas = await db.select(db.formaTemporadaJugador).get();
  return {for (final f in filas) f.jugadorId: f.factor};
}

/// Ruido gaussiano estándar (media 0, desviación 1) vía Box-Muller.
double _ruidoGaussiano(Random random) {
  final u1 = 1 - random.nextDouble();
  final u2 = random.nextDouble();
  return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
}
