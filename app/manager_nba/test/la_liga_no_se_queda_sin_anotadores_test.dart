import 'dart:math';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/curva_estadisticas.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

/// Cierra la temporada sin jugar los partidos: lo que se vigila aquí es el
/// techo de talento, que lo decide el verano (progresión, retiradas y
/// draft), no la simulación — y quince veranos de verdad serían minutos.
Future<void> _cerrarDeGolpe(AppDatabase db, Random rng) async {
  for (final e in await db.select(db.resultadoTemporada).get()) {
    await (db.update(db.resultadoTemporada)
          ..where((t) => t.equipo.equals(e.equipo)))
        .write(ResultadoTemporadaCompanion(
      victorias: Value(20 + rng.nextInt(43)),
      derrotas: Value(20 + rng.nextInt(43)),
    ));
  }
  await sembrarPlayoffs(db);
  await simularPlayoffsCompletos(db);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('la curva de estadísticas', () {
    test('es convexa: el salto de 77 a 87 pesa mucho más que el de 92 a 99',
        () {
      final subeEnMedio = puntosTipicos(87) - puntosTipicos(77);
      final subeArriba = puntosTipicos(99) - puntosTipicos(92);
      // Con los datos reales la razón es 2,7 (11,8 contra 4,3). El listón
      // va en 2 porque lo que tiene que detectar es que esto vuelva a ser
      // una RECTA: con la fórmula vieja, `(media-48)*0.34`, los dos tramos
      // salían 3,4 y 2,4, o sea una razón de 1,4.
      expect(subeEnMedio, greaterThan(2 * subeArriba),
          reason: 'si esto se aplana, la curva se ha vuelto una recta y '
              'volvemos al bug: 77->87 sube $subeEnMedio y 92->99 '
              '$subeArriba');
      // Y los números salen del dataset real, no de la nada.
      expect(puntosTipicos(77), closeTo(7.8, 0.1));
      expect(puntosTipicos(87), closeTo(19.6, 0.1));
    });

    test('un jugador que no cambia de media conserva sus números exactos',
        () {
      // Es la propiedad que hace que mover a alguien por la curva no le
      // borre la personalidad: sin cambio de nivel, no hay cambio de nada.
      for (final pts in [4.0, 12.5, 22.0, 28.0]) {
        for (final media in [70, 80, 90]) {
          final estilo = estiloRespectoASuNivel(pts, puntosTipicos(media));
          final recalculado = puntosTipicos(media) * estilo;
          // Solo cuadra si el estilo no estaba fuera de los topes, que es
          // justo lo que se quiere: dentro del rango normal, identidad.
          if (estilo > 0.4 && estilo < 1.5) {
            expect(recalculado, closeTo(pts, 0.01),
                reason: '$pts puntos con media $media');
          }
        }
      }
    });

    test('un base reparte más que un pívot del mismo nivel, y al revés con '
        'los rebotes', () {
      expect(asistenciasTipicas(88, 'PG'),
          greaterThan(asistenciasTipicas(88, 'C') * 2));
      expect(rebotesTipicos(88, 'C'), greaterThan(rebotesTipicos(88, 'PG')));
    });
  });

  /// El bug: la liga se quedaba sin anotadores mientras seguía llena de
  /// medias altas.
  ///
  /// Medido sobre 15 veranos con el código viejo, el mejor anotador de la
  /// liga caía de 33,5 puntos a **21,4** y los jugadores de 25+ pasaban de
  /// 16 a **cero** — con 26 medias de 90 o más todavía en activo.
  /// Superestrellas anotando como suplentes.
  ///
  /// Dos causas, las dos por tratar como recta algo que es una curva: los
  /// prospectos del draft nacían de `(media - 48) * 0.34` topado en 18
  /// puntos, y al envejecer se escalaba `ptsPg` por `nuevaMedia/mediaVieja`.
  /// Un rookie de 65 con 5,8 puntos que llegaba a 95 acababa con 8,5.
  test('tras quince veranos la liga sigue teniendo anotadores de verdad',
      () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');

    final rng = Random(20260805);
    for (var t = 1; t <= 15; t++) {
      await _cerrarDeGolpe(db, rng);
      await empezarNuevaTemporada(db, random: rng);
    }

    final enEquipos = (await db.select(db.jugadores).get())
        .where((j) => !j.retirado && esFranquicia(j.equipo))
        .toList();
    final pts = enEquipos.map((j) => j.ptsPg).toList()
      ..sort((a, b) => b.compareTo(a));
    final medias = enEquipos.map((j) => j.media).toList()
      ..sort((a, b) => b.compareTo(a));

    // Sigue habiendo un anotador de referencia. Con el código viejo: 21,4.
    expect(pts.first, greaterThan(26.0),
        reason: 'el mejor anotador de la liga promedia '
            '${pts.first.toStringAsFixed(1)} puntos tras 15 veranos');

    // Y no es uno suelto: hay un grupo de anotadores. Antes: cero.
    final anotadores = pts.where((p) => p > 25).length;
    expect(anotadores, greaterThanOrEqualTo(6),
        reason: 'solo $anotadores jugadores por encima de 25 puntos');

    // El otro lado: la curva y el estilo se multiplican, así que hay que
    // vigilar que el producto no se dispare. Con el primer tope de estilo
    // que se probó (2,0) salió un jugador de 43,7 puntos.
    expect(pts.first, lessThanOrEqualTo(maxPuntosPorPartido),
        reason: 'nadie promedia ${pts.first.toStringAsFixed(1)} puntos');

    // Y que esto siga siendo coherente con las medias: si hay estrellas,
    // tienen que anotar como estrellas.
    expect(medias.where((m) => m >= 90).length, greaterThan(5),
        reason: 'la liga se ha quedado sin jugadores de élite');

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 10)));
}
