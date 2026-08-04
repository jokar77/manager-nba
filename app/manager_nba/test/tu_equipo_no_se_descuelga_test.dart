import 'dart:math';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

/// Cierra la temporada sin jugar los 82 partidos: récords inventados,
/// playoffs sembrados y resueltos. Lo que se mide aquí es el VERANO —
/// contratos, draft y mercado—, que es donde vivía el problema; simular los
/// partidos de verdad solo añadiría minutos de espera. La simulación ya la
/// vigilan `realismo_estadisticas_test.dart` y compañía.
Future<void> _cerrarTemporadaDeGolpe(AppDatabase db, Random rng) async {
  final equipos = await db.select(db.resultadoTemporada).get();
  for (final e in equipos) {
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

/// Media de los ocho mejores de [equipo]: la fuerza real de una plantilla,
/// que la media de los 18 diluye con el fondo del banquillo.
double _topOcho(List<Jugador> plantilla) {
  final medias = plantilla.map((j) => j.media).toList()
    ..sort((a, b) => b.compareTo(a));
  final ocho = medias.take(8);
  return ocho.reduce((a, b) => a + b) / ocho.length;
}

double _mediana(List<double> xs) {
  final ordenados = [...xs]..sort();
  return ordenados[ordenados.length ~/ 2];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Un manager que pasa de la pretemporada tiene que acabar mediocre, no
  /// aniquilado. Este test simula justo eso: cinco veranos seguidos sin que
  /// el usuario renueve a nadie ni fiche a nadie.
  ///
  /// De dónde sale. Midiendo cuatro temporadas COMPLETAS por el camino real
  /// (partidos incluidos), el equipo del usuario hacía 41-41, 35-47, 12-70 y
  /// 4-78, con la media de sus ocho mejores cayendo de 83,4 a 74,4 y su masa
  /// salarial de 237M a 54M mientras la liga se movía en 200M y subía a 87.
  /// No era mala suerte: eran dos asimetrías del verano, las dos silenciosas.
  ///
  /// 1. Su plantilla se quedaba clavada en `plantillaMinima` (13) porque era
  ///    el único objetivo que existía para ella, mientras las 29 de la CPU
  ///    acababan en `plantillaMaxima` (18).
  /// 2. `colocarAgentesLibresDeNivel` —el reequilibrio que convierte espacio
  ///    salarial en jugadores cada verano— excluía a su equipo SIEMPRE, no
  ///    solo durante su ventana de mercado. Con 150M sin gastar no se le
  ///    ofrecía a nadie nunca, así que un año malo no tenía suelo.
  ///
  /// Lo que se vigila es el enganche con la liga, no un récord concreto: que
  /// tu equipo tenga el mismo tamaño de plantilla que los demás y que su
  /// nivel no se despeñe respecto a la mediana. Los márgenes son anchos a
  /// propósito —quedarse por debajo de la mediana es una consecuencia
  /// legítima de no jugar el mercado—; lo que no puede pasar es descolgarse
  /// sin fondo.
  test('cinco veranos sin tocar nada dejan tu equipo mediocre, no hundido',
      () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');

    final rng = Random(20260804);
    final huecosPorTemporada = <double>[];

    for (var t = 1; t <= 5; t++) {
      await _cerrarTemporadaDeGolpe(db, rng);
      await empezarNuevaTemporada(db, random: rng);

      final activos = (await db.select(db.jugadores).get())
          .where((j) => !j.retirado && esFranquicia(j.equipo))
          .toList();
      final porEquipo = <String, List<Jugador>>{};
      for (final j in activos) {
        porEquipo.putIfAbsent(j.equipo, () => []).add(j);
      }

      final tuya = porEquipo['DEN']!;

      // 1. Mismo tamaño de plantilla que la liga. Antes: 13 contra 18 fijo.
      final tamanoTipico =
          _mediana(porEquipo.values.map((p) => p.length.toDouble()).toList());
      expect(tuya.length, greaterThanOrEqualTo(tamanoTipico.round()),
          reason: 'verano $t: tienes ${tuya.length} jugadores y la liga '
              'juega con ${tamanoTipico.round()}');

      // 2. El nivel no se descuelga. Antes esta diferencia crecía sin techo
      //    verano tras verano (llegó a 11 puntos de media).
      final tuTop8 = _topOcho(tuya);
      final medianaTop8 =
          _mediana(porEquipo.values.map(_topOcho).toList());
      huecosPorTemporada.add(medianaTop8 - tuTop8);
      expect(medianaTop8 - tuTop8, lessThan(5.0),
          reason: 'verano $t: tu top-8 es ${tuTop8.toStringAsFixed(1)} y la '
              'mediana de la liga ${medianaTop8.toStringAsFixed(1)}; huecos '
              'por temporada: '
              '${huecosPorTemporada.map((h) => h.toStringAsFixed(1)).toList()}');

      // 3. Y el hueco no crece sin freno: lo que mataba la partida no era
      //    estar por debajo, era que cada verano se estuviera más abajo.
      if (huecosPorTemporada.length >= 3) {
        final ultimo = huecosPorTemporada.last;
        final primero = huecosPorTemporada.first;
        expect(ultimo - primero, lessThan(4.0),
            reason: 'el hueco con la liga crece sin suelo: '
                '${huecosPorTemporada.map((h) => h.toStringAsFixed(1)).toList()}');
      }
    }

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 10)));

  /// El otro lado del mismo arreglo: que tu oficina te tape agujeros no
  /// puede convertirse en que te fiche las estrellas. Si no jugar el mercado
  /// saliera igual de bien que jugarlo, el mercado sobraría.
  test('el reparto automático no te firma estrellas: esas las fichas tú',
      () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');

    final rng = Random(11);
    final idsAlEmpezar = (await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals('DEN')))
            .get())
        .map((j) => j.id)
        .toSet();

    for (var t = 1; t <= 3; t++) {
      await _cerrarTemporadaDeGolpe(db, rng);
      await empezarNuevaTemporada(db, random: rng);
    }

    // De todo lo que ha llegado solo por el reparto automático (el usuario
    // no ha firmado a nadie), nadie puede ser una estrella. El draft sí
    // puede darte un jugadorazo, así que los rookies quedan fuera: eso es
    // una elección tuya en la pantalla del draft.
    final temporada = await leerTemporada(db);
    final llegados = (await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals('DEN')))
            .get())
        .where((j) => !idsAlEmpezar.contains(j.id))
        .where((j) => j.draftYear == null || j.draftYear! < temporada.anioInicio)
        .toList();

    final estrellas = llegados.where((j) => j.media >= 85).toList();
    expect(estrellas, isEmpty,
        reason: 'tu oficina te ha fichado sola a '
            '${estrellas.map((j) => '${j.nombreFicticio} (${j.media})').join(', ')}');

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 10)));
}
