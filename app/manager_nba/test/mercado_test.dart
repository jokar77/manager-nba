import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/agencia_libre_repository.dart';
import 'package:manager_nba/domain/contratos_repository.dart';
import 'package:manager_nba/domain/draft_repository.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/salarios.dart';
import 'package:manager_nba/domain/traspasos_repository.dart';

/// Un generador que siempre devuelve el mismo número, para forzar que una
/// negociación salga a favor o en contra sin depender de la suerte.
class _RandomFijo implements Random {
  _RandomFijo(this.valor);
  final double valor;

  @override
  double nextDouble() => valor;
  @override
  bool nextBool() => valor < 0.5;
  @override
  int nextInt(int max) => (valor * max).floor().clamp(0, max - 1);
}

/// Un jugador de laboratorio con sueldo bajo, para montar traspasos donde
/// el tope salarial no sea lo que decide.
JugadoresCompanion _ficha({
  required String nombre,
  required String equipo,
  required int media,
  required int edad,
}) {
  return JugadoresCompanion.insert(
    nombreFicticio: nombre,
    nombreReal: nombre,
    posicion: 'SF',
    posicionSecundaria: const Value('PF'),
    equipo: equipo,
    edad: edad,
    media: media,
    potencial: media,
    atrTiro3: media,
    atrAtaque: media,
    atrDefensa: media,
    ptsPg: 15,
    astPg: 3,
    trbPg: 5,
    factorLongevidad: 1.0,
    edadRetiro: 38,
    salario: const Value(5000000),
    aniosContrato: const Value(2),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
  });

  tearDown(() async {
    await db.close();
  });

  Future<Jugador> unJugadorDe(String equipo) async {
    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals(equipo))
          ..orderBy([(t) => OrderingTerm.desc(t.media)]))
        .get();
    return plantilla.first;
  }

  group('contratos', () {
    test('descontarAnioDeContrato baja un año a todos y saca a la luz los '
        'que vencen', () async {
      final antes = await db.select(db.jugadores).get();
      final conUnAno =
          antes.where((j) => j.aniosContrato == 1).map((j) => j.id).toSet();
      expect(conUnAno, isNotEmpty);

      await descontarAnioDeContrato(db);

      final vencen = await contratosQueVencen(db, 'LAL');
      final idsVencen = vencen.map((j) => j.id).toSet();
      expect(idsVencen, isNotEmpty);
      expect(idsVencen.every(conUnAno.contains), isTrue,
          reason: 'solo vencen los que estaban a un año');
    });

    test('el tope salarial deja fichar por el mínimo aunque estés pasado, '
        'pero no contratos grandes', () async {
      // Se infla la masa salarial de LAL por encima del tope.
      await (db.update(db.jugadores)..where((t) => t.equipo.equals('LAL')))
          .write(const JugadoresCompanion(salario: Value(20000000)));

      expect(await espacioSalarial(db, 'LAL'), lessThan(0));
      expect(await puedeAsumir(db, 'LAL', salarioMinimo), isTrue);
      expect(await puedeAsumir(db, 'LAL', 15000000), isFalse);
    });
  });

  group('renovaciones', () {
    test('una oferta generosa se acepta y actualiza el contrato', () async {
      await descontarAnioDeContrato(db);
      final vencen = await contratosQueVencen(db, 'LAL');
      final jugador = vencen.first;
      final pedido = valorDeMercado(jugador);

      final respuesta = await ofrecerRenovacion(db, jugador.id,
          salario: (pedido * 1.2).round(),
          anios: aniosContratoEstimados(edad: jugador.edad),
          random: _RandomFijo(0.01));

      expect(respuesta.aceptada, isTrue);
      final actualizado = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(jugador.id)))
          .getSingle();
      expect(actualizado.salario, (pedido * 1.2).round());
      expect(actualizado.aniosContrato, greaterThan(0));
      expect(actualizado.ofertasRechazadas, 0);
    });

    test('una oferta ridícula ofende: cuenta doble y agota la negociación '
        'antes', () async {
      await descontarAnioDeContrato(db);
      final jugador = (await contratosQueVencen(db, 'LAL')).first;

      final primera = await ofrecerRenovacion(db, jugador.id,
          salario: salarioMinimo,
          anios: 2,
          random: _RandomFijo(0.99));
      expect(primera.aceptada, isFalse);
      expect(primera.ofertasRechazadas, 2,
          reason: 'una oferta insultante penaliza el doble');
      expect(primera.mensaje, contains('insulto'));

      // Tras la segunda negativa se acabó la negociación.
      final segunda = await ofrecerRenovacion(db, jugador.id,
          salario: salarioMinimo, anios: 2, random: _RandomFijo(0.99));
      expect(segunda.quedanOfertas, isFalse);

      final tercera = await ofrecerRenovacion(db, jugador.id,
          salario: valorDeMercado(jugador) * 3,
          anios: 2,
          random: _RandomFijo(0.0));
      expect(tercera.aceptada, isFalse,
          reason: 'ya no negocia ni con una millonada');
    });

    test('no se puede ofrecer lo que no cabe bajo el tope', () async {
      await descontarAnioDeContrato(db);
      final jugador = (await contratosQueVencen(db, 'LAL')).first;
      await (db.update(db.jugadores)..where((t) => t.equipo.equals('LAL')))
          .write(const JugadoresCompanion(salario: Value(20000000)));

      final respuesta = await ofrecerRenovacion(db, jugador.id,
          salario: 40000000, anios: 3, random: _RandomFijo(0.0));

      expect(respuesta.aceptada, isFalse);
      expect(respuesta.mensaje, contains('espacio salarial'));
      expect(respuesta.ofertasRechazadas, 0,
          reason: 'una oferta que no puedes hacer no cuenta como rechazo');
    });

    test('la CPU resuelve sus vencimientos sola: renueva o suelta, pero no '
        'deja a nadie en el limbo', () async {
      await descontarAnioDeContrato(db);
      await resolverVencimientosDeLaCpu(db,
          equipoUsuario: 'LAL', random: Random(3));

      final enLimbo = await (db.select(db.jugadores)
            ..where((t) =>
                t.retirado.equals(false) &
                t.aniosContrato.isSmallerOrEqualValue(0) &
                t.equipo.equals('LAL').not() &
                t.equipo.equals(equipoAgenciaLibre).not()))
          .get();
      expect(enLimbo, isEmpty);

      // Y a los tuyos no les ha tocado nadie.
      expect(await contratosQueVencen(db, 'LAL'), isNotEmpty);
    });

    test('renovar no es automático: decide el jugador con la misma lógica que '
        'cuando negocias tú, más el proyecto deportivo', () {
      // Sin esto la CPU retenía a todo el que podía pagar y las agencias
      // libres eran un desierto. Ojo: no hay cuota de estrellas ni nada
      // que empuje a nadie fuera — manda la oferta y lo bien que va el
      // equipo.
      const pedido = 20000000;
      const edad = 28;
      const anios = 3;

      // Mismo contrato, distinto equipo: en el que gana se firma más.
      final enEquipoBueno = probabilidadDeRenovarConLaCpu(
          salario: pedido, pedido: pedido, anios: anios, edad: edad,
          winPct: 60 / 82);
      final enEquipoMalo = probabilidadDeRenovarConLaCpu(
          salario: pedido, pedido: pedido, anios: anios, edad: edad,
          winPct: 15 / 82);
      expect(enEquipoBueno, greaterThan(enEquipoMalo));

      // Mismo equipo, distinto contrato: pagar más convence.
      final buenaOferta = probabilidadDeRenovarConLaCpu(
          salario: (pedido * 1.2).round(), pedido: pedido, anios: anios,
          edad: edad, winPct: 0.5);
      final ofertaTacana = probabilidadDeRenovarConLaCpu(
          salario: (pedido * 0.8).round(), pedido: pedido, anios: anios,
          edad: edad, winPct: 0.5);
      expect(buenaOferta, greaterThan(ofertaTacana));

      // Nunca es seguro del todo, ni imposible del todo.
      expect(
          probabilidadDeRenovarConLaCpu(
              salario: pedido * 3, pedido: pedido, anios: anios, edad: edad,
              winPct: 1.0),
          lessThanOrEqualTo(0.95));
      expect(
          probabilidadDeRenovarConLaCpu(
              salario: 1, pedido: pedido, anios: anios, edad: edad,
              winPct: 0.0),
          greaterThanOrEqualTo(0.05));
    });

    test('si el equipo no cabe bajo el tope, el jugador se va aunque sea una '
        'estrella: no hay renovación posible', () async {
      // El caso que pidió el usuario: "a lo mejor el equipo donde está no
      // tiene masa salarial y tiene que irse sí o sí".
      final delBoston = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('BOS'))
            ..orderBy([(t) => OrderingTerm.desc(t.media)]))
          .get();
      final estrella = delBoston.first;
      // Se deja al equipo pegado al tope con el resto de sueldos, de modo
      // que renovarle a él no quepa de ninguna manera.
      await (db.update(db.jugadores)
            ..where((t) =>
                t.equipo.equals('BOS') & t.id.equals(estrella.id).not()))
          .write(const JugadoresCompanion(salario: Value(12000000)));
      await (db.update(db.jugadores)..where((t) => t.id.equals(estrella.id)))
          .write(const JugadoresCompanion(
              salario: Value(1000000), aniosContrato: Value(1)));

      await descontarAnioDeContrato(db);
      await resolverVencimientosDeLaCpu(db,
          equipoUsuario: 'LAL', random: Random(5));

      final tras = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(estrella.id)))
          .getSingle();
      expect(tras.equipo, equipoAgenciaLibre,
          reason: 'no había sitio bajo el tope para su renovación');
    });

    test('con la aleatoriedad puesta, alguien a quien el equipo SÍ podía '
        'pagar acaba en la agencia libre', () async {
      // Equipos con sitio de sobra bajo el tope: sin la tirada de
      // probabilidadDeNoRenovar no se soltaría a nadie por dinero.
      await (db.update(db.jugadores)
            ..where((t) => t.equipo.equals('LAL').not()))
          .write(const JugadoresCompanion(salario: Value(1000000)));
      final libresAntes = (await agentesLibres(db)).length;

      await descontarAnioDeContrato(db);
      await resolverVencimientosDeLaCpu(db,
          equipoUsuario: 'LAL', random: Random(3));

      expect((await agentesLibres(db)).length, greaterThan(libresAntes),
          reason: 'alguno ha decidido no renovar aunque le pagaran');
    });
  });

  group('tu ventana de mercado', () {
    /// Cierra una temporada entera y devuelve la foto del mercado en el
    /// momento exacto en el que se te abre la pantalla de agencia libre.
    Future<({List<Jugador> sinRenovar, List<Jugador> enElMercado})>
        veranoHastaTuVentana(Random rng) async {
      final cierre = await cerrarTemporada(db, random: rng);
      final sinRenovar = await contratosQueVencen(db, 'LAL');
      final rookies = await avanzarDraftHastaElTurnoDe(db, null);
      await finalizarPretemporada(db, cierre, rookies, random: rng);
      return (
        sinRenovar: sinRenovar,
        enElMercado: await agentesLibres(db),
      );
    }

    test('al que no renuevas te lo encuentras en la agencia libre, no '
        'fichado por otro equipo', () async {
      final verano = await veranoHastaTuVentana(Random(7));
      expect(verano.sinRenovar, isNotEmpty);

      final enElMercado = verano.enElMercado.map((j) => j.id).toSet();
      final porId = {
        for (final j in await db.select(db.jugadores).get()) j.id: j,
      };
      for (final jugador in verano.sinRenovar) {
        final ahora = porId[jugador.id]!;
        // Retirarse por edad sí es una salida legítima; fichar por otro
        // equipo antes de que llegues tú, no.
        if (ahora.retirado) continue;
        expect(enElMercado, contains(jugador.id),
            reason: '${jugador.nombreFicticio} (media ${jugador.media}) '
                'acabó en ${ahora.equipo} sin que te diera tiempo a verlo');
      }
    });

    test('el mercado que ves tiene jugadores de nivel, no solo relleno',
        () async {
      final verano = await veranoHastaTuVentana(Random(7));
      final buenos =
          verano.enElMercado.where((j) => j.media >= 76).toList();
      expect(buenos, isNotEmpty,
          reason: 'antes la CPU barría el mercado antes de tu turno y el '
              'mejor agente libre que llegabas a ver era un 75');
    });

    test('al cerrar tu ventana la CPU sale a por lo que no has fichado: '
        'nadie de nivel se queda sin equipo', () async {
      final cierre = await cerrarTemporada(db, random: Random(7));
      final rookies = await avanzarDraftHastaElTurnoDe(db, null);
      await finalizarPretemporada(db, cierre, rookies, random: Random(7));
      expect((await agentesLibres(db)).where((j) => j.media >= 76), isNotEmpty);

      await cerrarVentanaDeAgenciaLibre(db,
          equipoUsuario: 'LAL',
          temporadaCerrada: cierre.temporadaCerrada,
          claseDelDraft: cierre.anioDraft,
          random: Random(7));

      expect((await agentesLibres(db)).where((j) => j.media >= 76), isEmpty,
          reason: 'un jugador de ese nivel no se pasa el año en su casa');
    });
  });

  group('agencia libre', () {
    test('fichar respeta el tope, y por el mínimo siempre se puede',
        () async {
      await (db.update(db.jugadores)..where((t) => t.equipo.equals('LAL')))
          .write(const JugadoresCompanion(salario: Value(20000000)));

      final libres = await agentesLibres(db);
      expect(libres, isNotEmpty);
      final caro = libres.first;

      expect(
          await ficharAgenteLibre(db,
              jugadorId: caro.id, equipo: 'LAL', salario: 30000000),
          isNull,
          reason: 'no cabe bajo el tope');

      final firmado = await ficharAgenteLibre(db,
          jugadorId: caro.id, equipo: 'LAL', salario: salarioMinimo);
      expect(firmado, salarioMinimo);

      final actualizado = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(caro.id)))
          .getSingle();
      expect(actualizado.equipo, 'LAL');
      expect(actualizado.dorsal, isNotNull,
          reason: 'se le da un dorsal libre nada más firmar');
    });

    test('ofrecerContratoFichaje negocia igual que una renovación: una '
        'oferta generosa firma, una ridícula ofende y agota la '
        'negociación', () async {
      // Se despeja hueco bajo el tope: fichar es dinero nuevo, no libera
      // nada como una renovación, así que hace falta margen de verdad.
      final plantillaLal = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('LAL')))
          .get();
      await mandarAAgenciaLibre(
          db, plantillaLal.skip(5).map((j) => j.id).toList());

      final libre = (await agentesLibres(db)).first;

      final ridicula = await ofrecerContratoFichaje(
        db,
        libre.id,
        equipo: 'LAL',
        salario: salarioMinimo,
        anios: 2,
        random: _RandomFijo(0.99),
      );
      expect(ridicula.aceptada, isFalse);
      expect(ridicula.ofertasRechazadas, 2,
          reason: 'una oferta insultante penaliza el doble');

      final generosa = await ofrecerContratoFichaje(
        db,
        libre.id,
        equipo: 'LAL',
        salario: (precioDeAgenteLibre(libre) * 1.3).round(),
        anios: aniosContratoEstimados(edad: libre.edad),
        random: _RandomFijo(0.01),
      );
      expect(generosa.aceptada, isTrue, reason: generosa.mensaje);

      final actualizado = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(libre.id)))
          .getSingle();
      expect(actualizado.equipo, 'LAL');
      expect(actualizado.ofertasRechazadas, 0);
    });

    test('ofrecerContratoFichaje no deja fichar a alguien que ya no está '
        'libre, ni saltarse el tope', () async {
      final mio = await unJugadorDe('LAL');
      final respuestaNoLibre = await ofrecerContratoFichaje(
        db,
        mio.id,
        equipo: 'BOS',
        salario: mio.salario,
        anios: 2,
        random: _RandomFijo(0.0),
      );
      expect(respuestaNoLibre.aceptada, isFalse);
      expect(respuestaNoLibre.mensaje, contains('ya no está libre'));

      await (db.update(db.jugadores)..where((t) => t.equipo.equals('LAL')))
          .write(const JugadoresCompanion(salario: Value(20000000)));
      final libre = (await agentesLibres(db)).first;
      final respuestaSinTope = await ofrecerContratoFichaje(
        db,
        libre.id,
        equipo: 'LAL',
        salario: 15000000,
        anios: 2,
        random: _RandomFijo(0.0),
      );
      expect(respuestaSinTope.aceptada, isFalse);
      expect(respuestaSinTope.mensaje, contains('espacio salarial'));
    });

    test('completarPlantillaConElMinimo deja el equipo listo para jugar '
        'aunque lo vacíes casi entero', () async {
      final plantilla = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('LAL'))
            ..orderBy([(t) => OrderingTerm.desc(t.media)]))
          .get();
      // Se deja al equipo con solo 3 jugadores.
      await mandarAAgenciaLibre(
          db, plantilla.skip(3).map((j) => j.id).toList());

      final antes = await huecosDePlantilla(db, 'LAL');
      expect(antes.plantillaLista, isFalse);

      await completarPlantillaConElMinimo(db, 'LAL', random: Random(5));

      final despues = await huecosDePlantilla(db, 'LAL');
      expect(despues.plantillaLista, isTrue,
          reason: 'faltan ${despues.fichajesQueFaltan} fichajes y los '
              'puestos ${despues.puestosSinCubrir}');
      expect(await tamanoDePlantilla(db, 'LAL'),
          greaterThanOrEqualTo(plantillaMinima));
    });
  });

  group('traspasos', () {
    test('un cambio desequilibrado a tu favor lo rechazan; el mismo cambio '
        'al revés lo aceptan', () async {
      final crack = await unJugadorDe('LAL');
      final rival = crack.equipo == 'BOS' ? 'NYK' : 'BOS';
      final suCrack = await unJugadorDe(rival);

      // Se busca en tu plantilla a alguien claramente peor que su estrella.
      final tuya = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('LAL'))
            ..orderBy([(t) => OrderingTerm.asc(t.media)]))
          .get();
      final tuPeor = tuya.first;

      final robo = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: rival,
          tuyos: [tuPeor.id],
          suyos: [suCrack.id]);
      expect(robo.aceptado, isFalse);
      expect(robo.margen, lessThan(0));

      // El mismo intercambio al revés: tú das la estrella y pides a su
      // peor jugador. Ahí el que sale ganando es el rival.
      final delRival = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals(rival))
            ..orderBy([(t) => OrderingTerm.asc(t.media)]))
          .get();
      final regalo = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: rival,
          tuyos: [crack.id],
          suyos: [delRival.first.id]);
      expect(regalo.margen, greaterThan(0));
      // Puede rechazarlo igualmente si no le cabe el salario de la
      // estrella bajo el tope, pero nunca por falta de valor.
      expect(regalo.mensaje, isNot(contains('no le sale a cuenta')));
    });

    test('un cambio de valor parecido pero a favor del rival, con los '
        'salarios cuadrados, se acepta', () async {
      // Dos jugadores de sueldo parecido para que el tope no estorbe, pero
      // el que da el usuario claramente mejor.
      final mio = await db.into(db.jugadores).insert(_ficha(
          nombre: 'Estrella cedida', equipo: 'LAL', media: 90, edad: 27));
      final suyo = await db.into(db.jugadores).insert(_ficha(
          nombre: 'Suplente rival', equipo: 'BOS', media: 72, edad: 27));

      final respuesta = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: [mio],
          suyos: [suyo]);

      expect(respuesta.aceptado, isTrue, reason: respuesta.mensaje);
      expect(respuesta.margen, greaterThan(0.08));
    });

    test('ejecutarTraspaso mueve a los jugadores y les da dorsal libre en su '
        'equipo nuevo', () async {
      final mio = await unJugadorDe('LAL');
      final suyo = await unJugadorDe('BOS');

      await ejecutarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: [mio.id],
          suyos: [suyo.id]);

      final mioAhora =
          await (db.select(db.jugadores)..where((t) => t.id.equals(mio.id)))
              .getSingle();
      final suyoAhora =
          await (db.select(db.jugadores)..where((t) => t.id.equals(suyo.id)))
              .getSingle();

      expect(mioAhora.equipo, 'BOS');
      expect(suyoAhora.equipo, 'LAL');
      // El dorsal no se queda en el limbo hasta la pretemporada: se reparte
      // uno libre en el momento.
      expect(mioAhora.dorsal, isNotNull);
      expect(suyoAhora.dorsal, isNotNull);
      final enLal = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('LAL')))
          .get();
      final dorsales = enLal.map((j) => j.dorsal).toList();
      expect(dorsales.toSet().length, dorsales.length,
          reason: 'y sin pisar el de nadie');
    });

    test('no se acepta un traspaso que deje al rival sin plantilla o por '
        'encima del tope', () async {
      final suCrack = await unJugadorDe('BOS');
      final bos = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('BOS')))
          .get();
      // BOS se queda con lo justo.
      await mandarAAgenciaLibre(
          db,
          bos
              .where((j) => j.id != suCrack.id)
              .skip(plantillaMinima - 2)
              .map((j) => j.id)
              .toList());

      final tuya = await (db.select(db.jugadores)
            ..where((t) => t.equipo.equals('LAL')))
          .get();

      // Le pides dos jugadores y solo le das uno: se queda corto.
      final respuesta = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: [tuya.first.id],
          suyos: bos.take(3).map((j) => j.id).toList());
      expect(respuesta.aceptado, isFalse);
    });
  });
}
