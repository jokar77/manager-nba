import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/shared/estilo.dart';

/// El escudo de equipo (`PlacaEquipo`/`EquipoLogo`) también lo usan los
/// "equipos" que no son franquicias —Este, Oeste, Novatos, Sophomores del
/// All-Star— cuyo código es la palabra entera, no tres letras. Sin encoger
/// el texto para que quepa, se salía del escudo.
void main() {
  testWidgets('un código largo (Sophomores) no desborda el escudo',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: PlacaEquipo(
            codigo: 'Sophomores',
            primario: Colors.blue,
            secundario: Colors.red,
            tamano: 40,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Sophomores'), findsOneWidget);
  });

  testWidgets('un código real de tres letras se sigue viendo igual de '
      'grande (el ajuste no lo encoge de más)', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: PlacaEquipo(
            codigo: 'LAL',
            primario: Colors.purple,
            secundario: Colors.amber,
            tamano: 40,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final texto = tester.widget<Text>(find.text('LAL'));
    expect((texto.style!.fontSize!), 40 * 0.34);
  });
}
