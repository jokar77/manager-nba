import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/posiciones.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la segunda posición siempre es un puesto contiguo, hacia fuera si '
      'el jugador reparte más y hacia dentro si rebotea más', () {
    // Extremos del espectro: solo pueden ir hacia un lado.
    expect(derivarPosicionSecundaria(posicion: 'PG', astPg: 1, trbPg: 9), 'SG');
    expect(derivarPosicionSecundaria(posicion: 'C', astPg: 9, trbPg: 1), 'PF');

    // Un escolta que reparte mucho también hace de base.
    expect(derivarPosicionSecundaria(posicion: 'SG', astPg: 7, trbPg: 3), 'PG');
    // Un escolta reboteador tira hacia alero.
    expect(derivarPosicionSecundaria(posicion: 'SG', astPg: 2, trbPg: 6), 'SF');
  });

  test('si el dataset trae dos posiciones ("SG / PG"), se respeta la '
      'declarada en vez de derivar nada', () {
    const nbsp = ' ';
    expect(posicionSecundariaDeclarada('SG$nbsp/${nbsp}PG'), 'PG');
    expect(posicionSecundariaDeclarada('SG'), isNull);
    expect(posicionSecundariaDeclarada('SG / XX'), isNull);
  });

  group('con el dataset real', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await importarJugadoresSiHaceFalta(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('todos los jugadores acaban con una segunda posición válida y '
        'distinta de la primera', () async {
      final jugadores = await db.select(db.jugadores).get();
      expect(jugadores, isNotEmpty);

      for (final j in jugadores) {
        expect(posicionesEquipo, contains(j.posicionSecundaria),
            reason: '${j.nombreFicticio} tiene una segunda posición rara');
        expect(j.posicionSecundaria, isNot(j.posicion));
      }
    });

    test('cada equipo puede cubrir los 5 puestos con jugadores cómodos: ya '
        'no hay plantillas sin recambio natural en un puesto', () async {
      Map<String, List<Jugador>> plantillas(List<Jugador> jugadores) {
        final porEquipo = <String, List<Jugador>>{};
        for (final j in jugadores) {
          if (j.equipo == 'FA') continue;
          porEquipo.putIfAbsent(j.equipo, () => []).add(j);
        }
        return porEquipo;
      }

      // El dataset es una foto real de la NBA, y una plantilla real no
      // garantiza dos jugadores naturales en cada puesto: al actualizarlo
      // contra 2kratings.com quedó un equipo con un solo pívot cómodo. Lo
      // que sí tiene que cumplir el dataset —y es lo que de verdad valida
      // `derivarPosicionSecundaria`— es que nadie se quede a cero en un
      // puesto, porque de ahí no se sale fichando.
      for (final entry in plantillas(await db.select(db.jugadores).get())
          .entries) {
        for (final puesto in posicionesEquipo) {
          final comodos =
              entry.value.where((j) => juegaComodoDe(j, puesto)).length;
          expect(comodos, greaterThanOrEqualTo(1),
              reason: '${entry.key} no tiene a nadie para $puesto');
        }
      }

      // Y el recambio (los dos por puesto) lo garantiza ya el arranque de
      // la partida, que completa desde la agencia libre lo que el dataset
      // no dé. Ver la nota en `crearFranquicia`.
      await crearFranquicia(db, 'LAL');
      final trasCrear = await (db.select(db.jugadores)
            ..where((t) => t.retirado.equals(false)))
          .get();
      for (final entry in plantillas(trasCrear).entries) {
        for (final puesto in posicionesEquipo) {
          final comodos =
              entry.value.where((j) => juegaComodoDe(j, puesto)).length;
          expect(comodos, greaterThanOrEqualTo(2),
              reason: '${entry.key} no tiene ni dos jugadores para $puesto');
        }
      }
    });
  });

  test('el factor de puesto va graduado y la penalización real es suave',
      () {
    expect(factorPuestoNatural, 1.0);
    expect(factorPuestoSecundario, greaterThan(factorFueraDePosicion));
    expect(factorPuestoSecundario, lessThan(factorPuestoNatural));
    // Que te falte un puesto natural no puede ser una losa: como mucho un
    // 10% menos de rendimiento en ese jugador concreto.
    expect(factorFueraDePosicion, greaterThanOrEqualTo(0.9));
  });
}
