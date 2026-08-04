import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/camisetas_repository.dart';
import 'package:manager_nba/domain/carrera_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/legado_historico_repository.dart';

/// El legado real (camisetas retiradas y Hall of Fame de verdad) que el
/// usuario pasó como datos: se importa una vez, no se pisa con lo que gana
/// la CPU o el jugador dentro de la partida, y bloquea sus números para
/// siempre.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
  });

  tearDown(() => db.close());

  test('importa camisetas retiradas reales de varias franquicias, con '
      'jugadorId negativo (no hay simulación detrás) y sin colar entradas '
      'sin número de verdad', () async {
    await importarLegadoHistoricoSiHaceFalta(db);

    final deChicago = await leerCamisetasRetiradas(db, 'CHI');
    // Jordan (23), Pippen (33), Sloan (4), Love (10) sí; Phil Jackson,
    // Johnny Kerr y Jerry Krause ("-", sin dorsal) no.
    expect(deChicago.map((c) => c.dorsal), containsAll([4, 10, 23, 33]));
    expect(deChicago.any((c) => c.nombreJugador.contains('Jackson')), isFalse,
        reason: 'sin número real no hay nada que bloquear');
    expect(deChicago.every((c) => c.jugadorId < 0), isTrue);

    final deDenver = await leerCamisetasRetiradas(db, 'DEN');
    expect(deDenver.any((c) => c.dorsal == 432), isFalse,
        reason: '432 son las victorias de Doug Moe coladas por el número, '
            'no un dorsal');

    // Los Clippers no han retirado nunca nada en la vida real.
    expect(await leerCamisetasRetiradas(db, 'LAC'), isEmpty);

    // 232 entradas en el dato de origen, 17 sin número real (honores sin
    // camiseta o victorias de entrenador coladas por el campo del número):
    // tienen que quedar fuera exactamente esas 17, ni una más ni una menos.
    final todas = await db.select(db.camisetasRetiradas).get();
    expect(todas, hasLength(215));
  });

  test('llamarla dos veces no duplica nada', () async {
    await importarLegadoHistoricoSiHaceFalta(db);
    final primera = await leerCamisetasRetiradas(db, 'BOS');

    await importarLegadoHistoricoSiHaceFalta(db);
    final segunda = await leerCamisetasRetiradas(db, 'BOS');

    expect(segunda.length, primera.length);
  });

  test('importa el Hall of Fame real con el año de ingreso codificado en '
      'negativo, distinto de una temporada de la partida', () async {
    await importarLegadoHistoricoSiHaceFalta(db);

    final miembros = await db.select(db.hallDeLaFama).get();
    expect(miembros, isNotEmpty);
    expect(miembros.every((m) => m.jugadorId < 0), isTrue);

    final jordan =
        miembros.firstWhere((m) => m.nombreJugador == 'Michael Jordan');
    expect(jordan.temporadaIngreso, -2009);
    expect(miembros, hasLength(155));
  });

  test('una leyenda real no tiene carrera simulada (leerCarrera), pero su '
      'ficha no se rompe (leerCarreraParaFicha)', () async {
    await importarLegadoHistoricoSiHaceFalta(db);
    final miembros = await db.select(db.hallDeLaFama).get();
    final russell =
        miembros.firstWhere((m) => m.nombreJugador == 'Bill Russell');

    expect(await leerCarrera(db, russell.jugadorId), isNull);
    expect(await leerCarreraParaFicha(db, russell.jugadorId), isNull,
        reason: 'no hay jugador real detrás, ni siquiera de referencia');
  });

  group('bloqueo de números retirados', () {
    test('si un jugador actual llevaba puesto un número que la historia '
        'real acaba de bloquear, se le reasigna otro en el momento',
        () async {
      final bulls = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('CHI') & t.retirado.equals(false)))
          .get();
      final cualquiera = bulls.first;
      // Se le fuerza el 23 de Jordan a mano, simulando la coincidencia.
      await (db.update(db.jugadores)..where((t) => t.id.equals(cualquiera.id)))
          .write(const JugadoresCompanion(dorsal: Value(23)));

      await importarLegadoHistoricoSiHaceFalta(db);

      final tras = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(cualquiera.id)))
          .getSingle();
      expect(tras.dorsal, isNot(23));
      expect(tras.dorsal, isNotNull, reason: 'se le reparte uno libre');
    });

    test('asignarDorsalesQueFalten nunca da un número ya retirado (real o '
        'del juego) a un jugador nuevo', () async {
      await importarLegadoHistoricoSiHaceFalta(db);

      final lal = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('LAL')))
          .get();
      final retirados = (await leerCamisetasRetiradas(db, 'LAL'))
          .map((c) => c.dorsal)
          .toSet();
      for (final j in lal) {
        if (j.dorsal == null) continue;
        expect(retirados.contains(j.dorsal), isFalse,
            reason: '${j.nombreFicticio} lleva un número retirado');
      }
    });

    test('si el jugador que se retira ya tiene su número real conocido en '
        'ese equipo (legado real), se usa ese en vez del dorsal que lleva '
        'puesto ahora mismo', () async {
      await importarLegadoHistoricoSiHaceFalta(db);

      final bulls = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('CHI') & t.retirado.equals(false)))
          .get();
      final cualquiera = bulls.first;
      // Se hace pasar por Jordan, cuyo 23 con los Bulls ya está en el dato
      // real importado (jugadorId negativo): simula que fue traspasado
      // antes de retirarse y su dorsal actual (99) no es el de verdad.
      await (db.update(db.jugadores)..where((t) => t.id.equals(cualquiera.id)))
          .write(const JugadoresCompanion(
              nombreReal: Value('Michael Jordan'), dorsal: Value(99)));

      await retirarCamiseta(db,
          equipo: 'CHI', jugadorId: cualquiera.id, temporada: 5);

      final retirada = await (db.select(db.camisetasRetiradas)
            ..where((t) => t.jugadorId.equals(cualquiera.id)))
          .getSingle();
      expect(retirada.dorsal, 23,
          reason: 'el 23 real de Jordan con los Bulls, no el 99 que llevaba');
    });

    test('retirar una camiseta en directo libera el sitio a quien la '
        'llevara puesta en ese momento, sin tocar al resto', () async {
      final lal = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('LAL') & t.retirado.equals(false)))
          .get();
      final seRetira = lal[0];
      final coincide = lal[1];
      final ajeno = lal[2];
      // Los dos primeros con el mismo número, como si el reparto hubiera
      // coincidido antes de que se retirara la camiseta.
      await (db.update(db.jugadores)..where((t) => t.id.equals(seRetira.id)))
          .write(const JugadoresCompanion(dorsal: Value(77)));
      await (db.update(db.jugadores)..where((t) => t.id.equals(coincide.id)))
          .write(const JugadoresCompanion(dorsal: Value(77)));
      await (db.update(db.jugadores)..where((t) => t.id.equals(ajeno.id)))
          .write(const JugadoresCompanion(dorsal: Value(88)));

      await retirarCamiseta(db,
          equipo: 'LAL', jugadorId: seRetira.id, temporada: 5);

      final deColision = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(coincide.id)))
          .getSingle();
      expect(deColision.dorsal, isNot(77),
          reason: 'ya no puede llevar el número que se acaba de retirar');

      final sinTocar = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(ajeno.id)))
          .getSingle();
      expect(sinTocar.dorsal, 88, reason: 'a este no le tocaba nada');
    });
  });

  test('empezar una franquicia nueva en la misma ranura conserva el legado '
      'real, pero borra el Hall of Fame y las camisetas que ganó la '
      'partida anterior', () async {
    await importarLegadoHistoricoSiHaceFalta(db);

    // Un "logro" de la partida anterior: jugadorId positivo, de verdad.
    final propio = (await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('LAL')))
        .get())
        .first;
    await retirarCamiseta(db,
        equipo: 'LAL', jugadorId: propio.id, temporada: 5);
    await db.into(db.hallDeLaFama).insert(HallDeLaFamaCompanion.insert(
        jugadorId: propio.id,
        nombreJugador: propio.nombreFicticio,
        temporadaIngreso: 5,
        puntuacion: 90));

    await nuevaFranquicia(db);

    final camisetas = await db.select(db.camisetasRetiradas).get();
    expect(camisetas.every((c) => c.jugadorId < 0), isTrue,
        reason: 'lo real se queda, lo de la partida anterior se va');
    expect(camisetas, isNotEmpty);

    final hof = await db.select(db.hallDeLaFama).get();
    expect(hof.every((m) => m.jugadorId < 0), isTrue);
    expect(hof, isNotEmpty);
  });
}
