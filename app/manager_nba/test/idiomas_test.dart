import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/i18n/textos.dart';

/// Lo que vigila este fichero: que cambiar de idioma sirva de algo y que
/// ningún idioma se quede a medias.
///
/// La clase abstracta ya obliga a que estén TODOS los textos —si falta uno,
/// no compila—, pero no impide el otro fallo típico de una traducción a
/// medio hacer: dejar la cadena en castellano copiada y pegada. Eso sí se
/// puede detectar, y es lo que se hace aquí.
void main() {
  /// Todos los textos de un idioma, en una lista, para poder compararlos
  /// entre sí sin escribir 60 líneas por idioma.
  List<String> todos(Textos t) => [
        t.aceptar, t.cancelar, t.cerrar, t.guardar, t.continuar, t.si, t.no,
        t.cargando, t.nuevaPartida, t.ajustes, t.elegirEquipo, t.sobrescribir,
        t.ranuraOcupada, t.avisoSobrescribir, t.modoOscuro, t.modoOscuroDetalle,
        t.idioma, t.idiomaDetalle, t.calendario, t.calendarioDetalle,
        t.tuEquipo, t.tuEquipoDetalle, t.entrenador, t.banquilloVacante,
        t.clasificacion, t.clasificacionDetalle, t.mercado, t.traspasos,
        t.traspasosDetalle, t.ofertasRecibidas, t.agenciaLibre,
        t.agenciaLibreDetalle, t.competicion, t.nbaCup, t.allStar,
        t.allStarDetalle, t.resumenTemporada, t.resumenTemporadaDetalle,
        t.playoffs, t.premios, t.legado, t.record, t.masaSalarial, t.temporada,
        t.sinEntrenador, t.sinEntrenadorDetalle, t.despedir, t.contratar,
        t.negociar, t.ofrecer, t.sueldo, t.duracion, t.ataque, t.defensa,
        t.desarrollo, t.equilibrado, t.especialistaAtaque,
        t.especialistaDefensa, t.formadorDeJovenes, t.loQuePuedesOfrecer,
        t.topeDeLaFranquicia, t.finiquitos, t.aceptariaLaOferta, t.todaviaNo,
        t.noVaAAceptar, t.anios(1), t.anios(3), t.alAnio('8,0M'),
      ];

  test('los siete idiomas existen y ninguno deja un texto vacío', () {
    expect(Idioma.values.length, 7);
    for (final idioma in Idioma.values) {
      final textos = textosDe(idioma);
      for (final texto in todos(textos)) {
        expect(texto.trim(), isNotEmpty,
            reason: 'a ${idioma.nombre} le falta rellenar un texto');
      }
      expect(idioma.nombre.trim(), isNotEmpty);
      expect(idioma.codigo.length, 2);
    }
  });

  test('ningún idioma es una copia del castellano sin traducir', () {
    // El fallo típico de una traducción a medias: dejar la cadena original
    // pegada. Se permite alguna coincidencia suelta —"No" es "No" en
    // inglés, "NBA Cup" y "All-Star" no se traducen en ningún idioma, y
    // "Mercado" es idéntico en portugués— pero no la mayoría.
    final castellano = todos(const TextosEs());

    for (final idioma in Idioma.values) {
      if (idioma == Idioma.espanol) continue;
      final otros = todos(textosDe(idioma));
      var iguales = 0;
      for (var i = 0; i < castellano.length; i++) {
        if (castellano[i] == otros[i]) iguales++;
      }
      expect(iguales / castellano.length, lessThan(0.25),
          reason: '${idioma.nombre} tiene $iguales de ${castellano.length} '
              'textos idénticos al castellano: parece a medio traducir');
    }
  });

  test('el código guardado se traduce a idioma, y uno raro cae en castellano',
      () {
    expect(Idioma.desdeCodigo('en'), Idioma.ingles);
    expect(Idioma.desdeCodigo('zh'), Idioma.chino);
    // Una partida anterior al selector, o un código de una versión futura.
    expect(Idioma.desdeCodigo(null), Idioma.espanol);
    expect(Idioma.desdeCodigo('klingon'), Idioma.espanol);
  });

  testWidgets('cambiar el idioma cambia lo que se ve en pantalla',
      (tester) async {
    Future<void> montar(Idioma idioma) async {
      await tester.pumpWidget(MaterialApp(
        home: Idiomas(
          textos: textosDe(idioma),
          child: Builder(
            builder: (context) => Scaffold(body: Text(t(context).tuEquipo)),
          ),
        ),
      ));
      await tester.pump();
    }

    await montar(Idioma.espanol);
    expect(find.text('Tu equipo'), findsOneWidget);

    await montar(Idioma.ingles);
    expect(find.text('Your team'), findsOneWidget);
    expect(find.text('Tu equipo'), findsNothing);

    await montar(Idioma.chino);
    expect(find.text('你的球队'), findsOneWidget);
  });

  testWidgets('una pantalla sin Idiomas por encima no revienta: sale en '
      'castellano', (tester) async {
    // Es lo que permite que los tests de widget monten una pantalla suelta
    // sin envolverla, y que un olvido de fontanería no tumbe la app.
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(body: Text(t(context).ajustes)),
      ),
    ));
    await tester.pump();
    expect(find.text('Ajustes'), findsOneWidget);
  });
}
