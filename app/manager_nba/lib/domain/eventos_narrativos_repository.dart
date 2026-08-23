import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
// Solo para dejar la etiqueta en español guardada junto al efecto, como
// respaldo legible; lo que se ENSEÑA se traduce en la pantalla, con el
// idioma que tenga puesto el usuario en ese momento.
import '../i18n/textos_eventos.dart';
import 'entrenadores_repository.dart' show leerEntrenadorDe;
import 'eventos_narrativos.dart';
import 'posiciones.dart';

// Casi todo el que lee eventos necesita también el catálogo: se reexporta
// para no tener que importar los dos ficheros en cada sitio.
export 'eventos_narrativos.dart';

/// Con qué probabilidad salta un evento por cada partido simulado.
///
/// Va por PARTIDO y no por tramo, igual que las ofertas entrantes, y por la
/// misma razón: si fuera por llamada, quien simula semana a semana tendría
/// veintisiete oportunidades por temporada y quien le da a "simular hasta el
/// final" tendría dos. Ese bug ya se pagó una vez en
/// `ofertas_repository.dart`; aquí se hace bien desde el principio.
///
/// Con 0,035 salen ~2,9 eventos por temporada de 82 partidos, que con un
/// tope de [maxEventosPorTemporada] deja el tope como el que manda y
/// quedarse sin ninguno como una rareza.
const probabilidadDeEventoPorPartido = 0.035;

/// Cuántos eventos como mucho por temporada. Más que esto y dejan de ser
/// acontecimientos para ser una interrupción constante. Fijado a 5 a
/// petición expresa: no tiene que sonar más de cinco veces el teléfono en
/// toda la temporada.
const maxEventosPorTemporada = 5;

// ---------------------------------------------------------------------------
// Efectos activos
// ---------------------------------------------------------------------------

/// Los efectos de vestuario en marcha ahora mismo, del más fuerte al más
/// flojo. Es lo que se enseña en el menú principal.
Future<List<EfectoDeEvento>> leerEfectosActivos(AppDatabase db) async {
  final filas = await (db.select(db.efectosDeEvento)
        ..where((t) => t.partidosRestantes.isBiggerThanValue(0)))
      .get();
  final efectos = filas
      .map((f) => EfectoDeEvento(
          // Las partidas anteriores a la traducción no tienen clave: se
          // quedan con la etiqueta que guardaron, en español, y así al
          // menos se leen. Se agotan en unos partidos.
          clave: f.claveEfecto ?? '',
          factor: f.factor,
          partidos: f.partidosRestantes,
          etiquetaGuardada: f.etiqueta))
      .toList()
    ..sort((a, b) =>
        (b.factor - 1).abs().compareTo((a.factor - 1).abs()));
  return efectos;
}

/// El multiplicador que sale de juntar todos los efectos activos.
///
/// Se multiplican entre sí (no se suman) porque son porcentajes de
/// rendimiento: un +4% y un -4% a la vez dejan al equipo prácticamente como
/// estaba, que es exactamente lo que quiere decir "buen rollo pero piernas
/// cansadas".
///
/// El resultado va acotado al mismo rango que un efecto suelto: por muchos
/// que se acumulen, los eventos no pueden mover el equipo más de un 5%. Sin
/// ese tope, encadenar tres decisiones buenas daría una ventaja mayor que
/// la de fichar al mejor entrenador de la liga, y eso convierte el juego en
/// "elige bien en los diálogos" en vez de "gestiona la plantilla".
Future<double> multiplicadorDeEventos(AppDatabase db) async {
  final efectos = await leerEfectosActivos(db);
  if (efectos.isEmpty) return 1.0;
  var total = 1.0;
  for (final e in efectos) {
    total *= e.factor;
  }
  return total.clamp(minFactorDeEvento, maxFactorDeEvento);
}

/// Le descuenta un partido a todos los efectos activos y borra los que se
/// hayan agotado.
///
/// Se llama UNA vez por partido tuyo jugado. No se llama por los partidos
/// de la CPU: los efectos son de tu vestuario y se gastan cuando tu equipo
/// juega, no cuando pasa el tiempo.
Future<void> gastarUnPartidoDeEfectos(AppDatabase db) async {
  // UNA sola sentencia, sin transacción y sin borrar nada.
  //
  // Esto corre en cada partido tuyo —unos 82 por temporada, más playoffs—, y
  // la inmensa mayoría de ellos no tienen ningún efecto activo, así que
  // tiene que costar lo mínimo posible. La primera versión abría una
  // transacción y hacía dos sentencias por partido; con eso, un test que
  // simula dos temporadas enteras se pasó del tiempo límite.
  //
  // Las filas que llegan a cero se quedan ahí sin molestar: todo el mundo
  // las lee con `partidosRestantes > 0`. Se limpian al resolver el siguiente
  // evento y al pasar de año, que son momentos en los que da igual lo que
  // cueste.
  await db.customUpdate(
    'UPDATE efectos_de_evento SET partidos_restantes = partidos_restantes - 1 '
    'WHERE partidos_restantes > 0',
    updates: {db.efectosDeEvento},
  );
}

/// Tira las filas ya gastadas. Va aparte de [gastarUnPartidoDeEfectos]
/// porque esa corre en cada partido y esta no hace falta que corra nunca en
/// caliente.
Future<void> _limpiarEfectosAgotados(AppDatabase db) =>
    (db.delete(db.efectosDeEvento)
          ..where((t) => t.partidosRestantes.isSmallerOrEqualValue(0)))
        .go();

// ---------------------------------------------------------------------------
// Disparar un evento
// ---------------------------------------------------------------------------

/// Las claves de los eventos que ya han salido esta temporada.
Future<Set<String>> _eventosVistos(AppDatabase db) async {
  final temporada = await (db.select(db.temporada)..where((t) => t.id.equals(0)))
      .getSingleOrNull();
  final crudo = temporada?.eventosVistos ?? '';
  return crudo.split(',').where((c) => c.isNotEmpty).toSet();
}

Future<void> _apuntarVisto(AppDatabase db, String clave) async {
  final vistos = await _eventosVistos(db)
    ..add(clave);
  await (db.update(db.temporada)..where((t) => t.id.equals(0)))
      .write(TemporadaCompanion(eventosVistos: Value(vistos.join(','))));
}

/// Monta la foto del equipo que miran las condiciones del catálogo.
Future<ContextoDeEvento> contextoDe(
  AppDatabase db,
  String equipoUsuario,
) async {
  final resultado = await (db.select(db.resultadoTemporada)
        ..where((t) => t.equipo.equals(equipoUsuario)))
      .getSingleOrNull();
  final plantilla = await (db.select(db.jugadores)
        ..where((t) =>
            t.equipo.equals(equipoUsuario) & t.retirado.equals(false)))
      .get();
  final mejores = [...plantilla]..sort((a, b) => b.media.compareTo(a.media));
  final cinco = mejores.take(5).toList();

  return ContextoDeEvento(
    victorias: resultado?.victorias ?? 0,
    derrotas: resultado?.derrotas ?? 0,
    partidosJugados: (resultado?.victorias ?? 0) + (resultado?.derrotas ?? 0),
    mediaDelEquipo: cinco.isEmpty
        ? 0
        : (cinco.map((j) => j.media).reduce((a, b) => a + b) / cinco.length)
            .round(),
    tieneEntrenador: await leerEntrenadorDe(db, equipoUsuario) != null,
    jugadoresJovenes: plantilla.where((j) => j.edad <= 23).length,
  );
}

/// El nombre en pantalla (`nombreFicticio`) de quien protagoniza [evento],
/// según el [RolDeProtagonista] que le toque, buscando en tu rotación
/// guardada de 10 (ver `franquicia_repository.dart`) — los "10 que están
/// participando" de la lista de bugs.
///
/// Null si el evento no habla de nadie en concreto
/// (`evento.protagonista == null`) o si la rotación todavía no está
/// completa: no debería pasar en una partida real (no se puede jugar ni un
/// partido sin rotación completa, y sin partidos jugados no salta ningún
/// evento), pero un test puede montar un evento de prueba sin rotación, y
/// aquí no se revienta por eso — se cae al genérico del idioma
/// (`TextosDeEventos.jugadorGenerico`).
Future<String?> nombreDelProtagonista(
  AppDatabase db,
  EventoNarrativo evento,
  Random rng,
) async {
  final rol = evento.protagonista;
  if (rol == null) return null;

  final rotacion = await db.select(db.rotacionJugador).get();
  if (rotacion.length < posicionesEquipo.length * 2) return null;

  final ids = rotacion.map((f) => f.jugadorId).toSet();
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.id.isIn(ids) & t.retirado.equals(false)))
      .get();
  if (jugadores.isEmpty) return null;
  final porId = {for (final j in jugadores) j.id: j};

  Jugador mejorPor(List<Jugador> pool, Comparable Function(Jugador) clave) =>
      ([...pool]..sort((a, b) => clave(b).compareTo(clave(a)))).first;

  switch (rol) {
    case RolDeProtagonista.estrella:
      final estrellas = rotacion
          .where((f) => f.esEstrellaAtaque || f.esEstrellaDefensa)
          .map((f) => porId[f.jugadorId])
          .whereType<Jugador>()
          .toList();
      final pool = estrellas.isNotEmpty ? estrellas : jugadores;
      return mejorPor(pool, (j) => j.media).nombreFicticio;
    case RolDeProtagonista.joven:
      final jovenes = jugadores.where((j) => j.edad <= 23).toList();
      final pool = jovenes.isNotEmpty ? jovenes : jugadores;
      return pool[rng.nextInt(pool.length)].nombreFicticio;
    case RolDeProtagonista.veterano:
      return mejorPor(jugadores, (j) => j.edad).nombreFicticio;
    case RolDeProtagonista.titular:
      final titulares = rotacion
          .where((f) => f.esTitular)
          .map((f) => porId[f.jugadorId])
          .whereType<Jugador>()
          .toList();
      final pool = titulares.isNotEmpty ? titulares : jugadores;
      return pool[rng.nextInt(pool.length)].nombreFicticio;
    case RolDeProtagonista.cualquiera:
      return jugadores[rng.nextInt(jugadores.length)].nombreFicticio;
  }
}

/// ¿Salta un evento en este tramo? Devuelve el evento a plantear, o null.
///
/// [partidosSimulados] son los partidos TUYOS que se acaban de jugar. Los
/// topes mandan sobre la suerte: nunca más de [maxEventosPorTemporada] al
/// año, y nunca uno repetido.
Future<EventoNarrativo?> eventoQueSalta(
  AppDatabase db, {
  required String equipoUsuario,
  required int partidosSimulados,
  Random? random,
}) async {
  if (partidosSimulados <= 0) return null;
  final rng = random ?? Random();

  final vistos = await _eventosVistos(db);
  if (vistos.length >= maxEventosPorTemporada) return null;

  var salta = false;
  for (var i = 0; i < partidosSimulados; i++) {
    if (rng.nextDouble() < probabilidadDeEventoPorPartido) {
      salta = true;
      break;
    }
  }
  if (!salta) return null;

  return elegirEvento(
    await contextoDe(db, equipoUsuario),
    yaVistos: vistos,
    random: rng,
  );
}

/// Aplica la opción elegida: guarda sus efectos y apunta el evento como
/// visto para que no vuelva a salir esta temporada.
///
/// Apuntarlo como visto va aquí y no al plantearlo a propósito: si la app se
/// cierra con el diálogo abierto, el evento no se ha decidido y tiene que
/// poder volver a salir.
Future<void> resolverEvento(
  AppDatabase db,
  EventoNarrativo evento,
  OpcionDeEvento opcion,
) async {
  await _limpiarEfectosAgotados(db);
  await db.transaction(() async {
    for (final efecto in opcion.efectos) {
      final acotado = efecto.acotado;
      await db.into(db.efectosDeEvento).insert(EfectosDeEventoCompanion.insert(
            clave: evento.clave,
            claveEfecto: Value(acotado.clave),
            // La etiqueta en español se sigue guardando aunque ya no se
            // enseñe: es lo que hace que una fila de esta tabla se entienda
            // al mirarla a mano, y el respaldo si algún día se borrara una
            // clave del catálogo con partidas en marcha.
            etiqueta: const EventosEs().etiquetaDeEfecto(acotado.clave) ??
                acotado.clave,
            factor: acotado.factor,
            partidosRestantes: acotado.partidos,
          ));
    }
    if (opcion.bonusSalarial != 0) {
      // Se ACUMULA, no se pisa: en una temporada pueden salir dos eventos
      // con dinero y el segundo no puede borrar lo que dejó el primero.
      final actual = await bonusSalarialDeEventos(db);
      await (db.update(db.temporada)..where((t) => t.id.equals(0))).write(
          TemporadaCompanion(
              bonusSalarial: Value(actual + opcion.bonusSalarial)));
    }
    await _apuntarVisto(db, evento.clave);
  });
}

/// El margen de tope salarial que han dejado los eventos de esta temporada.
/// Lo suma [espacioSalarial], y solo para el equipo del usuario.
Future<int> bonusSalarialDeEventos(AppDatabase db) async {
  final temporada = await (db.select(db.temporada)..where((t) => t.id.equals(0)))
      .getSingleOrNull();
  return temporada?.bonusSalarial ?? 0;
}

/// Borra los efectos y la lista de vistos: se llama en el cambio de año.
/// Un verano entero borra cualquier bronca de vestuario.
Future<void> limpiarEventosDeLaTemporada(AppDatabase db) async {
  await db.delete(db.efectosDeEvento).go();
  await (db.update(db.temporada)..where((t) => t.id.equals(0))).write(
      const TemporadaCompanion(
          eventosVistos: Value(''), bonusSalarial: Value(0)));
}
