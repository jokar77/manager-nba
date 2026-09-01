import 'package:flutter/material.dart';

import '../../domain/permisos.dart';
import '../../domain/tienda.dart';
import '../../i18n/textos.dart';
import '../../shared/estilo.dart';

/// La pantalla de compra: qué trae la versión completa y los dos caminos
/// para conseguirla —pagar, o recuperar una compra ya hecha en esta cuenta.
///
/// No lee nada de la partida abierta a propósito: se puede llegar aquí
/// desde el menú de arranque, sin ninguna franquicia cargada todavía (ver
/// `_bloqueada` en `start_menu_screen.dart`).
class ComprarScreen extends StatefulWidget {
  const ComprarScreen({super.key});

  @override
  State<ComprarScreen> createState() => _ComprarScreenState();
}

class _ComprarScreenState extends State<ComprarScreen> {
  /// Mientras se espera a la tienda, para no dejar pulsar los dos botones
  /// a la vez ni el mismo dos veces seguidas.
  bool _procesando = false;

  Future<void> _comprar() async {
    if (_procesando) return;
    setState(() => _procesando = true);

    final pagada = await tienda.comprarCompleta();
    if (!mounted) return;

    if (pagada) {
      permisos.registrarCompra();
      Navigator.of(context).pop(true);
      return;
    }

    // `false` cubre tanto cancelar como que el pago se caiga: a efectos de
    // esta pantalla son el mismo caso, y no es un error del juego. Se
    // vuelve a dejar todo listo para intentarlo otra vez, sin avisos.
    setState(() => _procesando = false);
  }

  Future<void> _restaurar() async {
    if (_procesando) return;
    setState(() => _procesando = true);

    final habiaCompra = await tienda.restaurarCompra();
    if (!mounted) return;

    if (habiaCompra) {
      permisos.registrarCompra();
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _procesando = false);
    // A diferencia de comprar, aquí sí se avisa: restaurar es una acción
    // que el jugador pide a propósito para comprobar si ya había pagado, y
    // dejar el botón callado sin decir nada se lee como que no ha
    // funcionado.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t(context).restaurarSinCompraPreviaMensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);

    return Scaffold(
      appBar: BarraNeutraAppBar(titulo: textos.comprarCompletaTitulo),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(textos.comprarCompletaExplicacion,
              style: TextStyle(fontSize: 13, color: e.textoTenue)),
          const SizedBox(height: 14),
          const _TablaComparativa(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BotonPrincipal(
                texto: textos.comprarBtn,
                color: e.marca,
                onTap: _procesando ? null : _comprar,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _procesando ? null : _restaurar,
                child: Text(mayus(textos.restaurarCompraBtn)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila a fila, lo que cambia entre las dos ediciones. Mismos datos que la
/// tabla "Lo demás" de `docs/plan_monetizacion.md`.
class _TablaComparativa extends StatelessWidget {
  const _TablaComparativa();

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);

    return PanelCortado(
      fondo: e.panel,
      corte: 12,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CabeceraDeColumnas(
              gratis: textos.comprarCompletaColumnaGratis,
              completa: textos.comprarCompletaColumnaCompleta,
            ),
            const SizedBox(height: 10),
            _FilaComparativa(
              etiqueta: textos.comprarCompletaFilaRanuras,
              gratis: textos.comprarCompletaFilaRanurasGratis,
              completa: textos.comprarCompletaFilaRanurasCompleta,
            ),
            _FilaComparativa(
              etiqueta: textos.comprarCompletaFilaSimular,
              gratis: textos.comprarCompletaFilaSimularGratis,
              completa: textos.comprarCompletaFilaSimularCompleta,
            ),
            _FilaComparativa(
              etiqueta: textos.comprarCompletaFilaPatrocinadores,
              gratis: textos.comprarCompletaFilaPatrocinadoresGratis,
              completa: textos.comprarCompletaFilaPatrocinadoresCompleta,
            ),
            _FilaComparativa(
              etiqueta: textos.comprarCompletaFilaAnuncios,
              gratis: textos.comprarCompletaFilaAnunciosGratis,
              completa: textos.comprarCompletaFilaAnunciosCompleta,
              ultima: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CabeceraDeColumnas extends StatelessWidget {
  final String gratis;
  final String completa;

  const _CabeceraDeColumnas({required this.gratis, required this.completa});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Row(
      children: [
        const Expanded(flex: 3, child: SizedBox.shrink()),
        Expanded(
          flex: 2,
          child: Text(mayus(gratis),
              textAlign: TextAlign.center, style: rotulo(e, tamano: 9)),
        ),
        Expanded(
          flex: 2,
          child: Text(mayus(completa),
              textAlign: TextAlign.center,
              style: rotulo(e, tamano: 9, color: e.marca)),
        ),
      ],
    );
  }
}

/// Una fila: qué es, qué trae gratis y qué trae la completa.
class _FilaComparativa extends StatelessWidget {
  final String etiqueta;
  final String gratis;
  final String completa;
  final bool ultima;

  const _FilaComparativa({
    required this.etiqueta,
    required this.gratis,
    required this.completa,
    this.ultima = false,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: ultima
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: e.linea)),
            ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(etiqueta,
                style: TextStyle(fontSize: 13, color: e.texto)),
          ),
          Expanded(
            flex: 2,
            child: Text(gratis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: e.textoTenue)),
          ),
          Expanded(
            flex: 2,
            child: Text(completa,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: e.bien)),
          ),
        ],
      ),
    );
  }
}
