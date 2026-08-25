import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/modo_carrera_repository.dart';
import '../../domain/posiciones.dart';
import '../../i18n/textos.dart';
import '../../shared/estilo.dart';

/// Primera pantalla del Modo Carrera: quién es tu jugador. Como en la
/// identidad de Copero, se ve en una camiseta grande que cambia en vivo con
/// lo que vas escribiendo — apellido, dorsal, posición y nacionalidad. La
/// nacionalidad decide, en la pantalla siguiente, qué organizaciones
/// juveniles te ofertan (ver `rutas_juveniles.dart`).
class CrearJugadorScreen extends StatefulWidget {
  final AppDatabase db;
  final void Function(EstadoCarrera estado) onCreado;

  const CrearJugadorScreen({
    super.key,
    required this.db,
    required this.onCreado,
  });

  @override
  State<CrearJugadorScreen> createState() => _CrearJugadorScreenState();
}

class _CrearJugadorScreenState extends State<CrearJugadorScreen> {
  final _apellidoController = TextEditingController();
  final _dorsalController = TextEditingController(text: '23');
  String _posicion = posicionesEquipo.first;
  late String _nacionalidad = rutasJuveniles.keys.first;
  bool _guardando = false;

  @override
  void dispose() {
    _apellidoController.dispose();
    _dorsalController.dispose();
    super.dispose();
  }

  bool get _formularioValido {
    final dorsal = int.tryParse(_dorsalController.text);
    return _apellidoController.text.trim().isNotEmpty &&
        dorsal != null &&
        dorsal >= 0 &&
        dorsal <= 99;
  }

  Future<void> _confirmar() async {
    if (!_formularioValido || _guardando) return;
    setState(() => _guardando = true);
    await crearPartidaCarrera(
      widget.db,
      IdentidadCarrera(
        apellido: _apellidoController.text.trim(),
        dorsal: int.parse(_dorsalController.text),
        posicion: _posicion,
        nacionalidad: _nacionalidad,
      ),
    );
    if (!mounted) return;
    final estado = await leerPartidaCarrera(widget.db);
    if (!mounted || estado == null) return;
    widget.onCreado(estado);
  }

  Future<void> _elegirNacionalidad() async {
    final elegida = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Estilo.de(context).panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SelectorDeNacionalidad(actual: _nacionalidad),
    );
    if (elegida != null) setState(() => _nacionalidad = elegida);
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final dorsal = int.tryParse(_dorsalController.text) ?? 0;
    final nacionalidad = rutasJuveniles[_nacionalidad]!;

    return Scaffold(
      backgroundColor: e.fondo,
      appBar: BarraNeutraAppBar(titulo: textos.crearJugadorTitulo),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: CamisetaJugador(
                    dorsal: dorsal,
                    apellido: _apellidoController.text,
                  ),
                ),
                const SizedBox(height: 24),
                _Etiqueta(texto: textos.apellidoLabel),
                const SizedBox(height: 6),
                TextField(
                  controller: _apellidoController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: e.texto),
                  onChanged: (_) => setState(() {}),
                  decoration: _decoracionCampo(e),
                ),
                const SizedBox(height: 18),
                _Etiqueta(texto: textos.dorsalLabel),
                const SizedBox(height: 6),
                TextField(
                  controller: _dorsalController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: e.texto),
                  onChanged: (_) => setState(() {}),
                  decoration: _decoracionCampo(e),
                ),
                const SizedBox(height: 18),
                _Etiqueta(texto: textos.posicionLabel),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final posicion in posicionesEquipo)
                      ChoiceChip(
                        label: Text(posicion),
                        selected: _posicion == posicion,
                        selectedColor: colorModoCarrera,
                        labelStyle: TextStyle(
                          color: _posicion == posicion
                              ? Colors.white
                              : e.texto,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => setState(() => _posicion = posicion),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _Etiqueta(texto: textos.nacionalidadLabel),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _elegirNacionalidad,
                    borderRadius: BorderRadius.circular(10),
                    child: PanelCortado(
                      fondo: e.panel,
                      corte: 10,
                      borde: Border.all(color: e.linea),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Text(nacionalidad.bandera,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                nacionalidad.nombrePais,
                                style: titular(e, tamano: 18),
                              ),
                            ),
                            Icon(Icons.expand_more, color: e.textoRotulo),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                BotonPrincipal(
                  texto: textos.confirmarIdentidadBtn,
                  color: colorModoCarrera,
                  onTap: _formularioValido && !_guardando ? _confirmar : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracionCampo(Estilo e) => InputDecoration(
        filled: true,
        fillColor: e.panel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: e.linea),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: e.linea),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorModoCarrera),
        ),
      );
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  const _Etiqueta({required this.texto});

  @override
  Widget build(BuildContext context) =>
      Text(mayus(texto), style: rotulo(Estilo.de(context)));
}

/// La hoja que despliega las 12 nacionalidades, cada una con su bandera
/// ocupando todo el ancho de la fila — mucho más vistosa que el
/// desplegable nativo de antes, y con el mismo aspecto de lista de las
/// demás pantallas del juego.
class _SelectorDeNacionalidad extends StatelessWidget {
  final String actual;
  const _SelectorDeNacionalidad({required this.actual});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: e.textoRotulo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(mayus(textos.nacionalidadLabel), style: rotulo(e)),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                children: [
                  for (final entry in rutasJuveniles.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => Navigator.of(context).pop(entry.key),
                          child: PanelCortado(
                            fondo: entry.key == actual
                                ? colorModoCarrera.withValues(alpha: 0.18)
                                : e.panelSuave,
                            corte: 10,
                            borde: Border.all(
                              color: entry.key == actual
                                  ? colorModoCarrera
                                  : e.linea,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Text(entry.value.bandera,
                                      style: const TextStyle(fontSize: 30)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      entry.value.nombrePais,
                                      style: titular(e, tamano: 19),
                                    ),
                                  ),
                                  if (entry.key == actual)
                                    Icon(Icons.check_circle,
                                        color: colorModoCarrera),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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

/// La camiseta grande de la ficha, con dorsal y apellido — cambia en vivo
/// mientras escribes, igual que la identidad de Copero. La silueta se
/// dibuja a mano (sin imagen): cuello en pico y sisas de camiseta de
/// básquet, sin mangas.
class CamisetaJugador extends StatelessWidget {
  final int dorsal;
  final String apellido;
  final double ancho;

  const CamisetaJugador({
    super.key,
    required this.dorsal,
    required this.apellido,
    this.ancho = 220,
  });

  @override
  Widget build(BuildContext context) {
    final alto = ancho * 1.15;
    return SizedBox(
      width: ancho,
      height: alto,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(ancho, alto),
            painter: _CamisetaPainter(
              primario: colorModoCarrera,
              secundario: Colors.white,
            ),
          ),
          Positioned(
            top: alto * 0.22,
            child: SizedBox(
              width: ancho * 0.7,
              child: Text(
                apellido.trim().isEmpty ? '—' : mayus(apellido.trim()),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: familiaTitular,
                  fontSize: ancho * 0.09,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            top: alto * 0.36,
            child: Text(
              '$dorsal',
              style: TextStyle(
                fontFamily: familiaTitular,
                fontSize: ancho * 0.34,
                fontWeight: FontWeight.w800,
                height: 1,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CamisetaPainter extends CustomPainter {
  final Color primario;
  final Color secundario;

  _CamisetaPainter({required this.primario, required this.secundario});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cuerpo = Path()
      ..moveTo(w * 0.36, 0)
      ..lineTo(w * 0.14, h * 0.03)
      ..quadraticBezierTo(w * 0.00, h * 0.22, w * 0.09, h * 0.35)
      ..quadraticBezierTo(w * 0.15, h * 0.29, w * 0.17, h * 0.19)
      ..lineTo(w * 0.13, h * 0.94)
      ..quadraticBezierTo(w * 0.13, h, w * 0.20, h)
      ..lineTo(w * 0.80, h)
      ..quadraticBezierTo(w * 0.87, h, w * 0.87, h * 0.94)
      ..lineTo(w * 0.83, h * 0.19)
      ..quadraticBezierTo(w * 0.85, h * 0.29, w * 0.91, h * 0.35)
      ..quadraticBezierTo(w * 1.00, h * 0.22, w * 0.86, h * 0.03)
      ..lineTo(w * 0.64, 0)
      ..lineTo(w * 0.50, h * 0.13)
      ..close();

    canvas.drawPath(cuerpo, Paint()..color = primario);

    final ribete = Paint()
      ..color = secundario.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(cuerpo, ribete);
  }

  @override
  bool shouldRepaint(covariant _CamisetaPainter oldDelegate) =>
      oldDelegate.primario != primario || oldDelegate.secundario != secundario;
}
