import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/calendario_repository.dart';
import '../../domain/franquicia_repository.dart';
import '../../domain/lesiones_repository.dart';
import '../../domain/picks_repository.dart';
import '../../domain/posiciones.dart';
import '../../i18n/textos.dart';
import '../../domain/equipos_info.dart';
import '../../shared/contraste.dart';
import '../../shared/estilo.dart';
import '../../shared/icono_lesion.dart';
import '../../shared/medias_jugador.dart';

/// El color del sexto hombre en el selector de roles: distinto del naranja
/// de ataque y el azul de defensa, para que los tres se distingan de un
/// vistazo.
const colorSextoHombre = Color(0xFF9C5FE0);

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
  int? _sextoHombreId;
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
    final statsDeLaTemporada = await widget.db
        .select(widget.db.estadisticasTemporadaJugador)
        .get();
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
      if (fila.esSextoHombre) _sextoHombreId = fila.jugadorId;
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

  /// Solo los suplentes: es de donde puede salir el sexto hombre.
  Set<int> get _suplentesAsignados {
    final ids = <int>{};
    for (final a in _asignaciones.values) {
      if (a.suplenteId != null) ids.add(a.suplenteId!);
    }
    return ids;
  }

  bool get _rotacionCompleta {
    return _asignaciones.values.every(
      (a) => a.titularId != null && a.suplenteId != null,
    );
  }

  /// Los tres roles elegidos. Son **obligatorios** para guardar, igual que
  /// los diez huecos: un equipo sin estrella de ataque ni sexto hombre es
  /// un equipo a medio montar, y el motor los usa.
  ///
  /// No hace falta comprobar que haya candidatos: en cuanto la rotación
  /// está completa hay diez jugadores para las estrellas y cinco suplentes
  /// para el sexto hombre. Por eso [_intentarGuardar] mira la alineación
  /// primero — al revés se pediría un sexto hombre sin suplentes de los
  /// que sacarlo.
  bool get _rolesCompletos =>
      _estrellaAtaqueId != null &&
      _estrellaDefensaId != null &&
      _sextoHombreId != null;

  /// Cuántas veces se ha intentado guardar con los roles a medias. Se le
  /// pasa a la banda, que se abre y parpadea cada vez que sube.
  int _avisosDeRoles = 0;

  /// Intenta guardar, y si no se puede **dice qué falta**.
  ///
  /// Antes el botón salía deshabilitado y ya está. Eso tiene un problema
  /// que se ve en cuanto alguien lo usa: un botón muerto no explica nada,
  /// y desde que la banda de roles se pliega en móvil, lo que falta puede
  /// estar además doblado. Así que el botón siempre responde, y cuando no
  /// se puede guardar señala el sitio.
  Future<void> _intentarGuardar() async {
    final textos = t(context);

    if (!_rotacionCompleta) {
      _avisar(textos.faltaAlineacionAviso);
      return;
    }
    if (!_rolesCompletos) {
      // La banda se abre sola y parpadea: el mensaje dice qué falta y el
      // parpadeo dice dónde.
      setState(() => _avisosDeRoles++);
      _avisar(textos.faltanRolesAviso);
      return;
    }
    await _guardar();
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
      // Sin esto, dos toques seguidos encolan dos avisos y el segundo sale
      // cuando ya no viene a cuento.
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
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
          '${_nombrePosicion(context, posicion)}',
        ),
        children: plantilla.map((j) {
          final huecoActual = _huecoDe(j.id);
          final yaEnEsteHueco = j.id == actual;
          final comodo = juegaComodoDe(j, posicion);
          final lesion = _lesionados[j.id];

          final detalle = lesion != null
              ? t(
                  context,
                ).lesionSimple(lesion.motivo, _formatearFecha(lesion.fechaFin))
              : (huecoActual != null && !yaEnEsteHueco
                    // Elegir a alguien que ya está en otro puesto no está
                    // prohibido: se intercambian los dos, que es lo natural
                    // cuando quieres mover a un jugador de sitio.
                    ? t(context).yaAsignadoIntercambio(
                        _descripcionHueco(context, huecoActual),
                      )
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
                          j.nombreFicticio,
                          etiquetaPosicion(j),
                          j.media,
                        ),
                        style: TextStyle(
                          fontWeight: yaEnEsteHueco
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: lesion != null ? Colors.red : null,
                        ),
                      ),
                      if (detalle != null)
                        Text(
                          detalle,
                          style: TextStyle(
                            fontSize: 12,
                            color: lesion != null
                                ? Colors.red
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!comodo)
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 18,
                  ),
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
    final lesionados = plantilla
        .where((j) => _lesionados.containsKey(j.id))
        .toList();
    var disponibles = plantilla
        .where((j) => !_lesionados.containsKey(j.id))
        .toList();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t(context).fueraPorLesion(
              lesionados.map((j) => j.nombreFicticio).join(", "),
            ),
          ),
        ),
      );
    }

    setState(() {
      _estrellaAtaqueId = null;
      _estrellaDefensaId = null;
      _sextoHombreId = null;
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
        if (fila.esSextoHombre.value) {
          _sextoHombreId = fila.jugadorId.value;
        }
      }
    });
  }

  Future<void> _guardar() async {
    final filas = <RotacionJugadorCompanion>[];
    for (final entry in _asignaciones.entries) {
      final posicion = entry.key;
      final a = entry.value;
      filas.add(
        RotacionJugadorCompanion.insert(
          posicion: posicion,
          esTitular: true,
          jugadorId: a.titularId!,
          minutos: a.minutosTitular,
          esEstrellaAtaque: Value(_estrellaAtaqueId == a.titularId),
          esEstrellaDefensa: Value(_estrellaDefensaId == a.titularId),
        ),
      );
      filas.add(
        RotacionJugadorCompanion.insert(
          posicion: posicion,
          esTitular: false,
          jugadorId: a.suplenteId!,
          minutos: a.minutosSuplente,
          esEstrellaAtaque: Value(_estrellaAtaqueId == a.suplenteId),
          esEstrellaDefensa: Value(_estrellaDefensaId == a.suplenteId),
          esSextoHombre: Value(_sextoHombreId == a.suplenteId),
        ),
      );
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
    final e = Estilo.de(context);
    final info = infoDe(widget.equipo);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: e.fondo,
        body: Column(
          children: [
            _BarraDeEquipo(
              equipo: widget.equipo,
              info: info,
              onPicks: _verPicks,
            ),
            Expanded(
              child: FutureBuilder<List<Jugador>>(
                future: _plantillaFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || _cargandoRotacionPrevia) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final plantilla = snapshot.data!;
                  final jugadoresPorId = {for (final j in plantilla) j.id: j};
                  return TabBarView(
                    children: [
                      _alineacion(info, plantilla, jugadoresPorId),
                      _EstadisticasTab(plantilla: plantilla, stats: _stats),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// La pestaña de alineación: los cinco puestos con su titular y su
  /// suplente, y arriba del todo cómo queda el quinteto.
  ///
  /// En escritorio los cinco puestos se ponen en fila —una columna cada
  /// uno, como una alineación de verdad— porque a 1600 px de ancho la lista
  /// vertical deja tres cuartas partes de la pantalla en blanco.
  Widget _alineacion(
    EquipoInfo info,
    List<Jugador> plantilla,
    Map<int, Jugador> jugadoresPorId,
  ) {
    final acento = colorLegibleComoTexto(info.colorSecundario, context);
    final titulares = [
      for (final posicion in posicionesEquipo)
        if (_asignaciones[posicion]?.titularId != null)
          jugadoresPorId[_asignaciones[posicion]!.titularId!]!,
    ];
    final rotacion = [
      for (final id in _todosLosAsignados)
        if (jugadoresPorId[id] != null) jugadoresPorId[id]!,
    ];

    final bloques = [
      for (final posicion in posicionesEquipo)
        _PuestoCard(
          posicion: posicion,
          nombrePosicion: _nombrePosicion(context, posicion),
          acento: acento,
          asignacion: _asignaciones[posicion]!,
          jugadoresPorId: jugadoresPorId,
          lesionados: _lesionados,
          onElegirTitular: () => _elegirJugador(plantilla, posicion, true),
          onElegirSuplente: () => _elegirJugador(plantilla, posicion, false),
          onCambiarMinutosTitular: (delta) => setState(() {
            final a = _asignaciones[posicion]!;
            a.minutosTitular = (a.minutosTitular + delta).clamp(0, 48);
          }),
        ),
    ];
    return Column(
      children: [
        _FranjaAtaqueDefensa(
          titulares: titulares,
          rotacion: rotacion,
          acento: acento,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            children: [
              BotonPerfilado(
                icono: Icons.auto_awesome,
                texto: t(context).alinearAutomaticamenteBtn,
                color: acento,
                onTap: () => _alinearAutomaticamente(plantilla),
                alto: 46,
              ),
              const SizedBox(height: 12),
              // La fila de cinco columnas no depende del tramo de pantalla
              // sino del ancho que hay de verdad: es el contenido el que
              // manda. Una ventana de 1024 ya cuenta como "amplio", pero
              // ahí las cinco columnas salen a 190 px y las etiquetas de
              // ataque y defensa no caben.
              LayoutBuilder(
                builder: (context, restricciones) {
                  if (restricciones.maxWidth < _anchoMinimoParaCincoPuestos) {
                    return Column(
                      children: [
                        for (final bloque in bloques)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: bloque,
                          ),
                      ],
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < bloques.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(child: bloques[i]),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        _SelectorEstrellas(
          jugadoresPorId: jugadoresPorId,
          idsAsignados: _todosLosAsignados,
          estrellaAtaqueId: _estrellaAtaqueId,
          estrellaDefensaId: _estrellaDefensaId,
          idsSuplentes: _suplentesAsignados,
          sextoHombreId: _sextoHombreId,
          onCambiarEstrellaAtaque: (id) =>
              setState(() => _estrellaAtaqueId = id),
          onCambiarEstrellaDefensa: (id) =>
              setState(() => _estrellaDefensaId = id),
          onCambiarSextoHombre: (id) => setState(() => _sextoHombreId = id),
          senalDeAviso: _avisosDeRoles,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: BotonPrincipal(
            texto: widget.esConfiguracionInicial
                ? t(context).empezarTemporadaBtn
                : t(context).guardarRotacionBtn,
            color: acento,
            // Siempre pulsable: si falta algo, `_intentarGuardar` dice qué
            // y señala dónde. Un botón apagado no explica ninguna de las
            // dos cosas.
            onTap: _intentarGuardar,
          ),
        ),
      ],
    );
  }
}

String _nombrePosicion(BuildContext context, String codigo) =>
    t(context).nombresDePosiciones[codigo] ?? codigo;

/// Un puesto de la rotación: su titular, su suplente y el reparto de
/// minutos entre los dos.
/// Lo que necesita un puesto para que quepan su nombre, la placa de media y
/// las etiquetas de ataque y defensa sin recortar. Por debajo de esto los
/// cinco puestos se apilan.
const _anchoMinimoParaCincoPuestos = 1190.0;

class _PuestoCard extends StatelessWidget {
  final String posicion;
  final String nombrePosicion;
  final Color acento;
  final _AsignacionPuesto asignacion;
  final Map<int, Jugador> jugadoresPorId;
  final Map<int, Lesion> lesionados;
  final VoidCallback onElegirTitular;
  final VoidCallback onElegirSuplente;
  final void Function(int delta) onCambiarMinutosTitular;

  const _PuestoCard({
    required this.posicion,
    required this.nombrePosicion,
    required this.acento,
    required this.asignacion,
    required this.jugadoresPorId,
    required this.lesionados,
    required this.onElegirTitular,
    required this.onElegirSuplente,
    required this.onCambiarMinutosTitular,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final hayDos =
        asignacion.titularId != null && asignacion.suplenteId != null;
    // El puesto entero se marca en rojo si su titular está lesionado: así se
    // ve el agujero desde fuera, sin abrir nada.
    final titularLesionado = lesionados[asignacion.titularId] != null;

    return PanelCortado(
      fondo: e.panel,
      corte: 12,
      borde: Border(
        left: BorderSide(color: titularLesionado ? e.mal : acento, width: 3),
        top: BorderSide(color: e.linea),
        right: BorderSide(color: e.linea),
        bottom: BorderSide(color: e.linea),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: e.linea)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    mayus(nombrePosicion),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titular(e, tamano: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Text(posicion, style: rotulo(e, tamano: 9)),
              ],
            ),
          ),
          _HuecoJugador(
            etiqueta: t(context).tituloTitular,
            clave: 'titular',
            posicion: posicion,
            jugador: jugadoresPorId[asignacion.titularId],
            lesion: lesionados[asignacion.titularId],
            destacado: true,
            acento: acento,
            onTap: onElegirTitular,
          ),
          if (hayDos)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      mayus(
                        t(
                          context,
                        ).minutosTitularLabel.replaceAll(':', '').trim(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: rotulo(e, tamano: 9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PasoMinutos(
                    icono: Icons.remove,
                    onTap: () => onCambiarMinutosTitular(-1),
                  ),
                  SizedBox(
                    width: 62,
                    child: Text(
                      '${asignacion.minutosTitular} / '
                      '${asignacion.minutosSuplente}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: cifra(e, tamano: 17),
                    ),
                  ),
                  _PasoMinutos(
                    icono: Icons.add,
                    onTap: () => onCambiarMinutosTitular(1),
                  ),
                ],
              ),
            ),
          _HuecoJugador(
            etiqueta: t(context).tituloSuplente,
            clave: 'suplente',
            posicion: posicion,
            jugador: jugadoresPorId[asignacion.suplenteId],
            lesion: lesionados[asignacion.suplenteId],
            destacado: false,
            acento: acento,
            onTap: onElegirSuplente,
          ),
        ],
      ),
    );
  }
}

/// Un hueco de la rotación: quién lo ocupa, lo bueno que es y por qué no
/// debería estar ahí, si es el caso.
class _HuecoJugador extends StatelessWidget {
  final String etiqueta;

  /// Identificador estable del hueco, sin traducir. La etiqueta que se ve
  /// cambia con el idioma; esto no, y es lo que usan los tests para señalar
  /// un hueco concreto sin depender de cómo esté redactado.
  final String clave;

  final String posicion;
  final Jugador? jugador;
  final Lesion? lesion;

  /// El titular manda: placa más grande y sin fondo propio.
  final bool destacado;

  final Color acento;
  final VoidCallback onTap;

  const _HuecoJugador({
    required this.etiqueta,
    required this.clave,
    required this.posicion,
    required this.jugador,
    required this.destacado,
    required this.acento,
    required this.onTap,
    this.lesion,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final fueraDePosicion =
        jugador != null && !juegaComodoDe(jugador!, posicion);
    final lesionado = jugador != null && lesion != null;

    final lineaAviso = lesionado
        ? textos.lesionConDetalle(
            lesion!.motivo,
            lesion!.partidosEstimados,
            _formatearFecha(lesion!.fechaFin),
          )
        : (fueraDePosicion ? textos.fueraDeSusDosPosiciones : null);

    final ladoPlaca = destacado ? 46.0 : 38.0;

    return Material(
      color: destacado ? Colors.transparent : e.panelSuave,
      child: InkWell(
        key: ValueKey('hueco-$posicion-$clave'),
        onTap: onTap,
        child: Container(
          decoration: destacado
              ? null
              : BoxDecoration(
                  border: Border(top: BorderSide(color: e.linea)),
                ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              if (jugador == null)
                Container(
                  width: ladoPlaca,
                  height: ladoPlaca,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: e.lineaFuerte),
                  ),
                  child: Icon(Icons.add, size: 20, color: e.textoRotulo),
                )
              else
                PlacaMedia(
                  media: jugador!.media,
                  tamano: ladoPlaca,
                  apagada: lesionado,
                ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mayus(etiqueta),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: rotulo(
                        e,
                        tamano: 9,
                        color: destacado ? acento : e.textoRotulo,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      // Con clave propia: es lo que señalan los tests para
                      // leer quién ocupa el hueco sin depender de en qué
                      // orden queden los textos de la fila.
                      key: ValueKey('nombre-$posicion-$clave'),
                      jugador == null
                          ? textos.elegirJugadorPlaceholder
                          : mayus(jugador!.nombreFicticio),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titular(
                        e,
                        tamano: destacado ? 18 : 15,
                        color: lesionado ? e.textoTenue : e.texto,
                      ),
                    ),
                    if (jugador != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        jugador!.dorsal == null
                            ? etiquetaPosicion(jugador!)
                            : '${etiquetaPosicion(jugador!)} · '
                                  '#${jugador!.dorsal}',
                        style: TextStyle(fontSize: 11, color: e.textoTenue),
                      ),
                    ],
                    if (lineaAviso != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lineaAviso,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.25,
                          color: lesionado ? e.mal : Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (lesionado)
                const IconoLesion()
              else if (fueraDePosicion)
                const Icon(Icons.warning_amber, color: Colors.orange, size: 20)
              else
                Icon(Icons.chevron_right, size: 18, color: e.textoRotulo),
            ],
          ),
        ),
      ),
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
    final ordenados = [...plantilla]
      ..sort((a, b) {
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
                  '(${s.partidosJugados} PJ)',
                ),
        );
      },
    );
  }
}

/// Los tres roles de la rotación: a quién se le da la bola, a quién le toca
/// el mejor del rival, y quién entra primero desde el banquillo.
///
/// Por debajo de este ancho los tres selectores no caben en fila —el
/// desplegable del sexto hombre se quedaba sin sitio para su etiqueta— así
/// que se apilan. Y apilados ocupaban un tercio de la pantalla de un móvil,
/// permanentemente, por tres cosas que se tocan una vez y no se vuelven a
/// mirar: por eso ahí la banda se pliega (ver [_SelectorEstrellas]).
const _anchoMinimoParaTresSelectores = 520.0;

/// El apellido, que es como se reconoce a un jugador de un vistazo.
///
/// En la banda plegada caben tres nombres en una línea de móvil solo si se
/// recortan; el nombre entero obligaría a ponerlos en columna, que es justo
/// lo que se está evitando. Los nombres del dataset son «Nombre Apellido»,
/// así que la última palabra es la buena.
String _apellido(String nombre) {
  final partes = nombre.trim().split(' ');
  return partes.isEmpty ? nombre : partes.last;
}

/// El icono de cada rol. Es lo que lo identifica en la banda plegada, donde
/// no cabe la etiqueta entera; el nombre completo va en el `Semantics`.
const _iconoAtaque = Icons.local_fire_department;
const _iconoDefensa = Icons.shield;
const _iconoSextoHombre = Icons.bolt;

/// Identificadores estables de los tres desplegables de rol, sin traducir.
///
/// Misma idea que las claves de `_HuecoJugador`: la etiqueta que se ve
/// cambia con el idioma, esto no. Y aquí hacen falta además porque señalar
/// uno de los tres por posición no funciona — un finder indexado revienta
/// dentro de `tap`, que por debajo busca el `View` que lo contiene y le
/// aplica el mismo índice.
const claveRolAtaque = Key('rol-estrella-ataque');
const claveRolDefensa = Key('rol-estrella-defensa');
const claveRolSextoHombre = Key('rol-sexto-hombre');

class _SelectorEstrellas extends StatefulWidget {
  final Map<int, Jugador> jugadoresPorId;
  final Set<int> idsAsignados;
  final int? estrellaAtaqueId;
  final int? estrellaDefensaId;

  /// Solo suplentes: un titular no puede ser sexto hombre por definición.
  final Set<int> idsSuplentes;
  final int? sextoHombreId;
  final void Function(int?) onCambiarEstrellaAtaque;
  final void Function(int?) onCambiarEstrellaDefensa;
  final void Function(int?) onCambiarSextoHombre;

  /// Un contador que la pantalla sube cada vez que alguien intenta guardar
  /// con roles sin elegir. Cuando cambia, la banda se abre sola y parpadea.
  ///
  /// Es un contador y no un `bool` a propósito: hace falta poder avisar dos
  /// veces seguidas. Con un booleano, el segundo intento no cambiaría nada
  /// y el parpadeo no se repetiría — justo cuando quien lo necesita es
  /// alguien que ya no se enteró la primera vez.
  final int senalDeAviso;

  const _SelectorEstrellas({
    required this.jugadoresPorId,
    required this.idsAsignados,
    required this.estrellaAtaqueId,
    required this.estrellaDefensaId,
    required this.idsSuplentes,
    required this.sextoHombreId,
    required this.onCambiarEstrellaAtaque,
    required this.onCambiarEstrellaDefensa,
    required this.onCambiarSextoHombre,
    required this.senalDeAviso,
  });

  @override
  State<_SelectorEstrellas> createState() => _SelectorEstrellasState();
}

class _SelectorEstrellasState extends State<_SelectorEstrellas>
    with SingleTickerProviderStateMixin {
  /// El parpadeo del aviso. Es finito —dos idas y vueltas y para— y no un
  /// `repeat()`: una animación que no termina nunca deja colgado a
  /// `pumpAndSettle` en los tests, y en la pantalla sería un semáforo.
  late final AnimationController _parpadeo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _intensidad = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
  ]).animate(_parpadeo);

  @override
  void didUpdateWidget(covariant _SelectorEstrellas anterior) {
    super.didUpdateWidget(anterior);
    if (widget.senalDeAviso != anterior.senalDeAviso) {
      // Abrirla es la mitad del aviso: parpadear una banda plegada diría
      // "aquí hay algo" pero no dejaría verlo ni arreglarlo.
      setState(() => _abierto = true);
      _parpadeo.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _parpadeo.dispose();
    super.dispose();
  }

  /// Solo cuenta en pantalla estrecha: en ancho los tres están siempre a la
  /// vista, porque ahí caben en una fila y no le quitan sitio a nada.
  ///
  /// Arranca plegado aunque los tres roles sean **obligatorios** para
  /// guardar (ver `_rolesCompletos`), y se puede por dos cosas: el resumen
  /// de la banda dice a quién hay puesto y a quién no —plegado no esconde,
  /// dobla— y si alguien intenta guardar sin elegirlos, la banda se abre
  /// sola y parpadea. O sea que no hay forma de quedarse atascado sin
  /// saber por qué.
  bool _abierto = false;

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final candidatos = widget.idsAsignados.toList()
      ..sort(
        (a, b) => widget.jugadoresPorId[a]!.nombreFicticio.compareTo(
          widget.jugadoresPorId[b]!.nombreFicticio,
        ),
      );
    final candidatosSuplentes = widget.idsSuplentes.toList()
      ..sort(
        (a, b) => widget.jugadoresPorId[a]!.nombreFicticio.compareTo(
          widget.jugadoresPorId[b]!.nombreFicticio,
        ),
      );

    // `maxLines: 1` explícito: con la media añadida (Lista 15 punto 6) el
    // texto es más largo, y sin fijarlo a una línea el `Text` intentaba
    // partirlo en dos dentro de la fila de altura fija del desplegable —
    // se recortaba mal y descuadraba el punto donde caía el toque en el
    // test que elige un jugador por su etiqueta.
    DropdownMenuItem<int?> item(int? id, String etiqueta) => DropdownMenuItem(
      value: id,
      child: Text(etiqueta, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    // Lista 15 punto 6: antes cada opción solo enseñaba el nombre, y elegir
    // estrella de ataque o de defensa era mirar apellidos y adivinar. La
    // media que importa depende del rol — ataque para la de ataque,
    // defensa para la de defensa, y las dos para el sexto hombre, que no
    // se especializa en ninguna — así que cada selector trae su propia
    // etiqueta, no una genérica para los tres.
    String etiquetaConAtaque(Jugador j) =>
        '${j.nombreFicticio} · ${t(context).ataque} ${j.atrAtaque}';
    String etiquetaConDefensa(Jugador j) =>
        '${j.nombreFicticio} · ${t(context).defensa} ${j.atrDefensa}';
    String etiquetaConAtaqueYDefensa(Jugador j) =>
        '${j.nombreFicticio} · ${t(context).ataque} ${j.atrAtaque} / '
        '${t(context).defensa} ${j.atrDefensa}';

    Widget selector({
      required Key clave,
      required String etiqueta,
      required Color color,
      required int? valor,
      required List<int> opciones,
      required void Function(int?) onChanged,
      required String Function(Jugador) etiquetaDeOpcion,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mayus(etiqueta),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: rotulo(
              e,
              tamano: 9,
              color: colorLegibleComoTexto(color, context),
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<int?>(
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              filled: true,
              fillColor: e.panel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: e.lineaFuerte),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: e.lineaFuerte),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: color, width: 2),
              ),
            ),
            key: clave,
            initialValue: opciones.contains(valor) ? valor : null,
            items: [
              item(null, t(context).ningunaOpcion),
              ...opciones.map(
                (id) => item(
                  id,
                  etiquetaDeOpcion(widget.jugadoresPorId[id]!),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ],
      );
    }

    final selectores = [
      selector(
        clave: claveRolAtaque,
        etiqueta: t(context).estrellaAtaqueLabel,
        color: colorAtaque,
        valor: widget.estrellaAtaqueId,
        opciones: candidatos,
        onChanged: widget.onCambiarEstrellaAtaque,
        etiquetaDeOpcion: etiquetaConAtaque,
      ),
      selector(
        clave: claveRolDefensa,
        etiqueta: t(context).estrellaDefensaLabel,
        color: colorDefensa,
        valor: widget.estrellaDefensaId,
        opciones: candidatos,
        onChanged: widget.onCambiarEstrellaDefensa,
        etiquetaDeOpcion: etiquetaConDefensa,
      ),
      selector(
        clave: claveRolSextoHombre,
        etiqueta: t(context).sextoHombreLabel,
        color: colorSextoHombre,
        valor: widget.sextoHombreId,
        opciones: candidatosSuplentes,
        onChanged: widget.onCambiarSextoHombre,
        etiquetaDeOpcion: etiquetaConAtaqueYDefensa,
      ),
    ];

    return AnimatedBuilder(
      animation: _intensidad,
      builder: (context, hijo) {
        final fuerza = _intensidad.value;
        return Container(
          decoration: BoxDecoration(
            // El fondo se tiñe hacia el color de aviso y la línea de arriba
            // engorda: son las dos cosas que se ven sin estar mirando ahí.
            color: Color.lerp(e.marcador, e.mal, fuerza * 0.28),
            border: Border(
              top: BorderSide(
                color: Color.lerp(e.lineaFuerte, e.mal, fuerza)!,
                width: 1 + fuerza * 2,
              ),
            ),
          ),
          child: hijo,
        );
      },
      child: LayoutBuilder(
        builder: (context, restricciones) {
          if (restricciones.maxWidth >= _anchoMinimoParaTresSelectores) {
            // En ancho caben los tres en fila y no le quitan sitio a nada:
            // se quedan siempre desplegados, sin banda ni flecha.
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < selectores.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: selectores[i]),
                  ],
                ],
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: () => setState(() => _abierto = !_abierto),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  child: _ResumenDeRoles(
                    jugadoresPorId: widget.jugadoresPorId,
                    estrellaAtaqueId: widget.estrellaAtaqueId,
                    estrellaDefensaId: widget.estrellaDefensaId,
                    sextoHombreId: widget.sextoHombreId,
                    abierto: _abierto,
                  ),
                ),
              ),
              if (_abierto)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < selectores.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        selectores[i],
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// La línea que se ve con la banda plegada: los tres roles con su icono y
/// el apellido de quien los lleva, o un guion si no hay nadie.
///
/// Tiene que decir de un vistazo lo mismo que dirían los tres desplegables
/// abiertos. Si no, plegar sería esconder.
class _ResumenDeRoles extends StatelessWidget {
  final Map<int, Jugador> jugadoresPorId;
  final int? estrellaAtaqueId;
  final int? estrellaDefensaId;
  final int? sextoHombreId;
  final bool abierto;

  const _ResumenDeRoles({
    required this.jugadoresPorId,
    required this.estrellaAtaqueId,
    required this.estrellaDefensaId,
    required this.sextoHombreId,
    required this.abierto,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);

    Widget rol(IconData icono, Color color, int? id, String etiqueta) {
      final jugador = id == null ? null : jugadoresPorId[id];
      final texto = jugador == null ? '—' : _apellido(jugador.nombreFicticio);
      // El icono se queda sin etiqueta escrita por falta de sitio, pero no
      // puede quedarse sin nombre: quien use un lector de pantalla oye el
      // rol entero y a quién lo lleva.
      return Expanded(
        child: Semantics(
          label:
              '$etiqueta: '
              '${jugador?.nombreFicticio ?? textos.ningunaOpcion}',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 15,
                color: colorLegibleComoTexto(color, context),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: jugador == null
                        ? FontWeight.normal
                        : FontWeight.w600,
                    color: jugador == null ? e.textoTenue : e.texto,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        rol(
          _iconoAtaque,
          colorAtaque,
          estrellaAtaqueId,
          textos.estrellaAtaqueLabel,
        ),
        const SizedBox(width: 8),
        rol(
          _iconoDefensa,
          colorDefensa,
          estrellaDefensaId,
          textos.estrellaDefensaLabel,
        ),
        const SizedBox(width: 8),
        rol(
          _iconoSextoHombre,
          colorSextoHombre,
          sextoHombreId,
          textos.sextoHombreLabel,
        ),
        Icon(
          abierto ? Icons.expand_more : Icons.expand_less,
          size: 22,
          color: e.textoTenue,
        ),
      ],
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
            Text(
              t(context).tituloTusPicksDeDraft,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
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
/// sabe si el equipo que estás montando defiende o no defiende. Va arriba y
/// ya no al final de la pantalla porque es justo lo que estás mirando
/// mientras mueves la alineación: abajo había que ir a buscarlo después de
/// cada cambio.
class _FranjaAtaqueDefensa extends StatelessWidget {
  final List<Jugador> titulares;
  final List<Jugador> rotacion;
  final Color acento;

  const _FranjaAtaqueDefensa({
    required this.titulares,
    required this.rotacion,
    required this.acento,
  });

  @override
  Widget build(BuildContext context) {
    if (titulares.isEmpty) return const SizedBox.shrink();
    final e = Estilo.de(context);
    final textos = t(context);
    final quinteto = mediasDe(titulares);
    final todos = mediasDe(rotacion);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: e.marcador,
        border: Border(top: BorderSide(color: acento, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mayus(textos.quintetoInicial),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: rotulo(e, tamano: 9),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '${mayus(textos.rotacionCompleta)}  '
                  '${todos.ataque} / ${todos.defensa}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: rotulo(e, tamano: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _BarraDeMedia(
                  etiqueta: textos.ataque,
                  valor: quinteto.ataque,
                  color: colorAtaque,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _BarraDeMedia(
                  etiqueta: textos.defensa,
                  valor: quinteto.defensa,
                  color: colorDefensa,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Una media del equipo con su barra: el número solo no dice si 82 es mucho
/// o poco, la barra sí.
class _BarraDeMedia extends StatelessWidget {
  final String etiqueta;
  final int valor;
  final Color color;

  const _BarraDeMedia({
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final tinta = colorLegibleComoTexto(color, context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                mayus(etiqueta),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: rotulo(e, tamano: 10, color: tinta),
              ),
            ),
            const SizedBox(width: 6),
            Text('$valor', style: cifra(e, tamano: 20, color: tinta)),
          ],
        ),
        const SizedBox(height: 3),
        LayoutBuilder(
          builder: (context, restricciones) => Container(
            height: 5,
            color: e.lineaFuerte,
            alignment: Alignment.centerLeft,
            child: Container(
              // La escala arranca en 40 y no en 0: por debajo de ahí no hay
              // jugadores, y con 0 todas las barras salían casi llenas y sin
              // diferencia visible entre un equipo bueno y uno malo.
              width:
                  restricciones.maxWidth * ((valor - 40) / 60).clamp(0.0, 1.0),
              height: 5,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// La barra de arriba: color del equipo, monograma de fondo y las dos
/// pestañas.
class _BarraDeEquipo extends StatelessWidget {
  final String equipo;
  final EquipoInfo info;
  final VoidCallback onPicks;

  const _BarraDeEquipo({
    required this.equipo,
    required this.info,
    required this.onPicks,
  });

  @override
  Widget build(BuildContext context) {
    final textos = t(context);
    final fondo = info.colorPrimario;
    final sobre = textoSobre(fondo);
    final acento = acentoDeEquipo(fondo, info.colorSecundario);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [fondo, const Color(0xFF05070B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: CunaEsquina(color: acento, tamano: 110),
          ),
          Positioned(
            top: 0,
            right: -6,
            child: MonogramaFantasma(texto: equipo, tamano: 104),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Row(
                    children: [
                      BackButton(color: sobre),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mayus('${info.ciudad} · ${textos.tuEquipo}'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: acento,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              // El apodo del club y no "Tu equipo" otra vez:
                              // el rótulo de arriba ya dice dónde estás, y
                              // así la barra manda identidad igual que la
                              // del menú principal.
                              mayus(info.apodo),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: familiaTitular,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                color: sobre,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.style),
                        color: sobre,
                        tooltip: textos.tusPicksDeDraft,
                        onPressed: onPicks,
                      ),
                    ],
                  ),
                ),
                TabBar(
                  indicatorColor: acento,
                  indicatorWeight: 3,
                  labelColor: sobre,
                  unselectedLabelColor: textoSecundarioSobre(fondo),
                  labelStyle: const TextStyle(
                    fontFamily: familiaTitular,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: familiaTitular,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                  tabs: [
                    Tab(text: mayus(textos.pestanaAlineacion)),
                    Tab(text: mayus(textos.pestanaEstadisticas)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasoMinutos extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;

  const _PasoMinutos({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Material(
      color: e.panelSuave,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border.all(color: e.lineaFuerte)),
          child: Icon(icono, size: 18, color: e.texto),
        ),
      ),
    );
  }
}
