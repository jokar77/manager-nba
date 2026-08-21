import 'entrenador_en_partido.dart';
import 'jugador_en_partido.dart';

/// Una plantilla de 5 titulares + banquillo, lista para simular un partido.
class EquipoPartido {
  final String nombre;
  final List<JugadorEnPartido> jugadores;

  /// Quién dirige. Opcional: un equipo sin entrenador rinde exactamente
  /// como antes de que existieran (ver [aporteDelEntrenador]), así que
  /// todo lo que no le pase uno —el All-Star, los tests viejos— sigue
  /// funcionando igual.
  final EntrenadorEnPartido? entrenador;

  EquipoPartido({
    required this.nombre,
    required this.jugadores,
    this.entrenador,
  }) {
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
    final sextosHombres = jugadores.where((j) => j.esSextoHombre).length;
    if (sextosHombres > 1) {
      throw ArgumentError('$nombre tiene más de un sexto hombre');
    }
  }

  List<JugadorEnPartido> get jugadoresActivos =>
      jugadores.where((j) => j.juega).toList();
}
