import 'package:flutter/material.dart';

import '../../i18n/textos.dart';import 'package:sim_engine/sim_engine.dart' as sim;

import '../../domain/equipos_info.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/pantalla.dart';

/// Pantalla de resultado: marcador final y tabla de estadísticas por
/// jugador de ambos equipos.
class BoxscoreScreen extends StatelessWidget {
  final sim.Boxscore boxscore;

  const BoxscoreScreen({super.key, required this.boxscore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t(context).tituloResultadoPartido)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Marcador(boxscore: boxscore),
          const SizedBox(height: 12),
          _ParcialesCuartos(boxscore: boxscore),
          const SizedBox(height: 24),
          _TablaEquipo(
            nombreEquipo: boxscore.equipoLocal,
            stats: boxscore.statsLocal,
          ),
          const SizedBox(height: 24),
          _TablaEquipo(
            nombreEquipo: boxscore.equipoVisitante,
            stats: boxscore.statsVisitante,
          ),
        ],
      ),
    );
  }
}

class _Marcador extends StatelessWidget {
  final sim.Boxscore boxscore;

  const _Marcador({required this.boxscore});

  @override
  Widget build(BuildContext context) {
    final ganaLocal = boxscore.marcadorLocal >= boxscore.marcadorVisitante;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _EquipoMarcador(
              nombre: boxscore.equipoLocal,
              puntos: boxscore.marcadorLocal,
              esGanador: ganaLocal,
            ),
            const Text('-', style: TextStyle(fontSize: 28)),
            _EquipoMarcador(
              nombre: boxscore.equipoVisitante,
              puntos: boxscore.marcadorVisitante,
              esGanador: !ganaLocal,
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
    return Column(
      children: [
        // El escudo junto al marcador: en un partido los equipos se
        // reconocen antes por el logo que leyendo tres letras.
        EquipoLogo(codigoEquipo: nombre, tamano: 34),
        const SizedBox(height: 4),
        Text(nombre,
            style: TextStyle(
                fontWeight: esGanador ? FontWeight.bold : FontWeight.normal)),
        Text(
          '$puntos',
          style: TextStyle(
            fontSize: 32,
            fontWeight: esGanador ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _ParcialesCuartos extends StatelessWidget {
  final sim.Boxscore boxscore;

  const _ParcialesCuartos({required this.boxscore});

  @override
  Widget build(BuildContext context) {
    // Los 4 primeros periodos son siempre los cuartos; si el partido llegó
    // a empate, le siguen una o más prórrogas ("P1", "P2"...).
    final numPeriodos = boxscore.parcialesLocal.length;
    final prefijoCuarto = t(context).prefijoCuarto;
    final prefijoProrroga = t(context).prefijoProrroga;
    final etiquetas = List.generate(
        numPeriodos,
        (i) => i < 4
            ? '$prefijoCuarto${i + 1}'
            : '$prefijoProrroga${i - 3}');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DataTable(
          columnSpacing: 24,
          headingRowHeight: 32,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 32,
          columns: [
            const DataColumn(label: Text('')),
            ...etiquetas.map((e) => DataColumn(label: Text(e), numeric: true)),
            DataColumn(label: Text(t(context).columnaTotal), numeric: true),
          ],
          rows: [
            _filaParciales(boxscore.equipoLocal, boxscore.parcialesLocal,
                boxscore.marcadorLocal),
            _filaParciales(boxscore.equipoVisitante, boxscore.parcialesVisitante,
                boxscore.marcadorVisitante),
          ],
        ),
      ),
    );
  }

  DataRow _filaParciales(String equipo, List<int> parciales, int total) {
    return DataRow(cells: [
      DataCell(Text(equipo, style: const TextStyle(fontWeight: FontWeight.bold))),
      ...parciales.map((p) => DataCell(Text('$p'))),
      DataCell(Text('$total', style: const TextStyle(fontWeight: FontWeight.bold))),
    ]);
  }
}

class _TablaEquipo extends StatelessWidget {
  final String nombreEquipo;
  final List<sim.EstadisticasJugador> stats;

  const _TablaEquipo({required this.nombreEquipo, required this.stats});

  @override
  Widget build(BuildContext context) {
    final ordenadas = [...stats]
      ..sort((a, b) => b.puntos.compareTo(a.puntos));
    // La barra lleva el color puro del equipo; el nombre, la versión que se
    // lee sobre el fondo del tema (hay azules marinos que en modo oscuro
    // desaparecían del todo).
    final colorEquipo = infoDe(nombreEquipo).colorPrimario;
    final colorTexto = colorLegibleComoTexto(colorEquipo, context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 20,
                  color: colorEquipo,
                  margin: const EdgeInsets.only(right: 8),
                ),
                Text(nombreEquipo,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorTexto)),
              ],
            ),
            const SizedBox(height: 8),
            // `DataTable` reparte el ancho según lo que ocupe cada celda, y
            // con un nombre largo en un teléfono se sale de la tarjeta. La
            // versión estrecha es la misma tabla hecha a mano: columnas
            // numéricas de ancho fijo y el nombre ocupando lo que sobre,
            // recortado con puntos suspensivos.
            if (tamanoDe(context).esCompacto)
              _TablaCompacta(ordenadas: ordenadas)
            else
              DataTable(
                columnSpacing: 20,
                columns: [
                  DataColumn(label: Text(t(context).columnaJugador)),
                  DataColumn(label: Text(t(context).columnaMin), numeric: true),
                  DataColumn(label: Text(t(context).columnaPts), numeric: true),
                  DataColumn(label: Text(t(context).columnaAst), numeric: true),
                  DataColumn(label: Text(t(context).columnaReb), numeric: true),
                ],
                rows: ordenadas.map((s) {
                  return DataRow(cells: [
                    DataCell(Text(s.nombreFicticio)),
                    DataCell(Text('${s.minutos}')),
                    DataCell(Text('${s.puntos}')),
                    DataCell(Text('${s.asistencias}')),
                    DataCell(Text('${s.rebotes}')),
                  ]);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

/// El boxscore de un equipo en pantalla estrecha: mismas columnas, pero con
/// anchos fijos para los números y el nombre quedándose con lo que sobre.
/// Cabe en un iPhone sin recortar ninguna estadística.
class _TablaCompacta extends StatelessWidget {
  final List<sim.EstadisticasJugador> ordenadas;

  const _TablaCompacta({required this.ordenadas});

  /// Suficiente para tres cifras: nadie mete 100 puntos, pero los minutos
  /// de una prórroga larga pasan de 50 y el ancho tiene que aguantarlo.
  static const _anchoNumero = 34.0;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;

    Widget fila(String nombre, List<String> valores,
        {required TextStyle estilo, TextStyle? estiloNombre}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(nombre,
                  overflow: TextOverflow.ellipsis,
                  style: estiloNombre ?? estilo),
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

    return Column(
      children: [
        fila(
          t(context).columnaJugador,
          [t(context).columnaMin, t(context).columnaPts,
              t(context).columnaAst, t(context).columnaReb],
          estilo: TextStyle(fontSize: 12, color: outline),
        ),
        const Divider(height: 1),
        for (final s in ordenadas)
          fila(
            s.nombreFicticio,
            [
              '${s.minutos}',
              '${s.puntos}',
              '${s.asistencias}',
              '${s.rebotes}',
            ],
            estilo: const TextStyle(fontSize: 13),
            estiloNombre: const TextStyle(fontSize: 13),
          ),
      ],
    );
  }
}
