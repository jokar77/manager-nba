import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/carrera_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/tipo_premio.dart';

/// La carrera guarda en qué temporada exacta se ganó cada premio individual
/// (no solo cuántas veces), para que la ficha pueda mostrar el año junto al
/// trofeo — "MVP (24-25, 26-27)" dice mucho más que un "x2" suelto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late int jugadorId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    jugadorId =
        (await (db.select(db.jugadores)..limit(1)).getSingle()).id;

    await db.into(db.historialEstadisticasJugador).insert(
        HistorialEstadisticasJugadorCompanion.insert(
          temporada: 2,
          jugadorId: jugadorId,
          equipo: 'DEN',
          media: 90,
          partidosJugados: 70,
          puntosTotales: 1800,
          asistenciasTotales: 400,
          rebotesTotales: 500,
        ));
  });

  tearDown(() => db.close());

  Future<void> darPremio(TipoPremio tipo, int temporada) async {
    await db.into(db.historialPremios).insert(HistorialPremiosCompanion.insert(
          temporada: temporada,
          tipo: tipo.name,
          jugadorId: jugadorId,
          nombreJugador: 'Prueba',
          equipo: 'DEN',
        ));
  }

  test('temporadasDeGano trae las temporadas exactas de cada premio, no '
      'solo el conteo', () async {
    await darPremio(TipoPremio.mvp, 2);
    await darPremio(TipoPremio.mvp, 4);
    await darPremio(TipoPremio.mejorDefensor, 3);

    final carrera = await leerCarreraParaFicha(db, jugadorId);
    expect(carrera, isNotNull);
    expect(carrera!.vecesGano(TipoPremio.mvp), 2);
    expect(carrera.temporadasDeGano(TipoPremio.mvp), [2, 4]);
    expect(carrera.temporadasDeGano(TipoPremio.mejorDefensor), [3]);
  });

  test('las temporadas salen ordenadas aunque los premios no se hayan '
      'guardado en orden', () async {
    await darPremio(TipoPremio.rookieDelAno, 5);
    await darPremio(TipoPremio.rookieDelAno, 1);
    await darPremio(TipoPremio.rookieDelAno, 3);

    final carrera = await leerCarreraParaFicha(db, jugadorId);
    expect(carrera!.temporadasDeGano(TipoPremio.rookieDelAno), [1, 3, 5]);
  });

  test('sin premios de un tipo, la lista está vacía y no revienta', () async {
    final carrera = await leerCarreraParaFicha(db, jugadorId);
    expect(carrera!.temporadasDeGano(TipoPremio.masMejorado), isEmpty);
  });

  test('leerCarrerasParaFichas (la versión en lote) también trae las '
      'temporadas de cada premio', () async {
    await darPremio(TipoPremio.mvp, 2);
    await darPremio(TipoPremio.mvp, 6);

    final carreras = await leerCarrerasParaFichas(db, [jugadorId]);
    expect(carreras[jugadorId]!.temporadasDeGano(TipoPremio.mvp), [2, 6]);
  });
}
