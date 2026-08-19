/// Las reglas de los entrenadores que no necesitan base de datos: cómo se
/// resume su nivel en un número, cuánto cobran, qué hace falta para
/// convencerles y cuándo se retiran. Aparte del repositorio para poder
/// probarlas sin montar una partida entera.
library;

import 'dart:math';

/// Peso de cada faceta en la media del entrenador.
///
/// Ataque y defensa pesan lo mismo y se llevan el grueso porque son las dos
/// que deciden partidos. El desarrollo pesa menos en el número que se
/// enseña, pero no porque importe poco: importa en otra escala de tiempo
/// (los veranos), y meterlo al mismo peso haría que un especialista en
/// canteras pareciera un entrenador de equipo campeón.
const _pesoAtaque = 0.40;
const _pesoDefensa = 0.40;
const _pesoDesarrollo = 0.20;

/// El número de 0 a 99 que resume a un entrenador, con el mismo criterio en
/// todas partes: la pantalla, el mercado y la CPU miran este.
int mediaDeEntrenador({
  required int ataque,
  required int defensa,
  required int desarrollo,
}) =>
    (ataque * _pesoAtaque + defensa * _pesoDefensa + desarrollo * _pesoDesarrollo)
        .round()
        .clamp(1, 99);

/// Cómo se describe a un entrenador en una línea, según en qué destaque.
/// Se compara cada faceta con las otras dos, no con la liga: lo que
/// interesa es qué clase de entrenador es, no si es bueno (para eso está la
/// media).
String estiloDeEntrenador({
  required int ataque,
  required int defensa,
  required int desarrollo,
}) {
  final maximo = [ataque, defensa, desarrollo].reduce((a, b) => a > b ? a : b);
  final minimo = [ataque, defensa, desarrollo].reduce((a, b) => a < b ? a : b);
  // Sin una faceta claramente por encima, es un entrenador equilibrado y
  // decirlo es más honesto que forzar una etiqueta.
  if (maximo - minimo < 6) return 'Equilibrado';
  if (maximo == ataque) return 'Especialista en ataque';
  if (maximo == defensa) return 'Especialista en defensa';
  return 'Formador de jóvenes';
}

// ---------------------------------------------------------------------------
// Dinero
// ---------------------------------------------------------------------------

/// Lo que cobra un entrenador del montón de la liga, y el techo de la
/// escala. Calibrado con los sueldos reales publicados: el mejor pagado de
/// la NBA ronda los 17-18M al año, un entrenador asentado 8-10M, uno recién
/// llegado 3-4M, y el suelo del oficio anda por los 2M.
const salarioMinimoEntrenador = 2000000;
const salarioMaximoEntrenador = 18000000;

/// Lo que pide un entrenador de [media] al año, en dólares.
///
/// La curva es convexa igual que la de los jugadores (ver salarios.dart):
/// entre un 55 y un 65 hay dos millones de diferencia, y entre un 80 y un
/// 90 hay ocho. El dinero se concentra arriba del todo, que es como
/// funciona el mercado de banquillos de verdad.
int salarioDeEntrenador(int media) {
  final porEncimaDelSuelo = max(0, media - 50) / 40.0;
  final bruto = salarioMinimoEntrenador +
      pow(porEncimaDelSuelo.clamp(0.0, 1.0), 2.2) *
          (salarioMaximoEntrenador - salarioMinimoEntrenador);
  // Se redondea a cien mil: un sueldo de "8.437.219" no lo publica nadie.
  return ((bruto / 100000).round() * 100000)
      .clamp(salarioMinimoEntrenador, salarioMaximoEntrenador);
}

// El sueldo del entrenador NO tiene un presupuesto aparte: entra en la masa
// salarial de la franquicia y compite con los jugadores, contra el mismo
// tope (ver `topeSalarial` y `masaSalarial`). El tope lleva 20M de margen
// justo por esto; el porqué de ese margen está explicado en salarios.dart.

/// Los años que pide un entrenador según su nivel y su edad. Un entrenador
/// de prestigio no firma por uno; uno de 68 años tampoco pide cinco.
int aniosPedidosPorEntrenador({required int media, required int edad}) {
  if (edad >= 64) return 2;
  if (media >= 82) return 4;
  if (media >= 70) return 3;
  return 2;
}

// ---------------------------------------------------------------------------
// Convencerle
// ---------------------------------------------------------------------------

/// Media de equipo (la de sus cinco mejores) que exige un entrenador del
/// montón, y cuánto sube esa exigencia por cada punto de su propia media.
///
/// Los dos números salen de MEDIR el dataset, no de estimarlos: las medias
/// de los cinco mejores de los 30 equipos van de 82 (BRK, LAC, MEM, SAC) a
/// 90 (PHI), con mediana 85. O sea que toda la liga cabe en 8 puntos, y una
/// exigencia que se mueva más rápido que eso deja el mercado en dos
/// extremos absurdos: o todos aceptan en todas partes, o no acepta nadie en
/// ninguna. Con estos valores:
///
///   un entrenador de 90 pide 87 ... le valen ~5 equipos
///   uno de 76 (la media) pide 84 . le vale la mitad de la liga
///   uno de 66 pide 82 ........... le vale cualquiera
const _mediaDeEquipoNeutra = 84.0;
const _cuantoMasPideElBueno = 0.22;

/// Lo que se resiste a moverse un entrenador que YA está dirigiendo a otro
/// equipo. No se le puede fichar como a uno parado: tiene trabajo, y para
/// dejarlo el proyecto nuevo tiene que ser claramente mejor.
///
/// Dos puntos, medidos sobre el recorrido real de la liga (las medias de los
/// cinco mejores van de 82 a 90). Con esta prima, y contando que el sueldo
/// tiene un techo de 18M que a los mejores ya les deja sin margen de
/// subida:
///
///   el mejor de la liga (media 90) .. le valen 6 de 30 proyectos, y el
///                                     dinero no le mueve: ya cobra el techo
///   uno muy bueno (media 88) ........ 9 de 30 a su precio, 14 pagando más
///   uno del montón (media 62) ....... se lo lleva cualquiera
///
/// Sin prima, pagando el máximo se lo llevaba cualquiera de los 30: robar
/// entrenadores salía gratis y la decisión desaparecía.
const primaPorTenerEquipo = 2.0;

/// Lo que se rebaja un formador de jóvenes: es justo el trabajo que sabe
/// hacer, y sin esta excepción los equipos en reconstrucción no podrían
/// fichar nunca a quien más falta les hace. Dos puntos sobre un recorrido de
/// ocho es mucho — le abre media docena larga de equipos.
const _rebajaDelFormador = 2.0;

/// Cuánto vale una victoria del año pasado, en puntos de media de equipo.
/// Una temporada de 60 sube algo menos de un punto y una de 20 baja otro
/// tanto: matiza, pero no sustituye a la plantilla.
const _valorDeUnaVictoria = 0.05;

/// Cuánto proyecto puede comprar el dinero, como máximo, y cuánto hay que
/// pasarse de su precio para llegar ahí.
///
/// El tope existe para que el mercado no se resuelva con la cartera: puedes
/// convencer a alguien de que tu equipo es un punto o dos peor de lo que él
/// querría, no de que un equipo de 82 es un aspirante al anillo. Sin el
/// tope, bastaría con subir el deslizador al máximo para llevarte al mejor
/// entrenador de la liga a la peor plantilla, y la decisión desaparecería.
const maxPuntosQueCompraElDinero = 4.0;
const _sobreprecioParaElMaximo = 0.6;

/// Y lo que mueven los años: ofrecerle menos de los que pide le echa para
/// atrás bastante más de lo que le atrae ofrecerle de más. Un entrenador
/// quiere estabilidad para hacer su trabajo; un año extra está bien, pero
/// dos años menos de los que pedía es una desconfianza que se nota.
const _puntosPorAnio = 0.6;
const _maxPuntosPorAniosDeMas = 1.2;
const _minPuntosPorAniosDeMenos = -2.0;

/// Edad a partir de la cual un entrenador puede colgar la carpeta. No es un
/// corte duro: por encima de esta edad se retira con una probabilidad que
/// crece cada año (ver `pasarElVeranoDeLosEntrenadores`). Popovich dirigió
/// hasta los 76, así que el tope duro se pone algo por encima.
const edadDeRetiroDeEntrenador = 66;
const edadMaximaDeEntrenador = 77;

/// Lo que exige el entrenador, en media de equipo.
double exigenciaDeProyecto({
  required int mediaDelEntrenador,
  required int desarrolloDelEntrenador,
  bool yaTieneEquipo = false,
}) {
  var exigencia = _mediaDeEquipoNeutra +
      (mediaDelEntrenador - 76) * _cuantoMasPideElBueno;
  if (desarrolloDelEntrenador >= 80) exigencia -= _rebajaDelFormador;
  if (yaTieneEquipo) exigencia += primaPorTenerEquipo;
  return exigencia;
}

/// Lo que suma o resta el récord, con 41-41 como punto neutro.
///
/// Ojo al caso de los cero partidos, que es el que revienta si se olvida:
/// al empezar una temporada TODOS los equipos van 0-0, y contar eso como
/// "una temporada de 0 victorias" ponía a la liga entera 5 puntos por
/// debajo de lo que pide cualquiera. Resultado: en el año 1 no había un
/// solo entrenador dispuesto a firmar por nadie. Sin partidos no hay
/// juicio que hacer, así que el récord no cuenta.
///
/// Y a mitad de temporada se proyecta a 82: un 5-15 es un ritmo de 20
/// victorias, no un año de 5.
double tironDelRecord(int victorias, int derrotas) {
  final jugados = victorias + derrotas;
  if (jugados == 0) return 0;
  final proyectadas = victorias / jugados * 82;
  return (proyectadas - 41) * _valorDeUnaVictoria;
}

/// Cuántos puntos de proyecto compra (o destruye) la oferta económica.
/// [sobreprecio] es `salario / pedido - 1`: 0,2 es un 20% por encima de lo
/// que pide, -0,3 es un 30% por debajo.
double compensacionPorDinero(double sobreprecio) =>
    (sobreprecio / _sobreprecioParaElMaximo).clamp(-1.5, 1.0) *
    maxPuntosQueCompraElDinero;

/// Lo que mueven los años ofrecidos frente a los que pedía.
double efectoDeLosAnios({required int ofrecidos, required int pedidos}) =>
    ((ofrecidos - pedidos) * _puntosPorAnio)
        .clamp(_minPuntosPorAniosDeMenos, _maxPuntosPorAniosDeMas);

/// La respuesta del entrenador a una oferta concreta, con el motivo.
class RespuestaDelEntrenador {
  final bool acepta;

  /// Cuánto le falta al proyecto para convencerle, en puntos de media de
  /// equipo. Negativo o cero cuando acepta. Sirve para poder decirle al
  /// usuario si está cerca o si no hay dinero que lo arregle.
  final double loQueFalta;

  const RespuestaDelEntrenador({required this.acepta, required this.loQueFalta});
}

/// ¿Acepta este entrenador dirigir a un equipo así, por ese dinero y esos
/// años?
///
/// La regla en una frase: cuanto mejor es el entrenador, mejor tiene que
/// ser el proyecto — y el dinero puede tapar parte de la diferencia, pero
/// solo parte (ver [maxPuntosQueCompraElDinero]).
///
/// Es DETERMINISTA, a diferencia de la negociación con jugadores, que va
/// por probabilidad. Y es a propósito: un entrenador se ficha una vez al
/// año, no cuarenta veces como en el mercado de jugadores. Que una decisión
/// tan aislada se resolviera con un dado dejaría al usuario sin saber nunca
/// si le faltó dinero, proyecto o suerte; así puede subir la oferta y ver
/// exactamente dónde está la línea.
RespuestaDelEntrenador valorarOferta({
  required int mediaDelEntrenador,
  required int desarrolloDelEntrenador,
  required int mediaDelEquipo,
  required int victorias,
  required int derrotas,
  required int salarioOfrecido,
  required int salarioPedido,
  required int aniosOfrecidos,
  required int aniosPedidos,
  bool yaTieneEquipo = false,
}) {
  final exigencia = exigenciaDeProyecto(
    mediaDelEntrenador: mediaDelEntrenador,
    desarrolloDelEntrenador: desarrolloDelEntrenador,
    yaTieneEquipo: yaTieneEquipo,
  );
  final ofrecido = mediaDelEquipo +
      tironDelRecord(victorias, derrotas) +
      compensacionPorDinero(salarioOfrecido / salarioPedido - 1) +
      efectoDeLosAnios(ofrecidos: aniosOfrecidos, pedidos: aniosPedidos);

  return RespuestaDelEntrenador(
    acepta: ofrecido >= exigencia,
    loQueFalta: exigencia - ofrecido,
  );
}

/// Cuánto acelera (o frena) el entrenador el crecimiento de un jugador
/// joven, como multiplicador del salto que daría por su cuenta.
///
/// Un desarrollo de 76 —la media de la liga— deja el crecimiento
/// exactamente como estaba antes de que existieran los entrenadores. El
/// mejor formador lo sube un ~20% y el peor lo baja otro tanto: se nota a
/// lo largo de una reconstrucción de varios años, que es la escala en la
/// que un entrenador desarrolla a alguien, pero no convierte a un rookie en
/// estrella en un solo verano.
double factorDeDesarrollo(int? desarrollo) {
  if (desarrollo == null) return 1.0;
  return (1.0 + (desarrollo - 76) / 16 * 0.20).clamp(0.75, 1.25);
}
