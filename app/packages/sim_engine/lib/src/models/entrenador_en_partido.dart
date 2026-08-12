/// El entrenador de un equipo, tal y como lo ve el motor de simulación.
///
/// Solo lleva lo que cambia un partido: cuánto mejora el ataque y cuánto
/// mejora la defensa de los suyos. Su tercera faceta —el desarrollo de
/// jugadores jóvenes— no vive aquí a propósito: no afecta a ningún partido,
/// se nota de verano en verano (ver progresion_repository.dart en la app).
class EntrenadorEnPartido {
  /// Atributos en la misma escala 0-99 que los de los jugadores.
  final int ataque;
  final int defensa;

  const EntrenadorEnPartido({required this.ataque, required this.defensa});
}
