import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/campeones_repository.dart';
import '../../domain/conferencias.dart';
import '../../domain/contratos_repository.dart';
import '../../domain/entrenadores_repository.dart';
import '../../domain/eventos_narrativos_repository.dart';
import '../../domain/equipos_info.dart';
import '../../main.dart' show routeObserver;
import '../../domain/fin_temporada_repository.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/ofertas_repository.dart';
import '../../domain/salarios.dart';
import '../../domain/torneo_repository.dart';
import '../ajustes/ajustes_screen.dart';
import '../allstar/allstar_screen.dart';
import '../calendario/calendario_screen.dart';
import '../calendario/resumen_simulacion_screen.dart';
import '../calendario/simulacion_ui.dart';
import '../../domain/calendario_repository.dart';
import '../clasificacion/clasificacion_screen.dart';
import '../playoffs/playoffs_screen.dart';
import '../premios/premios_screen.dart';
import '../roster/roster_config_screen.dart';
import '../temporada/evento_narrativo_dialog.dart';
import '../temporada/legado_screen.dart';
import '../temporada/resumen_temporada_screen.dart';
import '../torneo/torneo_screen.dart';
import '../mercado/agencia_libre_screen.dart';
import '../mercado/entrenador_screen.dart';
import '../mercado/ofertas_screen.dart';
import '../mercado/traspasos_screen.dart';
import '../../i18n/textos.dart';
import '../../shared/contraste.dart';
import '../../shared/estilo.dart';
import '../../shared/navegacion.dart';
import '../../shared/pantalla.dart';

/// Menú principal de la franquicia: calendario, tu equipo, clasificación,
/// traspasos y — una vez completes tu temporada regular de 82 partidos —
/// premios y playoffs.
class HomeHubScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipo;

  /// Solo para los tests: siembra el azar de simular desde la tarjeta de
  /// próximo partido. Ver `simularHastaConDialogo`.
  final Random? random;

  const HomeHubScreen({
    super.key,
    required this.db,
    required this.equipo,
    this.random,
  });

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
}

/// El próximo partido pendiente de tu calendario: lo justo para pintar la
/// tarjeta y para poder simularlo sin ir al Calendario.
class _ProximoPartido {
  final String rival;
  final DateTime fecha;
  final bool esLocal;
  final bool esTorneoTemporada;

  const _ProximoPartido({
    required this.rival,
    required this.fecha,
    required this.esLocal,
    required this.esTorneoTemporada,
  });
}

/// Lo que hace falta para pintar el menú: en qué punto está la temporada,
/// qué hay desbloqueado y cuántas ofertas esperan.
class _EstadoDelHub {
  final bool temporadaCompleta;
  final bool copaSembrada;
  final int ofertas;
  final int temporada;

  /// El año de verdad de esta temporada ("2030-31"). "Temporada 5" no le
  /// dice nada a nadie: lo que sitúa una carrera es el año.
  final String anioTemporada;
  final int victorias;
  final int derrotas;
  final int masaSalarial;

  /// Puesto en tu conferencia (1-15) y a cuál perteneces. Es lo primero que
  /// mira un mánager al abrir el juego: si estás dentro de playoffs o no.
  final int puestoConferencia;
  final String conferencia;

  /// Lo que lleva ganado tu franquicia EN ESTA CARRERA. Un palmarés que
  /// no se ve no motiva a nadie: si has ganado dos anillos, eso tiene que
  /// estar en la cabecera del equipo, no escondido en Legado.
  final int anillos;
  final int copas;

  /// Lo que hay activo en el vestuario ahora mismo (ver
  /// `eventos_narrativos.dart`). Vacío casi siempre; cuando hay algo, es lo
  /// primero que quieres ver al abrir el juego.
  final List<EfectoDeEvento> efectosDeVestuario;

  /// Quién ocupa tu banquillo, y su media. Null si está vacante.
  final String? entrenador;
  final int mediaEntrenador;

  /// El próximo partido pendiente de tu calendario. Null si no hay ninguno
  /// —temporada regular completa, o playoffs, que se juegan por su propia
  /// pestaña y no tienen fila en `PartidosCalendario`—: entonces la tarjeta
  /// no se enseña, igual que la de efectos de vestuario cuando está vacía.
  final _ProximoPartido? proximoPartido;

  const _EstadoDelHub({
    required this.temporadaCompleta,
    required this.copaSembrada,
    required this.ofertas,
    required this.temporada,
    required this.anioTemporada,
    required this.victorias,
    required this.derrotas,
    required this.masaSalarial,
    required this.puestoConferencia,
    required this.conferencia,
    this.anillos = 0,
    this.copas = 0,
    this.efectosDeVestuario = const [],
    this.entrenador,
    this.mediaEntrenador = 0,
    this.proximoPartido,
  });

  static const vacio = _EstadoDelHub(
    temporadaCompleta: false,
    copaSembrada: false,
    ofertas: 0,
    temporada: 1,
    anioTemporada: '',
    victorias: 0,
    derrotas: 0,
    masaSalarial: 0,
    puestoConferencia: 0,
    conferencia: 'Oeste',
  );

  int get partidosJugados => victorias + derrotas;
}

/// Un destino del menú. Tenerlos como datos y no como trece bloques de
/// widget repetidos es lo que permite pintarlos de dos formas distintas
/// (ficha grande o fila) según el ancho, sin duplicar los textos.
class _Destino {
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;
  final bool bloqueado;

  /// Contador que se pinta a la derecha (ofertas sin resolver).
  final String? insignia;

  const _Destino({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.bloqueado = false,
    this.insignia,
  });
}

class _HomeHubScreenState extends State<HomeHubScreen> with RouteAware {
  late Future<_EstadoDelHub> _estadoFuture = _cargarEstado();

  Future<_EstadoDelHub> _cargarEstado() async {
    final completa = await temporadaRegularCompleta(widget.db, widget.equipo);
    final copaSembrada = (await leerSeriesTorneo(widget.db)).isNotEmpty;
    final ofertas = (await ofertasPendientes(widget.db, widget.equipo)).length;
    final temporada = await leerTemporada(widget.db);
    final titulos = await titulosEnLaPartida(widget.db, widget.equipo);
    final record = await (widget.db.select(widget.db.resultadoTemporada)
          ..where((t) => t.equipo.equals(widget.equipo)))
        .getSingleOrNull();
    final masa = await masaSalarial(widget.db, widget.equipo);

    // Puesto en la conferencia, por porcentaje de victorias — que es como se
    // ordena una clasificación de la NBA. A mitad de temporada no todos han
    // jugado los mismos partidos, así que por victorias a secas engañaría.
    final conferencia = conferenciaPorEquipo[widget.equipo] ?? 'Oeste';
    final todos = await widget.db.select(widget.db.resultadoTemporada).get();
    final deMiConferencia = todos
        .where((r) => conferenciaPorEquipo[r.equipo] == conferencia)
        .toList()
      ..sort((a, b) {
        double pct(ResultadoTemporadaData r) {
          final total = r.victorias + r.derrotas;
          return total == 0 ? 0 : r.victorias / total;
        }

        final porPct = pct(b).compareTo(pct(a));
        return porPct != 0 ? porPct : a.equipo.compareTo(b.equipo);
      });
    final puesto =
        deMiConferencia.indexWhere((r) => r.equipo == widget.equipo) + 1;

    final entrenador = await leerEntrenadorDe(widget.db, widget.equipo);

    // El primero sin jugar, ordenado por fecha. No hace falta pasar por
    // `proximaFechaPendiente` (que solo devuelve la fecha): aquí hace falta
    // la fila entera, para saber contra quién y si es en casa.
    final partidos = await leerPartidos(widget.db, widget.equipo);
    final pendientes = partidos.where((p) => !p.jugado).toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final proximoPartido = pendientes.isEmpty
        ? null
        : _ProximoPartido(
            rival: pendientes.first.rival,
            fecha: pendientes.first.fecha,
            esLocal: pendientes.first.esLocal,
            esTorneoTemporada: pendientes.first.esTorneoTemporada,
          );

    return _EstadoDelHub(
      anioTemporada: etiquetaDeTemporada(temporada.anioInicio),
      anillos: titulos.anillos,
      copas: titulos.copas,
      efectosDeVestuario: await leerEfectosActivos(widget.db),
      temporadaCompleta: completa,
      copaSembrada: copaSembrada,
      ofertas: ofertas,
      temporada: temporada.numero,
      victorias: record?.victorias ?? 0,
      derrotas: record?.derrotas ?? 0,
      masaSalarial: masa,
      puestoConferencia: puesto,
      conferencia: conferencia,
      entrenador: entrenador?.nombreFicticio,
      mediaEntrenador: entrenador == null ? 0 : mediaDe(entrenador),
      proximoPartido: proximoPartido,
    );
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

  /// Al volver del Calendario (o de cualquier otra pantalla) puede haberse
  /// desbloqueado algo — playoffs, premios, la NBA Cup — así que se
  /// recarga. Sin esto había que salir del juego y volver a entrar para que
  /// apareciera la NBA Cup.
  @override
  void didPopNext() {
    // Ojo: cuerpo de bloque, no `=>`. Con flecha, el valor de la asignación
    // es el propio Future y setState revienta ("callback argument returned
    // a Future") justo dentro de la notificación del RouteObserver, lo que
    // además deja el Navigator bloqueado y rompe toda la navegación
    // posterior.
    setState(() {
      _estadoFuture = _cargarEstado();
    });
  }

  void _abrir(Widget Function(BuildContext) constructor, {RouteSettings? ruta}) {
    Navigator.of(context).push(MaterialPageRoute(
      settings: ruta,
      builder: constructor,
    ));
  }

  /// Los cuatro sitios donde entras cada día. Van como fichas grandes: si
  /// todo pesa lo mismo, no hay menú, hay lista.
  List<_Destino> _principales(_EstadoDelHub estado) {
    final db = widget.db;
    final equipo = widget.equipo;
    final textos = t(context);
    return [
      _Destino(
        icono: Icons.calendar_month,
        color: const Color(0xFF3D7BFF),
        titulo: textos.calendario,
        subtitulo: textos.calendarioDetalle,
        onTap: () => _abrir(
          (context) => CalendarioScreen(db: db, equipoUsuario: equipo),
          ruta: const RouteSettings(name: RutasPrincipales.calendario),
        ),
      ),
      _Destino(
        icono: Icons.groups,
        color: const Color(0xFF14A38B),
        titulo: textos.tuEquipo,
        subtitulo: textos.tuEquipoDetalle,
        onTap: () => _abrir((context) => RosterConfigScreen(
              db: db,
              equipo: equipo,
              esConfiguracionInicial: false,
              onGuardado: () => Navigator.of(context).pop(),
            )),
      ),
      _Destino(
        icono: Icons.leaderboard,
        color: const Color(0xFF7A5AF8),
        titulo: textos.clasificacion,
        subtitulo: textos.clasificacionDetalle,
        onTap: () => _abrir(
            (context) => ClasificacionScreen(db: db, equipoUsuario: equipo)),
      ),
      _Destino(
        icono: Icons.sports,
        color: const Color(0xFF9C6ADE),
        titulo: textos.entrenador,
        subtitulo: estado.entrenador == null
            ? textos.banquilloVacante
            : '${estado.entrenador} · media ${estado.mediaEntrenador}',
        onTap: () => _abrir(
            (context) => EntrenadorScreen(db: db, equipoUsuario: equipo)),
      ),
    ];
  }

  List<_Destino> _mercado(_EstadoDelHub estado) {
    final db = widget.db;
    final equipo = widget.equipo;
    final textos = t(context);
    return [
      _Destino(
        icono: Icons.swap_horiz,
        color: const Color(0xFFE08A1E),
        titulo: textos.traspasos,
        subtitulo: textos.traspasosDetalle,
        onTap: () =>
            _abrir((context) => TraspasosScreen(db: db, equipoUsuario: equipo)),
      ),
      _Destino(
        icono: Icons.mark_email_unread,
        color: const Color(0xFFD64550),
        titulo: textos.ofertasRecibidas,
        subtitulo: estado.ofertas == 0
            ? textos.nadieTePropuestoNadaAhora
            : estado.ofertas == 1
                ? textos.unEquipoQuiereAUnoDeTusJugadores
                : textos.nEquiposHanPreguntado(estado.ofertas),
        insignia: estado.ofertas == 0 ? null : '${estado.ofertas}',
        onTap: () =>
            _abrir((context) => OfertasScreen(db: db, equipoUsuario: equipo)),
      ),
      _Destino(
        icono: Icons.person_add,
        color: const Color(0xFF2E9E5B),
        titulo: textos.agenciaLibre,
        subtitulo: textos.agenciaLibreDetalle,
        onTap: () => _abrir(
            (context) => AgenciaLibreScreen(db: db, equipoUsuario: equipo)),
      ),
    ];
  }

  List<_Destino> _competicion(_EstadoDelHub estado) {
    final db = widget.db;
    final equipo = widget.equipo;
    final textos = t(context);
    return [
      _Destino(
        icono: Icons.emoji_events_outlined,
        color: const Color(0xFFB07D2B),
        titulo: textos.nbaCup,
        subtitulo: estado.copaSembrada
            ? textos.cuadroYResultadosDeLaCopa(textos.nbaCup)
            : textos.seDesbloqueaAlTerminarFaseDeGrupos,
        bloqueado: !estado.copaSembrada,
        onTap: !estado.copaSembrada
            ? null
            : () => _abrir(
                (context) => TorneoScreen(db: db, equipoUsuario: equipo)),
      ),
      _Destino(
        icono: Icons.star,
        color: const Color(0xFF1D8FE0),
        titulo: textos.allStar,
        subtitulo: textos.allStarDetalle,
        onTap: () => _abrir((context) => AllStarScreen(db: db)),
      ),
      _Destino(
        icono: Icons.assessment,
        color: const Color(0xFF2E9E7B),
        titulo: textos.resumenTemporada,
        subtitulo: textos.resumenTemporadaDetalle,
        onTap: () => _abrir((context) =>
            ResumenTemporadaScreen(db: db, equipoUsuario: equipo)),
      ),
      _Destino(
        icono: Icons.emoji_events,
        color: const Color(0xFFD4A017),
        titulo: textos.premios,
        subtitulo: estado.temporadaCompleta
            ? textos.premiosDeFinDeTemporadaSubtitulo
            : textos.seDesbloqueaAlTerminarTemporadaRegular,
        bloqueado: !estado.temporadaCompleta,
        onTap: !estado.temporadaCompleta
            ? null
            : () => _abrir(
                (context) => PremiosScreen(db: db, equipoUsuario: equipo)),
      ),
      _Destino(
        icono: Icons.sports_basketball,
        color: const Color(0xFFE2622C),
        titulo: textos.playoffs,
        subtitulo: estado.temporadaCompleta
            ? textos.bracketDeEliminatorias
            : textos.seDesbloqueaAlTerminarTemporadaRegular,
        bloqueado: !estado.temporadaCompleta,
        onTap: !estado.temporadaCompleta
            ? null
            : () => _abrir(
                (context) => PlayoffsScreen(db: db, equipoUsuario: equipo)),
      ),
    ];
  }

  List<_Destino> _legado() {
    final db = widget.db;
    final equipo = widget.equipo;
    final textos = t(context);
    return [
      _Destino(
        icono: Icons.military_tech,
        color: const Color(0xFF8E6BC9),
        titulo: textos.legado,
        subtitulo: textos.hallOfFameYCamisetasRetiradasSubtitulo(
            textos.hallOfFame, textos.pestanaCamisetasRetiradas),
        onTap: () =>
            _abrir((context) => LegadoScreen(db: db, equipoUsuario: equipo)),
      ),
    ];
  }

  void _abrirAjustes() => _abrir((context) => const AjustesScreen());

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final info = infoDe(widget.equipo);
    final tamano = tamanoDe(context);

    return Scaffold(
      backgroundColor: e.fondo,
      body: FutureBuilder<_EstadoDelHub>(
        future: _estadoFuture,
        builder: (context, snapshot) {
          final estado = snapshot.data ?? _EstadoDelHub.vacio;
          return tamano == Tamano.amplio
              ? _anchoDeEscritorio(e, info, estado)
              : _unaColumna(e, info, estado, tamano);
        },
      ),
    );
  }

  /// Móvil y tablet: la cabecera arriba y el menú debajo, todo en un
  /// scroll. Lo único que cambia entre los dos es cuántas columnas caben.
  Widget _unaColumna(
      Estilo e, EquipoInfo info, _EstadoDelHub estado, Tamano tamano) {
    final compacto = tamano.esCompacto;
    final margen = compacto ? 16.0 : 28.0;
    final acento = colorLegibleComoTexto(info.colorSecundario, context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CabeceraEquipo(
            equipo: widget.equipo,
            info: info,
            estado: estado,
            margen: margen,
            columnasDeMarcador: compacto ? 3 : 4,
            onAjustes: _abrirAjustes,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(margen, 0, margen, 28),
          sliver: SliverList.list(children: [
            if (estado.proximoPartido != null)
              _TarjetaProximoPartido(
                db: widget.db,
                equipoUsuario: widget.equipo,
                partido: estado.proximoPartido!,
                random: widget.random,
                // El closure que se le PASA a setState tiene que ser de
                // bloque, no de flecha: `setState(() => x = y)` hace que el
                // argumento devuelva el valor de la asignación (el propio
                // Future de `_cargarEstado()`), y setState revienta con
                // "callback argument returned a Future" — el mismo fallo
                // que ya advertía `didPopNext` más abajo en este fichero.
                onSimulado: () {
                  setState(() {
                    _estadoFuture = _cargarEstado();
                  });
                },
              ),
            TarjetaDeEfectosActivos(efectos: estado.efectosDeVestuario),
            ..._secciones(e, estado, acento,
                columnasFichas: compacto ? 2 : 4,
                columnasFilas: compacto ? 1 : 2,
                altoFicha: compacto ? 138 : 150),
          ]),
        ),
      ],
    );
  }

  /// Escritorio: la cabecera de identidad va arriba, igual que en móvil —
  /// el menú aprovecha el ancho de sobra con más columnas por fila, no con
  /// una columna fija a un lado.
  Widget _anchoDeEscritorio(
      Estilo e, EquipoInfo info, _EstadoDelHub estado) {
    final acento = colorLegibleComoTexto(info.colorSecundario, context);
    const margen = 32.0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _CabeceraEquipo(
            equipo: widget.equipo,
            info: info,
            estado: estado,
            margen: margen,
            columnasDeMarcador: 4,
            onAjustes: _abrirAjustes,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(margen, 0, margen, 32),
          sliver: SliverList.list(children: [
            if (estado.proximoPartido != null)
              _TarjetaProximoPartido(
                db: widget.db,
                equipoUsuario: widget.equipo,
                partido: estado.proximoPartido!,
                random: widget.random,
                // Ver el comentario de la otra copia de este callback,
                // arriba en _unaColumna.
                onSimulado: () {
                  setState(() {
                    _estadoFuture = _cargarEstado();
                  });
                },
              ),
            TarjetaDeEfectosActivos(efectos: estado.efectosDeVestuario),
            ..._secciones(e, estado, acento,
                columnasFichas: 4, columnasFilas: 3, altoFicha: 190),
          ]),
        ),
      ],
    );
  }

  List<Widget> _secciones(
    Estilo e,
    _EstadoDelHub estado,
    Color acento, {
    required int columnasFichas,
    required int columnasFilas,
    required double altoFicha,
  }) {
    final textos = t(context);
    return [
      const SizedBox(height: 16),
      SeparadorSeccion(titulo: textos.tuFranquiciaSeccion, acento: acento),
      const SizedBox(height: 10),
      _rejilla(
        _principales(estado)
            .map((d) => _Ficha(destino: d, alto: altoFicha))
            .toList(),
        columnasFichas,
        9,
      ),
      const SizedBox(height: 22),
      SeparadorSeccion(titulo: textos.mercado, acento: acento),
      const SizedBox(height: 10),
      _rejilla(_mercado(estado).map((d) => _Fila(destino: d)).toList(),
          columnasFilas, 7),
      const SizedBox(height: 22),
      SeparadorSeccion(titulo: textos.competicion, acento: acento),
      const SizedBox(height: 10),
      _rejilla(_competicion(estado).map((d) => _Fila(destino: d)).toList(),
          columnasFilas, 7),
      const SizedBox(height: 22),
      SeparadorSeccion(titulo: textos.legado, acento: acento),
      const SizedBox(height: 10),
      _rejilla(
          _legado().map((d) => _Fila(destino: d)).toList(), columnasFilas, 7),
    ];
  }

  /// Reparte [piezas] en [columnas] columnas iguales.
  ///
  /// A mano y no con un GridView porque estas rejillas viven dentro de un
  /// sliver y tienen alto conocido: un GridView anidado obligaría a
  /// `shrinkWrap` y a pelearse con el `childAspectRatio` para conseguir lo
  /// que aquí es una fila de `Expanded`.
  Widget _rejilla(List<Widget> piezas, int columnas, double hueco) {
    if (columnas <= 1) {
      return Column(
        children: [
          for (var i = 0; i < piezas.length; i++) ...[
            if (i > 0) SizedBox(height: hueco),
            piezas[i],
          ],
        ],
      );
    }

    final filas = <Widget>[];
    for (var i = 0; i < piezas.length; i += columnas) {
      final trozo = piezas.skip(i).take(columnas).toList();
      filas.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var c = 0; c < columnas; c++) ...[
              if (c > 0) SizedBox(width: hueco),
              // Los huecos que sobran en la última fila se quedan vacíos:
              // así las columnas siguen alineadas con las de arriba.
              Expanded(
                  child: c < trozo.length ? trozo[c] : const SizedBox.shrink()),
            ],
          ],
        ),
      ));
      if (i + columnas < piezas.length) filas.add(SizedBox(height: hueco));
    }
    return Column(children: filas);
  }
}

/// La franja de arriba en móvil y tablet: placa del equipo, apodo grande,
/// palmarés y el marcador con cómo va la temporada.
class _CabeceraEquipo extends StatelessWidget {
  final String equipo;
  final EquipoInfo info;
  final _EstadoDelHub estado;
  final double margen;
  final int columnasDeMarcador;
  final VoidCallback onAjustes;

  const _CabeceraEquipo({
    required this.equipo,
    required this.info,
    required this.estado,
    required this.margen,
    required this.columnasDeMarcador,
    required this.onAjustes,
  });

  @override
  Widget build(BuildContext context) {
    final fondo = info.colorPrimario;
    final sobre = textoSobre(fondo);
    final acento = acentoDeEquipo(info.colorPrimario, info.colorSecundario);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Siempre acaba casi en negro, en los dos modos: la cabecera es
          // la banda de identidad del club, no parte del fondo de la app.
          colors: [fondo, const Color(0xFF05070B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: 0, right: 0, child: CunaEsquina(color: acento)),
          Positioned(
            top: 2,
            right: -8,
            child: MonogramaFantasma(texto: equipo, tamano: 132),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(margen, 12, margen, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlacaEquipo(
                        codigo: equipo,
                        primario: info.colorPrimario,
                        secundario: info.colorSecundario,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mayus('${info.ciudad} · ${estado.conferencia}'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.2,
                                  color: acento),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              mayus(info.apodo),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: familiaTitular,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  height: 0.98,
                                  letterSpacing: -0.5,
                                  color: sobre),
                            ),
                            if (estado.anillos > 0 || estado.copas > 0) ...[
                              const SizedBox(height: 8),
                              _Palmares(
                                  anillos: estado.anillos,
                                  copas: estado.copas,
                                  acento: acento,
                                  sobre: sobre),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        color: sobre,
                        tooltip: t(context).ajustes,
                        onPressed: onAjustes,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Marcador(
                  estado: estado,
                  acento: acento,
                  margen: margen,
                  columnas: columnasDeMarcador,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La franja de datos pegada bajo la cabecera: récord, puesto y salarial.
class _Marcador extends StatelessWidget {
  final _EstadoDelHub estado;
  final Color acento;
  final double margen;
  final int columnas;

  const _Marcador({
    required this.estado,
    required this.acento,
    required this.margen,
    required this.columnas,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final datos = _datosDelMarcador(context, estado, e);
    final visibles = datos.take(columnas).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: e.marcador,
        border: Border(top: BorderSide(color: acento, width: 2)),
      ),
      // IntrinsicHeight porque el `stretch` de abajo —el que hace que los
      // filetes separadores lleguen de arriba abajo— necesita una altura
      // definida, y aquí dentro de un sliver no la hay.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < visibles.length; i++)
              Expanded(
                child: Container(
                  decoration: i == 0
                      ? null
                      : BoxDecoration(
                          border:
                              Border(left: BorderSide(color: e.lineaFuerte))),
                  padding:
                      EdgeInsets.fromLTRB(i == 0 ? margen : 14, 11, 14, 12),
                  child: _Dato(dato: visibles[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static List<_DatoDeMarcador> _datosDelMarcador(
      BuildContext context, _EstadoDelHub estado, Estilo e) {
    final textos = t(context);
    return [
      _DatoDeMarcador(
        etiqueta: '${textos.record} · ${estado.partidosJugados}/82',
        valor: '${estado.victorias}-${estado.derrotas}',
      ),
      _DatoDeMarcador(
        etiqueta: estado.conferencia,
        valor: estado.puestoConferencia == 0
            ? '—'
            : '${estado.puestoConferencia}º',
        // Del 1 al 10 entras en playoffs o play-in; del 11 para abajo, a
        // casa. Se ve de un vistazo por el color.
        color: estado.puestoConferencia == 0
            ? null
            : (estado.puestoConferencia <= 10 ? e.bien : e.mal),
      ),
      _DatoDeMarcador(
        etiqueta: textos.salarialLabel,
        valor: formatearSalario(estado.masaSalarial),
        color: estado.masaSalarial > topeSalarial ? e.mal : null,
      ),
      _DatoDeMarcador(
        etiqueta: textos.entrenador,
        valor: estado.entrenador == null
            ? '—'
            : '${estado.entrenador} ${estado.mediaEntrenador}',
      ),
    ];
  }
}

class _DatoDeMarcador {
  final String etiqueta;
  final String valor;
  final Color? color;

  const _DatoDeMarcador({
    required this.etiqueta,
    required this.valor,
    this.color,
  });
}

class _Dato extends StatelessWidget {
  final _DatoDeMarcador dato;

  const _Dato({required this.dato});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(mayus(dato.etiqueta),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: rotulo(e, tamano: 9)),
        const SizedBox(height: 1),
        Text(dato.valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: cifra(e, tamano: 26, color: dato.color)),
      ],
    );
  }
}

/// Ficha grande: los cuatro destinos principales.
class _Ficha extends StatelessWidget {
  final _Destino destino;
  final double alto;

  const _Ficha({required this.destino, required this.alto});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final color = colorLegibleComoTexto(destino.color, context);

    return SizedBox(
      height: alto,
      child: PanelCortado(
        fondo: e.panel,
        corte: 16,
        borde: Border.all(color: e.linea),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: destino.onTap,
            child: Stack(
              children: [
                Positioned(top: 0, left: 0, child: Container(width: 48, height: 3, color: color)),
                Positioned(
                  right: -14,
                  bottom: -12,
                  child: Icon(destino.icono,
                      size: alto * 0.55,
                      color: color.withValues(alpha: 0.10)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 16, 13, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(destino.icono, size: 22, color: color),
                      const Spacer(),
                      Text(mayus(destino.titulo),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titular(e, tamano: alto > 170 ? 22 : 18)),
                      const SizedBox(height: 3),
                      Text(destino.subtitulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11.5,
                              height: 1.28,
                              color: e.textoTenue)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de acceso: todo lo demás.
class _Fila extends StatelessWidget {
  final _Destino destino;

  const _Fila({required this.destino});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final color = colorLegibleComoTexto(destino.color, context);
    final bloqueado = destino.bloqueado;

    return Opacity(
      opacity: bloqueado ? 0.5 : 1,
      child: PanelCortado(
        fondo: bloqueado ? e.panelApagado : e.panelSuave,
        corte: 11,
        borde: Border(
          left: BorderSide(
              color: bloqueado ? color.withValues(alpha: 0.35) : color,
              width: 3),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: destino.onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 58),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
                child: Row(
                  children: [
                    SizedBox(
                        width: 46,
                        child: Icon(destino.icono, size: 21, color: color)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mayus(destino.titulo),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: titular(e, tamano: 17)),
                          const SizedBox(height: 2),
                          Text(destino.subtitulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11.5, color: e.textoTenue)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (destino.insignia != null && !bloqueado)
                      Container(
                        constraints: const BoxConstraints(minWidth: 24),
                        height: 24,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        color: const Color(0xFFD64550),
                        child: Text(destino.insignia!,
                            style: TextStyle(
                                fontFamily: familiaTitular,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      )
                    else
                      Icon(bloqueado ? Icons.lock_outline : Icons.chevron_right,
                          size: bloqueado ? 16 : 18,
                          color: e.textoRotulo),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Los títulos de tu franquicia en la cabecera: anillos y NBA Cups.
///
/// Iconos distintos y no dos trofeos iguales, que es lo que se hizo ya en
/// el selector de equipos: el anillo lleva copa dorada y la Cup una medalla
/// en otro tono. No son los trofeos reales —esos no se pueden usar— pero se
/// distinguen de un vistazo.
class _Palmares extends StatelessWidget {
  final int anillos;
  final int copas;
  final Color acento;
  final Color sobre;

  const _Palmares({
    required this.anillos,
    required this.copas,
    required this.acento,
    required this.sobre,
  });

  @override
  Widget build(BuildContext context) {
    final textos = t(context);
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (anillos > 0)
          _Chapa(
            icono: Icons.emoji_events,
            colorIcono: const Color(0xFFFFC94D),
            borde: acento,
            texto: textos.anillos(anillos),
            colorTexto: sobre,
          ),
        if (copas > 0)
          _Chapa(
            icono: Icons.military_tech,
            colorIcono: const Color(0xFFB9C6D6),
            borde: const Color(0xFFB9C6D6),
            texto: textos.copasGanadas(copas, textos.nbaCup),
            colorTexto: sobre,
          ),
      ],
    );
  }
}

class _Chapa extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color borde;
  final String texto;
  final Color colorTexto;

  const _Chapa({
    required this.icono,
    required this.colorIcono,
    required this.borde,
    required this.texto,
    required this.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 9, 3),
      decoration: BoxDecoration(
        color: borde.withValues(alpha: 0.14),
        border: Border(left: BorderSide(color: borde, width: 2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: colorIcono),
          const SizedBox(width: 5),
          Text(mayus(texto),
              style: TextStyle(
                  fontFamily: familiaTitular,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: colorTexto)),
        ],
      ),
    );
  }
}

/// El próximo partido, con un botón para simularlo sin salir del menú.
///
/// Solo se enseña si hay uno: con la temporada regular completa, o durante
/// los playoffs (que se juegan por su cuadro, no tienen fila en
/// `PartidosCalendario`), el estado no trae ninguno y la tarjeta desaparece
/// — el mismo patrón que la de efectos de vestuario.
///
/// Es un `StatefulWidget` propio, no una función del hub, porque necesita
/// su propio "está simulando" para deshabilitarse mientras dura: el hub no
/// tiene por qué saber que esta tarjeta está ocupada.
class _TarjetaProximoPartido extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final _ProximoPartido partido;

  /// Se llama al terminar de simular (haya habido partido o no) para que el
  /// hub recargue el récord y el siguiente partido pendiente.
  final VoidCallback onSimulado;

  /// Solo para los tests. Ver `simularHastaConDialogo`.
  final Random? random;

  const _TarjetaProximoPartido({
    required this.db,
    required this.equipoUsuario,
    required this.partido,
    required this.onSimulado,
    this.random,
  });

  @override
  State<_TarjetaProximoPartido> createState() =>
      _TarjetaProximoPartidoState();
}

class _TarjetaProximoPartidoState extends State<_TarjetaProximoPartido> {
  bool _simulando = false;

  Future<void> _simular() async {
    if (_simulando) return;
    setState(() => _simulando = true);

    // El mismo camino que "Simular 1 partido" del Calendario: sin diálogo
    // de confirmación, porque apunta a un único partido concreto y no hay
    // nada que decidir (a diferencia de "simular hasta" una fecha lejana,
    // que sí puede arrastrar varios).
    final resultado = await simularHastaConDialogo(
        context, widget.db, widget.equipoUsuario, widget.partido.fecha,
        random: widget.random);
    if (!mounted) return;
    setState(() => _simulando = false);
    widget.onSimulado();

    if (resultado.partidos.isNotEmpty && context.mounted) {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (context) => ResumenSimulacionScreen(
          db: widget.db,
          equipoUsuario: widget.equipoUsuario,
          resultado: resultado,
          random: widget.random,
        ),
      ));
      // Al volver del resumen puede haber más de un partido simulado (una
      // oferta te paró a media semana, por ejemplo): se recarga otra vez.
      widget.onSimulado();
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final tuInfo = infoDe(widget.equipoUsuario);
    final rivalInfo = infoDe(widget.partido.rival);
    final acento = acentoDeEquipo(tuInfo.colorPrimario, tuInfo.colorSecundario);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PanelCortado(
        fondo: e.panel,
        corte: 16,
        borde: Border(
          left: BorderSide(color: acento, width: 3),
          top: BorderSide(color: e.linea),
          right: BorderSide(color: e.linea),
          bottom: BorderSide(color: e.linea),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                      widget.partido.esLocal
                          ? Icons.home
                          : Icons.flight_takeoff,
                      size: 13,
                      color: acento),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      mayus(
                          '${textos.proximoPartidoTitulo} · '
                          '${widget.partido.esLocal ? textos.enCasaLabel : textos.fueraLabel}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: rotulo(e, tamano: 10, color: acento),
                    ),
                  ),
                  if (widget.partido.esTorneoTemporada) ...[
                    const Icon(Icons.emoji_events,
                        size: 14, color: Color(0xFFE0A81E)),
                    const SizedBox(width: 6),
                  ],
                  Text(_fechaCorta(widget.partido.fecha),
                      style: TextStyle(fontSize: 11, color: e.textoTenue)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        PlacaEquipo(
                          codigo: widget.equipoUsuario,
                          primario: tuInfo.colorPrimario,
                          secundario: tuInfo.colorSecundario,
                          tamano: 40,
                        ),
                        const SizedBox(height: 5),
                        Text(mayus(tuInfo.apodo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: titular(e, tamano: 13)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(textos.vsAbreviatura,
                        style: cifra(e, tamano: 15, color: e.textoRotulo)),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        PlacaEquipo(
                          codigo: widget.partido.rival,
                          primario: rivalInfo.colorPrimario,
                          secundario: rivalInfo.colorSecundario,
                          tamano: 40,
                        ),
                        const SizedBox(height: 5),
                        Text(mayus(rivalInfo.apodo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: titular(e, tamano: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BotonPrincipal(
                texto: textos.simularUnPartido,
                icono: Icons.play_arrow,
                color: acento,
                alto: 44,
                onTap: _simulando ? null : _simular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _fechaCorta(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')}/'
    '${fecha.month.toString().padLeft(2, '0')}';
