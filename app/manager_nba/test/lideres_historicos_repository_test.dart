import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/legado_real_repository.dart';
import 'package:manager_nba/domain/lideres_historicos_repository.dart';

/// Los líderes históricos cubren TODA la historia de la liga: las leyendas
/// ya retiradas (que no tienen fila en `Jugadores`) y los de tu partida,
/// sumando carrera real y simulada bajo el mismo total. Los que siguen
/// jugando van marcados como en activo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late List<Jugador> jugadores;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
    jugadores = await db.select(db.jugadores).get();
    await datosRealesDe('Michael Jordan');
  });

  tearDown(() => db.close());

  test('las leyendas ya retiradas mandan en la lista: Jordan aparece con '
      'sus puntos reales aunque no juegue en tu partida', () async {
    final lideres = await leerLideresHistoricos(db);
    final jordanReal = await carreraRealDe('Michael Jordan');

    final jordan = lideres.puntos.firstWhere((l) => l.nombre == 'Michael Jordan');
    expect(jordan.total, jordanReal!.puntos);
    expect(jordan.jugadorId, isNull, reason: 'no tiene fila en Jugadores');
    expect(jordan.enActivo, isFalse, reason: 'lleva retirado décadas');
  });

  test('van de mayor a menor', () async {
    final lideres = await leerLideresHistoricos(db);
    for (final lista in [
      lideres.puntos,
      lideres.asistencias,
      lideres.rebotes,
    ]) {
      final totales = lista.map((l) => l.total).toList();
      expect(totales, orderedEquals([...totales]..sort((a, b) => b.compareTo(a))));
    }
  });

  test('los jugadores de tu liga salen marcados como en activo, y dejan de '
      'estarlo al retirarse', () async {
    final jugador = jugadores.firstWhere((j) => j.nombreReal.isNotEmpty);

    var lideres = await leerLideresHistoricos(db, top: jugadores.length * 2);
    var fila =
        lideres.puntos.firstWhere((l) => l.nombreReal == jugador.nombreReal);
    expect(fila.enActivo, isTrue);
    expect(fila.jugadorId, jugador.id);

    await (db.update(db.jugadores)..where((t) => t.id.equals(jugador.id)))
        .write(const JugadoresCompanion(retirado: Value(true)));

    lideres = await leerLideresHistoricos(db, top: jugadores.length * 2);
    fila = lideres.puntos.firstWhere((l) => l.nombreReal == jugador.nombreReal);
    expect(fila.enActivo, isFalse,
        reason: 'al retirarse se le quita el color de activo');
  });

  test('a alguien con carrera real se le suman los puntos reales y los '
      'simulados en el mismo total, sin separarlos', () async {
    final jugador =
        jugadores.firstWhere((j) => j.nombreReal == 'Michael Jordan',
            orElse: () => jugadores.first);
    await db.update(db.jugadores).replace(
        jugador.copyWith(nombreReal: 'Michael Jordan'));

    await db.into(db.historialEstadisticasJugador).insert(
        HistorialEstadisticasJugadorCompanion.insert(
          temporada: 1,
          jugadorId: jugador.id,
          equipo: jugador.equipo,
          media: 95,
          partidosJugados: 70,
          puntosTotales: 2000,
          asistenciasTotales: 300,
          rebotesTotales: 300,
        ));

    final jordanReal = await carreraRealDe('Michael Jordan');
    final lideres = await leerLideresHistoricos(db);
    final fila =
        lideres.puntos.firstWhere((l) => l.nombreReal == 'Michael Jordan');

    expect(fila.total, jordanReal!.puntos + 2000);
    expect(fila.enActivo, isTrue, reason: 'ahora sí juega en tu liga');
  });

  test('las estadísticas de la temporada en curso (sin archivar) también '
      'cuentan', () async {
    final activo = jugadores.firstWhere((j) => j.nombreReal.isEmpty,
        orElse: () => jugadores.last);
    await db.update(db.jugadores).replace(activo.copyWith(nombreReal: ''));
    await db.into(db.estadisticasTemporadaJugador).insert(
        EstadisticasTemporadaJugadorCompanion.insert(
          jugadorId: Value(activo.id),
          partidosJugados: const Value(40),
          puntosTotales: const Value(1000),
          asistenciasTotales: const Value(200),
          rebotesTotales: const Value(150),
        ));

    final lideres = await leerLideresHistoricos(db, top: jugadores.length * 2);
    final fila = lideres.puntos.firstWhere((l) => l.jugadorId == activo.id);
    expect(fila.total, 1000);
  });
}
