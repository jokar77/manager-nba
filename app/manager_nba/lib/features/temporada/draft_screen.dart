import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../shared/estilo.dart';
import '../../shared/ficha_jugador.dart';
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
enum _Orden { potencial, mediaDesc, mediaAsc }

String _etiquetaOrden(_Orden o, Textos textos) => switch (o) {
      _Orden.potencial => textos.ordenPotencial,
      _Orden.mediaDesc => textos.ordenMediaDesc,
      _Orden.mediaAsc => textos.ordenMediaAsc,
    };

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
        appBar: barraDeClub(
          widget.equipoUsuario,
          t(context).tituloDraft,
          // El draft es paso obligatorio del verano: sin flecha de volver.
          conVolver: false,
          acciones: [
            IconButton(
              icon: const Icon(Icons.groups),
              tooltip: t(context).verTuPlantilla,
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
                      : Center(
                          child: Text(t(context).eligiendoElRestoDeEquipos))),
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
                    child: Text(t(context).continuar),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _procesando ? null : _simularElResto,
                    child: Text(t(context).queElijaLaCpuPorMi),
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
      final e = Estilo.de(context);
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(mayus(t(context).draftCompletado),
            style: titular(e, tamano: 19)),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mayus(t(context).eleccionNumero(numeroDeEleccion)),
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1,
                        color: textoSecundarioSobre(fondo))),
                Text(
                  mayus(
                      esMiTurno ? t(context).teTocaElegir : info.nombreCompleto),
                  style: TextStyle(
                      fontFamily: familiaTitular,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
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
          Text(t(context).ordenarPorLabel),
          const SizedBox(width: 8),
          Expanded(
            child: SegmentedButton<_Orden>(
              segments: _Orden.values
                  .map((o) => ButtonSegment(
                      value: o, label: Text(_etiquetaOrden(o, t(context)))))
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
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: FilaDeJugador(
            media: p.media,
            nombre: p.nombreFicticio,
            detalle: '${etiquetaPosicion(p)} · '
                '${t(context).edadJugador(p.edad)}',
            // El potencial es LO que se mira en un draft: un 72 con cinco
            // estrellas vale más que un 78 con dos.
            bajoElNombre: PotencialEstrellas(potencial: p.potencial),
            // La fila entera elige: apuntar a un botón pequeño para cada
            // pick, con la lista llena de prospectos, era trabajo de más.
            onTap: procesando ? null : () => onElegir(p),
            accesorio: Icon(Icons.chevron_right,
                size: 18, color: Estilo.de(context).textoRotulo),
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
    final e = Estilo.de(context);
    final ordenados = [...elegidos]
      ..sort((a, b) => a.numeroDeEleccion.compareTo(b.numeroDeEleccion));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: ordenados.length,
      itemBuilder: (context, i) {
        final r = ordenados[i];
        final esTuyo = r.equipo == equipoUsuario;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: FilaDeJugador(
            media: r.media,
            nombre: r.nombre,
            detalle: '#${r.numeroDeEleccion} · ${r.posicion}',
            bajoElNombre: PotencialEstrellas(potencial: r.potencial, tamano: 12),
            // Con quién se ha ido cada uno, por nombre y no solo por escudo:
            // el logo de dos colores no basta para reconocer 30 franquicias.
            accesorio: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mayus(infoDe(r.equipo).apodo),
                    style: titular(e,
                        tamano: 13, color: esTuyo ? e.marca : e.texto)),
                const SizedBox(width: 6),
                EquipoLogo(codigoEquipo: r.equipo, tamano: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
