import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/tipo_evento_temporada.dart';
import 'package:manager_nba/features/calendario/simulacion_ui.dart';

/// El bug (lista parte 11, punto 10): el All-Star dejó de avisar.
///
/// La causa era sutil. El aviso comprobaba si la fecha del All-Star caía
/// entre el PRIMER y el ÚLTIMO PARTIDO JUGADO de cada etapa de simulación
/// — y el All-Star es justamente el fin de semana en el que no se juega.
/// Desde que la simulación avanza por etapas de siete días (para poder
/// pararse en las ofertas), el parón entero cae en el hueco entre los
/// partidos de una etapa y los de la siguiente, así que no quedaba dentro
/// del rango de ninguna de las dos.
///
/// El caso de abajo es exactamente ese: partidos hasta el 14, All-Star el
/// 16, partidos desde el 20. Con la lógica vieja no lo pillaba ni la etapa
/// que termina el 17 ni la que empieza el 20.
void main() {
  EventosTemporadaData evento(DateTime fecha) => EventosTemporadaData(
        id: 1,
        tipo: TipoEventoTemporada.allStar.name,
        fecha: fecha,
      );

  final allStar = [evento(DateTime(2027, 2, 16))];

  test('la etapa que cruza el parón lo detecta, aunque no se juegue ni un '
      'partido esos días', () {
    // Meta de la etapa: el 17. Los partidos de esa etapa terminaron el 14,
    // así que mirando partidos no se veía nada.
    expect(allStarYaAlcanzado(allStar, DateTime(2027, 2, 17)), isTrue);
  });

  test('el mismo día del All-Star ya cuenta', () {
    expect(allStarYaAlcanzado(allStar, DateTime(2027, 2, 16)), isTrue);
  });

  test('antes de su fecha no se avisa', () {
    expect(allStarYaAlcanzado(allStar, DateTime(2027, 2, 14)), isFalse);
    expect(allStarYaAlcanzado(allStar, DateTime(2027, 1, 1)), isFalse);
  });

  test('una etapa muy posterior también lo detecta: quien simula la '
      'temporada entera de una vez no se queda sin aviso', () {
    expect(allStarYaAlcanzado(allStar, DateTime(2027, 4, 30)), isTrue);
  });

  test('sin evento de All-Star no se avisa de nada', () {
    expect(allStarYaAlcanzado(const [], DateTime(2027, 4, 30)), isFalse);
  });
}
