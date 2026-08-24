import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/grupos_torneo.dart' show grupoTorneoPorEquipo;
import 'package:manager_nba/domain/patrocinadores.dart';

/// El catálogo de patrocinadores: 386 marcas repartidas por ciudades, de
/// las que cada temporada salen hasta tres ofertas por categoría.
///
/// Lo que más se vigila aquí es que ninguna categoría se quede sin oferta
/// en ninguna temporada: la pantalla de pretemporada enseña las cuatro
/// siempre, y una vacía sería un hueco.
void main() {
  final equiposReales = grupoTorneoPorEquipo.keys.toList();

  test('los 30 equipos reales tienen oferta en las cuatro categorías, sea '
      'cual sea la temporada', () {
    for (final equipo in equiposReales) {
      // Veinte temporadas: más de lo que dura la cantera más corta (once
      // marcas), así que cada categoría da la vuelta entera al menos una
      // vez y se comprueban todas sus marcas.
      for (var temporada = 0; temporada < 20; temporada++) {
        final porCategoria = ofertasDeTemporada(equipo, temporada);
        expect(porCategoria.keys, categoriasPatrocinio,
            reason: '$equipo en la temporada $temporada');
        for (final categoria in categoriasPatrocinio) {
          expect(porCategoria[categoria], isNotEmpty,
              reason: '$equipo/$categoria en la temporada $temporada');
        }
      }
    }
  });

  test('nunca salen más de tres ofertas, ni más de las marcas que hay', () {
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        final cantera = patrocinadoresDe(equipo)
            .where((p) => p.categoria == categoria)
            .length;
        for (var temporada = 0; temporada < 12; temporada++) {
          final ofertas =
              ofertasDe(equipo, categoria, temporada: temporada);
          expect(ofertas.length, lessThanOrEqualTo(ofertasPorCategoria));
          expect(ofertas.length, lessThanOrEqualTo(cantera));
          // Tres siempre que la ciudad dé para tres.
          if (cantera >= ofertasPorCategoria) {
            expect(ofertas, hasLength(ofertasPorCategoria),
                reason: '$equipo/$categoria');
          }
        }
      }
    }
  });

  test('las ofertas de una categoría son de marcas distintas', () {
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        for (var temporada = 0; temporada < 12; temporada++) {
          final claves = ofertasDe(equipo, categoria, temporada: temporada)
              .map((o) => o.patrocinador.clave)
              .toList();
          expect(claves.toSet(), hasLength(claves.length),
              reason: '$equipo/$categoria repite marca en $temporada');
        }
      }
    }
  });

  test('cada oferta dura lo que dice su puesto, y son duraciones distintas',
      () {
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        final ofertas = ofertasDe(equipo, categoria, temporada: 3);
        for (var i = 0; i < ofertas.length; i++) {
          expect(ofertas[i].anios, aniosDeOferta[i],
              reason: '$equipo/$categoria, oferta $i');
        }
        expect(ofertas.map((o) => o.anios).toSet(), hasLength(ofertas.length));
      }
    }
  });

  test('el contrato más largo paga MENOS al año que el más corto', () {
    // Es lo único que hace que la decisión exista: si el largo pagara más,
    // se firmaría siempre el largo. Ver `_factorPorDuracion`.
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        for (var temporada = 0; temporada < 12; temporada++) {
          final ofertas = ofertasDe(equipo, categoria, temporada: temporada);
          if (ofertas.length < 2) continue;
          expect(ofertas.first.bonusAnual,
              greaterThan(ofertas.last.bonusAnual),
              reason: '$equipo/$categoria en la temporada $temporada');
        }
      }
    }
  });

  test('el dinero de una oferta es una cifra redonda y del orden de su '
      'categoría', () {
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        final base = bonusPorCategoria[categoria]!;
        for (var temporada = 0; temporada < 12; temporada++) {
          for (final oferta
              in ofertasDe(equipo, categoria, temporada: temporada)) {
            expect(oferta.bonusAnual % 50000, 0,
                reason: '${oferta.patrocinador.clave} da '
                    '${oferta.bonusAnual}, que no es redondo');
            // Nunca menos de la mitad ni más del doble del base: un
            // patrocinio no puede convertirse en el sistema entero.
            expect(oferta.bonusAnual,
                inInclusiveRange((base * 0.5).round(), base * 2));
            expect(oferta.bonusTotal, oferta.bonusAnual * oferta.anios);
          }
        }
      }
    }
  });

  test('el dinero cambia de una temporada a otra', () {
    // Sin esto, esperar un año no costaría nada y firmar largo nunca
    // compensaría. Ver el comentario de `_dinero`.
    var distintos = 0;
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        final ahora = ofertasDe(equipo, categoria, temporada: 4).first;
        final luego = ofertasDe(equipo, categoria, temporada: 5).first;
        if (ahora.bonusAnual != luego.bonusAnual) distintos++;
      }
    }
    expect(distintos, greaterThan(60),
        reason: 'el dinero apenas se mueve entre temporadas');
  });

  test('cada equipo tiene su propia cantera, de once marcas para arriba', () {
    for (final equipo in equiposReales) {
      final cantera = patrocinadoresDe(equipo);
      expect(cantera.length, greaterThanOrEqualTo(11), reason: equipo);
      for (final categoria in categoriasPatrocinio) {
        expect(cantera.where((p) => p.categoria == categoria), isNotEmpty,
            reason: '$equipo no tiene ninguna marca de $categoria');
      }
    }
  });

  test('ningún patrocinador se queda sin nombre, sin historia o con un año '
      'de fundación absurdo', () {
    for (final p in catalogoPatrocinadores) {
      expect(p.nombre.trim(), isNotEmpty, reason: p.clave);
      expect(p.historia.trim(), isNotEmpty, reason: p.clave);
      expect(p.fundacion, inInclusiveRange(1600, 2026),
          reason: '${p.clave} funda en ${p.fundacion}');
      expect(categoriasPatrocinio, contains(p.categoria), reason: p.clave);
    }
  });

  test('las claves son únicas y apuntan a un logo con su mismo nombre', () {
    final claves = catalogoPatrocinadores.map((p) => p.clave).toList();
    expect(claves.toSet(), hasLength(claves.length),
        reason: 'hay claves repetidas');
    for (final p in catalogoPatrocinadores) {
      expect(p.clave, matches(RegExp(r'^[A-Z]{2,3}_\d\d$')));
      expect(p.logo, 'assets/logos/${p.clave}.jpg');
      // La clave empieza por el código de su hoja: si no, el logo sería el
      // de otra ciudad.
      expect(p.clave, startsWith('${p.equipo}_'));
    }
  });

  test('patrocinadorPorClave encuentra a cualquiera del catálogo', () {
    for (final p in catalogoPatrocinadores) {
      expect(patrocinadorPorClave(p.clave)?.nombre, p.nombre);
    }
    expect(patrocinadorPorClave('ZZZ_99'), isNull);
  });

  test('bonusSalarial de un patrocinador es el fijo de su categoría', () {
    for (final p in catalogoPatrocinadores) {
      expect(p.bonusSalarial, bonusPorCategoria[p.categoria]);
    }
  });

  test('el mismo equipo y la misma temporada dan siempre las mismas ofertas',
      () {
    // Es lo que permite no guardar ninguna semilla en la partida: cargar
    // una franquicia vieja tiene que devolver las ofertas que tenía.
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        final primero = ofertasDe(equipo, categoria, temporada: 7);
        final segundo = ofertasDe(equipo, categoria, temporada: 7);
        expect(primero.map((o) => o.patrocinador.clave),
            segundo.map((o) => o.patrocinador.clave));
        expect(primero.map((o) => o.bonusAnual),
            segundo.map((o) => o.bonusAnual));
      }
    }
  });

  test('las marcas cambian de una temporada a la siguiente', () {
    // La gracia de tener cantera: la pretemporada del año que viene no es
    // la misma pantalla. Solo se exige donde hay con qué — tres ciudades
    // tienen una única marca en alguna categoría.
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        final cantera = patrocinadoresDe(equipo)
            .where((p) => p.categoria == categoria)
            .length;
        if (cantera < 2) continue;
        for (var temporada = 0; temporada < 10; temporada++) {
          expect(
              ofertasDe(equipo, categoria, temporada: temporada)
                  .first
                  .patrocinador
                  .clave,
              isNot(ofertasDe(equipo, categoria, temporada: temporada + 1)
                  .first
                  .patrocinador
                  .clave),
              reason: '$equipo/$categoria repite entre $temporada y '
                  '${temporada + 1}');
        }
      }
    }
  });

  test('con más de tres candidatas, el año que viene solapa lo mínimo que '
      'permite el tamaño de la cantera (Lista 15 punto 9)', () {
    // Antes el hueco de tres se desplazaba de una en una: con "hasta
    // tres", dos de las tres ofertas de este año SIEMPRE volvían a salir
    // el año que viene, tuviera la cantera el tamaño que tuviera. Ahora
    // se desplaza de tres en tres, y el solape baja al mínimo que
    // permite cada tamaño de cantera (principio del palomar: dos
    // combinaciones de 3 sobre N no pueden solaparse en menos de
    // `max(0, 6 - N)`).
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        final cantera = patrocinadoresDe(equipo)
            .where((p) => p.categoria == categoria)
            .length;
        if (cantera <= ofertasPorCategoria) continue;
        final minimoPosible = (2 * ofertasPorCategoria - cantera)
            .clamp(0, ofertasPorCategoria);
        for (var temporada = 0; temporada < 8; temporada++) {
          final ahora = ofertasDe(equipo, categoria, temporada: temporada)
              .map((o) => o.patrocinador.clave)
              .toSet();
          final luego = ofertasDe(equipo, categoria, temporada: temporada + 1)
              .map((o) => o.patrocinador.clave)
              .toSet();
          expect(ahora.intersection(luego).length, minimoPosible,
              reason: '$equipo/$categoria (cantera de $cantera) entre '
                  '$temporada y ${temporada + 1}');
        }
      }
    }
  });

  test('los dos de Los Ángeles comparten cantera pero no las mismas ofertas',
      () {
    expect(patrocinadoresDe('LAC').map((p) => p.clave),
        patrocinadoresDe('LAL').map((p) => p.clave));

    // Comparten las marcas de la ciudad, pero la semilla lleva el código
    // del equipo: el mismo año cada uno recibe ofertas distintas.
    var distintos = 0;
    for (var temporada = 0; temporada < 10; temporada++) {
      for (final categoria in categoriasPatrocinio) {
        final clippers = ofertasDe('LAC', categoria, temporada: temporada)
            .first
            .patrocinador
            .clave;
        final lakers = ofertasDe('LAL', categoria, temporada: temporada)
            .first
            .patrocinador
            .clave;
        if (clippers != lakers) distintos++;
      }
    }
    expect(distintos, greaterThan(30),
        reason: 'van demasiado sincronizados para compartir ciudad');
  });

  test('un equipo que no existe no tiene patrocinadores ni ofertas', () {
    expect(patrocinadoresDe('ZZZ'), isEmpty);
    expect(ofertasDe('ZZZ', 'estadio', temporada: 1), isEmpty);
  });
}
