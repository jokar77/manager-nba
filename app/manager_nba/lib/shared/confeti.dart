import 'dart:math';

import 'package:flutter/material.dart';

/// Lluvia de confeti para las celebraciones. Se dibuja con un
/// `CustomPainter` sobre lo que haya debajo — nada de dependencias ni de
/// imágenes.
///
/// Cae una sola vez y para: una animación en bucle detrás de un diálogo se
/// queda girando para siempre aunque no la mire nadie, y en una app que pasa
/// el 99% del tiempo en pantallas quietas eso solo gasta batería.
class LluviaDeConfeti extends StatefulWidget {
  /// Los colores del equipo que celebra, más un dorado de la casa.
  final List<Color> colores;
  final int piezas;
  final Duration duracion;

  const LluviaDeConfeti({
    super.key,
    required this.colores,
    this.piezas = 90,
    this.duracion = const Duration(seconds: 4),
  });

  @override
  State<LluviaDeConfeti> createState() => _LluviaDeConfetiState();
}

class _LluviaDeConfetiState extends State<LluviaDeConfeti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _control = AnimationController(
    vsync: this,
    duration: widget.duracion,
  )..forward();

  /// Las piezas se sortean una vez y no cambian: si se resortearan en cada
  /// fotograma el confeti parpadearía en vez de caer.
  late final List<_Papelillo> _papelillos = _sortear();

  List<_Papelillo> _sortear() {
    final rng = Random(7);
    final colores = [...widget.colores, const Color(0xFFD4A017)];
    return [
      for (var i = 0; i < widget.piezas; i++)
        _Papelillo(
          x: rng.nextDouble(),
          retraso: rng.nextDouble() * 0.35,
          velocidad: 0.75 + rng.nextDouble() * 0.5,
          balanceo: 0.02 + rng.nextDouble() * 0.05,
          giro: rng.nextDouble() * pi,
          ancho: 5 + rng.nextDouble() * 6,
          alto: 8 + rng.nextDouble() * 8,
          color: colores[rng.nextInt(colores.length)],
        ),
    ];
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _control,
        builder: (context, _) => CustomPaint(
          painter: _PintorConfeti(_papelillos, _control.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Papelillo {
  final double x;
  final double retraso;
  final double velocidad;
  final double balanceo;
  final double giro;
  final double ancho;
  final double alto;
  final Color color;

  const _Papelillo({
    required this.x,
    required this.retraso,
    required this.velocidad,
    required this.balanceo,
    required this.giro,
    required this.ancho,
    required this.alto,
    required this.color,
  });
}

class _PintorConfeti extends CustomPainter {
  final List<_Papelillo> papelillos;
  final double t;

  const _PintorConfeti(this.papelillos, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in papelillos) {
      final avance = (t - p.retraso) * p.velocidad;
      if (avance <= 0) continue;
      final y = avance * (size.height + p.alto * 2) - p.alto;
      if (y > size.height) continue;
      final x = p.x * size.width + sin(avance * 12 + p.giro) * p.balanceo * size.width;

      // Se desvanecen al final para que no desaparezcan de golpe.
      final opacidad = avance > 0.85 ? (1 - (avance - 0.85) / 0.15) : 1.0;
      paint.color = p.color.withValues(alpha: opacidad.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.giro + avance * 8);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.ancho, height: p.alto),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorConfeti oldDelegate) =>
      oldDelegate.t != t;
}
