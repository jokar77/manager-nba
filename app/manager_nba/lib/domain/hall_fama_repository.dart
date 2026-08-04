import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'carrera_repository.dart';
import 'legado_real_repository.dart';
import 'tipo_premio.dart';

/// Puntuación mínima de carrera para entrar en el Hall of Fame. Calibrada
/// midiendo 15 temporadas simuladas: con 70 entraban 4 de 464 retirados
/// (realista, pero el Hall of Fame se quedaba vacío durante años enteros);
/// con 55 entra alrededor de uno por temporada, que es lo que hace que
/// merezca la pena visitarlo. Un titular sólido sin premios se queda en
/// 35-45, así que sigue haciendo falta haber sido importante.
const umbralHallDeLaFama = 55.0;

/// Puntos que aporta cada mérito. Los premios individuales pesan más que
/// los anillos porque un anillo se puede ganar siendo el duodécimo hombre.
const _puntosPorPremio = {
  TipoPremio.mvp: 25.0,
  TipoPremio.mejorDefensor: 12.0,
  TipoPremio.primerQuinteto: 10.0,
  TipoPremio.segundoQuinteto: 5.0,
  TipoPremio.rookieDelAno: 3.0,
  TipoPremio.masMejorado: 2.0,
};
const _puntosPorAnillo = 8.0;
const _puntosPorCopa = 2.0;

/// Cuánto vale la carrera de un jugador de cara al Hall of Fame: sus
/// trofeos, el nivel máximo que alcanzó y la producción acumulada, con un
/// mínimo de recorrido (una carrera de 3 años no entra por mucho que
/// brillara).
double puntuacionDeCarrera(CarreraJugador carrera) {
  if (carrera.temporadasTotales < 6) return 0;

  // Lo que ya había hecho antes de que empezara tu partida. Sin esto, las
  // leyendas que llegan al final de su carrera se retirarían con dos
  // temporadas simuladas y no entrarían jamás; con esto, LeBron, Curry o
  // Durant llegan con el pase prácticamente hecho y a Jokić o Antetokounmpo
  // les basta con seguir rindiendo un par de años más.
  var puntos = carrera.prestigioPrevio;
  for (final entrada in _puntosPorPremio.entries) {
    puntos += carrera.vecesGano(entrada.key) * entrada.value;
  }
  puntos += carrera.anillos.length * _puntosPorAnillo;
  puntos += carrera.copas.length * _puntosPorCopa;

  // Pico de nivel: solo cuenta lo que pase de 85 (ser bueno no basta).
  puntos += (carrera.mejorMedia - 85).clamp(0, 14) * 2.0;

  // Producción: puntos + asistencias y rebotes ponderados, escalado por lo
  // larga que fue la carrera.
  final produccion = carrera.puntosPorPartido +
      carrera.asistenciasPorPartido * 1.5 +
      carrera.rebotesPorPartido * 1.2;
  puntos += produccion * carrera.temporadas * 0.09;

  return puntos;
}

/// Revisa a los recién retirados y mete en el Hall of Fame a los que pasen
/// del umbral. Se llama al cambiar de temporada, después de archivar las
/// estadísticas del año.
///
/// Entra quien cumpla CUALQUIERA de los dos caminos: lo que ha hecho dentro
/// de tu partida (`puntuacionDeCarrera`, que ya cuenta `prestigioPrevio`
/// como abono a cuenta de su carrera real), o su carrera NBA real de
/// verdad (`entraEnHofReal`, con los datos de Kaggle). Hace falta el
/// segundo camino porque el primero necesita al menos una temporada
/// simulada (`leerCarrera` con `exigirTemporadasSimuladas: true`): una
/// leyenda real que se retira sin haber llegado a completar ni un año
/// contigo, si no, no entraría nunca.
Future<List<MiembroHallDeLaFama>> evaluarIngresosHallDeLaFama(
  AppDatabase db, {
  required List<int> jugadorIdsRetirados,
  required int temporada,
}) async {
  final yaDentro = (await db.select(db.hallDeLaFama).get())
      .map((m) => m.jugadorId)
      .toSet();

  final nuevos = <MiembroHallDeLaFama>[];
  for (final id in jugadorIdsRetirados) {
    if (yaDentro.contains(id)) continue;

    final jugador = await (db.select(db.jugadores)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    final carrera = await leerCarrera(db, id);

    final puntuacion = carrera == null ? 0.0 : puntuacionDeCarrera(carrera);
    final porSimulado = puntuacion >= umbralHallDeLaFama;
    final porCarreraReal =
        jugador != null && await entraEnHofReal(jugador.nombreReal);
    if (!porSimulado && !porCarreraReal) continue;

    final nombre = carrera?.nombre ?? jugador?.nombreFicticio ?? '?';
    final insertadoId = await db.into(db.hallDeLaFama).insert(
          HallDeLaFamaCompanion.insert(
            jugadorId: id,
            nombreJugador: nombre,
            temporadaIngreso: temporada,
            puntuacion: puntuacion,
          ),
        );
    nuevos.add(MiembroHallDeLaFama(
      id: insertadoId,
      jugadorId: id,
      nombreJugador: nombre,
      temporadaIngreso: temporada,
      puntuacion: puntuacion,
    ));
  }

  nuevos.sort((a, b) => b.puntuacion.compareTo(a.puntuacion));
  return nuevos;
}

/// Todos los miembros del Hall of Fame, de mejor carrera a peor.
Future<List<MiembroHallDeLaFama>> leerHallDeLaFama(AppDatabase db) {
  return (db.select(db.hallDeLaFama)
        ..orderBy([(t) => OrderingTerm.desc(t.puntuacion)]))
      .get();
}
