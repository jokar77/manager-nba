import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show FontLoader;

/// Mete la tipografía del juego en un test de widgets.
///
/// **`flutter test` NO carga las fuentes que declara el `pubspec.yaml`**:
/// mide con una de relleno. Como todo el rediseño se apoya en una
/// condensada —los titulares en mayúsculas solo caben porque la letra es
/// estrecha—, sin esto los tests de desborde estarían comprobando una
/// pantalla que no es la que se publica: una más ancha.
///
/// Se llama desde `setUpAll` en cualquier test que mida sitio.
Future<void> cargarTipografiaDelJuego() async {
  final cargador = FontLoader('Saira Condensed');
  for (final fichero in const [
    'assets/fonts/SairaCondensed-Bold.ttf',
    'assets/fonts/SairaCondensed-ExtraBold.ttf',
  ]) {
    final bytes = File(fichero).readAsBytesSync();
    cargador.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await cargador.load();
}
