/// El guion de los eventos narrativos, en los siete idiomas del juego.
///
/// Va aparte de `textos.dart` a propósito. Son ~250 frases de guion —
/// títulos, planteamientos, respuestas y consecuencias— y metidas en la
/// clase [Textos] la dejarían varias veces más larga que todo el resto de
/// la interfaz junta, que es donde se busca de verdad cuando falta un
/// rótulo.
///
/// Cada idioma vive en su propio fichero (`eventos_es.dart`, `eventos_en.dart`
/// ...) como `part` de este, igual que hace `textos.dart` con los suyos.
///
/// Aquí el compilador vigila una parte y un test la otra:
///
/// * **El compilador** obliga a que cada idioma implemente [eventos] y
///   [etiquetasDeEfecto]. Si se añade un idioma, no compila hasta que estén.
/// * **El test** (`eventos_traducidos_test.dart`) comprueba que las claves
///   de dentro de esos mapas cubran el catálogo entero: cada evento, cada
///   opción de cada evento y cada etiqueta de efecto, en los siete idiomas.
///   Un mapa no puede comprobarlo el analizador, y un evento nuevo sin
///   traducir tiene que reventar en CI, no delante del usuario.
///
/// El registro de las traducciones: segunda persona, frases cortas y
/// lenguaje de vestuario, no de nota de prensa. Esto se lee en un móvil en
/// mitad de una simulación.
library;

part 'eventos_es.dart';
part 'eventos_en.dart';
part 'eventos_fr.dart';
part 'eventos_pt.dart';
part 'eventos_de.dart';
part 'eventos_it.dart';
part 'eventos_zh.dart';

/// Una de las respuestas de un evento, ya escrita.
class TextoDeOpcion {
  /// El botón que se pulsa ("Pagar la cena").
  final String etiqueta;

  /// Lo que se le cuenta al usuario DESPUÉS de elegir. Es lo que hace que la
  /// decisión se entienda: sin esto, eliges a ciegas y no aprendes nada.
  final String consecuencia;

  const TextoDeOpcion(this.etiqueta, this.consecuencia);
}

/// Un evento del catálogo, ya escrito.
class TextoDeEvento {
  final String titulo;

  /// El texto que se lee. En segunda persona y corto.
  final String texto;

  /// Las respuestas, por la clave que usa `catalogoDeEventos`.
  final Map<String, TextoDeOpcion> opciones;

  const TextoDeEvento({
    required this.titulo,
    required this.texto,
    required this.opciones,
  });
}

/// El guion completo en un idioma.
abstract class TextosDeEventos {
  const TextosDeEventos();

  /// Cada evento del catálogo por su clave.
  Map<String, TextoDeEvento> get eventos;

  /// El nombre de cada efecto de vestuario por su clave
  /// ('buen_rollo' → "Buen rollo en el vestuario").
  Map<String, String> get etiquetasDeEfecto;

  /// El texto de un evento. Revienta si falta, y a propósito: un evento sin
  /// traducir es un fallo de programación, y devolver la clave en crudo lo
  /// escondería hasta que apareciera en pantalla delante del usuario.
  TextoDeEvento de(String clave) {
    final texto = eventos[clave];
    if (texto == null) {
      throw StateError('evento sin traducir: $clave');
    }
    return texto;
  }

  /// El texto de una opción dentro de un evento.
  TextoDeOpcion opcion(String claveEvento, String claveOpcion) {
    final texto = de(claveEvento).opciones[claveOpcion];
    if (texto == null) {
      throw StateError('opción sin traducir: $claveEvento / $claveOpcion');
    }
    return texto;
  }

  /// El nombre de un efecto, o null si no se conoce esa clave.
  ///
  /// Este SÍ devuelve null en vez de reventar, y es la única excepción: los
  /// efectos se guardan en la base de datos y una partida empezada con una
  /// versión anterior puede traer claves que ya no existen. Quien lo llama
  /// tiene una etiqueta de reserva para ese caso.
  String? etiquetaDeEfecto(String clave) => etiquetasDeEfecto[clave];
}
