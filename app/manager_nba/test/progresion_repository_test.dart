import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/domain/progresion_repository.dart';

/// Un veterano de laboratorio, listo para empezar a declinar (30 años, un
/// año más y entra en la zona de declive).
JugadoresCompanion _veterano({
  required String nombre,
  required int edad,
  int media = 90,
  double factorLongevidad = 1.0,
  int? potencial,
}) {
  return JugadoresCompanion.insert(
    nombreFicticio: nombre,
    nombreReal: '',
    posicion: 'SF',
    equipo: 'LAL',
    edad: edad,
    media: media,
    potencial: potencial ?? media,
    atrTiro3: media,
    atrAtaque: media,
    atrDefensa: media,
    ptsPg: 25,
    astPg: 5,
    trbPg: 6,
    factorLongevidad: factorLongevidad,
    edadRetiro: 45,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Caso real que reportó el usuario: Isaac Jones (media 65, potencial 45,
  /// 25 años) perdía 20 puntos de media en un solo verano. El potencial del
  /// dataset viene por debajo de la media en 396 de los 641 jugadores, y el
  /// código lo usaba como techo duro (`min(potencial, ...)`), así que en vez
  /// de frenar el crecimiento hundía al jugador hasta ese número.
  test('un potencial por debajo de la media no hunde al jugador: como mucho '
      'deja de crecer', () async {
    final casos = [
      // (edad, media, potencial) — joven, en plenitud y ya en declive.
      (25, 65, 45),
      (28, 70, 40),
      (33, 68, 42),
    ];

    for (final (edad, media, potencial) in casos) {
      final id = await db.into(db.jugadores).insert(_veterano(
          nombre: 'Caso $edad', edad: edad, media: media, potencial: potencial));

      await envejecerLiga(db, random: Random(3));

      final despues =
          await (db.select(db.jugadores)..where((t) => t.id.equals(id)))
              .getSingle();
      final caida = media - despues.media;
      expect(caida, lessThanOrEqualTo(8),
          reason: 'con $edad años, media $media y potencial $potencial ha '
              'perdido $caida puntos de golpe');
      expect(despues.media, greaterThan(potencial),
          reason: 'no puede desplomarse hasta su potencial');
    }
  });

  /// Antes de la corrección, la caída de un solo año se multiplicaba por
  /// los años que llevaba en declive: una estrella que seguía jugando a los
  /// 38-40 podía perder 10-13 puntos de golpe en una sola temporada (un
  /// LeBron que baja 12 puntos de un año para otro). Se prueba envejeciendo
  /// al mismo jugador uno por uno hasta los 40 y comprobando que ningún
  /// salto de un año es descontrolado.
  test('el declive de un veterano longevo nunca pega un salto grande en un '
      'solo año, ni siquiera muy mayor', () async {
    final id = await db.into(db.jugadores).insert(
        _veterano(nombre: 'Veterano De Prueba', edad: 30, media: 95));

    final rng = Random(11);
    var caidaMaxima = 0;
    for (var edad = 30; edad < 40; edad++) {
      final antes =
          await (db.select(db.jugadores)..where((t) => t.id.equals(id)))
              .getSingle();
      await envejecerLiga(db, random: rng);
      final despues =
          await (db.select(db.jugadores)..where((t) => t.id.equals(id)))
              .getSingle();
      if (despues.retirado) break;

      final caida = antes.media - despues.media;
      if (caida > caidaMaxima) caidaMaxima = caida;
    }

    expect(caidaMaxima, lessThanOrEqualTo(6),
        reason: 'ningún año debería llevarse más de un puñado de puntos');
  });

  test('la intensidad del declive se estabiliza en vez de crecer sin '
      'límite con la edad', () async {
    // Dos copias del mismo jugador: una se envejece de golpe hasta los 36
    // (declive "reciente") y la otra hasta los 42 (declive "de toda la
    // vida"). Si el declive estuviera acotado, la caída del último año no
    // debería ser muy distinta entre ambas.
    final idReciente = await db.into(db.jugadores).insert(
        _veterano(nombre: 'Reciente', edad: 34, media: 90));
    final idLargo = await db.into(db.jugadores).insert(
        _veterano(nombre: 'Largo', edad: 40, media: 70));

    // Se envejece toda la liga a la vez (una sola llamada mueve a los dos),
    // así que se leen antes/después para cada uno con la misma tirada.
    final antesReciente = (await (db.select(db.jugadores)
              ..where((t) => t.id.equals(idReciente)))
            .getSingle())
        .media;
    final antesLargo = (await (db.select(db.jugadores)
              ..where((t) => t.id.equals(idLargo)))
            .getSingle())
        .media;
    await envejecerLiga(db, random: Random(3));
    final despuesReciente = (await (db.select(db.jugadores)
              ..where((t) => t.id.equals(idReciente)))
            .getSingle())
        .media;
    final despuesLargo = (await (db.select(db.jugadores)
              ..where((t) => t.id.equals(idLargo)))
            .getSingle())
        .media;

    final caidaReciente = antesReciente - despuesReciente;
    final caidaLarga = antesLargo - despuesLargo;

    expect((caidaLarga - caidaReciente).abs(), lessThanOrEqualTo(3),
        reason: 'caidaReciente=$caidaReciente caidaLarga=$caidaLarga: la '
            'intensidad debería ser parecida, no disparada por los años '
            'acumulados de declive');
  });

  group('a los mejores no los retira el calendario', () {
    /// El caso del usuario: LeBron y Durant colgando las botas con media 92
    /// porque el sorteo de edad de retiro (34-42, sin mirar el nivel) les
    /// había tocado corto.
    Future<Jugador> tras(int anios, JugadoresCompanion ficha) async {
      final id = await db.into(db.jugadores).insert(ficha);
      for (var i = 0; i < anios; i++) {
        await envejecerLiga(db, random: Random(3));
      }
      return (db.select(db.jugadores)..where((t) => t.id.equals(id)))
          .getSingle();
    }

    /// La lista de retirados enseña con qué edad cuelga las botas cada uno,
    /// así que el cambio tiene que traer esa edad — y la de después de
    /// cumplir años, que es la de verdad: retirarse "con 38" cuando ya has
    /// cumplido 39 sería mentir por un año.
    test('el cambio de un retirado trae la edad con la que se retira',
        () async {
      final id = await db.into(db.jugadores).insert(
          _veterano(nombre: 'El Rey', edad: 41, media: 60)
              .copyWith(edadRetiro: const Value(36)));

      final cambios = await envejecerLiga(db, random: Random(3));
      final suyo = cambios.firstWhere((c) => c.jugadorId == id);

      expect(suyo.seRetira, isTrue);
      expect(suyo.edad, 42, reason: 'tenía 41 y el verano le suma uno');

      final enBd = await (db.select(db.jugadores)..where((t) => t.id.equals(id)))
          .getSingle();
      expect(suyo.edad, enBd.edad,
          reason: 'la edad del cambio y la guardada tienen que coincidir');
    });

    test('un 92 con la edad de retiro cumplida sigue jugando', () async {
      final ficha = _veterano(nombre: 'El Rey', edad: 41, media: 92)
          .copyWith(edadRetiro: const Value(36));

      final despues = await tras(1, ficha);
      expect(despues.retirado, isFalse,
          reason: 'nadie deja el baloncesto siendo de los diez mejores');
      expect(despues.edad, 42);
    });

    test('cuando el declive lo baja de la línea, entonces sí se retira',
        () async {
      final ficha = _veterano(nombre: 'El Rey', edad: 38, media: 92)
          .copyWith(edadRetiro: const Value(36));

      final despues = await tras(8, ficha);
      expect(despues.retirado, isTrue);
      // Se va cuando ya no es lo que era. La media que queda guardada es la
      // de su última temporada, así que puede rondar la línea por arriba;
      // lo que no puede es haberse ido siendo aún un 92.
      expect(despues.media, lessThan(90),
          reason: 'no se retira en su mejor momento');
      expect(despues.edad, greaterThan(ficha.edadRetiro.value),
          reason: 'ha jugado más años de los que le tocaban');
      expect(despues.edad, lessThanOrEqualTo(edadMaximaEnActivo + 1),
          reason: 'y no hay carreras eternas');
    });

    test('a uno normal le sigue tocando su edad de retiro', () async {
      final ficha = _veterano(nombre: 'Rotación', edad: 36, media: 72)
          .copyWith(edadRetiro: const Value(36));

      expect((await tras(1, ficha)).retirado, isTrue);
    });
  });


  test('a veces un joven no mejora nada en el verano: el potencial no se '
      'alcanza siempre', () async {
    // Lo que se pidió arreglar (lista parte 11, punto 22): antes el salto
    // anual era siempre positivo, sin ni una excepción posible antes de
    // los 27 años. Con hasta ocho veranos de margen, casi cualquiera
    // acababa cerca de su potencial — no había sitio para un bust de
    // verdad, uno de esos prospectos que simplemente no despega.
    var estancados = 0;
    const muestras = 200;
    for (var semilla = 0; semilla < muestras; semilla++) {
      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      final id = await db2.into(db2.jugadores).insert(
          _veterano(nombre: 'Proyecto', edad: 20, media: 65, potencial: 90));
      await envejecerLiga(db2, random: Random(semilla));
      final despues =
          await (db2.select(db2.jugadores)..where((t) => t.id.equals(id)))
              .getSingle();
      if (despues.media == 65) estancados++;
      await db2.close();
    }

    // La probabilidad de estancarse es probabilidadDeEstancarse (16%): con
    // 200 muestras el margen de sobra evita que el test sea frágil, pero
    // sigue exigiendo que el mecanismo exista de verdad.
    expect(estancados, greaterThan(0),
        reason: 'en 200 intentos, ni uno solo se ha estancado');
    expect(estancados / muestras, lessThan(0.30),
        reason: 'estancarse tiene que ser la excepción, no la norma');
  });
}