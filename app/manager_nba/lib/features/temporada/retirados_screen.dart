import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../shared/estilo.dart';
import '../../shared/ficha_jugador.dart';
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
    // OJO al filtro por equipo, que faltaba y era el bug: sin él, un
    // jugador al que otra franquicia ya le había retirado la camiseta
    // —cosa que pasa sola con las leyendas reales, que cuelgan del techo
    // donde hicieron historia— contaba como "ya retirada" también aquí, y
    // la opción de retirársela en TU equipo no aparecía nunca.
    //
    // Son cosas distintas: que a alguien le retiren la camiseta en Nueva
    // Orleans no quita que se la merezca también en el tuyo.
    final ya = await (widget.db.select(widget.db.camisetasRetiradas)
          ..where((t) =>
              t.jugadorId.isIn(propios) &
              t.equipo.equals(widget.equipoUsuario)))
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
      content: Text(t(context).camisetaDeXRetirada(jugador.nombre)),
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
      appBar: barraDeClub(widget.equipoUsuario, t(context).tituloSeRetiran,
          conVolver: false),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : (propios.isEmpty && resto.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(t(context).estaTemporadaNoSeRetiraNadie,
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (propios.isNotEmpty) ...[
                      _Titulo(t(context).tuEquipoLabel),
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
                      _Titulo(t(context).restoDeLaLiga),
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
            child: Text(t(context).continuar),
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
        child: SeparadorSeccion(titulo: texto, acento: Estilo.de(context).marca),
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
        ? t(context).tituloAgenciaLibre
        : infoDe(cambio.equipo).nombreCompleto;
    final aviso = !camisetaRetirada
        ? ''
        : retiradaAutomatica
            ? t(context).suCamisetaYaRetiradaSola
            : t(context).camisetaRetiradaSufijo;

    final e = Estilo.de(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: FilaDeJugador(
        // La media con la que se retira, como placa: en una lista de doce
        // retiradas es lo que distingue a una leyenda de un suplente. Por
        // eso el detalle de abajo no la repite en texto — solo procedencia
        // y edad, que ahí sí que no se ven en ningún otro sitio.
        media: cambio.mediaAntes,
        nombre: cambio.nombre,
        detalle: '$procedencia · ${t(context).edadJugador(cambio.edad)}$aviso',
        onTap: onTap,
        accesorio: esAgenteLibre
            ? Icon(Icons.person_off, size: 20, color: e.textoRotulo)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EquipoLogo(codigoEquipo: cambio.equipo, tamano: 26),
                  if (onTap != null) ...[
                    const SizedBox(width: 6),
                    camisetaRetirada
                        ? const Icon(Icons.checkroom,
                            size: 18, color: Color(0xFFE0A81E))
                        : Icon(Icons.chevron_right,
                            size: 18, color: e.textoRotulo),
                  ],
                ],
              ),
      ),
    );
  }
}
