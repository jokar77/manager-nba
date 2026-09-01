import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/posiciones.dart';
import '../../domain/salarios.dart';
import '../../domain/traspasos_repository.dart';
import '../../shared/equipo_logo.dart';
import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../shared/estilo.dart';
import '../../shared/ficha_jugador.dart';
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
      appBar: barraDeClub(equipo, info.nombreCompleto),
      body: FutureBuilder<List<Jugador>>(
        future: _cargarPlantilla(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final plantilla = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: plantilla.length,
            itemBuilder: (context, i) {
              final j = plantilla[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: FilaDeJugador(
                  media: j.media,
                  nombre: j.nombreFicticio,
                  detalle:
                      '${etiquetaPosicion(j)} · ${t(context).edadJugador(j.edad)}',
                  onTap: () =>
                      abrirFichaDeJugador(context, db, j.id, equipoUsuario),
                ),
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
        titulo: t(context).comoFicharA(widget.jugador.nombreFicticio),
        vacio: t(context).sinConQueConvencerles,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t(context).fechaLimiteTraspasosPasada)));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t(context).traspasoCerradoCon(elegida.equipoRival))));
  }

  @override
  Widget build(BuildContext context) {
    final j = widget.jugador;
    final stats = widget.stats;
    final esTuyo = j.equipo == widget.equipoUsuario;
    final e = Estilo.de(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PlacaMedia(media: j.media, tamano: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mayus(j.nombreFicticio), style: titular(e, tamano: 18)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          EquipoLogo(codigoEquipo: j.equipo, tamano: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${etiquetaPosicion(j)} · '
                              '${t(context).edadJugador(j.edad)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(fontSize: 12, color: e.textoTenue),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (stats != null && stats.partidosJugados > 0)
              _Fila(
                etiqueta: t(context).estaTemporada,
                valor: '${(stats.puntosTotales / stats.partidosJugados).toStringAsFixed(1)} pts · '
                    '${(stats.asistenciasTotales / stats.partidosJugados).toStringAsFixed(1)} ast · '
                    '${(stats.rebotesTotales / stats.partidosJugados).toStringAsFixed(1)} reb '
                    '(${stats.partidosJugados} PJ)',
              )
            else
              _Fila(
                  etiqueta: t(context).estaTemporada,
                  valor: t(context).todaviaNoHaJugado),
            _Fila(
              etiqueta: t(context).contrato,
              valor: '${t(context).alAnio(formatearSalario(j.salario))} · '
                  '${t(context).anios(j.aniosContrato)}',
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
                  label: Text(t(context).intentarTraspasar),
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
    final e = Estilo.de(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(mayus(etiqueta), style: rotulo(e, tamano: 10)),
          ),
          Expanded(child: Text(valor, style: TextStyle(color: e.texto))),
        ],
      ),
    );
  }
}
