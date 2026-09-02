import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/estilo.dart';
import '../../data/database/app_database.dart';
import '../../domain/equipos_info.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/icono_camiseta.dart';
import '../../shared/pantalla.dart';

/// Las camisetas que la liga ha colgado del techo este verano, a pantalla
/// completa.
///
/// Antes era un diálogo, y colgar un dorsal para siempre es de las cosas
/// grandes que le pueden pasar a un jugador: se merece la misma pantalla que
/// el Hall of Fame, no un cuadro pequeño que se cierra sin mirar. Además,
/// una leyenda de varias franquicias trae varias filas y en un diálogo no
/// caben (ver equiposQueRetiranCamisetaReal).
class CamisetasNuevasScreen extends StatelessWidget {
  final List<CamisetaRetirada> nuevas;
  final VoidCallback onContinuar;

  const CamisetasNuevasScreen({
    super.key,
    required this.nuevas,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final unaSola = nuevas.length == 1;

    // Agrupadas por jugador: quien cuelga en tres sitios sale una vez con sus
    // tres equipos debajo, no tres veces suelto.
    final porJugador = <String, List<CamisetaRetirada>>{};
    for (final c in nuevas) {
      (porJugador[c.nombreJugador] ??= []).add(c);
    }

    return Scaffold(
      appBar: BarraNeutraAppBar(
        titulo: unaSola
            ? t(context).camisetaRetiradaSingular
            : t(context).pestanaCamisetasRetiradas,
        conVolver: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(tamanoDe(context).esCompacto ? 12 : 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                const IconoCamisetaRetirada(tamano: 56, color: Colors.amber),
                const SizedBox(height: 12),
                Text(
                  unaSola
                      ? t(context).unDorsalQueNoVolvera
                      : t(context).dorsalesQueNoVolveran,
                  textAlign: TextAlign.center,
                  style: titular(e, tamano: 16),
                ),
              ],
            ),
          ),
          for (final entrada in porJugador.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PanelCortado(
                fondo: e.panel,
                corte: 12,
                borde: Border.all(color: e.linea),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entrada.key, style: titular(e, tamano: 16)),
                      const SizedBox(height: 10),
                      for (final c in entrada.value)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              EquipoLogo(codigoEquipo: c.equipo, tamano: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(nombreDeEquipoEnFicha(c.equipo),
                                    style: rotulo(e, tamano: 12)),
                              ),
                              Text('#${c.dorsal}', style: cifra(e, tamano: 20)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onContinuar,
              child: Text(t(context).continuar),
            ),
          ),
        ),
      ),
    );
  }
}
