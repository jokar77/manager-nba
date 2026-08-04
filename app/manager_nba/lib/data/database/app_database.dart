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
  int get schemaVersion => 20;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Sin usuarios reales todavía: en un upgrade simplemente se tira
        // el esquema entero y se recrea, en vez de escribir migraciones
        // paso a paso para datos que no existen aún.
        onUpgrade: (m, from, to) async {
          for (final tabla in allTables) {
            await m.deleteTable(tabla.actualTableName);
          }
          await m.createAll();
        },
      );

}
