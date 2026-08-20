import 'package:flutter/material.dart';

/// Color de texto que se lee bien encima de [fondo].
///
/// Cualquier sitio que pinte un fondo de color fijo (el amarillo de
/// campeón, el color de un equipo...) tiene que usar esto en vez de dejar
/// que el texto herede el color del tema: en modo oscuro el texto por
/// defecto es claro, y encima de un fondo claro fijo se volvía ilegible.
Color textoSobre(Color fondo) =>
    ThemeData.estimateBrightnessForColor(fondo) == Brightness.dark
        ? Colors.white
        : Colors.black87;

/// Versión atenuada de [textoSobre], para subtítulos y texto secundario
/// encima de un fondo de color.
Color textoSecundarioSobre(Color fondo) =>
    textoSobre(fondo).withValues(alpha: 0.75);

/// Ajusta [color] para que se lea como *texto* sobre el fondo del tema
/// actual, conservando el tono.
///
/// Los colores de equipo son identidad, no legibilidad: hay azules marinos
/// que desaparecen en modo oscuro y amarillos que desaparecen en claro. Se
/// aclara u oscurece lo justo para que siempre se distinga.
Color colorLegibleComoTexto(Color color, BuildContext context) {
  final hsl = HSLColor.fromColor(color);
  final esOscuro = Theme.of(context).brightness == Brightness.dark;
  final luminosidad = esOscuro
      ? (hsl.lightness < 0.62 ? 0.62 : hsl.lightness)
      : (hsl.lightness > 0.42 ? 0.42 : hsl.lightness);
  return hsl.withLightness(luminosidad).toColor();
}

/// El color con el que se rotula ENCIMA del color principal de un equipo.
///
/// Lo natural es su segundo color (el oro de Denver sobre su azul marino),
/// pero hay clubes cuyos dos colores se parecen demasiado o que llevan negro
/// sobre azul marino. Cuando el contraste entre los dos no da, se cae al
/// blanco o al negro que toque.
Color acentoDeEquipo(Color primario, Color secundario) {
  final a = primario.computeLuminance();
  final b = secundario.computeLuminance();
  final claro = a > b ? a : b;
  final oscuro = a > b ? b : a;
  return (claro + 0.05) / (oscuro + 0.05) >= 2.2
      ? secundario
      : textoSobre(primario);
}
