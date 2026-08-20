import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../domain/draft_repository.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/progresion_repository.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/potencial_estrellas.dart';

/// Resumen de lo que ha cambiado al pasar de año: quién se ha retirado,
/// quién ha dado un salto (o lo contrario) y qué rookies te ha traído el
/// draft. Es la pantalla que cierra una temporada y abre la siguiente.
class PretemporadaScreen extends StatelessWidget {
  final ResumenPretemporada resumen;
  final String equipoUsuario;
  final VoidCallback onContinuar;

  const PretemporadaScreen({
    super.key,
    required this.resumen,
    required this.equipoUsuario,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraDeClub(
          equipoUsuario, t(context).temporadaN(resumen.temporadaNueva),
          conVolver: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: EquipoLogo(codigoEquipo: equipoUsuario),
              title: Text(
                  t(context).arrancaLaTemporada(resumen.temporadaNueva,
                      resumen.anioInicio, resumen.anioInicio + 1),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(t(context).plantillaHaCambiadoAviso),
            ),
          ),
          const SizedBox(height: 8),
          if (resumen.tusRookies.isNotEmpty)
            _Seccion(
              titulo: t(context).tusEleccionesDelDraft,
              icono: Icons.new_releases,
              hijos: resumen.tusRookies
                  .map((r) => _FilaRookie(rookie: r))
                  .toList(),
            ),
          if (resumen.retiradosPropios.isNotEmpty)
            _Seccion(
              titulo: t(context).seRetiranDeTuEquipo,
              icono: Icons.waving_hand,
              hijos: resumen.retiradosPropios
                  .map((c) => ListTile(
                        dense: true,
                        title: Text(c.nombre),
                        subtitle: Text(
                            t(context).cuelgaLasBotasCon(c.edad, c.mediaAntes)),
                      ))
                  .toList(),
            ),
          if (resumen.progresanTuyos.isNotEmpty)
            _Seccion(
              titulo: t(context).hanDadoUnPasoAdelante,
              icono: Icons.trending_up,
              hijos: resumen.progresanTuyos
                  .take(5)
                  .map((c) => _FilaCambio(cambio: c))
                  .toList(),
            ),
          if (resumen.declinanTuyos.isNotEmpty)
            _Seccion(
              titulo: t(context).empiezanABajar,
              icono: Icons.trending_down,
              hijos: resumen.declinanTuyos
                  .take(5)
                  .map((c) => _FilaCambio(cambio: c))
                  .toList(),
            ),
          if (resumen.mejoresDelDraft.isNotEmpty)
            _Seccion(
              titulo: t(context).topDelDraft,
              icono: Icons.star,
              hijos: resumen.mejoresDelDraft
                  .map((r) => _FilaRookie(rookie: r, conEquipo: true))
                  .toList(),
            ),
          if (resumen.traspasosDeLaLiga.isNotEmpty)
            _Seccion(
              titulo: t(context).movimientosEnLaLiga,
              icono: Icons.swap_horiz,
              hijos: resumen.traspasosDeLaLiga
                  .map((mov) => ListTile(
                        dense: true,
                        leading:
                            EquipoLogo(codigoEquipo: mov.equipoA, tamano: 24),
                        title: Text('${mov.jugadorDeA} → ${mov.equipoB}'),
                        subtitle: Text(t(context).recibeA(
                            mov.equipoA, mov.jugadorDeB, mov.posicionDeB)),
                      ))
                  .toList(),
            ),
          if (resumen.retiradosLiga.isNotEmpty)
            _Seccion(
              titulo: t(context).tambienSeRetiran,
              icono: Icons.exit_to_app,
              hijos: [
                ListTile(
                  dense: true,
                  title: Text(resumen.retiradosLiga
                      .take(12)
                      .map((c) => c.nombre)
                      .join(', ')),
                  subtitle: resumen.retiradosLiga.length > 12
                      ? Text(t(context)
                          .yNMas(resumen.retiradosLiga.length - 12))
                      : null,
                ),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinuar,
              child: Text(t(context).empezarLaTemporadaBtn),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> hijos;

  const _Seccion({
    required this.titulo,
    required this.icono,
    required this.hijos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 20),
                const SizedBox(width: 8),
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            ...hijos,
          ],
        ),
      ),
    );
  }
}

class _FilaCambio extends StatelessWidget {
  final CambioDeJugador cambio;

  const _FilaCambio({required this.cambio});

  @override
  Widget build(BuildContext context) {
    final sube = cambio.delta > 0;
    return ListTile(
      dense: true,
      title: Text(cambio.nombre),
      trailing: Text(
        '${cambio.mediaAntes} → ${cambio.mediaDespues} '
        '(${sube ? '+' : ''}${cambio.delta})',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: sube ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

class _FilaRookie extends StatelessWidget {
  final RookieElegido rookie;
  final bool conEquipo;

  const _FilaRookie({required this.rookie, this.conEquipo = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: conEquipo
          ? EquipoLogo(codigoEquipo: rookie.equipo, tamano: 24)
          : CircleAvatar(
              radius: 14,
              child: Text('${rookie.numeroDeEleccion}',
                  style: const TextStyle(fontSize: 11))),
      title: Text(rookie.nombre),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t(context).posicionMediaSeparador(
              rookie.posicion, rookie.media)),
          PotencialEstrellas(potencial: rookie.potencial, tamano: 12),
        ],
      ),
      trailing: conEquipo ? Text('#${rookie.numeroDeEleccion}') : null,
    );
  }
}
