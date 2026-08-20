import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/ajustes_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/features/ajustes/ajustes_screen.dart';
import 'package:manager_nba/i18n/textos.dart';
import 'package:manager_nba/shared/preferencias.dart';

/// El fallo que vigila este fichero: la pantalla de Ajustes se abre desde
/// dos sitios —el menú de inicio y el menú de dentro de una partida— y la
/// segunda estaba mal conectada. Recibía la base de datos de LA PARTIDA en
/// vez de la de la app, así que el idioma se guardaba donde nadie lo lee, y
/// no recibía los notificadores, así que la app no se repintaba: desde
/// dentro de una partida, cambiar de idioma o de tema no hacía nada.
///
/// Ahora la pantalla no recibe nada: coge la base y los notificadores ella
/// sola. Estos tests comprueban las dos mitades del arreglo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() {
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
    temaNotifier.value = ThemeMode.light;
    idiomaNotifier.value = Idioma.espanol;
  });

  tearDown(() async {
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
    temaNotifier.value = ThemeMode.light;
    idiomaNotifier.value = Idioma.espanol;
  });

  /// Monta la pantalla igual que la monta el menú de dentro de la partida:
  /// sin pasarle absolutamente nada.
  Future<void> abrirAjustesScreen(WidgetTester tester) async {
    await tester.pumpWidget(ValueListenableBuilder<Idioma>(
      valueListenable: idiomaNotifier,
      builder: (context, idioma, _) => MaterialApp(
        home: Idiomas(textos: textosDe(idioma), child: const AjustesScreen()),
      ),
    ));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('cambiar el idioma desde dentro de la partida lo guarda en la '
      'base de la APP y repinta', (tester) async {
    // Una partida abierta a la vez: es la situación real, y es la base que
    // antes se colaba por error.
    final partida = abrirSlot(1);

    await abrirAjustesScreen(tester);
    await tester.tap(find.text(Idioma.ingles.nombre));
    await tester.pump();

    expect(idiomaNotifier.value, Idioma.ingles,
        reason: 'sin esto la app no se entera y no se repinta nada');
    expect(await leerIdioma(abrirAjustes()), Idioma.ingles,
        reason: 'el idioma es de la app, tiene que quedar en su base');
    expect(await leerIdioma(partida), Idioma.espanol,
        reason: 'la base de la partida no pinta nada aquí');

    // Y se ve: la propia pantalla ya está en inglés. En mayúsculas,
    // porque así rotula la barra de arriba desde el rediseño.
    expect(find.text(const TextosEn().ajustes.toUpperCase()), findsOneWidget);
  });

  testWidgets('el modo oscuro también sale de la base de la app y repinta',
      (tester) async {
    final partida = abrirSlot(1);

    await abrirAjustesScreen(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(temaNotifier.value, ThemeMode.dark);
    expect(await leerModoOscuro(abrirAjustes()), isTrue);
    expect(await leerModoOscuro(partida), isFalse);
  });

  testWidgets('al volver a abrirla enseña lo que se eligió antes',
      (tester) async {
    await abrirAjustesScreen(tester);
    await tester.tap(find.text(Idioma.frances.nombre));
    await tester.pump();

    // Se cierra y se abre de nuevo, como quien sale y vuelve a entrar.
    await abrirAjustesScreen(tester);
    expect(find.text(const TextosFr().ajustes.toUpperCase()), findsOneWidget);
  });
}
