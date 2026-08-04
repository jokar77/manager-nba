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
    // cuarto, así que hay que quedarse con el marcador grande (fontSize 32).
    Text marcadorGrande(String puntos) => tester
        .widgetList<Text>(find.text(puntos))
        .firstWhere((t) => t.style?.fontSize == 32);

    final textoMarcadorLocal = marcadorGrande('110');
    expect(textoMarcadorLocal.style?.color, isNot(Colors.green));
    expect(textoMarcadorLocal.style?.fontWeight, FontWeight.bold);

    final textoMarcadorVisitante = marcadorGrande('100');
    expect(textoMarcadorVisitante.style?.color, isNot(Colors.green));
    expect(textoMarcadorVisitante.style?.fontWeight, FontWeight.normal);

    // "DEN"/"LAL" también aparecen en la fila de parciales por cuarto, así
    // que hay que quedarse con el título grande de cada _TablaEquipo
    // (fontSize 18) para comprobar su color.
    Text tituloDeTabla(String equipo) => tester
        .widgetList<Text>(find.text(equipo))
        .firstWhere((t) => t.style?.fontSize == 18);

    final tituloLocal = tituloDeTabla('DEN');
    final tituloVisitante = tituloDeTabla('LAL');
    expect(tituloLocal.style?.color, infoDe('DEN').colorPrimario);
    expect(tituloVisitante.style?.color, infoDe('LAL').colorPrimario);
    expect(tituloLocal.style?.color, isNot(tituloVisitante.style?.color));
  });
}
