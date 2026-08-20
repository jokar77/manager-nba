import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/features/calendario/resumen_simulacion_screen.dart';
import 'package:manager_nba/features/calendario/simulacion_ui.dart';

/// Verifica específicamente que el bloque "Lesiones activas ahora mismo"
/// se muestra cuando el resultado trae lesiones — para descartar que sea
/// un bug de UI (en vez de solo frecuencia/tuning) tras el reporte de que
/// "ya no sale el aviso que salía antes".
void main() {
  testWidgets('el bloque de lesiones activas se muestra cuando hay '
      'lesiones en el resultado', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    final resultado = ResultadoLoteSimulado(
      partidos: const [],
      lesionesActivas: [
        LesionActivaInfo(
          nombreJugador: 'Jugador de Prueba',
          motivo: 'Esguince de tobillo',
          partidosEstimados: 3,
          vuelve: DateTime(2026, 12, 1),
        ),
      ],
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

    expect(find.text('LESIONES ACTIVAS AHORA MISMO'), findsOneWidget);
    // El nombre va en mayúsculas, como todos los titulares del juego.
    expect(find.textContaining('JUGADOR DE PRUEBA'), findsOneWidget);

    await db.close();
  });
}
