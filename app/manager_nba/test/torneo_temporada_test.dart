import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/calendario/generador_calendario.dart';
import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/fin_temporada_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/domain/torneo_repository.dart';

Future<void> _guardarRotacionAutomatica(AppDatabase db, String equipo) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo))
        ..orderBy([(t) => OrderingTerm.desc(t.media)]))
      .get();
  await guardarRotacion(db, generarRotacionAutomatica(plantilla));
}

/// Simula hasta [diaObjetivo], resolviendo fechas límite automáticamente
/// (como haría el usuario eligiendo "seguir simulando").
Future<ResultadoTramo> _simularHasta(
  AppDatabase db,
  String equipo,
  DateTime diaObjetivo,
) async {
  int? ignorar;
  late ResultadoTramo ultimo;
  while (true) {
    ultimo = await simularTramo(db, equipo, diaObjetivo,
        eventoIdAIgnorar: ignorar);
    if (ultimo.eventoBloqueante == null) return ultimo;
    ignorar = ultimo.eventoBloqueante!.id;
  }
}

/// victorias+derrotas de cada equipo menos cuántos de sus partidos de
/// temporada regular están jugados: el "sobrante" son partidos de
/// cuartos/semis de la NBA Cup, que suman al récord sin tener una fila de
/// calendario propia (ver nota de diseño en torneo_repository.dart). La
/// Final sí tiene fila de calendario cuando la juegas tú, pero es de fase
/// `copa_final` y no cuenta por ninguno de los dos lados.
Future<Map<String, int>> _sobranteDeRecordSobreCalendario(
  AppDatabase db,
) async {
  final resultados = await db.select(db.resultadoTemporada).get();
  final sobrante = <String, int>{};
  for (final r in resultados) {
    final jugados = await (db.select(db.partidosCalendario)
          ..where((t) =>
              t.equipoPropietario.equals(r.equipo) &
              t.jugado.equals(true) &
              t.fase.equals(faseRegular)))
        .get();
    sobrante[r.equipo] = (r.victorias + r.derrotas) - jugados.length;
  }
  return sobrante;
}

Future<PartidosCalendarioData?> _finalDeCopaEnCalendario(
  AppDatabase db,
  String equipo,
) {
  return (db.select(db.partidosCalendario)
        ..where((t) =>
            t.equipoPropietario.equals(equipo) &
            t.fase.equals(faseFinalCopa)))
      .getSingleOrNull();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await _guardarRotacionAutomatica(db, 'DEN');

    // El campeón de la NBA Cup se apunta también en el registro compartido
    // entre partidas (campeones_repository.dart); en un test se sustituye
    // por uno en memoria para no depender de `path_provider`.
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
  });

  tearDown(() async {
    await db.close();
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  test('al terminar la fase de grupos se siembra la NBA Cup entera: cuartos '
      'y semifinal se resuelven solos, y la Final o se programa en tu '
      'calendario (si eres finalista) o se juega sola y te llega el '
      'campeón', () async {
    final partidos = await leerPartidos(db, 'DEN');
    final anioTemporada = partidos.first.fecha.year;
    final finFaseDeGrupos = DateTime(anioTemporada, 12, 17);

    expect(await leerSeriesTorneo(db), isEmpty);

    final tramo = await _simularHasta(db, 'DEN', finFaseDeGrupos);

    final series = await leerSeriesTorneo(db);
    // 4 cuartos + 2 semis + 1 final = 7 series.
    expect(series.length, 7);
    expect(series.where((s) => s.ronda < 3).every((s) => s.ganador != null),
        isTrue,
        reason: 'cuartos y semis deberían haberse resuelto solos');

    final finalNba = series.firstWhere((s) => s.ronda == 3);
    final eresFinalista =
        finalNba.equipoA == 'DEN' || finalNba.equipoB == 'DEN';
    final filaDeCalendario = await _finalDeCopaEnCalendario(db, 'DEN');

    if (eresFinalista) {
      expect(finalNba.ganador, isNull,
          reason: 'tu Final se juega desde el calendario, no sola');
      expect(tramo.novedadesCopa.finalDelUsuario, isNotNull);
      expect(filaDeCalendario, isNotNull,
          reason: 'la Final tiene que aparecer como un día más del calendario');
      expect(filaDeCalendario!.jugado, isFalse);
      expect(filaDeCalendario.rival,
          finalNba.equipoA == 'DEN' ? finalNba.equipoB : finalNba.equipoA);

      // Simular hasta ese día la juega y corona campeón.
      final tras = await _simularHasta(db, 'DEN', filaDeCalendario.fecha);
      expect(tras.novedadesCopa.campeon, isNotNull);
      final jugada = await _finalDeCopaEnCalendario(db, 'DEN');
      expect(jugada!.jugado, isTrue);
    } else {
      expect(finalNba.ganador, isNotNull,
          reason: 'si no eres finalista, la Final se juega sola');
      expect(tramo.novedadesCopa.campeon, finalNba.ganador);
      expect(tramo.novedadesCopa.serieIdFinal, finalNba.id);
      expect(filaDeCalendario, isNull,
          reason: 'no eres finalista: no se te programa nada');
    }

    await simularTorneoCompleto(db);

    final compartido = abrirAjustes();
    final campeones = await (compartido.select(compartido.historialCampeones)
          ..where((t) => t.tipo.equals('ist')))
        .get();
    expect(campeones.length, 1);
    final finalResuelta =
        (await leerSeriesTorneo(db)).firstWhere((s) => s.ronda == 3);
    expect(campeones.first.equipo, finalResuelta.ganador);
    expect(campeones.first.logradoPorUsuario, finalResuelta.ganador == 'DEN');

    // Volver a intentar sembrar no debe crear una segunda tanda de series.
    await sembrarCuartosDeTorneoSiToca(db, equipoUsuario: 'DEN');
    expect(await leerSeriesTorneo(db), hasLength(7));
  });

  test('cuartos y semifinal de la NBA Cup suman al récord de temporada '
      'regular (una victoria/derrota sin fila de calendario propia); la '
      'final no suma nada y tampoco cuenta para dar la temporada por '
      'terminada', () async {
    final partidos = await leerPartidos(db, 'DEN');
    final anioTemporada = partidos.first.fecha.year;
    await _simularHasta(db, 'DEN', DateTime(anioTemporada, 12, 17));

    final sobrante = await _sobranteDeRecordSobreCalendario(db);
    final series = await leerSeriesTorneo(db);

    final semifinalistas = <String>{};
    for (final s in series.where((s) => s.ronda == 2)) {
      semifinalistas.addAll([s.equipoA, s.equipoB]);
    }
    final cuartofinalistas = <String>{};
    for (final s in series.where((s) => s.ronda == 1)) {
      cuartofinalistas.addAll([s.equipoA, s.equipoB]);
    }
    final eliminadosEnCuartos = cuartofinalistas.difference(semifinalistas);

    // Los 4 semifinalistas jugaron cuartos Y semis: +2 sobre su calendario.
    for (final equipo in semifinalistas) {
      expect(sobrante[equipo], 2,
          reason: '$equipo llegó a semis, debería sumar 2 partidos de Cup');
    }
    // Los 4 eliminados en cuartos solo jugaron esa ronda: +1.
    for (final equipo in eliminadosEnCuartos) {
      expect(sobrante[equipo], 1,
          reason: '$equipo cayó en cuartos, debería sumar 1 partido de Cup');
    }

    await simularTorneoCompleto(db);

    final sobranteTrasFinal = await _sobranteDeRecordSobreCalendario(db);
    // La final no debe cambiar el sobrante de nadie: sigue siendo
    // exactamente el de cuartos+semis.
    for (final equipo in semifinalistas) {
      expect(sobranteTrasFinal[equipo], 2,
          reason: '$equipo no debería sumar nada más por la final de la Cup');
    }

    // Y su fila de calendario (si la hay) no acerca el fin de temporada.
    expect(await temporadaRegularCompleta(db, 'DEN'), isFalse);
  });
}
