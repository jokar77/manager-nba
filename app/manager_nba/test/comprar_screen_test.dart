import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/permisos.dart';
import 'package:manager_nba/domain/tienda.dart';
import 'package:manager_nba/features/tienda/comprar_screen.dart';

/// La pantalla de compra (paso 4 del plan de monetización), con `tienda` y
/// `permisos` sustituidos a mano.
///
/// Mismo patrón que `bloqueos_version_gratuita_test.dart` con `permisos`, y
/// que `almacenDeSlots` en `slots_repository.dart`: una variable de
/// biblioteca pensada para sustituirse en los tests. No había hasta ahora
/// ningún test que sustituyera `tienda`; este es el que sienta el patrón.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    tienda = TiendaDeMentira();
    permisos = Permisos();
  });

  testWidgets('comprar con éxito registra la compra y cierra la pantalla',
      (tester) async {
    permisos = Permisos(edicion: Edicion.gratis);
    final falsa = TiendaDeMentira()..ventaSaleBien = true;
    tienda = falsa;

    bool? resultado;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              resultado = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const ComprarScreen()),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'COMPRAR'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'COMPRAR'));
    await tester.pumpAndSettle();

    expect(falsa.comprasIntentadas, 1);
    expect(permisos.esCompleta, isTrue,
        reason: 'comprarCompleta() a true tiene que registrar la compra');
    expect(find.byType(ComprarScreen), findsNothing,
        reason: 'una compra que sale bien cierra la pantalla');
    expect(resultado, isTrue);
  });

  testWidgets(
      'comprar cancelado o fallido no cambia nada y se puede reintentar',
      (tester) async {
    permisos = Permisos(edicion: Edicion.gratis);
    final falsa = TiendaDeMentira()..ventaSaleBien = false;
    tienda = falsa;

    await tester.pumpWidget(MaterialApp(home: const ComprarScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'COMPRAR'));
    await tester.pumpAndSettle();

    expect(permisos.esCompleta, isFalse,
        reason: 'false cubre tanto cancelar como que el pago se caiga');
    expect(find.byType(ComprarScreen), findsOneWidget,
        reason: 'sin drama: la pantalla se queda, no hay ningún aviso');

    // Y se puede volver a intentar sin que el botón se haya quedado
    // bloqueado del primer intento.
    await tester.tap(find.widgetWithText(FilledButton, 'COMPRAR'));
    await tester.pumpAndSettle();
    expect(falsa.comprasIntentadas, 2);
  });

  testWidgets('restaurar con éxito registra la compra y cierra la pantalla',
      (tester) async {
    permisos = Permisos(edicion: Edicion.gratis);
    final falsa = TiendaDeMentira()..habiaCompraPrevia = true;
    tienda = falsa;

    bool? resultado;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              resultado = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const ComprarScreen()),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'RESTAURAR COMPRA'));
    await tester.pumpAndSettle();

    expect(falsa.restauracionesPedidas, 1);
    expect(permisos.esCompleta, isTrue,
        reason: 'restaurarCompra() a true es una compra ya pagada antes');
    expect(find.byType(ComprarScreen), findsNothing);
    expect(resultado, isTrue);
  });

  testWidgets('restaurar sin compra previa avisa y deja la pantalla abierta',
      (tester) async {
    permisos = Permisos(edicion: Edicion.gratis);
    final falsa = TiendaDeMentira()..habiaCompraPrevia = false;
    tienda = falsa;

    await tester.pumpWidget(MaterialApp(home: const ComprarScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'RESTAURAR COMPRA'));
    await tester.pumpAndSettle();

    expect(permisos.esCompleta, isFalse);
    expect(find.byType(ComprarScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget,
        reason: 'a diferencia de comprar, aquí sí hay que avisar: es una '
            'acción que se pide a propósito');
  });
}
