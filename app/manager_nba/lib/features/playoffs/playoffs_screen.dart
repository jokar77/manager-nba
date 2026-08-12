import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/playoffs_repository.dart';
import '../../shared/campeon_dialog.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import '../partido/serie_boxscores_screen.dart';
import '../temporada/cambio_de_temporada.dart';

/// Play-in y bracket de playoffs. Los seeds 7-10 de cada conferencia
/// juegan primero el play-in (formato NBA real) para decidir los puestos
/// 7 y 8; los seeds 1-6 pasan directos. Mientras tu equipo siga vivo (en
/// el play-in o en el bracket), cada partido se simula uno a uno (botón)
/// y el resto avanza a la par, un partido cada vez, igual que en el
/// calendario normal. Si no clasificaste o ya quedaste eliminado, puedes
/// resolver el resto de golpe.
class PlayoffsScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const PlayoffsScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  State<PlayoffsScreen> createState() => _PlayoffsScreenState();
}

class _PlayoffsScreenState extends State<PlayoffsScreen> {
  late Future<List<Serie>> _seriesFuture;
  bool _procesando = false;
  // Evita reabrir el diálogo de campeón cada vez que se recarga esta
  // pantalla: se pone a true en cuanto se detecta un ganador (ya sea al
  // cargar por primera vez con la final ya decidida, o justo al
  // simularla).
  bool _campeonYaVisto = false;
  String? _temporada;

  @override
  void initState() {
    super.initState();
    _seriesFuture = _cargarInicial();
  }

  Future<List<Serie>> _cargarInicial() async {
    final series = await leerSeries(widget.db);
    _campeonYaVisto = _campeonDeLaLista(series) != null;
    final temporada = await leerTemporada(widget.db);
    if (mounted) {
      setState(() => _temporada = etiquetaDeTemporada(temporada.anioInicio));
    }
    return series;
  }

  String? _campeonDeLaLista(List<Serie> series) =>
      series.where((s) => s.conferencia == 'Final').firstOrNull?.ganador;

  /// Ejecuta [accion] (una simulación), recarga las series y, si con esto
  /// se acaba de decidir la Final NBA por primera vez, anuncia al campeón
  /// con un diálogo — con su confeti y el MVP de las Finales, no solo el
  /// banner pasivo del bracket.
  Future<void> _simularYComprobarCampeon(Future<void> Function() accion) async {
    setState(() => _procesando = true);
    await accion();
    final series = await leerSeries(widget.db);
    if (!mounted) return;
    setState(() {
      _seriesFuture = Future.value(series);
      _procesando = false;
    });

    final campeon = _campeonDeLaLista(series);
    if (campeon != null && !_campeonYaVisto) {
      _campeonYaVisto = true;
      await _anunciarCampeon(campeon);
    }
  }

  Future<void> _anunciarCampeon(String campeon) async {
    final mvp = await mvpDeLasFinales(widget.db);
    if (!mounted) return;
    await mostrarCampeonDecidido(
      context,
      'la NBA',
      campeon,
      esTuEquipo: campeon == widget.equipoUsuario,
      temporada: _temporada,
      detalle: mvp == null
          ? null
          : TarjetaMvpDeFinales(
              nombre: mvp.nombre,
              equipo: mvp.equipo,
              partidos: mvp.partidos,
              puntos: mvp.puntos,
              asistencias: mvp.asistencias,
              rebotes: mvp.rebotes,
            ),
    );
  }

  /// Desde aquí también se pasa de año: cuando acabas de ganar el anillo
  /// estás en el bracket, no en el calendario, y tener que volver atrás para
  /// seguir era un paso de más.
  Future<void> _empezarSiguienteTemporada() async {
    setState(() => _procesando = true);
    final hecho = await ejecutarCambioDeTemporada(
        context, widget.db, widget.equipoUsuario);
    if (!mounted) return;
    if (!hecho) {
      setState(() => _procesando = false);
      return;
    }
    // El bracket del año que viene todavía no existe: se siembra al acabar
    // la temporada regular, así que aquí se sale a lo que haya detrás.
    Navigator.of(context).pop();
  }

  Future<void> _simularPartidoDeTuSerie() => _simularYComprobarCampeon(
      () => avanzarPlayoffsUnPartido(widget.db, widget.equipoUsuario));

  Future<void> _simularTodo() =>
      _simularYComprobarCampeon(() => simularPlayoffsCompletos(widget.db));

  Future<void> _simularRonda() =>
      _simularYComprobarCampeon(() => simularRondaPlayoffsCompleta(widget.db));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playoffs')),
      body: FutureBuilder<List<Serie>>(
        future: _seriesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final series = snapshot.data!;
          if (series.isEmpty) {
            return const Center(
                child: Text('Los playoffs se siembran al terminar tu '
                    'temporada regular (82 partidos).'));
          }

          // "Implicado" = tu equipo sigue vivo en el play-in o el bracket
          // (no solo clasificado directo a playoffs).
          final implicado = series.any((s) =>
              (s.equipoA == widget.equipoUsuario ||
                  s.equipoB == widget.equipoUsuario) &&
              (s.ganador == null || s.ganador == widget.equipoUsuario));
          final finalNba =
              series.where((s) => s.conferencia == 'Final').firstOrNull;
          final playIn = series.where((s) => s.ronda == 0).toList();
          // Mientras quede play-in, la primera ronda no se toca: el 1 y el 2
          // ni siquiera saben todavía contra quién juegan.
          final playInSinResolver = playIn.any((s) => s.ganador == null);

          return Column(
            children: [
              if (_procesando) const LinearProgressIndicator(),
              if (finalNba?.ganador != null) ...[
                BannerCampeon(
                  competicion: 'la NBA',
                  campeon: finalNba!.ganador!,
                  esTuEquipo: finalNba.ganador == widget.equipoUsuario,
                  temporada: _temporada,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _procesando
                              ? null
                              : () => _anunciarCampeon(finalNba.ganador!),
                          icon: const Icon(Icons.emoji_events, size: 18),
                          label: const Text('Ver celebración'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              _procesando ? null : _empezarSiguienteTemporada,
                          icon: const Icon(Icons.skip_next, size: 18),
                          label: const Text('Siguiente temporada'),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _procesando ? null : _simularRonda,
                          child: Text(playInSinResolver
                              ? 'Resolver el Play-In'
                              : 'Simular ronda completa'),
                        ),
                      ),
                      if (!implicado) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: _procesando ? null : _simularTodo,
                            child: const Text('Simular todo'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // El Play-In desaparece en cuanto se resuelve: cumplida
                      // su función (decidir el 7 y el 8), lo único que hacía
                      // era empujar el cuadro hacia abajo cada vez que
                      // entrabas a mirar cómo iban tus playoffs.
                      if (playIn.isNotEmpty && playInSinResolver) ...[
                        _PanelPlayIn(
                          db: widget.db,
                          series: playIn,
                          equipoUsuario: widget.equipoUsuario,
                          procesando: _procesando,
                          onSimular: _simularPartidoDeTuSerie,
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text('Bracket',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (playInSinResolver)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.lock_clock,
                                  size: 15,
                                  color:
                                      Theme.of(context).colorScheme.outline),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'La primera ronda no empieza hasta que el '
                                  'Play-In decida quién es el 7 y el 8.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Sin scroll horizontal: el cuadro se encoge solo hasta
                      // caber en el ancho que haya (ver _BracketVisual), así
                      // que envolverlo en un scroll infinito le quitaría la
                      // referencia que necesita para escalarse.
                      _BracketVisual(
                        db: widget.db,
                        series: series,
                        equipoUsuario: widget.equipoUsuario,
                        procesando: _procesando,
                        bloqueadoPorPlayIn: playInSinResolver,
                        onSimular: _simularPartidoDeTuSerie,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// El Play-In, una columna por conferencia. No cabe en el bracket (no es una
/// eliminatoria de potencias de dos), así que va aparte, pero enseñando lo
/// que está en juego en cada partido: quién entra de 7, quién de 8 y quién
/// se va a casa.
class _PanelPlayIn extends StatelessWidget {
  final AppDatabase db;
  final List<Serie> series;
  final String equipoUsuario;
  final bool procesando;
  final VoidCallback onSimular;

  const _PanelPlayIn({
    required this.db,
    required this.series,
    required this.equipoUsuario,
    required this.procesando,
    required this.onSimular,
  });

  static const _queSeJuega = {
    'playin_7v8': 'El ganador entra como 7',
    'playin_9v10': 'El perdedor queda eliminado',
    'playin_final': 'El ganador entra como 8',
  };

  @override
  Widget build(BuildContext context) {
    final resuelto = series.every((s) => s.ganador != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Play-In',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            if (resuelto)
              const Icon(Icons.check_circle, size: 16, color: Colors.green),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, restricciones) {
            final columnas = [
              for (final conferencia in ['Oeste', 'Este'])
                _ColumnaPlayIn(
                  db: db,
                  conferencia: conferencia,
                  series: series
                      .where((s) => s.conferencia == conferencia)
                      .toList(),
                  equipoUsuario: equipoUsuario,
                  procesando: procesando,
                  onSimular: onSimular,
                  queSeJuega: _queSeJuega,
                ),
            ];
            if (restricciones.maxWidth < 520) {
              return Column(
                children: [
                  columnas[0],
                  const SizedBox(height: 10),
                  columnas[1],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: columnas[0]),
                const SizedBox(width: 12),
                Expanded(child: columnas[1]),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ColumnaPlayIn extends StatelessWidget {
  final AppDatabase db;
  final String conferencia;
  final List<Serie> series;
  final String equipoUsuario;
  final bool procesando;
  final VoidCallback onSimular;
  final Map<String, String> queSeJuega;

  const _ColumnaPlayIn({
    required this.db,
    required this.conferencia,
    required this.series,
    required this.equipoUsuario,
    required this.procesando,
    required this.onSimular,
    required this.queSeJuega,
  });

  @override
  Widget build(BuildContext context) {
    // Orden fijo: primero los dos cruces, luego el partido por el 8º puesto.
    const orden = ['playin_7v8', 'playin_9v10', 'playin_final'];
    final ordenadas = [
      for (final etapa in orden)
        ...series.where((s) => s.etapa == etapa),
    ];
    final info = infoDe(conferencia);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: info.colorPrimario,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text('Conferencia $conferencia',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textoSobre(info.colorPrimario))),
          ),
          if (ordenadas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Sin play-in', style: TextStyle(fontSize: 12)),
            )
          else
            for (final serie in ordenadas)
              _FilaPlayIn(
                key: ValueKey('playin-${serie.id}'),
                db: db,
                serie: serie,
                equipoUsuario: equipoUsuario,
                procesando: procesando,
                onSimular: onSimular,
                queSeJuega: queSeJuega[serie.etapa] ?? '',
              ),
        ],
      ),
    );
  }
}

class _FilaPlayIn extends StatelessWidget {
  final AppDatabase db;
  final Serie serie;
  final String equipoUsuario;
  final bool procesando;
  final VoidCallback onSimular;
  final String queSeJuega;

  const _FilaPlayIn({
    super.key,
    required this.db,
    required this.serie,
    required this.equipoUsuario,
    required this.procesando,
    required this.onSimular,
    required this.queSeJuega,
  });

  @override
  Widget build(BuildContext context) {
    final esTuSerie =
        serie.equipoA == equipoUsuario || serie.equipoB == equipoUsuario;
    final jugado = serie.ganador != null;
    final outline = Theme.of(context).colorScheme.outline;

    return InkWell(
      onTap: jugado
          ? () => abrirEstadisticasDeSerie(context, db,
              origen: 'playoffs', serieId: serie.id)
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(queSeJuega,
                style: TextStyle(fontSize: 10, color: outline)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _equipo(context, serie.equipoA, serie.seedA),
                      const SizedBox(height: 2),
                      _equipo(context, serie.equipoB, serie.seedB),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (esTuSerie && !jugado)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(fontSize: 11),
                    ),
                    onPressed: procesando ? null : onSimular,
                    child: const Text('Jugar'),
                  )
                else if (jugado)
                  const Icon(Icons.check_circle, size: 18, color: Colors.green)
                else
                  Text('Por jugar',
                      style: TextStyle(fontSize: 10, color: outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _equipo(BuildContext context, String equipo, int seed) {
    final gana = serie.ganador == equipo;
    final perdio = serie.ganador != null && !gana;
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text('$seed',
              style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.outline)),
        ),
        EquipoLogo(codigoEquipo: equipo, tamano: 18),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            infoDe(equipo).apodo,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: gana ? FontWeight.bold : FontWeight.normal,
              decoration: perdio ? TextDecoration.lineThrough : null,
              color: perdio
                  ? Theme.of(context).colorScheme.outline
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bracket visual real, de arriba abajo: el Oeste baja desde la primera
/// ronda hasta su final de conferencia, el Este sube desde abajo, y las dos
/// mitades se encuentran en la Final NBA del centro. Cajas conectadas por
/// líneas, igual que un cuadro de eliminatorias de verdad.
///
/// Va en vertical y no en horizontal por una razón de medida: en horizontal
/// el cuadro necesitaba 1400 píxeles de ancho, y en un móvil de 390 eso lo
/// dejaba al 28% —ilegible sin pellizcar—. Girado, lo ancho pasa a ser lo
/// alto: cuatro cajas de ancho en vez de ocho columnas, y el scroll
/// vertical que ya tenía la pantalla se encarga del resto.
///
/// El Play-In no cabe aquí (no es una eliminatoria de potencias de dos) y
/// se muestra aparte, encima, solo mientras esté sin resolver.
class _BracketVisual extends StatelessWidget {
  final AppDatabase db;
  final List<Serie> series;
  final String equipoUsuario;
  final bool procesando;
  final bool bloqueadoPorPlayIn;
  final VoidCallback onSimular;

  const _BracketVisual({
    required this.db,
    required this.series,
    required this.equipoUsuario,
    required this.procesando,
    required this.bloqueadoPorPlayIn,
    required this.onSimular,
  });

  static const _boxWidth = 152.0;
  // Tiene que caber siempre el caso más alto: dos filas de equipo + el
  // botón "Simular" cuando la serie es la tuya (antes desbordaba ~10px).
  static const _boxHeight = 78.0;

  /// Hueco horizontal entre dos cajas hermanas de la primera ronda.
  static const _slot = 162.0;

  /// Hueco vertical entre una ronda y la siguiente: donde van las líneas.
  static const _connector = 30.0;
  static const _filaAlto = _boxHeight + _connector;

  /// Columna de la izquierda con el nombre de cada ronda. En vertical no
  /// hay sitio encima de las cajas (la primera ronda ocupa todo el ancho),
  /// así que las etiquetas van al lado.
  static const _anchoEtiquetas = 66.0;

  Serie? _buscar(String conferencia, String etapa) =>
      series.where((s) => s.conferencia == conferencia && s.etapa == etapa).firstOrNull;

  /// Centro horizontal (X) de la caja `indice` de `ronda` (0=Ronda1 con 4
  /// cajas, 1=Semis con 2, 2=Final de conferencia con 1): el centro de una
  /// ronda es siempre el punto medio de sus dos cajas hijas.
  double _centroX(int ronda, int indice) {
    if (ronda == 0) return indice * _slot + _slot / 2;
    final a = _centroX(ronda - 1, indice * 2);
    final b = _centroX(ronda - 1, indice * 2 + 1);
    return (a + b) / 2;
  }

  /// Centro vertical de cada una de las siete filas, de arriba abajo:
  /// 0 Oeste R1 · 1 Oeste semis · 2 Final Oeste · 3 FINAL NBA ·
  /// 4 Final Este · 5 Este semis · 6 Este R1.
  double _centroY(int fila) => fila * _filaAlto + _boxHeight / 2;

  /// La franja de conferencia que va arriba del todo y abajo del todo.
  static const _altoBanda = 24.0;

  @override
  Widget build(BuildContext context) {
    final anchoCuadro = 4 * _slot;
    final anchoTotal = _anchoEtiquetas + anchoCuadro;
    final alturaCuadro = 7 * _filaAlto - _connector;
    final centroFinales = _centroX(2, 0);

    // Orden vertical de la primera ronda: tiene que ser el del cruce real
    // (el ganador del 1-8 se mide al del 4-5, y el del 2-7 al del 3-6), no
    // el orden de seeds. Con el orden de seeds, el bracket dibujaba juntas
    // dos series que en realidad no se cruzan y hacía esperar un rival
    // equivocado en la siguiente ronda.
    const ordenRonda1 = [
      'ronda1_1v8',
      'ronda1_4v5',
      'ronda1_2v7',
      'ronda1_3v6',
    ];
    final oeste = ordenRonda1.map((e) => _buscar('Oeste', e)).toList();
    final este = ordenRonda1.map((e) => _buscar('Este', e)).toList();
    final semisOeste = [_buscar('Oeste', 'semis_a'), _buscar('Oeste', 'semis_b')];
    final semisEste = [_buscar('Este', 'semis_a'), _buscar('Este', 'semis_b')];
    final finalOeste = _buscar('Oeste', 'finalConferencia');
    final finalEste = _buscar('Este', 'finalConferencia');
    final finalNba = _buscar('Final', 'finalNBA');

    final lineColor = Theme.of(context).colorScheme.outlineVariant;

    Widget caja(Serie? serie, double centroEnX, double centroEnY,
        {required String etiquetaVacia}) {
      return Positioned(
        left: centroEnX - _boxWidth / 2,
        top: centroEnY - _boxHeight / 2,
        width: _boxWidth,
        height: _boxHeight,
        child: _CajaSerie(
          // Clave estable por serie: la usan los tests para tocar una caja
          // concreta del cuadro sin depender de en qué orden salgan los
          // InkWell de la pantalla.
          key: serie == null ? null : ValueKey('serie-${serie.id}'),
          db: db,
          serie: serie,
          equipoUsuario: equipoUsuario,
          procesando: procesando,
          bloqueada: bloqueadoPorPlayIn,
          onSimular: onSimular,
          etiquetaVacia: etiquetaVacia,
        ),
      );
    }

    // El Oeste baja (filas 0,1,2), la Final NBA en medio (3) y el Este sube
    // (4,5,6): el mismo cuadro de siempre girado un cuarto de vuelta.
    final cajas = <Widget>[
      for (var i = 0; i < 4; i++)
        caja(oeste[i], _centroX(0, i), _centroY(0),
            etiquetaVacia: 'Primera ronda'),
      for (var i = 0; i < 2; i++)
        caja(semisOeste[i], _centroX(1, i), _centroY(1),
            etiquetaVacia: 'Semifinal de conferencia'),
      caja(finalOeste, centroFinales, _centroY(2),
          etiquetaVacia: 'Final de conferencia'),
      caja(finalNba, centroFinales, _centroY(3), etiquetaVacia: 'Final NBA'),
      caja(finalEste, centroFinales, _centroY(4),
          etiquetaVacia: 'Final de conferencia'),
      for (var i = 0; i < 2; i++)
        caja(semisEste[i], _centroX(1, i), _centroY(5),
            etiquetaVacia: 'Semifinal de conferencia'),
      for (var i = 0; i < 4; i++)
        caja(este[i], _centroX(0, i), _centroY(6),
            etiquetaVacia: 'Primera ronda'),
    ];

    // El nombre de cada ronda, a la izquierda y a la altura de su fila. En
    // horizontal esto era una cabecera de columnas; girado el cuadro, la
    // primera ronda ocupa todo el ancho y no queda hueco arriba.
    const nombresDeFila = [
      'Primera\nronda',
      'Semifinales',
      'Final\nOeste',
      'FINAL\nNBA',
      'Final\nEste',
      'Semifinales',
      'Primera\nronda',
    ];
    final etiquetas = <Widget>[
      for (var fila = 0; fila < 7; fila++)
        Positioned(
          left: 0,
          top: _centroY(fila) - _boxHeight / 2,
          width: _anchoEtiquetas - 8,
          height: _boxHeight,
          child: Center(
            child: _Ronda(
                texto: nombresDeFila[fila], destacado: fila == 3),
          ),
        ),
    ];

    final cuadro = SizedBox(
      width: anchoTotal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TituloConferencia(conferencia: 'Oeste', ancho: anchoTotal),
          const SizedBox(height: 4),
          SizedBox(
            width: anchoTotal,
            height: alturaCuadro,
            child: Stack(
              children: [
                Positioned(
                  left: _anchoEtiquetas,
                  top: 0,
                  width: anchoCuadro,
                  height: alturaCuadro,
                  child: CustomPaint(
                    size: Size(anchoCuadro, alturaCuadro),
                    painter: _ConectorBracket(
                      boxHeight: _boxHeight,
                      centroX: _centroX,
                      centroY: _centroY,
                      centroFinales: centroFinales,
                      color: lineColor,
                    ),
                  ),
                ),
                ...etiquetas,
                // Las cajas se colocan en coordenadas del cuadro, así que
                // van desplazadas por la columna de etiquetas.
                Positioned(
                  left: _anchoEtiquetas,
                  top: 0,
                  width: anchoCuadro,
                  height: alturaCuadro,
                  child: Stack(children: cajas),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _TituloConferencia(conferencia: 'Este', ancho: anchoTotal),
        ],
      ),
    );

    // Se encoge hasta caber en el ancho que haya, para que el cuadro se vea
    // ENTERO sin arrastrar el dedo a ciegas. En vertical la penalización es
    // mucho menor que antes: 714 píxeles de ancho en vez de 1400, o sea que
    // en un móvil de 390 se queda al 55% en lugar del 28%.
    //
    // Aun así, encogido los nombres se leen justos, y por eso va dentro de
    // un InteractiveViewer: se pellizca para acercarse a lo que interese.
    // Los botones de simular siguen funcionando con el zoom puesto.
    final alturaTotal = alturaCuadro + 2 * _altoBanda + 8;
    return LayoutBuilder(builder: (context, constraints) {
      final escala = constraints.maxWidth >= anchoTotal
          ? 1.0
          : constraints.maxWidth / anchoTotal;
      final encogido = SizedBox(
        // Clave estable para medir el cuadro desde los tests: si cabe sin
        // encoger no hay InteractiveViewer, así que buscar ese widget no
        // sirve para saber cuánto ocupa.
        key: const ValueKey('cuadro-playoffs'),
        width: anchoTotal * escala,
        height: alturaTotal * escala,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.topLeft,
          child: SizedBox(
              width: anchoTotal, height: alturaTotal, child: cuadro),
        ),
      );
      if (escala == 1.0) return encogido;
      return InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: encogido,
      );
    });
  }
}


/// La franja de color que dice de qué conferencia es cada mitad del cuadro:
/// una arriba del todo (Oeste) y otra abajo del todo (Este).
class _TituloConferencia extends StatelessWidget {
  final String conferencia;
  final double ancho;

  const _TituloConferencia(
      {required this.conferencia, required this.ancho});

  @override
  Widget build(BuildContext context) {
    final info = infoDe(conferencia);
    return Container(
      width: ancho,
      height: _BracketVisual._altoBanda,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: info.colorPrimario,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'CONFERENCIA ${conferencia.toUpperCase()}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: textoSobre(info.colorPrimario),
        ),
      ),
    );
  }
}

class _Ronda extends StatelessWidget {
  final String texto;
  final bool destacado;

  const _Ronda({required this.texto, this.destacado = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
        color: destacado
            ? const Color(0xFFD4A017)
            : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

/// Las líneas del cuadro, ahora de arriba abajo: dos hermanas confluyen en
/// la caja de la ronda siguiente, que está una fila más adentro.
class _ConectorBracket extends CustomPainter {
  final double boxHeight;
  final double Function(int ronda, int indice) centroX;
  final double Function(int fila) centroY;
  final double centroFinales;
  final Color color;

  const _ConectorBracket({
    required this.boxHeight,
    required this.centroX,
    required this.centroY,
    required this.centroFinales,
    required this.color,
  });

  /// Une dos cajas hermanas (en `xA` y `xB`, con su borde en `yDesde`) con
  /// la caja padre (borde en `yHasta`, centrada entre las dos). Funciona en
  /// los dos sentidos: si `yHasta` está por encima, el trazo sube.
  void _tramo(Canvas canvas, Paint paint, double yDesde, double xA, double xB,
      double yHasta) {
    final yMid = (yDesde + yHasta) / 2;
    canvas.drawLine(Offset(xA, yDesde), Offset(xA, yMid), paint);
    canvas.drawLine(Offset(xB, yDesde), Offset(xB, yMid), paint);
    canvas.drawLine(Offset(xA, yMid), Offset(xB, yMid), paint);
    final xMid = (xA + xB) / 2;
    canvas.drawLine(Offset(xMid, yMid), Offset(xMid, yHasta), paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    double abajoDe(int fila) => centroY(fila) + boxHeight / 2;
    double arribaDe(int fila) => centroY(fila) - boxHeight / 2;

    // Oeste, bajando: Ronda1 (fila 0) -> Semis (1) -> Final Oeste (2).
    for (var i = 0; i < 2; i++) {
      _tramo(canvas, paint, abajoDe(0), centroX(0, 2 * i),
          centroX(0, 2 * i + 1), arribaDe(1));
    }
    _tramo(canvas, paint, abajoDe(1), centroX(1, 0), centroX(1, 1),
        arribaDe(2));
    // Final Oeste -> Final NBA.
    canvas.drawLine(Offset(centroFinales, abajoDe(2)),
        Offset(centroFinales, arribaDe(3)), paint);

    // Este, subiendo: Ronda1 (fila 6) -> Semis (5) -> Final Este (4).
    for (var i = 0; i < 2; i++) {
      _tramo(canvas, paint, arribaDe(6), centroX(0, 2 * i),
          centroX(0, 2 * i + 1), abajoDe(5));
    }
    _tramo(canvas, paint, arribaDe(5), centroX(1, 0), centroX(1, 1),
        abajoDe(4));
    // Final Este -> Final NBA.
    canvas.drawLine(Offset(centroFinales, arribaDe(4)),
        Offset(centroFinales, abajoDe(3)), paint);
  }

  @override
  bool shouldRepaint(covariant _ConectorBracket oldDelegate) => false;
}

class _CajaSerie extends StatelessWidget {
  final AppDatabase db;
  final Serie? serie;
  final String equipoUsuario;
  final bool procesando;

  /// Mientras el play-in no termine, ninguna serie del cuadro se puede
  /// jugar aunque ya se sepan sus dos equipos.
  final bool bloqueada;
  final VoidCallback onSimular;
  final String etiquetaVacia;

  const _CajaSerie({
    super.key,
    required this.db,
    required this.serie,
    required this.equipoUsuario,
    required this.procesando,
    required this.bloqueada,
    required this.onSimular,
    required this.etiquetaVacia,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    final serie = this.serie;
    if (serie == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(etiquetaVacia,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: borderColor)),
      );
    }

    final esTuSerie =
        serie.equipoA == equipoUsuario || serie.equipoB == equipoUsuario;
    // La Final ya decidida se corona en el propio cuadro: dorada y con el
    // trofeo. Antes el campeón solo se sabía por el banner de arriba, y al
    // mirar el bracket la caja del título era una más.
    final esCampeon = serie.etapa == 'finalNBA' && serie.ganador != null;
    const dorado = Color(0xFFD4A017);

    return InkWell(
      onTap: (serie.victoriasA + serie.victoriasB) == 0
          ? null
          : () => abrirEstadisticasDeSerie(context, db,
              origen: 'playoffs', serieId: serie.id),
      child: Container(
        decoration: BoxDecoration(
          color: esCampeon ? dorado.withValues(alpha: 0.14) : null,
          border: Border.all(
              color: esCampeon
                  ? dorado
                  : (esTuSerie
                      ? Theme.of(context).colorScheme.primary
                      : borderColor),
              width: esCampeon || esTuSerie ? 2 : 1),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _filaEquipo(context, serie.equipoA, serie.seedA, serie.victoriasA,
                serie.ganador == serie.equipoA),
            _filaEquipo(context, serie.equipoB, serie.seedB, serie.victoriasB,
                serie.ganador == serie.equipoB),
            if (esTuSerie && serie.ganador == null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(
                  height: 20,
                  child: bloqueada
                      // El texto va en Flexible: la caja del bracket mide
                      // 176 fijos y "Esperando al Play-In" con su candado
                      // se salía 39px por la derecha. Pasaba también en
                      // escritorio — la caja no depende del ancho de la
                      // ventana— solo que nadie lo había mirado.
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_clock,
                                size: 11, color: borderColor),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text('Esperando al Play-In',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 9, color: borderColor)),
                            ),
                          ],
                        )
                      : FilledButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(fontSize: 10),
                          ),
                          onPressed: procesando ? null : onSimular,
                          child: const Text('Simular'),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filaEquipo(
      BuildContext context, String equipo, int seed, int victorias, bool gana) {
    // El rival que sale del play-in todavía no existe: su hueco se enseña
    // como tal, en vez de como un equipo sin nombre ni escudo.
    if (equipo == equipoPorDefinir) {
      final gris = Theme.of(context).colorScheme.outline;
      return Row(
        children: [
          if (seed > 0)
            Text('$seed ',
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Icon(Icons.help_outline, size: 16, color: gris),
          const SizedBox(width: 4),
          Expanded(
            child: Text('Por definir',
                style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: gris),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (seed > 0)
          Text('$seed ', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        EquipoLogo(codigoEquipo: equipo, tamano: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            infoDe(equipo).apodo,
            style: TextStyle(
                fontSize: 11, fontWeight: gana ? FontWeight.bold : FontWeight.normal),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text('$victorias', style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
