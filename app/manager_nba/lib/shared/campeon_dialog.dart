import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/equipos_info.dart';
import 'confeti.dart';
import 'contraste.dart';
import 'equipo_logo.dart';

/// Aviso de que una competición ya tiene campeón, compartido entre los
/// playoffs (NBA) y la NBA Cup.
///
/// Si el campeón es tu equipo ([esTuEquipo]) el mensaje cambia por completo:
/// confeti, vibración y enhorabuena, no la nota informativa que sale cuando
/// el título se lo lleva otro. En los dos casos la cabecera va con el color
/// del equipo campeón y el texto en el tono que contrasta con él (ver
/// contraste.dart), para que se lea igual de bien en claro y oscuro.
///
/// [temporada] es el año de la temporada ("2027-28"), que es lo que convierte
/// el aviso en un titular de verdad; [detalle] cuelga debajo cualquier cosa
/// extra (el MVP de las Finales, por ejemplo). Si se pasa
/// [etiquetaAccionExtra], el diálogo enseña un botón más y devuelve `true`
/// cuando se pulsa.
Future<bool> mostrarCampeonDecidido(
  BuildContext context,
  String competicion,
  String campeon, {
  bool esTuEquipo = false,
  String? etiquetaAccionExtra,
  String? temporada,
  Widget? detalle,
}) async {
  if (esTuEquipo) {
    // En escritorio no hace nada; en un móvil, el anillo se nota.
    await HapticFeedback.heavyImpact();
  }
  if (!context.mounted) return false;
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => _DialogoCampeon(
      competicion: competicion,
      campeon: campeon,
      esTuEquipo: esTuEquipo,
      etiquetaAccionExtra: etiquetaAccionExtra,
      temporada: temporada,
      detalle: detalle,
    ),
  );
  return resultado ?? false;
}

/// "Campeones de la NBA", no "X es campeón de la NBA": el titular es del
/// equipo, en plural, como se dice de verdad.
String tituloDeCampeon(String competicion, {String? temporada}) {
  final base = 'Campeones de $competicion';
  return temporada == null ? base : '$base $temporada';
}

class _DialogoCampeon extends StatelessWidget {
  final String competicion;
  final String campeon;
  final bool esTuEquipo;
  final String? etiquetaAccionExtra;
  final String? temporada;
  final Widget? detalle;

  const _DialogoCampeon({
    required this.competicion,
    required this.campeon,
    required this.esTuEquipo,
    this.etiquetaAccionExtra,
    this.temporada,
    this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    final info = infoDe(campeon);
    final fondo = info.colorPrimario;
    final sobreFondo = textoSobre(fondo);
    final nombre =
        info.nombreCompleto.trim().isEmpty ? campeon : info.nombreCompleto;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [fondo, info.colorSecundario],
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events,
                          size: esTuEquipo ? 64 : 48, color: sobreFondo),
                      const SizedBox(height: 12),
                      Text(
                        esTuEquipo
                            ? '¡CAMPEONES!'
                            : tituloDeCampeon(competicion,
                                temporada: temporada),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: sobreFondo,
                          fontSize: esTuEquipo ? 30 : 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: esTuEquipo ? 2 : 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        esTuEquipo
                            ? tituloDeCampeon(competicion, temporada: temporada)
                            : nombre,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: textoSecundarioSobre(fondo), fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      EquipoLogo(codigoEquipo: campeon, tamano: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nombre,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              esTuEquipo
                                  ? '¡Enhorabuena! Lo has conseguido: el anillo '
                                      'es vuestro. La próxima temporada toca '
                                      'defenderlo.'
                                  : '$nombre se lleva el título.',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (detalle != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: detalle!,
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (etiquetaAccionExtra != null)
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(etiquetaAccionExtra!),
                        ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(esTuEquipo ? '¡A celebrarlo!' : 'Cerrar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (esTuEquipo)
              Positioned.fill(
                child: LluviaDeConfeti(
                  colores: [info.colorPrimario, info.colorSecundario],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// El MVP de las Finales con sus medias de la serie, para colgarlo del
/// diálogo del campeón.
class TarjetaMvpDeFinales extends StatelessWidget {
  final String nombre;
  final String equipo;
  final int partidos;
  final double puntos;
  final double asistencias;
  final double rebotes;

  const TarjetaMvpDeFinales({
    super.key,
    required this.nombre,
    required this.equipo,
    required this.partidos,
    required this.puntos,
    required this.asistencias,
    required this.rebotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A017).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.military_tech, color: Color(0xFFD4A017), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MVP de las Finales · $nombre',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${puntos.toStringAsFixed(1)} pts · '
                  '${asistencias.toStringAsFixed(1)} ast · '
                  '${rebotes.toStringAsFixed(1)} reb '
                  'en $partidos ${partidos == 1 ? "partido" : "partidos"}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          EquipoLogo(codigoEquipo: equipo, tamano: 24),
        ],
      ),
    );
  }
}

/// Banner fijo de "esta competición ya tiene campeón", el que se queda en
/// la pantalla del bracket. Mismo criterio de contraste que el diálogo.
class BannerCampeon extends StatelessWidget {
  final String competicion;
  final String campeon;
  final bool esTuEquipo;
  final String? temporada;

  const BannerCampeon({
    super.key,
    required this.competicion,
    required this.campeon,
    this.esTuEquipo = false,
    this.temporada,
  });

  @override
  Widget build(BuildContext context) {
    final info = infoDe(campeon);
    final fondo = info.colorPrimario;
    final sobreFondo = textoSobre(fondo);
    final nombre =
        info.nombreCompleto.trim().isEmpty ? campeon : info.nombreCompleto;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [fondo, info.colorSecundario],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, color: sobreFondo),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombre,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: sobreFondo),
                ),
                Text(
                  tituloDeCampeon(competicion, temporada: temporada),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: textoSecundarioSobre(fondo)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
