import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/draft_repository.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late List<String> orden;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
    final equipos = await db.select(db.resultadoTemporada).get();
    orden = equipos.map((e) => e.equipo).toList()..sort();
  });

  tearDown(() async {
    await db.close();
  });

  test('el draft va turno a turno: los prospectos esperan en el pool, se '
      'elige por orden y al terminar no queda ninguno sin destino',
      () async {
    await iniciarDraft(db,
        anioDraft: 2027, ordenDeEleccion: orden, random: Random(1));

    // La clase entera está disponible y todavía no es de nadie.
    expect(await prospectosDisponibles(db), hasLength(orden.length * rondasDeDraft));
    expect(await equipoQueElige(db), orden.first);
    expect(await numeroDeEleccionActual(db), 1);

    // Elección manual: el primero de la lista se va al equipo con el turno.
    final disponibles = await prospectosDisponibles(db);
    final elegido = await elegirEnDraft(db, disponibles.first.id);
    expect(elegido, isNotNull);
    expect(elegido!.equipo, orden.first);
    expect(elegido.numeroDeEleccion, 1);
    expect(await equipoQueElige(db), orden[1]);
    expect(await numeroDeEleccionActual(db), 2);

    final jugadorElegido = await (db.select(db.jugadores)
          ..where((t) => t.id.equals(elegido.jugadorId)))
        .getSingle();
    expect(jugadorElegido.equipo, orden.first);

    // El resto lo resuelve la CPU.
    final deLaCpu = await avanzarDraftHastaElTurnoDe(db, null);
    expect(deLaCpu, hasLength(orden.length * rondasDeDraft - 1));
    expect(await equipoQueElige(db), isNull);
    expect(await prospectosDisponibles(db), isEmpty);

    await finalizarDraft(db, random: Random(1));
    expect(await leerDraftEnCurso(db), isNull);
  });

  test('avanzarDraftHastaElTurnoDe se para justo en tu turno y no elige por '
      'ti', () async {
    await iniciarDraft(db,
        anioDraft: 2027, ordenDeEleccion: orden, random: Random(2));

    final antes = await avanzarDraftHastaElTurnoDe(db, 'LAL');
    expect(await equipoQueElige(db), 'LAL');
    expect(antes.every((r) => r.equipo != 'LAL'), isTrue);
    expect(antes, hasLength(orden.indexOf('LAL')));
  });

  test('la CPU va a por el mejor disponible, y entre dos parecidos se queda '
      'con el que le tapa un hueco de plantilla', () async {
    // SAC se queda sin ningún pívot.
    final plantillaSac = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('SAC')))
        .get();
    for (final j in plantillaSac) {
      if (j.posicion == 'C' || j.posicionSecundaria == 'C') {
        await (db.update(db.jugadores)..where((t) => t.id.equals(j.id)))
            .write(const JugadoresCompanion(equipo: Value(equipoAgenciaLibre)));
      }
    }

    await iniciarDraft(db,
        anioDraft: 2027, ordenDeEleccion: ['SAC'], random: Random(3));

    // Se sustituye la clase generada por dos prospectos controlados: un
    // pívot y un base algo mejor, pero dentro del margen del empujón por
    // necesidad.
    await (db.delete(db.jugadores)
          ..where((t) => t.equipo.equals(equipoProspectos)))
        .go();
    Future<int> meterProspecto(String posicion, int media, int potencial) {
      return db.into(db.jugadores).insert(JugadoresCompanion.insert(
            nombreFicticio: 'Prospecto $posicion',
            nombreReal: '',
            posicion: posicion,
            posicionSecundaria: Value(posicion == 'C' ? 'PF' : 'SG'),
            equipo: equipoProspectos,
            edad: 20,
            media: media,
            potencial: potencial,
            atrTiro3: 60,
            atrAtaque: media,
            atrDefensa: media,
            ptsPg: 8,
            astPg: 2,
            trbPg: 5,
            factorLongevidad: 1.0,
            edadRetiro: 35,
          ));
    }

    final idPivot = await meterProspecto('C', 70, 82);
    await meterProspecto('PG', 72, 84); // ~2.8 puntos de valor por encima

    final elegido = await elegirPorLaCpu(db);
    expect(elegido!.jugadorId, idPivot,
        reason: 'siendo parecidos, SAC debería cubrir su hueco de pívot');
  });

  test('pero si el mejor disponible es claramente superior, la CPU no '
      'renuncia a él por cubrir un hueco', () async {
    final plantillaSac = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('SAC')))
        .get();
    for (final j in plantillaSac) {
      if (j.posicion == 'C' || j.posicionSecundaria == 'C') {
        await (db.update(db.jugadores)..where((t) => t.id.equals(j.id)))
            .write(const JugadoresCompanion(equipo: Value(equipoAgenciaLibre)));
      }
    }

    await iniciarDraft(db,
        anioDraft: 2027, ordenDeEleccion: ['SAC'], random: Random(3));
    await (db.delete(db.jugadores)
          ..where((t) => t.equipo.equals(equipoProspectos)))
        .go();

    Future<int> meterProspecto(String posicion, int media, int potencial) {
      return db.into(db.jugadores).insert(JugadoresCompanion.insert(
            nombreFicticio: 'Prospecto $posicion',
            nombreReal: '',
            posicion: posicion,
            posicionSecundaria: Value(posicion == 'C' ? 'PF' : 'SG'),
            equipo: equipoProspectos,
            edad: 20,
            media: media,
            potencial: potencial,
            atrTiro3: 60,
            atrAtaque: media,
            atrDefensa: media,
            ptsPg: 8,
            astPg: 2,
            trbPg: 5,
            factorLongevidad: 1.0,
            edadRetiro: 35,
          ));
    }

    await meterProspecto('C', 60, 70);
    final idEstrella = await meterProspecto('PG', 78, 96);

    final elegido = await elegirPorLaCpu(db);
    expect(elegido!.jugadorId, idEstrella,
        reason: 'un proyecto de estrella vale más que tapar un hueco');
  });

  test('los prospectos que nadie elige acaban en la agencia libre, no '
      'flotando en el pool', () async {
    // Solo dos turnos: sobran 58 prospectos de los 60 generados.
    await iniciarDraft(db,
        anioDraft: 2027, ordenDeEleccion: orden, random: Random(4));
    final total = (await prospectosDisponibles(db)).length;

    await elegirPorLaCpu(db);
    await finalizarDraft(db, random: Random(4));

    expect(await prospectosDisponibles(db), isEmpty);
    final libres = await (db.select(db.jugadores)
          ..where((t) =>
              t.equipo.equals(equipoAgenciaLibre) & t.draftYear.equals(2027)))
        .get();
    expect(libres, hasLength(total - 1));
  });

  test('cerrarTemporada deja el draft listo y finalizarPretemporada lo '
      'cierra: el cambio de año se puede partir en dos', () async {
    // Récords para que haya orden de draft y playoffs resueltos.
    final rng = Random(9);
    for (final e in await db.select(db.resultadoTemporada).get()) {
      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals(e.equipo)))
          .write(ResultadoTemporadaCompanion(
        victorias: Value(20 + rng.nextInt(43)),
        derrotas: Value(20 + rng.nextInt(43)),
      ));
    }

    final cierre = await cerrarTemporada(db, random: rng);
    expect(cierre.temporadaCerrada, 1);
    expect(await leerDraftEnCurso(db), isNotNull,
        reason: 'el draft tiene que quedar en marcha');

    final rookies = await avanzarDraftHastaElTurnoDe(db, null);
    final resumen = await finalizarPretemporada(db, cierre, rookies, random: rng);

    expect(resumen.temporadaNueva, 2);
    expect(resumen.tusRookies, hasLength(rondasDeDraft));
    expect(await leerDraftEnCurso(db), isNull);

    // Y la temporada nueva está generada.
    final partidos = await leerPartidos(db, 'LAL');
    expect(partidos, hasLength(82));
    expect(partidos.every((p) => !p.jugado), isTrue);
  });

  test('los nombres generados no son estrellas reales disfrazadas', () async {
    // Antes de la corrección, todo apellido "raro" de la lista era una
    // estrella actual con una o dos letras cambiadas: Doncik (Doncic),
    // Jokik (Jokic), Antetokunmo (Antetokounmpo), Wembanyema (Wembanyama),
    // Bogdanovik (Bogdanovic)... Se comprueba que ninguno de esos ha
    // vuelto a colarse en una clase de draft grande.
    const disfracesProhibidos = [
      'doncik', 'jokik', 'antetokunmo', 'wembanyema', 'bogdanovik',
      'petrovik', 'sabonas', 'hernangomes', 'holmgrun', 'banchera',
      'poeltel', 'zubats',
    ];

    final clase = generarClaseDeDraft(
      anioDraft: 2030,
      cantidad: 400,
      nombresYaUsados: {},
      random: Random(42),
    );

    for (final p in clase) {
      final apellido =
          p.companion.nombreFicticio.value.split(' ').last.toLowerCase();
      expect(disfracesProhibidos, isNot(contains(apellido)),
          reason: '"${p.companion.nombreFicticio.value}" suena a una '
              'estrella real disfrazada');
    }
  });

  test('la distribución de origen de los nombres es mayoría EEUU, con '
      'europeos y africanos como minoría clara', () async {
    // Los apellidos de cada bolsa no se solapan entre sí, así que contar
    // en qué bolsa cae cada uno basta para medir la proporción real.
    const apellidosEuropa = {
      'Novak', 'Ivanovic', 'Kovac', 'Horvat', 'Pavlovic', 'Lindqvist',
      'Berger', 'Rossi', 'Moretti', 'Kowalski', 'Novotny', 'Halvorsen',
      'Andersson', 'Marchetti', 'Vukovic',
    };
    const apellidosAfrica = {
      'Mensah', 'Osei', 'Nwosu', 'Abara', 'Diakite', 'Toure',
    };

    final clase = generarClaseDeDraft(
      anioDraft: 2030,
      cantidad: 2000,
      nombresYaUsados: {},
      random: Random(7),
    );

    var europa = 0;
    var africa = 0;
    for (final p in clase) {
      final apellido = p.companion.nombreFicticio.value.split(' ').last;
      if (apellidosEuropa.contains(apellido)) europa++;
      if (apellidosAfrica.contains(apellido)) africa++;
    }

    final total = clase.length;
    // Con pesos 70/24/6 hay margen de sobra para no ser un test frágil,
    // pero sigue comprobando que EEUU domina claramente y África es
    // minoría clara frente a Europa.
    expect(europa / total, inInclusiveRange(0.10, 0.40));
    expect(africa / total, inInclusiveRange(0.01, 0.15));
    expect(africa, lessThan(europa));
  });
}
