import 'dart:math';

// drift también exporta `isNull`/`isNotNull` (los suyos son para construir
// SQL, no para afirmar en un test): se ocultan para que ganen los de matcher.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/entrenadores_importer.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/entrenadores_repository.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/progresion_repository.dart';

Future<AppDatabase> _ligaConEntrenadores(String equipo) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await importarJugadoresSiHaceFalta(db);
  await crearFranquicia(db, equipo);
  await importarEntrenadoresSiHaceFalta(db);
  return db;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el asset trae un entrenador por franquicia y un mercado de libres',
      () async {
    final db = await _ligaConEntrenadores('DEN');

    final todos = await db.select(db.entrenadores).get();
    final conEquipo = todos.where((e) => esFranquicia(e.equipo)).toList();
    final libres = todos.where((e) => e.equipo == equipoAgenciaLibre).toList();

    expect(conEquipo.length, 30, reason: 'las 30 franquicias con banquillo');
    expect(conEquipo.map((e) => e.equipo).toSet().length, 30,
        reason: 'ningún entrenador puede dirigir a dos equipos a la vez');
    expect(libres, isNotEmpty,
        reason: 'sin mercado no habría ninguna decisión que tomar');

    // Y las medias tienen que estar repartidas: si salieran todas parecidas,
    // fichar entrenador daría igual.
    final medias = conEquipo.map(mediaDe).toList()..sort();
    expect(medias.last - medias.first, greaterThanOrEqualTo(20),
        reason: 'del mejor al peor tiene que haber una diferencia real');

    await db.close();
  });

  test('importar es idempotente: llamarlo dos veces no duplica banquillos',
      () async {
    final db = await _ligaConEntrenadores('BOS');
    final antes = (await db.select(db.entrenadores).get()).length;

    await importarEntrenadoresSiHaceFalta(db);

    expect((await db.select(db.entrenadores).get()).length, antes);
    await db.close();
  });

  test('despedir deja el banquillo vacío y al entrenador en el mercado',
      () async {
    final db = await _ligaConEntrenadores('MIA');
    final antes = await leerEntrenadorDe(db, 'MIA');
    expect(antes, isNotNull);

    await despedirEntrenador(db, 'MIA');

    expect(await leerEntrenadorDe(db, 'MIA'), isNull);
    final libres = await leerEntrenadoresLibres(db);
    expect(libres.map((e) => e.id), contains(antes!.id));

    await db.close();
  });

  test('un equipo sin entrenador rinde igual que con uno del montón, no peor',
      () async {
    // La escala del entrenador está centrada en la media de la liga, así
    // que "sin banquillo" tiene que ser neutro. Si no lo fuera, despedir a
    // alguien sería un castigo automático y nadie lo haría nunca.
    final db = await _ligaConEntrenadores('ORL');

    expect(await entrenadorEnPartidoDe(db, 'ORL'), isNotNull);
    await despedirEntrenador(db, 'ORL');
    expect(await entrenadorEnPartidoDe(db, 'ORL'), isNull);

    await db.close();
  });

  // SAC es uno de los cuatro equipos del suelo de la liga (media de sus
  // cinco mejores: 82, contra los 90 de PHI). Se usa tal cual, sin retocar
  // la plantilla, porque lo que interesa probar es que el mercado funciona
  // con los equipos que EXISTEN, no con un caso inventado.
  const equipoDelSuelo = 'SAC';

  test('un entrenador de primera rechaza al peor equipo, y uno modesto no',
      () async {
    final db = await _ligaConEntrenadores(equipoDelSuelo);
    await despedirEntrenador(db, equipoDelSuelo);

    final libres = await leerEntrenadoresLibres(db);
    final mejor = libres.first;
    final peor = libres.last;
    expect(mediaDe(mejor), greaterThan(mediaDe(peor)));

    expect(await aceptariaDirigirA(db, mejor, equipoDelSuelo), isFalse,
        reason: 'el mejor del mercado quiere un proyecto ganador');
    expect(await aceptariaDirigirA(db, peor, equipoDelSuelo), isTrue,
        reason: 'el más modesto firma donde sea: es su oportunidad');

    await db.close();
  });

  test('en el año 1, con la liga a 0-0, el mercado no se bloquea', () async {
    // El bug que esto vigila: al empezar la temporada TODOS los equipos van
    // 0-0, y si eso se cuenta como "una temporada de 0 victorias" la liga
    // entera queda por debajo de lo que pide cualquiera. Resultado: en el
    // año 1 no habría un solo entrenador dispuesto a firmar por nadie.
    final db = await _ligaConEntrenadores('BOS');
    final sinJugar = await recordDeEstaTemporada(db, 'BOS');
    expect(sinJugar.victorias + sinJugar.derrotas, 0);

    final libres = await leerEntrenadoresLibres(db);
    var aceptanAlguno = 0;
    for (final c in libres) {
      if (await aceptariaDirigirA(db, c, 'BOS')) aceptanAlguno++;
    }
    expect(aceptanAlguno, greaterThan(0),
        reason: 'sin partidos jugados no hay nada que juzgar: el récord no '
            'puede penalizar');

    await db.close();
  });

  test('contratar a quien no acepta no cambia nada y dice por qué', () async {
    final db = await _ligaConEntrenadores(equipoDelSuelo);
    await despedirEntrenador(db, equipoDelSuelo);

    final mejor = (await leerEntrenadoresLibres(db)).first;
    final motivo = await contratarEntrenador(db, mejor.id, equipoDelSuelo);

    expect(motivo, MotivoDeRechazo.noLeConvenceElProyecto);
    expect(await leerEntrenadorDe(db, equipoDelSuelo), isNull,
        reason: 'un rechazo no puede dejar a medias el fichaje');

    await db.close();
  });

  test('contratar al que sí acepta ocupa el banquillo y libera al anterior',
      () async {
    final db = await _ligaConEntrenadores('BOS');
    final anterior = await leerEntrenadorDe(db, 'BOS');

    // Alguien del mercado que acepte dirigir a un equipo bueno.
    final libres = await leerEntrenadoresLibres(db);
    Entrenador? candidato;
    for (final c in libres) {
      if (await aceptariaDirigirA(db, c, 'BOS')) {
        candidato = c;
        break;
      }
    }
    expect(candidato, isNotNull,
        reason: 'un equipo campeón tiene que poder fichar a alguien');

    final motivo = await contratarEntrenador(db, candidato!.id, 'BOS');
    expect(motivo, isNull);

    final ahora = await leerEntrenadorDe(db, 'BOS');
    expect(ahora?.id, candidato.id);
    final libresDespues = await leerEntrenadoresLibres(db);
    expect(libresDespues.map((e) => e.id), contains(anterior!.id),
        reason: 'al que estaba se le despide, no se le borra');
    expect(libresDespues.map((e) => e.id), isNot(contains(candidato.id)));

    await db.close();
  });

  test('un formador de jóvenes hace crecer más a un chaval que uno malo',
      () async {
    // Se mide sobre la MISMA semilla y el mismo jugador: lo único que
    // cambia entre las dos pasadas es el entrenador.
    Future<int> mediaTrasUnVerano(int desarrollo) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final id = await db.into(db.jugadores).insert(JugadoresCompanion.insert(
            nombreFicticio: 'Proyecto',
            nombreReal: '',
            posicion: 'SF',
            equipo: 'UTA',
            edad: 20,
            media: 65,
            potencial: 90,
            atrTiro3: 65,
            atrAtaque: 65,
            atrDefensa: 65,
            ptsPg: 8,
            astPg: 2,
            trbPg: 4,
            factorLongevidad: 1.0,
            edadRetiro: 38,
          ));
      await envejecerLiga(db,
          random: Random(7), desarrolloPorEquipo: {'UTA': desarrollo});
      final tras = await (db.select(db.jugadores)..where((t) => t.id.equals(id)))
          .getSingle();
      await db.close();
      return tras.media;
    }

    final conElMejor = await mediaTrasUnVerano(93);
    final neutro = await mediaTrasUnVerano(76);
    final conElPeor = await mediaTrasUnVerano(60);

    expect(conElMejor, greaterThan(neutro),
        reason: 'un formador tiene que notarse');
    expect(neutro, greaterThan(conElPeor));
    // Pero no puede ser la diferencia entre un suplente y una estrella en un
    // solo verano: el entrenador acelera, no fabrica.
    expect(conElMejor - conElPeor, lessThan(6));
  });

  test('el desarrollo no sube a nadie por encima de su potencial', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final id = await db.into(db.jugadores).insert(JugadoresCompanion.insert(
          nombreFicticio: 'Casi Hecho',
          nombreReal: '',
          posicion: 'PG',
          equipo: 'OKC',
          edad: 21,
          media: 79,
          potencial: 80,
          atrTiro3: 79,
          atrAtaque: 79,
          atrDefensa: 79,
          ptsPg: 14,
          astPg: 5,
          trbPg: 3,
          factorLongevidad: 1.0,
          edadRetiro: 38,
        ));

    await envejecerLiga(db,
        random: Random(3), desarrolloPorEquipo: {'OKC': 99});

    final tras =
        await (db.select(db.jugadores)..where((t) => t.id.equals(id))).getSingle();
    expect(tras.media, lessThanOrEqualTo(80));

    await db.close();
  });

  test('el verano mueve banquillos: envejecen, se retiran y llegan relevos',
      () async {
    final db = await _ligaConEntrenadores('DEN');

    // Media liga hunde su récord, para que haya despidos que observar.
    final equipos = (await db.select(db.resultadoTemporada).get())
        .map((r) => r.equipo)
        .where(esFranquicia)
        .toList()
      ..sort();
    for (final equipo in equipos.take(15)) {
      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals(equipo)))
          .write(const ResultadoTemporadaCompanion(
              victorias: Value(15), derrotas: Value(67)));
    }

    final edadesAntes = {
      for (final e in await db.select(db.entrenadores).get()) e.id: e.edad,
    };

    final movimientos = await pasarElVeranoDeLosEntrenadores(db,
        equipoUsuario: 'DEN', random: Random(11));

    final despues = await db.select(db.entrenadores).get();
    for (final e in despues) {
      if (e.equipo == equipoRetirados) continue;
      expect(e.edad, edadesAntes[e.id]! + 1, reason: 'cumplen años todos');
    }

    expect(movimientos, isNotEmpty,
        reason: 'con media liga a 15-67 tiene que moverse algún banquillo');

    // Y ningún equipo puede quedarse con dos entrenadores.
    final porEquipo = <String, int>{};
    for (final e in despues.where((e) => esFranquicia(e.equipo))) {
      porEquipo[e.equipo] = (porEquipo[e.equipo] ?? 0) + 1;
    }
    expect(porEquipo.values.every((n) => n == 1), isTrue,
        reason: 'un equipo, un entrenador');

    await db.close();
  });

  test('el verano NO te toca el banquillo: a ti no te despide nadie',
      () async {
    final db = await _ligaConEntrenadores('DEN');
    final tuyoAntes = await leerEntrenadorDe(db, 'DEN');

    // Peor récord posible, que a un equipo de la CPU le costaría el puesto.
    await (db.update(db.resultadoTemporada)..where((t) => t.equipo.equals('DEN')))
        .write(const ResultadoTemporadaCompanion(
            victorias: Value(5), derrotas: Value(77)));

    await pasarElVeranoDeLosEntrenadores(db,
        equipoUsuario: 'DEN', random: Random(2));

    final tuyoDespues = await leerEntrenadorDe(db, 'DEN');
    expect(tuyoDespues?.id, tuyoAntes!.id,
        reason: 'echar al entrenador es decisión tuya, no de la liga');

    await db.close();
  });

  test('el récord de la temporada pasa a la carrera del entrenador una vez',
      () async {
    final db = await _ligaConEntrenadores('DEN');
    final antes = await leerEntrenadorDe(db, 'DEN');
    expect(antes!.victorias, 0);

    await (db.update(db.resultadoTemporada)..where((t) => t.equipo.equals('DEN')))
        .write(const ResultadoTemporadaCompanion(
            victorias: Value(58), derrotas: Value(24)));

    // Durante el año, el récord del entrenador se lee del de su equipo.
    final enCurso = await recordDeEstaTemporada(db, 'DEN');
    expect(enCurso.victorias, 58);
    expect(antes.victorias, 0, reason: 'no se guarda partido a partido');

    await pasarElVeranoDeLosEntrenadores(db,
        equipoUsuario: 'DEN', random: Random(4));

    final despues = await leerEntrenadorDe(db, 'DEN');
    expect(despues?.victorias, 58);
    expect(despues?.derrotas, 24);
    expect(despues?.temporadas, antes.temporadas + 1);

    await db.close();
  });

  test('una partida vieja sin entrenadores se rellena sin dejar huecos',
      () async {
    // El caso de quien ya tiene una carrera empezada: la tabla llega vacía
    // y hay que cubrir los 30 banquillos sin preguntar por el proyecto.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'NYK');
    await importarEntrenadoresSiHaceFalta(db);

    // Se simula el hueco: todos a la calle.
    await db.update(db.entrenadores).write(
        const EntrenadoresCompanion(equipo: Value(equipoAgenciaLibre)));
    expect(await leerEntrenadorDe(db, 'NYK'), isNull);

    await asignarEntrenadoresQueFalten(db);

    final equipos = (await db.select(db.resultadoTemporada).get())
        .map((r) => r.equipo)
        .where(esFranquicia);
    for (final equipo in equipos) {
      expect(await leerEntrenadorDe(db, equipo), isNotNull,
          reason: '$equipo se ha quedado sin banquillo');
    }

    await db.close();
  });
}
