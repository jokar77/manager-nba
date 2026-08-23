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

  /// Si la pantalla ha llegado a guardar. Es lo que separa "avisa" de
  /// "avisa y además deja pasar igualmente".
  late bool guardado;

  Future<void> montar(WidgetTester tester, Size tamano) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    guardado = false;
    await tester.pumpWidget(
      MaterialApp(
        home: RosterConfigScreen(
          db: db,
          equipo: 'DEN',
          esConfiguracionInicial: false,
          onGuardado: () => guardado = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Lo que mide de alto la banda de roles, que es lo que se está
  /// intentando bajar.
  double altoDeLaBanda(WidgetTester tester) {
    // El icono de la flecha solo existe en la versión plegable; se sube al
    // ancestro con tamaño para medir la banda entera. Vale la flecha esté
    // como esté —plegada apunta arriba y desplegada abajo— porque hay que
    // poder medir en los dos estados.
    final flecha = find.byWidgetPredicate(
      (w) =>
          w is Icon &&
          (w.icon == Icons.expand_less || w.icon == Icons.expand_more),
    );
    final contenedor = find
        .ancestor(of: flecha, matching: find.byType(Container))
        .first;
    return tester.getSize(contenedor).height;
  }

  const iphone = Size(390, 844);
  const escritorio = Size(1600, 900);

  /// Los rótulos de los botones van en mayúsculas (ver `mayus` en
  /// shared/estilo.dart), así que buscarlos por el texto tal cual no vale.
  final botonGuardar = find.text(
    const TextosEs().guardarRotacionBtn.toUpperCase(),
  );

  /// Deja la alineación y los tres roles puestos de una tacada.
  Future<void> alinearAutomaticamente(WidgetTester tester) async {
    await tester.tap(
      find.text(const TextosEs().alinearAutomaticamenteBtn.toUpperCase()),
    );
    await tester.pumpAndSettle();
  }

  /// Quita el rol de [clave], y deja la banda plegada como estaba.
  ///
  /// Hace falta porque `crearFranquicia` no deja rotación: para llegar al
  /// caso "alineación completa pero un rol sin elegir" hay que alinear
  /// primero y vaciar uno después.
  Future<void> vaciarRol(WidgetTester tester, Key clave) async {
    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    // Nada de `ensureVisible` aquí: la banda es un pie fijo y ya está a la
    // vista, y llamarlo cambiaría de pestaña — el primer `Scrollable` que
    // encuentra hacia arriba es el `PageView` del `TabBarView`.
    await tester.tap(find.byKey(clave));
    await tester.pumpAndSettle();
    await tester.tap(find.text(const TextosEs().ningunaOpcion).last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();
  }

  testWidgets('en móvil arranca plegada, con la línea de resumen', (
    tester,
  ) async {
    await montar(tester, iphone);

    expect(
      find.byIcon(Icons.expand_less),
      findsOneWidget,
      reason: 'la flecha de desplegar tiene que estar',
    );
    expect(
      find.byType(DropdownButtonFormField<int?>),
      findsNothing,
      reason: 'plegada no se enseña ningún desplegable',
    );

    // Los tres roles siguen anunciados, aunque sin nadie puesto todavía.
    expect(find.text('—'), findsNWidgets(3));
  });

  testWidgets('en móvil la banda plegada ocupa mucho menos que desplegada', (
    tester,
  ) async {
    await montar(tester, iphone);
    final plegada = altoDeLaBanda(tester);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();
    final desplegada = altoDeLaBanda(tester);

    // Medido en un iPhone vertical (390×844): 43 px plegada contra 270
    // desplegada. Son 227 px libres, un 27% de la pantalla, que es
    // exactamente el problema que se estaba arreglando.
    expect(
      plegada,
      lessThan(desplegada / 2),
      reason:
          'plegada $plegada, desplegada $desplegada — si no ahorra '
          'la mitad larga, no compensa doblar nada',
    );
    // Y en términos absolutos: una línea, no un tercio de la pantalla.
    expect(plegada, lessThan(60));
  });

  testWidgets('desplegarla enseña los tres selectores con su etiqueta', (
    tester,
  ) async {
    await montar(tester, iphone);

    await tester.tap(find.byIcon(Icons.expand_less));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<int?>), findsNWidgets(3));
    expect(
      find.byIcon(Icons.expand_more),
      findsOneWidget,
      reason: 'abierta, la flecha apunta al revés',
    );

    final textos = const TextosEs();
    for (final etiqueta in [
      textos.estrellaAtaqueLabel,
      textos.estrellaDefensaLabel,
      textos.sextoHombreLabel,
    ]) {
      expect(
        find.text(etiqueta.toUpperCase()),
        findsOneWidget,
        reason: 'abierta sí hay sitio para el nombre entero del rol',
      );
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

  testWidgets('el resumen enseña el apellido de quien lleva cada rol', (
    tester,
  ) async {
    await montar(tester, iphone);

    // "Alinear automáticamente" marca las dos estrellas y el sexto hombre.
    await tester.tap(
      find.text(const TextosEs().alinearAutomaticamenteBtn.toUpperCase()),
    );
    await tester.pumpAndSettle();

    // Ya no hay huecos vacíos en la banda, y sigue plegada.
    expect(
      find.text('—'),
      findsNothing,
      reason: 'con los tres roles puestos, el resumen los enseña',
    );
    expect(
      find.byType(DropdownButtonFormField<int?>),
      findsNothing,
      reason: 'alinear no despliega la banda',
    );
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
  });

  testWidgets('con la alineación vacía, el aviso es el de la alineación', (
    tester,
  ) async {
    // El orden importa: los roles se piden DESPUÉS de los diez huecos,
    // porque el sexto hombre sale de los suplentes y sin alineación no hay
    // suplentes de los que sacarlo.
    await montar(tester, iphone);

    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(find.text(const TextosEs().faltaAlineacionAviso), findsOneWidget);
    expect(find.text(const TextosEs().faltanRolesAviso), findsNothing);
    expect(guardado, isFalse);
  });

  testWidgets('sin los tres roles no se guarda, y se dice por qué', (
    tester,
  ) async {
    await montar(tester, iphone);
    await alinearAutomaticamente(tester);
    await vaciarRol(tester, claveRolAtaque);

    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(
      find.text(const TextosEs().faltanRolesAviso),
      findsOneWidget,
      reason: 'un botón que no hace nada no explica qué falta',
    );
    expect(guardado, isFalse, reason: 'no se puede guardar a medias');
  });

  testWidgets('al intentar guardar, la banda se abre sola para enseñar lo '
      'que falta', (tester) async {
    await montar(tester, iphone);
    await alinearAutomaticamente(tester);
    await vaciarRol(tester, claveRolAtaque);
    expect(
      find.byType(DropdownButtonFormField<int?>),
      findsNothing,
      reason: 'la banda vuelve a quedarse plegada',
    );

    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    // Abrirla es la mitad del aviso: parpadear una banda plegada diría
    // "aquí hay algo" sin dejar verlo ni arreglarlo.
    expect(
      find.byType(DropdownButtonFormField<int?>),
      findsNWidgets(3),
      reason: 'la banda tiene que abrirse sola al avisar',
    );
  });

  testWidgets('el aviso se repite si se vuelve a intentar', (tester) async {
    // Con un booleano en vez de un contador, el segundo intento no
    // cambiaría nada y no volvería a parpadear — justo cuando quien lo
    // necesita es alguien que no se enteró la primera vez.
    await montar(tester, iphone);
    await alinearAutomaticamente(tester);
    await vaciarRol(tester, claveRolSextoHombre);

    for (var intento = 0; intento < 2; intento++) {
      await tester.tap(botonGuardar);
      await tester.pumpAndSettle();
      expect(
        find.text(const TextosEs().faltanRolesAviso),
        findsOneWidget,
        reason: 'intento ${intento + 1}',
      );
    }
    expect(guardado, isFalse);
  });

  testWidgets('con los tres roles puestos sí guarda', (tester) async {
    await montar(tester, iphone);
    // «Alinear automáticamente» deja la alineación y los tres roles.
    await alinearAutomaticamente(tester);

    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(find.text(const TextosEs().faltanRolesAviso), findsNothing);
    expect(find.text(const TextosEs().faltaAlineacionAviso), findsNothing);
    expect(guardado, isTrue);
  });

  testWidgets('en escritorio no se pliega: los tres siempre a la vista', (
    tester,
  ) async {
    await montar(tester, escritorio);

    expect(
      find.byType(DropdownButtonFormField<int?>),
      findsNWidgets(3),
      reason: 'en ancho caben en fila y no estorban',
    );
    expect(
      find.byIcon(Icons.expand_less),
      findsNothing,
      reason: 'sin banda plegable no hay flecha que enseñar',
    );
    expect(find.byIcon(Icons.expand_more), findsNothing);
  });
}
