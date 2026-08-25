import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/modo_carrera_repository.dart';
import '../../domain/posiciones.dart';
import '../../i18n/textos.dart';
import '../../shared/estilo.dart';

/// Primera pantalla del Modo Carrera: quién es tu jugador. Solo cuatro
/// datos, como en la identidad de Copero — apellido, dorsal, posición y
/// nacionalidad. La nacionalidad decide, en la pantalla siguiente, qué
/// organizaciones juveniles te ofertan (ver `rutas_juveniles.dart`).
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

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);

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
                        onSelected: (_) => setState(() => _posicion = posicion),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _Etiqueta(texto: textos.nacionalidadLabel),
                const SizedBox(height: 8),
                PanelCortado(
                  fondo: e.panel,
                  corte: 10,
                  borde: Border.all(color: e.linea),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _nacionalidad,
                        isExpanded: true,
                        dropdownColor: e.panel,
                        style: TextStyle(color: e.texto, fontSize: 15),
                        items: [
                          for (final entry in rutasJuveniles.entries)
                            DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value.nombrePais),
                            ),
                        ],
                        onChanged: (valor) {
                          if (valor != null) {
                            setState(() => _nacionalidad = valor);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                BotonPrincipal(
                  texto: textos.confirmarIdentidadBtn,
                  color: e.marca,
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
          borderSide: BorderSide(color: e.marca),
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
