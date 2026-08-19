import 'package:flutter/material.dart';

import '../i18n/textos.dart';
/// La cruz blanca sobre fondo rojo con la que se marcan las lesiones en
/// todas partes.
///
/// Un icono rojo suelto se confundía con cualquier otro aviso; la cruz
/// sobre el cuadro rojo se reconoce de un vistazo y sin leer, que es de lo
/// que se trata cuando estás pasando por un resumen de veinte partidos.
/// Lleva su propio fondo a propósito: así se ve igual en modo claro y en
/// modo oscuro, sin depender del color del tema.
class IconoLesion extends StatelessWidget {
  final double tamano;

  const IconoLesion({super.key, this.tamano = 18});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: t(context).lesionLabel,
      child: Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(tamano * 0.22),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.add, size: tamano * 0.78, color: Colors.white),
      ),
    );
  }
}
