import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/calendario_repository.dart';
import '../../domain/franquicia_repository.dart';
import '../../domain/lesiones_repository.dart';
import '../../domain/picks_repository.dart';
import '../../domain/posiciones.dart';
import '../../i18n/textos.dart';
import '../../shared/icono_lesion.dart';
import '../../shared/medias_jugador.dart';

class _AsignacionPuesto {
  int? titularId;
  int? suplenteId;
  int minutosTitular = minutosPorDefectoTitular;

  int get minutosSuplente => 48 - minutosTitular;
}

/// Alineación por posiciones: 5 puestos (PG/SG/SF/PF/C), cada uno con un
/// titular y un suplente elegidos a mano. Si [esConfiguracionInicial] es
/// true, esta pantalla es paso obligatorio del onboarding (arranca la
/// franquicia); si es false, se abre desde el menú para editar la
/// rotación ya guardada.
class RosterConfigScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipo;
  final bool esConfiguracionInicial;

  /// Se llama tras guardar la rotación con éxito. En el onboarding inicial
  /// navega al menú principal; al editar desde el menú, hace un simple pop.
  final VoidCallback onGuardado;

  const RosterConfigScreen({
    super.key,
    required this.db,
    required this.equipo,
    required this.esConfiguracionInicial,
    required this.onGuardado,
  });

  @override
  State<RosterConfigScreen> createState() => _RosterConfigScreenState();
}

class _RosterConfigScreenState extends State<RosterConfigScreen> {
  late Future<List<Jugador>> _plantillaFuture;
  final Map<String, _AsignacionPuesto> _asignaciones = {
    for (final p in posicionesEquipo) p: _AsignacionPuesto(),
  };
  int? _estrellaAtaqueId;
  int? _estrellaDefensaId;
  bool _cargandoRotacionPrevia = true;
  Map<int, Lesion> _lesionados = {};
  Map<int, EstadisticasTemporadaJugadorData> _stats = {};

  @override
  void initState() {
    super.initState();
    _plantillaFuture = _cargarPlantillaYRotacion();
  }

  Future<List<Jugador>> _cargarPlantillaYRotacion() async {
    final query = widget.db.select(widget.db.jugadores)
      ..where((t) => t.equipo.equals(widget.equipo))
      ..orderBy([(t) => OrderingTerm.desc(t.media)]);
    final plantilla = await query.get();
    final idsDeEstaPlantilla = plantilla.map((j) => j.id).toSet();

    // La fecha de la PARTIDA, no la del ordenador: con DateTime.now() todas
    // las lesiones de la temporada parecían seguir activas (sus fechas de
    // vuelta caen en el año de la partida, siempre por delante del reloj
    // real), así que la plantilla salía llena de lesionados en rojo que ya
    // se habían recuperado — y "alineación automática" los dejaba fuera,
    // mandando a la cancha a los suplentes el resto del año.
    final hoyEnLaPartida =
        await fechaActualDeLaLiga(widget.db) ?? DateTime.now();
    _lesionados = await lesionesActivasEn(widget.db, hoyEnLaPartida);
    final statsDeLaTemporada =
        await widget.db.select(widget.db.estadisticasTemporadaJugador).get();
    _stats = {
      for (final s in statsDeLaTemporada)
        if (idsDeEstaPlantilla.contains(s.jugadorId)) s.jugadorId: s,
    };

    final rotacionPrevia = await leerRotacion(widget.db);
    for (final fila in rotacionPrevia) {
      // Salvaguarda: si por lo que sea quedó guardada una rotación de otro
      // equipo (p. ej. un fallo al empezar una franquicia nueva sin
      // limpiarla), ignora esas filas en vez de asignar un jugadorId que no
      // existe en esta plantilla — eso hacía saltar un
      // "Null check operator used on a null value" en _SelectorEstrellas
      // al intentar ordenar por un jugador que `jugadoresPorId` no tiene.
      if (!idsDeEstaPlantilla.contains(fila.jugadorId)) continue;
      final asignacion = _asignaciones[fila.posicion];
      if (asignacion == null) continue;
      if (fila.esTitular) {
        asignacion.titularId = fila.jugadorId;
        asignacion.minutosTitular = fila.minutos;
      } else {
        asignacion.suplenteId = fila.jugadorId;
      }
      if (fila.esEstrellaAtaque) _estrellaAtaqueId = fila.jugadorId;
      if (fila.esEstrellaDefensa) _estrellaDefensaId = fila.jugadorId;
    }
    _cargandoRotacionPrevia = false;
    return plantilla;
  }

  Set<int> get _todosLosAsignados {
    final ids = <int>{};
    for (final a in _asignaciones.values) {
      if (a.titularId != null) ids.add(a.titularId!);
      if (a.suplenteId != null) ids.add(a.suplenteId!);
    }
    return ids;
  }

  bool get _rotacionCompleta {
    return _asignaciones.values
        .every((a) => a.titularId != null && a.suplenteId != null);
  }

  /// En qué hueco (puesto + titular/suplente) está ya [jugadorId], si está
  /// en alguno.
  (String, bool)? _huecoDe(int jugadorId) {
    for (final entry in _asignaciones.entries) {
      if (entry.value.titularId == jugadorId) return (entry.key, true);
      if (entry.value.suplenteId == jugadorId) return (entry.key, false);
    }
    return null;
  }

  void _ponerEn((String, bool) hueco, int? jugadorId) {
    final asignacion = _asignaciones[hueco.$1]!;
    if (hueco.$2) {
      asignacion.titularId = jugadorId;
    } else {
      asignacion.suplenteId = jugadorId;
    }
  }

  String _descripcionHueco(BuildContext context, (String, bool) hueco) =>
      t(context).descripcionHueco(hueco.$2, _nombrePosicion(context, hueco.$1));

  Future<void> _elegirJugador(
    List<Jugador> plantilla,
    String posicion,
    bool esTitular,
  ) async {
    final destino = (posicion, esTitular);
    final actual = esTitular
        ? _asignaciones[posicion]!.titularId
        : _asignaciones[posicion]!.suplenteId;

    final elegido = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
            '${esTitular ? t(context).tituloTitular : t(context).tituloSuplente} — '
            '${_nombrePosicion(context, posicion)}'),
        children: plantilla.map((j) {
          final huecoActual = _huecoDe(j.id);
          final yaEnEsteHueco = j.id == actual;
          final comodo = juegaComodoDe(j, posicion);
          final lesion = _lesionados[j.id];

          final detalle = lesion != null
              ? t(context).lesionSimple(
                  lesion.motivo, _formatearFecha(lesion.fechaFin))
              : (huecoActual != null && !yaEnEsteHueco
                  // Elegir a alguien que ya está en otro puesto no está
                  // prohibido: se intercambian los dos, que es lo natural
                  // cuando quieres mover a un jugador de sitio.
                  ? t(context).yaAsignadoIntercambio(
                      _descripcionHueco(context, huecoActual))
                  : null);

          return SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(j.id),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t(context).nombreConPosicionYMedia(
                            j.nombreFicticio, etiquetaPosicion(j), j.media),
                        style: TextStyle(
                          fontWeight:
                              yaEnEsteHueco ? FontWeight.bold : FontWeight.normal,
                          color: lesion != null ? Colors.red : null,
                        ),
                      ),
                      if (detalle != null)
                        Text(detalle,
                            style: TextStyle(
                                fontSize: 12,
                                color: lesion != null
                                    ? Colors.red
                                    : Theme.of(context).colorScheme.outline)),
                    ],
                  ),
                ),
                if (!comodo)
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (elegido == null || elegido == actual) return;
    setState(() {
      final origen = _huecoDe(elegido);
      // Si venía de otro hueco, el jugador que estaba aquí se va allí (o
      // ese hueco se queda vacío si este estaba libre).
      if (origen != null) _ponerEn(origen, actual);
      _ponerEn(destino, elegido);
    });
  }

  /// Rellena los 10 huecos con los mejores jugadores sanos de la plantilla
  /// y marca las dos estrellas, todo con lo que devuelve
  /// `generarRotacionAutomatica` — que es exactamente lo que usa la CPU en
  /// sus partidos. El usuario puede seguir ajustando a mano cualquier hueco
  /// después de pulsar el botón.
  ///
  /// Las estrellas salen de las filas generadas, no de volver a ordenar la
  /// plantilla por media: así son siempre los dos mejores DE LA ROTACIÓN.
  /// Calculándolas aparte se podía acabar marcando como estrella a alguien
  /// que ni siquiera había entrado en los diez.
  void _alinearAutomaticamente(List<Jugador> plantilla) {
    final lesionados =
        plantilla.where((j) => _lesionados.containsKey(j.id)).toList();
    var disponibles =
        plantilla.where((j) => !_lesionados.containsKey(j.id)).toList();
    var seIgnoranLesiones = false;
    if (disponibles.length < posicionesEquipo.length * 2) {
      disponibles = plantilla;
      seIgnoranLesiones = true;
    }
    final filas = generarRotacionAutomatica(disponibles);

    // Que se vea por qué falta alguien. Un titular lesionado desaparece de
    // la alineación sin más explicación, y desde fuera eso parece que el
    // botón no coge a los mejores.
    if (lesionados.isNotEmpty && !seIgnoranLesiones) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t(context).fueraPorLesion(
            lesionados.map((j) => j.nombreFicticio).join(", "))),
      ));
    }

    setState(() {
      _estrellaAtaqueId = null;
      _estrellaDefensaId = null;
      for (final fila in filas) {
        final asignacion = _asignaciones[fila.posicion.value]!;
        if (fila.esTitular.value) {
          asignacion.titularId = fila.jugadorId.value;
          asignacion.minutosTitular = fila.minutos.value;
        } else {
          asignacion.suplenteId = fila.jugadorId.value;
        }
        if (fila.esEstrellaAtaque.value) {
          _estrellaAtaqueId = fila.jugadorId.value;
        }
        if (fila.esEstrellaDefensa.value) {
          _estrellaDefensaId = fila.jugadorId.value;
        }
      }
    });
  }

  Future<void> _guardar() async {
    final filas = <RotacionJugadorCompanion>[];
    for (final entry in _asignaciones.entries) {
      final posicion = entry.key;
      final a = entry.value;
      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: true,
        jugadorId: a.titularId!,
        minutos: a.minutosTitular,
        esEstrellaAtaque: Value(_estrellaAtaqueId == a.titularId),
        esEstrellaDefensa: Value(_estrellaDefensaId == a.titularId),
      ));
      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: false,
        jugadorId: a.suplenteId!,
        minutos: a.minutosSuplente,
        esEstrellaAtaque: Value(_estrellaAtaqueId == a.suplenteId),
        esEstrellaDefensa: Value(_estrellaDefensaId == a.suplenteId),
      ));
    }

    await guardarRotacion(widget.db, filas);
    if (!mounted) return;
    widget.onGuardado();
  }

  Future<void> _verPicks() async {
    final picks = await picksDe(widget.db, widget.equipo);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => _HojaDePicks(picks: picks),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t(context).alineacionDeEquipo(widget.equipo)),
          actions: [
            IconButton(
              icon: const Icon(Icons.style),
              tooltip: t(context).tusPicksDeDraft,
              onPressed: _verPicks,
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(text: t(context).pestanaAlineacion),
            Tab(text: t(context).pestanaEstadisticas),
          ]),
        ),
        body: FutureBuilder<List<Jugador>>(
          future: _plantillaFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData || _cargandoRotacionPrevia) {
              return const Center(child: CircularProgressIndicator());
            }
            final plantilla = snapshot.data!;
            final jugadoresPorId = {for (final j in plantilla) j.id: j};

            return TabBarView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _alinearAutomaticamente(plantilla),
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(t(context).alinearAutomaticamenteBtn),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: posicionesEquipo
                            .map((posicion) => _PuestoCard(
                                  posicion: posicion,
                                  nombrePosicion: _nombrePosicion(context, posicion),
                                  asignacion: _asignaciones[posicion]!,
                                  jugadoresPorId: jugadoresPorId,
                                  lesionados: _lesionados,
                                  onElegirTitular: () =>
                                      _elegirJugador(plantilla, posicion, true),
                                  onElegirSuplente: () =>
                                      _elegirJugador(plantilla, posicion, false),
                                  onCambiarMinutosTitular: (delta) =>
                                      setState(() {
                                    final a = _asignaciones[posicion]!;
                                    a.minutosTitular =
                                        (a.minutosTitular + delta).clamp(0, 48);
                                  }),
                                ))
                            .toList(),
                      ),
                    ),
                    _SelectorEstrellas(
                      jugadoresPorId: jugadoresPorId,
                      idsAsignados: _todosLosAsignados,
                      estrellaAtaqueId: _estrellaAtaqueId,
                      estrellaDefensaId: _estrellaDefensaId,
                      onCambiarEstrellaAtaque: (id) =>
                          setState(() => _estrellaAtaqueId = id),
                      onCambiarEstrellaDefensa: (id) =>
                          setState(() => _estrellaDefensaId = id),
                    ),
                    _AtaqueYDefensaDelEquipo(
                      titulares: [
                        for (final posicion in posicionesEquipo)
                          if (_asignaciones[posicion]?.titularId != null)
                            jugadoresPorId[_asignaciones[posicion]!.titularId!]!,
                      ],
                      rotacion: [
                        for (final id in _todosLosAsignados)
                          if (jugadoresPorId[id] != null) jugadoresPorId[id]!,
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _rotacionCompleta ? _guardar : null,
                          child: Text(widget.esConfiguracionInicial
                              ? t(context).empezarTemporadaBtn
                              : t(context).guardarRotacionBtn),
                        ),
                      ),
                    ),
                  ],
                ),
                _EstadisticasTab(plantilla: plantilla, stats: _stats),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _nombrePosicion(BuildContext context, String codigo) =>
    t(context).nombresDePosiciones[codigo] ?? codigo;

class _PuestoCard extends StatelessWidget {
  final String posicion;
  final String nombrePosicion;
  final _AsignacionPuesto asignacion;
  final Map<int, Jugador> jugadoresPorId;
  final Map<int, Lesion> lesionados;
  final VoidCallback onElegirTitular;
  final VoidCallback onElegirSuplente;
  final void Function(int delta) onCambiarMinutosTitular;

  const _PuestoCard({
    required this.posicion,
    required this.nombrePosicion,
    required this.asignacion,
    required this.jugadoresPorId,
    required this.lesionados,
    required this.onElegirTitular,
    required this.onElegirSuplente,
    required this.onCambiarMinutosTitular,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombrePosicion,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _HuecoJugador(
              etiqueta: t(context).tituloTitular,
              posicion: posicion,
              jugador: jugadoresPorId[asignacion.titularId],
              lesion: lesionados[asignacion.titularId],
              onTap: onElegirTitular,
            ),
            if (asignacion.titularId != null && asignacion.suplenteId != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(t(context).minutosTitularLabel),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => onCambiarMinutosTitular(-1),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${asignacion.minutosTitular} / ${asignacion.minutosSuplente}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () => onCambiarMinutosTitular(1),
                    ),
                  ],
                ),
              ),
            _HuecoJugador(
              etiqueta: t(context).tituloSuplente,
              posicion: posicion,
              jugador: jugadoresPorId[asignacion.suplenteId],
              lesion: lesionados[asignacion.suplenteId],
              onTap: onElegirSuplente,
            ),
          ],
        ),
      ),
    );
  }
}

class _HuecoJugador extends StatelessWidget {
  final String etiqueta;
  final String posicion;
  final Jugador? jugador;
  final Lesion? lesion;
  final VoidCallback onTap;

  const _HuecoJugador({
    required this.etiqueta,
    required this.posicion,
    required this.jugador,
    required this.onTap,
    this.lesion,
  });

  @override
  Widget build(BuildContext context) {
    final fueraDePosicion = jugador != null && !juegaComodoDe(jugador!, posicion);
    final lesionado = jugador != null && lesion != null;

    final lineaAviso = lesionado
        ? t(context).lesionConDetalle(lesion!.motivo,
            lesion!.partidosEstimados, _formatearFecha(lesion!.fechaFin))
        : (fueraDePosicion ? t(context).fueraDeSusDosPosiciones : null);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(jugador == null
          ? '$etiqueta: ${t(context).elegirJugadorPlaceholder}'
          : t(context).huecoConJugador(
              etiqueta, jugador!.nombreFicticio, etiquetaPosicion(jugador!),
              jugador!.media)),
      // El ataque y la defensa van aquí y no en el título: dos jugadores de
      // la misma media pueden ser cosas muy distintas, y sin verlo la
      // alineación se hace a ciegas.
      subtitle: jugador == null && lineaAviso == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (jugador != null)
                  MediasAtaqueDefensa.de(jugador!, compacto: true),
                if (lineaAviso != null)
                  Text(lineaAviso,
                      style: TextStyle(
                          color: lesionado ? Colors.red : Colors.orange)),
              ],
            ),
      trailing: lesionado
          ? const IconoLesion()
          : (fueraDePosicion
              ? const Icon(Icons.warning_amber, color: Colors.orange)
              : const Icon(Icons.chevron_right)),
      onTap: onTap,
    );
  }
}

String _formatearFecha(DateTime fecha) {
  return '${fecha.day.toString().padLeft(2, '0')}/'
      '${fecha.month.toString().padLeft(2, '0')}';
}

/// Las estadísticas de la temporada actual de toda la plantilla, en su
/// propia pestaña — antes iban de subtítulo bajo cada nombre en la
/// pestaña de Alineación, y hacían tres líneas por hueco solo para poder
/// comparar a dos suplentes.
class _EstadisticasTab extends StatelessWidget {
  final List<Jugador> plantilla;
  final Map<int, EstadisticasTemporadaJugadorData> stats;

  const _EstadisticasTab({required this.plantilla, required this.stats});

  @override
  Widget build(BuildContext context) {
    final ordenados = [...plantilla]..sort((a, b) {
        final statsA = stats[a.id];
        final statsB = stats[b.id];
        final ppgA = statsA == null || statsA.partidosJugados == 0
            ? -1.0
            : statsA.puntosTotales / statsA.partidosJugados;
        final ppgB = statsB == null || statsB.partidosJugados == 0
            ? -1.0
            : statsB.puntosTotales / statsB.partidosJugados;
        return ppgB.compareTo(ppgA);
      });

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: ordenados.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final j = ordenados[i];
        final s = stats[j.id];
        final sinPartidos = s == null || s.partidosJugados == 0;
        return ListTile(
          dense: true,
          title: Text('${j.nombreFicticio} (${etiquetaPosicion(j)})'),
          subtitle: sinPartidos
              ? Text(t(context).sinPartidosJugadosTemporada)
              : Text(
                  '${(s.puntosTotales / s.partidosJugados).toStringAsFixed(1)} pts · '
                  '${(s.asistenciasTotales / s.partidosJugados).toStringAsFixed(1)} ast · '
                  '${(s.rebotesTotales / s.partidosJugados).toStringAsFixed(1)} reb '
                  '(${s.partidosJugados} PJ)'),
        );
      },
    );
  }
}

class _SelectorEstrellas extends StatelessWidget {
  final Map<int, Jugador> jugadoresPorId;
  final Set<int> idsAsignados;
  final int? estrellaAtaqueId;
  final int? estrellaDefensaId;
  final void Function(int?) onCambiarEstrellaAtaque;
  final void Function(int?) onCambiarEstrellaDefensa;

  const _SelectorEstrellas({
    required this.jugadoresPorId,
    required this.idsAsignados,
    required this.estrellaAtaqueId,
    required this.estrellaDefensaId,
    required this.onCambiarEstrellaAtaque,
    required this.onCambiarEstrellaDefensa,
  });

  @override
  Widget build(BuildContext context) {
    final candidatos = idsAsignados.toList()
      ..sort((a, b) =>
          jugadoresPorId[a]!.nombreFicticio.compareTo(jugadoresPorId[b]!.nombreFicticio));

    DropdownMenuItem<int?> item(int? id, String etiqueta) => DropdownMenuItem(
          value: id,
          child: Text(etiqueta, overflow: TextOverflow.ellipsis),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int?>(
              decoration:
                  InputDecoration(labelText: t(context).estrellaAtaqueLabel),
              initialValue:
                  candidatos.contains(estrellaAtaqueId) ? estrellaAtaqueId : null,
              items: [
                item(null, t(context).ningunaOpcion),
                ...candidatos
                    .map((id) => item(id, jugadoresPorId[id]!.nombreFicticio)),
              ],
              onChanged: onCambiarEstrellaAtaque,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int?>(
              decoration:
                  InputDecoration(labelText: t(context).estrellaDefensaLabel),
              initialValue: candidatos.contains(estrellaDefensaId)
                  ? estrellaDefensaId
                  : null,
              items: [
                item(null, t(context).ningunaOpcion),
                ...candidatos
                    .map((id) => item(id, jugadoresPorId[id]!.nombreFicticio)),
              ],
              onChanged: onCambiarEstrellaDefensa,
            ),
          ),
        ],
      ),
    );
  }
}

/// Las elecciones de draft que tiene el equipo, agrupadas por temporada.
class _HojaDePicks extends StatelessWidget {
  final List<PickDraft> picks;

  const _HojaDePicks({required this.picks});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t(context).tituloTusPicksDeDraft,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (picks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(t(context).sinPicksPropios),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: picks.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = picks[i];
                    final esPropio = p.equipoOriginal == p.equipoActual;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        p.ronda == 1 ? Icons.looks_one : Icons.looks_two,
                        size: 20,
                      ),
                      title: Text(etiquetaDePick(p)),
                      subtitle: esPropio
                          ? null
                          : Text(t(context).traspasadoATiPorOtroEquipo),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}


/// El ataque y la defensa de tu quinteto y de la rotación entera.
///
/// Es lo que faltaba para poder decidir: viendo solo medias sueltas no se
/// sabe si el equipo que estás montando defiende o no defiende.
class _AtaqueYDefensaDelEquipo extends StatelessWidget {
  final List<Jugador> titulares;
  final List<Jugador> rotacion;

  const _AtaqueYDefensaDelEquipo({
    required this.titulares,
    required this.rotacion,
  });

  @override
  Widget build(BuildContext context) {
    if (titulares.isEmpty) return const SizedBox.shrink();
    final quinteto = mediasDe(titulares);
    final todos = mediasDe(rotacion);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t(context).ataqueYDefensaTitulo,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _Linea(
                  etiqueta: t(context).quintetoInicial,
                  ataque: quinteto.ataque,
                  defensa: quinteto.defensa),
              const SizedBox(height: 4),
              _Linea(
                  etiqueta: t(context).rotacionCompleta,
                  ataque: todos.ataque,
                  defensa: todos.defensa),
            ],
          ),
        ),
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  final String etiqueta;
  final int ataque;
  final int defensa;

  const _Linea({
    required this.etiqueta,
    required this.ataque,
    required this.defensa,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(etiqueta,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(width: 8),
        MediasAtaqueDefensa(ataque: ataque, defensa: defensa),
      ],
    );
  }
}
