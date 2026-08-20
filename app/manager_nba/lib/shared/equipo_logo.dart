import 'package:flutter/material.dart';

import '../domain/equipos_info.dart';
import 'estilo.dart';

/// El escudo de un equipo: el cuadrado partido en diagonal con sus dos
/// colores (sin imágenes ni escudos reales, que no se pueden usar).
///
/// Era un círculo hasta el rediseño. Se cambió aquí dentro, y no en las
/// treinta pantallas que lo pintan, precisamente para que no hubiera dos
/// escudos distintos conviviendo según por dónde llegaras: la forma del
/// equipo es una decisión de todo el juego, no de cada pantalla.
class EquipoLogo extends StatelessWidget {
  final String codigoEquipo;
  final double tamano;

  const EquipoLogo({super.key, required this.codigoEquipo, this.tamano = 40});

  @override
  Widget build(BuildContext context) {
    final info = infoDe(codigoEquipo);
    return PlacaEquipo(
      codigo: codigoEquipo,
      primario: info.colorPrimario,
      secundario: info.colorSecundario,
      tamano: tamano,
    );
  }
}
