import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/database/app_database.dart';
import 'dorsales_repository.dart';
import 'legado_historico_repository.dart' show codigoPorNombreReal;

const _rutaCamisetasFuturas = 'assets/data/camisetas_futuras.json';

/// Números que una franquicia retiraría de verdad a un jugador que TODAVÍA
/// no los tiene retirados: Westbrook y el 0 de Oklahoma, Durant y el 35 de
/// Golden State... Son los que faltaban.
///
/// El dorsal que lleva un jugador dentro de la partida no sirve para esto:
/// se le sortea al importarlo si el dataset no trae el suyo, y se le vuelve
/// a sortear cada vez que cambia de equipo y su número está cogido. Así es
/// como a Westbrook le salía un 34 en Oklahoma.
///
/// El fichero es solo una ayuda para acertar el número de los que ya son
/// conocidos: no decide quién merece la camiseta. Eso lo sigue decidiendo la
/// carrera de cada uno dentro de tu partida, así que un Wembanyama que se
/// pase diez años en San Antonio tendrá la suya igual sin estar en esta
/// lista.
Map<String, int>? _numerosFuturos;

Future<Map<String, int>> _cargarNumerosFuturos() async {
  final cache = _numerosFuturos;
  if (cache != null) return cache;

  final mapa = <String, int>{};
  try {
    final crudo = await rootBundle.loadString(_rutaCamisetasFuturas);
    for (final entrada in jsonDecode(crudo) as List<dynamic>) {
      final fila = entrada as Map<String, dynamic>;
      final equipo = codigoPorNombreReal[fila['team'] as String];
      final numero = int.tryParse((fila['number'] as String).trim());
      if (equipo == null || numero == null) continue;
      mapa['$equipo|${fila['name']}'] = numero;
    }
  } catch (_) {
    // Esto es un lujo, no un requisito: si el fichero no se puede leer se
    // sigue con el dorsal que lleve el jugador. Lo que no puede pasar es
    // que un cambio de temporada entero reviente por un JSON de apoyo.
  }
  return _numerosFuturos = mapa;
}

/// El número que [nombreReal] llevaría en la camiseta que le retirase
/// [equipo], según la lista de candidatos. Null si no está.
Future<int?> numeroFuturoConocido({
  required String equipo,
  required String nombreReal,
}) async {
  if (nombreReal.isEmpty) return null;
  return (await _cargarNumerosFuturos())['$equipo|$nombreReal'];
}

/// El número real ya importado (ver legado_historico_repository.dart) que
/// [nombreReal] llevó en [equipo], si el juego ya lo trae de antes — esas
/// filas son hechos reales (jugadorId negativo), no lo que la simulación le
/// haya asignado de dorsal en su fichaje más reciente, que puede no tener
/// nada que ver si acabó traspasado a otro equipo antes de retirarse.
Future<int?> numeroRealYaConocido(
  AppDatabase db, {
  required String equipo,
  required String nombreReal,
}) async {
  if (nombreReal.isEmpty) return null;
  final fila = await (db.select(db.camisetasRetiradas)
        ..where((t) =>
            t.jugadorId.isSmallerThanValue(0) &
            t.equipo.equals(equipo) &
            t.nombreJugador.equals(nombreReal)))
      .getSingleOrNull();
  return fila?.dorsal;
}

/// Retira la camiseta de [jugadorId] en [equipo]: ese dorsal queda
/// bloqueado para siempre en esa franquicia. Si alguien en plantilla
/// llevaba puesto justo ese número (coincidencia rara, pero posible), se le
/// reparte uno nuevo en el acto — nadie puede vestir un dorsal ya retirado.
///
/// El número que se guarda es el real ya conocido de antes (ver
/// [numeroRealYaConocido]) si lo hay — el equipo que retira la camiseta no
/// siempre es donde jugó por última vez dentro de tu partida, así que su
/// dorsal actual puede no ser el correcto — y si no, el que lleva puesto
/// ahora mismo.
///
/// Idempotente: volver a llamarla con el mismo jugador Y el mismo equipo no
/// duplica nada. Con OTRO equipo sí retira otra camiseta, que es lo que
/// tiene que pasar: una leyenda de varias franquicias cuelga del techo en
/// todas ellas. Antes la comprobación no miraba el equipo, así que en cuanto
/// LeBron tenía la suya en un sitio, Miami y los Lakers se quedaban sin
/// homenaje.
Future<void> retirarCamiseta(
  AppDatabase db, {
  required String equipo,
  required int jugadorId,
  required int temporada,
}) async {
  final yaRetirada = await (db.select(db.camisetasRetiradas)
        ..where((t) => t.jugadorId.equals(jugadorId) & t.equipo.equals(equipo)))
      .getSingleOrNull();
  if (yaRetirada != null) return;

  final jugador = await (db.select(db.jugadores)
        ..where((t) => t.id.equals(jugadorId)))
      .getSingleOrNull();
  if (jugador == null || jugador.dorsal == null) return;

  // Por este orden: el número que esa franquicia ya retiró de verdad, el
  // que le retiraría si le tocara (lista de candidatos) y, solo si no hay
  // ninguna de las dos cosas, el que lleve puesto en tu partida.
  final numeroReal = await numeroRealYaConocido(db,
          equipo: equipo, nombreReal: jugador.nombreReal) ??
      await numeroFuturoConocido(
          equipo: equipo, nombreReal: jugador.nombreReal);

  await db.into(db.camisetasRetiradas).insert(
        CamisetasRetiradasCompanion.insert(
          equipo: equipo,
          jugadorId: jugadorId,
          nombreJugador: jugador.nombreFicticio,
          dorsal: numeroReal ?? jugador.dorsal!,
          temporada: temporada,
        ),
      );

  await asignarDorsalesQueFalten(db);
}

/// Las camisetas retiradas de [equipo], por número.
Future<List<CamisetaRetirada>> leerCamisetasRetiradas(
  AppDatabase db,
  String equipo,
) {
  return (db.select(db.camisetasRetiradas)
        ..where((t) => t.equipo.equals(equipo))
        ..orderBy([(t) => OrderingTerm.asc(t.dorsal)]))
      .get();
}

/// Todas las camisetas retiradas de la liga, agrupadas por equipo. La CPU
/// también retira camisetas (ver nueva_temporada_repository.dart), así que
/// esto no es solo tu franquicia.
Future<Map<String, List<CamisetaRetirada>>> leerCamisetasRetiradasPorEquipo(
  AppDatabase db,
) async {
  final todas = await (db.select(db.camisetasRetiradas)
        ..orderBy([
          (t) => OrderingTerm.asc(t.equipo),
          (t) => OrderingTerm.asc(t.dorsal),
        ]))
      .get();

  final porEquipo = <String, List<CamisetaRetirada>>{};
  for (final c in todas) {
    porEquipo.putIfAbsent(c.equipo, () => []).add(c);
  }
  return porEquipo;
}
