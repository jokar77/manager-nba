import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/legado_historico_repository.dart';
import 'package:manager_nba/domain/legado_real_repository.dart';
import 'package:manager_nba/features/temporada/camisetas_retiradas_screen.dart';
import 'package:manager_nba/features/temporada/hall_fama_screen.dart';
import 'package:manager_nba/features/temporada/lideres_historicos_screen.dart';

/// Las dos vistas de Legado tienen que pintar el legado real importado.
///
/// Nada de `pumpAndSettle`: mientras haya un indicador de carga girando no se
/// queda quieto nunca, así que un fallo de carga se manifestaría como un test
/// colgado diez minutos en vez de como un fallo con su mensaje. Se bombea un
/// número fijo de veces y se mira qué hay en pantalla.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await importarLegadoHistoricoSiHaceFalta(db);
    // Precalienta la caché del asset de legado real FUERA de testWidgets
    // (ver la nota en carrera_jugador_screen_test.dart): dentro de un
    // reloj de mentira, una lectura de asset que no se ha resuelto puede
    // quedarse colgada sin más pump() que la haga avanzar.
    await datosRealesDe('LeBron James');
  });

  tearDown(() => db.close());

  Future<void> asentar(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('las camisetas retiradas reales se ven, y por defecto las del '
      'equipo del usuario', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CamisetasRetiradasBody(db: db, equipoUsuario: 'LAL'),
      ),
    ));
    await asentar(tester);

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Retirada real de la franquicia'), findsWidgets,
        reason: 'los Lakers tienen camisetas retiradas reales de sobra');
    expect(find.textContaining('todavía no ha retirado'), findsNothing);
    expect(find.textContaining('Todavía no hay ninguna'), findsNothing);
  });

  testWidgets('el Hall of Fame real se ve, en orden cronológico inverso',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: HallDeLaFamaBody(db: db)),
    ));
    await asentar(tester);

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Entró en 20'),
        findsWidgets);
    // Lo más reciente arriba: la última hornada real del dataset es 2026,
    // y los pioneros de 1959 quedan al fondo (fuera de la primera pantalla).
    expect(find.textContaining('en 2026'), findsWidgets,
        reason: 'inverso significa que lo último abre la lista');
    expect(find.textContaining('en 1959'), findsNothing,
        reason: 'los pioneros van al final, no arriba del todo');
  });

  testWidgets(
      'en el aviso de nuevos ingresos, tocar cualquier nombre abre su '
      'ficha, y el icono de info explica la puntuación',
      (tester) async {
    final jugador =
        (await (db.select(db.jugadores)..limit(1)).get()).first;

    await tester.pumpWidget(MaterialApp(
      home: NuevosEnHallDeLaFamaScreen(
        db: db,
        nuevos: [
          MiembroHallDeLaFama(
            id: 1,
            jugadorId: jugador.id,
            nombreJugador: jugador.nombreFicticio,
            temporadaIngreso: 3,
            puntuacion: 80,
          ),
        ],
        onContinuar: () {},
      ),
    ));
    await asentar(tester);

    expect(tester.takeException(), isNull);

    // Tocar la tarjeta del nuevo miembro lleva a su ficha (se identifica
    // por el nombre en la barra de CarreraJugadorScreen). Los nombres van
    // en mayúsculas en los dos sitios, como todos los titulares del juego.
    await tester.tap(find.text(jugador.nombreFicticio.toUpperCase()));
    await asentar(tester);
    expect(find.text(jugador.nombreFicticio.toUpperCase()), findsWidgets,
        reason: 'la ficha del jugador también muestra su nombre, en la '
            'barra de arriba y en mayúsculas como el resto de titulares');

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.info_outline));
    await asentar(tester);
    expect(find.text('¿Qué es la puntuación de carrera?'), findsOneWidget);
  });

  testWidgets('los líderes históricos se ven, con al menos un nombre en '
      'la pestaña de puntos', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: LideresHistoricosBody(db: db)),
    ));
    await asentar(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Puntos'), findsOneWidget);
    expect(find.text('Asistencias'), findsOneWidget);
    expect(find.text('Rebotes'), findsOneWidget);
    expect(find.text('1'), findsOneWidget,
        reason: 'el número 1 del ranking de puntos');
  });

  testWidgets(
      'en la lista del Hall of Fame solo se ve el año: ni temporadas ni '
      'promedios debajo, tenga o no carrera archivada', (tester) async {
    // Un inducido DENTRO de la partida, con carrera y estadísticas
    // guardadas de sobra: es el caso que antes sí mostraba una segunda
    // línea con temporadas y promedios. Se monta a mano.
    final jugador = (await (db.select(db.jugadores)..limit(1)).getSingle());
    await db.into(db.historialEstadisticasJugador).insert(
        HistorialEstadisticasJugadorCompanion.insert(
          temporada: 2,
          jugadorId: jugador.id,
          equipo: jugador.equipo,
          media: 95,
          partidosJugados: 80,
          puntosTotales: 2000,
          asistenciasTotales: 500,
          rebotesTotales: 600,
        ));
    await db.into(db.hallDeLaFama).insert(HallDeLaFamaCompanion.insert(
        jugadorId: jugador.id,
        nombreJugador: jugador.nombreFicticio,
        temporadaIngreso: 3,
        puntuacion: 90));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: HallDeLaFamaBody(db: db)),
    ));
    await asentar(tester);

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Entró en'), findsWidgets,
        reason: 'el año se queda: es justo lo único que debe verse');
    expect(find.textContaining(' pts · '), findsNothing,
        reason: 'la lista ya no enseña promedios, aunque haya carrera '
            'archivada — eso vive en la ficha, a un toque de distancia');
    expect(find.textContaining('temporadas'), findsNothing,
        reason: 'ni el recuento de temporadas suelto');
  });
}
