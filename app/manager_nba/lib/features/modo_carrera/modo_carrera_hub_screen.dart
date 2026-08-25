import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/carrera_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/modo_carrera_repository.dart';
import '../../i18n/textos.dart';
import '../../shared/estilo.dart';

/// El hub del Modo Carrera: una única pantalla que cambia de contenido y de
/// botón según la fase de la partida (juvenil, predraft, nba, retirado), en
/// vez de una pantalla por fase — con lo poco que hay que enseñar en cada
/// una, es más sencillo de navegar que encadenar cuatro pantallas casi
/// vacías.
class ModoCarreraHubScreen extends StatefulWidget {
  final AppDatabase db;
  final EstadoCarrera estadoInicial;

  const ModoCarreraHubScreen({
    super.key,
    required this.db,
    required this.estadoInicial,
  });

  @override
  State<ModoCarreraHubScreen> createState() => _ModoCarreraHubScreenState();
}

class _ModoCarreraHubScreenState extends State<ModoCarreraHubScreen> {
  late EstadoCarrera _estado = widget.estadoInicial;
  bool _avanzando = false;

  Future<void> _avanzarJuvenil() async {
    if (_avanzando) return;
    setState(() => _avanzando = true);
    final resumen = await avanzarTemporadaJuvenil(widget.db);
    final nuevoEstado = await leerPartidaCarrera(widget.db);
    if (!mounted || nuevoEstado == null) return;
    setState(() {
      _estado = nuevoEstado;
      _avanzando = false;
    });
    if (!mounted) return;
    await _mostrarResumenJuvenil(resumen);
  }

  Future<void> _entrarAlDraft() async {
    if (_avanzando) return;
    setState(() => _avanzando = true);
    final resultado = await entrarAlDraft(widget.db);
    final nuevoEstado = await leerPartidaCarrera(widget.db);
    if (!mounted || nuevoEstado == null) return;
    setState(() {
      _estado = nuevoEstado;
      _avanzando = false;
    });
    if (!mounted) return;
    await _dialogoSimple(
      titulo: t(context).entrarAlDraftBtn,
      mensaje: t(context).draftResultadoMensaje(
          infoDe(resultado.equipo).nombreCompleto),
    );
  }

  Future<void> _avanzarNba() async {
    if (_avanzando) return;
    setState(() => _avanzando = true);
    final jugadorIdAntes = _estado.jugadorId!;
    final resumen = await avanzarTemporadaNba(widget.db);
    final nuevoEstado = await leerPartidaCarrera(widget.db);
    if (!mounted || nuevoEstado == null) return;
    setState(() {
      _estado = nuevoEstado;
      _avanzando = false;
    });
    if (!mounted) return;

    if (resumen.seRetira) {
      final enHallDeLaFama = await (widget.db.select(widget.db.hallDeLaFama)
            ..where((t) => t.jugadorId.equals(jugadorIdAntes)))
          .getSingleOrNull();
      if (!mounted) return;
      await _mostrarResumenRetiro(resumen, enHallDeLaFama != null);
      return;
    }
    await _mostrarResumenNba(resumen);
  }

  Future<void> _mostrarResumenJuvenil(ResumenTemporadaJuvenil r) async {
    final textos = t(context);
    await _dialogoSimple(
      titulo: '${textos.edadLabel} ${r.edad}',
      mensaje: '${textos.mediaLabel}: ${r.mediaAntes} → ${r.mediaDespues}\n'
          'PTS ${r.ptsPg.toStringAsFixed(1)} · '
          'AST ${r.astPg.toStringAsFixed(1)} · '
          'REB ${r.trbPg.toStringAsFixed(1)}',
    );
  }

  Future<void> _mostrarResumenNba(ResumenTemporadaNba r) async {
    final textos = t(context);
    final lineas = <String>[
      '${textos.mediaLabel}: ${r.mediaAntes} → ${r.mediaDespues}',
      'PTS ${r.ptsPg.toStringAsFixed(1)} · '
          'AST ${r.astPg.toStringAsFixed(1)} · '
          'REB ${r.trbPg.toStringAsFixed(1)}',
      '${r.victorias}-${r.derrotas}',
      if (r.cambioDeEquipo)
        textos.cambioDeEquipoMensaje(infoDe(r.equipo).nombreCompleto),
    ];
    await _dialogoSimple(
      titulo: '${t(context).temporada} ${r.temporada}',
      mensaje: lineas.join('\n'),
    );
  }

  Future<void> _mostrarResumenRetiro(
      ResumenTemporadaNba r, bool enHallDeLaFama) async {
    final textos = t(context);
    await _dialogoSimple(
      titulo: textos.carreraRetiradaTitulo,
      mensaje: '${textos.seRetiraMensaje(r.edad)}\n'
          '${enHallDeLaFama ? textos.entraEnHallDeLaFamaMensaje : textos.noEntraEnHallDeLaFamaMensaje}',
    );
  }

  Future<void> _dialogoSimple(
      {required String titulo, required String mensaje}) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          BotonDialogoPrincipal(
            texto: t(context).continuar,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);

    return Scaffold(
      backgroundColor: e.fondo,
      appBar: BarraNeutraAppBar(
        titulo: '${_estado.apellido} #${_estado.dorsal}',
        conVolver: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _FichaDeJugador(estado: _estado),
                const SizedBox(height: 24),
                if (_estado.fase == FaseCarrera.retirado)
                  _ResumenDeRetiro(db: widget.db, jugadorId: _estado.jugadorId!)
                else
                  BotonPrincipal(
                    texto: _textoBoton(textos),
                    color: e.marca,
                    onTap: _avanzando ? null : _accion(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _textoBoton(Textos textos) => switch (_estado.fase) {
        FaseCarrera.juvenil => textos.avanzarTemporadaBtn,
        FaseCarrera.predraft => textos.entrarAlDraftBtn,
        FaseCarrera.nba => textos.avanzarTemporadaBtn,
        FaseCarrera.retirado => '',
      };

  VoidCallback? _accion() => switch (_estado.fase) {
        FaseCarrera.juvenil => _avanzarJuvenil,
        FaseCarrera.predraft => _entrarAlDraft,
        FaseCarrera.nba => _avanzarNba,
        FaseCarrera.retirado => null,
      };
}

/// La ficha del jugador: identidad y sus números de ahora mismo. Los mismos
/// cuatro datos que Copero enseña en su tarjeta (edad, media, equipo,
/// puntos por partido), adaptados a lo que este juego ya calcula.
class _FichaDeJugador extends StatelessWidget {
  final EstadoCarrera estado;

  const _FichaDeJugador({required this.estado});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final equipo = estado.equipoNba;
    final info = equipo == null ? null : infoDe(equipo);

    return PanelCortado(
      fondo: e.panel,
      corte: 14,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${estado.apellido} · ${estado.posicion}',
                      style: titular(e, tamano: 20)),
                ),
                PlacaMedia(media: estado.media),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              info?.nombreCompleto ??
                  estado.organizacionActual ??
                  textos.ofertaJuvenilTitulo,
              style: TextStyle(fontSize: 14, color: e.textoTenue),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Estadistica(label: textos.edadLabel, valor: '${estado.edad}'),
                _Estadistica(
                    label: textos.potencialLabel, valor: '${estado.potencial}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  final String label;
  final String valor;

  const _Estadistica({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(mayus(label), style: rotulo(e)),
          Text(valor, style: cifra(e, tamano: 21)),
        ],
      ),
    );
  }
}

/// El resumen final de una carrera retirada: totales de toda la etapa NBA y
/// si entró en el Salón de la Fama. No hay botón de acción — la carrera ya
/// terminó — así que esta es la última pantalla del modo.
class _ResumenDeRetiro extends StatelessWidget {
  final AppDatabase db;
  final int jugadorId;

  const _ResumenDeRetiro({required this.db, required this.jugadorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CarreraJugador?>(
      future: leerCarreraParaFicha(db, jugadorId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final carrera = snapshot.data;
        if (carrera == null) return const SizedBox.shrink();

        final e = Estilo.de(context);
        final textos = t(context);
        return PanelCortado(
          fondo: e.panel,
          corte: 14,
          borde: Border.all(color: e.linea),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mayus(textos.carreraRetiradaTitulo), style: rotulo(e)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _Estadistica(
                        label: 'PTS',
                        valor: carrera.puntosPorPartido.toStringAsFixed(1)),
                    _Estadistica(
                        label: 'AST',
                        valor:
                            carrera.asistenciasPorPartido.toStringAsFixed(1)),
                    _Estadistica(
                        label: 'REB',
                        valor: carrera.rebotesPorPartido.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('${carrera.temporadas} temporadas · '
                    '${carrera.partidos} partidos'),
              ],
            ),
          ),
        );
      },
    );
  }
}
