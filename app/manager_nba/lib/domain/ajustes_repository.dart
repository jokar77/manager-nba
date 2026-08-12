import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import '../i18n/textos.dart';

Future<bool> leerModoOscuro(AppDatabase db) async {
  final fila =
      await (db.select(db.ajustes)..where((t) => t.id.equals(0))).getSingleOrNull();
  return fila?.modoOscuro ?? false;
}

Future<void> guardarModoOscuro(AppDatabase db, bool activo) async {
  await db.into(db.ajustes).insertOnConflictUpdate(
        AjustesCompanion(id: const Value(0), modoOscuro: Value(activo)),
      );
}

/// El idioma elegido. Español si la partida es anterior al selector o si el
/// código guardado ya no existe (ver [Idioma.desdeCodigo]).
Future<Idioma> leerIdioma(AppDatabase db) async {
  final fila = await (db.select(db.ajustes)..where((t) => t.id.equals(0)))
      .getSingleOrNull();
  return Idioma.desdeCodigo(fila?.idioma);
}

Future<void> guardarIdioma(AppDatabase db, Idioma idioma) async {
  await db.into(db.ajustes).insertOnConflictUpdate(
        AjustesCompanion(id: const Value(0), idioma: Value(idioma.codigo)),
      );
}
