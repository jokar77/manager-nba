import 'dart:math';

import 'package:drift/drift.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import '../data/database/app_database.dart';
import 'entrenadores.dart';
import 'equipos_especiales.dart';

// Casi todo el que lee entrenadores necesita también la media y el estilo:
// se reexportan para no tener que importar los dos ficheros en cada sitio.
export 'entrenadores.dart';

/// El entrenador de [equipo], o null si el banquillo está vacío (te acabas
/// de cargar al anterior, o la partida es de antes de que existieran los
/// entrenadores y todavía no se ha rellenado).
Future<Entrenador?> leerEntrenadorDe(AppDatabase db, String equipo) {
  return (db.select(db.entrenadores)..where((t) => t.equipo.equals(equipo)))
      .getSingleOrNull();
}

/// Los que están sin equipo, de mejor a peor.
Future<List<Entrenador>> leerEntrenadoresLibres(AppDatabase db) async {
  final libres = await (db.select(db.entrenadores)
        ..where((t) => t.equipo.equals(equipoAgenciaLibre)))
      .get();
  return libres..sort((a, b) => mediaDe(b).compareTo(mediaDe(a)));
}

/// La media de un entrenador, con el mismo criterio en toda la app.
int mediaDe(Entrenador e) => mediaDeEntrenador(
      ataque: e.atrAtaque,
      defensa: e.atrDefensa,
      desarrollo: e.atrDesarrollo,
    );

/// Cómo lo ve el motor de simulación. Null si el equipo no tiene
/// entrenador: el motor lo trata como "aporte cero" (ver
/// `aporteDelEntrenador` en sim_engine), o sea que dirigir sin entrenador no
/// es un castigo, simplemente no hay ayuda.
Future<sim.EntrenadorEnPartido?> entrenadorEnPartidoDe(
  AppDatabase db,
  String equipo,
) async {
  final e = await leerEntrenadorDe(db, equipo);
  if (e == null) return null;
  return sim.EntrenadorEnPartido(ataque: e.atrAtaque, defensa: e.atrDefensa);
}

/// Los entrenadores de TODA la liga de una vez, indexados por equipo.
///
/// Existe por rendimiento y no por comodidad: simular un tramo de calendario
/// monta la alineación de los 30 equipos en cada jornada, y preguntar por el
/// entrenador equipo a equipo dentro de ese bucle son miles de consultas por
/// mes simulado.
Future<Map<String, sim.EntrenadorEnPartido>> leerEntrenadoresDeLaLiga(
  AppDatabase db,
) async {
  final todos = await db.select(db.entrenadores).get();
  return {
    for (final e in todos)
      if (esFranquicia(e.equipo))
        e.equipo: sim.EntrenadorEnPartido(
            ataque: e.atrAtaque, defensa: e.atrDefensa),
  };
}

/// La media de los cinco mejores de [equipo]: el mismo criterio que usa la
/// pantalla de elegir equipo para decir "media del equipo". Es lo que mira
/// un entrenador antes de aceptar tu oferta.
Future<int> mediaDeLosCincoMejores(AppDatabase db, String equipo) async {
  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.media)])
        ..limit(5))
      .get();
  if (plantilla.isEmpty) return 0;
  return (plantilla.map((j) => j.media).reduce((a, b) => a + b) /
          plantilla.length)
      .round();
}

/// ¿Aceptaría [entrenador] dirigir a [equipo] tal y como está hoy?
Future<bool> aceptariaDirigirA(
  AppDatabase db,
  Entrenador entrenador,
  String equipo,
) async {
  final media = await mediaDeLosCincoMejores(db, equipo);
  final resultado = await (db.select(db.resultadoTemporada)
        ..where((t) => t.equipo.equals(equipo)))
      .getSingleOrNull();
  return aceptaLaOferta(
    mediaDelEntrenador: mediaDe(entrenador),
    desarrolloDelEntrenador: entrenador.atrDesarrollo,
    mediaDelEquipo: media,
    victoriasElAnoPasado: resultado?.victorias ?? 0,
  );
}

/// Despide al entrenador de [equipo]: se va a la lista de libres, donde
/// puede volver a firmar por cualquiera (incluido tú, si te arrepientes).
///
/// No cuesta nada porque el tope salarial del juego cuenta solo jugadores.
/// El precio es el otro: te quedas sin nadie en el banquillo hasta que
/// fiches, y quien te interese puede decirte que no.
Future<void> despedirEntrenador(AppDatabase db, String equipo) async {
  await (db.update(db.entrenadores)..where((t) => t.equipo.equals(equipo)))
      .write(const EntrenadoresCompanion(equipo: Value(equipoAgenciaLibre)));
}

/// Por qué no se ha podido fichar a un entrenador, para poder decírselo al
/// usuario con palabras en vez de con un booleano.
enum MotivoDeRechazo {
  /// Ya no está libre (se lo ha llevado otro equipo mientras mirabas).
  yaTieneEquipo,

  /// No le convence el proyecto: tu plantilla no da para lo que él pide.
  noLeConvenceElProyecto,
}

/// Ficha a [entrenadorId] para [equipo]. Si ya había alguien en el
/// banquillo, se le despide en el mismo movimiento.
///
/// Devuelve null si ha firmado, o el motivo si ha dicho que no.
Future<MotivoDeRechazo?> contratarEntrenador(
  AppDatabase db,
  int entrenadorId,
  String equipo,
) async {
  final candidato = await (db.select(db.entrenadores)
        ..where((t) => t.id.equals(entrenadorId)))
      .getSingleOrNull();
  if (candidato == null || candidato.equipo != equipoAgenciaLibre) {
    return MotivoDeRechazo.yaTieneEquipo;
  }
  if (!await aceptariaDirigirA(db, candidato, equipo)) {
    return MotivoDeRechazo.noLeConvenceElProyecto;
  }

  await db.transaction(() async {
    await despedirEntrenador(db, equipo);
    await (db.update(db.entrenadores)..where((t) => t.id.equals(entrenadorId)))
        .write(EntrenadoresCompanion(equipo: Value(equipo)));
  });
  return null;
}

/// El récord de esta temporada del entrenador de [equipo].
///
/// No se guarda partido a partido, y es a propósito: el récord de un
/// entrenador es EXACTAMENTE el de su equipo, así que llevarlo aparte serían
/// dos consultas más en cada uno de los ~2.500 partidos que se simulan en un
/// año, para acabar con dos cuentas que pueden desincronizarse. Se lee de
/// `ResultadoTemporada`, que ya está, y lo acumulado de su carrera se suma
/// una vez por verano (ver [pasarElVeranoDeLosEntrenadores]).
Future<({int victorias, int derrotas})> recordDeEstaTemporada(
  AppDatabase db,
  String equipo,
) async {
  final fila = await (db.select(db.resultadoTemporada)
        ..where((t) => t.equipo.equals(equipo)))
      .getSingleOrNull();
  return (victorias: fila?.victorias ?? 0, derrotas: fila?.derrotas ?? 0);
}

/// Un movimiento de banquillo del verano, para poder contarlo en la
/// pantalla de pretemporada.
class MovimientoDeEntrenador {
  final String equipo;
  final String? saliente;
  final String? entrante;

  /// True cuando el saliente no se ha ido a otro equipo: lo ha dejado.
  final bool seRetira;

  const MovimientoDeEntrenador({
    required this.equipo,
    this.saliente,
    this.entrante,
    this.seRetira = false,
  });
}

/// Victorias por debajo de las cuales un equipo de la CPU se plantea un
/// cambio de banquillo. Veintiocho de 82 es una temporada claramente mala
/// sin ser un desastre irrepetible.
const _victoriasQueSalvanElPuesto = 28;

/// Probabilidad de que un equipo de la CPU con una mala temporada eche al
/// entrenador. No es automático a propósito: en la NBA real una temporada
/// mala no siempre cuesta el puesto, y si lo fuera, cada verano habría
/// exactamente los mismos movimientos.
const _probabilidadDeDespido = 0.55;

/// El verano de los entrenadores: cumplen años, los mayores lo dejan, los
/// equipos de la CPU que han ido mal se plantean un cambio, y los bancos
/// que queden vacíos se llenan con el mejor libre que acepte el proyecto.
///
/// TU banquillo no se toca: si quieres cambiar de entrenador lo haces tú
/// desde su pantalla. Lo único que puede pasarte es que el tuyo se retire —
/// eso no lo decide nadie— y en ese caso te lo dice el resumen de
/// pretemporada y te quedas con el puesto vacante hasta que fiches.
///
/// Va después de [envejecerLiga] en el cierre de temporada, para que la
/// media de plantilla que miran los candidatos sea ya la del año que viene.
Future<List<MovimientoDeEntrenador>> pasarElVeranoDeLosEntrenadores(
  AppDatabase db, {
  required String equipoUsuario,
  Random? random,
}) async {
  final rng = random ?? Random();
  final movimientos = <MovimientoDeEntrenador>[];

  // 1. Un año más para todos, y el récord de la temporada que acaba pasa a
  //    su carrera. Este es el único sitio donde se suma: durante el año, el
  //    récord del entrenador se lee del de su equipo (ver
  //    [recordDeEstaTemporada]).
  final resultados = await db.select(db.resultadoTemporada).get();
  final recordPorEquipo = {
    for (final r in resultados) r.equipo: (r.victorias, r.derrotas),
  };

  final todos = await db.select(db.entrenadores).get();
  for (final e in todos) {
    if (e.equipo == equipoRetirados) continue;
    final delAno = recordPorEquipo[e.equipo] ?? (0, 0);
    await (db.update(db.entrenadores)..where((t) => t.id.equals(e.id)))
        .write(EntrenadoresCompanion(
      edad: Value(e.edad + 1),
      temporadas: Value(e.temporadas + (esFranquicia(e.equipo) ? 1 : 0)),
      victorias: Value(e.victorias + delAno.$1),
      derrotas: Value(e.derrotas + delAno.$2),
    ));
  }

  // 2. Retiradas. Se decide sobre la edad ya cumplida.
  for (final e in todos) {
    if (e.equipo == equipoRetirados) continue;
    final edad = e.edad + 1;
    if (!_seRetira(edad, rng)) continue;
    await (db.update(db.entrenadores)..where((t) => t.id.equals(e.id)))
        .write(const EntrenadoresCompanion(equipo: Value(equipoRetirados)));
    if (esFranquicia(e.equipo)) {
      movimientos.add(MovimientoDeEntrenador(
        equipo: e.equipo,
        saliente: e.nombreFicticio,
        seRetira: true,
      ));
    }
  }

  // 3. Despidos de la CPU. El tuyo no: tú decides.
  final victoriasPorEquipo = {
    for (final r in resultados) r.equipo: r.victorias,
  };
  final trasRetiradas = await db.select(db.entrenadores).get();
  for (final e in trasRetiradas) {
    if (!esFranquicia(e.equipo) || e.equipo == equipoUsuario) continue;
    final victorias = victoriasPorEquipo[e.equipo] ?? 41;
    if (victorias >= _victoriasQueSalvanElPuesto) continue;
    if (rng.nextDouble() >= _probabilidadDeDespido) continue;

    await despedirEntrenador(db, e.equipo);
    movimientos.add(MovimientoDeEntrenador(
      equipo: e.equipo,
      saliente: e.nombreFicticio,
    ));
  }

  // 4. Los banquillos vacíos se llenan. El tuyo NO: que se te vaya el
  //    entrenador y aparezca otro puesto a dedo sería quitarte la decisión.
  final equipos = resultados.map((r) => r.equipo).where(esFranquicia).toList()
    ..sort();
  for (final equipo in equipos) {
    if (equipo == equipoUsuario) continue;
    if (await leerEntrenadorDe(db, equipo) != null) continue;

    final fichado = await _contratarAlMejorQueAcepte(db, equipo);
    if (fichado == null) continue;
    final indice = movimientos.indexWhere((m) => m.equipo == equipo);
    if (indice >= 0) {
      final previo = movimientos[indice];
      movimientos[indice] = MovimientoDeEntrenador(
        equipo: equipo,
        saliente: previo.saliente,
        entrante: fichado,
        seRetira: previo.seRetira,
      );
    } else {
      movimientos.add(
          MovimientoDeEntrenador(equipo: equipo, entrante: fichado));
    }
  }

  return movimientos;
}

/// Ficha para [equipo] al mejor libre que acepte el proyecto, y devuelve su
/// nombre. Null si no lo coge nadie — puede pasar si el mercado se ha
/// quedado seco, y es preferible a un banquillo con alguien que no quería
/// estar ahí.
Future<String?> _contratarAlMejorQueAcepte(
    AppDatabase db, String equipo) async {
  for (final candidato in await leerEntrenadoresLibres(db)) {
    if (!await aceptariaDirigirA(db, candidato, equipo)) continue;
    await (db.update(db.entrenadores)..where((t) => t.id.equals(candidato.id)))
        .write(EntrenadoresCompanion(equipo: Value(equipo)));
    return candidato.nombreFicticio;
  }
  return null;
}

/// A partir de [edadDeRetiroDeEntrenador] la probabilidad de dejarlo crece
/// un 12% por año, y a [edadMaximaDeEntrenador] es segura. Repartido así
/// —en vez de con un corte seco— cada partida tiene sus propias retiradas.
bool _seRetira(int edad, Random rng) {
  if (edad >= edadMaximaDeEntrenador) return true;
  if (edad < edadDeRetiroDeEntrenador) return false;
  return rng.nextDouble() < (edad - edadDeRetiroDeEntrenador + 1) * 0.12;
}

/// Rellena los banquillos que estén vacíos porque la partida viene de una
/// versión sin entrenadores: reparte a los libres por los equipos que no
/// tengan a nadie, sin mirar si aceptan el proyecto (aquí no hay decisión
/// que tomar, solo un hueco de datos que tapar).
///
/// El del usuario también, y a propósito: al abrir una partida vieja se
/// encuentra su banquillo cubierto como estaba en la vida real, no vacío.
Future<void> asignarEntrenadoresQueFalten(AppDatabase db) async {
  final ocupados = (await db.select(db.entrenadores).get())
      .map((e) => e.equipo)
      .where(esFranquicia)
      .toSet();
  final equipos = (await db.select(db.resultadoTemporada).get())
      .map((r) => r.equipo)
      .where(esFranquicia)
      .where((e) => !ocupados.contains(e))
      .toList()
    ..sort();
  if (equipos.isEmpty) return;

  final libres = await leerEntrenadoresLibres(db);
  for (var i = 0; i < equipos.length && i < libres.length; i++) {
    await (db.update(db.entrenadores)..where((t) => t.id.equals(libres[i].id)))
        .write(EntrenadoresCompanion(equipo: Value(equipos[i])));
  }
}
