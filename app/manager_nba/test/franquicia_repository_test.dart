import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/posiciones.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('leerEquipoFranquicia es null antes de crear franquicia', () async {
    expect(await leerEquipoFranquicia(db), isNull);
  });

  test('empezar una partida no manda a la agencia libre a nadie que tuviera '
      'equipo: en el año 1 solo son agentes libres los que ya lo eran',
      () async {
    final conEquipo = (await db.select(db.jugadores).get())
        .where((j) => j.equipo != equipoAgenciaLibre)
        .map((j) => j.id)
        .toSet();
    expect(conEquipo, isNotEmpty);

    await crearFranquicia(db, 'DEN');

    final librespuesDeCrear = (await (db.select(db.jugadores)
              ..where((t) => t.equipo.equals(equipoAgenciaLibre)))
            .get())
        .map((j) => j.id)
        .toSet();

    expect(librespuesDeCrear.intersection(conEquipo), isEmpty,
        reason: 'recortar las plantillas grandes al crear la partida metía '
            'en la agencia libre a decenas de jugadores que en la vida real '
            'están bajo contrato');
  });

  test(
      'crearFranquicia guarda el equipo y genera la temporada de los 30 '
      'equipos (82 partidos cada uno) + 3 eventos + resultado inicial',
      () async {
    await crearFranquicia(db, 'DEN');

    expect(await leerEquipoFranquicia(db), 'DEN');
    final partidos = await db.select(db.partidosCalendario).get();
    final eventos = await db.select(db.eventosTemporada).get();
    final resultados = await db.select(db.resultadoTemporada).get();

    expect(partidos.length, 30 * 82);
    expect(
      partidos.where((p) => p.equipoPropietario == 'DEN').length,
      82,
    );
    expect(eventos.length, 3);
    expect(resultados.length, 30);
    expect(resultados.every((r) => r.victorias == 0 && r.derrotas == 0),
        isTrue);
  });

  test('crearFranquicia es idempotente: llamarla dos veces no revienta por '
      'la clave única de ResultadoTemporada', () async {
    await crearFranquicia(db, 'DEN');
    await crearFranquicia(db, 'DEN');

    expect(await leerEquipoFranquicia(db), 'DEN');
    final resultados = await db.select(db.resultadoTemporada).get();
    expect(resultados.length, 30);
    final partidos = await db.select(db.partidosCalendario).get();
    expect(partidos.length, 30 * 82);
  });

  test('generarRotacionAutomatica rellena los 10 huecos con los mejores '
      'disponibles y prioriza la posición real de cada uno', () async {
    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('DEN')))
        .get();

    final filas = generarRotacionAutomatica(plantilla);
    expect(filas.length, 10);

    final idsUsados = filas.map((f) => f.jugadorId.value).toSet();
    expect(idsUsados.length, 10); // nadie se repite en dos huecos

    final plantillaPorId = {for (final j in plantilla) j.id: j};
    for (final posicion in posicionesEquipo) {
      final delPuesto =
          filas.where((f) => f.posicion.value == posicion).toList();
      expect(delPuesto.length, 2); // titular + suplente

      final minutos = delPuesto.map((f) => f.minutos.value).toSet();
      expect(delPuesto[0].minutos.value + delPuesto[1].minutos.value, 48);
      expect(minutos.length, 2); // titular y suplente con minutos distintos
    }

    // Con datos reales (582 jugadores repartidos en 30 equipos) cada
    // plantilla suele traer de sobra jugadores de cada posición real, así
    // que lo normal es que titular y suplente jueguen en su puesto.
    final fueraDePosicion = filas
        .where((f) => plantillaPorId[f.jugadorId.value]!.posicion != f.posicion.value)
        .length;
    expect(fueraDePosicion, lessThan(5));
  });

  Future<List<Jugador>> plantillaDe(String equipo) => (db.select(db.jugadores)
        ..where((t) => t.equipo.equals(equipo)))
      .get();

  test('el reparto por puestos no deja en el banquillo a nadie que rindiera '
      'más en ese puesto: manda el nivel, no la etiqueta', () async {
    for (final equipo in ['DEN', 'LAL', 'BOS', 'GSW', 'MIA']) {
      final plantilla = await plantillaDe(equipo);
      final porPuesto = repartirPorPuestos(plantilla);
      final asignados = {
        for (final p in posicionesEquipo)
          for (final j in porPuesto[p]!) j.id,
      };
      final enElBanquillo =
          plantilla.where((j) => !asignados.contains(j.id)).toList();

      double rinde(Jugador j, String puesto) =>
          j.media * factorDePuesto(j, puesto);

      for (final posicion in posicionesEquipo) {
        for (final jugador in porPuesto[posicion]!) {
          for (final suplente in enElBanquillo) {
            expect(rinde(suplente, posicion),
                lessThanOrEqualTo(rinde(jugador, posicion)),
                reason: '$equipo: ${suplente.nombreFicticio} '
                    '(${etiquetaPosicion(suplente)}, media ${suplente.media}) '
                    'rendiría más de $posicion que '
                    '${jugador.nombreFicticio} '
                    '(${etiquetaPosicion(jugador)}, media ${jugador.media}) '
                    'y se ha quedado fuera');
          }
        }
      }
    }
  });

  test('un base-escolta de 80 no se queda sin convocar mientras un base de '
      '71 sale de suplente', () async {
    // El caso tal y como lo contó el usuario. Se monta a mano una plantilla
    // de 12 con los dos protagonistas y diez jugadores de relleno repartidos
    // por los cinco puestos, para que haya competencia real por los huecos.
    final reales = await plantillaDe('DEN');
    Jugador conFicha(int i, int media, String posicion, String? secundaria) =>
        reales[i].copyWith(
            media: media,
            posicion: posicion,
            posicionSecundaria: Value(secundaria));

    final estrellaDelBanquillo = conFicha(0, 80, 'PG', 'SG');
    final baseFlojo = conFicha(1, 71, 'PG', 'SG');
    final plantilla = [
      estrellaDelBanquillo,
      baseFlojo,
      conFicha(2, 88, 'PG', 'SG'), // los dos bases que sí son mejores que él
      conFicha(3, 84, 'PG', 'SG'),
      conFicha(4, 83, 'SG', 'SF'), // y los dos escoltas, también
      conFicha(5, 82, 'SG', 'PG'),
      conFicha(6, 79, 'SF', 'PF'),
      conFicha(7, 75, 'SF', 'SG'),
      conFicha(8, 78, 'PF', 'C'),
      conFicha(9, 74, 'PF', 'SF'),
      conFicha(10, 77, 'C', 'PF'),
      conFicha(11, 70, 'C', 'PF'),
    ];

    final filas = generarRotacionAutomatica(plantilla);
    final convocados = filas.map((f) => f.jugadorId.value).toSet();

    expect(convocados, contains(estrellaDelBanquillo.id),
        reason: 'con los cinco puestos cogidos por bases y escoltas mejores '
            'que él, al de 80 le toca jugar fuera de su sitio — pero entra, '
            'porque hasta penalizado (72) rinde más que cualquiera de los '
            'que se quedarían fuera');
    expect(convocados, isNot(contains(baseFlojo.id)),
        reason: 'el de 71 es justo el que sobra');
  });

  test('un natural conserva su puesto frente a alguien de fuera solo algo '
      'mejor, pero no frente a uno mucho mejor', () async {
    final plantilla = await plantillaDe('DEN');
    final base = plantilla.firstWhere((j) => j.posicion == 'PG');

    // Alguien que no es base y que rinde MENOS de PG que el base natural
    // (aun con su media más alta) no le quita el sitio.
    final algoMejor = plantilla.firstWhere(
        (j) => !juegaComodoDe(j, 'PG') && j.media > base.media,
        orElse: () => base);
    if (!identical(algoMejor, base) &&
        algoMejor.media * factorFueraDePosicion < base.media) {
      final reparto = repartirPorPuestos([base, algoMejor], porPuesto: 1);
      expect(reparto['PG']!.single.id, base.id);
    }

    // Y al revés: uno lo bastante mejor sí entra de PG.
    final muchoMejor = plantilla.firstWhere(
        (j) => !juegaComodoDe(j, 'PG') && j.media * factorFueraDePosicion > base.media,
        orElse: () => base);
    if (!identical(muchoMejor, base)) {
      final reparto = repartirPorPuestos([base, muchoMejor], porPuesto: 1);
      expect(reparto['PG']!.single.id, muchoMejor.id);
    }
  });

  test('generarRotacionAutomatica marca a las dos estrellas, igual que hace '
      'la CPU en cada partido', () async {
    // El bug que hundía el récord: la rotación se generaba sin ninguna
    // estrella marcada (esEstrellaAtaque/esEstrellaDefensa a false), pero
    // los 29 equipos de la CPU sí salen siempre con las suyas (ver
    // generarAlineacionAutomatica). Con la MISMA plantilla en los dos lados,
    // esa diferencia valía por sí sola unas 8 victorias por temporada: el
    // enfrentamiento directo pasaba del 50% al 40%.
    for (final equipo in ['DEN', 'LAL', 'CLE']) {
      final plantilla = await plantillaDe(equipo);
      final filas = generarRotacionAutomatica(plantilla);

      final ataque =
          filas.where((f) => f.esEstrellaAtaque.value).toList();
      final defensa =
          filas.where((f) => f.esEstrellaDefensa.value).toList();
      expect(ataque, hasLength(1), reason: '$equipo: una estrella de ataque');
      expect(defensa, hasLength(1), reason: '$equipo: una estrella de defensa');
      expect(ataque.first.jugadorId.value,
          isNot(defensa.first.jugadorId.value),
          reason: 'no puede ser la misma persona las dos');

      // Y son los dos mejores de los que entran en la rotación.
      final porId = {for (final j in plantilla) j.id: j};
      final mediasEnRotacion = filas
          .map((f) => porId[f.jugadorId.value]!.media)
          .toList()
        ..sort((a, b) => b.compareTo(a));
      expect(porId[ataque.first.jugadorId.value]!.media, mediasEnRotacion[0]);
      expect(porId[defensa.first.jugadorId.value]!.media, mediasEnRotacion[1]);
    }
  });

  test('generarRotacionAutomatica no manda a nadie fuera de su sitio '
      'teniendo natural disponible, y cubre los 10 huecos', () async {
    final plantilla = await plantillaDe('DEN');
    final filas = generarRotacionAutomatica(plantilla);
    expect(filas.length, 10);

    final porId = {for (final j in plantilla) j.id: j};
    final fueraDeSitio = filas
        .where((f) => !juegaComodoDe(porId[f.jugadorId.value]!,
            f.posicion.value))
        .length;
    // Con plantillas reales de 14+ jugadores siempre hay natural o segunda
    // posición para los diez huecos.
    expect(fueraDeSitio, 0);
  });

  test('guardarRotacion + leerRotacion + rotacionEstaCompleta', () async {
    final plantilla = await plantillaDe('DEN');
    expect(plantilla.length, greaterThanOrEqualTo(10));

    // Toma 2 jugadores cualesquiera por puesto (no hace falta que jueguen
    // ahí de verdad: es justo lo que se está testeando más abajo).
    final filas = <RotacionJugadorCompanion>[];
    for (var i = 0; i < posicionesEquipo.length; i++) {
      final posicion = posicionesEquipo[i];
      final titular = plantilla[i * 2];
      final suplente = plantilla[i * 2 + 1];
      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: true,
        jugadorId: titular.id,
        minutos: 32,
      ));
      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: false,
        jugadorId: suplente.id,
        minutos: 16,
      ));
    }

    expect(rotacionEstaCompleta(await leerRotacion(db)), isFalse);
    await guardarRotacion(db, filas);
    final leida = await leerRotacion(db);
    expect(leida.length, 10);
    expect(rotacionEstaCompleta(leida), isTrue);
  });

  test('repararRotacion conserva la suma de 48 minutos por puesto cuando '
      'solo se traspasa a la mitad del par (titular o suplente), no a los '
      'dos', () async {
    final plantilla = await plantillaDe('DEN');

    // Minutos asimétricos a propósito en PG (28/20 en vez del 32/16 por
    // defecto): así, si el arreglo usara un valor fijo para el sustituto en
    // vez del complemento real, se notaría enseguida en la suma.
    final filas = <RotacionJugadorCompanion>[];
    final usados = <int>{};
    for (final posicion in posicionesEquipo) {
      final titular = plantilla.firstWhere(
          (j) => j.posicion == posicion && !usados.contains(j.id));
      usados.add(titular.id);
      final suplente = plantilla.firstWhere(
        (j) => j.posicion == posicion && !usados.contains(j.id),
        orElse: () => plantilla.firstWhere((j) => !usados.contains(j.id)),
      );
      usados.add(suplente.id);

      final minutosTitular = posicion == 'PG' ? 28 : 32;
      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: true,
        jugadorId: titular.id,
        minutos: minutosTitular,
      ));
      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: false,
        jugadorId: suplente.id,
        minutos: 48 - minutosTitular,
      ));
    }
    await guardarRotacion(db, filas);

    // "Traspasa" solo al titular de PG: se va del equipo, su suplente se
    // queda con sus 20 minutos personalizados intactos.
    final titularPg = filas.firstWhere(
        (f) => f.posicion.value == 'PG' && f.esTitular.value);
    await (db.update(db.jugadores)
          ..where((t) => t.id.equals(titularPg.jugadorId.value)))
        .write(const JugadoresCompanion(equipo: Value('FA')));

    final cambio = await repararRotacion(db, 'DEN');
    expect(cambio, isTrue);

    final leida = await leerRotacion(db);
    expect(rotacionEstaCompleta(leida), isTrue);
    expect(leida.fold<int>(0, (a, f) => a + f.minutos), 240);
    for (final posicion in posicionesEquipo) {
      final delPuesto = leida.where((f) => f.posicion == posicion);
      expect(delPuesto.fold<int>(0, (a, f) => a + f.minutos), 48,
          reason: '$posicion no suma 48 tras reparar la rotación');
    }
  });

  test('repararRotacion pone de titular al que entra si rinde más que el que '
      'se queda: un 87 no puede acabar de suplente detrás de un 81', () async {
    final plantilla = await plantillaDe('DEN');
    await guardarRotacion(db, generarRotacionAutomatica(plantilla));

    final rotacionInicial = await leerRotacion(db);
    final enRotacion = rotacionInicial.map((f) => f.jugadorId).toSet();
    final titularSg = rotacionInicial
        .firstWhere((f) => f.posicion == 'SG' && f.esTitular);
    final suplenteSg = rotacionInicial
        .firstWhere((f) => f.posicion == 'SG' && !f.esTitular);

    // El titular de escolta se queda en 81...
    await (db.update(db.jugadores)..where((t) => t.id.equals(titularSg.jugadorId)))
        .write(const JugadoresCompanion(media: Value(81)));

    // ...y fuera de la rotación espera un escolta/alero de 87. Al resto del
    // banquillo se le baja la media para que no haya duda de quién es el
    // mejor disponible.
    final banquillo =
        plantilla.where((j) => !enRotacion.contains(j.id)).toList();
    expect(banquillo, isNotEmpty);
    final elDe87 = banquillo.first;
    await (db.update(db.jugadores)..where((t) => t.id.equals(elDe87.id))).write(
        const JugadoresCompanion(
            media: Value(87),
            posicion: Value('SG'),
            posicionSecundaria: Value('SF')));
    for (final otro in banquillo.skip(1)) {
      await (db.update(db.jugadores)..where((t) => t.id.equals(otro.id)))
          .write(const JugadoresCompanion(media: Value(60)));
    }

    // Se traspasa al suplente de escolta: el hueco que queda libre es el de
    // suplente, y ahí es donde antes se metía al 87 sin mirar a quién tenía
    // por delante.
    await (db.update(db.jugadores)
          ..where((t) => t.id.equals(suplenteSg.jugadorId)))
        .write(const JugadoresCompanion(equipo: Value(equipoAgenciaLibre)));

    expect(await repararRotacion(db, 'DEN'), isTrue);

    final leida = await leerRotacion(db);
    expect(rotacionEstaCompleta(leida), isTrue);
    expect(leida.fold<int>(0, (a, f) => a + f.minutos), 240);

    final nuevoTitular =
        leida.firstWhere((f) => f.posicion == 'SG' && f.esTitular);
    final nuevoSuplente =
        leida.firstWhere((f) => f.posicion == 'SG' && !f.esTitular);
    expect(nuevoTitular.jugadorId, elDe87.id,
        reason: 'el mejor disponible del puesto tiene que ser el titular');
    expect(nuevoSuplente.jugadorId, titularSg.jugadorId,
        reason: 'el 81 baja al banquillo, no se queda de titular');
    // Y los minutos siguen siendo los del rol, no los de la persona.
    expect(nuevoTitular.minutos, minutosPorDefectoTitular);
    expect(nuevoSuplente.minutos, 48 - minutosPorDefectoTitular);
  });

  test('repararRotacion elige al mejor disponible por rendimiento, no por la '
      'etiqueta de la posición', () async {
    final plantilla = await plantillaDe('DEN');
    await guardarRotacion(db, generarRotacionAutomatica(plantilla));

    final rotacionInicial = await leerRotacion(db);
    final enRotacion = rotacionInicial.map((f) => f.jugadorId).toSet();
    final titularC = rotacionInicial
        .firstWhere((f) => f.posicion == 'C' && f.esTitular);

    final banquillo =
        plantilla.where((j) => !enRotacion.contains(j.id)).toList();
    expect(banquillo.length, greaterThanOrEqualTo(2));

    // Un base de 90 (que de pívot rinde 81) contra un pívot natural de 70.
    final baseCrack = banquillo[0];
    final pivotFlojo = banquillo[1];
    await (db.update(db.jugadores)..where((t) => t.id.equals(baseCrack.id)))
        .write(const JugadoresCompanion(
            media: Value(90),
            posicion: Value('PG'),
            posicionSecundaria: Value('SG')));
    await (db.update(db.jugadores)..where((t) => t.id.equals(pivotFlojo.id)))
        .write(const JugadoresCompanion(
            media: Value(70),
            posicion: Value('C'),
            posicionSecundaria: Value('PF')));
    for (final otro in banquillo.skip(2)) {
      await (db.update(db.jugadores)..where((t) => t.id.equals(otro.id)))
          .write(const JugadoresCompanion(media: Value(50)));
    }

    // Se va el titular de pívot; el suplente que había sigue ahí.
    await (db.update(db.jugadores)..where((t) => t.id.equals(titularC.jugadorId)))
        .write(const JugadoresCompanion(equipo: Value(equipoAgenciaLibre)));

    expect(await repararRotacion(db, 'DEN'), isTrue);

    final leida = await leerRotacion(db);
    final delPuesto = leida.where((f) => f.posicion == 'C').toList();
    expect(delPuesto.map((f) => f.jugadorId), contains(baseCrack.id),
        reason: '90 fuera de sitio rinde 81, más que los 70 del pívot natural');
    expect(delPuesto.map((f) => f.jugadorId), isNot(contains(pivotFlojo.id)));
  });

  test('construirEquipoUsuario gradúa el rendimiento según el puesto: pleno '
      'en su posición natural, casi pleno en la segunda, y penalizado solo '
      'si lo pones donde no juega', () async {
    final plantilla = await plantillaDe('DEN');

    // Fuerza a que el titular de PG sea alguien que no puede jugar ahí ni
    // de primera ni de segunda, para provocar el caso "fuera de posición"
    // de forma determinista.
    //
    // Se coge de un puesto con excedente: sacándolo de su sitio hacen falta
    // otros dos de su posición para el titular y el suplente de más abajo.
    // Sin esa condición el test dependía de cómo estuviera compuesto DEN en
    // el dataset — al actualizarlo contra 2kratings.com el elegido resultó
    // ser el único pívot del equipo y la rotación ya no se podía montar.
    final porPosicion = <String, int>{};
    for (final j in plantilla) {
      porPosicion[j.posicion] = (porPosicion[j.posicion] ?? 0) + 1;
    }
    final jugadorFueraDePosicion = plantilla.firstWhere((j) =>
        !juegaComodoDe(j, 'PG') && (porPosicion[j.posicion] ?? 0) > 2);

    final filas = <RotacionJugadorCompanion>[];
    final usados = <int>{};
    for (final posicion in posicionesEquipo) {
      final titular = posicion == 'PG'
          ? jugadorFueraDePosicion
          : plantilla.firstWhere(
              (j) => j.posicion == posicion && !usados.contains(j.id));
      usados.add(titular.id);
      // Para el suplente, intenta también un jugador de esa posición
      // natural (para no meter penalizaciones "sin querer" que
      // contaminen la aserción de más abajo); si el equipo no tiene un
      // segundo jugador de ese puesto, coge cualquiera que quede.
      final suplente = plantilla.firstWhere(
        (j) => j.posicion == posicion && !usados.contains(j.id),
        orElse: () => plantilla.firstWhere((j) => !usados.contains(j.id)),
      );
      usados.add(suplente.id);

      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: true,
        jugadorId: titular.id,
        minutos: 32,
      ));
      filas.add(RotacionJugadorCompanion.insert(
        posicion: posicion,
        esTitular: false,
        jugadorId: suplente.id,
        minutos: 16,
      ));
    }

    await guardarRotacion(db, filas);
    final equipo =
        await construirEquipoUsuarioParaFecha(db, 'DEN', DateTime(2026, 10, 21));

    expect(equipo.jugadores.length, 10);
    expect(
      equipo.jugadores.fold<int>(0, (a, j) => a + j.minutos),
      240,
    );

    final jep = equipo.jugadores
        .firstWhere((j) => j.jugador.id == jugadorFueraDePosicion.id.toString());
    expect(jep.penalizacionFueraDePosicion, factorFueraDePosicion);

    // El resto de huecos lleva exactamente el factor que le toca según su
    // posición natural / segunda posición — se recalcula aquí en vez de
    // asumir nada, porque con datos reales no todos los equipos tienen dos
    // jugadores de cada puesto.
    final plantillaPorId = {for (final j in plantilla) j.id: j};
    final filasPorJugadorId = {for (final f in filas) f.jugadorId.value: f};
    for (final j in equipo.jugadores) {
      final id = int.parse(j.jugador.id);
      final fila = filasPorJugadorId[id]!;
      expect(
        j.penalizacionFueraDePosicion,
        factorDePuesto(plantillaPorId[id]!, fila.posicion.value),
        reason: 'jugador $id en puesto ${fila.posicion.value}',
      );
    }
  });
}
