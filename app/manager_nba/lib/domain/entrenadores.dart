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

/// Media de equipo (la de sus cinco mejores) a partir de la cual un
/// entrenador considera que el proyecto merece la pena.
///
/// Es la única barrera para fichar: no hay dinero de por medio porque el
/// tope salarial del juego cuenta solo jugadores, así que sin esto no
/// habría decisión ninguna — ficharías al mejor libre siempre. Con esto, un
/// entrenador de primera solo va a un equipo que le convenza, y si estás
/// reconstruyendo tienes que conformarte con alguien de menos nombre (o
/// convencer a un formador de jóvenes, que son más flexibles: ver
/// [aceptaLaOferta]).
const _mediaDeEquipoNeutra = 78;

/// ¿Acepta este entrenador dirigir a un equipo así?
///
/// La regla en una frase: cuanto mejor es el entrenador, mejor tiene que
/// ser el equipo para que le diga que sí. Un 90 quiere un contendiente; un
/// 65 firma con cualquiera.
///
/// [mediaDelEquipo] es la de los cinco mejores jugadores de la plantilla —
/// el mismo criterio que usa la ficha de equipo— y [victoriasElAnoPasado]
/// es el récord de la temporada que acaba de terminar (0 si es la primera).
bool aceptaLaOferta({
  required int mediaDelEntrenador,
  required int desarrolloDelEntrenador,
  required int mediaDelEquipo,
  required int victoriasElAnoPasado,
}) {
  // Lo que exige, en puntos de media de equipo. Un entrenador medio (75)
  // pide un equipo medio; por cada punto que sube su media, sube algo más
  // de medio punto lo que pide.
  var exigencia = _mediaDeEquipoNeutra + (mediaDelEntrenador - 75) * 0.6;

  // Un formador de jóvenes se apunta a una reconstrucción: es justo el
  // trabajo que sabe hacer, y sin esta excepción los equipos malos no
  // podrían fichar nunca a quien más falta les hace.
  if (desarrolloDelEntrenador >= 80) exigencia -= 6;

  // Y el récord del año pasado matiza: 50 victorias es un proyecto que
  // funciona aunque la plantilla no deslumbre, y 20 son una señal de alarma
  // aunque los nombres estén bien. Alrededor de 41 (la mitad de 82) no
  // suma ni resta.
  final tiron = (victoriasElAnoPasado - 41) * 0.12;

  return mediaDelEquipo + tiron >= exigencia;
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
