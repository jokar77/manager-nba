import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import 'package:manager_nba/domain/equipos_info.dart';
import 'package:manager_nba/features/partido/boxscore_screen.dart';

sim.Boxscore _boxscoreDeEjemplo() {
  return sim.Boxscore(
    equipoLocal: 'DEN',
    equipoVisitante: 'LAL',
    marcadorLocal: 110,
    marcadorVisitante: 100,
    statsLocal: const [
      sim.EstadisticasJugador(
        jugadorId: '1',
        nombreFicticio: 'Jugador Local',
        minutos: 32,
        puntos: 20,
        asistencias: 5,
        rebotes: 6,
      ),
    ],
    statsVisitante: const [
      sim.EstadisticasJugador(
        jugadorId: '2',
        nombreFicticio: 'Jugador Visitante',
        minutos: 30,
        puntos: 18,
        asistencias: 4,
        rebotes: 5,
      ),
    ],
    parcialesLocal: const [28, 27, 30, 25],
    parcialesVisitante: const [25, 26, 24, 25],
  );
}

void main() {
  testWidgets('el marcador del ganador no se pinta en verde, y la cabecera '
      'de cada tabla usa el color de su propio equipo',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BoxscoreScreen(boxscore: _boxscoreDeEjemplo()),
    ));
    await tester.pump();

    // "110"/"100" también aparecen como Total en la tabla de parciales por
    // cuarto, así que hay que quedarse con el marcador grande.
    Text marcadorGrande(String puntos) => tester
        .widgetList<Text>(find.text(puntos))
        .firstWhere((t) => (t.style?.fontSize ?? 0) >= 30);

    final local = marcadorGrande('110');
    final visitante = marcadorGrande('100');

    // Lo que se vigila es que el marcador NO se pinte de verde: hubo una
    // versión que teñía de verde al ganador y en un boxscore eso se lee
    // como si el color fuera parte del resultado.
    expect(local.style?.color, isNot(Colors.green));
    expect(visitante.style?.color, isNot(Colors.green));

    // Y que ganador y perdedor se distingan. Desde el rediseño no es por el
    // grosor de la letra (los dos van en la misma condensada gruesa) sino
    // por la tinta: el ganador con la principal, el perdedor apagado.
    expect(local.style?.color, isNot(visitante.style?.color));

    // La cabecera de cada tabla lleva el color de SU club, no uno común.
    Text tituloDeTabla(String equipo) => tester
        .widget<Text>(find.text(infoDe(equipo).nombreCompleto.toUpperCase()));

    final tituloLocal = tituloDeTabla('DEN');
    final tituloVisitante = tituloDeTabla('LAL');
    expect(tituloLocal.style?.color, isNot(tituloVisitante.style?.color));
  });
}
