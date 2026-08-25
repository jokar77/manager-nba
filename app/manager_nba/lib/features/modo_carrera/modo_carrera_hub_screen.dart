import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/carrera_repository.dart';
import '../../domain/entrenadores_repository.dart' show formatearMillones;
import '../../domain/equipos_info.dart';
import '../../domain/modo_carrera_repository.dart';
import '../../domain/salarios.dart';
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
  late Future<List<FilaLineaDeTiempo>> _lineaDeTiempo =
      leerLineaDeTiempo(widget.db);
  late Future<CarreraJugador?> _carrera = _cargarCarrera();

  Future<CarreraJugador?> _cargarCarrera() {
    final jugadorId = _estado.jugadorId;
    if (jugadorId == null) return Future.value(null);
    return leerCarreraParaFicha(widget.db, jugadorId);
  }

  void _refrescarLineaDeTiempo() {
    _lineaDeTiempo = leerLineaDeTiempo(widget.db);
    _carrera = _cargarCarrera();
  }

  Future<void> _avanzarJuvenil() async {
    if (_avanzando) return;
    final evento = eventoDeCarreraAleatorio(Random());
    final opcion = await _elegirEvento(evento);
    if (!mounted) return;

    setState(() => _avanzando = true);
    final resumen = await avanzarTemporadaJuvenil(widget.db,
        efectoMedia: opcion.efectoMedia);
    final nuevoEstado = await leerPartidaCarrera(widget.db);
    if (!mounted || nuevoEstado == null) return;
    setState(() {
      _estado = nuevoEstado;
      _avanzando = false;
      _refrescarLineaDeTiempo();
    });
    if (!mounted) return;
    await _mostrarResumenJuvenil(resumen, opcion);
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
      _refrescarLineaDeTiempo();
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
    final evento = eventoDeCarreraAleatorio(Random());
    final opcion = await _elegirEvento(evento);
    if (!mounted) return;

    setState(() => _avanzando = true);
    final jugadorIdAntes = _estado.jugadorId!;
    final resumen = await avanzarTemporadaNba(widget.db,
        efectoMedia: opcion.efectoMedia);
    final nuevoEstado = await leerPartidaCarrera(widget.db);
    if (!mounted || nuevoEstado == null) return;
    setState(() {
      _estado = nuevoEstado;
      _avanzando = false;
      _refrescarLineaDeTiempo();
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
    await _mostrarResumenNba(resumen, opcion);
    if (!mounted) return;

    final elegida = await _elegirEquipoTemporada(resumen);
    await elegirEquipoTemporada(widget.db, elegida);
    if (!mounted) return;
    setState(_refrescarLineaDeTiempo);
    if (elegida.equipo != resumen.equipo) {
      if (!mounted) return;
      await _dialogoSimple(
        titulo: t(context).decisionDeEquipoTitulo,
        mensaje: t(context).cambioDeEquipoMensaje(
            infoDe(elegida.equipo).nombreCompleto),
      );
    }
  }

  /// El aviso de fin de temporada, estilo Copero: quedarte donde estás o
  /// fichar por una de las dos ofertas de traspaso. No se puede cerrar sin
  /// elegir — la carrera no sigue sin que decidas.
  Future<OfertaDeEquipo> _elegirEquipoTemporada(ResumenTemporadaNba r) async {
    final textos = t(context);
    final ofertas = [r.ofertaQuedarse, ...r.ofertasDeTraspaso];
    final elegida = await showDialog<OfertaDeEquipo>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(textos.decisionDeEquipoTitulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < ofertas.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorModoCarrera,
                      side: BorderSide(color: colorModoCarrera),
                    ),
                    onPressed: () => Navigator.of(context).pop(ofertas[i]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          i == 0
                              ? textos.quedarmeEnMiEquipoBtn(
                                  infoDe(ofertas[i].equipo).nombreCompleto)
                              : textos.ficharPorBtn(
                                  infoDe(ofertas[i].equipo).nombreCompleto),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          textos.contratoAnioMillones(
                              textos.aniosDeContrato(ofertas[i].aniosContrato),
                              formatearMillones(ofertas[i].salario)),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return elegida!;
  }

  /// El evento de decisión de esta temporada: 2-3 opciones, cada una con un
  /// pequeño efecto en tu media (ver `eventos_de_carrera.dart`). No se puede
  /// cerrar sin elegir — es una decisión de la temporada, no un aviso.
  Future<OpcionDeEventoDeCarrera> _elegirEvento(EventoDeCarrera evento) async {
    final elegida = await showDialog<OpcionDeEventoDeCarrera>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(evento.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(evento.descripcion),
            const SizedBox(height: 16),
            for (final opcion in evento.opciones)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorModoCarrera,
                      side: BorderSide(color: colorModoCarrera),
                    ),
                    onPressed: () => Navigator.of(context).pop(opcion),
                    child: Text(opcion.texto, textAlign: TextAlign.center),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    return elegida!;
  }

  Future<void> _mostrarResumenJuvenil(
      ResumenTemporadaJuvenil r, OpcionDeEventoDeCarrera opcion) async {
    final textos = t(context);
    await _dialogoSimple(
      titulo: '${textos.edadLabel} ${r.edad}',
      mensaje: '${opcion.mensaje}\n\n'
          '${textos.mediaLabel}: ${r.mediaAntes} → ${r.mediaDespues}\n'
          'PTS ${r.ptsPg.toStringAsFixed(1)} · '
          'AST ${r.astPg.toStringAsFixed(1)} · '
          'REB ${r.trbPg.toStringAsFixed(1)}',
    );
  }

  Future<void> _mostrarResumenNba(
      ResumenTemporadaNba r, OpcionDeEventoDeCarrera opcion) async {
    final textos = t(context);
    final lineas = <String>[
      opcion.mensaje,
      '',
      '${textos.mediaLabel}: ${r.mediaAntes} → ${r.mediaDespues}',
      'PTS ${r.ptsPg.toStringAsFixed(1)} · '
          'AST ${r.astPg.toStringAsFixed(1)} · '
          'REB ${r.trbPg.toStringAsFixed(1)}',
      '${r.victorias}-${r.derrotas}',
      for (final premio in r.premiosGanados)
        '🏆 ${_nombreDePremio(textos, premio)}',
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
                _FichaDeJugador(
                    estado: _estado,
                    lineaDeTiempo: _lineaDeTiempo,
                    carrera: _carrera),
                const SizedBox(height: 24),
                if (_estado.fase == FaseCarrera.retirado)
                  _ResumenDeRetiro(db: widget.db, jugadorId: _estado.jugadorId!)
                else
                  BotonPrincipal(
                    texto: _textoBoton(textos),
                    color: colorModoCarrera,
                    onTap: _avanzando ? null : _accion(),
                  ),
                const SizedBox(height: 24),
                _LineaDeTiempo(lineaDeTiempo: _lineaDeTiempo),
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

/// Cómo se llama un premio en el idioma del usuario. Reusa las mismas
/// claves que `premios/premios_screen.dart` (el modo Franquicia), salvo
/// para los tipos que Modo Carrera nunca concede (Más Mejorado, quintetos,
/// MVP del All-Star/Rising Stars), que no hace falta nombrar aquí.
String _nombreDePremio(Textos textos, TipoPremio premio) => switch (premio) {
      TipoPremio.allStar => textos.allStar,
      TipoPremio.mvp => textos.premioMvp,
      TipoPremio.mejorDefensor => textos.premioMejorDefensor,
      TipoPremio.rookieDelAno => textos.premioRookieDelAno,
      _ => premio.name,
    };

/// La ficha del jugador: identidad y sus números de ahora mismo. Mismo
/// contenido que la tarjeta de Copero — bandera, dorsal y puesto, edad y
/// valor (aquí media/potencial, que es lo que este juego calcula), y las
/// tres estadísticas por partido de la última temporada.
class _FichaDeJugador extends StatelessWidget {
  final EstadoCarrera estado;
  final Future<List<FilaLineaDeTiempo>> lineaDeTiempo;
  final Future<CarreraJugador?> carrera;

  const _FichaDeJugador({
    required this.estado,
    required this.lineaDeTiempo,
    required this.carrera,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final equipo = estado.equipoNba;
    final info = equipo == null ? null : infoDe(equipo);
    final bandera = rutasJuveniles[estado.nacionalidad]?.bandera ?? '';

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
                Text(bandera, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorModoCarrera.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('#${estado.dorsal} ${estado.posicion}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorModoCarrera)),
                ),
                const Spacer(),
                PlacaMedia(media: estado.media),
              ],
            ),
            const SizedBox(height: 10),
            Text(mayus(estado.apellido), style: titular(e, tamano: 24)),
            const SizedBox(height: 2),
            Text(
              info?.nombreCompleto ??
                  estado.organizacionActual ??
                  textos.ofertaJuvenilTitulo,
              style: TextStyle(fontSize: 14, color: e.textoTenue),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Estadistica(label: textos.edadLabel, valor: '${estado.edad}'),
                _Estadistica(
                  label: textos.valorLabel,
                  valor:
                      '\$${formatearSalario(salarioEstimado(media: estado.media, edad: estado.edad))}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<FilaLineaDeTiempo>>(
              future: lineaDeTiempo,
              builder: (context, snapshot) {
                final conPartidos = (snapshot.data ?? const [])
                    .where((f) => f.partidos > 0)
                    .toList();
                final ultima = conPartidos.isEmpty ? null : conPartidos.first;
                return Row(
                  children: [
                    _Estadistica(label: 'PJ', valor: '${ultima?.partidos ?? 0}'),
                    _Estadistica(
                        label: 'PTS',
                        valor: (ultima?.ptsPg ?? 0).toStringAsFixed(1)),
                    _Estadistica(
                        label: 'AST',
                        valor: (ultima?.astPg ?? 0).toStringAsFixed(1)),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            FutureBuilder<CarreraJugador?>(
              future: carrera,
              builder: (context, snapshot) {
                final ganados = <TipoPremio, int>{};
                for (final premio in [
                  TipoPremio.mvp,
                  TipoPremio.mejorDefensor,
                  TipoPremio.rookieDelAno,
                  TipoPremio.allStar,
                ]) {
                  final veces = snapshot.data?.vecesGano(premio) ?? 0;
                  if (veces > 0) ganados[premio] = veces;
                }
                if (ganados.isEmpty) {
                  return Row(
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          size: 18, color: e.textoRotulo),
                      const SizedBox(width: 8),
                      Text(mayus(textos.vitrinaVaciaLabel),
                          style: rotulo(e)),
                    ],
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entrada in ganados.entries)
                      _EtiquetaDePremio(
                        texto: _nombreDePremio(textos, entrada.key),
                        veces: entrada.value,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// La línea de tiempo: una fila por temporada jugada, de la más reciente a
/// la más vieja — el mismo vistazo de "cómo ha ido tu carrera" que enseña
/// Copero a la derecha de la ficha.
class _LineaDeTiempo extends StatelessWidget {
  final Future<List<FilaLineaDeTiempo>> lineaDeTiempo;

  const _LineaDeTiempo({required this.lineaDeTiempo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FilaLineaDeTiempo>>(
      future: lineaDeTiempo,
      builder: (context, snapshot) {
        final filas = snapshot.data ?? const [];
        if (filas.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final fila in filas) ...[
              _FilaTemporada(fila: fila),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _FilaTemporada extends StatelessWidget {
  final FilaLineaDeTiempo fila;

  const _FilaTemporada({required this.fila});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return PanelCortado(
      fondo: e.panelSuave,
      corte: 10,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text('${fila.edad}',
                  style: cifra(e, tamano: 17, color: e.textoTenue)),
            ),
            Expanded(
              child: Text(fila.lugar,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titular(e, tamano: 15)),
            ),
            PlacaMedia(media: fila.media, tamano: 28),
            const SizedBox(width: 10),
            if (fila.partidos > 0) ...[
              _CifraCorta(label: 'PJ', valor: '${fila.partidos}'),
              _CifraCorta(label: 'PTS', valor: fila.ptsPg.toStringAsFixed(1)),
              _CifraCorta(label: 'AST', valor: fila.astPg.toStringAsFixed(1)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CifraCorta extends StatelessWidget {
  final String label;
  final String valor;

  const _CifraCorta({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(valor, style: titular(e, tamano: 14)),
          Text(label, style: rotulo(e, tamano: 8)),
        ],
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
/// Todo lo que hace falta para el resumen final, leído de una sola vez: la
/// carrera, si entró en el Salón de la Fama y si tiene alguna camiseta
/// retirada.
class _DatosDeRetiro {
  final CarreraJugador carrera;
  final bool enHallDeLaFama;
  final List<String> camisetasRetiradas;

  const _DatosDeRetiro({
    required this.carrera,
    required this.enHallDeLaFama,
    required this.camisetasRetiradas,
  });
}

class _ResumenDeRetiro extends StatelessWidget {
  final AppDatabase db;
  final int jugadorId;

  const _ResumenDeRetiro({required this.db, required this.jugadorId});

  Future<_DatosDeRetiro?> _cargar() async {
    final carrera = await leerCarreraParaFicha(db, jugadorId);
    if (carrera == null) return null;
    final hof = await (db.select(db.hallDeLaFama)
          ..where((t) => t.jugadorId.equals(jugadorId)))
        .getSingleOrNull();
    final camisetas = await (db.select(db.camisetasRetiradas)
          ..where((t) => t.jugadorId.equals(jugadorId)))
        .get();
    return _DatosDeRetiro(
      carrera: carrera,
      enHallDeLaFama: hof != null,
      camisetasRetiradas: camisetas.map((c) => c.equipo).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DatosDeRetiro?>(
      future: _cargar(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final datos = snapshot.data;
        if (datos == null) return const SizedBox.shrink();
        final carrera = datos.carrera;

        final e = Estilo.de(context);
        final textos = t(context);
        final premiosIndividuales = [
          TipoPremio.mvp,
          TipoPremio.mejorDefensor,
          TipoPremio.rookieDelAno,
        ];
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
                if (datos.enHallDeLaFama) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events,
                          color: Color(0xFFFFC94D), size: 20),
                      const SizedBox(width: 8),
                      Text(textos.entraEnHallDeLaFamaMensaje,
                          style: titular(e, tamano: 15)),
                    ],
                  ),
                ],
                if (datos.camisetasRetiradas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.checkroom, color: colorModoCarrera, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          datos.camisetasRetiradas
                              .map((c) => infoDe(c).nombreCompleto)
                              .join(', '),
                          style: TextStyle(fontSize: 13, color: e.textoTenue),
                        ),
                      ),
                    ],
                  ),
                ],
                if (premiosIndividuales.any((p) => carrera.vecesGano(p) > 0) ||
                    carrera.vecesGano(TipoPremio.allStar) > 0) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final premio in [
                        ...premiosIndividuales,
                        TipoPremio.allStar,
                      ])
                        if (carrera.vecesGano(premio) > 0)
                          _EtiquetaDePremio(
                            texto: _nombreDePremio(textos, premio),
                            veces: carrera.vecesGano(premio),
                          ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EtiquetaDePremio extends StatelessWidget {
  final String texto;
  final int veces;

  const _EtiquetaDePremio({required this.texto, required this.veces});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorModoCarrera.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorModoCarrera.withValues(alpha: 0.4)),
      ),
      child: Text(
        veces > 1 ? '$texto ×$veces' : texto,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: e.texto),
      ),
    );
  }
}
