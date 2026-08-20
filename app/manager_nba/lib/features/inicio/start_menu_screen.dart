import 'dart:async';

import 'package:flutter/material.dart';

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
import '../../shared/estilo.dart';
import '../../shared/navegacion.dart';

/// Pantalla de arranque: las tres ranuras de guardado. Cada una es una
/// carrera independiente —su liga, su calendario, su palmarés—, así que
/// empezar una partida nueva ya no borra la que tenías a medias: se ocupa
/// otra ranura.
///
/// Una ranura ocupada enseña equipo, temporada, récord y anillos, y desde
/// ella se continúa o se borra. Una vacía solo ofrece empezar.
class StartMenuScreen extends StatefulWidget {
  const StartMenuScreen({super.key});

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
    // Y los jugadores que el dataset haya ganado desde que empezó esta
    // partida: `importarJugadoresSiHaceFalta` se sale en cuanto ve la tabla
    // con datos, así que sin esto una carrera en marcha no vería nunca a
    // los que se añadieron después (ver el porqué en el importador).
    await anadirJugadoresQueFaltenDelDataset(db);
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
          title: Text(t(context).sobrescribirLaPartidaN(slot)),
          content: Text(t(context).sePerderaEnteraAviso),
          actions: [
            BotonDialogoSecundario(
              texto: t(context).cancelar,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            BotonDialogoPrincipal(
              texto: t(context).sobrescribirBtn,
              color: Estilo.de(context).mal,
              onPressed: () => Navigator.of(context).pop(true),
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
        titulo: t(context).eligeTuEquipoTitulo,
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
        title: Text(t(context).borrarLaPartidaN(resumen.numero)),
        content: Text(t(context).sePierdeCarreraDeAviso(nombre)),
        actions: [
          BotonDialogoSecundario(
            texto: t(context).cancelar,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          BotonDialogoPrincipal(
            texto: t(context).borrarBtn,
            color: Estilo.de(context).mal,
            onPressed: () => Navigator.of(context).pop(true),
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
    final e = Estilo.de(context);

    return Scaffold(
      backgroundColor: e.fondo,
      body: Stack(
        children: [
          // El balón, enorme y casi transparente, saliéndose por la esquina.
          // Es lo único decorativo de la pantalla: el resto es menú.
          Positioned(
            right: -70,
            bottom: -60,
            child: IgnorePointer(
              child: Icon(Icons.sports_basketball,
                  size: 360, color: e.marca.withValues(alpha: 0.07)),
            ),
          ),
          SafeArea(
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
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      children: [
                        // Alineado a la izquierda y no centrado: es un menú
                        // de juego, no una portada.
                        Container(width: 46, height: 4, color: e.marca),
                        const SizedBox(height: 16),
                        Text('MANAGER NBA',
                            style: TextStyle(
                                fontFamily: familiaTitular,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                letterSpacing: -0.5,
                                color: e.texto)),
                        const SizedBox(height: 8),
                        Text(_subtitulo(context, hayPartidas),
                            style:
                                TextStyle(fontSize: 14, color: e.textoTenue)),
                        const SizedBox(height: 26),
                        if (_procesando)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: LinearProgressIndicator(
                                color: e.marca, backgroundColor: e.panel),
                          ),
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
        ],
      ),
    );
  }

  String _subtitulo(BuildContext context, bool hayPartidas) =>
      switch (_vista) {
        _Vista.menu => hayPartidas
            ? t(context).sigueDondeLoDejaste
            : t(context).empiezaTuCarrera,
        _Vista.empezar => t(context).enQueRanuraQuieresEmpezar,
        _Vista.cargar => t(context).eligeLaPartidaQueQuieresCargar,
      };

  /// El menú de verdad: tres opciones y nada más. Las ranuras solo salen
  /// cuando hay que elegir una, que es cuando significan algo.
  List<Widget> _opcionesDelMenu({required bool hayPartidas}) {
    final e = Estilo.de(context);
    final textos = t(context);
    return [
      if (hayPartidas) ...[
        BotonPrincipal(
          texto: textos.continuar,
          icono: Icons.play_arrow,
          color: e.marca,
          onTap: _procesando ? null : _continuarUltima,
        ),
        const SizedBox(height: 12),
      ],
      // Sin partidas, empezar una es LA acción de la pantalla; con partidas,
      // la principal es seguir donde lo dejaste.
      if (hayPartidas)
        BotonPerfilado(
          texto: textos.nuevaPartidaBtn,
          icono: Icons.add,
          color: e.texto,
          onTap: _procesando
              ? null
              : () => setState(() => _vista = _Vista.empezar),
        )
      else
        BotonPrincipal(
          texto: textos.nuevaPartidaBtn,
          icono: Icons.add,
          color: e.marca,
          onTap: _procesando
              ? null
              : () => setState(() => _vista = _Vista.empezar),
        ),
      if (hayPartidas) ...[
        const SizedBox(height: 12),
        BotonPerfilado(
          texto: textos.cargarPartidaBtn,
          icono: Icons.folder_open,
          color: e.texto,
          onTap: _procesando
              ? null
              : () => setState(() => _vista = _Vista.cargar),
        ),
      ],
      const SizedBox(height: 12),
      BotonPerfilado(
        texto: textos.ajustes,
        icono: Icons.settings,
        color: e.texto,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const AjustesScreen(),
        )),
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
            t(context).lasTresRanurasOcupadasAviso,
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
      BotonPerfilado(
        texto: t(context).volver,
        icono: Icons.arrow_back,
        color: Estilo.de(context).textoTenue,
        alto: 44,
        onTap:
            _procesando ? null : () => setState(() => _vista = _Vista.menu),
      ),
    ];
  }
}

/// La ficha de una ranura: con partida enseña de un vistazo por dónde vas;
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

    final e = Estilo.de(context);
    final equipo = resumen.equipo!;
    final info = infoDe(equipo);
    final sobre = textoSobre(info.colorPrimario);
    final secundario = textoSecundarioSobre(info.colorPrimario);
    final acento = acentoDeEquipo(info.colorPrimario, info.colorSecundario);
    final textos = t(context);

    return PanelCortado(
      fondo: e.panel,
      corte: 14,
      borde: Border.all(color: e.linea),
      child: Column(
        children: [
          // La franja de identidad, en el color del club.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [info.colorPrimario, const Color(0xFF05070B)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -4,
                  right: -4,
                  child: MonogramaFantasma(texto: equipo, tamano: 86),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      PlacaEquipo(
                        codigo: equipo,
                        primario: info.colorPrimario,
                        secundario: info.colorSecundario,
                        tamano: 42,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(mayus(textos.partidaNumero(resumen.numero)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.8,
                                    color: acento)),
                            const SizedBox(height: 2),
                            // El nombre completo y no solo el apodo: aquí
                            // estás eligiendo entre carreras distintas, y la
                            // ciudad es la mitad de la identidad del club.
                            Text(mayus(info.nombreCompleto),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: familiaTitular,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                    color: sobre)),
                            const SizedBox(height: 3),
                            Text(resumen.etiquetaTemporada,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11.5, color: secundario)),
                          ],
                        ),
                      ),
                      if (resumen.titulos > 0) ...[
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events,
                                size: 18, color: Color(0xFFFFC94D)),
                            Text('${resumen.titulos}',
                                style: TextStyle(
                                    fontFamily: familiaTitular,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: sobre)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Y debajo, en el suelo de la app, el récord y qué se puede hacer.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mayus(textos.record), style: rotulo(e, tamano: 9)),
                      Text('${resumen.victorias}-${resumen.derrotas}',
                          style: cifra(e, tamano: 21)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: textos.borrarEstaPartidaTooltip,
                  onPressed: deshabilitado ? null : onBorrar,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: e.textoRotulo,
                ),
                const SizedBox(width: 4),
                if (modoEmpezar)
                  BotonPerfilado(
                    texto: textos.sobrescribirBtn,
                    color: e.mal,
                    alto: 42,
                    onTap: deshabilitado ? null : onEmpezar,
                  )
                else
                  BotonPrincipal(
                    texto: textos.continuar,
                    color: acentoDeEquipo(
                        info.colorPrimario, info.colorSecundario),
                    alto: 42,
                    onTap: deshabilitado ? null : onContinuar,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacia(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    return PanelCortado(
      fondo: e.panelApagado,
      corte: 14,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: e.textoRotulo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mayus(textos.partidaNumero(resumen.numero)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: rotulo(e, tamano: 9)),
                  const SizedBox(height: 2),
                  Text(textos.ranuraVaciaLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: e.textoTenue)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Cargando partida no hay nada que cargar en una ranura vacía:
            // el botón se queda a la vista pero apagado, para que se entienda
            // que la ranura existe y está libre.
            BotonPerfilado(
              texto: textos.empezarBtn,
              color: e.marca,
              alto: 42,
              onTap: deshabilitado || !modoEmpezar ? null : onEmpezar,
            ),
          ],
        ),
      ),
    );
  }
}
