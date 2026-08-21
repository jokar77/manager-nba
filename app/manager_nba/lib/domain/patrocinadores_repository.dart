import 'package:drift/drift.dart' show Value;

import '../data/database/app_database.dart';
// Solo para dejar la etiqueta en español guardada junto al efecto, igual
// que hace `eventos_narrativos_repository.dart`: lo que se ENSEÑA se
// traduce en pantalla con el idioma que tenga puesto el usuario.
import '../i18n/textos_eventos.dart';
import 'eventos_narrativos.dart' show EfectoDeEvento;
import 'patrocinadores.dart';

/// Las categorías de patrocinio que tienes activas ahora mismo.
Future<Set<String>> leerPatrociniosActivos(AppDatabase db) async {
  final filas = await db.select(db.patrociniosActivos).get();
  return filas.map((f) => f.categoria).toSet();
}

/// Activa o desactiva el patrocinio de [categoria]. Sin comprobar contra el
/// catálogo: si [categoria] no tiene candidato para tu equipo (no debería
/// pasar, cada equipo tiene las cuatro), simplemente no aporta nada al
/// activarla — es la capa de UI la que solo ofrece categorías con
/// candidato real.
Future<void> alternarPatrocinio(
  AppDatabase db,
  String categoria, {
  required bool activo,
}) async {
  // Se borra primero y no con insertOnConflictUpdate: el conflicto que
  // importa es sobre `categoria` (única por fila), pero drift genera el
  // upsert sobre la clave primaria `id` — con `id` autoincremental esa
  // fila siempre es nueva, así que el upsert nunca detecta el duplicado y
  // la restricción UNIQUE de la tabla salta como un error de verdad en
  // vez de actualizar.
  await (db.delete(db.patrociniosActivos)
        ..where((t) => t.categoria.equals(categoria)))
      .go();
  if (activo) {
    await db.into(db.patrociniosActivos).insert(
        PatrociniosActivosCompanion.insert(categoria: categoria));
  }
}

/// El margen de tope salarial que dan tus patrocinadores activos esta
/// temporada. Lo suma [espacioSalarial], igual que el margen de los
/// eventos narrativos — son dos fuentes de dinero distintas que se
/// acumulan, no se pisan.
Future<int> bonusSalarialDePatrocinadores(
  AppDatabase db, {
  required String equipoUsuario,
}) async {
  final activas = await leerPatrociniosActivos(db);
  var total = 0;
  for (final categoria in activas) {
    total += patrocinadorDe(equipoUsuario, categoria)?.bonusSalarial ?? 0;
  }
  return total;
}

/// Desactiva todos los patrocinios: se llama al empezar una franquicia
/// nueva y en cada cambio de temporada — el patrocinio es una decisión de
/// esta temporada, no algo que se herede sola año tras año.
Future<void> limpiarPatrocinios(AppDatabase db) async {
  await db.delete(db.patrociniosActivos).go();
}

/// La clave con la que se guardan los compromisos en `EfectosDeEvento`.
/// Comparte tabla con los eventos narrativos a propósito (ver
/// [CompromisoDePatrocinio]), y esta clave es lo que permite distinguirlos
/// para volver a calcularlos sin tocar los de los eventos.
const claveDeCompromisoDePatrocinio = 'patrocinio';

/// Deja en el vestuario lo que piden los patrocinadores activos.
///
/// Se llama al confirmar la pantalla de patrocinadores, y es idempotente:
/// borra primero los compromisos que hubiera puesto una confirmación
/// anterior. Sin eso, volver a entrar en la pantalla iría acumulando
/// compromisos encima de los de antes.
///
/// Solo toca las filas con [claveDeCompromisoDePatrocinio]: una bronca de
/// vestuario que estuviera corriendo no se ve afectada.
Future<void> aplicarCompromisosDePatrocinio(
  AppDatabase db, {
  required String equipoUsuario,
}) async {
  await (db.delete(db.efectosDeEvento)
        ..where((t) => t.clave.equals(claveDeCompromisoDePatrocinio)))
      .go();

  final activas = await leerPatrociniosActivos(db);
  for (final categoria in activas) {
    if (patrocinadorDe(equipoUsuario, categoria) == null) continue;
    final compromiso = compromisoPorCategoria[categoria];
    if (compromiso == null) continue;
    // Por el mismo camino que un efecto de evento: acotado a los topes
    // medidos, para que un compromiso nuevo no pueda valer más que todo el
    // sistema de entrenadores junto.
    final efecto = EfectoDeEvento(
      clave: compromiso.clave,
      factor: compromiso.factor,
      partidos: compromiso.partidos,
    ).acotado;
    await db.into(db.efectosDeEvento).insert(EfectosDeEventoCompanion.insert(
          clave: claveDeCompromisoDePatrocinio,
          claveEfecto: Value(efecto.clave),
          etiqueta: const EventosEs().etiquetaDeEfecto(efecto.clave) ??
              efecto.clave,
          factor: efecto.factor,
          partidosRestantes: efecto.partidos,
        ));
  }
}
