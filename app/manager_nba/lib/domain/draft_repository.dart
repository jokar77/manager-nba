import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'curva_estadisticas.dart';
import 'equipos_especiales.dart';
import 'picks_repository.dart';
import 'posiciones.dart';
import 'salarios.dart';

/// Rondas del draft: 2 por equipo, como en la NBA real.
const rondasDeDraft = 2;

/// Plantilla mínima con la que un equipo puede afrontar una temporada: los
/// 10 huecos de la rotación (titular + suplente de cada puesto) más un
/// pequeño colchón para lesiones.
const plantillaMinima = 13;

/// Tope de plantilla. Hace falta porque el draft aporta 2 jugadores al año
/// por equipo y las retiradas se llevan menos de 2 de media: sin recortar,
/// en 25 temporadas las plantillas se irían a 35 jugadores. Al pasarse del
/// tope se corta por abajo (los de peor media quedan libres).
const plantillaMaxima = 18;

// Los prospectos del draft son jugadores inventados, sin relación con
// nadie real: a diferencia del dataset importado (582 jugadores reales con
// nombre disimulado, cambiando un par de letras a propósito porque
// representan a alguien que existe), aquí no hay nadie detrás a quien
// disimular. Por eso estos nombres y apellidos son de cosecha propia, no
// versiones retocadas de estrellas actuales — antes esta lista sí lo era
// ('Doncik', 'Jokik', 'Antetokunmo', 'Wembanyema', 'Bogdanovik'... cada
// nombre "raro" era una estrella real con una letra cambiada) y el
// resultado eran rookies que se leían como el jugador real disfrazado.
//
// Se reparten por origen para que la distribución de la liga se parezca a
// la NBA real: mayoría de EEUU, un grupo de europeos y muy pocos
// africanos. Nombre y apellido se sortean por separado (con este mismo
// reparto de pesos cada uno), así que un nombre europeo puede acabar con
// apellido estadounidense sin que eso rompa nada.
const _origenEEUU = 0;
const _origenEuropa = 1;
const _origenAfrica = 2;

/// Peso de cada origen al sortear: EEUU pesa mucho más que Europa, que a su
/// vez pesa mucho más que África.
const _pesosPorOrigen = [70, 24, 6];

const _nombresPilaEEUU = [
  'Jaylen', 'Marcus', 'Tyler', 'Brandon', 'Cameron', 'Dominic', 'Malik',
  'Jalen', 'Dorian', 'Isaiah', 'Andre', 'Xavier', 'Terrence', 'Devin',
  'Corey', 'Darius', 'Trey', 'Jaden', 'Keon', 'Rashad', 'Quentin',
  'Immanuel', 'Brayden', 'Trevon', 'Jamal', 'Elijah', 'Tristan', 'Deshawn',
  'Antoine', 'Julian', 'Grant', 'Miles', 'Chase', 'Colton', 'Bryson',
];

const _nombresPilaEuropa = [
  'Matteo', 'Luca', 'Andrei', 'Lukas', 'Marko', 'Stefan', 'Nils', 'Viktor',
  'Emil', 'Pavel', 'Tomas', 'Milan', 'Ivo', 'Adrian', 'Rasmus',
];

const _nombresPilaAfrica = [
  'Chidi', 'Kwame', 'Themba', 'Amadou', 'Femi', 'Junior',
];

const _apellidosEEUU = [
  'Harrison', 'Coleman', 'Barnett', 'Whitmore', 'Sanders', 'Bryant',
  'Sharpe', 'Murray', 'Williamson', 'Jefferson', 'Robertson', 'Bradford',
  'Sutton', 'Hendricks', 'Marsh', 'Calloway', 'Prescott', 'Winslow',
  'Ashford', 'Kingsley', 'Beaumont', 'Lockridge', 'Tanner', 'Ellison',
  'Whitfield', 'Sherwood', 'Kirkland', 'Delgado', 'Ferris', 'Boswell',
  'Hutchins', 'Carrington', 'Deleon', 'Sweeney', 'Ratliff',
];

const _apellidosEuropa = [
  'Novak', 'Ivanovic', 'Kovac', 'Horvat', 'Pavlovic', 'Lindqvist', 'Berger',
  'Rossi', 'Moretti', 'Kowalski', 'Novotny', 'Halvorsen', 'Andersson',
  'Marchetti', 'Vukovic',
];

const _apellidosAfrica = [
  'Mensah', 'Osei', 'Nwosu', 'Abara', 'Diakite', 'Toure',
];

int _origenSorteado(Random rng) {
  final total = _pesosPorOrigen.reduce((a, b) => a + b);
  var tirada = rng.nextInt(total);
  for (var i = 0; i < _pesosPorOrigen.length; i++) {
    if (tirada < _pesosPorOrigen[i]) return i;
    tirada -= _pesosPorOrigen[i];
  }
  return _origenEEUU;
}

List<String> _porOrigen(int origen, {required bool esApellido}) =>
    switch ((origen, esApellido)) {
      (_origenEuropa, false) => _nombresPilaEuropa,
      (_origenAfrica, false) => _nombresPilaAfrica,
      (_, false) => _nombresPilaEEUU,
      (_origenEuropa, true) => _apellidosEuropa,
      (_origenAfrica, true) => _apellidosAfrica,
      (_, true) => _apellidosEEUU,
    };

/// Un jugador recién generado para el draft, antes de asignarle equipo.
class ProspectoDraft {
  final JugadoresCompanion companion;
  final int posicionEnDraft;

  const ProspectoDraft({
    required this.companion,
    required this.posicionEnDraft,
  });
}

/// Un rookie ya repartido, para poder contarlo en el resumen.
class RookieElegido {
  final int jugadorId;
  final String nombre;
  final String posicion;
  final String equipo;
  final int media;
  final int potencial;
  final int numeroDeEleccion;

  const RookieElegido({
    required this.jugadorId,
    required this.nombre,
    required this.posicion,
    required this.equipo,
    required this.media,
    required this.potencial,
    required this.numeroDeEleccion,
  });
}

/// Genera la clase de draft de [anioDraft]: [cantidad] prospectos ordenados
/// de mejor a peor, con la calidad decayendo según el puesto (el número 1
/// llega listo para jugar y con techo de estrella; el último es un proyecto
/// de banquillo).
///
/// Esto es lo que hace posible una carrera indefinida: el dataset original
/// se agota del todo hacia la temporada 20, así que a partir de ahí la liga
/// se sostiene con jugadores generados.
/// [calidadFija] fuerza a todos los generados al mismo nivel de la curva
/// (0.0 = número 1 del draft, 1.0 = última elección). Lo usa el relleno de
/// plantillas cortas, que no debe producir estrellas.
List<ProspectoDraft> generarClaseDeDraft({
  required int anioDraft,
  required int cantidad,
  required Set<String> nombresYaUsados,
  double? calidadFija,
  String? posicionFija,
  Random? random,
}) {
  final rng = random ?? Random();
  final usados = {...nombresYaUsados};
  final prospectos = <ProspectoDraft>[];

  for (var i = 0; i < cantidad; i++) {
    // 0.0 el número 1 del draft, 1.0 el último.
    final posicionRelativa =
        calidadFija ?? (cantidad == 1 ? 0.0 : i / (cantidad - 1));

    final media = (74 - posicionRelativa * 16 + rng.nextInt(5) - 2)
        .round()
        .clamp(52, 80);
    final margenPotencial = (22 - posicionRelativa * 12).round();
    final potencial =
        (media + rng.nextInt(margenPotencial + 1) + 2).clamp(media, 99);

    final posicion = posicionFija ??
        posicionesEquipo[rng.nextInt(posicionesEquipo.length)];
    final edad = 19 + rng.nextInt(3);

    // Contrato de rookie. En la NBA la primera ronda firma la escala
    // completa y la segunda contratos cortos, así que una clase de draft no
    // se deshace hasta que esos contratos vencen.
    //
    // Antes esto no se rellenaba y caían los valores por defecto de la
    // tabla —salario 0 y UN solo año—, o sea que un drafteado no tenía
    // contrato de rookie en absoluto: el verano siguiente ya entraba en el
    // reparto de vencimientos de `resolverVencimientosDeLaCpu` en igualdad
    // con los veteranos, donde `probabilidadDeNoRenovar` lo podía soltar al
    // mercado. Medido a 8 temporadas, de cada hornada de 60 solo 32 seguían
    // en una plantilla al año siguiente: la clase se deshacía tras UNA
    // temporada en vez de al acabar su primer contrato.
    //
    // El relleno de plantillas cortas entra por aquí con `calidadFija` 1.0,
    // así que le toca el contrato del final del draft — que es justo lo que
    // le corresponde a un no drafteado.
    final aniosDeRookie = posicionRelativa < 0.5 ? 4 : 2;

    final tiro3 = _atributo(rng, media, posicion == 'C' ? -8 : 4);
    final defensa = _atributo(rng, media, posicion == 'C' ? 6 : 0);

    prospectos.add(ProspectoDraft(
      posicionEnDraft: i + 1,
      companion: JugadoresCompanion.insert(
        nombreFicticio: _nombreUnico(rng, usados),
        nombreReal: '',
        posicion: posicion,
        posicionSecundaria: Value(_segundaPosicionDe(posicion, tiro3, defensa)),
        equipo: equipoAgenciaLibre,
        edad: edad,
        media: media,
        potencial: potencial,
        atrTiro3: tiro3,
        atrAtaque: _atributo(rng, media, 0),
        atrDefensa: defensa,
        ptsPg: _ptsDe(media),
        astPg: _astDe(posicion, media),
        trbPg: _trbDe(posicion, media),
        // Un rookie con buen físico dura más; se sortea sin más.
        factorLongevidad: 0.9 + rng.nextDouble() * 0.25,
        edadRetiro: edad + 10 + rng.nextInt(11),
        draftYear: Value(anioDraft),
        // La escala de rookie va por el PUESTO del draft, como en la NBA
        // real: un numero 1 cobra de franquicia desde el primer dia,
        // gane lo que gane esa temporada. Los de segunda ronda
        // (posicionRelativa >= 0,5) van por lo que son, porque ahi no
        // hay escala real que seguir.
        salario: Value(posicionRelativa < 0.5
            ? salarioDeRookiePrimeraRonda(posicionRelativa)
            : salarioEstimado(media: media, edad: edad)),
        aniosContrato: Value(aniosDeRookie),
      ),
    ));
  }

  return prospectos;
}

String _nombreSorteado(Random rng) {
  final pila = _porOrigen(_origenSorteado(rng), esApellido: false);
  final apellido = _porOrigen(_origenSorteado(rng), esApellido: true);
  return '${pila[rng.nextInt(pila.length)]} '
      '${apellido[rng.nextInt(apellido.length)]}';
}

/// Un nombre inventado que no esté ya en [usados] (se le añade). Lo usan
/// tanto los rookies del draft como los entrenadores que van saliendo del
/// mercado, para que todo el mundo inventado en la partida salga del mismo
/// repertorio y con el mismo reparto de orígenes.
String nombreFicticioUnico(Random rng, Set<String> usados) =>
    _nombreUnico(rng, usados);

String _nombreUnico(Random rng, Set<String> usados) {
  for (var intento = 0; intento < 200; intento++) {
    final nombre = _nombreSorteado(rng);
    if (usados.add(nombre)) return nombre;
  }
  // Con cientos de combinaciones esto no debería pasar en muchas
  // temporadas, pero en una carrera muy larga hay que garantizar unicidad
  // igualmente.
  var sufijo = 2;
  while (true) {
    final nombre = '${_nombreSorteado(rng)} $sufijo';
    if (usados.add(nombre)) return nombre;
    sufijo++;
  }
}

int _atributo(Random rng, int media, int sesgo) =>
    (media + sesgo + rng.nextInt(9) - 4).clamp(30, 99);

/// La segunda posición de un prospecto, por su perfil de juego: el que tira
/// de tres se abre hacia fuera y el que defiende tira hacia dentro.
///
/// No se usa `derivarPosicionSecundaria` (la de los jugadores reales) porque
/// no serviría de nada: un prospecto nace justo en la curva, con las
/// asistencias y los rebotes EXACTAMENTE típicos de su puesto, así que la
/// comparación daría empate y todas las hornadas saldrían escoradas al
/// mismo lado. Sus atributos sí vienen sorteados, y ahí sí hay variedad.
String _segundaPosicionDe(String posicion, int tiro3, int defensa) {
  final indice = posicionesEquipo.indexOf(posicion);
  if (indice <= 0) return posicionesEquipo[1];
  if (indice >= posicionesEquipo.length - 1) {
    return posicionesEquipo[posicionesEquipo.length - 2];
  }
  return tiro3 > defensa
      ? posicionesEquipo[indice - 1]
      : posicionesEquipo[indice + 1];
}

// Los números con los que nace un prospecto salen de la curva medida en el
// dataset real (ver curva_estadisticas.dart), no de una recta.
//
// Antes eran rectas con tope: `_ptsDe` daba `(media - 48) * 0.34` topado en
// 18, así que un prospecto de media 90 nacía con 14,3 puntos —un 90 real
// anota unos 25— y NINGÚN jugador generado podía pasar de 18 en su vida.
// Con las clases de draft sustituyendo poco a poco al dataset real, el
// techo anotador de la liga se hundía: medido sobre 15 veranos, el mejor
// anotador pasaba de 33,5 a 21,4 puntos.
//
// Los prospectos nacen justo en la curva, sin desviarse: su personalidad ya
// la marcan sus atributos y lo que hagan al progresar.
double _ptsDe(int media) => puntosTipicos(media);

double _astDe(String posicion, int media) =>
    asistenciasTipicas(media, posicion);

double _trbDe(String posicion, int media) => rebotesTipicos(media, posicion);

/// Pone en marcha el draft de [anioDraft]: genera la clase completa y la
/// deja en el "pool" ([equipoProspectos]) — todavía no es de nadie — y
/// apunta el orden de los turnos.
///
/// [ordenDeEleccion] es el orden de la clasificación (peor récord primero),
/// pero quien elige en cada puesto no es necesariamente ese equipo: si su
/// pick de ese año y esa ronda está traspasado, el turno es del dueño
/// actual. Ver picks_repository.dart.
///
/// A partir de aquí las elecciones van una a una, con
/// [elegirEnDraft] cuando eliges tú y [elegirPorLaCpu] cuando le toca a
/// otro. El estado vive en la base, así que un draft a medias sobrevive a
/// cerrar el juego.
Future<void> iniciarDraft(
  AppDatabase db, {
  required int anioDraft,
  required List<String> ordenDeEleccion,
  Random? random,
}) async {
  final rng = random ?? Random();
  final nombresUsados = (await db.select(db.jugadores).get())
      .map((j) => j.nombreFicticio)
      .toSet();

  final clase = generarClaseDeDraft(
    anioDraft: anioDraft,
    cantidad: ordenDeEleccion.length * rondasDeDraft,
    nombresYaUsados: nombresUsados,
    random: rng,
  );

  final picks = await picksVivos(db);
  final dueno = {
    for (final p in picks)
      if (p.temporada == anioDraft) '${p.ronda}|${p.equipoOriginal}': p.equipoActual,
  };

  final turnos = <String>[
    for (var ronda = 1; ronda <= rondasDeDraft; ronda++)
      for (final equipo in ordenDeEleccion)
        dueno['$ronda|$equipo'] ?? equipo,
  ];

  await db.transaction(() async {
    await db.batch((batch) => batch.insertAll(
          db.jugadores,
          clase.map((p) =>
              p.companion.copyWith(equipo: const Value(equipoProspectos))),
        ));
    await db.into(db.draftEnCurso).insertOnConflictUpdate(
          DraftEnCursoCompanion.insert(
            id: const Value(0),
            anioDraft: anioDraft,
            ordenEquipos: turnos.join(','),
            indice: const Value(0),
          ),
        );
  });
}

/// El draft que está a medias, si lo hay.
Future<DraftEnCursoData?> leerDraftEnCurso(AppDatabase db) =>
    (db.select(db.draftEnCurso)..where((t) => t.id.equals(0)))
        .getSingleOrNull();

/// Los prospectos que quedan por elegir, de mejor a peor valorados.
Future<List<Jugador>> prospectosDisponibles(AppDatabase db) {
  return (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipoProspectos))
        ..orderBy([
          (t) => OrderingTerm.desc(t.potencial),
          (t) => OrderingTerm.desc(t.media),
        ]))
      .get();
}

/// A qué equipo le toca elegir, o null si el draft ya terminó.
Future<String?> equipoQueElige(AppDatabase db) async {
  final estado = await leerDraftEnCurso(db);
  if (estado == null) return null;
  final turnos = estado.ordenEquipos.split(',');
  if (estado.indice >= turnos.length) return null;
  return turnos[estado.indice];
}

/// Número de la elección actual (1 = número 1 del draft).
Future<int> numeroDeEleccionActual(AppDatabase db) async {
  final estado = await leerDraftEnCurso(db);
  return (estado?.indice ?? 0) + 1;
}

/// Asigna [jugadorId] al equipo que tiene el turno y pasa al siguiente.
Future<RookieElegido?> elegirEnDraft(AppDatabase db, int jugadorId) async {
  final estado = await leerDraftEnCurso(db);
  if (estado == null) return null;
  final equipo = await equipoQueElige(db);
  if (equipo == null) return null;

  final prospecto = await (db.select(db.jugadores)
        ..where((t) =>
            t.id.equals(jugadorId) & t.equipo.equals(equipoProspectos)))
      .getSingleOrNull();
  if (prospecto == null) return null;

  await db.transaction(() async {
    await (db.update(db.jugadores)..where((t) => t.id.equals(jugadorId)))
        .write(JugadoresCompanion(equipo: Value(equipo)));
    await (db.update(db.draftEnCurso)..where((t) => t.id.equals(0)))
        .write(DraftEnCursoCompanion(indice: Value(estado.indice + 1)));
  });

  return RookieElegido(
    jugadorId: prospecto.id,
    nombre: prospecto.nombreFicticio,
    posicion: prospecto.posicion,
    equipo: equipo,
    media: prospecto.media,
    potencial: prospecto.potencial,
    numeroDeEleccion: estado.indice + 1,
  );
}

/// Elección de la CPU: coge al mejor disponible, dando un empujón a los
/// prospectos que cubren un puesto donde su plantilla anda corta. Pesa más
/// el potencial que la media — en el draft se ficha por lo que puede llegar
/// a ser, no por lo que es hoy.
Future<RookieElegido?> elegirPorLaCpu(AppDatabase db) async {
  final equipo = await equipoQueElige(db);
  if (equipo == null) return null;

  final disponibles = await prospectosDisponibles(db);
  if (disponibles.isEmpty) return null;

  final plantilla = await (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo)))
      .get();
  final puestosCortos = {
    for (final puesto in posicionesEquipo)
      if (plantilla.where((j) => juegaComodoDe(j, puesto)).length < 2) puesto,
  };

  double valor(Jugador j) {
    final base = j.potencial * 0.6 + j.media * 0.4;
    final cubreHueco = puestosCortos.contains(j.posicion) ||
        puestosCortos.contains(j.posicionSecundaria);
    return cubreHueco ? base + 6 : base;
  }

  final elegido = disponibles.reduce((a, b) => valor(a) >= valor(b) ? a : b);
  return elegirEnDraft(db, elegido.id);
}

/// Resuelve elecciones de la CPU hasta que le toque a [pararEn] o hasta que
/// se acabe el draft. Devuelve lo que ha ido pasando, para poder enseñarlo.
Future<List<RookieElegido>> avanzarDraftHastaElTurnoDe(
  AppDatabase db,
  String? pararEn,
) async {
  final elegidos = <RookieElegido>[];
  while (true) {
    final turno = await equipoQueElige(db);
    if (turno == null || turno == pararEn) break;
    final elegido = await elegirPorLaCpu(db);
    if (elegido == null) break;
    elegidos.add(elegido);
  }
  return elegidos;
}

/// Cierra el draft: los prospectos que nadie eligió pasan a la agencia
/// libre, se completan las plantillas cortas, se garantiza que todos los
/// puestos tengan recambio y se recorta a los equipos pasados de tope.
Future<void> finalizarDraft(AppDatabase db, {Random? random}) async {
  final rng = random ?? Random();
  final estado = await leerDraftEnCurso(db);
  final anioDraft = estado?.anioDraft ?? DateTime.now().year;

  await (db.update(db.jugadores)
        ..where((t) => t.equipo.equals(equipoProspectos)))
      .write(const JugadoresCompanion(equipo: Value(equipoAgenciaLibre)));
  await db.delete(db.draftEnCurso).go();

  // Las elecciones de este draft ya están gastadas, y se abre un año más al
  // final del horizonte para que siempre haya picks futuros que negociar.
  await marcarPicksUsados(db, anioDraft);
  final equipos = (await db.select(db.jugadores).get())
      .map((j) => j.equipo)
      .where(esFranquicia)
      .toSet()
      .toList()
    ..sort();
  await asegurarPicksFuturos(db,
      primerAnioDeDraft: anioDraft + 1, equipos: equipos);

  // El orden importa: primero se cubren los huecos (por número y por
  // puesto) y solo después se recorta, porque el recorte ya sabe que no
  // puede dejar un puesto descubierto.
  await _completarPlantillasCortas(db, anioDraft: anioDraft, random: rng);
  await _garantizarCoberturaDePuestos(db, anioDraft: anioDraft, random: rng);
  await recortarPlantillasLargas(db, claseDelDraft: anioDraft);
}

/// Celebra el draft entero de golpe, eligiendo la CPU por todos. Es lo que
/// usa el cambio de temporada automático (y los tests); cuando lo juegas tú
/// desde la pantalla del draft, se usan las funciones de arriba paso a paso.
Future<List<RookieElegido>> celebrarDraft(
  AppDatabase db, {
  required int anioDraft,
  required List<String> ordenDeEleccion,
  Random? random,
}) async {
  final rng = random ?? Random();
  await iniciarDraft(db,
      anioDraft: anioDraft, ordenDeEleccion: ordenDeEleccion, random: rng);
  final elegidos = await avanzarDraftHastaElTurnoDe(db, null);
  await finalizarDraft(db, random: rng);
  return elegidos;
}

/// Cada equipo tiene que poder poner titular y suplente cómodos en los 5
/// puestos. Como la posición de cada rookie se sortea, un equipo puede
/// acabar sin nadie de un puesto concreto tras unas cuantas retiradas; aquí
/// se fichan los que falten, ya con la posición que hace falta.
Future<void> _garantizarCoberturaDePuestos(
  AppDatabase db, {
  required int anioDraft,
  required Random random,
}) async {
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();
  // Los nombres se comparan contra TODOS los jugadores, retirados
  // incluidos: siguen en la base (palmarés, Hall of Fame, camisetas), así
  // que reutilizar su nombre sería confuso además de romper la unicidad.
  final nombresUsados = (await db.select(db.jugadores).get())
      .map((j) => j.nombreFicticio)
      .toSet();

  final porEquipo = <String, List<Jugador>>{};
  for (final j in jugadores) {
    if (!esFranquicia(j.equipo)) continue;
    porEquipo.putIfAbsent(j.equipo, () => []).add(j);
  }

  for (final entry in porEquipo.entries) {
    for (final puesto in posicionesEquipo) {
      var comodos = entry.value.where((j) => juegaComodoDe(j, puesto)).length;
      while (comodos < 2) {
        final ficha = generarClaseDeDraft(
          anioDraft: anioDraft,
          cantidad: 1,
          nombresYaUsados: nombresUsados,
          calidadFija: 1.0,
          posicionFija: puesto,
          random: random,
        ).single;
        nombresUsados.add(ficha.companion.nombreFicticio.value);
        await db.into(db.jugadores).insert(
            ficha.companion.copyWith(equipo: Value(entry.key)));
        comodos++;
      }
    }
  }
}

/// Deja libre (equipo 'FA') a los peores de cada plantilla que pase de
/// [plantillaMaxima]. Sin este recorte las plantillas crecerían sin freno
/// temporada tras temporada (el draft da 2 al año y las retiradas se llevan
/// menos de 2 de media).
///
/// Nunca corta a alguien si con eso un puesto se quedaría con menos de dos
/// jugadores cómodos: prefiere mantener a un suplente flojo antes que dejar
/// al equipo sin recambio en una posición.
///
/// Y dentro de eso se corta en tres tandas: primero quien acaba contrato,
/// después quien tiene años garantizados y, solo como último recurso, la
/// clase de draft de [claseDelDraft] — al que acabas de elegir no lo sueltas
/// antes de verlo jugar.
///
/// Cortando solo por media, el primero de la lista era siempre el rookie
/// recién drafteado (es el peor de la plantilla el día que llega), así que
/// la hornada se deshacía el mismo verano que entraba: medido a 8
/// temporadas, 23 de cada 60 elegidos se quedaban sin equipo sin haber
/// jugado un partido. Ningún equipo suelta a una primera ronda con años
/// garantizados por delante para quedarse con un veterano al que le queda
/// uno.
Future<List<String>> recortarPlantillasLargas(
  AppDatabase db, {
  int? claseDelDraft,
}) async {
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();

  final porEquipo = <String, List<Jugador>>{};
  for (final j in jugadores) {
    if (!esFranquicia(j.equipo)) continue;
    porEquipo.putIfAbsent(j.equipo, () => []).add(j);
  }

  final cortados = <String>[];
  for (final entry in porEquipo.entries) {
    final quedan = [...entry.value]..sort((a, b) {
        final porTanda = tandaDeCorte(a, claseDelDraft: claseDelDraft)
            .compareTo(tandaDeCorte(b, claseDelDraft: claseDelDraft));
        return porTanda != 0 ? porTanda : a.media.compareTo(b.media);
      });
    for (final candidato in [...quedan]) {
      if (quedan.length <= plantillaMaxima) break;

      final sinEl = quedan.where((j) => j.id != candidato.id).toList();
      final dejaHueco = posicionesEquipo.any(
          (puesto) => sinEl.where((j) => juegaComodoDe(j, puesto)).length < 2);
      if (dejaHueco) continue;

      await (db.update(db.jugadores)..where((t) => t.id.equals(candidato.id)))
          .write(const JugadoresCompanion(equipo: Value(equipoAgenciaLibre)));
      quedan.removeWhere((j) => j.id == candidato.id);
      cortados.add(candidato.nombreFicticio);
    }
  }
  return cortados;
}

/// En qué tanda entra [j] cuando un equipo tiene que soltar a alguien:
/// cuanto más bajo, antes se le corta. Primero quien acaba contrato,
/// después quien tiene años garantizados y, si se pasa [claseDelDraft], en
/// último lugar los recién elegidos ese año.
///
/// Lo comparte todo el que suelta gente en verano —[recortarPlantillasLargas]
/// y el hueco que abre la agencia libre para colocar a una estrella— porque
/// el criterio tiene que ser el mismo: si uno respeta los contratos y el
/// otro no, la clase de draft se cae igual por la puerta de atrás.
///
/// A estas alturas del verano los contratos ya se han descontado y los
/// vencidos están resueltos, así que `aniosContrato > 1` es exactamente "le
/// quedan años garantizados después de este".
int tandaDeCorte(Jugador j, {int? claseDelDraft}) {
  if (claseDelDraft != null && j.draftYear == claseDelDraft) return 2;
  return j.aniosContrato > 1 ? 1 : 0;
}

/// Completa la plantilla de un único equipo con jugadores generados hasta
/// que llegue al mínimo y tenga los 5 puestos cubiertos.
///
/// Es la red de seguridad de la agencia libre: si el mercado se ha quedado
/// seco (carrera muy larga, o te has quedado corto y ya no hay agentes
/// libres útiles), un equipo no puede quedarse sin poder alinear.
Future<void> generarRellenoDeUrgencia(
  AppDatabase db,
  String equipo, {
  Random? random,
}) async {
  final rng = random ?? Random();
  final anioDraft = (await (db.select(db.temporada)..where((t) => t.id.equals(0)))
              .getSingleOrNull())
          ?.anioInicio ??
      DateTime.now().year;

  Future<List<Jugador>> plantilla() => (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo) & t.retirado.equals(false)))
      .get();

  var actual = await plantilla();
  var nombresUsados = (await db.select(db.jugadores).get())
      .map((j) => j.nombreFicticio)
      .toSet();

  Future<void> fichar(String? puesto) async {
    final ficha = generarClaseDeDraft(
      anioDraft: anioDraft,
      cantidad: 1,
      nombresYaUsados: nombresUsados,
      calidadFija: 1.0,
      posicionFija: puesto,
      random: rng,
    ).single;
    nombresUsados.add(ficha.companion.nombreFicticio.value);
    await db.into(db.jugadores).insert(ficha.companion.copyWith(
          equipo: Value(equipo),
          salario: const Value(salarioMinimo),
          aniosContrato: const Value(1),
        ));
    actual = await plantilla();
  }

  for (final puesto in posicionesEquipo) {
    while (actual.where((j) => juegaComodoDe(j, puesto)).length < 2) {
      await fichar(puesto);
    }
  }
  while (actual.length < plantillaMinima) {
    await fichar(null);
  }
}

/// Rellena con no drafteados cualquier plantilla que se haya quedado por
/// debajo de [plantillaMinima]. Sin esto, una racha de retiradas en el
/// mismo equipo lo dejaría sin poder cubrir los 10 huecos de la rotación.
Future<void> _completarPlantillasCortas(
  AppDatabase db, {
  required int anioDraft,
  required Random random,
}) async {
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();

  final porEquipo = <String, int>{};
  for (final j in jugadores) {
    if (!esFranquicia(j.equipo)) continue;
    porEquipo[j.equipo] = (porEquipo[j.equipo] ?? 0) + 1;
  }

  // Los nombres se comparan contra TODOS los jugadores, retirados
  // incluidos: siguen en la base (palmarés, Hall of Fame, camisetas), así
  // que reutilizar su nombre sería confuso además de romper la unicidad.
  final nombresUsados = (await db.select(db.jugadores).get())
      .map((j) => j.nombreFicticio)
      .toSet();
  for (final entry in porEquipo.entries) {
    final faltan = plantillaMinima - entry.value;
    if (faltan <= 0) continue;

    // Se generan como si fuesen el final del draft: jugadores de rotación
    // corta, sin techo de estrella.
    final relleno = generarClaseDeDraft(
      anioDraft: anioDraft,
      cantidad: faltan,
      nombresYaUsados: nombresUsados,
      calidadFija: 1.0,
      random: random,
    );
    for (final p in relleno) {
      nombresUsados.add(p.companion.nombreFicticio.value);
      await db.into(db.jugadores).insert(
          p.companion.copyWith(equipo: Value(entry.key)));
    }
  }
}
