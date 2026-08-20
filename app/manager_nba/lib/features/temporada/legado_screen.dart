import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../data/database/app_database.dart';
import '../../shared/icono_camiseta.dart';
import 'camisetas_retiradas_screen.dart';
import 'hall_fama_screen.dart';
import 'lideres_historicos_screen.dart';

/// El legado de tu liga en un solo sitio: quién ha entrado en el Hall of
/// Fame, qué camisetas se han retirado y quién manda en los totales
/// históricos. Eran entradas de menú sueltas que contaban lo mismo desde
/// ángulos distintos, así que ahora son pestañas de la misma pantalla.
class LegadoScreen extends StatelessWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const LegadoScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: barraDeClub(
          equipoUsuario,
          t(context).tituloLegado,
          acciones: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: t(context).explicacionPuntuacionCarreraTooltip,
              onPressed: () => mostrarExplicacionPuntuacionHof(context),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.military_tech), text: t(context).hallOfFame),
              Tab(
                icon: const IconoCamisetaRetirada(tamano: 24),
                text: t(context).pestanaCamisetasRetiradas,
              ),
              Tab(icon: const Icon(Icons.leaderboard), text: t(context).pestanaLideresHistoricos),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HallDeLaFamaBody(db: db),
            CamisetasRetiradasBody(db: db, equipoUsuario: equipoUsuario),
            LideresHistoricosBody(db: db),
          ],
        ),
      ),
    );
  }
}
