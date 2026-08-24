import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/i18n/textos.dart';

/// Lista 15 punto 11: a un jugador con 1 año de contrato le tiene que
/// decir "1 año", no "último año" — antes `_aniosDeContrato` en
/// `traspasos_screen.dart` y `contratoEnUnaLinea` en `hoja_de_propuestas.dart`
/// sustituían el número por un texto especial ("Último año"/"último año")
/// en cuanto quedaba 1 año o menos, algo que ni el usuario pidió ni decía
/// cuántos años quedaban.
void main() {
  test('un año exacto usa el singular, no un texto especial de "último año"',
      () {
    expect(const TextosEs().aniosDeContrato(1), '1 año');
    expect(const TextosEn().aniosDeContrato(1), '1 year');
  });

  test('más de un año sigue en plural', () {
    expect(const TextosEs().aniosDeContrato(3), '3 años');
    expect(const TextosEn().aniosDeContrato(3), '3 years');
  });
}
