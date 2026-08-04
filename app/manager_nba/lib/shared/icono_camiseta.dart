import 'package:flutter/material.dart';

/// Una camiseta de baloncesto (tirantes, sisas abiertas) con un dorsal a la
/// espalda. Se dibuja a mano en vez de usar un icono del sistema porque
/// ninguno de los que hay es una camiseta de baloncesto: `checkroom` es una
/// percha y `sports_basketball` un balón.
///
/// El [dorsal] por defecto es el 23 — el número retirado por excelencia.
class IconoCamisetaRetirada extends StatelessWidget {
  final double tamano;
  final String dorsal;
  final Color? color;

  const IconoCamisetaRetirada({
    super.key,
    this.tamano = 24,
    this.dorsal = '23',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tinta = color ?? IconTheme.of(context).color ?? Colors.white;
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(
        painter: _PintorDeCamiseta(color: tinta, dorsal: dorsal),
      ),
    );
  }
}

class _PintorDeCamiseta extends CustomPainter {
  final Color color;
  final String dorsal;

  _PintorDeCamiseta({required this.color, required this.dorsal});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trazo = w * 0.09;

    // Contorno: hombros anchos, escote en pico y sisas hacia dentro.
    final camiseta = Path()
      ..moveTo(w * 0.28, h * 0.12)
      ..lineTo(w * 0.42, h * 0.12)
      ..quadraticBezierTo(w * 0.50, h * 0.26, w * 0.58, h * 0.12)
      ..lineTo(w * 0.72, h * 0.12)
      ..lineTo(w * 0.86, h * 0.30)
      ..lineTo(w * 0.74, h * 0.42)
      ..lineTo(w * 0.74, h * 0.90)
      ..lineTo(w * 0.26, h * 0.90)
      ..lineTo(w * 0.26, h * 0.42)
      ..lineTo(w * 0.14, h * 0.30)
      ..close();

    canvas.drawPath(
      camiseta,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = trazo
        ..strokeJoin = StrokeJoin.round,
    );

    // El dorsal, centrado en el pecho de la camiseta.
    final texto = TextPainter(
      text: TextSpan(
        text: dorsal,
        style: TextStyle(
          color: color,
          fontSize: h * 0.34,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    texto.paint(
      canvas,
      Offset((w - texto.width) / 2, h * 0.50 - texto.height / 2),
    );
  }

  @override
  bool shouldRepaint(_PintorDeCamiseta oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dorsal != dorsal;
}
