import 'dart:math';

import '../models/boxscore.dart';
import '../models/equipo_partido.dart';
import '../models/jugador_en_partido.dart';
import '../reglas/pesos_atributos.dart';

/// Simula un partido completo entre dos equipos.
///
/// Es una función pura salvo por la fuente de aleatoriedad: dado el mismo
/// [seed], el resultado es reproducible. Sin [seed], usa aleatoriedad real.
///
/// Algoritmo (resumen):
/// 1. Cada equipo obtiene un rating ofensivo/defensivo (0-99) como media de
///    los índices de sus jugadores activos, ponderada por minutos jugados,
///    factor_longevidad y un bonus si el jugador es la estrella designada.
///    Al resultado se le suma lo que aporte el entrenador, si lo hay (ver
///    [aporteDelEntrenador]).
/// 2. El marcador de cada equipo sale de comparar su rating ofensivo con el
///    rating defensivo rival contra una referencia de liga, más ruido
///    gaussiano acotado.
/// 3. Los puntos del equipo se reparten entre sus jugadores según una
///    combinación de sus pts_pg reales (escalados por minutos) y su índice
///    ofensivo, y se reconcilian para que la suma cuadre exactamente con el
///    marcador del equipo. Asistencias y rebotes se derivan igual a partir
///    de ast_pg/trb_pg, sin necesidad de cuadrar un total de equipo.
/// 4. `JugadorEnPartido.penalizacionFueraDePosicion` multiplica tanto su
///    aportación al rating de equipo como su reparto individual de
///    estadísticas: un jugador fuera de posición rinde peor y, al no
///    aportar tanto a su equipo, el rival saca ventaja de forma natural.
/// 5. Nunca hay empates: si el marcador de los 4 cuartos queda igualado,
///    se juegan prórrogas de 5 minutos (una tras otra si hiciera falta)
///    hasta que alguien gane.
Boxscore simularPartido({
  required EquipoPartido local,
  required EquipoPartido visitante,
  int? seed,
}) {
  final random = seed != null ? Random(seed) : Random();

  final ratingOfensivoLocal = _ratingOfensivoEquipo(local);
  final ratingDefensivoLocal = _ratingDefensivoEquipo(local);
  final ratingOfensivoVisitante = _ratingOfensivoEquipo(visitante);
  final ratingDefensivoVisitante = _ratingDefensivoEquipo(visitante);

  // Un único sorteo para los dos equipos: es lo que hace que un partido se
  // sienta de anotación baja, media o alta de verdad (ver PesosAtributos.
  // sigmaRitmo), en vez de que cada equipo ande por su cuenta.
  final factorRitmo = (1 + _ruidoGaussiano(random) * PesosAtributos.sigmaRitmo)
      .clamp(PesosAtributos.factorRitmoMinimo, PesosAtributos.factorRitmoMaximo);

  final marcadorRegulacionLocal = _marcadorEquipo(
    ratingOfensivoPropio: ratingOfensivoLocal,
    ratingDefensivoRival: ratingDefensivoVisitante,
    factorRitmo: factorRitmo,
    random: random,
  );
  final marcadorRegulacionVisitante = _marcadorEquipo(
    ratingOfensivoPropio: ratingOfensivoVisitante,
    ratingDefensivoRival: ratingDefensivoLocal,
    factorRitmo: factorRitmo,
    random: random,
  );

  var marcadorLocal = marcadorRegulacionLocal;
  var marcadorVisitante = marcadorRegulacionVisitante;
  final prorrogasLocal = <int>[];
  final prorrogasVisitante = <int>[];

  // Un partido nunca puede acabar en empate: si los 4 cuartos quedan
  // igualados se juega una prórroga de 5 minutos (y se repite si hiciera
  // falta) hasta que alguien gane. La salvaguarda del límite de intentos
  // es solo para no bloquear el hilo ante una racha de aleatoriedad
  // extrema — con las constantes actuales, no debería alcanzarse nunca.
  while (marcadorLocal == marcadorVisitante) {
    final prorrogaLocal = _marcadorProrroga(
      ratingOfensivoPropio: ratingOfensivoLocal,
      ratingDefensivoRival: ratingDefensivoVisitante,
      random: random,
    );
    final prorrogaVisitante = _marcadorProrroga(
      ratingOfensivoPropio: ratingOfensivoVisitante,
      ratingDefensivoRival: ratingDefensivoLocal,
      random: random,
    );
    prorrogasLocal.add(prorrogaLocal);
    prorrogasVisitante.add(prorrogaVisitante);
    marcadorLocal += prorrogaLocal;
    marcadorVisitante += prorrogaVisitante;

    if (prorrogasLocal.length > 20) {
      if (marcadorLocal == marcadorVisitante) marcadorLocal += 1;
      break;
    }
  }

  return Boxscore(
    equipoLocal: local.nombre,
    equipoVisitante: visitante.nombre,
    marcadorLocal: marcadorLocal,
    marcadorVisitante: marcadorVisitante,
    statsLocal: _statsEquipo(local, marcadorLocal, random),
    statsVisitante: _statsEquipo(visitante, marcadorVisitante, random),
    parcialesLocal: [
      ..._dividirEnCuartos(marcadorRegulacionLocal, random),
      ...prorrogasLocal,
    ],
    parcialesVisitante: [
      ..._dividirEnCuartos(marcadorRegulacionVisitante, random),
      ...prorrogasVisitante,
    ],
  );
}

/// Marcador de un equipo en una prórroga de 5 minutos: mismo criterio que
/// [_marcadorEquipo] (rating propio vs. rating defensivo rival + ruido
/// gaussiano) pero con las constantes de prórroga, que dan un marcador más
/// bajo y con más dispersión relativa para que un segundo empate seguido
/// sea raro.
int _marcadorProrroga({
  required double ratingOfensivoPropio,
  required double ratingDefensivoRival,
  required Random random,
}) {
  final factorAtaque = _factorComprimido(
      ratingOfensivoPropio / PesosAtributos.ratingLigaMedio);
  final factorDefensaRival = _factorComprimido(
      PesosAtributos.ratingLigaMedio / ratingDefensivoRival);

  final esperado =
      PesosAtributos.puntosProrrogaMedios * factorAtaque * factorDefensaRival;
  final ruido = _ruidoGaussiano(random) * PesosAtributos.sigmaRuidoProrroga;

  final marcador = (esperado + ruido).round();
  return marcador.clamp(
      PesosAtributos.marcadorProrrogaMinimo, PesosAtributos.marcadorProrrogaMaximo);
}

/// Reparte [total] en 4 cuartos con algo de variación (ninguno negativo),
/// sumando exactamente [total].
List<int> _dividirEnCuartos(int total, Random random) {
  final pesos = List.generate(4, (_) => 0.8 + random.nextDouble() * 0.4);
  final sumaPesos = pesos.reduce((a, b) => a + b);
  final cuartos = pesos.map((p) => (p / sumaPesos * total).round()).toList();

  var diferencia = total - cuartos.reduce((a, b) => a + b);
  var indice = 0;
  while (diferencia != 0) {
    final delta = diferencia > 0 ? 1 : -1;
    if (cuartos[indice % 4] + delta >= 0) {
      cuartos[indice % 4] += delta;
      diferencia -= delta;
    }
    indice++;
    if (indice > 1000) break; // salvaguarda, no debería ocurrir
  }
  return cuartos;
}

// Nota: el peso (minutos/longevidad/rol) NO lleva la penalización fuera de
// posición. Si la llevara, al ser el rating una media ponderada
// (sumaPonderada / sumaPesos), penalizar el peso de un jugador con índice
// igual a la media del equipo no cambiaría nada esa media (numerador y
// denominador se reducen en la misma proporción). La penalización tiene
// que aplicarse directamente al índice para que arrastre la media del
// equipo hacia abajo cuando ese jugador tiene muchos minutos.
double _pesoJugador(JugadorEnPartido jep, {required bool esRolAtaque}) {
  final fraccionMinutos = jep.minutos / 48;
  final esEstrellaQueAplica =
      esRolAtaque ? jep.esEstrellaAtaque : jep.esEstrellaDefensa;
  final multiplicadorRol =
      esEstrellaQueAplica ? PesosAtributos.multiplicadorEstrella : 1.0;
  return fraccionMinutos * jep.jugador.factorLongevidad * multiplicadorRol;
}

/// Lo que el entrenador suma o resta al rating del equipo, en puntos de
/// rating. Un entrenador del montón aporta 0; el mejor de la liga, algo
/// menos de [PesosAtributos.maxAporteEntrenador]; el peor, otro tanto en
/// negativo. Sin entrenador (equipos del All-Star, tests antiguos) el
/// aporte es exactamente 0, así que el motor se comporta como siempre.
///
/// Va SUMADO al rating y no multiplicado a propósito: un buen entrenador
/// saca lo mismo de un equipo bueno que de uno malo. Multiplicar habría
/// hecho que los entrenadores solo importasen en los equipos ya fuertes,
/// que es lo contrario de para qué los ficha un equipo en reconstrucción.
double aporteDelEntrenador(int? atributo) {
  if (atributo == null) return 0;
  final desvio =
      (atributo - PesosAtributos.atributoEntrenadorMedio) /
          PesosAtributos.recorridoEntrenador;
  return desvio.clamp(-PesosAtributos.desvioMaximoEntrenador,
          PesosAtributos.desvioMaximoEntrenador) *
      PesosAtributos.maxAporteEntrenador;
}

double _ratingOfensivoEquipo(EquipoPartido equipo) {
  final activos = equipo.jugadoresActivos;
  double sumaPonderada = 0;
  double sumaPesos = 0;
  for (final jep in activos) {
    final peso = _pesoJugador(jep, esRolAtaque: true);
    sumaPonderada += jep.jugador.indiceOfensivo * jep.rendimiento * peso;
    sumaPesos += peso;
  }
  if (sumaPesos == 0) return PesosAtributos.ratingLigaMedio;
  return sumaPonderada / sumaPesos +
      aporteDelEntrenador(equipo.entrenador?.ataque);
}

double _ratingDefensivoEquipo(EquipoPartido equipo) {
  final activos = equipo.jugadoresActivos;
  double sumaPonderada = 0;
  double sumaPesos = 0;
  for (final jep in activos) {
    final peso = _pesoJugador(jep, esRolAtaque: false);
    sumaPonderada += jep.jugador.indiceDefensivo * jep.rendimiento * peso;
    sumaPesos += peso;
  }
  if (sumaPesos == 0) return PesosAtributos.ratingLigaMedio;
  return sumaPonderada / sumaPesos +
      aporteDelEntrenador(equipo.entrenador?.defensa);
}

int _marcadorEquipo({
  required double ratingOfensivoPropio,
  required double ratingDefensivoRival,
  required double factorRitmo,
  required Random random,
}) {
  final factorAtaque = _factorComprimido(
      ratingOfensivoPropio / PesosAtributos.ratingLigaMedio);
  final factorDefensaRival = _factorComprimido(
      PesosAtributos.ratingLigaMedio / ratingDefensivoRival);

  final esperado = PesosAtributos.puntosLigaMedios *
      factorAtaque *
      factorDefensaRival *
      factorRitmo;
  final ruido = _ruidoGaussiano(random) * PesosAtributos.sigmaRuidoMarcador;

  final marcador = (esperado + ruido).round();
  return marcador.clamp(
      PesosAtributos.marcadorMinimo, PesosAtributos.marcadorMaximo);
}

/// Acerca [crudo] a 1 según [PesosAtributos.sensibilidadAlRating]: es lo que
/// convierte la ventaja de rating de un equipo en una ventaja de marcador
/// del tamaño que se ve en la NBA de verdad.
///
/// Sin esto, un equipo 5 puntos de rating por encima de la media anotaba 7
/// más y encajaba 7 menos, o sea +14 de diferencia por partido cuando el
/// mejor equipo real ronda los +9. El resultado eran temporadas de 76-6.
double _factorComprimido(double crudo) =>
    (1 + (crudo - 1) * PesosAtributos.sensibilidadAlRating).clamp(0.6, 1.6);

/// Ruido gaussiano estándar (media 0, desviación 1) vía Box-Muller.
double _ruidoGaussiano(Random random) {
  final u1 = 1 - random.nextDouble();
  final u2 = random.nextDouble();
  return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
}

List<EstadisticasJugador> _statsEquipo(
  EquipoPartido equipo,
  int marcadorEquipo,
  Random random,
) {
  final activos = equipo.jugadoresActivos;
  if (activos.isEmpty) return [];

  final pesosPuntos = <JugadorEnPartido, double>{};
  for (final jep in activos) {
    final j = jep.jugador;
    final priorPts = j.ptsPg * _escalaPorMinutos(jep.minutos);
    final multiplicadorAtributo = PesosAtributos.multiplicadorAtributoMin +
        (PesosAtributos.multiplicadorAtributoMax -
                PesosAtributos.multiplicadorAtributoMin) *
            (j.indiceOfensivo / 99);
    // La chispa de anotación del sexto hombre es el mismo empujón que la
    // estrella de ataque, no uno acumulado: si el mejor suplente resulta
    // ser también el mejor jugador del equipo (puede pasar: la estrella se
    // elige por nivel general, sin mirar si es titular) no se dobla el
    // efecto por ser las dos cosas a la vez.
    final multiplicadorRol = jep.esEstrellaAtaque || jep.esSextoHombre
        ? PesosAtributos.multiplicadorEstrellaIndividual
        : 1.0;
    // Gaussiano y no uniforme: las noches malas y las buenas de verdad son
    // colas, no un rango plano. Ver PesosAtributos.sigmaRuidoAnotacion para
    // los números medidos.
    final ruido = max(
      PesosAtributos.minRuidoAnotacion,
      1 + _ruidoGaussiano(random) * PesosAtributos.sigmaRuidoAnotacion,
    );
    final peso = max(
      priorPts *
          multiplicadorAtributo *
          multiplicadorRol *
          jep.rendimiento *
          ruido,
      0.5,
    );
    pesosPuntos[jep] = peso;
  }

  final sumaPesos = pesosPuntos.values.fold<double>(0, (a, b) => a + b);
  final puntosPorJugador = <JugadorEnPartido, int>{};
  int puntosAsignados = 0;

  for (final jep in activos) {
    final share = pesosPuntos[jep]! / sumaPesos;
    final pts = (share * marcadorEquipo).round();
    puntosPorJugador[jep] = pts;
    puntosAsignados += pts;
  }

  // Reconciliar el redondeo para que la suma cuadre exactamente con el
  // marcador del equipo. Se ajusta a un jugador random (no siempre al
  // máximo anotador) para no inflar sistemáticamente su media de
  // temporada con el remanente de cada partido.
  final diferencia = marcadorEquipo - puntosAsignados;
  if (diferencia != 0 && activos.isNotEmpty) {
    final elegido = activos[random.nextInt(activos.length)];
    puntosPorJugador[elegido] = max(0, puntosPorJugador[elegido]! + diferencia);
  }

  return activos.map((jep) {
    final j = jep.jugador;
    final escalaMinutos = _escalaPorMinutos(jep.minutos);
    final asistencias =
        _statSecundaria(j.astPg, escalaMinutos, jep.rendimiento, random);
    final rebotes =
        _statSecundaria(j.trbPg, escalaMinutos, jep.rendimiento, random);

    return EstadisticasJugador(
      jugadorId: j.id,
      nombreFicticio: j.nombreFicticio,
      minutos: jep.minutos,
      puntos: puntosPorJugador[jep]!,
      asistencias: asistencias,
      rebotes: rebotes,
    );
  }).toList();
}

/// Cuánto escalan los promedios reales (pts/ast/reb por partido) de un
/// jugador según los minutos que le has dado. No es proporcional puro: ver
/// [PesosAtributos.pesoFijoDeMinutos].
double _escalaPorMinutos(int minutos) {
  const fijo = PesosAtributos.pesoFijoDeMinutos;
  return fijo + (1 - fijo) * (minutos / PesosAtributos.minutosReferencia);
}

int _statSecundaria(
  double statPg,
  double escalaMinutos,
  double penalizacionFueraDePosicion,
  Random random,
) {
  final ruido = 0.8 + random.nextDouble() * 0.4; // 0.8 - 1.2
  final valor = statPg * escalaMinutos * penalizacionFueraDePosicion * ruido;
  return max(0, valor.round());
}
