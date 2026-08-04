import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/resumen_temporada_repository.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/navegacion.dart';
import '../../shared/pantalla.dart';

const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _fechaCorta(DateTime f) => '${f.day} ${_meses[f.month - 1].substring(0, 3)}';

/// El balance de tu temporada regular al terminarla: récord y puesto, los 82
/// partidos con su resultado, y los promedios de cada jugador.
///
/// Hasta ahora la temporada se cerraba y saltaba directo a los premios: no
/// había ningún sitio donde ver de un vistazo qué había pasado en el año.
class ResumenTemporadaScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  /// Texto del botón de abajo. Cuando se llega aquí encadenado desde el
  /// final de la temporada lleva a los premios; abierto desde el menú, se
  /// limita a cerrar.
  final String textoBoton;
  final VoidCallback? onContinuar;

  const ResumenTemporadaScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    this.textoBoton = 'Cerrar',
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
            appBar: AppBar(title: const Text('Resumen de la temporada')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se ha podido cargar el resumen.\n'
                    '${snapshot.error}'),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Resumen de la temporada')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final resumen = snapshot.data!;
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(resumen.etiquetaTemporada.isEmpty
                  ? 'Resumen de la temporada'
                  : 'Temporada ${resumen.etiquetaTemporada}'),
              actions: const [BotonMenuPrincipal()],
              bottom: const TabBar(tabs: [
                Tab(text: 'Balance'),
                Tab(text: 'Partidos'),
                Tab(text: 'Jugadores'),
              ]),
            ),
            body: TabBarView(children: [
              _Balance(resumen: resumen, equipoUsuario: widget.equipoUsuario),
              _ListaDePartidos(resumen: resumen),
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
                    child: Text(widget.textoBoton),
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
        titulo: 'Puesto en el ${resumen.conferencia}',
        valor: '${resumen.puestoEnConferencia}º',
        nota: '${resumen.puestoEnLaLiga}º de la liga',
      ),
      (
        titulo: 'Puntos por partido',
        valor: resumen.puntosFavorPorPartido.toStringAsFixed(1),
        nota: 'encajados ${resumen.puntosContraPorPartido.toStringAsFixed(1)}',
      ),
      (
        titulo: 'Diferencia',
        valor: '${resumen.diferenciaPorPartido >= 0 ? '+' : ''}'
            '${resumen.diferenciaPorPartido.toStringAsFixed(1)}',
        nota: 'por partido',
      ),
      (
        titulo: 'Mejor racha',
        valor: '${resumen.mejorRachaGanando}',
        nota: 'victorias seguidas',
      ),
      (
        titulo: 'Peor racha',
        valor: '${resumen.peorRachaPerdiendo}',
        nota: 'derrotas seguidas',
      ),
      (
        titulo: 'Mejor victoria',
        valor: texto(resumen.mejorVictoria),
        nota: null,
      ),
      (
        titulo: 'Peor derrota',
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
                        '${resumen.partidosJugados} partidos · '
                        '${(resumen.partidosJugados == 0 ? 0 : resumen.victorias / resumen.partidosJugados * 100).round()}% '
                        'de victorias',
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

class _ListaDePartidos extends StatelessWidget {
  final ResumenDeTemporada resumen;

  const _ListaDePartidos({required this.resumen});

  @override
  Widget build(BuildContext context) {
    if (resumen.partidos.isEmpty) {
      return const Center(child: Text('Todavía no has jugado ningún partido.'));
    }

    // Agrupados por mes, en orden de calendario: 82 filas seguidas no hay
    // quien las lea.
    final filas = <Widget>[];
    var mesActual = -1;
    for (final p in resumen.partidos) {
      if (p.fecha.month != mesActual) {
        mesActual = p.fecha.month;
        filas.add(Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
          child: Text(
            '${_meses[mesActual - 1]} ${p.fecha.year}'.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.outline),
          ),
        ));
      }
      filas.add(_FilaPartido(partido: p));
    }
    return ListView(children: filas);
  }
}

class _FilaPartido extends StatelessWidget {
  final PartidoDelResumen partido;

  const _FilaPartido({required this.partido});

  @override
  Widget build(BuildContext context) {
    // Verde/rojo translúcido, que funciona igual en modo claro y oscuro (el
    // mismo criterio que el resumen de simulación y el calendario).
    final color = (partido.ganado ? Colors.green : Colors.red)
        .withValues(alpha: 0.14);
    final outline = Theme.of(context).colorScheme.outline;

    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(_fechaCorta(partido.fecha),
                style: TextStyle(fontSize: 12, color: outline)),
          ),
          EquipoLogo(codigoEquipo: partido.rival, tamano: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${partido.esLocal ? 'vs' : '@'} ${partido.rival}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(partido.ganado ? 'V' : 'D',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: partido.ganado
                      ? Colors.green.shade700
                      : Colors.red.shade700)),
          const SizedBox(width: 10),
          SizedBox(
            width: 66,
            child: Text('${partido.marcadorPropio}-${partido.marcadorRival}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
      return const Center(child: Text('Todavía no hay estadísticas.'));
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
        fila('Jugador', '', const ['PJ', 'Pts', 'Ast', 'Reb'],
            esCabecera: true),
        const Divider(height: 1),
        for (final j in jugados)
          fila(
            j.nombre,
            '${j.posicion} · media ${j.media}',
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
