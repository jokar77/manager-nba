import 'dart:math';

import 'package:drift/drift.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/database/app_database.dart';
import 'camisetas_repository.dart';
import 'carrera_repository.dart';
import 'curva_estadisticas.dart';
import 'dorsales_repository.dart';
import 'equipos_especiales.dart';
import 'equipos_info.dart';
import 'hall_fama_repository.dart';
import 'jugador_mapping.dart';
import 'posiciones.dart';
import 'progresion_repository.dart';
import 'rutas_juveniles.dart';
import 'salarios.dart';
import 'tipo_premio.dart';

export 'eventos_de_carrera.dart'
    show
        EventoDeCarrera,
        OpcionDeEventoDeCarrera,
        eventoDeCarreraAleatorio;
export 'rutas_juveniles.dart'
    show rutasJuveniles, ofertasJuvenilesIniciales, TipoOrganizacionJuvenil;
export 'tipo_premio.dart' show TipoPremio;

/// El Modo Carrera: controlas a un único jugador desde los 16 años hasta el
/// retiro, en vez de una franquicia entera. Ver `docs/plan.md` (sesión de
/// creación) para el porqué de cada decisión de alcance.
///
/// Versión mínima (confirmada con el usuario): la fase NBA NO simula las 30
/// franquicias completas —eso exigiría llevar también tu equipo en piloto
/// automático, algo que hoy solo hace un humano—, así que solo se simulan
/// los partidos de TU jugador (con el motor real, `simularPartido`) contra
/// un rival sintético de nivel medio. Al acabar cada temporada eliges tú
/// —como en Copero— si te quedas o fichas por una de dos ofertas de
/// traspaso, calculadas con las fórmulas reales de mercado en vez de una
/// negociación CPU a CPU (ver [OfertaDeEquipo] y [elegirEquipoTemporada]).
/// Premios de liga (MVP/DPOY/ROY) y el draft completo de 30 equipos quedan
/// fuera de esta entrega: los dos necesitan que TODA la liga haya jugado
/// una temporada.

/// Edad a la que se crea una carrera nueva.
const edadInicialCarrera = 16;

/// Edad de elegibilidad para el draft — mismo rango que usan los prospectos
/// generados por el draft real (`draft_repository.dart`: 19 + 0..2 años).
const edadDeDraft = 19;

/// Partidos por temporada NBA, como en la liga real.
const partidosPorTemporadaNba = 82;

/// En qué punto de la carrera está la partida.
enum FaseCarrera { juvenil, predraft, nba, retirado }

FaseCarrera _faseDesde(String clave) => FaseCarrera.values
    .firstWhere((f) => f.name == clave, orElse: () => FaseCarrera.juvenil);

/// La identidad elegida al crear la carrera.
class IdentidadCarrera {
  final String apellido;
  final int dorsal;
  final String posicion;
  final String nacionalidad;

  /// Cada cuántas temporadas se para a decidir — 1, 2 o 3. Por defecto 1
  /// (una decisión cada temporada, como hasta ahora) para no romper nada
  /// que ya construyera un `IdentidadCarrera` sin pensar en esto.
  final int cadenciaAnios;

  const IdentidadCarrera({
    required this.apellido,
    required this.dorsal,
    required this.posicion,
    required this.nacionalidad,
    this.cadenciaAnios = 1,
  });
}

/// Todo lo que hace falta para pintar la ficha de la carrera en un único
/// sitio: la fila de `PartidaCarrera`, y si ya hay fila en `Jugadores`
/// (fase nba/retirado), sus datos actuales — que son los que mandan, porque
/// desde el draft en adelante es esa tabla la que evoluciona.
class EstadoCarrera {
  final String apellido;
  final int dorsal;
  final String posicion;
  final String nacionalidad;
  final int edad;
  final FaseCarrera fase;
  final String? organizacionActual;
  final int media;
  final int potencial;
  final String? equipoNba;
  final int? jugadorId;
  final int temporadaNba;

  /// Salario y años de contrato REALES, no la estimación de mercado — solo
  /// una vez que hay fila de `Jugadores` (fase NBA). `null` en fase
  /// juvenil/predraft, donde todavía no hay ningún contrato que enseñar.
  final int? salario;
  final int? aniosContrato;

  /// Cada cuántas temporadas se para a decidir — 1, 2 o 3. Ver
  /// `IdentidadCarrera.cadenciaAnios`.
  final int cadenciaAnios;

  const EstadoCarrera({
    required this.apellido,
    required this.dorsal,
    required this.posicion,
    required this.nacionalidad,
    required this.edad,
    required this.fase,
    required this.organizacionActual,
    required this.media,
    required this.potencial,
    required this.equipoNba,
    required this.jugadorId,
    required this.temporadaNba,
    required this.cadenciaAnios,
    this.salario,
    this.aniosContrato,
  });
}

/// La partida de carrera de esta ranura, o null si no hay ninguna (ranura
/// vacía o de franquicia).
Future<EstadoCarrera?> leerPartidaCarrera(AppDatabase db) async {
  final fila = await (db.select(db.partidaCarrera)
        ..where((t) => t.id.equals(0)))
      .getSingleOrNull();
  if (fila == null) return null;

  if (fila.jugadorId != null) {
    final jugador = await (db.select(db.jugadores)
          ..where((t) => t.id.equals(fila.jugadorId!)))
        .getSingleOrNull();
    if (jugador != null) {
      return EstadoCarrera(
        apellido: fila.apellido,
        dorsal: jugador.dorsal ?? fila.dorsal,
        posicion: jugador.posicion,
        nacionalidad: fila.nacionalidad,
        edad: jugador.edad,
        fase: _faseDesde(fila.fase),
        organizacionActual: fila.organizacionJuvenilActual,
        media: jugador.media,
        potencial: jugador.potencial,
        equipoNba: jugador.retirado ? null : jugador.equipo,
        jugadorId: jugador.id,
        temporadaNba: fila.temporadaNba,
        cadenciaAnios: fila.cadenciaAnios,
        salario: jugador.salario,
        aniosContrato: jugador.aniosContrato,
      );
    }
  }

  return EstadoCarrera(
    apellido: fila.apellido,
    dorsal: fila.dorsal,
    posicion: fila.posicion,
    nacionalidad: fila.nacionalidad,
    edad: fila.edad,
    fase: _faseDesde(fila.fase),
    organizacionActual: fila.organizacionJuvenilActual,
    media: fila.media,
    potencial: fila.potencial,
    equipoNba: null,
    jugadorId: null,
    temporadaNba: fila.temporadaNba,
    cadenciaAnios: fila.cadenciaAnios,
  );
}

/// Una fila de la línea de tiempo de la carrera: una temporada, la edad que
/// tenías y dónde jugaste. Junta las dos fuentes de datos que ya existen
/// (`HistorialTemporadaJuvenil` para la fase juvenil,
/// `HistorialEstadisticasJugador` para la NBA) en una sola lista ordenada,
/// para pintar el resumen temporada a temporada que ya enseña Copero.
class FilaLineaDeTiempo {
  final int edad;
  final String lugar;
  final int media;
  final double ptsPg;
  final double astPg;
  final double trbPg;
  final int partidos;

  const FilaLineaDeTiempo({
    required this.edad,
    required this.lugar,
    required this.media,
    required this.ptsPg,
    required this.astPg,
    required this.trbPg,
    required this.partidos,
  });
}

/// La línea de tiempo completa de la partida en curso, de más reciente a
/// más antigua.
Future<List<FilaLineaDeTiempo>> leerLineaDeTiempo(AppDatabase db) async {
  final filas = <FilaLineaDeTiempo>[];

  final juveniles = await db.select(db.historialTemporadaJuvenil).get();
  for (final t in juveniles) {
    filas.add(FilaLineaDeTiempo(
      edad: t.edad,
      lugar: t.organizacion,
      media: t.media,
      ptsPg: t.ptsPg,
      astPg: t.astPg,
      trbPg: t.trbPg,
      partidos: 0,
    ));
  }

  final estado = await leerPartidaCarrera(db);
  if (estado?.jugadorId != null) {
    final temporadas = await (db.select(db.historialEstadisticasJugador)
          ..where((t) => t.jugadorId.equals(estado!.jugadorId!)))
        .get();
    for (final t in temporadas) {
      filas.add(FilaLineaDeTiempo(
        edad: edadDeDraft + t.temporada,
        lugar: t.equipo,
        media: t.media,
        ptsPg: t.partidosJugados == 0 ? 0 : t.puntosTotales / t.partidosJugados,
        astPg: t.partidosJugados == 0
            ? 0
            : t.asistenciasTotales / t.partidosJugados,
        trbPg: t.partidosJugados == 0
            ? 0
            : t.rebotesTotales / t.partidosJugados,
        partidos: t.partidosJugados,
      ));
    }
  }

  filas.sort((a, b) => b.edad.compareTo(a.edad));
  return filas;
}

int _atributoInicial(int media, Random rng) =>
    (media + rng.nextInt(9) - 4).clamp(20, 60);

/// Crea la carrera a los 16 años, sin organización juvenil todavía (hace
/// falta [elegirOrganizacionJuvenil] para eso). Solo puede haber una
/// carrera por ranura, igual que una franquicia — llamarla dos veces
/// reemplaza la identidad de la primera.
Future<void> crearPartidaCarrera(
  AppDatabase db,
  IdentidadCarrera identidad, {
  Random? random,
}) async {
  if (!rutasJuveniles.containsKey(identidad.nacionalidad)) {
    throw ArgumentError(
        'Nacionalidad sin ruta juvenil: ${identidad.nacionalidad}');
  }
  if (!posicionesEquipo.contains(identidad.posicion)) {
    throw ArgumentError('Posición desconocida: ${identidad.posicion}');
  }
  if (identidad.cadenciaAnios < 1 || identidad.cadenciaAnios > 3) {
    throw ArgumentError(
        'Cadencia fuera de rango (1-3): ${identidad.cadenciaAnios}');
  }
  final rng = random ?? Random();

  // Un chaval de 16 años recién empezando: muy por debajo de nivel NBA, con
  // un potencial bastante por delante (se sabrá si da la talla según cómo
  // progrese en la fase juvenil).
  final media = 38 + rng.nextInt(8);
  final potencial = (media + 25 + rng.nextInt(30)).clamp(media, 99);

  await db.into(db.partidaCarrera).insertOnConflictUpdate(
        PartidaCarreraCompanion.insert(
          id: const Value(0),
          apellido: identidad.apellido,
          dorsal: identidad.dorsal,
          posicion: identidad.posicion,
          nacionalidad: identidad.nacionalidad,
          edad: const Value(edadInicialCarrera),
          fase: const Value('juvenil'),
          media: Value(media),
          potencial: Value(potencial),
          atrTiro3: Value(_atributoInicial(media, rng)),
          atrAtaque: Value(_atributoInicial(media, rng)),
          atrDefensa: Value(_atributoInicial(media, rng)),
          cadenciaAnios: Value(identidad.cadenciaAnios),
        ),
      );
}

/// Elige [organizacion] (una de las de `rutasJuveniles[nacionalidad]`) como
/// destino juvenil. Hace falta antes de la primera [avanzarTemporadaJuvenil].
Future<void> elegirOrganizacionJuvenil(
  AppDatabase db,
  String organizacion,
) async {
  final fila = await (db.select(db.partidaCarrera)
        ..where((t) => t.id.equals(0)))
      .getSingle();
  final ruta = rutasJuveniles[fila.nacionalidad]!;
  if (!ruta.organizaciones.contains(organizacion)) {
    throw ArgumentError(
        '$organizacion no es una oferta válida para ${fila.nacionalidad}');
  }
  await (db.update(db.partidaCarrera)..where((t) => t.id.equals(0))).write(
    PartidaCarreraCompanion(organizacionJuvenilActual: Value(organizacion)),
  );
}

int _escalarAtributo(int valor, double factor) =>
    (valor * factor).round().clamp(1, 99);

/// Lo que ha pasado en una temporada juvenil, para poder contarlo.
class ResumenTemporadaJuvenil {
  final int edad;
  final int mediaAntes;
  final int mediaDespues;
  final double ptsPg;
  final double astPg;
  final double trbPg;
  final bool pasaAPredraft;

  const ResumenTemporadaJuvenil({
    required this.edad,
    required this.mediaAntes,
    required this.mediaDespues,
    required this.ptsPg,
    required this.astPg,
    required this.trbPg,
    required this.pasaAPredraft,
  });
}

/// Avanza un año de la fase juvenil: progresión (misma cuenta que usa toda
/// la liga, ver `progresionAnualDeMedia`) y una temporada de referencia
/// archivada en `HistorialTemporadaJuvenil`. Al llegar a [edadDeDraft] pasa
/// a fase `predraft`.
///
/// [efectoMedia] es el bonus (o penalización) de la decisión de un evento
/// de carrera que el jugador haya elegido para esta temporada — ver
/// `eventos_de_carrera.dart`. Se suma DESPUÉS de la progresión normal, así
/// que nunca sustituye el crecimiento natural, solo lo empuja un poco.
Future<ResumenTemporadaJuvenil> avanzarTemporadaJuvenil(
  AppDatabase db, {
  Random? random,
  int efectoMedia = 0,
}) async {
  final fila = await (db.select(db.partidaCarrera)
        ..where((t) => t.id.equals(0)))
      .getSingle();
  if (_faseDesde(fila.fase) != FaseCarrera.juvenil) {
    throw StateError('La carrera no está en fase juvenil');
  }
  if (fila.organizacionJuvenilActual == null) {
    throw StateError('Todavía no se ha elegido organización juvenil');
  }
  final rng = random ?? Random();

  final nuevaEdad = fila.edad + 1;
  final nuevaMedia = (progresionAnualDeMedia(
            media: fila.media,
            potencial: fila.potencial,
            nuevaEdad: nuevaEdad,
            factorLongevidad: 1.0,
            rng: rng,
          ) +
          efectoMedia)
      .clamp(1, 99);
  final factor = fila.media == 0 ? 1.0 : nuevaMedia / fila.media;

  final ptsPg = puntosTipicos(nuevaMedia);
  final astPg = asistenciasTipicas(nuevaMedia, fila.posicion);
  final trbPg = rebotesTipicos(nuevaMedia, fila.posicion);

  await db.into(db.historialTemporadaJuvenil).insert(
        HistorialTemporadaJuvenilCompanion.insert(
          edad: fila.edad,
          organizacion: fila.organizacionJuvenilActual!,
          media: nuevaMedia,
          ptsPg: ptsPg,
          astPg: astPg,
          trbPg: trbPg,
        ),
      );

  final pasaAPredraft = nuevaEdad >= edadDeDraft;
  await (db.update(db.partidaCarrera)..where((t) => t.id.equals(0))).write(
    PartidaCarreraCompanion(
      edad: Value(nuevaEdad),
      media: Value(nuevaMedia),
      potencial: Value(max(fila.potencial, nuevaMedia)),
      atrAtaque: Value(_escalarAtributo(fila.atrAtaque, factor)),
      atrDefensa: Value(_escalarAtributo(fila.atrDefensa, factor)),
      atrTiro3: Value(_escalarAtributo(fila.atrTiro3, factor)),
      fase: Value(pasaAPredraft ? 'predraft' : 'juvenil'),
    ),
  );

  return ResumenTemporadaJuvenil(
    edad: fila.edad,
    mediaAntes: fila.media,
    mediaDespues: nuevaMedia,
    ptsPg: ptsPg,
    astPg: astPg,
    trbPg: trbPg,
    pasaAPredraft: pasaAPredraft,
  );
}

/// El equipo de los 30 que mejor encaja con un jugador de [posicion],
/// [media] y [potencial]: misma fórmula que usa la CPU en el draft real
/// (`elegirPorLaCpu`, `draft_repository.dart`) — potencial pesa más que
/// media, y cubrir un hueco de plantilla suma puntos — con algo de ruido
/// para que la lotería no la gane siempre el mismo equipo.
Future<String> _mejorEquipoPara(
  AppDatabase db, {
  required String posicion,
  required int media,
  required int potencial,
  Set<String> excluir = const {},
  required Random rng,
}) async {
  var mejorEquipo = equiposInfo.keys.firstWhere(esFranquicia);
  var mejorValor = double.negativeInfinity;

  for (final equipo in equiposInfo.keys) {
    // `equiposInfo` también tiene las selecciones del All-Star (Este,
    // Oeste, Novatos, Sophomores) para poder reusar sus mismos widgets —
    // no son franquicias de verdad, nadie puede caer ahí.
    if (!esFranquicia(equipo) || excluir.contains(equipo)) continue;
    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false)))
        .get();
    final puestosCortos = {
      for (final puesto in posicionesEquipo)
        if (plantilla.where((j) => juegaComodoDe(j, puesto)).length < 2)
          puesto,
    };
    final base = potencial * 0.6 + media * 0.4;
    final valor =
        (puestosCortos.contains(posicion) ? base + 6 : base) + rng.nextDouble() * 10;
    if (valor > mejorValor) {
      mejorValor = valor;
      mejorEquipo = equipo;
    }
  }
  return mejorEquipo;
}

/// El resultado de entrar al draft.
class ResultadoDraft {
  final String equipo;
  final int jugadorId;

  const ResultadoDraft({required this.equipo, required this.jugadorId});
}

/// Entra al draft: lotería de un solo jugador (no las 60 elecciones del
/// draft real, ver la nota de alcance al principio del fichero). El equipo
/// que "te draftea" crea tu fila real en `Jugadores` — a partir de aquí el
/// resto del juego (progresión, Hall of Fama, camiseta retirada...) te trata
/// exactamente igual que a cualquier otro jugador.
Future<ResultadoDraft> entrarAlDraft(AppDatabase db, {Random? random}) async {
  final fila = await (db.select(db.partidaCarrera)
        ..where((t) => t.id.equals(0)))
      .getSingle();
  if (_faseDesde(fila.fase) != FaseCarrera.predraft) {
    throw StateError('La carrera no está lista para el draft');
  }
  final rng = random ?? Random();

  final equipo = await _mejorEquipoPara(
    db,
    posicion: fila.posicion,
    media: fila.media,
    potencial: fila.potencial,
    rng: rng,
  );

  final jugadorId = await db.into(db.jugadores).insert(
        JugadoresCompanion.insert(
          nombreFicticio: fila.apellido,
          nombreReal: '',
          posicion: fila.posicion,
          equipo: equipo,
          edad: fila.edad,
          media: fila.media,
          potencial: fila.potencial,
          atrTiro3: fila.atrTiro3,
          atrAtaque: fila.atrAtaque,
          atrDefensa: fila.atrDefensa,
          ptsPg: puntosTipicos(fila.media),
          astPg: asistenciasTipicas(fila.media, fila.posicion),
          trbPg: rebotesTipicos(fila.media, fila.posicion),
          factorLongevidad: 0.9 + rng.nextDouble() * 0.25,
          edadRetiro: fila.edad + 10 + rng.nextInt(11),
          dorsal: Value(fila.dorsal),
          salario: Value(salarioEstimado(media: fila.media, edad: fila.edad)),
          aniosContrato:
              Value(aniosContratoEstimados(edad: fila.edad)),
        ),
      );
  // El dorsal elegido en la creación del personaje puede coincidir con el
  // de alguien que ya esté en ese equipo (no se comprobó contra ningún
  // equipo en concreto porque en ese momento todavía no se sabía cuál te
  // draftearía). Mismo mecanismo que ya usa el draft real para sus
  // rookies: si hay choque, se queda con el número quien tenga mejor
  // media y al otro se le asigna uno libre.
  await asignarDorsalesQueFalten(db, random: rng);

  await (db.update(db.partidaCarrera)..where((t) => t.id.equals(0))).write(
    PartidaCarreraCompanion(
      fase: const Value('nba'),
      jugadorId: Value(jugadorId),
    ),
  );

  return ResultadoDraft(equipo: equipo, jugadorId: jugadorId);
}

/// Minutos del protagonista en el partido sintético: cuanto mejor es, más
/// juega — de 16 (banquillo corto) a 40 (estrella indiscutible).
int _minutosProtagonista(int media) =>
    (16 + media * 0.24).round().clamp(16, 40);

/// Reparte [total] minutos entre [n] jugadores lo más igualado posible, sin
/// perder ni sobrar ninguno (para que la suma de un `EquipoPartido` cuadre
/// exactamente en 240).
List<int> _repartirMinutos(int total, int n) {
  final base = total ~/ n;
  final resto = total - base * n;
  return List.generate(n, (i) => base + (i < resto ? 1 : 0));
}

sim.Jugador _companeroSintetico(String posicion, int media, Random rng) =>
    sim.Jugador(
      id: 'cpu_${posicion}_${rng.nextInt(1 << 31)}',
      nombreFicticio: 'Compañero',
      posicion: posicion,
      equipo: 'CPU',
      edad: 27,
      atrAtaque: media,
      atrDefensa: media,
      atrTiro3: media,
      media: media,
      potencial: media,
      ptsPg: puntosTipicos(media),
      astPg: asistenciasTipicas(media, posicion),
      trbPg: rebotesTipicos(media, posicion),
      factorLongevidad: 1.0,
    );

/// Tu equipo: el jugador real (media/atributos de su fila en `Jugadores`,
/// siempre la estrella de ataque) más DOS compañeros sintéticos de nivel de
/// rotación NBA en cada uno de los otros cuatro puestos (titular y
/// suplente, ocho en total) — no sale de una plantilla de verdad, ver la
/// nota de alcance al principio del fichero. Van dos por puesto y no uno
/// para que ningún compañero pase de los 48 minutos que exige
/// `JugadorEnPartido` ni cuando el protagonista juega pocos minutos (a los
/// 16 años de la primera temporada, con solo cuatro compañeros a uno cada
/// uno le tocarían 56).
sim.EquipoPartido _miEquipo(Jugador protagonista, Random rng) {
  final minutosMios = _minutosProtagonista(protagonista.media);
  final otrasPosiciones =
      posicionesEquipo.where((p) => p != protagonista.posicion).toList();
  final huecosDeCompanero = [
    for (final posicion in otrasPosiciones) ...[posicion, posicion],
  ];
  final minutosCompaneros =
      _repartirMinutos(240 - minutosMios, huecosDeCompanero.length);

  final jugadores = <sim.JugadorEnPartido>[
    sim.JugadorEnPartido(
      jugador: protagonista.toSimJugador(),
      minutos: minutosMios,
      esEstrellaAtaque: true,
    ),
  ];
  for (var i = 0; i < huecosDeCompanero.length; i++) {
    jugadores.add(sim.JugadorEnPartido(
      jugador: _companeroSintetico(
          huecosDeCompanero[i], 65 + rng.nextInt(15), rng),
      minutos: minutosCompaneros[i],
    ));
  }
  return sim.EquipoPartido(nombre: 'Mi equipo', jugadores: jugadores);
}

/// Un rival sintético de nivel medio-alto de liga, con los 5 puestos
/// cubiertos. Representa al conjunto de la competición, no a un rival real
/// concreto — mismo motivo de alcance que [_miEquipo].
sim.EquipoPartido _equipoRival(Random rng) {
  final minutos = _repartirMinutos(240, posicionesEquipo.length);
  final jugadores = <sim.JugadorEnPartido>[
    for (var i = 0; i < posicionesEquipo.length; i++)
      sim.JugadorEnPartido(
        jugador: _companeroSintetico(
            posicionesEquipo[i], 68 + rng.nextInt(12), rng),
        minutos: minutos[i],
        esEstrellaAtaque: i == 0,
      ),
  ];
  return sim.EquipoPartido(nombre: 'Rival', jugadores: jugadores);
}

/// Una oferta de equipo de fin de temporada: quedarte donde estás o fichar
/// por uno de los dos que se te ofrecen (ver [avanzarTemporadaNba]).
class OfertaDeEquipo {
  final String equipo;
  final int salario;
  final int aniosContrato;

  const OfertaDeEquipo({
    required this.equipo,
    required this.salario,
    required this.aniosContrato,
  });
}

/// Lo que ha pasado en una temporada NBA.
class ResumenTemporadaNba {
  final int temporada;
  final int edad;
  final int partidosJugados;
  final int puntosTotales;
  final int asistenciasTotales;
  final int rebotesTotales;
  final int victorias;
  final int derrotas;
  final int mediaAntes;
  final int mediaDespues;
  final String equipo;
  final bool seRetira;

  /// La decisión de fin de temporada: quedarte (misma plaza, con el salario
  /// que toque) o fichar por una de las dos ofertas de [ofertasDeTraspaso].
  /// [ofertasDeTraspaso] va vacía si [seRetira] es verdad — ya no hay
  /// equipo que elegir.
  final OfertaDeEquipo ofertaQuedarse;
  final List<OfertaDeEquipo> ofertasDeTraspaso;

  /// Los premios de esta temporada (puede ir vacía). Ver la nota de alcance
  /// sobre cómo se deciden en [avanzarTemporadaNba].
  final List<TipoPremio> premiosGanados;

  const ResumenTemporadaNba({
    required this.temporada,
    required this.edad,
    required this.partidosJugados,
    required this.puntosTotales,
    required this.asistenciasTotales,
    required this.rebotesTotales,
    required this.victorias,
    required this.derrotas,
    required this.mediaAntes,
    required this.mediaDespues,
    required this.equipo,
    required this.seRetira,
    required this.ofertaQuedarse,
    this.ofertasDeTraspaso = const [],
    this.premiosGanados = const [],
  });

  double get ptsPg => partidosJugados == 0 ? 0 : puntosTotales / partidosJugados;
  double get astPg =>
      partidosJugados == 0 ? 0 : asistenciasTotales / partidosJugados;
  double get trbPg => partidosJugados == 0 ? 0 : rebotesTotales / partidosJugados;
}

/// Avanza una temporada NBA completa: simula [partidosPorTemporadaNba]
/// partidos con el motor real (ver [_miEquipo]/[_equipoRival] para el porqué
/// de no simular las 30 franquicias), progresa/declina con la misma cuenta
/// que el resto de la liga, y comprueba el retiro. Si te retiras, evalúa
/// Hall of Fama y camiseta retirada en el mismo paso.
///
/// Si sigues activo, NO decide equipo/contrato por su cuenta: calcula la
/// oferta de quedarte y dos ofertas de traspaso (mismas fórmulas reales de
/// mercado que el resto del juego) y las deja en el resumen para que la
/// pantalla se las enseñe al jugador — como en Copero, la decisión de fin
/// de temporada es del jugador, no de una tirada de dados. Hay que llamar a
/// [elegirEquipoTemporada] con la oferta elegida para que se aplique.
///
/// [efectoMedia] es el bonus (o penalización) del evento de carrera que el
/// jugador haya elegido para esta temporada — ver `eventos_de_carrera.dart`.
Future<ResumenTemporadaNba> avanzarTemporadaNba(
  AppDatabase db, {
  Random? random,
  int efectoMedia = 0,
}) async {
  final fila = await (db.select(db.partidaCarrera)
        ..where((t) => t.id.equals(0)))
      .getSingle();
  if (_faseDesde(fila.fase) != FaseCarrera.nba || fila.jugadorId == null) {
    throw StateError('La carrera no está en fase NBA');
  }
  final rng = random ?? Random();
  final jugador = await (db.select(db.jugadores)
        ..where((t) => t.id.equals(fila.jugadorId!)))
      .getSingle();

  // 1) Se simulan los partidos de la temporada.
  final miEquipo = _miEquipo(jugador, rng);
  final rival = _equipoRival(rng);
  var partidosJugados = 0;
  var puntos = 0, asistencias = 0, rebotes = 0, victorias = 0;
  final miId = jugador.id.toString();

  for (var partido = 0; partido < partidosPorTemporadaNba; partido++) {
    final esLocal = partido.isEven;
    final boxscore = sim.simularPartido(
      local: esLocal ? miEquipo : rival,
      visitante: esLocal ? rival : miEquipo,
      seed: rng.nextInt(1 << 31),
    );
    final misStats = (esLocal ? boxscore.statsLocal : boxscore.statsVisitante)
        .firstWhere((e) => e.jugadorId == miId);
    partidosJugados++;
    puntos += misStats.puntos;
    asistencias += misStats.asistencias;
    rebotes += misStats.rebotes;

    final miMarcador = esLocal ? boxscore.marcadorLocal : boxscore.marcadorVisitante;
    final rivalMarcador =
        esLocal ? boxscore.marcadorVisitante : boxscore.marcadorLocal;
    if (miMarcador > rivalMarcador) victorias++;
  }

  final temporada = fila.temporadaNba + 1;
  await db.into(db.historialEstadisticasJugador).insert(
        HistorialEstadisticasJugadorCompanion.insert(
          temporada: temporada,
          jugadorId: jugador.id,
          equipo: jugador.equipo,
          media: jugador.media,
          partidosJugados: partidosJugados,
          puntosTotales: puntos,
          asistenciasTotales: asistencias,
          rebotesTotales: rebotes,
        ),
      );

  // 2) Progresión de fin de temporada — misma cuenta que toda la liga, más
  // el efecto del evento de esta temporada (si lo hay).
  final nuevaEdad = jugador.edad + 1;
  final nuevaMedia = (progresionAnualDeMedia(
            media: jugador.media,
            potencial: jugador.potencial,
            nuevaEdad: nuevaEdad,
            factorLongevidad: jugador.factorLongevidad,
            rng: rng,
          ) +
          efectoMedia)
      .clamp(1, 99);
  // Cuánto cambia la media este año, para escalar atrAtaque/atrDefensa/
  // atrTiro3 proporcionalmente más abajo — igual que ya hace la fase
  // juvenil con `_escalarAtributo`.
  final factor = jugador.media == 0 ? 1.0 : nuevaMedia / jugador.media;

  // 2.5) Premios de la temporada. Sin una liga completa que simular no hay
  // con qué comparar a los otros 450 candidatos de verdad (ver la nota de
  // alcance al principio del fichero) — así que en vez del cálculo real de
  // `premios_repository.dart`, cada premio es un umbral de tu propio nivel
  // con algo de azar, calibrado para que sean algo que se persigue, no un
  // regalo automático por llegar a cierta media. Se basan en `jugador.media`
  // (con la que jugaste ESTA temporada), no en `nuevaMedia` (la del año que
  // viene). Se guardan en `HistorialPremios`, la misma tabla que usa el
  // resto del juego, así que cuentan solos para el Salón de la Fama
  // (`hall_fama_repository.dart`) y para el resumen de retiro
  // (`carrera_repository.dart` ya los lee de ahí).
  final premiosGanados = <TipoPremio>[];
  final probabilidadAllStar = ((jugador.media - 78) / 14).clamp(0.0, 0.92);
  final esAllStar = rng.nextDouble() < probabilidadAllStar;
  if (esAllStar) premiosGanados.add(TipoPremio.allStar);

  if (esAllStar && jugador.media >= 90 && rng.nextDouble() < 0.22) {
    premiosGanados.add(TipoPremio.mvp);
  }
  if (jugador.atrDefensa >= 88 && rng.nextDouble() < 0.15) {
    premiosGanados.add(TipoPremio.mejorDefensor);
  }
  if (temporada == 1 && jugador.media >= 66 && rng.nextDouble() < 0.3) {
    premiosGanados.add(TipoPremio.rookieDelAno);
  }

  for (final premio in premiosGanados) {
    await db.into(db.historialPremios).insert(
          HistorialPremiosCompanion.insert(
            temporada: temporada,
            tipo: premio.name,
            jugadorId: jugador.id,
            nombreJugador: jugador.nombreFicticio,
            equipo: jugador.equipo,
          ),
        );
  }

  // 3) ¿Toca retiro? Mismo umbral que `envejecerLiga`: por edad, salvo que
  // sigas siendo de los mejores, con un tope duro.
  final leTocaPorEdad = nuevaEdad > jugador.edadRetiro;
  final sigueSiendoDeLosMejores = nuevaMedia >= mediaQueAguantaElRetiro;
  final seRetira = (leTocaPorEdad && !sigueSiendoDeLosMejores) ||
      nuevaEdad > edadMaximaEnActivo;

  if (seRetira) {
    await (db.update(db.jugadores)..where((t) => t.id.equals(jugador.id)))
        .write(JugadoresCompanion(
      edad: Value(nuevaEdad),
      media: Value(nuevaMedia),
      retirado: const Value(true),
      equipo: const Value(equipoRetirados),
      ptsPg: Value(puntosTipicos(nuevaMedia)),
      astPg: Value(asistenciasTipicas(nuevaMedia, jugador.posicion)),
      trbPg: Value(rebotesTipicos(nuevaMedia, jugador.posicion)),
      atrAtaque: Value(_escalarAtributo(jugador.atrAtaque, factor)),
      atrDefensa: Value(_escalarAtributo(jugador.atrDefensa, factor)),
      atrTiro3: Value(_escalarAtributo(jugador.atrTiro3, factor)),
    ));
    await (db.update(db.partidaCarrera)..where((t) => t.id.equals(0))).write(
      PartidaCarreraCompanion(
        edad: Value(nuevaEdad),
        temporadaNba: Value(temporada),
        fase: const Value('retirado'),
      ),
    );
    await _cerrarCarreraAlRetirarse(db, jugadorId: jugador.id, temporada: temporada);

    return ResumenTemporadaNba(
      temporada: temporada,
      edad: nuevaEdad,
      partidosJugados: partidosJugados,
      puntosTotales: puntos,
      asistenciasTotales: asistencias,
      rebotesTotales: rebotes,
      victorias: victorias,
      derrotas: partidosJugados - victorias,
      mediaAntes: jugador.media,
      mediaDespues: nuevaMedia,
      equipo: jugador.equipo,
      seRetira: true,
      ofertaQuedarse: OfertaDeEquipo(
        equipo: jugador.equipo,
        salario: jugador.salario,
        aniosContrato: 0,
      ),
      premiosGanados: premiosGanados,
    );
  }

  // 4) Edad/media/potencial se escriben ya — no dependen de qué equipo se
  // elija. El equipo/salario/años de contrato se quedan como están hasta
  // que la pantalla llame a [elegirEquipoTemporada] con la oferta que haya
  // tomado el jugador.
  //
  // ptsPg/astPg/trbPg y atrAtaque/atrDefensa/atrTiro3 también se
  // recalculan aquí: son lo que lee el motor de simulación
  // (`_miEquipo`, vía `toSimJugador()`) para decidir tus números en cada
  // partido — sin este recálculo se quedaban congelados en lo que tocaba
  // al draftear, así que un veterano de media 95 seguía metiendo los
  // mismos partidos que de novato de media 60.
  await (db.update(db.jugadores)..where((t) => t.id.equals(jugador.id))).write(
    JugadoresCompanion(
      edad: Value(nuevaEdad),
      media: Value(nuevaMedia),
      potencial: Value(max(jugador.potencial, nuevaMedia)),
      ptsPg: Value(puntosTipicos(nuevaMedia)),
      astPg: Value(asistenciasTipicas(nuevaMedia, jugador.posicion)),
      trbPg: Value(rebotesTipicos(nuevaMedia, jugador.posicion)),
      atrAtaque: Value(_escalarAtributo(jugador.atrAtaque, factor)),
      atrDefensa: Value(_escalarAtributo(jugador.atrDefensa, factor)),
      atrTiro3: Value(_escalarAtributo(jugador.atrTiro3, factor)),
    ),
  );
  await (db.update(db.partidaCarrera)..where((t) => t.id.equals(0))).write(
    PartidaCarreraCompanion(
      edad: Value(nuevaEdad),
      temporadaNba: Value(temporada),
    ),
  );

  // 5) Las tres ofertas de fin de temporada: quedarte (mismo contrato si le
  // quedan años, o uno nuevo estimado si toca renovar) y dos equipos
  // distintos con un contrato nuevo — mismas fórmulas reales de mercado que
  // el resto del juego (`salarios.dart`), en vez de decidir la CPU por ti.
  final aniosRestantes = jugador.aniosContrato - 1;
  final int salarioSiQuedo;
  final int aniosSiQuedo;
  if (aniosRestantes <= 0) {
    salarioSiQuedo = salarioEstimado(media: nuevaMedia, edad: nuevaEdad);
    aniosSiQuedo = aniosContratoEstimados(edad: nuevaEdad);
  } else {
    salarioSiQuedo = jugador.salario;
    aniosSiQuedo = aniosRestantes;
  }

  final equipoOferta1 = await _mejorEquipoPara(
    db,
    posicion: jugador.posicion,
    media: nuevaMedia,
    potencial: jugador.potencial,
    excluir: {jugador.equipo},
    rng: rng,
  );
  final equipoOferta2 = await _mejorEquipoPara(
    db,
    posicion: jugador.posicion,
    media: nuevaMedia,
    potencial: jugador.potencial,
    excluir: {jugador.equipo, equipoOferta1},
    rng: rng,
  );
  final salarioTraspaso = salarioEstimado(media: nuevaMedia, edad: nuevaEdad);
  final aniosTraspaso = aniosContratoEstimados(edad: nuevaEdad);

  return ResumenTemporadaNba(
    temporada: temporada,
    edad: nuevaEdad,
    partidosJugados: partidosJugados,
    puntosTotales: puntos,
    asistenciasTotales: asistencias,
    rebotesTotales: rebotes,
    victorias: victorias,
    derrotas: partidosJugados - victorias,
    mediaAntes: jugador.media,
    mediaDespues: nuevaMedia,
    equipo: jugador.equipo,
    seRetira: false,
    ofertaQuedarse: OfertaDeEquipo(
      equipo: jugador.equipo,
      salario: salarioSiQuedo,
      aniosContrato: aniosSiQuedo,
    ),
    ofertasDeTraspaso: [
      OfertaDeEquipo(
        equipo: equipoOferta1,
        salario: salarioTraspaso,
        aniosContrato: aniosTraspaso,
      ),
      OfertaDeEquipo(
        equipo: equipoOferta2,
        salario: salarioTraspaso,
        aniosContrato: aniosTraspaso,
      ),
    ],
    premiosGanados: premiosGanados,
  );
}

/// Aplica la oferta de fin de temporada que ha elegido el jugador (quedarse
/// o una de las dos de traspaso de [avanzarTemporadaNba]): equipo, salario
/// y años de contrato pasan a la fila real en `Jugadores`.
Future<void> elegirEquipoTemporada(
    AppDatabase db, OfertaDeEquipo elegida) async {
  final fila = await (db.select(db.partidaCarrera)
        ..where((t) => t.id.equals(0)))
      .getSingle();
  if (fila.jugadorId == null) {
    throw StateError('La carrera todavía no tiene jugador en la NBA');
  }
  await (db.update(db.jugadores)..where((t) => t.id.equals(fila.jugadorId!)))
      .write(JugadoresCompanion(
    equipo: Value(elegida.equipo),
    salario: Value(elegida.salario),
    aniosContrato: Value(elegida.aniosContrato),
  ));
}

/// Al retirarte: Salón de la Fama (misma evaluación que cualquier otro
/// jugador) y, si la mayoría de tu carrera fue en un mismo equipo y entraste
/// al Salón, la camiseta retirada allí. Un criterio deliberadamente simple
/// —no hay aquí nada de la "grandeza" que mide `legado_historico_repository`
/// para leyendas reales, porque tu jugador no tiene carrera real con la que
/// compararlo.
Future<void> _cerrarCarreraAlRetirarse(
  AppDatabase db, {
  required int jugadorId,
  required int temporada,
}) async {
  final nuevosEnElHall = await evaluarIngresosHallDeLaFama(
    db,
    jugadorIdsRetirados: [jugadorId],
    temporada: temporada,
  );
  if (nuevosEnElHall.isEmpty) return;

  final carrera = await leerCarrera(db, jugadorId);
  if (carrera == null || carrera.etapas.isEmpty) return;

  final etapaMasLarga = carrera.etapas
      .reduce((a, b) => a.temporadas >= b.temporadas ? a : b);
  await retirarCamiseta(
    db,
    equipo: etapaMasLarga.equipo,
    jugadorId: jugadorId,
    temporada: temporada,
  );
}
