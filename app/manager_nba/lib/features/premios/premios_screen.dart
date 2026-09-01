import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../domain/franquicia_repository.dart';
import '../../domain/premios_repository.dart';
import '../../domain/tipo_premio.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/estilo.dart';
import '../../shared/ficha_jugador.dart';
import '../../shared/navegacion.dart';
import '../calendario/calendario_screen.dart';

String _tituloPremio(BuildContext context, TipoPremio tipo) {
  return switch (tipo) {
    TipoPremio.mvp => t(context).premioMvp,
    TipoPremio.mejorDefensor => t(context).premioMejorDefensor,
    TipoPremio.rookieDelAno => t(context).premioRookieDelAno,
    TipoPremio.masMejorado => t(context).premioMasMejorado,
    TipoPremio.primerQuinteto => t(context).premioPrimerQuinteto,
    TipoPremio.segundoQuinteto => t(context).premioSegundoQuinteto,
    TipoPremio.mvpAllStar => t(context).premioMvpAllStar(t(context).allStar),
    TipoPremio.mvpRisingStars =>
      t(context).premioMvpRisingStars(t(context).risingStars),
    TipoPremio.allStar => t(context).allStar,
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
      appBar: barraDeClub(
          widget.equipoUsuario, t(context).tituloPremiosDeLaTemporada,
          acciones: const [BotonMenuPrincipal()]),
      body: FutureBuilder<_DatosDePremios>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                    t(context).noSePudieronCargarPremios('${snapshot.error}')),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final datos = snapshot.data!;
          final jugadoresPorId = datos.jugadoresPorId;
          final e = Estilo.de(context);
          final acento = infoDe(widget.equipoUsuario).colorPrimario;

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
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SeparadorSeccion(
                            titulo: _tituloPremio(context, tipo),
                            acento: acento),
                      ),
                      ...ganadores.map((g) {
                        final jugador = jugadoresPorId[g.jugadorId];
                        final stats = datos.statsPorJugador[g.jugadorId];
                        final equipo = jugador?.equipo;
                        final detalle = [
                          if (equipo != null) infoDe(equipo).nombreCompleto,
                          if (jugador != null) jugador.posicion,
                          if (stats != null) _lineaStats(context, stats),
                        ].where((s) => s.isNotEmpty).join(' · ');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: FilaDeJugador(
                            media: jugador?.media ?? 0,
                            nombre: jugador?.nombreFicticio ?? '—',
                            detalle: detalle,
                            // El escudo del equipo al que le dio el premio:
                            // saber de quién es cada estrella de un vistazo.
                            accesorio: equipo == null
                                ? Icon(Icons.emoji_events, color: e.marca)
                                : EquipoLogo(codigoEquipo: equipo, tamano: 32),
                          ),
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
                    child: Text(t(context).verCalendarioBtn),
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

String _lineaStats(BuildContext context, EstadisticasTemporadaJugadorData stats) {
  if (stats.partidosJugados == 0) return '';
  final pts = stats.puntosTotales / stats.partidosJugados;
  final ast = stats.asistenciasTotales / stats.partidosJugados;
  final reb = stats.rebotesTotales / stats.partidosJugados;
  return t(context).statsPremioLinea(pts.toStringAsFixed(1),
      ast.toStringAsFixed(1), reb.toStringAsFixed(1));
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
