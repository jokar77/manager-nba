import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/lesiones_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
    final plantilla =
        await (db.select(db.jugadores)..where((t) => t.equipo.equals('LAL')))
            .get();
    await guardarRotacion(db, generarRotacionAutomatica(plantilla));
  });

  tearDown(() => db.close());

  Future<int> idTitular() async {
    final filas = await leerRotacion(db);
    return filas.firstWhere((f) => f.esTitular).jugadorId;
  }

  /// El factorForma "sano" de [jugadorId] en [fecha] (solo el estado de
  /// forma de temporada, sorteado al crear la franquicia — no depende de
  /// lesiones). Sirve de referencia porque no es 1.0 para todo el mundo.
  Future<double> formaSana(int jugadorId, DateTime fecha) async {
    final equipo = await construirEquipoUsuarioParaFecha(db, 'LAL', fecha);
    return equipo.jugadores
        .firstWhere((j) => j.jugador.id == jugadorId.toString())
        .factorForma;
  }

  test('una lesión grave deja al titular fuera del todo: juega el '
      'suplente', () async {
    final rotacion = await leerRotacion(db);
    final filaTitular = rotacion.firstWhere((f) => f.esTitular);
    final filaSuplente = rotacion.firstWhere(
        (f) => f.posicion == filaTitular.posicion && !f.esTitular);
    final fecha = DateTime(2027, 1, 15);

    await db.into(db.lesiones).insert(LesionesCompanion.insert(
          jugadorId: filaTitular.jugadorId,
          fechaFin: fecha.add(const Duration(days: 30)),
          gravedad: 'grave',
        ));

    final equipo = await construirEquipoUsuarioParaFecha(db, 'LAL', fecha);
    final idsEnCancha = equipo.jugadores.map((j) => j.jugador.id).toSet();

    expect(idsEnCancha.contains(filaTitular.jugadorId.toString()), isFalse,
        reason: 'el lesionado grave no puede saltar a la cancha');
    expect(idsEnCancha.contains(filaSuplente.jugadorId.toString()), isTrue);
    final suplenteEnPartido = equipo.jugadores
        .firstWhere((j) => j.jugador.id == filaSuplente.jugadorId.toString());
    expect(suplenteEnPartido.minutos, 48,
        reason: 'el suplente cubre los 48 minutos del puesto');
  });

  test('una lesión leve no impide jugar, pero penaliza el rendimiento',
      () async {
    final id = await idTitular();
    final fecha = DateTime(2027, 1, 15);
    // El estado de forma de temporada no es 1.0 para todo el mundo —se
    // sortea al crear la franquicia—, así que se toma como referencia
    // antes de que exista ninguna lesión.
    final sano = await formaSana(id, fecha);

    await db.into(db.lesiones).insert(LesionesCompanion.insert(
          jugadorId: id,
          fechaFin: fecha.add(const Duration(days: 5)),
          gravedad: 'leve',
        ));

    final equipo = await construirEquipoUsuarioParaFecha(db, 'LAL', fecha);
    final enPartido =
        equipo.jugadores.firstWhere((j) => j.jugador.id == id.toString());

    expect(enPartido.minutos, greaterThan(0),
        reason: 'con una lesión leve sigue jugando sus minutos normales');
    expect(enPartido.factorForma, lessThan(sano),
        reason: 'pero rinde peor que si estuviera sano');
    expect(enPartido.factorForma,
        closeTo(sano * factorRendimientoLesionLeve, 0.001));
  });

  test('al recuperarse, el titular vuelve a su puesto automáticamente sin '
      'tener que tocar la alineación', () async {
    final rotacion = await leerRotacion(db);
    final filaTitular = rotacion.firstWhere((f) => f.esTitular);
    final inicioLesion = DateTime(2027, 1, 15);
    final finLesion = inicioLesion.add(const Duration(days: 10));
    final sano = await formaSana(filaTitular.jugadorId, inicioLesion);

    await db.into(db.lesiones).insert(LesionesCompanion.insert(
          jugadorId: filaTitular.jugadorId,
          fechaFin: finLesion,
          gravedad: 'grave',
        ));

    // Durante la lesión, no juega.
    final durante =
        await construirEquipoUsuarioParaFecha(db, 'LAL', inicioLesion);
    expect(
        durante.jugadores
            .map((j) => j.jugador.id)
            .contains(filaTitular.jugadorId.toString()),
        isFalse);

    // Pasada la fecha de vuelta, es titular de nuevo con sus minutos de
    // siempre — no hace falta que el usuario reconfigure nada: la rotación
    // guardada nunca dejó de decir que él era el titular.
    final despues = await construirEquipoUsuarioParaFecha(
        db, 'LAL', finLesion.add(const Duration(days: 1)));
    final deVuelta = despues.jugadores.firstWhere(
        (j) => j.jugador.id == filaTitular.jugadorId.toString());
    expect(deVuelta.minutos, filaTitular.minutos);
    expect(deVuelta.factorForma, sano,
        reason: 'ya no arrastra penalización: la lesión ha terminado');
  });
}
