import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../domain/draft_repository.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/progresion_repository.dart';
import '../../domain/traspasos_cpu_repository.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/estilo.dart';
import '../../shared/ficha_jugador.dart';
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
    final e = Estilo.de(context);
    return Scaffold(
      appBar: barraDeClub(
          equipoUsuario, t(context).temporadaN(resumen.temporadaNueva),
          conVolver: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PanelCortado(
            fondo: e.panel,
            corte: 14,
            borde: Border.all(color: e.linea),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  EquipoLogo(codigoEquipo: equipoUsuario, tamano: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            mayus(t(context).arrancaLaTemporada(
                                resumen.temporadaNueva, resumen.anioInicio,
                                resumen.anioInicio + 1)),
                            style: titular(e, tamano: 17)),
                        const SizedBox(height: 3),
                        Text(t(context).plantillaHaCambiadoAviso,
                            style:
                                TextStyle(fontSize: 12, color: e.textoTenue)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                  .map((c) => FilaDeJugador(
                        media: c.mediaAntes,
                        nombre: c.nombre,
                        detalle: t(context).cuelgaLasBotasCon(c.edad, c.mediaAntes),
                        apagado: true,
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
                  .map((mov) => _FilaMovimiento(mov: mov))
                  .toList(),
            ),
          if (resumen.retiradosLiga.isNotEmpty)
            _Seccion(
              titulo: t(context).tambienSeRetiran,
              icono: Icons.exit_to_app,
              hijos: [_FilaRetiradosLiga(retirados: resumen.retiradosLiga)],
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
    final e = Estilo.de(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 15, color: e.marca),
              const SizedBox(width: 8),
              Expanded(child: SeparadorSeccion(titulo: titulo, acento: e.marca)),
            ],
          ),
          const SizedBox(height: 10),
          for (final hijo in hijos) ...[
            hijo,
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _FilaCambio extends StatelessWidget {
  final CambioDeJugador cambio;

  const _FilaCambio({required this.cambio});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final sube = cambio.delta > 0;
    return FilaDeJugador(
      media: cambio.mediaDespues,
      nombre: cambio.nombre,
      detalle: '${cambio.mediaAntes} → ${cambio.mediaDespues}',
      accesorio: Text(
        '${sube ? '+' : ''}${cambio.delta}',
        style: titular(e, tamano: 16, color: sube ? e.bien : e.mal),
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
    final e = Estilo.de(context);
    return FilaDeJugador(
      media: rookie.media,
      nombre: rookie.nombre,
      detalle: rookie.posicion,
      bajoElNombre: PotencialEstrellas(potencial: rookie.potencial, tamano: 12),
      accesorio: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (conEquipo) ...[
            EquipoLogo(codigoEquipo: rookie.equipo, tamano: 22),
            const SizedBox(width: 6),
          ],
          Text('#${rookie.numeroDeEleccion}', style: titular(e, tamano: 14)),
        ],
      ),
    );
  }
}

/// Un traspaso cerrado entre dos equipos de la CPU: quién manda a quién y a
/// cambio de qué. No hay una única media que representar (son dos jugadores
/// de dos equipos distintos), así que va sin `PlacaMedia`, con el mismo
/// panel cortado que el resto de filas de esta pantalla.
class _FilaMovimiento extends StatelessWidget {
  final TraspasoDeLaCpu mov;

  const _FilaMovimiento({required this.mov});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return PanelCortado(
      fondo: e.panelSuave,
      corte: 10,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
        child: Row(
          children: [
            EquipoLogo(codigoEquipo: mov.equipoA, tamano: 26),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${mov.jugadorDeA} → ${mov.equipoB}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titular(e, tamano: 15)),
                  const SizedBox(height: 2),
                  Text(
                      t(context).recibeA(
                          mov.equipoA, mov.jugadorDeB, mov.posicionDeB),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: e.textoTenue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Los que se retiran del resto de la liga: demasiados como para darles una
/// fila cada uno, así que van en un único bloque con sus nombres.
class _FilaRetiradosLiga extends StatelessWidget {
  final List<CambioDeJugador> retirados;

  const _FilaRetiradosLiga({required this.retirados});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final restantes = retirados.length - 12;
    return PanelCortado(
      fondo: e.panelSuave,
      corte: 10,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(retirados.take(12).map((c) => c.nombre).join(', '),
                style: TextStyle(fontSize: 13, color: e.texto)),
            if (restantes > 0) ...[
              const SizedBox(height: 4),
              Text(t(context).yNMas(restantes), style: rotulo(e, tamano: 10)),
            ],
          ],
        ),
      ),
    );
  }
}
