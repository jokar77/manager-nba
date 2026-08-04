import 'package:flutter/material.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../../data/database/app_database.dart';
import '../../domain/boxscores_serie_repository.dart';
import 'boxscore_screen.dart';

/// Abre las estadísticas de una serie ya empezada (playoffs o NBA Cup): si
/// solo tiene un partido jugado (siempre el caso en la Cup, al ser
/// partidos únicos), va directa al boxscore; si tiene varios (una serie de
/// playoffs al mejor de 7), muestra antes una lista para elegir cuál.
Future<void> abrirEstadisticasDeSerie(
  BuildContext context,
  AppDatabase db, {
  required String origen,
  required int serieId,
}) async {
  final boxscores =
      await leerBoxscoresDeSerie(db, origen: origen, serieId: serieId);
  if (boxscores.isEmpty || !context.mounted) return;

  if (boxscores.length == 1) {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BoxscoreScreen(boxscore: boxscores.first),
    ));
    return;
  }

  await Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => SerieBoxscoresScreen(boxscores: boxscores),
  ));
}

/// Lista de los partidos jugados de una serie al mejor de 7, cada uno
/// tocable para ver su boxscore completo.
class SerieBoxscoresScreen extends StatelessWidget {
  final List<sim.Boxscore> boxscores;

  const SerieBoxscoresScreen({super.key, required this.boxscores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partidos de la serie')),
      body: ListView.builder(
        itemCount: boxscores.length,
        itemBuilder: (context, i) {
          final b = boxscores[i];
          return ListTile(
            title: Text('Partido ${i + 1}: ${b.equipoLocal} ${b.marcadorLocal} - '
                '${b.marcadorVisitante} ${b.equipoVisitante}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BoxscoreScreen(boxscore: b),
            )),
          );
        },
      ),
    );
  }
}
