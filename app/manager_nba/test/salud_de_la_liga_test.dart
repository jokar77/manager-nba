import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/agencia_libre_repository.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

/// La liga tiene que seguir siendo una liga después de varios años: sin
/// estrellas apiladas en la agencia libre y sin equipos vacíos.
///
/// Nace de un caso real: simulando la segunda temporada con Cleveland salía
/// un 2-80. Midiendo la liga se vio que cada verano caían jugadores al
/// mercado y NADIE los volvía a fichar (115 → 173 → 218 agentes libres, de
/// ellos 15 → 28 → 35 con media 80+), porque `completarPlantillaConElMinimo`
/// solo se llamaba para el equipo del usuario y solo cubría mínimos.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tras varios cambios de temporada no se apilan estrellas sin equipo',
      () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'CLE');

    final rng = Random(7);
    for (var t = 1; t <= 3; t++) {
      await empezarNuevaTemporada(db, random: rng);
    }

    final activos = (await db.select(db.jugadores).get())
        .where((j) => !j.retirado)
        .toList();
    final libres =
        activos.where((j) => j.equipo == equipoAgenciaLibre).toList();

    // Un jugador de este nivel no pasa un año entero sin equipo.
    final estrellasLibres = libres.where((j) => j.media >= 85).length;
    expect(estrellasLibres, lessThanOrEqualTo(3),
        reason: '$estrellasLibres jugadores de 85+ sin equipo: el mercado '
            'de la CPU no está funcionando');

    // Y ningún equipo se queda sin plantilla viable.
    final porEquipo = <String, int>{};
    for (final j in activos) {
      if (!esFranquicia(j.equipo)) continue;
      porEquipo[j.equipo] = (porEquipo[j.equipo] ?? 0) + 1;
    }
    expect(porEquipo.length, 30);
    for (final entrada in porEquipo.entries) {
      expect(entrada.value, greaterThanOrEqualTo(10),
          reason: '${entrada.key} se ha quedado con ${entrada.value}');
    }

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 5)));

  /// El otro lado del mismo problema: no que se apilaran estrellas, sino que
  /// se apilara *todo el mundo*. Cada draft mete 60 jugadores nuevos y las
  /// 30 plantillas están capadas, así que el excedente caía en la agencia
  /// libre y no salía nunca (98 → 153 → 205 → 257 agentes libres en cuatro
  /// veranos, +52 al año y sin techo). Ver `depurarAgenciaLibre`.
  test('la agencia libre no crece sin freno temporada tras temporada',
      () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'CLE');

    final rng = Random(7);
    final porTemporada = <int>[];
    for (var t = 1; t <= 5; t++) {
      await empezarNuevaTemporada(db, random: rng);
      porTemporada.add((await agentesLibres(db)).length);
    }

    for (final libres in porTemporada) {
      expect(libres, lessThanOrEqualTo(maxAgentesLibres),
          reason: 'la agencia libre se ha pasado del cupo: $porTemporada');
    }

    // Y sigue habiendo mercado de verdad: el cupo poda la cola, no vacía la
    // agencia libre (los equipos tiran de ella para completar plantillas).
    expect(porTemporada.last, greaterThanOrEqualTo(20),
        reason: 'la agencia libre se ha quedado seca: $porTemporada');

    // Nadie se queda sin equipo por viejo: quien no encuentra mercado a esa
    // edad se retira en vez de acumularse en la lista.
    final veteranosLibres =
        (await agentesLibres(db)).where((j) => j.edad >= 32).toList();
    expect(veteranosLibres, isEmpty,
        reason: '${veteranosLibres.length} agentes libres de 32+ años');

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 5)));

  /// Una clase de draft se deshace poco a poco, no de golpe: los 60 elegidos
  /// cumplen su contrato de rookie y la criba llega al vencer.
  ///
  /// Antes no era así por dos motivos que se tapaban entre ellos. Los
  /// drafteados salían con los valores por defecto de la tabla —salario 0 y
  /// contrato de UN año—, o sea sin contrato de rookie; y
  /// `_cortarParaHacerSitio` elegía a quién soltar por media a secas, que el
  /// día del draft es siempre el recién llegado. Trazando un verano entero,
  /// de los 60 elegidos salían 23 a la agencia libre sin haber jugado un
  /// partido.
  test('la clase de draft aguanta su contrato de rookie antes de cribarse',
      () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'CLE');

    final rng = Random(7);
    for (var t = 1; t <= 6; t++) {
      await empezarNuevaTemporada(db, random: rng);
    }

    final anioActual = (await leerTemporada(db)).anioInicio;
    final todos = await db.select(db.jugadores).get();
    List<Jugador> claseDe(int anio) =>
        todos.where((j) => j.draftYear == anio).toList();

    // La hornada que acaba de entrar se queda prácticamente entera: a quien
    // acabas de elegir no lo sueltas antes de verlo jugar.
    //
    // No es un veto absoluto y no puede serlo: si un equipo no tiene a nadie
    // más que soltar sin dejar un puesto sin recambio, se corta igualmente a
    // un rookie antes que dejar a una estrella sin equipo. Medido en 10
    // temporadas con tres semillas distintas, el primer verano se caen entre
    // 0 y 5 de cada 60; antes de respetar los contratos eran 22-23 fijos.
    final reciente = claseDe(anioActual);
    expect(reciente, isNotEmpty);
    final sinEquipo =
        reciente.where((j) => j.retirado || !esFranquicia(j.equipo)).toList();
    expect(sinEquipo.length, lessThanOrEqualTo(reciente.length ~/ 6),
        reason: '${sinEquipo.length} de ${reciente.length} recién drafteados '
            'ya están fuera de una plantilla el mismo verano que llegan');

    // Y a partir de ahí sí se criba, pero sin vaciarse: las clases con unos
    // años encima conservan a la mayoría en la liga.
    //
    // Lo que se vigila es el suelo. El techo estaba en 0,95 y flaqueaba sin
    // que nada hubiera cambiado: esta simulación va sin semilla, y con 60
    // jugadores por clase basta que sobrevivan 58 en vez de 57 para pasar
    // de 0,95 a 0,967. Que una clase joven se conserve casi entera no es un
    // fallo —son chavales de 22 años con contrato—, así que el tope se sube
    // a 1: la criba de verdad se ve en las clases con más años encima, y de
    // eso se encarga el suelo.
    for (var anio = anioActual - 4; anio < anioActual; anio++) {
      final clase = claseDe(anio);
      if (clase.isEmpty) continue;
      final siguen = clase.where((j) => !j.retirado).length / clase.length;
      expect(siguen, inInclusiveRange(0.45, 1.0),
          reason: 'la clase de $anio conserva el '
              '${(siguen * 100).round()}% de sus ${clase.length} elegidos');
    }

    await db.close();
  }, timeout: const Timeout(Duration(minutes: 5)));
}
