import 'dart:math';

import 'package:drift/drift.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/database/app_database.dart';
import 'contratos_repository.dart' show masaSalarial;
import 'draft_repository.dart' show nombreFicticioUnico;
import 'entrenadores.dart';
import 'equipos_especiales.dart';
import 'salarios.dart' show topeSalarial;

// Casi todo el que lee entrenadores necesita también la media y el estilo:
// se reexportan para no tener que importar los dos ficheros en cada sitio.
export 'entrenadores.dart';

/// El entrenador de [equipo], o null si el banquillo está vacío (te acabas
/// de cargar al anterior, o la partida es de antes de que existieran los
/// entrenadores y todavía no se ha rellenado).
///
/// Ojo: un entrenador al que despediste sigue teniendo su finiquito
/// apuntado contra tu equipo, pero su `equipo` ya es [equipoAgenciaLibre],
/// así que no lo devuelve esta consulta. Son dos cosas distintas a
/// propósito: quién dirige y a quién le debes dinero.
Future<Entrenador?> leerEntrenadorDe(AppDatabase db, String equipo) {
  return (db.select(db.entrenadores)..where((t) => t.equipo.equals(equipo)))
      .getSingleOrNull();
}

/// Los que están sin equipo, de mejor a peor.
Future<List<Entrenador>> leerEntrenadoresLibres(AppDatabase db) async {
  final libres = await (db.select(db.entrenadores)
        ..where((t) => t.equipo.equals(equipoAgenciaLibre)))
      .get();
  return libres..sort((a, b) => mediaDe(b).compareTo(mediaDe(a)));
}

/// La media de un entrenador, con el mismo criterio en toda la app.
int mediaDe(Entrenador e) => mediaDeEntrenador(
      ataque: e.atrAtaque,
      defensa: e.atrDefensa,
      desarrollo: e.atrDesarrollo,
    );

/// Lo que pide al año, en dólares.
int salarioQuePide(Entrenador e) => salarioDeEntrenador(mediaDe(e));

/// Los años que pide.
int aniosQuePide(Entrenador e) =>
    aniosPedidosPorEntrenador(media: mediaDe(e), edad: e.edad);

/// Cómo lo ve el motor de simulación. Null si el equipo no tiene
/// entrenador: el motor lo trata como "aporte cero" (ver
/// `aporteDelEntrenador` en sim_engine), o sea que dirigir sin entrenador no
/// es un castigo, simplemente no hay ayuda.
Future<sim.EntrenadorEnPartido?> entrenadorEnPartidoDe(
  AppDatabase db,
  String equipo,
) async {
  final e = await leerEntrenadorDe(db, equipo);
  if (e == null) return null;
  return sim.EntrenadorEnPartido(ataque: e.atrAtaque, defensa: e.atrDefensa);
}

/// Los entrenadores de TODA la liga de una vez, indexados por equipo.
///
/// Existe por rendimiento y no por comodidad: simular un tramo de calendario
/// monta la alineación de los 30 equipos en cada jornada, y preguntar por el
/// entrenador equipo a equipo dentro de ese bucle son miles de consultas por
/// mes simulado.
Future<Map<String, sim.EntrenadorEnPartido>> leerEntrenadoresDeLaLiga(
  AppDatabase db,
) async {
  final todos = await db.select(db.entrenadores).get();
  return {
    for (final e in todos)
      if (esFranquicia(e.equipo))
        e.equipo: sim.EntrenadorEnPartido(
            ataque: e.atrAtaque, defensa: e.atrDefensa),
  };
}

/// La media de los cinco mejores de [equipo]: el mismo criterio que usa la
/// pantalla de elegir equipo para decir "media del equipo". Es lo que mira
/// un entrenador antes de aceptar tu oferta.
Future<int> mediaDeLosCincoMejores(AppDatabase db, String equipo) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.media)])
        ..limit(5))
      .get();
  if (plantilla.isEmpty) return 0;
  return (plantilla.map((j) => j.media).reduce((a, b) => a + b) /
          plantilla.length)
      .round();
}

/// El récord de esta temporada del entrenador de [equipo].
///
/// No se guarda partido a partido, y es a propósito: el récord de un
/// entrenador es EXACTAMENTE el de su equipo, así que llevarlo aparte serían
/// dos consultas más en cada uno de los ~2.500 partidos que se simulan en un
/// año, para acabar con dos cuentas que pueden desincronizarse. Se lee de
/// `ResultadoTemporada`, que ya está, y lo acumulado de su carrera se suma
/// una vez por verano (ver [pasarElVeranoDeLosEntrenadores]).
Future<({int victorias, int derrotas})> recordDeEstaTemporada(
  AppDatabase db,
  String equipo,
) async {
  final fila = await (db.select(db.resultadoTemporada)
        ..where((t) => t.equipo.equals(equipo)))
      .getSingleOrNull();
  return (victorias: fila?.victorias ?? 0, derrotas: fila?.derrotas ?? 0);
}

// ---------------------------------------------------------------------------
// El presupuesto de banquillo
// ---------------------------------------------------------------------------

/// Lo que le cuesta el banquillo a un equipo y cuánto aire le queda dentro
/// del tope de la franquicia.
class PresupuestoDeBanquillo {
  /// Lo que cobra quien dirige ahora mismo (0 si el puesto está vacante).
  final int sueldoDelActual;

  /// Lo que se sigue pagando a entrenadores despedidos que aún tenían
  /// contrato. Es dinero que no puedes gastarte en nadie más.
  final int finiquitos;

  /// La masa salarial COMPLETA del equipo (jugadores + banquillo) y lo que
  /// le queda hasta el tope. Negativo si ya se pasó.
  final int masaSalarialTotal;
  final int espacioEnElTope;

  const PresupuestoDeBanquillo({
    required this.sueldoDelActual,
    required this.finiquitos,
    required this.masaSalarialTotal,
    required this.espacioEnElTope,
  });

  int get comprometido => sueldoDelActual + finiquitos;

  /// Lo máximo que puedes ofrecerle a un entrenador nuevo.
  ///
  /// Sale del tope de la franquicia, no de una hucha aparte: el sueldo del
  /// entrenador es masa salarial como la de cualquier jugador. Y ojo — si ya
  /// tienes entrenador, su sueldo NO se libera al fichar a otro, porque al
  /// anterior hay que finiquitarlo y se le sigue pagando.
  ///
  /// El suelo es el sueldo mínimo, igual que con los jugadores: un equipo
  /// pasado de tope siempre puede firmar por el mínimo. Sin esa válvula, las
  /// seis franquicias que empiezan la partida por encima del tope se
  /// quedarían sin poder tener entrenador nunca.
  int get libre => max(
        salarioMinimoEntrenador,
        min(espacioEnElTope, salarioMaximoEntrenador),
      );
}

/// Dónde está comprometido el dinero del banquillo de [equipo].
Future<PresupuestoDeBanquillo> presupuestoDe(
  AppDatabase db,
  String equipo,
) async {
  final actual = await leerEntrenadorDe(db, equipo);
  final conFiniquito = await (db.select(db.entrenadores)
        ..where((t) =>
            t.equipoQuePagaFiniquito.equals(equipo) &
            t.aniosDeFiniquito.isBiggerThanValue(0)))
      .get();
  final masa = await masaSalarial(db, equipo);
  return PresupuestoDeBanquillo(
    sueldoDelActual: actual?.salario ?? 0,
    finiquitos: conFiniquito.fold<int>(0, (suma, e) => suma + e.salario),
    masaSalarialTotal: masa,
    espacioEnElTope: topeSalarial - masa,
  );
}

/// Lo máximo que [equipo] puede ofrecerle a un entrenador nuevo.
Future<int> maximoQuePuedesOfrecer(AppDatabase db, String equipo) async =>
    (await presupuestoDe(db, equipo)).libre;

// ---------------------------------------------------------------------------
// Contratar y despedir
// ---------------------------------------------------------------------------

/// Por qué no se ha podido fichar a un entrenador.
enum MotivoDeRechazo {
  /// Ya no está libre (se lo ha llevado otro equipo mientras mirabas).
  yaTieneEquipo,

  /// No te da el presupuesto de banquillo para ese sueldo.
  sinPresupuesto,

  /// No le convence: ni el proyecto ni lo que le ofreces llegan.
  noLeConvenceLaOferta,
}

/// El resultado de intentar fichar, con lo que hace falta para contárselo
/// al usuario.
class ResultadoDeFichaje {
  final MotivoDeRechazo? motivo;
  final String mensaje;

  const ResultadoDeFichaje({this.motivo, required this.mensaje});

  bool get firmado => motivo == null;
}

/// Le ofrece a [entrenadorId] dirigir a [equipo] por [salario] al año
/// durante [anios].
///
/// Si acepta y ya había alguien en el banquillo, al anterior se le despide
/// en el mismo movimiento — con su finiquito, que sigue comiendo
/// presupuesto.
Future<ResultadoDeFichaje> contratarEntrenador(
  AppDatabase db,
  int entrenadorId,
  String equipo, {
  required int salario,
  required int anios,
}) async {
  final candidato = await (db.select(db.entrenadores)
        ..where((t) => t.id.equals(entrenadorId)))
      .getSingleOrNull();
  if (candidato == null || candidato.equipo != equipoAgenciaLibre) {
    return const ResultadoDeFichaje(
      motivo: MotivoDeRechazo.yaTieneEquipo,
      mensaje: 'Ya ha firmado por otro equipo.',
    );
  }

  final tope = await maximoQuePuedesOfrecer(db, equipo);
  if (salario > tope) {
    return ResultadoDeFichaje(
      motivo: MotivoDeRechazo.sinPresupuesto,
      mensaje: 'No te da la masa salarial: como mucho puedes ofrecer '
          '${formatearMillones(tope)}.',
    );
  }

  final respuesta = await valorarOfertaDe(db, candidato, equipo,
      salario: salario, anios: anios);
  if (!respuesta.acepta) {
    return ResultadoDeFichaje(
      motivo: MotivoDeRechazo.noLeConvenceLaOferta,
      mensaje: respuesta.loQueFalta > maxPuntosQueCompraElDinero
          ? '${candidato.nombreFicticio} no dirigiría a este equipo ni por '
              'todo el dinero del mundo: le falta proyecto.'
          : '${candidato.nombreFicticio} rechaza la oferta. Con más dinero o '
              'más años quizá se lo piense.',
    );
  }

  await db.transaction(() async {
    await despedirEntrenador(db, equipo);
    await (db.update(db.entrenadores)..where((t) => t.id.equals(entrenadorId)))
        .write(EntrenadoresCompanion(
      equipo: Value(equipo),
      salario: Value(salario),
      aniosContrato: Value(anios),
      // Si venía cobrando un finiquito de otro equipo, deja de cobrarlo:
      // ha vuelto a trabajar.
      equipoQuePagaFiniquito: const Value(null),
      aniosDeFiniquito: const Value(0),
    ));
  });

  return ResultadoDeFichaje(
    mensaje: '${candidato.nombreFicticio} firma por $anios '
        '${anios == 1 ? 'temporada' : 'temporadas'} y '
        '${formatearMillones(salario)} al año.',
  );
}

/// ¿Qué diría [entrenador] a una oferta de [equipo]? Con su precio y sus
/// años si no se indican otros: es lo que enseña la lista del mercado antes
/// de que el usuario abra la negociación.
Future<RespuestaDelEntrenador> valorarOfertaDe(
  AppDatabase db,
  Entrenador entrenador,
  String equipo, {
  int? salario,
  int? anios,
}) async {
  final media = await mediaDeLosCincoMejores(db, equipo);
  final record = await recordDeEstaTemporada(db, equipo);
  return valorarOferta(
    mediaDelEntrenador: mediaDe(entrenador),
    desarrolloDelEntrenador: entrenador.atrDesarrollo,
    mediaDelEquipo: media,
    victorias: record.victorias,
    derrotas: record.derrotas,
    salarioOfrecido: salario ?? salarioQuePide(entrenador),
    salarioPedido: salarioQuePide(entrenador),
    aniosOfrecidos: anios ?? aniosQuePide(entrenador),
    aniosPedidos: aniosQuePide(entrenador),
  );
}

/// Despide al entrenador de [equipo]: se va a la lista de libres y, si le
/// quedaban años, el equipo le sigue pagando hasta que se cumplan.
Future<void> despedirEntrenador(AppDatabase db, String equipo) async {
  final actual = await leerEntrenadorDe(db, equipo);
  if (actual == null) return;

  // Los años que le quedan por cobrar. El del año en curso cuenta: se le
  // paga entero aunque le eches en octubre, como en la vida real.
  final pendientes = max(0, actual.aniosContrato);

  await (db.update(db.entrenadores)..where((t) => t.id.equals(actual.id)))
      .write(EntrenadoresCompanion(
    equipo: const Value(equipoAgenciaLibre),
    aniosContrato: const Value(0),
    equipoQuePagaFiniquito:
        pendientes > 0 ? Value(equipo) : const Value(null),
    aniosDeFiniquito: Value(pendientes),
  ));
}

/// Lo que te costaría echar al entrenador de [equipo] ahora mismo: su sueldo
/// por los años que le queden. Cero si el banquillo está vacío o si su
/// contrato termina este verano.
Future<int> costeDeDespedir(AppDatabase db, String equipo) async {
  final actual = await leerEntrenadorDe(db, equipo);
  if (actual == null) return 0;
  return actual.salario * max(0, actual.aniosContrato);
}

/// Formatea millones para la UI: "8,4M".
String formatearMillones(int dolares) =>
    '${(dolares / 1000000).toStringAsFixed(1).replaceAll('.', ',')}M';

// ---------------------------------------------------------------------------
// El verano
// ---------------------------------------------------------------------------

/// Un movimiento de banquillo del verano, para poder contarlo en la
/// pantalla de pretemporada.
class MovimientoDeEntrenador {
  final String equipo;
  final String? saliente;
  final String? entrante;

  /// True cuando el saliente no se ha ido a otro equipo: lo ha dejado.
  final bool seRetira;

  const MovimientoDeEntrenador({
    required this.equipo,
    this.saliente,
    this.entrante,
    this.seRetira = false,
  });
}

/// Victorias por debajo de las cuales un equipo de la CPU se plantea un
/// cambio de banquillo. Veintiocho de 82 es una temporada claramente mala
/// sin ser un desastre irrepetible.
const _victoriasQueSalvanElPuesto = 28;

/// Probabilidad de que un equipo de la CPU con una mala temporada eche al
/// entrenador. No es automático a propósito: en la NBA real una temporada
/// mala no siempre cuesta el puesto, y si lo fuera, cada verano habría
/// exactamente los mismos movimientos.
const _probabilidadDeDespido = 0.55;

/// Cuántos entrenadores libres se considera un mercado sano. Por debajo de
/// esto se generan nuevos: sin esto, al cabo de diez o quince temporadas se
/// habrían retirado todos los del asset y no quedaría a quién fichar.
const _minimoDeEntrenadoresLibres = 12;

/// El verano de los entrenadores: cumplen años, se les descuenta un año de
/// contrato (y de finiquito), los mayores lo dejan, los equipos de la CPU
/// que han ido mal se plantean un cambio, los que acaban contrato quedan
/// libres, y los bancos vacíos se llenan.
///
/// TU banquillo no se toca: si quieres cambiar de entrenador lo haces tú
/// desde su pantalla. Lo único que puede pasarte es que el tuyo se retire o
/// que se le acabe el contrato — las dos cosas te las cuenta el resumen de
/// pretemporada.
///
/// Va después de [envejecerLiga] en el cierre de temporada, para que la
/// media de plantilla que miran los candidatos sea ya la del año que viene.
Future<List<MovimientoDeEntrenador>> pasarElVeranoDeLosEntrenadores(
  AppDatabase db, {
  required String equipoUsuario,
  Random? random,
}) async {
  final rng = random ?? Random();
  final movimientos = <MovimientoDeEntrenador>[];

  // 1. Un año más, el récord de la temporada pasa a su carrera, y se
  //    descuenta un año de contrato y de finiquito. Este es el único sitio
  //    donde se suma el récord: durante el año se lee del de su equipo (ver
  //    [recordDeEstaTemporada]).
  final resultados = await db.select(db.resultadoTemporada).get();
  final recordPorEquipo = {
    for (final r in resultados) r.equipo: (r.victorias, r.derrotas),
  };

  final todos = await db.select(db.entrenadores).get();
  for (final e in todos) {
    if (e.equipo == equipoRetirados) continue;
    final delAno = recordPorEquipo[e.equipo] ?? (0, 0);
    final finiquitoRestante = max(0, e.aniosDeFiniquito - 1);
    await (db.update(db.entrenadores)..where((t) => t.id.equals(e.id)))
        .write(EntrenadoresCompanion(
      edad: Value(e.edad + 1),
      temporadas: Value(e.temporadas + (esFranquicia(e.equipo) ? 1 : 0)),
      victorias: Value(e.victorias + delAno.$1),
      derrotas: Value(e.derrotas + delAno.$2),
      aniosContrato:
          Value(esFranquicia(e.equipo) ? max(0, e.aniosContrato - 1) : 0),
      aniosDeFiniquito: Value(finiquitoRestante),
      equipoQuePagaFiniquito: finiquitoRestante == 0
          ? const Value(null)
          : Value(e.equipoQuePagaFiniquito),
    ));
  }

  // 2. Retiradas. Se decide sobre la edad ya cumplida.
  for (final e in todos) {
    if (e.equipo == equipoRetirados) continue;
    final edad = e.edad + 1;
    if (!_seRetira(edad, rng)) continue;
    await (db.update(db.entrenadores)..where((t) => t.id.equals(e.id)))
        .write(const EntrenadoresCompanion(
      equipo: Value(equipoRetirados),
      aniosContrato: Value(0),
    ));
    if (esFranquicia(e.equipo)) {
      movimientos.add(MovimientoDeEntrenador(
        equipo: e.equipo,
        saliente: e.nombreFicticio,
        seRetira: true,
      ));
    }
  }

  // 3. Contratos cumplidos: quien llega a cero años se queda libre. También
  //    el tuyo — pero a ti se te avisa y decides si le renuevas.
  //
  //    A los que salen de TU banquillo se les guarda el id: la CPU no puede
  //    firmarlos este verano. Es la misma cortesía que ya tiene la agencia
  //    libre de jugadores — si tu entrenador acabara contrato y otro equipo
  //    se lo llevara antes de que pudieras hablar con él, renovar no sería
  //    una decisión, sería una carrera que siempre pierdes.
  final tuyosQueQuedanLibres = <int>{};
  for (final e in await db.select(db.entrenadores).get()) {
    if (!esFranquicia(e.equipo) || e.aniosContrato > 0) continue;
    if (e.equipo == equipoUsuario) tuyosQueQuedanLibres.add(e.id);
    await (db.update(db.entrenadores)..where((t) => t.id.equals(e.id)))
        .write(const EntrenadoresCompanion(
      equipo: Value(equipoAgenciaLibre),
      salario: Value(0),
    ));
    movimientos.add(MovimientoDeEntrenador(
      equipo: e.equipo,
      saliente: e.nombreFicticio,
    ));
  }

  // 4. Despidos de la CPU. El tuyo no: tú decides.
  final victoriasPorEquipo = {
    for (final r in resultados) r.equipo: r.victorias,
  };
  for (final e in await db.select(db.entrenadores).get()) {
    if (!esFranquicia(e.equipo) || e.equipo == equipoUsuario) continue;
    final victorias = victoriasPorEquipo[e.equipo] ?? 41;
    if (victorias >= _victoriasQueSalvanElPuesto) continue;
    if (rng.nextDouble() >= _probabilidadDeDespido) continue;

    await despedirEntrenador(db, e.equipo);
    movimientos.add(MovimientoDeEntrenador(
      equipo: e.equipo,
      saliente: e.nombreFicticio,
    ));
  }

  // 5. Que no se seque el mercado. Con solo los del asset, al cabo de diez
  //    o quince veranos se habrían retirado todos.
  await generarEntrenadoresSiFaltan(db, random: rng);

  // 6. Los banquillos vacíos se llenan. El tuyo NO: que se te vaya el
  //    entrenador y aparezca otro puesto a dedo sería quitarte la decisión.
  final equipos = resultados.map((r) => r.equipo).where(esFranquicia).toList()
    ..sort();
  for (final equipo in equipos) {
    if (equipo == equipoUsuario) continue;
    if (await leerEntrenadorDe(db, equipo) != null) continue;

    final fichado = await _contratarAlMejorQueAcepte(db, equipo,
        intocables: tuyosQueQuedanLibres);
    if (fichado == null) continue;
    final indice = movimientos.indexWhere((m) => m.equipo == equipo);
    if (indice >= 0) {
      final previo = movimientos[indice];
      movimientos[indice] = MovimientoDeEntrenador(
        equipo: equipo,
        saliente: previo.saliente,
        entrante: fichado,
        seRetira: previo.seRetira,
      );
    } else {
      movimientos.add(
          MovimientoDeEntrenador(equipo: equipo, entrante: fichado));
    }
  }

  return movimientos;
}

/// Ficha para [equipo] al mejor libre que acepte el proyecto y quepa en su
/// presupuesto, y devuelve su nombre. Null si no lo coge nadie.
///
/// La CPU no regatea: ofrece lo que el entrenador pide, y si no le llega el
/// presupuesto pasa al siguiente. Es deliberado — si negociara como tú,
/// haría falta un modelo de "cuánto está dispuesto a apretar cada equipo"
/// que no aportaría nada visible desde fuera.
///
/// [intocables] son los que acaban de salir del banquillo del usuario: este
/// verano no se los puede llevar nadie, para que le dé tiempo a renovar.
Future<String?> _contratarAlMejorQueAcepte(
  AppDatabase db,
  String equipo, {
  Set<int> intocables = const {},
}) async {
  final tope = await maximoQuePuedesOfrecer(db, equipo);
  for (final candidato in await leerEntrenadoresLibres(db)) {
    if (intocables.contains(candidato.id)) continue;

    // Se ofrece lo que pide, o el tope si no llega. Ese recorte importa: un
    // equipo pasado de tope solo puede ofrecer el mínimo, igual que con los
    // jugadores, y entonces solo firmará quien acepte cobrarlo.
    //
    // Sin este min(), la CPU descartaba a todo el que pidiera más que su
    // tope y las franquicias pasadas de tope —seis desde el primer día— se
    // habrían quedado sin banquillo para siempre.
    final ofrecido = min(salarioQuePide(candidato), tope);
    final respuesta =
        await valorarOfertaDe(db, candidato, equipo, salario: ofrecido);
    if (!respuesta.acepta) continue;

    await (db.update(db.entrenadores)..where((t) => t.id.equals(candidato.id)))
        .write(EntrenadoresCompanion(
      equipo: Value(equipo),
      salario: Value(ofrecido),
      aniosContrato: Value(aniosQuePide(candidato)),
      equipoQuePagaFiniquito: const Value(null),
      aniosDeFiniquito: const Value(0),
    ));
    return candidato.nombreFicticio;
  }
  return null;
}

/// A partir de [edadDeRetiroDeEntrenador] la probabilidad de dejarlo crece
/// un 12% por año, y a [edadMaximaDeEntrenador] es segura. Repartido así
/// —en vez de con un corte seco— cada partida tiene sus propias retiradas.
bool _seRetira(int edad, Random rng) {
  if (edad >= edadMaximaDeEntrenador) return true;
  if (edad < edadDeRetiroDeEntrenador) return false;
  return rng.nextDouble() < (edad - edadDeRetiroDeEntrenador + 1) * 0.12;
}

/// Mete gente nueva en el mercado si se ha quedado corto.
///
/// Son entrenadores de primer trabajo: jóvenes, sin palmarés y de nivel
/// bajo-medio, como los que de verdad entran en la NBA desde un banquillo
/// de asistente. Los buenos no se generan: se hacen ganando partidos.
Future<void> generarEntrenadoresSiFaltan(
  AppDatabase db, {
  Random? random,
}) async {
  final rng = random ?? Random();
  final libres = await leerEntrenadoresLibres(db);
  final faltan = _minimoDeEntrenadoresLibres - libres.length;
  if (faltan <= 0) return;

  final usados =
      (await db.select(db.entrenadores).get()).map((e) => e.nombreFicticio).toSet();

  final nuevos = <EntrenadoresCompanion>[];
  for (var i = 0; i < faltan; i++) {
    // Alrededor de 60 de media, con una faceta destacada para que no salgan
    // todos iguales.
    final base = 55 + rng.nextInt(12);
    final destacada = rng.nextInt(3);
    int atributo(int cual) =>
        (base + (cual == destacada ? 6 + rng.nextInt(7) : rng.nextInt(7) - 3))
            .clamp(40, 99);

    nuevos.add(EntrenadoresCompanion.insert(
      nombreFicticio: nombreFicticioUnico(rng, usados),
      nombreReal: '',
      equipo: equipoAgenciaLibre,
      edad: 38 + rng.nextInt(12),
      atrAtaque: atributo(0),
      atrDefensa: atributo(1),
      atrDesarrollo: atributo(2),
      temporadas: const Value(0),
    ));
  }

  await db.batch((batch) => batch.insertAll(db.entrenadores, nuevos));
}

/// Rellena los banquillos que estén vacíos porque la partida viene de una
/// versión sin entrenadores: reparte a los libres por los equipos que no
/// tengan a nadie, sin mirar si aceptan el proyecto (aquí no hay decisión
/// que tomar, solo un hueco de datos que tapar).
///
/// El del usuario también, y a propósito: al abrir una partida vieja se
/// encuentra su banquillo cubierto como estaba en la vida real, no vacío.
Future<void> asignarEntrenadoresQueFalten(AppDatabase db) async {
  final ocupados = (await db.select(db.entrenadores).get())
      .map((e) => e.equipo)
      .where(esFranquicia)
      .toSet();
  final equipos = (await db.select(db.resultadoTemporada).get())
      .map((r) => r.equipo)
      .where(esFranquicia)
      .where((e) => !ocupados.contains(e))
      .toList()
    ..sort();
  if (equipos.isEmpty) return;

  final libres = await leerEntrenadoresLibres(db);
  for (var i = 0; i < equipos.length && i < libres.length; i++) {
    await (db.update(db.entrenadores)..where((t) => t.id.equals(libres[i].id)))
        .write(EntrenadoresCompanion(equipo: Value(equipos[i])));
  }
}

/// Le pone contrato a quien no lo tenga: al importar (que no trae sueldos) y
/// a las partidas que vienen de la versión anterior, donde la tabla existía
/// pero sin columnas de contrato.
///
/// Los que dirigen firman por lo que piden; los libres se quedan a cero,
/// que es lo correcto — un entrenador sin equipo no cobra de nadie.
Future<void> asignarContratosQueFalten(AppDatabase db) async {
  final sinContrato = await (db.select(db.entrenadores)
        ..where((t) => t.salario.equals(0)))
      .get();
  for (final e in sinContrato) {
    if (!esFranquicia(e.equipo)) continue;
    await (db.update(db.entrenadores)..where((t) => t.id.equals(e.id)))
        .write(EntrenadoresCompanion(
      salario: Value(salarioQuePide(e)),
      aniosContrato: Value(aniosQuePide(e)),
    ));
  }
}
