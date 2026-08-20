import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/campeones_repository.dart';
import '../../domain/equipos_especiales.dart';
import '../../domain/equipos_info.dart';
import '../../i18n/textos.dart';
import '../../shared/contraste.dart';
import '../../shared/estilo.dart';
import '../../shared/pantalla.dart';
import 'team_preview_screen.dart';

class _FilaEquipo {
  final String codigo;
  final double media;
  final bool tieneTituloIst;
  final bool tieneTituloNba;

  const _FilaEquipo({
    required this.codigo,
    required this.media,
    required this.tieneTituloIst,
    required this.tieneTituloNba,
  });
}

/// Lista de los 30 equipos disponibles: logo, nombre completo, media del
/// equipo y los dos huecos de trofeo (torneo de mitad de temporada / NBA),
/// rellenos si ese equipo ya ganó ese título alguna vez (aunque sea en una
/// franquicia anterior, o en otra partida guardada: el palmarés es tuyo, no
/// de la ranura). Tocar un equipo abre su plantilla antes de confirmar.
class TeamSelectorScreen extends StatelessWidget {
  final AppDatabase db;
  final String titulo;
  final void Function(String equipo) onSeleccionado;

  const TeamSelectorScreen({
    super.key,
    required this.db,
    required this.titulo,
    required this.onSeleccionado,
  });

  Future<List<_FilaEquipo>> _cargarEquipos() async {
    final jugadores = await db.select(db.jugadores).get();
    final porEquipo = <String, List<Jugador>>{};
    for (final j in jugadores) {
      if (!esFranquicia(j.equipo)) continue;
      porEquipo.putIfAbsent(j.equipo, () => []).add(j);
    }

    // Solo los títulos que has ganado tú dirigiendo ese equipo: si la CPU
    // gana el anillo con los Lakers, ese trofeo no es tuyo y el hueco sigue
    // vacío al empezar una partida nueva.
    final conIst = await equiposConTituloDelUsuario('ist');
    final conNba = await equiposConTituloDelUsuario('nba');

    const jugadoresTitulares = 5;
    final filas = porEquipo.entries.map((entry) {
      // Media de los 5 titulares (los mejores), no de toda la plantilla:
      // el resto del roster son suplentes que apenas juegan y bajaban la
      // media de todos los equipos por igual sin reflejar el quinteto real.
      final ordenados = [...entry.value]..sort((a, b) => b.media.compareTo(a.media));
      final rotacion = ordenados.take(jugadoresTitulares).toList();
      final media =
          rotacion.map((j) => j.media).reduce((a, b) => a + b) / rotacion.length;
      return _FilaEquipo(
        codigo: entry.key,
        media: media,
        tieneTituloIst: conIst.contains(entry.key),
        tieneTituloNba: conNba.contains(entry.key),
      );
    }).toList()
      ..sort((a, b) => infoDe(a.codigo).nombreCompleto.compareTo(infoDe(b.codigo).nombreCompleto));

    return filas;
  }

  /// Cuántas fichas caben por fila. Los cortes son los de siempre
  /// (`shared/pantalla.dart`): dos con el móvil en vertical, tres en tablet
  /// y cinco en una ventana de escritorio.
  int _columnas(BuildContext context) => switch (tamanoDe(context)) {
        Tamano.compacto => 2,
        Tamano.medio => 3,
        Tamano.amplio => 5,
      };

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);

    return Scaffold(
      backgroundColor: e.fondo,
      body: Column(
        children: [
          _CabeceraSimple(titulo: titulo),
          Expanded(
            child: FutureBuilder<List<_FilaEquipo>>(
              future: _cargarEquipos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final equipos = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _columnas(context),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    // Alto fijo en vez de proporción: así la ficha mide lo
                    // que necesita su contenido y no lo que salga de dividir
                    // el ancho, que a dos columnas daba fichas altísimas.
                    mainAxisExtent: 150,
                  ),
                  itemCount: equipos.length,
                  itemBuilder: (context, i) => _FichaDeEquipo(
                    fila: equipos[i],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TeamPreviewScreen(
                        db: db,
                        equipo: equipos[i].codigo,
                        onElegir: () => onSeleccionado(equipos[i].codigo),
                      ),
                    )),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera de las pantallas que todavía no tienen club: franja oscura con
/// el acento del juego y el título en grande.
class _CabeceraSimple extends StatelessWidget {
  final String titulo;

  const _CabeceraSimple({required this.titulo});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: e.marcador,
        border: Border(bottom: BorderSide(color: e.marca, width: 2)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 16, 14),
          child: Row(
            children: [
              BackButton(color: e.texto),
              Expanded(
                child: Text(
                  mayus(titulo),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: familiaTitular,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.04,
                    color: e.texto,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un equipo: su color, su monograma, la media de su quinteto y los dos
/// huecos de trofeo.
class _FichaDeEquipo extends StatelessWidget {
  final _FilaEquipo fila;
  final VoidCallback onTap;

  const _FichaDeEquipo({required this.fila, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final info = infoDe(fila.codigo);
    final acento = acentoDeEquipo(info.colorPrimario, info.colorSecundario);
    final textos = t(context);

    return PanelCortado(
      fondo: e.panel,
      corte: 14,
      borde: Border.all(color: e.linea),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // La franja del club, con la media encima: es lo que se
              // compara de un equipo a otro.
              Container(
                height: 62,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [info.colorPrimario, const Color(0xFF05070B)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -8,
                      right: -6,
                      child: MonogramaFantasma(
                          texto: fila.codigo, tamano: 74, opacidad: 0.07),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: [
                          PlacaEquipo(
                            codigo: fila.codigo,
                            primario: info.colorPrimario,
                            secundario: info.colorSecundario,
                            tamano: 34,
                          ),
                          const Spacer(),
                          Tooltip(
                            message: textos.mediaDelEquipo(fila.media.round()),
                            child:
                                PlacaMedia(media: fila.media.round(), tamano: 38),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mayus(info.ciudad),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: rotulo(e, tamano: 9, color: acento)),
                      const SizedBox(height: 2),
                      Text(mayus(info.apodo),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titular(e, tamano: 17)),
                      const Spacer(),
                      // Los dos huecos de trofeo: apagados si nunca has
                      // ganado ese título dirigiendo a este club.
                      Row(
                        children: [
                          _Trofeo(
                            icono: Icons.military_tech,
                            ganado: fila.tieneTituloIst,
                            color: const Color(0xFF5B9BE5),
                            mensaje: textos.torneoDeMitadDeTemporada,
                          ),
                          const SizedBox(width: 6),
                          _Trofeo(
                            icono: Icons.emoji_events,
                            ganado: fila.tieneTituloNba,
                            color: const Color(0xFFE0A81E),
                            mensaje: textos.campeonNba,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Trofeo extends StatelessWidget {
  final IconData icono;
  final bool ganado;
  final Color color;
  final String mensaje;

  const _Trofeo({
    required this.icono,
    required this.ganado,
    required this.color,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Tooltip(
      message: mensaje,
      child: Icon(icono,
          size: 19,
          color: ganado
              ? colorLegibleComoTexto(color, context)
              : e.textoRotulo.withValues(alpha: 0.35)),
    );
  }
}
