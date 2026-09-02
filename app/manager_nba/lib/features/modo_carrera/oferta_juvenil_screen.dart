import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/modo_carrera_repository.dart';
import '../../i18n/textos.dart';
import '../../shared/estilo.dart';

/// Tres organizaciones de tu país quieren sumarte a su proyecto juvenil.
/// Igual que la elección de club de Copero, pero con lo que ya usa
/// `rutas_juveniles.dart`: clubes de cantera, universidades o academias
/// según el país.
class OfertaJuvenilScreen extends StatefulWidget {
  final AppDatabase db;
  final EstadoCarrera estado;
  final void Function(EstadoCarrera estado) onElegida;

  const OfertaJuvenilScreen({
    super.key,
    required this.db,
    required this.estado,
    required this.onElegida,
  });

  @override
  State<OfertaJuvenilScreen> createState() => _OfertaJuvenilScreenState();
}

class _OfertaJuvenilScreenState extends State<OfertaJuvenilScreen> {
  bool _eligiendo = false;

  Future<void> _elegir(String organizacion) async {
    if (_eligiendo) return;
    setState(() => _eligiendo = true);
    await elegirOrganizacionJuvenil(widget.db, organizacion);
    if (!mounted) return;
    final estado = await leerPartidaCarrera(widget.db);
    if (!mounted || estado == null) return;
    widget.onElegida(estado);
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final ofertas = ofertasJuvenilesIniciales(widget.estado.nacionalidad);

    return Scaffold(
      backgroundColor: e.fondo,
      appBar: BarraNeutraAppBar(
        titulo: textos.ofertaJuvenilTitulo,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  textos.ofertaJuvenilDescripcion,
                  style: TextStyle(fontSize: 14, color: e.textoTenue),
                ),
                const SizedBox(height: 20),
                for (final organizacion in ofertas) ...[
                  PanelCortado(
                    fondo: e.panel,
                    corte: 12,
                    borde: Border.all(color: e.linea),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(organizacion, style: titular(e, tamano: 19)),
                          const SizedBox(height: 12),
                          BotonPrincipal(
                            texto: textos.ficharPorBtn(organizacion),
                            color: colorModoCarrera,
                            alto: 44,
                            onTap:
                                _eligiendo ? null : () => _elegir(organizacion),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
