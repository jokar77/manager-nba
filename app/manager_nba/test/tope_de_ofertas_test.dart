import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/ofertas_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

/// El tope de 3 ofertas por temporada tiene que valer en TODAS las
/// temporadas, no solo en la primera.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ninguna temporada pasa del tope de ofertas', () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'MIN');
    await guardarRotacion(
        db,
        generarRotacionAutomatica(await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals('MIN')))
            .get()));

    final rng = Random(11);
    final porTemporada = <int>[];

    for (var t = 1; t <= 3; t++) {
      // Se simula el año entero como lo hace el calendario: tramo a tramo,
      // generando ofertas después de cada uno.
      final partidos = await leerPartidos(db, 'MIN');
      final ultimo = partidos.last.fecha;
      var creadasEsteAno = 0;
      var vueltas = 0;
      int? ignorar;
      while (vueltas++ < 40) {
        final tramo =
            await simularTramo(db, 'MIN', ultimo, eventoIdAIgnorar: ignorar);
        if (tramo.simulados.isNotEmpty) {
          creadasEsteAno += await generarOfertasEntrantes(
            db,
            equipoUsuario: 'MIN',
            partidosSimulados: tramo.simulados.length,
            fecha: tramo.simulados.last.fecha,
            random: rng,
          );
        }
        if (tramo.eventoBloqueante == null) break;
        ignorar = tramo.eventoBloqueante!.id;
      }

      final temporada = await (db.select(db.temporada)
            ..where((t) => t.id.equals(0)))
          .getSingle();
      porTemporada.add(creadasEsteAno);
      expect(creadasEsteAno, lessThanOrEqualTo(maxOfertasPorTemporada),
          reason: 'la temporada $t generó $creadasEsteAno ofertas');
      expect(temporada.ofertasGeneradasEstaTemporada,
          lessThanOrEqualTo(maxOfertasPorTemporada),
          reason: 'el contador de la temporada $t se ha ido a '
              '${temporada.ofertasGeneradasEstaTemporada}');

      if (t < 3) await empezarNuevaTemporada(db, random: rng);
    }

    // Y el contador tiene que arrancar a cero cada verano, o el tope del año
    // siguiente nacería ya agotado (o al revés, si no se guardara).
    final temporadaFinal = await (db.select(db.temporada)
          ..where((t) => t.id.equals(0)))
        .getSingle();
    expect(temporadaFinal.numero, 3);

    // ignore: avoid_print
    print('ofertas por temporada: $porTemporada');

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 15)));

  test('aplazar una oferta la deja en la bandeja pero deja de avisar',
      () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'MIN');

    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('MIN')))
        .get();
    final rival = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('BOS')))
        .get();
    await db.into(db.ofertasTraspaso).insert(OfertasTraspasoCompanion.insert(
          equipoOfertante: 'BOS',
          pideJugadores: '${plantilla.first.id}',
          ofreceJugadores: '${rival.first.id}',
          fecha: DateTime(2026, 12, 1),
        ));

    expect(await ofertasSinVer(db), 1);

    // Lo que hace el aviso al cerrarse, tanto si vas a verlas como si dices
    // "más tarde": darlas por avisadas. Antes solo lo hacía la pantalla de
    // ofertas, así que aplazar una hacía que el aviso volviera a saltar —y
    // cortara la simulación— en cada tramo, dando la sensación de que
    // llegaban ofertas sin parar.
    await marcarOfertasComoVistas(db);

    expect(await ofertasSinVer(db), 0,
        reason: 'ya se ha avisado: no debe volver a interrumpir');
    expect(await ofertasPendientes(db, 'MIN'), hasLength(1),
        reason: 'aplazarla no es rechazarla: sigue sobre la mesa');

    await db.close();
  });
}
