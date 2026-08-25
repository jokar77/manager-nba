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
    descripcion:
        'Te ofrecen un programa específico de fuerza y explosividad.',
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
];

/// Un evento al azar del catálogo, para la temporada que empieza.
EventoDeCarrera eventoDeCarreraAleatorio(Random rng) =>
    catalogoDeEventosDeCarrera[rng.nextInt(catalogoDeEventosDeCarrera.length)];
