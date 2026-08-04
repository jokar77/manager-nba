import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/ofertas_repository.dart';
import '../../domain/picks_repository.dart';
import '../../domain/posiciones.dart';
import '../../shared/equipo_logo.dart';
import 'traspasos_screen.dart';

/// Las propuestas que te han llegado mientras simulabas. Cada una es un
/// traspaso cerrado: el equipo que la manda ya ha dicho que sí, así que
/// aceptarla lo ejecuta en el momento.
///
/// Y si no te convence tal cual, no hay que elegir entre tragar o tirarla:
/// "Contraofertar" la abre en la mesa de traspasos con las piezas ya
/// puestas, para quitar, añadir o meter a un tercer equipo y volver a
/// proponerla.
class OfertasScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const OfertasScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  State<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen> {
  List<OfertaEntrante>? _ofertas;

  /// Cuál se está mirando. Se recorta contra el total al pintar, porque
  /// aceptar o rechazar la última hace que la lista encoja bajo los pies.
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    await marcarOfertasComoVistas(widget.db);
    final ofertas = await ofertasPendientes(widget.db, widget.equipoUsuario);
    if (!mounted) return;
    setState(() {
      _ofertas = ofertas;
      if (_indice >= ofertas.length) _indice = 0;
    });
  }

  Future<void> _aceptar(OfertaEntrante oferta) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerramos el traspaso?'),
        content: Text('Se van ${oferta.resumenQuePiden} y llegan '
            '${oferta.resumenQueOfrecen}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    await aceptarOferta(widget.db, oferta,
        equipoUsuario: widget.equipoUsuario);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Traspaso cerrado con ${oferta.equipoOfertante}.')));
    await _cargar();
  }

  Future<void> _rechazar(OfertaEntrante oferta) async {
    await rechazarOferta(widget.db, oferta.id);
    await _cargar();
  }

  /// Abre la oferta en la mesa de traspasos para retocarla. La oferta se
  /// queda en la bandeja: si la contrapropuesta no cuaja, la original sigue
  /// ahí para aceptarla tal cual.
  Future<void> _contraofertar(OfertaEntrante oferta) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => TraspasosScreen(
        db: widget.db,
        equipoUsuario: widget.equipoUsuario,
        propuestaInicial: PropuestaDePartida(
          equipoRival: oferta.equipoOfertante,
          tusJugadores: oferta.tePiden.map((j) => j.id).toList(),
          susJugadores: oferta.teOfrecen.map((j) => j.id).toList(),
          susPicks: oferta.teOfrecenPicks.map((p) => p.id).toList(),
        ),
      ),
    ));
    if (!mounted) return;
    // Al volver puede que el traspaso se haya cerrado por otro camino: se
    // relee la bandeja, que ya limpia sola lo que se ha quedado obsoleto.
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final ofertas = _ofertas;
    return Scaffold(
      appBar: AppBar(title: const Text('Ofertas recibidas')),
      body: ofertas == null
          ? const Center(child: CircularProgressIndicator())
          : ofertas.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Ahora mismo nadie te ha pedido nada. Sigue simulando: '
                      'las ofertas llegan durante la temporada.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              // De una en una: cada oferta es una decisión, y verlas todas
              // apiladas en una lista invitaba a pasar de largo. Con las
              // flechas se van repasando como quien pasa carpetas.
              : Column(
                  children: [
                    _Navegador(
                      indice: _indice.clamp(0, ofertas.length - 1),
                      total: ofertas.length,
                      onAnterior: () => setState(() => _indice--),
                      onSiguiente: () => setState(() => _indice++),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Builder(builder: (context) {
                          final actual =
                              ofertas[_indice.clamp(0, ofertas.length - 1)];
                          return _TarjetaOferta(
                            oferta: actual,
                            onAceptar: () => _aceptar(actual),
                            onRechazar: () => _rechazar(actual),
                            onContraofertar: () => _contraofertar(actual),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// "Oferta 2 de 5", con sus flechas. Sin envolver: si solo hay una, no hay
/// nada que navegar.
class _Navegador extends StatelessWidget {
  final int indice;
  final int total;
  final VoidCallback onAnterior;
  final VoidCallback onSiguiente;

  const _Navegador({
    required this.indice,
    required this.total,
    required this.onAnterior,
    required this.onSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            onPressed: indice > 0 ? onAnterior : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Oferta anterior',
          ),
          Text('Oferta ${indice + 1} de $total',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton.filledTonal(
            onPressed: indice < total - 1 ? onSiguiente : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Oferta siguiente',
          ),
        ],
      ),
    );
  }
}

/// Un jugador de la oferta con lo que hace falta para juzgarla: quién es,
/// dónde juega, su nivel y lo que produce por partido. Sin los promedios,
/// decidir un traspaso era comparar dos números de media a ciegas.
String _lineaJugador(Jugador j) =>
    '${j.nombreFicticio} · ${etiquetaPosicion(j)} · ${j.media} · '
    '${j.ptsPg.toStringAsFixed(1)} pts, '
    '${j.astPg.toStringAsFixed(1)} ast, '
    '${j.trbPg.toStringAsFixed(1)} reb';

class _TarjetaOferta extends StatelessWidget {
  final OfertaEntrante oferta;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;
  final VoidCallback onContraofertar;

  const _TarjetaOferta({
    required this.oferta,
    required this.onAceptar,
    required this.onRechazar,
    required this.onContraofertar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EquipoLogo(codigoEquipo: oferta.equipoOfertante),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    infoDe(oferta.equipoOfertante).nombreCompleto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _Bloque(
              titulo: 'Te piden',
              icono: Icons.arrow_upward,
              lineas: [for (final j in oferta.tePiden) _lineaJugador(j)],
            ),
            const SizedBox(height: 8),
            _Bloque(
              titulo: 'Te ofrecen',
              icono: Icons.arrow_downward,
              lineas: [
                for (final j in oferta.teOfrecen) _lineaJugador(j),
                for (final p in oferta.teOfrecenPicks) etiquetaDePick(p),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onContraofertar,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Contraofertar'),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRechazar,
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: onAceptar,
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<String> lineas;

  const _Bloque({
    required this.titulo,
    required this.icono,
    required this.lineas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 16),
            const SizedBox(width: 4),
            Text(titulo,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        for (final linea in lineas)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 2),
            child: Text(linea, style: const TextStyle(fontSize: 13)),
          ),
      ],
    );
  }
}
