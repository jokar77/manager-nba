import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/campeones_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.into(db.franquicia).insert(
        FranquiciaCompanion.insert(id: const Value(0), equipo: 'DEN'));

    // El palmarés compartido (equiposConTituloDelUsuario) vive en la base
    // de ajustes, no en la partida: en un test se sustituye por una en
    // memoria para no depender de `path_provider`.
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
  });

  tearDown(() async {
    await db.close();
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  test('solo cuentan como trofeo tuyo los títulos que gana el equipo que '
      'estás dirigiendo; los de la CPU quedan guardados pero no rellenan '
      'el palmarés del selector', () async {
    await registrarCampeon(db, equipo: 'DEN', tipo: 'nba');
    await registrarCampeon(db, equipo: 'LAL', tipo: 'nba');
    await registrarCampeon(db, equipo: 'BOS', tipo: 'ist');
    await registrarCampeon(db, equipo: 'DEN', tipo: 'ist');

    expect(await equiposConTituloDelUsuario('nba'), {'DEN'});
    expect(await equiposConTituloDelUsuario('ist'), {'DEN'});

    // Nada se pierde: los títulos de la CPU siguen en el histórico, tanto
    // en la partida como en el registro compartido.
    final todos = await db.select(db.historialCampeones).get();
    expect(todos, hasLength(4));
    expect(todos.where((c) => c.logradoPorUsuario), hasLength(2));

    final compartido = abrirAjustes();
    final todosCompartidos =
        await compartido.select(compartido.historialCampeones).get();
    expect(todosCompartidos, hasLength(4));
  });

  test('sin franquicia activa, ningún título cuenta como tuyo', () async {
    await db.delete(db.franquicia).go();
    await registrarCampeon(db, equipo: 'DEN', tipo: 'nba');

    expect(await equiposConTituloDelUsuario('nba'), isEmpty);
  });

  test('el palmarés es tuyo, no de la partida: vive en su propio fichero, '
      'independiente del de la ranura', () async {
    await registrarCampeon(db, equipo: 'DEN', tipo: 'nba');

    // Otra "partida" cualquiera, sin ningún dato compartido con `db` —
    // igual que sería otra ranura de guardado.
    final otraPartida = AppDatabase.forTesting(NativeDatabase.memory());

    expect(await equiposConTituloDelUsuario('nba'), {'DEN'},
        reason: 'el trofeo del selector de equipos no depende de qué '
            'ranura tengas abierta ahora mismo');

    await otraPartida.close();
  });
}
