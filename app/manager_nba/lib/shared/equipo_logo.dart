import 'package:flutter/material.dart';

import '../domain/equipos_info.dart';

/// Logo simple de un equipo: un círculo partido en los dos colores
/// principales del equipo (sin imágenes ni escudos reales).
class EquipoLogo extends StatelessWidget {
  final String codigoEquipo;
  final double tamano;

  const EquipoLogo({super.key, required this.codigoEquipo, this.tamano = 40});

  @override
  Widget build(BuildContext context) {
    final info = infoDe(codigoEquipo);
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [info.colorPrimario, info.colorPrimario, info.colorSecundario, info.colorSecundario],
          stops: const [0.0, 0.5, 0.5, 1.0],
        ),
        border: Border.all(color: Colors.black26, width: 1),
      ),
    );
  }
}
