import 'dart:math';

import 'package:drift/drift.dart';

import '../data/calendario/generador_calendario.dart';
import '../data/database/app_database.dart';
import 'agencia_libre_repository.dart';
import 'camisetas_repository.dart';
import 'carrera_repository.dart';
import 'contratos_repository.dart';
import 'dorsales_repository.dart';
import 'entrenadores_repository.dart';
import 'leyendas.dart';
import 'draft_repository.dart';
import 'equipos_especiales.dart';
import 'eventos_narrativos_repository.dart' show limpiarEventosDeLaTemporada;
import 'forma_repository.dart';
import 'franquicia_repository.dart';
import 'hall_fama_repository.dart';
import 'legado_real_repository.dart';
import 'ofertas_repository.dart';
import 'progresion_repository.dart';
import 'traspasos_cpu_repository.dart';

/// Qué ha pasado en el paso de una temporada a la siguiente, para poder
/// contárselo al usuario en la pantalla de pretemporada.
class ResumenPretemporada {
  final int temporadaNueva;
  final int anioInicio;


  /// Retirados de tu equipo y del resto de la liga (los tuyos primero).
  final List<CambioDeJugador> retiradosPropios;
  final List<CambioDeJugador> retiradosLiga;

  /// Los que más han crecido y los que más han bajado de tu plantilla.
  final List<CambioDeJugador> progresanTuyos;
  final List<CambioDeJugador> declinanTuyos;

  /// Rookies que te ha dado el draft, y las mejores elecciones de la liga.
  final List<RookieElegido> tusRookies;
  final List<RookieElegido> mejoresDelDraft;

  /// Los que acaban de entrar en el Hall of Fame con esta hornada de
  /// retiradas.
  final List<MiembroHallDeLaFama> nuevosEnHallDeLaFama;

  /// Los intercambios que han cerrado entre ellos los equipos de la CPU.
  final List<TraspasoDeLaCpu> traspasosDeLaLiga;

  /// La temporada que se acaba de cerrar (la de las retiradas), que es la
  /// que hay que apuntar al retirar una camiseta.
  final int temporadaCerrada;

  const ResumenPretemporada({
    required this.temporadaNueva,
    required this.anioInicio,
    required this.retiradosPropios,
    required this.retiradosLiga,
    required this.progresanTuyos,
    required this.declinanTuyos,
    required this.tusRookies,
    required this.mejoresDelDraft,
    required this.nuevosEnHallDeLaFama,
    required this.temporadaCerrada,
    this.traspasosDeLaLiga = const [],
  });

  /// Todos los retirados del año, los tuyos primero.
  List<CambioDeJugador> get retiradosDelAno =>
      [...retiradosPropios, ...retiradosLiga];
}

/// La temporada en curso (número y año natural de inicio). Si aún no hay
/// fila —franquicias creadas antes de existir esta tabla— se asume la 1.
Future<TemporadaData> leerTemporada(AppDatabase db) async {
  final fila =
      await (db.select(db.temporada)..where((t) => t.id.equals(0))).getSingleOrNull();
  if (fila != null) return fila;

  final partidos = await (db.select(db.partidosCalendario)..limit(1)).get();
  final anio = partidos.isEmpty
      ? proximoInicioDeTemporada().year
      : partidos.first.fecha.year;
  await db.into(db.temporada).insertOnConflictUpdate(
        TemporadaCompanion.insert(
            id: const Value(0), numero: const Value(1), anioInicio: anio),
      );
  return (db.select(db.temporada)..where((t) => t.id.equals(0))).getSingle();
}

/// Cómo se nombra una temporada que arranca en [anioInicio]: "2027-28".
String etiquetaDeTemporada(int anioInicio) {
  final siguiente = (anioInicio + 1) % 100;
  return '$anioInicio-${siguiente.toString().padLeft(2, '0')}';
}

/// La etiqueta de año ("25-26") de la temporada [numero], calculada a
/// partir de [actual] — número y año de inicio avanzan juntos, uno por año,
/// así que basta con la distancia entre los dos números. Para cualquier
/// sitio que solo tenga guardado el NÚMERO de temporada (todo lo histórico:
/// premios, camisetas retiradas...) y necesite mostrar el año real.
String etiquetaTemporadaDesde(TemporadaData actual, int numero) =>
    etiquetaDeTemporada(anioDeTemporadaDesde(actual, numero));

/// El año en el que arrancó la temporada [numero] de tu partida. Lo mismo
/// que [etiquetaTemporadaDesde] pero en número, para poder ordenar y
/// comparar etapas con las de la carrera real.
int anioDeTemporadaDesde(TemporadaData actual, int numero) =>
    actual.anioInicio - (actual.numero - numero);

/// ¿Se puede ya pasar de año? Solo cuando la Final NBA tiene ganador: hasta
/// entonces queda temporada por jugar.
Future<bool> sePuedeEmpezarNuevaTemporada(AppDatabase db) async {
  final finalNba = await (db.select(db.seriesPlayoffs)
        ..where((t) => t.conferencia.equals('Final')))
      .getSingleOrNull();
  return finalNba?.ganador != null;
}

/// Lo que sabe el cierre de temporada y necesita después la pretemporada.
/// El paso intermedio es el draft, que puedes jugar tú (ver
/// draft_repository.dart), así que hay que poder partir el proceso en dos.
class CierreDeTemporada {
  final String equipoUsuario;
  final int temporadaCerrada;
  final int anioDraft;
  final List<CambioDeJugador> cambios;
  final List<MiembroHallDeLaFama> nuevosEnHallDeLaFama;

  /// Las camisetas que las 29 franquicias de la CPU han colgado este verano.
  /// Pasaba en silencio: se enteraba uno meses después, entrando en Legado.
  final List<CamisetaRetirada> nuevasCamisetasRetiradas;

  /// El baile de banquillos del verano: quién se retira, a quién echan y
  /// quién le sustituye.
  final List<MovimientoDeEntrenador> movimientosDeEntrenadores;

  const CierreDeTemporada({
    required this.equipoUsuario,
    required this.temporadaCerrada,
    required this.anioDraft,
    required this.cambios,
    required this.nuevosEnHallDeLaFama,
    this.nuevasCamisetasRetiradas = const [],
    this.movimientosDeEntrenadores = const [],
  });

  List<CambioDeJugador> get retirados =>
      cambios.where((c) => c.seRetira).toList();
}

/// Primer paso del cambio de año: archiva la temporada que termina,
/// envejece a toda la liga (retiradas, progresión y declive), evalúa quién
/// entra en el Hall of Fame y deja el draft listo para empezar.
///
/// No toca el calendario ni borra nada de la temporada: eso es
/// [finalizarPretemporada], que va después del draft.
Future<CierreDeTemporada> cerrarTemporada(
  AppDatabase db, {
  Random? random,
}) async {
  final rng = random ?? Random();
  final equipoUsuario = await leerEquipoFranquicia(db);
  if (equipoUsuario == null) {
    throw StateError('No hay franquicia activa que hacer avanzar de año');
  }

  final temporada = await leerTemporada(db);
  final ordenDeDraft = await _ordenDeDraft(db);

  // Ojo al orden: archivar tiene que ir antes de envejecer, porque guarda
  // el equipo y la media que tenía cada jugador *esta* temporada.
  await _archivarTemporada(db, temporada.numero);
  await archivarEstadisticasDeTemporada(db, temporada.numero);

  // Los jóvenes crecen con el entrenador que han tenido ESTE año, así que
  // se lee antes de que el verano mueva los banquillos de sitio.
  final desarrollo = {
    for (final e in await db.select(db.entrenadores).get())
      if (esFranquicia(e.equipo)) e.equipo: e.atrDesarrollo,
  };
  final cambios = await envejecerLiga(db,
      random: rng, desarrolloPorEquipo: desarrollo);
  final retirados = cambios.where((c) => c.seRetira).toList();

  // Y ahora sí, el baile de banquillos: retiradas, despidos de la CPU y
  // sustitutos. Va después de envejecer para que la plantilla que miran los
  // candidatos sea la del año que viene, no la que ya no existe.
  final movimientosDeEntrenadores = await pasarElVeranoDeLosEntrenadores(db,
      equipoUsuario: equipoUsuario, random: rng);

  final nuevosHof = await evaluarIngresosHallDeLaFama(
    db,
    jugadorIdsRetirados: retirados.map((c) => c.jugadorId).toList(),
    temporada: temporada.numero,
  );
  final camisetasAntes =
      (await db.select(db.camisetasRetiradas).get()).map((c) => c.id).toSet();
  await _retirarCamisetasDeLaCpu(db, retirados, equipoUsuario, temporada.numero);
  final nuevasCamisetas = (await db.select(db.camisetasRetiradas).get())
      .where((c) => !camisetasAntes.contains(c.id))
      .toList();

  // Contratos: se descuenta un año a todos y los 29 equipos de la CPU
  // resuelven sus vencimientos solos. Los tuyos se quedan pendientes de que
  // decidas tú en la pantalla de renovaciones.
  await descontarAnioDeContrato(db);
  await resolverVencimientosDeLaCpu(db,
      equipoUsuario: equipoUsuario, random: rng);

  await iniciarDraft(
    db,
    anioDraft: temporada.anioInicio + 1,
    ordenDeEleccion: ordenDeDraft,
    random: rng,
  );

  return CierreDeTemporada(
    equipoUsuario: equipoUsuario,
    temporadaCerrada: temporada.numero,
    anioDraft: temporada.anioInicio + 1,
    cambios: cambios,
    nuevosEnHallDeLaFama: nuevosHof,
    nuevasCamisetasRetiradas: nuevasCamisetas,
    movimientosDeEntrenadores: movimientosDeEntrenadores,
  );
}

/// Último paso del cambio de año, ya con el draft resuelto: reparte
/// dorsales, borra todo lo que era "de esta temporada" (estadísticas,
/// lesiones, playoffs, NBA Cup, calendario), sortea el estado de forma
/// nuevo, genera el calendario del año siguiente y te deja una alineación
/// automática hecha (tu rotación anterior puede tener retirados).
Future<ResumenPretemporada> finalizarPretemporada(
  AppDatabase db,
  CierreDeTemporada cierre,
  List<RookieElegido> rookies, {
  Random? random,
}) async {
  final rng = random ?? Random();
  final equipoUsuario = cierre.equipoUsuario;
  final cambios = cierre.cambios;
  final retirados = cierre.retirados;

  await finalizarDraft(db, random: rng);

  // Lo que siga sin contrato a estas alturas se va a la agencia libre, y
  // si con eso te quedas corto de plantilla se completa con lo que haya.
  final sinContrato = await contratosQueVencen(db, equipoUsuario);
  await mandarAAgenciaLibre(db, sinContrato.map((j) => j.id).toList());
  await completarPlantillaConElMinimo(db, equipoUsuario, random: rng);

  // Y los otros 29 hacen su mercado: sin esto soltaban gente cada verano y
  // no fichaban nunca, así que las estrellas se apilaban en la agencia
  // libre y la liga entera se degradaba temporada a temporada.
  //
  // Pero solo la primera ola: aquí se tapan agujeros de plantilla y nada
  // más. A los agentes libres de nivel no los toca nadie hasta que tú
  // cierres tu ventana de mercado (cerrarVentanaDeAgenciaLibre), que es lo
  // que hace que puedas ver —y fichar— a quien no renovaste.
  await completarPlantillasDeLaCpu(db,
      equipoUsuario: equipoUsuario,
      claseDelDraft: cierre.anioDraft,
      respetarTuVentana: true,
      random: rng);

  // Con el mercado ya cerrado se depura lo que ha quedado sin firmar: si
  // no, la agencia libre se queda cada año con el excedente del draft y
  // crece sin techo (ver depurarAgenciaLibre). Va aquí, después de que
  // todos hayan fichado, para no retirar a nadie que fuera a tener equipo.
  final sinMercado = await depurarAgenciaLibre(db);
  final hofSinMercado = await evaluarIngresosHallDeLaFama(
    db,
    jugadorIdsRetirados: sinMercado.map((j) => j.id).toList(),
    temporada: cierre.temporadaCerrada,
  );

  // La liga se mueve sola: los equipos de la CPU se intercambian piezas
  // entre ellos antes de que arranque el año. Va después del draft y de la
  // agencia libre, con las plantillas ya cerradas, para que nadie se quede
  // roto por un traspaso hecho sobre una foto vieja.
  final traspasosDeLaLiga =
      await ejecutarTraspasosDeLaCpu(db, equipoUsuario: equipoUsuario, random: rng);

  // Las ofertas de la temporada pasada ya no valen.
  await borrarOfertas(db);

  await asignarDorsalesQueFalten(db, random: rng);

  final temporada = await leerTemporada(db);
  final nuevoNumero = temporada.numero + 1;
  final nuevoAnio = temporada.anioInicio + 1;
  await _limpiarDatosDeTemporada(db);
  await sortearFormaDeTemporada(db, random: rng);
  await _generarTemporada(db, equipoUsuario, DateTime(nuevoAnio, 10, 22));

  await db.into(db.temporada).insertOnConflictUpdate(TemporadaCompanion.insert(
        id: const Value(0),
        numero: Value(nuevoNumero),
        anioInicio: nuevoAnio,
        // Sin poner esto a mano, insertOnConflictUpdate solo toca las
        // columnas presentes en el companion: el contador de ofertas de la
        // temporada anterior se quedaría tal cual, y el tope de la season
        // nueva nacería ya agotado.
        ofertasGeneradasEstaTemporada: const Value(0),
        // Y lo mismo con los eventos narrativos ya vistos: si no se
        // resetean aquí, el verano siguiente empezaría con la lista llena y
        // no saltaría ni uno en toda la temporada.
        eventosVistos: const Value(''),
      ));

  // Un verano entero borra cualquier bronca de vestuario y cualquier racha
  // de buen rollo: los efectos activos no cruzan de un año al siguiente.
  await limpiarEventosDeLaTemporada(db);

  // La rotación guardada puede apuntar a retirados o a gente que ya no
  // está en el equipo: se deja una válida hecha, editable como siempre.
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipoUsuario)))
      .get();
  await guardarRotacion(db, generarRotacionAutomatica(plantilla));

  final enActivo = cambios.where((c) => !c.seRetira).toList();

  // Quién es tuyo se mira en la plantilla de AHORA, ya cerrada la
  // pretemporada — no en el equipo que tenía cada uno cuando se calcularon
  // los cambios de media. Entre medias han pasado las renovaciones, la
  // agencia libre y los traspasos: sin esto, en tu resumen seguían saliendo
  // jugadores que no renovaron y ya no están en el equipo.
  final idsEnPlantilla = plantilla.map((j) => j.id).toSet();
  bool esTuyo(CambioDeJugador c) => idsEnPlantilla.contains(c.jugadorId);

  // Los retirados son la excepción: al colgar las botas dejan de estar en
  // ninguna plantilla, así que ahí sí vale el equipo en el que estaban.
  bool seRetiroSiendoTuyo(CambioDeJugador c) => c.equipo == equipoUsuario;

  return ResumenPretemporada(
    temporadaNueva: nuevoNumero,
    anioInicio: nuevoAnio,
    nuevosEnHallDeLaFama: [
      ...cierre.nuevosEnHallDeLaFama,
      ...hofSinMercado,
    ],
    temporadaCerrada: cierre.temporadaCerrada,
    traspasosDeLaLiga: traspasosDeLaLiga,
    retiradosPropios: retirados.where(seRetiroSiendoTuyo).toList(),
    retiradosLiga: retirados.where((c) => !seRetiroSiendoTuyo(c)).toList(),
    progresanTuyos:
        enActivo.where(esTuyo).where((c) => c.delta > 0).toList(),
    declinanTuyos: enActivo
        .where(esTuyo)
        .where((c) => c.delta < 0)
        .toList()
        .reversed
        .toList(),
    tusRookies: rookies.where((r) => r.equipo == equipoUsuario).toList(),
    mejoresDelDraft: rookies.take(5).toList(),
  );
}

/// Cierra tu ventana de mercado: los 29 equipos de la CPU salen a por lo que
/// no hayas fichado tú.
///
/// El verano va en dos olas a propósito. Durante la primera —dentro de
/// [finalizarPretemporada], antes de que veas la pantalla de agencia libre—
/// la CPU solo tapa agujeros de plantilla y tiene prohibido tocar a nadie de
/// nivel. Sin esa regla el mercado ya estaba barrido cuando te tocaba mirar:
/// la estrella a la que acababas de no renovar aparecía fichada por otro
/// equipo antes de que pudieras verla en la lista, y lo mejor que te
/// quedaba era gente de 75. Los buenos siguen sin quedarse en la calle todo
/// el año, pero ahora tú tienes el primer turno.
///
/// La depuración va aquí y no antes porque colocar a las estrellas obliga a
/// algún equipo a cortar a su duodécimo hombre: si se depurara antes, esos
/// cortados se quedarían en el mercado hasta el verano siguiente.
Future<void> cerrarVentanaDeAgenciaLibre(
  AppDatabase db, {
  required String equipoUsuario,
  required int temporadaCerrada,
  int? claseDelDraft,
  Random? random,
}) async {
  await completarPlantillasDeLaCpu(db,
      equipoUsuario: equipoUsuario,
      claseDelDraft: claseDelDraft,
      random: random);

  // Y tu equipo también llega al tamaño con el que juega la liga, con lo
  // que haya sobrado. Va DESPUÉS de la ola de la CPU a propósito: los
  // agentes libres de nivel ya se han repartido y aquí solo quedan restos
  // que se firman por el mínimo, así que esto no ficha por ti — solo
  // impide que salgas a jugar cinco hombres por debajo de tus 29 rivales.
  //
  // Sin esto tu plantilla se quedaba clavada en `plantillaMinima` (13)
  // mientras las 29 de la CPU acababan en `plantillaMaxima` (18), todos
  // los veranos. Medido sobre cuatro temporadas seguidas con la misma
  // semilla: 37-45, 19-63, 19-63 y 4-78, con la media de los ocho mejores
  // cayendo de 83,4 a 74,4 mientras la liga subía a 87.
  await completarPlantillaConElMinimo(db, equipoUsuario,
      hasta: plantillaMaxima, random: random);

  final sinMercado = await depurarAgenciaLibre(db);
  await evaluarIngresosHallDeLaFama(
    db,
    jugadorIdsRetirados: sinMercado.map((j) => j.id).toList(),
    temporada: temporadaCerrada,
  );

  // Y AHORA se rehace tu rotación, con el verano ya cerrado.
  //
  // `finalizarPretemporada` también la deja hecha, pero eso pasa antes de
  // que se abra la ventana de mercado: la plantilla de ese momento es la
  // peor del año —ya sin retirados ni contratos vencidos, y todavía sin un
  // solo fichaje—, así que todo lo que firmases después se quedaba fuera de
  // los diez que juegan. Medido: una estrella de media 89 recién fichada en
  // el banquillo mientras un 67 salía de titular. Y como los 29 equipos de
  // la CPU se realinean con lo mejor que tengan en cada partido, la
  // desventaja era solo tuya y se repetía cada verano — de ahí que un buen
  // equipo pudiera acabar último.
  final tuPlantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipoUsuario)))
      .get();
  if (tuPlantilla.length >= posicionesEquipo.length * 2) {
    await guardarRotacion(db, generarRotacionAutomatica(tuPlantilla));
  }
}

/// Cambio de año completo con el draft resuelto por la CPU de principio a
/// fin. Es el atajo: cuando el draft lo juegas tú, la pantalla encadena
/// [cerrarTemporada], las elecciones y [finalizarPretemporada].
Future<ResumenPretemporada> empezarNuevaTemporada(
  AppDatabase db, {
  Random? random,
}) async {
  final rng = random ?? Random();
  final cierre = await cerrarTemporada(db, random: rng);
  final rookies = await avanzarDraftHastaElTurnoDe(db, null);
  final resumen = await finalizarPretemporada(db, cierre, rookies, random: rng);
  // Sin pantalla de por medio no hay ventana de mercado que respetar: se
  // cierra aquí mismo para que la liga quede como si el verano entero
  // hubiera pasado.
  await cerrarVentanaDeAgenciaLibre(db,
      equipoUsuario: cierre.equipoUsuario,
      temporadaCerrada: cierre.temporadaCerrada,
      claseDelDraft: cierre.anioDraft,
      random: rng);
  return resumen;
}

/// Los equipos de la CPU también honran a sus leyendas: al retirarse un
/// jugador con carrera de Hall of Fame, su franquicia le retira la camiseta
/// automáticamente. La decisión solo se te pregunta a ti, para tu equipo.
///
/// Con una salvedad: las leyendas reales (ver `leyendas.dart`) las honra la
/// franquicia con la que hicieron historia, no la que las tuviera en
/// plantilla el último año. Y no se les exige currículum dentro del juego:
/// Chris Paul no necesita ganar nada en tu partida para que Nueva Orleans
/// le retire la camiseta — ya se la ganó antes de que tú llegaras.
Future<void> _retirarCamisetasDeLaCpu(
  AppDatabase db,
  List<CambioDeJugador> retirados,
  String equipoUsuario,
  int temporada,
) async {
  for (final c in retirados) {
    if (!esFranquicia(c.equipo)) continue;

    final jugador = await (db.select(db.jugadores)
          ..where((t) => t.id.equals(c.jugadorId)))
        .getSingleOrNull();

    // La franquicia real, decidida con su carrera NBA de verdad (Kaggle):
    // cubre 582 de los 641 jugadores del juego, no solo el puñado de
    // estrellas ya conocidas de franquiciasHistoricas.
    //
    // Y son todas las que le correspondan, no solo una: quien hizo historia
    // en tres sitios cuelga del techo en los tres.
    final historicasReales = jugador == null
        ? const <String>[]
        : await equiposQueRetiranCamisetaReal(jugador.nombreReal,
            preferido: c.equipo);
    if (historicasReales.isNotEmpty) {
      for (final equipo in historicasReales) {
        await retirarCamiseta(db,
            equipo: equipo, jugadorId: c.jugadorId, temporada: temporada);
      }
      continue;
    }

    // Lo que la carrera real no cubra (sin datos de Kaggle, o los casos ya
    // curados a mano antes de tener esos datos) sigue el camino de siempre.
    final historica = jugador == null
        ? null
        : franquiciaHistoricaDe(jugador.nombreReal, preferida: c.equipo);
    if (historica != null) {
      await retirarCamiseta(db,
          equipo: historica, jugadorId: c.jugadorId, temporada: temporada);
      continue;
    }

    // Del resto, la decisión es tuya para tu equipo y automática para la CPU.
    if (c.equipo == equipoUsuario) continue;
    final carrera = await leerCarrera(db, c.jugadorId);
    if (carrera == null) continue;
    if (puntuacionDeCarrera(carrera) < umbralHallDeLaFama) continue;
    await retirarCamiseta(db,
        equipo: c.equipo, jugadorId: c.jugadorId, temporada: temporada);
  }
}

/// Orden del draft: peor récord elige primero. Se calcula antes de tocar
/// nada, con la clasificación final de la temporada que termina.
Future<List<String>> _ordenDeDraft(AppDatabase db) async {
  final resultados = await db.select(db.resultadoTemporada).get();
  final ordenados = [...resultados]..sort((a, b) {
      double winPct(ResultadoTemporadaData r) {
        final total = r.victorias + r.derrotas;
        return total == 0 ? 0.0 : r.victorias / total;
      }

      final cmp = winPct(a).compareTo(winPct(b));
      return cmp != 0 ? cmp : a.equipo.compareTo(b.equipo);
    });
  return ordenados.map((r) => r.equipo).toList();
}

Future<void> _archivarTemporada(AppDatabase db, int numero) async {
  final resultados = await db.select(db.resultadoTemporada).get();
  final premios = await db.select(db.premiosTemporada).get();
  final jugadores = await db.select(db.jugadores).get();
  final porId = {for (final j in jugadores) j.id: j};

  await db.batch((batch) {
    batch.insertAll(
      db.historialTemporadaEquipo,
      resultados.map((r) => HistorialTemporadaEquipoCompanion.insert(
            temporada: numero,
            equipo: r.equipo,
            victorias: r.victorias,
            derrotas: r.derrotas,
          )),
    );
    batch.insertAll(
      db.historialPremios,
      premios.map((p) => HistorialPremiosCompanion.insert(
            temporada: numero,
            tipo: p.tipo,
            jugadorId: p.jugadorId,
            nombreJugador: porId[p.jugadorId]?.nombreFicticio ?? '?',
            equipo: porId[p.jugadorId]?.equipo ?? '?',
          )),
    );
  });
}

/// Borra todo lo que pertenece a la temporada que acaba de cerrarse. El
/// palmarés (`HistorialCampeones`) y los históricos nuevos no se tocan: son
/// justo lo que da sentido a una carrera larga.
Future<void> _limpiarDatosDeTemporada(AppDatabase db) async {
  await db.transaction(() async {
    await db.delete(db.estadisticasTemporadaJugador).go();
    await db.delete(db.resultadoTemporada).go();
    await db.delete(db.premiosTemporada).go();
    await db.delete(db.lesiones).go();
    await db.delete(db.seriesPlayoffs).go();
    await db.delete(db.seriesTorneo).go();
    await db.delete(db.boxscoresSerie).go();
    await db.delete(db.istTemporada).go();
    await db.delete(db.partidosCalendario).go();
    await db.delete(db.eventosTemporada).go();
    await db.delete(db.rotacionJugador).go();
  });
}

Future<void> _generarTemporada(
  AppDatabase db,
  String equipoUsuario,
  DateTime fechaInicio,
) async {
  final equiposQuery = db.selectOnly(db.jugadores)
    ..addColumns([db.jugadores.equipo])
    ..groupBy([db.jugadores.equipo]);
  final filas = await equiposQuery.get();
  final equipos = filas
      .map((f) => f.read(db.jugadores.equipo)!)
      .where(esFranquicia)
      .toList();

  final calendario = generarCalendarioLiga(
    equipoUsuario: equipoUsuario,
    equiposDisponibles: equipos,
    fechaInicio: fechaInicio,
  );

  await db.transaction(() async {
    await db.batch((batch) {
      batch.insertAll(db.partidosCalendario, calendario.partidos);
      batch.insertAll(db.eventosTemporada, calendario.eventos);
      batch.insertAll(
        db.resultadoTemporada,
        equipos.map((e) => ResultadoTemporadaCompanion.insert(equipo: e)),
      );
    });
  });
}
