import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/shared/potencial_estrellas.dart';

void main() {
  test('estrellasDePotencial reparte de 1 a 5 estrellas en pasos de media, '
      'sin huecos ni saltos', () {
    expect(estrellasDePotencial(45), 1.0);
    expect(estrellasDePotencial(60), 1.0);
    expect(estrellasDePotencial(61), 1.5);
    expect(estrellasDePotencial(64), 1.5);
    expect(estrellasDePotencial(65), 2.0);
    expect(estrellasDePotencial(69), 2.0);
    expect(estrellasDePotencial(70), 2.5);
    expect(estrellasDePotencial(73), 2.5);
    expect(estrellasDePotencial(74), 3.0);
    expect(estrellasDePotencial(77), 3.0);
    expect(estrellasDePotencial(78), 3.5);
    expect(estrellasDePotencial(81), 3.5);
    expect(estrellasDePotencial(82), 4.0);
    expect(estrellasDePotencial(85), 4.0);
    expect(estrellasDePotencial(86), 4.5);
    expect(estrellasDePotencial(89), 4.5);
    expect(estrellasDePotencial(90), 5.0);
    expect(estrellasDePotencial(99), 5.0);

    // Monótona: más potencial nunca da menos estrellas.
    var anterior = estrellasDePotencial(45);
    for (var p = 46; p <= 99; p++) {
      final actual = estrellasDePotencial(p);
      expect(actual, greaterThanOrEqualTo(anterior));
      anterior = actual;
    }
  });

  test('dos prospectos que antes quedaban pegados en la misma banda entera '
      'ahora se distinguen con media estrella', () {
    // 75 y 81 caían los dos en "3 estrellas" con la escala vieja: con
    // medias estrellas, 81 pasa a marcar más que 75.
    expect(estrellasDePotencial(75), lessThan(estrellasDePotencial(81)));
  });

  testWidgets(
      'etiquetaDePotencial se queda en 5 textos: la media estrella afina '
      'el dibujo, no crea una banda de texto nueva', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        context = c;
        return const SizedBox.shrink();
      }),
    ));

    final etiquetas = {
      for (var p = 45; p <= 99; p++) etiquetaDePotencial(context, p)
    };
    expect(etiquetas.length, 5, reason: 'siguen siendo las 5 bandas de siempre');

    // 4.5 y 5.0 estrellas comparten etiqueta ("Elite" empieza en 90); 3.5
    // y 4.0 comparten "Muy alto"; y así con el resto de medias bandas.
    expect(etiquetaDePotencial(context, 86), etiquetaDePotencial(context, 89));
    expect(etiquetaDePotencial(context, 90),
        isNot(etiquetaDePotencial(context, 89)));
  });
}
