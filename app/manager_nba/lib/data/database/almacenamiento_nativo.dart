import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Escritorio y móvil: cada partida es un fichero SQLite en la carpeta de
/// documentos de la app. Es el camino de siempre, sin cambios — el puerto a
/// web no toca nada de esto.

QueryExecutor abrirBaseDeDatos(String nombre) {
  return LazyDatabase(() async {
    final file = File(await _ruta(nombre));
    return NativeDatabase.createInBackground(file);
  });
}

Future<bool> existeBaseDeDatos(String nombre) async =>
    File(await _ruta(nombre)).existsSync();

/// Nada que apuntar: el fichero en disco ya es la prueba de que existe.
void apuntarQueExiste(String nombre) {}

QueryExecutor baseDeDatosEnMemoria() => NativeDatabase.memory();

Future<void> borrarBaseDeDatos(String nombre) async {
  final fichero = File(await _ruta(nombre));
  if (fichero.existsSync()) await fichero.delete();
}

Future<void> renombrarBaseDeDatos(String origen, String destino) async {
  final antiguo = File(await _ruta(origen));
  if (!antiguo.existsSync()) return;
  await antiguo.rename(await _ruta(destino));
}

Future<String?> leerPreferencia(String clave) async {
  final fichero = File(await _ruta(clave));
  if (!fichero.existsSync()) return null;
  return (await fichero.readAsString()).trim();
}

Future<void> guardarPreferencia(String clave, String valor) async {
  await File(await _ruta(clave)).writeAsString(valor);
}

Future<String> _ruta(String nombre) async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, nombre);
}
