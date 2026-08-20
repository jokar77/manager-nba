import 'package:flutter/material.dart';

import 'package:sim_engine/sim_engine.dart' as sim;

import '../../i18n/textos.dart';

import '../../domain/equipos_info.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/estilo.dart';

/// Pantalla de resultado: marcador final y tabla de estadísticas por
/// jugador de ambos equipos.
class BoxscoreScreen extends StatelessWidget {
  final sim.Boxscore boxscore;

  const BoxscoreScreen({super.key, required this.boxscore});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final info = infoDe(boxscore.equipoLocal);

    return Scaffold(
      backgroundColor: e.fondo,
      appBar: BarraDeTituloAppBar(
        codigo: boxscore.equipoLocal,
        primario: info.colorPrimario,
        secundario: info.colorSecundario,
        titulo: t(context).tituloResultadoPartido,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        children: [
          _Marcador(boxscore: boxscore),
          const SizedBox(height: 10),
          _ParcialesCuartos(boxscore: boxscore),
          const SizedBox(height: 18),
          _TablaEquipo(
            nombreEquipo: boxscore.equipoLocal,
            stats: boxscore.statsLocal,
          ),
          const SizedBox(height: 12),
          _TablaEquipo(
            nombreEquipo: boxscore.equipoVisitante,
            stats: boxscore.statsVisitante,
          ),
        ],
      ),
    );
  }
}

/// El marcador final, en la franja de los dos clubes.
class _Marcador extends StatelessWidget {
  final sim.Boxscore boxscore;

  const _Marcador({required this.boxscore});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final ganaLocal = boxscore.marcadorLocal >= boxscore.marcadorVisitante;

    return PanelCortado(
      fondo: e.marcador,
      corte: 14,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: _EquipoMarcador(
                  nombre: boxscore.equipoLocal,
                  puntos: boxscore.marcadorLocal,
                  esGanador: ganaLocal),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(width: 1, height: 54, color: e.lineaFuerte),
            ),
            Expanded(
              child: _EquipoMarcador(
                  nombre: boxscore.equipoVisitante,
                  puntos: boxscore.marcadorVisitante,
                  esGanador: !ganaLocal),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipoMarcador extends StatelessWidget {
  final String nombre;
  final int puntos;
  final bool esGanador;

  const _EquipoMarcador({
    required this.nombre,
    required this.puntos,
    required this.esGanador,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // El escudo junto al marcador: en un partido los equipos se
        // reconocen antes por el escudo que leyendo tres letras.
        EquipoLogo(codigoEquipo: nombre, tamano: 34),
        const SizedBox(height: 6),
        Text(mayus(nombre),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: rotulo(e,
                tamano: 10, color: esGanador ? e.texto : e.textoRotulo)),
        const SizedBox(height: 2),
        Text('$puntos',
            maxLines: 1,
            style: cifra(e,
                tamano: 38, color: esGanador ? e.texto : e.textoTenue)),
      ],
    );
  }
}

/// Los parciales por cuarto. Es la única tabla del juego con una fila por
/// equipo, así que se dibuja a mano en vez de con `DataTable`: los anchos
/// fijos son lo que la hace caber en un móvil.
class _ParcialesCuartos extends StatelessWidget {
  final sim.Boxscore boxscore;

  const _ParcialesCuartos({required this.boxscore});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    // Los 4 primeros periodos son siempre los cuartos; si el partido llegó
    // a empate, le siguen una o más prórrogas ("P1", "P2"...).
    final numPeriodos = boxscore.parcialesLocal.length;
    final prefijoCuarto = t(context).prefijoCuarto;
    final prefijoProrroga = t(context).prefijoProrroga;
    final etiquetas = List.generate(numPeriodos,
        (i) => i < 4 ? '$prefijoCuarto${i + 1}' : '$prefijoProrroga${i - 3}');

    Widget fila(String equipo, List<int> parciales, int total,
        {bool cabecera = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(cabecera ? '' : mayus(equipo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titular(e, tamano: 14)),
            ),
            for (var i = 0; i < parciales.length; i++)
              SizedBox(
                width: 30,
                child: Text(cabecera ? etiquetas[i] : '${parciales[i]}',
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: cabecera
                        ? rotulo(e, tamano: 9)
                        : TextStyle(fontSize: 13, color: e.textoTenue)),
              ),
            SizedBox(
              width: 40,
              child: Text(
                  cabecera ? mayus(t(context).columnaTotal) : '$total',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: cabecera
                      ? rotulo(e, tamano: 9)
                      : cifra(e, tamano: 16)),
            ),
          ],
        ),
      );
    }

    return PanelCortado(
      fondo: e.panel,
      corte: 12,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Column(
          children: [
            fila('', boxscore.parcialesLocal, 0, cabecera: true),
            Container(height: 1, color: e.linea),
            fila(boxscore.equipoLocal, boxscore.parcialesLocal,
                boxscore.marcadorLocal),
            fila(boxscore.equipoVisitante, boxscore.parcialesVisitante,
                boxscore.marcadorVisitante),
          ],
        ),
      ),
    );
  }
}

/// El boxscore de un equipo: una fila por jugador, con el nombre quedándose
/// el ancho que sobre y los números en columnas fijas.
///
/// Antes había dos tablas —`DataTable` en ancho y una hecha a mano en
/// estrecho— porque `DataTable` reparte el ancho según lo que ocupe cada
/// celda y con un nombre largo se salía de la tarjeta en un teléfono. Ahora
/// es la misma en todos los anchos: además de caber siempre, la de Material
/// era lo único del juego que seguía teniendo su aspecto.
class _TablaEquipo extends StatelessWidget {
  final String nombreEquipo;
  final List<sim.EstadisticasJugador> stats;

  const _TablaEquipo({required this.nombreEquipo, required this.stats});

  /// Suficiente para tres cifras: nadie mete 100 puntos, pero los minutos
  /// de una prórroga larga pasan de 50 y el ancho tiene que aguantarlo.
  static const _anchoNumero = 38.0;

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final ordenadas = [...stats]..sort((a, b) => b.puntos.compareTo(a.puntos));
    // La barra lleva el color puro del equipo; el nombre, la versión que se
    // lee sobre el fondo del tema (hay azules marinos que en modo oscuro
    // desaparecían del todo).
    final colorEquipo = infoDe(nombreEquipo).colorPrimario;
    final colorTexto = colorLegibleComoTexto(colorEquipo, context);

    Widget fila(String nombre, List<String> valores, {bool cabecera = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(cabecera ? nombre : mayus(nombre),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: cabecera
                      ? rotulo(e, tamano: 9)
                      : titular(e, tamano: 14)),
            ),
            for (final v in valores)
              SizedBox(
                width: _anchoNumero,
                child: Text(v,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: cabecera
                        ? rotulo(e, tamano: 9)
                        : TextStyle(fontSize: 13.5, color: e.textoTenue)),
              ),
          ],
        ),
      );
    }

    return PanelCortado(
      fondo: e.panel,
      corte: 12,
      borde: Border(
        left: BorderSide(color: colorEquipo, width: 4),
        top: BorderSide(color: e.linea),
        right: BorderSide(color: e.linea),
        bottom: BorderSide(color: e.linea),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EquipoLogo(codigoEquipo: nombreEquipo, tamano: 24),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(mayus(infoDe(nombreEquipo).nombreCompleto),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titular(e, tamano: 17, color: colorTexto)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            fila(
              mayus(t(context).columnaJugador),
              [
                mayus(t(context).columnaMin),
                mayus(t(context).columnaPts),
                mayus(t(context).columnaAst),
                mayus(t(context).columnaReb),
              ],
              cabecera: true,
            ),
            Container(height: 1, color: e.linea),
            for (final s in ordenadas)
              fila(s.nombreFicticio, [
                '${s.minutos}',
                '${s.puntos}',
                '${s.asistencias}',
                '${s.rebotes}',
              ]),
          ],
        ),
      ),
    );
  }
}
