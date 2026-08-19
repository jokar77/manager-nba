import 'dart:math';

/// Escala salarial de la liga, en dólares. Los números están calibrados
/// contra los contratos reales de la 2026-27 (Basketball-Reference): el
/// máximo de la liga ronda los 62M, una estrella 45-55M, un titular bueno
/// 20-30M, rotación 8-15M y el mínimo del convenio ~2,3M.
const salarioMinimo = 2300000;

/// Techo de la escala. Por encima del máximo real de la liga (Curry cobra
/// 62,58M la 2026-27) para que un contrato real nunca quede por fuera.
const salarioMaximo = 70000000;

/// Tope salarial por equipo y temporada, jugadores Y banquillo juntos. Al
/// pasarse, solo se puede fichar por el mínimo.
///
/// Son los 220M del tope real de la NBA más 20M de margen para el
/// entrenador, y ese margen no es un regalo: el sueldo del banquillo entra
/// en la masa salarial (ver [masaSalarial]), así que gastarte 18M en un
/// entrenador de primera te deja 18M menos para jugadores. Compite de
/// verdad.
///
/// Por qué el margen y no meter al entrenador en los 220M pelados: medido
/// sobre el dataset, SEIS equipos empiezan la partida por encima de 220M
/// (PHI a -26M, DEN a -22M, GSW a -16M, más ORL, MIN y NYK) y trece más
/// tienen menos de 18M de aire. Con el tope pelado, esos seis no podrían
/// firmar entrenador en absoluto —por encima del tope solo se ficha por el
/// mínimo— y los mejores equipos de la liga acabarían con los peores
/// banquillos, que es justo al revés de lo que pasa en la realidad.
///
/// Si alguna vez se quiere endurecer, se baja este número: cuanto más cerca
/// de 220M, más duele fichar entrenador.
const topeSalarial = 240000000;

/// La parte del tope pensada para el banquillo. No es un presupuesto
/// separado —el tope es uno solo— pero sirve para explicar de dónde sale el
/// margen y para acotar lo que se le puede ofrecer a un entrenador.
const margenDeBanquillo = 20000000;

/// Estima el salario de un jugador del que no tenemos contrato real, a
/// partir de su nivel. La curva es deliberadamente convexa: entre un
/// jugador de 70 y uno de 80 hay poca diferencia de sueldo, pero entre uno
/// de 85 y uno de 95 hay 30 millones — como en la NBA de verdad, donde el
/// dinero se concentra arriba del todo.
///
/// [edad] modula un poco: un chaval de 21 con la misma media que un
/// veterano cobra menos (sigue en contrato de rookie).
int salarioEstimado({required int media, required int edad}) {
  final porEncimaDelSuelo = max(0, media - 62);
  final bruto = salarioMinimo + pow(porEncimaDelSuelo, 2.4) * 12456;

  final factorEdad = edad <= 22
      ? 0.45
      : edad <= 24
          ? 0.7
          : 1.0;

  return (bruto * factorEdad).round().clamp(salarioMinimo, salarioMaximo);
}

/// El sueldo de un rookie de primera ronda, POR PUESTO DEL DRAFT, como en
/// la escala real de la NBA — no por la media que trae el día 1.
///
/// [posicionRelativa] es 0,0 para el número 1 y 1,0 para el último de la
/// ronda. Sin esta función, `salarioEstimado` se aplicaba con la media de
/// draft (típicamente 72-76 incluso para el número 1, porque un prospecto
/// de 19 años nunca trae una media alta), y con el descuento por edad
/// (factor 0,45 bajo 22 años) el número 1 del draft acababa cobrando una
/// MEDIANA de 3,2M — el sueldo real del número 1 de verdad ronda los
/// 12,5M. Medido sobre 300 clases: con la fórmula vieja, un equipo con
/// varios rookies de primera ronda que despegan se quedaba con decenas de
/// millones de tope sin gastar solo porque a sus futuras estrellas se les
/// pagaba como a jugadores de banquillo.
///
/// La curva: 12,5M en el número 1, bajando hasta el mínimo hacia el final
/// de la ronda — la misma forma cóncava que la escala real.
int salarioDeRookiePrimeraRonda(double posicionRelativa) {
  const techo = 12500000;
  final bruto = salarioMinimo +
      (techo - salarioMinimo) * pow(1 - posicionRelativa, 1.7);
  return (bruto.round() ~/ 100000) * 100000;
}

/// Años de contrato estimados cuando no se conocen: los jóvenes con
/// proyección firman largo, los veteranos año a año.
int aniosContratoEstimados({required int edad}) {
  if (edad <= 23) return 4;
  if (edad <= 27) return 3;
  if (edad <= 31) return 2;
  return 1;
}

/// Formatea un salario para la UI: "58,5M" o "2,3M".
String formatearSalario(int dolares) {
  final millones = dolares / 1000000;
  return '${millones.toStringAsFixed(1).replaceAll('.', ',')}M';
}
