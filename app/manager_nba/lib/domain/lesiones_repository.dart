import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

/// Probabilidad de lesión (leve o grave) para cada jugador que juega un
/// partido, y el rango de días que le deja fuera. Constantes fácilmente
/// ajustables — no pretenden ser una simulación médica real, solo dar
/// variedad realista de "casi siempre nada, a veces unos días, rara vez
/// mucho tiempo".
// Bajadas a la mitad tras feedback de que, jugando de verdad una temporada
// completa, salían demasiadas lesiones seguidas para sentirse "normal".
const probabilidadLesionGrave = 0.0004;
const probabilidadLesionLeve = 0.004;
const _diasLesionLeveMin = 2;
const _diasLesionLeveMax = 8;
const _diasLesionGraveMin = 20;
const _diasLesionGraveMax = 60;
const _diasPorPartido = 2;

/// Cuánto rinde peor un jugador con una lesión leve (magulladura, dolor
/// muscular) si decide jugar con ella — no le impide saltar a la cancha,
/// pero no está al cien por cien. Una grave sí le deja fuera del todo (ver
/// [jugadoresFueraDeJuegoEn]).
const factorRendimientoLesionLeve = 0.82;

const _motivosLeves = [
  'Esguince de tobillo',
  'Molestia muscular en el gemelo',
  'Contusión en la rodilla',
  'Sobrecarga en la espalda',
  'Golpe en la mano',
  'Molestia en el isquiotibial',
];

const _motivosGraves = [
  'Rotura de ligamento cruzado',
  'Fractura en la pierna',
  'Rotura del tendón de Aquiles',
  'Fractura en la mano',
  'Rotura muscular grave en el cuádriceps',
];

/// Una lesión recién ocurrida (para poder avisar en la UI).
class NuevaLesion {
  final int jugadorId;
  final String gravedad;
  final String motivo;
  final int partidosEstimados;
  final DateTime fechaFin;

  const NuevaLesion({
    required this.jugadorId,
    required this.gravedad,
    required this.motivo,
    required this.partidosEstimados,
    required this.fechaFin,
  });
}

/// Tira una lesión para cada jugador de [jugadorIdsQueJugaron] tras
/// disputarse un partido en [fechaPartido], guarda las que tocan, y
/// devuelve la lista de lesiones nuevas (para poder avisar en la UI).
Future<List<NuevaLesion>> tirarLesionesPartido(
  AppDatabase db,
  List<int> jugadorIdsQueJugaron,
  DateTime fechaPartido, {
  Random? random,
}) async {
  final rng = random ?? Random();
  final nuevas = <NuevaLesion>[];

  for (final jugadorId in jugadorIdsQueJugaron) {
    final tirada = rng.nextDouble();
    String? gravedad;
    var dias = 0;

    if (tirada < probabilidadLesionGrave) {
      gravedad = 'grave';
      dias = _diasLesionGraveMin +
          rng.nextInt(_diasLesionGraveMax - _diasLesionGraveMin + 1);
    } else if (tirada < probabilidadLesionGrave + probabilidadLesionLeve) {
      gravedad = 'leve';
      dias = _diasLesionLeveMin +
          rng.nextInt(_diasLesionLeveMax - _diasLesionLeveMin + 1);
    }

    if (gravedad != null) {
      final motivos = gravedad == 'grave' ? _motivosGraves : _motivosLeves;
      final motivo = motivos[rng.nextInt(motivos.length)];
      final partidosEstimados = max(1, (dias / _diasPorPartido).round());
      nuevas.add(NuevaLesion(
        jugadorId: jugadorId,
        gravedad: gravedad,
        motivo: motivo,
        partidosEstimados: partidosEstimados,
        fechaFin: fechaPartido.add(Duration(days: dias)),
      ));
    }
  }

  if (nuevas.isNotEmpty) {
    await db.batch((batch) => batch.insertAll(
          db.lesiones,
          nuevas.map((n) => LesionesCompanion.insert(
                jugadorId: n.jugadorId,
                fechaFin: n.fechaFin,
                gravedad: n.gravedad,
                motivo: Value(n.motivo),
                partidosEstimados: Value(n.partidosEstimados),
              )),
        ));
  }

  return nuevas;
}

/// Ids de los jugadores que siguen lesionados a fecha [fecha] (su lesión
/// más reciente termina después de esa fecha), leves y graves por igual.
/// Para saber quién no puede jugar de verdad, usa
/// [jugadoresFueraDeJuegoEn]; esta función es para lo que solo necesita
/// saber "¿está tocado?" (p. ej. el aviso en la ficha del jugador).
Future<Set<int>> jugadoresLesionadosEn(AppDatabase db, DateTime fecha) async {
  final filas = await (db.select(db.lesiones)
        ..where((t) => t.fechaFin.isBiggerThanValue(fecha)))
      .get();
  return filas.map((f) => f.jugadorId).toSet();
}

/// Ids de los jugadores que NO pueden jugar en [fecha]: solo cuenta la
/// lesión grave. Con una leve se puede seguir alineando al jugador —rinde
/// peor, pero juega— así que no cuenta como "fuera de juego".
Future<Set<int>> jugadoresFueraDeJuegoEn(AppDatabase db, DateTime fecha) async {
  final activas = await lesionesActivasEn(db, fecha);
  return activas.entries
      .where((e) => e.value.gravedad == 'grave')
      .map((e) => e.key)
      .toSet();
}

/// Multiplicador de rendimiento por lesión leve activa en [fecha]: 1.0 si
/// no tiene ninguna. Se combina con el estado de forma de la temporada
/// (multiplicando los dos) al construir la alineación de un partido.
Future<Map<int, double>> factoresLesionLeveEn(
  AppDatabase db,
  DateTime fecha,
) async {
  final activas = await lesionesActivasEn(db, fecha);
  return {
    for (final entry in activas.entries)
      if (entry.value.gravedad == 'leve') entry.key: factorRendimientoLesionLeve,
  };
}

/// La lesión activa (la más reciente) de cada jugador que sigue lesionado
/// a fecha [fecha] — para mostrar motivo, gravedad y vuelta estimada.
Future<Map<int, Lesion>> lesionesActivasEn(AppDatabase db, DateTime fecha) async {
  final filas = await (db.select(db.lesiones)
        ..where((t) => t.fechaFin.isBiggerThanValue(fecha)))
      .get();
  final activas = <int, Lesion>{};
  for (final f in filas) {
    final actual = activas[f.jugadorId];
    if (actual == null || f.fechaFin.isAfter(actual.fechaFin)) {
      activas[f.jugadorId] = f;
    }
  }
  return activas;
}
