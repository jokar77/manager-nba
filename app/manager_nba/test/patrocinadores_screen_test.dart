import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart'
    show leerTemporada;
import 'package:manager_nba/domain/patrocinadores.dart';
import 'package:manager_nba/domain/patrocinadores_repository.dart';
import 'package:manager_nba/features/temporada/patrocinadores_screen.dart';

/// La pantalla de patrocinadores: cuatro categorías que se despliegan, con
/// hasta tres ofertas dentro de cada una, y lo que firmas se guarda de
/// verdad.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
  });

  tearDown(() => db.close());

  /// Las cuatro categorías con su historia no caben en la ventana de test
  /// por defecto: sin esto, la última queda fuera del árbol pintado y no se
  /// encuentra, aunque esté ahí en la lista.
  void ventanaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(1024, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> abrirPantalla(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: PatrocinadoresScreen(
        db: db,
        equipoUsuario: 'DEN',
        onContinuar: () {},
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<List<OfertaDePatrocinio>> ofertasDeLaPantalla(String categoria) async {
    final temporada = (await leerTemporada(db)).numero;
    return ofertasDe('DEN', categoria, temporada: temporada);
  }

  testWidgets('arranca con las cuatro categorías cerradas y sin firmar',
      (tester) async {
    ventanaAlta(tester);
    await abrirPantalla(tester);

    expect(tester.takeException(), isNull);
    // Las cuatro cabeceras, ninguna oferta a la vista.
    expect(find.byIcon(Icons.expand_more),
        findsNWidgets(categoriasPatrocinio.length));
    expect(find.byIcon(Icons.expand_less), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
  });

  testWidgets('desplegar una categoría enseña sus ofertas, con su marca, su '
      'dinero y sus años', (tester) async {
    ventanaAlta(tester);
    await abrirPantalla(tester);

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();

    final ofertas = await ofertasDeLaPantalla(categoriasPatrocinio.first);
    for (final oferta in ofertas) {
      expect(find.text(oferta.patrocinador.nombre), findsOneWidget,
          reason: oferta.patrocinador.clave);
      expect(
        find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == oferta.patrocinador.logo),
        findsWidgets,
        reason: 'falta el logo de ${oferta.patrocinador.clave}',
      );
    }
    // Una por duración, y sin repetir marca.
    expect(ofertas.map((o) => o.anios).toSet(), hasLength(ofertas.length));
  });

  testWidgets('solo se despliega una categoría a la vez', (tester) async {
    ventanaAlta(tester);
    await abrirPantalla(tester);

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.expand_less), findsOneWidget);

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.expand_less), findsOneWidget,
        reason: 'con dos abiertas la pantalla deja de leerse');
  });

  testWidgets('tocar una oferta la firma, y volver a tocarla la deshace',
      (tester) async {
    ventanaAlta(tester);
    await abrirPantalla(tester);

    final categoria = categoriasPatrocinio.first;
    final ofertas = await ofertasDeLaPantalla(categoria);

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();

    // Se toca el radio y no el nombre: una vez firmada, el nombre sale
    // dos veces —en la cabecera de la categoría y en su tarjeta— y un
    // `find.text` encontraría dos.
    await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
    await tester.pumpAndSettle();

    final contrato = (await leerContratosDePatrocinio(db))[categoria];
    expect(contrato, isNotNull);
    expect(contrato!.clave, ofertas.first.patrocinador.clave);
    expect(contrato.bonusAnual, ofertas.first.bonusAnual);
    expect(contrato.aniosRestantes, ofertas.first.anios);

    await tester.tap(find.byIcon(Icons.check_circle));
    await tester.pumpAndSettle();
    expect(await leerPatrociniosActivos(db), isEmpty);
  });

  testWidgets('firmar otra oferta de la misma categoría cambia de marca, no '
      'suma dos', (tester) async {
    ventanaAlta(tester);
    await abrirPantalla(tester);

    final categoria = categoriasPatrocinio.first;
    final ofertas = await ofertasDeLaPantalla(categoria);
    expect(ofertas.length, greaterThanOrEqualTo(2));

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
    await tester.pumpAndSettle();
    // La primera sin marcar es ahora la segunda oferta.
    await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
    await tester.pumpAndSettle();

    expect(await leerPatrociniosActivos(db), {categoria});
    final contrato = (await leerContratosDePatrocinio(db))[categoria]!;
    expect(contrato.clave, ofertas[1].patrocinador.clave);
    expect(contrato.aniosRestantes, ofertas[1].anios);
  });

  testWidgets('un contrato heredado sale con candado y no se despliega',
      (tester) async {
    // Lo que compras al firmar largo: esa categoría no se toca hasta que
    // caduque. Se simula firmando ANTES de abrir la pantalla, que es lo que
    // se encuentra al llegar de un año anterior.
    final categoria = 'bebida';
    final temporada = (await leerTemporada(db)).numero;
    final larga = ofertasDe('DEN', categoria, temporada: temporada).last;
    await firmarPatrocinio(db, larga);

    ventanaAlta(tester);
    await abrirPantalla(tester);

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    // Su marca se ve en la cabecera, pero sin flecha de desplegar.
    expect(find.text(larga.patrocinador.nombre), findsOneWidget);
    expect(find.byIcon(Icons.expand_more),
        findsNWidgets(categoriasPatrocinio.length - 1));

    // Y tocarlo no abre nada ni lo rompe.
    await tester.tap(find.byIcon(Icons.lock_outline));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    expect((await leerContratosDePatrocinio(db))[categoria]!.clave,
        larga.patrocinador.clave);
  });

  testWidgets('lo firmado en esta misma pantalla sí se puede cambiar',
      (tester) async {
    ventanaAlta(tester);
    await abrirPantalla(tester);

    final categoria = categoriasPatrocinio.first;
    final ofertas = await ofertasDeLaPantalla(categoria);

    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked).first);
    await tester.pumpAndSettle();

    // Sigue abierta y sin candado: lo acabas de firmar tú, así que se
    // puede desmarcar mientras no salgas de la pantalla.
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text(ofertas.first.patrocinador.nombre), findsWidgets);
  });

  testWidgets('en una temporada distinta salen marcas distintas',
      (tester) async {
    // El motivo entero de tener cantera: la pretemporada del año que viene
    // no es la misma pantalla.
    final temporada = (await leerTemporada(db)).numero;
    final categoria = categoriasPatrocinio.first;
    final ahora = ofertasDe('DEN', categoria, temporada: temporada);
    final siguiente = ofertasDe('DEN', categoria, temporada: temporada + 1);
    expect(ahora.map((o) => o.patrocinador.clave),
        isNot(siguiente.map((o) => o.patrocinador.clave)));

    ventanaAlta(tester);
    await abrirPantalla(tester);
    await tester.tap(find.byIcon(Icons.expand_more).first);
    await tester.pumpAndSettle();

    for (final o in ahora) {
      expect(find.text(o.patrocinador.nombre), findsOneWidget,
          reason: o.patrocinador.clave);
    }
    for (final o in siguiente) {
      if (ahora.any((a) => a.patrocinador.clave == o.patrocinador.clave)) {
        continue;
      }
      expect(find.text(o.patrocinador.nombre), findsNothing,
          reason: o.patrocinador.clave);
    }
  });

  testWidgets('tocar continuar llama al callback', (tester) async {
    var continuado = false;
    await tester.pumpWidget(MaterialApp(
      home: PatrocinadoresScreen(
        db: db,
        equipoUsuario: 'DEN',
        onContinuar: () => continuado = true,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(continuado, isTrue);
  });
}
