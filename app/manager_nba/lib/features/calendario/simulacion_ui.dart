import 'dart:math';

import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/estilo.dart';

import '../../data/database/app_database.dart';
import '../../domain/allstar_repository.dart';
import '../../domain/calendario_repository.dart';
import '../../domain/lesiones_repository.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/ofertas_repository.dart';
import '../../domain/tipo_evento_temporada.dart';
import '../../domain/tipo_premio.dart';
import '../../shared/campeon_dialog.dart';
import '../allstar/allstar_screen.dart';
import '../../domain/entrenadores_repository.dart';
import '../../domain/eventos_narrativos_repository.dart';
import '../mercado/agencia_libre_screen.dart';
import '../mercado/entrenador_screen.dart';
import '../temporada/evento_narrativo_dialog.dart';
import '../mercado/ofertas_screen.dart';
import '../mercado/traspasos_screen.dart';
import '../partido/serie_boxscores_screen.dart';

/// Una lesión que sigue activa al terminar el lote simulado (a diferencia
/// de `NuevaLesion`, que incluye también a quien ya se recuperó a mitad).
class LesionActivaInfo {
  final String nombreJugador;
  final String motivo;
  final int partidosEstimados;
  final DateTime vuelve;

  const LesionActivaInfo({
    required this.nombreJugador,
    required this.motivo,
    required this.partidosEstimados,
    required this.vuelve,
  });
}

class ResultadoLoteSimulado {
  final List<PartidoSimuladoInfo> partidos;
  final List<LesionActivaInfo> lesionesActivas;
  final bool temporadaTerminada;

  const ResultadoLoteSimulado({
    required this.partidos,
    required this.lesionesActivas,
    required this.temporadaTerminada,
  });
}

/// El primer partido pendiente (para el botón "Simular 1 partido").
DateTime? proximaFechaPendiente(List<PartidosCalendarioData> partidos) {
  final pendientes = partidos.where((p) => !p.jugado).toList()
    ..sort((a, b) => a.fecha.compareTo(b.fecha));
  return pendientes.isEmpty ? null : pendientes.first.fecha;
}

/// Cuántos partidos tuyos quedan por jugar hasta [diaObjetivo] inclusive.
/// Es lo que decide cuántos segmentos pinta la barra de progreso antes de
/// arrancar la simulación: hace falta saberlo de antemano, porque la barra
/// se construye con el total ya fijo y se va rellenando encima.
int partidosPendientesHasta(
        List<PartidosCalendarioData> partidos, DateTime diaObjetivo) =>
    partidos.where((p) => !p.jugado && !p.fecha.isAfter(diaObjetivo)).length;

/// La fecha "actual" de tu temporada: el último partido jugado, o el
/// primero programado si todavía no has jugado ninguno.
DateTime fechaActualDeLaTemporada(List<PartidosCalendarioData> partidos) {
  final jugados = partidos.where((p) => p.jugado).toList();
  if (jugados.isEmpty) return partidos.first.fecha;
  return jugados.map((p) => p.fecha).reduce((a, b) => a.isAfter(b) ? a : b);
}

/// ¿Ha llegado ya la fecha del All-Star, mirando hasta [hasta]?
///
/// Suelto y público para poder probarlo: es donde estaba el bug, y montar
/// un diálogo entero para comprobar una comparación de fechas no compensa.
bool allStarYaAlcanzado(
  List<EventosTemporadaData> eventosAllStar,
  DateTime hasta,
) =>
    eventosAllStar.any((e) => !e.fecha.isAfter(hasta));

/// Plantea un evento de vestuario si toca, y aplica lo que se decida.
///
/// El evento se apunta como "ya visto" solo al resolverlo (ver
/// `resolverEvento`), así que si la app se cierra con el diálogo abierto no
/// se pierde: vuelve a salir.
Future<void> _plantearEventoNarrativo(
  BuildContext context,
  AppDatabase db,
  String equipoUsuario,
  int partidosSimulados, {
  Random? random,
}) async {
  final evento = await eventoQueSalta(db,
      equipoUsuario: equipoUsuario,
      partidosSimulados: partidosSimulados,
      random: random);
  if (evento == null || !context.mounted) return;

  final opcion = await plantearEvento(context, evento);
  if (opcion == null) return;

  await resolverEvento(db, evento, opcion);
  if (!context.mounted) return;
  await contarConsecuencia(context, evento, opcion);
}

/// Si el banquillo está vacío, lleva a la pantalla de entrenadores y no
/// deja seguir hasta que haya alguien. Devuelve si se puede jugar.
///
/// Está aquí y no en el Calendario porque hay dos caminos que simulan
/// (`CalendarioScreen` y `ResumenSimulacionScreen`) y el aviso tiene que
/// salir en los dos.
Future<bool> _asegurarQueHayEntrenador(
  BuildContext context,
  AppDatabase db,
  String equipoUsuario,
) async {
  if (await leerEntrenadorDe(db, equipoUsuario) != null) return true;
  if (!context.mounted) return false;
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (context) => EntrenadorScreen(
      db: db,
      equipoUsuario: equipoUsuario,
      onContinuar: () => Navigator.of(context).pop(),
    ),
  ));
  if (!context.mounted) return false;
  return await leerEntrenadorDe(db, equipoUsuario) != null;
}

/// Simula hasta [diaObjetivo] (pausando en fechas límite sin resolver, con
/// opción de ir a Traspasos) y arma un resumen listo para pintar. Lo usan
/// tanto `CalendarioScreen` como `ResumenSimulacionScreen`, para no
/// duplicar esta lógica.
Future<ResultadoLoteSimulado> simularHastaConDialogo(
  BuildContext context,
  AppDatabase db,
  String equipoUsuario,
  DateTime diaObjetivo, {
  /// Se llama después de cada tramo simulado (la simulación avanza por
  /// semanas, ver más abajo), con todo lo simulado hasta ese momento. Es
  /// lo que alimenta la barra de progreso segmentada: no hay enganche al
  /// motor para saber cuándo se resuelve cada partido suelto, así que la
  /// granularidad real es "por semana", no "por partido".
  void Function(List<PartidoSimuladoInfo> hastaAhora)? onProgreso,

  /// El azar de lo que pasa MIENTRAS simulas: si te llega una oferta de
  /// traspaso y si salta un evento de vestuario. En el juego se deja a
  /// null, que es lo que da una partida distinta cada vez.
  ///
  /// Los tests lo siembran. No es un capricho: las dos cosas que decide
  /// abren un diálogo y **paran la simulación esperando respuesta**, y en
  /// un test no hay nadie que conteste, así que el juego se queda ahí
  /// parado para siempre. Con el reloj de por medio eso pasaba unas veces
  /// sí y otras no, que es de donde salían los tests inestables.
  ///
  /// El resultado de los partidos NO depende de esto: cada partido lleva
  /// su semilla guardada en la tabla del calendario (`seedA`/`seedB`), así
  /// que simular es reproducible por su cuenta.
  Random? random,
}) async {
  // Nada de simular con el banquillo vacío. Si acabas de despedir a tu
  // entrenador, aquí se te manda a buscar uno antes de seguir: es el mismo
  // listón que la plantilla mínima, y va a la agencia DE ENTRENADORES, no
  // a la de jugadores.
  if (!await _asegurarQueHayEntrenador(context, db, equipoUsuario)) {
    return const ResultadoLoteSimulado(
      partidos: [],
      lesionesActivas: [],
      temporadaTerminada: false,
    );
  }

  final acumulados = <PartidoSimuladoInfo>[];
  final lesionesAcumuladas = <NuevaLesion>[];
  var temporadaTerminada = false;
  var finalDeCopaYaAvisada = false;
  var campeonDeCopaYaAvisado = false;
  var allStarYaAvisado = false;
  int? ignorar;
  DateTime? ultimaFechaSimulada;

  // La simulación no se come el tramo entero de una tacada: avanza por
  // etapas de una semana. Es lo que permite que una oferta que llega en
  // noviembre te pare en noviembre —y no al final de todo, cuando ya no
  // puedes hacer nada con ella— sin dejar de ser un único "simular hasta".
  const pasoDeParada = Duration(days: 7);
  DateTime? cursor;
  var interrumpidoPorOferta = false;

  while (true) {
    // Meta de esta etapa: como mucho una semana más allá de donde íbamos,
    // y nunca más allá del día que pediste.
    final metaParcial = cursor == null || !cursor.add(pasoDeParada).isBefore(diaObjetivo)
        ? diaObjetivo
        : cursor.add(pasoDeParada);

    final tramo = await simularTramo(
      db,
      equipoUsuario,
      metaParcial,
      eventoIdAIgnorar: ignorar,
    );
    acumulados.addAll(tramo.simulados);
    lesionesAcumuladas.addAll(tramo.lesionesNuevas);
    if (tramo.temporadaRegularTerminada) temporadaTerminada = true;
    onProgreso?.call(List.unmodifiable(acumulados));

    // Se avisa en la misma etapa en la que ocurre (como con las ofertas más
    // abajo), no al final de todo el lote: si simulas "hasta fin de mes" y
    // la Cup se decide en la primera semana, antes te enterabas tres
    // semanas tarde, cuando ya no quedaba nada que hacer con el aviso.
    final finalDeCopaProgramada = tramo.novedadesCopa.finalDelUsuario;
    if (finalDeCopaProgramada != null && !finalDeCopaYaAvisada) {
      finalDeCopaYaAvisada = true;
      if (context.mounted) {
        await _avisarFinalDeCopaProgramada(context, finalDeCopaProgramada);
      }
    }
    final campeonDeCopa = tramo.novedadesCopa.campeon;
    if (campeonDeCopa != null && !campeonDeCopaYaAvisado) {
      campeonDeCopaYaAvisado = true;
      if (context.mounted) {
        await _avisarCampeonDeCopa(context, db, campeonDeCopa,
            tramo.novedadesCopa.serieIdFinal, equipoUsuario);
      }
    }
    // El fin de semana de las estrellas, en la etapa en la que cae. Antes
    // se miraba al final del lote entero, así que simulando "hasta el final
    // de la temporada" el All-Star de febrero te saltaba en abril, pegado a
    // los premios y sin nada que ver ya.
    //
    // Se le pasa la META de la etapa y NO los partidos que se han jugado en
    // ella. Ver el porqué en _avisarSiHuboAllStar: mirar los partidos era
    // justamente lo que hacía que el aviso no saliera nunca.
    if (context.mounted && !allStarYaAvisado) {
      allStarYaAvisado = await _avisarSiHuboAllStar(context, db, metaParcial);
    }

    // Los eventos de vestuario, en la etapa en la que caen y como mucho uno
    // por etapa. Igual que las ofertas: pararte en noviembre por algo que
    // pasa en noviembre, no soltarte cuatro diálogos seguidos al final de
    // un "simular hasta el final de temporada".
    if (context.mounted && tramo.simulados.isNotEmpty) {
      await _plantearEventoNarrativo(
          context, db, equipoUsuario, tramo.simulados.length,
          random: random);
    }

    if (tramo.simulados.isNotEmpty) {
      final maxFecha = tramo.simulados
          .map((p) => p.fecha)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      if (ultimaFechaSimulada == null || maxFecha.isAfter(ultimaFechaSimulada)) {
        ultimaFechaSimulada = maxFecha;
      }
    }
    cursor = ultimaFechaSimulada ?? metaParcial;

    // Los rivales se mueven mientras juegas: se generan aquí, etapa a
    // etapa, y no al final del lote.
    if (tramo.simulados.isNotEmpty) {
      await generarOfertasEntrantes(
        db,
        equipoUsuario: equipoUsuario,
        partidosSimulados: tramo.simulados.length,
        fecha: cursor,
        random: random,
      );
      if (await ofertasSinVer(db) > 0) {
        if (!context.mounted) break;
        // Una oferta encima de la mesa para la simulación: se decide y
        // después se sigue desde donde estábamos.
        await _avisarDeOfertasEntrantes(context, db, equipoUsuario);
        if (!context.mounted) break;
        interrumpidoPorOferta = true;
      }
    }

    if (tramo.eventoBloqueante == null) {
      // Si la etapa se quedó corta porque tocaba parar a mirar una oferta,
      // o simplemente porque era una semana intermedia, se sigue.
      final quedaCamino = cursor.isBefore(diaObjetivo);
      if (quedaCamino && tramo.simulados.isNotEmpty) continue;
      break;
    }
    if (!context.mounted) break;
    final eventoBloqueante = tramo.eventoBloqueante!;
    final esAgenciaLibre = esFechaLimiteDeAgenciaLibre(eventoBloqueante);
    final seguir = await _mostrarDialogoDeadline(context, eventoBloqueante);
    if (seguir != true) {
      if (context.mounted) {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => esAgenciaLibre
              ? AgenciaLibreScreen(db: db, equipoUsuario: equipoUsuario)
              : TraspasosScreen(db: db, equipoUsuario: equipoUsuario),
        ));
      }
      break;
    }
    ignorar = eventoBloqueante.id;
  }

  // El All-Star, la Final de la Cup y el campeón ya se han avisado etapa a
  // etapa dentro del bucle, igual que las ofertas.
  // Las ofertas ya se han ido generando y avisando etapa a etapa dentro del
  // bucle; aquí solo se repesca lo que hubiera quedado sin mirar (por
  // ejemplo si el tramo terminó justo con una recién llegada).
  if (context.mounted && !interrumpidoPorOferta) {
    await _avisarDeOfertasEntrantes(context, db, equipoUsuario);
  }

  // No hace falta avisar aquí de que la temporada regular terminó: quien
  // llama a esta función (CalendarioScreen, ResumenSimulacionScreen)
  // encadena directamente a PremiosScreen usando el flag `temporadaTerminada`
  // del resultado devuelto.

  final lesionesActivas = <LesionActivaInfo>[];
  if (lesionesAcumuladas.isNotEmpty && ultimaFechaSimulada != null) {
    final activasEnDb = await lesionesActivasEn(db, ultimaFechaSimulada);
    final idsNuevosYActivos = lesionesAcumuladas
        .map((l) => l.jugadorId)
        .toSet()
        .intersection(activasEnDb.keys.toSet());
    if (idsNuevosYActivos.isNotEmpty) {
      final jugadores = await (db.select(db.jugadores)
            ..where((t) => t.id.isIn(idsNuevosYActivos)))
          .get();
      final nombresPorId = {for (final j in jugadores) j.id: j.nombreFicticio};
      for (final id in idsNuevosYActivos) {
        final lesion = activasEnDb[id]!;
        lesionesActivas.add(LesionActivaInfo(
          nombreJugador: nombresPorId[id] ?? '?',
          motivo: lesion.motivo,
          partidosEstimados: lesion.partidosEstimados,
          vuelve: lesion.fechaFin,
        ));
      }
    }
  }

  return ResultadoLoteSimulado(
    partidos: acumulados,
    lesionesActivas: lesionesActivas,
    temporadaTerminada: temporadaTerminada,
  );
}

/// Si hay ofertas sin mirar, te lo dice y te lleva a verlas. Igual que con
/// el campeón de la Cup, no hay que salir del calendario para nada.
Future<void> _avisarDeOfertasEntrantes(
  BuildContext context,
  AppDatabase db,
  String equipoUsuario,
) async {
  final sinVer = await ofertasSinVer(db);
  if (sinVer == 0 || !context.mounted) return;

  final verlas = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t(context).ofertaTitulo(sinVer)),
      content: Text(t(context).ofertaMensaje(sinVer)),
      actions: [
        BotonDialogoSecundario(
          texto: t(context).masTarde,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BotonDialogoPrincipal(
          texto: t(context).verOfertaBoton(sinVer),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  // Ya te hemos avisado: se marcan como vistas pase lo que pase, también si
  // dices "más tarde". La oferta NO se descarta —sigue en la bandeja hasta
  // que la aceptes o la rechaces—, solo deja de interrumpir.
  //
  // Sin esto, aplazar una oferta significaba que el aviso volvía a saltar en
  // cada tramo que simulabas, con las mismas tres propuestas de siempre, y
  // además cortaba la simulación cada vez. Desde fuera se ve exactamente
  // como "me llegan ofertas sin parar", aunque el tope de 3 por temporada
  // esté funcionando (medido: 3, 3 y 3 en las tres primeras temporadas).
  await marcarOfertasComoVistas(db);

  if (verlas == true && context.mounted) {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => OfertasScreen(
        db: db,
        equipoUsuario: equipoUsuario,
        cierraSolaAlVaciarse: true,
      ),
    ));
  }
}

/// ¿Es esta fecha límite la de la agencia libre? Es lo que decide, tanto
/// en el título del diálogo como en a qué pantalla lleva "no sigo
/// simulando": antes ese botón llevaba siempre a Traspasos, aunque la
/// fecha límite cruzada fuera la de agencia libre.
bool esFechaLimiteDeAgenciaLibre(EventosTemporadaData evento) =>
    TipoEventoTemporada.desdeNombre(evento.tipo) ==
    TipoEventoTemporada.finAgenciaLibre;

Future<bool?> _mostrarDialogoDeadline(
  BuildContext context,
  EventosTemporadaData evento,
) {
  final esAgenciaLibre = esFechaLimiteDeAgenciaLibre(evento);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(esAgenciaLibre
          ? t(context).tituloEventoFinAgenciaLibre
          : t(context).tituloEventoFechaLimiteTraspasos),
      content: Text(t(context).preguntaSeguirSimulando),
      actions: [
        BotonDialogoSecundario(
          texto: esAgenciaLibre
              ? t(context).irAAgenciaLibre
              : t(context).irATraspasos,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BotonDialogoPrincipal(
          texto: t(context).seguirSimulando,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}

/// Si el tramo simulado se ha cruzado con el fin de semana de las
/// estrellas, se juega el All-Star (Este vs Oeste con los 10 mejores de
/// cada conferencia según lo que están haciendo esta temporada) y se avisa,
/// dando a elegir entre ver el partido o seguir a lo tuyo.
///
/// Devuelve true si el fin de semana ya ha pasado en este tramo, para que
/// quien llama no vuelva a mirarlo en las etapas siguientes.
Future<bool> _avisarSiHuboAllStar(
  BuildContext context,
  AppDatabase db,
  DateTime hasta,
) async {
  final eventos = await leerEventos(db);
  final allStar = eventos
      .where((e) => e.tipo == TipoEventoTemporada.allStar.name)
      .toList();
  if (allStar.isEmpty) return false;

  // ¿Ha llegado ya su fecha? Y ojo con cómo se pregunta esto.
  //
  // Antes se miraba si la fecha del All-Star caía entre el primer y el
  // último partido JUGADO en esta etapa, y por eso el aviso dejó de salir:
  // el All-Star es precisamente el fin de semana en el que NO se juega.
  // Desde que la simulación avanza por etapas de siete días, el parón cae
  // entero en el hueco entre los partidos de una etapa y los de la
  // siguiente, así que no quedaba dentro del rango de ninguna de las dos y
  // no lo detectaba nadie. Y si una etapa caía toda dentro del parón, la
  // lista de partidos venía vacía y se salía por la primera línea.
  //
  // Ahora se compara con la META de la etapa, que avanza aunque no se
  // juegue nada.
  if (!allStarYaAlcanzado(allStar, hasta)) return false;

  // Ya jugado = ya se avisó en otra tanda (o la partida viene de antes de
  // este arreglo). Se devuelve true para no volver a mirarlo, pero sin
  // sacar un aviso de algo que el usuario ya vio.
  if (await leerBoxscoreAllStar(db) != null) return true;

  // El fin de semana entero: primero los jóvenes, luego las estrellas.
  await jugarRisingStarsSiHaceFalta(db);
  final boxscore = await jugarAllStarSiHaceFalta(db);
  if (!context.mounted) return true;

  if (boxscore == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t(context).allStarWeekendMayus),
    ));
    return true;
  }

  final mvp = await mvpDeLaTemporada(db, TipoPremio.mvpAllStar);
  if (!context.mounted) return true;

  final ganaEste = boxscore.marcadorLocal > boxscore.marcadorVisitante;
  final verPartido = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t(context).allStarWeekendMayus),
      content: Text(t(context).resultadoAllStar(
        esteGana: ganaEste,
        local: boxscore.marcadorLocal,
        visitante: boxscore.marcadorVisitante,
        mvp: mvp?.nombreFicticio,
      )),
      actions: [
        BotonDialogoSecundario(
          texto: t(context).seguirSimulando,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BotonDialogoPrincipal(
          texto: t(context).verFinDeSemana,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if (verPartido == true && context.mounted) {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => AllStarScreen(db: db),
    ));
  }
  return true;
}

/// Has llegado a la Final de la NBA Cup: se te programa como un día más de
/// tu calendario, así que no hay que ir a ningún menú aparte.
///
/// Va en una barra abajo y no en un diálogo a propósito: es una FECHA que
/// apuntar, no una decisión. Un diálogo a pantalla completa que hay que
/// cerrar a mano para enterarte de que tienes un partido el día 14 corta la
/// simulación por nada — el aviso gordo se guarda para el campeón, que sí
/// es un acontecimiento.
Future<void> _avisarFinalDeCopaProgramada(
  BuildContext context,
  DateTime fecha,
) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 6),
    content: Text(t(context).finalCupProgramada(_fechaCorta(context, fecha))),
  ));
}

/// Ya hay campeón de la NBA Cup (lo hayas ganado tú o no): se anuncia y se
/// puede abrir el boxscore de esa Final sin salir del calendario.
Future<void> _avisarCampeonDeCopa(
  BuildContext context,
  AppDatabase db,
  String campeon,
  int? serieId,
  String equipoUsuario,
) async {
  final temporada = await leerTemporada(db);
  if (!context.mounted) return;
  final verEstadisticas = await mostrarCampeonDecidido(
    context,
    true,
    campeon,
    // La Cup no da anillo: es un título de diciembre.
    daAnillo: false,
    esTuEquipo: campeon == equipoUsuario,
    temporada: etiquetaDeTemporada(temporada.anioInicio),
    etiquetaAccionExtra: serieId == null ? null : t(context).verEstadisticas,
  );

  if (verEstadisticas && serieId != null && context.mounted) {
    await abrirEstadisticasDeSerie(context, db,
        origen: 'torneo', serieId: serieId);
  }
}

String _fechaCorta(BuildContext context, DateTime f) =>
    t(context).fechaCorta(f.day, f.month);

