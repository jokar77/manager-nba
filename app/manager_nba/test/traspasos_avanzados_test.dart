import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/agencia_libre_repository.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/draft_repository.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/ofertas_repository.dart';
import 'package:manager_nba/domain/picks_repository.dart';
import 'package:manager_nba/domain/posiciones.dart';
import 'package:manager_nba/domain/restriccion_de_fichaje.dart';
import 'package:manager_nba/domain/salarios.dart';
import 'package:manager_nba/domain/tipo_evento_temporada.dart';
import 'package:manager_nba/domain/traspasos_cpu_repository.dart';
import 'package:manager_nba/domain/traspasos_repository.dart';

/// Un generador que siempre devuelve el mismo número: sirve para forzar que
/// algo que depende de la suerte pase (o no) sin repetir el test 100 veces.
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

  Future<int> anioDelProximoDraft() async =>
      (await leerTemporada(db)).anioInicio + 1;

  group('picks de draft', () {
    test('al crear la franquicia cada equipo tiene sus dos picks de los '
        'próximos años, todos suyos', () async {
      final picks = await picksVivos(db);
      final equipos = picks.map((p) => p.equipoOriginal).toSet();

      expect(equipos.length, 30);
      expect(picks.length, 30 * rondasDeDraft * aniosDePicksFuturos);
      expect(picks.every((p) => p.equipoActual == p.equipoOriginal), isTrue);
      expect(await picksDe(db, 'LAL'),
          hasLength(rondasDeDraft * aniosDePicksFuturos));
    });

    test('un pick vale más cuanto peor es el equipo del que viene, y una '
        'primera ronda vale más que una segunda', () async {
      final picks = await picksVivos(db);
      final anio = await anioDelProximoDraft();
      final fuerza = await fuerzaDeLosEquipos(db);
      final puestos = puestosEsperadosDeDraft(fuerza);

      // El peor equipo de la liga elige el primero.
      final peor = puestos.entries.firstWhere((e) => e.value == 1).key;
      final mejor = puestos.entries.firstWhere((e) => e.value == 30).key;

      PickDraft pick(String equipo, int ronda) => picks.firstWhere((p) =>
          p.equipoOriginal == equipo && p.ronda == ronda && p.temporada == anio);

      double valor(PickDraft p) => valorDePick(p,
          puestosEsperados: puestos, anioActualDeDraft: anio);

      expect(valor(pick(peor, 1)), greaterThan(valor(pick(mejor, 1))));
      expect(valor(pick(peor, 1)), greaterThan(valor(pick(peor, 2))));

      // Y un pick lejano vale menos que el mismo pick del año que viene.
      final lejano = picks.firstWhere((p) =>
          p.equipoOriginal == peor &&
          p.ronda == 1 &&
          p.temporada == anio + aniosDePicksFuturos - 1);
      expect(valor(lejano), lessThan(valor(pick(peor, 1))));
    });

    test('el draft respeta quién es el dueño del pick, no la clasificación',
        () async {
      final anio = await anioDelProximoDraft();
      final deBoston = (await picksDe(db, 'BOS'))
          .firstWhere((p) => p.ronda == 1 && p.temporada == anio);
      await traspasarPicks(db, [deBoston.id], 'LAL');

      // BOS elige el primero por clasificación, pero su pick es de LAL.
      final orden = ['BOS', 'NYK', ...await _otrosEquipos(db, ['BOS', 'NYK'])];
      await iniciarDraft(db,
          anioDraft: anio, ordenDeEleccion: orden, random: Random(1));

      expect(await equipoQueElige(db), 'LAL');
      expect(await numeroDeEleccionActual(db), 1);
    });

    test('al cerrarse un draft sus picks quedan gastados y se abre un año '
        'nuevo al final del horizonte', () async {
      final anio = await anioDelProximoDraft();
      final orden = await _otrosEquipos(db, []);
      await celebrarDraft(db,
          anioDraft: anio, ordenDeEleccion: orden, random: Random(7));

      final vivos = await picksVivos(db);
      expect(vivos.any((p) => p.temporada <= anio), isFalse,
          reason: 'los del draft recién celebrado ya están usados');
      expect(vivos.map((p) => p.temporada).reduce(max),
          anio + aniosDePicksFuturos);
      expect(await picksDe(db, 'LAL'),
          hasLength(rondasDeDraft * aniosDePicksFuturos));
    });

    test('un pick se puede meter en un traspaso y cambia de dueño', () async {
      final anio = await anioDelProximoDraft();
      final mio = (await picksDe(db, 'LAL'))
          .firstWhere((p) => p.ronda == 1 && p.temporada == anio);

      // Tu peor jugador y un pick de primera ronda a cambio del suyo: con
      // eso les sobra para decir que sí, y ninguna plantilla cambia de
      // tamaño.
      final peorDeLal = (await plantillaParaTraspasos(db, 'LAL')).last;
      final peorDeBos = (await plantillaParaTraspasos(db, 'BOS')).last;
      final respuesta = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: [peorDeLal.id],
          tusPicks: [mio.id],
          suyos: [peorDeBos.id]);
      expect(respuesta.aceptado, isTrue, reason: respuesta.mensaje);

      await ejecutarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: [peorDeLal.id],
          tusPicks: [mio.id],
          suyos: [peorDeBos.id]);

      final ahora = (await picksVivos(db)).firstWhere((p) => p.id == mio.id);
      expect(ahora.equipoActual, 'BOS');
      expect(ahora.equipoOriginal, 'LAL',
          reason: 'sigue cayendo en el puesto que le toque a LAL');
    });
  });

  group('romperte la plantilla', () {
    test('por defecto se bloquea, pero desde la mesa de traspasos solo '
        'avisa', () async {
      // Se vacía LAL hasta dejarlo justo en el mínimo: soltar a uno más lo
      // deja corto.
      final tuya = await plantillaParaTraspasos(db, 'LAL');
      await (db.update(db.jugadores)
            ..where((t) =>
                t.id.isIn(tuya.skip(plantillaMinima).map((j) => j.id))))
          .write(const JugadoresCompanion(equipo: Value(equipoAgenciaLibre)));

      // Das dos y pides uno: te quedas en 12. Se eligen dos sueldos bajos
      // para que lo que decida sea la plantilla y no el tope salarial.
      final baratos = [...tuya.take(plantillaMinima)]
        ..sort((a, b) => a.salario.compareTo(b.salario));
      final unos = [baratos[0].id, baratos[1].id];
      final peorDeBos = (await plantillaParaTraspasos(db, 'BOS')).last;

      final bloqueado = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: unos,
          suyos: [peorDeBos.id]);
      expect(bloqueado.aceptado, isFalse);
      expect(bloqueado.mensaje, contains('Te dejaría'));
      expect(bloqueado.aviso, isNull);

      final permitido = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: unos,
          suyos: [peorDeBos.id],
          dejarRompertePlantilla: true);
      expect(permitido.aceptado, isTrue, reason: permitido.mensaje);
      expect(permitido.aviso, isNotNull);
      expect(permitido.aviso, contains('agencia libre'));
    });

    test('el buscador automático nunca propone algo que te deje cojo',
        () async {
      final tuya = await plantillaParaTraspasos(db, 'LAL');
      await (db.update(db.jugadores)
            ..where((t) =>
                t.id.isIn(tuya.skip(plantillaMinima).map((j) => j.id))))
          .write(const JugadoresCompanion(equipo: Value(equipoAgenciaLibre)));

      final objetivo = (await plantillaParaTraspasos(db, 'BOS')).first;
      final propuestas = await buscarFichajeDe(db,
          equipoUsuario: 'LAL', jugadorObjetivoId: objetivo.id);

      for (final p in propuestas) {
        expect(p.jugadoresQueSalen.length, lessThanOrEqualTo(1),
            reason: 'con 13 en plantilla no puede pedirte dos y darte uno');
      }
    });
  });

  group('restricción de fichaje reciente', () {
    test('un jugador fichado hace poco no se puede traspasar, sea cual sea '
        'el paquete ofrecido', () async {
      // La fecha "de hoy" de la liga, no la del reloj real: nada más crear
      // la franquicia ya hay un calendario generado con partidos en
      // octubre, así que comparar contra `DateTime.now()` aquí daba una
      // diferencia de meses que no tenía nada que ver con la firma.
      final hoy = await fechaActualDeLaLiga(db) ?? DateTime.now();
      final tuya = await plantillaParaTraspasos(db, 'LAL');
      final recienFichado = tuya.first;
      await (db.update(db.jugadores)
            ..where((t) => t.id.equals(recienFichado.id)))
          .write(JugadoresCompanion(
              fechaFichaje: Value(hoy.subtract(
                  const Duration(days: diasMinimosTrasFichaje - 10)))));

      final peorDeBos = (await plantillaParaTraspasos(db, 'BOS')).last;
      final respuesta = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: [recienFichado.id],
          suyos: [peorDeBos.id]);

      expect(respuesta.aceptado, isFalse);
      expect(respuesta.mensaje, contains('no se puede traspasar todavía'));
    });

    test('pasados los tres meses, ya se puede traspasar con normalidad',
        () async {
      final hoy = await fechaActualDeLaLiga(db) ?? DateTime.now();
      final tuya = await plantillaParaTraspasos(db, 'LAL');
      final fichadoHaceTiempo = tuya.first;
      await (db.update(db.jugadores)
            ..where((t) => t.id.equals(fichadoHaceTiempo.id)))
          .write(JugadoresCompanion(
              fechaFichaje: Value(hoy.subtract(
                  const Duration(days: diasMinimosTrasFichaje + 1)))));

      final peorDeBos = (await plantillaParaTraspasos(db, 'BOS')).last;
      final respuesta = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: [fichadoHaceTiempo.id],
          suyos: [peorDeBos.id]);

      expect(respuesta.mensaje, isNot(contains('no se puede traspasar')));
    });

    test('fichar por agencia libre dispara la restricción de inmediato',
        () async {
      final libre = (await agentesLibres(db)).first;
      final fichado = await ficharAgenteLibre(db,
          jugadorId: libre.id, equipo: 'LAL', salario: salarioMinimo);
      expect(fichado, isNotNull);

      final peorDeBos = (await plantillaParaTraspasos(db, 'BOS')).last;
      final respuesta = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: 'BOS',
          tuyos: [libre.id],
          suyos: [peorDeBos.id]);

      expect(respuesta.aceptado, isFalse);
      expect(respuesta.mensaje, contains('no se puede traspasar todavía'));
    });
  });

  group('encaje salarial', () {
    test('media liga arranca por encima del tope: es lo normal, no un error',
        () async {
      final mercado = await cargarMercado(db);
      final pasados = mercado.franquicias
          .where((e) => mercado.masaSalarialDe(e) > topeSalarial);
      expect(pasados, isNotEmpty,
          reason: 'las plantillas reales cuestan más que el tope, como en la '
              'NBA de verdad; el tope no puede ser un muro para traspasar');
    });

    test('un equipo pasado de tope puede recibir un sueldo parecido al que '
        'suelta, pero no absorber uno grande a cambio de nada', () {
      const masa = 260000000;
      expect(
          encajeSalarialRoto(
              masaPrevia: masa,
              salarioQueSale: 50000000,
              salarioQueEntra: 52000000),
          isNull,
          reason: 'sueldos emparejados: el traspaso clásico de estrella');
      expect(
          encajeSalarialRoto(
              masaPrevia: masa,
              salarioQueSale: 3000000,
              salarioQueEntra: 50000000),
          isNotNull,
          reason: 'eso es meterse 47M más estando ya pasado de tope');
    });

    test('quien acaba por debajo del tope puede absorber lo que quiera', () {
      expect(
          encajeSalarialRoto(
              masaPrevia: 100000000,
              salarioQueSale: 2300000,
              salarioQueEntra: 60000000),
          isNull);
    });

    test('fichar a la estrella de un equipo pasado de tope ya no se cae por '
        'el tope salarial', () async {
      // El caso que reportaste: Jaylen Brown juega en un Boston que arranca
      // muy por encima del tope. Antes, cualquier paquete por él lo tumbaba
      // el tope aunque los sueldos cuadrasen.
      final estrella = await (db.select(db.jugadores)
            ..where((t) => t.nombreReal.equals('Jaylen Brown')))
          .getSingleOrNull();
      expect(estrella, isNotNull, reason: 'está en el dataset');
      final mercado = await cargarMercado(db);
      expect(mercado.masaSalarialDe(estrella!.equipo),
          greaterThan(topeSalarial),
          reason: 'su equipo está pasado de tope: ese es el escenario');

      final propuestas = await buscarFichajeDe(db,
          equipoUsuario: 'LAL', jugadorObjetivoId: estrella.id);
      expect(propuestas, isNotEmpty,
          reason: 'tiene que haber alguna forma de traerlo');

      final elegida = propuestas.first;
      final respuesta = await evaluarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: elegida.equipoRival,
          tuyos: elegida.idsQueSalen,
          suyos: elegida.idsQueLlegan,
          tusPicks: elegida.idsPicksQueSalen,
          susPicks: elegida.idsPicksQueLlegan);
      expect(respuesta.aceptado, isTrue, reason: respuesta.mensaje);
    });
  });

  group('traspasos a tres bandas', () {
    test('un triángulo en el que los tres ganan se acepta y mueve a cada uno '
        'a su destino', () async {
      final mercado = await cargarMercado(db);
      final triple = _buscarTriangulo(mercado, equipoUsuario: 'LAL');
      expect(triple, isNotNull,
          reason: 'con 30 equipos tiene que salir alguno');

      final respuesta = await evaluarTraspasoMultiple(db,
          equipoUsuario: 'LAL',
          equipos: triple!.equipos,
          movimientos: triple.movimientos,
          dejarRompertePlantilla: true);
      expect(respuesta.aceptado, isTrue, reason: respuesta.mensaje);
      expect(respuesta.balances, hasLength(3));
      expect(respuesta.mensaje, contains('tres bandas'));

      await ejecutarTraspasoMultiple(db, triple.movimientos);
      for (final m in triple.movimientos.where((m) => !m.esPick)) {
        final j = await (db.select(db.jugadores)
              ..where((t) => t.id.equals(m.jugadorId!)))
            .getSingle();
        expect(j.equipo, m.destino);
      }
    });

    test('un tercer equipo que ni pone ni se lleva nada no cuela', () async {
      final mio = (await plantillaParaTraspasos(db, 'LAL')).last;
      final suyo = (await plantillaParaTraspasos(db, 'BOS')).last;

      final respuesta = await evaluarTraspasoMultiple(db,
          equipoUsuario: 'LAL',
          equipos: ['LAL', 'BOS', 'MIA'],
          movimientos: [
            MovimientoDeTraspaso.jugador(mio.id, destino: 'BOS'),
            MovimientoDeTraspaso.jugador(suyo.id, destino: 'LAL'),
          ]);
      expect(respuesta.aceptado, isFalse);
      expect(respuesta.mensaje, contains('MIA'));
    });

    test('no se puede mandar a un jugador al equipo en el que ya está',
        () async {
      final mio = (await plantillaParaTraspasos(db, 'LAL')).last;
      final respuesta = await evaluarTraspasoMultiple(db,
          equipoUsuario: 'LAL',
          equipos: ['LAL', 'BOS'],
          movimientos: [
            MovimientoDeTraspaso.jugador(mio.id, destino: 'LAL'),
          ]);
      expect(respuesta.aceptado, isFalse);
    });
  });

  group('buscador automático', () {
    test('buscar salida para uno de los tuyos devuelve traspasos que la CPU '
        'ya acepta, y se pueden cerrar tal cual', () async {
      final mio = (await plantillaParaTraspasos(db, 'LAL')).first;
      final propuestas = await buscarSalidaPara(db,
          equipoUsuario: 'LAL', jugadorIds: [mio.id]);

      expect(propuestas, isNotEmpty);
      for (final p in propuestas) {
        expect(p.idsQueSalen, [mio.id]);
        expect(p.equipoRival, isNot('LAL'));
        final respuesta = await evaluarTraspaso(db,
            equipoUsuario: 'LAL',
            equipoRival: p.equipoRival,
            tuyos: p.idsQueSalen,
            suyos: p.idsQueLlegan,
            tusPicks: p.idsPicksQueSalen,
            susPicks: p.idsPicksQueLlegan);
        expect(respuesta.aceptado, isTrue, reason: respuesta.mensaje);
      }

      final elegida = propuestas.first;
      await ejecutarTraspaso(db,
          equipoUsuario: 'LAL',
          equipoRival: elegida.equipoRival,
          tuyos: elegida.idsQueSalen,
          suyos: elegida.idsQueLlegan,
          tusPicks: elegida.idsPicksQueSalen,
          susPicks: elegida.idsPicksQueLlegan);

      final movido =
          await (db.select(db.jugadores)..where((t) => t.id.equals(mio.id)))
              .getSingle();
      expect(movido.equipo, elegida.equipoRival);
      for (final llega in elegida.idsQueLlegan) {
        final j = await (db.select(db.jugadores)..where((t) => t.id.equals(llega)))
            .getSingle();
        expect(j.equipo, 'LAL');
      }
    });

    test('si pones a dos jugadores y un pick sobre la mesa, el buscador '
        'ofrece por el paquete entero, no por uno solo', () async {
      final mios = await plantillaParaTraspasos(db, 'LAL');
      final dos = [mios[0].id, mios[1].id];
      final miPick = (await picksDe(db, 'LAL')).first;

      final propuestas = await buscarSalidaPara(db,
          equipoUsuario: 'LAL', jugadorIds: dos, pickIds: [miPick.id]);
      expect(propuestas, isNotEmpty);

      for (final p in propuestas) {
        expect(p.idsQueSalen.toSet(), dos.toSet(),
            reason: 'salen los dos, no uno');
        expect(p.idsPicksQueSalen, [miPick.id]);
        // Y lo que ofrecen es de verdad el precio del paquete: la CPU no
        // acepta pagar por dos lo que pagaría por uno.
        final respuesta = await evaluarTraspaso(db,
            equipoUsuario: 'LAL',
            equipoRival: p.equipoRival,
            tuyos: p.idsQueSalen,
            suyos: p.idsQueLlegan,
            tusPicks: p.idsPicksQueSalen,
            susPicks: p.idsPicksQueLlegan);
        expect(respuesta.aceptado, isTrue, reason: respuesta.mensaje);
      }

      final porUnoSolo = await buscarSalidaPara(db,
          equipoUsuario: 'LAL', jugadorIds: [mios[0].id]);
      expect(propuestas.first.valorQueRecibes,
          greaterThan(porUnoSolo.first.valorQueRecibes),
          reason: 'por tres piezas tienen que darte más que por una');
    });

    test('buscar cómo fichar a uno de otro equipo propone paquetes tuyos, de '
        'menos a más caro', () async {
      final objetivo = (await plantillaParaTraspasos(db, 'BOS')).first;
      final propuestas = await buscarFichajeDe(db,
          equipoUsuario: 'LAL', jugadorObjetivoId: objetivo.id);

      expect(propuestas, isNotEmpty);
      for (final p in propuestas) {
        expect(p.idsQueLlegan, [objetivo.id]);
        expect(p.equipoRival, 'BOS');
        expect(p.jugadoresQueSalen.every((j) => j.equipo == 'LAL'), isTrue);
        expect(p.picksQueSalen.every((k) => k.equipoActual == 'LAL'), isTrue);
      }
      final valores = propuestas.map((p) => p.valorQueEntregas).toList();
      expect(valores, orderedEquals([...valores]..sort()));
    });

    test('el buscador no propone nada por un jugador que no es tuyo ni por '
        'uno que ya lo es', () async {
      final suyo = (await plantillaParaTraspasos(db, 'BOS')).first;
      final mio = (await plantillaParaTraspasos(db, 'LAL')).first;

      expect(
          await buscarSalidaPara(db, equipoUsuario: 'LAL', jugadorIds: [suyo.id]),
          isEmpty);
      expect(
          await buscarFichajeDe(db,
              equipoUsuario: 'LAL', jugadorObjetivoId: mio.id),
          isEmpty);
    });
  });

  group('traspasos entre equipos de la CPU', () {
    test('la liga se mueve sola sin romper ninguna plantilla', () async {
      final cerrados = await ejecutarTraspasosDeLaCpu(db,
          equipoUsuario: 'LAL', random: Random(11));

      // Ni una liga congelada ni un mercadillo: unos cuantos movimientos.
      expect(cerrados.length, inInclusiveRange(3, 12),
          reason: 'se han cerrado ${cerrados.length} traspasos');
      expect(cerrados.map((t) => t.equipoA).toSet().length, cerrados.length,
          reason: 'cada equipo entra como mucho en un intercambio');
      expect(cerrados.every((t) => t.equipoA != 'LAL' && t.equipoB != 'LAL'),
          isTrue,
          reason: 'con tu equipo se negocia, no se decide por ti');

      final jugadores = await (db.select(db.jugadores)
            ..where((t) => t.retirado.equals(false)))
          .get();
      final porEquipo = <String, List<Jugador>>{};
      for (final j in jugadores) {
        if (!esFranquicia(j.equipo)) continue;
        porEquipo.putIfAbsent(j.equipo, () => []).add(j);
      }
      for (final entry in porEquipo.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(plantillaMinima),
            reason: '${entry.key} se ha quedado corto');
        for (final puesto in posicionesEquipo) {
          expect(entry.value.where((j) => juegaComodoDe(j, puesto)).length,
              greaterThanOrEqualTo(2),
              reason: '${entry.key} se ha quedado sin recambio en $puesto');
        }
      }
    });

    test('al empezar la temporada 2 hay jugadores que han cambiado de equipo',
        () async {
      final antes = {
        for (final j in await db.select(db.jugadores).get()) j.id: j.equipo,
      };

      final resumen = await empezarNuevaTemporada(db, random: Random(4));

      final despues = await (db.select(db.jugadores)
            ..where((t) => t.retirado.equals(false)))
          .get();
      final cambiados = despues.where((j) =>
          antes.containsKey(j.id) &&
          antes[j.id] != j.equipo &&
          esFranquicia(antes[j.id]!) &&
          esFranquicia(j.equipo));

      expect(resumen.traspasosDeLaLiga, isNotEmpty);
      expect(cambiados, isNotEmpty);
    });
  });

  group('ofertas entrantes', () {
    test('jugar la temporada entera siempre trae ofertas: el tope de 3 lo '
        'marca el límite, no la suerte', () async {
      // El ritmo va por partido simulado, así que una temporada son 82
      // tiros repartidos en tramos semanales. Con el ritmo viejo (0,022 por
      // partido) la media era de 1,4 ofertas y 1 de cada 12 temporadas se
      // quedaba a cero: te podías jugar el año sin que sonara el teléfono.
      //
      // Se arranca en la fecha real del primer partido, no en enero: el
      // mercado cierra en la fecha límite de traspasos, así que empezando a
      // mitad de curso se estaría midiendo solo la cola de la temporada.
      final primerPartido = (await leerPartidos(db, 'LAL'))
          .map((p) => p.fecha)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final porSemilla = <int>[];
      for (var semilla = 0; semilla < 8; semilla++) {
        await db.delete(db.ofertasTraspaso).go();
        await (db.update(db.temporada)..where((t) => t.id.equals(0)))
            .write(const TemporadaCompanion(
                ofertasGeneradasEstaTemporada: Value(0)));

        final rng = Random(semilla);
        var total = 0;
        for (var semana = 0; semana < 24; semana++) {
          total += await generarOfertasEntrantes(
            db,
            equipoUsuario: 'LAL',
            partidosSimulados: semana.isEven ? 3 : 4,
            fecha: primerPartido.add(Duration(days: 7 * semana)),
            random: rng,
          );
          // El usuario las va resolviendo según llegan; si no, se toparía
          // con maxOfertasPendientes y dejarían de generarse.
          await db.delete(db.ofertasTraspaso).go();
        }
        porSemilla.add(total);
      }

      expect(porSemilla.where((n) => n == 0), isEmpty,
          reason: 'ninguna temporada debería quedarse sin una sola oferta');
      expect(porSemilla.every((n) => n <= maxOfertasPorTemporada), isTrue,
          reason: 'el tope de $maxOfertasPorTemporada sigue mandando');
    });

    test('simular una temporada entera te trae alguna oferta, y aceptarla '
        'ejecuta el traspaso', () async {
      final creadas = await generarOfertasEntrantes(db,
          equipoUsuario: 'LAL',
          partidosSimulados: 1,
          fecha: DateTime(2027, 1, 15),
          random: _RandomFijo(0.0));
      expect(creadas, 1);
      expect(await ofertasSinVer(db), 1);

      final ofertas = await ofertasPendientes(db, 'LAL');
      expect(ofertas, hasLength(1));
      final oferta = ofertas.single;
      expect(oferta.tePiden, isNotEmpty);
      expect(oferta.tePiden.every((j) => j.equipo == 'LAL'), isTrue);
      expect(
          oferta.teOfrecen.every((j) => j.equipo == oferta.equipoOfertante),
          isTrue);

      await aceptarOferta(db, oferta, equipoUsuario: 'LAL');

      for (final j in oferta.tePiden) {
        final ahora =
            await (db.select(db.jugadores)..where((t) => t.id.equals(j.id)))
                .getSingle();
        expect(ahora.equipo, oferta.equipoOfertante);
      }
      for (final j in oferta.teOfrecen) {
        final ahora =
            await (db.select(db.jugadores)..where((t) => t.id.equals(j.id)))
                .getSingle();
        expect(ahora.equipo, 'LAL');
      }
      expect(await ofertasPendientes(db, 'LAL'), isEmpty);
    });

    test('sin partidos simulados no llega nada, y no se acumulan más del '
        'máximo', () async {
      expect(
          await generarOfertasEntrantes(db,
              equipoUsuario: 'LAL',
              partidosSimulados: 0,
              fecha: DateTime(2027, 1, 1),
              random: _RandomFijo(0.0)),
          0);

      for (var i = 0; i < maxOfertasPendientes + 3; i++) {
        await generarOfertasEntrantes(db,
            equipoUsuario: 'LAL',
            partidosSimulados: 30,
            fecha: DateTime(2027, 1, 1),
            random: _RandomFijo(0.0));
      }
      final pendientes = await db.select(db.ofertasTraspaso).get();
      expect(pendientes.length, lessThanOrEqualTo(maxOfertasPendientes));
    });

    test('pasada la fecha límite de traspasos ya no llama nadie', () async {
      final limite = await (db.select(db.eventosTemporada)
            ..where((t) => t.tipo
                .equals(TipoEventoTemporada.fechaLimiteTraspasos.name)))
          .getSingle();

      // El día antes sí entran ofertas.
      expect(
          await generarOfertasEntrantes(db,
              equipoUsuario: 'LAL',
              partidosSimulados: 30,
              fecha: limite.fecha.subtract(const Duration(days: 1)),
              random: _RandomFijo(0.0)),
          greaterThan(0));
      for (final o in await ofertasPendientes(db, 'LAL')) {
        await rechazarOferta(db, o.id);
      }

      // El día después, no. Antes seguían llegando en marzo y abril, y al
      // aceptarlas te saltaba que el mercado estaba cerrado.
      expect(
          await generarOfertasEntrantes(db,
              equipoUsuario: 'LAL',
              partidosSimulados: 30,
              fecha: limite.fecha.add(const Duration(days: 1)),
              random: _RandomFijo(0.0)),
          0);
      expect(await ofertasPendientes(db, 'LAL'), isEmpty);
    });

    test('hay un tope real por temporada, no solo "como mucho 3 sin '
        'resolver a la vez": aunque vayas rechazando cada oferta para '
        'liberar sitio, no llegan más de maxOfertasPorTemporada en total',
        () async {
      var generadas = 0;
      for (var i = 0; i < maxOfertasPorTemporada + 5; i++) {
        final creadas = await generarOfertasEntrantes(db,
            equipoUsuario: 'LAL',
            partidosSimulados: 30,
            fecha: DateTime(2027, 1, 1),
            random: _RandomFijo(0.0));
        generadas += creadas;
        // Se libera sitio enseguida: sin el contador por temporada, esto
        // dejaría generar una oferta nueva cada vez.
        for (final o in await ofertasPendientes(db, 'LAL')) {
          await rechazarOferta(db, o.id);
        }
      }
      expect(generadas, maxOfertasPorTemporada);

      final temporada = await leerTemporada(db);
      expect(temporada.ofertasGeneradasEstaTemporada, maxOfertasPorTemporada);
    });

    test('el tope se resetea al cambiar de temporada', () async {
      for (var i = 0; i < maxOfertasPorTemporada; i++) {
        await generarOfertasEntrantes(db,
            equipoUsuario: 'LAL',
            partidosSimulados: 30,
            fecha: DateTime(2027, 1, 1),
            random: _RandomFijo(0.0));
        for (final o in await ofertasPendientes(db, 'LAL')) {
          await rechazarOferta(db, o.id);
        }
      }
      expect((await leerTemporada(db)).ofertasGeneradasEstaTemporada,
          maxOfertasPorTemporada);
      // Agotado el tope, no llega ninguna más esta misma temporada.
      expect(
          await generarOfertasEntrantes(db,
              equipoUsuario: 'LAL',
              partidosSimulados: 30,
              fecha: DateTime(2027, 3, 1),
              random: _RandomFijo(0.0)),
          0);

      final cierre = await cerrarTemporada(db);
      final orden = await _otrosEquipos(db, []);
      final rookies = await celebrarDraft(db,
          anioDraft: cierre.anioDraft, ordenDeEleccion: orden);
      await finalizarPretemporada(db, cierre, rookies);

      expect((await leerTemporada(db)).ofertasGeneradasEstaTemporada, 0,
          reason: 'la temporada nueva empieza con el tope entero otra vez');
      final anioNuevo = (await leerTemporada(db)).anioInicio;
      expect(
          await generarOfertasEntrantes(db,
              equipoUsuario: 'LAL',
              partidosSimulados: 1,
              fecha: DateTime(anioNuevo, 11, 1),
              random: _RandomFijo(0.0)),
          1,
          reason: 'y ya puede volver a generar ofertas');
    });

    test('una oferta que se ha quedado obsoleta no se enseña', () async {
      await generarOfertasEntrantes(db,
          equipoUsuario: 'LAL',
          partidosSimulados: 1,
          fecha: DateTime(2027, 1, 15),
          random: _RandomFijo(0.0));
      final oferta = (await ofertasPendientes(db, 'LAL')).single;

      // El jugador que te pedían se va a otro sitio por su cuenta.
      await (db.update(db.jugadores)
            ..where((t) => t.id.equals(oferta.tePiden.first.id)))
          .write(const JugadoresCompanion(equipo: Value('MIA')));

      expect(await ofertasPendientes(db, 'LAL'), isEmpty);
      expect(await db.select(db.ofertasTraspaso).get(), isEmpty,
          reason: 'se limpia sola al leerla');
    });

    test('marcarOfertasComoVistas apaga el aviso pero no borra la oferta',
        () async {
      await generarOfertasEntrantes(db,
          equipoUsuario: 'LAL',
          partidosSimulados: 1,
          fecha: DateTime(2027, 1, 15),
          random: _RandomFijo(0.0));

      await marcarOfertasComoVistas(db);
      expect(await ofertasSinVer(db), 0);
      expect(await ofertasPendientes(db, 'LAL'), hasLength(1));
    });
  });
}

/// Un traspaso a tres bandas ya montado: A da a B, B da a C y C da a A.
class _Triangulo {
  final List<String> equipos;
  final List<MovimientoDeTraspaso> movimientos;
  _Triangulo(this.equipos, this.movimientos);
}

/// Busca un triángulo que los tres firmarían. Tu equipo paga la fiesta (da
/// más de lo que recibe), que es justo lo que hace falta para que a los otros
/// dos les salga a cuenta entrar.
_Triangulo? _buscarTriangulo(
  MercadoDeTraspasos mercado, {
  required String equipoUsuario,
}) {
  final otros =
      mercado.franquicias.where((e) => e != equipoUsuario).take(5).toList();
  final mios = mercado.plantillaDe(equipoUsuario).toList()
    ..sort((x, y) => valorDeTraspaso(y).compareTo(valorDeTraspaso(x)));

  /// Los [cuantos] jugadores de [equipo] con valor más cercano a [objetivo].
  List<Jugador> cerca(String equipo, double objetivo, {int cuantos = 8}) {
    final lista = mercado.plantillaDe(equipo).toList()
      ..sort((x, y) => (valorDeTraspaso(x) - objetivo)
          .abs()
          .compareTo((valorDeTraspaso(y) - objetivo).abs()));
    return lista.take(cuantos).toList();
  }

  for (final a in mios.take(6)) {
    final valorA = valorDeTraspaso(a);
    for (final b in otros) {
      for (final c in otros) {
        if (b == c) continue;
        for (final jb in cerca(b, valorA / 1.2)) {
          for (final jc in cerca(c, valorDeTraspaso(jb) / 1.2)) {
            final movimientos = [
              MovimientoDeTraspaso.jugador(a.id, destino: b),
              MovimientoDeTraspaso.jugador(jb.id, destino: c),
              MovimientoDeTraspaso.jugador(jc.id, destino: equipoUsuario),
            ];
            final respuesta = evaluarMultipleEnMercado(mercado,
                equipoUsuario: equipoUsuario,
                equipos: [equipoUsuario, b, c],
                movimientos: movimientos,
                dejarRompertePlantilla: true);
            if (respuesta.aceptado) {
              return _Triangulo([equipoUsuario, b, c], movimientos);
            }
          }
        }
      }
    }
  }
  return null;
}

/// Los 30 equipos de la liga, poniendo delante los de [primero].
Future<List<String>> _otrosEquipos(AppDatabase db, List<String> primero) async {
  final todos = (await db.select(db.jugadores).get())
      .map((j) => j.equipo)
      .where(esFranquicia)
      .toSet()
      .toList()
    ..sort();
  return [...primero, ...todos.where((e) => !primero.contains(e))];
}
