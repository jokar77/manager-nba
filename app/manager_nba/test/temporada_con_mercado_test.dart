import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/draft_repository.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/ofertas_repository.dart';
import 'package:manager_nba/domain/posiciones.dart';
import 'package:manager_nba/domain/traspasos_repository.dart';

/// Lo mismo que hace `simularHastaConDialogo` cuando en cada fecha límite
/// respondes "seguir simulando".
Future<void> _simularHasta(
    AppDatabase db, String equipo, DateTime dia) async {
  int? ignorar;
  while (true) {
    final tramo =
        await simularTramo(db, equipo, dia, eventoIdAIgnorar: ignorar);
    if (tramo.eventoBloqueante == null) break;
    ignorar = tramo.eventoBloqueante!.id;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Una temporada jugada como se juega de verdad, con la plantilla
  /// cambiando por debajo. Es la prueba que pilló los dos bugs gordos del
  /// mercado: traspasar a un titular dejaba la rotación apuntando a alguien
  /// que ya no estaba (y el siguiente partido reventaba), y los que llegaban
  /// se quedaban sin dorsal hasta la pretemporada siguiente.
  test('una temporada entera traspasando y aceptando ofertas no rompe nada',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
    final inicial =
        await (db.select(db.jugadores)..where((t) => t.equipo.equals('LAL')))
            .get();
    await guardarRotacion(db, generarRotacionAutomatica(inicial));

    final rng = Random(9);
    final fechas = (await leerPartidos(db, 'LAL')).map((p) => p.fecha).toList();
    var traspasos = 0;
    var ofertasAceptadas = 0;

    for (var i = 0; i < fechas.length; i += 8) {
      await _simularHasta(db, 'LAL', fechas[i]);

      // Se busca salida a alguien al azar y se acepta lo primero que salga.
      final mia = await plantillaParaTraspasos(db, 'LAL');
      final victima = mia[rng.nextInt(mia.length)];
      final propuestas = await buscarSalidaPara(db,
          equipoUsuario: 'LAL', jugadorIds: [victima.id]);
      if (propuestas.isNotEmpty) {
        final p = propuestas[rng.nextInt(propuestas.length)];
        await ejecutarTraspaso(db,
            equipoUsuario: 'LAL',
            equipoRival: p.equipoRival,
            tuyos: p.idsQueSalen,
            suyos: p.idsQueLlegan,
            tusPicks: p.idsPicksQueSalen,
            susPicks: p.idsPicksQueLlegan);
        traspasos++;
      }

      await generarOfertasEntrantes(db,
          equipoUsuario: 'LAL',
          partidosSimulados: 8,
          fecha: fechas[i],
          random: rng);
      final ofertas = await ofertasPendientes(db, 'LAL');
      if (ofertas.isNotEmpty && rng.nextBool()) {
        await aceptarOferta(db, ofertas.first, equipoUsuario: 'LAL');
        ofertasAceptadas++;
      }
    }
    await _simularHasta(db, 'LAL', fechas.last);

    expect(traspasos, greaterThan(3));
    expect(ofertasAceptadas, greaterThan(0));

    // La temporada se ha jugado entera pese al trasiego.
    final calendario = await leerPartidos(db, 'LAL');
    expect(calendario.where((p) => p.jugado).length, calendario.length);

    // Tu plantilla sigue siendo alineable.
    final tuya =
        await (db.select(db.jugadores)..where((t) => t.equipo.equals('LAL')))
            .get();
    expect(tuya.length, inInclusiveRange(plantillaMinima, plantillaMaxima));
    expect(tuya.where((j) => j.dorsal == null), isEmpty,
        reason: 'quien llega en un traspaso se queda sin número');
    final dorsales = tuya.map((j) => j.dorsal).toList();
    expect(dorsales.toSet().length, dorsales.length);
    for (final puesto in posicionesEquipo) {
      expect(tuya.where((j) => juegaComodoDe(j, puesto)).length,
          greaterThanOrEqualTo(2),
          reason: 'te has quedado sin recambio en $puesto');
    }

    // Y la rotación guardada no apunta a fantasmas.
    final rotacion = await leerRotacion(db);
    final ids = tuya.map((j) => j.id).toSet();
    expect(rotacion, hasLength(posicionesEquipo.length * 2));
    expect(rotacion.where((f) => !ids.contains(f.jugadorId)), isEmpty,
        reason: 'la rotación tiene jugadores que ya no están en el equipo');

    // El resto de la liga tampoco se ha roto por el camino.
    final todos = await (db.select(db.jugadores)
          ..where((t) => t.retirado.equals(false)))
        .get();
    final porEquipo = <String, List<Jugador>>{};
    for (final j in todos) {
      if (esFranquicia(j.equipo)) {
        porEquipo.putIfAbsent(j.equipo, () => []).add(j);
      }
    }
    for (final e in porEquipo.entries) {
      expect(e.value.length, greaterThanOrEqualTo(plantillaMinima),
          reason: '${e.key} se ha quedado corto');
      for (final puesto in posicionesEquipo) {
        expect(e.value.where((j) => juegaComodoDe(j, puesto)).length,
            greaterThanOrEqualTo(2),
            reason: '${e.key} sin recambio en $puesto');
      }
    }

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 10)));

  test('traspasar a un titular a mitad de temporada no revienta el siguiente '
      'partido', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
    final plantilla =
        await (db.select(db.jugadores)..where((t) => t.equipo.equals('LAL')))
            .get();
    await guardarRotacion(db, generarRotacionAutomatica(plantilla));

    final titular = (await leerRotacion(db)).firstWhere((f) => f.esTitular);
    final peorDeBos = (await plantillaParaTraspasos(db, 'BOS')).last;
    await ejecutarTraspaso(db,
        equipoUsuario: 'LAL',
        equipoRival: 'BOS',
        tuyos: [titular.jugadorId],
        suyos: [peorDeBos.id]);

    final tuya =
        await (db.select(db.jugadores)..where((t) => t.equipo.equals('LAL')))
            .get();
    final ids = tuya.map((j) => j.id).toSet();
    expect((await leerRotacion(db)).where((f) => !ids.contains(f.jugadorId)),
        isEmpty);

    // Y el hueco se ha tapado con alguien del mismo puesto.
    final nueva = (await leerRotacion(db))
        .firstWhere((f) => f.posicion == titular.posicion && f.esTitular);
    expect(nueva.jugadorId, isNot(titular.jugadorId));

    final fecha = (await leerPartidos(db, 'LAL')).first.fecha;
    await expectLater(
        construirEquipoUsuarioParaFecha(db, 'LAL', fecha), completes);

    await db.close();
  });
}
