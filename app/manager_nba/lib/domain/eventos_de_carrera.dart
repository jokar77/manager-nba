/// Eventos de decisión del Modo Carrera: antes de cada temporada eliges
/// entre 2-3 opciones y eso te empuja la media un poco, para arriba o para
/// abajo — el equivalente sencillo de las decisiones de Copero. Primera
/// versión sin condiciones de contexto (edad, fase, forma...): un evento al
/// azar del catálogo, cada temporada. Se puede afinar más adelante sin
/// tocar cómo se aplica el efecto (ver `avanzarTemporadaJuvenil`/
/// `avanzarTemporadaNba` en `modo_carrera_repository.dart`).
library;

import 'dart:math';

class OpcionDeEventoDeCarrera {
  final String texto;

  /// Lo que suma (o resta) a tu media esta temporada. Se aplica DESPUÉS de
  /// la progresión normal, así que nunca sustituye el crecimiento natural
  /// — solo lo empuja un poco en un sentido u otro.
  final int efectoMedia;

  final String mensaje;

  const OpcionDeEventoDeCarrera({
    required this.texto,
    required this.efectoMedia,
    required this.mensaje,
  });
}

class EventoDeCarrera {
  final String titulo;
  final String descripcion;
  final List<OpcionDeEventoDeCarrera> opciones;

  const EventoDeCarrera({
    required this.titulo,
    required this.descripcion,
    required this.opciones,
  });
}

const catalogoDeEventosDeCarrera = <EventoDeCarrera>[
  EventoDeCarrera(
    titulo: 'Plan de pretemporada',
    descripcion:
        'Tu entrenador te propone un plan de trabajo extra antes de que arranque la temporada.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'A tope, sin descanso',
        efectoMedia: 2,
        mensaje: 'Llegas más fuerte, aunque algo cansado.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Un plan equilibrado',
        efectoMedia: 1,
        mensaje: 'Progresas sin arriesgar de más.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Prefieres descansar',
        efectoMedia: 0,
        mensaje: 'Llegas fresco, pero sin ventaja extra.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Horas extra de tiro',
    descripcion:
        'Puedes quedarte cada día una hora más en la cancha trabajando el tiro.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Todos los días',
        efectoMedia: 2,
        mensaje: 'El trabajo de más se nota en tu juego.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Solo antes de partido',
        efectoMedia: 1,
        mensaje: 'Un empujón pequeño, sin sobrecargarte.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'No hace falta',
        efectoMedia: 0,
        mensaje: 'Te centras en lo de siempre.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Estudiar vídeo',
    descripcion:
        'El cuerpo técnico te pasa horas de vídeo de rivales para preparar la temporada.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Verlo todo con detalle',
        efectoMedia: 1,
        mensaje: 'Lees mejor el juego, aunque sea un detalle pequeño.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Un repaso rápido',
        efectoMedia: 0,
        mensaje: 'Te quedas con lo básico.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Molestia en la rodilla',
    descripcion:
        'Notas una molestia leve. El fisio te da a elegir cómo llevarla.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Jugar igual, apretando los dientes',
        efectoMedia: -1,
        mensaje: 'Aguantas, pero te pasa factura.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Rehabilitación a fondo',
        efectoMedia: 1,
        mensaje: 'Cuidarte a tiempo compensa.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Trabajo con el preparador físico',
    descripcion: 'Te ofrecen un programa específico de fuerza y explosividad.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Apuntarte',
        efectoMedia: 2,
        mensaje: 'Llegas más explosivo a la temporada.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Seguir con tu rutina de siempre',
        efectoMedia: 0,
        mensaje: 'Nada cambia, para bien ni para mal.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Vida fuera de la cancha',
    descripcion:
        'Entre viajes, entrevistas y vida social, cuesta encontrar el equilibrio.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Priorizar el descanso',
        efectoMedia: 1,
        mensaje: 'Llegas a los partidos con la cabeza despejada.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Vivir el momento',
        efectoMedia: -1,
        mensaje: 'Lo pasas bien, pero se nota en la cancha.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Se acaba la temporada: ¿y el verano?',
    descripcion:
        'Con la temporada cerrada, tienes por delante meses libres antes de la pretemporada.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Desconectar del todo',
        efectoMedia: -1,
        mensaje:
            'Vuelves con la cabeza descansada, pero se nota la falta de trabajo.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Vacaciones con algo de trabajo',
        efectoMedia: 1,
        mensaje:
            'Encuentras el equilibrio justo entre descansar y no perder el ritmo.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Entrenar todo el verano',
        efectoMedia: 2,
        mensaje:
            'Llegas a la pretemporada como un tren — aunque sin haber desconectado nada.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Torneo de verano',
    descripcion:
        'Te invitan a jugar un torneo amistoso entre profesionales, fuera de la liga.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Apuntarte',
        efectoMedia: 1,
        mensaje:
            'Coges ritmo de competición antes de que empiece la liga de verdad.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Pasar del torneo',
        efectoMedia: 0,
        mensaje: 'Prefieres llegar fresco a la pretemporada.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Cambio de dieta',
    descripcion:
        'Un nutricionista te propone cambiar por completo tu forma de alimentarte.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Seguirlo a rajatabla',
        efectoMedia: 1,
        mensaje: 'El cuerpo responde mejor de lo que esperabas.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Hacer solo ajustes pequeños',
        efectoMedia: 0,
        mensaje: 'Cambios discretos, resultados discretos.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Oferta publicitaria',
    descripcion:
        'Una marca te ofrece un contrato jugoso que te robaría buena parte del verano en sesiones de fotos y anuncios.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Firmar el contrato',
        efectoMedia: -1,
        mensaje:
            'El dinero está bien, pero el verano se te ha ido en otras cosas.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Rechazarlo: toca entrenar',
        efectoMedia: 1,
        mensaje: 'Te centras en lo tuyo y dejas el dinero fácil para otro año.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Trabajo mental',
    descripcion:
        'El club te ofrece sesiones con un psicólogo deportivo antes de que arranque la temporada.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Aprovecharlas',
        efectoMedia: 1,
        mensaje: 'Llegas más fuerte de cabeza a los momentos difíciles.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'No las necesitas',
        efectoMedia: 0,
        mensaje: 'Sigues con tu rutina de siempre.',
      ),
    ],
  ),
  EventoDeCarrera(
    titulo: 'Se lesiona un compañero de posición',
    descripcion:
        'En pretemporada, un compañero de tu misma posición se lesiona y el cuerpo técnico te pide dar un paso adelante.',
    opciones: [
      OpcionDeEventoDeCarrera(
        texto: 'Dar un paso adelante',
        efectoMedia: 2,
        mensaje:
            'La responsabilidad extra te hace crecer más rápido de lo normal.',
      ),
      OpcionDeEventoDeCarrera(
        texto: 'Seguir a tu ritmo',
        efectoMedia: 0,
        mensaje: 'Prefieres no precipitarte y esperar tu momento.',
      ),
    ],
  ),
];

/// Un evento al azar del catálogo, para la temporada que empieza.
EventoDeCarrera eventoDeCarreraAleatorio(Random rng) =>
    catalogoDeEventosDeCarrera[rng.nextInt(catalogoDeEventosDeCarrera.length)];
