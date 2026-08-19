import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';

TemporadaData _temporada({required int numero, required int anioInicio}) =>
    TemporadaData(
      id: 0,
      numero: numero,
      anioInicio: anioInicio,
      ofertasGeneradasEstaTemporada: 0,
      eventosVistos: '',
    );

/// etiquetaTemporadaDesde traduce un número de temporada de la partida
/// ("temporada 3") al mismo formato de año que usa el resto del juego
/// ("25-26"). Es lo que hace legible cualquier premio o trofeo histórico,
/// que solo tiene guardado el número.
void main() {
  test('la temporada actual se traduce con su propio año de inicio', () {
    final actual = _temporada(numero: 5, anioInicio: 2030);
    expect(etiquetaTemporadaDesde(actual, 5), '2030-31');
  });

  test('una temporada anterior se traduce restando la distancia en años',
      () {
    final actual = _temporada(numero: 5, anioInicio: 2030);
    // Cada temporada avanza el año en 1 al mismo ritmo que su número.
    expect(etiquetaTemporadaDesde(actual, 1), '2026-27');
    expect(etiquetaTemporadaDesde(actual, 3), '2028-29');
    expect(etiquetaTemporadaDesde(actual, 4), '2029-30');
  });
}
