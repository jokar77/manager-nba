import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

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
