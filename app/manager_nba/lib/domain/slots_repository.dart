import '../data/database/almacenamiento.dart';
import '../data/database/app_database.dart';
import 'franquicia_repository.dart';
import 'modo_carrera_repository.dart';
import 'nueva_temporada_repository.dart';
import 'permisos.dart';

/// Ranuras de guardado. Tres carreras en paralelo: empezar una partida nueva
/// ya no borra la que tenías a medias.
const numeroDeSlots = 3;

/// Cada partida vive en su propio fichero SQLite. Es lo que hace que las
/// ranuras sean independientes de verdad —plantillas, calendario, palmarés,
/// leyendas retiradas— sin tener que meter un "slot" en cada tabla del
/// esquema.
String ficheroDeSlot(int slot) => 'manager_nba_slot$slot.sqlite';

/// Los ajustes (tema claro/oscuro, idioma) son de la app, no de la partida,
/// así que viven aparte y sobreviven a borrar cualquier ranura.
const ficheroDeAjustes = 'manager_nba_ajustes.sqlite';

/// El fichero único que usaban las versiones sin ranuras. Si sigue ahí, la
/// partida en curso se conserva pasándola a la ranura 1.
const ficheroSinSlots = 'manager_nba.sqlite';

/// En qué ranura estabas la última vez, para que "Continuar" no te haga
/// elegir. Va en un fichero de texto suelto y no en una tabla a propósito:
/// meterlo en el esquema obligaría a subir la versión de la base de datos, y
/// con la estrategia de migración actual eso borra todas las partidas.
const ficheroUltimaRanura = 'manager_nba_ultima_ranura.txt';

// ---------------------------------------------------------------------------
// De dónde salen las partidas
// ---------------------------------------------------------------------------

/// Dónde se guardan las partidas. En la app son ficheros SQLite en la
/// carpeta de documentos; en los tests se sustituye por bases en memoria,
/// que es lo que permite probar el menú de partidas y el flujo completo sin
/// tocar el disco ni depender de `path_provider`.
abstract class AlmacenDeSlots {
  Future<bool> existe(int slot);

  /// Abre la ranura. Quien la abre es responsable de cerrarla con [cerrar].
  AppDatabase abrir(int slot);

  Future<void> cerrar(AppDatabase db);
  Future<void> borrar(int slot);

  /// La base de ajustes de la app, común a todas las ranuras.
  AppDatabase ajustes();

  /// La última ranura en la que se jugó, o null si no consta ninguna.
  Future<int?> leerUltimaRanura();

  /// Anota [slot] como la ranura en la que se está jugando.
  Future<void> guardarUltimaRanura(int slot);

  /// Rescata la partida de las versiones sin ranuras, si la hubiera.
  Future<void> migrarPartidaSinSlots();
}

/// El almacén en uso. La app lo deja como está; los tests lo sustituyen.
AlmacenDeSlots almacenDeSlots = AlmacenDeSlotsEnDisco();

/// El almacén de verdad: ficheros SQLite en escritorio y móvil, y el
/// almacenamiento del navegador en web. La diferencia la resuelve
/// `data/database/almacenamiento.dart`; aquí solo se habla de ranuras.
///
/// Se sigue llamando "en disco" para distinguirlo del de memoria de los
/// tests, aunque en el navegador no haya disco ninguno.
class AlmacenDeSlotsEnDisco implements AlmacenDeSlots {
  // Cacheada: no es solo la pantalla de ajustes quien la pide — el palmarés
  // compartido (ver campeones_repository.dart) también vive aquí, y eso
  // puede consultarse muchas veces en una sesión. Sin cachear, cada llamada
  // abriría una conexión (y un isolate de fondo) nueva sobre el mismo
  // fichero.
  AppDatabase? _ajustes;

  @override
  Future<bool> existe(int slot) => existeBaseDeDatos(ficheroDeSlot(slot));

  @override
  AppDatabase abrir(int slot) {
    // Abrir una ranura es lo que la crea, así que es aquí donde queda
    // constancia de que existe (en web hace falta, en nativo no hace nada).
    apuntarQueExiste(ficheroDeSlot(slot));
    return AppDatabase.enFichero(ficheroDeSlot(slot));
  }

  @override
  Future<void> cerrar(AppDatabase db) => db.close();

  @override
  Future<void> borrar(int slot) => borrarBaseDeDatos(ficheroDeSlot(slot));

  @override
  AppDatabase ajustes() =>
      _ajustes ??= AppDatabase.enFichero(ficheroDeAjustes);

  @override
  Future<int?> leerUltimaRanura() async {
    final guardado = await leerPreferencia(ficheroUltimaRanura);
    if (guardado == null) return null;
    final slot = int.tryParse(guardado.trim());
    if (slot == null || slot < 1 || slot > numeroDeSlots) return null;
    return slot;
  }

  @override
  Future<void> guardarUltimaRanura(int slot) =>
      guardarPreferencia(ficheroUltimaRanura, '$slot');

  /// La partida única de las versiones sin ranuras pasa a ser la ranura 1, y
  /// solo si esa ranura está libre: una partida que ya existiera ahí no se
  /// pisa.
  @override
  Future<void> migrarPartidaSinSlots() async {
    if (!await existeBaseDeDatos(ficheroSinSlots)) return;
    if (await existeBaseDeDatos(ficheroDeSlot(1))) return;
    await renombrarBaseDeDatos(ficheroSinSlots, ficheroDeSlot(1));
    apuntarQueExiste(ficheroDeSlot(1));
  }
}

/// Ranuras en memoria, para los tests: se comportan como las de disco
/// (existen en cuanto se abren, se pueden borrar) pero no dejan nada
/// escrito. Cerrar una ranura no la destruye — igual que en disco, el
/// fichero sigue ahí— así que [cerrar] no hace nada.
class AlmacenDeSlotsEnMemoria implements AlmacenDeSlots {
  final Map<int, AppDatabase> _abiertas = {};
  AppDatabase? _ajustes;

  @override
  Future<bool> existe(int slot) async => _abiertas.containsKey(slot);

  @override
  AppDatabase abrir(int slot) => _abiertas.putIfAbsent(
      slot, () => AppDatabase.forTesting(baseDeDatosEnMemoria()));

  @override
  Future<void> cerrar(AppDatabase db) async {}

  @override
  Future<void> borrar(int slot) async {
    final db = _abiertas.remove(slot);
    await db?.close();
  }

  @override
  AppDatabase ajustes() =>
      _ajustes ??= AppDatabase.forTesting(baseDeDatosEnMemoria());

  int? _ultimaRanura;

  @override
  Future<int?> leerUltimaRanura() async => _ultimaRanura;

  @override
  Future<void> guardarUltimaRanura(int slot) async => _ultimaRanura = slot;

  @override
  Future<void> migrarPartidaSinSlots() async {}

  /// Cierra todo lo abierto. Para el tearDown de los tests.
  Future<void> cerrarTodo() async {
    for (final db in _abiertas.values) {
      await db.close();
    }
    _abiertas.clear();
    await _ajustes?.close();
    _ajustes = null;
  }
}

// ---------------------------------------------------------------------------
// Consulta de ranuras
// ---------------------------------------------------------------------------

/// Abre (creándola si hace falta) la base de datos de una ranura.
AppDatabase abrirSlot(int slot) => almacenDeSlots.abrir(slot);

/// Cierra una ranura abierta con [abrirSlot].
Future<void> cerrarSlot(AppDatabase db) => almacenDeSlots.cerrar(db);

/// La base de datos compartida entre partidas: los ajustes (tema, idioma) y
/// el palmarés de campeones (ver `campeones_repository.dart`). Cualquier
/// dato que sea un logro tuyo y no de una ranura en concreto vive aquí.
AppDatabase abrirAjustes() => almacenDeSlots.ajustes();

/// Rescata la partida de las versiones anteriores, que no tenían ranuras.
Future<void> migrarPartidaSinSlots() => almacenDeSlots.migrarPartidaSinSlots();

/// La ranura que abre "Continuar": la última en la que jugaste, siempre que
/// siga teniendo una partida dentro. Si no consta ninguna (o la borraste),
/// se cae a la primera ocupada que haya, y solo devuelve null cuando de
/// verdad no hay ninguna partida empezada.
Future<int?> ranuraParaContinuar() async {
  final resumenes = await leerResumenDeSlots();
  final ocupadas = resumenes.where((r) => r.ocupada).map((r) => r.numero);
  if (ocupadas.isEmpty) return null;

  final ultima = await almacenDeSlots.leerUltimaRanura();
  if (ultima != null && ocupadas.contains(ultima)) return ultima;
  return ocupadas.first;
}

/// Anota en qué ranura se está jugando, para que "Continuar" la recuerde.
Future<void> marcarRanuraComoUsada(int slot) =>
    almacenDeSlots.guardarUltimaRanura(slot);

/// Borra una ranura entera.
Future<void> borrarSlot(int slot) => almacenDeSlots.borrar(slot);

/// Lo que se enseña de una ranura en el menú de inicio sin tener que
/// entrar en ella.
class ResumenSlot {
  final int numero;

  /// null si la ranura está vacía O es de Modo Carrera. El resto de campos
  /// de franquicia solo tienen sentido cuando [equipo] no es null.
  final String? equipo;
  final int temporada;
  final int anioInicio;
  final int victorias;
  final int derrotas;
  final int titulos;

  /// La carrera de esta ranura, si es de Modo Carrera y no de franquicia.
  /// [equipo] y [carrera] nunca son distintos de null a la vez: una ranura
  /// es de un modo o del otro.
  final EstadoCarrera? carrera;

  /// Si esta ranura es de las que solo trae la versión completa. Se enseña
  /// igualmente, con su candado: esconderla dejaría al jugador sin saber
  /// que existe, y lo que se vende aquí es comodidad, no un secreto.
  final bool bloqueada;

  const ResumenSlot({
    required this.numero,
    this.equipo,
    this.temporada = 1,
    this.anioInicio = 0,
    this.victorias = 0,
    this.derrotas = 0,
    this.titulos = 0,
    this.carrera,
    this.bloqueada = false,
  });

  bool get ocupada => equipo != null || carrera != null;

  /// "2027-28 · temporada 3", para la ficha de la ranura.
  String get etiquetaTemporada =>
      '${etiquetaDeTemporada(anioInicio)} · temporada $temporada';
}

/// El estado de las ranuras. Una ranura que no existe se devuelve vacía sin
/// abrir nada: así consultar el menú no crea partidas que nadie ha empezado.
Future<List<ResumenSlot>> leerResumenDeSlots() async {
  final disponibles = ranurasDisponibles();
  final resumenes = <ResumenSlot>[];
  for (var slot = 1; slot <= numeroDeSlots; slot++) {
    if (slot > disponibles) {
      // Bloqueada: no se abre su fichero. Leerla sería trabajo para
      // enseñar una partida que de todas formas no se puede tocar.
      resumenes.add(ResumenSlot(numero: slot, bloqueada: true));
      continue;
    }
    resumenes.add(await leerResumenDeSlot(slot));
  }
  return resumenes;
}

/// Cuántas ranuras puede usar este jugador: las tres en la versión
/// completa, solo la primera en la gratuita.
///
/// No se le pasa temporada a [Permisos.puede] a propósito: este menú se
/// pinta ANTES de abrir ninguna partida, así que no hay ninguna temporada
/// en curso contra la que medir un desbloqueo por vídeo. Y tampoco tendría
/// sentido que la hubiera: una ranura que caduca al año siguiente sería
/// una forma muy cara de perder una carrera.
int ranurasDisponibles() =>
    permisos.puede(Funcion.ranurasExtra) ? numeroDeSlots : 1;

Future<ResumenSlot> leerResumenDeSlot(int slot) async {
  if (!await almacenDeSlots.existe(slot)) return ResumenSlot(numero: slot);

  final db = abrirSlot(slot);
  try {
    final equipo = await leerEquipoFranquicia(db);
    if (equipo == null) {
      final carrera = await leerPartidaCarrera(db);
      return ResumenSlot(numero: slot, carrera: carrera);
    }

    final temporada = await leerTemporada(db);
    final record = await (db.select(db.resultadoTemporada)
          ..where((t) => t.equipo.equals(equipo)))
        .getSingleOrNull();
    final titulos = await db.select(db.historialCampeones).get();

    return ResumenSlot(
      numero: slot,
      equipo: equipo,
      temporada: temporada.numero,
      anioInicio: temporada.anioInicio,
      victorias: record?.victorias ?? 0,
      derrotas: record?.derrotas ?? 0,
      titulos: titulos
          .where((c) => c.equipo == equipo && c.logradoPorUsuario)
          .length,
    );
  } finally {
    await cerrarSlot(db);
  }
}

/// La primera ranura libre, o null si están las tres ocupadas.
Future<int?> primeraRanuraLibre() async {
  for (final resumen in await leerResumenDeSlots()) {
    if (!resumen.ocupada) return resumen.numero;
  }
  return null;
}
