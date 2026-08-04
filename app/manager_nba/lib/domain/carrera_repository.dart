import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'tipo_premio.dart';

/// Un tramo de la carrera de un jugador en un mismo equipo: de qué
/// temporada a qué temporada estuvo y qué hizo allí.
class EtapaEnEquipo {
  final String equipo;
  final int desdeTemporada;
  final int hastaTemporada;
  final int partidos;
  final int puntos;
  final int asistencias;
  final int rebotes;

  const EtapaEnEquipo({
    required this.equipo,
    required this.desdeTemporada,
    required this.hastaTemporada,
    required this.partidos,
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
  });

  int get temporadas => hastaTemporada - desdeTemporada + 1;
  double get puntosPorPartido => partidos == 0 ? 0 : puntos / partidos;
  double get asistenciasPorPartido => partidos == 0 ? 0 : asistencias / partidos;
  double get rebotesPorPartido => partidos == 0 ? 0 : rebotes / partidos;
}

/// La carrera completa de un jugador: sus etapas, sus totales y sus
/// trofeos. Se construye desde `HistorialEstadisticasJugador` (una fila por
/// temporada jugada), así que solo cubre temporadas ya cerradas.
class CarreraJugador {
  final int jugadorId;
  final String nombre;
  final String nombreReal;
  final String posicion;
  final List<EtapaEnEquipo> etapas;
  final int partidos;
  final int puntos;
  final int asistencias;
  final int rebotes;
  final int mejorMedia;

  /// Temporadas jugadas antes de que empezara tu partida, y lo que valen de
  /// cara al Hall of Fame. Las medias de arriba solo cubren lo simulado: de
  /// lo anterior el juego no tiene estadísticas, solo el rastro.
  final int temporadasPrevias;
  final double prestigioPrevio;

  /// Su producción de referencia por partido, la del dataset con el que
  /// arranca la partida. Es lo único que se sabe de lo que hizo antes de que
  /// tú llegaras: no hay boxscores de aquellos años, así que se enseña como
  /// lo que es —una referencia— y no mezclada con lo simulado.
  final double ptsPgReferencia;
  final double astPgReferencia;
  final double trbPgReferencia;

  /// Cuántas veces ganó cada premio individual.
  final Map<TipoPremio, int> premios;

  /// En qué temporadas (número de la partida, no año real) ganó cada
  /// premio — para poder mostrarlo junto al premio en la ficha.
  final Map<TipoPremio, List<int>> premiosPorTemporada;

  /// Temporadas en las que fue campeón de la NBA y de la NBA Cup.
  final List<int> anillos;
  final List<int> copas;

  const CarreraJugador({
    required this.jugadorId,
    required this.nombre,
    required this.nombreReal,
    required this.posicion,
    required this.etapas,
    required this.partidos,
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
    required this.mejorMedia,
    required this.temporadasPrevias,
    required this.prestigioPrevio,
    required this.ptsPgReferencia,
    required this.astPgReferencia,
    required this.trbPgReferencia,
    required this.premios,
    this.premiosPorTemporada = const {},
    required this.anillos,
    required this.copas,
  });

  /// ¿Tiene carrera anterior a tu partida? Los rookies que se han hecho en
  /// tu liga, no; las estrellas que ya estaban, sí.
  bool get vieneDeAntes => temporadasPrevias > 0;

  /// ¿Se ha jugado algo suyo dentro de tu partida?
  bool get tieneTemporadasSimuladas => etapas.isNotEmpty;

  int get temporadas => etapas.fold(0, (a, e) => a + e.temporadas);

  /// Temporadas de toda su vida deportiva, contando las anteriores a tu
  /// partida.
  int get temporadasTotales => temporadas + temporadasPrevias;
  double get puntosPorPartido => partidos == 0 ? 0 : puntos / partidos;
  double get asistenciasPorPartido => partidos == 0 ? 0 : asistencias / partidos;
  double get rebotesPorPartido => partidos == 0 ? 0 : rebotes / partidos;

  int vecesGano(TipoPremio tipo) => premios[tipo] ?? 0;
  List<int> temporadasDeGano(TipoPremio tipo) =>
      premiosPorTemporada[tipo] ?? const [];
}

/// Reconstruye la carrera de [jugadorId]. Devuelve null si no llegó a jugar
/// ninguna temporada completa (un rookie que se retira el mismo año, por
/// ejemplo).
Future<CarreraJugador?> leerCarrera(AppDatabase db, int jugadorId) =>
    _leerCarrera(db, jugadorId, exigirTemporadasSimuladas: true);

/// La carrera tal y como se enseña en su ficha: igual que [leerCarrera],
/// pero sin exigir que se haya jugado nada dentro de tu partida.
///
/// Hace falta para las leyendas reales: si Chris Paul se retira en tu
/// primera temporada, el juego no tiene ni un año archivado suyo, pero su
/// carrera existe — y tocar su camiseta retirada tiene que llevar a algún
/// sitio, no a una pantalla vacía.
Future<CarreraJugador?> leerCarreraParaFicha(AppDatabase db, int jugadorId) =>
    _leerCarrera(db, jugadorId, exigirTemporadasSimuladas: false);

/// Las carreras de un montón de jugadores de golpe, para las pantallas que
/// enseñan una lista larga (el Hall of Fame, sin ir más lejos, son 155
/// leyendas reales más las que hayas creado tú).
///
/// Existe por una razón de peso: pedir la carrera de uno en uno cuesta
/// cuatro consultas por jugador —y una de ellas recorre el palmarés
/// entero—, así que una lista de 155 se comía más de 600 consultas cada
/// vez que se repintaba. Eso saturaba la única conexión de la base de datos
/// y dejaba colgada no solo esa pantalla, sino cualquier otra que estuviera
/// pidiendo datos a la vez. Aquí son cuatro consultas en total, se agrupe a
/// quien se agrupe.
///
/// Los ids negativos (leyendas reales previas a tu partida, ver
/// `legado_historico_repository.dart`) no llegan a consultarse: no hay
/// ningún jugador simulado detrás, así que nunca tendrán carrera.
Future<Map<int, CarreraJugador>> leerCarrerasParaFichas(
  AppDatabase db,
  Iterable<int> jugadorIds,
) async {
  final ids = jugadorIds.where((id) => id >= 0).toSet().toList();
  if (ids.isEmpty) return {};

  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.id.isIn(ids)))
      .get();
  if (jugadores.isEmpty) return {};

  final temporadas = await (db.select(db.historialEstadisticasJugador)
        ..where((t) => t.jugadorId.isIn(ids))
        ..orderBy([(t) => OrderingTerm.asc(t.temporada)]))
      .get();
  final premios = await (db.select(db.historialPremios)
        ..where((t) => t.jugadorId.isIn(ids)))
      .get();
  final campeonatos = await db.select(db.historialCampeones).get();

  final temporadasPorJugador = <int, List<TemporadaDeCarrera>>{};
  for (final t in temporadas) {
    temporadasPorJugador.putIfAbsent(t.jugadorId, () => []).add(t);
  }
  final premiosPorJugador = <int, List<PremioHistorico>>{};
  for (final p in premios) {
    premiosPorJugador.putIfAbsent(p.jugadorId, () => []).add(p);
  }

  return {
    for (final jugador in jugadores)
      jugador.id: _ensamblarCarrera(
        jugador,
        temporadasPorJugador[jugador.id] ?? const [],
        premiosPorJugador[jugador.id] ?? const [],
        campeonatos,
      ),
  };
}

Future<CarreraJugador?> _leerCarrera(
  AppDatabase db,
  int jugadorId, {
  required bool exigirTemporadasSimuladas,
}) async {
  final jugador = await (db.select(db.jugadores)
        ..where((t) => t.id.equals(jugadorId)))
      .getSingleOrNull();
  if (jugador == null) return null;

  final temporadas = await (db.select(db.historialEstadisticasJugador)
        ..where((t) => t.jugadorId.equals(jugadorId))
        ..orderBy([(t) => OrderingTerm.asc(t.temporada)]))
      .get();
  if (temporadas.isEmpty && exigirTemporadasSimuladas) return null;

  final premiosGanados = await (db.select(db.historialPremios)
        ..where((t) => t.jugadorId.equals(jugadorId)))
      .get();
  final campeonatos = await db.select(db.historialCampeones).get();

  return _ensamblarCarrera(jugador, temporadas, premiosGanados, campeonatos);
}

/// Monta la carrera con los datos ya leídos. Sin tocar la base: es lo que
/// permite que [leerCarrerasParaFichas] resuelva muchas de una tacada.
/// [temporadas] tiene que venir ordenada por temporada ascendente.
CarreraJugador _ensamblarCarrera(
  Jugador jugador,
  List<TemporadaDeCarrera> temporadas,
  List<PremioHistorico> premiosGanados,
  List<Campeonato> campeonatos,
) {
  // Etapas: se agrupan temporadas consecutivas en el mismo equipo (si
  // vuelve años después, son dos etapas distintas).
  final etapas = <EtapaEnEquipo>[];
  for (final t in temporadas) {
    final ultima = etapas.isEmpty ? null : etapas.last;
    if (ultima != null &&
        ultima.equipo == t.equipo &&
        ultima.hastaTemporada == t.temporada - 1) {
      etapas[etapas.length - 1] = EtapaEnEquipo(
        equipo: ultima.equipo,
        desdeTemporada: ultima.desdeTemporada,
        hastaTemporada: t.temporada,
        partidos: ultima.partidos + t.partidosJugados,
        puntos: ultima.puntos + t.puntosTotales,
        asistencias: ultima.asistencias + t.asistenciasTotales,
        rebotes: ultima.rebotes + t.rebotesTotales,
      );
    } else {
      etapas.add(EtapaEnEquipo(
        equipo: t.equipo,
        desdeTemporada: t.temporada,
        hastaTemporada: t.temporada,
        partidos: t.partidosJugados,
        puntos: t.puntosTotales,
        asistencias: t.asistenciasTotales,
        rebotes: t.rebotesTotales,
      ));
    }
  }

  final premios = <TipoPremio, int>{};
  final premiosPorTemporada = <TipoPremio, List<int>>{};
  for (final p in premiosGanados) {
    final tipo = TipoPremio.desdeNombre(p.tipo);
    premios[tipo] = (premios[tipo] ?? 0) + 1;
    premiosPorTemporada.putIfAbsent(tipo, () => []).add(p.temporada);
  }
  for (final lista in premiosPorTemporada.values) {
    lista.sort();
  }

  // Un anillo cuenta si el jugador estaba en ese equipo esa temporada.
  final equipoPorTemporada = {
    for (final t in temporadas) t.temporada: t.equipo,
  };
  final anillos = <int>[];
  final copas = <int>[];
  for (final c in campeonatos) {
    if (equipoPorTemporada[c.temporada] != c.equipo) continue;
    (c.tipo == 'nba' ? anillos : copas).add(c.temporada);
  }

  return CarreraJugador(
    jugadorId: jugador.id,
    nombre: jugador.nombreFicticio,
    nombreReal: jugador.nombreReal,
    posicion: jugador.posicion,
    etapas: etapas,
    partidos: temporadas.fold(0, (a, t) => a + t.partidosJugados),
    puntos: temporadas.fold(0, (a, t) => a + t.puntosTotales),
    asistencias: temporadas.fold(0, (a, t) => a + t.asistenciasTotales),
    rebotes: temporadas.fold(0, (a, t) => a + t.rebotesTotales),
    mejorMedia: temporadas.isEmpty
        ? jugador.media
        : temporadas.map((t) => t.media).reduce((a, b) => a > b ? a : b),
    temporadasPrevias: jugador.temporadasPrevias,
    prestigioPrevio: jugador.prestigioPrevio,
    ptsPgReferencia: jugador.ptsPg,
    astPgReferencia: jugador.astPg,
    trbPgReferencia: jugador.trbPg,
    premios: premios,
    premiosPorTemporada: premiosPorTemporada,
    anillos: anillos..sort(),
    copas: copas..sort(),
  );
}

/// Cuántas temporadas lleva cada jugador en la liga: las que ya tenía
/// jugadas cuando empezó tu partida más las que se han jugado dentro de
/// ella.
///
/// Hace falta porque `temporadasPrevias` es un dato congelado: se escribe
/// al importar el dataset y no lo toca nadie más. Filtrar por esa columna
/// tal cual significa que quien entró como rookie en tu temporada 1 sigue
/// contando como rookie para siempre — que es justo lo que hacía que el
/// Rising Stars repitiera jugadores año tras año.
///
/// Ojo: se cuentan las temporadas con estadísticas archivadas, así que
/// alguien que no llegara a jugar ni un minuto en todo un año no la suma.
/// Para lo que se usa esto (elegir a los mejores jóvenes) da igual: nadie
/// así entra en una convocatoria.
Future<Map<int, int>> experienciaEnLaLiga(AppDatabase db) async {
  final jugadores = await db.select(db.jugadores).get();
  final historial = await db.select(db.historialEstadisticasJugador).get();

  final temporadasPorJugador = <int, Set<int>>{};
  for (final h in historial) {
    temporadasPorJugador.putIfAbsent(h.jugadorId, () => {}).add(h.temporada);
  }

  return {
    for (final j in jugadores)
      j.id: j.temporadasPrevias + (temporadasPorJugador[j.id]?.length ?? 0),
  };
}

/// Archiva las estadísticas de la temporada [temporada] que acaba de
/// cerrarse, para que sigan disponibles cuando se borre el año en curso.
Future<void> archivarEstadisticasDeTemporada(
  AppDatabase db,
  int temporada,
) async {
  final estadisticas = await db.select(db.estadisticasTemporadaJugador).get();
  if (estadisticas.isEmpty) return;

  final jugadores = await db.select(db.jugadores).get();
  final porId = {for (final j in jugadores) j.id: j};

  await db.batch((batch) {
    batch.insertAll(
      db.historialEstadisticasJugador,
      estadisticas
          .where((e) => porId.containsKey(e.jugadorId))
          .map((e) => HistorialEstadisticasJugadorCompanion.insert(
                temporada: temporada,
                jugadorId: e.jugadorId,
                equipo: porId[e.jugadorId]!.equipo,
                media: porId[e.jugadorId]!.media,
                partidosJugados: e.partidosJugados,
                puntosTotales: e.puntosTotales,
                asistenciasTotales: e.asistenciasTotales,
                rebotesTotales: e.rebotesTotales,
              )),
    );
  });
}
