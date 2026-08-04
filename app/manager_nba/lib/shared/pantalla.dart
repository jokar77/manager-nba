import 'package:flutter/widgets.dart';

/// Los tres tamaños de pantalla del juego. El mismo código corre en un
/// iPhone, en un iPad y en una ventana de Windows; lo único que cambia es
/// cuánto sitio hay para repartir.
///
/// Vive en un único archivo a propósito: cuando cada pantalla se inventa su
/// propio corte (una a 640, otra a 600, otra a 700) el resultado es que a
/// ciertos anchos media interfaz se reordena y la otra media no.
enum Tamano {
  /// Teléfono en vertical. Una columna, todo apilado, nada en paralelo.
  compacto,

  /// Teléfono apaisado y tablet en vertical. Caben dos cosas a la vez.
  medio,

  /// Tablet apaisada y escritorio. Es el diseño denso de siempre.
  amplio;

  /// Estrecho de verdad: es donde hay que apilar y donde los objetivos
  /// táctiles tienen que crecer.
  bool get esCompacto => this == Tamano.compacto;

  /// Se toca con el dedo (móvil o tablet), no con el ratón.
  bool get esTactil => this != Tamano.amplio;
}

/// Los cortes. 600 y 1024 son los de Material Design, que es lo que espera
/// cualquiera que haya usado otra app: un iPhone cae en compacto en
/// vertical y en medio apaisado, y un iPad en medio o amplio según cómo lo
/// gires.
const anchoMedio = 600.0;
const anchoAmplio = 1024.0;

Tamano tamanoDe(BuildContext context) =>
    tamanoParaAncho(MediaQuery.sizeOf(context).width);

Tamano tamanoParaAncho(double ancho) {
  if (ancho < anchoMedio) return Tamano.compacto;
  if (ancho < anchoAmplio) return Tamano.medio;
  return Tamano.amplio;
}

/// Altura mínima de cualquier cosa que se toque. En escritorio se deja al
/// valor denso de siempre (con ratón, apretado es una ventaja: cabe más
/// información en pantalla); con el dedo hace falta el mínimo de 48 que
/// marcan tanto Apple como Google.
double alturaTactilMinima(BuildContext context) =>
    tamanoDe(context).esTactil ? 48 : 0;

/// ¿Se pueden usar listas densas? Con ratón sí; con el dedo, no.
bool listasDensas(BuildContext context) => !tamanoDe(context).esTactil;
