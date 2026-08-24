import 'dart:math';

import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/estilo.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../data/calendario/generador_calendario.dart';
import '../../data/database/app_database.dart';
import '../../domain/calendario_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/fin_temporada_repository.dart';
import '../../domain/permisos.dart';
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

  /// Solo para los tests: siembra el azar de lo que pasa mientras simulas.
  /// Ver `simularHastaConDialogo`, que es quien lo usa.
  final Random? random;

  const CalendarioScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    this.random,
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
  int _totalASimular = 0;
  List<PartidoSimuladoInfo> _progresoSimulacion = const [];
  bool _procesandoPlayoffs = false;
  bool _campeonPlayoffsYaVisto = false;
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _clavesPorMes = {};

  /// En qué temporada va la partida. Solo se usa para el permiso de
  /// «Temporada»; hasta que se carga, ese botón sale bloqueado, que es el
  /// lado seguro.
  int? _temporadaActual;

  /// Si esta partida puede simular el año de golpe. En la versión gratuita
  /// no: es uno de los tres bloqueos (ver `permisos.dart`).
  bool get _puedeTemporadaEntera =>
      _temporadaActual != null &&
      permisos.puede(
        Funcion.simularTemporadaEntera,
        temporada: _temporadaActual,
      );

  /// Simula lo que quede de temporada regular, sobre el calendario y con su
  /// barra de progreso.
  void _simularTemporadaEntera() {
    if (_partidos.isEmpty || _temporadaCompleta) return;
    if (proximaFechaPendiente(_partidos) == null) return;
    _simularHasta(_partidos.last.fecha);
  }

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
    // El número de temporada solo hace falta para saber si «Temporada»
    // está desbloqueado: el vídeo recompensado abre esa función durante una
    // temporada y solo esa (ver `permisos.dart`).
    final temporada = await leerTemporada(widget.db);
    if (!mounted) return;
    setState(() {
      _partidos = partidos;
      _eventos = eventos;
      _temporadaCompleta = temporadaCompleta;
      _seriesPlayoffs = series;
      _temporadaActual = temporada.numero;
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

  /// Desplaza el calendario para que se vea el mes de [fecha]. Lo usan
  /// tanto "ir al mes actual" al abrir/terminar como el avance en vivo
  /// mientras se simula (ver `_simularHasta`).
  void _scrollearAFecha(DateTime fecha) {
    if (!mounted) return;
    final clave = _claveMes(DateTime(fecha.year, fecha.month));
    final key = _clavesPorMes[clave];
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 300), alignment: 0.05);
    }
  }

  void _scrollearAlMesActual() {
    if (_partidos.isEmpty || !mounted) return;
    _scrollearAFecha(
        proximaFechaPendiente(_partidos) ?? fechaActualDeLaTemporada(_partidos));
  }

  Future<void> _simularHasta(DateTime diaObjetivo) async {
    setState(() {
      _simulando = true;
      _totalASimular = partidosPendientesHasta(_partidos, diaObjetivo);
      _progresoSimulacion = const [];
    });
    final resultado = await simularHastaConDialogo(
        context, widget.db, widget.equipoUsuario, diaObjetivo,
        random: widget.random, onProgreso: (hastaAhora) {
      if (!mounted) return;
      setState(() => _progresoSimulacion = hastaAhora);
      // Lista 15 punto 4: sin esto, la vista se quedaba clavada en el mes
      // en el que se tocó "simular" mientras el marcador avanzaba semanas
      // por delante — no se veía por dónde iba de verdad hasta que
      // terminaba todo el tramo. Se sigue el último partido resuelto, que
      // es lo único que avanza en tiempo real durante la simulación (los
      // `_partidos` de la pantalla no se refrescan hasta el final).
      if (hastaAhora.isNotEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollearAFecha(hastaAhora.last.fecha));
      }
    });

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
          // Desde el resumen se puede seguir simulando, así que la semilla
          // tiene que viajar con él o el azar volvería a entrar por ahí.
          random: widget.random,
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
          BotonDialogoSecundario(
            texto: t(context).cancelar,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          BotonDialogoPrincipal(
            texto: t(context).simular,
            onPressed: () => Navigator.of(context).pop(true),
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
              BotonDialogoSecundario(
                texto: t(context).cerrar,
                onPressed: () => Navigator.of(context).pop(),
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
            BotonDialogoSecundario(
              texto: t(context).cerrar,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = infoDe(widget.equipoUsuario);
    final estilo = Estilo.de(context);
    final proximoPendiente = _cargando ? null : proximaFechaPendiente(_partidos);

    return Scaffold(
      backgroundColor: estilo.fondo,
      body: Column(
        children: [
          BarraDeTitulo(
            codigo: widget.equipoUsuario,
            primario: info.colorPrimario,
            secundario: info.colorSecundario,
            sobretitulo: info.nombreCompleto,
            titulo: t(context).calendario,
          ),
          if (_cargando)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Column(
                children: [
                _BotonesAvanceRapido(
                  habilitado: !_simulando && proximoPendiente != null,
                  onSimular1Semana: () => _simularHasta(
                      fechaActualDeLaTemporada(_partidos).add(const Duration(days: 7))),
                  onSimular1Mes: () => _simularHasta(
                      fechaActualDeLaTemporada(_partidos).add(const Duration(days: 30))),
                  onSimularTemporada: _simularTemporadaEntera,
                  puedeTemporada: _puedeTemporadaEntera,
                ),
                if (_simulando)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: BarraProgresoSimulacion(
                      total: _totalASimular,
                      resultados: _progresoSimulacion
                          .map((p) => p.marcadorUsuario >= p.marcadorRival)
                          .toList(),
                    ),
                  ),
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

/// Los saltos de simulación del calendario, de menos a más: una semana, un
/// mes y lo que quede de temporada.
///
/// **Ya no está "Simular 1 partido"**, y no es un olvido: el partido
/// siguiente se simula desde la tarjeta del menú, que además enseña contra
/// quién juegas. Tenerlo también aquí era el mismo botón dos veces, y le
/// quitaba sitio a los que sí son propios del calendario.
///
/// El orden es de menos a más y **«Temporada» va a la derecha del todo**:
/// es el salto más gordo y el único que puede acabar el año de un toque,
/// así que no conviene tenerlo pegado a los otros dos.
class _BotonesAvanceRapido extends StatelessWidget {
  final bool habilitado;
  final VoidCallback onSimular1Semana;
  final VoidCallback onSimular1Mes;
  final VoidCallback onSimularTemporada;

  /// En la versión gratuita simular el año entero está bloqueado. El botón
  /// se enseña igualmente, con candado: esconderlo dejaría sin ver lo que
  /// se está ofreciendo.
  final bool puedeTemporada;

  const _BotonesAvanceRapido({
    required this.habilitado,
    required this.onSimular1Semana,
    required this.onSimular1Mes,
    required this.onSimularTemporada,
    required this.puedeTemporada,
  });

  @override
  Widget build(BuildContext context) {
    // En un móvil cada botón se queda con unos 120 píxeles y "Simular 1
    // semana" no cabe en una línea: la fila crecía a tres renglones y le
    // robaba al calendario el alto que necesita para enseñar el mes entero.
    // El verbo se sobreentiende, así que en compacto se cae.
    final compacto = tamanoDe(context).esCompacto;
    final textos = t(context);

    final e = Estilo.de(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Row(
        children: [
          Expanded(
            child: BotonPerfilado(
              texto: compacto ? textos.unaSemana : textos.simularUnaSemana,
              color: e.texto,
              alto: 44,
              onTap: habilitado ? onSimular1Semana : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BotonPerfilado(
              texto: compacto ? textos.unMes : textos.simularUnMes,
              color: e.texto,
              alto: 44,
              onTap: habilitado ? onSimular1Mes : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: BotonPerfilado(
              // Lista 15 punto 5: "Temporada entera" en compacto no cabía en
              // una línea, y las dos que hacían falta desbordaban el alto
              // fijo del botón. Mismo tratamiento que los otros dos: el
              // sustantivo solo, sin el verbo ni el adjetivo.
              texto: compacto ? textos.temporada : textos.simularTemporadaEntera,
              icono: puedeTemporada ? Icons.fast_forward : Icons.lock_outline,
              color: e.texto,
              alto: 44,
              onTap: habilitado && puedeTemporada ? onSimularTemporada : null,
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
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
          child: SeparadorSeccion(
            titulo: '${t(context).nombresMeses[mes.month - 1]} ${mes.year}',
            acento: acentoDeEquipo(
                infoDe(equipoUsuario).colorPrimario,
                infoDe(equipoUsuario).colorSecundario),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: t(context)
                .diasSemanaAbrev
                .map((d) => Expanded(
                      child: Center(
                        child: Text(mayus(d),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: rotulo(Estilo.de(context), tamano: 9)),
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
    final e = Estilo.de(context);
    final colorEquipo = infoDe(equipoUsuario).colorPrimario;

    // Tintes translúcidos y no fondos fijos: así el texto de la celda, que
    // sale de la paleta del modo activo, mantiene contraste en claro y en
    // oscuro — con un fondo claro fijo, la tinta clara del modo oscuro
    // quedaba casi ilegible encima.
    Color? fondo;
    Color? filo;
    if (partido != null) {
      if (partido!.jugado) {
        final gana = partido!.marcadorPropietario! >= partido!.marcadorRival!;
        final color = gana ? e.bien : e.mal;
        fondo = color.withValues(alpha: 0.16);
        filo = color;
      } else {
        // Los partidos que quedan por jugar van tintados con el color de tu
        // club: se distinguen de un día vacío sin necesidad de otro color
        // más en la pantalla.
        fondo = colorEquipo.withValues(alpha: 0.16);
        filo = colorEquipo;
      }
    }

    return InkWell(
      onTap: (partido != null || evento != null) ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: fondo ?? e.panel,
          border: Border.all(color: e.linea),
        ),
        child: Stack(
          children: [
            // El filo de color arriba: es lo que se lee de un vistazo al
            // recorrer un mes entero —ganado, perdido, por jugar— sin tener
            // que mirar el marcador de cada celda.
            if (filo != null)
              Positioned(
                  top: 0, left: 0, right: 0, child: Container(height: 2, color: filo)),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Solo el número: el nombre del día ya está en la
                      // cabecera de la columna, así que repetirlo en cada
                      // celda no añade información.
                      Flexible(
                        child: Text(
                          '$dia',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: familiaTitular,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            color: e.textoTenue,
                          ),
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
                              size: 13,
                              color: e.textoRotulo,
                            ),
                          if (partido?.esTorneoTemporada == true)
                            const Icon(Icons.emoji_events,
                                size: 15, color: Color(0xFFE0A81E)),
                          if (evento != null)
                            Icon(_iconoEvento(evento!.tipo),
                                size: 16, color: e.marca),
                        ],
                      ),
                    ],
                  ),
                  if (partido != null)
                    Expanded(
                      child: Center(
                        child: Text(
                          mayus(partido!.rival),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titular(e, tamano: 13),
                        ),
                      ),
                    ),
                  if (partido?.jugado == true)
                    Text(
                      '${partido!.marcadorPropietario}-${partido!.marcadorRival}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: familiaTitular,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: e.texto,
                      ),
                    ),
                ],
              ),
            ),
            // Los días ya pasados se apagan hacia el fondo de la pantalla.
            // Antes se les echaba negro encima, que en modo claro los hacía
            // resaltar en vez de apagarlos.
            if (esPasado)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(color: e.fondo.withValues(alpha: 0.55)),
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
