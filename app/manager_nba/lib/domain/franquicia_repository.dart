import 'dart:math';

import 'package:drift/drift.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/calendario/generador_calendario.dart';
import '../data/database/app_database.dart';
import 'agencia_libre_repository.dart';
import 'dorsales_repository.dart';
import 'entrenadores_repository.dart';
import 'equipos_especiales.dart';
import 'eventos_narrativos_repository.dart' show multiplicadorDeEventos;
import 'forma_repository.dart';
import 'jugador_mapping.dart';
import 'lesiones_repository.dart';
import 'picks_repository.dart';
import 'posiciones.dart';

// Media docena de sitios usan `posicionesEquipo` a través de este
// repositorio; se reexporta para no tener que tocar todos los imports.
export 'posiciones.dart' show posicionesEquipo;

/// Minutos por defecto del titular al generar una rotación (el suplente se
/// queda con el resto hasta 48).
const minutosPorDefectoTitular = 32;

/// Rellena los 10 huecos (titular+suplente x 5 puestos) con los mejores
/// jugadores de [plantilla] para cada puesto: primero los que lo tienen
/// como posición natural, si no quedan los que lo llevan como segunda
/// posición, y en último caso el mejor disponible aunque juegue fuera de
/// sitio. La usan tanto el botón "Alinear automáticamente" como la
/// generación de alineación de los equipos rivales/CPU.
List<RotacionJugadorCompanion> generarRotacionAutomatica(
  List<Jugador> plantilla,
) {
  final porPuesto = repartirPorPuestos(plantilla);

  // Las dos estrellas son los dos mejores de los que entran en la rotación,
  // igual que hace la CPU en cada uno de sus partidos (ver
  // generarAlineacionAutomatica). Sin esto tu equipo salía a la cancha SIN
  // estrellas mientras los otros 29 llevaban siempre las suyas: una
  // desventaja fija en los 82 partidos que hundía el récord por muy buena
  // que fuera la plantilla. Y como el cambio de temporada regenera la
  // rotación, las que hubieras marcado a mano se perdían cada año.
  final enRotacion = <Jugador>[];
  for (final posicion in posicionesEquipo) {
    final delPuesto = porPuesto[posicion]!;
    if (delPuesto.length < 2) continue;
    enRotacion.addAll([delPuesto[0], delPuesto[1]]);
  }
  final porMedia = [...enRotacion]..sort((a, b) => b.media.compareTo(a.media));
  final estrellaAtaqueId = porMedia.isNotEmpty ? porMedia[0].id : null;
  final estrellaDefensaId = porMedia.length > 1 ? porMedia[1].id : null;

  // El sexto hombre es el mejor SUPLENTE de la rotación, no el mejor de
  // todos: por definición no puede ser titular. Mismo motivo que las
  // estrellas de arriba — sin esto tu equipo sale sin sexto hombre mientras
  // los otros 29 llevan siempre el suyo (ver generarAlineacionAutomatica).
  final suplentes = <Jugador>[
    for (final posicion in posicionesEquipo)
      if (porPuesto[posicion]!.length >= 2) porPuesto[posicion]![1],
  ]..sort((a, b) => b.media.compareTo(a.media));
  final sextoHombreId = suplentes.isNotEmpty ? suplentes[0].id : null;

  final filas = <RotacionJugadorCompanion>[];
  for (final posicion in posicionesEquipo) {
    final delPuesto = porPuesto[posicion]!;
    if (delPuesto.length < 2) continue;

    filas.add(RotacionJugadorCompanion.insert(
      posicion: posicion,
      esTitular: true,
      jugadorId: delPuesto[0].id,
      minutos: minutosPorDefectoTitular,
      esEstrellaAtaque: Value(delPuesto[0].id == estrellaAtaqueId),
      esEstrellaDefensa: Value(delPuesto[0].id == estrellaDefensaId),
      // Explícito a false y no ausente: un titular nunca es sexto hombre,
      // pero dejarlo ausente en vez de puesto haría que leer `.value` de
      // esta fila reventara en vez de dar el false que le toca.
      esSextoHombre: const Value(false),
    ));
    filas.add(RotacionJugadorCompanion.insert(
      posicion: posicion,
      esTitular: false,
      jugadorId: delPuesto[1].id,
      minutos: 48 - minutosPorDefectoTitular,
      esEstrellaAtaque: Value(delPuesto[1].id == estrellaAtaqueId),
      esEstrellaDefensa: Value(delPuesto[1].id == estrellaDefensaId),
      esSextoHombre: Value(delPuesto[1].id == sextoHombreId),
    ));
  }

  return filas;
}

/// ¿Ya elegiste equipo? Si no hay franquicia, toca onboarding.
Future<String?> leerEquipoFranquicia(AppDatabase db) async {
  final fila = await (db.select(db.franquicia)
        ..where((t) => t.id.equals(0)))
      .getSingleOrNull();
  return fila?.equipo;
}

/// Borra la franquicia activa y todo su progreso (rotación, calendario,
/// lesiones, resultados, premios, playoffs, estado del torneo de mitad de
/// temporada) para poder elegir un equipo nuevo desde cero. `Ajustes` e
/// `HistorialCampeones` no se tocan: los títulos ganados quedan para
/// siempre, aunque cambies de equipo.
Future<void> nuevaFranquicia(AppDatabase db) async {
  await db.transaction(() async {
    await db.delete(db.franquicia).go();
    await db.delete(db.rotacionJugador).go();
    await db.delete(db.patrociniosActivos).go();
    await db.delete(db.partidosCalendario).go();
    await db.delete(db.eventosTemporada).go();
    await db.delete(db.lesiones).go();
    await db.delete(db.estadisticasTemporadaJugador).go();
    await db.delete(db.resultadoTemporada).go();
    await db.delete(db.premiosTemporada).go();
    await db.delete(db.seriesPlayoffs).go();
    await db.delete(db.istTemporada).go();
    await db.delete(db.seriesTorneo).go();
    await db.delete(db.boxscoresSerie).go();
    await db.delete(db.formaTemporadaJugador).go();
    await db.delete(db.temporada).go();
    await db.delete(db.historialTemporadaEquipo).go();
    await db.delete(db.historialPremios).go();
    await db.delete(db.historialEstadisticasJugador).go();
    // Las camisetas y el Hall of Fame de leyendas reales (jugadorId
    // negativo, ver legado_historico_repository.dart) son hechos del mundo
    // real, no logros de esta partida: sobreviven a empezar de cero. Solo
    // se borra lo que ganaron jugadores simulados de la partida anterior.
    await (db.delete(db.camisetasRetiradas)
          ..where((t) => t.jugadorId.isBiggerOrEqualValue(0)))
        .go();
    await (db.delete(db.hallDeLaFama)
          ..where((t) => t.jugadorId.isBiggerOrEqualValue(0)))
        .go();
    await db.delete(db.draftEnCurso).go();
    await db.delete(db.picksDraft).go();
    await db.delete(db.ofertasTraspaso).go();
  });
}

/// Guarda el equipo elegido y genera la temporada regular completa de los
/// 30 equipos (partidos + fechas especiales) — ver nota de diseño en
/// generador_calendario.dart sobre por qué cada equipo lleva su propio
/// calendario en vez de una liga entrelazada. No crea ninguna rotación
/// para el usuario: hay que configurarla a mano antes del primer partido.
///
/// Idempotente: si ya había datos de una temporada anterior (p. ej. una
/// franquicia previa que no se borró del todo, o esta función se dispara
/// dos veces por un doble tap en el menú de inicio) los limpia antes de
/// insertar, para no chocar con la clave única de `ResultadoTemporada`.
Future<void> crearFranquicia(AppDatabase db, String equipo) async {
  final equiposQuery = db.selectOnly(db.jugadores)
    ..addColumns([db.jugadores.equipo])
    ..groupBy([db.jugadores.equipo]);
  final filasEquipos = await equiposQuery.get();
  final equiposDisponibles =
      filasEquipos.map((f) => f.read(db.jugadores.equipo)!).toList();

  final calendario = generarCalendarioLiga(
    equipoUsuario: equipo,
    equiposDisponibles: equiposDisponibles,
  );

  final equiposReales =
      equiposDisponibles.where(esFranquicia).toSet().toList();

  await db.transaction(() async {
    await db.into(db.franquicia).insertOnConflictUpdate(
          FranquiciaCompanion.insert(id: const Value(0), equipo: equipo),
        );

    await db.delete(db.partidosCalendario).go();
    await db.delete(db.eventosTemporada).go();
    await db.delete(db.resultadoTemporada).go();

    await db.batch((batch) {
      batch.insertAll(db.partidosCalendario, calendario.partidos);
      batch.insertAll(db.eventosTemporada, calendario.eventos);
      batch.insertAll(
        db.resultadoTemporada,
        equiposReales
            .map((e) => ResultadoTemporadaCompanion.insert(equipo: e))
            .toList(),
      );
    });
  });

  // Estado de forma de la temporada: se sortea una vez por franquicia, y
  // es lo que hace que cada partida tenga sus propios MVP, defensor del
  // año y quintetos en vez de repetir siempre los mismos nombres.
  await sortearFormaDeTemporada(db);

  // Ojo: aquí NO se recortan las plantillas grandes. El dataset deja
  // equipos de 14 a 26 jugadores y recortarlos al tope mandaba a la
  // agencia libre a medio centenar de jugadores que en la vida real están
  // bajo contrato — la agencia libre del año 1 salía llena de gente que no
  // debería estar ahí. Los únicos agentes libres del año 1 son los que ya
  // venían marcados como tales en el dataset; a partir de la temporada 2
  // la agencia libre se llena sola con quien acaba contrato y no renueva.
  //
  // Arrancar con plantillas desiguales no desequilibra la liga: la fuerza
  // de un equipo sale de sus 5 mejores y la rotación es de 10, así que los
  // suplentes de más no aportan nada. El recorte al tope sigue existiendo
  // donde toca, en el cierre del draft de cada verano.
  //
  // Lo que sí hay que garantizar es el suelo. El dataset es una foto real de
  // la NBA, y una foto real no tiene por qué dar 30 plantillas jugables: al
  // actualizarlo contra 2kratings.com, con los agentes libres reales puestos
  // en 'FA', OKC y SAC se quedaban en 12 jugadores (el mínimo es
  // [plantillaMinima]) y a varios equipos les faltaba el segundo hombre en
  // algún puesto. Antes esto no se notaba porque el dataset venía con casi
  // todo el mundo colocado, pero depender de eso es frágil: cualquier
  // refresco de datos podía dejar la liga sin arrancar.
  //
  // Se completa desde la agencia libre, que es de donde saldrían de verdad,
  // y solo hasta el mínimo: a quien ya llega no se le toca.
  for (final equipoReal in equiposReales) {
    await completarPlantillaConElMinimo(db, equipoReal);
  }

  // A quien no tenga dorsal real se le reparte uno libre de su equipo.
  await asignarDorsalesQueFalten(db);

  // Arranca el reloj de la carrera: esta es la temporada 1.
  final anioInicio = calendario.partidos.first.fecha.value.year;
  await db.into(db.temporada).insertOnConflictUpdate(
        TemporadaCompanion.insert(
          id: const Value(0),
          numero: const Value(1),
          anioInicio: anioInicio,
        ),
      );

  // Y con él el mercado de picks: cada equipo arranca con sus dos
  // elecciones de los próximos drafts, todas suyas.
  await asegurarPicksFuturos(db,
      primerAnioDeDraft: anioInicio + 1, equipos: equiposReales);
}

/// Tu rotación actual (puede tener menos de 10 filas si aún no la has
/// completado).
Future<List<RotacionJugadorData>> leerRotacion(AppDatabase db) {
  return db.select(db.rotacionJugador).get();
}

/// Reemplaza la rotación guardada por [filas] (se espera que sean 10:
/// titular+suplente de cada uno de los 5 puestos).
Future<void> guardarRotacion(
  AppDatabase db,
  List<RotacionJugadorCompanion> filas,
) async {
  await db.transaction(() async {
    await db.delete(db.rotacionJugador).go();
    await db.batch((batch) {
      batch.insertAll(db.rotacionJugador, filas);
    });
  });
}

/// Arregla la rotación guardada después de un movimiento de plantilla a
/// mitad de temporada (un traspaso, un fichaje, una oferta aceptada).
///
/// Sin esto, traspasar a un titular dejaba la rotación apuntando a alguien
/// que ya no está en el equipo y el siguiente partido reventaba al montar la
/// alineación. Se conservan las filas que siguen siendo válidas —tus minutos
/// y tus roles de estrella no se tocan— y solo se rellenan los huecos con el
/// mejor disponible de cada puesto.
///
/// Devuelve true si ha tenido que cambiar algo.
Future<bool> repararRotacion(AppDatabase db, String equipoUsuario) async {
  final filas = await leerRotacion(db);
  if (filas.isEmpty) return false;

  final plantilla = await (db.select(db.jugadores)
        ..where((t) =>
            t.equipo.equals(equipoUsuario) & t.retirado.equals(false)))
      .get();
  final enPlantilla = plantilla.map((j) => j.id).toSet();

  final validas = filas.where((f) => enPlantilla.contains(f.jugadorId)).toList();
  if (validas.length == filas.length && rotacionEstaCompleta(filas)) {
    return false;
  }
  // Con menos de 10 jugadores no hay rotación posible; se deja como está y
  // ya se completará la plantilla en la agencia libre.
  if (plantilla.length < posicionesEquipo.length * 2) return false;

  final ordenados = [...plantilla]..sort((a, b) => b.media.compareTo(a.media));
  final usados = validas.map((f) => f.jugadorId).toSet();

  /// Lo que rinde [jugador] jugando de [posicion]: su media por el factor de
  /// comodidad, el mismo criterio que usa `repartirPorPuestos`.
  double rendimiento(Jugador jugador, String posicion) =>
      jugador.media * factorDePuesto(jugador, posicion);

  /// El mejor disponible para un puesto es el que más rinde en él, no el
  /// primero que lleve esa etiqueta. Mirar la etiqueta antes que el nivel
  /// dejaba a un 90 en el banquillo por delante de un 70 natural, cuando el
  /// motor solo penaliza un 10% por jugar fuera de sitio.
  Jugador mejorLibrePara(String posicion) {
    final libres = ordenados.where((j) => !usados.contains(j.id)).toList()
      ..sort((a, b) {
        final porRendimiento =
            rendimiento(b, posicion).compareTo(rendimiento(a, posicion));
        if (porRendimiento != 0) return porRendimiento;
        return a.id.compareTo(b.id);
      });
    return libres.first;
  }

  final nuevas = <RotacionJugadorCompanion>[];
  for (final posicion in posicionesEquipo) {
    RotacionJugadorData? previaDe(bool esTitular) {
      final filas = validas.where(
          (f) => f.posicion == posicion && f.esTitular == esTitular);
      return filas.isEmpty ? null : filas.first;
    }

    RotacionJugadorCompanion filaConservada(RotacionJugadorData f) =>
        RotacionJugadorCompanion.insert(
          posicion: f.posicion,
          esTitular: f.esTitular,
          jugadorId: f.jugadorId,
          minutos: f.minutos,
          esEstrellaAtaque: Value(f.esEstrellaAtaque),
          esEstrellaDefensa: Value(f.esEstrellaDefensa),
          esSextoHombre: Value(f.esSextoHombre),
        );

    // El titular y el suplente de un puesto siempre tienen que sumar 48
    // minutos. Si se sustituye solo uno de los dos (el otro sigue en la
    // plantilla y conserva sus minutos tal cual, que pueden no ser el
    // reparto por defecto), el sustituto tiene que recibir el complemento
    // exacto — no un valor fijo — o la rotación deja de sumar 240 y revienta
    // al montar la alineación del partido.
    final previaTitular = previaDe(true);
    final previaSuplente = previaDe(false);

    if (previaTitular != null && previaSuplente != null) {
      // Los dos siguen en el equipo: no se toca nada. Si has puesto de
      // titular a quien tú quieres, es cosa tuya.
      nuevas.add(filaConservada(previaTitular));
      nuevas.add(filaConservada(previaSuplente));
      continue;
    }

    if (previaTitular == null && previaSuplente == null) {
      // Puesto entero vacío: los dos mejores libres, el mejor de titular.
      for (final esTitular in [true, false]) {
        final sustituto = mejorLibrePara(posicion);
        usados.add(sustituto.id);
        nuevas.add(RotacionJugadorCompanion.insert(
          posicion: posicion,
          esTitular: esTitular,
          jugadorId: sustituto.id,
          minutos: esTitular
              ? minutosPorDefectoTitular
              : 48 - minutosPorDefectoTitular,
        ));
      }
      continue;
    }

    // Falta uno de los dos. Los minutos son del ROL, no de la persona: el
    // que se queda ya tenía los suyos y el que entra recibe el complemento
    // exacto, así el puesto sigue sumando 48.
    final conservada = previaTitular ?? previaSuplente!;
    final minutosTitular = previaTitular?.minutos ?? 48 - previaSuplente!.minutos;
    final sustituto = mejorLibrePara(posicion);
    usados.add(sustituto.id);

    // Y si el que entra rinde más que el que se queda, entra de TITULAR.
    // Antes el sustituto heredaba el hueco vacío tal cual, así que perder al
    // suplente de un puesto y fichar a un 87 lo sentaba detrás del 81 que ya
    // estaba: exactamente el bug de alineación que se repetía partida tras
    // partida aunque el botón de alinear funcionase bien.
    final quienSeQueda =
        plantilla.firstWhere((j) => j.id == conservada.jugadorId);
    final entraDeTitular = rendimiento(sustituto, posicion) >
        rendimiento(quienSeQueda, posicion);

    for (final esTitular in [true, false]) {
      final esElQueSeQueda = entraDeTitular != esTitular;
      nuevas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: esTitular,
        jugadorId: esElQueSeQueda ? conservada.jugadorId : sustituto.id,
        minutos: esTitular ? minutosTitular : 48 - minutosTitular,
        esEstrellaAtaque:
            Value(esElQueSeQueda && conservada.esEstrellaAtaque),
        esEstrellaDefensa:
            Value(esElQueSeQueda && conservada.esEstrellaDefensa),
        // Un sexto hombre nunca puede ser titular: si el que se queda pasa
        // a titular con este cambio, pierde la designación aquí en vez de
        // colársela a un puesto donde ya no tiene sentido.
        esSextoHombre:
            Value(esElQueSeQueda && !esTitular && conservada.esSextoHombre),
      ));
    }
  }

  await guardarRotacion(db, nuevas);
  return true;
}

/// Lo que hay que hacer después de cualquier movimiento de plantilla: dar
/// dorsal a quien acabe de llegar y dejar la rotación en pie. Es el punto
/// único por el que pasan traspasos, fichajes y ofertas aceptadas.
Future<void> sanearTrasMovimientoDePlantilla(
  AppDatabase db, {
  Random? random,
}) async {
  await asignarDorsalesQueFalten(db, random: random);
  final equipoUsuario = await leerEquipoFranquicia(db);
  if (equipoUsuario != null) await repararRotacion(db, equipoUsuario);
}

/// Una rotación válida tiene exactamente 10 filas: titular + suplente de
/// cada uno de los 5 puestos, todas con jugador asignado.
bool rotacionEstaCompleta(List<RotacionJugadorData> filas) {
  if (filas.length != posicionesEquipo.length * 2) return false;
  for (final posicion in posicionesEquipo) {
    final deEsePuesto = filas.where((f) => f.posicion == posicion);
    final tieneTitular = deEsePuesto.any((f) => f.esTitular);
    final tieneSuplente = deEsePuesto.any((f) => !f.esTitular);
    if (!tieneTitular || !tieneSuplente) return false;
  }
  return true;
}

sim.JugadorEnPartido _jugadorEnPartidoDesde(
  Jugador jugadorRow,
  String posicionAsignada,
  int minutos, {
  bool esEstrellaAtaque = false,
  bool esEstrellaDefensa = false,
  bool esSextoHombre = false,
  double factorForma = 1.0,
}) {
  return sim.JugadorEnPartido(
    jugador: jugadorRow.toSimJugador(),
    minutos: minutos,
    esEstrellaAtaque: esEstrellaAtaque,
    esEstrellaDefensa: esEstrellaDefensa,
    esSextoHombre: esSextoHombre,
    penalizacionFueraDePosicion:
        factorDePuesto(jugadorRow, posicionAsignada),
    factorForma: factorForma,
  );
}

/// Construye el `EquipoPartido` que espera sim_engine a partir de tu
/// rotación guardada, para un partido en [fecha]: aplica la penalización
/// fuera de posición cuando el puesto asignado no coincide con la
/// posición real del jugador, y respeta las lesiones activas ese día —
/// una lesión grave deja fuera al jugador (si el titular de un puesto está
/// así, juega el suplente los 48 minutos, y si los dos lo están se ficha
/// de emergencia al mejor disponible de la plantilla); una leve no le
/// impide jugar, pero rinde peor ese partido.
Future<sim.EquipoPartido> construirEquipoUsuarioParaFecha(
  AppDatabase db,
  String equipoUsuario,
  DateTime fecha,
) async {
  final filas = await leerRotacion(db);
  if (!rotacionEstaCompleta(filas)) {
    throw StateError('La rotación de $equipoUsuario no está completa');
  }

  final lesionados = await jugadoresFueraDeJuegoEn(db, fecha);
  final penalizacionLeve = await factoresLesionLeveEn(db, fecha);
  final formas = await leerFormas(db);
  // Lo que haya dejado la última decisión de vestuario (ver
  // `eventos_narrativos_repository.dart`). Se aplica AQUÍ, en el único
  // sitio por el que pasa tu equipo para jugar cualquier competición —liga,
  // playoffs y NBA Cup—, así que un evento se nota en las tres sin tener
  // que acordarse de engancharlo en cada una.
  //
  // Y solo aquí: los eventos son decisiones tuyas y los otros 29 equipos no
  // las tienen, así que sus alineaciones no lo miran.
  final animo = await multiplicadorDeEventos(db);
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipoUsuario)))
      .get();
  final plantillaPorId = {for (final j in plantilla) j.id: j};

  sim.JugadorEnPartido enPartido(
    Jugador jugadorRow,
    String posicion,
    int minutos, {
    bool esEstrellaAtaque = false,
    bool esEstrellaDefensa = false,
    bool esSextoHombre = false,
  }) {
    return _jugadorEnPartidoDesde(
      jugadorRow,
      posicion,
      minutos,
      esEstrellaAtaque: esEstrellaAtaque,
      esEstrellaDefensa: esEstrellaDefensa,
      esSextoHombre: esSextoHombre,
      factorForma: (formas[jugadorRow.id] ?? 1.0) *
          (penalizacionLeve[jugadorRow.id] ?? 1.0) *
          animo,
    );
  }

  final porPuesto = <String, List<RotacionJugadorData>>{};
  for (final fila in filas) {
    porPuesto.putIfAbsent(fila.posicion, () => []).add(fila);
  }

  final usadosIds = <int>{};
  final jugadoresEnPartido = <sim.JugadorEnPartido>[];

  for (final posicion in posicionesEquipo) {
    final filaTitular =
        porPuesto[posicion]!.firstWhere((f) => f.esTitular);
    final filaSuplente =
        porPuesto[posicion]!.firstWhere((f) => !f.esTitular);
    // Alguien que ya no está en el equipo cuenta como no disponible, igual
    // que un lesionado. `repararRotacion` debería haberlo arreglado antes,
    // pero esto es la red: un traspaso nunca puede dejar la partida sin
    // poder simular.
    final titularOk = plantillaPorId.containsKey(filaTitular.jugadorId) &&
        !lesionados.contains(filaTitular.jugadorId);
    final suplenteOk = plantillaPorId.containsKey(filaSuplente.jugadorId) &&
        !lesionados.contains(filaSuplente.jugadorId);

    if (titularOk && suplenteOk) {
      jugadoresEnPartido.add(enPartido(
        plantillaPorId[filaTitular.jugadorId]!,
        posicion,
        filaTitular.minutos,
        esEstrellaAtaque: filaTitular.esEstrellaAtaque,
        esEstrellaDefensa: filaTitular.esEstrellaDefensa,
      ));
      jugadoresEnPartido.add(enPartido(
        plantillaPorId[filaSuplente.jugadorId]!,
        posicion,
        filaSuplente.minutos,
        esEstrellaAtaque: filaSuplente.esEstrellaAtaque,
        esEstrellaDefensa: filaSuplente.esEstrellaDefensa,
        esSextoHombre: filaSuplente.esSextoHombre,
      ));
      usadosIds.add(filaTitular.jugadorId);
      usadosIds.add(filaSuplente.jugadorId);
    } else if (titularOk) {
      jugadoresEnPartido.add(enPartido(
        plantillaPorId[filaTitular.jugadorId]!,
        posicion,
        48,
        esEstrellaAtaque: filaTitular.esEstrellaAtaque,
        esEstrellaDefensa: filaTitular.esEstrellaDefensa,
      ));
      usadosIds.add(filaTitular.jugadorId);
    } else if (suplenteOk) {
      jugadoresEnPartido.add(enPartido(
        plantillaPorId[filaSuplente.jugadorId]!,
        posicion,
        48,
        esEstrellaAtaque: filaSuplente.esEstrellaAtaque,
        esEstrellaDefensa: filaSuplente.esEstrellaDefensa,
        esSextoHombre: filaSuplente.esSextoHombre,
      ));
      usadosIds.add(filaSuplente.jugadorId);
    } else {
      var emergencia = plantilla
          .where((j) =>
              !lesionados.contains(j.id) && !usadosIds.contains(j.id))
          .toList()
        ..sort((a, b) => b.media.compareTo(a.media));
      // Salvaguarda extrema: si de verdad no queda nadie sano sin usar,
      // se ficha de emergencia a alguien ya lesionado antes que jugar con
      // menos de 5 en la cancha.
      if (emergencia.isEmpty) {
        emergencia = plantilla.where((j) => !usadosIds.contains(j.id)).toList()
          ..sort((a, b) => b.media.compareTo(a.media));
      }
      if (emergencia.isEmpty) {
        throw StateError(
            'No quedan jugadores disponibles para $posicion en $equipoUsuario');
      }
      jugadoresEnPartido.add(enPartido(emergencia.first, posicion, 48));
      usadosIds.add(emergencia.first.id);
    }
  }

  return sim.EquipoPartido(
    nombre: equipoUsuario,
    jugadores: jugadoresEnPartido,
    entrenador: await entrenadorEnPartidoDe(db, equipoUsuario),
  );
}
