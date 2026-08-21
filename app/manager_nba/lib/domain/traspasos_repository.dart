import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'calendario_repository.dart';
import 'contratos_repository.dart';
import 'restriccion_de_fichaje.dart';
import 'draft_repository.dart';
import 'equipos_especiales.dart';
import 'franquicia_repository.dart';
import 'picks_repository.dart';
import 'posiciones.dart';
import 'salarios.dart';
import 'tipo_evento_temporada.dart';

/// Margen mínimo que le tiene que salir a la CPU para molestarse en cerrar
/// un traspaso: un 8% más de valor del que entrega.
const margenExigido = 0.08;

/// Un equipo por encima del tope no puede absorber sueldo alegremente: solo
/// puede recibir hasta un 125% de lo que suelta. Es la regla de encaje real
/// de la NBA y es lo que hace que los traspasos de estrellas tengan que ir
/// emparejados en dinero, no que sean imposibles.
const factorEncajeSalarial = 1.25;

/// Colchón sobre el encaje: sin él, un uno por uno entre dos sueldos casi
/// iguales se caía por unos pocos miles de dólares.
const holguraEncajeSalarial = 5000000;

/// ¿Le cuadra el dinero a un equipo? Devuelve null si sí, o el motivo si no.
///
/// Media liga arranca por encima del tope —las plantillas reales cuestan más
/// que el tope, como en la NBA de verdad—, así que exigir quedarse por debajo
/// bloqueaba cualquier traspaso con un sueldo grande dentro. Lo que se exige
/// es lo mismo que exige la NBA: si acabas bajo el tope, todo vale; si te
/// quedas por encima, tienes que soltar un sueldo parecido al que recibes.
String? encajeSalarialRoto({
  required int masaPrevia,
  required int salarioQueSale,
  required int salarioQueEntra,
}) {
  final masaNueva = masaPrevia - salarioQueSale + salarioQueEntra;
  if (masaNueva <= topeSalarial) return null;
  final maximoQuePuedeRecibir =
      (salarioQueSale * factorEncajeSalarial).round() + holguraEncajeSalarial;
  if (salarioQueEntra <= maximoQuePuedeRecibir) return null;
  return 'está por encima del tope: solo puede recibir hasta '
      '${formatearSalario(maximoQuePuedeRecibir)} por los '
      '${formatearSalario(salarioQueSale)} que suelta.';
}

/// Lo que vale un jugador en el mercado de traspasos. No es su salario:
/// es lo que aporta. Pesa el nivel actual, el recorrido que le queda (un
/// chaval de 21 con potencial 95 vale más que un veterano de 33 con la
/// misma media) y penaliza un contrato inflado — quien cobra por encima de
/// lo que rinde es un lastre, no un activo.
double valorDeTraspaso(Jugador jugador) {
  final nivel = pow(max(0, jugador.media - 55), 2.0).toDouble();

  final recorrido = (jugador.potencial - jugador.media).clamp(0, 20);
  final juventud = jugador.edad <= 23
      ? 1.25
      : jugador.edad <= 27
          ? 1.10
          : jugador.edad <= 31
              ? 1.0
              : 0.80;
  final proyeccion = 1 + recorrido * 0.015;

  final justo = valorDeMercado(jugador);
  // Cobrar el doble de lo que vales resta; cobrar poco para lo que rindes
  // suma (contrato "de ganga").
  final ajusteContrato =
      (justo / max(jugador.salario, salarioMinimo)).clamp(0.6, 1.4);

  return nivel * juventud * proyeccion * ajusteContrato;
}

/// Todo lo que se puede poner sobre la mesa: un jugador o una elección de
/// draft. Tener las dos cosas en el mismo tipo es lo que permite que el
/// buscador automático arme paquetes mixtos sin duplicar la lógica.
class ActivoDeTraspaso {
  final Jugador? jugador;
  final PickDraft? pick;
  final double valor;

  const ActivoDeTraspaso._(this.jugador, this.pick, this.valor);

  factory ActivoDeTraspaso.deJugador(Jugador j) =>
      ActivoDeTraspaso._(j, null, valorDeTraspaso(j));

  factory ActivoDeTraspaso.dePick(PickDraft p, double valor) =>
      ActivoDeTraspaso._(null, p, valor);

  bool get esPick => pick != null;
  int get salario => jugador?.salario ?? 0;
  String get etiqueta => jugador?.nombreFicticio ?? etiquetaDePick(pick!);
}

/// Foto de la liga cargada de una sola vez. El buscador automático evalúa
/// decenas de miles de combinaciones; ir a la base en cada una lo haría
/// inviable, así que se carga todo aquí y se calcula en memoria.
class MercadoDeTraspasos {
  final List<Jugador> jugadores;
  final List<PickDraft> picks;
  final Map<String, int> puestosEsperados;
  final int anioDeDraft;

  /// La fecha "de hoy" en la liga, para la restricción de recién fichados
  /// (ver [restriccionDeFichajeReciente]). Se carga una sola vez con el
  /// resto del mercado y no en cada comprobación: el buscador automático
  /// evalúa miles de combinaciones sobre la misma foto.
  final DateTime fechaActual;

  late final Map<int, Jugador> _jugadoresPorId = {
    for (final j in jugadores) j.id: j,
  };
  late final Map<int, PickDraft> _picksPorId = {
    for (final p in picks) p.id: p,
  };
  late final Map<int, double> _valorDePickPorId = {
    for (final p in picks)
      p.id: valorDePick(p,
          puestosEsperados: puestosEsperados, anioActualDeDraft: anioDeDraft),
  };
  late final Map<String, List<Jugador>> _plantillas = () {
    final mapa = <String, List<Jugador>>{};
    for (final j in jugadores) {
      if (j.retirado) continue;
      mapa.putIfAbsent(j.equipo, () => []).add(j);
    }
    return mapa;
  }();

  MercadoDeTraspasos({
    required this.jugadores,
    required this.picks,
    required this.puestosEsperados,
    required this.anioDeDraft,
    required this.fechaActual,
  });

  Jugador? jugador(int id) => _jugadoresPorId[id];
  PickDraft? pick(int id) => _picksPorId[id];
  double valorDe(PickDraft p) => _valorDePickPorId[p.id] ?? 0;

  List<Jugador> plantillaDe(String equipo) => _plantillas[equipo] ?? const [];

  List<PickDraft> picksDeEquipo(String equipo) =>
      picks.where((p) => p.equipoActual == equipo && !p.usado).toList();

  int masaSalarialDe(String equipo) =>
      plantillaDe(equipo).fold<int>(0, (a, j) => a + j.salario);

  /// Todo lo negociable de un equipo, de más a menos valioso.
  List<ActivoDeTraspaso> activosDe(String equipo) {
    final activos = <ActivoDeTraspaso>[
      ...plantillaDe(equipo).map(ActivoDeTraspaso.deJugador),
      ...picksDeEquipo(equipo).map((p) => ActivoDeTraspaso.dePick(p, valorDe(p))),
    ];
    activos.sort((a, b) => b.valor.compareTo(a.valor));
    return activos;
  }

  List<String> get franquicias =>
      _plantillas.keys.where(esFranquicia).toList()..sort();
}

/// Carga la foto del mercado. El año de referencia para los picks es el del
/// próximo draft: desde ahí se cuenta cuánto hay que esperar por cada uno.
Future<MercadoDeTraspasos> cargarMercado(AppDatabase db) async {
  final jugadores = await db.select(db.jugadores).get();
  final picks = await picksVivos(db);
  final fuerza = await fuerzaDeLosEquipos(db);
  final temporada =
      await (db.select(db.temporada)..where((t) => t.id.equals(0)))
          .getSingleOrNull();
  final anioDeDraft = (temporada?.anioInicio ?? DateTime.now().year) + 1;
  final fechaActual = await fechaActualDeLaLiga(db) ?? DateTime.now();

  return MercadoDeTraspasos(
    jugadores: jugadores,
    picks: picks,
    puestosEsperados: puestosEsperadosDeDraft(fuerza),
    anioDeDraft: anioDeDraft,
    fechaActual: fechaActual,
  );
}

/// Veredicto de la CPU ante una propuesta de traspaso.
class RespuestaTraspaso {
  final bool aceptado;
  final String mensaje;

  /// Cuánto valor gana (o pierde) el otro equipo con el cambio, en tanto
  /// por uno sobre lo que entrega. Positivo = le sale a cuenta. Si hay varios
  /// equipos implicados, el del que peor sale parado: es el que decide.
  final double margen;

  /// Pega que tiene el traspaso para ti pero que no lo impide: te deja la
  /// plantilla corta o sin recambio en un puesto. Es cosa tuya arreglarlo
  /// después en la agencia libre.
  final String? aviso;

  /// Cómo le queda a cada equipo implicado, para pintarlo en la mesa.
  final Map<String, BalanceDeEquipo> balances;

  const RespuestaTraspaso({
    required this.aceptado,
    required this.mensaje,
    required this.margen,
    this.aviso,
    this.balances = const {},
  });
}

/// Lo que gana y lo que suelta un equipo en un traspaso concreto. Es lo que
/// permite enseñar en la mesa, equipo a equipo, si el dinero le cuadra y si
/// el cambio le sale a cuenta.
class BalanceDeEquipo {
  final String equipo;
  final int masaPrevia;
  final int salarioQueSale;
  final int salarioQueEntra;
  final double valorQueEntrega;
  final double valorQueRecibe;
  final int jugadoresPrevios;
  final int jugadoresAhora;

  const BalanceDeEquipo({
    required this.equipo,
    required this.masaPrevia,
    required this.salarioQueSale,
    required this.salarioQueEntra,
    required this.valorQueEntrega,
    required this.valorQueRecibe,
    required this.jugadoresPrevios,
    required this.jugadoresAhora,
  });

  int get masaNueva => masaPrevia - salarioQueSale + salarioQueEntra;

  /// Positivo = sale ganando. Sobre lo que entrega, en tanto por uno.
  double get margen => valorQueEntrega == 0
      ? (valorQueRecibe > 0 ? 1.0 : 0.0)
      : (valorQueRecibe - valorQueEntrega) / valorQueEntrega;

  bool get participa =>
      salarioQueSale > 0 ||
      salarioQueEntra > 0 ||
      valorQueEntrega > 0 ||
      valorQueRecibe > 0;
}

/// Un activo que cambia de manos y a qué equipo va. Con esto un traspaso deja
/// de ser "lo mío por lo tuyo" y pasa a ser una lista de movimientos, que es
/// lo que hace falta para meter a un tercer equipo en la operación.
class MovimientoDeTraspaso {
  final int? jugadorId;
  final int? pickId;
  final String destino;

  const MovimientoDeTraspaso.jugador(int this.jugadorId, {required this.destino})
      : pickId = null;

  const MovimientoDeTraspaso.pick(int this.pickId, {required this.destino})
      : jugadorId = null;

  bool get esPick => pickId != null;

  /// Identificador estable para usarlo como clave en la UI.
  String get clave => esPick ? 'p$pickId' : 'j$jugadorId';
}

/// Estudia un traspaso sobre una foto ya cargada del mercado. [tuyos] y
/// [tusPicks] salen de [equipoUsuario]; [suyos] y [susPicks] salen de
/// [equipoRival].
///
/// La CPU acepta si sale ganando en valor, si le cuadra el encaje salarial
/// y si el cambio no le deja la plantilla rota (por debajo del mínimo o sin
/// recambio en un puesto). No regatea: o le conviene o no.
///
/// Con [dejarRompertePlantilla] tu lado deja de ser un veto y pasa a ser un
/// aviso (`RespuestaTraspaso.aviso`): si quieres vaciar un puesto y arreglarlo
/// luego en la agencia libre, es tu equipo y es tu problema. Lo activa la
/// mesa de traspasos; el buscador automático no, porque no tiene sentido que
/// te proponga él solo paquetes que te dejan cojo.
RespuestaTraspaso evaluarEnMercado(
  MercadoDeTraspasos mercado, {
  required String equipoUsuario,
  required String equipoRival,
  List<int> tuyos = const [],
  List<int> suyos = const [],
  List<int> tusPicks = const [],
  List<int> susPicks = const [],
  bool dejarRompertePlantilla = false,
}) {
  return evaluarMultipleEnMercado(
    mercado,
    equipoUsuario: equipoUsuario,
    equipos: [equipoUsuario, equipoRival],
    movimientos: [
      for (final id in tuyos)
        MovimientoDeTraspaso.jugador(id, destino: equipoRival),
      for (final id in tusPicks)
        MovimientoDeTraspaso.pick(id, destino: equipoRival),
      for (final id in suyos)
        MovimientoDeTraspaso.jugador(id, destino: equipoUsuario),
      for (final id in susPicks)
        MovimientoDeTraspaso.pick(id, destino: equipoUsuario),
    ],
    dejarRompertePlantilla: dejarRompertePlantilla,
  );
}

/// El motor de verdad: estudia un traspaso entre [equipos] —dos o tres— en el
/// que cada activo de [movimientos] va al equipo que diga su destino.
///
/// Cada equipo de la CPU tiene que salir ganando ([margenExigido]), a nadie
/// se le puede romper la plantilla y a todos les tiene que cuadrar el dinero
/// ([encajeSalarialRoto]). Tu equipo es el único que puede aceptar salir
/// perdiendo: es tuyo y allá tú.
RespuestaTraspaso evaluarMultipleEnMercado(
  MercadoDeTraspasos mercado, {
  required String equipoUsuario,
  required List<String> equipos,
  required List<MovimientoDeTraspaso> movimientos,
  bool dejarRompertePlantilla = false,
}) {
  if (movimientos.isEmpty) {
    return const RespuestaTraspaso(
        aceptado: false,
        mensaje: 'No has puesto nada sobre la mesa.',
        margen: 0);
  }
  if (equipos.length < 2 || equipos.toSet().length != equipos.length) {
    return const RespuestaTraspaso(
        aceptado: false,
        mensaje: 'Hacen falta al menos dos equipos distintos.',
        margen: 0);
  }

  // Reparto de cada activo: de quién sale y a dónde va.
  final salen = <String, List<Jugador>>{for (final e in equipos) e: []};
  final entran = <String, List<Jugador>>{for (final e in equipos) e: []};
  final valorQueEntrega = <String, double>{for (final e in equipos) e: 0};
  final valorQueRecibe = <String, double>{for (final e in equipos) e: 0};

  for (final m in movimientos) {
    final String origen;
    final double valor;
    if (m.esPick) {
      final pick = mercado.pick(m.pickId!);
      if (pick == null) {
        return const RespuestaTraspaso(
            aceptado: false,
            mensaje: 'Hay una elección de draft que ya no existe.',
            margen: 0);
      }
      origen = pick.equipoActual;
      valor = mercado.valorDe(pick);
    } else {
      final jugador = mercado.jugador(m.jugadorId!);
      if (jugador == null) {
        return const RespuestaTraspaso(
            aceptado: false,
            mensaje: 'Hay un jugador que ya no existe.',
            margen: 0);
      }
      final impedimento =
          restriccionDeFichajeReciente(jugador, mercado.fechaActual);
      if (impedimento != null) {
        return RespuestaTraspaso(
            aceptado: false, mensaje: impedimento, margen: 0);
      }
      origen = jugador.equipo;
      valor = valorDeTraspaso(jugador);
      salen[origen]?.add(jugador);
      entran[m.destino]?.add(jugador);
    }

    if (!equipos.contains(origen) ||
        !equipos.contains(m.destino) ||
        origen == m.destino) {
      return const RespuestaTraspaso(
          aceptado: false,
          mensaje: 'Algo de lo que hay sobre la mesa ya no es de quien creías.',
          margen: 0);
    }
    valorQueEntrega[origen] = valorQueEntrega[origen]! + valor;
    valorQueRecibe[m.destino] = valorQueRecibe[m.destino]! + valor;
  }

  final balances = <String, BalanceDeEquipo>{
    for (final e in equipos)
      e: BalanceDeEquipo(
        equipo: e,
        masaPrevia: mercado.masaSalarialDe(e),
        salarioQueSale: salen[e]!.fold<int>(0, (a, j) => a + j.salario),
        salarioQueEntra: entran[e]!.fold<int>(0, (a, j) => a + j.salario),
        valorQueEntrega: valorQueEntrega[e]!,
        valorQueRecibe: valorQueRecibe[e]!,
        jugadoresPrevios: mercado.plantillaDe(e).length,
        jugadoresAhora: mercado.plantillaDe(e).length -
            salen[e]!.length +
            entran[e]!.length,
      ),
  };

  // Un equipo al que no le llega ni le sale nada está de adorno: fuera.
  final deAdorno = equipos.where((e) => !balances[e]!.participa).toList();
  if (deAdorno.isNotEmpty && deAdorno.length > equipos.length - 2) {
    return const RespuestaTraspaso(
        aceptado: false,
        mensaje: 'No has puesto nada sobre la mesa.',
        margen: 0);
  }

  final margenesCpu = [
    for (final e in equipos)
      if (e != equipoUsuario && balances[e]!.participa) balances[e]!.margen,
  ];
  final margen = margenesCpu.isEmpty ? 0.0 : margenesCpu.reduce(min);

  RespuestaTraspaso no(String mensaje, {String? aviso}) => RespuestaTraspaso(
      aceptado: false,
      mensaje: mensaje,
      margen: margen,
      aviso: aviso,
      balances: balances);

  if (deAdorno.isNotEmpty) {
    return no('${deAdorno.first} no pinta nada en este traspaso: '
        'ni pone ni se lleva.');
  }

  // Plantillas resultantes: a nadie se le puede quedar corta ni sin recambio.
  String? aviso;
  for (final equipo in equipos) {
    final resultante = mercado
        .plantillaDe(equipo)
        .where((j) => !salen[equipo]!.any((s) => s.id == j.id))
        .toList()
      ..addAll(entran[equipo]!);
    final rota = plantillaRota(resultante,
        tamanoPrevio: mercado.plantillaDe(equipo).length);
    if (rota == null) continue;
    if (equipo != equipoUsuario) return no('A $equipo $rota');
    if (!dejarRompertePlantilla) return no('Te $rota');
    aviso = 'Ojo: te $rota '
        'Tendrás que taparlo en la agencia libre antes del próximo partido.';
  }

  // Encaje salarial, equipo por equipo.
  for (final equipo in equipos) {
    final b = balances[equipo]!;
    final roto = encajeSalarialRoto(
      masaPrevia: b.masaPrevia,
      salarioQueSale: b.salarioQueSale,
      salarioQueEntra: b.salarioQueEntra,
    );
    if (roto == null) continue;
    return no(
        equipo == equipoUsuario ? 'Tu equipo $roto' : 'A $equipo le pasa que $roto',
        aviso: aviso);
  }

  // Y por último, si a la CPU le sale a cuenta.
  for (final equipo in equipos) {
    if (equipo == equipoUsuario) continue;
    if (balances[equipo]!.margen < margenExigido) {
      return no('$equipo lo rechaza: no le sale a cuenta.', aviso: aviso);
    }
  }

  final quienesAceptan = equipos.where((e) => e != equipoUsuario).join(' y ');
  return RespuestaTraspaso(
      aceptado: true,
      mensaje: equipos.length > 2
          ? '$quienesAceptan aceptan el traspaso a tres bandas.'
          : '$quienesAceptan acepta el traspaso.',
      margen: margen,
      aviso: aviso,
      balances: balances);
}

/// Qué le pasa a una plantilla resultante que no vale, o null si está bien.
/// El texto se completa con "A LAL ..." o "Te ...".
///
/// Con [tamanoPrevio] la comprobación de tamaño solo se queja si el traspaso
/// *empeora* las cosas: a un equipo que ya venga con 19 jugadores no se le
/// puede prohibir un uno por uno que lo deja exactamente igual.
String? plantillaRota(List<Jugador> plantilla, {int? tamanoPrevio}) {
  final previo = tamanoPrevio ?? plantilla.length;
  if (plantilla.length < plantillaMinima && plantilla.length < previo) {
    return 'dejaría la plantilla por debajo del mínimo de '
        '$plantillaMinima jugadores.';
  }
  if (plantilla.length > plantillaMaxima && plantilla.length > previo) {
    return 'dejaría la plantilla por encima del máximo de '
        '$plantillaMaxima jugadores.';
  }
  for (final puesto in posicionesEquipo) {
    if (plantilla.where((j) => juegaComodoDe(j, puesto)).length < 2) {
      return 'dejaría sin recambio en $puesto.';
    }
  }
  return null;
}

/// Igual que [evaluarEnMercado] pero cargando la foto del mercado. Es lo
/// que usa la pantalla de traspasos cuando propones tú.
Future<RespuestaTraspaso> evaluarTraspaso(
  AppDatabase db, {
  required String equipoUsuario,
  required String equipoRival,
  List<int> tuyos = const [],
  List<int> suyos = const [],
  List<int> tusPicks = const [],
  List<int> susPicks = const [],
  bool dejarRompertePlantilla = false,
}) async {
  final mercado = await cargarMercado(db);
  return evaluarEnMercado(
    mercado,
    equipoUsuario: equipoUsuario,
    equipoRival: equipoRival,
    tuyos: tuyos,
    suyos: suyos,
    tusPicks: tusPicks,
    susPicks: susPicks,
    dejarRompertePlantilla: dejarRompertePlantilla,
  );
}

/// Igual que [evaluarMultipleEnMercado] pero cargando la foto del mercado.
/// Es lo que usa la mesa de traspasos con sus dos o tres columnas.
Future<RespuestaTraspaso> evaluarTraspasoMultiple(
  AppDatabase db, {
  required String equipoUsuario,
  required List<String> equipos,
  required List<MovimientoDeTraspaso> movimientos,
  bool dejarRompertePlantilla = false,
}) async {
  final mercado = await cargarMercado(db);
  return evaluarMultipleEnMercado(
    mercado,
    equipoUsuario: equipoUsuario,
    equipos: equipos,
    movimientos: movimientos,
    dejarRompertePlantilla: dejarRompertePlantilla,
  );
}

/// Ejecuta un traspaso de dos o tres bandas ya aceptado: cada activo se va a
/// donde diga su movimiento. Ver [ejecutarTraspaso] para el porqué del
/// dorsal, el saneo posterior y el corte por fecha límite.
///
/// Con [equipoUsuario] se comprueba la fecha límite igual que en
/// [ejecutarTraspaso], y devuelve false si ya ha pasado.
Future<bool> ejecutarTraspasoMultiple(
  AppDatabase db,
  List<MovimientoDeTraspaso> movimientos, {
  String? equipoUsuario,
}) async {
  if (movimientos.isEmpty) return false;
  if (equipoUsuario != null &&
      await haPasadoFechaLimite(
          db, equipoUsuario, TipoEventoTemporada.fechaLimiteTraspasos)) {
    return false;
  }
  await db.transaction(() async {
    for (final destino in movimientos.map((m) => m.destino).toSet()) {
      final jugadores = [
        for (final m in movimientos)
          if (!m.esPick && m.destino == destino) m.jugadorId!,
      ];
      if (jugadores.isNotEmpty) {
        await (db.update(db.jugadores)..where((t) => t.id.isIn(jugadores)))
            .write(JugadoresCompanion(
                equipo: Value(destino), dorsal: const Value(null)));
      }
      final picks = [
        for (final m in movimientos)
          if (m.esPick && m.destino == destino) m.pickId!,
      ];
      await traspasarPicks(db, picks, destino);
    }
  });

  await sanearTrasMovimientoDePlantilla(db);
  return true;
}

/// Ejecuta un traspaso ya aceptado: intercambia jugadores y picks.
///
/// Al llegar a su equipo nuevo se les quita el dorsal (el suyo puede estar
/// cogido allí) y acto seguido se sanea: se reparten los números libres y se
/// arregla tu rotación si el que se ha ido estaba en ella. Sin eso, traspasar
/// a un titular a mitad de temporada dejaba la alineación apuntando a alguien
/// que ya no está y el siguiente partido reventaba.
///
/// Pasada la fecha límite no se mueve nada y devuelve false. El corte vive
/// aquí, en el dominio, y no solo en los botones: hay varias pantallas que
/// cierran traspasos (la mesa de traspasos, la ficha de un equipo desde la
/// Clasificación, aceptar una oferta recibida) y bloquear solo una dejaba el
/// resto abiertas — salía el aviso y el traspaso se hacía igual.
///
/// [respetarFechaLimite] en false es para los movimientos que no son tuyos:
/// los que cierran entre ellos los equipos de la CPU en pretemporada.
Future<bool> ejecutarTraspaso(
  AppDatabase db, {
  required String equipoUsuario,
  required String equipoRival,
  List<int> tuyos = const [],
  List<int> suyos = const [],
  List<int> tusPicks = const [],
  List<int> susPicks = const [],
  bool respetarFechaLimite = true,
}) async {
  if (respetarFechaLimite &&
      await haPasadoFechaLimite(
          db, equipoUsuario, TipoEventoTemporada.fechaLimiteTraspasos)) {
    return false;
  }

  await db.transaction(() async {
    if (tuyos.isNotEmpty) {
      await (db.update(db.jugadores)..where((t) => t.id.isIn(tuyos)))
          .write(JugadoresCompanion(
              equipo: Value(equipoRival), dorsal: const Value(null)));
    }
    if (suyos.isNotEmpty) {
      await (db.update(db.jugadores)..where((t) => t.id.isIn(suyos)))
          .write(JugadoresCompanion(
              equipo: Value(equipoUsuario), dorsal: const Value(null)));
    }
    await traspasarPicks(db, tusPicks, equipoRival);
    await traspasarPicks(db, susPicks, equipoUsuario);
  });

  await sanearTrasMovimientoDePlantilla(db);
  return true;
}

/// La plantilla de [equipo] tal y como se enseña en la mesa de traspasos:
/// de mejor a peor.
Future<List<Jugador>> plantillaParaTraspasos(AppDatabase db, String equipo) {
  return (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.media)]))
      .get();
}

/// Los equipos con los que se puede negociar (todos menos el tuyo).
Future<List<String>> equiposParaNegociar(
  AppDatabase db,
  String equipoUsuario,
) async {
  final todos = await db.select(db.jugadores).get();
  return todos
      .map((j) => j.equipo)
      .where(esFranquicia)
      .where((e) => e != equipoUsuario)
      .toSet()
      .toList()
    ..sort();
}

// ---------------------------------------------------------------------------
// Buscador automático
// ---------------------------------------------------------------------------

/// Un traspaso completo que la CPU ya ha dicho que aceptaría. Lo devuelve el
/// buscador automático para que solo tengas que elegir cuál te gusta.
class PropuestaTraspaso {
  final String equipoRival;
  final List<Jugador> jugadoresQueSalen;
  final List<Jugador> jugadoresQueLlegan;
  final List<PickDraft> picksQueSalen;
  final List<PickDraft> picksQueLlegan;
  final double valorQueRecibes;
  final double valorQueEntregas;

  const PropuestaTraspaso({
    required this.equipoRival,
    required this.jugadoresQueSalen,
    required this.jugadoresQueLlegan,
    required this.picksQueSalen,
    required this.picksQueLlegan,
    required this.valorQueRecibes,
    required this.valorQueEntregas,
  });

  List<int> get idsQueSalen => jugadoresQueSalen.map((j) => j.id).toList();
  List<int> get idsQueLlegan => jugadoresQueLlegan.map((j) => j.id).toList();
  List<int> get idsPicksQueSalen => picksQueSalen.map((p) => p.id).toList();
  List<int> get idsPicksQueLlegan => picksQueLlegan.map((p) => p.id).toList();

  String get resumenQueSale => [
        ...jugadoresQueSalen.map((j) => j.nombreFicticio),
        ...picksQueSalen.map(etiquetaDePick),
      ].join(', ');

  String get resumenQueLlega => [
        ...jugadoresQueLlegan.map((j) => j.nombreFicticio),
        ...picksQueLlegan.map(etiquetaDePick),
      ].join(', ');
}

/// Todas las combinaciones de uno, dos o tres activos, con su valor total.
/// Tres es el techo realista: con más piezas el traspaso deja de ser creíble
/// y el número de combinaciones se dispara.
List<(List<ActivoDeTraspaso>, double)> _combinaciones(
  List<ActivoDeTraspaso> activos,
) {
  final salida = <(List<ActivoDeTraspaso>, double)>[];
  final n = activos.length;
  for (var i = 0; i < n; i++) {
    salida.add(([activos[i]], activos[i].valor));
    for (var j = i + 1; j < n; j++) {
      salida
          .add(([activos[i], activos[j]], activos[i].valor + activos[j].valor));
      for (var k = j + 1; k < n; k++) {
        salida.add(([activos[i], activos[j], activos[k]],
            activos[i].valor + activos[j].valor + activos[k].valor));
      }
    }
  }
  return salida;
}

/// Buscas salida para lo que pongas encima de la mesa —uno de los tuyos, o
/// un paquete de varios jugadores y picks— y recorre los 29 equipos
/// devolviendo, de cada uno, el mejor paquete que estaría dispuesto a darte
/// a cambio.
///
/// Acepta varios activos a propósito: antes solo miraba a un jugador, así
/// que si marcabas a dos y le dabas al buscador, el segundo (y sus picks) se
/// quedaban fuera del cálculo y las ofertas que salían eran las de un
/// traspaso que no era el que estabas montando.
///
/// La CPU nunca paga de más, así que lo que se busca es el paquete más
/// valioso que aún le siga saliendo a cuenta.
Future<List<PropuestaTraspaso>> buscarSalidaPara(
  AppDatabase db, {
  required String equipoUsuario,
  required List<int> jugadorIds,
  List<int> pickIds = const [],
  int maxPropuestas = 8,
}) async {
  final mercado = await cargarMercado(db);
  return buscarSalidaEnMercado(mercado,
      equipoUsuario: equipoUsuario,
      jugadorIds: jugadorIds,
      pickIds: pickIds,
      maxPropuestas: maxPropuestas);
}

List<PropuestaTraspaso> buscarSalidaEnMercado(
  MercadoDeTraspasos mercado, {
  required String equipoUsuario,
  required List<int> jugadorIds,
  List<int> pickIds = const [],
  int maxPropuestas = 8,
}) {
  final loQueSale = <ActivoDeTraspaso>[];
  for (final id in jugadorIds) {
    final jugador = mercado.jugador(id);
    if (jugador == null || jugador.equipo != equipoUsuario) return [];
    loQueSale.add(ActivoDeTraspaso.deJugador(jugador));
  }
  if (pickIds.isNotEmpty) {
    final tuyos = mercado.activosDe(equipoUsuario);
    for (final id in pickIds) {
      ActivoDeTraspaso? activo;
      for (final a in tuyos) {
        if (a.pick?.id == id) activo = a;
      }
      if (activo == null) return [];
      loQueSale.add(activo);
    }
  }
  if (loQueSale.isEmpty) return [];

  final valorOfrecido = loQueSale.fold<double>(0, (a, x) => a + x.valor);
  // Por encima de esto el rival pierde valor y dice que no.
  final techo = valorOfrecido / (1 + margenExigido);

  final propuestas = <PropuestaTraspaso>[];
  for (final rival in mercado.franquicias) {
    if (rival == equipoUsuario) continue;

    final candidatos = _combinaciones(mercado.activosDe(rival))
        .where((c) => c.$2 <= techo)
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    // Solo la mejor propuesta de cada equipo: veintinueve variantes del
    // mismo paquete no ayudan a decidir.
    for (final candidato in candidatos.take(8)) {
      final propuesta = _montarSiEncaja(
        mercado,
        equipoUsuario: equipoUsuario,
        equipoRival: rival,
        loQueSale: loQueSale,
        loQueLlega: candidato.$1,
      );
      if (propuesta != null) {
        propuestas.add(propuesta);
        break;
      }
    }
  }

  propuestas.sort((a, b) => b.valorQueRecibes.compareTo(a.valorQueRecibes));
  return propuestas.take(maxPropuestas).toList();
}

/// Quieres a alguien de otro equipo: busca qué combinaciones de tu plantilla
/// y tus picks bastarían para convencerles, empezando por la más barata.
Future<List<PropuestaTraspaso>> buscarFichajeDe(
  AppDatabase db, {
  required String equipoUsuario,
  required int jugadorObjetivoId,
  int maxPropuestas = 8,
}) async {
  final mercado = await cargarMercado(db);
  return buscarFichajeEnMercado(mercado,
      equipoUsuario: equipoUsuario,
      jugadorObjetivoId: jugadorObjetivoId,
      maxPropuestas: maxPropuestas);
}

List<PropuestaTraspaso> buscarFichajeEnMercado(
  MercadoDeTraspasos mercado, {
  required String equipoUsuario,
  required int jugadorObjetivoId,
  int maxPropuestas = 8,
}) {
  final objetivo = mercado.jugador(jugadorObjetivoId);
  if (objetivo == null || !esFranquicia(objetivo.equipo)) return [];
  if (objetivo.equipo == equipoUsuario) return [];

  final valorPedido = valorDeTraspaso(objetivo);
  // Por debajo de esto no le compensa soltarlo.
  final suelo = valorPedido * (1 + margenExigido);

  final candidatos = _combinaciones(mercado.activosDe(equipoUsuario))
      .where((c) => c.$2 >= suelo)
      .toList()
    ..sort((a, b) => a.$2.compareTo(b.$2));

  final propuestas = <PropuestaTraspaso>[];
  final piezasPrincipalesVistas = <String>{};
  for (final candidato in candidatos) {
    if (propuestas.length >= maxPropuestas) break;
    final propuesta = _montarSiEncaja(
      mercado,
      equipoUsuario: equipoUsuario,
      equipoRival: objetivo.equipo,
      loQueSale: candidato.$1,
      loQueLlega: [ActivoDeTraspaso.deJugador(objetivo)],
    );
    if (propuesta == null) continue;
    // Nada de enseñar cinco versiones del mismo paquete con la pieza de
    // relleno cambiada: la pieza gorda tiene que ser distinta cada vez.
    final principal = candidato.$1
        .reduce((a, b) => a.valor >= b.valor ? a : b)
        .etiqueta;
    if (!piezasPrincipalesVistas.add(principal)) continue;
    propuestas.add(propuesta);
  }

  return propuestas;
}

/// Comprueba una propuesta contra todas las reglas y, si pasa, la empaqueta.
PropuestaTraspaso? _montarSiEncaja(
  MercadoDeTraspasos mercado, {
  required String equipoUsuario,
  required String equipoRival,
  required List<ActivoDeTraspaso> loQueSale,
  required List<ActivoDeTraspaso> loQueLlega,
}) {
  final jugadoresQueSalen =
      loQueSale.where((a) => !a.esPick).map((a) => a.jugador!).toList();
  final picksQueSalen =
      loQueSale.where((a) => a.esPick).map((a) => a.pick!).toList();
  final jugadoresQueLlegan =
      loQueLlega.where((a) => !a.esPick).map((a) => a.jugador!).toList();
  final picksQueLlegan =
      loQueLlega.where((a) => a.esPick).map((a) => a.pick!).toList();

  final respuesta = evaluarEnMercado(
    mercado,
    equipoUsuario: equipoUsuario,
    equipoRival: equipoRival,
    tuyos: jugadoresQueSalen.map((j) => j.id).toList(),
    suyos: jugadoresQueLlegan.map((j) => j.id).toList(),
    tusPicks: picksQueSalen.map((p) => p.id).toList(),
    susPicks: picksQueLlegan.map((p) => p.id).toList(),
  );
  if (!respuesta.aceptado) return null;

  return PropuestaTraspaso(
    equipoRival: equipoRival,
    jugadoresQueSalen: jugadoresQueSalen,
    jugadoresQueLlegan: jugadoresQueLlegan,
    picksQueSalen: picksQueSalen,
    picksQueLlegan: picksQueLlegan,
    valorQueRecibes: loQueLlega.fold<double>(0, (a, x) => a + x.valor),
    valorQueEntregas: loQueSale.fold<double>(0, (a, x) => a + x.valor),
  );
}
