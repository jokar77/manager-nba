import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'conferencias.dart';
import 'nueva_temporada_repository.dart';

/// Un partido de tu temporada ya jugado, con lo justo para listarlo.
class PartidoDelResumen {
  final int id;
  final DateTime fecha;
  final String rival;
  final bool esLocal;
  final int marcadorPropio;
  final int marcadorRival;

  const PartidoDelResumen({
    required this.id,
    required this.fecha,
    required this.rival,
    required this.esLocal,
    required this.marcadorPropio,
    required this.marcadorRival,
  });

  bool get ganado => marcadorPropio > marcadorRival;
  int get diferencia => marcadorPropio - marcadorRival;
}

/// Una fila de la tabla de jugadores del resumen: sus promedios del año.
class JugadorDelResumen {
  final int jugadorId;
  final String nombre;
  final String posicion;
  final int media;
  final int partidosJugados;
  final double puntos;
  final double asistencias;
  final double rebotes;

  const JugadorDelResumen({
    required this.jugadorId,
    required this.nombre,
    required this.posicion,
    required this.media,
    required this.partidosJugados,
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
  });
}

/// Una fila de la clasificación general: cómo terminó un equipo el año.
///
/// Al cerrar la temporada, lo que interesa no es repasar tus 82 partidos
/// uno a uno —eso ya lo has visto según se jugaban— sino ver dónde has
/// quedado respecto a los otros 29.
class EquipoEnLaClasificacion {
  final String equipo;
  final String conferencia;
  final int victorias;
  final int derrotas;

  const EquipoEnLaClasificacion({
    required this.equipo,
    required this.conferencia,
    required this.victorias,
    required this.derrotas,
  });

  int get jugados => victorias + derrotas;
  double get porcentaje => jugados == 0 ? 0 : victorias / jugados;
}

/// Todo lo que pasó en tu temporada regular, de una sola lectura.
class ResumenDeTemporada {
  final String etiquetaTemporada;
  final int numeroTemporada;
  final int victorias;
  final int derrotas;
  final String conferencia;
  final int puestoEnConferencia;
  final int puestoEnLaLiga;
  final double puntosFavorPorPartido;
  final double puntosContraPorPartido;
  final int mejorRachaGanando;
  final int peorRachaPerdiendo;
  final PartidoDelResumen? mejorVictoria;
  final PartidoDelResumen? peorDerrota;
  final List<PartidoDelResumen> partidos;
  final List<JugadorDelResumen> jugadores;

  /// Los 30 equipos ordenados de mejor a peor porcentaje.
  final List<EquipoEnLaClasificacion> clasificacion;

  const ResumenDeTemporada({
    required this.etiquetaTemporada,
    required this.numeroTemporada,
    required this.victorias,
    required this.derrotas,
    required this.conferencia,
    required this.puestoEnConferencia,
    required this.puestoEnLaLiga,
    required this.puntosFavorPorPartido,
    required this.puntosContraPorPartido,
    required this.mejorRachaGanando,
    required this.peorRachaPerdiendo,
    required this.mejorVictoria,
    required this.peorDerrota,
    required this.partidos,
    required this.jugadores,
    required this.clasificacion,
  });

  int get partidosJugados => victorias + derrotas;
  double get diferenciaPorPartido =>
      puntosFavorPorPartido - puntosContraPorPartido;
}

/// Reúne el resumen de la temporada regular de [equipoUsuario]: su récord y
/// su puesto, los 82 partidos con su resultado y los promedios de cada
/// jugador de la plantilla.
///
/// Solo cuenta la fase regular: los partidos de playoffs y la Final de la
/// NBA Cup viven en el mismo calendario pero no son parte de este balance
/// (la Cup ni siquiera cuenta para el récord, ver simularTramo).
Future<ResumenDeTemporada> leerResumenDeTemporada(
  AppDatabase db,
  String equipoUsuario,
) async {
  final todos = await (db.select(db.partidosCalendario)
        ..where((t) => t.fase.equals('regular') & t.jugado.equals(true))
        ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
      .get();

  final mios = <PartidoDelResumen>[];
  final victoriasPorEquipo = <String, int>{};
  final jugadosPorEquipo = <String, int>{};
  var puntosFavor = 0, puntosContra = 0;

  for (final p in todos) {
    if (p.marcadorPropietario == null || p.marcadorRival == null) continue;
    jugadosPorEquipo[p.equipoPropietario] =
        (jugadosPorEquipo[p.equipoPropietario] ?? 0) + 1;
    if (p.marcadorPropietario! > p.marcadorRival!) {
      victoriasPorEquipo[p.equipoPropietario] =
          (victoriasPorEquipo[p.equipoPropietario] ?? 0) + 1;
    }
    if (p.equipoPropietario != equipoUsuario) continue;

    puntosFavor += p.marcadorPropietario!;
    puntosContra += p.marcadorRival!;
    mios.add(PartidoDelResumen(
      id: p.id,
      fecha: p.fecha,
      rival: p.rival,
      esLocal: p.esLocal,
      marcadorPropio: p.marcadorPropietario!,
      marcadorRival: p.marcadorRival!,
    ));
  }

  final victorias = mios.where((p) => p.ganado).length;
  final derrotas = mios.length - victorias;

  // Puesto: por porcentaje de victorias, que es como se ordena una
  // clasificación de la NBA — no por victorias a secas, porque a mitad de
  // temporada no todos han jugado los mismos partidos.
  double porcentaje(String equipo) {
    final n = jugadosPorEquipo[equipo] ?? 0;
    return n == 0 ? 0 : (victoriasPorEquipo[equipo] ?? 0) / n;
  }

  final conferencia = conferenciaPorEquipo[equipoUsuario] ?? 'Oeste';
  int puestoEntre(Iterable<String> equipos) {
    final ordenados = equipos.toList()
      ..sort((a, b) {
        final porPorcentaje = porcentaje(b).compareTo(porcentaje(a));
        return porPorcentaje != 0 ? porPorcentaje : a.compareTo(b);
      });
    return ordenados.indexOf(equipoUsuario) + 1;
  }

  final deMiConferencia = jugadosPorEquipo.keys
      .where((e) => conferenciaPorEquipo[e] == conferencia);

  // Rachas: la más larga ganando y la más larga perdiendo, en orden de
  // calendario.
  var rachaGanando = 0, mejorRachaGanando = 0;
  var rachaPerdiendo = 0, peorRachaPerdiendo = 0;
  for (final p in mios) {
    if (p.ganado) {
      rachaPerdiendo = 0;
      rachaGanando++;
      if (rachaGanando > mejorRachaGanando) mejorRachaGanando = rachaGanando;
    } else {
      rachaGanando = 0;
      rachaPerdiendo++;
      if (rachaPerdiendo > peorRachaPerdiendo) {
        peorRachaPerdiendo = rachaPerdiendo;
      }
    }
  }

  PartidoDelResumen? extremo(bool ganados) {
    final candidatos = mios.where((p) => p.ganado == ganados).toList();
    if (candidatos.isEmpty) return null;
    candidatos.sort((a, b) => ganados
        ? b.diferencia.compareTo(a.diferencia)
        : a.diferencia.compareTo(b.diferencia));
    return candidatos.first;
  }

  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipoUsuario)))
      .get();
  final stats = {
    for (final s in await db.select(db.estadisticasTemporadaJugador).get())
      s.jugadorId: s,
  };
  final jugadores = <JugadorDelResumen>[];
  for (final j in plantilla) {
    final s = stats[j.id];
    final pj = s?.partidosJugados ?? 0;
    jugadores.add(JugadorDelResumen(
      jugadorId: j.id,
      nombre: j.nombreFicticio,
      posicion: j.posicion,
      media: j.media,
      partidosJugados: pj,
      puntos: pj == 0 ? 0 : s!.puntosTotales / pj,
      asistencias: pj == 0 ? 0 : s!.asistenciasTotales / pj,
      rebotes: pj == 0 ? 0 : s!.rebotesTotales / pj,
    ));
  }
  jugadores.sort((a, b) => b.puntos.compareTo(a.puntos));

  final temporada = await (db.select(db.temporada)
        ..where((t) => t.id.equals(0)))
      .getSingleOrNull();

  // La clasificación entera, con el mismo criterio que el puesto de arriba:
  // por porcentaje, y el nombre del equipo para desempatar de forma estable.
  final clasificacion = jugadosPorEquipo.keys
      .map((e) => EquipoEnLaClasificacion(
            equipo: e,
            conferencia: conferenciaPorEquipo[e] ?? 'Oeste',
            victorias: victoriasPorEquipo[e] ?? 0,
            derrotas: (jugadosPorEquipo[e] ?? 0) - (victoriasPorEquipo[e] ?? 0),
          ))
      .toList()
    ..sort((a, b) {
      final porPorcentaje = b.porcentaje.compareTo(a.porcentaje);
      return porPorcentaje != 0 ? porPorcentaje : a.equipo.compareTo(b.equipo);
    });

  return ResumenDeTemporada(
    etiquetaTemporada:
        temporada == null ? '' : etiquetaDeTemporada(temporada.anioInicio),
    numeroTemporada: temporada?.numero ?? 1,
    victorias: victorias,
    derrotas: derrotas,
    conferencia: conferencia,
    puestoEnConferencia: puestoEntre(deMiConferencia),
    puestoEnLaLiga: puestoEntre(jugadosPorEquipo.keys),
    puntosFavorPorPartido: mios.isEmpty ? 0 : puntosFavor / mios.length,
    puntosContraPorPartido: mios.isEmpty ? 0 : puntosContra / mios.length,
    mejorRachaGanando: mejorRachaGanando,
    peorRachaPerdiendo: peorRachaPerdiendo,
    mejorVictoria: extremo(true),
    peorDerrota: extremo(false),
    partidos: mios,
    jugadores: jugadores,
    clasificacion: clasificacion,
  );
}
