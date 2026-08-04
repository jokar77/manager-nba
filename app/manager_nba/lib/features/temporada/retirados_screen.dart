import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/camisetas_repository.dart';
import '../../domain/carrera_repository.dart';
import '../../domain/equipos_especiales.dart';
import '../../domain/equipos_info.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/progresion_repository.dart';
import '../../shared/equipo_logo.dart';
import 'carrera_jugador_screen.dart';

/// Todos los que cuelgan las botas esta temporada: con qué media se retiran
/// y desde dónde (su equipo, o la agencia libre si acabó sin contrato).
///
/// De los tuyos se puede decidir aquí mismo si retirarles la camiseta,
/// viendo antes su trayectoria en el equipo.
class RetiradosScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final CierreDeTemporada cierre;
  final VoidCallback onContinuar;

  const RetiradosScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    required this.cierre,
    required this.onContinuar,
  });

  @override
  State<RetiradosScreen> createState() => _RetiradosScreenState();
}

class _RetiradosScreenState extends State<RetiradosScreen> {
  // Los que ya tenían la camiseta retirada al entrar aquí: leyendas reales
  // que se honran automáticamente (ver nueva_temporada_repository.dart), sin
  // preguntar. Se cargan aparte de los que el usuario retira en esta
  // pantalla para poder avisar de que ya ha pasado, en vez de dejar que
  // parezca una decisión pendiente que en realidad no hace nada.
  Set<int> _yaRetiradasAntes = {};
  final Set<int> _retiradasEnEstaSesion = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarYaRetiradas();
  }

  Future<void> _cargarYaRetiradas() async {
    final propios = widget.cierre.retirados
        .where((c) => c.equipo == widget.equipoUsuario)
        .map((c) => c.jugadorId)
        .toList();
    if (propios.isEmpty) {
      setState(() => _cargando = false);
      return;
    }
    final ya = await (widget.db.select(widget.db.camisetasRetiradas)
          ..where((t) => t.jugadorId.isIn(propios)))
        .get();
    if (!mounted) return;
    setState(() {
      _yaRetiradasAntes = ya.map((c) => c.jugadorId).toSet();
      _cargando = false;
    });
  }

  Future<void> _decidirCamiseta(CambioDeJugador jugador) async {
    final carrera = await leerCarrera(widget.db, jugador.jugadorId);
    if (!mounted) return;

    // Ya se le retiró sola, sin preguntar (leyenda real con historia propia
    // fuera del juego): solo se enseña su carrera, no hay nada que decidir.
    if (_yaRetiradasAntes.contains(jugador.jugadorId)) {
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (context) => CarreraJugadorScreen(
          db: widget.db,
          carrera: carrera,
          nombreSiNoHayCarrera: jugador.nombre,
          equipoDestacado: widget.equipoUsuario,
        ),
      ));
      return;
    }

    final retirarla = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CarreraJugadorScreen(
          db: widget.db,
          carrera: carrera,
          nombreSiNoHayCarrera: jugador.nombre,
          equipoDestacado: widget.equipoUsuario,
          preguntarPorCamiseta: true,
        ),
      ),
    );
    if (retirarla != true || !mounted) return;

    await retirarCamiseta(
      widget.db,
      equipo: widget.equipoUsuario,
      jugadorId: jugador.jugadorId,
      temporada: widget.cierre.temporadaCerrada,
    );
    if (!mounted) return;
    setState(() => _retiradasEnEstaSesion.add(jugador.jugadorId));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Camiseta de ${jugador.nombre} retirada.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final retirados = widget.cierre.retirados;
    final propios =
        retirados.where((c) => c.equipo == widget.equipoUsuario).toList();
    final resto =
        retirados.where((c) => c.equipo != widget.equipoUsuario).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Se retiran'),
        automaticallyImplyLeading: false,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : (propios.isEmpty && resto.isEmpty)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Esta temporada no se retira nadie.',
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (propios.isNotEmpty) ...[
                      const _Titulo('Tu equipo'),
                      ...propios.map((c) => _FilaRetirado(
                            cambio: c,
                            camisetaRetirada:
                                _yaRetiradasAntes.contains(c.jugadorId) ||
                                    _retiradasEnEstaSesion.contains(c.jugadorId),
                            retiradaAutomatica:
                                _yaRetiradasAntes.contains(c.jugadorId),
                            onTap: () => _decidirCamiseta(c),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (resto.isNotEmpty) ...[
                      const _Titulo('Resto de la liga'),
                      ...resto.map((c) => _FilaRetirado(cambio: c)),
                    ],
                  ],
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onContinuar,
            child: const Text('Continuar'),
          ),
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(texto,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );
}

class _FilaRetirado extends StatelessWidget {
  final CambioDeJugador cambio;
  final bool camisetaRetirada;
  final bool retiradaAutomatica;
  final VoidCallback? onTap;

  const _FilaRetirado({
    required this.cambio,
    this.camisetaRetirada = false,
    this.retiradaAutomatica = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final esAgenteLibre = !esFranquicia(cambio.equipo);
    final procedencia = esAgenteLibre
        ? 'Agencia libre'
        : infoDe(cambio.equipo).nombreCompleto;
    final aviso = !camisetaRetirada
        ? ''
        : retiradaAutomatica
            ? ' · su camiseta ya se ha retirado sola (leyenda real)'
            : ' · camiseta retirada';

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: esAgenteLibre
            ? const Icon(Icons.person_off)
            : EquipoLogo(codigoEquipo: cambio.equipo, tamano: 32),
        title: Text(cambio.nombre),
        subtitle: Text('$procedencia · se retira con ${cambio.edad} años y '
            'media ${cambio.mediaAntes}$aviso'),
        trailing: onTap == null
            ? null
            : (camisetaRetirada
                ? const Icon(Icons.checkroom, color: Colors.amber)
                : const Icon(Icons.chevron_right)),
        onTap: onTap,
      ),
    );
  }
}
