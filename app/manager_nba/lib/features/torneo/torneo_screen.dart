import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/torneo_repository.dart';
import '../../shared/campeon_dialog.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import '../partido/serie_boxscores_screen.dart';

/// NBA Cup: cuartos de final -> semifinal -> final, conferencias separadas
/// hasta la final, todo partidos únicos. Se ve como un cuadro de verdad —el
/// Oeste a un lado, el Este al otro y la Final en el centro—, igual que el
/// de playoffs, porque es la misma clase de eliminatoria.
///
/// Es una pantalla de consulta, no de juego: cuartos y semifinal cuentan
/// para la temporada regular y se resuelven solos en cuanto termina la fase
/// de grupos, y la Final o la juegas desde tu calendario (si eres
/// finalista, se te programa como un día más) o se juega sola y te llega el
/// aviso del campeón mientras simulas. Aquí solo se ve el cuadro y se abren
/// las estadísticas de cada partido.
class TorneoScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const TorneoScreen({super.key, required this.db, required this.equipoUsuario});

  @override
  State<TorneoScreen> createState() => _TorneoScreenState();
}

class _TorneoScreenState extends State<TorneoScreen> {
  late final Future<List<SerieTorneo>> _seriesFuture =
      leerSeriesTorneo(widget.db);
  String? _temporada;

  @override
  void initState() {
    super.initState();
    _cargarTemporada();
  }

  Future<void> _cargarTemporada() async {
    final temporada = await leerTemporada(widget.db);
    if (!mounted) return;
    setState(() => _temporada = etiquetaDeTemporada(temporada.anioInicio));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraDeClub(widget.equipoUsuario, t(context).nbaCup),
      body: FutureBuilder<List<SerieTorneo>>(
        future: _seriesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final series = snapshot.data!;
          if (series.isEmpty) {
            return Center(
                child: Text(t(context)
                    .cuartosCopaSeSiembranAviso(t(context).nbaCup)));
          }

          final finalCup =
              series.where((s) => s.conferencia == 'Final').firstOrNull;

          return Column(
            children: [
              if (finalCup?.ganador != null)
                BannerCampeon(
                  esCup: true,
                  campeon: finalCup!.ganador!,
                  esTuEquipo: finalCup.ganador == widget.equipoUsuario,
                  temporada: _temporada,
                )
              else
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    t(context).finalSeJuegaDesdeCalendarioAviso,
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _BracketCopa(
                      db: widget.db,
                      series: series,
                      equipoUsuario: widget.equipoUsuario,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// El cuadro de la Copa: dos cuartos y una semifinal por conferencia, con la
/// Final en el centro. Mismo dibujo que el bracket de playoffs (cajas
/// posicionadas y líneas a mano) pero con dos rondas por lado en vez de tres.
class _BracketCopa extends StatelessWidget {
  final AppDatabase db;
  final List<SerieTorneo> series;
  final String equipoUsuario;

  const _BracketCopa({
    required this.db,
    required this.series,
    required this.equipoUsuario,
  });

  static const _boxWidth = 176.0;
  static const _boxHeight = 62.0;
  static const _slot = 96.0;
  static const _connector = 28.0;
  static const _colWidth = _boxWidth + _connector;

  SerieTorneo? _buscar(String conferencia, String etapa) => series
      .where((s) => s.conferencia == conferencia && s.etapa == etapa)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    const altura = 2 * _slot;
    const finalX = 2 * _colWidth;
    const anchoTotal = 4 * _colWidth + _boxWidth;
    const centro = altura / 2;
    final lineColor = Theme.of(context).colorScheme.outlineVariant;

    final cuartosOeste = [
      _buscar('Oeste', 'cuartos_a'),
      _buscar('Oeste', 'cuartos_b'),
    ];
    final cuartosEste = [
      _buscar('Este', 'cuartos_a'),
      _buscar('Este', 'cuartos_b'),
    ];

    Widget caja(SerieTorneo? serie, double x, double y,
        {required String etiquetaVacia}) {
      return Positioned(
        left: x,
        top: y - _boxHeight / 2,
        width: _boxWidth,
        height: _boxHeight,
        child: _CajaCopa(
          key: serie == null ? null : ValueKey('copa-${serie.id}'),
          db: db,
          serie: serie,
          equipoUsuario: equipoUsuario,
          etiquetaVacia: etiquetaVacia,
        ),
      );
    }

    final cajas = <Widget>[
      for (var i = 0; i < 2; i++)
        caja(cuartosOeste[i], 0, _slot / 2 + i * _slot,
            etiquetaVacia: t(context).cuartosDeFinalLabel),
      caja(_buscar('Oeste', 'semis'), _colWidth, centro,
          etiquetaVacia: t(context).semifinalLabel),
      caja(_buscar('Final', 'final'), finalX, centro,
          etiquetaVacia: t(context).finalDeLaCopaLabel(t(context).nbaCup)),
      caja(_buscar('Este', 'semis'), finalX + _colWidth, centro,
          etiquetaVacia: t(context).semifinalLabel),
      for (var i = 0; i < 2; i++)
        caja(cuartosEste[i], finalX + 2 * _colWidth, _slot / 2 + i * _slot,
            etiquetaVacia: t(context).cuartosDeFinalLabel),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: anchoTotal,
          child: Column(
            children: [
              Row(
                children: [
                  _TituloConferenciaCopa(
                      conferencia: 'Oeste', ancho: 2 * _colWidth),
                  SizedBox(
                    width: _boxWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Icon(Icons.military_tech,
                          size: 18, color: Color(0xFFB07D2B)),
                    ),
                  ),
                  _TituloConferenciaCopa(
                      conferencia: 'Este', ancho: 2 * _colWidth),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  SizedBox(
                      width: _colWidth,
                      child: _RondaCopa(t(context).cuartosRondaLabel)),
                  SizedBox(
                      width: _colWidth,
                      child: _RondaCopa(t(context).semifinalLabel)),
                  SizedBox(
                      width: _boxWidth,
                      child: _RondaCopa(t(context).finalRondaLabel)),
                  SizedBox(
                      width: _colWidth,
                      child: _RondaCopa(t(context).semifinalLabel)),
                  SizedBox(
                      width: _colWidth,
                      child: _RondaCopa(t(context).cuartosRondaLabel)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: anchoTotal,
          height: altura,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(anchoTotal, altura),
                painter: _ConectorCopa(
                  boxWidth: _boxWidth,
                  colWidth: _colWidth,
                  slot: _slot,
                  finalX: finalX,
                  centro: centro,
                  color: lineColor,
                ),
              ),
              ...cajas,
            ],
          ),
        ),
      ],
    );
  }
}

class _ConectorCopa extends CustomPainter {
  final double boxWidth;
  final double colWidth;
  final double slot;
  final double finalX;
  final double centro;
  final Color color;

  const _ConectorCopa({
    required this.boxWidth,
    required this.colWidth,
    required this.slot,
    required this.finalX,
    required this.centro,
    required this.color,
  });

  /// La horquilla que une dos cajas de una ronda con la única de la
  /// siguiente: dos tramos horizontales, el vertical que los junta y la
  /// salida hacia la caja de destino.
  void _horquilla(Canvas canvas, Paint paint, double xIzq, double yA,
      double yB, double xDer) {
    final xMid = (xIzq + xDer) / 2;
    canvas.drawLine(Offset(xIzq, yA), Offset(xMid, yA), paint);
    canvas.drawLine(Offset(xIzq, yB), Offset(xMid, yB), paint);
    canvas.drawLine(Offset(xMid, yA), Offset(xMid, yB), paint);
    canvas.drawLine(Offset(xMid, centro), Offset(xDer, centro), paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final yArriba = slot / 2;
    final yAbajo = slot / 2 + slot;

    // Oeste: cuartos -> semifinal -> final.
    _horquilla(canvas, paint, boxWidth, yArriba, yAbajo, colWidth);
    canvas.drawLine(
        Offset(colWidth + boxWidth, centro), Offset(finalX, centro), paint);

    // Este, en espejo.
    final semisEsteX = finalX + colWidth;
    final cuartosEsteX = finalX + 2 * colWidth;
    canvas.drawLine(
        Offset(finalX + boxWidth, centro), Offset(semisEsteX, centro), paint);
    _horquilla(
        canvas, paint, cuartosEsteX, yArriba, yAbajo, semisEsteX + boxWidth);
  }

  @override
  bool shouldRepaint(covariant _ConectorCopa oldDelegate) => false;
}

class _TituloConferenciaCopa extends StatelessWidget {
  final String conferencia;
  final double ancho;

  const _TituloConferenciaCopa(
      {required this.conferencia, required this.ancho});

  @override
  Widget build(BuildContext context) {
    final info = infoDe(conferencia);
    return Container(
      width: ancho,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: info.colorPrimario,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        conferencia == 'Oeste'
            ? t(context).tituloConferenciaOeste
            : t(context).tituloConferenciaEste,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: textoSobre(info.colorPrimario),
        ),
      ),
    );
  }
}

class _RondaCopa extends StatelessWidget {
  final String texto;

  const _RondaCopa(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style:
          TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.outline),
    );
  }
}

class _CajaCopa extends StatelessWidget {
  final AppDatabase db;
  final SerieTorneo? serie;
  final String equipoUsuario;
  final String etiquetaVacia;

  const _CajaCopa({
    super.key,
    required this.db,
    required this.serie,
    required this.equipoUsuario,
    required this.etiquetaVacia,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    final serie = this.serie;
    if (serie == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(etiquetaVacia,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: borderColor)),
      );
    }

    final esTuSerie =
        serie.equipoA == equipoUsuario || serie.equipoB == equipoUsuario;
    return InkWell(
      onTap: serie.ganador == null
          ? null
          : () => abrirEstadisticasDeSerie(context, db,
              origen: 'torneo', serieId: serie.id),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: esTuSerie
                  ? Theme.of(context).colorScheme.primary
                  : borderColor,
              width: esTuSerie ? 2 : 1),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _fila(context, serie.equipoA),
            _fila(context, serie.equipoB),
            if (serie.ganador == null)
              Text(t(context).pendienteLabel,
                  style: TextStyle(fontSize: 9, color: borderColor)),
          ],
        ),
      ),
    );
  }

  Widget _fila(BuildContext context, String equipo) {
    final gana = serie!.ganador == equipo;
    final perdio = serie!.ganador != null && !gana;
    return Row(
      children: [
        EquipoLogo(codigoEquipo: equipo, tamano: 16),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            infoDe(equipo).apodo,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: gana ? FontWeight.bold : FontWeight.normal,
              decoration: perdio ? TextDecoration.lineThrough : null,
              color: perdio ? Theme.of(context).colorScheme.outline : null,
            ),
          ),
        ),
        if (gana) const Icon(Icons.check, size: 13, color: Colors.green),
      ],
    );
  }
}
