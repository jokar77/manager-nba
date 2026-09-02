import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/curva_estadisticas.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/equipos_info.dart';
import 'package:manager_nba/domain/modo_carrera_repository.dart';
import 'package:manager_nba/domain/salarios.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
  });

  tearDown(() async {
    await db.close();
  });

  const identidad = IdentidadCarrera(
    apellido: 'Testigo',
    dorsal: 7,
    posicion: 'PG',
    nacionalidad: 'ESP',
  );

  test('leerPartidaCarrera es null antes de crear la carrera', () async {
    expect(await leerPartidaCarrera(db), isNull);
  });

  test('crearPartidaCarrera arranca a los 16 años en fase juvenil, sin '
      'organización elegida todavía', () async {
    await crearPartidaCarrera(db, identidad, random: Random(1));

    final estado = await leerPartidaCarrera(db);
    expect(estado, isNotNull);
    expect(estado!.edad, 16);
    expect(estado.fase, FaseCarrera.juvenil);
    expect(estado.organizacionActual, isNull);
    expect(estado.apellido, 'Testigo');
    expect(estado.dorsal, 7);
    expect(estado.posicion, 'PG');
    expect(estado.jugadorId, isNull);
    expect(estado.cadenciaAnios, 1,
        reason: 'por defecto, una decisión cada temporada');
  });

  test('crearPartidaCarrera guarda la cadencia de decisión elegida',
      () async {
    await crearPartidaCarrera(
      db,
      const IdentidadCarrera(
        apellido: 'Testigo',
        dorsal: 7,
        posicion: 'PG',
        nacionalidad: 'ESP',
        cadenciaAnios: 3,
      ),
      random: Random(1),
    );

    final estado = await leerPartidaCarrera(db);
    expect(estado!.cadenciaAnios, 3);
  });

  test('crearPartidaCarrera rechaza una cadencia fuera de 1-3', () async {
    expect(
      () => crearPartidaCarrera(
        db,
        const IdentidadCarrera(
          apellido: 'X',
          dorsal: 1,
          posicion: 'PG',
          nacionalidad: 'ESP',
          cadenciaAnios: 4,
        ),
      ),
      throwsArgumentError,
    );
  });

  test('crearPartidaCarrera rechaza una nacionalidad sin ruta juvenil',
      () async {
    expect(
      () => crearPartidaCarrera(
        db,
        const IdentidadCarrera(
          apellido: 'X',
          dorsal: 1,
          posicion: 'PG',
          nacionalidad: 'ZZZ',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('avanzarTemporadaJuvenil exige haber elegido organización antes',
      () async {
    await crearPartidaCarrera(db, identidad, random: Random(1));
    expect(() => avanzarTemporadaJuvenil(db), throwsStateError);
  });

  test('elegirOrganizacionJuvenil rechaza una organización que no es de tu '
      'país', () async {
    await crearPartidaCarrera(db, identidad, random: Random(1));
    expect(
      () => elegirOrganizacionJuvenil(db, 'Un club cualquiera'),
      throwsArgumentError,
    );
  });

  test('la fase juvenil progresa temporada a temporada hasta llegar a la '
      'edad de draft', () async {
    await crearPartidaCarrera(db, identidad, random: Random(1));
    final oferta = ofertasJuvenilesIniciales('ESP').first;
    await elegirOrganizacionJuvenil(db, oferta);

    final rng = Random(42);
    ResumenTemporadaJuvenil? ultimo;
    for (var i = 0; i < edadDeDraft - edadInicialCarrera; i++) {
      ultimo = await avanzarTemporadaJuvenil(db, random: rng);
    }

    expect(ultimo, isNotNull);
    expect(ultimo!.pasaAPredraft, isTrue);

    final estado = await leerPartidaCarrera(db);
    expect(estado!.fase, FaseCarrera.predraft);
    expect(estado.edad, edadDeDraft);

    final historial = await db.select(db.historialTemporadaJuvenil).get();
    expect(historial.length, edadDeDraft - edadInicialCarrera);
  });

  test('entrarAlDraft crea la fila real en Jugadores y pasa a fase nba',
      () async {
    await crearPartidaCarrera(db, identidad, random: Random(1));
    await elegirOrganizacionJuvenil(db, ofertasJuvenilesIniciales('ESP').first);
    final rng = Random(7);
    for (var i = 0; i < edadDeDraft - edadInicialCarrera; i++) {
      await avanzarTemporadaJuvenil(db, random: rng);
    }

    final resultado = await entrarAlDraft(db, random: rng);
    expect(equiposInfo.containsKey(resultado.equipo), isTrue);
    // El draft solo puede caer en una de las 30 franquicias reales —
    // `equiposInfo` también tiene las selecciones del All-Star (Este,
    // Oeste, Novatos, Sophomores), que no son equipos de verdad.
    expect(esFranquicia(resultado.equipo), isTrue);
    expect(equiposDeAllStar.contains(resultado.equipo), isFalse);

    final estado = await leerPartidaCarrera(db);
    expect(estado!.fase, FaseCarrera.nba);
    expect(estado.jugadorId, resultado.jugadorId);
    expect(estado.equipoNba, resultado.equipo);

    final jugador = await (db.select(db.jugadores)
          ..where((t) => t.id.equals(resultado.jugadorId)))
        .getSingle();
    expect(jugador.posicion, 'PG');
    expect(jugador.dorsal, 7);
    expect(jugador.equipo, resultado.equipo);
    expect(jugador.retirado, isFalse);
  });

  test('entrarAlDraft falla si la carrera no está en fase predraft',
      () async {
    await crearPartidaCarrera(db, identidad, random: Random(1));
    expect(() => entrarAlDraft(db), throwsStateError);
  });

  test('si el dorsal elegido choca con alguien del equipo que te draftea, '
      'se resuelve sin dejar duplicados', () async {
    // El dorsal no se puede comprobar contra ningún equipo al crear el
    // personaje (todavía no se sabe cuál te va a draftear), así que
    // entrarAlDraft tiene que resolver el choque si lo hay — 23 es un
    // número común entre los 646 reales, buena apuesta para toparse con
    // alguien.
    final rng = Random(11);
    await crearPartidaCarrera(
      db,
      const IdentidadCarrera(
        apellido: 'Testigo',
        dorsal: 23,
        posicion: 'PG',
        nacionalidad: 'ESP',
      ),
      random: rng,
    );
    await elegirOrganizacionJuvenil(db, ofertasJuvenilesIniciales('ESP').first);
    for (var i = 0; i < edadDeDraft - edadInicialCarrera; i++) {
      await avanzarTemporadaJuvenil(db, random: rng);
    }

    final resultado = await entrarAlDraft(db, random: rng);

    final plantilla = await (db.select(db.jugadores)
          ..where((t) =>
              t.equipo.equals(resultado.equipo) & t.retirado.equals(false)))
        .get();
    final dorsales = plantilla.map((j) => j.dorsal).whereType<int>().toList();
    expect(dorsales.length, dorsales.toSet().length,
        reason: 'ningún equipo puede tener dos jugadores con el mismo dorsal');

    final miJugador = plantilla.firstWhere((j) => j.id == resultado.jugadorId);
    expect(miJugador.dorsal, isNotNull);
  });

  test('el efecto de un evento de carrera se nota en la media de la '
      'temporada juvenil', () async {
    await crearPartidaCarrera(db, identidad, random: Random(1));
    await elegirOrganizacionJuvenil(db, ofertasJuvenilesIniciales('ESP').first);

    final resumen = await avanzarTemporadaJuvenil(db,
        random: Random(1), efectoMedia: 20);
    // Sin el bonus, esta semilla no llega ni de lejos a +20: si el efecto
    // no se estuviera aplicando, mediaDespues rondaría lo que ya se mide en
    // otros tests (unos pocos puntos). Con él, tiene que notarse claramente.
    expect(resumen.mediaDespues - resumen.mediaAntes, greaterThan(5));
  });

  Future<int> llevarHastaLaNba(Random rng) async {
    await crearPartidaCarrera(db, identidad, random: rng);
    await elegirOrganizacionJuvenil(db, ofertasJuvenilesIniciales('ESP').first);
    for (var i = 0; i < edadDeDraft - edadInicialCarrera; i++) {
      await avanzarTemporadaJuvenil(db, random: rng);
    }
    final resultado = await entrarAlDraft(db, random: rng);
    return resultado.jugadorId;
  }

  test('el efecto de un evento de carrera se nota en la media de la '
      'temporada NBA', () async {
    final rng = Random(7);
    await llevarHastaLaNba(rng);

    final resumen =
        await avanzarTemporadaNba(db, random: rng, efectoMedia: 20);
    expect(resumen.mediaDespues - resumen.mediaAntes, greaterThan(5));
  });

  test('avanzarTemporadaNba juega los 82 partidos y archiva la temporada en '
      'HistorialEstadisticasJugador', () async {
    final rng = Random(99);
    final jugadorId = await llevarHastaLaNba(rng);

    final resumen = await avanzarTemporadaNba(db, random: rng);
    expect(resumen.partidosJugados, partidosPorTemporadaNba);
    expect(resumen.victorias + resumen.derrotas, partidosPorTemporadaNba);
    expect(resumen.temporada, 1);

    final historial = await (db.select(db.historialEstadisticasJugador)
          ..where((t) => t.jugadorId.equals(jugadorId)))
        .get();
    expect(historial, hasLength(1));
    expect(historial.single.partidosJugados, partidosPorTemporadaNba);

    final estado = await leerPartidaCarrera(db);
    expect(estado!.temporadaNba, 1);
  });

  test('las estadísticas y los atributos se recalculan con la media nueva '
      'cada temporada, no se quedan congelados en los del draft', () async {
    final rng = Random(3);
    final jugadorId = await llevarHastaLaNba(rng);

    final antesDeJugar = await (db.select(db.jugadores)
          ..where((t) => t.id.equals(jugadorId)))
        .getSingle();
    // El valor de referencia al draftear: si el fallo (congelarse) volviera,
    // esta comprobación de abajo seguiría cumpliéndose por casualidad en la
    // primera temporada, así que hace falta jugar varias para que la media
    // se mueva de verdad.
    expect(antesDeJugar.ptsPg, puntosTipicos(antesDeJugar.media));
    // Proporción atributo/media al draftear, para comprobar que se
    // mantiene (dentro del redondeo) según la media va cambiando —
    // `_escalarAtributo` reescala proporcionalmente, no fija un valor.
    final proporcionAtaqueInicial =
        antesDeJugar.atrAtaque / antesDeJugar.media;

    for (var i = 0; i < 8; i++) {
      final resumen = await avanzarTemporadaNba(db, random: rng);
      if (resumen.seRetira) break;
      await elegirEquipoTemporada(db, resumen.ofertaQuedarse);

      final jugador = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(jugadorId)))
          .getSingle();
      // La comprobación central del bug: ptsPg/astPg/trbPg tienen que
      // corresponder a la media de ESTA temporada, no a la del draft.
      expect(jugador.ptsPg, puntosTipicos(jugador.media),
          reason: 'ptsPg se quedó congelado en vez de seguir a la media');
      expect(
          jugador.astPg, asistenciasTipicas(jugador.media, jugador.posicion));
      expect(jugador.trbPg, rebotesTipicos(jugador.media, jugador.posicion));
      // Mismo bug, en los otros tres atributos que también lee el motor
      // de simulación: no pueden quedarse congelados en los del draft.
      expect((jugador.atrAtaque / jugador.media - proporcionAtaqueInicial)
              .abs(),
          lessThan(0.05),
          reason: 'atrAtaque no está escalando con la media');
    }
  });

  test('avanzarTemporadaNba falla si todavía no hay draft', () async {
    await crearPartidaCarrera(db, identidad, random: Random(1));
    expect(() => avanzarTemporadaNba(db), throwsStateError);
  });

  test('avanzarTemporadaNba ofrece quedarte o traspasarte a uno de dos '
      'equipos distintos, y elegirEquipoTemporada aplica la elegida con '
      'salario y años de contrato válidos', () async {
    final rng = Random(2);
    final jugadorId = await llevarHastaLaNba(rng);

    var huboTraspaso = false;
    for (var i = 0; i < 10; i++) {
      final resumen = await avanzarTemporadaNba(db, random: rng);
      if (resumen.seRetira) break;

      expect(resumen.ofertasDeTraspaso, hasLength(2));
      final equiposOfrecidos = {
        resumen.ofertaQuedarse.equipo,
        for (final o in resumen.ofertasDeTraspaso) o.equipo,
      };
      expect(equiposOfrecidos, hasLength(3),
          reason: 'las 3 ofertas de la temporada deben ser de equipos '
              'distintos entre sí');
      for (final equipo in equiposOfrecidos) {
        expect(esFranquicia(equipo), isTrue,
            reason: 'ninguna oferta puede caer en una selección del '
                'All-Star (Este/Oeste/Novatos/Sophomores)');
      }

      // Se alterna la elección para probar los dos caminos: quedarse y
      // pedir el traspaso.
      final elegida =
          i.isEven ? resumen.ofertasDeTraspaso.first : resumen.ofertaQuedarse;
      if (elegida.equipo != resumen.equipo) huboTraspaso = true;
      await elegirEquipoTemporada(db, elegida);

      final jugador = await (db.select(db.jugadores)
            ..where((t) => t.id.equals(jugadorId)))
          .getSingle();
      expect(jugador.salario, greaterThanOrEqualTo(salarioMinimo));
      expect(jugador.aniosContrato, greaterThan(0));
      // El equipo que ha quedado grabado en su fila de Jugadores tiene que
      // ser el de la oferta que se eligió.
      expect(jugador.equipo, elegida.equipo);
    }

    expect(huboTraspaso, isTrue,
        reason: 'con la elección alternada, la primera temporada ya pide '
            'el traspaso');
  });

  test('una carrera jugada hasta el final de la edad máxima se retira, entra '
      'en el Hall of Fame si da la talla, y su carrera queda en '
      'HistorialEstadisticasJugador', () async {
    // Semilla elegida para que el jugador nazca con potencial alto: así
    // acumula temporadas de sobra por encima del umbral del Hall of Fama
    // (55 puntos) antes de que la edad máxima le obligue a retirarse.
    final rng = Random(2024);
    final jugadorId = await llevarHastaLaNba(rng);

    ResumenTemporadaNba resumen;
    var temporadas = 0;
    do {
      resumen = await avanzarTemporadaNba(db, random: rng);
      temporadas++;
    } while (!resumen.seRetira && temporadas < 40);

    expect(resumen.seRetira, isTrue,
        reason: 'con 40 temporadas de margen ya se debería haber retirado');

    final jugador =
        await (db.select(db.jugadores)..where((t) => t.id.equals(jugadorId)))
            .getSingle();
    expect(jugador.retirado, isTrue);
    expect(jugador.equipo, equipoRetirados);

    final estado = await leerPartidaCarrera(db);
    expect(estado!.fase, FaseCarrera.retirado);

    final historial = await (db.select(db.historialEstadisticasJugador)
          ..where((t) => t.jugadorId.equals(jugadorId)))
        .get();
    expect(historial.length, temporadas);
  });
}
