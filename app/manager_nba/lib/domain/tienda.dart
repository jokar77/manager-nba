/// El puerto de la tienda: la compra única que desbloquea el juego entero.
///
/// Mismo reparto que `anuncios.dart`. Play Billing necesita cuenta de
/// desarrollador, ficha publicada y un móvil de verdad, así que el juego
/// habla con esta interfaz y quien enchufa lo de Google es `main.dart`, y
/// solo en el build de Android.
library;

/// Comprar y restaurar la versión completa.
abstract class Tienda {
  /// Lanza el flujo de compra y espera a que termine.
  ///
  /// Devuelve si quedó pagada. `false` cubre los dos finales que no son
  /// una compra —que la cancele o que el pago se caiga—, porque a efectos
  /// del juego son lo mismo: se sigue sin tener la completa.
  Future<bool> comprarCompleta();

  /// Pregunta si esta cuenta YA la había pagado.
  ///
  /// Es el caso de reinstalar o de estrenar móvil: la compra vive en la
  /// cuenta de Google, no en el aparato, y volver a cobrar por algo ya
  /// pagado es la forma más rápida de ganarse una reseña de una estrella.
  /// Se llama al arrancar, sin que el usuario pida nada.
  Future<bool> restaurarCompra();
}

/// La implementación por defecto: aquí no se vende nada.
///
/// Es la que corre en web y en escritorio. En Steam el juego sale completo
/// por compilación, así que no hay nada que comprar y [comprarCompleta]
/// no se llama nunca; si alguien la llamara, decir "no se compró" es la
/// respuesta honesta.
class TiendaDeMentira implements Tienda {
  /// Qué contesta [comprarCompleta]. Los tests lo ponen a true para probar
  /// el camino de "acaba de pagar".
  bool ventaSaleBien = false;

  /// Qué contesta [restaurarCompra]. A true para probar el reinstalar.
  bool habiaCompraPrevia = false;

  int comprasIntentadas = 0;
  int restauracionesPedidas = 0;

  @override
  Future<bool> comprarCompleta() async {
    comprasIntentadas++;
    return ventaSaleBien;
  }

  @override
  Future<bool> restaurarCompra() async {
    restauracionesPedidas++;
    return habiaCompraPrevia;
  }

  /// Vuelve a empezar. Útil entre dos casos del mismo test.
  void olvidar() {
    ventaSaleBien = false;
    habiaCompraPrevia = false;
    comprasIntentadas = 0;
    restauracionesPedidas = 0;
  }
}

/// La tienda en uso. La app lo deja como está salvo en Android, donde
/// `main.dart` pone la implementación de Play Billing; los tests lo
/// sustituyen.
Tienda tienda = TiendaDeMentira();
