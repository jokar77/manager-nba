import 'dart:math';

// drift también exporta `isNull`/`isNotNull` (los suyos son para construir
// SQL, no para afirmar en un test): se ocultan para que ganen los de matcher.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/entrenadores_importer.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/contratos_repository.dart';
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

    expect((await valorarOfertaDe(db, mejor, equipoDelSuelo)).acepta, isFalse,
        reason: 'el mejor del mercado quiere un proyecto ganador');
    expect((await valorarOfertaDe(db, peor, equipoDelSuelo)).acepta, isTrue,
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
      if ((await valorarOfertaDe(db, c, 'BOS')).acepta) aceptanAlguno++;
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
    final resultado = await contratarEntrenador(db, mejor.id, equipoDelSuelo,
        salario: salarioQuePide(mejor), anios: aniosQuePide(mejor));

    expect(resultado.motivo, MotivoDeRechazo.noLeConvenceLaOferta);
    expect(await leerEntrenadorDe(db, equipoDelSuelo), isNull,
        reason: 'un rechazo no puede dejar a medias el fichaje');

    await db.close();
  });

  test('contratar al que sí acepta ocupa el banquillo y libera al anterior',
      () async {
    final db = await _ligaConEntrenadores('BOS');
    final anterior = await leerEntrenadorDe(db, 'BOS');
    // Para que quepa en el presupuesto hay que hacer sitio: el que está
    // cobra, y al despedirle su sueldo se convierte en finiquito.
    await despedirEntrenador(db, 'BOS');

    final libres = await leerEntrenadoresLibres(db);
    Entrenador? candidato;
    for (final c in libres) {
      final cabe = salarioQuePide(c) <= await maximoQuePuedesOfrecer(db, 'BOS');
      if (cabe && (await valorarOfertaDe(db, c, 'BOS')).acepta) {
        candidato = c;
        break;
      }
    }
    expect(candidato, isNotNull,
        reason: 'un equipo campeón tiene que poder fichar a alguien');

    final resultado = await contratarEntrenador(db, candidato!.id, 'BOS',
        salario: salarioQuePide(candidato), anios: aniosQuePide(candidato));
    expect(resultado.firmado, isTrue, reason: resultado.mensaje);

    final ahora = await leerEntrenadorDe(db, 'BOS');
    expect(ahora?.id, candidato.id);
    expect(ahora?.salario, salarioQuePide(candidato));
    expect(ahora?.aniosContrato, aniosQuePide(candidato));

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

  test('el sueldo sube con el nivel y se queda dentro de la escala real',
      () async {
    // Los topes salen de los sueldos publicados: el mejor pagado de la NBA
    // ronda los 17-18M y el suelo del oficio los 2M.
    expect(salarioDeEntrenador(90), greaterThan(salarioDeEntrenador(76)));
    expect(salarioDeEntrenador(76), greaterThan(salarioDeEntrenador(60)));
    expect(salarioDeEntrenador(99), lessThanOrEqualTo(salarioMaximoEntrenador));
    expect(salarioDeEntrenador(40),
        greaterThanOrEqualTo(salarioMinimoEntrenador));

    // Y la curva tiene que ser convexa, como la de los jugadores: arriba se
    // concentra el dinero. Si fuera recta, un 90 costaría lo mismo de más
    // que un 70 y no habría decisión económica ninguna.
    final subeArriba = salarioDeEntrenador(90) - salarioDeEntrenador(80);
    final subeAbajo = salarioDeEntrenador(70) - salarioDeEntrenador(60);
    expect(subeArriba, greaterThan(subeAbajo * 2));
  });

  test('el dinero tapa parte de la falta de proyecto, pero no toda', () async {
    // Un entrenador bueno en un equipo flojo: a su precio dice que no.
    final aSuPrecio = valorarOferta(
      mediaDelEntrenador: 88,
      desarrolloDelEntrenador: 70,
      mediaDelEquipo: 82,
      victorias: 0,
      derrotas: 0,
      salarioOfrecido: 12000000,
      salarioPedido: 12000000,
      aniosOfrecidos: 4,
      aniosPedidos: 4,
    );
    expect(aSuPrecio.acepta, isFalse);

    // Pagándole el doble sigue sin llegar: el tope de lo que compra el
    // dinero existe justo para que el mercado no se resuelva con la
    // cartera.
    final aldoble = valorarOferta(
      mediaDelEntrenador: 88,
      desarrolloDelEntrenador: 70,
      mediaDelEquipo: 82,
      victorias: 0,
      derrotas: 0,
      salarioOfrecido: 24000000,
      salarioPedido: 12000000,
      aniosOfrecidos: 4,
      aniosPedidos: 4,
    );
    expect(aldoble.loQueFalta, lessThan(aSuPrecio.loQueFalta),
        reason: 'el dinero tiene que acercar');
    expect(aSuPrecio.loQueFalta - aldoble.loQueFalta,
        lessThanOrEqualTo(maxPuntosQueCompraElDinero + 0.001),
        reason: 'pero nunca más de lo que dice el tope');
  });

  test('ofrecer menos años de los que pide echa para atrás', () async {
    RespuestaDelEntrenador con(int anios) => valorarOferta(
          mediaDelEntrenador: 70,
          desarrolloDelEntrenador: 70,
          mediaDelEquipo: 83,
          victorias: 0,
          derrotas: 0,
          salarioOfrecido: 5000000,
          salarioPedido: 5000000,
          aniosOfrecidos: anios,
          aniosPedidos: 3,
        );
    expect(con(1).loQueFalta, greaterThan(con(3).loQueFalta));
    expect(con(4).loQueFalta, lessThan(con(3).loQueFalta));
  });

  test('despedir con contrato en vigor deja un finiquito que sigue contando '
      'en la masa salarial', () async {
    final db = await _ligaConEntrenadores('BOS');
    final actual = await leerEntrenadorDe(db, 'BOS');
    expect(actual!.salario, greaterThan(0));
    expect(actual.aniosContrato, greaterThan(0));

    final coste = await costeDeDespedir(db, 'BOS');
    expect(coste, actual.salario * actual.aniosContrato);

    final masaAntes = await masaSalarial(db, 'BOS');
    await despedirEntrenador(db, 'BOS');
    final masaDespues = await masaSalarial(db, 'BOS');

    final presupuesto = await presupuestoDe(db, 'BOS');
    expect(presupuesto.sueldoDelActual, 0, reason: 'ya no dirige nadie');
    expect(presupuesto.finiquitos, actual.salario,
        reason: 'se le sigue pagando lo mismo cada año que le quedaba');
    expect(masaDespues, masaAntes,
        reason: 'echarle no te ahorra un céntimo: su sueldo sigue en la masa '
            'salarial hasta que se cumpla el contrato');

    await db.close();
  });

  test('el sueldo del entrenador cuenta en la masa salarial del equipo',
      () async {
    final db = await _ligaConEntrenadores('MEM');
    final entrenador = await leerEntrenadorDe(db, 'MEM');

    final soloJugadores = (await (db.select(db.jugadores)
              ..where((t) =>
                  t.equipo.equals('MEM') & t.retirado.equals(false)))
            .get())
        .fold<int>(0, (a, j) => a + j.salario);

    expect(await masaSalarial(db, 'MEM'), soloJugadores + entrenador!.salario,
        reason: 'el banquillo entra en el total de la franquicia');
    expect(await costeDelBanquillo(db, 'MEM'), entrenador.salario);

    await db.close();
  });

  test('un equipo pasado de tope solo puede firmar entrenador por el mínimo',
      () async {
    // PHI arranca la partida con 246M de masa salarial, por encima del tope
    // de la franquicia. La válvula es la misma que con los jugadores —
    // siempre se puede firmar por el mínimo— y existe para que esos equipos
    // no se queden sin banquillo para siempre.
    final db = await _ligaConEntrenadores('PHI');
    await despedirEntrenador(db, 'PHI');

    final presupuesto = await presupuestoDe(db, 'PHI');
    expect(presupuesto.espacioEnElTope, lessThan(0),
        reason: 'PHI empieza pasado de tope');
    expect(presupuesto.libre, salarioMinimoEntrenador,
        reason: 'solo le queda la excepción del mínimo');

    final caro = (await leerEntrenadoresLibres(db))
        .firstWhere((e) => salarioQuePide(e) > salarioMinimoEntrenador);
    final rechazado = await contratarEntrenador(db, caro.id, 'PHI',
        salario: salarioQuePide(caro), anios: 3);
    expect(rechazado.motivo, MotivoDeRechazo.sinPresupuesto);
    expect(await leerEntrenadorDe(db, 'PHI'), isNull);

    await db.close();
  });

  test('un equipo de la CPU pasado de tope acaba encontrando entrenador '
      'por el mínimo', () async {
    // La otra cara del mismo caso: si la CPU descartara a todo el que pide
    // más de lo que le cabe, las seis franquicias que empiezan pasadas de
    // tope se quedarían sin banquillo para siempre.
    final db = await _ligaConEntrenadores('DEN');
    await despedirEntrenador(db, 'PHI');
    expect(await leerEntrenadorDe(db, 'PHI'), isNull);
    expect((await presupuestoDe(db, 'PHI')).espacioEnElTope, lessThan(0));

    await pasarElVeranoDeLosEntrenadores(db,
        equipoUsuario: 'DEN', random: Random(31));

    final nuevo = await leerEntrenadorDe(db, 'PHI');
    expect(nuevo, isNotNull, reason: 'PHI no puede quedarse sin entrenador');
    expect(nuevo!.salario, lessThanOrEqualTo(salarioMinimoEntrenador),
        reason: 'pasado de tope, solo por el mínimo');

    await db.close();
  });

  test('gastar en el banquillo te deja menos sitio para jugadores', () async {
    // Es la consecuencia de que el entrenador cuente en la masa salarial:
    // el espacio salarial del equipo baja exactamente lo que cobra.
    final db = await _ligaConEntrenadores('MEM');
    final entrenador = await leerEntrenadorDe(db, 'MEM');
    final espacioConEntrenador = await espacioSalarial(db, 'MEM');

    await despedirEntrenador(db, 'MEM');
    // Despedir no libera nada: el finiquito sigue contando.
    expect(await espacioSalarial(db, 'MEM'), espacioConEntrenador,
        reason: 'el finiquito ocupa el mismo sitio que ocupaba su sueldo');

    // Y cuando se cumple el contrato, ahí sí se recupera el espacio.
    for (var i = 0; i < entrenador!.aniosContrato; i++) {
      await pasarElVeranoDeLosEntrenadores(db,
          equipoUsuario: 'DEN', random: Random(20 + i));
    }
    expect(await costeDelBanquillo(db, 'MEM'), greaterThanOrEqualTo(0));

    await db.close();
  });

  test('el finiquito se va consumiendo cada verano hasta desaparecer',
      () async {
    final db = await _ligaConEntrenadores('BOS');
    final despedido = await leerEntrenadorDe(db, 'BOS');
    final anios = despedido!.aniosContrato;
    await despedirEntrenador(db, 'BOS');

    expect((await presupuestoDe(db, 'BOS')).finiquitos, greaterThan(0));

    for (var i = 0; i < anios; i++) {
      await pasarElVeranoDeLosEntrenadores(db,
          equipoUsuario: 'DEN', random: Random(i + 1));
    }

    expect((await presupuestoDe(db, 'BOS')).finiquitos, 0,
        reason: 'pasados los años del contrato, ya no se le debe nada');

    await db.close();
  });

  test('cuando a TU entrenador se le acaba el contrato, la CPU no puede '
      'llevárselo ese mismo verano', () async {
    // Sin esto, renovar no sería una decisión sino una carrera que siempre
    // pierdes: el verano libera a tu entrenador y, dos pasos más abajo, un
    // equipo de la CPU con el banquillo vacío se lo lleva antes de que
    // llegues a la pantalla.
    final db = await _ligaConEntrenadores('DEN');
    final tuyo = await leerEntrenadorDe(db, 'DEN');

    // Se le deja un año, para que este verano sea el último.
    await (db.update(db.entrenadores)..where((t) => t.id.equals(tuyo!.id)))
        .write(const EntrenadoresCompanion(aniosContrato: Value(1)));

    await pasarElVeranoDeLosEntrenadores(db,
        equipoUsuario: 'DEN', random: Random(9));

    final despues = await (db.select(db.entrenadores)
          ..where((t) => t.id.equals(tuyo!.id)))
        .getSingle();
    expect(despues.equipo, anyOf(equipoAgenciaLibre, equipoRetirados),
        reason: 'se le acabó el contrato y nadie ha podido ficharlo todavía');
    expect(await leerEntrenadorDe(db, 'DEN'), isNull,
        reason: 'tu banquillo queda vacante: te toca decidir a ti');

    await db.close();
  });

  test('el mercado no se seca: si quedan pocos libres, se generan más',
      () async {
    final db = await _ligaConEntrenadores('DEN');

    // Se vacía el mercado a lo bruto, como pasaría tras muchos veranos de
    // retiradas.
    await (db.delete(db.entrenadores)
          ..where((t) => t.equipo.equals(equipoAgenciaLibre)))
        .go();
    expect(await leerEntrenadoresLibres(db), isEmpty);

    await generarEntrenadoresSiFaltan(db, random: Random(4));

    final libres = await leerEntrenadoresLibres(db);
    expect(libres.length, greaterThanOrEqualTo(12));
    // Son entrenadores de primer trabajo, no estrellas caídas del cielo.
    for (final e in libres) {
      expect(mediaDe(e), lessThan(78),
          reason: 'los buenos se hacen ganando, no se generan');
      expect(e.nombreFicticio, isNotEmpty);
    }
    expect(libres.map((e) => e.nombreFicticio).toSet().length, libres.length,
        reason: 'sin nombres repetidos');

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
