import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/eventos_narrativos_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';

ContextoDeEvento _contexto({
  int victorias = 20,
  int derrotas = 20,
  int mediaDelEquipo = 85,
  bool tieneEntrenador = true,
  int jugadoresJovenes = 3,
}) =>
    ContextoDeEvento(
      victorias: victorias,
      derrotas: derrotas,
      partidosJugados: victorias + derrotas,
      mediaDelEquipo: mediaDelEquipo,
      tieneEntrenador: tieneEntrenador,
      jugadoresJovenes: jugadoresJovenes,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  // El catálogo (Dart puro, sin base de datos)
  // -------------------------------------------------------------------------

  test('todos los eventos están bien formados', () {
    expect(catalogoDeEventos, isNotEmpty);

    final claves = <String>{};
    for (final evento in catalogoDeEventos) {
      expect(claves.add(evento.clave), isTrue,
          reason: 'la clave ${evento.clave} está repetida, y las claves son '
              'lo que impide que un evento salga dos veces por temporada');
      expect(evento.titulo.trim(), isNotEmpty);
      expect(evento.texto.trim(), isNotEmpty);
      expect(evento.opciones.length, greaterThanOrEqualTo(2),
          reason: '${evento.clave}: con una sola opción no hay decisión');

      for (final opcion in evento.opciones) {
        expect(opcion.etiqueta.trim(), isNotEmpty);
        expect(opcion.consecuencia.trim(), isNotEmpty,
            reason: '${evento.clave}: sin consecuencia escrita, el usuario '
                'elige a ciegas y no aprende nada');
      }
    }
  });

  test('ningún efecto se pasa de los topes medidos', () {
    // El tope no es decorativo: la simulación vale 3,7 victorias por cada
    // 1% de rendimiento de equipo, así que un efecto suelto que se fuera de
    // rango valdría más que todo el sistema de entrenadores.
    for (final evento in catalogoDeEventos) {
      for (final opcion in evento.opciones) {
        for (final efecto in opcion.efectos) {
          expect(efecto.factor,
              inInclusiveRange(minFactorDeEvento, maxFactorDeEvento),
              reason: '${evento.clave} / ${opcion.etiqueta}: factor '
                  '${efecto.factor} fuera de rango');
          expect(efecto.partidos, inInclusiveRange(1, maxPartidosDeEfecto),
              reason: '${evento.clave} / ${opcion.etiqueta}: '
                  '${efecto.partidos} partidos es demasiado');
          expect(efecto.etiqueta.trim(), isNotEmpty);
        }
      }
    }
  });

  test('ninguna opción es gratis: la que más da, algo cuesta', () {
    // La regla de diseño número 1. Se comprueba de la única forma
    // automatizable: dentro de un mismo evento, la opción con más ganancia
    // acumulada tiene que tener también algún inconveniente — o bien no ser
    // la única con efectos positivos.
    for (final evento in catalogoDeEventos) {
      double balance(OpcionDeEvento o) => o.efectos.fold<double>(
          0, (a, e) => a + (e.factor - 1) * e.partidos);

      final mejor = evento.opciones
          .reduce((a, b) => balance(a) >= balance(b) ? a : b);
      if (balance(mejor) <= 0) continue; // ninguna opción es netamente buena

      final tieneCoste = mejor.efectos.any((e) => !e.esBueno);
      final hayOtraBuena = evento.opciones
          .where((o) => o != mejor)
          .any((o) => balance(o) > 0);
      expect(tieneCoste || hayOtraBuena, isTrue,
          reason: '${evento.clave}: "${mejor.etiqueta}" es mejor que el resto '
              'y no cuesta nada, así que no hay nada que decidir');
    }
  });

  test('las condiciones filtran de verdad: una pelea no sale líder de la '
      'liga', () {
    final lider = _contexto(victorias: 40, derrotas: 8);
    final hundido = _contexto(victorias: 8, derrotas: 40);

    final bronca = catalogoDeEventos
        .firstWhere((e) => e.clave == 'bronca_en_el_entrenamiento');
    expect(bronca.encajaEn(lider), isFalse);
    expect(bronca.encajaEn(hundido), isTrue);

    final prensa =
        catalogoDeEventos.firstWhere((e) => e.clave == 'prensa_dura');
    expect(prensa.encajaEn(lider), isFalse,
        reason: 'nadie cruje a un equipo que va primero');
    expect(prensa.encajaEn(hundido), isTrue);
  });

  test('a cero partidos jugados el récord no cuenta como una temporada de '
      'cero victorias', () {
    // El mismo cuidado que hizo falta con las ofertas a entrenadores: si un
    // 0-0 se leyera como "va camino de 0 victorias", el primer día de la
    // temporada saltarían todos los eventos de equipo hundido.
    final recienEmpezado = _contexto(victorias: 0, derrotas: 0);
    expect(recienEmpezado.victoriasProyectadas, 41);
    expect(recienEmpezado.vaMal, isFalse);
    expect(recienEmpezado.vaBien, isFalse);
  });

  test('elegirEvento no repite lo ya visto y devuelve null si no queda nada',
      () {
    final contexto = _contexto();
    final rng = Random(1);

    final todas = catalogoDeEventos.map((e) => e.clave).toSet();
    expect(elegirEvento(contexto, yaVistos: todas, random: rng), isNull);

    final elegido = elegirEvento(contexto, yaVistos: {}, random: rng);
    expect(elegido, isNotNull);
    expect(
        elegirEvento(contexto, yaVistos: {elegido!.clave}, random: rng)?.clave,
        isNot(elegido.clave));
  });

  // -------------------------------------------------------------------------
  // Los efectos, ya con base de datos
  // -------------------------------------------------------------------------

  group('efectos guardados', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await importarJugadoresSiHaceFalta(db);
      await crearFranquicia(db, 'DEN');
    });

    tearDown(() => db.close());

    EventoNarrativo eventoDePrueba(List<EfectoDeEvento> efectos) =>
        EventoNarrativo(
          clave: 'prueba',
          titulo: 'Prueba',
          texto: 'Texto',
          opciones: [
            OpcionDeEvento(
                etiqueta: 'Sí', consecuencia: 'Pasa algo', efectos: efectos),
          ],
        );

    test('resolver un evento guarda sus efectos y lo apunta como visto',
        () async {
      final evento = eventoDePrueba(const [
        EfectoDeEvento(etiqueta: 'Buen rollo', factor: 1.02, partidos: 5),
        EfectoDeEvento(etiqueta: 'Cansancio', factor: 0.99, partidos: 2),
      ]);

      await resolverEvento(db, evento, evento.opciones.first);

      final activos = await leerEfectosActivos(db);
      expect(activos, hasLength(2));
      // El más fuerte primero: es lo que se enseña arriba en el menú.
      expect(activos.first.etiqueta, 'Buen rollo');

      // Y no vuelve a salir esta temporada.
      final otra = await eventoQueSalta(db,
          equipoUsuario: 'DEN', partidosSimulados: 50, random: Random(1));
      expect(otra?.clave, isNot('prueba'));
    });

    test('los efectos se multiplican entre sí: bueno y malo a la vez casi se '
        'anulan', () async {
      final evento = eventoDePrueba(const [
        EfectoDeEvento(etiqueta: 'Arriba', factor: 1.02, partidos: 5),
        EfectoDeEvento(etiqueta: 'Abajo', factor: 0.98, partidos: 5),
      ]);
      await resolverEvento(db, evento, evento.opciones.first);

      expect(await multiplicadorDeEventos(db), closeTo(1.0, 0.001));
    });

    test('por muchos efectos buenos que se acumulen, no se pasa del tope',
        () async {
      for (var i = 0; i < 6; i++) {
        await db.into(db.efectosDeEvento).insert(
            EfectosDeEventoCompanion.insert(
                clave: 'x$i',
                etiqueta: 'Bueno $i',
                factor: 1.02,
                partidosRestantes: 10));
      }
      // Sin tope serían 1,02^6 = 1,126, o sea +47 victorias de 82.
      expect(await multiplicadorDeEventos(db), maxFactorDeEvento);
    });

    test('sin efectos activos el multiplicador es exactamente 1', () async {
      expect(await multiplicadorDeEventos(db), 1.0);
    });

    test('cada partido gasta uno, y al agotarse el efecto desaparece',
        () async {
      final evento = eventoDePrueba(const [
        EfectoDeEvento(etiqueta: 'Corto', factor: 1.02, partidos: 2),
      ]);
      await resolverEvento(db, evento, evento.opciones.first);

      await gastarUnPartidoDeEfectos(db);
      expect((await leerEfectosActivos(db)).single.partidos, 1);

      await gastarUnPartidoDeEfectos(db);
      expect(await leerEfectosActivos(db), isEmpty);
      expect(await multiplicadorDeEventos(db), 1.0);

      // Y gastar de más no revienta ni deja filas fantasma.
      await gastarUnPartidoDeEfectos(db);
      expect(await leerEfectosActivos(db), isEmpty);
    });

    test('un efecto fuera de rango se acota al guardarlo, no al leerlo',
        () async {
      final evento = eventoDePrueba(const [
        EfectoDeEvento(etiqueta: 'Exagerado', factor: 1.40, partidos: 500),
      ]);
      await resolverEvento(db, evento, evento.opciones.first);

      final guardado = (await leerEfectosActivos(db)).single;
      expect(guardado.factor, maxFactorDeEvento);
      expect(guardado.partidos, maxPartidosDeEfecto);
    });

    test('sin partidos simulados no salta ningún evento', () async {
      expect(
          await eventoQueSalta(db,
              equipoUsuario: 'DEN', partidosSimulados: 0, random: Random(1)),
          isNull);
    });

    test('con el tope de la temporada agotado no salta ninguno más',
        () async {
      for (var i = 0; i < maxEventosPorTemporada; i++) {
        final evento = EventoNarrativo(
          clave: 'gastado$i',
          titulo: 'T',
          texto: 'T',
          opciones: const [
            OpcionDeEvento(etiqueta: 'Vale', consecuencia: 'Nada'),
          ],
        );
        await resolverEvento(db, evento, evento.opciones.first);
      }

      expect(
          await eventoQueSalta(db,
              equipoUsuario: 'DEN', partidosSimulados: 82, random: Random(1)),
          isNull,
          reason: 'cuatro al año ya son bastantes interrupciones');
    });

    test('el verano borra los efectos y la lista de vistos', () async {
      final evento = eventoDePrueba(const [
        EfectoDeEvento(etiqueta: 'Largo', factor: 1.02, partidos: 12),
      ]);
      await resolverEvento(db, evento, evento.opciones.first);

      await limpiarEventosDeLaTemporada(db);

      expect(await leerEfectosActivos(db), isEmpty);
      // Y el evento vuelve a estar disponible el año siguiente.
      final contexto = await contextoDe(db, 'DEN');
      expect(elegirEvento(contexto, yaVistos: {}, random: Random(2)), isNotNull);
    });

    test('el contexto sale de la partida de verdad', () async {
      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals('DEN')))
          .write(const ResultadoTemporadaCompanion(
              victorias: Value(10), derrotas: Value(30)));

      final contexto = await contextoDe(db, 'DEN');
      expect(contexto.victorias, 10);
      expect(contexto.partidosJugados, 40);
      expect(contexto.vaMal, isTrue);
      expect(contexto.mediaDelEquipo, greaterThan(0));
    });
  });
}
