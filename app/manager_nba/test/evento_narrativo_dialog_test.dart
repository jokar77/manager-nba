import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/eventos_narrativos_repository.dart';
import 'package:manager_nba/features/temporada/evento_narrativo_dialog.dart';

/// Los mismos tres tamaños que vigila `adaptacion_movil_test.dart`. Un
/// desborde de layout sale como excepción en un test, así que montar el
/// diálogo a los tres es la única red de verdad que hay aquí: en este
/// entorno no se pueden hacer capturas.
const _tamanos = <String, Size>{
  'iPhone vertical': Size(390, 844),
  'iPad vertical': Size(820, 1180),
  'escritorio': Size(1600, 900),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// El evento del catálogo con más opciones y textos más largos: si cabe
  /// este, caben todos.
  EventoNarrativo elMasLargo() {
    final ordenados = [...catalogoDeEventos]..sort((a, b) {
        int peso(EventoNarrativo e) =>
            e.opciones.length * 1000 +
            e.texto.length +
            e.opciones.fold<int>(0, (a, o) => a + o.etiqueta.length);
        return peso(b).compareTo(peso(a));
      });
    return ordenados.first;
  }

  Future<void> montar(
    WidgetTester tester,
    Size tamano,
    Widget Function(BuildContext) alPulsar,
  ) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(body: alPulsar(context))),
    ));
    await tester.pump();
  }

  for (final entrada in _tamanos.entries) {
    testWidgets('el diálogo de evento cabe en ${entrada.key}', (tester) async {
      final evento = elMasLargo();
      await montar(
        tester,
        entrada.value,
        (context) => TextButton(
          onPressed: () => plantearEvento(context, evento),
          child: const Text('abrir'),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text(evento.titulo), findsOneWidget);
      for (final opcion in evento.opciones) {
        expect(find.text(opcion.etiqueta), findsOneWidget);
      }
    });

    testWidgets('la consecuencia cabe en ${entrada.key}', (tester) async {
      // La consecuencia con más efectos: es la que más alto ocupa.
      final conMasEfectos = catalogoDeEventos
          .expand((e) => e.opciones.map((o) => (e, o)))
          .reduce((a, b) =>
              a.$2.efectos.length >= b.$2.efectos.length ? a : b);

      await montar(
        tester,
        entrada.value,
        (context) => TextButton(
          onPressed: () => contarConsecuencia(
              context, conMasEfectos.$1, conMasEfectos.$2),
          child: const Text('abrir'),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text(conMasEfectos.$2.consecuencia), findsOneWidget);
      for (final efecto in conMasEfectos.$2.efectos) {
        expect(find.text(efecto.etiqueta), findsOneWidget);
      }
    });

    testWidgets('el margen salarial se ve en ${entrada.key}', (tester) async {
      // El dinero es el único efecto que NO se nota en la pista: si no se
      // dice aquí, el usuario se entera semanas después al ir a fichar y
      // sin poder relacionarlo con esta decisión. O sea, no se entera.
      final conDinero = catalogoDeEventos
          .expand((e) => e.opciones.map((o) => (e, o)))
          .firstWhere((par) => par.$2.bonusSalarial > 0);

      await montar(
        tester,
        entrada.value,
        (context) => TextButton(
          onPressed: () =>
              contarConsecuencia(context, conDinero.$1, conDinero.$2),
          child: const Text('abrir'),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Margen salarial'), findsOneWidget);
      expect(find.textContaining('+'), findsWidgets,
          reason: 'el dinero que entra se enseña con su signo');
    });
  }

  testWidgets('elegir una opción la devuelve', (tester) async {
    final evento = catalogoDeEventos
        .firstWhere((e) => e.clave == 'cena_de_equipo');
    OpcionDeEvento? elegida;

    await montar(tester, _tamanos['iPhone vertical']!, (context) {
      return TextButton(
        onPressed: () async =>
            elegida = await plantearEvento(context, evento),
        child: const Text('abrir'),
      );
    });

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(evento.opciones.first.etiqueta));
    await tester.pumpAndSettle();

    expect(elegida, isNotNull);
    expect(elegida!.etiqueta, evento.opciones.first.etiqueta);
  });

  testWidgets('no se puede escapar del diálogo sin elegir', (tester) async {
    // "No hacer nada" es una opción del catálogo cuando tiene sentido, así
    // que cerrar tocando fuera sería una respuesta gratis que no existe en
    // el guion.
    final evento = catalogoDeEventos
        .firstWhere((e) => e.clave == 'cena_de_equipo');

    await montar(tester, _tamanos['iPhone vertical']!, (context) {
      return TextButton(
        onPressed: () => plantearEvento(context, evento),
        child: const Text('abrir'),
      );
    });

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    // Un toque en la esquina de arriba, fuera del diálogo.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text(evento.titulo), findsOneWidget,
        reason: 'el diálogo tiene que seguir ahí');
  });

  testWidgets('la tarjeta del vestuario no se enseña si no hay nada activo',
      (tester) async {
    await montar(
      tester,
      _tamanos['iPhone vertical']!,
      (context) => const TarjetaDeEfectosActivos(efectos: []),
    );
    expect(find.text('En el vestuario'), findsNothing);
  });

  testWidgets('con efectos activos, la tarjeta los lista', (tester) async {
    await montar(
      tester,
      _tamanos['iPhone vertical']!,
      (context) => const TarjetaDeEfectosActivos(efectos: [
        EfectoDeEvento(
            etiqueta: 'Buen rollo en el vestuario',
            factor: 1.02,
            partidos: 12),
        EfectoDeEvento(
            etiqueta: 'Piernas cansadas', factor: 0.98, partidos: 1),
      ]),
    );

    expect(find.text('En el vestuario'), findsOneWidget);
    expect(find.text('Buen rollo en el vestuario'), findsOneWidget);
    expect(find.text('12 partidos'), findsOneWidget);
    // Singular cuando queda uno: "1 partidos" se lee fatal.
    expect(find.text('1 partido'), findsOneWidget);
  });
}
