import '../data/database/app_database.dart';
import 'legado_real_repository.dart';

/// Cuántos nombres se enseñan por categoría. Con toda la historia de la NBA
/// dentro, una lista sin tope sería un muro de texto; con 50 se ve de sobra
/// quién manda y por dónde andan los tuyos.
const topLideresHistoricos = 50;

class LiderHistorico {
  /// Cómo se le llama en el juego: el nombre ficticio si es alguien de tu
  /// liga, o el real si es una leyenda que ya estaba retirada cuando
  /// empezaste.
  final String nombre;

  /// Su fila en `Jugadores`, si existe. Las leyendas puras no tienen.
  final int? jugadorId;

  /// Nombre real, para poder abrir su ficha aunque no juegue en tu liga.
  final String nombreReal;

  /// En activo AHORA MISMO en tu partida. Es lo que se pinta en otro color:
  /// en cuanto se retira deja de estarlo y el color desaparece solo.
  final bool enActivo;

  final int total;

  const LiderHistorico({
    required this.nombre,
    required this.jugadorId,
    required this.nombreReal,
    required this.enActivo,
    required this.total,
  });
}

class LideresHistoricos {
  final List<LiderHistorico> puntos;
  final List<LiderHistorico> asistencias;
  final List<LiderHistorico> rebotes;

  const LideresHistoricos({
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
  });
}

/// Un jugador con sus tres totales de carrera acumulados, antes de saber
/// todavía en qué puesto queda de cada categoría.
typedef _FilaLider = ({
  String nombre,
  int? jugadorId,
  String nombreReal,
  bool enActivo,
  int pts,
  int ast,
  int reb,
});

/// Los líderes históricos de puntos, asistencias y rebotes de toda la
/// historia de la liga, de mayor a menor.
///
/// Cuenta a TODO el que tenga carrera NBA real en el asset de Kaggle —los
/// 582 del dataset del juego y también las leyendas ya retiradas, que no
/// tienen fila en `Jugadores` pero cuyos totales son justo los que mandan
/// en estas listas (los 32.292 puntos de Jordan no los va a alcanzar nadie
/// en dos temporadas simuladas)— y le suma lo que haya hecho dentro de tu
/// partida, bajo el mismo total. Mismo criterio que la ficha individual:
/// no se separa "lo real" de "lo simulado".
///
/// También entran los que solo existen en tu liga (rookies salidos de tus
/// drafts), que empiezan de cero y van subiendo.
///
/// Se incluyen las estadísticas de la temporada en curso, todavía sin
/// archivar, así que la lista sube sola según se juega.
///
/// No hay triples ni versión de playoffs: el motor de simulación no lleva
/// la cuenta de ninguno de los dos, así que no habría con qué sumar lo
/// simulado a lo real sin dejar media lista coja.
Future<LideresHistoricos> leerLideresHistoricos(
  AppDatabase db, {
  int top = topLideresHistoricos,
}) async {
  final jugadores = await db.select(db.jugadores).get();
  final archivadas = await db.select(db.historialEstadisticasJugador).get();
  final actuales = await db.select(db.estadisticasTemporadaJugador).get();
  final reales = await todasLasCarrerasReales();

  final puntosSim = <int, int>{};
  final asistenciasSim = <int, int>{};
  final rebotesSim = <int, int>{};

  void sumar(int jugadorId, int pts, int ast, int reb) {
    puntosSim[jugadorId] = (puntosSim[jugadorId] ?? 0) + pts;
    asistenciasSim[jugadorId] = (asistenciasSim[jugadorId] ?? 0) + ast;
    rebotesSim[jugadorId] = (rebotesSim[jugadorId] ?? 0) + reb;
  }

  for (final t in archivadas) {
    sumar(t.jugadorId, t.puntosTotales, t.asistenciasTotales, t.rebotesTotales);
  }
  for (final t in actuales) {
    sumar(t.jugadorId, t.puntosTotales, t.asistenciasTotales, t.rebotesTotales);
  }

  final porNombreReal = {
    for (final j in jugadores)
      if (j.nombreReal.isNotEmpty) j.nombreReal: j,
  };

  final filas = <_FilaLider>[];

  // 1) Todas las carreras reales, con lo simulado encima si además juega
  //    (o jugó) en tu liga.
  for (final entrada in reales.entries) {
    final real = entrada.value;
    final j = porNombreReal[entrada.key];
    filas.add((
      nombre: j?.nombreFicticio ?? entrada.key,
      jugadorId: j?.id,
      nombreReal: entrada.key,
      enActivo: j != null && !j.retirado,
      pts: real.puntos + (j == null ? 0 : puntosSim[j.id] ?? 0),
      ast: real.asistencias + (j == null ? 0 : asistenciasSim[j.id] ?? 0),
      reb: real.rebotes + (j == null ? 0 : rebotesSim[j.id] ?? 0),
    ));
  }

  // 2) Los que solo existen en tu partida: rookies de tus drafts y demás
  //    gente sin carrera NBA real detrás.
  for (final j in jugadores) {
    if (j.nombreReal.isNotEmpty && reales.containsKey(j.nombreReal)) continue;
    final pts = puntosSim[j.id] ?? 0;
    final ast = asistenciasSim[j.id] ?? 0;
    final reb = rebotesSim[j.id] ?? 0;
    if (pts == 0 && ast == 0 && reb == 0) continue;
    filas.add((
      nombre: j.nombreFicticio,
      jugadorId: j.id,
      nombreReal: j.nombreReal,
      enActivo: !j.retirado,
      pts: pts,
      ast: ast,
      reb: reb,
    ));
  }

  List<LiderHistorico> ordenarPor(int Function(_FilaLider) valor) {
    final copia = [...filas]..sort((a, b) {
        final porValor = valor(b).compareTo(valor(a));
        // Desempate por nombre para que el orden no baile entre aperturas.
        return porValor != 0 ? porValor : a.nombre.compareTo(b.nombre);
      });
    return copia
        .where((f) => valor(f) > 0)
        .take(top)
        .map((f) => LiderHistorico(
              nombre: f.nombre,
              jugadorId: f.jugadorId,
              nombreReal: f.nombreReal,
              enActivo: f.enActivo,
              total: valor(f),
            ))
        .toList();
  }

  return LideresHistoricos(
    puntos: ordenarPor((f) => f.pts),
    asistencias: ordenarPor((f) => f.ast),
    rebotes: ordenarPor((f) => f.reb),
  );
}
