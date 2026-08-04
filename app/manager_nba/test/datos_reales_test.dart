import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/draft_repository.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/posiciones.dart';
import 'package:manager_nba/domain/salarios.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Jugador> porNombreReal(String nombre) async {
    return (db.select(db.jugadores)..where((t) => t.nombreReal.equals(nombre)))
        .getSingle();
  }

  test('los dorsales, salarios y equipos reales llegan a la base tal cual',
      () async {
    final curry = await porNombreReal('Stephen Curry');
    expect(curry.dorsal, 30);
    expect(curry.salario, 62587158);
    expect(curry.equipo, 'GSW');

    final jokic = await porNombreReal('Nikola Jokić');
    expect(jokic.dorsal, 15);
    expect(jokic.salario, 59033114);
    expect(jokic.aniosContrato, 2);

    // Traspaso recogido de la fuente: en el dataset original estaba en MIL.
    final giannis = await porNombreReal('Giannis Antetokounmpo');
    expect(giannis.equipo, 'MIA');
    expect(giannis.dorsal, 7);
  });

  test('a quien no tenemos contrato real se le estima uno dentro de la '
      'escala de la liga', () async {
    final jugadores = await db.select(db.jugadores).get();

    // Todo el mundo cobra algo y tiene contrato. El suelo no puede ser
    // `salarioMinimo`: entre los contratos reales hay acuerdos parciales
    // por debajo del mínimo del convenio (Ricky Rubio, 424.672).
    expect(jugadores.every((j) => j.salario > 0), isTrue);
    expect(jugadores.every((j) => j.salario <= salarioMaximo), isTrue);
    expect(jugadores.every((j) => j.aniosContrato >= 1), isTrue);

    // La escala tiene que discriminar: los mejores cobran mucho más que la
    // media de la liga.
    final ordenados = [...jugadores]..sort((a, b) => b.media.compareTo(a.media));
    final top20 = ordenados.take(20);
    final mediaTop = top20.map((j) => j.salario).reduce((a, b) => a + b) / 20;
    final mediaLiga =
        jugadores.map((j) => j.salario).reduce((a, b) => a + b) / jugadores.length;
    expect(mediaTop, greaterThan(mediaLiga * 2.5));
  });

  test('salarioEstimado sigue la escala real: sube fuerte arriba y se '
      'aplana abajo', () {
    int deMedia(int media, {int edad = 28}) =>
        salarioEstimado(media: media, edad: edad);

    expect(deMedia(60), salarioMinimo);
    expect(deMedia(70), lessThan(deMedia(80)));
    expect(deMedia(80), lessThan(deMedia(90)));
    // El salto de 85 a 95 tiene que ser mucho mayor que el de 65 a 75.
    expect(deMedia(95) - deMedia(85),
        greaterThan((deMedia(75) - deMedia(65)) * 4));
    // Un chaval con contrato de rookie cobra menos que un veterano igual.
    expect(deMedia(85, edad: 21), lessThan(deMedia(85, edad: 28)));
  });

  test('tras crear la franquicia las 30 plantillas son jugables y con todos '
      'los puestos cubiertos', () async {
    await crearFranquicia(db, 'LAL');

    final jugadores = await (db.select(db.jugadores)
          ..where((t) => t.retirado.equals(false)))
        .get();
    final porEquipo = <String, List<Jugador>>{};
    for (final j in jugadores) {
      if (!esFranquicia(j.equipo)) continue;
      porEquipo.putIfAbsent(j.equipo, () => []).add(j);
    }

    expect(porEquipo.length, 30);
    for (final entry in porEquipo.entries) {
      // Solo el mínimo: al empezar la partida las plantillas se dejan tal
      // y como las da el dataset (de 14 a 26), sin recortar al tope. Antes
      // se recortaban, y eso mandaba a la agencia libre del año 1 a medio
      // centenar de jugadores que en la vida real tienen contrato. El tope
      // vuelve a aplicarse en el cierre del draft de cada verano.
      expect(entry.value.length, greaterThanOrEqualTo(plantillaMinima),
          reason: '${entry.key} tiene ${entry.value.length} jugadores');

      for (final puesto in posicionesEquipo) {
        expect(entry.value.where((j) => juegaComodoDe(j, puesto)).length,
            greaterThanOrEqualTo(2),
            reason: '${entry.key} no puede cubrir $puesto');
      }

      // Dorsales únicos dentro del equipo.
      final dorsales = entry.value.map((j) => j.dorsal).toList();
      expect(dorsales.every((d) => d != null), isTrue);
      expect(dorsales.toSet().length, dorsales.length,
          reason: '${entry.key} repite dorsal');
    }
  });
}
