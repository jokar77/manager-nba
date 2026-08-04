import 'jugador.dart';

/// Un jugador con su configuración para un partido concreto: minutos y roles.
class JugadorEnPartido {
  final Jugador jugador;
  final int minutos;
  final bool esEstrellaAtaque;
  final bool esEstrellaDefensa;

  /// Multiplicador (0.0-1.0) aplicado a sus índices ofensivo/defensivo y a
  /// su reparto de estadísticas cuando juega fuera de su posición natural.
  /// 1.0 = sin penalización. La app decide este valor comparando el puesto
  /// asignado con `jugador.posicion`; el motor no sabe qué es "una
  /// posición", solo aplica el multiplicador que recibe.
  final double penalizacionFueraDePosicion;

  /// Estado de forma del jugador esta temporada: multiplicador alrededor de
  /// 1.0 (por encima = año de explosión, por debajo = año flojo) que la app
  /// sortea una vez por temporada. 1.0 = forma neutra. Igual que con la
  /// penalización fuera de posición, el motor no decide este valor: solo lo
  /// aplica.
  final double factorForma;

  const JugadorEnPartido({
    required this.jugador,
    required this.minutos,
    this.esEstrellaAtaque = false,
    this.esEstrellaDefensa = false,
    this.penalizacionFueraDePosicion = 1.0,
    this.factorForma = 1.0,
  })  : assert(minutos >= 0 && minutos <= 48,
            'minutos debe estar entre 0 y 48'),
        assert(
            penalizacionFueraDePosicion >= 0.0 &&
                penalizacionFueraDePosicion <= 1.0,
            'penalizacionFueraDePosicion debe estar entre 0.0 y 1.0'),
        assert(factorForma > 0.0, 'factorForma debe ser positivo');

  bool get juega => minutos > 0;

  /// Todo lo que modula el rendimiento del jugador en este partido
  /// concreto, junto: fuera de posición y estado de forma.
  double get rendimiento => penalizacionFueraDePosicion * factorForma;
}
