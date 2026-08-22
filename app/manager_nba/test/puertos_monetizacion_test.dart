import 'package:flutter_test/flutter_test.dart';
import 'package:manager_nba/domain/anuncios.dart';
import 'package:manager_nba/domain/permisos.dart';
import 'package:manager_nba/domain/tienda.dart';

/// Los dos puertos que tocan Google —anuncios y tienda— y cómo se juntan
/// con la capa de permisos.
///
/// Lo que se prueba aquí no es AdMob ni Play Billing: es que el juego
/// pueda funcionar entero SIN ellos, que es lo que permite que la web, el
/// escritorio y la suite no dependan de tener cuentas montadas.
void main() {
  group('el puerto de anuncios', () {
    late AnunciosDeMentira falsos;

    setUp(() {
      falsos = AnunciosDeMentira();
      anuncios = falsos;
    });

    tearDown(() => anuncios = AnunciosDeMentira());

    test('por defecto no hay que montar nada para que el juego tire', () {
      expect(anuncios, isA<AnunciosDeMentira>(),
          reason: 'sin esto, arrancar en web o escritorio pediría AdMob');
    });

    test('lleva la cuenta de los interstitials pedidos', () async {
      await anuncios.mostrarInterstitial();
      await anuncios.mostrarInterstitial();

      // El contador existe para que se pueda comprobar la regla que más
      // fácil se rompe sin querer: uno por cambio de temporada, nunca dos
      // seguidos. Quien la hace cumplir es quien llama, no el puerto.
      expect(falsos.interstitialsPedidos, 2);
    });

    test('el vídeo visto entero da la recompensa', () async {
      expect(await anuncios.mostrarRecompensado(), isTrue);
      expect(falsos.recompensadosPedidos, 1);
    });

    test('cerrarlo antes de tiempo no la da', () async {
      falsos.concedeRecompensa = false;
      expect(await anuncios.mostrarRecompensado(), isFalse,
          reason: 'tres segundos de vídeo no son un vídeo visto');
    });

    test('sin anuncios de verdad la recompensa se concede igual', () async {
      // En web y escritorio no hay AdMob. Negar la recompensa ahí dejaría
      // los patrocinadores inalcanzables en un build gratuito de PC: un
      // bloqueo sin salida, no una venta.
      expect(await AnunciosDeMentira().mostrarRecompensado(), isTrue);
    });
  });

  group('el puerto de la tienda', () {
    late TiendaDeMentira falsa;

    setUp(() {
      falsa = TiendaDeMentira();
      tienda = falsa;
    });

    tearDown(() => tienda = TiendaDeMentira());

    test('por defecto no vende nada', () async {
      expect(await tienda.comprarCompleta(), isFalse,
          reason: 'en web y en Steam no hay nada que vender');
    });

    test('una compra que sale bien se anota', () async {
      falsa.ventaSaleBien = true;
      expect(await tienda.comprarCompleta(), isTrue);
      expect(falsa.comprasIntentadas, 1);
    });

    test('cancelar y que falle el pago son lo mismo para el juego', () async {
      falsa.ventaSaleBien = false;
      expect(await tienda.comprarCompleta(), isFalse);
    });

    test('restaurar encuentra una compra vieja', () async {
      falsa.habiaCompraPrevia = true;
      expect(await tienda.restaurarCompra(), isTrue);
      expect(falsa.restauracionesPedidas, 1);
    });
  });

  group('juntando los puertos con los permisos', () {
    test('comprar abre el juego entero y quita la publicidad', () async {
      final falsa = TiendaDeMentira()..ventaSaleBien = true;
      final p = Permisos(edicion: Edicion.gratis);
      expect(p.vePublicidad, isTrue);

      if (await falsa.comprarCompleta()) p.registrarCompra();

      expect(p.esCompleta, isTrue);
      expect(p.vePublicidad, isFalse);
    });

    test('restaurar al arrancar vale igual que comprar', () async {
      final falsa = TiendaDeMentira()..habiaCompraPrevia = true;
      final p = Permisos(edicion: Edicion.gratis);

      if (await falsa.restaurarCompra()) p.registrarCompra();

      expect(p.puede(Funcion.patrocinadores, temporada: 1), isTrue,
          reason: 'reinstalar no puede costar otra compra');
    });

    test('el vídeo abre los patrocinadores solo esa temporada', () async {
      final falsos = AnunciosDeMentira();
      final p = Permisos(edicion: Edicion.gratis);

      if (await falsos.mostrarRecompensado()) {
        p.desbloquearPorVideo(Funcion.patrocinadores, temporada: 3);
      }

      expect(p.puede(Funcion.patrocinadores, temporada: 3), isTrue);
      expect(p.puede(Funcion.patrocinadores, temporada: 4), isFalse,
          reason: 'los patrocinadores se reeligen cada año: el bucle sale '
              'solo');
    });

    test('un vídeo abandonado no desbloquea nada', () async {
      final falsos = AnunciosDeMentira()..concedeRecompensa = false;
      final p = Permisos(edicion: Edicion.gratis);

      if (await falsos.mostrarRecompensado()) {
        p.desbloquearPorVideo(Funcion.patrocinadores, temporada: 3);
      }

      expect(p.puede(Funcion.patrocinadores, temporada: 3), isFalse);
    });
  });
}
