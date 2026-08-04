import 'package:drift/drift.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/calendario/generador_calendario.dart';
import '../data/database/app_database.dart';
import '../features/partido/alineacion_automatica.dart';
import 'agencia_libre_repository.dart';
import 'fin_temporada_repository.dart';
import 'forma_repository.dart';
import 'franquicia_repository.dart';
import 'lesiones_repository.dart';
import 'tipo_evento_temporada.dart';
import 'torneo_repository.dart';

Future<List<PartidosCalendarioData>> leerPartidos(
  AppDatabase db,
  String equipoPropietario,
) {
  return (db.select(db.partidosCalendario)
        ..where((t) => t.equipoPropietario.equals(equipoPropietario))
        ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
      .get();
}

Future<List<EventosTemporadaData>> leerEventos(AppDatabase db) {
  return db.select(db.eventosTemporada).get();
}

bool _esFechaLimite(String tipo) =>
    tipo == TipoEventoTemporada.finAgenciaLibre.name ||
    tipo == TipoEventoTemporada.fechaLimiteTraspasos.name;

/// ¿Ya se ha pasado la fecha límite de [tipo] este año? El diálogo que
/// aparece AL cruzarla (ver simularTramo/simulacion_ui.dart) avisa, pero no
/// impedía nada después: si seguías simulando de largo, la agencia libre y
/// los traspasos se quedaban abiertos el resto de la temporada. Se compara
/// contra la fecha "actual": el último partido tuyo ya jugado, o el primero
/// programado si todavía no has jugado ninguno.
Future<bool> haPasadoFechaLimite(
  AppDatabase db,
  String equipoUsuario,
  TipoEventoTemporada tipo,
) async {
  final evento = await (db.select(db.eventosTemporada)
        ..where((t) => t.tipo.equals(tipo.name)))
      .getSingleOrNull();
  if (evento == null) return false;

  final partidos = await leerPartidos(db, equipoUsuario);
  if (partidos.isEmpty) return false;
  final jugados = partidos.where((p) => p.jugado);
  final fechaActual = jugados.isEmpty
      ? partidos.first.fecha
      : jugados.map((p) => p.fecha).reduce((a, b) => a.isAfter(b) ? a : b);

  return fechaActual.isAfter(evento.fecha);
}

/// Un partido ya simulado dentro de un tramo, con su boxscore completo.
/// Solo se genera para tus propios partidos (los del resto de la liga se
/// simulan igual, pero no hace falta devolverlos a la UI).
class PartidoSimuladoInfo {
  final DateTime fecha;
  final String rival;
  final bool esLocal;
  final sim.Boxscore boxscore;

  const PartidoSimuladoInfo({
    required this.fecha,
    required this.rival,
    required this.esLocal,
    required this.boxscore,
  });

  int get marcadorUsuario =>
      esLocal ? boxscore.marcadorLocal : boxscore.marcadorVisitante;
  int get marcadorRival =>
      esLocal ? boxscore.marcadorVisitante : boxscore.marcadorLocal;
}

/// Resultado de simular un tramo: los partidos tuyos que se llegaron a
/// jugar, y si el tramo se detuvo antes de [diaObjetivo] por una fecha
/// límite sin resolver ([eventoBloqueante] no nulo en ese caso).
class ResultadoTramo {
  final List<PartidoSimuladoInfo> simulados;
  final EventosTemporadaData? eventoBloqueante;

  /// true si con este tramo se acaba de completar tu temporada regular
  /// (82 partidos): ya hay premios calculados y playoffs sembrados.
  final bool temporadaRegularTerminada;

  /// Lesiones nuevas ocurridas a jugadores tuyos durante este tramo.
  final List<NuevaLesion> lesionesNuevas;

  /// Novedades de la NBA Cup ocurridas en este tramo: tu Final programada
  /// en el calendario, o el campeón recién coronado (ver
  /// torneo_repository.dart).
  final NovedadesCopa novedadesCopa;

  const ResultadoTramo({
    required this.simulados,
    this.eventoBloqueante,
    this.temporadaRegularTerminada = false,
    this.lesionesNuevas = const [],
    this.novedadesCopa = NovedadesCopa.ninguna,
  });
}

/// Simula todos los partidos pendientes hasta [diaObjetivo] inclusive —
/// tanto los tuyos como los del resto de la liga, para que la
/// clasificación se pueda consultar en cualquier momento — a no ser que se
/// cruce por el camino una fecha límite tuya (fin de agencia libre /
/// traspasos) todavía sin resolver, en cuyo caso se para justo ahí (esa
/// pausa solo aplica a tu calendario; el resto de la liga no tiene
/// traspasos que gestionar). Una fecha límite se considera resuelta si ya
/// hay algún partido tuyo jugado con fecha posterior a ella (o si su id es
/// [eventoIdAIgnorar], usado para continuar tras confirmar el aviso).
Future<ResultadoTramo> simularTramo(
  AppDatabase db,
  String equipoUsuario,
  DateTime diaObjetivo, {
  int? eventoIdAIgnorar,
}) async {
  final eventos = await leerEventos(db);
  final partidosJugadosUsuario = await (db.select(db.partidosCalendario)
        ..where((t) =>
            t.equipoPropietario.equals(equipoUsuario) & t.jugado.equals(true)))
      .get();

  bool yaResuelto(EventosTemporadaData e) =>
      partidosJugadosUsuario.any((p) => p.fecha.isAfter(e.fecha));

  final candidatos = eventos
      .where((e) => _esFechaLimite(e.tipo))
      .where((e) => !e.fecha.isAfter(diaObjetivo))
      .where((e) => e.id != eventoIdAIgnorar)
      .where((e) => !yaResuelto(e))
      .toList()
    ..sort((a, b) => a.fecha.compareTo(b.fecha));

  final eventoBloqueante = candidatos.isEmpty ? null : candidatos.first;
  final tope = eventoBloqueante?.fecha ?? diaObjetivo;

  final simuladosUsuario = <PartidoSimuladoInfo>[];
  final lesionesNuevas = <NuevaLesion>[];
  var campeonDeCopaAqui = false;

  await db.transaction(() async {
    final pendientesUsuario = await _pendientesDe(db, equipoUsuario, tope);
    for (final partido in pendientesUsuario) {
      // La Final de la NBA Cup vive en tu calendario como un día más, pero
      // no cuenta para el récord ni para las estadísticas: se juega por la
      // vía del torneo (ver torneo_repository.dart).
      if (partido.fase == faseFinalCopa) {
        final boxscore = await jugarFinalDeCopaDelCalendario(db, partido,
            equipoUsuario: equipoUsuario);
        if (boxscore != null) {
          simuladosUsuario.add(PartidoSimuladoInfo(
            fecha: partido.fecha,
            rival: partido.rival,
            esLocal: partido.esLocal,
            boxscore: boxscore,
          ));
          campeonDeCopaAqui = true;
        }
        continue;
      }

      final equipoPropio =
          await construirEquipoUsuarioParaFecha(db, equipoUsuario, partido.fecha);
      final resultado = await _simularYPersistir(db, partido, equipoPropio);
      simuladosUsuario.add(PartidoSimuladoInfo(
        fecha: partido.fecha,
        rival: partido.rival,
        esLocal: partido.esLocal,
        boxscore: resultado.boxscore,
      ));
      lesionesNuevas.addAll(resultado.lesiones);
    }

    final equiposQuery = db.selectOnly(db.resultadoTemporada)
      ..addColumns([db.resultadoTemporada.equipo]);
    final filasEquipos = await equiposQuery.get();
    final otrosEquipos = filasEquipos
        .map((f) => f.read(db.resultadoTemporada.equipo)!)
        .where((e) => e != equipoUsuario);

    for (final equipo in otrosEquipos) {
      final pendientes = await _pendientesDe(db, equipo, tope);
      for (final partido in pendientes) {
        final equipoPropio = await construirAutoParaFecha(
            db, equipo, partido.fecha);
        await _simularYPersistir(db, partido, equipoPropio);
      }
    }
  });

  // Cerrada tu ventana de mercado, la liga se reparte a los agentes libres
  // de nivel que sigan sin equipo. El dataset arranca con gente así ya en
  // la calle (un 88 y un 84 entre otros) y hasta ahora ese reparto solo
  // corría en verano: en la temporada 1 se pasaban el año entero sin
  // fichar por nadie. Va aquí, y no antes, para que el primer turno sea
  // siempre tuyo.
  final limiteAgencia = eventos
      .where((e) => e.tipo == TipoEventoTemporada.finAgenciaLibre.name)
      .firstOrNull;
  if (limiteAgencia != null && !tope.isBefore(limiteAgencia.fecha)) {
    await colocarAgentesLibresDeNivel(db, equipoUsuario: equipoUsuario);
  }

  // Fuera de la transacción: puede que dispare varias más (borrar/insertar
  // premios y series de playoffs) y no hace falta que formen parte de la
  // misma unidad atómica que la simulación de partidos.
  final temporadaTerminada =
      await cerrarTemporadaRegularSiToca(db, equipoUsuario);
  var novedadesCopa =
      await sembrarCuartosDeTorneoSiToca(db, equipoUsuario: equipoUsuario);

  // Si la Final que has jugado tú desde el calendario acaba de decidir el
  // título, el aviso del campeón sale por aquí.
  if (campeonDeCopaAqui) {
    final finalCopa = (await leerSeriesTorneo(db))
        .where((s) => s.conferencia == 'Final')
        .firstOrNull;
    if (finalCopa?.ganador != null) {
      novedadesCopa = NovedadesCopa(
        campeon: finalCopa!.ganador,
        serieIdFinal: finalCopa.id,
      );
    }
  }

  return ResultadoTramo(
    simulados: simuladosUsuario,
    eventoBloqueante: eventoBloqueante,
    temporadaRegularTerminada: temporadaTerminada,
    lesionesNuevas: lesionesNuevas,
    novedadesCopa: novedadesCopa,
  );
}

/// El "hoy" de tu partida: la fecha del último partido ya jugado de la
/// liga, o la del primero programado si todavía no se ha jugado ninguno.
/// Null si no hay calendario.
///
/// Todo lo que dependa de en qué momento de la temporada estamos —sobre
/// todo quién sigue lesionado— tiene que preguntar por aquí y NO por
/// `DateTime.now()`. Son dos calendarios distintos: la partida transcurre
/// en su propio año (octubre de 2026 en adelante en una partida nueva),
/// así que comparar una fecha de vuelta de lesión contra el reloj del
/// ordenador da respuestas sin sentido — una lesión que en el juego terminó
/// hace meses seguía contando como activa.
Future<DateTime?> fechaActualDeLaLiga(AppDatabase db) async {
  final ultimoJugado = await (db.select(db.partidosCalendario)
        ..where((t) => t.jugado.equals(true))
        ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
        ..limit(1))
      .getSingleOrNull();
  if (ultimoJugado != null) return ultimoJugado.fecha;

  final primero = await (db.select(db.partidosCalendario)
        ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
        ..limit(1))
      .getSingleOrNull();
  return primero?.fecha;
}

Future<List<PartidosCalendarioData>> _pendientesDe(
  AppDatabase db,
  String equipoPropietario,
  DateTime tope,
) {
  return (db.select(db.partidosCalendario)
        ..where((t) =>
            t.equipoPropietario.equals(equipoPropietario) &
            t.jugado.equals(false) &
            t.fecha.isSmallerOrEqualValue(tope))
        ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
      .get();
}

Future<sim.EquipoPartido> construirAutoParaFecha(
  AppDatabase db,
  String equipo,
  DateTime fecha,
) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo)))
      .get();
  final lesionados = await jugadoresFueraDeJuegoEn(db, fecha);
  final formas = await _formasConLesionLeve(db, fecha);
  return generarAlineacionAutomatica(equipo, plantilla,
      lesionadosIds: lesionados, formas: formas);
}

/// El estado de forma de la temporada combinado con la penalización de
/// lesión leve: quien tiene una lesión leve activa rinde peor ese partido
/// sin dejar de poder jugarlo (una grave sí le deja fuera, ver
/// [jugadoresFueraDeJuegoEn]).
Future<Map<int, double>> _formasConLesionLeve(
  AppDatabase db,
  DateTime fecha,
) async {
  final formas = await leerFormas(db);
  final penalizacionLeve = await factoresLesionLeveEn(db, fecha);
  if (penalizacionLeve.isEmpty) return formas;
  return {
    for (final id in {...formas.keys, ...penalizacionLeve.keys})
      id: (formas[id] ?? 1.0) * (penalizacionLeve[id] ?? 1.0),
  };
}

/// Simula un partido del calendario y persiste todo lo que cambia:
/// resultado del partido, récord del equipo dueño, estadísticas de
/// temporada de sus jugadores, y lesiones nuevas. El rival de este partido
/// concreto no se ve afectado (ver nota de diseño sobre calendarios
/// independientes en generador_calendario.dart).
Future<({sim.Boxscore boxscore, List<NuevaLesion> lesiones})>
    _simularYPersistir(
  AppDatabase db,
  PartidosCalendarioData partido,
  sim.EquipoPartido equipoPropietario,
) async {
  final plantillaRival = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(partido.rival)))
      .get();
  final lesionadosRival = await jugadoresFueraDeJuegoEn(db, partido.fecha);
  final formas = await _formasConLesionLeve(db, partido.fecha);
  final equipoRival = generarAlineacionAutomatica(partido.rival, plantillaRival,
      lesionadosIds: lesionadosRival, formas: formas);

  final local = partido.esLocal ? equipoPropietario : equipoRival;
  final visitante = partido.esLocal ? equipoRival : equipoPropietario;
  final boxscore = sim.simularPartido(local: local, visitante: visitante);

  final marcadorPropietario =
      partido.esLocal ? boxscore.marcadorLocal : boxscore.marcadorVisitante;
  final marcadorRival =
      partido.esLocal ? boxscore.marcadorVisitante : boxscore.marcadorLocal;
  final statsPropietario =
      partido.esLocal ? boxscore.statsLocal : boxscore.statsVisitante;

  await (db.update(db.partidosCalendario)
        ..where((t) => t.id.equals(partido.id)))
      .write(PartidosCalendarioCompanion(
    jugado: const Value(true),
    marcadorPropietario: Value(marcadorPropietario),
    marcadorRival: Value(marcadorRival),
  ));

  await actualizarResultadoTemporada(
      db, partido.equipoPropietario, marcadorPropietario >= marcadorRival);
  await actualizarEstadisticasJugadores(db, statsPropietario);
  final lesiones = await tirarLesionesPartido(
    db,
    statsPropietario.map((s) => int.parse(s.jugadorId)).toList(),
    partido.fecha,
  );

  return (boxscore: boxscore, lesiones: lesiones);
}

/// Suma una victoria o derrota más a [equipo]. Se usa tanto para partidos
/// normales de temporada regular como para los de cuartos/semifinal de la
/// NBA Cup (que también cuentan para el récord; ver torneo_repository.dart).
Future<void> actualizarResultadoTemporada(
  AppDatabase db,
  String equipo,
  bool gano,
) async {
  final actual = await (db.select(db.resultadoTemporada)
        ..where((t) => t.equipo.equals(equipo)))
      .getSingleOrNull();
  await db.into(db.resultadoTemporada).insertOnConflictUpdate(
        ResultadoTemporadaCompanion(
          equipo: Value(equipo),
          victorias: Value((actual?.victorias ?? 0) + (gano ? 1 : 0)),
          derrotas: Value((actual?.derrotas ?? 0) + (gano ? 0 : 1)),
        ),
      );
}

/// Suma los minutos/puntos/asistencias/rebotes de [stats] a los totales de
/// temporada de cada jugador. Misma nota que [actualizarResultadoTemporada]
/// sobre reutilización para cuartos/semifinal de la NBA Cup.
Future<void> actualizarEstadisticasJugadores(
  AppDatabase db,
  List<sim.EstadisticasJugador> stats,
) async {
  for (final s in stats) {
    final jugadorId = int.parse(s.jugadorId);
    final actual = await (db.select(db.estadisticasTemporadaJugador)
          ..where((t) => t.jugadorId.equals(jugadorId)))
        .getSingleOrNull();
    await db.into(db.estadisticasTemporadaJugador).insertOnConflictUpdate(
          EstadisticasTemporadaJugadorCompanion(
            jugadorId: Value(jugadorId),
            partidosJugados: Value((actual?.partidosJugados ?? 0) + 1),
            puntosTotales: Value((actual?.puntosTotales ?? 0) + s.puntos),
            asistenciasTotales:
                Value((actual?.asistenciasTotales ?? 0) + s.asistencias),
            rebotesTotales: Value((actual?.rebotesTotales ?? 0) + s.rebotes),
          ),
        );
  }
}
