import 'package:flutter/material.dart';

/// Cuántas estrellas (de 5, en pasos de media) le corresponden a un
/// potencial numérico.
///
/// El número de potencial no se enseña nunca en la interfaz —ni en la
/// agencia libre ni en las vistas generales de jugador—: es información que
/// en un scouting de verdad nadie te da con precisión de punto exacto. Solo
/// en el Draft, donde tiene sentido comparar prospectos entre sí, se
/// traduce a esta escala visual de grosor de estrellas. Las medias
/// estrellas afinan la comparación entre prospectos que quedarían
/// pegados en la misma banda entera (p. ej. 75 y 81 de potencial, ambos
/// "3 estrellas" antes de esto).
double estrellasDePotencial(int potencial) => switch (potencial) {
      >= 90 => 5.0,
      >= 86 => 4.5,
      >= 82 => 4.0,
      >= 78 => 3.5,
      >= 74 => 3.0,
      >= 70 => 2.5,
      >= 65 => 2.0,
      >= 61 => 1.5,
      _ => 1.0,
    };

/// Etiqueta corta a juego con las estrellas, para cuando además del icono
/// hace falta texto (p. ej. en un tooltip o una lista sin espacio para
/// dibujar iconos). Se queda en las mismas 5 bandas de siempre: la media
/// estrella afina el dibujo, no crea una categoría nueva.
String etiquetaDePotencial(int potencial) {
  final estrellas = estrellasDePotencial(potencial);
  if (estrellas >= 5) return 'Elite';
  if (estrellas >= 4) return 'Muy alto';
  if (estrellas >= 3) return 'Alto';
  if (estrellas >= 2) return 'Medio';
  return 'Bajo';
}

/// Las cinco estrellas del potencial de un prospecto, rellenas hasta donde
/// corresponda. Solo se usa en el Draft.
class PotencialEstrellas extends StatelessWidget {
  final int potencial;
  final double tamano;

  const PotencialEstrellas({
    super.key,
    required this.potencial,
    this.tamano = 14,
  });

  @override
  Widget build(BuildContext context) {
    final estrellas = estrellasDePotencial(potencial);
    final llenas = estrellas.floor();
    final mediaEstrella = estrellas - llenas >= 0.5;
    final color = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: 'Potencial: ${etiquetaDePotencial(potencial)}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Icon(
              i < llenas
                  ? Icons.star
                  : (i == llenas && mediaEstrella)
                      ? Icons.star_half
                      : Icons.star_border,
              size: tamano,
              color: i < llenas || (i == llenas && mediaEstrella)
                  ? color
                  : color.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }
}
