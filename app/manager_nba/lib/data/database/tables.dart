import 'package:drift/drift.dart';

/// Tabla de jugadores importada desde jugadores_manager_30_07.json.
@DataClassName('Jugador')
class Jugadores extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombreFicticio => text()();
  TextColumn get nombreReal => text()();
  TextColumn get posicion => text()();

  /// Segundo puesto que el jugador puede cubrir sin penalización real. El
  /// dataset casi nunca la trae, así que se deriva de su juego al importar
  /// (ver posiciones.dart) — en la NBA real casi todo el mundo puede jugar
  /// el puesto de al lado.
  TextColumn get posicionSecundaria => text().nullable()();

  TextColumn get equipo => text()();

  IntColumn get edad => integer()();
  IntColumn get media => integer()();
  IntColumn get potencial => integer()();
  IntColumn get atrTiro3 => integer()();
  IntColumn get atrAtaque => integer()();
  IntColumn get atrDefensa => integer()();

  RealColumn get ptsPg => real()();
  RealColumn get astPg => real()();
  RealColumn get trbPg => real()();
  RealColumn get factorLongevidad => real()();

  IntColumn get edadRetiro => integer()();
  IntColumn get draftYear => integer().nullable()();

  /// Los retirados no se borran (siguen en el palmarés y en los premios de
  /// temporadas pasadas): se marcan aquí y su `equipo` pasa a
  /// [equipoRetirados], que ninguna consulta de plantilla busca.
  BoolColumn get retirado => boolean().withDefault(const Constant(false))();

  /// Dorsal. El dataset no lo trae: se asigna al importar y al fichar, único
  /// dentro del equipo y respetando los números ya retirados por esa
  /// franquicia (ver dorsales_repository.dart).
  IntColumn get dorsal => integer().nullable()();

  /// Temporadas que el jugador ya llevaba jugadas cuando empieza tu
  /// partida, deducidas de su año de draft (o de su edad).
  IntColumn get temporadasPrevias => integer().withDefault(const Constant(0))();

  /// Salario de esta temporada, en dólares, y años que le quedan de
  /// contrato (incluido este). De los jugadores conocidos son los reales
  /// (assets/data/datos_reales.json); del resto se estiman a partir de su
  /// nivel, calibrados contra esa misma escala.
  IntColumn get salario => integer().withDefault(const Constant(0))();
  IntColumn get aniosContrato => integer().withDefault(const Constant(1))();

  /// Ofertas de renovación que ya ha rechazado esta pretemporada. A la
  /// tercera se acabó la negociación: o va a la agencia libre o lo firma
  /// otro. Se pone a cero cuando firma.
  IntColumn get ofertasRechazadas => integer().withDefault(const Constant(0))();

  /// Fecha (de la liga, no del reloj real) en la que fichó como agente
  /// libre por el equipo con el que está ahora. Null para quien nunca ha
  /// fichado así —importado, drafteado, o simplemente renovado con su
  /// equipo—: esos no tienen restricción de traspaso por esto. Ver
  /// [traspasos_repository.dart].
  DateTimeColumn get fechaFichaje => dateTime().nullable()();

  /// Crédito de carrera anterior a tu partida, de cara al Hall of Fame.
  ///
  /// Sin esto, las leyendas que ya están al final de su carrera —LeBron,
  /// Curry, Durant— se retirarían habiendo jugado dos temporadas contigo y
  /// no entrarían nunca, porque el juego solo sabe de lo que ha simulado.
  /// Ver hall_fama_repository.dart.
  RealColumn get prestigioPrevio => real().withDefault(const Constant(0))();
}

/// Las estadísticas de un jugador en una temporada ya cerrada. Es lo que
/// permite calcular medias de carrera y saber en qué equipo estuvo cada
/// año: `EstadisticasTemporadaJugador` se borra al cambiar de temporada,
/// esto no.
@DataClassName('TemporadaDeCarrera')
class HistorialEstadisticasJugador extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get temporada => integer()();
  IntColumn get jugadorId => integer()();
  TextColumn get equipo => text()();
  IntColumn get media => integer()();
  IntColumn get partidosJugados => integer()();
  IntColumn get puntosTotales => integer()();
  IntColumn get asistenciasTotales => integer()();
  IntColumn get rebotesTotales => integer()();
}

/// Una camiseta retirada por una franquicia. El número queda bloqueado para
/// siempre en ese equipo.
@DataClassName('CamisetaRetirada')
class CamisetasRetiradas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get equipo => text()();
  IntColumn get jugadorId => integer()();
  TextColumn get nombreJugador => text()();
  IntColumn get dorsal => integer()();
  IntColumn get temporada => integer()();
}

/// Una elección de draft. [equipoOriginal] es de quién era en origen —lo
/// que decide en qué puesto cae, porque el orden lo marca su
/// clasificación— y [equipoActual] quién la posee ahora tras los
/// traspasos. Al usarse en un draft se marca [usado].
@DataClassName('PickDraft')
class PicksDraft extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get temporada => integer()();
  IntColumn get ronda => integer()();
  TextColumn get equipoOriginal => text()();
  TextColumn get equipoActual => text()();
  BoolColumn get usado => boolean().withDefault(const Constant(false))();
}

/// Una oferta de traspaso que te ha llegado de otro equipo mientras
/// simulabas. Los jugadores van como listas de ids separadas por comas
/// (`pideJugadores` salen de tu equipo, `ofreceJugadores` vienen del suyo);
/// `ofrecePicks` son ids de `PicksDraft`.
@DataClassName('OfertaTraspaso')
class OfertasTraspaso extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get equipoOfertante => text()();
  TextColumn get pideJugadores => text()();
  TextColumn get ofreceJugadores => text()();
  TextColumn get ofrecePicks => text().withDefault(const Constant(''))();
  DateTimeColumn get fecha => dateTime()();
  BoolColumn get vista => boolean().withDefault(const Constant(false))();
}

/// El draft que se está celebrando ahora mismo (una sola fila, id fijo 0).
/// Existe para que un draft a medias sobreviva a cerrar el juego:
/// [ordenEquipos] son los 60 turnos separados por comas e [indice] por cuál
/// va. Se borra al terminarlo.
class DraftEnCurso extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get anioDraft => integer()();
  TextColumn get ordenEquipos => text()();
  IntColumn get indice => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Un jugador retirado que ha entrado en el Hall of Fame, con la
/// puntuación de carrera que le dio el pase (ver hall_fama_repository.dart).
@DataClassName('MiembroHallDeLaFama')
class HallDeLaFama extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jugadorId => integer()();
  TextColumn get nombreJugador => text()();
  IntColumn get temporadaIngreso => integer()();
  RealColumn get puntuacion => real()();
}

/// Estado del "reloj" de la carrera (una sola fila, id fijo 0): en qué
/// temporada vas y en qué año natural empieza. La temporada 1 es la que
/// arranca al crear la franquicia.
class Temporada extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get numero => integer().withDefault(const Constant(1))();
  IntColumn get anioInicio => integer()();

  /// Cuántas ofertas de traspaso entrantes se han generado ya esta
  /// temporada (ver ofertas_repository.dart). A diferencia de la fila de
  /// `OfertasTraspaso`, que se borra al aceptar o rechazar, este contador
  /// no baja nunca dentro de una misma temporada — es lo que permite un
  /// tope real de verdad de como mucho unas pocas por temporada, no solo
  /// "como mucho 3 a la vez sin resolver". Se pone a 0 en cada cambio de
  /// año.
  IntColumn get ofertasGeneradasEstaTemporada =>
      integer().withDefault(const Constant(0))();

  /// Las claves de los eventos narrativos que ya han salido esta temporada,
  /// separadas por comas. Es lo que evita que te salga la misma cena de
  /// equipo tres veces el mismo ano.
  ///
  /// Va como texto y no como tabla aparte a proposito: son un punado de
  /// cadenas cortas que solo se leen enteras y se resetean cada verano. Una
  /// tabla para esto seria mas ceremonia que dato (mismo criterio que las
  /// listas de ids de `OfertasTraspaso`).
  TextColumn get eventosVistos => text().withDefault(const Constant(''))();

  /// Margen de tope salarial extra que han dejado los eventos narrativos
  /// esta temporada (patrocinios, actos publicitarios...). Se suma al tope
  /// SOLO para el equipo del usuario: los otros 29 no toman estas
  /// decisiones, así que no les puede tocar.
  ///
  /// Va en la fila de temporada y no en una tabla aparte porque es un
  /// número suelto que se resetea cada verano, igual que
  /// [eventosVistos]. Puede ser negativo (una multa) sin que nada se
  /// rompa: el espacio salarial ya sabía ser negativo de antes, es lo que
  /// significa estar por encima del tope.
  IntColumn get bonusSalarial => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// El récord final de un equipo en una temporada ya cerrada. Sobrevive al
/// cambio de año (a diferencia de `ResultadoTemporada`, que se resetea).
@DataClassName('RecordHistorico')
class HistorialTemporadaEquipo extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get temporada => integer()();
  TextColumn get equipo => text()();
  IntColumn get victorias => integer()();
  IntColumn get derrotas => integer()();
}

/// Un premio de una temporada ya cerrada. Guarda el nombre y el equipo del
/// jugador en ese momento, no solo su id: dentro de 15 temporadas el
/// jugador estará retirado y puede haber cambiado de equipo, pero el premio
/// se ganó con esa camiseta.
@DataClassName('PremioHistorico')
class HistorialPremios extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get temporada => integer()();
  TextColumn get tipo => text()();
  IntColumn get jugadorId => integer()();
  TextColumn get nombreJugador => text()();
  TextColumn get equipo => text()();
}

/// Una sola fila (id fijo 0): el equipo elegido por el usuario. Su
/// ausencia decide si hace falta el onboarding al arrancar la app.
class Franquicia extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get equipo => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tu rotación actual: 5 puestos (PG/SG/SF/PF/C) x 2 huecos (titular y
/// suplente) = 10 filas cuando está completa. Los minutos de titular y
/// suplente de un mismo puesto deben sumar 48 (lo valida la capa de
/// dominio, no la tabla).
class RotacionJugador extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get posicion => text()();
  BoolColumn get esTitular => boolean()();
  IntColumn get jugadorId => integer()();
  IntColumn get minutos => integer()();
  BoolColumn get esEstrellaAtaque =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get esEstrellaDefensa =>
      boolean().withDefault(const Constant(false))();

  /// El sexto hombre: el primer suplente que entra a anotar. Igual que las
  /// estrellas de arriba, es una designación tuya, no algo que calcule el
  /// motor solo — pero a diferencia de ellas, solo puede recaer en un
  /// suplente (lo valida la capa de dominio: un titular ya tiene su propio
  /// rol, no "sale del banquillo").
  BoolColumn get esSextoHombre =>
      boolean().withDefault(const Constant(false))();
}

/// Las categorías de patrocinio activas ahora mismo (estadio, camiseta,
/// bebida, ocio — ver `domain/patrocinadores.dart`). Una fila por categoría
/// activa; si la categoría no tiene fila, está desactivada. Es del equipo
/// del usuario únicamente — los otros 29 no eligen patrocinadores — así
/// que, igual que `RotacionJugador`, no lleva columna de equipo.
class PatrociniosActivos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get categoria => text()();

  /// Qué marca concreta la patrocina, por la clave del catálogo
  /// (`ATL_01`). Ver `Patrocinador.clave`.
  ///
  /// Las tres columnas de abajo son nullable solo por la migración: una
  /// partida que venga de antes de la 29 tiene filas sin contrato, de
  /// cuando el patrocinio era "encendido o apagado" y duraba un año fijo.
  /// El código nuevo siempre las escribe; quien las lee las normaliza en un
  /// único sitio (`_contratoDeFila` en `patrocinadores_repository.dart`).
  TextColumn get clave => text().nullable()();

  /// Lo que paga al año. Ya no es fijo por categoría: cada oferta trae el
  /// suyo, y por eso hay que guardarlo — dentro de tres años el catálogo
  /// puede haber cambiado y el contrato firmado manda.
  IntColumn get bonusAnual => integer().nullable()();

  /// Cuántas temporadas le quedan, esta incluida. Es una cuenta atrás y no
  /// una temporada final a propósito: la pantalla de patrocinadores corre
  /// ANTES de que suba el número de temporada (ver `finalizarPretemporada`),
  /// así que cualquier cuenta con números absolutos se equivoca en uno.
  /// Bajando de uno en uno al cerrar el año no hay off-by-one posible.
  IntColumn get aniosRestantes => integer().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoria},
      ];
}

/// Un partido de la temporada de [equipoPropietario] (los 30 equipos
/// tienen su propia temporada de 82 partidos; solo la tuya se juega/edita
/// desde la UI, las otras 29 se simulan en segundo plano). El resultado y
/// las lesiones de este partido solo afectan a [equipoPropietario], no a
/// [rival] (cada equipo lleva su propio calendario independiente — ver
/// nota de diseño en generador_calendario.dart).
class PartidosCalendario extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get equipoPropietario => text()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get rival => text()();
  BoolColumn get esLocal => boolean()();
  BoolColumn get jugado => boolean().withDefault(const Constant(false))();
  BoolColumn get esTorneoTemporada =>
      boolean().withDefault(const Constant(false))();
  /// 'regular' o 'playoffs'.
  TextColumn get fase => text().withDefault(const Constant('regular'))();
  IntColumn get marcadorPropietario => integer().nullable()();
  IntColumn get marcadorRival => integer().nullable()();
}

/// Fechas especiales de la temporada que no son un partido tuyo: fin de
/// agencia libre, fecha límite de traspasos, All-Star. `tipo` guarda el
/// nombre de `TipoEventoTemporada` (ver lib/domain/tipo_evento_temporada.dart).
class EventosTemporada extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get tipo => text()();
}

/// Un jugador lesionado: no puede jugar hasta [fechaFin] (inclusive del
/// día anterior, exclusive de fechaFin en adelante).
@DataClassName('Lesion')
class Lesiones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get jugadorId => integer()();
  DateTimeColumn get fechaFin => dateTime()();
  /// 'leve' o 'grave'.
  TextColumn get gravedad => text()();
  /// Frase corta ("esguince de tobillo", "rotura de ligamento cruzado"...).
  TextColumn get motivo => text().withDefault(const Constant(''))();
  /// Partidos que se pierde, estimados al crear la lesión (días / ritmo de
  /// un partido cada ~2 días).
  IntColumn get partidosEstimados => integer().withDefault(const Constant(0))();
}

/// Totales acumulados de la temporada en curso para un jugador, de los
/// que salen las medias que alimentan clasificaciones y premios. Una fila
/// por jugador.
class EstadisticasTemporadaJugador extends Table {
  IntColumn get jugadorId => integer()();
  IntColumn get partidosJugados => integer().withDefault(const Constant(0))();
  IntColumn get puntosTotales => integer().withDefault(const Constant(0))();
  IntColumn get asistenciasTotales =>
      integer().withDefault(const Constant(0))();
  IntColumn get rebotesTotales => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {jugadorId};
}

/// Récord de la temporada en curso de cada uno de los 30 equipos.
class ResultadoTemporada extends Table {
  TextColumn get equipo => text()();
  IntColumn get victorias => integer().withDefault(const Constant(0))();
  IntColumn get derrotas => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {equipo};
}

/// Premios de fin de temporada regular. `tipo` guarda el nombre de
/// `TipoPremio` (ver lib/domain/tipo_premio.dart).
class PremiosTemporada extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => text()();
  IntColumn get jugadorId => integer()();
}

/// Una serie de playoffs (o un partido único de play-in). `conferencia` es
/// 'Este'/'Oeste', o 'Final' para la final de la NBA (entre los dos
/// campeones de conferencia). `ronda`: 0 (play-in), 1 (primera ronda), 2
/// (semis), 3 (final de conferencia), 4 (final NBA) — solo para ordenar.
/// `etapa` identifica la serie exacta dentro de esa ronda (ver
/// lib/domain/playoffs_repository.dart), necesario porque el play-in
/// tiene tres partidos distintos en la ronda 0. `victoriasNecesarias` es 4
/// para series al mejor de 7, 1 para partidos únicos de play-in.
@DataClassName('Serie')
class SeriesPlayoffs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conferencia => text()();
  IntColumn get ronda => integer()();
  TextColumn get etapa => text()();
  TextColumn get equipoA => text()();
  TextColumn get equipoB => text()();
  IntColumn get seedA => integer()();
  IntColumn get seedB => integer()();
  IntColumn get victoriasA => integer().withDefault(const Constant(0))();
  IntColumn get victoriasB => integer().withDefault(const Constant(0))();
  IntColumn get victoriasNecesarias => integer().withDefault(const Constant(4))();
  TextColumn get ganador => text().nullable()();
}

/// Ajustes de la app (una sola fila, id fijo 0): tema y, para la Fase 3b,
/// idioma.
class Ajustes extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  BoolColumn get modoOscuro => boolean().withDefault(const Constant(true))();
  /// 'es' o 'en' — el selector real llega en la Fase 3b.
  TextColumn get idioma => text().withDefault(const Constant('es'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Un título ganado por un equipo (persiste aunque empieces una franquicia
/// nueva). `tipo` es 'ist' o 'nba'. [logradoPorUsuario] distingue los que
/// ganaste tú dirigiendo ese equipo de los que ganó la CPU: los trofeos del
/// selector de equipos solo enseñan los tuyos (si no, al empezar una
/// partida nueva aparecían equipos "con palmarés" que en realidad nunca
/// habías dirigido).
@DataClassName('Campeonato')
class HistorialCampeones extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get equipo => text()();
  TextColumn get tipo => text()();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get temporada => integer().withDefault(const Constant(1))();
  BoolColumn get logradoPorUsuario =>
      boolean().withDefault(const Constant(false))();
}

/// Estado del torneo de mitad de temporada de la franquicia en curso (una
/// sola fila, id fijo 0). Se borra al empezar una franquicia nueva, a
/// diferencia de `HistorialCampeones` — solo evita volver a coronar/avisar
/// del campeón dos veces dentro de la misma temporada. `faseGrupos` es
/// true mientras se están jugando los 4 partidos de grupo de cada equipo;
/// pasa a false en cuanto se siembran los cuartos de la NBA Cup.
class IstTemporada extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  BoolColumn get faseGruposActiva =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get campeonAnunciado =>
      boolean().withDefault(const Constant(false))();
  TextColumn get equipoCampeon => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Una serie de la fase eliminatoria de la NBA Cup: siempre un partido
/// único (cuartos, semifinal o final). `conferencia` es 'Este'/'Oeste'
/// para cuartos y semifinal, 'Final' para la final (entre los dos
/// finalistas de conferencia). `ronda`: 1 (cuartos), 2 (semifinal), 3
/// (final) — solo para ordenar. `etapa` identifica la serie exacta dentro
/// de la ronda (ver lib/domain/torneo_repository.dart).
@DataClassName('SerieTorneo')
class SeriesTorneo extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conferencia => text()();
  IntColumn get ronda => integer()();
  TextColumn get etapa => text()();
  TextColumn get equipoA => text()();
  TextColumn get equipoB => text()();
  IntColumn get seedA => integer()();
  IntColumn get seedB => integer()();
  TextColumn get ganador => text().nullable()();
}

/// El "estado de forma" de un jugador para la temporada en curso: un
/// multiplicador alrededor de 1.0 que se sortea al empezar la franquicia y
/// se aplica a su rendimiento durante toda la temporada. Sin esto la
/// simulación es prácticamente determinista y los premios acababan siempre
/// en el mismo jugador partida tras partida; con esto hay años de explosión
/// y años flojos, como en la NBA real. Se borra al empezar una franquicia
/// nueva.
@DataClassName('FormaJugador')
class FormaTemporadaJugador extends Table {
  IntColumn get jugadorId => integer()();
  RealColumn get factor => real().withDefault(const Constant(1.0))();

  @override
  Set<Column> get primaryKey => {jugadorId};
}

/// Un efecto de vestuario en marcha: lo que ha dejado una decision tuya en
/// un evento narrativo (ver `eventos_narrativos.dart`).
///
/// Solo tiene filas de TU equipo: los eventos son decisiones tuyas y los
/// otros 29 no las tienen. Cada partido que juegas se le descuenta uno a
/// `partidosRestantes`, y al llegar a cero la fila se borra — por eso la
/// duracion va en partidos y no en fechas: asi "diez partidos de buen
/// rollo" dura lo mismo simules dia a dia o mes a mes.
class EfectosDeEvento extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Que evento lo produjo. Solo para poder contarlo; no se usa como clave.
  TextColumn get clave => text()();

  /// Cual de los efectos del catalogo es ('buen_rollo'), para buscar su
  /// nombre en el idioma que tenga puesto el usuario.
  ///
  /// Nullable por las partidas empezadas antes de que los eventos se
  /// tradujeran: aquellas filas solo guardaron [etiqueta], ya escrita en
  /// espanol, y no hay forma de adivinar a que efecto correspondian.
  TextColumn get claveEfecto => text().nullable()();

  /// Como se llama en pantalla ("Buen rollo en el vestuario").
  ///
  /// Desde que existe [claveEfecto] es solo el respaldo: se escribe en
  /// espanol para que la fila se entienda al mirar la base de datos a mano,
  /// pero lo que se ensena sale de traducir la clave.
  TextColumn get etiqueta => text()();

  /// Multiplicador sobre el estado de forma de cada jugador del equipo.
  RealColumn get factor => real()();

  IntColumn get partidosRestantes => integer()();
}

/// El boxscore completo (serializado en JSON) de un partido simulado
/// dentro de una serie de playoffs o de la NBA Cup. A diferencia de los
/// partidos de temporada regular (`PartidosCalendario`), estas series no
/// tienen una fila de calendario por partido, así que hace falta este
/// sitio aparte para poder volver a consultarlo ("ver estadísticas") desde
/// la pantalla de playoffs/Cup. `origen` es 'playoffs' o 'torneo';
/// `serieId` es el id de `SeriesPlayoffs`/`SeriesTorneo` correspondiente
/// (no hay clave foránea real porque el mismo id numérico puede existir en
/// ambas tablas — `origen` desambigua).
class BoxscoresSerie extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get origen => text()();
  IntColumn get serieId => integer()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get boxscoreJson => text()();
}

/// Los entrenadores de la liga: uno por franquicia, más los que están sin
/// equipo esperando una oferta.
///
/// Igual que con los jugadores, `equipo` es quien manda: [equipoAgenciaLibre]
/// para los que están libres y [equipoRetirados] para los que ya lo han
/// dejado. No se borra a nadie — un entrenador retirado sigue haciendo falta
/// para contar quién ganó qué.
@DataClassName('Entrenador')
class Entrenadores extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get nombreFicticio => text()();
  TextColumn get nombreReal => text()();
  TextColumn get equipo => text()();
  IntColumn get edad => integer()();

  /// Las tres facetas, en la misma escala 0-99 que los atributos de un
  /// jugador. Ataque y defensa se notan en cada partido (van al rating de
  /// equipo, ver sim_engine); desarrollo se nota de verano en verano, en lo
  /// que crecen los jóvenes de la plantilla.
  IntColumn get atrAtaque => integer()();
  IntColumn get atrDefensa => integer()();
  IntColumn get atrDesarrollo => integer()();

  /// Palmarés previo a tu partida: anillos y premios de Entrenador del Año
  /// que ya tenía cuando empezaste. Lo que gane contigo se guarda aparte, en
  /// `HistorialCampeones` y `HistorialPremios`.
  IntColumn get anillos => integer().withDefault(const Constant(0))();
  IntColumn get premios => integer().withDefault(const Constant(0))();

  /// Temporadas dirigidas antes de tu partida, para poder decir "lleva 22
  /// años en esto" y para que la edad de retiro tenga sentido.
  IntColumn get temporadas => integer().withDefault(const Constant(0))();

  /// Récord acumulado EN TU PARTIDA, que es lo que sube o baja su cotización
  /// y lo que mira un equipo de la CPU antes de echarle.
  IntColumn get victorias => integer().withDefault(const Constant(0))();
  IntColumn get derrotas => integer().withDefault(const Constant(0))();

  /// Su contrato: lo que cobra al año y los años que le quedan (incluido
  /// este). Sale del presupuesto de banquillo, que es aparte del tope
  /// salarial de jugadores (ver entrenadores.dart).
  IntColumn get salario => integer().withDefault(const Constant(0))();
  IntColumn get aniosContrato => integer().withDefault(const Constant(0))();

  /// El finiquito: si le has despedido con años por delante, el equipo que
  /// le echó le sigue pagando hasta que se cumpla el contrato.
  ///
  /// Vive aquí y no en una tabla aparte porque es información del contrato
  /// del entrenador, no una entidad nueva — y así no puede quedarse
  /// huérfana si alguien vuelve a firmarle.
  TextColumn get equipoQuePagaFiniquito => text().nullable()();
  IntColumn get aniosDeFiniquito => integer().withDefault(const Constant(0))();
}
