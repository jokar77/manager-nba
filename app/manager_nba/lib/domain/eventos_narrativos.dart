/// Los eventos narrativos: cosas que pasan alrededor del equipo durante la
/// temporada y sobre las que hay que decidir algo, con consecuencias reales
/// en la pista.
///
/// Este fichero es Dart puro (sin base de datos) para poder probar el
/// catálogo y las condiciones sin montar una partida. La parte que guarda y
/// aplica los efectos está en `eventos_narrativos_repository.dart`, y lo
/// que se lee en pantalla está en `i18n/textos_eventos.dart`.
///
/// **Aquí no hay texto.** El catálogo son claves, condiciones y números; lo
/// que se lee vive en los siete idiomas del juego. Se separó así cuando
/// tocó traducirlos: si el guion viviera aquí, cada evento nuevo habría que
/// escribirlo siete veces en medio de la lógica, y un ajuste de equilibrio
/// (subir un factor, acortar una racha) obligaría a tocar los siete sitios
/// donde solo cambia una palabra.
///
/// Tres reglas de diseño, para que esto no se convierta en un generador de
/// texto sin consecuencias:
///
/// 1. **Toda opción tiene un coste o no es una decisión.** Si una de las
///    respuestas es mejor que las demás en todo, no hay nada que elegir. Por
///    eso casi todos los eventos cambian algo bueno por algo malo (más
///    química a cambio de piernas cansadas) o algo de ahora por algo de
///    después.
/// 2. **Los efectos son del equipo entero y duran un número de PARTIDOS**,
///    no de días: así "diez partidos de buen rollo" significa lo mismo si
///    simulas día a día o mes a mes.
/// 3. **Solo le pasan a tu equipo.** Son tus decisiones de vestuario; los
///    otros 29 no las tienen porque no habría a quién preguntar.
library;

import 'dart:math';

/// Cuánto puede mover un solo efecto el rendimiento del equipo, como
/// multiplicador sobre el estado de forma de cada jugador (ver
/// `forma_repository.dart`, donde la forma individual va de 0,84 a 1,16).
///
/// MEDIDO, y la primera versión de estos números estaba muy pasada. Se
/// simularon temporadas completas de 82 partidos con un efecto fijo puesto
/// todo el año:
///
///   factor 0,96 ... 32,8 victorias
///   factor 1,00 ... 49,4 victorias
///   factor 1,04 ... 62,6 victorias
///
/// O sea **3,7 victorias por cada 1%**. La simulación es muy sensible al
/// rendimiento de equipo (ya se sabía: ver el arrastre de la forma en
/// `forma_repository.dart`), así que los ±4% que se pusieron a ojo hacían
/// que UNA respuesta de un diálogo valiera más que todo el sistema de
/// entrenadores junto, que vale 5,6 victorias del mejor al peor. Eso
/// convierte el juego en "acierta en los diálogos" en vez de "gestiona la
/// plantilla".
///
/// Con el tope en ±3% y las magnitudes de abajo, el efecto más fuerte del
/// catálogo (un 2% durante 12 partidos) vale 0,02 × 372 × 12/82 ≈ **1,1
/// victorias**, y una temporada entera de decisiones buenas frente a una de
/// decisiones malas anda por las 4 victorias de diferencia. Se nota, pero
/// por debajo del entrenador — que es como tiene que ser: el entrenador es
/// una decisión de plantilla y esto es una anécdota de vestuario.
const maxFactorDeEvento = 1.03;
const minFactorDeEvento = 0.97;

/// Y cuántos partidos puede durar como mucho. Doce es una racha larga
/// (mes y medio de calendario) sin llegar a ser "el resto del año".
const maxPartidosDeEfecto = 12;

/// Un efecto activo en el vestuario: un multiplicador sobre el rendimiento
/// del equipo que se va gastando partido a partido.
class EfectoDeEvento {
  /// Con qué nombre se busca su texto ('buen_rollo', 'piernas_cansadas').
  /// Ver `etiquetasDeEfecto` en `i18n/textos_eventos.dart`.
  final String clave;

  /// Multiplicador sobre el estado de forma. 1,03 = un 3% mejor.
  final double factor;

  /// Partidos que le quedan de vida.
  final int partidos;

  /// La etiqueta tal cual estaba guardada en la base de datos, para las
  /// partidas empezadas ANTES de que los efectos tuvieran clave.
  ///
  /// Aquellas filas guardaron el texto ya escrito ("Buen rollo en el
  /// vestuario") y no hay forma de saber a qué efecto del catálogo
  /// correspondían, así que se enseñan tal cual: en español y sin traducir,
  /// pero legibles. Se vacían solas al acabar la temporada.
  final String? etiquetaGuardada;

  const EfectoDeEvento({
    required this.clave,
    required this.factor,
    required this.partidos,
    this.etiquetaGuardada,
  });

  bool get esBueno => factor > 1.0;

  /// Acotado a lo que se considera sano, por si un evento futuro se pasa.
  EfectoDeEvento get acotado => EfectoDeEvento(
        clave: clave,
        factor: factor.clamp(minFactorDeEvento, maxFactorDeEvento),
        partidos: partidos.clamp(1, maxPartidosDeEfecto),
        etiquetaGuardada: etiquetaGuardada,
      );
}

/// Una de las respuestas posibles a un evento.
class OpcionDeEvento {
  /// Con qué nombre se busca su texto dentro del evento ('noche_larga').
  final String clave;

  /// Los efectos de rendimiento que deja. Uno, o varios con signos
  /// distintos.
  final List<EfectoDeEvento> efectos;

  /// Margen de tope salarial que deja la decisión, en dólares. Positivo es
  /// dinero que entra (un patrocinio); negativo, una multa.
  ///
  /// Es el segundo eje del sistema, y existe porque con un solo eje todas
  /// las decisiones se parecían: cambiar rendimiento por rendimiento acaba
  /// siendo siempre la misma pregunta. Cambiar DINERO por piernas es otra
  /// cosa — la respuesta depende de si vas a fichar o no, y eso ya no lo
  /// decide el diálogo, lo decide tu plantilla.
  final int bonusSalarial;

  const OpcionDeEvento({
    required this.clave,
    this.efectos = const [],
    this.bonusSalarial = 0,
  });

  /// ¿Esta opción no hace absolutamente nada? Se usa en el test que vigila
  /// que ninguna lo sea: una respuesta sin consecuencias no es una
  /// decisión, es un botón de cerrar.
  bool get noHaceNada => efectos.isEmpty && bonusSalarial == 0;
}

/// En qué situación está el equipo cuando toca sortear un evento. Es lo que
/// permite que los eventos vengan a cuento: una pelea en el vestuario
/// después de siete derrotas seguidas se lee como algo que pasa de verdad;
/// la misma pelea con el mejor récord de la liga, no.
class ContextoDeEvento {
  final int victorias;
  final int derrotas;

  /// Partidos jugados de los 82. Sirve para los eventos que solo tienen
  /// sentido en un momento del año (el final de temporada, por ejemplo).
  final int partidosJugados;

  /// Media de los cinco mejores, el mismo criterio que usa todo el juego.
  final int mediaDelEquipo;

  /// Si el banquillo está ocupado. Sin entrenador no hay a quién pedirle
  /// que hable con el vestuario.
  final bool tieneEntrenador;

  /// Cuántos jugadores de 23 años o menos hay en la plantilla, para los
  /// eventos de cantera.
  final int jugadoresJovenes;

  const ContextoDeEvento({
    required this.victorias,
    required this.derrotas,
    required this.partidosJugados,
    required this.mediaDelEquipo,
    required this.tieneEntrenador,
    required this.jugadoresJovenes,
  });

  /// Ritmo de victorias proyectado a 82 partidos. Sin partidos jugados se
  /// devuelve 41 (el punto neutro) en vez de 0: es el mismo cuidado que hizo
  /// falta con las ofertas a entrenadores — contar un 0-0 como "temporada de
  /// cero victorias" deja todos los umbrales rotos el primer día.
  double get victoriasProyectadas =>
      partidosJugados == 0 ? 41 : victorias / partidosJugados * 82;

  bool get vaMal => victoriasProyectadas < 34;
  bool get vaBien => victoriasProyectadas > 50;
}

/// A qué jugador de tu rotación de 10 (ver `franquicia_repository.dart`) se
/// refiere un evento, para poder decir su nombre en vez de "un jugador".
///
/// Lista 15, punto 2: antes ningún evento nombraba a nadie ("tu mejor
/// jugador", "un veterano", "uno de tus titulares"), así que la misma frase
/// podía referirse a cualquiera de la plantilla sin que el usuario supiera
/// a quién. Resuelto en `eventos_narrativos_repository.dart`, que busca el
/// nombre real en tu rotación guardada según este rol.
enum RolDeProtagonista {
  /// El mejor de tus dos estrellas marcadas, o el de más media si por lo
  /// que sea no hay ninguna marcada todavía.
  estrella,

  /// Uno de tus jugadores de 23 años o menos, al azar.
  joven,

  /// El de más edad de la rotación.
  veterano,

  /// Uno de tus cinco titulares, al azar.
  titular,

  /// Cualquiera de los diez de la rotación, sin más criterio.
  cualquiera,
}

/// Un evento del catálogo.
class EventoNarrativo {
  /// Identificador estable. Se guarda para no repetir el mismo evento dos
  /// veces en la misma temporada, así que NO se puede cambiar sin romper las
  /// partidas en curso (lo único que pasaría es que un evento ya visto
  /// pudiera repetirse una vez). Es también con lo que se busca su texto en
  /// `i18n/textos_eventos.dart`.
  final String clave;

  final List<OpcionDeEvento> opciones;

  /// Cuándo puede salir. Null = en cualquier momento.
  final bool Function(ContextoDeEvento)? cuando;

  /// Si este evento habla de un jugador concreto, qué papel busca en tu
  /// rotación. Null en los eventos que son del vestuario en general (la
  /// mayoría) y no de nadie en particular.
  final RolDeProtagonista? protagonista;

  const EventoNarrativo({
    required this.clave,
    required this.opciones,
    this.cuando,
    this.protagonista,
  });

  bool encajaEn(ContextoDeEvento contexto) =>
      cuando == null || cuando!(contexto);
}

// ---------------------------------------------------------------------------
// El catálogo
// ---------------------------------------------------------------------------

/// Duraciones que se repiten, con nombre para que se lea qué se está
/// eligiendo en cada evento en vez de un número suelto.
const _unaRachaLarga = 12;
const _unaRachaCorta = 6;
const _unosPocosPartidos = 3;

/// Magnitudes con nombre, por lo mismo. A 3,7 victorias por punto
/// porcentual (ver [maxFactorDeEvento]), lo que vale cada una durante una
/// racha larga de 12 partidos es:
///
///   _muchoMejor / _muchoPeor ... ±1,1 victorias
///   _algoMejor  / _algoPeor .... ±0,5 victorias
///
/// Números pequeños a propósito: son cuatro eventos por temporada y no
/// pueden sumar más que gestionar bien la plantilla.
const _muchoMejor = 1.02;
const _algoMejor = 1.01;
const _algoPeor = 0.99;
const _muchoPeor = 0.98;

/// Y las magnitudes de dinero, en dólares de tope salarial.
///
/// La referencia NO es el tope (240M): a esa escala cualquier cifra de
/// patrocinio es ruido. Tampoco es el salario mínimo (2,3M) — el ajuste
/// final los deja por debajo, ver la nota de abajo.
///
/// Por eso el pellizco pequeño es de 1,5M y el grande de 3M: menos que el
/// mínimo del convenio, a propósito — el dinero de un patrocinio es un
/// extra puntual de un solo diálogo, no algo pensado para desbloquear un
/// fichaje por sí solo. Una multa fuerte quita 4M, que duele sin dejarte
/// sin plantilla.
///
/// Bajados dos veces por feedback directo: primero de 3M/6M a 2,5M/4M, y
/// de ahí a 1,5M/3M — seguían pareciendo demasiado dinero para un evento
/// que dura un diálogo.
const _bastanteDinero = 3000000;
const _algoDeDinero = 1500000;
const _multaFuerte = -4000000;

/// Y un gasto del club, que no es lo mismo que una multa: no es un castigo
/// por una decisión, es lo que cuesta algo que has decidido pagar. Se queda
/// por debajo de [_multaFuerte] a propósito — invertir en la plantilla
/// tiene que doler menos que hacer el ridículo en público.
const _gastoModerado = -2000000;

/// Todos los eventos que existen. El orden no importa: se sortea entre los
/// que encajan.
///
/// Las claves de aquí (del evento, de cada opción y de cada efecto) son las
/// que se buscan en los siete idiomas. Un test comprueba que ninguna se
/// quede sin traducir en ningún idioma.
final List<EventoNarrativo> catalogoDeEventos = [
  // El ejemplo que pidió el usuario, tal cual: química a cambio de energía.
  EventoNarrativo(
    clave: 'cena_de_equipo',
    opciones: const [
      OpcionDeEvento(
        clave: 'noche_larga',
        efectos: [
          EfectoDeEvento(
              clave: 'buen_rollo',
              factor: _muchoMejor,
              partidos: _unaRachaLarga),
          EfectoDeEvento(
              clave: 'piernas_cansadas',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
        ],
      ),
      OpcionDeEvento(
        clave: 'cena_corta',
        efectos: [
          EfectoDeEvento(
              clave: 'buen_rollo',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        clave: 'ahora_no_toca',
        efectos: [
          EfectoDeEvento(
              clave: 'piernas_frescas',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'grupo_frio',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'bronca_en_el_entrenamiento',
    // Una pelea con el mejor récord de la liga no se sostiene.
    cuando: (c) => !c.vaBien && c.partidosJugados >= 10,
    opciones: const [
      OpcionDeEvento(
        clave: 'multar_a_los_dos',
        efectos: [
          EfectoDeEvento(
              clave: 'vestuario_tenso',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'disciplina',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'que_lo_arreglen_ellos',
        efectos: [
          EfectoDeEvento(
              clave: 'buen_rollo',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        clave: 'mirar_a_otro_lado',
        efectos: [
          EfectoDeEvento(
              clave: 'vestuario_roto',
              factor: _muchoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'estrella_pide_descanso',
    protagonista: RolDeProtagonista.estrella,
    cuando: (c) => c.partidosJugados >= 30 && c.partidosJugados <= 65,
    opciones: const [
      OpcionDeEvento(
        clave: 'que_descanse',
        efectos: [
          EfectoDeEvento(
              clave: 'sin_tu_mejor_jugador',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'plantilla_fresca',
              factor: _muchoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'te_necesito_ahora',
        efectos: [
          EfectoDeEvento(
              clave: 'plantilla_al_limite',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'joven_pide_minutos',
    protagonista: RolDeProtagonista.joven,
    cuando: (c) => c.jugadoresJovenes >= 2 && c.partidosJugados >= 15,
    opciones: const [
      OpcionDeEvento(
        clave: 'dale_minutos',
        efectos: [
          EfectoDeEvento(
              clave: 'rotacion_verde',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'grupo_enchufado',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'que_se_lo_gane',
        efectos: [
          EfectoDeEvento(
              clave: 'banquillo_descontento',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'prensa_dura',
    cuando: (c) => c.vaMal && c.partidosJugados >= 15,
    opciones: const [
      OpcionDeEvento(
        clave: 'defender_al_grupo',
        efectos: [
          EfectoDeEvento(
              clave: 'el_grupo_va_contigo',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'nadie_se_da_por_aludido',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'darles_la_razon',
        efectos: [
          EfectoDeEvento(
              clave: 'vestuario_dolido',
              factor: _muchoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        clave: 'no_entrar_al_trapo',
        efectos: [
          EfectoDeEvento(
              clave: 'nadie_dio_la_cara',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'el_ruido_se_apaga',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'racha_buena',
    cuando: (c) => c.vaBien && c.partidosJugados >= 20 && c.tieneEntrenador,
    opciones: const [
      OpcionDeEvento(
        clave: 'apretar_mientras_dure',
        efectos: [
          EfectoDeEvento(
              clave: 'a_todo_gas',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'desgaste_acumulado',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'levantar_el_pie',
        efectos: [
          EfectoDeEvento(
              clave: 'se_corta_la_racha',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'cargas_controladas',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'aficion_llena_el_pabellon',
    cuando: (c) => c.partidosJugados >= 10,
    opciones: const [
      OpcionDeEvento(
        clave: 'abrir_las_puertas',
        efectos: [
          EfectoDeEvento(
              clave: 'la_grada_empuja',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
          EfectoDeEvento(
              clave: 'una_manana_sin_entrenar',
              factor: _algoPeor,
              partidos: 1),
        ],
        bonusSalarial: _algoDeDinero,
      ),
      OpcionDeEvento(
        clave: 'a_entrenar',
        efectos: [
          EfectoDeEvento(
              clave: 'manana_de_trabajo',
              factor: _algoMejor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'la_grada_fria',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  // El otro eje del sistema: dinero contra piernas. Lo que hace que esta
  // decisión no tenga respuesta correcta es que depende de algo que el
  // diálogo no sabe — si te falta espacio para firmar a alguien o no.
  EventoNarrativo(
    clave: 'acto_publicitario',
    cuando: (c) => c.partidosJugados >= 5,
    opciones: const [
      OpcionDeEvento(
        clave: 'firmar_el_acuerdo_entero',
        efectos: [
          EfectoDeEvento(
              clave: 'dia_de_rodaje',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
        ],
        bonusSalarial: _bastanteDinero,
      ),
      OpcionDeEvento(
        clave: 'negociar_algo_mas_corto',
        efectos: [
          EfectoDeEvento(
              clave: 'manana_de_fotos', factor: _algoPeor, partidos: 1),
        ],
        bonusSalarial: _algoDeDinero,
      ),
      OpcionDeEvento(
        clave: 'decirles_que_no',
        efectos: [
          EfectoDeEvento(
              clave: 'plantilla_descansada',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'partido_benefico',
    cuando: (c) => c.partidosJugados >= 12,
    opciones: const [
      OpcionDeEvento(
        clave: 'ir_con_los_titulares',
        efectos: [
          EfectoDeEvento(
              clave: 'un_partido_de_mas',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'la_ciudad_se_vuelca',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
        bonusSalarial: _bastanteDinero,
      ),
      OpcionDeEvento(
        clave: 'mandar_a_los_suplentes',
        efectos: [
          EfectoDeEvento(
              clave: 'el_banquillo_coge_ritmo',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
        bonusSalarial: _algoDeDinero,
      ),
      OpcionDeEvento(
        clave: 'no_ir',
        efectos: [
          EfectoDeEvento(
              clave: 'semana_de_descanso',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
        bonusSalarial: _multaFuerte,
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'viaje_infernal',
    cuando: (c) => c.partidosJugados >= 8,
    opciones: const [
      OpcionDeEvento(
        clave: 'viajar_con_margen',
        efectos: [
          EfectoDeEvento(
              clave: 'bien_descansados',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'sin_trabajo_tactico',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
        ],
      ),
      OpcionDeEvento(
        clave: 'como_siempre',
        efectos: [
          EfectoDeEvento(
              clave: 'piernas_cansadas',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'veterano_de_vestuario',
    protagonista: RolDeProtagonista.veterano,
    cuando: (c) => c.vaMal || c.partidosJugados >= 40,
    opciones: const [
      OpcionDeEvento(
        clave: 'dejales_solos',
        efectos: [
          EfectoDeEvento(
              clave: 'se_han_dicho_las_cosas',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'el_vestuario_va_por_libre',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'prefiero_estar_delante',
        efectos: [
          EfectoDeEvento(
              clave: 'la_charla_no_llego_a_pasar',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'sabes_lo_que_hay',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'recta_final',
    cuando: (c) => c.partidosJugados >= 68,
    opciones: const [
      OpcionDeEvento(
        clave: 'tirar_de_los_titulares',
        efectos: [
          EfectoDeEvento(
              clave: 'rotacion_corta',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'titulares_fundidos',
              factor: _muchoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        clave: 'repartir_minutos',
        efectos: [
          EfectoDeEvento(
              clave: 'suplentes_en_pista',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'cargas_controladas',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  // ---------------------------------------------------------------------
  // Segunda tanda (a 2026-08-21). Doce eventos con un tope de cinco por
  // temporada se repetían demasiado pronto en una carrera larga: en cuanto
  // llevabas tres años ya los habías visto todos. Estos ocho suben el
  // catálogo a veinte y, sobre todo, cubren situaciones que no tocaba
  // ninguno de los doce primeros — la directiva, el entrenador como parte
  // interesada, la propiedad y el dinero del club.
  // ---------------------------------------------------------------------

  EventoNarrativo(
    clave: 'rumor_de_traspaso',
    protagonista: RolDeProtagonista.titular,
    cuando: (c) => c.partidosJugados >= 20,
    opciones: const [
      OpcionDeEvento(
        clave: 'prometerle_que_se_queda',
        efectos: [
          EfectoDeEvento(
              clave: 'jugador_liberado',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          // El coste de prometer: el vestuario entero se entera de que
          // aquí el sitio no se pierde por jugar mal.
          EfectoDeEvento(
              clave: 'nadie_teme_por_su_puesto',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'decirle_la_verdad',
        efectos: [
          EfectoDeEvento(
              clave: 'jugador_tocado',
              factor: _muchoPeor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'se_juegan_el_puesto',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'no_contestar',
        efectos: [
          EfectoDeEvento(
              clave: 'duda_en_el_vestuario',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  // El dilema más incómodo del catálogo, y el que mejor usa el eje del
  // dinero: perder a propósito paga y además mejora el draft (que el
  // diálogo no modela), así que la respuesta depende de si te has creído
  // que este año todavía se puede.
  EventoNarrativo(
    clave: 'tanking_de_la_directiva',
    cuando: (c) => c.vaMal && c.partidosJugados >= 55,
    opciones: const [
      OpcionDeEvento(
        clave: 'mirar_al_draft',
        efectos: [
          EfectoDeEvento(
              clave: 'equipo_desarmado',
              factor: _muchoPeor,
              partidos: _unaRachaLarga),
        ],
        bonusSalarial: _bastanteDinero,
      ),
      OpcionDeEvento(
        clave: 'competir_hasta_el_final',
        efectos: [
          EfectoDeEvento(
              clave: 'orgullo_del_grupo',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'jugador_llega_tarde',
    protagonista: RolDeProtagonista.cualquiera,
    cuando: (c) => c.partidosJugados >= 10,
    opciones: const [
      OpcionDeEvento(
        clave: 'multarle',
        efectos: [
          EfectoDeEvento(
              clave: 'disciplina',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
          EfectoDeEvento(
              clave: 'vestuario_tenso',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
        ],
      ),
      OpcionDeEvento(
        clave: 'hablar_en_privado',
        efectos: [
          EfectoDeEvento(
              clave: 'jugador_agradecido',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'el_resto_toma_nota',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'sentarle_un_partido',
        efectos: [
          EfectoDeEvento(
              clave: 'sin_uno_de_la_rotacion',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'norma_clara',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'camiseta_de_una_leyenda',
    cuando: (c) => c.partidosJugados >= 25,
    opciones: const [
      OpcionDeEvento(
        clave: 'ceremonia_a_lo_grande',
        efectos: [
          EfectoDeEvento(
              clave: 'la_ciudad_se_vuelca',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
          EfectoDeEvento(
              clave: 'descanso_roto', factor: _muchoPeor, partidos: 1),
        ],
        bonusSalarial: _bastanteDinero,
      ),
      OpcionDeEvento(
        clave: 'algo_breve',
        efectos: [
          EfectoDeEvento(
              clave: 'homenaje_discreto',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
        bonusSalarial: _algoDeDinero,
      ),
      OpcionDeEvento(
        clave: 'dejarlo_para_el_verano',
        efectos: [
          EfectoDeEvento(
              clave: 'rutina_intacta',
              factor: _algoMejor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'la_leyenda_dolida',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'entrenador_pide_mando',
    cuando: (c) => c.tieneEntrenador && c.partidosJugados >= 12,
    opciones: const [
      OpcionDeEvento(
        clave: 'darle_mando',
        efectos: [
          EfectoDeEvento(
              clave: 'entrenador_con_las_riendas',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'pierdes_el_banquillo',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'mando_compartido',
        efectos: [
          EfectoDeEvento(
              clave: 'equilibrio_incomodo',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'nadie_se_desmarca',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        clave: 'decidir_tu',
        efectos: [
          EfectoDeEvento(
              clave: 'mano_firme',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'entrenador_dolido',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'metida_de_pata_en_redes',
    protagonista: RolDeProtagonista.cualquiera,
    cuando: (c) => c.partidosJugados >= 8,
    opciones: const [
      OpcionDeEvento(
        clave: 'multarle_y_zanjarlo',
        efectos: [
          EfectoDeEvento(
              clave: 'disciplina',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
          EfectoDeEvento(
              clave: 'jugador_resentido',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
      // Sale caro de verdad: defenderle a él te obliga a decir en público
      // lo que piensas del arbitraje, y eso lo paga el club.
      OpcionDeEvento(
        clave: 'defenderle_en_publico',
        efectos: [
          EfectoDeEvento(
              clave: 'el_grupo_va_contigo',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
        ],
        bonusSalarial: _multaFuerte,
      ),
      OpcionDeEvento(
        clave: 'obligarle_a_disculparse',
        efectos: [
          EfectoDeEvento(
              clave: 'disculpa_forzada',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              clave: 'el_ruido_se_apaga',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'precio_de_las_entradas',
    cuando: (c) => c.vaBien && c.partidosJugados >= 25,
    opciones: const [
      OpcionDeEvento(
        clave: 'subirlas',
        efectos: [
          EfectoDeEvento(
              clave: 'la_grada_fria',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
        bonusSalarial: _bastanteDinero,
      ),
      OpcionDeEvento(
        clave: 'subirlas_un_poco',
        efectos: [
          EfectoDeEvento(
              clave: 'algo_de_ruido_en_la_grada',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
        ],
        bonusSalarial: _algoDeDinero,
      ),
      OpcionDeEvento(
        clave: 'no_tocarlas',
        efectos: [
          EfectoDeEvento(
              clave: 'la_grada_empuja',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'nutricionista',
    cuando: (c) => c.partidosJugados >= 6,
    opciones: const [
      OpcionDeEvento(
        clave: 'cambiarlo_todo',
        efectos: [
          EfectoDeEvento(
              clave: 'protestas_en_el_comedor',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'plantilla_mejor_alimentada',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
        bonusSalarial: _gastoModerado,
      ),
      OpcionDeEvento(
        clave: 'solo_en_los_viajes',
        efectos: [
          EfectoDeEvento(
              clave: 'pequeno_cambio',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        clave: 'dejarlo_como_esta',
        efectos: [
          EfectoDeEvento(
              clave: 'rutina_intacta',
              factor: _algoMejor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              clave: 'mismo_de_siempre',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),
];

/// Elige un evento que encaje en [contexto] y que no esté en [yaVistos].
/// Null si no hay ninguno disponible.
EventoNarrativo? elegirEvento(
  ContextoDeEvento contexto, {
  required Set<String> yaVistos,
  required Random random,
}) {
  final disponibles = catalogoDeEventos
      .where((e) => !yaVistos.contains(e.clave) && e.encajaEn(contexto))
      .toList();
  if (disponibles.isEmpty) return null;
  return disponibles[random.nextInt(disponibles.length)];
}
