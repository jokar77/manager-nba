import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/features/partido/alineacion_automatica.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late List<Jugador> plantilla;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('DEN')))
        .get();
  });

  tearDown(() async {
    await db.close();
  });

  test('la CPU juega con 10 jugadores, los mismos que el usuario (titular + '
      'suplente de cada puesto), repartiendo los 240 minutos', () {
    final equipo = generarAlineacionAutomatica('DEN', plantilla);

    expect(equipo.jugadores, hasLength(10));
    expect(equipo.jugadores.map((j) => j.minutos).reduce((a, b) => a + b), 240);
    expect(equipo.jugadores.every((j) => j.minutos > 0), isTrue);
  });

  test('los lesionados no entran en la alineación, pero se sigue jugando '
      'con 10', () {
    final ordenada = [...plantilla]..sort((a, b) => b.media.compareTo(a.media));
    final lesionados = ordenada.take(3).map((j) => j.id).toSet();

    final equipo = generarAlineacionAutomatica('DEN', plantilla,
        lesionadosIds: lesionados);

    expect(equipo.jugadores, hasLength(10));
    expect(
        equipo.jugadores.any((j) => lesionados.contains(int.parse(j.jugador.id))),
        isFalse);
  });

  test('el factor de forma de cada jugador llega a la alineación', () {
    final ordenada = [...plantilla]..sort((a, b) => b.media.compareTo(a.media));
    final estrella = ordenada.first;

    final equipo = generarAlineacionAutomatica('DEN', plantilla,
        formas: {estrella.id: 1.2});

    final enPartido = equipo.jugadores
        .firstWhere((j) => j.jugador.id == estrella.id.toString());
    expect(enPartido.factorForma, 1.2);
    // El resto va con forma neutra al no estar en el mapa.
    expect(
        equipo.jugadores
            .where((j) => j.jugador.id != estrella.id.toString())
            .every((j) => j.factorForma == 1.0),
        isTrue);
  });
}
