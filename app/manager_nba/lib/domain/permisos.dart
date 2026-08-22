/// Quién puede usar qué.
///
/// La tentación al monetizar es repartir `if (esGratis)` por todo el juego.
/// Eso envejece mal: cuando dentro de dos meses se añada un modo nuevo a la
/// lista de bloqueados hay que ir a buscarlos uno a uno. Aquí se hace al
/// revés: una lista de funciones, y tres fuentes de permiso que se suman.
///
/// Añadir un bloqueo nuevo es, entonces, una entrada más en [Funcion] y la
/// línea que lo consulte donde toque. Nada más.
///
/// Este fichero es Dart puro a propósito: ni base de datos, ni AdMob, ni
/// Play. Así se puede probar entero sin nada montado, y el día que entren
/// los puertos `Anuncios` y `Tienda` hablarán con esto y no al revés.
library;

/// Lo que la versión gratuita tiene bloqueado.
///
/// La lista se va a mover (hay modos de juego en mente), así que el resto
/// del juego nunca pregunta "¿soy gratis?" sino "¿puedo hacer esto?".
enum Funcion {
  /// La pantalla de patrocinadores. En gratis sale con los cuatro
  /// bloqueados y un vídeo recompensado los abre **todos** para esa
  /// temporada: la gracia de esa pantalla es elegir entre cuatro que piden
  /// cosas distintas, y un vídeo por cabeza haría que lo óptimo fuera
  /// verlos los cuatro, que es justo la decisión que se quiso crear.
  patrocinadores,

  /// Las ranuras de guardado más allá de la primera (gratis 1, completa 3).
  ranurasExtra,

  /// Simular la temporada entera de golpe. Todavía no existe en el juego;
  /// la entrada está aquí porque el bloqueo se decidió con las otras dos.
  simularTemporadaEntera,
}

/// Con qué edición se compiló el binario.
enum Edicion {
  /// Play Store: con anuncios y con la compra dentro.
  gratis,

  /// Steam, escritorio y builds internas: sale con todo abierto y sin nada
  /// que vender.
  completa,
}

/// La edición sale de `--dart-define=EDICION=...`.
///
/// El valor por defecto es [Edicion.completa] **a propósito**: así
/// `flutter run` y toda la suite de tests siguen viendo el juego entero sin
/// tocar ni una línea, y es el build gratuito el que tiene que pedirlo:
///
/// ```
/// flutter build appbundle --dart-define=EDICION=gratis   # Play, con anuncios
/// flutter build windows                                  # Steam, todo abierto
/// ```
///
/// Que el defecto sea el permisivo es deliberado: si algún día se cuela un
/// build sin el `--dart-define`, el fallo es "un usuario tuvo de más", no
/// "todo el mundo se quedó fuera de lo que había pagado".
const _edicionCompilada = String.fromEnvironment(
  'EDICION',
  defaultValue: 'completa',
);

/// La edición de este binario. Ver [_edicionCompilada].
Edicion get edicionDeCompilacion =>
    _edicionCompilada == 'gratis' ? Edicion.gratis : Edicion.completa;

/// Las tres fuentes de permiso, sumadas.
///
/// 1. **La compilación**: [Edicion.completa] lo abre todo.
/// 2. **La compra**: un pago único, para siempre. Quién la recuerda entre
///    sesiones es el puerto `Tienda` (`restaurarCompra()`), no esta clase:
///    aquí solo se anota con [registrarCompra].
/// 3. **El vídeo recompensado**: abre UNA función y solo durante la
///    temporada en curso.
class Permisos {
  Permisos({Edicion? edicion}) : _edicion = edicion ?? edicionDeCompilacion;

  final Edicion _edicion;

  /// Se enciende con [registrarCompra], que es lo que llamará el puerto
  /// `Tienda` tanto al comprar como al restaurar una compra vieja.
  bool _comprada = false;

  /// Función -> número de temporada en la que se pagó el vídeo. Caduca sola
  /// al cambiar de año, sin tener que acordarse de limpiar nada: basta con
  /// que el número deje de coincidir.
  final Map<Funcion, int> _porVideo = {};

  /// Si tiene el juego entero, sea por compilación o porque lo pagó.
  bool get esCompleta => _edicion == Edicion.completa || _comprada;

  /// Si a este jugador se le enseñan anuncios.
  ///
  /// Lo consultará el puerto `Anuncios` antes del interstitial de cambio de
  /// temporada. Quien compra deja de verlos en el acto.
  bool get vePublicidad => !esCompleta;

  /// Si [funcion] está disponible ahora mismo.
  ///
  /// [temporada] es el número de temporada en curso, y solo hace falta para
  /// los desbloqueos por vídeo. Se pasa `null` desde donde todavía no hay
  /// partida abierta —el menú de ranuras, sin ir más lejos, se pinta antes
  /// de que exista ninguna temporada—, y ahí un desbloqueo temporal
  /// simplemente no aplica.
  bool puede(Funcion funcion, {int? temporada}) {
    if (esCompleta) return true;
    if (temporada == null) return false;
    return _porVideo[funcion] == temporada;
  }

  /// Anota que se pagó la versión completa.
  ///
  /// Los desbloqueos temporales dejan de tener sentido a partir de aquí:
  /// se tiran para que no queden colgando.
  void registrarCompra() {
    _comprada = true;
    _porVideo.clear();
  }

  /// Abre [funcion] durante la temporada [temporada] y solo esa. Es lo que
  /// se llama cuando un vídeo recompensado termina de verse.
  ///
  /// No hace nada si ya se tiene el juego entero: ver un vídeo teniéndolo
  /// comprado no debería dejar rastro.
  void desbloquearPorVideo(Funcion funcion, {required int temporada}) {
    if (esCompleta) return;
    _porVideo[funcion] = temporada;
  }

  /// Solo para tests: deja los permisos como recién arrancados.
  void olvidarDesbloqueos() => _porVideo.clear();
}

/// Los permisos en uso. La app lo deja como está; los tests lo sustituyen.
///
/// Mismo patrón que `almacenDeSlots` en `slots_repository.dart`: una
/// variable de biblioteca que se puede cambiar, en vez de arrastrar una
/// dependencia por medio juego.
Permisos permisos = Permisos();
