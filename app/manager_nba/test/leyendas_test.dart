import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/camisetas_repository.dart';
import 'package:manager_nba/domain/carrera_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/leyendas.dart';

/// Las leyendas reales las honra la franquicia con la que hicieron
/// historia, no la que las tuviera fichadas el último año.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
  });

  tearDown(() => db.close());

  Future<Jugador> porNombreReal(String nombre) =>
      (db.select(db.jugadores)..where((t) => t.nombreReal.equals(nombre)))
          .getSingle();

  group('mapa de leyendas', () {
    test('todos los nombres del mapa existen en el dataset: si no, la '
        'retirada automática nunca se dispararía', () async {
      final reales = (await db.select(db.jugadores).get())
          .map((j) => j.nombreReal)
          .toSet();
      for (final nombre in franquiciasHistoricas.keys) {
        expect(reales, contains(nombre));
      }
    });

    test('la franquicia elegida es la histórica, y entre varias se prefiere '
        'donde esté jugando ahora', () {
      // Chris Paul: Clippers y Pelicans. Si acaba en cualquiera de las dos,
      // esa; si acaba en otra, la primera de su historia.
      expect(franquiciaHistoricaDe('Chris Paul', preferida: 'NOP'), 'NOP');
      expect(franquiciaHistoricaDe('Chris Paul', preferida: 'SAS'), 'LAC');
      expect(franquiciaHistoricaDe('Chris Paul'), 'LAC');

      // Los que solo tienen una casa no admiten discusión.
      expect(franquiciaHistoricaDe('Klay Thompson', preferida: 'DAL'), 'GSW');
      expect(franquiciaHistoricaDe('Russell Westbrook', preferida: 'DEN'),
          'OKC');
    });

    test('un jugador cualquiera no es leyenda: su camiseta la decide lo que '
        'haga en tu partida', () {
      expect(franquiciaHistoricaDe('Un Rookie Cualquiera'), isNull);
      expect(esLeyendaReal('Un Rookie Cualquiera'), isFalse);
      expect(esLeyendaReal('Stephen Curry'), isTrue);
    });
  });

  group('retirada automática', () {
    test('al retirarse una leyenda, su franquicia histórica le retira la '
        'camiseta aunque acabara en otro equipo', () async {
      final klay = await porNombreReal('Klay Thompson');
      // Se le traspasa a un equipo que no pinta nada en su historia.
      await (db.update(db.jugadores)..where((t) => t.id.equals(klay.id)))
          .write(const JugadoresCompanion(equipo: Value('CHO')));

      final destino =
          franquiciaHistoricaDe(klay.nombreReal, preferida: 'CHO');
      expect(destino, 'GSW');

      await retirarCamiseta(db,
          equipo: destino!, jugadorId: klay.id, temporada: 3);

      final deGsw = await leerCamisetasRetiradas(db, 'GSW');
      expect(deGsw.map((c) => c.jugadorId), contains(klay.id));
      expect(await leerCamisetasRetiradas(db, 'CHO'), isEmpty);
    });

    test('retirar una camiseta dos veces no la duplica', () async {
      final curry = await porNombreReal('Stephen Curry');
      await retirarCamiseta(db, equipo: 'GSW', jugadorId: curry.id, temporada: 2);
      await retirarCamiseta(db, equipo: 'GSW', jugadorId: curry.id, temporada: 3);

      final deGsw = await leerCamisetasRetiradas(db, 'GSW');
      expect(deGsw.where((c) => c.jugadorId == curry.id), hasLength(1));
    });
  });

  group('carrera de una leyenda sin temporadas simuladas', () {
    test('leerCarrera no la ve (es lo que evalúa el Hall of Fame), pero la '
        'ficha sí', () async {
      final lebron = await porNombreReal('LeBron James');
      expect(lebron.temporadasPrevias, greaterThan(0));

      expect(await leerCarrera(db, lebron.id), isNull,
          reason: 'sin ningún año archivado no hay carrera que puntuar');

      final ficha = await leerCarreraParaFicha(db, lebron.id);
      expect(ficha, isNotNull,
          reason: 'pero su camiseta retirada tiene que llevar a algún sitio');
      expect(ficha!.vieneDeAntes, isTrue);
      expect(ficha.tieneTemporadasSimuladas, isFalse);
      expect(ficha.temporadasPrevias, lebron.temporadasPrevias);
      expect(ficha.ptsPgReferencia, lebron.ptsPg);
      expect(ficha.trbPgReferencia, lebron.trbPg);
      expect(ficha.mejorMedia, lebron.media,
          reason: 'sin años archivados, su media actual es lo que hay');
    });

    test('un jugador que no existe no tiene ficha', () async {
      expect(await leerCarreraParaFicha(db, 999999), isNull);
    });
  });
}
