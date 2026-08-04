import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/shared/navegacion.dart';

/// Una pantalla mínima con un botón para empujar la siguiente (con el
/// nombre de ruta que le corresponda a ESA pantalla, no a esta), y otro
/// opcional para volver directo al menú o al calendario. Sirve para montar
/// cadenas de navegación de prueba sin tener que simular una temporada
/// real.
class _Pantalla extends StatelessWidget {
  final String titulo;
  final Widget? siguiente;

  /// Nombre de ruta que se le pone a [siguiente] al empujarla — es la
  /// pantalla de destino la que necesita el nombre para poder encontrarse
  /// después con `popUntil`, no esta.
  final String? nombreRutaSiguiente;
  final bool botonMenu;
  final bool botonCalendario;

  const _Pantalla({
    required this.titulo,
    this.siguiente,
    this.nombreRutaSiguiente,
    this.botonMenu = false,
    this.botonCalendario = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(titulo),
          if (siguiente != null)
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                settings: RouteSettings(name: nombreRutaSiguiente),
                builder: (context) => siguiente!,
              )),
              child: const Text('Siguiente'),
            ),
          if (botonMenu)
            TextButton(
              onPressed: () => volverAlMenuPrincipal(context),
              child: const Text('Volver al menú'),
            ),
          if (botonCalendario)
            TextButton(
              onPressed: () => volverAlCalendario(context),
              child: const Text('Ver calendario'),
            ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('volverAlMenuPrincipal salta directo al hub, saltándose todas '
      'las pantallas intermedias de una tacada', (WidgetTester tester) async {
    // Cadena real: StartMenu -push(hub)-> Hub -push(calendario)-> Calendario
    // -push-> Resumen -push-> Premios. Cada flecha lleva el nombre de ruta
    // de la pantalla a la que apunta, igual que en la app de verdad.
    await tester.pumpWidget(MaterialApp(
      home: _Pantalla(
        titulo: 'StartMenu',
        nombreRutaSiguiente: RutasPrincipales.hub,
        siguiente: _Pantalla(
          titulo: 'Hub',
          nombreRutaSiguiente: RutasPrincipales.calendario,
          siguiente: _Pantalla(
            titulo: 'Calendario',
            siguiente: _Pantalla(
              titulo: 'Resumen de simulación',
              siguiente: _Pantalla(titulo: 'Premios', botonMenu: true),
            ),
          ),
        ),
      ),
    ));

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Premios'), findsOneWidget);

    await tester.tap(find.text('Volver al menú'));
    await tester.pumpAndSettle();

    // Directo al Hub: ni Calendario, ni Resumen, ni Premios siguen vivos.
    expect(find.text('Hub'), findsOneWidget);
    expect(find.text('Calendario'), findsNothing);
    expect(find.text('Resumen de simulación'), findsNothing);
    expect(find.text('Premios'), findsNothing);
  });

  testWidgets('volverAlCalendario reutiliza el que ya está abierto en vez de '
      'apilar uno nuevo', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: _Pantalla(
        titulo: 'StartMenu',
        nombreRutaSiguiente: RutasPrincipales.calendario,
        siguiente: _Pantalla(
          titulo: 'Calendario',
          siguiente: _Pantalla(
            titulo: 'Resumen de simulación',
            siguiente: _Pantalla(titulo: 'Premios', botonCalendario: true),
          ),
        ),
      ),
    ));

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Ver calendario'));
    await tester.pumpAndSettle();

    // Ha vuelto al Calendario original: no hay una segunda instancia, y
    // Resumen/Premios han desaparecido de la pila.
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Resumen de simulación'), findsNothing);
    expect(find.text('Premios'), findsNothing);
  });
}
