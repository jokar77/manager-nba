import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/domain/grupos_torneo.dart' show grupoTorneoPorEquipo;
import 'package:manager_nba/domain/patrocinadores.dart';

/// El catálogo de patrocinadores: los 30 equipos reales tienen sus cuatro
/// categorías, ni una de más ni de menos, todas con datos de verdad.
void main() {
  final equiposReales = grupoTorneoPorEquipo.keys.toList();

  test('los 30 equipos reales tienen exactamente las cuatro categorías, ni '
      'repetidas ni de más', () {
    for (final equipo in equiposReales) {
      final propios = patrocinadoresDe(equipo);
      expect(propios.map((p) => p.categoria).toSet(),
          categoriasPatrocinio.toSet(),
          reason: '$equipo debería tener exactamente estas categorías: '
              '$categoriasPatrocinio');
      expect(propios, hasLength(categoriasPatrocinio.length),
          reason: '$equipo tiene categorías repetidas');
    }
  });

  test('ningún patrocinador se queda sin nombre, sin historia o con un año '
      'de fundación absurdo', () {
    for (final p in catalogoPatrocinadores) {
      expect(p.nombre.trim(), isNotEmpty, reason: '${p.equipo}/${p.categoria}');
      expect(p.historia.trim(), isNotEmpty, reason: '${p.equipo}/${p.categoria}');
      expect(p.fundacion, inInclusiveRange(1700, 2026),
          reason: '${p.equipo}/${p.categoria} funda en ${p.fundacion}');
    }
  });

  test('bonusSalarial de un patrocinador es el fijo de su categoría', () {
    for (final p in catalogoPatrocinadores) {
      expect(p.bonusSalarial, bonusPorCategoria[p.categoria]);
    }
  });

  test('patrocinadorDe encuentra exactamente el mismo objeto que '
      'patrocinadoresDe para esa categoría', () {
    for (final equipo in equiposReales) {
      for (final categoria in categoriasPatrocinio) {
        final directo = patrocinadorDe(equipo, categoria);
        final delListado = patrocinadoresDe(equipo)
            .where((p) => p.categoria == categoria)
            .single;
        expect(directo, isNotNull);
        expect(directo!.nombre, delListado.nombre);
      }
    }
  });

  test('un equipo que no existe no tiene patrocinadores', () {
    expect(patrocinadoresDe('ZZZ'), isEmpty);
    expect(patrocinadorDe('ZZZ', 'estadio'), isNull);
  });
}
