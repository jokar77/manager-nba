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
import '../../shared/equipo_logo.dart';
import '../../shared/navegacion.dart';

/// Menú principal de la franquicia: calendario, tu equipo, clasificación,
/// traspasos y — una vez completes tu temporada regular de 82 partidos —
/// premios y playoffs.
class HomeHubScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipo;

  const HomeHubScreen({super.key, required this.db, required this.equipo});

  @override
  State<HomeHubScreen> createState() => _HomeHubScreenState();
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

  @override
  Widget build(BuildContext context) {
    final db = widget.db;
    final equipo = widget.equipo;
    final textos = t(context);
    final info = infoDe(equipo);
    final colorEquipo = info.colorPrimario;

    return Scaffold(
      body: FutureBuilder<_EstadoDelHub>(
        future: _estadoFuture,
        builder: (context, snapshot) {
          final estado = snapshot.data ?? _EstadoDelHub.vacio;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                // 190 no daba: el apodo del equipo lo pinta
                // `FlexibleSpaceBar.title` pegado abajo, y la fila de datos
                // de la cabecera se le echaba encima. En el navegador, donde
                // el texto se mide distinto, el solape se veía claro.
                expandedHeight: 214,
                backgroundColor: colorEquipo,
                foregroundColor: textoSobre(colorEquipo),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: textos.ajustes,
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AjustesScreen(),
                    )),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(info.apodo,
                      style: TextStyle(
                          color: textoSobre(colorEquipo),
                          fontWeight: FontWeight.bold)),
                  titlePadding:
                      const EdgeInsetsDirectional.only(start: 16, bottom: 14),
                  background: _CabeceraEquipo(equipo: equipo, estado: estado),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                sliver: SliverList.list(children: [
                  TarjetaDeEfectosActivos(
                      efectos: estado.efectosDeVestuario),
                  _AccesoMenu(
                    icono: Icons.calendar_month,
                    color: const Color(0xFF3D7BFF),
                    titulo: textos.calendario,
                    subtitulo: textos.calendarioDetalle,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      settings:
                          const RouteSettings(name: RutasPrincipales.calendario),
                      builder: (context) =>
                          CalendarioScreen(db: db, equipoUsuario: equipo),
                    )),
                  ),
                  _AccesoMenu(
                    icono: Icons.groups,
                    color: const Color(0xFF14A38B),
                    titulo: textos.tuEquipo,
                    subtitulo: textos.tuEquipoDetalle,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => RosterConfigScreen(
                        db: db,
                        equipo: equipo,
                        esConfiguracionInicial: false,
                        onGuardado: () => Navigator.of(context).pop(),
                      ),
                    )),
                  ),
                  _AccesoMenu(
                    icono: Icons.sports,
                    color: const Color(0xFF9C6ADE),
                    titulo: textos.entrenador,
                    subtitulo: estado.entrenador == null
                        ? textos.banquilloVacante
                        : '${estado.entrenador} · media '
                            '${estado.mediaEntrenador}',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          EntrenadorScreen(db: db, equipoUsuario: equipo),
                    )),
                  ),
                  _AccesoMenu(
                    icono: Icons.leaderboard,
                    color: const Color(0xFF7A5AF8),
                    titulo: textos.clasificacion,
                    subtitulo: textos.clasificacionDetalle,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ClasificacionScreen(db: db, equipoUsuario: equipo),
                    )),
                  ),
                  _SeparadorDeSeccion(titulo: textos.mercado),
                  _AccesoMenu(
                    icono: Icons.swap_horiz,
                    color: const Color(0xFFE08A1E),
                    titulo: textos.traspasos,
                    subtitulo: textos.traspasosDetalle,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          TraspasosScreen(db: db, equipoUsuario: equipo),
                    )),
                  ),
                  _AccesoMenu(
                    icono: Icons.mark_email_unread,
                    color: const Color(0xFFD64550),
                    titulo: textos.ofertasRecibidas,
                    subtitulo: estado.ofertas == 0
                        ? textos.nadieTePropuestoNadaAhora
                        : estado.ofertas == 1
                            ? textos.unEquipoQuiereAUnoDeTusJugadores
                            : textos.nEquiposHanPreguntado(estado.ofertas),
                    insignia: estado.ofertas == 0 ? null : '${estado.ofertas}',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          OfertasScreen(db: db, equipoUsuario: equipo),
                    )),
                  ),
                  _AccesoMenu(
                    icono: Icons.person_add,
                    color: const Color(0xFF2E9E5B),
                    titulo: textos.agenciaLibre,
                    subtitulo: textos.agenciaLibreDetalle,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          AgenciaLibreScreen(db: db, equipoUsuario: equipo),
                    )),
                  ),
                  _SeparadorDeSeccion(titulo: textos.competicion),
                  _AccesoMenu(
                    icono: Icons.emoji_events_outlined,
                    color: const Color(0xFFB07D2B),
                    titulo: textos.nbaCup,
                    subtitulo: estado.copaSembrada
                        ? textos.cuadroYResultadosDeLaCopa(textos.nbaCup)
                        : textos.seDesbloqueaAlTerminarFaseDeGrupos,
                    deshabilitado: !estado.copaSembrada,
                    onTap: !estado.copaSembrada
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  TorneoScreen(db: db, equipoUsuario: equipo),
                            )),
                  ),
                  _AccesoMenu(
                    icono: Icons.star,
                    color: const Color(0xFF1D8FE0),
                    titulo: textos.allStar,
                    subtitulo: textos.allStarDetalle,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AllStarScreen(db: db),
                    )),
                  ),
                  _AccesoMenu(
                    icono: Icons.assessment,
                    color: const Color(0xFF2E9E7B),
                    titulo: textos.resumenTemporada,
                    subtitulo: textos.resumenTemporadaDetalle,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ResumenTemporadaScreen(
                          db: db, equipoUsuario: equipo),
                    )),
                  ),
                  _AccesoMenu(
                    icono: Icons.emoji_events,
                    color: const Color(0xFFD4A017),
                    titulo: textos.premios,
                    subtitulo: estado.temporadaCompleta
                        ? textos.premiosDeFinDeTemporadaSubtitulo
                        : textos.seDesbloqueaAlTerminarTemporadaRegular,
                    deshabilitado: !estado.temporadaCompleta,
                    onTap: !estado.temporadaCompleta
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PremiosScreen(db: db, equipoUsuario: equipo),
                            )),
                  ),
                  _AccesoMenu(
                    icono: Icons.sports_basketball,
                    color: const Color(0xFFE2622C),
                    titulo: textos.playoffs,
                    subtitulo: estado.temporadaCompleta
                        ? textos.bracketDeEliminatorias
                        : textos.seDesbloqueaAlTerminarTemporadaRegular,
                    deshabilitado: !estado.temporadaCompleta,
                    onTap: !estado.temporadaCompleta
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  PlayoffsScreen(db: db, equipoUsuario: equipo),
                            )),
                  ),
                  _SeparadorDeSeccion(titulo: textos.legado),
                  _AccesoMenu(
                    icono: Icons.military_tech,
                    color: const Color(0xFF8E6BC9),
                    titulo: textos.legado,
                    subtitulo: textos.hallOfFameYCamisetasRetiradasSubtitulo(
                        textos.hallOfFame, textos.pestanaCamisetasRetiradas),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          LegadoScreen(db: db, equipoUsuario: equipo),
                    )),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// La franja de arriba: logo grande, nombre completo y de un vistazo cómo va
/// la temporada (récord y masa salarial).
class _CabeceraEquipo extends StatelessWidget {
  final String equipo;
  final _EstadoDelHub estado;

  const _CabeceraEquipo({required this.equipo, required this.estado});

  @override
  Widget build(BuildContext context) {
    final info = infoDe(equipo);
    final fondo = info.colorPrimario;
    final sobre = textoSobre(fondo);
    final secundario = textoSecundarioSobre(fondo);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [fondo, Color.lerp(fondo, info.colorSecundario, 0.45)!],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          // El 58 de abajo es el hueco que se le deja al apodo del equipo,
          // que va superpuesto en la misma franja (ver expandedHeight).
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 58),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  EquipoLogo(codigoEquipo: equipo, tamano: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$equipo · ${info.ciudad}',
                            style: TextStyle(
                                color: secundario,
                                fontSize: 13,
                                letterSpacing: 0.3)),
                        Text(
                            estado.anioTemporada.isEmpty
                                ? '${t(context).temporada} ${estado.temporada}'
                                : '${estado.anioTemporada}  ·  '
                                    '${t(context).temporada} '
                                    '${estado.temporada}',
                            style: TextStyle(
                                color: sobre,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        if (estado.anillos > 0 || estado.copas > 0)
                          _Palmares(
                            anillos: estado.anillos,
                            copas: estado.copas,
                            color: sobre,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Cada dato en su columna y con separadores en medio: pegados
              // el uno al otro se leían como una sola cifra larga. Los
              // textos se recortan en vez de desbordar la franja.
              Row(
                children: [
                  Expanded(
                    child: _Dato(
                      // El récord ya deja claro cuántos se han jugado (V+D),
                      // así que no hace falta un dato aparte para eso.
                      etiqueta: '${t(context).record} (${estado.partidosJugados}/82)',
                      valor: '${estado.victorias}-${estado.derrotas}',
                      color: sobre,
                      colorEtiqueta: secundario,
                    ),
                  ),
                  _SeparadorDeDato(color: secundario),
                  Expanded(
                    child: _Dato(
                      etiqueta: estado.conferencia,
                      valor: estado.puestoConferencia == 0
                          ? '—'
                          : '${estado.puestoConferencia}º',
                      // Del 1 al 10 entras en playoffs o play-in; del 11 para
                      // abajo, a casa. Se ve de un vistazo por el color.
                      color: estado.puestoConferencia == 0 ||
                              estado.puestoConferencia <= 10
                          ? sobre
                          : const Color(0xFFFFC5C5),
                      colorEtiqueta: secundario,
                    ),
                  ),
                  _SeparadorDeDato(color: secundario),
                  Expanded(
                    child: _Dato(
                      etiqueta: t(context).salarialLabel,
                      valor: formatearSalario(estado.masaSalarial),
                      color: estado.masaSalarial > topeSalarial
                          ? const Color(0xFFFFC5C5)
                          : sobre,
                      colorEtiqueta: secundario,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeparadorDeDato extends StatelessWidget {
  final Color color;

  const _SeparadorDeDato({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: color.withValues(alpha: 0.35),
      );
}

class _Dato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color color;
  final Color colorEtiqueta;

  const _Dato({
    required this.etiqueta,
    required this.valor,
    required this.color,
    required this.colorEtiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(etiqueta.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: colorEtiqueta, fontSize: 10, letterSpacing: 0.6)),
        Text(valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: color, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SeparadorDeSeccion extends StatelessWidget {
  final String titulo;

  const _SeparadorDeSeccion({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Row(
        children: [
          Text(titulo.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              )),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              height: 1,
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesoMenu extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;
  final bool deshabilitado;
  final Color color;

  /// Contador que se pinta a la derecha (ofertas sin resolver, por ejemplo).
  final String? insignia;

  const _AccesoMenu({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    required this.color,
    this.deshabilitado = false,
    this.insignia,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: deshabilitado ? 0.45 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono,
                      size: 24, color: colorLegibleComoTexto(color, context)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(subtitulo,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          )),
                    ],
                  ),
                ),
                if (insignia != null && !deshabilitado) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD64550),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(insignia!,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 6),
                ],
                if (!deshabilitado)
                  Icon(Icons.chevron_right,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.35)),
              ],
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
  final Color color;

  const _Palmares({
    required this.anillos,
    required this.copas,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (anillos > 0) ...[
            const Icon(Icons.emoji_events, size: 15, color: Color(0xFFFFC94D)),
            const SizedBox(width: 3),
            Text(
              anillos == 1 ? '1 anillo' : '$anillos anillos',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
          if (anillos > 0 && copas > 0) const SizedBox(width: 10),
          if (copas > 0) ...[
            const Icon(Icons.military_tech, size: 15, color: Color(0xFFB9C6D6)),
            const SizedBox(width: 3),
            Text(
              copas == 1 ? '1 NBA Cup' : '$copas NBA Cups',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
