import 'dart:math';

/// Escala salarial de la liga, en dólares. Los números están calibrados
/// contra los contratos reales de la 2026-27 (Basketball-Reference): el
/// máximo de la liga ronda los 62M, una estrella 45-55M, un titular bueno
/// 20-30M, rotación 8-15M y el mínimo del convenio ~2,3M.
const salarioMinimo = 2300000;

/// Techo de la escala. Por encima del máximo real de la liga (Curry cobra
/// 62,58M la 2026-27) para que un contrato real nunca quede por fuera.
const salarioMaximo = 70000000;

/// Tope salarial por equipo y temporada. Al pasarse, solo se puede fichar
/// por el mínimo.
const topeSalarial = 220000000;

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
