import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/contratos_repository.dart';
import '../../domain/posiciones.dart';
import '../../domain/salarios.dart';

/// Los contratos de tu equipo que se acaban. Por cada uno se puede ofrecer
/// sueldo y años; el jugador acepta o no según lo que pida, y cada negativa
/// le deja peor predispuesto. A la tercera se acabó la negociación y se va
/// a la agencia libre.
class RenovacionesScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final VoidCallback onContinuar;

  const RenovacionesScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    required this.onContinuar,
  });

  @override
  State<RenovacionesScreen> createState() => _RenovacionesScreenState();
}

class _RenovacionesScreenState extends State<RenovacionesScreen> {
  List<Jugador> _vencen = [];
  int _espacio = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    final vencen = await contratosQueVencen(widget.db, widget.equipoUsuario);
    final espacio = await espacioSalarial(widget.db, widget.equipoUsuario);
    if (!mounted) return;
    setState(() {
      _vencen = vencen;
      _espacio = espacio;
      _cargando = false;
    });
  }

  Future<void> _negociar(Jugador jugador) async {
    final respuesta = await showDialog<RespuestaOferta>(
      context: context,
      builder: (context) => _DialogoDeOferta(db: widget.db, jugador: jugador),
    );
    if (respuesta == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(respuesta.mensaje)));
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Renovaciones'),
        automaticallyImplyLeading: false,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _BarraDeTope(espacio: _espacio),
                Expanded(
                  child: _vencen.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No se te acaba ningún contrato: la plantilla '
                              'sigue atada un año más.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(12),
                          children: _vencen
                              .map((j) => _FilaRenovacion(
                                    jugador: j,
                                    onNegociar: () => _negociar(j),
                                  ))
                              .toList(),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onContinuar,
            child: Text(_vencen.isEmpty
                ? 'Continuar'
                : 'Continuar (${_vencen.length} se van a la agencia libre)'),
          ),
        ),
      ),
    );
  }
}

class _BarraDeTope extends StatelessWidget {
  final int espacio;

  const _BarraDeTope({required this.espacio});

  @override
  Widget build(BuildContext context) {
    final pasado = espacio < 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: (pasado ? Colors.red : Colors.green).withValues(alpha: 0.15),
      child: Text(
        pasado
            ? 'Estás ${formatearSalario(-espacio)} por encima del tope: solo '
                'puedes ofrecer contratos del mínimo.'
            : 'Te quedan ${formatearSalario(espacio)} bajo el tope de '
                '${formatearSalario(topeSalarial)}.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _FilaRenovacion extends StatelessWidget {
  final Jugador jugador;
  final VoidCallback onNegociar;

  const _FilaRenovacion({required this.jugador, required this.onNegociar});

  @override
  Widget build(BuildContext context) {
    final pide = valorDeMercado(jugador);
    final ofertasRestantes = maxOfertasDeRenovacion - jugador.ofertasRechazadas;
    final sinOfertas = ofertasRestantes <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(jugador.nombreFicticio,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${etiquetaPosicion(jugador)} · ${jugador.edad} años · '
            'media ${jugador.media}\n'
            'Cobraba ${formatearSalario(jugador.salario)} · '
            'pide ${formatearSalario(pide)}'),
        isThreeLine: true,
        trailing: sinOfertas
            ? const Text('Se acabó\nla negociación',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: Colors.red))
            : FilledButton(
                onPressed: onNegociar,
                child: Text('Ofrecer ($ofertasRestantes)'),
              ),
      ),
    );
  }
}

/// Diálogo de oferta: sueldo y años, con el precio que pide como
/// referencia para no ir a ciegas.
class _DialogoDeOferta extends StatefulWidget {
  final AppDatabase db;
  final Jugador jugador;

  const _DialogoDeOferta({required this.db, required this.jugador});

  @override
  State<_DialogoDeOferta> createState() => _DialogoDeOfertaState();
}

class _DialogoDeOfertaState extends State<_DialogoDeOferta> {
  late double _salario = valorDeMercado(widget.jugador).toDouble();
  late int _anios = aniosContratoEstimados(edad: widget.jugador.edad);
  bool _enviando = false;

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    final respuesta = await ofrecerRenovacion(
      widget.db,
      widget.jugador.id,
      salario: _salario.round(),
      anios: _anios,
    );
    if (!mounted) return;
    Navigator.of(context).pop(respuesta);
  }

  @override
  Widget build(BuildContext context) {
    final pide = valorDeMercado(widget.jugador);
    final ratio = _salario / pide;
    final probabilidad = probabilidadDeAceptar(
      salario: _salario.round(),
      pedido: pide,
      anios: _anios,
      edad: widget.jugador.edad,
      ofertasRechazadas: widget.jugador.ofertasRechazadas,
    );

    return AlertDialog(
      title: Text('Oferta a ${widget.jugador.nombreFicticio}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pide ${formatearSalario(pide)} al año',
              style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 16),
          Text('Sueldo: ${formatearSalario(_salario.round())}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _salario,
            min: salarioMinimo.toDouble(),
            max: (pide * 1.6).clamp(salarioMinimo * 2, salarioMaximo).toDouble(),
            onChanged: _enviando ? null : (v) => setState(() => _salario = v),
          ),
          // Altura fija: este texto cambia de una a dos líneas según lo que
          // ofrezcas, y sin reservarle el sitio el diálogo entero pegaba un
          // salto cada vez que movías el slider.
          SizedBox(
            height: 32,
            child: Text(
              ratio < 0.75
                  ? 'Se lo va a tomar como un insulto.'
                  : probabilidad < 0.25
                      ? 'Muy improbable que la acepte así: el sueldo, los años '
                          'o ambos se quedan cortos.'
                      : probabilidad < 0.6
                          ? 'Se lo puede pensar; no las tiene todas consigo.'
                          : probabilidad < 0.9
                              ? 'Es probable que acepte.'
                              : 'Prácticamente seguro que dice que sí.',
              style: TextStyle(
                fontSize: 12,
                color: ratio < 0.75 || probabilidad < 0.25
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Años: '),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _enviando || _anios <= 1
                    ? null
                    : () => setState(() => _anios--),
              ),
              Text('$_anios',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _enviando || _anios >= 5
                    ? null
                    : () => setState(() => _anios++),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando ? null : _enviar,
          child: const Text('Ofrecer'),
        ),
      ],
    );
  }
}
