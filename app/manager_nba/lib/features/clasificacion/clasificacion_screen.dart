import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/conferencias.dart';
import '../../domain/equipos_info.dart';
import '../../shared/contraste.dart';
import '../../i18n/textos.dart';
import '../../shared/estilo.dart';
import 'equipo_detalle_screen.dart';

enum _OrdenJugadores { puntos, asistencias, rebotes }

String _etiquetaOrden(_OrdenJugadores o, Textos textos) => switch (o) {
      _OrdenJugadores.puntos => textos.ordenPuntos,
      _OrdenJugadores.asistencias => textos.ordenAsistencias,
      _OrdenJugadores.rebotes => textos.ordenRebotes,
    };

/// Clasificación consultable en cualquier momento: equipos (víctorias/
/// derrotas por conferencia) y líderes de jugadores por la temporada
/// simulada hasta ahora. Con temporada parcial, las medias son solo de lo
/// ya jugado.
class ClasificacionScreen extends StatelessWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const ClasificacionScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final info = infoDe(equipoUsuario);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            BarraDeTitulo(
              codigo: equipoUsuario,
              primario: info.colorPrimario,
              secundario: info.colorSecundario,
              titulo: t(context).clasificacion,
            ),
            TabBar(tabs: [
              Tab(text: mayus(t(context).pestanaEquipos)),
              Tab(text: mayus(t(context).pestanaJugadores)),
            ]),
            Expanded(
              child: TabBarView(children: [
                _TablaEquipos(db: db, equipoUsuario: equipoUsuario),
                _LideresJugadores(db: db, equipoUsuario: equipoUsuario),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Puestos que marcan la frontera dentro de una conferencia: el 6 es el
/// último que entra directo a playoffs y el 10 el último del play-in.
const _ultimoDePlayoffs = 6;
const _ultimoDePlayIn = 10;

class _TablaEquipos extends StatelessWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const _TablaEquipos({required this.db, required this.equipoUsuario});

  Future<Map<String, List<ResultadoTemporadaData>>> _cargar() async {
    final filas = await db.select(db.resultadoTemporada).get();
    final porConferencia = <String, List<ResultadoTemporadaData>>{};
    for (final f in filas) {
      final conferencia = conferenciaPorEquipo[f.equipo];
      if (conferencia == null) continue;
      porConferencia.putIfAbsent(conferencia, () => []).add(f);
    }
    for (final lista in porConferencia.values) {
      lista.sort((a, b) {
        final cmp = _porcentaje(b).compareTo(_porcentaje(a));
        return cmp != 0 ? cmp : b.victorias.compareTo(a.victorias);
      });
    }
    return porConferencia;
  }

  static double _porcentaje(ResultadoTemporadaData r) {
    final total = r.victorias + r.derrotas;
    return total == 0 ? 0.0 : r.victorias / total;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<ResultadoTemporadaData>>>(
      future: _cargar(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final porConferencia = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: ['Este', 'Oeste'].expand((conferencia) sync* {
            yield _CabeceraConferencia(
                titulo: conferencia == 'Este'
                    ? t(context).tituloConferenciaEste
                    : t(context).tituloConferenciaOeste);
            final equipos = porConferencia[conferencia] ?? [];
            for (var i = 0; i < equipos.length; i++) {
              yield _FilaEquipo(
                db: db,
                equipoUsuario: equipoUsuario,
                puesto: i + 1,
                resultado: equipos[i],
                esTuyo: equipos[i].equipo == equipoUsuario,
                porcentaje: _porcentaje(equipos[i]),
                lider: equipos.isEmpty ? null : equipos.first,
              );
              if (i + 1 == _ultimoDePlayoffs || i + 1 == _ultimoDePlayIn) {
                yield _Frontera(
                  texto: i + 1 == _ultimoDePlayoffs
                      ? t(context).fronteraPlayIn
                      : t(context).fronteraFueraDePlayoffs,
                );
              }
            }
          }).toList(),
        );
      },
    );
  }
}

/// Lo que ocupan las tres columnas de cifras de la derecha. Las comparten
/// la cabecera y las filas: cuando la cabecera fingía la alineación con
/// espacios ("V-D    %    DIF"), cualquier cambio de ancho en las filas la
/// dejaba descuadrada y encima podía desbordar en un móvil.
const _anchoRecord = 52.0;
const _anchoPorcentaje = 44.0;
const _anchoDiferencia = 34.0;

class _CabeceraConferencia extends StatelessWidget {
  final String titulo;

  const _CabeceraConferencia({required this.titulo});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    Widget columna(String texto, double ancho) => SizedBox(
          width: ancho,
          child: Text(texto,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: rotulo(e, tamano: 9)),
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Flexible(
            child: Text(titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titular(e, tamano: 14, color: e.marca)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: e.lineaFuerte)),
          const SizedBox(width: 10),
          columna('V-D', _anchoRecord),
          columna('%', _anchoPorcentaje),
          columna('DIF', _anchoDiferencia),
        ],
      ),
    );
  }
}

/// La línea que separa playoffs / play-in / lotería.
class _Frontera extends StatelessWidget {
  final String texto;

  const _Frontera({required this.texto});

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Divider(height: 1, color: color)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(texto.toUpperCase(),
                style: TextStyle(
                    fontSize: 9, letterSpacing: 0.8, color: color)),
          ),
          Expanded(child: Divider(height: 1, color: color)),
        ],
      ),
    );
  }
}

class _FilaEquipo extends StatelessWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final int puesto;
  final ResultadoTemporadaData resultado;
  final bool esTuyo;
  final double porcentaje;
  final ResultadoTemporadaData? lider;

  const _FilaEquipo({
    required this.db,
    required this.equipoUsuario,
    required this.puesto,
    required this.resultado,
    required this.esTuyo,
    required this.porcentaje,
    required this.lider,
  });

  /// Partidos de diferencia con el primero de la conferencia, como en las
  /// clasificaciones de verdad.
  String get _diferencia {
    if (lider == null || lider!.equipo == resultado.equipo) return '—';
    final juegos = ((lider!.victorias - resultado.victorias) +
            (resultado.derrotas - lider!.derrotas)) /
        2;
    if (juegos <= 0) return '—';
    return juegos == juegos.roundToDouble()
        ? juegos.toStringAsFixed(0)
        : juegos.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final info = infoDe(resultado.equipo);
    final acento = colorLegibleComoTexto(info.colorPrimario, context);
    final jugados = resultado.victorias + resultado.derrotas;

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => EquipoDetalleScreen(
          db: db,
          equipo: resultado.equipo,
          equipoUsuario: equipoUsuario,
        ),
      )),
      child: Container(
      decoration: BoxDecoration(
        // Tu equipo, con su propio color en el filo y el panel levantado:
        // en una tabla de quince filas iguales hay que poder encontrarse de
        // un vistazo.
        color: esTuyo ? e.panel : null,
        border: esTuyo
            ? Border(left: BorderSide(color: acento, width: 4))
            : null,
      ),
      padding: EdgeInsets.fromLTRB(esTuyo ? 8 : 12, 7, 12, 7),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('$puesto',
                textAlign: TextAlign.center,
                style: cifra(e, tamano: 15, color: e.textoRotulo)),
          ),
          const SizedBox(width: 6),
          PlacaEquipo(
            codigo: resultado.equipo,
            primario: info.colorPrimario,
            secundario: info.colorSecundario,
            tamano: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mayus(info.nombreCompleto),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titular(e,
                        tamano: 15,
                        color: esTuyo ? e.texto : e.textoTenue)),
                if (jugados > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    // Sin esquinas redondeadas, como el resto del juego.
                    child: LinearProgressIndicator(
                      value: porcentaje,
                      minHeight: 3,
                      backgroundColor: e.lineaFuerte,
                      valueColor: AlwaysStoppedAnimation(acento),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: _anchoRecord,
            child: Text('${resultado.victorias}-${resultado.derrotas}',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: cifra(e, tamano: 17)),
          ),
          SizedBox(
            width: _anchoPorcentaje,
            child: Text(
                jugados == 0
                    ? '—'
                    : porcentaje.toStringAsFixed(3).substring(1),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: e.textoTenue)),
          ),
          SizedBox(
            width: _anchoDiferencia,
            child: Text(_diferencia,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: e.textoRotulo)),
          ),
        ],
      ),
      ),
    );
  }
}

class _LideresJugadores extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const _LideresJugadores({required this.db, required this.equipoUsuario});

  @override
  State<_LideresJugadores> createState() => _LideresJugadoresState();
}

class _LideresJugadoresState extends State<_LideresJugadores> {
  _OrdenJugadores _orden = _OrdenJugadores.puntos;

  Future<List<_LineaLider>> _cargar() async {
    final estadisticas =
        await widget.db.select(widget.db.estadisticasTemporadaJugador).get();
    final jugadores = await widget.db.select(widget.db.jugadores).get();
    final jugadoresPorId = {for (final j in jugadores) j.id: j};

    final lineas = <_LineaLider>[];
    for (final e in estadisticas) {
      if (e.partidosJugados == 0) continue;
      final jugador = jugadoresPorId[e.jugadorId];
      if (jugador == null) continue;
      lineas.add(_LineaLider(
        jugadorId: jugador.id,
        nombre: jugador.nombreFicticio,
        equipo: jugador.equipo,
        partidos: e.partidosJugados,
        puntos: e.puntosTotales / e.partidosJugados,
        asistencias: e.asistenciasTotales / e.partidosJugados,
        rebotes: e.rebotesTotales / e.partidosJugados,
      ));
    }
    return lineas;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: SegmentedButton<_OrdenJugadores>(
            segments: _OrdenJugadores.values
                .map((o) => ButtonSegment(
                    value: o, label: Text(_etiquetaOrden(o, t(context)))))
                .toList(),
            selected: {_orden},
            onSelectionChanged: (s) => setState(() => _orden = s.first),
            showSelectedIcon: false,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<_LineaLider>>(
            future: _cargar(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final lineas = [...snapshot.data!]
                ..sort((a, b) => switch (_orden) {
                      _OrdenJugadores.puntos => b.puntos.compareTo(a.puntos),
                      _OrdenJugadores.asistencias =>
                        b.asistencias.compareTo(a.asistencias),
                      _OrdenJugadores.rebotes =>
                        b.rebotes.compareTo(a.rebotes),
                    });
              if (lineas.isEmpty) {
                return Center(child: Text(t(context).sinPartidosJugados));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: lineas.length,
                itemBuilder: (context, i) => _FilaLider(
                  db: widget.db,
                  equipoUsuario: widget.equipoUsuario,
                  puesto: i + 1,
                  linea: lineas[i],
                  orden: _orden,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilaLider extends StatelessWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final int puesto;
  final _LineaLider linea;
  final _OrdenJugadores orden;

  const _FilaLider({
    required this.db,
    required this.equipoUsuario,
    required this.puesto,
    required this.linea,
    required this.orden,
  });

  /// Bronce, plata y oro para los tres primeros; el resto va en gris.
  Color? get _colorDelPodio => switch (puesto) {
        1 => const Color(0xFFD4A017),
        2 => const Color(0xFF9E9E9E),
        3 => const Color(0xFFB07D2B),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final podio = _colorDelPodio;
    return InkWell(
      onTap: () =>
          abrirFichaDeJugador(context, db, linea.jugadorId, equipoUsuario),
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: podio?.withValues(alpha: 0.20) ??
                  Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.07),
            ),
            child: Text('$puesto',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: podio == null
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6)
                      : colorLegibleComoTexto(podio, context),
                )),
          ),
          const SizedBox(width: 10),
          PlacaEquipo(
            codigo: linea.equipo,
            primario: infoDe(linea.equipo).colorPrimario,
            secundario: infoDe(linea.equipo).colorSecundario,
            tamano: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mayus(linea.nombre),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titular(Estilo.de(context), tamano: 15)),
                Text('${linea.equipo} · ${linea.partidos} PJ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11, color: Estilo.de(context).textoTenue)),
              ],
            ),
          ),
          _Estadistica(
              valor: linea.puntos,
              etiqueta: 'PTS',
              destacada: orden == _OrdenJugadores.puntos),
          _Estadistica(
              valor: linea.asistencias,
              etiqueta: 'AST',
              destacada: orden == _OrdenJugadores.asistencias),
          _Estadistica(
              valor: linea.rebotes,
              etiqueta: 'REB',
              destacada: orden == _OrdenJugadores.rebotes),
        ],
      ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  final double valor;
  final String etiqueta;
  final bool destacada;

  const _Estadistica({
    required this.valor,
    required this.etiqueta,
    required this.destacada,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: 44,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valor.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: destacada ? FontWeight.bold : FontWeight.normal,
                color: destacada
                    ? Theme.of(context).colorScheme.primary
                    : onSurface.withValues(alpha: 0.75),
              )),
          Text(etiqueta,
              style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.5,
                  color: onSurface.withValues(alpha: 0.45))),
        ],
      ),
    );
  }
}

class _LineaLider {
  final int jugadorId;
  final String nombre;
  final String equipo;
  final int partidos;
  final double puntos;
  final double asistencias;
  final double rebotes;

  const _LineaLider({
    required this.jugadorId,
    required this.nombre,
    required this.equipo,
    required this.partidos,
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
  });
}
