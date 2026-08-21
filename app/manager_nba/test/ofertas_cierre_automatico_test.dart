import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/features/mercado/ofertas_screen.dart';

/// Cuando la simulación se para para que decidas una oferta, resolver la
/// última tiene que devolverte solo al Calendario — sin este cierre
/// automático, te quedabas mirando una bandeja vacía hasta darle tú mismo
/// a "volver".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');

    final deDen = (await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('DEN')))
        .get())
      .first;
    final deBos = (await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('BOS')))
        .get())
      .first;

    await db.into(db.ofertasTraspaso).insert(
        OfertasTraspasoCompanion.insert(
          equipoOfertante: 'BOS',
          pideJugadores: '${deDen.id}',
          ofreceJugadores: '${deBos.id}',
          fecha: DateTime(2026, 11, 1),
        ));
  });

  tearDown(() => db.close());

  Future<void> asentar(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Una navegación de verdad, con algo debajo: así "se cierra sola" se
  /// puede comprobar viendo qué pantalla queda encima, no solo que no
  /// haya excepciones.
  Widget appConCalendarioDebajoYOfertasEncima({required bool cierraSola}) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: const Center(child: Text('CALENDARIO')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OfertasScreen(
                db: db,
                equipoUsuario: 'DEN',
                cierraSolaAlVaciarse: cierraSola,
              ),
            )),
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }

  testWidgets(
      'con cierraSolaAlVaciarse, rechazar la última oferta vuelve sola al '
      'Calendario', (tester) async {
    await tester.pumpWidget(
        appConCalendarioDebajoYOfertasEncima(cierraSola: true));
    await tester.tap(find.byType(FloatingActionButton));
    await asentar(tester);

    expect(find.text('Rechazar'), findsOneWidget);
    await tester.tap(find.text('Rechazar'));
    await asentar(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('CALENDARIO'), findsOneWidget,
        reason: 'sin ofertas que quedan, la pantalla se cierra sola');
    expect(find.text('Rechazar'), findsNothing);
  });

  testWidgets(
      'sin cierraSolaAlVaciarse (consulta desde el menú), rechazar la '
      'última oferta se queda en la pantalla', (tester) async {
    await tester.pumpWidget(
        appConCalendarioDebajoYOfertasEncima(cierraSola: false));
    await tester.tap(find.byType(FloatingActionButton));
    await asentar(tester);

    await tester.tap(find.text('Rechazar'));
    await asentar(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('CALENDARIO'), findsNothing,
        reason: 'una consulta voluntaria no te echa fuera de golpe');
  });
}
