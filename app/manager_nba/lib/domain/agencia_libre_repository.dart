import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'calendario_repository.dart' show fechaActualDeLaLiga;
import 'contratos_repository.dart';
import 'draft_repository.dart';
import 'equipos_especiales.dart';
import 'franquicia_repository.dart';
import 'posiciones.dart';
import 'salarios.dart';

/// Todos los agentes libres, de mejor a peor.
Future<List<Jugador>> agentesLibres(AppDatabase db) {
  return (db.select(db.jugadores)
        ..where((t) =>
            t.equipo.equals(equipoAgenciaLibre) & t.retirado.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.media)]))
      .get();
}

/// Cuántos jugadores tiene [equipo] ahora mismo.
Future<int> tamanoDePlantilla(AppDatabase db, String equipo) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false)))
      .get();
  return plantilla.length;
}

/// Qué le falta a [equipo] para poder afrontar la temporada: número de
/// fichajes pendientes y puestos sin recambio. Mientras esto no esté a
/// cero no se puede empezar a jugar.
///
/// Hay dos listones, y la diferencia entre ellos costaba temporadas
/// enteras. [plantillaLista] es el mínimo legal ([plantillaMinima], 13):
/// por debajo de eso no se puede ni salir a la pista. [plantillaAlCompleto]
/// es el tamaño con el que de verdad juega la liga ([plantillaMaxima], 18),
/// que es donde acaban las 29 plantillas de la CPU cada verano.
///
/// Antes solo existía el primero, y la pantalla de agencia libre te decía
/// "plantilla lista" en cuanto llegabas a 13 — cinco jugadores por debajo
/// de todos tus rivales, todos los años y sin avisar. Medido sobre cuatro
/// temporadas con la misma semilla, el mismo equipo hacía 38-44 quedándose
/// en 13-16 y 50-32 completando hasta 18, con la media de sus ocho mejores
/// subiendo de 81,0 a 87,0.
class HuecosDePlantilla {
  final int fichajesQueFaltan;

  /// Cuántos faltan para llegar al tamaño con el que juega el resto de la
  /// liga. No bloquea nada: es lo que hay que enseñar para que la decisión
  /// de quedarse corto sea tuya y no una sorpresa.
  final int fichajesRecomendados;

  final List<String> puestosSinCubrir;

  const HuecosDePlantilla({
    required this.fichajesQueFaltan,
    required this.fichajesRecomendados,
    required this.puestosSinCubrir,
  });

  bool get plantillaLista => fichajesQueFaltan <= 0 && puestosSinCubrir.isEmpty;

  bool get plantillaAlCompleto =>
      fichajesRecomendados <= 0 && puestosSinCubrir.isEmpty;
}

Future<HuecosDePlantilla> huecosDePlantilla(
  AppDatabase db,
  String equipo,
) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false)))
      .get();

  final sinCubrir = [
    for (final puesto in posicionesEquipo)
      if (plantilla.where((j) => juegaComodoDe(j, puesto)).length < 2) puesto,
  ];

  return HuecosDePlantilla(
    fichajesQueFaltan: plantillaMinima - plantilla.length,
    fichajesRecomendados: plantillaMaxima - plantilla.length,
    puestosSinCubrir: sinCubrir,
  );
}

/// Lo que pide un agente libre por firmar. Los que llevan tiempo sin
/// equipo (ya rechazaron ofertas) rebajan sus pretensiones.
int precioDeAgenteLibre(Jugador jugador) => valorDeMercado(jugador);

/// Ficha a [jugadorId] para [equipo]. Devuelve null si no se puede (no hay
/// espacio salarial y no es un contrato del mínimo), o el salario firmado.
///
/// Con [salario] nulo se firma por su precio de mercado; si no cabe bajo el
/// tope, se intenta por el mínimo.
Future<int?> ficharAgenteLibre(
  AppDatabase db, {
  required int jugadorId,
  required String equipo,
  int? salario,
  int? anios,
}) async {
  final jugador = await (db.select(db.jugadores)
        ..where((t) => t.id.equals(jugadorId)))
      .getSingleOrNull();
  if (jugador == null || jugador.equipo != equipoAgenciaLibre) return null;

  final precio = salario ?? precioDeAgenteLibre(jugador);
  if (!await puedeAsumir(db, equipo, precio)) return null;

  final aniosFirmados = anios ?? aniosContratoEstimados(edad: jugador.edad);
  final fechaFichaje = await fechaActualDeLaLiga(db) ?? DateTime.now();
  await (db.update(db.jugadores)..where((t) => t.id.equals(jugadorId)))
      .write(JugadoresCompanion(
    equipo: Value(equipo),
    salario: Value(precio),
    aniosContrato: Value(aniosFirmados),
    ofertasRechazadas: const Value(0),
    // El dorsal se reasigna aquí debajo: el suyo puede estar cogido.
    dorsal: const Value(null),
    fechaFichaje: Value(fechaFichaje),
  ));

  await sanearTrasMovimientoDePlantilla(db);
  return precio;
}

/// Cómo ha ido una oferta a un agente libre.
class RespuestaFichaje {
  final bool aceptada;
  final int ofertasRechazadas;
  final String mensaje;

  const RespuestaFichaje({
    required this.aceptada,
    required this.ofertasRechazadas,
    required this.mensaje,
  });

  bool get quedanOfertas => ofertasRechazadas < maxOfertasDeRenovacion;
}

/// Le ofrece a [jugadorId] —un agente libre— firmar por [salario] al año
/// durante [anios]. Es la versión de fichaje de [ofrecerRenovacion]: mismo
/// tira y afloja (hasta [maxOfertasDeRenovacion] ofertas, la psicología de
/// [probabilidadDeAceptar]), pero sin un contrato previo que liberar — un
/// fichaje por su precio de mercado no es un clic automático, es una
/// negociación como cualquier otra.
Future<RespuestaFichaje> ofrecerContratoFichaje(
  AppDatabase db,
  int jugadorId, {
  required String equipo,
  required int salario,
  required int anios,
  Random? random,
}) async {
  final rng = random ?? Random();
  final jugador = await (db.select(db.jugadores)
        ..where((t) => t.id.equals(jugadorId)))
      .getSingle();

  if (jugador.equipo != equipoAgenciaLibre) {
    return RespuestaFichaje(
      aceptada: false,
      ofertasRechazadas: jugador.ofertasRechazadas,
      mensaje: '${jugador.nombreFicticio} ya no está libre.',
    );
  }

  if (jugador.ofertasRechazadas >= maxOfertasDeRenovacion) {
    return RespuestaFichaje(
      aceptada: false,
      ofertasRechazadas: jugador.ofertasRechazadas,
      mensaje: 'Ya no quiere seguir negociando contigo.',
    );
  }

  if (!await puedeAsumir(db, equipo, salario)) {
    return RespuestaFichaje(
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
    final fechaFichaje = await fechaActualDeLaLiga(db) ?? DateTime.now();
    await (db.update(db.jugadores)..where((t) => t.id.equals(jugadorId)))
        .write(JugadoresCompanion(
      equipo: Value(equipo),
      salario: Value(salario),
      aniosContrato: Value(anios),
      ofertasRechazadas: const Value(0),
      // El dorsal se reasigna en el saneo: el suyo puede estar cogido aquí.
      dorsal: const Value(null),
      fechaFichaje: Value(fechaFichaje),
    ));
    await sanearTrasMovimientoDePlantilla(db, random: rng);
    return RespuestaFichaje(
      aceptada: true,
      ofertasRechazadas: 0,
      mensaje: '${jugador.nombreFicticio} firma por $anios '
          '${anios == 1 ? 'temporada' : 'temporadas'}.',
    );
  }

  final penalizacion = ratio < 0.75 ? 2 : 1;
  final rechazadas =
      min(maxOfertasDeRenovacion, jugador.ofertasRechazadas + penalizacion);
  await (db.update(db.jugadores)..where((t) => t.id.equals(jugadorId)))
      .write(JugadoresCompanion(ofertasRechazadas: Value(rechazadas)));

  return RespuestaFichaje(
    aceptada: false,
    ofertasRechazadas: rechazadas,
    mensaje: ratio < 0.75
        ? '${jugador.nombreFicticio} se ha tomado la oferta como un insulto.'
        : '${jugador.nombreFicticio} la rechaza: esperaba algo más.',
  );
}

/// La agencia libre de los 29 equipos de la CPU: cada uno ficha lo mejor
/// que puede pagar hasta tener una plantilla de verdad, empezando por los
/// puestos que le falten.
///
/// Sin esto, el mercado se atascaba de forma absurda: `resolverVencimientos
/// DeLaCpu` soltaba a todo el que un equipo no pudiera pagar, pero nadie
/// volvía a fichar jamás — solo tu equipo llamaba a
/// [completarPlantillaConElMinimo]. Temporada a temporada la agencia libre
/// se llenaba de estrellas sin equipo (115 → 173 → 218 agentes libres, de
/// ellos 15 → 28 → 35 con media 80+) mientras tu plantilla se deshacía y la
/// liga se volvía injugable.
///
/// Se ficha por orden de calidad y respetando el tope salarial, así que un
/// equipo arruinado seguirá firmando mínimos: lo que no puede pasar es que
/// un jugador de 90 se quede en la calle todo el año.
/// [claseDelDraft] es el año de la hornada que acaba de entrar, para que al
/// hacer sitio a una estrella no se suelte justo a los recién elegidos.
Future<void> completarPlantillasDeLaCpu(
  AppDatabase db, {
  required String equipoUsuario,
  int? claseDelDraft,
  bool respetarTuVentana = false,
  Random? random,
}) async {
  final equipos = (await db.select(db.jugadores).get())
      .map((j) => j.equipo)
      .where(esFranquicia)
      .where((e) => e != equipoUsuario)
      .toSet();

  for (final equipo in equipos) {
    while (true) {
      final huecos = await huecosDePlantilla(db, equipo);
      if (huecos.plantillaLista) break;

      var libres = await agentesLibres(db); // ya vienen de mejor a peor
      if (respetarTuVentana) {
        libres =
            libres.where((j) => j.media < _mediaQueNoSeQuedaLibre).toList();
      }
      if (libres.isEmpty) break;

      final puesto = huecos.puestosSinCubrir.isEmpty
          ? null
          : huecos.puestosSinCubrir.first;
      final candidatos = puesto == null
          ? libres
          : libres.where((j) => juegaComodoDe(j, puesto)).toList();
      if (candidatos.isEmpty) break;

      // El mejor que de verdad quepa en su tope; si ninguno cabe por su
      // precio, se tira del mínimo (que siempre se puede firmar).
      Jugador? fichado;
      for (final candidato in candidatos) {
        final firmado = await ficharAgenteLibre(db,
            jugadorId: candidato.id, equipo: equipo);
        if (firmado != null) {
          fichado = candidato;
          break;
        }
      }
      fichado ??= await _ficharPorElMinimo(db, equipo, candidatos);
      if (fichado == null) break;
    }

    final huecos = await huecosDePlantilla(db, equipo);
    if (!huecos.plantillaLista) {
      await generarRellenoDeUrgencia(db, equipo, random: random);
    }
  }

  if (respetarTuVentana) return;
  // Tu ventana ya está cerrada, así que tu equipo entra en el reparto como
  // uno más. No es fichar por ti a mitad de tu turno: es que, terminado el
  // verano, tu oficina hace su trabajo igual que las otras 29.
  await colocarAgentesLibresDeNivel(db,
      equipoUsuario: equipoUsuario,
      claseDelDraft: claseDelDraft,
      incluirAlUsuario: true);
}

/// Nivel a partir del cual un agente libre no puede quedarse sin equipo: en
/// la NBA real un jugador de este nivel firma en cuanto sale al mercado.
const _mediaQueNoSeQuedaLibre = 76;

/// A partir de aquí un agente libre es una estrella, y a las estrellas las
/// fichas tú o no las fichas: tu oficina no firma a nadie de este nivel por
/// su cuenta. Por debajo sí, para que un verano desatendido no te deje sin
/// rotación (ver [colocarAgentesLibresDeNivel]).
const _mediaDeEstrellaQueFichasTu = 82;

/// Reparte a los agentes libres buenos entre los equipos que tengan sitio.
///
/// Cubrir los mínimos no basta: con plantillas de 13-18 todos los equipos
/// están "completos" según [huecosDePlantilla], así que las estrellas que
/// caían al mercado se quedaban ahí temporada tras temporada. Aquí se les
/// busca equipo de verdad, del mejor jugador al peor, ofreciéndoselo al
/// equipo con más espacio salarial que pueda pagarle.
/// También se usa DURANTE la temporada, al cruzarse la fecha límite de
/// agencia libre (ver `calendario_repository.dart`). Hace falta porque el
/// dataset arranca con gente de nivel ya en el mercado —Harden con 88 y
/// DeRozan con 84 empiezan como agentes libres— y este reparto solo corría
/// en verano: en la temporada 1 se pasaban el año entero sin equipo. Al
/// engancharlo a la fecha límite, tú tienes toda la ventana para ficharlos
/// primero y, si no lo haces, se los lleva la liga.
/// [incluirAlUsuario] mete también a tu equipo en el reparto, pero solo
/// para jugadores por debajo de [_mediaDeEstrellaQueFichasTu]. Únicamente
/// se usa al cerrar tu ventana de mercado en verano, nunca en temporada.
///
/// Hace falta porque tu equipo era el único de la liga sin mecanismo de
/// reequilibrio: las 29 franquicias de la CPU convierten su espacio
/// salarial en jugadores cada verano y la tuya no, así que un año malo se
/// convertía en una espiral sin suelo. Medido sobre cuatro temporadas con
/// la misma semilla, un usuario que renovaba a los suyos pero no firmaba
/// agentes libres acababa 3-79 con la masa salarial en 120M y 150M sin
/// gastar, mientras la liga se movía en 200M.
///
/// El tope es igual de importante que el reparto. Sin él —dejando que tu
/// equipo optase también a las estrellas— la medición se iba al otro
/// extremo: el usuario que no tocaba nada acababa 59-23 con la mejor
/// plantilla de la liga, o sea que jugar el mercado dejaba de servir para
/// nada. Con el tope, tu oficina te tapa agujeros con rotación decente y
/// las estrellas siguen siendo cosa tuya.
Future<int> colocarAgentesLibresDeNivel(
  AppDatabase db, {
  required String equipoUsuario,
  int? claseDelDraft,
  bool incluirAlUsuario = false,
}) async {
  final todos = (await db.select(db.jugadores).get())
      .map((j) => j.equipo)
      .where(esFranquicia)
      .toSet()
      .toList();
  final soloCpu = todos.where((e) => e != equipoUsuario).toList();

  var colocados = 0;
  for (final jugador in await agentesLibres(db)) {
    if (jugador.media < _mediaQueNoSeQuedaLibre) break; // vienen ordenados

    final equipos = incluirAlUsuario &&
            jugador.media < _mediaDeEstrellaQueFichasTu
        ? todos
        : soloCpu;

    // Se le ofrece al que más margen tenga: es quien de verdad puede
    // permitírselo y a quien más le pesa un hueco en la plantilla.
    final conSitio = <String, int>{};
    for (final equipo in equipos) {
      if (await tamanoDePlantilla(db, equipo) >= plantillaMaxima) continue;
      conSitio[equipo] = await espacioSalarial(db, equipo);
    }
    // Con las 30 plantillas al tope no hay hueco literal, pero eso no
    // significa que un jugador de este nivel se quede sin equipo: alguien
    // corta a su duodécimo hombre para meterlo, como en la NBA.
    if (conSitio.isEmpty) {
      final equipo = await _cortarParaHacerSitio(db, equipos, jugador.media,
          claseDelDraft: claseDelDraft);
      // `continue`, no `break`: que a ESTE no le encuentren sitio no puede
      // dejar en la calle a todos los que vienen detrás, que son peores y
      // por tanto más fáciles de colocar.
      if (equipo == null) continue;
      conSitio[equipo] = await espacioSalarial(db, equipo);
    }

    final porMargen = conSitio.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var colocado = false;
    for (final candidato in porMargen) {
      final firmado = await ficharAgenteLibre(db,
          jugadorId: jugador.id, equipo: candidato.key);
      if (firmado != null) {
        colocado = true;
        break;
      }
    }

    // Si a estas alturas de verano nadie puede pagarle lo que vale, acaba
    // firmando por el mínimo con quien tenga más margen — que es justo lo
    // que hacen los veteranos buenos en la NBA real cuando se quedan sin
    // mercado. Lo que no puede ser es que se pase el año en su casa.
    if (!colocado) {
      await ficharAgenteLibre(db,
          jugadorId: jugador.id,
          equipo: porMargen.first.key,
          salario: salarioMinimo);
    }
    colocados++;
  }
  return colocados;
}

/// Busca el equipo cuyo peor jugador esté lo bastante por debajo de [media]
/// como para que valga la pena cortarlo, lo manda a la agencia libre y
/// devuelve ese equipo. Null si a nadie le compensa.
///
/// El margen evita el carrusel: un equipo no corta a su duodécimo para
/// firmar a alguien que juega igual de bien, solo si la mejora es clara.
///
/// El orden de corte es el de [tandaDeCorte], no la media a secas. Yendo
/// por media pura el candidato era siempre el rookie recién drafteado —el
/// peor de la plantilla el día que llega—, así que esta función se llevaba
/// por delante media clase de draft cada verano para hacer sitio a las
/// estrellas libres: trazando un verano entero, de los 60 elegidos salían
/// 23 a la agencia libre aquí mismo, sin haber jugado un partido, y era la
/// única puerta por la que se caían.
Future<String?> _cortarParaHacerSitio(
  AppDatabase db,
  List<String> equipos,
  int media, {
  int? claseDelDraft,
}) async {
  const mejoraMinima = 8;

  int ordenDeCorte(Jugador a, Jugador b) {
    final porTanda = tandaDeCorte(a, claseDelDraft: claseDelDraft)
        .compareTo(tandaDeCorte(b, claseDelDraft: claseDelDraft));
    return porTanda != 0 ? porTanda : a.media.compareTo(b.media);
  }

  String? mejorEquipo;
  Jugador? aCortar;
  for (final equipo in equipos) {
    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false)))
        .get()
      ..sort(ordenDeCorte);
    if (plantilla.isEmpty) continue;

    // Por ese orden, el primero que se pueda soltar sin dejar un puesto
    // descubierto: cortar al duodécimo está bien, quedarse sin ningún alero
    // de recambio no.
    for (final candidato in plantilla) {
      // Aquí va `continue` y no `break`: la lista ya no está ordenada por
      // media, así que un candidato que no compense no significa que los
      // siguientes tampoco.
      if (media - candidato.media < mejoraMinima) continue;
      final quedan = plantilla.where((j) => j.id != candidato.id);
      final dejaHueco = posicionesEquipo.any(
          (p) => quedan.where((j) => juegaComodoDe(j, p)).length < 2);
      if (dejaHueco) continue;
      if (aCortar == null || ordenDeCorte(candidato, aCortar) < 0) {
        aCortar = candidato;
        mejorEquipo = equipo;
      }
      break;
    }
  }

  if (aCortar == null) return null;
  await mandarAAgenciaLibre(db, [aCortar.id]);
  return mejorEquipo;
}

/// Edad a la que un jugador que lleva todo el verano sin que le suene el
/// teléfono cuelga las botas. No es la edad de retiro normal (esa es de
/// cada jugador, y llega bastante más tarde): es la de quien ya no juega
/// porque nadie lo quiere.
const _edadDeRetiroSinEquipo = 32;

/// Cuántos agentes libres sobreviven al cierre del mercado de verano. Es el
/// tamaño que tenía el mercado de forma natural tras el primer verano, así
/// que es la foto de una agencia libre sana: profundidad de sobra para
/// completar cualquier plantilla sin convertir la pantalla en un listín.
const maxAgentesLibres = 100;

/// Hasta esta edad a un agente libre se le mira el techo y no solo lo que
/// es hoy (ver `_edadFinDeCrecimiento` en progresion_repository.dart).
const _edadDeProyecto = 27;

/// Cierra el verano vaciando la agencia libre de quien ya no pinta nada en
/// la liga.
///
/// Sin esto el mercado crece y no para: cada draft mete 60 jugadores nuevos,
/// las 30 plantillas están capadas a [plantillaMaxima] (540 plazas en toda
/// la liga) y las retiradas por edad no se llevan tantos como entran, así
/// que el excedente cae aquí y no sale jamás. Medido con 4 cambios de
/// temporada seguidos: 98 → 153 → 205 → 257 agentes libres, +52 cada año y
/// sin techo — la pantalla de agencia libre acababa siendo una lista
/// interminable de nombres irrelevantes y cada recorrido del mercado (que
/// son unos cuantos por verano) más lento que el anterior.
///
/// Se limpia por dos vías, y siempre DESPUÉS de que los 30 equipos hayan
/// hecho su mercado: a estas alturas del verano ya no queda nadie por
/// firmar a nadie, así que no se retira a quien fuera a tener equipo.
///
/// - Quien llega a [_edadDeRetiroSinEquipo] sin que nadie lo haya querido lo
///   deja, que es lo que pasa de verdad con un veterano que se queda sin
///   mercado.
/// - Del resto se quedan los [maxAgentesLibres] mejores; los demás
///   desaparecen de la liga (en la NBA real acaban jugando fuera).
///
/// De [_mediaQueNoSeQuedaLibre] para arriba no se toca a nadie por ninguna
/// de las dos vías: que un jugador de ese nivel siga libre es un fallo del
/// mercado —lo cubre [_mercadoDeEstrellasLibres]—, no un motivo para
/// retirarlo.
///
/// Devuelve los retirados: hay que pasarlos por el Hall of Fame, porque una
/// leyenda venida a menos puede acabar sus días sin equipo y su carrera
/// sigue contando igual.
Future<List<Jugador>> depurarAgenciaLibre(AppDatabase db) async {
  final retirados = <Jugador>[];
  final siguen = <Jugador>[];
  for (final jugador in await agentesLibres(db)) {
    if (jugador.media < _mediaQueNoSeQuedaLibre &&
        jugador.edad >= _edadDeRetiroSinEquipo) {
      retirados.add(jugador);
    } else {
      siguen.add(jugador);
    }
  }

  // El cupo se reparte por lo que cada uno puede llegar a dar, no solo por
  // su media de hoy: un proyecto de 20 años con techo alto es justo el tipo
  // de agente libre que interesa tener en la lista, y ordenando por media
  // pura lo adelantaría cualquier veterano de rotación corta.
  siguen.sort((a, b) => _techoDeMercado(b).compareTo(_techoDeMercado(a)));
  if (siguen.length > maxAgentesLibres) {
    retirados.addAll(siguen.sublist(maxAgentesLibres));
  }

  if (retirados.isNotEmpty) {
    await (db.update(db.jugadores)
          ..where((t) => t.id.isIn(retirados.map((j) => j.id).toList())))
        .write(const JugadoresCompanion(
      retirado: Value(true),
      equipo: Value(equipoRetirados),
      dorsal: Value(null),
    ));
  }
  return retirados;
}

/// Lo que vale un agente libre a la hora de repartir el cupo. El potencial
/// del dataset viene por debajo de la media en más de la mitad de los
/// jugadores importados (se generó como "cuánto le queda por crecer"), así
/// que se toma el mayor de los dos — ver la nota en `_mediaTrasUnAno`.
int _techoDeMercado(Jugador j) =>
    j.edad < _edadDeProyecto ? max(j.media, j.potencial) : j.media;

/// Último recurso cuando nadie cabe bajo el tope: el peor de los candidatos
/// por el salario mínimo, que es la excepción que siempre se puede firmar.
Future<Jugador?> _ficharPorElMinimo(
  AppDatabase db,
  String equipo,
  List<Jugador> candidatos,
) async {
  final elegido = candidatos.last;
  final firmado = await ficharAgenteLibre(db,
      jugadorId: elegido.id, equipo: equipo, salario: salarioMinimo);
  return firmado == null ? null : elegido;
}

/// Completa la plantilla de [equipo] hasta el mínimo fichando por el
/// salario mínimo a agentes libres que estén dispuestos a cobrarlo,
/// priorizando los puestos que estén sin cubrir. Es el botón de "arréglalo
/// tú" para no tener que ir uno a uno.
///
/// [hasta] sube el listón por encima del mínimo (por ejemplo hasta
/// [plantillaMaxima], que es donde acaba la liga entera): sigue firmando
/// por el mínimo mientras la plantilla no llegue a ese tamaño.
///
/// Devuelve los fichados.
Future<List<Jugador>> completarPlantillaConElMinimo(
  AppDatabase db,
  String equipo, {
  int? hasta,
  Random? random,
}) async {
  final fichados = <Jugador>[];
  final objetivo = hasta ?? plantillaMinima;

  while (true) {
    final huecos = await huecosDePlantilla(db, equipo);
    if (huecos.plantillaLista &&
        await tamanoDePlantilla(db, equipo) >= objetivo) {
      break;
    }

    final libres = await agentesLibres(db);
    if (libres.isEmpty) break;

    // Si falta cubrir un puesto, se busca a alguien de ese puesto; si no,
    // simplemente al mejor disponible que acepte el mínimo.
    final puesto =
        huecos.puestosSinCubrir.isEmpty ? null : huecos.puestosSinCubrir.first;

    // NUNCA una estrella por esta vía. Esto es la red de seguridad para que
    // no te quedes sin plantilla, no una forma de que te regalen un 87 por
    // el salario mínimo.
    //
    // El bug que arregla: al filtrar por un puesto vacante, si el único
    // agente libre que lo cubría era una estrella, `.last` era esa estrella
    // y se firmaba por el mínimo del convenio. Salía una de cada tres
    // partidas simuladas y te aparecía un titular de nivel All-Star en la
    // plantilla sin haber hecho nada.
    List<Jugador> sinEstrellas(List<Jugador> xs) =>
        xs.where((j) => j.media < _mediaDeEstrellaQueFichasTu).toList();

    var candidatos = sinEstrellas(puesto == null
        ? libres
        : libres.where((j) => juegaComodoDe(j, puesto)).toList());

    // Si ese puesto solo lo cubre una estrella, se deja sin cubrir y se
    // rellena con quien sea: jugar a alguien fuera de posición cuesta un
    // 10% (ver factorDePuesto), regalar un 87 desequilibra la partida.
    if (candidatos.isEmpty && puesto != null) {
      candidatos = sinEstrellas(libres);
      // Y si ya se llegó al tamaño objetivo, no hay nada más que hacer:
      // seguir fichando para tapar un hueco imposible vaciaría el mercado.
      if (await tamanoDePlantilla(db, equipo) >= objetivo) break;
    }
    if (candidatos.isEmpty) break;

    // Por el mínimo solo firman los que no valen mucho más que eso: nadie
    // de primer nivel acepta el sueldo de convenio.
    final asequibles = candidatos
        .where((j) => precioDeAgenteLibre(j) <= salarioMinimo * 3)
        .toList();
    final elegido =
        (asequibles.isEmpty ? candidatos : asequibles).last;

    final firmado = await ficharAgenteLibre(db,
        jugadorId: elegido.id, equipo: equipo, salario: salarioMinimo);
    if (firmado == null) break;
    fichados.add(elegido);
  }

  // Si la agencia libre se ha quedado sin nadie útil (carrera muy larga,
  // mercado seco), se generan jugadores de relleno para que el equipo
  // pueda jugar igualmente.
  final huecos = await huecosDePlantilla(db, equipo);
  if (!huecos.plantillaLista) {
    await generarRellenoDeUrgencia(db, equipo, random: random);
  }

  return fichados;
}
