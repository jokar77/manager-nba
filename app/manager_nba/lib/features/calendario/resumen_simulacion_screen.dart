import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/estilo.dart';
import '../../shared/icono_lesion.dart';

import '../../data/database/app_database.dart';
import '../../domain/calendario_repository.dart';
import '../../shared/navegacion.dart';
import '../partido/boxscore_screen.dart';
import '../premios/premios_screen.dart';
import '../temporada/resumen_temporada_screen.dart';
import 'simulacion_ui.dart';

/// Resumen de los partidos simulados en el último lote, con acceso al
/// boxscore completo de cada uno. Tiene sus propios botones de avance
/// rápido para poder seguir simulando sin volver al calendario.
class ResumenSimulacionScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final ResultadoLoteSimulado resultado;

  const ResumenSimulacionScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    required this.resultado,
  });

  @override
  State<ResumenSimulacionScreen> createState() => _ResumenSimulacionScreenState();
}

class _ResumenSimulacionScreenState extends State<ResumenSimulacionScreen> {
  late ResultadoLoteSimulado _resultado;
  bool _simulando = false;
  int _totalASimular = 0;
  List<PartidoSimuladoInfo> _progresoSimulacion = const [];
  bool _premiosMostrados = false;

  @override
  void initState() {
    super.initState();
    _resultado = widget.resultado;
    WidgetsBinding.instance.addPostFrameCallback((_) => _irAPremiosSiToca());
  }

  Future<void> _simularHasta(DateTime diaObjetivo) async {
    // Una consulta más para saber cuántos segmentos pintar: esta pantalla
    // no guarda el calendario entero como hace el Calendario, así que no
    // hay otro sitio de donde sacar el total antes de empezar.
    final partidos = await leerPartidos(widget.db, widget.equipoUsuario);
    if (!mounted) return;
    setState(() {
      _simulando = true;
      _totalASimular = partidosPendientesHasta(partidos, diaObjetivo);
      _progresoSimulacion = const [];
    });
    final nuevo = await simularHastaConDialogo(
        context, widget.db, widget.equipoUsuario, diaObjetivo,
        onProgreso: (hastaAhora) {
      if (mounted) setState(() => _progresoSimulacion = hastaAhora);
    });
    if (!mounted) return;
    setState(() {
      _simulando = false;
      if (nuevo.partidos.isNotEmpty) _resultado = nuevo;
    });
    await _irAPremiosSiToca();
  }

  /// Encadena automáticamente al resumen de los últimos partidos jugados
  /// (esta misma pantalla) con el balance del año y los premios de fin de
  /// temporada, en cuanto se detecta que tu temporada regular se acaba de
  /// completar — sin necesidad de que el usuario navegue a mano. Solo se
  /// dispara una vez.
  ///
  /// El balance va primero: antes se saltaba directo a los premios y no
  /// quedaba ningún sitio donde ver qué había pasado en tus 82 partidos.
  Future<void> _irAPremiosSiToca() async {
    if (_premiosMostrados || !_resultado.temporadaTerminada || !mounted) return;
    _premiosMostrados = true;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ResumenTemporadaScreen(
        db: widget.db,
        equipoUsuario: widget.equipoUsuario,
        textoBoton: t(context).verLosPremios,
        onContinuar: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PremiosScreen(
              db: widget.db,
              equipoUsuario: widget.equipoUsuario,
              calendarioEnPila: true,
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final partidos = _resultado.partidos;
    // Cuántas has ganado en el tramo: simulando un mes entero, contar los
    // marcadores a ojo para saber cómo te ha ido no es razonable.
    final ganados =
        partidos.where((p) => p.marcadorUsuario > p.marcadorRival).length;
    final perdidos = partidos.length - ganados;

    return Scaffold(
      appBar: barraDeClub(
        widget.equipoUsuario,
        partidos.isEmpty
            ? t(context).sinPartidosTitulo
            : t(context).resumenPartidos(partidos.length, ganados, perdidos),
        acciones: const [BotonMenuPrincipal()],
      ),
      body: Column(
        children: [
          if (_simulando)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: BarraProgresoSimulacion(
                total: _totalASimular,
                resultados: _progresoSimulacion
                    .map((p) => p.marcadorUsuario >= p.marcadorRival)
                    .toList(),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              children: [
                if (_resultado.lesionesActivas.isNotEmpty) ...[
                  _AvisoDeLesiones(lesiones: _resultado.lesionesActivas),
                  const SizedBox(height: 12),
                ],
                for (final p in partidos) ...[
                  _FilaDePartido(
                    partido: p,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          BoxscoreScreen(boxscore: p.boxscore),
                    )),
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: BotonPerfilado(
                    texto: t(context).simularUnPartido,
                    color: e.texto,
                    alto: 44,
                    onTap: _simulando
                        ? null
                        : () async {
                            final partidosActuales = await leerPartidos(
                                widget.db, widget.equipoUsuario);
                            final proximo =
                                proximaFechaPendiente(partidosActuales);
                            if (proximo != null) _simularHasta(proximo);
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BotonPerfilado(
                    texto: t(context).simularUnaSemana,
                    color: e.texto,
                    alto: 44,
                    onTap: _simulando
                        ? null
                        : () async {
                            final partidosActuales = await leerPartidos(
                                widget.db, widget.equipoUsuario);
                            _simularHasta(
                                fechaActualDeLaTemporada(partidosActuales)
                                    .add(const Duration(days: 7)));
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BotonPerfilado(
                    texto: t(context).simularUnMes,
                    color: e.texto,
                    alto: 44,
                    onTap: _simulando
                        ? null
                        : () async {
                            final partidosActuales = await leerPartidos(
                                widget.db, widget.equipoUsuario);
                            _simularHasta(
                                fechaActualDeLaTemporada(partidosActuales)
                                    .add(const Duration(days: 30)));
                          },
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

/// Quién se ha quedado fuera y hasta cuándo. Va arriba del todo: enterarte
/// de una lesión tres pantallas después es enterarte tarde.
class _AvisoDeLesiones extends StatelessWidget {
  final List<LesionActivaInfo> lesiones;

  const _AvisoDeLesiones({required this.lesiones});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return PanelCortado(
      fondo: e.mal.withValues(alpha: 0.10),
      corte: 12,
      borde: Border(left: BorderSide(color: e.mal, width: 3)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconoLesion(tamano: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(mayus(t(context).lesionesActivasAhora),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: rotulo(e, tamano: 10, color: e.mal)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final l in lesiones)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mayus(l.nombreJugador),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titular(e, tamano: 15)),
                    Text(
                      '${l.motivo} · ${l.partidosEstimados} · '
                      '${_formatearFecha(l.vuelve)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: e.textoTenue),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Un partido del lote: el filo de color dice si ganaste antes de que leas
/// el marcador.
class _FilaDePartido extends StatelessWidget {
  final PartidoSimuladoInfo partido;
  final VoidCallback onTap;

  const _FilaDePartido({required this.partido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final gana = partido.marcadorUsuario >= partido.marcadorRival;
    final color = gana ? e.bien : e.mal;
    // Orden real local-visitante, no "tu equipo primero": si jugaste fuera,
    // el rival aparece primero aunque hayas ganado — igual que en el
    // diálogo de partido ya jugado del calendario.
    final ganaLocal =
        partido.boxscore.marcadorLocal >= partido.boxscore.marcadorVisitante;

    Widget lado(String equipo, bool destacado) => Expanded(
          child: Row(
            mainAxisAlignment:
                destacado ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!destacado) ...[
                EquipoLogo(codigoEquipo: equipo, tamano: 22),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(mayus(equipo),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign:
                        destacado ? TextAlign.right : TextAlign.left,
                    style: titular(e,
                        tamano: 16,
                        color: destacado ? e.texto : e.textoTenue)),
              ),
              if (destacado) ...[
                const SizedBox(width: 7),
                EquipoLogo(codigoEquipo: equipo, tamano: 22),
              ],
            ],
          ),
        );

    return PanelCortado(
      fondo: color.withValues(alpha: 0.12),
      corte: 11,
      borde: Border(left: BorderSide(color: color, width: 3)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 9),
            child: Column(
              children: [
                Text(_formatearFecha(partido.fecha),
                    style: rotulo(e, tamano: 9)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    lado(partido.boxscore.equipoLocal, ganaLocal),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${partido.boxscore.marcadorLocal}-'
                        '${partido.boxscore.marcadorVisitante}',
                        style: cifra(e, tamano: 22),
                      ),
                    ),
                    lado(partido.boxscore.equipoVisitante, !ganaLocal),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatearFecha(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}
