import 'package:flutter_test/flutter_test.dart';
import 'package:manager_nba/domain/permisos.dart';

/// La capa de permisos: quién puede usar qué, y por qué el valor por
/// defecto tiene que ser el permisivo.
void main() {
  group('la edición por defecto', () {
    test('sin --dart-define el juego sale entero', () {
      // Este es EL test que protege a los otros 576: mientras el defecto
      // sea "completa", ninguno de ellos tiene que enterarse de que existe
      // una versión gratuita.
      expect(edicionDeCompilacion, Edicion.completa);

      final p = Permisos();
      expect(p.esCompleta, isTrue);
      for (final f in Funcion.values) {
        expect(p.puede(f), isTrue, reason: '$f debería estar abierta');
      }
      expect(p.vePublicidad, isFalse);
    });
  });

  group('la edición gratuita', () {
    test('trae las tres funciones bloqueadas y con anuncios', () {
      final p = Permisos(edicion: Edicion.gratis);

      expect(p.esCompleta, isFalse);
      expect(p.vePublicidad, isTrue);
      for (final f in Funcion.values) {
        expect(p.puede(f, temporada: 1), isFalse,
            reason: '$f debería estar bloqueada en gratis');
      }
    });

    test('la compra lo abre todo y quita la publicidad', () {
      final p = Permisos(edicion: Edicion.gratis);
      p.registrarCompra();

      expect(p.esCompleta, isTrue);
      expect(p.vePublicidad, isFalse);
      for (final f in Funcion.values) {
        expect(p.puede(f, temporada: 1), isTrue);
      }
    });

    test('restaurar una compra vieja vale igual que comprarla ahora', () {
      // Es el caso de reinstalar: la Tienda devuelve que ya estaba pagada
      // y se registra igual que una compra recién hecha.
      final p = Permisos(edicion: Edicion.gratis)..registrarCompra();
      expect(p.esCompleta, isTrue);
      expect(p.puede(Funcion.patrocinadores, temporada: 1), isTrue);
    });
  });

  group('el desbloqueo por vídeo', () {
    test('abre solo la función que se pagó', () {
      final p = Permisos(edicion: Edicion.gratis);
      p.desbloquearPorVideo(Funcion.patrocinadores, temporada: 3);

      expect(p.puede(Funcion.patrocinadores, temporada: 3), isTrue);
      expect(p.puede(Funcion.ranurasExtra, temporada: 3), isFalse,
          reason: 'un vídeo abre lo suyo, no el juego entero');
    });

    test('caduca al cambiar de temporada', () {
      final p = Permisos(edicion: Edicion.gratis);
      p.desbloquearPorVideo(Funcion.patrocinadores, temporada: 3);

      expect(p.puede(Funcion.patrocinadores, temporada: 4), isFalse,
          reason: 'dura una temporada, y los patrocinadores se reeligen '
              'cada año: el bucle sale solo');
      // Y tampoco vale volver atrás en el número.
      expect(p.puede(Funcion.patrocinadores, temporada: 2), isFalse);
    });

    test('sin temporada en curso no aplica', () {
      // El menú de ranuras se pinta antes de que exista ninguna partida:
      // ahí no hay número de temporada contra el que comparar.
      final p = Permisos(edicion: Edicion.gratis);
      p.desbloquearPorVideo(Funcion.ranurasExtra, temporada: 1);

      expect(p.puede(Funcion.ranurasExtra), isFalse);
    });

    test('no deja rastro si ya se tiene el juego entero', () {
      final p = Permisos(edicion: Edicion.gratis);
      p.registrarCompra();
      p.desbloquearPorVideo(Funcion.patrocinadores, temporada: 3);

      // Se comprueba desde dentro: al comprador no se le apunta nada
      // temporal, así que si un día se le devolviera la compra no se
      // quedaría con desbloqueos sueltos de regalo.
      p.olvidarDesbloqueos();
      expect(p.puede(Funcion.patrocinadores, temporada: 3), isTrue,
          reason: 'sigue abierto por la compra, no por el vídeo');
    });

    test('la compra tira los desbloqueos temporales pendientes', () {
      final p = Permisos(edicion: Edicion.gratis);
      p.desbloquearPorVideo(Funcion.patrocinadores, temporada: 3);
      p.registrarCompra();
      p.olvidarDesbloqueos();

      expect(p.puede(Funcion.patrocinadores, temporada: 3), isTrue);
    });
  });

  group('la variable global', () {
    tearDown(() => permisos = Permisos());

    test('se puede sustituir, como almacenDeSlots', () {
      expect(permisos.esCompleta, isTrue);

      permisos = Permisos(edicion: Edicion.gratis);
      expect(permisos.puede(Funcion.patrocinadores, temporada: 1), isFalse);
    });
  });
}
