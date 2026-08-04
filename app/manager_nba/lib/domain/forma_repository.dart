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

/// Cuánto se le deja arrastrar a un equipo entero la suerte de sus
/// jugadores. Con 1.0 no se corrige nada (como estaba) y con 0.0 la forma
/// media de cada rotación es exactamente 1.0.
///
/// Que la forma varíe por jugador es bueno y hace falta: es lo que mueve el
/// MVP de un año a otro. Lo que no puede pasar es que se acumule. Los
/// sorteos individuales de los diez que juegan se suman y mueven la fuerza
/// del equipo entero, y ahí el efecto era brutal: midiendo 10 temporadas
/// del MISMO equipo con la MISMA plantilla, las victorias se desviaban 7,9
/// —contra un suelo irreducible de 4,4— y la forma sorteada explicaba el
/// 61% del resultado final (r = 0,78). Dicho de otra forma, tu temporada la
/// decidía más un dado de septiembre que tu plantilla.
///
/// Se deja algo (0.35) a propósito: un equipo puede tener un buen año o uno
/// gris, como en la NBA de verdad. Lo que ya no puede es que ese dado pese
/// más que las decisiones del manager.
const _arrastreDeEquipo = 0.35;

/// Cuántos jugadores se consideran "la rotación" al neutralizar el arrastre:
/// los mejores por media, que son los que de verdad juegan (ver
/// generarRotacionAutomatica y generarAlineacionAutomatica, ambas de 10).
const _tamanoDeLaRotacion = 10;

/// Sortea el estado de forma de esta temporada para todos los jugadores y
/// lo guarda, sustituyendo el anterior. Se llama al crear la franquicia (y
/// se llamará al empezar cada temporada nueva).
Future<void> sortearFormaDeTemporada(AppDatabase db, {Random? random}) async {
  final rng = random ?? Random();
  final jugadores = await db.select(db.jugadores).get();

  final sorteo = {
    for (final j in jugadores) j.id: 1.0 + _ruidoGaussiano(rng) * _sigmaForma
  };

  // Cuánta suerte le ha tocado a cada equipo EN CONJUNTO, mirando solo a
  // los que van a jugar. Los agentes libres y los retirados no forman
  // equipo, así que se quedan con su sorteo tal cual.
  final porEquipo = <String, List<Jugador>>{};
  for (final j in jugadores) {
    if (j.retirado) continue;
    porEquipo.putIfAbsent(j.equipo, () => []).add(j);
  }
  final arrastrePorEquipo = <String, double>{};
  for (final entrada in porEquipo.entries) {
    final rotacion = [...entrada.value]
      ..sort((a, b) => b.media.compareTo(a.media));
    final losQueJuegan = rotacion.take(_tamanoDeLaRotacion).toList();
    if (losQueJuegan.isEmpty) continue;
    final media = losQueJuegan
            .map((j) => sorteo[j.id]!)
            .reduce((a, b) => a + b) /
        losQueJuegan.length;
    arrastrePorEquipo[entrada.key] = media - 1.0;
  }

  final filas = jugadores.map((j) {
    final exceso = j.retirado ? 0.0 : (arrastrePorEquipo[j.equipo] ?? 0.0);
    final factor = (sorteo[j.id]! - exceso * (1 - _arrastreDeEquipo))
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
