import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/contratos_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/patrocinadores.dart';
import 'package:manager_nba/domain/patrocinadores_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
  });

  tearDown(() => db.close());

  test('sin tocar nada, no hay ningún patrocinio activo', () async {
    expect(await leerPatrociniosActivos(db), isEmpty);
    expect(await bonusSalarialDePatrocinadores(db, equipoUsuario: 'DEN'), 0);
  });

  test('activar una categoría la deja activa, y desactivarla la quita',
      () async {
    await alternarPatrocinio(db, 'estadio', activo: true);
    expect(await leerPatrociniosActivos(db), {'estadio'});

    await alternarPatrocinio(db, 'estadio', activo: false);
    expect(await leerPatrociniosActivos(db), isEmpty);
  });

  test('activar la misma categoría dos veces no la duplica', () async {
    await alternarPatrocinio(db, 'camiseta', activo: true);
    await alternarPatrocinio(db, 'camiseta', activo: true);
    expect(await leerPatrociniosActivos(db), {'camiseta'});
  });

  test('el bonus suma exactamente el de cada categoría activa, del equipo '
      'que sea', () async {
    await alternarPatrocinio(db, 'estadio', activo: true);
    await alternarPatrocinio(db, 'ocio', activo: true);

    final esperado = patrocinadorDe('DEN', 'estadio')!.bonusSalarial +
        patrocinadorDe('DEN', 'ocio')!.bonusSalarial;
    expect(await bonusSalarialDePatrocinadores(db, equipoUsuario: 'DEN'),
        esperado);
  });

  test('limpiarPatrocinios desactiva todo', () async {
    await alternarPatrocinio(db, 'estadio', activo: true);
    await alternarPatrocinio(db, 'bebida', activo: true);

    await limpiarPatrocinios(db);

    expect(await leerPatrociniosActivos(db), isEmpty);
    expect(await bonusSalarialDePatrocinadores(db, equipoUsuario: 'DEN'), 0);
  });

  test('el bonus de patrocinadores llega al espacio salarial, y solo al '
      'tuyo', () async {
    final antesTuyo = await espacioSalarial(db, 'DEN');
    final antesRival = await espacioSalarial(db, 'LAL');

    await alternarPatrocinio(db, 'camiseta', activo: true);
    final bonus = patrocinadorDe('DEN', 'camiseta')!.bonusSalarial;

    expect(await espacioSalarial(db, 'DEN'), antesTuyo + bonus,
        reason: 'el margen es para tu equipo');
    expect(await espacioSalarial(db, 'LAL'), antesRival,
        reason: 'los otros 29 no eligen patrocinadores: no les toca nada');
  });

  test('nuevaFranquicia deja los patrocinios de la partida anterior fuera',
      () async {
    await alternarPatrocinio(db, 'estadio', activo: true);
    expect(await leerPatrociniosActivos(db), isNotEmpty);

    await nuevaFranquicia(db);

    expect(await leerPatrociniosActivos(db), isEmpty);
  });
}
