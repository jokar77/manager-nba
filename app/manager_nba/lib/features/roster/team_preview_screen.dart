import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/contraste.dart';

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
                Text(info.nombreCompleto,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
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
                      subtitle: Text(j.posicion),
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
