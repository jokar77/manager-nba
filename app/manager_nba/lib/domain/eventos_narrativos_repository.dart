import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'entrenadores_repository.dart' show leerEntrenadorDe;
import 'eventos_narrativos.dart';

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
          etiqueta: f.etiqueta,
          factor: f.factor,
          partidos: f.partidosRestantes))
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
            etiqueta: acotado.etiqueta,
            factor: acotado.factor,
            partidosRestantes: acotado.partidos,
          ));
    }
    await _apuntarVisto(db, evento.clave);
  });
}

/// Borra los efectos y la lista de vistos: se llama en el cambio de año.
/// Un verano entero borra cualquier bronca de vestuario.
Future<void> limpiarEventosDeLaTemporada(AppDatabase db) async {
  await db.delete(db.efectosDeEvento).go();
  await (db.update(db.temporada)..where((t) => t.id.equals(0)))
      .write(const TemporadaCompanion(eventosVistos: Value('')));
}
