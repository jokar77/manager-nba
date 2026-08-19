import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
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
        title: Text(t(context).tituloRenovaciones),
        automaticallyImplyLeading: false,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _BarraDeTope(espacio: _espacio),
                Expanded(
                  child: _vencen.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              t(context).ningunContratoSeAcaba,
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
                ? t(context).continuar
                : t(context).continuarConNAgenciaLibre(_vencen.length)),
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
            ? t(context).porEncimaDelTope(formatearSalario(-espacio))
            : t(context).teQuedanBajoElTope(
                formatearSalario(espacio), formatearSalario(topeSalarial)),
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
        subtitle: Text(t(context).subtituloRenovacion(
            etiquetaPosicion(jugador), jugador.edad, jugador.media,
            formatearSalario(jugador.salario), formatearSalario(pide))),
        isThreeLine: true,
        trailing: sinOfertas
            ? Text(t(context).seAcaboLaNegociacion,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 11, color: Colors.red))
            : FilledButton(
                onPressed: onNegociar,
                child: Text(t(context).ofrecerConN(ofertasRestantes)),
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
      title: Text(t(context).ofertaA(widget.jugador.nombreFicticio)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t(context).pideAlAnio(formatearSalario(pide)),
              style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 16),
          Text(t(context).sueldoLabel(formatearSalario(_salario.round())),
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
                  ? t(context).insultoOferta
                  : probabilidad < 0.25
                      ? t(context).ofertaImprobable
                      : probabilidad < 0.6
                          ? t(context).ofertaSePuedePensar
                          : probabilidad < 0.9
                              ? t(context).ofertaProbableAceptar
                              : t(context).ofertaSeguraAceptar,
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
              Text(t(context).aniosLabelDosPuntos),
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
          child: Text(t(context).cancelar),
        ),
        FilledButton(
          onPressed: _enviando ? null : _enviar,
          child: Text(t(context).ofrecer),
        ),
      ],
    );
  }
}
