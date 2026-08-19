/// Los eventos narrativos: cosas que pasan alrededor del equipo durante la
/// temporada y sobre las que hay que decidir algo, con consecuencias reales
/// en la pista.
///
/// Este fichero es Dart puro (sin base de datos) para poder probar el
/// catálogo y las condiciones sin montar una partida. La parte que guarda y
/// aplica los efectos está en `eventos_narrativos_repository.dart`.
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
  /// Cómo se llama en la pantalla ("Buen rollo en el vestuario").
  final String etiqueta;

  /// Multiplicador sobre el estado de forma. 1,03 = un 3% mejor.
  final double factor;

  /// Partidos que le quedan de vida.
  final int partidos;

  const EfectoDeEvento({
    required this.etiqueta,
    required this.factor,
    required this.partidos,
  });

  bool get esBueno => factor > 1.0;

  /// Acotado a lo que se considera sano, por si un evento futuro se pasa.
  EfectoDeEvento get acotado => EfectoDeEvento(
        etiqueta: etiqueta,
        factor: factor.clamp(minFactorDeEvento, maxFactorDeEvento),
        partidos: partidos.clamp(1, maxPartidosDeEfecto),
      );
}

/// Una de las respuestas posibles a un evento.
class OpcionDeEvento {
  /// El botón que se pulsa ("Pagar la cena").
  final String etiqueta;

  /// Lo que se le cuenta al usuario DESPUÉS de elegir. Es lo que hace que la
  /// decisión se entienda: sin esto, eliges a ciegas y no aprendes nada.
  final String consecuencia;

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
    required this.etiqueta,
    required this.consecuencia,
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

/// Un evento del catálogo.
class EventoNarrativo {
  /// Identificador estable. Se guarda para no repetir el mismo evento dos
  /// veces en la misma temporada, así que NO se puede cambiar sin romper las
  /// partidas en curso (lo único que pasaría es que un evento ya visto
  /// pudiera repetirse una vez).
  final String clave;

  final String titulo;

  /// El texto que se lee. En segunda persona y corto: esto se lee en un
  /// móvil, en medio de una simulación.
  final String texto;

  final List<OpcionDeEvento> opciones;

  /// Cuándo puede salir. Null = en cualquier momento.
  final bool Function(ContextoDeEvento)? cuando;

  const EventoNarrativo({
    required this.clave,
    required this.titulo,
    required this.texto,
    required this.opciones,
    this.cuando,
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
/// patrocinio es ruido. La referencia es el **salario mínimo, 2,3M**,
/// porque es el escalón que de verdad decide si puedes firmar a alguien o
/// no. Por debajo de eso el dinero es decorativo: sube un número en una
/// pantalla y no desbloquea ni un fichaje.
///
/// Por eso el pellizco pequeño es de 3M —justo por encima del mínimo, o sea
/// "te da para un jugador de rotación"— y el grande de 6M, que ya es un
/// suplente de nivel. Una multa fuerte quita 4M, que duele sin dejarte
/// sin plantilla.
const _bastanteDinero = 6000000;
const _algoDeDinero = 3000000;
const _multaFuerte = -4000000;

/// Todos los eventos que existen. El orden no importa: se sortea entre los
/// que encajan.
final List<EventoNarrativo> catalogoDeEventos = [
  // El ejemplo que pidió el usuario, tal cual: química a cambio de energía.
  EventoNarrativo(
    clave: 'cena_de_equipo',
    titulo: 'Cena de equipo',
    texto: 'Los veteranos quieren organizar una cena para toda la plantilla, '
        'cuerpo técnico incluido. Dicen que hace falta soltarse un poco.',
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Que sea una noche larga',
        consecuencia: 'El vestuario se ha soltado de verdad y se nota en la '
            'pista. Los próximos dos partidos van a costar: nadie ha dormido '
            'lo que debía.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Buen rollo en el vestuario',
              factor: _muchoMejor,
              partidos: _unaRachaLarga),
          EfectoDeEvento(
              etiqueta: 'Piernas cansadas',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Cena corta y a dormir',
        consecuencia: 'Un par de horas, risas y a casa. No arregla el mundo, '
            'pero el grupo está algo más unido y mañana se entrena.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Buen rollo en el vestuario',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Ahora no toca',
        consecuencia: 'Se entrena y se descansa. Se llega con las piernas '
            'frescas al siguiente partido, pero nadie se ha olvidado de que '
            'dijiste que no: el grupo anda más frío de lo que estaba.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Piernas frescas',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'Grupo frío',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'bronca_en_el_entrenamiento',
    titulo: 'Se han liado en el entrenamiento',
    texto: 'Dos jugadores han pasado de las palabras a los empujones en un '
        'cinco contra cinco. Están separados en el vestuario y la prensa ya '
        'lo sabe.',
    // Una pelea con el mejor récord de la liga no se sostiene.
    cuando: (c) => !c.vaBien && c.partidosJugados >= 10,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Multar a los dos',
        consecuencia: 'Queda claro quién manda. El vestuario está tenso unos '
            'días, pero nadie va a volver a hacerlo.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Vestuario tenso',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              etiqueta: 'Disciplina',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Que lo arreglen ellos',
        consecuencia: 'Se dan la mano delante del grupo. Parece sincero.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Buen rollo en el vestuario',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Mirar a otro lado',
        consecuencia: 'Nadie dice nada y el asunto se enquista. En la pista '
            'se ve: no se pasan el balón igual.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Vestuario roto',
              factor: _muchoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'estrella_pide_descanso',
    titulo: 'Tu mejor jugador pide descanso',
    texto: 'Lleva jugando con molestias desde noviembre. No está lesionado, '
        'pero pide sentarse unos partidos para llegar entero al final de '
        'temporada.',
    cuando: (c) => c.partidosJugados >= 30 && c.partidosJugados <= 65,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Que descanse',
        consecuencia: 'Se pierde unos partidos y se nota su ausencia, pero '
            'vuelve fresco y con ganas para el tramo que de verdad importa.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Sin tu mejor jugador',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              etiqueta: 'Plantilla fresca',
              factor: _muchoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Te necesito ahora',
        consecuencia: 'Lo entiende y aprieta los dientes. Rinde, pero se le '
            've arrastrando la pierna y el resto del grupo lo nota.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Plantilla al límite',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'joven_pide_minutos',
    titulo: 'Un joven quiere minutos',
    texto: 'Uno de tus chavales lleva media temporada pegado al banquillo. '
        'Su agente ha llamado: o juega, o el verano que viene se busca la '
        'vida en otro sitio.',
    cuando: (c) => c.jugadoresJovenes >= 2 && c.partidosJugados >= 15,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Dale minutos',
        consecuencia: 'Los primeros partidos se le ven las costuras, pero se '
            'suelta rápido y el vestuario ve que aquí se premia el trabajo.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Rotación verde',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'Grupo enchufado',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Que se lo gane en el entrenamiento',
        consecuencia: 'Se lo toma mal y se le nota en la cara. El resto de '
            'jóvenes toma nota de cómo funcionan las cosas aquí.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Banquillo descontento',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'prensa_dura',
    titulo: 'La prensa os está crujiendo',
    texto: 'Después de la última derrota, el periódico de la ciudad ha '
        'publicado que el vestuario está muerto y que aquí sobra gente. Te '
        'piden una respuesta.',
    cuando: (c) => c.vaMal && c.partidosJugados >= 15,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Defender al grupo en público',
        consecuencia: 'Los jugadores lo agradecen: has puesto la cara por '
            'ellos cuando nadie lo hacía. El problema es que ahora el foco '
            'está en ti, y dentro nadie se siente señalado por lo que está '
            'haciendo mal.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'El grupo va contigo',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'Nadie se da por aludido',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Darles la razón',
        consecuencia: 'Has admitido en público que el equipo no está a la '
            'altura. Es verdad, pero dentro no ha sentado bien.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Vestuario dolido',
              factor: _muchoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'No entrar al trapo',
        consecuencia: 'Dos frases hechas y a entrenar. Sin leña, el asunto '
            'se apaga solo en unos días. Lo que queda dentro es que no '
            'saliste a dar la cara por ellos.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Nadie dio la cara por ellos',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'El ruido se apaga',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'racha_buena',
    titulo: 'Nadie os para',
    texto: 'El equipo va lanzado y se empieza a hablar de vosotros como '
        'candidatos. El entrenador pregunta si aprieta o si levanta el pie '
        'para no quemar a nadie.',
    cuando: (c) => c.vaBien && c.partidosJugados >= 20 && c.tieneEntrenador,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Apretar mientras dure',
        consecuencia: 'Se entrena a tope y la racha se alarga. El desgaste '
            'llegará, pero más tarde.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'A todo gas',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'Desgaste acumulado',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Levantar el pie',
        consecuencia: 'Cargas más suaves y minutos repartidos. La racha se '
            'corta antes de lo que se habría cortado apretando, pero el '
            'equipo llega entero.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Se corta la racha',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              etiqueta: 'Cargas controladas',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'aficion_llena_el_pabellon',
    titulo: 'El pabellón se llena',
    texto: 'Las entradas se están agotando y la afición pide un gesto: un '
        'entrenamiento a puerta abierta, firmas, fotos. Ocupa una mañana '
        'entera de trabajo.',
    cuando: (c) => c.partidosJugados >= 10,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Abrir las puertas',
        consecuencia: 'El pabellón va a empujar de verdad los próximos '
            'partidos, y la tienda del club no ha parado en toda la mañana. '
            'La sesión de trabajo perdida se paga en el siguiente.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'La grada empuja',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
          EfectoDeEvento(
              etiqueta: 'Una mañana sin entrenar',
              factor: _algoPeor,
              partidos: 1),
        ],
        bonusSalarial: _algoDeDinero,
      ),
      OpcionDeEvento(
        etiqueta: 'A entrenar, que es lo que toca',
        consecuencia: 'Se trabaja la mañana entera y se nota en el siguiente '
            'partido. La afición lo entiende a medias: alguna pancarta ha '
            'salido en la grada.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Mañana de trabajo',
              factor: _algoMejor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              etiqueta: 'La grada, fría',
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
    titulo: 'Un patrocinador quiere a la plantilla',
    texto: 'Una marca de la ciudad pone dinero encima de la mesa por un día '
        'entero de rodaje: toda la plantilla, sesión de fotos y anuncio. Es '
        'un día de trabajo perdido y los jugadores ya han puesto cara.',
    cuando: (c) => c.partidosJugados >= 5,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Firmar el acuerdo entero',
        consecuencia: 'Rodaje hasta las tantas y jugadores de mal humor, pero '
            'el club se lleva un buen pellizco que da aire con el tope '
            'salarial.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Día de rodaje',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
        ],
        bonusSalarial: _bastanteDinero,
      ),
      OpcionDeEvento(
        etiqueta: 'Negociar algo más corto',
        consecuencia: 'Media mañana de fotos y a entrenar. Se cobra menos, '
            'pero nadie ha perdido el día entero.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Mañana de fotos',
              factor: _algoPeor,
              partidos: 1),
        ],
        bonusSalarial: _algoDeDinero,
      ),
      OpcionDeEvento(
        etiqueta: 'Decirles que no',
        consecuencia: 'La plantilla se entera de que les has ahorrado el '
            'marrón y llega al siguiente partido con las piernas nuevas. El '
            'dinero, para otro año.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Plantilla descansada',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'partido_benefico',
    titulo: 'Partido benéfico entre semana',
    texto: 'El ayuntamiento organiza un amistoso benéfico y quiere al equipo. '
        'Cae justo entre dos partidos de liga.',
    cuando: (c) => c.partidosJugados >= 12,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Ir con los titulares',
        consecuencia: 'Pabellón lleno y la ciudad volcada con el equipo. Es '
            'un partido más en unas piernas que ya venían justas.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Un partido de más',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              etiqueta: 'La ciudad se vuelca',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
        bonusSalarial: _bastanteDinero,
      ),
      OpcionDeEvento(
        etiqueta: 'Mandar a los suplentes',
        consecuencia: 'Los de abajo cogen minutos de verdad y se les ve '
            'sueltos. La recaudación es menor, pero nadie importante se ha '
            'cansado.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'El banquillo coge ritmo',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
        bonusSalarial: _algoDeDinero,
      ),
      OpcionDeEvento(
        etiqueta: 'No ir',
        consecuencia: 'Semana limpia de trabajo y descanso. El acto se '
            'celebra igual sin vosotros, la ciudad lo lee como un feo y el '
            'club acaba compensándolo de su bolsillo.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Semana de descanso',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
        ],
        bonusSalarial: _multaFuerte,
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'viaje_infernal',
    titulo: 'Cinco partidos fuera en ocho días',
    texto: 'El calendario ha dejado un viaje muy duro. El preparador físico '
        'propone viajar un día antes a cada ciudad, que sale caro pero '
        'ahorra horas de avión.',
    cuando: (c) => c.partidosJugados >= 8,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Viajar con margen',
        consecuencia: 'El equipo llega descansado a cada partido. Lo que se '
            'pierde son sesiones de vídeo y entrenamiento: se viaja mucho y '
            'se trabaja poco.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Bien descansados',
              factor: _algoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'Sin trabajo táctico',
              factor: _algoPeor,
              partidos: _unosPocosPartidos),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Como siempre',
        consecuencia: 'Aviones de madrugada y hoteles a las tres de la '
            'mañana. Se va a notar.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Piernas cansadas',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'veterano_de_vestuario',
    titulo: 'Un veterano se ofrece a hablar con el grupo',
    texto: 'El más veterano de la plantilla te pide cinco minutos con el '
        'equipo, sin cuerpo técnico delante. Dice que hay cosas que se '
        'hablan mejor entre jugadores.',
    cuando: (c) => c.vaMal || c.partidosJugados >= 40,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Déjales solos',
        consecuencia: 'Nadie ha contado qué se dijo ahí dentro, pero el '
            'equipo ha salido distinto al siguiente partido. Lo que se '
            'decidiera, lo decidieron ellos: tú te has quedado fuera de esa '
            'conversación.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Se han dicho las cosas',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'El vestuario va por libre',
              factor: _algoPeor,
              partidos: _unaRachaLarga),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Prefiero estar delante',
        consecuencia: 'La charla se queda a medias —con el jefe delante nadie '
            'dice lo que piensa— pero sales sabiendo exactamente quién está '
            'con quién en ese vestuario.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'La charla no llegó a pasar',
              factor: _algoPeor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'Sabes lo que hay',
              factor: _algoMejor,
              partidos: _unaRachaLarga),
        ],
      ),
    ],
  ),

  EventoNarrativo(
    clave: 'recta_final',
    titulo: 'Se juegan los playoffs en tres semanas',
    texto: 'Quedan pocos partidos y todo está apretado. El cuerpo técnico '
        'pregunta si se acortan las rotaciones para tirar de los mejores.',
    cuando: (c) => c.partidosJugados >= 68,
    opciones: const [
      OpcionDeEvento(
        etiqueta: 'Tirar de los titulares',
        consecuencia: 'Los mejores van a jugarlo casi todo. Rinde ahora y se '
            'paga en abril.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Rotación corta',
              factor: _muchoMejor,
              partidos: _unaRachaCorta),
          EfectoDeEvento(
              etiqueta: 'Titulares fundidos',
              factor: _muchoPeor,
              partidos: _unaRachaCorta),
        ],
      ),
      OpcionDeEvento(
        etiqueta: 'Repartir minutos',
        consecuencia: 'Nadie llega fundido a los playoffs, pero en la recta '
            'final se pierde algún partido por el camino — y el puesto en la '
            'clasificación se decide justo ahora.',
        efectos: [
          EfectoDeEvento(
              etiqueta: 'Suplentes en pista',
              factor: _muchoPeor,
              partidos: _unosPocosPartidos),
          EfectoDeEvento(
              etiqueta: 'Cargas controladas',
              factor: _algoMejor,
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
