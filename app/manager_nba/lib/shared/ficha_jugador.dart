import 'package:flutter/material.dart';

import 'estilo.dart';

/// Un jugador en una lista: su media como placa de color, el nombre en
/// grande y lo que haga falta a la derecha.
///
/// Vive aquí porque media docena de pantallas listan jugadores —agencia
/// libre, draft, traspasos, ofertas, retirados— y cada una se lo montaba
/// con su propio `ListTile`. El resultado era que el mismo jugador se veía
/// distinto según por dónde llegaras a él, y que la media, que es EL dato
/// con el que se decide, iba escondida en el subtítulo.
class FilaDeJugador extends StatelessWidget {
  final int media;
  final String nombre;

  /// La línea de debajo: posición, edad, equipo… lo que sitúe al jugador
  /// en esa pantalla concreta.
  final String detalle;

  /// Lo que esa pantalla añada bajo el detalle: las estrellas de potencial
  /// en el draft, las medias de ataque y defensa en el mercado.
  final Widget? bajoElNombre;

  /// Lo de la derecha: un precio y su botón, un chevron, un aviso.
  final Widget? accesorio;

  final VoidCallback? onTap;

  /// Para quien no está disponible (lesionado, ya no negocia): se apaga sin
  /// desaparecer, porque sigue habiendo que saber quién es y lo bueno que
  /// es.
  final bool apagado;

  const FilaDeJugador({
    super.key,
    required this.media,
    required this.nombre,
    required this.detalle,
    this.bajoElNombre,
    this.accesorio,
    this.onTap,
    this.apagado = false,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);

    return Opacity(
      opacity: apagado ? 0.55 : 1,
      child: PanelCortado(
        fondo: e.panelSuave,
        corte: 10,
        borde: Border.all(color: e.linea),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              child: Row(
                children: [
                  PlacaMedia(media: media, tamano: 40),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mayus(nombre),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titular(e, tamano: 16)),
                        const SizedBox(height: 2),
                        Text(detalle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 11.5, color: e.textoTenue)),
                        if (bajoElNombre != null) ...[
                          const SizedBox(height: 5),
                          // Encogiendo antes que desbordar: lo que va aquí
                          // son etiquetas de ancho fijo (ATA/DEF, estrellas
                          // de potencial) y en un móvil, con un precio y un
                          // botón a la derecha, la columna se queda en nada.
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: bajoElNombre!,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (accesorio != null) ...[
                    const SizedBox(width: 10),
                    accesorio!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
