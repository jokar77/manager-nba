import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/resumen_temporada_repository.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/navegacion.dart';
import '../../shared/pantalla.dart';

/// El balance de tu temporada regular al terminarla: récord y puesto, la
/// clasificación de los 30 equipos, y los promedios de cada jugador.
///
/// Hasta ahora la temporada se cerraba y saltaba directo a los premios: no
/// había ningún sitio donde ver de un vistazo qué había pasado en el año.
class ResumenTemporadaScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  /// Texto del botón de abajo. Cuando se llega aquí encadenado desde el
  /// final de la temporada lleva a los premios; abierto desde el menú, se
  /// limita a cerrar.
  final String? textoBoton;
  final VoidCallback? onContinuar;

  const ResumenTemporadaScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    this.textoBoton,
    this.onContinuar,
  });

  @override
  State<ResumenTemporadaScreen> createState() => _ResumenTemporadaScreenState();
}

class _ResumenTemporadaScreenState extends State<ResumenTemporadaScreen> {
  late final Future<ResumenDeTemporada> _futuro =
      leerResumenDeTemporada(widget.db, widget.equipoUsuario);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ResumenDeTemporada>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: barraDeClub(
                widget.equipoUsuario, t(context).tituloResumenDeLaTemporada),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                    t(context).noSePudoCargarResumen('${snapshot.error}')),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: barraDeClub(
                widget.equipoUsuario, t(context).tituloResumenDeLaTemporada),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final resumen = snapshot.data!;
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: barraDeClub(
              widget.equipoUsuario,
              resumen.etiquetaTemporada.isEmpty
                  ? t(context).tituloResumenDeLaTemporada
                  : t(context).temporadaConEtiqueta(resumen.etiquetaTemporada),
              acciones: const [BotonMenuPrincipal()],
              bottom: TabBar(tabs: [
                Tab(text: t(context).pestanaBalance),
                Tab(text: t(context).clasificacion),
                Tab(text: t(context).pestanaJugadores),
              ]),
            ),
            body: TabBarView(children: [
              _Balance(resumen: resumen, equipoUsuario: widget.equipoUsuario),
              _Clasificacion(
                  resumen: resumen, equipoUsuario: widget.equipoUsuario),
              _TablaDeJugadores(resumen: resumen),
            ]),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.onContinuar ??
                        () => Navigator.of(context).pop(),
                    child: Text(widget.textoBoton ?? t(context).cerrar),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Balance extends StatelessWidget {
  final ResumenDeTemporada resumen;
  final String equipoUsuario;

  const _Balance({required this.resumen, required this.equipoUsuario});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final columnas = switch (tamanoDe(context)) {
      Tamano.compacto => 2,
      Tamano.medio => 3,
      Tamano.amplio => 4,
    };

    String texto(PartidoDelResumen? p) => p == null
        ? '—'
        : '${p.esLocal ? 'vs' : '@'} ${p.rival}  '
            '${p.marcadorPropio}-${p.marcadorRival}';

    final fichas = <({String titulo, String valor, String? nota})>[
      (
        titulo: t(context).puestoEnConferencia(resumen.conferencia == 'Oeste'
            ? t(context).conferenciaOeste
            : t(context).conferenciaEste),
        valor: t(context).puestoValor(resumen.puestoEnConferencia),
        nota: t(context).puestoEnLaLigaNota(resumen.puestoEnLaLiga),
      ),
      (
        titulo: t(context).puntosPorPartidoLabel,
        valor: resumen.puntosFavorPorPartido.toStringAsFixed(1),
        nota: t(context).encajadosLabel(
            resumen.puntosContraPorPartido.toStringAsFixed(1)),
      ),
      (
        titulo: t(context).diferenciaLabel,
        valor: '${resumen.diferenciaPorPartido >= 0 ? '+' : ''}'
            '${resumen.diferenciaPorPartido.toStringAsFixed(1)}',
        nota: t(context).porPartidoLabel,
      ),
      (
        titulo: t(context).mejorRachaLabel,
        valor: '${resumen.mejorRachaGanando}',
        nota: t(context).victoriasSeguidasLabel,
      ),
      (
        titulo: t(context).peorRachaLabel,
        valor: '${resumen.peorRachaPerdiendo}',
        nota: t(context).derrotasSeguidasLabel,
      ),
      (
        titulo: t(context).mejorVictoriaLabel,
        valor: texto(resumen.mejorVictoria),
        nota: null,
      ),
      (
        titulo: t(context).peorDerrotaLabel,
        valor: texto(resumen.peorDerrota),
        nota: null,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                EquipoLogo(codigoEquipo: equipoUsuario, tamano: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(infoDe(equipoUsuario).nombreCompleto,
                          style: tema.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('${resumen.victorias}-${resumen.derrotas}',
                          style: tema.textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        t(context).partidosJugadosVictoriasPct(
                            resumen.partidosJugados,
                            (resumen.partidosJugados == 0
                                    ? 0
                                    : resumen.victorias /
                                        resumen.partidosJugados *
                                        100)
                                .round()),
                        style: TextStyle(color: tema.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: columnas,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            for (final f in fichas)
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(f.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: tema.colorScheme.outline)),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(f.valor,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      if (f.nota != null)
                        Text(f.nota!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                color: tema.colorScheme.outline)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// La clasificación final de las dos conferencias.
///
/// Ocupa el sitio donde antes iba la lista de los 82 partidos: esa lista no
/// contaba nada que no hubieras visto ya según se jugaban, y lo que de
/// verdad se quiere saber al cerrar el año es dónde has quedado respecto a
/// los otros 29.
class _Clasificacion extends StatelessWidget {
  final ResumenDeTemporada resumen;
  final String equipoUsuario;

  const _Clasificacion({required this.resumen, required this.equipoUsuario});

  @override
  Widget build(BuildContext context) {
    if (resumen.clasificacion.isEmpty) {
      return Center(child: Text(t(context).todaviaNoHayClasificacion));
    }

    // En pantalla ancha caben las dos conferencias una al lado de la otra;
    // en un móvil van seguidas.
    final columnas = [
      for (final conferencia in ['Oeste', 'Este'])
        _TablaDeConferencia(
          conferencia: conferencia,
          equipos: resumen.clasificacion
              .where((e) => e.conferencia == conferencia)
              .toList(),
          equipoUsuario: equipoUsuario,
        ),
    ];

    if (tamanoDe(context) == Tamano.compacto) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [columnas[0], const SizedBox(height: 16), columnas[1]],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: columnas[0]),
            const SizedBox(width: 12),
            Expanded(child: columnas[1]),
          ],
        ),
      ],
    );
  }
}

class _TablaDeConferencia extends StatelessWidget {
  final String conferencia;
  final List<EquipoEnLaClasificacion> equipos;
  final String equipoUsuario;

  const _TablaDeConferencia({
    required this.conferencia,
    required this.equipos,
    required this.equipoUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: tema.colorScheme.surfaceContainerHighest,
            child: Text(
                conferencia == 'Oeste'
                    ? t(context).tituloConferenciaOeste
                    : t(context).tituloConferenciaEste,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
          ),
          for (var i = 0; i < equipos.length; i++)
            _FilaClasificacion(
              puesto: i + 1,
              fila: equipos[i],
              esTuyo: equipos[i].equipo == equipoUsuario,
            ),
        ],
      ),
    );
  }
}

class _FilaClasificacion extends StatelessWidget {
  final int puesto;
  final EquipoEnLaClasificacion fila;
  final bool esTuyo;

  const _FilaClasificacion({
    required this.puesto,
    required this.fila,
    required this.esTuyo,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    // Las ocho primeras plazas son las de playoffs directo; de la 9 a la 10,
    // play-in. Se marca con una línea, que es como se lee una clasificación
    // de la NBA de un vistazo.
    final bordeDePlayoffs = puesto == 8 || puesto == 10;

    return Container(
      decoration: BoxDecoration(
        color: esTuyo
            ? tema.colorScheme.primary.withValues(alpha: 0.14)
            : null,
        border: Border(
          bottom: BorderSide(
            color: bordeDePlayoffs
                ? tema.colorScheme.outline
                : tema.dividerColor,
            width: bordeDePlayoffs ? 1.5 : 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('$puesto',
                style: TextStyle(fontSize: 12, color: tema.colorScheme.outline)),
          ),
          EquipoLogo(codigoEquipo: fila.equipo, tamano: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              infoDe(fila.equipo).apodo,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: esTuyo ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          SizedBox(
            width: 54,
            child: Text('${fila.victorias}-${fila.derrotas}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 44,
            child: Text(
              // ".732", como en una clasificación de la NBA. El 1.000 de un
              // 82-0 se deja entero: quitarle el uno lo convertiría en
              // ".000", que es justo lo contrario.
              fila.porcentaje >= 1
                  ? '1.000'
                  : fila.porcentaje.toStringAsFixed(3).substring(1),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: tema.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _TablaDeJugadores extends StatelessWidget {
  final ResumenDeTemporada resumen;

  const _TablaDeJugadores({required this.resumen});

  /// Tres cifras con decimal ("28.4") caben justo aquí.
  static const _anchoNumero = 42.0;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final jugados = resumen.jugadores.where((j) => j.partidosJugados > 0);
    if (jugados.isEmpty) {
      return Center(child: Text(t(context).todaviaNoHayEstadisticas));
    }

    Widget fila(String nombre, String subtitulo, List<String> valores,
        {required bool esCabecera}) {
      final estilo = TextStyle(
        fontSize: 13,
        fontWeight: esCabecera ? FontWeight.bold : FontWeight.normal,
        color: esCabecera ? outline : null,
      );
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, overflow: TextOverflow.ellipsis, style: estilo),
                  if (subtitulo.isNotEmpty)
                    Text(subtitulo,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: outline)),
                ],
              ),
            ),
            for (final v in valores)
              SizedBox(
                width: _anchoNumero,
                child: Text(v, textAlign: TextAlign.right, style: estilo),
              ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        fila(
            t(context).columnaJugador,
            '',
            [t(context).columnaPJ, t(context).columnaPts,
                t(context).columnaAst, t(context).columnaReb],
            esCabecera: true),
        const Divider(height: 1),
        for (final j in jugados)
          fila(
            j.nombre,
            t(context).posicionMedia(j.posicion, j.media),
            [
              '${j.partidosJugados}',
              j.puntos.toStringAsFixed(1),
              j.asistencias.toStringAsFixed(1),
              j.rebotes.toStringAsFixed(1),
            ],
            esCabecera: false,
          ),
      ],
    );
  }
}
