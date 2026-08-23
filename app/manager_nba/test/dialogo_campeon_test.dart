import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/shared/campeon_dialog.dart';

/// Los mismos tres tamaños que vigilan `adaptacion_movil_test.dart` y el
/// diálogo de eventos. Un desborde de layout salta como excepción en un
/// test, así que montar el diálogo a los tres es toda la red que hace
/// falta: aquí no se pueden hacer capturas.
const _tamanos = <String, Size>{
  'iPhone vertical': Size(390, 844),
  'iPad vertical': Size(820, 1180),
  'escritorio': Size(1600, 900),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La vibración de "has ganado" sale por el canal de plataforma, y en un
  /// test nadie contesta a ese canal: el `await` de `heavyImpact()` se
  /// queda colgado y el diálogo no llega a abrirse nunca. Con este
  /// contestador de mentira responde al momento y el aviso aparece.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Abre el aviso de campeón y no vuelve hasta que está en pantalla.
  ///
  /// Lo de esperar a verlo no es paranoia: con `esTuEquipo` el diálogo se
  /// abre DESPUÉS de un `await HapticFeedback.heavyImpact()`, así que un
  /// `pump()` suelto vuelve antes de que exista. Un test que no comprueba
  /// que llegó a abrirse pasa en verde sin haber mirado nada — que es
  /// justo lo que hacía la primera versión de este archivo.
  ///
  /// Y no se puede usar `pumpAndSettle`: cuando el campeón eres tú cae
  /// confeti, y esa animación no termina nunca.
  Future<void> abrir(
    WidgetTester tester,
    Size tamano, {
    required bool esTuEquipo,
    required String extra,
  }) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => mostrarCampeonDecidido(
                context,
                true,
                'DEN',
                esTuEquipo: esTuEquipo,
                // La Cup no da anillo: es el caso real de este aviso.
                daAnillo: false,
                temporada: '2027-28',
                etiquetaAccionExtra: extra,
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));

    for (var i = 0; i < 20 && find.text(extra).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    // Y una vez está montado, hay que dejar que TERMINE de aparecer.
    // Un desborde se canta al pintar, y mientras dura la animación de
    // entrada el diálogo va con opacidad 0: a opacidad 0 Flutter se salta
    // el pintado entero, así que en el primer fotograma el fallo no salta
    // aunque el layout ya esté mal. Sin esta espera, este archivo pasaba
    // en verde con el Row roto.
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(extra), findsOneWidget,
        reason: 'el diálogo del campeón tenía que estar abierto');
  }

  for (final entrada in _tamanos.entries) {
    testWidgets('el campeón de la Copa cabe en ${entrada.key}',
        (tester) async {
      await abrir(tester, entrada.value,
          esTuEquipo: false, extra: 'Ver estadísticas');
      expect(find.text('Cerrar'), findsOneWidget);
    });

    testWidgets('el campeón siendo tu equipo cabe en ${entrada.key}',
        (tester) async {
      await abrir(tester, entrada.value,
          esTuEquipo: true, extra: 'Ver estadísticas');
      expect(find.text('¡A celebrarlo!'), findsOneWidget);
    });
  }
}
