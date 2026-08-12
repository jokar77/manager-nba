import 'package:drift/drift.dart';

import 'almacenamiento.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Jugadores,
  Franquicia,
  RotacionJugador,
  PartidosCalendario,
  EventosTemporada,
  Lesiones,
  EstadisticasTemporadaJugador,
  ResultadoTemporada,
  PremiosTemporada,
  SeriesPlayoffs,
  Ajustes,
  HistorialCampeones,
  IstTemporada,
  SeriesTorneo,
  BoxscoresSerie,
  FormaTemporadaJugador,
  Temporada,
  HistorialTemporadaEquipo,
  HistorialPremios,
  HistorialEstadisticasJugador,
  CamisetasRetiradas,
  HallDeLaFama,
  DraftEnCurso,
  PicksDraft,
  OfertasTraspaso,
  Entrenadores,
])
class AppDatabase extends _$AppDatabase {
  /// Abre la partida guardada con el nombre [nombre]. Cada partida vive por
  /// su cuenta (ver `domain/slots_repository.dart`), así que aquí no hay una
  /// única base: hay tantas como ranuras tenga el jugador.
  ///
  /// Dónde se guarda de verdad —un fichero SQLite en escritorio y móvil, el
  /// almacenamiento del navegador en web— lo resuelve `almacenamiento.dart`.
  AppDatabase.enFichero(String nombre) : super(abrirBaseDeDatos(nombre));
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 21;

  /// CUIDADO AL TOCAR ESTO: aquí se decide si una actualización del juego
  /// conserva las partidas guardadas o se las lleva por delante.
  ///
  /// Hasta la versión 20 el `onUpgrade` tiraba el esquema entero y lo
  /// recreaba, con el argumento de que no había usuarios reales. Ya los hay:
  /// hay gente con carreras de varias temporadas en marcha. Desde la 20 en
  /// adelante, cada salto tiene que escribirse a mano y ser ADITIVO — crear
  /// tablas o columnas nuevas, nunca borrar lo que ya está.
  ///
  /// El camino destructivo se queda solo para las bases anteriores a la 20,
  /// que son de la época en que efectivamente no había nada que perder.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 20) {
            for (final tabla in allTables) {
              await m.deleteTable(tabla.actualTableName);
            }
            await m.createAll();
            return;
          }

          // 20 -> 21: los entrenadores. Tabla nueva y nada más, así que la
          // partida en curso sigue intacta; el importador la rellena sola
          // la próxima vez que se abra (ver entrenadores_importer.dart).
          if (from < 21) await m.createTable(entrenadores);
        },
      );

}
