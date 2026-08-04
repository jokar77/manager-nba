import 'package:drift/drift.dart';

import 'almacenamiento_nativo.dart'
    if (dart.library.js_interop) 'almacenamiento_web.dart' as impl;

/// Cómo se guarda una partida, según dónde se esté jugando.
///
/// En escritorio y en móvil cada partida es un fichero SQLite en la carpeta
/// de documentos. En el navegador no hay ficheros: es SQLite compilado a
/// WebAssembly guardando en el almacenamiento del propio navegador
/// (OPFS o IndexedDB, lo mejor que soporte). Esto es lo que permite jugar
/// desde un iPhone añadiendo la web a la pantalla de inicio, sin Mac y sin
/// App Store.
///
/// Todo lo de arriba —repositorios, pantallas, tests— no se entera de la
/// diferencia: pide una conexión por nombre y ya está.

/// Abre (creando si hace falta) la base de datos llamada [nombre].
QueryExecutor abrirBaseDeDatos(String nombre) => impl.abrirBaseDeDatos(nombre);

/// ¿Existe ya una partida guardada con ese nombre? No la abre.
Future<bool> existeBaseDeDatos(String nombre) =>
    impl.existeBaseDeDatos(nombre);

/// Deja constancia de que la partida [nombre] existe.
///
/// En nativo no hace nada: el fichero está en el disco y preguntarle al
/// sistema si existe es instantáneo. En el navegador no hay ficheros, y
/// averiguar si una base existe obliga a abrirla — demasiado caro para
/// hacerlo con las tres ranuras cada vez que se pinta el menú de inicio—,
/// así que se lleva la cuenta aparte.
void apuntarQueExiste(String nombre) => impl.apuntarQueExiste(nombre);

/// Borra la partida [nombre]. No falla si no existía.
Future<void> borrarBaseDeDatos(String nombre) => impl.borrarBaseDeDatos(nombre);

/// Renombra [origen] a [destino]. Se usa una sola vez, para rescatar la
/// partida de las versiones que no tenían ranuras.
Future<void> renombrarBaseDeDatos(String origen, String destino) =>
    impl.renombrarBaseDeDatos(origen, destino);

/// Una base de datos que solo vive en memoria, para los tests.
///
/// Está aquí y no en el fichero de los tests porque `AlmacenDeSlotsEnMemoria`
/// vive en `lib/`, y con `NativeDatabase.memory()` escrito directamente allí
/// la compilación web se caía entera: arrastraba `dart:ffi`, que en un
/// navegador no existe. Los tests corren en la máquina virtual de Dart, así
/// que en web esto no se llama nunca.
QueryExecutor baseDeDatosEnMemoria() => impl.baseDeDatosEnMemoria();

/// Un valor suelto que sobrevive entre sesiones y no merece una tabla: hoy
/// solo la última ranura en la que se jugó.
Future<String?> leerPreferencia(String clave) => impl.leerPreferencia(clave);

Future<void> guardarPreferencia(String clave, String valor) =>
    impl.guardarPreferencia(clave, valor);
