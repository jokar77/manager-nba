import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../data/importer/entrenadores_importer.dart';
import '../../data/importer/jugadores_importer.dart';
import '../../domain/entrenadores_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/franquicia_repository.dart';
import '../../domain/legado_historico_repository.dart';
import '../../domain/slots_repository.dart';
import '../../main.dart' show routeObserver;
import '../ajustes/ajustes_screen.dart';
import '../hub/home_hub_screen.dart';
import '../roster/roster_config_screen.dart';
import '../roster/team_selector_screen.dart';
import '../../i18n/textos.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/navegacion.dart';

/// Pantalla de arranque: las tres ranuras de guardado. Cada una es una
/// carrera independiente —su liga, su calendario, su palmarés—, así que
/// empezar una partida nueva ya no borra la que tenías a medias: se ocupa
/// otra ranura.
///
/// Una ranura ocupada enseña equipo, temporada, récord y anillos, y desde
/// ella se continúa o se borra. Una vacía solo ofrece empezar.
class StartMenuScreen extends StatefulWidget {
  /// La base de datos de ajustes (tema e idioma): es de la app, no de
  /// ninguna partida, y sobrevive a borrar cualquier ranura.
  final AppDatabase ajustesDb;
  final ValueNotifier<ThemeMode> temaNotifier;
  final ValueNotifier<Idioma> idiomaNotifier;

  const StartMenuScreen({
    super.key,
    required this.ajustesDb,
    required this.temaNotifier,
    required this.idiomaNotifier,
  });

  @override
  State<StartMenuScreen> createState() => _StartMenuScreenState();
}

/// Qué se está enseñando: el menú corto, o la lista de ranuras (y para qué).
enum _Vista { menu, empezar, cargar }

class _StartMenuScreenState extends State<StartMenuScreen> with RouteAware {
  late Future<List<ResumenSlot>> _slotsFuture;
  bool _procesando = false;
  _Vista _vista = _Vista.menu;

  @override
  void initState() {
    super.initState();
    _slotsFuture = leerResumenDeSlots();
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
    super.dispose();
  }

  /// Al volver del menú principal hay que releer las ranuras: la partida
  /// que acabas de crear (o lo que hayas avanzado en ella) tiene que verse
  /// aquí sin reiniciar la app.
  @override
  void didPopNext() => _recargar();

  /// Vuelve a leer las ranuras. Con [volverAlMenu] a false se recarga sin
  /// moverte de donde estás, que es lo que quieres tras borrar una: seguir
  /// en la lista para poder tocar otra.
  void _recargar({bool volverAlMenu = true}) {
    setState(() {
      _procesando = false;
      if (volverAlMenu) _vista = _Vista.menu;
      _slotsFuture = leerResumenDeSlots();
    });
  }

  /// "Continuar": entra directo a la última partida jugada, sin pasar por la
  /// lista de ranuras.
  Future<void> _continuarUltima() async {
    if (_procesando) return;
    final slot = await ranuraParaContinuar();
    if (!mounted || slot == null) return;
    await _continuar(slot);
  }

  /// Abre la ranura y entra al menú principal. La base se cierra al salir:
  /// dos ranuras abiertas a la vez sobre ficheros distintos funcionarían,
  /// pero dejar una colgada impediría borrar su fichero después.
  Future<void> _continuar(int slot) async {
    if (_procesando) return;
    setState(() => _procesando = true);
    final db = abrirSlot(slot);
    final equipo = await leerEquipoFranquicia(db);
    if (!mounted || equipo == null) {
      await cerrarSlot(db);
      if (mounted) _recargar();
      return;
    }
    // Backfill silencioso: si esta partida se creó antes de que existiera
    // el legado real, lo consigue ahora mismo (no vuelve a hacer nada si ya
    // lo tenía).
    await importarLegadoHistoricoSiHaceFalta(db);
    // Lo mismo con los entrenadores: una partida empezada antes de que
    // existieran se los encuentra aquí, y los banquillos que se hayan
    // quedado sin cubrir se rellenan.
    await importarEntrenadoresSiHaceFalta(db);
    await asignarEntrenadoresQueFalten(db);
    // Las partidas de la versión anterior tienen entrenador pero no
    // contrato: se les pone uno acorde a su nivel.
    await asignarContratosQueFalten(db);
    await marcarRanuraComoUsada(slot);
    if (!mounted) {
      await cerrarSlot(db);
      return;
    }

    await Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: RutasPrincipales.hub),
      builder: (context) => HomeHubScreen(db: db, equipo: equipo),
    ));
    await cerrarSlot(db);
    if (mounted) _recargar();
  }

  Future<void> _empezarEn(int slot) async {
    if (_procesando) return;

    // Estrenar una ranura que ya tiene partida se lleva por delante esa
    // carrera: eso se pregunta antes, no después.
    final resumenes = await _slotsFuture;
    if (!mounted) return;
    final ocupada = resumenes.firstWhere((r) => r.numero == slot).ocupada;
    if (ocupada) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('¿Sobrescribir la partida $slot?'),
          content: const Text(
            'Esa ranura ya tiene una carrera en marcha y se perderá entera: '
            'plantillas, calendario y palmarés. Esto no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sobrescribir'),
            ),
          ],
        ),
      );
      if (confirmar != true || !mounted) return;
    }

    setState(() => _procesando = true);

    final db = abrirSlot(slot);
    // Una ranura recién estrenada (o reutilizada tras una carrera larga)
    // tiene que arrancar con el dataset original, no con una liga
    // envejecida: la importación se fuerza siempre al empezar.
    await importarJugadoresSiHaceFalta(db, forzar: true);
    // Los entrenadores también vuelven a su sitio de partida: los de la
    // carrera anterior están envejecidos, retirados y repartidos por otros
    // equipos.
    await importarEntrenadoresSiHaceFalta(db, forzar: true);
    await nuevaFranquicia(db);
    // Las camisetas y el Hall of Fame reales sobreviven a "nueva partida"
    // (son hechos del mundo real, no logros de esta partida en concreto);
    // esto solo hace falta la primerísima vez que se estrena la ranura.
    await importarLegadoHistoricoSiHaceFalta(db);
    await marcarRanuraComoUsada(slot);
    if (!mounted) {
      await cerrarSlot(db);
      return;
    }

    // El estreno encadena tres pantallas (elegir equipo -> alineación ->
    // hub) con pushReplacement/pushAndRemoveUntil por el camino: esas
    // sustituciones resuelven el `push` de la pantalla que sustituyen antes
    // de tiempo, así que esperar solo al primer `push` para saber cuándo
    // cerrar la base de datos la cerraría con el usuario todavía dentro de
    // la siguiente pantalla. Un único Completer, que solo se resuelve en
    // el punto real de vuelta al menú (se seleccionó equipo o no, se
    // guardó la alineación o no), evita eso.
    final sesionTerminada = Completer<void>();
    var equipoElegido = false;
    var configuracionGuardada = false;

    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => TeamSelectorScreen(
        db: db,
        titulo: 'Elige tu equipo',
        onSeleccionado: (equipo) async {
          equipoElegido = true;
          await crearFranquicia(db, equipo);
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => RosterConfigScreen(
              db: db,
              equipo: equipo,
              esConfiguracionInicial: true,
              onGuardado: () {
                configuracionGuardada = true;
                Navigator.of(context)
                    .pushAndRemoveUntil(
                      MaterialPageRoute(
                        settings:
                            const RouteSettings(name: RutasPrincipales.hub),
                        builder: (context) =>
                            HomeHubScreen(db: db, equipo: equipo),
                      ),
                      (route) => route.isFirst,
                    )
                    .then((_) => sesionTerminada.complete());
              },
            ),
          )).then((_) {
            if (!configuracionGuardada) sesionTerminada.complete();
          });
        },
      ),
    )).then((_) {
      if (!equipoElegido) sesionTerminada.complete();
    });

    await sesionTerminada.future;
    await cerrarSlot(db);
    if (mounted) _recargar();
  }

  Future<void> _borrar(ResumenSlot resumen) async {
    if (_procesando) return;
    final nombre = infoDe(resumen.equipo ?? '').nombreCompleto;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Borrar la partida ${resumen.numero}?'),
        content: Text(
          'Se pierde toda la carrera de $nombre: plantillas, calendario, '
          'palmarés, leyendas y camisetas retiradas. Esto no se puede '
          'deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    setState(() => _procesando = true);
    await borrarSlot(resumen.numero);
    if (mounted) _recargar(volverAlMenu: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: FutureBuilder<List<ResumenSlot>>(
              future: _slotsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final slots = snapshot.data!;
                final hayPartidas = slots.any((s) => s.ocupada);
                final hayHueco = slots.any((s) => !s.ocupada);

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 12),
                    const Icon(Icons.sports_basketball,
                        size: 84, color: Colors.deepOrange),
                    const SizedBox(height: 12),
                    const Text('Manager NBA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_subtitulo(hayPartidas),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.outline)),
                    const SizedBox(height: 20),
                    if (_procesando) const LinearProgressIndicator(),
                    if (_vista == _Vista.menu)
                      ..._opcionesDelMenu(hayPartidas: hayPartidas)
                    else
                      ..._listaDeRanuras(slots, hayHueco: hayHueco),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _subtitulo(bool hayPartidas) => switch (_vista) {
        _Vista.menu =>
          hayPartidas ? 'Sigue donde lo dejaste' : 'Empieza tu carrera',
        _Vista.empezar => '¿En qué ranura quieres empezar?',
        _Vista.cargar => 'Elige la partida que quieres cargar',
      };

  /// El menú de verdad: tres opciones y nada más. Las ranuras solo salen
  /// cuando hay que elegir una, que es cuando significan algo.
  List<Widget> _opcionesDelMenu({required bool hayPartidas}) {
    return [
      if (hayPartidas) ...[
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _procesando ? null : _continuarUltima,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Continuar', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
      ],
      SizedBox(
        height: 52,
        child: hayPartidas
            ? OutlinedButton.icon(
                onPressed: _procesando
                    ? null
                    : () => setState(() => _vista = _Vista.empezar),
                icon: const Icon(Icons.add),
                label: const Text('Nueva partida',
                    style: TextStyle(fontSize: 16)),
              )
            : FilledButton.icon(
                onPressed: _procesando
                    ? null
                    : () => setState(() => _vista = _Vista.empezar),
                icon: const Icon(Icons.add),
                label: const Text('Nueva partida',
                    style: TextStyle(fontSize: 16)),
              ),
      ),
      if (hayPartidas) ...[
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _procesando
                ? null
                : () => setState(() => _vista = _Vista.cargar),
            icon: const Icon(Icons.folder_open),
            label:
                const Text('Cargar partida', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
      const SizedBox(height: 12),
      SizedBox(
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AjustesScreen(
              db: widget.ajustesDb,
              temaNotifier: widget.temaNotifier,
              idiomaNotifier: widget.idiomaNotifier,
            ),
          )),
          icon: const Icon(Icons.settings),
          label: Text(t(context).ajustes, style: const TextStyle(fontSize: 16)),
        ),
      ),
    ];
  }

  /// Las tres ranuras. Al venir de "Nueva partida" solo se puede estrenar; al
  /// venir de "Cargar partida", solo entrar en las que ya tienen algo.
  List<Widget> _listaDeRanuras(List<ResumenSlot> slots,
      {required bool hayHueco}) {
    final empezando = _vista == _Vista.empezar;
    return [
      if (empezando && !hayHueco)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Las tres ranuras están ocupadas: borra una para empezar de '
            'nuevo, o continúa una de las que ya tienes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      for (final slot in slots) ...[
        _FichaDeSlot(
          resumen: slot,
          deshabilitado: _procesando,
          modoEmpezar: empezando,
          onContinuar: () => _continuar(slot.numero),
          onEmpezar: () => _empezarEn(slot.numero),
          onBorrar: () => _borrar(slot),
        ),
        const SizedBox(height: 12),
      ],
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed:
            _procesando ? null : () => setState(() => _vista = _Vista.menu),
        icon: const Icon(Icons.arrow_back),
        label: const Text('Volver'),
      ),
    ];
  }
}

/// La tarjeta de una ranura: con partida enseña de un vistazo por dónde vas;
/// vacía, solo invita a empezar.
class _FichaDeSlot extends StatelessWidget {
  final ResumenSlot resumen;
  final bool deshabilitado;

  /// true si se está eligiendo dónde empezar una partida nueva: entonces una
  /// ranura ocupada ofrece "Sobrescribir" (avisando de lo que se pierde) en
  /// vez de "Continuar".
  final bool modoEmpezar;
  final VoidCallback onContinuar;
  final VoidCallback onEmpezar;
  final VoidCallback onBorrar;

  const _FichaDeSlot({
    required this.resumen,
    required this.deshabilitado,
    required this.modoEmpezar,
    required this.onContinuar,
    required this.onEmpezar,
    required this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    if (!resumen.ocupada) return _vacia(context);

    final equipo = resumen.equipo!;
    final info = infoDe(equipo);
    final sobre = textoSobre(info.colorPrimario);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  info.colorPrimario,
                  Color.lerp(info.colorPrimario, info.colorSecundario, 0.5)!,
                ],
              ),
            ),
            child: Row(
              children: [
                EquipoLogo(codigoEquipo: equipo, tamano: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PARTIDA ${resumen.numero}',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: textoSecundarioSobre(info.colorPrimario))),
                      Text(info.nombreCompleto,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: sobre)),
                      Text(resumen.etiquetaTemporada,
                          style: TextStyle(
                              fontSize: 12,
                              color:
                                  textoSecundarioSobre(info.colorPrimario))),
                    ],
                  ),
                ),
                if (resumen.titulos > 0)
                  Row(
                    children: [
                      Icon(Icons.emoji_events,
                          size: 18, color: const Color(0xFFD4A017)),
                      const SizedBox(width: 2),
                      Text('${resumen.titulos}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: sobre)),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Récord ${resumen.victorias}-${resumen.derrotas}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                IconButton(
                  tooltip: 'Borrar esta partida',
                  onPressed: deshabilitado ? null : onBorrar,
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
                const SizedBox(width: 4),
                if (modoEmpezar)
                  OutlinedButton(
                    onPressed: deshabilitado ? null : onEmpezar,
                    child: const Text('Sobrescribir'),
                  )
                else
                  FilledButton(
                    onPressed: deshabilitado ? null : onContinuar,
                    child: const Text('Continuar'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacia(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: outline),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PARTIDA ${resumen.numero}',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                          color: outline)),
                  Text('Ranura vacía',
                      style: TextStyle(fontSize: 15, color: outline)),
                ],
              ),
            ),
            // Cargando partida no hay nada que cargar en una ranura vacía:
            // el botón se queda a la vista pero apagado, para que se entienda
            // que la ranura existe y está libre.
            OutlinedButton(
              onPressed: deshabilitado || !modoEmpezar ? null : onEmpezar,
              child: const Text('Empezar'),
            ),
          ],
        ),
      ),
    );
  }
}
