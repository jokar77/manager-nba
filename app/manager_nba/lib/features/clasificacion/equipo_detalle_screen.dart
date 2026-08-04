import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/posiciones.dart';
import '../../domain/salarios.dart';
import '../../domain/traspasos_repository.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/hoja_de_propuestas.dart';

/// Plantilla completa de un equipo, para consultarla desde Clasificación.
/// Tocar un jugador abre su ficha: estadísticas de la temporada, contrato
/// y —si es de otro equipo— un botón para que el buscador automático
/// intente encontrarle un traspaso.
class EquipoDetalleScreen extends StatelessWidget {
  final AppDatabase db;
  final String equipo;
  final String equipoUsuario;

  const EquipoDetalleScreen({
    super.key,
    required this.db,
    required this.equipo,
    required this.equipoUsuario,
  });

  Future<List<Jugador>> _cargarPlantilla() {
    return (db.select(db.jugadores)
          ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false))
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
      body: FutureBuilder<List<Jugador>>(
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
                subtitle: Text('${etiquetaPosicion(j)} · ${j.edad} años'),
                trailing: Text('Media ${j.media}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () =>
                    abrirFichaDeJugador(context, db, j.id, equipoUsuario),
              );
            },
          );
        },
      ),
    );
  }

}

/// Abre la ficha del jugador [jugadorId]: estadísticas de la temporada,
/// contrato y, si no es tuyo, un botón para que el buscador automático
/// intente traspasarlo. La usan tanto la plantilla de un equipo
/// (Clasificación) como la lista de líderes de estadísticas.
Future<void> abrirFichaDeJugador(
  BuildContext context,
  AppDatabase db,
  int jugadorId,
  String equipoUsuario,
) async {
  final jugador = await (db.select(db.jugadores)
        ..where((t) => t.id.equals(jugadorId)))
      .getSingleOrNull();
  if (jugador == null) return;
  final stats = await (db.select(db.estadisticasTemporadaJugador)
        ..where((t) => t.jugadorId.equals(jugadorId)))
      .getSingleOrNull();
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _FichaDeJugador(
      db: db,
      jugador: jugador,
      stats: stats,
      equipoUsuario: equipoUsuario,
    ),
  );
}

class _FichaDeJugador extends StatefulWidget {
  final AppDatabase db;
  final Jugador jugador;
  final EstadisticasTemporadaJugadorData? stats;
  final String equipoUsuario;

  const _FichaDeJugador({
    required this.db,
    required this.jugador,
    required this.stats,
    required this.equipoUsuario,
  });

  @override
  State<_FichaDeJugador> createState() => _FichaDeJugadorState();
}

class _FichaDeJugadorState extends State<_FichaDeJugador> {
  bool _buscando = false;

  Future<void> _intentarTraspasar() async {
    if (_buscando) return;
    setState(() => _buscando = true);
    final propuestas = await buscarFichajeDe(
      widget.db,
      equipoUsuario: widget.equipoUsuario,
      jugadorObjetivoId: widget.jugador.id,
    );
    if (!mounted) return;
    setState(() => _buscando = false);

    final elegida = await showModalBottomSheet<PropuestaTraspaso>(
      context: context,
      isScrollControlled: true,
      builder: (context) => HojaDePropuestas(
        titulo: '¿Cómo fichar a ${widget.jugador.nombreFicticio}?',
        vacio: 'No tienes con qué convencerles ahora mismo: ni tu plantilla '
            'ni tus picks les llegan sin dejarte roto.',
        propuestas: propuestas,
      ),
    );
    if (elegida == null || !mounted) return;

    final hecho = await ejecutarTraspaso(
      widget.db,
      equipoUsuario: widget.equipoUsuario,
      equipoRival: elegida.equipoRival,
      tuyos: elegida.idsQueSalen,
      suyos: elegida.idsQueLlegan,
      tusPicks: elegida.idsPicksQueSalen,
      susPicks: elegida.idsPicksQueLlegan,
    );
    if (!mounted) return;
    if (!hecho) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Ya ha pasado la fecha límite de traspasos: no se '
              'pueden cerrar más operaciones esta temporada.')));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Traspaso cerrado con ${elegida.equipoRival}.')));
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.jugador;
    final stats = widget.stats;
    final esTuyo = j.equipo == widget.equipoUsuario;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EquipoLogo(codigoEquipo: j.equipo, tamano: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(j.nombreFicticio,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${etiquetaPosicion(j)} · ${j.edad} años · '
                          'media ${j.media}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats != null && stats.partidosJugados > 0)
              _Fila(
                etiqueta: 'Esta temporada',
                valor: '${(stats.puntosTotales / stats.partidosJugados).toStringAsFixed(1)} pts · '
                    '${(stats.asistenciasTotales / stats.partidosJugados).toStringAsFixed(1)} ast · '
                    '${(stats.rebotesTotales / stats.partidosJugados).toStringAsFixed(1)} reb '
                    '(${stats.partidosJugados} PJ)',
              )
            else
              const _Fila(
                  etiqueta: 'Esta temporada', valor: 'Todavía no ha jugado'),
            _Fila(
              etiqueta: 'Contrato',
              valor: '${formatearSalario(j.salario)}/año · '
                  '${j.aniosContrato} '
                  '${j.aniosContrato == 1 ? "temporada" : "temporadas"}',
            ),
            const SizedBox(height: 20),
            if (!esTuyo)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _buscando ? null : _intentarTraspasar,
                  icon: _buscando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.swap_horiz),
                  label: const Text('Intentar traspasar'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Fila({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(etiqueta,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline)),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
