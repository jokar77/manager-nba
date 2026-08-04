import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/tipo_evento_temporada.dart';
import 'package:manager_nba/domain/traspasos_repository.dart';

JugadoresCompanion _jugador(String nombre, String equipo) =>
    JugadoresCompanion.insert(
      nombreFicticio: nombre,
      nombreReal: '',
      posicion: 'Alero',
      equipo: equipo,
      edad: 25,
      media: 80,
      potencial: 85,
      atrTiro3: 75,
      atrAtaque: 80,
      atrDefensa: 75,
      ptsPg: 15,
      astPg: 4,
      trbPg: 5,
      factorLongevidad: 1,
      edadRetiro: 37,
    );

/// haPasadoFechaLimite es lo que bloquea Agencia Libre y Traspasos después
/// de su fecha: antes el diálogo avisaba al cruzarla pero nada impedía
/// seguir operando el resto de la temporada.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> sembrarPartido(DateTime fecha, {required bool jugado}) async {
    await db.into(db.partidosCalendario).insert(PartidosCalendarioCompanion.insert(
          equipoPropietario: 'DEN',
          rival: 'LAL',
          fecha: fecha,
          esLocal: true,
          jugado: Value(jugado),
        ));
  }

  test('sin fecha límite sembrada, no bloquea nada', () async {
    await sembrarPartido(DateTime(2026, 3, 1), jugado: true);
    expect(
        await haPasadoFechaLimite(
            db, 'DEN', TipoEventoTemporada.finAgenciaLibre),
        isFalse);
  });

  test('antes de la fecha límite, sigue abierto', () async {
    await db.into(db.eventosTemporada).insert(EventosTemporadaCompanion.insert(
          fecha: DateTime(2026, 3, 15),
          tipo: TipoEventoTemporada.finAgenciaLibre.name,
        ));
    await sembrarPartido(DateTime(2026, 3, 1), jugado: true);
    await sembrarPartido(DateTime(2026, 3, 20), jugado: false);

    expect(
        await haPasadoFechaLimite(
            db, 'DEN', TipoEventoTemporada.finAgenciaLibre),
        isFalse);
  });

  test('en cuanto tu último partido jugado es posterior a la fecha límite, '
      'se cierra', () async {
    await db.into(db.eventosTemporada).insert(EventosTemporadaCompanion.insert(
          fecha: DateTime(2026, 3, 15),
          tipo: TipoEventoTemporada.finAgenciaLibre.name,
        ));
    await sembrarPartido(DateTime(2026, 3, 1), jugado: true);
    await sembrarPartido(DateTime(2026, 3, 20), jugado: true);

    expect(
        await haPasadoFechaLimite(
            db, 'DEN', TipoEventoTemporada.finAgenciaLibre),
        isTrue);
  });

  group('el corte vive en el dominio, no solo en los botones', () {
    // Había varias pantallas capaces de cerrar un traspaso (la mesa, la
    // ficha de equipo desde Clasificación, aceptar una oferta) y solo una
    // miraba la fecha: salía el aviso y el traspaso se hacía igual.
    Future<void> sembrarFechaLimitePasada() async {
      await db.into(db.eventosTemporada).insert(
            EventosTemporadaCompanion.insert(
              fecha: DateTime(2027, 2, 5),
              tipo: TipoEventoTemporada.fechaLimiteTraspasos.name,
            ),
          );
      await sembrarPartido(DateTime(2027, 3, 1), jugado: true);
    }

    test('pasada la fecha, ejecutarTraspaso no mueve a nadie y devuelve false',
        () async {
      await sembrarFechaLimitePasada();
      final mio = await db.into(db.jugadores).insertReturning(
          _jugador('Mío', 'DEN'));
      final suyo = await db.into(db.jugadores).insertReturning(
          _jugador('Suyo', 'LAL'));

      final hecho = await ejecutarTraspaso(db,
          equipoUsuario: 'DEN',
          equipoRival: 'LAL',
          tuyos: [mio.id],
          suyos: [suyo.id]);

      expect(hecho, isFalse);
      final trasMio = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(mio.id)))
          .getSingle();
      final trasSuyo = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(suyo.id)))
          .getSingle();
      expect(trasMio.equipo, 'DEN', reason: 'no se ha movido nadie');
      expect(trasSuyo.equipo, 'LAL');
    });

    test('antes de la fecha sí se ejecuta', () async {
      await db.into(db.eventosTemporada).insert(
            EventosTemporadaCompanion.insert(
              fecha: DateTime(2027, 2, 5),
              tipo: TipoEventoTemporada.fechaLimiteTraspasos.name,
            ),
          );
      await sembrarPartido(DateTime(2027, 1, 10), jugado: true);

      final mio =
          await db.into(db.jugadores).insertReturning(_jugador('Mío', 'DEN'));
      final suyo =
          await db.into(db.jugadores).insertReturning(_jugador('Suyo', 'LAL'));

      final hecho = await ejecutarTraspaso(db,
          equipoUsuario: 'DEN',
          equipoRival: 'LAL',
          tuyos: [mio.id],
          suyos: [suyo.id]);

      expect(hecho, isTrue);
      final trasMio = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(mio.id)))
          .getSingle();
      expect(trasMio.equipo, 'LAL');
    });

    test('los traspasos entre equipos de la CPU no miran tu fecha límite',
        () async {
      await sembrarFechaLimitePasada();
      final deA =
          await db.into(db.jugadores).insertReturning(_jugador('A', 'BOS'));
      final deB =
          await db.into(db.jugadores).insertReturning(_jugador('B', 'MIA'));

      final hecho = await ejecutarTraspaso(db,
          equipoUsuario: 'BOS',
          equipoRival: 'MIA',
          tuyos: [deA.id],
          suyos: [deB.id],
          respetarFechaLimite: false);

      expect(hecho, isTrue);
    });
  });

  test('los dos tipos de fecha límite son independientes', () async {
    await db.into(db.eventosTemporada).insert(EventosTemporadaCompanion.insert(
          fecha: DateTime(2026, 2, 1),
          tipo: TipoEventoTemporada.fechaLimiteTraspasos.name,
        ));
    await sembrarPartido(DateTime(2026, 3, 1), jugado: true);

    expect(
        await haPasadoFechaLimite(
            db, 'DEN', TipoEventoTemporada.fechaLimiteTraspasos),
        isTrue);
    expect(
        await haPasadoFechaLimite(
            db, 'DEN', TipoEventoTemporada.finAgenciaLibre),
        isFalse,
        reason: 'no hay evento de agencia libre sembrado');
  });
}
