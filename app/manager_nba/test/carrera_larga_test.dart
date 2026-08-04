import 'dart:math';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/draft_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/posiciones.dart';
import 'package:manager_nba/domain/progresion_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

/// Termina la temporada en curso sin simular los 82 partidos: se rellenan
/// récords ficticios, se siembran los playoffs y se resuelven. Simular 25
/// temporadas completas de verdad tardaría minutos; lo que este test tiene
/// que comprobar es el cambio de año, no la simulación de partidos (que ya
/// cubren otros tests).
Future<void> _cerrarTemporadaDeGolpe(AppDatabase db, Random rng) async {
  final equipos = await db.select(db.resultadoTemporada).get();
  for (var i = 0; i < equipos.length; i++) {
    await (db.update(db.resultadoTemporada)
          ..where((t) => t.equipo.equals(equipos[i].equipo)))
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

  late AppDatabase db;
  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');

    // Cada campeón de la NBA se apunta también en el registro compartido
    // entre partidas (ver campeones_repository.dart), que en un test se
    // sustituye por uno en memoria para no depender de `path_provider`.
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
  });

  tearDown(() async {
    await db.close();
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  test('25 temporadas seguidas: la liga sigue siendo jugable — 30 equipos '
      'con plantillas dentro de límites, edades coherentes y nadie '
      'duplicado', () async {
    final rng = Random(20260731);

    for (var temporada = 1; temporada <= 25; temporada++) {
      await _cerrarTemporadaDeGolpe(db, rng);
      expect(await sePuedeEmpezarNuevaTemporada(db), isTrue,
          reason: 'la temporada $temporada debería poder cerrarse');
      await empezarNuevaTemporada(db, random: rng);
    }

    final estado = await leerTemporada(db);
    expect(estado.numero, 26);

    final activos = await (db.select(db.jugadores)
          ..where((t) => t.retirado.equals(false)))
        .get();
    final porEquipo = <String, List<Jugador>>{};
    for (final j in activos) {
      if (j.equipo == 'FA' || j.equipo == equipoRetirados) continue;
      porEquipo.putIfAbsent(j.equipo, () => []).add(j);
    }

    expect(porEquipo.length, 30, reason: 'siguen siendo 30 equipos');
    for (final entry in porEquipo.entries) {
      expect(entry.value.length,
          inInclusiveRange(plantillaMinima, plantillaMaxima),
          reason: '${entry.key} tiene ${entry.value.length} jugadores');

      // Cada equipo tiene que poder cubrir los 5 puestos con dos jugadores
      // cómodos: si no, la alineación automática se rompería.
      for (final puesto in posicionesEquipo) {
        expect(entry.value.where((j) => juegaComodoDe(j, puesto)).length,
            greaterThanOrEqualTo(2),
            reason: '${entry.key} no puede cubrir $puesto');
      }
    }

    // Nadie sigue en activo pasado de su edad de retiro salvo que siga
    // siendo de los mejores de la liga (ver mediaQueAguantaElRetiro: nadie
    // cuelga las botas con media 92 solo porque el calendario diga que ya
    // toca), y ni así por encima del tope duro. Las medias, en rango.
    for (final j in activos) {
      if (j.edad > j.edadRetiro) {
        expect(j.media, greaterThanOrEqualTo(mediaQueAguantaElRetiro),
            reason: '${j.nombreFicticio} sigue jugando con ${j.edad} años '
                'sin ser ya una estrella');
      }
      expect(j.edad, lessThanOrEqualTo(edadMaximaEnActivo),
          reason: j.nombreFicticio);
      expect(j.media, inInclusiveRange(30, 99), reason: j.nombreFicticio);
      expect(j.ptsPg, greaterThanOrEqualTo(0.0));
    }

    // Los nombres siguen siendo únicos tras 25 clases de draft generadas.
    final todos = await db.select(db.jugadores).get();
    expect(todos.map((j) => j.nombreFicticio).toSet().length, todos.length);

    // Nada crece sin control: el calendario es el de una sola temporada.
    final partidos = await (db.select(db.partidosCalendario)
          ..where((t) => t.equipoPropietario.equals('LAL')))
        .get();
    expect(partidos.length, 82);

    // Y el histórico sí se acumula: 25 temporadas archivadas.
    final historico = await db.select(db.historialTemporadaEquipo).get();
    expect(historico.map((h) => h.temporada).toSet().length, 25);
    expect(await db.select(db.historialCampeones).get(), hasLength(25));
  }, timeout: const Timeout(Duration(minutes: 5)));

  test('tras la primera temporada hay rookies generados y retirados, y la '
      'rotación del usuario queda lista para jugar', () async {
    final rng = Random(7);
    await _cerrarTemporadaDeGolpe(db, rng);

    final resumen = await empezarNuevaTemporada(db, random: rng);

    expect(resumen.temporadaNueva, 2);
    expect(resumen.tusRookies, hasLength(rondasDeDraft));
    expect(resumen.retiradosPropios.length + resumen.retiradosLiga.length,
        greaterThan(0));

    // La rotación se regenera sola: la anterior podía tener retirados.
    final rotacion = await leerRotacion(db);
    expect(rotacionEstaCompleta(rotacion), isTrue);
    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('LAL')))
        .get();
    final ids = plantilla.map((j) => j.id).toSet();
    expect(rotacion.every((f) => ids.contains(f.jugadorId)), isTrue);

    // Y la temporada nueva arranca limpia.
    expect(await db.select(db.estadisticasTemporadaJugador).get(), isEmpty);
    expect(await db.select(db.lesiones).get(), isEmpty);
    expect(await db.select(db.seriesPlayoffs).get(), isEmpty);
    final resultados = await db.select(db.resultadoTemporada).get();
    expect(resultados.every((r) => r.victorias == 0 && r.derrotas == 0), isTrue);
  });
}
