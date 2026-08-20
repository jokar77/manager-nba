import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/calendario_repository.dart';
import 'package:manager_nba/features/calendario/resumen_simulacion_screen.dart';
import 'package:manager_nba/features/calendario/simulacion_ui.dart';

sim.Boxscore _boxscoreDeEjemplo({required String local, required String visitante}) {
  return sim.Boxscore(
    equipoLocal: local,
    equipoVisitante: visitante,
    marcadorLocal: 105,
    marcadorVisitante: 98,
    statsLocal: const [],
    statsVisitante: const [],
    parcialesLocal: const [26, 27, 25, 27],
    parcialesVisitante: const [24, 25, 24, 25],
  );
}

void main() {
  testWidgets('el partido jugado fuera muestra "rival - marcador - tu '
      'equipo" (orden real local-visitante), no "tu equipo primero"',
      (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    // DEN juega de visitante contra LAL: LAL es el local en el boxscore
    // aunque tú (DEN) hayas ganado 98-105.
    final resultado = ResultadoLoteSimulado(
      partidos: [
        PartidoSimuladoInfo(
          fecha: DateTime(2026, 11, 1),
          rival: 'LAL',
          esLocal: false,
          boxscore: _boxscoreDeEjemplo(local: 'LAL', visitante: 'DEN'),
        ),
      ],
      lesionesActivas: const [],
      temporadaTerminada: false,
    );

    await tester.pumpWidget(MaterialApp(
      home: ResumenSimulacionScreen(
        db: db,
        equipoUsuario: 'DEN',
        resultado: resultado,
      ),
    ));
    await tester.pump();

    expect(find.text('105-98'), findsOneWidget);
    // El local (LAL) va antes que el visitante (DEN) en la fila, aunque
    // DEN sea "tu equipo" y haya ganado.
    //
    // Solo dentro de la lista: la barra de arriba lleva de fondo el
    // monograma gigante del club, que también dice "DEN".
    Finder enLaLista(String equipo) =>
        find.descendant(of: find.byType(ListView), matching: find.text(equipo));
    final posicionLal = tester.getTopLeft(enLaLista('LAL')).dx;
    final posicionDen = tester.getTopLeft(enLaLista('DEN')).dx;
    expect(posicionLal, lessThan(posicionDen));

    await db.close();
  });
}
