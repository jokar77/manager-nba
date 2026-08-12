import 'dart:math' as math;

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';

Future<void> _guardarRotacionAutomatica(AppDatabase db, String equipo) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo))
        ..orderBy([(t) => OrderingTerm.desc(t.media)]))
      .get();

  final usados = <int>{};
  final filas = <RotacionJugadorCompanion>[];
  for (final posicion in posicionesEquipo) {
    final titular = plantilla.firstWhere(
      (j) => j.posicion == posicion && !usados.contains(j.id),
      orElse: () => plantilla.firstWhere((j) => !usados.contains(j.id)),
    );
    usados.add(titular.id);
    final suplente = plantilla.firstWhere((j) => !usados.contains(j.id));
    usados.add(suplente.id);

    filas.add(RotacionJugadorCompanion.insert(
      posicion: posicion,
      esTitular: true,
      jugadorId: titular.id,
      minutos: 32,
    ));
    filas.add(RotacionJugadorCompanion.insert(
      posicion: posicion,
      esTitular: false,
      jugadorId: suplente.id,
      minutos: 16,
    ));
  }
  await guardarRotacion(db, filas);
}

Future<void> _simularTemporadaCompleta(AppDatabase db, String equipo) async {
  final partidos = await leerPartidos(db, equipo);
  final diaObjetivo = partidos.last.fecha;
  int? ignorar;
  while (true) {
    final tramo = await simularTramo(db, equipo, diaObjetivo,
        eventoIdAIgnorar: ignorar);
    if (tramo.eventoBloqueante == null) break;
    ignorar = tramo.eventoBloqueante!.id;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('las medias de puntos de temporada de los 582 jugadores simulables '
      'se quedan en un rango realista tras una temporada completa',
      () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await _guardarRotacionAutomatica(db, 'DEN');

    await _simularTemporadaCompleta(db, 'DEN');

    final estadisticas = await db.select(db.estadisticasTemporadaJugador).get();
    final conPartidos = estadisticas.where((e) => e.partidosJugados >= 20).toList();
    expect(conPartidos, isNotEmpty);

    final medias = conPartidos
        .map((e) => e.puntosTotales / e.partidosJugados)
        .toList();

    // Esta simulación usa aleatoriedad real (sin seed, a propósito — es una
    // temporada de verdad, no un test de una tirada exacta), así que lo que
    // se mide tiene que aguantar la variación normal entre ejecuciones.
    //
    // Antes se miraba el máximo de la liga contra un tope de 38, y eso
    // flaqueaba: el máximo de ~300 muestras es de los estadísticos más
    // inestables que hay (basta UN jugador con un año excepcional). Medido
    // en cuatro temporadas seguidas, el mejor anotador salió 33,0 / 33,4 /
    // 33,2 / 35,1, pero en una quinta se fue a 38,5 y tumbaba la suite sin
    // que nada hubiera cambiado en el motor.
    //
    // Se comprueban dos cosas distintas, cada una con el margen que le
    // toca: la media del top 5 (muy estable: 30,2-31,2 en esas mismas
    // cuatro tiradas) para vigilar el nivel general de anotación, y un
    // techo duro y generoso para el máximo, que es lo que de verdad
    // detectaría una regresión — sin los ajustes de pesos_atributos.dart
    // esto daba máximos de 45-56, y con el escalado por minutos crudo,
    // 36-43.
    final ordenadas = [...medias]..sort((a, b) => b.compareTo(a));
    final mediaDelTop5 =
        ordenadas.take(5).reduce((a, b) => a + b) / 5;
    expect(mediaDelTop5, lessThan(34),
        reason: 'los mejores anotadores de la liga se han disparado: '
            '${ordenadas.take(5).map((m) => m.toStringAsFixed(1)).toList()}');
    expect(ordenadas.first, lessThan(42),
        reason: 'nadie promedia eso en una temporada de la NBA');

    final porEncimaDe30 = medias.where((m) => m > 30).length;
    // El dataset real ya trae ~17 jugadores con pts_pg >= 25, así que
    // algunos superando 30 en la simulación es normal — lo que no lo era
    // es que fuesen ~20 de los cuales varios rondando los 40-45.
    expect(porEncimaDe30 / medias.length, lessThan(0.05));

    await db.close();
  });

  test('los récords de la liga se reparten como en la NBA: el mejor no gana '
      'el 93% de sus partidos ni el peor el 6%', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await _guardarRotacionAutomatica(db, 'DEN');

    await _simularTemporadaCompleta(db, 'DEN');

    final partidos = (await db.select(db.partidosCalendario).get())
        .where((p) => p.jugado && p.fase == 'regular')
        .toList();

    final victorias = <String, int>{};
    final jugados = <String, int>{};
    final margenes = <double>[];
    for (final p in partidos) {
      final propio = p.marcadorPropietario!, rival = p.marcadorRival!;
      jugados[p.equipoPropietario] = (jugados[p.equipoPropietario] ?? 0) + 1;
      if (propio > rival) {
        victorias[p.equipoPropietario] =
            (victorias[p.equipoPropietario] ?? 0) + 1;
      }
      // Solo los locales: cada partido está guardado dos veces (una fila por
      // equipo), y contarlo dos veces duplicaría la muestra con el mismo
      // margen cambiado de signo.
      if (p.esLocal) margenes.add((propio - rival).toDouble());
    }
    expect(jugados.length, 30);

    final porcentajes = jugados.keys
        .map((e) => (victorias[e] ?? 0) / jugados[e]!)
        .toList()
      ..sort();

    double desviacion(List<double> xs) {
      final media = xs.reduce((a, b) => a + b) / xs.length;
      final suma =
          xs.fold<double>(0, (a, x) => a + (x - media) * (x - media));
      return math.sqrt(suma / xs.length);
    }

    // Igual que el test de arriba, esto simula una temporada con
    // aleatoriedad real, así que los márgenes son anchos a propósito. Lo que
    // vigilan es una regresión de balance, no una tirada concreta.
    //
    // El caso que lo motiva: OKC terminaba 39-43 la primera temporada
    // mientras otros hacían 76-6 y 5-77. La causa era que la ventaja de
    // rating de un equipo se traducía en marcador casi sin comprimir (ver
    // PesosAtributos.sensibilidadAlRating) y que el único ruido que separaba
    // a los dos equipos era pequeño (sigmaRuidoMarcador): un equipo algo
    // mejor ganaba el 93% de las noches en vez del 75%.
    //
    // QUIÉN VIGILA QUÉ, y por qué está repartido así. Medido sobre 28
    // temporadas (14 seguidas en una sola ejecución + 14 ejecuciones
    // independientes del test):
    //
    //   dispersión del % de victorias .. 0,130 - 0,168   (la mala: 0,237)
    //   desviación del margen .......... 12,6 - 13,3 pts
    //   mejor equipo ................... 0,744 - 0,842   (la mala: 0,927)
    //   peor equipo .................... 0,085 - 0,293   (la mala: 0,061)
    //
    // Fíjate en la última línea: la cola sana del PEOR equipo llega a 0,085
    // y el desastre que hay que cazar estaba en 0,061. Se solapan casi. Por
    // eso el récord de un equipo suelto no puede ser el guardián: es el
    // estadístico más inestable de los cuatro (basta que a una plantilla le
    // toque un mal estado de forma) y cualquier umbral que distinga de
    // verdad los dos casos falla por azar. El límite anterior estaba en
    // 0,10 —o sea, saltaba con 8 victorias, que es una temporada
    // perfectamente creíble— y tumbaba la publicación 2 de cada 14 veces
    // sin que nada estuviera roto.
    //
    // El trabajo fino lo hace la DISPERSIÓN, que promedia los 30 equipos y
    // por eso apenas se mueve (±0,019 en 28 temporadas) mientras que la mala
    // se va a 0,237: margen de sobra por los dos lados. Los récords
    // individuales se quedan como lo que pueden ser sin mentir, un control
    // de disparates.
    final mejor = porcentajes.last;
    final peor = porcentajes.first;
    expect(mejor, lessThan(0.92),
        reason: 'el mejor equipo gana ${(mejor * 100).round()}% de sus '
            'partidos; ni los 72-10 de Chicago llegaron al 88%');
    expect(mejor, greaterThan(0.58),
        reason: 'sin un equipo dominante la liga se ha vuelto un sorteo');
    expect(peor, greaterThan(0.04),
        reason: 'el peor equipo gana ${(peor * 100).round()}%: eso ya no es '
            'una mala temporada, es que la liga está rota');
    expect(peor, lessThan(0.42));

    final dispersion = desviacion(porcentajes);
    expect(dispersion, inInclusiveRange(0.09, 0.21),
        reason: 'la desviación del % de victorias es '
            '${dispersion.toStringAsFixed(3)} y la NBA real ronda 0,145');

    // Cualquiera puede ganar cualquier noche: la diferencia de un partido
    // suelto tiene que dispersarse como en la NBA (~13,5 puntos).
    expect(desviacion(margenes), inInclusiveRange(10.5, 16.5),
        reason: 'la diferencia por partido se dispersa '
            '${desviacion(margenes).toStringAsFixed(1)} puntos');

    await db.close();
  });
}
