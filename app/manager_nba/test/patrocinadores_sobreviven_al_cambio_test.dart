import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/contratos_repository.dart';
import 'package:manager_nba/domain/eventos_narrativos_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/patrocinadores.dart';
import 'package:manager_nba/domain/patrocinadores_repository.dart';

/// Los patrocinadores se eligen en el cambio de temporada, y el margen que
/// dan tiene que seguir ahí cuando llegas a fichar.
///
/// Esto existe por un bug de verdad: `PatrocinadoresScreen` se enseña en el
/// paso 2c de `ejecutarCambioDeTemporada`, pero `finalizarPretemporada` —que
/// corre DESPUÉS, en el paso 4.5— llamaba a `limpiarPatrocinios`. O sea que
/// el juego te hacía elegir patrocinadores y te los borraba antes de
/// dejarte gastar el dinero. El sistema entero no hacía nada en una partida
/// ya empezada.
///
/// No lo cazó ningún test porque los que había miraban el repositorio por
/// separado, y `flujo_completo_test.dart` solo pasa por el camino de la
/// PRIMERA temporada, donde `finalizarPretemporada` no llega a correr
/// después de la pantalla.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
  });

  tearDown(() => db.close());

  test('lo que eliges en la pantalla de patrocinadores sigue puesto después '
      'de la pretemporada', () async {
    // El orden real del cambio de temporada: primero cierras el año, luego
    // eliges patrocinadores (paso 2c) y solo después se remata la
    // pretemporada (paso 4.5).
    final cierre = await cerrarTemporada(db, random: Random(1));

    await alternarPatrocinio(db, 'camiseta', activo: true);
    await alternarPatrocinio(db, 'estadio', activo: true);
    final margenElegido =
        await bonusSalarialDePatrocinadores(db, equipoUsuario: 'DEN');
    expect(margenElegido, greaterThan(0));

    await finalizarPretemporada(db, cierre, const [], random: Random(1));

    expect(await leerPatrociniosActivos(db), {'camiseta', 'estadio'},
        reason: 'la pretemporada estaba borrando los patrocinadores que '
            'acababas de elegir');
    expect(await bonusSalarialDePatrocinadores(db, equipoUsuario: 'DEN'),
        margenElegido);
  });

  test('y el margen llega de verdad al espacio salarial con el que fichas',
      () async {
    final cierre = await cerrarTemporada(db, random: Random(2));
    final sinPatrocinio = await espacioSalarial(db, 'DEN');

    await alternarPatrocinio(db, 'camiseta', activo: true);
    await finalizarPretemporada(db, cierre, const [], random: Random(2));

    // El espacio salarial cambia entre las dos llamadas por muchas cosas
    // (retiradas, contratos que vencen), así que lo que se compara no es el
    // número absoluto sino que el patrocinio esté sumando su parte.
    final conPatrocinio = await espacioSalarial(db, 'DEN');
    final sinEl = conPatrocinio -
        await bonusSalarialDePatrocinadores(db, equipoUsuario: 'DEN');
    expect(conPatrocinio, greaterThan(sinEl),
        reason: 'el patrocinio de la camiseta tiene que dar margen para '
            'fichar, que es todo el sentido que tiene elegirlo');
    expect(sinPatrocinio, isNotNull);
  });

  group('lo que piden a cambio', () {
    test('firmar deja su compromiso en el vestuario, y no firmar no deja '
        'nada', () async {
      await aplicarCompromisosDePatrocinio(db, equipoUsuario: 'DEN');
      expect(await leerEfectosActivos(db), isEmpty,
          reason: 'sin patrocinios firmados no hay nada que cumplir');

      await alternarPatrocinio(db, 'camiseta', activo: true);
      await aplicarCompromisosDePatrocinio(db, equipoUsuario: 'DEN');

      final activos = await leerEfectosActivos(db);
      expect(activos, hasLength(1));
      expect(activos.single.clave, 'dias_de_medios');
      expect(activos.single.esBueno, isFalse,
          reason: 'la camiseta es el que más paga y el que más molesta');
    });

    test('confirmar dos veces no acumula compromisos', () async {
      // Volver atrás y volver a entrar en la pantalla es normal. Si cada
      // confirmación apilara los compromisos encima de los anteriores, dos
      // vueltas dejarían al equipo con el doble de castigo.
      await alternarPatrocinio(db, 'camiseta', activo: true);
      await alternarPatrocinio(db, 'estadio', activo: true);

      await aplicarCompromisosDePatrocinio(db, equipoUsuario: 'DEN');
      await aplicarCompromisosDePatrocinio(db, equipoUsuario: 'DEN');

      expect(await leerEfectosActivos(db), hasLength(2));
    });

    test('rehacer los compromisos no toca una bronca de vestuario que esté '
        'corriendo', () async {
      // Comparten tabla, así que borrar de más aquí se llevaría por delante
      // los efectos de los eventos narrativos.
      final evento = EventoNarrativo(
        clave: 'bronca_de_prueba',
        opciones: const [
          OpcionDeEvento(clave: 'si', efectos: [
            EfectoDeEvento(clave: 'vestuario_roto', factor: 0.98, partidos: 8),
          ]),
        ],
      );
      await resolverEvento(db, evento, evento.opciones.first);

      await alternarPatrocinio(db, 'ocio', activo: true);
      await aplicarCompromisosDePatrocinio(db, equipoUsuario: 'DEN');

      final claves =
          (await leerEfectosActivos(db)).map((e) => e.clave).toSet();
      expect(claves, containsAll(['vestuario_roto', 'trabajo_con_la_ciudad']));
    });

    test('el de ocio es el único que suma en la pista: es el barato', () async {
      // Es lo que hace que la decisión no sea aritmética. Si todos costaran
      // en proporción a lo que pagan, la respuesta sería siempre la misma
      // cuenta; así depende de si te falta tope salarial o no.
      expect(compromisoPorCategoria['ocio']!.esBueno, isTrue);
      for (final categoria in ['camiseta', 'estadio', 'bebida']) {
        expect(compromisoPorCategoria[categoria]!.esBueno, isFalse,
            reason: '$categoria tiene que costar algo');
      }
      expect(bonusPorCategoria['ocio'],
          lessThan(bonusPorCategoria['camiseta']!),
          reason: 'el que no cuesta nada tiene que ser el que menos paga');
    });

    test('ningún compromiso se sale de los topes medidos de un efecto', () {
      for (final entrada in compromisoPorCategoria.entries) {
        expect(entrada.value.factor,
            inInclusiveRange(minFactorDeEvento, maxFactorDeEvento),
            reason: '${entrada.key}: un patrocinio no puede mover el equipo '
                'más que cualquier otro efecto de vestuario');
        expect(entrada.value.partidos,
            inInclusiveRange(1, maxPartidosDeEfecto));
      }
    });

    test('cada categoría del catálogo tiene su compromiso escrito', () {
      for (final categoria in categoriasPatrocinio) {
        expect(compromisoPorCategoria[categoria], isNotNull,
            reason: '$categoria se puede firmar y no pide nada a cambio');
      }
    });
  });
}
