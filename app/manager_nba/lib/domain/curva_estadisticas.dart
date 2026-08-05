/// Qué números pone un jugador según su nivel.
///
/// Existe porque la relación entre la media y las estadísticas **no es
/// lineal**, y tratarla como si lo fuera vaciaba la liga de anotadores.
/// Medido sobre los 582 jugadores del dataset real:
///
/// | media | 67  | 72  | 77  | 82   | 87   | 92   | 97   |
/// |-------|-----|-----|-----|------|------|------|------|
/// | pts   | 3,4 | 4,4 | 7,8 | 13,3 | 19,6 | 25,2 | 28,2 |
///
/// Entre un 77 y un 87 los puntos se multiplican por 2,5; entre un 92 y un
/// 97 solo suben un 12%. Es una curva con forma de S, no una recta.
///
/// Lo que pasaba sin esto, medido sobre 15 veranos seguidos: el mejor
/// anotador de la liga caía de 33,5 puntos a 21,4 y desaparecían los
/// jugadores de 25+, mientras seguía habiendo 26 medias de 90 o más.
/// Superestrellas anotando como suplentes. Dos causas, las dos lineales:
/// los prospectos del draft nacían de una recta topada en 18 puntos, y al
/// envejecer se escalaba `ptsPg` por `nuevaMedia / mediaVieja`.
///
/// Aquí no se ajusta ninguna fórmula elegante: se interpolan los datos
/// medidos. Una curva inventada que pasara "cerca" sería más bonita y
/// menos fiel, y lo que hace falta es fidelidad.
library;

/// Los puntos por partido típicos de cada nivel. Los extremos (62 y 99)
/// extienden la tabla un poco por debajo y por encima de donde hay datos
/// suficientes, para que la curva no tenga escalones en las puntas.
const _puntos = <int, double>{
  62: 2.0,
  67: 3.4,
  72: 4.4,
  77: 7.8,
  82: 13.3,
  87: 19.6,
  92: 25.2,
  97: 28.2,
  99: 29.5,
};

const _asistencias = <int, double>{
  62: 0.6,
  67: 0.9,
  72: 1.1,
  77: 1.8,
  82: 3.0,
  87: 4.7,
  92: 5.2,
  97: 6.5,
  99: 6.9,
};

const _rebotes = <int, double>{
  62: 1.2,
  67: 1.7,
  72: 2.2,
  77: 3.4,
  82: 4.9,
  87: 6.1,
  92: 6.8,
  97: 7.6,
  99: 8.0,
};

/// Cuánto se desvía cada puesto de la media de su nivel. Medido sobre los
/// jugadores de media 78+ del dataset: un base reparte un 72% más
/// asistencias que el jugador medio de su nivel, y un pívot coge un 52%
/// más rebotes.
const _factorAsistencias = <String, double>{
  'PG': 1.72,
  'SG': 0.93,
  'SF': 0.92,
  'PF': 0.79,
  'C': 0.71,
};

const _factorRebotes = <String, double>{
  'PG': 0.74,
  'SG': 0.66,
  'SF': 0.95,
  'PF': 1.12,
  'C': 1.52,
};

/// Interpola linealmente entre los dos puntos medidos que rodean a [media].
/// Fuera de la tabla se devuelve el extremo, que es lo prudente: no hay
/// datos ahí y extrapolar una curva convexa se dispara enseguida.
double _enLaCurva(Map<int, double> tabla, int media) {
  final niveles = tabla.keys.toList()..sort();
  if (media <= niveles.first) return tabla[niveles.first]!;
  if (media >= niveles.last) return tabla[niveles.last]!;

  for (var i = 0; i < niveles.length - 1; i++) {
    final a = niveles[i], b = niveles[i + 1];
    if (media >= a && media <= b) {
      final t = (media - a) / (b - a);
      return tabla[a]! + (tabla[b]! - tabla[a]!) * t;
    }
  }
  return tabla[niveles.last]!;
}

/// Los puntos por partido que pone un jugador de esta [media].
double puntosTipicos(int media) => _enLaCurva(_puntos, media);

/// Las asistencias típicas de esta [media] en este [posicion].
double asistenciasTipicas(int media, String posicion) =>
    _enLaCurva(_asistencias, media) * (_factorAsistencias[posicion] ?? 1.0);

/// Los rebotes típicos de esta [media] en este [posicion].
double rebotesTipicos(int media, String posicion) =>
    _enLaCurva(_rebotes, media) * (_factorRebotes[posicion] ?? 1.0);

/// Cuánto se sale un jugador de lo típico de su nivel: 1.0 es exactamente
/// lo normal, 1.5 es un anotador nato y 0.6 un especialista defensivo.
///
/// Es lo que permite mover a un jugador por la curva **sin borrarle la
/// personalidad**: se recalcula su estadística en el nivel nuevo
/// conservando este número. Si su media no cambia, el resultado es
/// exactamente el que tenía.
///
/// Va acotado porque los extremos del dataset harían cosas raras al
/// arrastrarlos veinte puntos de media: un suplente que promedia 0,3
/// puntos no puede quedarse en 0,3 al convertirse en una estrella, ni un
/// especialista de garbage time proyectarse a 45.
///
/// El techo de 1,5 sale de los datos: en el dataset real el que más se sale
/// de lo típico de su nivel anda por ahí. Con 2,0 —que era el primer valor
/// probado— la medición sacó un jugador de **43,7 puntos** en la séptima
/// temporada, y eso no lo promedia nadie.
double estiloRespectoASuNivel(double valor, double tipicoDeSuNivel) {
  if (tipicoDeSuNivel <= 0) return 1.0;
  return (valor / tipicoDeSuNivel).clamp(0.4, 1.5);
}

/// Nadie promedia más que el mejor anotador del dataset real (33,5), así
/// que ahí está el techo, con un pelín de margen. Es un cinturón de
/// seguridad además del tope del estilo: la curva y el estilo se multiplican
/// y conviene que el producto no se pueda ir por su cuenta.
const maxPuntosPorPartido = 34.0;
