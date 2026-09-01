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
  EfectosDeEvento,
  PatrociniosActivos,
  PartidaCarrera,
  HistorialTemporadaJuvenil,
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
  int get schemaVersion => 31;

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

          // 21 -> 22: contratos de entrenador (sueldo, años y finiquito).
          // Columnas nuevas con valor por defecto, así que las filas que ya
          // existan quedan con contrato a cero; `asignarContratosQueFalten`
          // les pone uno acorde a su nivel al abrir la partida.
          if (from < 22) {
            await m.addColumn(entrenadores, entrenadores.salario);
            await m.addColumn(entrenadores, entrenadores.aniosContrato);
            await m.addColumn(
                entrenadores, entrenadores.equipoQuePagaFiniquito);
            await m.addColumn(entrenadores, entrenadores.aniosDeFiniquito);
          }

          // 22 -> 23: los eventos narrativos. Una tabla nueva para los
          // efectos en marcha y una columna nueva con las claves de los que
          // ya han salido esta temporada. Las dos cosas son aditivas: una
          // partida en curso sigue igual, simplemente empieza sin ningun
          // efecto activo y sin ningun evento visto, que es exactamente el
          // estado correcto.
          if (from < 23) {
            await m.createTable(efectosDeEvento);
            await m.addColumn(temporada, temporada.eventosVistos);
          }

          // 24: el margen de tope salarial que dejan los eventos. Aditiva
          // igual que la anterior: una partida en curso arranca con 0, que
          // es justo lo que tenia antes de que esto existiera.
          if (from < 24) {
            await m.addColumn(temporada, temporada.bonusSalarial);
          }

          // 25: fecha de fichaje como agente libre, para la restricción de
          // traspaso de recién fichados. Aditiva: una partida en curso
          // arranca con todo el mundo a null, que es exactamente "sin
          // restricción" — nadie de la plantilla actual fichó "hoy".
          if (from < 25) {
            await m.addColumn(jugadores, jugadores.fechaFichaje);
          }

          // 26: el sexto hombre de la rotación. Aditiva: una partida en
          // curso arranca sin nadie designado, que es un estado válido
          // (nunca es obligatorio, igual que las estrellas de ataque y
          // defensa).
          if (from < 26) {
            await m.addColumn(rotacionJugador, rotacionJugador.esSextoHombre);
          }

          // 27: los patrocinadores. Tabla nueva, así que una partida en
          // curso arranca sin ninguno activo — se eligen la primera vez
          // que se pase por el cambio de temporada, como cualquier otra
          // decisión de pretemporada.
          if (from < 27) {
            await m.createTable(patrociniosActivos);
          }

          // 28: la clave del efecto de vestuario, para poder enseñar su
          // nombre en el idioma del usuario en vez de en español fijo.
          // Aditiva y nullable: los efectos que ya estuvieran en marcha se
          // quedan con su etiqueta vieja y se siguen leyendo bien — no se
          // puede adivinar a qué efecto del catálogo correspondían, y de
          // todas formas se agotan en unos partidos.
          if (from < 28) {
            await m.addColumn(efectosDeEvento, efectosDeEvento.claveEfecto);
          }

          // 29: los patrocinios pasan a ser CONTRATOS. Antes cada categoría
          // era un interruptor que daba una cantidad fija y se apagaba al
          // cerrar el año; ahora se firma una marca concreta, por un dinero
          // concreto y para varios años.
          //
          // Las tres son aditivas y nullable, así que una partida en curso
          // no pierde nada: sus filas se quedan sin contrato y se leen como
          // lo que eran —el bonus fijo de su categoría, un año— hasta que
          // caduquen solas en el siguiente cambio de temporada.
          if (from < 29) {
            await m.addColumn(patrociniosActivos, patrociniosActivos.clave);
            await m.addColumn(
                patrociniosActivos, patrociniosActivos.bonusAnual);
            await m.addColumn(
                patrociniosActivos, patrociniosActivos.aniosRestantes);
          }

          // 30: el Modo Carrera. Dos tablas nuevas y nada más — una partida
          // de franquicia en curso no se entera de que existen.
          if (from < 30) {
            await m.createTable(partidaCarrera);
            await m.createTable(historialTemporadaJuvenil);
          }

          // 31: la cadencia de decisión de Modo Carrera (cada 1, 2 o 3
          // años). Columna nueva con valor por defecto — una carrera en
          // curso sigue preguntando cada año, como hacía hasta ahora.
          if (from < 31) {
            await m.addColumn(partidaCarrera, partidaCarrera.cadenciaAnios);
          }
        },
      );

}
