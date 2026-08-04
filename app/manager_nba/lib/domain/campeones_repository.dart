import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'franquicia_repository.dart';
import 'nueva_temporada_repository.dart';
import 'slots_repository.dart';

/// Apunta un título en el palmarés. [tipo] es 'nba' o 'ist'.
///
/// Se guarda dos veces, porque la pregunta "¿quién ha ganado esto?" tiene
/// dos respuestas distintas según quién pregunte:
/// - En la propia partida ([db]): de ahí sale, temporada a temporada, el
///   anillo que se le apunta a un jugador concreto en su carrera (ver
///   `carrera_repository.dart`) — algo que solo tiene sentido dentro de la
///   línea de tiempo de esta ranura.
/// - En el registro compartido entre partidas (`abrirAjustes`): es lo que
///   rellena los trofeos del selector de equipos. Es un logro tuyo, no de
///   esta ranura — si la borras o empiezas otra, el trofeo sigue ahí.
///
/// Marca `logradoPorUsuario` solo si el campeón es el equipo que estás
/// dirigiendo ahora mismo: los títulos que gana la CPU quedan guardados
/// (para poder consultarlos algún día) pero no cuentan como logro tuyo, así
/// que no rellenan los trofeos del selector de equipos.
Future<void> registrarCampeon(
  AppDatabase db, {
  required String equipo,
  required String tipo,
}) async {
  final equipoUsuario = await leerEquipoFranquicia(db);
  final temporada = await leerTemporada(db);
  final companion = HistorialCampeonesCompanion.insert(
    equipo: equipo,
    tipo: tipo,
    fecha: DateTime.now(),
    temporada: Value(temporada.numero),
    logradoPorUsuario: Value(equipo == equipoUsuario),
  );

  await db.into(db.historialCampeones).insert(companion);

  final compartido = abrirAjustes();
  await compartido.into(compartido.historialCampeones).insert(companion);
}

/// Los títulos que has ganado tú (no los de la CPU) alguna vez, en
/// cualquier partida, agrupados por tipo. Sale del registro compartido, no
/// de la partida en la que estés ahora: es un logro tuyo, no de la ranura.
Future<Set<String>> equiposConTituloDelUsuario(String tipo) async {
  final compartido = abrirAjustes();
  final filas = await (compartido.select(compartido.historialCampeones)
        ..where((t) => t.tipo.equals(tipo) & t.logradoPorUsuario.equals(true)))
      .get();
  return filas.map((c) => c.equipo).toSet();
}
