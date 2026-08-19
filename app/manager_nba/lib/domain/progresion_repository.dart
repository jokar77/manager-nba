import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'curva_estadisticas.dart';
import 'entrenadores.dart';
import 'equipos_especiales.dart';

// Este repositorio es quien manda a los jugadores a `equipoRetirados`, y
// media docena de sitios lo importan desde aquí: se reexporta para no
// tener que tocar todos esos imports.
export 'equipos_especiales.dart' show equipoRetirados;

/// Edad a partir de la cual un jugador deja de crecer. Con 25 se quedaba
/// corto: como el salto anual es una fracción de lo que falta, los
/// prospectos llegaban a su plenitud 4-5 puntos por debajo de su potencial
/// y el techo de la liga se iba aplanando temporada tras temporada.
const _edadFinDeCrecimiento = 27;

/// Edad a partir de la cual el declive se acelera de verdad.
const _edadDeclive = 31;

/// Probabilidad de que un jugador joven no mejore NADA en un verano
/// concreto. No es un castigo aparte: es la misma temporada de
/// progresión, tirando a que salga 0. Con esto ni todo el mundo llega a
/// su potencial ni deja de haber estrellas — solo dejan de ser un
/// destino garantizado.
const probabilidadDeEstancarse = 0.16;

/// Suelo de media: por muy mayor que sea, un jugador en activo no baja de
/// aquí (si bajara tanto, ya se habría retirado).
const _mediaMinima = 45;

/// Media a partir de la cual a un jugador no lo retira el calendario.
///
/// La edad de retiro se sortea al importar (34-42, moda 37) sin mirar el
/// nivel, y eso mandaba a casa a LeBron y a Durant con media 92 — nadie
/// deja el baloncesto siendo de los diez mejores del mundo. Mientras sigas
/// por encima de esta línea sigues jugando; el declive de cada verano acaba
/// bajándote de ella tarde o temprano, y ahí sí se aplica tu edad.
const mediaQueAguantaElRetiro = 85;

/// El tope duro, para que la excepción de arriba no dé carreras eternas.
/// Cuarenta y cuatro es un año más de lo que aguantó Vince Carter, que es
/// el techo de lo creíble.
const edadMaximaEnActivo = 44;

/// Lo que le ha pasado a un jugador al cambiar de temporada, para poder
/// contarlo en el resumen de pretemporada.
class CambioDeJugador {
  final int jugadorId;
  final String nombre;
  final String equipo;
  final int mediaAntes;
  final int mediaDespues;
  final bool seRetira;

  /// La edad que tiene ya cumplido el año, o sea con la que se retira quien
  /// cuelga las botas. "Se retira con 39" dice mucho más que la media sola.
  final int edad;

  const CambioDeJugador({
    required this.jugadorId,
    required this.nombre,
    required this.equipo,
    required this.mediaAntes,
    required this.mediaDespues,
    required this.seRetira,
    required this.edad,
  });

  int get delta => mediaDespues - mediaAntes;
}

/// Envejece un año a toda la liga: retira a quien pasa de su edad de
/// retiro, hace progresar a los jóvenes hacia su potencial y declinar a los
/// veteranos (más despacio cuanto mayor sea su `factorLongevidad`). Las
/// medias por partido (pts/ast/reb) se mueven en la misma proporción que la
/// media, para que las estadísticas simuladas acompañen a la evolución.
///
/// Devuelve un cambio por jugador afectado, ordenado de mejor a peor
/// evolución (los retirados aparte).
///
/// [desarrolloPorEquipo] es el atributo de desarrollo del entrenador de cada
/// equipo. Es lo único que hace el entrenador fuera de los partidos, y solo
/// toca a los que todavía crecen: acelera o frena su salto hacia el
/// potencial (ver [factorDeDesarrollo]). A un veterano en declive no le
/// afecta — un buen entrenador no le quita años a nadie.
Future<List<CambioDeJugador>> envejecerLiga(
  AppDatabase db, {
  Random? random,
  Map<String, int> desarrolloPorEquipo = const {},
}) async {
  final rng = random ?? Random();
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();

  final cambios = <CambioDeJugador>[];
  final actualizaciones = <(int, JugadoresCompanion)>[];

  for (final j in jugadores) {
    final nuevaEdad = j.edad + 1;
    final nuevaMedia = _mediaTrasUnAno(j, nuevaEdad, rng,
        factorDeDesarrollo(desarrolloPorEquipo[j.equipo]));

    // El nivel que decide es el del verano que viene, no el del año pasado:
    // si el declive de este verano ya te baja del listón, te retiras ahora y
    // no juegas una temporada de más con la media por debajo.
    final leTocaPorEdad = nuevaEdad > j.edadRetiro;
    final sigueSiendoDeLosMejores = nuevaMedia >= mediaQueAguantaElRetiro;
    if ((leTocaPorEdad && !sigueSiendoDeLosMejores) ||
        nuevaEdad > edadMaximaEnActivo) {
      cambios.add(CambioDeJugador(
        jugadorId: j.id,
        nombre: j.nombreFicticio,
        equipo: j.equipo,
        mediaAntes: j.media,
        mediaDespues: j.media,
        seRetira: true,
        edad: nuevaEdad,
      ));
      actualizaciones.add((
        j.id,
        JugadoresCompanion(
          edad: Value(nuevaEdad),
          retirado: const Value(true),
          equipo: const Value(equipoRetirados),
        )
      ));
      continue;
    }

    final factor = j.media == 0 ? 1.0 : nuevaMedia / j.media;

    // Las estadísticas se mueven POR LA CURVA de su nuevo nivel, no
    // multiplicando por la razón de medias.
    //
    // Escalar linealmente parecía razonable y vaciaba la liga: la relación
    // entre media y puntos es convexa (un 77 anota 7,8 y un 87 anota 19,6),
    // así que un rookie de 65 con 5,8 puntos que llegaba a 95 acababa con
    // 8,5 en vez de los ~28 que le tocan. Medido sobre 15 veranos, el mejor
    // anotador de la liga caía de 33,5 a 21,4 puntos y desaparecían los de
    // 25+, mientras seguía habiendo 26 medias de 90 o más.
    //
    // El "estilo" conserva la personalidad: quien anota más de lo normal
    // para su nivel lo sigue haciendo al subir. Y si la media no cambia, el
    // resultado es exactamente el que tenía.
    double porLaCurva(double valor, double antes, double despues) =>
        despues * estiloRespectoASuNivel(valor, antes);

    final nuevosPts = porLaCurva(
            j.ptsPg, puntosTipicos(j.media), puntosTipicos(nuevaMedia))
        .clamp(0.0, maxPuntosPorPartido);
    final nuevasAst = porLaCurva(j.astPg,
        asistenciasTipicas(j.media, j.posicion),
        asistenciasTipicas(nuevaMedia, j.posicion));
    final nuevosReb = porLaCurva(j.trbPg,
        rebotesTipicos(j.media, j.posicion),
        rebotesTipicos(nuevaMedia, j.posicion));

    cambios.add(CambioDeJugador(
      jugadorId: j.id,
      nombre: j.nombreFicticio,
      equipo: j.equipo,
      mediaAntes: j.media,
      mediaDespues: nuevaMedia,
      seRetira: false,
      edad: nuevaEdad,
    ));
    actualizaciones.add((
      j.id,
      JugadoresCompanion(
        edad: Value(nuevaEdad),
        media: Value(nuevaMedia),
        // El potencial nunca baja por debajo de lo ya alcanzado.
        potencial: Value(max(j.potencial, nuevaMedia)),
        atrAtaque: Value(_escalarAtributo(j.atrAtaque, factor)),
        atrDefensa: Value(_escalarAtributo(j.atrDefensa, factor)),
        atrTiro3: Value(_escalarAtributo(j.atrTiro3, factor)),
        ptsPg: Value(nuevosPts),
        astPg: Value(nuevasAst),
        trbPg: Value(nuevosReb),
      )
    ));
  }

  await db.transaction(() async {
    for (final (id, companion) in actualizaciones) {
      await (db.update(db.jugadores)..where((t) => t.id.equals(id)))
          .write(companion);
    }
  });

  cambios.sort((a, b) => b.delta.compareTo(a.delta));
  return cambios;
}

int _mediaTrasUnAno(
    Jugador j, int nuevaEdad, Random rng, double factorEntrenador) {
  // El techo de crecimiento: su potencial, pero NUNCA por debajo de lo que
  // ya es. En el dataset el potencial de 396 de los 641 jugadores viene por
  // debajo de su media (se generó como "cuánto le queda por crecer", no
  // como techo absoluto), así que usarlo tal cual como límite superior no
  // frenaba el crecimiento: hundía al jugador de golpe hasta ese número.
  // Isaac Jones —media 65, potencial 45, 25 años— perdía 20 puntos en un
  // solo verano, y con él más de la mitad de la liga. Un jugador hecho no
  // se desploma a su potencial: como mucho deja de mejorar.
  final techo = max(j.potencial, j.media);

  if (nuevaEdad < _edadFinDeCrecimiento) {
    // Los jóvenes se acercan a su potencial: cuanto más lejos están, más
    // rápido suben (un proyecto explota, un jugador ya hecho apenas mejora).
    // Aquí, y solo aquí, entra el entrenador: acelera o frena el salto, pero
    // no puede subir a nadie por encima de su potencial.
    //
    // Y aquí también entra la posibilidad de que el verano no traiga NADA:
    // sin esto, el salto siempre era positivo (22%-48% del margen, cada
    // año, sin excepción) y con hasta ocho veranos por delante (de 19 a
    // 27), casi cualquiera acababa cerca de su potencial. Medido: el
    // número 1 del draft llegaba a 90+ de media dentro de su contrato de
    // rookie el 20% de las veces — no es una barbaridad, pero el
    // crecimiento en sí NUNCA podía fallar, y eso es justo lo que no pasa
    // en la vida real: hay prospectos que se estancan un año, o varios.
    // Con [probabilidadDeEstancarse] algunos veranos no traen ni un punto,
    // sin tocar el resto de la curva.
    if (rng.nextDouble() < probabilidadDeEstancarse) return j.media;
    final margen = (techo - j.media).clamp(0, 40);
    final salto =
        (margen * (0.22 + rng.nextDouble() * 0.26) * factorEntrenador).round();
    return min(techo, j.media + salto);
  }

  if (nuevaEdad < _edadDeclive) {
    // Años de plenitud: se mueve poco, en cualquier dirección.
    return (j.media + rng.nextInt(3) - 1).clamp(_mediaMinima, techo);
  }

  // Declive: se agrava con la edad y lo amortigua el factor de longevidad,
  // pero acotado — sin el tope, `anosDeDeclive` crecía sin límite con la
  // edad y el "cuánto cae este año" (no el total acumulado, el de UN solo
  // año) se multiplicaba por ese número cada vez: una estrella que seguía
  // jugando a los 38-40 podía perder 10-13 puntos de golpe en una sola
  // temporada. A partir de los ~6 años de declive la intensidad se
  // estabiliza, así que un veterano longevo sigue bajando pero nunca a un
  // ritmo de más de un puñado de puntos al año.
  final anosDeDeclive = min(nuevaEdad - _edadDeclive + 1, 6);
  final intensidad = 1.0 + anosDeDeclive * 0.35;
  final caida =
      (intensidad * (0.7 + rng.nextDouble() * 0.6)) / max(j.factorLongevidad, 0.5);
  return max(_mediaMinima, j.media - caida.round());
}

int _escalarAtributo(int valor, double factor) =>
    (valor * factor).round().clamp(1, 99);
