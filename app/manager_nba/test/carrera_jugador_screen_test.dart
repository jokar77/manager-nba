import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/carrera_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/legado_real_repository.dart';
import 'package:manager_nba/domain/tipo_premio.dart';
import 'package:manager_nba/features/temporada/carrera_jugador_screen.dart';

/// La ficha ya no separa "lo real" de "lo simulado" como si fueran dos
/// jugadores: se suman bajo el mismo palmarés y se listan los equipos en
/// un único orden cronológico. Michael Jordan (5 MVP reales, 1988-2003 con
/// Bulls y Wizards) es un buen caso porque el asset de Kaggle ya lo trae
/// bien probado en legado_real_repository_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');
    // Precalienta la caché del asset de legado real FUERA de testWidgets:
    // dentro de testWidgets el reloj es de mentira y una llamada a
    // rootBundle.loadString que todavía no se ha resuelto puede quedarse
    // colgada sin más pump() que la haga avanzar. En setUp (zona normal) se
    // resuelve sin problema, y una vez en caché las siguientes llamadas ya
    // no vuelven a tocar el asset.
    await datosRealesDe('Michael Jordan');
  });

  tearDown(() => db.close());

  Future<void> asentar(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  CarreraJugador carreraDeJordanConUnaTemporadaSimulada() {
    return const CarreraJugador(
      jugadorId: 999999,
      nombre: 'Michael Jordan',
      nombreReal: 'Michael Jordan',
      posicion: 'SG',
      etapas: [
        EtapaEnEquipo(
          equipo: 'LAL',
          desdeTemporada: 1,
          hastaTemporada: 1,
          partidos: 70,
          puntos: 2000,
          asistencias: 400,
          rebotes: 350,
        ),
      ],
      partidos: 70,
      puntos: 2000,
      asistencias: 400,
      rebotes: 350,
      mejorMedia: 95,
      temporadasPrevias: 0,
      prestigioPrevio: 0,
      ptsPgReferencia: 0,
      astPgReferencia: 0,
      trbPgReferencia: 0,
      premios: {TipoPremio.mvp: 1},
      premiosPorTemporada: {
        TipoPremio.mvp: [1],
      },
      anillos: [],
      copas: [],
    );
  }

  testWidgets(
      'el palmarés suma los premios reales y los simulados bajo la misma '
      'fila, no como dos jugadores distintos', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CarreraJugadorScreen(
        db: db,
        carrera: carreraDeJordanConUnaTemporadaSimulada(),
        nombreSiNoHayCarrera: 'Michael Jordan',
      ),
    ));
    await asentar(tester);

    expect(tester.takeException(), isNull);

    // 5 MVP reales (1988, 1991, 1992, 1996, 1998) + 1 simulado (temporada 1
    // de la partida) = 6, con los años reales primero y el de la partida
    // al final — nunca se separan en dos filas distintas.
    final filaMvp = tester.widget<ListTile>(find.ancestor(
      of: find.text('MVP'),
      matching: find.byType(ListTile),
    ));
    expect((filaMvp.trailing as Text).data, 'x6');
    expect(
      find.text('1987-88, 1990-91, 1991-92, 1995-96, 1997-98, 2026-27'),
      findsOneWidget,
      reason: 'los años reales de MVP más el de la partida, todos juntos',
    );

    // Ya no hay una tarjeta aparte de "Su carrera en la NBA real": ese
    // encabezado desaparece porque todo se cuenta en el mismo sitio.
    expect(find.text('Su carrera en la NBA real'), findsNothing);
  });

  testWidgets(
      'la trayectoria lista primero los equipos reales y luego los '
      'simulados, en orden cronológico (nunca al revés)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CarreraJugadorScreen(
        db: db,
        carrera: carreraDeJordanConUnaTemporadaSimulada(),
        nombreSiNoHayCarrera: 'Michael Jordan',
      ),
    ));
    await asentar(tester);

    final bulls = find.text('Chicago Bolls');
    final lakers = find.text('Los Ángeles Lakars');
    expect(bulls, findsOneWidget);
    expect(lakers, findsOneWidget);

    // Chicago (real, años 90) tiene que aparecer por encima de Los Ángeles
    // (el equipo de tu partida, siempre posterior en el tiempo).
    final yBulls = tester.getTopLeft(bulls).dy;
    final yLakers = tester.getTopLeft(lakers).dy;
    expect(yBulls, lessThan(yLakers));
  });
}
