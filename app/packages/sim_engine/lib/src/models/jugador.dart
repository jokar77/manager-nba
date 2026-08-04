/// Un jugador tal y como viene del dataset (jugadores_manager_30_07.json),
/// sin nada de contexto de partido (eso lo añade [JugadorEnPartido]).
class Jugador {
  final String id;
  final String nombreFicticio;
  final String posicion;
  final String equipo;
  final int edad;
  final int atrAtaque;
  final int atrDefensa;
  final int atrTiro3;
  final int media;
  final int potencial;
  final double ptsPg;
  final double astPg;
  final double trbPg;
  final double factorLongevidad;

  const Jugador({
    required this.id,
    required this.nombreFicticio,
    required this.posicion,
    required this.equipo,
    required this.edad,
    required this.atrAtaque,
    required this.atrDefensa,
    required this.atrTiro3,
    required this.media,
    required this.potencial,
    required this.ptsPg,
    required this.astPg,
    required this.trbPg,
    required this.factorLongevidad,
  });

  /// Índice de capacidad ofensiva (0-99), combina tiro, anotación y media general.
  double get indiceOfensivo => atrAtaque * 0.55 + atrTiro3 * 0.30 + media * 0.15;

  /// Índice de capacidad defensiva (0-99).
  double get indiceDefensivo => atrDefensa * 0.7 + media * 0.3;
}
