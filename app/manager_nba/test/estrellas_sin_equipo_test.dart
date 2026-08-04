import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/domain/tipo_evento_temporada.dart';

/// Un jugador de nivel no se pasa la temporada en su casa: en la NBA real
/// firma en cuanto sale al mercado.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tras el verano no quedan jugadores de nivel sin equipo', () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'MIN');

    // La temporada 1 cuenta: Harden (88) y DeRozan (84) arrancan el dataset
    // ya como agentes libres, y el reparto de estrellas solo corría en el
    // verano — así que se pasaban el primer año enteros en su casa.
    final librosT1 = (await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals(equipoAgenciaLibre)))
            .get())
        .where((j) => !j.retirado && j.media >= 78)
        .toList();
    // ignore: avoid_print
    print('al empezar la partida: ${librosT1.length} de 78+ libres '
        '${librosT1.map((j) => j.media).toList()}');

    final rng = Random(3);
    for (var t = 1; t <= 3; t++) {
      await empezarNuevaTemporada(db, random: rng);

      final libres = (await (db.select(db.jugadores)
                ..where((t) => t.equipo.equals(equipoAgenciaLibre)))
              .get())
          .where((j) => !j.retirado)
          .toList()
        ..sort((a, b) => b.media.compareTo(a.media));

      final deNivel = libres.where((j) => j.media >= 78).toList();
      // ignore: avoid_print
      print('temporada $t: ${libres.length} libres, '
          '${deNivel.length} con media 78+ '
          '${deNivel.take(6).map((j) => '${j.nombreFicticio}(${j.media})').toList()}');

      expect(deNivel, isEmpty,
          reason: 'temporada $t: ${deNivel.length} jugadores de 78+ sin '
              'equipo. El peor bloqueo era que en cuanto UNO no encontraba '
              'sitio, el reparto de estrellas cortaba por lo sano y dejaba '
              'a todos los de detrás en la calle.');
    }

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 15)));

  test('en la temporada 1 la liga se reparte a los libres de nivel al '
      'cerrarse tu ventana de mercado', () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'MIN');
    await guardarRotacion(
        db,
        generarRotacionAutomatica(await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals('MIN')))
            .get()));

    Future<List<Jugador>> libresDeNivel() async =>
        (await (db.select(db.jugadores)
                  ..where((t) => t.equipo.equals(equipoAgenciaLibre)))
                .get())
            .where((j) => !j.retirado && j.media >= 78)
            .toList();

    // El dataset arranca con estrellas en la calle: Harden (88) y DeRozan
    // (84) entre ellas.
    expect(await libresDeNivel(), isNotEmpty);

    final limite = (await leerEventos(db)).firstWhere(
        (e) => e.tipo == TipoEventoTemporada.finAgenciaLibre.name);

    // Antes de la fecha límite el mercado es tuyo: nadie te los quita.
    await simularTramo(
        db, 'MIN', limite.fecha.subtract(const Duration(days: 3)));
    expect(await libresDeNivel(), isNotEmpty,
        reason: 'hasta que no se cierra tu ventana, el primer turno es tuyo');

    // Al cruzarla, la liga se los reparte. Antes esto solo pasaba en verano,
    // así que un 88 se quedaba sin equipo la temporada entera.
    var vueltas = 0;
    int? ignorar;
    while (vueltas++ < 6) {
      final tramo = await simularTramo(
          db, 'MIN', limite.fecha.add(const Duration(days: 7)),
          eventoIdAIgnorar: ignorar);
      if (tramo.eventoBloqueante == null) break;
      ignorar = tramo.eventoBloqueante!.id;
    }

    final quedan = await libresDeNivel();
    expect(quedan, isEmpty,
        reason: 'siguen sin equipo: '
            '${quedan.map((j) => '${j.nombreFicticio}(${j.media})').toList()}');

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 10)));
}
