import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text('Temporada ${resumen.temporadaNueva}'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: EquipoLogo(codigoEquipo: equipoUsuario),
              title: Text(
                  'Arranca la temporada ${resumen.temporadaNueva} '
                  '(${resumen.anioInicio}-${resumen.anioInicio + 1})',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Tu plantilla ha cambiado: revísala antes del primer '
                  'partido — se ha dejado una alineación automática hecha.'),
            ),
          ),
          const SizedBox(height: 8),
          if (resumen.tusRookies.isNotEmpty)
            _Seccion(
              titulo: 'Tus elecciones del draft',
              icono: Icons.new_releases,
              hijos: resumen.tusRookies
                  .map((r) => _FilaRookie(rookie: r))
                  .toList(),
            ),
          if (resumen.retiradosPropios.isNotEmpty)
            _Seccion(
              titulo: 'Se retiran de tu equipo',
              icono: Icons.waving_hand,
              hijos: resumen.retiradosPropios
                  .map((c) => ListTile(
                        dense: true,
                        title: Text(c.nombre),
                        subtitle: Text('Cuelga las botas con ${c.edad} años '
                            'y media ${c.mediaAntes}'),
                      ))
                  .toList(),
            ),
          if (resumen.progresanTuyos.isNotEmpty)
            _Seccion(
              titulo: 'Han dado un paso adelante',
              icono: Icons.trending_up,
              hijos: resumen.progresanTuyos
                  .take(5)
                  .map((c) => _FilaCambio(cambio: c))
                  .toList(),
            ),
          if (resumen.declinanTuyos.isNotEmpty)
            _Seccion(
              titulo: 'Empiezan a bajar',
              icono: Icons.trending_down,
              hijos: resumen.declinanTuyos
                  .take(5)
                  .map((c) => _FilaCambio(cambio: c))
                  .toList(),
            ),
          if (resumen.mejoresDelDraft.isNotEmpty)
            _Seccion(
              titulo: 'Top del draft',
              icono: Icons.star,
              hijos: resumen.mejoresDelDraft
                  .map((r) => _FilaRookie(rookie: r, conEquipo: true))
                  .toList(),
            ),
          if (resumen.traspasosDeLaLiga.isNotEmpty)
            _Seccion(
              titulo: 'Movimientos en la liga',
              icono: Icons.swap_horiz,
              hijos: resumen.traspasosDeLaLiga
                  .map((t) => ListTile(
                        dense: true,
                        leading: EquipoLogo(codigoEquipo: t.equipoA, tamano: 24),
                        title: Text('${t.jugadorDeA} → ${t.equipoB}'),
                        subtitle: Text('${t.equipoA} recibe a ${t.jugadorDeB} '
                            '(${t.posicionDeB})'),
                      ))
                  .toList(),
            ),
          if (resumen.retiradosLiga.isNotEmpty)
            _Seccion(
              titulo: 'Se retiran en el resto de la liga',
              icono: Icons.exit_to_app,
              hijos: [
                ListTile(
                  dense: true,
                  title: Text(resumen.retiradosLiga
                      .take(12)
                      .map((c) => c.nombre)
                      .join(', ')),
                  subtitle: resumen.retiradosLiga.length > 12
                      ? Text('y ${resumen.retiradosLiga.length - 12} más')
                      : null,
                ),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinuar,
              child: const Text('Empezar la temporada'),
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
          Text('${rookie.posicion} · media ${rookie.media} · '),
          PotencialEstrellas(potencial: rookie.potencial, tamano: 12),
        ],
      ),
      trailing: conEquipo ? Text('#${rookie.numeroDeEleccion}') : null,
    );
  }
}
