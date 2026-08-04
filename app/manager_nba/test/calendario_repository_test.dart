import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/tipo_evento_temporada.dart';

/// La primera fecha límite del calendario que de verdad corta la simulación
/// (el All-Star no lo hace). Cuál de las dos llega antes lo decide el
/// generador, así que se busca en vez de darlo por hecho.
Future<EventosTemporadaData> _primeraFechaLimite(AppDatabase db) async {
  final eventos = await leerEventos(db);
  final limites = eventos
      .where((e) =>
          e.tipo == TipoEventoTemporada.finAgenciaLibre.name ||
          e.tipo == TipoEventoTemporada.fechaLimiteTraspasos.name)
      .toList()
    ..sort((a, b) => a.fecha.compareTo(b.fecha));
  return limites.first;
}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await _guardarRotacionAutomatica(db, 'DEN');
  });

  tearDown(() async {
    await db.close();
  });

  test('simularTramo sin fecha límite por medio simula todo hasta el día '
      'objetivo y deja el resto pendiente', () async {
    final partidos = await leerPartidos(db, 'DEN');
    final diaObjetivo = partidos[4].fecha; // el 5º partido (índice 4)

    final resultado = await simularTramo(db, 'DEN', diaObjetivo);

    expect(resultado.eventoBloqueante, isNull);
    expect(resultado.simulados.length, 5);

    final actualizados = await leerPartidos(db, 'DEN');
    for (var i = 0; i < actualizados.length; i++) {
      expect(actualizados[i].jugado, i <= 4);
    }
  });

  test('simularTramo se detiene justo en una fecha límite sin resolver',
      () async {
    final partidos = await leerPartidos(db, 'DEN');

    // La primera fecha límite del calendario, sea cual sea: el All-Star no
    // corta la simulación, y cuál de las dos que sí cortan (agencia libre o
    // traspasos) llega antes depende de dónde las ponga el generador.
    final deadline = await _primeraFechaLimite(db);
    final diaObjetivo = partidos.last.fecha; // "simula toda la temporada"

    final resultado = await simularTramo(db, 'DEN', diaObjetivo);

    expect(resultado.eventoBloqueante?.id, deadline.id);
    // No debería haber simulado ningún partido posterior a la fecha límite.
    expect(
      resultado.simulados.every((p) => !p.fecha.isAfter(deadline.fecha)),
      isTrue,
    );

    final actualizados = await leerPartidos(db, 'DEN');
    expect(
      actualizados.any((p) => p.jugado && p.fecha.isAfter(deadline.fecha)),
      isFalse,
    );
  });

  test('pasar eventoIdAIgnorar deja avanzar más allá de esa fecha límite ya '
      'confirmada', () async {
    final partidos = await leerPartidos(db, 'DEN');
    final deadline = await _primeraFechaLimite(db);
    final diaObjetivo = partidos.last.fecha;

    final primerTramo = await simularTramo(db, 'DEN', diaObjetivo);
    expect(primerTramo.eventoBloqueante?.id, deadline.id);

    final segundoTramo = await simularTramo(
      db,
      'DEN',
      diaObjetivo,
      eventoIdAIgnorar: deadline.id,
    );

    // O bien llega hasta el final, o se para en la SIGUIENTE fecha límite
    // (nunca en la misma que ya se confirmó).
    expect(segundoTramo.eventoBloqueante?.id, isNot(deadline.id));
  });

  test('los partidos simulados traen boxscore completo con marcador '
      'consistente', () async {
    final partidos = await leerPartidos(db, 'DEN');
    final resultado = await simularTramo(db, 'DEN', partidos[0].fecha);

    expect(resultado.simulados.length, 1);
    final simulado = resultado.simulados.first;
    expect(simulado.marcadorUsuario,
        simulado.esLocal ? simulado.boxscore.marcadorLocal : simulado.boxscore.marcadorVisitante);
  });
}
