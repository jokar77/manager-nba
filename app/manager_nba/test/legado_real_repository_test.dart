import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/legado_real_repository.dart';

/// El scoring sobre carrera NBA real (datos de Kaggle, cruzados con
/// nba_legacy_scoring.js del usuario) y los datos que alimentan la ficha
/// del Legado. legado_real_scoring.json trae dos grupos: la plantilla
/// actual del juego (los que pueden retirarse dentro de tu partida) y las
/// leyendas ya retiradas que el juego importa como historia real, cuya
/// ficha también tiene que enseñar su carrera de verdad.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LeBron James: Cleveland cruza de sobra el umbral de camiseta y '
      'entra en el Hall of Fame', () async {
    final equipo = await equipoQueRetiraCamisetaReal('LeBron James');
    expect(equipo, anyOf('CLE', 'LAL', 'MIA'));
    expect(await entraEnHofReal('LeBron James'), isTrue);
  });

  test('con varios equipos elegibles, gana el preferido si está entre '
      'ellos; si no, el de mayor puntuación', () async {
    final conPreferidoLal =
        await equipoQueRetiraCamisetaReal('LeBron James', preferido: 'LAL');
    expect(conPreferidoLal, 'LAL');

    // Un preferido que no es de verdad uno de sus equipos no cuela.
    final conPreferidoAjeno =
        await equipoQueRetiraCamisetaReal('LeBron James', preferido: 'BOS');
    expect(conPreferidoAjeno, anyOf('CLE', 'LAL', 'MIA'));
  });

  test('una leyenda de varias franquicias retira camiseta en TODAS: LeBron '
      'cuelga en Cleveland, Miami y los Lakers', () async {
    final equipos = await equiposQueRetiranCamisetaReal('LeBron James');
    expect(equipos, containsAll(['CLE', 'MIA', 'LAL']),
        reason: 'antes solo se le retiraba una y las otras dos franquicias '
            'donde hizo historia se quedaban sin homenaje');
    // Sin repetidos aunque tenga dos etapas en Cleveland.
    expect(equipos.toSet().length, equipos.length);

    // El preferido (donde jugaba en tu partida) va el primero, pero los
    // demás siguen ahí.
    final conPreferido =
        await equiposQueRetiranCamisetaReal('LeBron James', preferido: 'MIA');
    expect(conPreferido.first, 'MIA');
    expect(conPreferido.toSet(), equipos.toSet());
  });

  test('quien solo hizo historia en un sitio sigue retirando una sola: '
      'Harden en Houston y nada más', () async {
    expect(await equiposQueRetiranCamisetaReal('James Harden'), ['HOU']);
  });

  test('un nombre sin carrera NBA real (novato de draft) no encuentra nada, '
      'sin reventar', () async {
    expect(await datosRealesDe('Este Nombre No Existe En La NBA'), isNull);
    expect(
        await equipoQueRetiraCamisetaReal('Este Nombre No Existe En La NBA'),
        isNull);
    expect(await entraEnHofReal('Este Nombre No Existe En La NBA'), isFalse);
  });

  test('James Harden: Houston, no cualquiera de sus otros cinco equipos',
      () async {
    // Caso puntual pedido por el usuario: 9 años, 8 All-Star, 1 MVP y 7
    // All-NBA con Houston tienen que ganar de sobra a sus pasos más cortos
    // por Brooklyn, Cleveland, Clippers, OKC y Philadelphia.
    final equipo = await equipoQueRetiraCamisetaReal('James Harden');
    expect(equipo, 'HOU');
  });

  test('un titular sólido sin premios ni anillos no cruza ningún umbral',
      () async {
    // Alguien con carrera larga pero sin trofeos no debería retirar
    // camiseta en ningún sitio ni entrar al HOF: calibra que el umbral no
    // está regalado.
    final datos = await datosRealesDe('Jonas Valančiūnas');
    expect(datos, isNotNull, reason: 'tiene que tener carrera real');
    expect(await entraEnHofReal('Jonas Valančiūnas'), isFalse);
    expect(await equipoQueRetiraCamisetaReal('Jonas Valančiūnas'), isNull);
  });

  group('datos para la ficha del Legado', () {
    test('las leyendas ya retiradas también están: su ficha es lo único que '
        'el juego puede enseñar de ellas', () async {
      // Jordan no juega en la partida (se retiró hace décadas), pero sale
      // en el Hall of Fame real y con camiseta retirada en Chicago, y esas
      // fichas tienen que llevar a algún sitio.
      final jordan = await carreraRealDe('Michael Jordan');
      expect(jordan, isNotNull);
      // Cifras de verdad, no aproximaciones: 32.292 puntos y 30,1 de media
      // son sus totales reales de carrera.
      expect(jordan!.puntos, 32292);
      expect(jordan.puntosPorPartido, closeTo(30.1, 0.05));
      expect(jordan.mvp, 5);
      expect(jordan.mvpFinales, 6);
      expect(jordan.anillos, 6);
      expect(jordan.titulosDeAnotacion, 10);
    });

    test('la etapa con un equipo concreto son sus años y su producción ahí, '
        'no los de su carrera entera', () async {
      // Es lo que pide la ficha de una camiseta retirada. Jordan promedió
      // 31,5 con los Bulls y 21,2 en su etapa final en Washington: la
      // media de carrera (30,1) no sirve para ninguna de las dos.
      final bulls = await etapaRealCon('Michael Jordan', 'CHI');
      expect(bulls, isNotNull);
      expect(bulls!.partidos, 930);
      expect(bulls.puntosPorPartido, closeTo(31.5, 0.05));
      expect(bulls.anillos, 6);

      final wizards = await etapaRealCon('Michael Jordan', 'WAS');
      expect(wizards!.puntosPorPartido, closeTo(21.2, 0.05));
      expect(wizards.anillos, 0);

      // Un equipo en el que nunca jugó no se inventa una etapa.
      expect(await etapaRealCon('Michael Jordan', 'BOS'), isNull);
    });

    test('un jugador con varias camisetas retiradas tiene una etapa distinta '
        'por equipo', () async {
      // El caso que pidió el usuario: LeBron con Cleveland, Miami y
      // Lakers. Cada ficha tiene que hablar de su etapa, no repetir la
      // misma carrera tres veces.
      final etapas = await etapasRealesDe('LeBron James');
      expect(etapas.map((e) => e.equipo), containsAll(['CLE', 'LAL', 'MIA']));

      final cle = etapas.firstWhere((e) => e.equipo == 'CLE');
      final mia = etapas.firstWhere((e) => e.equipo == 'MIA');
      expect(cle.anillos, 1);
      expect(mia.anillos, 2, reason: 'los dos títulos del Heat');
      expect(cle.partidos, greaterThan(mia.partidos),
          reason: 'once temporadas en Cleveland contra cuatro en Miami');
    });

    test('las etapas van en orden cronológico, del primer equipo al último',
        () async {
      final etapas = await etapasRealesDe('LeBron James');
      final anios = etapas.map((e) => e.primeraTemporada).toList();
      expect(anios, orderedEquals([...anios]..sort()));
      expect(etapas.first.equipo, 'CLE',
          reason: 'empezó en Cleveland, no donde más partidos jugó');
    });

    test('la temporada se enseña como la nombra el juego, no como el año '
        'suelto del dataset', () {
      // El dataset guarda el año en que TERMINA la temporada.
      expect(etiquetaTemporadaReal(1998), '1997-98');
      expect(etiquetaTemporadaReal(2000), '1999-00');
    });

    test('un nombre sin datos reales no revienta ninguna de las lecturas de '
        'ficha', () async {
      expect(await carreraRealDe('Nadie De La NBA'), isNull);
      expect(await etapaRealCon('Nadie De La NBA', 'CHI'), isNull);
      expect(await etapasRealesDe('Nadie De La NBA'), isEmpty);
    });

    test('los homónimos no se mezclan: cada nombre trae la carrera del '
        'jugador correcto', () async {
      // El asset se busca por nombre, y en 80 años de NBA hay repetidos.
      // Sin desambiguar, al Brandon Williams de la plantilla actual le caía
      // el anillo del Brandon Williams que jugó en 1998-2003.
      final brandon = await carreraRealDe('Brandon Williams');
      expect(brandon, isNotNull);
      expect(brandon!.anillos, 0,
          reason: 'el de la plantilla actual no ha ganado ningún anillo');

      // Con las leyendas manda el peso de la carrera, no quién jugó más
      // tarde: la ficha es la del pívot del Hall of Fame, no la de su hijo,
      // que jugó 7 partidos.
      final ewing = await carreraRealDe('Patrick Ewing');
      expect(ewing!.allStar, 11);
      expect(ewing.partidos, greaterThan(1000));
    });
  });

  group('años exactos de los premios (no solo el conteo)', () {
    test('Michael Jordan: MVP, MVP de Finales, DPOY y máximo anotador con '
        'sus temporadas reales', () async {
      final jordan = await carreraRealDe('Michael Jordan');
      expect(jordan, isNotNull);
      expect(jordan!.aniosMvp, [1988, 1991, 1992, 1996, 1998]);
      expect(jordan.aniosMvpFinales,
          [1991, 1992, 1993, 1996, 1997, 1998]);
      expect(jordan.aniosMejorDefensor, [1988]);
      expect(jordan.aniosMaximoAnotador, hasLength(10));
      // Coherentes con los conteos ya probados en otro test.
      expect(jordan.aniosMvp.length, jordan.mvp);
      expect(jordan.aniosMvpFinales.length, jordan.mvpFinales);
    });

    test('Larry Bird: MVP tres años seguidos, 2 MVP de Finales', () async {
      final bird = await carreraRealDe('Larry Bird');
      expect(bird!.aniosMvp, [1984, 1985, 1986]);
      expect(bird.aniosMvpFinales, [1984, 1986]);
    });

    test('sin premios de un tipo, la lista está vacía', () async {
      final valanciunas = await carreraRealDe('Jonas Valančiūnas');
      expect(valanciunas!.aniosMvp, isEmpty);
      expect(valanciunas.aniosMaximoAnotador, isEmpty);
    });
  });
}
