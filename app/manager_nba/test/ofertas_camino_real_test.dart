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
import 'package:manager_nba/domain/tipo_evento_temporada.dart';

/// Las ofertas se generan tras cada tramo simulado, y el ritmo tiene que
/// ser el mismo simules como simules. Antes se tiraba UNA vez por llamada
/// con probabilidad `min(0,35; partidos*0,06)`: quien avanzaba semana a
/// semana tenía ~27 oportunidades por temporada y quien le daba a "simular
/// hasta el final" tenía dos o tres. Medido por este mismo camino, cuatro
/// temporadas seguidas daban 0, 0, 0 y 1 oferta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('simulando la temporada de una tacada llegan ofertas igual, sin '
      'pasarse del tope y ninguna tras la fecha límite', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await guardarRotacion(db, generarRotacionAutomatica(await (db.select(db.jugadores)..where((t) => t.equipo.equals('DEN'))).get()));
    final rng = Random(11);

    for (var t = 1; t <= 4; t++) {
      final limite = await (db.select(db.eventosTemporada)
            ..where((e) =>
                e.tipo.equals(TipoEventoTemporada.fechaLimiteTraspasos.name)))
          .get();
      var generadas = 0;
      var trasLimite = 0;

      // Igual que simulacion_ui: se avanza por tramos y tras cada uno se
      // intenta generar oferta con la última fecha simulada.
      final partidos = await leerPartidos(db, 'DEN');
      final meta = partidos.map((p) => p.fecha).reduce((a, b) => a.isAfter(b) ? a : b);
      int? ignorar;
      while (true) {
        final tramo =
            await simularTramo(db, 'DEN', meta, eventoIdAIgnorar: ignorar);
        if (tramo.simulados.isNotEmpty) {
          final cursor = tramo.simulados
              .map((p) => p.fecha)
              .reduce((a, b) => a.isAfter(b) ? a : b);
          final n = await generarOfertasEntrantes(db,
              equipoUsuario: 'DEN',
              partidosSimulados: tramo.simulados.length,
              fecha: cursor,
              random: rng);
          generadas += n;
          if (n > 0 && limite.isNotEmpty && cursor.isAfter(limite.first.fecha)) {
            trasLimite += n;
          }
          await db.delete(db.ofertasTraspaso).go();
        }
        if (tramo.eventoBloqueante == null) break;
        ignorar = tramo.eventoBloqueante!.id;
      }

      final temporada = await leerTemporada(db);
      expect(generadas, greaterThan(0),
          reason: 'la temporada $t se quedó sin una sola oferta');
      expect(generadas, lessThanOrEqualTo(maxOfertasPorTemporada),
          reason: 'la temporada $t generó $generadas, por encima del tope');
      expect(trasLimite, 0,
          reason: 'la temporada $t generó $trasLimite ofertas con el '
              'mercado ya cerrado');
      expect(temporada.ofertasGeneradasEstaTemporada, generadas);

      await empezarNuevaTemporada(db, random: rng);
    }

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 15)));
}
