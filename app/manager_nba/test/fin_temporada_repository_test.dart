import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/calendario/generador_calendario.dart';
import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/fin_temporada_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/domain/tipo_premio.dart';

/// El cierre de la temporada regular es lo que siembra los playoffs. Su
/// guarda de "esto ya está hecho" no puede mirar la tabla de premios
/// entera: los MVP del fin de semana de las estrellas viven ahí y se
/// conceden en FEBRERO, con la temporada a medias.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');

    // Récords ficticios para poder sembrar sin simular 82 partidos de
    // verdad (mismo apaño que playoffs_repository_test.dart).
    final equipos = await db.select(db.resultadoTemporada).get();
    for (var i = 0; i < equipos.length; i++) {
      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals(equipos[i].equipo)))
          .write(ResultadoTemporadaCompanion(
        victorias: Value(82 - i),
        derrotas: Value(i),
      ));
    }

    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
  });

  tearDown(() async {
    await db.close();
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  /// Da por jugados los 82 partidos de temporada regular de [equipo].
  Future<void> terminarLaTemporadaRegularDe(String equipo) async {
    await (db.update(db.partidosCalendario)
          ..where((t) =>
              t.equipoPropietario.equals(equipo) & t.fase.equals(faseRegular)))
        .write(const PartidosCalendarioCompanion(jugado: Value(true)));
  }

  /// El MVP del All-Star, tal y como lo concede allstar_repository.dart en
  /// febrero: una fila más en `premiosTemporada`.
  Future<void> concederMvpDelAllStar() async {
    final jugador = (await (db.select(db.jugadores)..limit(1)).get()).first;
    await db.into(db.premiosTemporada).insert(PremiosTemporadaCompanion.insert(
          tipo: TipoPremio.mvpAllStar.name,
          jugadorId: jugador.id,
        ));
  }

  test('al acabar los 82 partidos se siembran los playoffs', () async {
    await terminarLaTemporadaRegularDe('DEN');

    expect(await cerrarTemporadaRegularSiToca(db, 'DEN'), isTrue);
    expect(await leerSeries(db), isNotEmpty,
        reason: 'sin series sembradas no hay playoffs que enseñar');
  });

  test('haber jugado el All-Star en febrero no impide que se siembren los '
      'playoffs en abril', () async {
    // El orden real de una temporada: primero el All-Star (febrero), y
    // meses después el final de la temporada regular.
    await concederMvpDelAllStar();
    await terminarLaTemporadaRegularDe('DEN');

    expect(await cerrarTemporadaRegularSiToca(db, 'DEN'), isTrue,
        reason: 'el MVP del All-Star no es un premio de fin de temporada, '
            'así que no puede contar como "esto ya estaba cerrado"');
    expect(await leerSeries(db), isNotEmpty,
        reason: 'este es el bug: la temporada acababa y los playoffs no '
            'aparecían por ningún lado');
  });

  test('es idempotente: una segunda llamada no vuelve a sembrar', () async {
    await terminarLaTemporadaRegularDe('DEN');
    await cerrarTemporadaRegularSiToca(db, 'DEN');
    final seriesTrasLaPrimera = await leerSeries(db);

    expect(await cerrarTemporadaRegularSiToca(db, 'DEN'), isFalse);
    expect((await leerSeries(db)).length, seriesTrasLaPrimera.length);
  });

  test('con la temporada a medias no se siembra nada', () async {
    expect(await cerrarTemporadaRegularSiToca(db, 'DEN'), isFalse);
    expect(await leerSeries(db), isEmpty);
  });
}
