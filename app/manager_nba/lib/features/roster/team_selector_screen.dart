import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/campeones_repository.dart';
import '../../domain/equipos_especiales.dart';
import '../../domain/equipos_info.dart';
import '../../i18n/textos.dart';
import '../../shared/equipo_logo.dart';
import 'team_preview_screen.dart';

class _FilaEquipo {
  final String codigo;
  final double media;
  final bool tieneTituloIst;
  final bool tieneTituloNba;

  const _FilaEquipo({
    required this.codigo,
    required this.media,
    required this.tieneTituloIst,
    required this.tieneTituloNba,
  });
}

/// Lista de los 30 equipos disponibles: logo, nombre completo, media del
/// equipo y los dos huecos de trofeo (torneo de mitad de temporada / NBA),
/// rellenos si ese equipo ya ganó ese título alguna vez (aunque sea en una
/// franquicia anterior, o en otra partida guardada: el palmarés es tuyo, no
/// de la ranura). Tocar un equipo abre su plantilla antes de confirmar.
class TeamSelectorScreen extends StatelessWidget {
  final AppDatabase db;
  final String titulo;
  final void Function(String equipo) onSeleccionado;

  const TeamSelectorScreen({
    super.key,
    required this.db,
    required this.titulo,
    required this.onSeleccionado,
  });

  Future<List<_FilaEquipo>> _cargarEquipos() async {
    final jugadores = await db.select(db.jugadores).get();
    final porEquipo = <String, List<Jugador>>{};
    for (final j in jugadores) {
      if (!esFranquicia(j.equipo)) continue;
      porEquipo.putIfAbsent(j.equipo, () => []).add(j);
    }

    // Solo los títulos que has ganado tú dirigiendo ese equipo: si la CPU
    // gana el anillo con los Lakers, ese trofeo no es tuyo y el hueco sigue
    // vacío al empezar una partida nueva.
    final conIst = await equiposConTituloDelUsuario('ist');
    final conNba = await equiposConTituloDelUsuario('nba');

    const jugadoresTitulares = 5;
    final filas = porEquipo.entries.map((entry) {
      // Media de los 5 titulares (los mejores), no de toda la plantilla:
      // el resto del roster son suplentes que apenas juegan y bajaban la
      // media de todos los equipos por igual sin reflejar el quinteto real.
      final ordenados = [...entry.value]..sort((a, b) => b.media.compareTo(a.media));
      final rotacion = ordenados.take(jugadoresTitulares).toList();
      final media =
          rotacion.map((j) => j.media).reduce((a, b) => a + b) / rotacion.length;
      return _FilaEquipo(
        codigo: entry.key,
        media: media,
        tieneTituloIst: conIst.contains(entry.key),
        tieneTituloNba: conNba.contains(entry.key),
      );
    }).toList()
      ..sort((a, b) => infoDe(a.codigo).nombreCompleto.compareTo(infoDe(b.codigo).nombreCompleto));

    return filas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: FutureBuilder<List<_FilaEquipo>>(
        future: _cargarEquipos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final equipos = snapshot.data!;
          return ListView.separated(
            itemCount: equipos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final fila = equipos[i];
              final info = infoDe(fila.codigo);
              return ListTile(
                leading: EquipoLogo(codigoEquipo: fila.codigo),
                title: Text(info.nombreCompleto,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(t(context).mediaDelEquipo(fila.media.round())),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: t(context).torneoDeMitadDeTemporada,
                      child: Icon(Icons.military_tech,
                          size: 22,
                          color: fila.tieneTituloIst
                              ? Colors.blueAccent
                              : Colors.grey.shade300),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: t(context).campeonNba,
                      child: Icon(Icons.emoji_events,
                          size: 22,
                          color: fila.tieneTituloNba
                              ? Colors.amber.shade700
                              : Colors.grey.shade300),
                    ),
                  ],
                ),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TeamPreviewScreen(
                    db: db,
                    equipo: fila.codigo,
                    onElegir: () => onSeleccionado(fila.codigo),
                  ),
                )),
              );
            },
          );
        },
      ),
    );
  }
}
