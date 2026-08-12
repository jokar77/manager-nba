/// Las reglas de los entrenadores que no necesitan base de datos: cómo se
/// resume su nivel en un número, qué hace falta para convencerles y cuándo
/// se retiran. Aparte del repositorio para poder probarlas sin montar una
/// partida entera.
library;

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

/// Edad a partir de la cual un entrenador puede colgar la carpeta. No es un
/// corte duro: por encima de esta edad se retira con una probabilidad que
/// crece cada año (ver `retiradasDeEntrenadores`). Popovich dirigió hasta
/// los 76, así que el tope duro se pone algo por encima.
const edadDeRetiroDeEntrenador = 66;
const edadMaximaDeEntrenador = 77;

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
///
/// Es la única barrera para fichar: no hay dinero de por medio porque el
/// tope salarial del juego cuenta solo jugadores, así que sin esto no habría
/// decisión ninguna — ficharías al mejor libre siempre.
const _mediaDeEquipoNeutra = 84.0;
const _cuantoMasPideElBueno = 0.22;

/// Lo que se rebaja un formador de jóvenes: es justo el trabajo que sabe
/// hacer, y sin esta excepción los equipos en reconstrucción no podrían
/// fichar nunca a quien más falta les hace. Dos puntos sobre un recorrido de
/// ocho es mucho — le abre media docena larga de equipos.
const _rebajaDelFormador = 2.0;

/// Cuánto vale una victoria del año pasado, en puntos de media de equipo.
/// Una temporada de 60 sube algo menos de un punto y una de 20 baja otro
/// tanto: matiza, pero no sustituye a la plantilla.
const _valorDeUnaVictoria = 0.05;

/// ¿Acepta este entrenador dirigir a un equipo así?
///
/// La regla en una frase: cuanto mejor es el entrenador, mejor tiene que
/// ser el equipo para que le diga que sí. Un 90 quiere un contendiente; un
/// 66 firma con cualquiera.
///
/// [mediaDelEquipo] es la de los cinco mejores jugadores de la plantilla —
/// el mismo criterio que usa la ficha de equipo. [victorias] y [derrotas]
/// son el récord con el que se le juzga.
bool aceptaLaOferta({
  required int mediaDelEntrenador,
  required int desarrolloDelEntrenador,
  required int mediaDelEquipo,
  required int victorias,
  required int derrotas,
}) {
  var exigencia = _mediaDeEquipoNeutra +
      (mediaDelEntrenador - 76) * _cuantoMasPideElBueno;
  if (desarrolloDelEntrenador >= 80) exigencia -= _rebajaDelFormador;

  return mediaDelEquipo + _tironDelRecord(victorias, derrotas) >= exigencia;
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
double _tironDelRecord(int victorias, int derrotas) {
  final jugados = victorias + derrotas;
  if (jugados == 0) return 0;
  final proyectadas = victorias / jugados * 82;
  return (proyectadas - 41) * _valorDeUnaVictoria;
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
