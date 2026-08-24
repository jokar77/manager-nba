import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../data/database/app_database.dart';
import '../../domain/calendario_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/picks_repository.dart';
import '../../domain/posiciones.dart';
import '../../domain/salarios.dart';
import '../../domain/tipo_evento_temporada.dart';
import '../../domain/traspasos_repository.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/estilo.dart';
import '../../shared/hoja_de_propuestas.dart';
import '../../shared/pantalla.dart';

/// Mesa de traspasos. Tres columnas: la tuya, la del equipo con el que
/// negocias y —si te hace falta para cuadrar la operación— la de un tercero.
/// Marcas qué se mueve, cada pieza dice a qué equipo va, y los rivales
/// contestan si les sale a cuenta. No regatean: valoran nivel, edad,
/// proyección y contrato, y miran que no les rompas la plantilla ni el
/// encaje salarial.
///
/// El dinero se ve en vivo en la cabecera de cada columna: masa salarial
/// antes y después. Estar por encima del tope no impide traspasar —media liga
/// lo está—, pero obliga a soltar un sueldo parecido al que recibes.
///
/// Si no sabes por dónde empezar, la lupa de cada jugador lanza el buscador
/// automático: en los tuyos busca quién te lo compraría y qué te darían por
/// él; en los suyos, qué tendrías que soltar para llevártelo.
/// Una propuesta con la que abrir la mesa ya montada. La usa la bandeja de
/// ofertas para "contraofertar": en vez de aceptar o rechazar a ciegas, se
/// abre la operación tal y como te la han planteado y la retocas.
class PropuestaDePartida {
  final String equipoRival;
  final List<int> tusJugadores;
  final List<int> susJugadores;
  final List<int> tusPicks;
  final List<int> susPicks;

  const PropuestaDePartida({
    required this.equipoRival,
    this.tusJugadores = const [],
    this.susJugadores = const [],
    this.tusPicks = const [],
    this.susPicks = const [],
  });
}

/// Las piezas de [propuesta] convertidas en movimientos de la mesa: lo tuyo
/// va hacia el rival y lo suyo hacia ti.
Map<String, MovimientoDeTraspaso> movimientosDePropuesta(
  PropuestaDePartida propuesta, {
  required String equipoUsuario,
}) {
  final rival = propuesta.equipoRival;
  return {
    for (final id in propuesta.tusJugadores)
      'j$id': MovimientoDeTraspaso.jugador(id, destino: rival),
    for (final id in propuesta.tusPicks)
      'p$id': MovimientoDeTraspaso.pick(id, destino: rival),
    for (final id in propuesta.susJugadores)
      'j$id': MovimientoDeTraspaso.jugador(id, destino: equipoUsuario),
    for (final id in propuesta.susPicks)
      'p$id': MovimientoDeTraspaso.pick(id, destino: equipoUsuario),
  };
}

/// De quién sale cada pieza de [propuesta].
Map<String, String> origenesDePropuesta(
  PropuestaDePartida propuesta, {
  required String equipoUsuario,
}) {
  final rival = propuesta.equipoRival;
  return {
    for (final id in propuesta.tusJugadores) 'j$id': equipoUsuario,
    for (final id in propuesta.tusPicks) 'p$id': equipoUsuario,
    for (final id in propuesta.susJugadores) 'j$id': rival,
    for (final id in propuesta.susPicks) 'p$id': rival,
  };
}

class TraspasosScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  /// Con qué llega la mesa puesta. Null para empezar de cero.
  final PropuestaDePartida? propuestaInicial;

  const TraspasosScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    this.propuestaInicial,
  });

  @override
  State<TraspasosScreen> createState() => _TraspasosScreenState();
}

/// Lo que hay cargado de un equipo que está sobre la mesa.
class _Lado {
  final String equipo;
  final List<Jugador> plantilla;
  final List<PickDraft> picks;

  const _Lado({
    required this.equipo,
    required this.plantilla,
    required this.picks,
  });

  int get masa => plantilla.fold<int>(0, (a, j) => a + j.salario);
}

class _TraspasosScreenState extends State<TraspasosScreen> {
  List<String> _equipos = [];
  String? _rival;
  String? _tercero;

  /// Los equipos cargados, por código. Se conservan aunque cambies de rival
  /// para no ir a la base cada vez que tocas el desplegable.
  final Map<String, _Lado> _lados = {};

  /// Lo que hay sobre la mesa, por clave de activo.
  final Map<String, MovimientoDeTraspaso> _movimientos = {};

  /// De qué equipo salió cada activo puesto sobre la mesa. Hace falta para
  /// saber a qué destinos se puede mandar cuando le das a la flecha.
  final Map<String, String> _origenes = {};

  RespuestaTraspaso? _respuesta;
  bool _cargando = true;
  bool _buscando = false;

  /// Ya pasó la fecha límite de traspasos: se puede seguir mirando el
  /// mercado, pero no cerrar nada.
  bool _cerrada = false;

  List<String> get _equiposEnMesa => [
        widget.equipoUsuario,
        ?_rival,
        ?_tercero,
      ];

  @override
  void initState() {
    super.initState();
    _cargarInicial();
  }

  Future<void> _cargarInicial() async {
    final equipos = await equiposParaNegociar(widget.db, widget.equipoUsuario);
    final propuesta = widget.propuestaInicial;
    final rival = propuesta?.equipoRival ??
        (equipos.isEmpty ? null : equipos.first);

    await _cargarLado(widget.equipoUsuario);
    if (rival != null) await _cargarLado(rival);
    final cerrada = await haPasadoFechaLimite(
        widget.db, widget.equipoUsuario, TipoEventoTemporada.fechaLimiteTraspasos);
    if (!mounted) return;
    setState(() {
      _equipos = equipos;
      _rival = rival;
      _cerrada = cerrada;
      _cargando = false;
      if (propuesta != null && rival != null) {
        _montar(propuesta, rival);
      }
    });
    // Con la mesa puesta, el veredicto de partida es el de la oferta tal y
    // como te la mandaron: así ves de entrada qué estás retocando.
    if (propuesta != null) await _evaluar();
  }

  /// Deja sobre la mesa las piezas de una propuesta ya montada.
  void _montar(PropuestaDePartida propuesta, String rival) {
    _movimientos.addAll(
        movimientosDePropuesta(propuesta, equipoUsuario: widget.equipoUsuario));
    _origenes.addAll(
        origenesDePropuesta(propuesta, equipoUsuario: widget.equipoUsuario));
  }

  Future<void> _cargarLado(String equipo) async {
    final plantilla = await plantillaParaTraspasos(widget.db, equipo);
    final picks = await picksDe(widget.db, equipo);
    _lados[equipo] =
        _Lado(equipo: equipo, plantilla: plantilla, picks: picks);
  }

  /// Al cambiar de equipo en una columna se cae todo lo que ese equipo tenía
  /// sobre la mesa: ya no es suyo, y dejarlo colgado sería un traspaso
  /// fantasma.
  void _limpiarLoQueTocaA(String? equipo) {
    if (equipo == null) return;
    final claves = _origenes.entries
        .where((e) => e.value == equipo)
        .map((e) => e.key)
        .toList();
    for (final clave in claves) {
      _movimientos.remove(clave);
      _origenes.remove(clave);
    }
    // Y lo que iba hacia él se queda sin destino: se recoloca al primero
    // que quede libre.
    for (final clave in _movimientos.keys.toList()) {
      if (_movimientos[clave]!.destino != equipo) continue;
      final origen = _origenes[clave]!;
      final destino = _equiposEnMesa.firstWhere((e) => e != origen,
          orElse: () => origen);
      if (destino == origen) {
        _movimientos.remove(clave);
        _origenes.remove(clave);
      } else {
        _movimientos[clave] = _rehacer(_movimientos[clave]!, destino);
      }
    }
  }

  MovimientoDeTraspaso _rehacer(MovimientoDeTraspaso m, String destino) =>
      m.esPick
          ? MovimientoDeTraspaso.pick(m.pickId!, destino: destino)
          : MovimientoDeTraspaso.jugador(m.jugadorId!, destino: destino);

  Future<void> _elegirRival(String equipo) async {
    if (equipo == _tercero) return;
    if (!_lados.containsKey(equipo)) await _cargarLado(equipo);
    if (!mounted) return;
    setState(() {
      _limpiarLoQueTocaA(_rival);
      _rival = equipo;
      _respuesta = null;
    });
  }

  Future<void> _elegirTercero(String? equipo) async {
    if (equipo != null && equipo == _rival) return;
    if (equipo != null && !_lados.containsKey(equipo)) {
      await _cargarLado(equipo);
    }
    if (!mounted) return;
    setState(() {
      _limpiarLoQueTocaA(_tercero);
      _tercero = equipo;
      _respuesta = null;
    });
  }

  Future<void> _recargarTodo() async {
    for (final equipo in _lados.keys.toList()) {
      await _cargarLado(equipo);
    }
    if (!mounted) return;
    setState(() {
      _movimientos.clear();
      _origenes.clear();
      _respuesta = null;
    });
  }

  /// El destino que se le pone a una pieza nada más marcarla: el siguiente
  /// equipo del corro. Con dos equipos es el único posible; con tres, el
  /// triángulo natural (tú → rival → tercero → tú).
  String _destinoPorDefecto(String origen) {
    final mesa = _equiposEnMesa;
    final i = mesa.indexOf(origen);
    return mesa[(i + 1) % mesa.length];
  }

  void _alternar(String clave, String origen, MovimientoDeTraspaso Function(String destino) crear) {
    setState(() {
      _respuesta = null;
      if (_movimientos.remove(clave) != null) {
        _origenes.remove(clave);
        return;
      }
      _origenes[clave] = origen;
      _movimientos[clave] = crear(_destinoPorDefecto(origen));
    });
  }

  void _cambiarDestino(String clave) {
    final actual = _movimientos[clave];
    final origen = _origenes[clave];
    if (actual == null || origen == null) return;
    final posibles = _equiposEnMesa.where((e) => e != origen).toList();
    if (posibles.length < 2) return;
    final siguiente =
        posibles[(posibles.indexOf(actual.destino) + 1) % posibles.length];
    setState(() {
      _movimientos[clave] = _rehacer(actual, siguiente);
      _respuesta = null;
    });
  }

  Future<void> _evaluar() async {
    final respuesta = await evaluarTraspasoMultiple(
      widget.db,
      equipoUsuario: widget.equipoUsuario,
      equipos: _equiposEnMesa,
      movimientos: _movimientos.values.toList(),
      // Tu equipo es tuyo: si quieres vaciar un puesto y taparlo luego en la
      // agencia libre, se avisa pero no se impide.
      dejarRompertePlantilla: true,
    );
    if (!mounted) return;
    setState(() => _respuesta = respuesta);
  }

  Future<void> _ejecutar() async {
    if (_cerrada) return;
    final aviso = _respuesta?.aviso;
    if (aviso != null) {
      final seguir = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t(context).teVasAQuedarCorto),
          content: Text(t(context).avisoLoCierras(aviso)),
          actions: [
            BotonDialogoSecundario(
              texto: t(context).mejorNo,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            BotonDialogoPrincipal(
              texto: t(context).cerrarloIgual,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      if (seguir != true || !mounted) return;
    }

    final hecho = await ejecutarTraspasoMultiple(
        widget.db, _movimientos.values.toList(),
        equipoUsuario: widget.equipoUsuario);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(hecho
            ? t(context).traspasoCerradoSimple
            : t(context).fechaLimiteTraspasosNoMasOperaciones)));
    await _recargarTodo();
  }

  /// Lo tuyo que hay marcado ahora mismo en la mesa, con [jugador] siempre
  /// dentro (es sobre quien has pulsado la lupa).
  ///
  /// El buscador tiene que mirar el paquete entero: antes iba solo con el
  /// jugador de la lupa, así que si habías puesto a dos y un pick sobre la
  /// mesa, las ofertas que te salían eran las de un traspaso más pequeño que
  /// el que estabas montando — y al cerrarlas se llevaban solo a uno.
  ({List<int> jugadores, List<int> picks}) _loTuyoEnLaMesa(Jugador jugador) {
    final jugadores = <int>{jugador.id};
    final picks = <int>{};
    for (final entrada in _movimientos.entries) {
      if (_origenes[entrada.key] != widget.equipoUsuario) continue;
      final movimiento = entrada.value;
      if (movimiento.esPick) {
        picks.add(movimiento.pickId!);
      } else {
        jugadores.add(movimiento.jugadorId!);
      }
    }
    return (jugadores: jugadores.toList(), picks: picks.toList());
  }

  /// Buscador automático sobre lo tuyo: quién te compraría el paquete que
  /// tienes montado.
  Future<void> _buscarSalida(Jugador jugador) async {
    if (_buscando || _avisarSiEstaCerrado()) return;
    setState(() => _buscando = true);
    final paquete = _loTuyoEnLaMesa(jugador);
    final propuestas = await buscarSalidaPara(
      widget.db,
      equipoUsuario: widget.equipoUsuario,
      jugadorIds: paquete.jugadores,
      pickIds: paquete.picks,
    );
    if (!mounted) return;
    setState(() => _buscando = false);

    final piezas = paquete.jugadores.length + paquete.picks.length;
    await _mostrarPropuestas(
      titulo: piezas == 1
          ? t(context).quienSeLlevaA(jugador.nombreFicticio)
          : t(context).quienSeLlevaPaquete(piezas),
      vacio: t(context).ningunEquipoTeDariaNada,
      propuestas: propuestas,
    );
  }

  /// Buscador automático sobre uno suyo: qué tendrías que soltar.
  /// Con el mercado cerrado no se busca: antes el buscador seguía
  /// funcionando y te montaba una lista de traspasos que luego no se podían
  /// cerrar. Enseñar operaciones imposibles es peor que no enseñar nada.
  bool _avisarSiEstaCerrado() {
    if (!_cerrada) return false;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t(context).mercadoCerradoNoSeBuscan),
    ));
    return true;
  }

  Future<void> _buscarFichaje(Jugador jugador) async {
    if (_buscando || _avisarSiEstaCerrado()) return;
    setState(() => _buscando = true);
    final propuestas = await buscarFichajeDe(
      widget.db,
      equipoUsuario: widget.equipoUsuario,
      jugadorObjetivoId: jugador.id,
    );
    if (!mounted) return;
    setState(() => _buscando = false);
    await _mostrarPropuestas(
      titulo: t(context).comoFicharA(jugador.nombreFicticio),
      vacio: t(context).noTienesConQueConvencer,
      propuestas: propuestas,
    );
  }

  Future<void> _mostrarPropuestas({
    required String titulo,
    required String vacio,
    required List<PropuestaTraspaso> propuestas,
  }) async {
    final elegida = await showModalBottomSheet<PropuestaTraspaso>(
      context: context,
      isScrollControlled: true,
      builder: (context) => HojaDePropuestas(
        titulo: titulo,
        vacio: vacio,
        propuestas: propuestas,
      ),
    );
    if (elegida == null || !mounted) return;

    final hecho = await ejecutarTraspaso(
      widget.db,
      equipoUsuario: widget.equipoUsuario,
      equipoRival: elegida.equipoRival,
      tuyos: elegida.idsQueSalen,
      suyos: elegida.idsQueLlegan,
      tusPicks: elegida.idsPicksQueSalen,
      susPicks: elegida.idsPicksQueLlegan,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(hecho
            ? t(context).traspasoCerradoCon(elegida.equipoRival)
            : t(context).fechaLimiteTraspasosNoMasOperaciones)));
    await _recargarTodo();
  }

  /// La masa salarial de [equipo] si se cerrara lo que hay marcado ahora
  /// mismo. Se calcula en vivo para que veas el dinero moverse según tocas.
  int _masaResultante(String equipo) {
    final lado = _lados[equipo];
    if (lado == null) return 0;
    var masa = lado.masa;
    for (final entrada in _movimientos.entries) {
      final m = entrada.value;
      if (m.esPick) continue;
      final jugador = _jugador(m.jugadorId!);
      if (jugador == null) continue;
      if (_origenes[entrada.key] == equipo) masa -= jugador.salario;
      if (m.destino == equipo) masa += jugador.salario;
    }
    return masa;
  }

  Jugador? _jugador(int id) {
    for (final lado in _lados.values) {
      for (final j in lado.plantilla) {
        if (j.id == id) return j;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: barraDeClub(widget.equipoUsuario, t(context).tituloTraspasos),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final respuesta = _respuesta;
    final mesa = _equiposEnMesa;

    return Scaffold(
      appBar: barraDeClub(
        widget.equipoUsuario,
        t(context).tituloTraspasos,
        bottom: _buscando
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(minHeight: 4),
              )
            : null,
      ),
      body: Column(
        children: [
          if (_cerrada)
            Container(
              width: double.infinity,
              color: Colors.red.withValues(alpha: 0.15),
              padding: const EdgeInsets.all(12),
              child: Text(
                t(context).fechaLimiteTraspasosBanner,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(child: _columnas(mesa)),
          // El acceso al tercer equipo cuando no cabe como columna.
          if (tamanoDe(context).esCompacto &&
              _tercero == null &&
              _equipos.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.group_add, size: 18),
                  label: Text(t(context).noCuadraMeteATercero),
                  onPressed: () {
                    final libres = _equipos
                        .where((e) => e != _rival && e != _tercero)
                        .toList();
                    if (libres.isNotEmpty) _elegirTercero(libres.first);
                  },
                ),
              ),
            ),
          if (respuesta != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: (respuesta.aceptado ? Colors.green : Colors.red)
                  .withValues(alpha: 0.15),
              child: Text(
                respuesta.mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          if (respuesta?.aviso != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.amber.withValues(alpha: 0.20),
              child: Row(
                children: [
                  Icon(Icons.warning_amber,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      respuesta!.aviso!,
                      style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _movimientos.isEmpty ? null : _evaluar,
                    child: Text(t(context).proponer),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: respuesta?.aceptado == true && !_cerrada
                        ? _ejecutar
                        : null,
                    child: Text(t(context).cerrarTraspasoBtn),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Las columnas, repartidas si caben y con scroll horizontal si no. Tres
  /// columnas apretadas en una ventana estrecha no hay quien las lea.
  Widget _columnas(List<String> mesa) {
    // En un teléfono dos columnas caben de sobra (unos 190px cada una) y es
    // como se entiende un traspaso: lo tuyo a un lado, lo suyo al otro.
    // Con 240 de mínimo no entraban ni dos y todo se iba a scroll
    // horizontal, que en la mesa de traspasos es lo peor que puede pasar:
    // dejas de ver un lado justo cuando estás comparando.
    final compacto = tamanoDe(context).esCompacto;
    final anchoMinimo = compacto ? 150.0 : 240.0;
    final columnas = [
      for (var i = 0; i < mesa.length; i++) _columnaDe(mesa[i], i),
      // El hueco de "mete a un tercero" ocuparía una columna entera y
      // rompería las dos que sí importan: en estrecho baja a un botón
      // debajo de la mesa.
      if (!compacto && _tercero == null && _equipos.length > 1)
        _anadirTercero(),
    ];

    return LayoutBuilder(
      builder: (context, restricciones) {
        if (restricciones.maxWidth >= anchoMinimo * columnas.length) {
          return Row(
            children: [
              for (var i = 0; i < columnas.length; i++) ...[
                if (i > 0) const VerticalDivider(width: 1),
                Expanded(child: columnas[i]),
              ],
            ],
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < columnas.length; i++) ...[
                if (i > 0) const VerticalDivider(width: 1),
                SizedBox(
                    width: anchoMinimo,
                    height: restricciones.maxHeight,
                    child: columnas[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _columnaDe(String equipo, int indice) {
    final lado = _lados[equipo];
    if (lado == null) return const SizedBox.shrink();
    final esTuyo = equipo == widget.equipoUsuario;
    final esTercero = equipo == _tercero;

    return _ColumnaEquipo(
      lado: lado,
      masaResultante: _masaResultante(equipo),
      // Tu columna no se cambia; las otras sí.
      selector: esTuyo
          ? null
          : _SelectorEquipo(
              equipos: _equipos
                  .where((e) =>
                      e == equipo ||
                      (e != _rival && e != _tercero))
                  .toList(),
              seleccionado: equipo,
              onCambiar: (e) =>
                  esTercero ? _elegirTercero(e) : _elegirRival(e),
              onQuitar: esTercero ? () => _elegirTercero(null) : null,
            ),
      titulo: esTuyo
          ? t(context).tuEquipoLabel
          : (esTercero ? t(context).tercerEquipoLabel : t(context).rivalLabel),
      movimientos: _movimientos,
      variosDestinos: _equiposEnMesa.length > 2,
      tooltipBuscador: esTuyo
          ? t(context).buscarQuienCompraria
          : t(context).buscarQueDarPorEl,
      onBuscar: esTuyo ? _buscarSalida : _buscarFichaje,
      onAlternarJugador: (j) => _alternar('j${j.id}', equipo,
          (destino) => MovimientoDeTraspaso.jugador(j.id, destino: destino)),
      onAlternarPick: (p) => _alternar('p${p.id}', equipo,
          (destino) => MovimientoDeTraspaso.pick(p.id, destino: destino)),
      onCambiarDestino: _cambiarDestino,
      colorIndice: indice,
    );
  }

  Widget _anadirTercero() {
    final libres =
        _equipos.where((e) => e != _rival && e != _tercero).toList();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_add,
                size: 40, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(t(context).noCuadraMeteATerceroLarga,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed:
                  libres.isEmpty ? null : () => _elegirTercero(libres.first),
              child: Text(t(context).anadirEquipoBtn),
            ),
          ],
        ),
      ),
    );
  }
}

/// El desplegable de la cabecera de una columna, con su aspa si se puede
/// sacar al equipo de la mesa.
class _SelectorEquipo extends StatelessWidget {
  final List<String> equipos;
  final String seleccionado;
  final void Function(String) onCambiar;
  final VoidCallback? onQuitar;

  const _SelectorEquipo({
    required this.equipos,
    required this.seleccionado,
    required this.onCambiar,
    this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            underline: const SizedBox.shrink(),
            value: seleccionado,
            items: equipos
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          EquipoLogo(codigoEquipo: e, tamano: 18),
                          const SizedBox(width: 6),
                          Flexible(
                              child: Text(infoDe(e).nombreCompleto,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (e) => e == null ? null : onCambiar(e),
          ),
        ),
        if (onQuitar != null)
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: t(context).sacarDeLaOperacion,
            onPressed: onQuitar,
          ),
      ],
    );
  }
}

class _ColumnaEquipo extends StatelessWidget {
  final _Lado lado;
  final int masaResultante;
  final _SelectorEquipo? selector;
  final String titulo;
  final Map<String, MovimientoDeTraspaso> movimientos;
  final bool variosDestinos;
  final String tooltipBuscador;
  final Future<void> Function(Jugador) onBuscar;
  final void Function(Jugador) onAlternarJugador;
  final void Function(PickDraft) onAlternarPick;
  final void Function(String clave) onCambiarDestino;
  final int colorIndice;

  const _ColumnaEquipo({
    required this.lado,
    required this.masaResultante,
    required this.selector,
    required this.titulo,
    required this.movimientos,
    required this.variosDestinos,
    required this.tooltipBuscador,
    required this.onBuscar,
    required this.onAlternarJugador,
    required this.onAlternarPick,
    required this.onCambiarDestino,
    required this.colorIndice,
  });

  /// Lo que este equipo pone sobre la mesa ahora mismo. Es lo único que
  /// ocupa la columna: la plantilla entera vive en el selector, no aquí.
  List<Jugador> get _jugadoresPuestos =>
      lado.plantilla.where((j) => movimientos.containsKey('j${j.id}')).toList();

  List<PickDraft> get _picksPuestos =>
      lado.picks.where((p) => movimientos.containsKey('p${p.id}')).toList();

  /// Abre el selector con todo lo que este equipo puede meter todavía en el
  /// traspaso, y marca lo que elijas.
  Future<void> _abrirSelector(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          final libres = lado.plantilla
              .where((j) => !movimientos.containsKey('j${j.id}'))
              .toList();
          final picksLibres = lado.picks
              .where((p) => !movimientos.containsKey('p${p.id}'))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    EquipoLogo(codigoEquipo: lado.equipo, tamano: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t(context).anadirDe(infoDe(lado.equipo).nombreCompleto),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final j in libres)
                      ListTile(
                        dense: true,
                        title: Text(j.nombreFicticio,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(
                            '${etiquetaPosicion(j)} · ${j.media} · '
                            '${formatearSalario(j.salario)} · '
                            '${_aniosDeContrato(context, j)}',
                            style: const TextStyle(fontSize: 11)),
                        trailing: IconButton(
                          icon: const Icon(Icons.search, size: 18),
                          tooltip: tooltipBuscador,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onBuscar(j);
                          },
                        ),
                        onTap: () {
                          onAlternarJugador(j);
                          Navigator.of(context).pop();
                        },
                      ),
                    if (picksLibres.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(t(context).eleccionesDeDraft,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      for (final p in picksLibres)
                        ListTile(
                          dense: true,
                          title: Text(etiquetaDePick(p),
                              style: const TextStyle(fontSize: 13)),
                          onTap: () {
                            onAlternarPick(p);
                            Navigator.of(context).pop();
                          },
                        ),
                    ],
                    if (libres.isEmpty && picksLibres.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          t(context).yaHasPuestoTodo,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cambia = masaResultante != lado.masa;
    final jugadores = _jugadoresPuestos;
    final picks = _picksPuestos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo.toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Theme.of(context).colorScheme.outline)),
              // Misma altura que el desplegable de las otras columnas (la de
              // un control tocable, 48). Tu columna, que no lleva selector,
              // medía menos y eso bajaba la masa salarial y la línea
              // separadora respecto a las de al lado.
              SizedBox(
                height: kMinInteractiveDimension,
                child: selector ??
                    Row(
                      children: [
                        EquipoLogo(codigoEquipo: lado.equipo, tamano: 18),
                        const SizedBox(width: 6),
                        Flexible(
                            child: Text(infoDe(lado.equipo).nombreCompleto,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
              ),
              _Masa(previa: lado.masa, ahora: masaResultante, cambia: cambia),
            ],
          ),
        ),
        const Divider(height: 12),
        // Solo lo que está puesto en la mesa, más un hueco para añadir. La
        // plantilla entera en tres columnas de casillas era un muro de
        // nombres en el que no se veía qué estabas ofreciendo de verdad.
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 12),
            children: [
              for (final j in jugadores)
                _Fila(
                  clave: 'j${j.id}',
                  titulo: j.nombreFicticio,
                  subtitulo: '${etiquetaPosicion(j)} · ${j.media} · '
                      '${formatearSalario(j.salario)} · '
                      '${_aniosDeContrato(context, j)}',
                  movimientos: movimientos,
                  variosDestinos: variosDestinos,
                  onAlternar: () => onAlternarJugador(j),
                  onCambiarDestino: onCambiarDestino,
                  accesorio: IconButton(
                    icon: const Icon(Icons.search, size: 18),
                    tooltip: tooltipBuscador,
                    onPressed: () => onBuscar(j),
                  ),
                ),
              for (final p in picks)
                _Fila(
                  clave: 'p${p.id}',
                  titulo: etiquetaDePick(p),
                  subtitulo: null,
                  movimientos: movimientos,
                  variosDestinos: variosDestinos,
                  onAlternar: () => onAlternarPick(p),
                  onCambiarDestino: onCambiarDestino,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: _HuecoParaAnadir(
                  vacio: jugadores.isEmpty && picks.isEmpty,
                  onTocar: () => _abrirSelector(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// El hueco vacío del traspaso: se toca y se abre el selector. Cuando la
/// columna todavía no tiene nada, es más alto y lo dice con todas las
/// letras; a partir del primero se queda en una línea discreta.
class _HuecoParaAnadir extends StatelessWidget {
  final bool vacio;
  final VoidCallback onTocar;

  const _HuecoParaAnadir({required this.vacio, required this.onTocar});

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return InkWell(
      onTap: onTocar,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: vacio ? 22 : 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: outline.withValues(alpha: 0.5),
              style: BorderStyle.solid,
              width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, size: vacio ? 26 : 18, color: outline),
            if (vacio) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(t(context).tocaParaElegirJugadoresOPicks,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: outline)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// La masa salarial de una columna: la de ahora y, si hay algo marcado, en
/// qué se queda. Roja si pasa del tope — que no impide traspasar, pero sí
/// obliga a cuadrar sueldos.
class _Masa extends StatelessWidget {
  final int previa;
  final int ahora;
  final bool cambia;

  const _Masa(
      {required this.previa, required this.ahora, required this.cambia});

  @override
  Widget build(BuildContext context) {
    final pasado = ahora > topeSalarial;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.payments,
              size: 13,
              color: pasado
                  ? Colors.orange
                  : Theme.of(context).colorScheme.outline),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              cambia
                  ? '${formatearSalario(previa)} → ${formatearSalario(ahora)}'
                  : formatearSalario(previa),
              style: TextStyle(
                fontSize: 11,
                fontWeight: cambia ? FontWeight.bold : FontWeight.normal,
                color: pasado
                    ? Colors.orange
                    : Theme.of(context).colorScheme.outline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Una pieza negociable. Marcada, enseña a qué equipo va: con dos equipos no
/// hay duda y no se pinta; con tres, la flecha rota entre los dos destinos
/// posibles.
class _Fila extends StatelessWidget {
  final String clave;
  final String titulo;
  final String? subtitulo;
  final Map<String, MovimientoDeTraspaso> movimientos;
  final bool variosDestinos;
  final VoidCallback onAlternar;
  final void Function(String) onCambiarDestino;
  final Widget? accesorio;

  const _Fila({
    required this.clave,
    required this.titulo,
    required this.subtitulo,
    required this.movimientos,
    required this.variosDestinos,
    required this.onAlternar,
    required this.onCambiarDestino,
    this.accesorio,
  });

  @override
  Widget build(BuildContext context) {
    final movimiento = movimientos[clave];
    final destino = movimiento?.destino;

    return CheckboxListTile(
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      value: movimiento != null,
      onChanged: (_) => onAlternar(),
      title: Text(titulo,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis),
      subtitle: subtitulo == null && destino == null
          ? null
          : Row(
              children: [
                if (subtitulo != null)
                  Flexible(
                      child: Text(subtitulo!,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis)),
                if (destino != null && variosDestinos) ...[
                  if (subtitulo != null) const SizedBox(width: 6),
                  InkWell(
                    onTap: () => onCambiarDestino(clave),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward, size: 12),
                          const SizedBox(width: 2),
                          Text(destino,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
      secondary: accesorio,
    );
  }
}


/// Los años que le quedan de contrato, para la línea de cada jugador.
///
/// El sueldo solo no basta para juzgar un traspaso: 40M con un año por
/// delante y 40M con cinco son operaciones completamente distintas.
String _aniosDeContrato(BuildContext context, Jugador j) =>
    t(context).aniosDeContrato(j.aniosContrato);
