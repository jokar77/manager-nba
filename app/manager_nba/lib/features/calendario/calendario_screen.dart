import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../data/calendario/generador_calendario.dart';
import '../../data/database/app_database.dart';
import '../../domain/calendario_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/fin_temporada_repository.dart';
import '../../domain/playoffs_repository.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/tipo_evento_temporada.dart';
import '../../main.dart' show routeObserver;
import '../../shared/campeon_dialog.dart';
import '../../shared/pantalla.dart';
import '../playoffs/playoffs_screen.dart';
import '../temporada/cambio_de_temporada.dart';
import 'resumen_simulacion_screen.dart';
import 'simulacion_ui.dart';
import '../../shared/contraste.dart';

/// Pantalla de calendario: toda la temporada en una única lista con
/// scroll continuo (un mes tras otro), cabecera de días de la semana en
/// cada mes, y celdas grandes para partidos y fechas especiales. Tocar un
/// día pendiente simula todo lo que falta hasta ahí.
class CalendarioScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const CalendarioScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> with RouteAware {
  List<PartidosCalendarioData> _partidos = [];
  List<EventosTemporadaData> _eventos = [];
  List<Serie> _seriesPlayoffs = [];
  bool _temporadaCompleta = false;
  bool _cargando = true;
  bool _simulando = false;
  bool _procesandoPlayoffs = false;
  bool _campeonPlayoffsYaVisto = false;
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _clavesPorMes = {};

  @override
  void initState() {
    super.initState();
    _recargarDatos(scrollearAlActual: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  /// Al volver de Premios o del bracket de Playoffs puede haber cambiado la
  /// temporada entera (playoffs recién sembrados, o un año nuevo con
  /// calendario regenerado): sin esto, esta pantalla seguía enseñando el
  /// bracket ya acabado de la temporada anterior porque nadie le avisaba de
  /// que volviera a leer sus datos.
  @override
  void didPopNext() => _recargarDatos();

  List<DateTime> get _mesesDeLaTemporada {
    if (_partidos.isEmpty) return [];
    final primero = _partidos.first.fecha;
    final ultimo = _partidos.last.fecha;
    final meses = <DateTime>[];
    var cursor = DateTime(primero.year, primero.month);
    final fin = DateTime(ultimo.year, ultimo.month);
    while (!cursor.isAfter(fin)) {
      meses.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return meses;
  }

  String _claveMes(DateTime mes) => '${mes.year}-${mes.month}';

  Future<void> _recargarDatos({bool scrollearAlActual = false}) async {
    final partidos = await leerPartidos(widget.db, widget.equipoUsuario);
    final eventos = await leerEventos(widget.db);
    final temporadaCompleta =
        await temporadaRegularCompleta(widget.db, widget.equipoUsuario);
    final series =
        temporadaCompleta ? await leerSeries(widget.db) : <Serie>[];
    if (!mounted) return;
    setState(() {
      _partidos = partidos;
      _eventos = eventos;
      _temporadaCompleta = temporadaCompleta;
      _seriesPlayoffs = series;
      _cargando = false;
    });
    _campeonPlayoffsYaVisto = _campeonDePlayoffs(series) != null;
    if (scrollearAlActual) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollearAlMesActual());
    }
  }

  String? _campeonDePlayoffs(List<Serie> series) =>
      series.where((s) => s.conferencia == 'Final').firstOrNull?.ganador;

  /// Ejecuta [accion] (una simulación de playoffs), recarga las series y,
  /// si con esto se acaba de decidir la Final NBA por primera vez, anuncia
  /// al campeón con un diálogo — no solo el banner pasivo del panel.
  Future<void> _simularPlayoffsYComprobarCampeon(
      Future<void> Function() accion) async {
    setState(() => _procesandoPlayoffs = true);
    await accion();
    if (!mounted) return;
    final series = await leerSeries(widget.db);
    if (!mounted) return;
    setState(() {
      _seriesPlayoffs = series;
      _procesandoPlayoffs = false;
    });

    final campeon = _campeonDePlayoffs(series);
    if (campeon != null && !_campeonPlayoffsYaVisto) {
      _campeonPlayoffsYaVisto = true;
      final mvp = await mvpDeLasFinales(widget.db);
      final temporada = await leerTemporada(widget.db);
      if (mounted) {
        await mostrarCampeonDecidido(
          context,
          false,
          campeon,
          esTuEquipo: campeon == widget.equipoUsuario,
          temporada: etiquetaDeTemporada(temporada.anioInicio),
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
    }
  }

  Future<void> _simularPartidoDePlayoffs() => _simularPlayoffsYComprobarCampeon(
      () => avanzarPlayoffsUnPartido(widget.db, widget.equipoUsuario));

  Future<void> _simularPlayoffsCompletos() => _simularPlayoffsYComprobarCampeon(
      () => simularPlayoffsCompletos(widget.db));

  Future<void> _simularRestoDeRondaDePlayoffs() =>
      _simularPlayoffsYComprobarCampeon(
          () => simularRondaPlayoffsCompleta(widget.db));

  /// Cierra el año y arranca el siguiente (envejecimiento, retiradas,
  /// draft, calendario nuevo) enseñando antes el resumen de pretemporada.
  Future<void> _empezarNuevaTemporada() async {
    setState(() => _procesandoPlayoffs = true);
    final hecho = await ejecutarCambioDeTemporada(
        context, widget.db, widget.equipoUsuario);
    if (!mounted || !hecho) return;

    _campeonPlayoffsYaVisto = false;
    await _recargarDatos(scrollearAlActual: true);
    if (!mounted) return;
    setState(() => _procesandoPlayoffs = false);
  }

  void _scrollearAlMesActual() {
    if (_partidos.isEmpty || !mounted) return;
    final fechaObjetivo =
        proximaFechaPendiente(_partidos) ?? fechaActualDeLaTemporada(_partidos);
    final clave = _claveMes(DateTime(fechaObjetivo.year, fechaObjetivo.month));
    final key = _clavesPorMes[clave];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 300), alignment: 0.05);
    }
  }

  Future<void> _simularHasta(DateTime diaObjetivo) async {
    setState(() => _simulando = true);
    final resultado = await simularHastaConDialogo(
        context, widget.db, widget.equipoUsuario, diaObjetivo);

    await _recargarDatos();
    if (!mounted) return;
    setState(() => _simulando = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollearAlMesActual());

    if (resultado.partidos.isNotEmpty && mounted) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ResumenSimulacionScreen(
          db: widget.db,
          equipoUsuario: widget.equipoUsuario,
          resultado: resultado,
        ),
      ));
      if (!mounted) return;
      await _recargarDatos();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollearAlMesActual());
    }
  }

  /// Tocar un día suelto del calendario simula TODO lo que haya hasta esa
  /// fecha, que pueden ser semanas enteras: se pregunta antes, porque un
  /// toque sin querer en el mes que viene no tiene vuelta atrás.
  Future<void> _confirmarYSimularHasta(DateTime fecha) async {
    final pendientes = _partidos
        .where((p) => !p.jugado && !p.fecha.isAfter(fecha))
        .length;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t(context).confirmarSimularTitulo),
        content: Text(
          pendientes <= 1
              ? t(context).seJugaraProximoPartido
              : t(context).seJugaranDeUnaVez(
                  pendientes, fecha.day, fecha.month),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t(context).cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t(context).simular),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) await _simularHasta(fecha);
  }

  void _tocarDia(DateTime fecha) {
    final partido = _partidos.where((p) => _mismoDia(p.fecha, fecha)).firstOrNull;
    if (partido != null) {
      if (partido.jugado) {
        final enfrentamiento = partido.esLocal
            ? '${widget.equipoUsuario} vs ${partido.rival}'
            : '${partido.rival} vs ${widget.equipoUsuario}';
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(partido.fase == faseFinalCopa
                ? t(context).finalCupVs(enfrentamiento)
                : enfrentamiento),
            content: Text(
              '${widget.equipoUsuario} ${partido.marcadorPropietario} - '
              '${partido.marcadorRival} ${partido.rival}',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t(context).cerrar),
              ),
            ],
          ),
        );
      } else if (!_simulando) {
        _confirmarYSimularHasta(fecha);
      }
      return;
    }

    final evento = _eventos.where((e) => _mismoDia(e.fecha, fecha)).firstOrNull;
    if (evento != null) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(_tituloEvento(t(context), evento.tipo)),
          content: Text(_descripcionEvento(t(context), evento.tipo)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t(context).cerrar),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorEquipo = infoDe(widget.equipoUsuario).colorPrimario;
    final proximoPendiente = _cargando ? null : proximaFechaPendiente(_partidos);

    return Scaffold(
      appBar: AppBar(
        title: Text(t(context).calendario),
        backgroundColor: colorEquipo,
        foregroundColor: textoSobre(colorEquipo),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _BotonesAvanceRapido(
                  habilitado: !_simulando && proximoPendiente != null,
                  onSimular1Partido: proximoPendiente == null
                      ? null
                      : () => _simularHasta(proximoPendiente),
                  onSimular1Semana: () => _simularHasta(
                      fechaActualDeLaTemporada(_partidos).add(const Duration(days: 7))),
                  onSimular1Mes: () => _simularHasta(
                      fechaActualDeLaTemporada(_partidos).add(const Duration(days: 30))),
                ),
                if (_simulando) const LinearProgressIndicator(),
                if (_temporadaCompleta)
                  _PanelPlayoffs(
                    db: widget.db,
                    equipoUsuario: widget.equipoUsuario,
                    series: _seriesPlayoffs,
                    procesando: _procesandoPlayoffs,
                    onSimularPartido: _simularPartidoDePlayoffs,
                    onSimularTodo: _simularPlayoffsCompletos,
                    onSimularRestoDeRonda: _simularRestoDeRondaDePlayoffs,
                    onEmpezarNuevaTemporada: _empezarNuevaTemporada,
                  ),
                Expanded(
                  // El alto que queda para el calendario se le pasa a cada
                  // mes para que la cuadrícula se ajuste y un mes entero
                  // quepa de una vez. Sin esto, la celda tenía una
                  // proporción fija y en un móvil se salía por abajo: había
                  // que arrastrar para ver la última semana.
                  child: LayoutBuilder(builder: (context, constraints) {
                    return ListView(
                      controller: _scrollController,
                      // La temporada son ~9 meses: construirlos todos de
                      // golpe es barato y hace falta para poder saltar al mes
                      // que toca. Con el cacheExtent por defecto, los meses
                      // aún no renderizados no tienen contexto y
                      // `ensureVisible` se quedaba sin hacer nada (la vista
                      // se quedaba clavada en octubre tras simular un mes).
                      scrollCacheExtent: const ScrollCacheExtent.pixels(20000),
                      children: _mesesDeLaTemporada.map((mes) {
                        final clave = _claveMes(mes);
                        final key =
                            _clavesPorMes.putIfAbsent(clave, () => GlobalKey());
                        return _SeccionMes(
                          key: key,
                          mes: mes,
                          equipoUsuario: widget.equipoUsuario,
                          partidos: _partidos,
                          eventos: _eventos,
                          fechaActual: fechaActualDeLaTemporada(_partidos),
                          onTocarDia: _tocarDia,
                          alturaDisponible: constraints.maxHeight,
                        );
                      }).toList(),
                    );
                  }),
                ),
              ],
            ),
    );
  }
}

bool _mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _tituloEvento(Textos textos, String tipo) {
  final t = TipoEventoTemporada.desdeNombre(tipo);
  return switch (t) {
    TipoEventoTemporada.finAgenciaLibre => textos.tituloEventoFinAgenciaLibre,
    TipoEventoTemporada.fechaLimiteTraspasos =>
      textos.tituloEventoFechaLimiteTraspasos,
    TipoEventoTemporada.allStar => textos.tituloEventoAllStar,
  };
}

String _descripcionEvento(Textos textos, String tipo) {
  final t = TipoEventoTemporada.desdeNombre(tipo);
  return switch (t) {
    TipoEventoTemporada.finAgenciaLibre => textos.descEventoFinAgenciaLibre,
    TipoEventoTemporada.fechaLimiteTraspasos =>
      textos.descEventoFechaLimiteTraspasos,
    TipoEventoTemporada.allStar => textos.descEventoAllStar,
  };
}

class _BotonesAvanceRapido extends StatelessWidget {
  final bool habilitado;
  final VoidCallback? onSimular1Partido;
  final VoidCallback onSimular1Semana;
  final VoidCallback onSimular1Mes;

  const _BotonesAvanceRapido({
    required this.habilitado,
    required this.onSimular1Partido,
    required this.onSimular1Semana,
    required this.onSimular1Mes,
  });

  @override
  Widget build(BuildContext context) {
    // En un móvil cada botón se queda con unos 120 píxeles y "Simular 1
    // partido" no cabe en una línea: la fila crecía a tres renglones y le
    // robaba al calendario el alto que necesita para enseñar el mes entero.
    // El verbo se sobreentiende, así que en compacto se cae.
    final compacto = tamanoDe(context).esCompacto;
    final textos = t(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: habilitado ? onSimular1Partido : null,
              child: Text(
                  compacto ? textos.unPartido : textos.simularUnPartido,
                  maxLines: 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: habilitado ? onSimular1Semana : null,
              child: Text(
                  compacto ? textos.unaSemana : textos.simularUnaSemana,
                  maxLines: 1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: habilitado ? onSimular1Mes : null,
              child: Text(compacto ? textos.unMes : textos.simularUnMes,
                  maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }
}



class _SeccionMes extends StatelessWidget {
  final DateTime mes;
  final String equipoUsuario;
  final List<PartidosCalendarioData> partidos;
  final List<EventosTemporadaData> eventos;
  final DateTime fechaActual;
  final void Function(DateTime) onTocarDia;

  /// Lo que mide de alto la zona de scroll del calendario. El mes intenta
  /// caber entero ahí dentro.
  final double alturaDisponible;

  const _SeccionMes({
    super.key,
    required this.mes,
    required this.equipoUsuario,
    required this.partidos,
    required this.eventos,
    required this.fechaActual,
    required this.onTocarDia,
    required this.alturaDisponible,
  });

  /// Lo que ocupa el mes por encima de la cuadrícula: el nombre del mes con
  /// su margen, la fila de iniciales de los días y el padding de la rejilla.
  static const _altoDeLasCabeceras = 70.0;

  /// Por debajo de esto la celda deja de poder enseñar el día, el rival y el
  /// resultado. Antes que apretarla más, se prefiere que el mes se salga un
  /// poco y haya que arrastrar.
  static const _altoMinimoDeCelda = 52.0;

  /// Proporción de celda cuando sobra sitio: un poco más alta que ancha, que
  /// es donde mejor entra el nombre del rival.
  static const _proporcionComoda = 0.85;

  @override
  Widget build(BuildContext context) {
    final diasEnMes = DateUtils.getDaysInMonth(mes.year, mes.month);
    final primerDiaSemana = DateTime(mes.year, mes.month, 1).weekday; // 1=lunes
    final huecosIniciales = primerDiaSemana - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
          child: Text(
            '${t(context).nombresMeses[mes.month - 1]} ${mes.year}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: t(context).diasSemanaAbrev
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline)),
                      ),
                    ))
                .toList(),
          ),
        ),
        LayoutBuilder(builder: (context, constraints) {
          // Un mes tiene que caber de una vez: se reparte el alto que queda
          // entre las semanas que tenga ese mes (4, 5 o 6) y de ahí sale la
          // proporción de la celda. Si sobra sitio se queda en la cómoda de
          // siempre, y nunca baja del mínimo legible.
          final filas = ((huecosIniciales + diasEnMes) / 7).ceil();
          final anchoCelda = (constraints.maxWidth - 8) / 7;
          final altoQueCabe =
              (alturaDisponible - _altoDeLasCabeceras) / filas;
          final altoCelda = altoQueCabe.clamp(
              _altoMinimoDeCelda, anchoCelda / _proporcionComoda);

          return GridView.builder(
            padding: const EdgeInsets.all(4),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: anchoCelda / altoCelda,
            ),
            itemCount: huecosIniciales + diasEnMes,
            itemBuilder: (context, index) {
              if (index < huecosIniciales) return const SizedBox.shrink();
              final dia = index - huecosIniciales + 1;
              final fecha = DateTime(mes.year, mes.month, dia);
              return _CeldaDia(
                dia: dia,
                fecha: fecha,
                equipoUsuario: equipoUsuario,
                partido:
                    partidos.where((p) => _mismoDia(p.fecha, fecha)).firstOrNull,
                evento:
                    eventos.where((e) => _mismoDia(e.fecha, fecha)).firstOrNull,
                esPasado: fecha.isBefore(DateTime(
                    fechaActual.year, fechaActual.month, fechaActual.day)),
                onTap: () => onTocarDia(fecha),
              );
            },
          );
        }),
      ],
    );
  }
}

class _CeldaDia extends StatelessWidget {
  final int dia;
  final DateTime fecha;
  final String equipoUsuario;
  final PartidosCalendarioData? partido;
  final EventosTemporadaData? evento;
  final bool esPasado;
  final VoidCallback onTap;

  const _CeldaDia({
    required this.dia,
    required this.fecha,
    required this.equipoUsuario,
    required this.partido,
    required this.evento,
    required this.esPasado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colores translúcidos (no un fondo claro fijo): así el texto de la
    // celda, que hereda el color por defecto del tema, mantiene contraste
    // tanto en modo claro como oscuro — con un fondo claro fijo, el texto
    // claro del modo oscuro quedaba casi ilegible encima.
    Color? color;
    if (partido != null) {
      if (partido!.jugado) {
        final gana = partido!.marcadorPropietario! >= partido!.marcadorRival!;
        color = (gana ? Colors.green : Colors.red).withValues(alpha: 0.18);
      } else {
        color = Colors.blue.withValues(alpha: 0.12);
      }
    }
    final colorTexto = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: (partido != null || evento != null) ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(2),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // En un móvil la celda mide unos 50px: el día con su
                    // abreviatura más los iconos no caben en la misma
                    // línea y se salían. El nombre del día se cae en
                    // compacto — ya está en la cabecera de la columna, así
                    // que no se pierde información.
                    Flexible(
                      child: Text(
                        tamanoDe(context).esCompacto
                            ? '$dia'
                            : '$dia ${t(context).diasSemanaAbrev[fecha.weekday - 1]}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: colorTexto),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (partido != null)
                          Icon(
                            partido!.esLocal
                                ? Icons.home
                                : Icons.flight_takeoff,
                            size: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        if (partido?.esTorneoTemporada == true)
                          const Icon(Icons.emoji_events,
                              size: 16, color: Colors.amber),
                        if (evento != null)
                          Icon(_iconoEvento(evento!.tipo), size: 18,
                              color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ],
                ),
                if (partido != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        partido!.rival,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorTexto),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                if (partido?.jugado == true)
                  Text(
                    '${partido!.marcadorPropietario}-${partido!.marcadorRival}',
                    style: TextStyle(fontSize: 10, color: colorTexto),
                  ),
              ],
            ),
            // Días ya pasados (con partido o sin él) llevan un tinte gris
            // para distinguirlos claramente de lo que queda por delante.
            if (esPasado)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(color: Colors.black.withValues(alpha: 0.12)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconoEvento(String tipo) {
    final t = TipoEventoTemporada.desdeNombre(tipo);
    return switch (t) {
      TipoEventoTemporada.finAgenciaLibre => Icons.person_search,
      TipoEventoTemporada.fechaLimiteTraspasos => Icons.gavel,
      TipoEventoTemporada.allStar => Icons.star,
    };
  }
}

/// Panel de playoffs integrado en el propio Calendario: una vez tu
/// temporada regular está completa, deja seguir jugando el play-in y el
/// bracket sin salir de esta pantalla — la pestaña "Playoffs" del menú
/// sigue existiendo aparte, con el bracket visual completo.
class _PanelPlayoffs extends StatelessWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final List<Serie> series;
  final bool procesando;
  final VoidCallback onSimularPartido;
  final VoidCallback onSimularTodo;
  final VoidCallback onSimularRestoDeRonda;
  final VoidCallback onEmpezarNuevaTemporada;

  const _PanelPlayoffs({
    required this.db,
    required this.equipoUsuario,
    required this.series,
    required this.procesando,
    required this.onSimularPartido,
    required this.onSimularTodo,
    required this.onSimularRestoDeRonda,
    required this.onEmpezarNuevaTemporada,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) return const SizedBox.shrink();

    final finalNba = series.where((s) => s.conferencia == 'Final').firstOrNull;
    final campeon = finalNba?.ganador;
    final tuSerie = series
        .where((s) =>
            (s.equipoA == equipoUsuario || s.equipoB == equipoUsuario) &&
            s.ganador == null)
        .firstOrNull;
    final implicado = series.any((s) =>
        (s.equipoA == equipoUsuario || s.equipoB == equipoUsuario) &&
        (s.ganador == null || s.ganador == equipoUsuario));

    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t(context).playoffs,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PlayoffsScreen(
                        db: db, equipoUsuario: equipoUsuario),
                  )),
                  child: Text(t(context).verBracketCompleto),
                ),
              ],
            ),
            if (campeon != null) ...[
              BannerCampeon(
                esCup: false,
                campeon: campeon,
                esTuEquipo: campeon == equipoUsuario,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: procesando ? null : onEmpezarNuevaTemporada,
                  icon: const Icon(Icons.skip_next),
                  label: Text(t(context).empezarSiguienteTemporada),
                ),
              ),
            ]
            else if (tuSerie != null) ...[
              Text(tuSerie.victoriasNecesarias == 1
                  ? '${tuSerie.equipoA} vs ${tuSerie.equipoB}'
                  : '${tuSerie.equipoA} ${tuSerie.victoriasA} - '
                      '${tuSerie.victoriasB} ${tuSerie.equipoB}'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: procesando ? null : onSimularPartido,
                  child: Text(t(context).simularPartidoDePlayoffs),
                ),
              ),
            ] else if (!implicado) ...[
              Text(t(context).noClasificasteAPlayoffs),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: procesando ? null : onSimularTodo,
                  child: Text(t(context).simularPlayoffsCompletos),
                ),
              ),
            ] else ...[
              Text(t(context).serieDecididaFaltaResto),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: procesando ? null : onSimularRestoDeRonda,
                  child: Text(t(context).simularRestoDeRonda),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
