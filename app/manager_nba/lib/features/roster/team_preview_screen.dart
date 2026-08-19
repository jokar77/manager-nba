import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/entrenadores_repository.dart';
import '../../domain/equipos_info.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/contraste.dart';
import '../../shared/medias_jugador.dart';

/// Plantilla completa de un equipo antes de confirmarlo: nombre, posición
/// y media de cada jugador, con la opción de elegir ese equipo o volver a
/// la lista.
class TeamPreviewScreen extends StatelessWidget {
  final AppDatabase db;
  final String equipo;
  final VoidCallback onElegir;

  const TeamPreviewScreen({
    super.key,
    required this.db,
    required this.equipo,
    required this.onElegir,
  });

  Future<List<Jugador>> _cargarPlantilla() {
    return (db.select(db.jugadores)
          ..where((t) => t.equipo.equals(equipo))
          ..orderBy([(t) => OrderingTerm.desc(t.media)]))
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final info = infoDe(equipo);
    return Scaffold(
      appBar: AppBar(
        title: Text(info.nombreCompleto),
        backgroundColor: info.colorPrimario,
        foregroundColor: textoSobre(info.colorPrimario),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                EquipoLogo(codigoEquipo: equipo, tamano: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(info.nombreCompleto,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Quién dirige. Elegir equipo mirando solo la plantilla se deja
          // fuera medio proyecto: el entrenador vale unas seis victorias de
          // 82 entre el mejor y el peor, y además decide cuánto crecen tus
          // jóvenes.
          _EntrenadorDelEquipo(db: db, equipo: equipo),
          Expanded(
            child: FutureBuilder<List<Jugador>>(
              future: _cargarPlantilla(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final plantilla = snapshot.data!;
                return ListView.separated(
                  itemCount: plantilla.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final j = plantilla[i];
                    return ListTile(
                      title: Text(j.nombreFicticio),
                      subtitle: Row(
                        children: [
                          Text('${j.posicion}  '),
                          MediasAtaqueDefensa.de(j, compacto: true),
                        ],
                      ),
                      trailing: Text('Media ${j.media}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onElegir,
                    child: const Text('Elegir este equipo'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// La fila del entrenador en la ficha de un equipo.
class _EntrenadorDelEquipo extends StatelessWidget {
  final AppDatabase db;
  final String equipo;

  const _EntrenadorDelEquipo({required this.db, required this.equipo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Entrenador?>(
      future: leerEntrenadorDe(db, equipo),
      builder: (context, snapshot) {
        final e = snapshot.data;
        if (e == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.sports),
              title: Text(e.nombreFicticio),
              subtitle: Text(
                '${e.edad} años · '
                '${estiloDeEntrenador(ataque: e.atrAtaque, defensa: e.atrDefensa, desarrollo: e.atrDesarrollo)}'
                '${e.anillos > 0 ? ' · ${e.anillos} anillo${e.anillos > 1 ? 's' : ''}' : ''}',
              ),
              trailing: Text('Media ${mediaDe(e)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }
}
