import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/franquicia_repository.dart';
import '../../domain/premios_repository.dart';
import '../../domain/tipo_premio.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/navegacion.dart';
import '../calendario/calendario_screen.dart';

String _tituloPremio(TipoPremio tipo) {
  return switch (tipo) {
    TipoPremio.mvp => 'MVP',
    TipoPremio.mejorDefensor => 'Mejor Defensor',
    TipoPremio.rookieDelAno => 'Rookie del Año',
    TipoPremio.masMejorado => 'Jugador Más Mejorado',
    TipoPremio.primerQuinteto => 'Primer Quinteto',
    TipoPremio.segundoQuinteto => 'Segundo Quinteto',
    TipoPremio.mvpAllStar => 'MVP del All-Star',
    TipoPremio.mvpRisingStars => 'MVP del Rising Stars',
  };
}

/// Lo que hace falta para pintar los premios, leído de una sola vez.
class _DatosDePremios {
  final Map<TipoPremio, List<PremiosTemporadaData>> premios;
  final Map<int, Jugador> jugadoresPorId;
  final Map<int, EstadisticasTemporadaJugadorData> statsPorJugador;

  const _DatosDePremios({
    required this.premios,
    required this.jugadoresPorId,
    required this.statsPorJugador,
  });
}

/// Premios de fin de temporada regular, ya calculados (se accede a esta
/// pantalla solo cuando tu temporada de 82 partidos está completa).
class PremiosScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  /// true cuando se llega aquí encadenado desde el Calendario (simular ->
  /// resumen -> premios): en ese caso "Ver calendario" vuelve al que ya
  /// está abierto en vez de apilar uno nuevo encima.
  final bool calendarioEnPila;

  const PremiosScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    this.calendarioEnPila = false,
  });

  @override
  State<PremiosScreen> createState() => _PremiosScreenState();
}

class _PremiosScreenState extends State<PremiosScreen> {
  // Una sola carga, guardada: antes eran tres FutureBuilder anidados con el
  // futuro creado dentro de `build`, así que cada repintado relanzaba las
  // tres consultas (y dos de ellas leen tablas enteras).
  late final Future<_DatosDePremios> _futuro = _cargar();

  Future<_DatosDePremios> _cargar() async {
    final db = widget.db;
    final premios = await leerPremios(db);
    final jugadores = await db.select(db.jugadores).get();
    final stats = await db.select(db.estadisticasTemporadaJugador).get();
    return _DatosDePremios(
      premios: premios,
      jugadoresPorId: {for (final j in jugadores) j.id: j},
      statsPorJugador: {for (final s in stats) s.jugadorId: s},
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = widget.db;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premios de la temporada'),
        actions: const [BotonMenuPrincipal()],
      ),
      body: FutureBuilder<_DatosDePremios>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se han podido cargar los premios.\n'
                    '${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final datos = snapshot.data!;
          final jugadoresPorId = datos.jugadoresPorId;

          // Los del fin de semana de las estrellas van al final: se
          // ganaron en febrero, pero son premios de esta temporada.
          const orden = [
            ...premiosDeFinDeTemporadaRegular,
            TipoPremio.mvpAllStar,
            TipoPremio.mvpRisingStars,
          ];

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: orden.expand((tipo) {
                    var ganadores = datos.premios[tipo] ?? [];
                    if (ganadores.isEmpty) return <Widget>[];
                    if (tipo == TipoPremio.primerQuinteto ||
                        tipo == TipoPremio.segundoQuinteto) {
                      ganadores =
                          _ordenadosPorPosicion(ganadores, jugadoresPorId);
                    }
                    return [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(_tituloPremio(tipo),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ...ganadores.map((g) {
                        final jugador = jugadoresPorId[g.jugadorId];
                        final stats = datos.statsPorJugador[g.jugadorId];
                        final equipo = jugador?.equipo;
                        return ListTile(
                          // El escudo del equipo al que le dio el premio:
                          // saber de quién es cada estrella de un vistazo.
                          leading: equipo == null
                              ? const Icon(Icons.emoji_events,
                                  color: Colors.amber)
                              : EquipoLogo(codigoEquipo: equipo, tamano: 36),
                          title: Text(jugador?.nombreFicticio ?? '—'),
                          subtitle: Text(
                              '${equipo == null ? '' : infoDe(equipo).nombreCompleto}'
                              '${jugador != null ? ' · ${jugador.posicion}' : ''}'
                              '${stats != null ? ' · ${_lineaStats(stats)}' : ''}'),
                        );
                      }),
                    ];
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => widget.calendarioEnPila
                        ? volverAlCalendario(context)
                        : Navigator.of(context).push(MaterialPageRoute(
                            settings: const RouteSettings(
                                name: RutasPrincipales.calendario),
                            builder: (context) => CalendarioScreen(
                                db: db, equipoUsuario: widget.equipoUsuario),
                          )),
                    child: const Text('Ver calendario'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _lineaStats(EstadisticasTemporadaJugadorData stats) {
  if (stats.partidosJugados == 0) return '';
  final pts = stats.puntosTotales / stats.partidosJugados;
  final ast = stats.asistenciasTotales / stats.partidosJugados;
  final reb = stats.rebotesTotales / stats.partidosJugados;
  return '${pts.toStringAsFixed(1)} pts, ${ast.toStringAsFixed(1)} ast, '
      '${reb.toStringAsFixed(1)} reb';
}

/// Los quintetos se calculan por puntuación combinada, pero se muestran en
/// orden de puesto (Base, Escolta, Alero, Ala-pívot, Pívot).
List<PremiosTemporadaData> _ordenadosPorPosicion(
  List<PremiosTemporadaData> ganadores,
  Map<int, Jugador> jugadoresPorId,
) {
  int indicePosicion(PremiosTemporadaData g) {
    final posicion = jugadoresPorId[g.jugadorId]?.posicion;
    final indice = posicionesEquipo.indexOf(posicion ?? '');
    return indice == -1 ? posicionesEquipo.length : indice;
  }

  final ordenados = [...ganadores]
    ..sort((a, b) => indicePosicion(a).compareTo(indicePosicion(b)));
  return ordenados;
}
