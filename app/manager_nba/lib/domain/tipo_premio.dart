/// Premios de fin de temporada regular. El `name` de cada valor es lo que
/// se guarda en `PremiosTemporada.tipo`. No incluye Entrenador del Año: el
/// juego no tiene un concepto de entrenador.
enum TipoPremio {
  mvp,
  mejorDefensor,
  rookieDelAno,
  masMejorado,
  primerQuinteto,
  segundoQuinteto,

  /// Los dos que no son de fin de temporada regular: se conceden cuando se
  /// juega su partido (el fin de semana de las estrellas, en febrero) y se
  /// guardan en la misma tabla, así que el cálculo de los de arriba no puede
  /// limpiarla entera. Ver [premiosDeFinDeTemporadaRegular].
  mvpAllStar,
  mvpRisingStars,

  /// Selección al All-Star (no ganar el partido, solo que te convocaran).
  /// Solo lo concede el Modo Carrera — el modo Franquicia no simula el
  /// proceso de votación de los aficionados, así que ningún jugador de
  /// franquicia recibe este premio.
  allStar;

  static TipoPremio desdeNombre(String nombre) {
    return TipoPremio.values.firstWhere((v) => v.name == nombre);
  }
}

/// Los premios que decide el rendimiento de los 82 partidos. Son los únicos
/// que se recalculan (y por tanto se borran y se vuelven a escribir) al
/// cerrar la temporada regular.
const premiosDeFinDeTemporadaRegular = [
  TipoPremio.mvp,
  TipoPremio.mejorDefensor,
  TipoPremio.rookieDelAno,
  TipoPremio.masMejorado,
  TipoPremio.primerQuinteto,
  TipoPremio.segundoQuinteto,
];
