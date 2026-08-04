import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/conferencias.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/resumen_temporada_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await guardarRotacion(
        db,
        generarRotacionAutomatica(await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals('DEN')))
            .get()));
  });

  tearDown(() async => db.close());

  /// Simula los dos primeros meses: suficiente para tener partidos de sobra
  /// sin pagar los 11 segundos de una temporada entera.
  Future<void> simularUnTramo() async {
    final partidos = await leerPartidos(db, 'DEN');
    await simularTramo(
        db, 'DEN', partidos.first.fecha.add(const Duration(days: 60)));
  }

  /// Al cerrar la temporada, la pestaña del medio enseña la clasificación de
  /// los 30 equipos y no la lista de tus 82 partidos: esa lista no contaba
  /// nada que no hubieras visto ya según se jugaban.
  test('el resumen trae la clasificación entera, ordenada y con tu equipo '
      'dentro', () async {
    await simularUnTramo();
    final resumen = await leerResumenDeTemporada(db, 'DEN');

    expect(resumen.clasificacion, hasLength(30));

    // Ordenada de mejor a peor porcentaje, sin saltos.
    for (var i = 1; i < resumen.clasificacion.length; i++) {
      expect(resumen.clasificacion[i - 1].porcentaje,
          greaterThanOrEqualTo(resumen.clasificacion[i].porcentaje),
          reason: 'la clasificación no está ordenada en la posición $i');
    }

    // Quince por conferencia, y cada fila cuadra con lo jugado.
    for (final conferencia in ['Este', 'Oeste']) {
      expect(
          resumen.clasificacion
              .where((e) => e.conferencia == conferencia)
              .length,
          15,
          reason: 'la conferencia $conferencia no tiene 15 equipos');
    }

    final tuya =
        resumen.clasificacion.firstWhere((e) => e.equipo == 'DEN');
    expect(tuya.victorias, resumen.victorias);
    expect(tuya.derrotas, resumen.derrotas);

    // Y el puesto que se enseña arriba es coherente con la tabla.
    final deTuConferencia = resumen.clasificacion
        .where((e) => e.conferencia == resumen.conferencia)
        .toList();
    expect(deTuConferencia.indexWhere((e) => e.equipo == 'DEN') + 1,
        resumen.puestoEnConferencia);
  });

  test('el resumen cuadra con lo que se ha jugado de verdad', () async {
    await simularUnTramo();
    final resumen = await leerResumenDeTemporada(db, 'DEN');

    final jugados = (await leerPartidos(db, 'DEN'))
        .where((p) => p.jugado && p.fase == 'regular')
        .toList();
    expect(jugados, isNotEmpty);

    expect(resumen.partidos.length, jugados.length);
    expect(resumen.partidosJugados, jugados.length);
    expect(resumen.victorias + resumen.derrotas, jugados.length);
    expect(resumen.victorias,
        jugados.where((p) => p.marcadorPropietario! > p.marcadorRival!).length);

    // Los promedios salen de los mismos partidos, así que tienen que caer en
    // el rango de un marcador NBA.
    expect(resumen.puntosFavorPorPartido, inInclusiveRange(85, 140));
    expect(resumen.puntosContraPorPartido, inInclusiveRange(85, 140));

    // Puesto: entre 1 y 15 en su conferencia y entre 1 y 30 en la liga.
    expect(conferenciaPorEquipo['DEN'], resumen.conferencia);
    expect(resumen.puestoEnConferencia, inInclusiveRange(1, 15));
    expect(resumen.puestoEnLaLiga, inInclusiveRange(1, 30));
  });

  test('las rachas y los extremos son coherentes con la lista de partidos',
      () async {
    await simularUnTramo();
    final resumen = await leerResumenDeTemporada(db, 'DEN');

    // Una racha no puede ser más larga que los partidos jugados, y si has
    // ganado alguno tiene que haber al menos una racha de 1.
    expect(resumen.mejorRachaGanando,
        inInclusiveRange(resumen.victorias > 0 ? 1 : 0, resumen.victorias));
    expect(resumen.peorRachaPerdiendo,
        inInclusiveRange(resumen.derrotas > 0 ? 1 : 0, resumen.derrotas));

    if (resumen.mejorVictoria != null) {
      final maxima = resumen.partidos
          .where((p) => p.ganado)
          .map((p) => p.diferencia)
          .reduce((a, b) => a > b ? a : b);
      expect(resumen.mejorVictoria!.diferencia, maxima);
    }
    if (resumen.peorDerrota != null) {
      final minima = resumen.partidos
          .where((p) => !p.ganado)
          .map((p) => p.diferencia)
          .reduce((a, b) => a < b ? a : b);
      expect(resumen.peorDerrota!.diferencia, minima);
    }
  });

  test('la tabla de jugadores es la plantilla de ahora, ordenada por puntos, '
      'y no cuela a nadie que ya no esté en el equipo', () async {
    await simularUnTramo();
    final resumen = await leerResumenDeTemporada(db, 'DEN');

    final plantilla = (await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals('DEN')))
            .get())
        .map((j) => j.id)
        .toSet();
    expect(resumen.jugadores.map((j) => j.jugadorId).toSet(), plantilla);

    final conMinutos =
        resumen.jugadores.where((j) => j.partidosJugados > 0).toList();
    expect(conMinutos.length, greaterThanOrEqualTo(10));
    for (var i = 1; i < conMinutos.length; i++) {
      expect(conMinutos[i - 1].puntos,
          greaterThanOrEqualTo(conMinutos[i].puntos));
    }
    // Y los promedios son promedios, no totales.
    expect(conMinutos.first.puntos, inInclusiveRange(5, 45));
  });

  test('sin ningún partido jugado el resumen no revienta: sale a cero',
      () async {
    final resumen = await leerResumenDeTemporada(db, 'DEN');
    expect(resumen.partidos, isEmpty);
    expect(resumen.victorias, 0);
    expect(resumen.derrotas, 0);
    expect(resumen.mejorVictoria, isNull);
    expect(resumen.peorDerrota, isNull);
    expect(resumen.puntosFavorPorPartido, 0);
    expect(resumen.jugadores, isNotEmpty);
  });
}
