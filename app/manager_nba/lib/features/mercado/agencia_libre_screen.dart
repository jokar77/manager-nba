import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../shared/estilo.dart';
import '../../shared/ficha_jugador.dart';
import '../../shared/medias_jugador.dart';
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
          ? t(context).plantillaCompletada
          : t(context).fichadosPorElMinimo(fichados.length)),
    ));
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final esPasoObligatorio = widget.onContinuar != null;

    return PopScope(
      canPop: !esPasoObligatorio,
      child: Scaffold(
        appBar: barraDeClub(
          widget.equipoUsuario,
          t(context).tituloAgenciaLibre,
          conVolver: !esPasoObligatorio,
          acciones: [
            IconButton(
              icon: const Icon(Icons.groups),
              tooltip: t(context).verTuPlantilla,
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
                      child: Text(
                        t(context).agenciaLibreCerrada,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                          label: Text(t(context).completarConContratosMinimos),
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
                            ? t(context).contadorAgentesLibres(_libres.length)
                            : t(context).contadorAgentesLibresFiltrado(
                                _visibles.length, _libres.length),
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _libres.isEmpty
                        ? Center(
                            child: Text(t(context).noQuedaNadieEnMercado))
                        : _visibles.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    t(context).nadieEncajaConFiltro,
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
                        ? t(context).empezarLaTemporadaBtn
                        : t(context).completaLaPlantillaParaContinuar),
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
                ? t(context).plantillaAlCompletoConN(plantilla)
                : t(context).plantillaDeMax(plantilla, plantillaMaxima),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          if (huecos.fichajesQueFaltan > 0)
            Text(t(context).faltanFichajesParaMinimo(huecos.fichajesQueFaltan),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface))
          else if (huecos.fichajesRecomendados > 0)
            Text(
                t(context).otrosEquiposJuegan(plantillaMaxima, plantilla,
                    huecos.fichajesRecomendados),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
          if (huecos.puestosSinCubrir.isNotEmpty)
            Text(
                t(context).sinRecambioEn(huecos.puestosSinCubrir.join(', ')),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(
            espacio < 0
                ? t(context).porEncimaDelTopeSoloMinimo
                : t(context).libresBajoElTope(formatearSalario(espacio)),
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
            label: Text(t(context).todosFiltro),
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
            label: Text(t(context).quePuedaPagar),
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

    final e = Estilo.de(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: FilaDeJugador(
        media: jugador.media,
        nombre: jugador.nombreFicticio,
        detalle: '${etiquetaPosicion(jugador)} · '
            '${t(context).edadJugador(jugador.edad)}',
        bajoElNombre: MediasAtaqueDefensa.de(jugador, compacto: true),
        apagado: sinOfertas,
        onTap: sinOfertas ? null : onNegociar,
        // El precio encima y la acción debajo: en horizontal se comían el
        // ancho del nombre en un móvil.
        accesorio: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatearSalario(precioDeAgenteLibre(jugador)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: cifra(e, tamano: 17)),
            const SizedBox(height: 5),
            if (sinOfertas)
              Text(t(context).yaNoNegocia,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: e.mal))
            else
              BotonPrincipal(
                texto: t(context).negociarConN(ofertasRestantes),
                color: e.marca,
                alto: 34,
                onTap: onNegociar,
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
      title: Text(t(context).ofertaA(widget.jugador.nombreFicticio)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t(context).pideAlAnio(formatearSalario(pide)),
              style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 16),
          Text(t(context).sueldoLabel(formatearSalario(_salario.round())),
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
                  ? t(context).insultoOferta
                  : probabilidad < 0.25
                      ? t(context).ofertaImprobable
                      : probabilidad < 0.6
                          ? t(context).ofertaSePuedePensar
                          : probabilidad < 0.9
                              ? t(context).ofertaProbableAceptar
                              : t(context).ofertaSeguraAceptar,
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
              Text(t(context).aniosLabelDosPuntos),
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
        BotonDialogoSecundario(
          texto: t(context).cancelar,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        BotonDialogoPrincipal(
          texto: t(context).ofrecer,
          onPressed: _enviando ? null : _enviar,
        ),
      ],
    );
  }
}
