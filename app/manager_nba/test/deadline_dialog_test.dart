import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/tipo_evento_temporada.dart';
import 'package:manager_nba/features/calendario/simulacion_ui.dart';

EventosTemporadaData _evento(TipoEventoTemporada tipo) {
  return EventosTemporadaData(
    id: 1,
    fecha: DateTime(2027, 1, 1),
    tipo: tipo.name,
  );
}

void main() {
  // Antes de este arreglo, cuando en `simularHastaConDialogo` elegías "no
  // seguir simulando" en la fecha límite, siempre te llevaba a Traspasos
  // — incluso si la fecha límite que se había cruzado era la de "fin de
  // la agencia libre". `esFechaLimiteDeAgenciaLibre` es la comprobación de
  // la que depende tanto el título del diálogo como a qué pantalla se
  // navega; se prueba aislada porque montar el flujo completo (simular
  // temporada real -> diálogo -> tap) es lento y fràgil en un test de
  // widgets.
  test('esFechaLimiteDeAgenciaLibre distingue el evento de fin de agencia '
      'libre del de fecha límite de traspasos', () {
    expect(esFechaLimiteDeAgenciaLibre(_evento(TipoEventoTemporada.finAgenciaLibre)),
        isTrue);
    expect(
        esFechaLimiteDeAgenciaLibre(
            _evento(TipoEventoTemporada.fechaLimiteTraspasos)),
        isFalse);
    expect(esFechaLimiteDeAgenciaLibre(_evento(TipoEventoTemporada.allStar)),
        isFalse);
  });
}
