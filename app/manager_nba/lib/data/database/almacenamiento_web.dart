import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:web/web.dart' as web;

/// Navegador: SQLite compilado a WebAssembly, guardando en el
/// almacenamiento del propio navegador. `WasmDatabase.open` elige sola la
/// mejor forma disponible —OPFS si el navegador la soporta, IndexedDB si
/// no— así que aquí no hay que decidir nada.
///
/// Los dos ficheros que hacen falta viven en `web/`: `sqlite3.wasm` (el
/// motor) y `drift_worker.js` (el worker que lo saca del hilo principal
/// para que simular una temporada no congele la pantalla). Están fijados a
/// las mismas versiones que las del `pubspec.lock`.
const _rutaWasm = 'sqlite3.wasm';
const _rutaWorker = 'drift_worker.js';

QueryExecutor abrirBaseDeDatos(String nombre) {
  return LazyDatabase(() async {
    final resultado = await WasmDatabase.open(
      databaseName: _nombreDeBase(nombre),
      sqlite3Uri: Uri.parse(_rutaWasm),
      driftWorkerUri: Uri.parse(_rutaWorker),
    );
    return resultado.resolvedExecutor;
  });
}

/// El nombre que ve el navegador. Se le quita la extensión `.sqlite`, que
/// aquí no pinta nada: no hay fichero.
String _nombreDeBase(String nombre) =>
    nombre.endsWith('.sqlite') ? nombre.substring(0, nombre.length - 7) : nombre;

/// Saber si una partida existe SIN abrirla. `WasmDatabase.probe` lo
/// responde, pero abre la base para averiguarlo, y hacerlo por cada ranura
/// cada vez que se pinta el menú de inicio es caro. Se lleva la cuenta
/// aparte en `localStorage`, que es instantáneo.
///
/// La lista es la fuente de verdad de qué ranuras hay ocupadas, así que
/// [abrirBaseDeDatos] no la toca: la apunta quien crea la partida (ver
/// `AlmacenDeSlotsEnNavegador.abrir`).
const _clavePartidas = 'manager_nba_partidas';

Set<String> _partidasApuntadas() {
  final crudo = web.window.localStorage.getItem(_clavePartidas);
  if (crudo == null || crudo.isEmpty) return {};
  return crudo.split(',').where((n) => n.isNotEmpty).toSet();
}

void _apuntarPartidas(Set<String> nombres) =>
    web.window.localStorage.setItem(_clavePartidas, nombres.join(','));

/// Deja constancia de que [nombre] existe. Lo llama quien abre una ranura.
void apuntarQueExiste(String nombre) {
  final partidas = _partidasApuntadas();
  if (partidas.add(nombre)) _apuntarPartidas(partidas);
}

Future<bool> existeBaseDeDatos(String nombre) async =>
    _partidasApuntadas().contains(nombre);

Future<void> borrarBaseDeDatos(String nombre) async {
  final partidas = _partidasApuntadas();
  if (partidas.remove(nombre)) _apuntarPartidas(partidas);

  // Y el almacenamiento de verdad, o la ranura "vacía" volvería a abrirse
  // con la partida vieja dentro. Hay que preguntarle al navegador dónde la
  // tiene guardada (OPFS o IndexedDB) antes de poder borrarla.
  final base = _nombreDeBase(nombre);
  final sonda = await WasmDatabase.probe(
    sqlite3Uri: Uri.parse(_rutaWasm),
    driftWorkerUri: Uri.parse(_rutaWorker),
    databaseName: base,
  );
  for (final existente in sonda.existingDatabases) {
    if (existente.$2 == base) await sonda.deleteDatabase(existente);
  }
}

/// En el navegador no hay partidas de versiones anteriores que rescatar
/// (esto es lo primero que se juega aquí), así que no hay nada que renombrar.
Future<void> renombrarBaseDeDatos(String origen, String destino) async {}

/// Los tests no corren en un navegador, así que esto no se llama nunca aquí.
/// Existe solo para que la versión web compile (ver la fachada).
QueryExecutor baseDeDatosEnMemoria() => throw UnsupportedError(
    'Las bases en memoria son cosa de los tests, que no corren en web.');

Future<String?> leerPreferencia(String clave) async =>
    web.window.localStorage.getItem(clave);

Future<void> guardarPreferencia(String clave, String valor) async =>
    web.window.localStorage.setItem(clave, valor);
