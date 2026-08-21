import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/eventos_narrativos.dart';
import 'package:manager_nba/domain/patrocinadores.dart';
import 'package:manager_nba/i18n/textos.dart';

/// Todas las claves de efecto que se pueden acabar enseñando en la tarjeta
/// del vestuario. Son de dos sitios distintos que comparten tabla y
/// pantalla: los eventos narrativos y los compromisos de patrocinio.
final clavesDeEfecto = <String>{
  ...catalogoDeEventos
      .expand((e) => e.opciones)
      .expand((o) => o.efectos)
      .map((f) => f.clave),
  ...compromisoPorCategoria.values.map((c) => c.clave),
};

/// La red que sustituye al compilador para el guion de los eventos.
///
/// El resto de la interfaz la vigila el analizador: `Textos` es una clase
/// abstracta y si falta un texto en un idioma, `flutter analyze` falla (ver
/// la nota de cabecera de `textos.dart`). El guion de los eventos no puede
/// ser así: son ~150 frases y meterlas como métodos abstractos dejaría esa
/// clase inservible para buscar nada. Viven en mapas, y lo que un mapa no
/// comprueba solo lo puede comprobar un test.
///
/// Por eso este fichero existe: un evento nuevo sin traducir tiene que
/// reventar aquí, no en el móvil de alguien que juega en alemán.
void main() {
  /// Los siete idiomas del juego, cada uno con su guion.
  final guiones = {
    for (final idioma in Idioma.values) idioma: textosDe(idioma).eventos,
  };

  test('los siete idiomas están enchufados', () {
    expect(guiones, hasLength(7));
    // Que no haya dos idiomas devolviendo el mismo objeto por un
    // copiar-pegar en `textosDe`: pasaría desapercibido para siempre.
    final titulosEnCadaIdioma = guiones.values
        .map((g) => g.de(catalogoDeEventos.first.clave).titulo)
        .toSet();
    expect(titulosEnCadaIdioma, hasLength(7),
        reason: 'dos idiomas están devolviendo el mismo guion');
  });

  for (final entrada in guiones.entries) {
    final idioma = entrada.key;
    final guion = entrada.value;

    group('el guion en ${idioma.nombre}', () {
      test('cubre todos los eventos del catálogo, con todas sus opciones', () {
        for (final evento in catalogoDeEventos) {
          // `de` y `opcion` revientan solos si falta la clave; el mensaje de
          // esa excepción ya dice cuál es, así que no hace falta envolverlo.
          final texto = guion.de(evento.clave);

          expect(texto.titulo.trim(), isNotEmpty,
              reason: '${idioma.codigo}: ${evento.clave} sin título');
          expect(texto.texto.trim(), isNotEmpty,
              reason: '${idioma.codigo}: ${evento.clave} sin planteamiento');

          for (final opcion in evento.opciones) {
            final textoDeOpcion = guion.opcion(evento.clave, opcion.clave);
            expect(textoDeOpcion.etiqueta.trim(), isNotEmpty,
                reason: '${idioma.codigo}: ${evento.clave}/${opcion.clave} '
                    'sin etiqueta de botón');
            expect(textoDeOpcion.consecuencia.trim(), isNotEmpty,
                reason: '${idioma.codigo}: ${evento.clave}/${opcion.clave} '
                    'sin consecuencia — sin ella se elige a ciegas y no se '
                    'aprende nada de la decisión');
          }
        }
      });

      test('cubre todas las etiquetas de efecto que se pueden enseñar', () {
        for (final clave in clavesDeEfecto) {
          expect(guion.etiquetaDeEfecto(clave)?.trim(), isNotEmpty,
              reason: '${idioma.codigo}: falta la etiqueta del efecto '
                  '"$clave"');
        }
      });

      test('no traduce dejando texto de sobra que ya no usa nadie', () {
        // Al revés que los dos de arriba: una clave traducida que el
        // catálogo ya no menciona es un evento borrado del que se olvidaron
        // los siete guiones, o una errata en la clave que hace que el texto
        // bueno no se encuentre nunca.
        final delCatalogo = catalogoDeEventos.map((e) => e.clave).toSet();
        expect(guion.eventos.keys.toSet().difference(delCatalogo), isEmpty,
            reason: '${idioma.codigo}: hay eventos traducidos que no están '
                'en el catálogo');

        expect(guion.etiquetasDeEfecto.keys.toSet().difference(clavesDeEfecto),
            isEmpty,
            reason: '${idioma.codigo}: hay etiquetas de efecto traducidas que '
                'ya no las usa ni un evento ni un patrocinio');

        for (final evento in catalogoDeEventos) {
          final delEvento = evento.opciones.map((o) => o.clave).toSet();
          expect(
              guion.de(evento.clave).opciones.keys.toSet().difference(delEvento),
              isEmpty,
              reason: '${idioma.codigo}: ${evento.clave} tiene opciones '
                  'traducidas que ya no existen');
        }
      });

      test('está traducido de verdad y no copiado del español', () {
        // El fallo silencioso de un fichero de traducción nuevo: crearlo
        // copiando el español y traducir solo la mitad. Aquí se ve porque
        // el guion completo de dos idiomas distintos no puede coincidir.
        if (idioma == Idioma.espanol) return;
        final espanol = guiones[Idioma.espanol]!;

        final iguales = catalogoDeEventos
            .where((e) =>
                guion.de(e.clave).titulo == espanol.de(e.clave).titulo)
            .map((e) => e.clave)
            .toList();

        expect(iguales, isEmpty,
            reason: '${idioma.codigo}: estos títulos siguen en español: '
                '${iguales.join(", ")}');
      });
    });
  }
}
