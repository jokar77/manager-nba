import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/lesiones_repository.dart';

/// El "hoy" de la partida. Todo lo que dependa de en qué punto de la
/// temporada estamos —sobre todo quién sigue lesionado— tiene que mirar el
/// calendario del juego y no el reloj del ordenador: son dos líneas de
/// tiempo distintas, y compararlas daba respuestas absurdas (un jugador que
/// volvió en noviembre seguía saliendo lesionado en abril).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> sembrarPartido(DateTime fecha, {required bool jugado}) async {
    await db.into(db.partidosCalendario).insert(
          PartidosCalendarioCompanion.insert(
            equipoPropietario: 'DEN',
            rival: 'LAL',
            fecha: fecha,
            esLocal: true,
            jugado: Value(jugado),
          ),
        );
  }

  test('sin calendario todavía, no hay fecha que dar', () async {
    expect(await fechaActualDeLaLiga(db), isNull);
  });

  test('antes de jugar nada, es el día del primer partido', () async {
    await sembrarPartido(DateTime(2026, 12, 5), jugado: false);
    await sembrarPartido(DateTime(2026, 10, 22), jugado: false);

    expect(await fechaActualDeLaLiga(db), DateTime(2026, 10, 22));
  });

  test('con la temporada en marcha, es el último partido jugado', () async {
    await sembrarPartido(DateTime(2026, 10, 22), jugado: true);
    await sembrarPartido(DateTime(2027, 1, 15), jugado: true);
    await sembrarPartido(DateTime(2027, 3, 1), jugado: false);

    expect(await fechaActualDeLaLiga(db), DateTime(2027, 1, 15));
  });

  test('un jugador que ya se recuperó dentro de la partida no cuenta como '
      'lesionado, aunque su fecha de vuelta siga por delante del reloj real',
      () async {
    // La partida va por enero de 2027; él volvió el 30 de noviembre.
    await sembrarPartido(DateTime(2027, 1, 15), jugado: true);
    await db.into(db.lesiones).insert(LesionesCompanion.insert(
          jugadorId: 1,
          fechaFin: DateTime(2026, 11, 30),
          gravedad: 'grave',
        ));

    final hoy = await fechaActualDeLaLiga(db);
    expect(hoy, isNotNull);
    expect(await lesionesActivasEn(db, hoy!), isEmpty,
        reason: 'volvió hace mes y medio de calendario de juego');

    // Y este es justo el fallo que había: medido contra el reloj del
    // ordenador —que va por detrás del año en el que transcurre la
    // partida— la misma lesión parecía seguir activa.
    expect(await lesionesActivasEn(db, DateTime(2026, 8, 2)), isNotEmpty,
        reason: 'comparar contra una fecha real anterior lo daba por '
            'lesionado: es lo que hacía DateTime.now()');
  });

  test('el que sigue lesionado de verdad sí cuenta', () async {
    await sembrarPartido(DateTime(2027, 1, 15), jugado: true);
    await db.into(db.lesiones).insert(LesionesCompanion.insert(
          jugadorId: 7,
          fechaFin: DateTime(2027, 2, 20),
          gravedad: 'grave',
        ));

    final hoy = await fechaActualDeLaLiga(db);
    expect(await lesionesActivasEn(db, hoy!), contains(7));
  });
}
