import 'package:flutter/material.dart';

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
  bool _premiosMostrados = false;

  @override
  void initState() {
    super.initState();
    _resultado = widget.resultado;
    WidgetsBinding.instance.addPostFrameCallback((_) => _irAPremiosSiToca());
  }

  Future<void> _simularHasta(DateTime diaObjetivo) async {
    setState(() => _simulando = true);
    final nuevo = await simularHastaConDialogo(
        context, widget.db, widget.equipoUsuario, diaObjetivo);
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
        textoBoton: 'Ver los premios',
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
    final partidos = _resultado.partidos;
    // Cuántas has ganado en el tramo: simulando un mes entero, contar los
    // marcadores a ojo para saber cómo te ha ido no es razonable.
    final ganados =
        partidos.where((p) => p.marcadorUsuario > p.marcadorRival).length;
    final perdidos = partidos.length - ganados;
    return Scaffold(
      appBar: AppBar(
        title: Text(partidos.isEmpty
            ? 'Sin partidos'
            : '${partidos.length} partidos · $ganados-$perdidos'),
        actions: const [BotonMenuPrincipal()],
      ),
      body: Column(
        children: [
          if (_simulando) const LinearProgressIndicator(),
          Expanded(
            child: ListView(
              children: [
                if (_resultado.lesionesActivas.isNotEmpty)
                  Container(
                    width: double.infinity,
                    // Rojo translúcido (no un rosa fijo): así el texto por
                    // defecto del tema — claro en modo oscuro, oscuro en
                    // modo claro — siempre tiene contraste suficiente. El
                    // fondo fijo de antes se quedaba claro también en modo
                    // oscuro y el texto (heredado, claro) era casi
                    // ilegible.
                    color: Colors.red.withValues(alpha: 0.12),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const IconoLesion(),
                            const SizedBox(width: 8),
                            Text('Lesiones activas ahora mismo',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ..._resultado.lesionesActivas.map((l) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: IconoLesion(tamano: 14),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${l.nombreJugador}: ${l.motivo} '
                                      '(${l.partidosEstimados} partidos, '
                                      'vuelve el '
                                      '${_formatearFecha(l.vuelve)})',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ...partidos.map((p) {
                  final gana = p.marcadorUsuario >= p.marcadorRival;
                  // Verde/rojo translúcido: funciona igual sobre fondo claro
                  // u oscuro sin necesidad de ramificar por Brightness.
                  final colorResultado = (gana ? Colors.green : Colors.red)
                      .withValues(alpha: 0.18);
                  // Orden real local-visitante, no "tu equipo primero": si
                  // jugaste fuera, el rival aparece primero aunque hayas
                  // ganado — igual que en el diálogo de partido ya jugado
                  // del calendario.
                  final ganaLocal =
                      p.boxscore.marcadorLocal >= p.boxscore.marcadorVisitante;
                  return InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BoxscoreScreen(boxscore: p.boxscore),
                    )),
                    child: Container(
                      width: double.infinity,
                      color: colorResultado,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Text(
                            _formatearFecha(p.fecha),
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                p.boxscore.equipoLocal,
                                style: TextStyle(
                                  fontWeight: ganaLocal
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${p.boxscore.marcadorLocal} - '
                                '${p.boxscore.marcadorVisitante}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                p.boxscore.equipoVisitante,
                                style: TextStyle(
                                  fontWeight: !ganaLocal
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _simulando
                        ? null
                        : () async {
                            final partidosActuales =
                                await leerPartidos(widget.db, widget.equipoUsuario);
                            final proximo = proximaFechaPendiente(partidosActuales);
                            if (proximo != null) _simularHasta(proximo);
                          },
                    child: const Text('Simular 1 partido'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _simulando
                        ? null
                        : () async {
                            final partidosActuales =
                                await leerPartidos(widget.db, widget.equipoUsuario);
                            _simularHasta(fechaActualDeLaTemporada(partidosActuales)
                                .add(const Duration(days: 7)));
                          },
                    child: const Text('Simular 1 semana'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _simulando
                        ? null
                        : () async {
                            final partidosActuales =
                                await leerPartidos(widget.db, widget.equipoUsuario);
                            _simularHasta(fechaActualDeLaTemporada(partidosActuales)
                                .add(const Duration(days: 30)));
                          },
                    child: const Text('Simular 1 mes'),
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

String _formatearFecha(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
}
