import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/entrenadores_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/posiciones.dart';
import '../../shared/contraste.dart';
import '../../shared/estilo.dart';
import '../../i18n/textos.dart';
import '../../shared/entrenador_ui.dart';
import '../../shared/medias_jugador.dart';

/// Plantilla completa de un equipo antes de confirmarlo: nombre, posición
/// y media de cada jugador, con la opción de elegir ese equipo o volver a
/// la lista.
class TeamPreviewScreen extends StatelessWidget {
  final AppDatabase db;
  final String equipo;
  final VoidCallback onElegir;

  const TeamPreviewScreen({
    super.key,
    required this.db,
    required this.equipo,
    required this.onElegir,
  });

  Future<List<Jugador>> _cargarPlantilla() {
    return (db.select(db.jugadores)
          ..where((t) => t.equipo.equals(equipo))
          ..orderBy([(t) => OrderingTerm.desc(t.media)]))
        .get();
  }

  /// La media del quinteto, que es la misma cifra que enseña la rejilla de
  /// equipos. La de la plantilla entera diluye el equipo con el fondo del
  /// banquillo y sale un 70 para todo el mundo.
  int _mediaDelQuinteto(List<Jugador> plantilla) {
    if (plantilla.isEmpty) return 0;
    final mejores = plantilla.take(5);
    return (mejores.map((j) => j.media).reduce((a, b) => a + b) /
            mejores.length)
        .round();
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final info = infoDe(equipo);
    final textos = t(context);

    return Scaffold(
      backgroundColor: e.fondo,
      body: FutureBuilder<List<Jugador>>(
        future: _cargarPlantilla(),
        builder: (context, snapshot) {
          final plantilla = snapshot.data;
          return Column(
            children: [
              _CabeceraDeClub(
                equipo: equipo,
                info: info,
                media: plantilla == null ? null : _mediaDelQuinteto(plantilla),
              ),
              _EntrenadorDelEquipo(db: db, equipo: equipo),
              Expanded(
                child: plantilla == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                        itemCount: plantilla.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, i) =>
                            _FilaDeJugador(jugador: plantilla[i]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: BotonPerfilado(
                        texto: textos.volver,
                        color: e.textoTenue,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: BotonPrincipal(
                        texto: textos.elegirEsteEquipo,
                        color: acentoDeEquipo(
                            info.colorPrimario, info.colorSecundario),
                        alto: 50,
                        onTap: onElegir,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// La franja de identidad del club, con la media de su quinteto al lado:
/// aquí es donde se decide, así que la cifra que se compara va a la vista.
class _CabeceraDeClub extends StatelessWidget {
  final String equipo;
  final EquipoInfo info;
  final int? media;

  const _CabeceraDeClub({
    required this.equipo,
    required this.info,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    final fondo = info.colorPrimario;
    final sobre = textoSobre(fondo);
    final acento = acentoDeEquipo(fondo, info.colorSecundario);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [fondo, const Color(0xFF05070B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: 0, right: 0, child: CunaEsquina(color: acento)),
          Positioned(
            top: 4,
            right: -8,
            child: MonogramaFantasma(texto: equipo, tamano: 118),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 16),
              child: Row(
                children: [
                  BackButton(color: sobre),
                  PlacaEquipo(
                    codigo: equipo,
                    primario: info.colorPrimario,
                    secundario: info.colorSecundario,
                    tamano: 50,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mayus(info.ciudad),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.2,
                                color: acento)),
                        const SizedBox(height: 2),
                        Text(mayus(info.apodo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: familiaTitular,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                letterSpacing: -0.4,
                                color: sobre)),
                      ],
                    ),
                  ),
                  if (media != null) ...[
                    const SizedBox(width: 10),
                    Tooltip(
                      message: t(context).mediaDelEquipo(media!),
                      child: PlacaMedia(media: media!, tamano: 48),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Un jugador de la plantilla: su media como placa, y en qué es bueno.
class _FilaDeJugador extends StatelessWidget {
  final Jugador jugador;

  const _FilaDeJugador({required this.jugador});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return PanelCortado(
      fondo: e.panelSuave,
      corte: 10,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
        child: Row(
          children: [
            PlacaMedia(media: jugador.media, tamano: 38),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mayus(jugador.nombreFicticio),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titular(e, tamano: 16)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      MediasAtaqueDefensa.de(jugador, compacto: true),
                      Text(etiquetaPosicion(jugador),
                          style:
                              TextStyle(fontSize: 11, color: e.textoTenue)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quién dirige. Elegir equipo mirando solo la plantilla se deja fuera
/// medio proyecto: el entrenador vale unas seis victorias de 82 entre el
/// mejor y el peor, y además decide cuánto crecen tus jóvenes.
class _EntrenadorDelEquipo extends StatelessWidget {
  final AppDatabase db;
  final String equipo;

  const _EntrenadorDelEquipo({required this.db, required this.equipo});

  @override
  Widget build(BuildContext context) {
    final estilo = Estilo.de(context);
    return FutureBuilder<Entrenador?>(
      future: leerEntrenadorDe(db, equipo),
      builder: (context, snapshot) {
        final entrenador = snapshot.data;
        if (entrenador == null) return const SizedBox.shrink();
        final textos = t(context);
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: estilo.marcador,
            border: Border(bottom: BorderSide(color: estilo.linea)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 11),
          child: Row(
            children: [
              Icon(Icons.sports, size: 20, color: estilo.textoRotulo),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mayus(textos.entrenador),
                        style: rotulo(estilo, tamano: 9)),
                    const SizedBox(height: 1),
                    Text(mayus(entrenador.nombreFicticio),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titular(estilo, tamano: 16)),
                    const SizedBox(height: 2),
                    Text(
                      '${textos.edadJugador(entrenador.edad)} · '
                      '${etiquetaDeEstilo(textos, estiloDeEntrenador(ataque: entrenador.atrAtaque, defensa: entrenador.atrDefensa, desarrollo: entrenador.atrDesarrollo))}'
                      '${entrenador.anillos > 0 ? ' · ${textos.anillos(entrenador.anillos)}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: estilo.textoTenue),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              PlacaMedia(media: mediaDe(entrenador), tamano: 36),
            ],
          ),
        );
      },
    );
  }
}
