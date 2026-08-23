/// El puerto de los anuncios.
///
/// Ni la lógica del juego ni los tests pueden depender de AdMob: es un SDK
/// que necesita cuenta, red y un móvil de verdad. Así que el juego habla
/// siempre con esta interfaz, y quien enchufa AdMob es `main.dart`, y solo
/// en el build de Android.
///
/// Es el mismo reparto que ya hace `almacenDeSlots` en
/// `slots_repository.dart`: una interfaz, una implementación de verdad y
/// otra de mentira, y una variable de biblioteca que se puede cambiar.
library;

import 'permisos.dart';

/// Enseñar anuncios. Quién los enseña de verdad se decide en `main.dart`.
abstract class Anuncios {
  /// Un anuncio a pantalla completa entre dos pantallas. Devuelve cuando
  /// se ha cerrado, para poder seguir justo después.
  ///
  /// El juego solo pide uno: al pasar de temporada, que es el final de una
  /// etapa larga y el momento natural de cortar. Las reglas de dónde NO
  /// puede salir (encima de un diálogo, a mitad de una decisión, dos
  /// seguidos) son de quien llama, no de aquí.
  Future<void> mostrarInterstitial();

  /// Un vídeo recompensado.
  ///
  /// Devuelve si se vio ENTERO, que es lo único que da derecho a la
  /// recompensa: cerrarlo a los tres segundos no cuenta. Quien decide qué
  /// se desbloquea con ese `true` es quien llama (ver `permisos.dart`),
  /// no este puerto.
  Future<bool> mostrarRecompensado();
}

/// La implementación por defecto: no enseña nada.
///
/// No es solo para los tests. Es la que corre en web y en escritorio, donde
/// AdMob directamente no existe, y es la que hace que el juego entero
/// funcione sin tener cuenta de anuncios montada.
///
/// El vídeo recompensado devuelve `true`: sin anuncios que ver, negar la
/// recompensa dejaría contenido inalcanzable. En la edición completa esto
/// da igual —ahí no se pide ningún vídeo—, pero en un build gratuito de
/// escritorio sería un bloqueo sin salida.
class AnunciosDeMentira implements Anuncios {
  /// Cuántas veces se ha pedido cada cosa. Para que los tests puedan
  /// comprobar que el interstitial sale UNA vez por cambio de temporada y
  /// no dos, que es la regla que más fácil se rompe sin querer.
  int interstitialsPedidos = 0;
  int recompensadosPedidos = 0;

  /// Qué contesta [mostrarRecompensado]. Los tests lo ponen a false para
  /// probar el caso de "cerró el vídeo antes de tiempo".
  bool concedeRecompensa = true;

  @override
  Future<void> mostrarInterstitial() async {
    interstitialsPedidos++;
  }

  @override
  Future<bool> mostrarRecompensado() async {
    recompensadosPedidos++;
    return concedeRecompensa;
  }

  /// Vuelve a empezar. Útil entre dos casos del mismo test.
  void olvidar() {
    interstitialsPedidos = 0;
    recompensadosPedidos = 0;
    concedeRecompensa = true;
  }
}

/// Los anuncios en uso. La app lo deja como está salvo en Android, donde
/// `main.dart` pone la implementación de AdMob; los tests lo sustituyen.
Anuncios anuncios = AnunciosDeMentira();

/// El único anuncio del juego: el que sale al terminar de pasar de
/// temporada. No hay ningún otro sitio desde donde llamar a esto.
///
/// Es el final de una etapa larga —el año se cerró, el draft se eligió, la
/// plantilla está lista— y por tanto el momento natural de cortar: una vez
/// cada varias horas de juego, no una interrupción constante.
///
/// Las tres reglas que hay que respetar no se pueden comprobar desde aquí,
/// así que van de la mano del sitio donde se llama
/// (`ejecutarCambioDeTemporada`):
///
///  - **Nunca encima de un diálogo ni a mitad de una decisión.** Por eso se
///    llama al FINAL del todo, cuando ya no queda ninguna pantalla del
///    cambio de temporada abierta.
///  - **Después de que la transición termine, no antes.**
///  - **Uno por cambio de temporada, nunca dos seguidos.** Se cumple solo:
///    `ejecutarCambioDeTemporada` corre una vez por año y esta es su
///    última línea.
///
/// Quien ya pagó no ve nada: la comprobación es lo primero.
Future<void> anuncioDeCambioDeTemporada() async {
  if (!permisos.vePublicidad) return;
  await anuncios.mostrarInterstitial();
}
