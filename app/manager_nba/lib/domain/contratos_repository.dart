import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'equipos_especiales.dart';
import 'salarios.dart';

/// Ofertas de renovación que admite un jugador antes de cortar la
/// negociación. A la tercera negativa se acabó: o lo pescas en la agencia
/// libre o lo pierdes.
const maxOfertasDeRenovacion = 3;

/// Lo que pide un jugador para renovar. Es su valor de mercado por nivel y
/// edad, con una prima para los jóvenes con recorrido: saben que van a
/// mejorar y lo cobran por adelantado.
int valorDeMercado(Jugador jugador) {
  final base = salarioEstimado(media: jugador.media, edad: jugador.edad);
  final recorrido = (jugador.potencial - jugador.media).clamp(0, 20);
  final prima = jugador.edad <= 25 ? 1 + recorrido * 0.02 : 1.0;
  return (base * prima).round().clamp(salarioMinimo, salarioMaximo);
}

/// Masa salarial de [equipo] esta temporada.
Future<int> masaSalarial(AppDatabase db, String equipo) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false)))
      .get();
  return plantilla.fold<int>(0, (a, j) => a + j.salario);
}

/// Cuánto le queda a [equipo] por debajo del tope. Negativo si ya se pasó.
Future<int> espacioSalarial(AppDatabase db, String equipo) async =>
    topeSalarial - await masaSalarial(db, equipo);

/// ¿Puede [equipo] pagar [salario]? Por encima del tope solo se puede
/// fichar por el mínimo, que es la excepción que evita que un equipo se
/// quede sin poder completar plantilla.
///
/// [salarioQueLibera] es lo que deja de pagar a la vez (renovar a alguien
/// que ya está en plantilla, o un traspaso): sin esto se contaría su sueldo
/// dos veces y renovar a tu propia estrella sería imposible.
Future<bool> puedeAsumir(
  AppDatabase db,
  String equipo,
  int salario, {
  int salarioQueLibera = 0,
}) async {
  if (salario <= salarioMinimo) return true;
  final masa = await masaSalarial(db, equipo);
  return masa - salarioQueLibera + salario <= topeSalarial;
}

/// Descuenta un año a todos los contratos en vigor. Se llama una vez al
/// cerrar la temporada; los que llegan a 0 son los que hay que renovar.
Future<void> descontarAnioDeContrato(AppDatabase db) async {
  await (db.update(db.jugadores)..where((t) => t.retirado.equals(false)))
      .write(JugadoresCompanion.custom(
    aniosContrato: db.jugadores.aniosContrato - const Constant(1),
  ));
  // Nadie arrastra el enfado de la pretemporada anterior.
  await db.update(db.jugadores).write(
      const JugadoresCompanion(ofertasRechazadas: Value(0)));
}

/// Los jugadores de [equipo] a los que se les ha acabado el contrato.
Future<List<Jugador>> contratosQueVencen(AppDatabase db, String equipo) {
  return (db.select(db.jugadores)
        ..where((t) =>
            t.equipo.equals(equipo) &
            t.retirado.equals(false) &
            t.aniosContrato.isSmallerOrEqualValue(0))
        ..orderBy([(t) => OrderingTerm.desc(t.media)]))
      .get();
}

/// Cómo ha ido una oferta de renovación.
class RespuestaOferta {
  final bool aceptada;
  final int ofertasRechazadas;
  final String mensaje;

  const RespuestaOferta({
    required this.aceptada,
    required this.ofertasRechazadas,
    required this.mensaje,
  });

  bool get quedanOfertas => ofertasRechazadas < maxOfertasDeRenovacion;
}

/// Con qué probabilidad acepta un jugador una oferta de [salario] al año
/// durante [anios], pidiendo [pedido]. La usan tanto las renovaciones
/// (jugadores ya en plantilla) como las negociaciones de agencia libre: la
/// psicología del jugador es la misma en los dos sitios.
///
/// Por debajo del 75% de su valor no hay trato posible y encima se ofende,
/// alrededor de su precio es probable que firme, y por encima es casi
/// seguro. Los años también cuentan —un veterano no quiere contratos largos
/// y un joven no quiere firmar por uno solo— y cada negativa anterior le
/// deja peor predispuesto, así que tirar bajo "a ver si cuela" sale caro.
double probabilidadDeAceptar({
  required int salario,
  required int pedido,
  required int anios,
  required int edad,
  required int ofertasRechazadas,
}) {
  final ratio = salario / pedido;
  var probabilidad = ((ratio - 0.75) / 0.35).clamp(0.0, 1.0);
  final aniosDeseados = aniosContratoEstimados(edad: edad);
  probabilidad -= (anios - aniosDeseados).abs() * 0.06;
  probabilidad -= ofertasRechazadas * 0.12;
  return probabilidad.clamp(0.0, 1.0);
}

/// Le ofrece a [jugadorId] renovar por [salario] al año durante [anios].
/// Ver [probabilidadDeAceptar] para cómo decide.
Future<RespuestaOferta> ofrecerRenovacion(
  AppDatabase db,
  int jugadorId, {
  required int salario,
  required int anios,
  Random? random,
}) async {
  final rng = random ?? Random();
  final jugador = await (db.select(db.jugadores)
        ..where((t) => t.id.equals(jugadorId)))
      .getSingle();

  if (jugador.ofertasRechazadas >= maxOfertasDeRenovacion) {
    return RespuestaOferta(
      aceptada: false,
      ofertasRechazadas: jugador.ofertasRechazadas,
      mensaje: 'Ya no quiere seguir negociando. Le verás en la agencia libre.',
    );
  }

  // Ya está en plantilla: lo que cuenta es la diferencia con lo que cobra.
  if (!await puedeAsumir(db, jugador.equipo, salario,
      salarioQueLibera: jugador.salario)) {
    return RespuestaOferta(
      aceptada: false,
      ofertasRechazadas: jugador.ofertasRechazadas,
      mensaje: 'No tienes espacio salarial para esa oferta.',
    );
  }

  final pedido = valorDeMercado(jugador);
  final ratio = salario / pedido;
  final probabilidad = probabilidadDeAceptar(
    salario: salario,
    pedido: pedido,
    anios: anios,
    edad: jugador.edad,
    ofertasRechazadas: jugador.ofertasRechazadas,
  );

  if (rng.nextDouble() < probabilidad) {
    await (db.update(db.jugadores)..where((t) => t.id.equals(jugadorId)))
        .write(JugadoresCompanion(
      salario: Value(salario),
      aniosContrato: Value(anios),
      ofertasRechazadas: const Value(0),
    ));
    return RespuestaOferta(
      aceptada: true,
      ofertasRechazadas: 0,
      mensaje: '${jugador.nombreFicticio} renueva por $anios '
          '${anios == 1 ? 'temporada' : 'temporadas'}.',
    );
  }

  // Una oferta ridícula ofende el doble.
  final penalizacion = ratio < 0.75 ? 2 : 1;
  final rechazadas =
      min(maxOfertasDeRenovacion, jugador.ofertasRechazadas + penalizacion);
  await (db.update(db.jugadores)..where((t) => t.id.equals(jugadorId)))
      .write(JugadoresCompanion(ofertasRechazadas: Value(rechazadas)));

  return RespuestaOferta(
    aceptada: false,
    ofertasRechazadas: rechazadas,
    mensaje: ratio < 0.75
        ? '${jugador.nombreFicticio} se ha tomado la oferta como un insulto.'
        : '${jugador.nombreFicticio} la rechaza: esperaba algo más.',
  );
}

/// Manda a la agencia libre a los jugadores indicados (contrato terminado
/// y sin renovar).
Future<void> mandarAAgenciaLibre(AppDatabase db, List<int> jugadorIds) async {
  if (jugadorIds.isEmpty) return;
  await (db.update(db.jugadores)..where((t) => t.id.isIn(jugadorIds)))
      .write(const JugadoresCompanion(
    equipo: Value(equipoAgenciaLibre),
    dorsal: Value(null),
    ofertasRechazadas: Value(0),
  ));
}

/// Con qué probabilidad acepta un jugador la renovación que le ofrece su
/// equipo de la CPU. Es exactamente la misma psicología que cuando negocias
/// tú ([probabilidadDeAceptar]: cuánto le ofreces frente a lo que pide, y
/// los años), más lo único que aquí se puede saber y en tu pantalla no: el
/// proyecto deportivo. [winPct] es lo que ganó el equipo la temporada que
/// acaba de cerrarse.
///
/// No hay ninguna cuota de estrellas ni nada que empuje a nadie al mercado:
/// quien llega a la agencia libre llega porque su equipo no le convenció o
/// porque no cabía bajo el tope. Que renovar fuera automático era el
/// problema — la CPU retenía a todo el que podía pagar y no salía nunca
/// nadie.
double probabilidadDeRenovarConLaCpu({
  required int salario,
  required int pedido,
  required int anios,
  required int edad,
  required double winPct,
}) {
  final base = probabilidadDeAceptar(
    salario: salario,
    pedido: pedido,
    anios: anios,
    edad: edad,
    ofertasRechazadas: 0,
  );
  // Ganar convence: en un equipo de 60 victorias se firma más a gusto que
  // en uno de 20, con el mismo contrato encima de la mesa.
  final porElProyecto = (winPct - 0.5) * 0.30;
  return (base + porElProyecto).clamp(0.05, 0.95);
}

/// Resuelve los vencimientos de los 29 equipos de la CPU: renuevan a quien
/// pueden pagar (los mejores primero) y sueltan al resto. El equipo del
/// usuario se queda intacto: esas decisiones las tomas tú.
///
/// Dos motivos para acabar en la agencia libre, los dos con sentido: que el
/// equipo no pueda pagar la renovación bajo el tope (ahí se va obligado), o
/// que el jugador no acepte lo que le ponen delante
/// ([probabilidadDeRenovarConLaCpu]).
Future<void> resolverVencimientosDeLaCpu(
  AppDatabase db, {
  required String equipoUsuario,
  Random? random,
}) async {
  final rng = random ?? Random();
  final equipos = (await db.select(db.jugadores).get())
      .map((j) => j.equipo)
      .where(esFranquicia)
      .where((e) => e != equipoUsuario)
      .toSet();

  // El récord de la temporada que acaba de cerrarse: todavía está en la
  // tabla (se borra después, en finalizarPretemporada).
  final resultados = await db.select(db.resultadoTemporada).get();
  final winPctPorEquipo = {
    for (final r in resultados)
      r.equipo: (r.victorias + r.derrotas) == 0
          ? 0.5
          : r.victorias / (r.victorias + r.derrotas),
  };

  for (final equipo in equipos) {
    final vencen = await contratosQueVencen(db, equipo);
    final winPct = winPctPorEquipo[equipo] ?? 0.5;
    final sueltos = <int>[];
    for (final jugador in vencen) {
      final pedido = valorDeMercado(jugador);
      // La CPU paga lo que vale, con un pequeño regateo aleatorio.
      final oferta = (pedido * (0.95 + rng.nextDouble() * 0.15)).round();

      // ¿Le cabe bajo el tope? Si no, no hay renovación posible: se va,
      // por bueno que sea. Es el caso de la estrella a la que su equipo ya
      // no puede pagar.
      if (!await puedeAsumir(db, equipo, oferta,
          salarioQueLibera: jugador.salario)) {
        sueltos.add(jugador.id);
        continue;
      }

      final anios = aniosContratoEstimados(edad: jugador.edad);
      final acepta = probabilidadDeRenovarConLaCpu(
        salario: oferta,
        pedido: pedido,
        anios: anios,
        edad: jugador.edad,
        winPct: winPct,
      );
      if (rng.nextDouble() < acepta) {
        await (db.update(db.jugadores)..where((t) => t.id.equals(jugador.id)))
            .write(JugadoresCompanion(
          salario: Value(oferta),
          aniosContrato: Value(anios),
        ));
      } else {
        sueltos.add(jugador.id);
      }
    }
    await mandarAAgenciaLibre(db, sueltos);
  }
}
