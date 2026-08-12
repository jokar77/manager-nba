import 'package:sim_engine/sim_engine.dart' as sim;

import '../../data/database/app_database.dart';
import '../../domain/jugador_mapping.dart';
import '../../domain/posiciones.dart';

/// Curva de minutos de la rotación de un equipo de la CPU: 5 titulares + 5
/// suplentes, exactamente los mismos 10 huecos que tiene tu rotación, y 240
/// minutos en total.
const _minutosTitulares = [34, 33, 32, 31, 30];
const _minutosSuplentes = [16, 16, 16, 16, 16];

/// Genera la alineación de un equipo controlado por la CPU: cubre los 5
/// puestos (titular + suplente) con los mejores jugadores disponibles para
/// cada uno — primero los que lo tienen como posición natural, luego los que
/// lo llevan de segunda, y en último caso el mejor que quede aunque juegue
/// fuera de sitio, con la misma penalización que se te aplica a ti. Los
/// lesionados de [lesionadosIds] quedan fuera, y [formas] son los
/// multiplicadores de estado de forma de la temporada (ver
/// forma_repository.dart).
///
/// Se usa tanto para los rivales de tus partidos como para simular la
/// temporada de los otros 29 equipos de la liga. Que la CPU se alinee por
/// puestos igual que tú es lo que hace la comparación justa: antes cogía
/// simplemente a sus 12 mejores por media, sin penalización posicional
/// ninguna, así que tú siempre partías en desventaja.
sim.EquipoPartido generarAlineacionAutomatica(
  String nombreEquipo,
  List<Jugador> plantilla, {
  Set<int> lesionadosIds = const {},
  Map<int, double> formas = const {},
  sim.EntrenadorEnPartido? entrenador,
}) {
  var disponibles =
      plantilla.where((j) => !lesionadosIds.contains(j.id)).toList();
  // Salvaguarda extrema: si de verdad no quedan ni 10 jugadores sanos para
  // cubrir la rotación, un equipo no puede quedarse sin jugar por lesiones
  // — se ignoran las lesiones como último recurso.
  if (disponibles.length < posicionesEquipo.length * 2) {
    disponibles = plantilla;
  }
  final ordenada = [...disponibles]
    ..sort((a, b) => b.media.compareTo(a.media));

  // Las dos estrellas son los dos mejores del equipo, jueguen donde jueguen.
  final estrellaAtaqueId = ordenada.isNotEmpty ? ordenada.first.id : null;
  final estrellaDefensaId = ordenada.length > 1 ? ordenada[1].id : null;

  // El reparto valora la pareja (jugador, puesto) entera —media por factor
  // de comodidad, ver repartirPorPuestos—, así que la CPU ni sienta talento
  // ni pone a su pívot de base.
  final porPuesto = repartirPorPuestos(disponibles);

  final jugadoresEnPartido = <sim.JugadorEnPartido>[];
  void anotar(Jugador jugador, String puesto, int minutos) {
    jugadoresEnPartido.add(sim.JugadorEnPartido(
      jugador: jugador.toSimJugador(),
      minutos: minutos,
      esEstrellaAtaque: jugador.id == estrellaAtaqueId,
      esEstrellaDefensa: jugador.id == estrellaDefensaId,
      penalizacionFueraDePosicion: factorDePuesto(jugador, puesto),
      factorForma: formas[jugador.id] ?? 1.0,
    ));
  }

  for (var i = 0; i < posicionesEquipo.length; i++) {
    anotar(porPuesto[posicionesEquipo[i]]![0], posicionesEquipo[i],
        _minutosTitulares[i]);
  }
  for (var i = 0; i < posicionesEquipo.length; i++) {
    anotar(porPuesto[posicionesEquipo[i]]![1], posicionesEquipo[i],
        _minutosSuplentes[i]);
  }

  return sim.EquipoPartido(
    nombre: nombreEquipo,
    jugadores: jugadoresEnPartido,
    entrenador: entrenador,
  );
}
