import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/forma_repository.dart';
import 'package:manager_nba/domain/premios_repository.dart';
import 'package:manager_nba/domain/tipo_premio.dart';

/// Un jugador sintético: así estos tests no dependen del dataset real ni
/// tienen que simular una temporada entera.
JugadoresCompanion _jugador({
  required String nombre,
  required String equipo,
  required int atrDefensa,
  int edad = 27,
  int media = 85,
  double ptsPg = 20,
}) {
  return JugadoresCompanion.insert(
    nombreFicticio: nombre,
    nombreReal: nombre,
    posicion: 'C',
    equipo: equipo,
    edad: edad,
    media: media,
    potencial: media,
    atrTiro3: 60,
    atrAtaque: media,
    atrDefensa: atrDefensa,
    ptsPg: ptsPg,
    astPg: 4,
    trbPg: 10,
    factorLongevidad: 1.0,
    edadRetiro: 38,
  );
}

Future<void> _estadisticas(
  AppDatabase db,
  int jugadorId, {
  int partidos = 82,
  int puntos = 1640,
  int asistencias = 328,
  int rebotes = 820,
}) {
  return db.into(db.estadisticasTemporadaJugador).insert(
        EstadisticasTemporadaJugadorCompanion.insert(
          jugadorId: Value(jugadorId),
          partidosJugados: Value(partidos),
          puntosTotales: Value(puntos),
          asistenciasTotales: Value(asistencias),
          rebotesTotales: Value(rebotes),
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('sortearFormaDeTemporada da a cada jugador un factor dentro de los '
      'límites, con variedad real (no todos 1.0)', () async {
    for (var i = 0; i < 60; i++) {
      await db.into(db.jugadores).insert(
          _jugador(nombre: 'J$i', equipo: 'DEN', atrDefensa: 70));
    }

    await sortearFormaDeTemporada(db, random: Random(7));
    final formas = await leerFormas(db);

    expect(formas.length, 60);
    expect(formas.values.every((f) => f >= formaMinima && f <= formaMaxima),
        isTrue);
    expect(formas.values.where((f) => f > 1.05).length, greaterThan(5),
        reason: 'debería haber jugadores en buen momento de forma');
    expect(formas.values.where((f) => f < 0.95).length, greaterThan(5),
        reason: 'y jugadores en un año flojo');
  });

  test('volver a sortear la forma cambia los factores: por eso los premios '
      'no salen siempre para el mismo jugador', () async {
    for (var i = 0; i < 60; i++) {
      await db.into(db.jugadores).insert(
          _jugador(nombre: 'J$i', equipo: 'DEN', atrDefensa: 70));
    }

    await sortearFormaDeTemporada(db, random: Random(1));
    final primera = await leerFormas(db);
    await sortearFormaDeTemporada(db, random: Random(2));
    final segunda = await leerFormas(db);

    final cambiados =
        primera.keys.where((id) => primera[id] != segunda[id]).length;
    expect(cambiados, greaterThan(50));
  });

  test('el Mejor Defensor ya no es siempre el del atrDefensa más alto: un '
      'año flojo lo puede dejar sin premio', () async {
    // "Muro" tiene la mejor defensa bruta; "Ancla" va justo por detrás.
    final idMuro = await db.into(db.jugadores).insert(
        _jugador(nombre: 'Muro', equipo: 'DEN', atrDefensa: 95));
    final idAncla = await db.into(db.jugadores).insert(
        _jugador(nombre: 'Ancla', equipo: 'DEN', atrDefensa: 88));

    await _estadisticas(db, idMuro);
    await _estadisticas(db, idAncla);
    await db.into(db.resultadoTemporada).insert(
        ResultadoTemporadaCompanion.insert(
            equipo: 'DEN',
            victorias: const Value(50),
            derrotas: const Value(32)));

    Future<int> mejorDefensorCon(double formaMuro, double formaAncla) async {
      await db.delete(db.formaTemporadaJugador).go();
      await db.batch((batch) => batch.insertAll(db.formaTemporadaJugador, [
            FormaTemporadaJugadorCompanion.insert(
                jugadorId: Value(idMuro), factor: Value(formaMuro)),
            FormaTemporadaJugadorCompanion.insert(
                jugadorId: Value(idAncla), factor: Value(formaAncla)),
          ]));
      await calcularPremios(db);
      final premios = await leerPremios(db);
      return premios[TipoPremio.mejorDefensor]!.single.jugadorId;
    }

    // En forma neutra gana el de mejor atrDefensa...
    expect(await mejorDefensorCon(1.0, 1.0), idMuro);
    // ...pero con un año flojo suyo y uno grande del otro, cambia.
    expect(await mejorDefensorCon(formaMinima, formaMaxima), idAncla);
  });

  test('un anotador reboteador con defensa mediocre no puede ganar el '
      'Mejor Defensor por muchos rebotes que coja', () async {
    // Perfil "Doncic": muchos rebotes y asistencias para su puesto, pero
    // defensa floja. Enfrente, un especialista defensivo discreto en ataque.
    final idAnotador = await db.into(db.jugadores).insert(
        _jugador(nombre: 'Anotador', equipo: 'DEN', atrDefensa: 70, ptsPg: 30));
    final idEspecialista = await db.into(db.jugadores).insert(
        _jugador(nombre: 'Especialista', equipo: 'DEN', atrDefensa: 92, ptsPg: 9));

    // El anotador rebotea muchísimo (12 por partido) y su equipo gana más.
    await _estadisticas(db, idAnotador,
        puntos: 2460, asistencias: 738, rebotes: 984);
    await _estadisticas(db, idEspecialista,
        puntos: 738, asistencias: 164, rebotes: 574);
    await db.into(db.resultadoTemporada).insert(
        ResultadoTemporadaCompanion.insert(
            equipo: 'DEN',
            victorias: const Value(60),
            derrotas: const Value(22)));

    // Incluso con el mejor año de forma posible para el anotador y el peor
    // para el especialista, el premio no puede cambiar de manos.
    await db.batch((batch) => batch.insertAll(db.formaTemporadaJugador, [
          FormaTemporadaJugadorCompanion.insert(
              jugadorId: Value(idAnotador), factor: Value(formaMaxima)),
          FormaTemporadaJugadorCompanion.insert(
              jugadorId: Value(idEspecialista), factor: Value(formaMinima)),
        ]));
    await calcularPremios(db);

    final premios = await leerPremios(db);
    expect(premios[TipoPremio.mejorDefensor]!.single.jugadorId, idEspecialista);
  });
}
