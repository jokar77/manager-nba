import 'dart:math';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/premios_repository.dart';
import 'package:manager_nba/domain/tipo_premio.dart';

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

/// Simula toda la temporada de [equipo], confirmando automáticamente
/// cualquier aviso de fecha límite (igual que "seguir simulando" en la UI).
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

  test('calcularPremios asigna cada categoría sin duplicados dentro de los '
      'quintetos, tras simular una temporada completa', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await _guardarRotacionAutomatica(db, 'DEN');

    await _simularTemporadaCompleta(db, 'DEN');

    await calcularPremios(db);
    final premios = await leerPremios(db);

    expect(premios[TipoPremio.mvp]?.length, 1);
    expect(premios[TipoPremio.mejorDefensor]?.length, 1);
    expect(premios[TipoPremio.masMejorado]?.length, 1);
    expect(premios[TipoPremio.primerQuinteto]?.length, 5);
    expect(premios[TipoPremio.segundoQuinteto]?.length, 5);
    // Rookie del año es opcional (puede no haber rookies calificados).
    expect(premios[TipoPremio.rookieDelAno]?.length ?? 0, lessThanOrEqualTo(1));

    final idsQuintetos = [
      ...premios[TipoPremio.primerQuinteto]!,
      ...premios[TipoPremio.segundoQuinteto]!,
    ].map((p) => p.jugadorId).toList();
    expect(idsQuintetos.toSet().length, idsQuintetos.length);

    await db.close();
  });

  test('calcularPremios es idempotente: llamarla dos veces no acumula '
      'premios', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'BOS');
    await _guardarRotacionAutomatica(db, 'BOS');

    await _simularTemporadaCompleta(db, 'BOS');

    await calcularPremios(db);
    final primeraVez = await db.select(db.premiosTemporada).get();
    await calcularPremios(db);
    final segundaVez = await db.select(db.premiosTemporada).get();

    expect(segundaVez.length, primeraVez.length);

    await db.close();
  });

  test('un jugador joven que ya jugó una temporada no puede repetir como '
      'Rookie del Año en la siguiente, aunque siga siendo joven', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'SAS');

    // Un novato de laboratorio: 19 años, sin temporadas previas, así que
    // seguirá teniendo 20 en la temporada 2 y sería un falso positivo si el
    // cálculo siguiera usando la edad como proxy de "rookie". Con atributos
    // al máximo para que gane el premio por mérito propio y no dependa de
    // que ningún rookie real del dataset le supere.
    final novatoId = await db.into(db.jugadores).insert(JugadoresCompanion.insert(
          nombreFicticio: 'Novato De Prueba',
          nombreReal: '',
          posicion: 'SG',
          equipo: 'SAS',
          edad: 19,
          media: 99,
          potencial: 99,
          atrTiro3: 99,
          atrAtaque: 99,
          atrDefensa: 99,
          ptsPg: 30,
          astPg: 8,
          trbPg: 8,
          factorLongevidad: 1.0,
          edadRetiro: 38,
          temporadasPrevias: const Value(0),
          // Con el contrato de 1 año por defecto, `empezarNuevaTemporada`
          // (el atajo sin pantalla de renovaciones) lo mandaría directo a
          // la agencia libre al pasar de temporada.
          aniosContrato: const Value(3),
        ));

    await _guardarRotacionAutomaticaConTitular(db, 'SAS', novatoId);
    await _simularTemporadaCompleta(db, 'SAS');
    await calcularPremios(db);

    final roy1 = (await leerPremios(db))[TipoPremio.rookieDelAno];
    expect(roy1?.map((p) => p.jugadorId), contains(novatoId),
        reason: 'en su primera temporada sí es un rookie válido');

    // Se pasa a la temporada 2: esto archiva sus estadísticas en el
    // histórico, que es la señal de que ya no es rookie.
    await empezarNuevaTemporada(db, random: Random(1));
    await _guardarRotacionAutomaticaConTitular(db, 'SAS', novatoId);
    await _simularTemporadaCompleta(db, 'SAS');
    await calcularPremios(db);

    final roy2 = (await leerPremios(db))[TipoPremio.rookieDelAno];
    expect(roy2?.map((p) => p.jugadorId) ?? const [], isNot(contains(novatoId)),
        reason: 'ya jugó una temporada: no puede volver a ganar el Rookie '
            'del Año por seguir siendo joven');

    await db.close();
  });
}

/// Como [_guardarRotacionAutomatica] pero forzando a [jugadorId] como
/// titular de su puesto, para poder seguirle la pista en los premios.
Future<void> _guardarRotacionAutomaticaConTitular(
  AppDatabase db,
  String equipo,
  int jugadorId,
) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo))
        ..orderBy([(t) => OrderingTerm.desc(t.media)]))
      .get();
  final objetivo = plantilla.firstWhere((j) => j.id == jugadorId);

  final usados = <int>{objetivo.id};
  final filas = <RotacionJugadorCompanion>[
    RotacionJugadorCompanion.insert(
      posicion: objetivo.posicion,
      esTitular: true,
      jugadorId: objetivo.id,
      minutos: 34,
    ),
  ];
  for (final posicion in posicionesEquipo) {
    if (posicion == objetivo.posicion) {
      final suplente =
          plantilla.firstWhere((j) => !usados.contains(j.id));
      usados.add(suplente.id);
      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: false,
        jugadorId: suplente.id,
        minutos: 14,
      ));
      continue;
    }
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
