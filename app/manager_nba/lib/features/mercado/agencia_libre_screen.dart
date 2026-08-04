import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/agencia_libre_repository.dart';
import '../../domain/calendario_repository.dart';
import '../../domain/contratos_repository.dart';
import '../../domain/draft_repository.dart';
import '../../domain/posiciones.dart';
import '../../domain/salarios.dart';
import '../../domain/tipo_evento_temporada.dart';
import '../roster/roster_config_screen.dart';

/// El mercado de agentes libres. Hasta que la plantilla no esté completa
/// (mínimo de jugadores y los 5 puestos con recambio) no se puede seguir:
/// o negocias a mano o le das al botón de completar con contratos del
/// mínimo.
///
/// Fichar no es un clic automático: se abre la misma negociación que una
/// renovación (sueldo, años, hasta tres ofertas), porque un agente libre de
/// nivel no firma solo porque le pongas su precio de mercado sobre la mesa.
class AgenciaLibreScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  /// Si es null, la pantalla es de consulta libre (desde el menú) y se
  /// puede salir cuando quieras. Si no, es el paso obligatorio de la
  /// pretemporada.
  final VoidCallback? onContinuar;

  const AgenciaLibreScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    this.onContinuar,
  });

  @override
  State<AgenciaLibreScreen> createState() => _AgenciaLibreScreenState();
}

class _AgenciaLibreScreenState extends State<AgenciaLibreScreen> {
  List<Jugador> _libres = [];
  HuecosDePlantilla _huecos =
      const HuecosDePlantilla(
          fichajesQueFaltan: 0,
          fichajesRecomendados: 0,
          puestosSinCubrir: []);
  int _espacio = 0;
  int _plantilla = 0;
  bool _cargando = true;
  bool _procesando = false;

  /// Ya pasó la fecha límite: no hay paso obligatorio (ese ya está resuelto
  /// para cuando esta fecha llega) así que solo se puede consultar, no
  /// fichar.
  bool _cerrada = false;

  /// null = todas las posiciones.
  String? _filtroPosicion;

  /// Solo los que caben en lo que te queda de tope salarial.
  bool _soloAsequibles = false;

  /// El mercado ya filtrado por lo que hayas pedido arriba.
  List<Jugador> get _visibles => _libres.where((j) {
        if (_filtroPosicion != null && !juegaComodoDe(j, _filtroPosicion!)) {
          return false;
        }
        // "Asequible" es lo que de verdad puedes pagar: el mínimo siempre
        // cabe, aunque estés por encima del tope (ver contratos_repository).
        final precio = precioDeAgenteLibre(j);
        if (_soloAsequibles && precio > _espacio && precio > salarioMinimo) {
          return false;
        }
        return true;
      }).toList();

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    final libres = await agentesLibres(widget.db);
    final huecos = await huecosDePlantilla(widget.db, widget.equipoUsuario);
    final espacio = await espacioSalarial(widget.db, widget.equipoUsuario);
    final plantilla = await tamanoDePlantilla(widget.db, widget.equipoUsuario);
    // El paso obligatorio de pretemporada nunca puede estar "cerrado": esa
    // fecha límite es de mitad de temporada, no de cuando arranca el año.
    final cerrada = widget.onContinuar != null
        ? false
        : await haPasadoFechaLimite(
            widget.db, widget.equipoUsuario, TipoEventoTemporada.finAgenciaLibre);
    if (!mounted) return;
    setState(() {
      _libres = libres;
      _huecos = huecos;
      _espacio = espacio;
      _plantilla = plantilla;
      _cerrada = cerrada;
      _cargando = false;
      _procesando = false;
    });
  }

  Future<void> _negociar(Jugador jugador) async {
    if (_cerrada) return;
    final respuesta = await showDialog<RespuestaFichaje>(
      context: context,
      builder: (context) =>
          _DialogoDeFichaje(db: widget.db, jugador: jugador, equipo: widget.equipoUsuario),
    );
    if (respuesta == null || !mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(respuesta.mensaje)));
    await _recargar();
  }

  Future<void> _completarAutomaticamente() async {
    if (_cerrada) return;
    setState(() => _procesando = true);
    // Hasta el tamaño de la liga, no hasta el mínimo: el botón está para
    // no tener que ir uno a uno, y dejarte en 13 era dejarte a medias.
    final fichados = await completarPlantillaConElMinimo(
        widget.db, widget.equipoUsuario,
        hasta: plantillaMaxima);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(fichados.isEmpty
          ? 'Plantilla completada.'
          : 'Fichados ${fichados.length} jugadores por el mínimo.'),
    ));
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final esPasoObligatorio = widget.onContinuar != null;

    return PopScope(
      canPop: !esPasoObligatorio,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agencia libre'),
          automaticallyImplyLeading: !esPasoObligatorio,
          actions: [
            IconButton(
              icon: const Icon(Icons.groups),
              tooltip: 'Ver tu plantilla',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RosterConfigScreen(
                  db: widget.db,
                  equipo: widget.equipoUsuario,
                  esConfiguracionInicial: false,
                  onGuardado: () => Navigator.of(context).pop(),
                ),
              )),
            ),
          ],
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_procesando) const LinearProgressIndicator(),
                  if (_cerrada)
                    Container(
                      width: double.infinity,
                      color: Colors.red.withValues(alpha: 0.15),
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        'La agencia libre ha cerrado por esta temporada: ya '
                        'se pasó la fecha límite. Puedes seguir mirando el '
                        'mercado, pero no fichar hasta el año que viene.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  _Estado(
                    huecos: _huecos,
                    espacio: _espacio,
                    plantilla: _plantilla,
                  ),
                  if (!_huecos.plantillaAlCompleto && !_cerrada)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _procesando ? null : _completarAutomaticamente,
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('Completar con contratos mínimos'),
                        ),
                      ),
                    ),
                  _Filtros(
                    posicion: _filtroPosicion,
                    soloAsequibles: _soloAsequibles,
                    onPosicion: (p) => setState(() => _filtroPosicion = p),
                    onAsequibles: (v) => setState(() => _soloAsequibles = v),
                  ),
                  // Cuántos hay de verdad y cuántos estás viendo. Sin esto
                  // no había forma de saber si el mercado está seco o si
                  // simplemente tienes un filtro puesto.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _visibles.length == _libres.length
                            ? '${_libres.length} agentes libres'
                            : '${_visibles.length} de ${_libres.length} '
                                'agentes libres (hay filtros puestos)',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _libres.isEmpty
                        ? const Center(
                            child: Text('No queda nadie en el mercado.'))
                        : _visibles.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'Nadie del mercado encaja con lo que has '
                                    'pedido. Prueba a quitar algún filtro.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: _visibles.length,
                                itemBuilder: (context, i) => _FilaAgenteLibre(
                                  jugador: _visibles[i],
                                  onNegociar: _cerrada
                                      ? null
                                      : () => _negociar(_visibles[i]),
                                ),
                              ),
                  ),
                ],
              ),
        bottomNavigationBar: !esPasoObligatorio
            ? null
            : Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_huecos.plantillaLista && !_procesando)
                        ? widget.onContinuar
                        : null,
                    child: Text(_huecos.plantillaLista
                        ? 'Empezar la temporada'
                        : 'Completa la plantilla para continuar'),
                  ),
                ),
              ),
      ),
    );
  }
}

class _Estado extends StatelessWidget {
  final HuecosDePlantilla huecos;
  final int espacio;
  final int plantilla;

  const _Estado({
    required this.huecos,
    required this.espacio,
    required this.plantilla,
  });

  @override
  Widget build(BuildContext context) {
    final lista = huecos.plantillaLista;
    // El verde se reserva para la plantilla de verdad completa. Antes se
    // ponía en cuanto llegabas al mínimo de 13 y decía "plantilla lista",
    // que era exactamente la información equivocada: la liga entera juega
    // con 18 y nadie te avisaba de que ibas cinco por detrás.
    final color = huecos.plantillaAlCompleto
        ? Colors.green
        : (lista ? Colors.amber : Colors.orange);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: color.withValues(alpha: 0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            huecos.plantillaAlCompleto
                ? 'Plantilla al completo: $plantilla jugadores.'
                : 'Plantilla: $plantilla de $plantillaMaxima jugadores.',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          if (huecos.fichajesQueFaltan > 0)
            Text('Faltan ${huecos.fichajesQueFaltan} fichajes para el mínimo.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface))
          else if (huecos.fichajesRecomendados > 0)
            Text(
                'Los otros 29 equipos juegan con $plantillaMaxima. Con '
                '$plantilla puedes empezar, pero vas '
                '${huecos.fichajesRecomendados} por detrás.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
          if (huecos.puestosSinCubrir.isNotEmpty)
            Text(
                'Sin recambio en: '
                '${huecos.puestosSinCubrir.join(', ')}.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(
            espacio < 0
                ? 'Por encima del tope: solo fichajes del mínimo.'
                : '${formatearSalario(espacio)} libres bajo el tope.',
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

/// Los dos filtros del mercado: por puesto (contando también la segunda
/// posición, que para fichar un recambio es lo que importa) y por si te lo
/// puedes permitir con el espacio salarial que te queda.
class _Filtros extends StatelessWidget {
  final String? posicion;
  final bool soloAsequibles;
  final ValueChanged<String?> onPosicion;
  final ValueChanged<bool> onAsequibles;

  const _Filtros({
    required this.posicion,
    required this.soloAsequibles,
    required this.onPosicion,
    required this.onAsequibles,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: posicion == null,
            onSelected: (_) => onPosicion(null),
          ),
          for (final p in posicionesEquipo) ...[
            const SizedBox(width: 6),
            ChoiceChip(
              label: Text(p),
              selected: posicion == p,
              onSelected: (_) => onPosicion(p),
            ),
          ],
          const SizedBox(width: 14),
          FilterChip(
            avatar: const Icon(Icons.savings, size: 18),
            label: const Text('Que pueda pagar'),
            selected: soloAsequibles,
            onSelected: onAsequibles,
          ),
        ],
      ),
    );
  }
}

class _FilaAgenteLibre extends StatelessWidget {
  final Jugador jugador;
  final VoidCallback? onNegociar;

  const _FilaAgenteLibre({
    required this.jugador,
    required this.onNegociar,
  });

  @override
  Widget build(BuildContext context) {
    final ofertasRestantes = maxOfertasDeRenovacion - jugador.ofertasRechazadas;
    final sinOfertas = ofertasRestantes <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        title: Text(jugador.nombreFicticio),
        subtitle: Text('${etiquetaPosicion(jugador)} · ${jugador.edad} años · '
            'media ${jugador.media}'),
        // En horizontal, no apilado: un ListTile denso solo da 40px de alto
        // al trailing, y el precio encima del botón se pasaba de ahí (se veía
        // la banda amarilla de desbordamiento). De lado caben de sobra y no
        // depende de cuadrar alturas al píxel.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatearSalario(precioDeAgenteLibre(jugador)),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            if (sinOfertas)
              const Text('Ya no negocia',
                  style: TextStyle(fontSize: 11, color: Colors.red))
            else
              SizedBox(
                height: 28,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 12)),
                  onPressed: onNegociar,
                  child: Text('Negociar ($ofertasRestantes)'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo de oferta a un agente libre: sueldo y años, con el precio que
/// pide como referencia. Mismo mecanismo que la negociación de renovaciones
/// (ver renovaciones_screen.dart) — no hay motivo para que fichar a alguien
/// nuevo sea más fácil que retener a alguien que ya es tuyo.
class _DialogoDeFichaje extends StatefulWidget {
  final AppDatabase db;
  final Jugador jugador;
  final String equipo;

  const _DialogoDeFichaje({
    required this.db,
    required this.jugador,
    required this.equipo,
  });

  @override
  State<_DialogoDeFichaje> createState() => _DialogoDeFichajeState();
}

class _DialogoDeFichajeState extends State<_DialogoDeFichaje> {
  late double _salario = precioDeAgenteLibre(widget.jugador).toDouble();
  late int _anios = aniosContratoEstimados(edad: widget.jugador.edad);
  bool _enviando = false;

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    final respuesta = await ofrecerContratoFichaje(
      widget.db,
      widget.jugador.id,
      equipo: widget.equipo,
      salario: _salario.round(),
      anios: _anios,
    );
    if (!mounted) return;
    Navigator.of(context).pop(respuesta);
  }

  @override
  Widget build(BuildContext context) {
    final pide = precioDeAgenteLibre(widget.jugador);
    final ratio = _salario / pide;
    final probabilidad = probabilidadDeAceptar(
      salario: _salario.round(),
      pedido: pide,
      anios: _anios,
      edad: widget.jugador.edad,
      ofertasRechazadas: widget.jugador.ofertasRechazadas,
    );

    return AlertDialog(
      title: Text('Oferta a ${widget.jugador.nombreFicticio}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pide ${formatearSalario(pide)} al año',
              style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 16),
          Text('Sueldo: ${formatearSalario(_salario.round())}',
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
                  ? 'Se lo va a tomar como un insulto.'
                  : probabilidad < 0.25
                      ? 'Muy improbable que la acepte así: el sueldo, los años '
                          'o ambos se quedan cortos.'
                      : probabilidad < 0.6
                          ? 'Se lo puede pensar; no las tiene todas consigo.'
                          : probabilidad < 0.9
                              ? 'Es probable que acepte.'
                              : 'Prácticamente seguro que dice que sí.',
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
              const Text('Años: '),
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
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando ? null : _enviar,
          child: const Text('Ofrecer'),
        ),
      ],
    );
  }
}
