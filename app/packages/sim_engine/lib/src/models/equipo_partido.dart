import 'jugador_en_partido.dart';

/// Una plantilla de 5 titulares + banquillo, lista para simular un partido.
class EquipoPartido {
  final String nombre;
  final List<JugadorEnPartido> jugadores;

  EquipoPartido({required this.nombre, required this.jugadores}) {
    final sumaMinutos =
        jugadores.fold<int>(0, (acc, j) => acc + j.minutos);
    if (sumaMinutos != 240) {
      throw ArgumentError(
          'La suma de minutos de $nombre debe ser 240 (5 jugadores x 48), es $sumaMinutos');
    }
    final estrellasAtaque = jugadores.where((j) => j.esEstrellaAtaque).length;
    if (estrellasAtaque > 1) {
      throw ArgumentError('$nombre tiene más de una estrella de ataque');
    }
    final estrellasDefensa = jugadores.where((j) => j.esEstrellaDefensa).length;
    if (estrellasDefensa > 1) {
      throw ArgumentError('$nombre tiene más de una estrella de defensa');
    }
  }

  List<JugadorEnPartido> get jugadoresActivos =>
      jugadores.where((j) => j.juega).toList();
}
