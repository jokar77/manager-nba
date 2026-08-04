import 'dart:math';


import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/draft_repository.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/picks_repository.dart';
import 'package:manager_nba/domain/posiciones.dart';
import 'package:manager_nba/domain/salarios.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('diez temporadas con mercado vivo dejan la liga coherente', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');

    for (var i = 0; i < 10; i++) {
      await empezarNuevaTemporada(db, random: Random(100 + i));
    }

    final jugadores = await (db.select(db.jugadores)
          ..where((t) => t.retirado.equals(false)))
        .get();
    final porEquipo = <String, List<Jugador>>{};
    for (final j in jugadores) {
      if (!esFranquicia(j.equipo)) continue;
      porEquipo.putIfAbsent(j.equipo, () => []).add(j);
    }

    expect(porEquipo.length, 30);

    for (final e in porEquipo.entries) {
      expect(e.value.length, inInclusiveRange(plantillaMinima, plantillaMaxima),
          reason: '${e.key} tiene ${e.value.length}');
      for (final p in posicionesEquipo) {
        expect(e.value.where((j) => juegaComodoDe(j, p)).length,
            greaterThanOrEqualTo(2),
            reason: '${e.key} sin recambio en $p');
      }
      final dorsales = e.value.map((j) => j.dorsal).toList();
      expect(dorsales.any((d) => d == null), isFalse,
          reason: '${e.key} tiene alguien sin dorsal');
      expect(dorsales.toSet().length, dorsales.length,
          reason: '${e.key} tiene dorsales repetidos: $dorsales');
      // El tope salarial se puede rebasar, pero solo firmando mínimos: es la
      // excepción que hace `puedeAsumir` para que un equipo caro no se quede
      // sin poder completar plantilla. Como no caben más de
      // [plantillaMaxima] jugadores, ese es el techo real de la masa.
      //
      // Antes esto exigía un 5% de margen sobre el tope, y era un número con
      // suerte, no un invariante: midiendo la masa máxima de la liga año a
      // año durante las 10 temporadas se ve pasar de 239M varias veces (PHI
      // ya arranca en 239,1M con los contratos reales del dataset, antes de
      // que el juego firme nada). El test solo miraba la foto final, así que
      // pasaba o no según en qué equipo cayeran los mínimos ese año.
      final masa = e.value.fold<int>(0, (a, j) => a + j.salario);
      expect(masa, lessThanOrEqualTo(topeSalarial + plantillaMaxima * salarioMinimo),
          reason: '${e.key} masa ${formatearSalario(masa)}');
    }

    // Picks: horizonte intacto, dueños reales, nada duplicado.
    final vivos = await picksVivos(db);
    final equipos = porEquipo.keys.toSet();
    for (final p in vivos) {
      expect(equipos.contains(p.equipoActual), isTrue,
          reason: 'pick de nadie: ${p.equipoActual}');
      expect(equipos.contains(p.equipoOriginal), isTrue);
    }
    final claves = vivos.map((p) => '${p.temporada}|${p.ronda}|${p.equipoOriginal}');
    expect(claves.toSet().length, claves.length,
        reason: 'hay picks duplicados');
    expect(vivos.length, 30 * rondasDeDraft * aniosDePicksFuturos);

    // Nombres únicos en toda la base (retirados incluidos).
    final todos = await db.select(db.jugadores).get();
    final nombres = todos.map((j) => j.nombreFicticio).toList();
    expect(nombres.toSet().length, nombres.length,
        reason: 'nombres repetidos');

    // Nadie en un limbo raro.
    final equiposValidos = {...equipos, equipoAgenciaLibre, equipoRetirados};
    for (final j in todos) {
      expect(equiposValidos.contains(j.equipo) || j.retirado, isTrue,
          reason: '${j.nombreFicticio} está en "${j.equipo}"');
    }

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 5)));
}
