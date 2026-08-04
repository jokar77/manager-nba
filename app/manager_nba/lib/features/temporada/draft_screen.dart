import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/draft_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/posiciones.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import '../../shared/potencial_estrellas.dart';
import '../roster/roster_config_screen.dart';

/// El draft, elección a elección. La CPU va eligiendo sola y se para en
/// cuanto te toca a ti: entonces se listan todos los prospectos que quedan
/// —nombre, posición, edad, media y potencial— para que elijas.
///
/// Devuelve todas las elecciones (tuyas y de la CPU) para el resumen de
/// pretemporada.
class DraftScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const DraftScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  State<DraftScreen> createState() => _DraftScreenState();
}

/// Criterios de orden de la lista de disponibles.
enum _Orden {
  potencial('Potencial'),
  mediaDesc('Media ↓'),
  mediaAsc('Media ↑');

  const _Orden(this.etiqueta);
  final String etiqueta;
}

class _DraftScreenState extends State<DraftScreen> {
  final List<RookieElegido> _elegidos = [];
  List<Jugador> _disponibles = [];
  String? _turno;
  int _numeroDeEleccion = 1;
  bool _procesando = true;
  _Orden _orden = _Orden.potencial;

  @override
  void initState() {
    super.initState();
    _avanzarHastaMiTurno();
  }

  Future<void> _refrescar() async {
    final disponibles = await prospectosDisponibles(widget.db);
    final turno = await equipoQueElige(widget.db);
    final numero = await numeroDeEleccionActual(widget.db);
    if (!mounted) return;
    setState(() {
      _disponibles = disponibles;
      _turno = turno;
      _numeroDeEleccion = numero;
      _procesando = false;
    });
  }

  Future<void> _avanzarHastaMiTurno() async {
    setState(() => _procesando = true);
    final deLaCpu =
        await avanzarDraftHastaElTurnoDe(widget.db, widget.equipoUsuario);
    _elegidos.addAll(deLaCpu);
    await _refrescar();
  }

  Future<void> _elegir(Jugador prospecto) async {
    setState(() => _procesando = true);
    final elegido = await elegirEnDraft(widget.db, prospecto.id);
    if (elegido != null) _elegidos.add(elegido);
    await _avanzarHastaMiTurno();
  }

  /// Si no te apetece elegir, la CPU lo hace por ti y sigue hasta el final.
  Future<void> _simularElResto() async {
    setState(() => _procesando = true);
    _elegidos.addAll(await avanzarDraftHastaElTurnoDe(widget.db, null));
    await _refrescar();
  }

  List<Jugador> get _ordenados {
    final lista = [..._disponibles];
    switch (_orden) {
      case _Orden.potencial:
        lista.sort((a, b) {
          final cmp = b.potencial.compareTo(a.potencial);
          return cmp != 0 ? cmp : b.media.compareTo(a.media);
        });
      case _Orden.mediaDesc:
        lista.sort((a, b) => b.media.compareTo(a.media));
      case _Orden.mediaAsc:
        lista.sort((a, b) => a.media.compareTo(b.media));
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final terminado = _turno == null;
    final esMiTurno = _turno == widget.equipoUsuario;

    return PopScope(
      // El draft hay que terminarlo: si se pudiera abandonar a medias, la
      // temporada nueva se quedaría sin generar.
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Draft'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.groups),
              tooltip: 'Ver tu plantilla',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RosterConfigScreen(
                  db: widget.db,
                  equipo: widget.equipoUsuario,
                  esConfiguracionInicial: false,
                  onGuardado: () => Navigator.of(context).pop(),
                ),
              )),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_procesando) const LinearProgressIndicator(),
            _Cabecera(
              turno: _turno,
              numeroDeEleccion: _numeroDeEleccion,
              esMiTurno: esMiTurno,
              terminado: terminado,
            ),
            if (esMiTurno) _BarraDeOrden(
              orden: _orden,
              onCambiar: (o) => setState(() => _orden = o),
            ),
            Expanded(
              child: terminado
                  ? _ListaElegidos(
                      elegidos: _elegidos,
                      equipoUsuario: widget.equipoUsuario)
                  : (esMiTurno
                      ? _ListaDisponibles(
                          prospectos: _ordenados,
                          procesando: _procesando,
                          onElegir: _elegir,
                        )
                      : const Center(
                          child: Text('Eligiendo el resto de equipos...'))),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: terminado
              ? SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _procesando
                        ? null
                        : () => Navigator.of(context).pop(_elegidos),
                    child: const Text('Continuar'),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _procesando ? null : _simularElResto,
                    child: const Text('Que elija la CPU por mí'),
                  ),
                ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final String? turno;
  final int numeroDeEleccion;
  final bool esMiTurno;
  final bool terminado;

  const _Cabecera({
    required this.turno,
    required this.numeroDeEleccion,
    required this.esMiTurno,
    required this.terminado,
  });

  @override
  Widget build(BuildContext context) {
    if (terminado) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Draft completado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }

    final info = infoDe(turno!);
    final fondo = info.colorPrimario;
    return Container(
      width: double.infinity,
      color: fondo,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          EquipoLogo(codigoEquipo: turno!, tamano: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elección número $numeroDeEleccion',
                    style: TextStyle(color: textoSecundarioSobre(fondo))),
                Text(
                  esMiTurno ? '¡Te toca elegir!' : info.nombreCompleto,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textoSobre(fondo)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraDeOrden extends StatelessWidget {
  final _Orden orden;
  final ValueChanged<_Orden> onCambiar;

  const _BarraDeOrden({required this.orden, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text('Ordenar por: '),
          const SizedBox(width: 8),
          Expanded(
            child: SegmentedButton<_Orden>(
              segments: _Orden.values
                  .map((o) => ButtonSegment(value: o, label: Text(o.etiqueta)))
                  .toList(),
              selected: {orden},
              onSelectionChanged: (s) => onCambiar(s.first),
              showSelectedIcon: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaDisponibles extends StatelessWidget {
  final List<Jugador> prospectos;
  final bool procesando;
  final void Function(Jugador) onElegir;

  const _ListaDisponibles({
    required this.prospectos,
    required this.procesando,
    required this.onElegir,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: prospectos.length,
      itemBuilder: (context, i) {
        final p = prospectos[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            // La fila entera elige: apuntar a un botón pequeño para cada
            // pick, con la lista llena de prospectos, era trabajo de más.
            onTap: procesando ? null : () => onElegir(p),
            title: Text(p.nombreFicticio,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${etiquetaPosicion(p)} · ${p.edad} años · '
                    'media ${p.media}'),
                const SizedBox(height: 3),
                PotencialEstrellas(potencial: p.potencial),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _ListaElegidos extends StatelessWidget {
  final List<RookieElegido> elegidos;
  final String equipoUsuario;

  const _ListaElegidos({required this.elegidos, required this.equipoUsuario});

  @override
  Widget build(BuildContext context) {
    final ordenados = [...elegidos]
      ..sort((a, b) => a.numeroDeEleccion.compareTo(b.numeroDeEleccion));

    return ListView.builder(
      itemCount: ordenados.length,
      itemBuilder: (context, i) {
        final r = ordenados[i];
        final esTuyo = r.equipo == equipoUsuario;
        return ListTile(
          dense: true,
          leading: SizedBox(
            width: 36,
            child: Text('#${r.numeroDeEleccion}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          title: Text(r.nombre,
              style: TextStyle(
                  fontWeight: esTuyo ? FontWeight.bold : FontWeight.normal)),
          subtitle: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${r.posicion} · media ${r.media} · '),
              PotencialEstrellas(potencial: r.potencial, tamano: 12),
            ],
          ),
          // Con quién se ha ido cada uno, por nombre y no solo por escudo:
          // el logo de dos colores no basta para reconocer 30 franquicias.
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(infoDe(r.equipo).apodo,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          esTuyo ? FontWeight.bold : FontWeight.normal)),
              const SizedBox(width: 6),
              EquipoLogo(codigoEquipo: r.equipo, tamano: 24),
            ],
          ),
        );
      },
    );
  }
}
