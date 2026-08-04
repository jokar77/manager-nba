import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/database/app_database.dart';

/// El dataset trae al menos un valor de posicion con un caracter de espacio
/// no separable (U+00A0, NBSP) alrededor de la barra, ej: "SG NBSP/NBSP PG".
/// Esta funcion lo limpia y se queda con la posicion principal.
String normalizarPosicion(String posicionCruda) {
  final codigoEspacioNoSeparable = String.fromCharCode(0x00A0);
  final limpia =
      posicionCruda.replaceAll(codigoEspacioNoSeparable, ' ').trim();
  return limpia.split('/').first.trim();
}

extension JugadorRowMapping on Jugador {
  /// Convierte la fila de base de datos al modelo que entiende sim_engine.
  sim.Jugador toSimJugador() {
    return sim.Jugador(
      id: id.toString(),
      nombreFicticio: nombreFicticio,
      posicion: posicion,
      equipo: equipo,
      edad: edad,
      atrAtaque: atrAtaque,
      atrDefensa: atrDefensa,
      atrTiro3: atrTiro3,
      media: media,
      potencial: potencial,
      ptsPg: ptsPg,
      astPg: astPg,
      trbPg: trbPg,
      factorLongevidad: factorLongevidad,
    );
  }
}
