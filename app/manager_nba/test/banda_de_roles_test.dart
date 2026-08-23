import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/features/roster/roster_config_screen.dart';
import 'package:manager_nba/i18n/textos.dart';

/// La banda de roles (estrella de ataque, de defensa y sexto hombre) de la
/// pantalla de alineación.
///
/// El problema que resuelve: en un móvil los tres desplegables apilados
/// ocupaban un tercio de la pantalla, siempre, por tres cosas que se tocan
/// una vez al montar el equipo y no se vuelven a mirar. Ahora ahí la banda
/// se pliega y deja una línea de resumen.
///
/// En escritorio no se pliega: los tres caben en fila y no le quitan sitio
/// a nada.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
  });

  tearDown(() => db.close());

  Future<void> montar(WidgetTester tester, Size tamano) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: RosterConfigScreen(
        db: db,
        equipo: 'DEN',
        esConfiguracionInicial: false,
        onGuardado: () {},
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// Lo que mide de alto la banda de roles, que es lo que se está
  /// intentando bajar.
  double altoDeLaBanda(WidgetTester tester) {
    // El icono de la flecha solo existe en la versión plegable; se sube al
    // ancestro con tamaño para medir la banda entera. Vale la flecha esté
    // como esté —plegada apunta arriba y desplegada abajo— porque hay que
    // poder medir en los dos estados.
    final flecha = find.byWidgetPredicate((w) =>
        w is Icon &&
        (w.icon == Icons.expand_less || w.icon == Icons.expand_more));
    final contenedor = find
        .ancestor(of: flecha, matching: find.byType(Container))
        .first;
    return tester.getSize(contenedor).height;
  }

  const iphone = Size(390, 844);
  const escritorio = Size(1600, 900);

  testWidgets('en móvil arranca plegada, con la línea de resumen',
      (tester) async {
    await montar(tester, iphone);

    expect(find.byIcon(Icons.expand_less), findsOneWidget,
        reason: 'la flecha de desplegar tiene que estar');
    expect(find.byType(DropdownButtonFormField<int?>), findsNothing,
        reason: 'plegada no se enseña ningún desplegable');

    // Los tres roles siguen anunciados, aunque sin nadie puesto todavía.
    expect(find.text('—'), findsNWidgets(3));
  });

  testWidgets('en móvil la banda plegada ocupa mucho menos que desplegada',
      (tester) async {
    await montar(tester, iphone);
    final plegada = altoDeLaBanda(tester);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();
    final desplegada = altoDeLaBanda(tester);

    // Medido en un iPhone vertical (390×844): 43 px plegada contra 270
    // desplegada. Son 227 px libres, un 27% de la pantalla, que es
    // exactamente el problema que se estaba arreglando.
    expect(plegada, lessThan(desplegada / 2),
        reason: 'plegada $plegada, desplegada $desplegada — si no ahorra '
            'la mitad larga, no compensa doblar nada');
    // Y en términos absolutos: una línea, no un tercio de la pantalla.
    expect(plegada, lessThan(60));
  });

  testWidgets('desplegarla enseña los tres selectores con su etiqueta',
      (tester) async {
    await montar(tester, iphone);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<int?>), findsNWidgets(3));
    expect(find.byIcon(Icons.expand_more), findsOneWidget,
        reason: 'abierta, la flecha apunta al revés');

    final textos = const TextosEs();
    for (final etiqueta in [
      textos.estrellaAtaqueLabel,
      textos.estrellaDefensaLabel,
      textos.sextoHombreLabel,
    ]) {
      expect(find.text(etiqueta.toUpperCase()), findsOneWidget,
          reason: 'abierta sí hay sitio para el nombre entero del rol');
    }
  });

  testWidgets('volver a tocarla la pliega', (tester) async {
    await montar(tester, iphone);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButtonFormField<int?>), findsNWidgets(3));

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButtonFormField<int?>), findsNothing);
  });

  testWidgets('el resumen enseña el apellido de quien lleva cada rol',
      (tester) async {
    await montar(tester, iphone);

    // "Alinear automáticamente" marca las dos estrellas y el sexto hombre.
    await tester.tap(
        find.text(const TextosEs().alinearAutomaticamenteBtn.toUpperCase()));
    await tester.pumpAndSettle();

    // Ya no hay huecos vacíos en la banda, y sigue plegada.
    expect(find.text('—'), findsNothing,
        reason: 'con los tres roles puestos, el resumen los enseña');
    expect(find.byType(DropdownButtonFormField<int?>), findsNothing,
        reason: 'alinear no despliega la banda');
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
  });

  testWidgets('en escritorio no se pliega: los tres siempre a la vista',
      (tester) async {
    await montar(tester, escritorio);

    expect(find.byType(DropdownButtonFormField<int?>), findsNWidgets(3),
        reason: 'en ancho caben en fila y no estorban');
    expect(find.byIcon(Icons.expand_less), findsNothing,
        reason: 'sin banda plegable no hay flecha que enseñar');
    expect(find.byIcon(Icons.expand_more), findsNothing);
  });
}
