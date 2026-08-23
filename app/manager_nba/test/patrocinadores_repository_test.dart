import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/contratos_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/patrocinadores.dart';
import 'package:manager_nba/domain/patrocinadores_repository.dart';

/// Los patrocinios como CONTRATOS: qué marca, cuánto paga y cuántos años
/// dura. Lo que más se vigila es la caducidad, que es lo único que no se
/// ve en pantalla hasta un año después.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
  });

  tearDown(() => db.close());

  /// La oferta número [puesto] de esa categoría: 0 es la de un año, 1 la de
  /// dos y 2 la de cuatro (ver `aniosDeOferta`).
  OfertaDePatrocinio oferta(String categoria, {int puesto = 0}) =>
      ofertasDe('DEN', categoria, temporada: 1)[puesto];

  test('sin tocar nada, no hay ningún patrocinio activo', () async {
    expect(await leerPatrociniosActivos(db), isEmpty);
    expect(await bonusSalarialDePatrocinadores(db), 0);
  });
  group('una partida de antes del esquema 29', () {
    /// Mete una fila como las que dejaba el código viejo: solo la
    /// categoría, sin marca, sin dinero y sin años.
    ///
    /// Es lo que se encuentra al abrir una partida guardada con la versión
    /// anterior, cuando un patrocinio era un interruptor. No hay tests de
    /// migración en el proyecto, así que lo que se comprueba aquí es lo
    /// único que de verdad puede romperse: que esas filas se sigan
    /// leyendo.
    Future<void> filaVieja(String categoria) => db
        .into(db.patrociniosActivos)
        .insert(PatrociniosActivosCompanion.insert(categoria: categoria));

    test('se lee con el dinero fijo de su categoría y un año de duración',
        () async {
      await filaVieja('camiseta');

      final contrato = (await leerContratosDePatrocinio(db))['camiseta']!;
      expect(contrato.clave, isNull);
      expect(contrato.patrocinador, isNull);
      expect(contrato.bonusAnual, bonusPorCategoria['camiseta']);
      expect(contrato.aniosRestantes, 1);
    });

    test('sigue dando su margen', () async {
      await filaVieja('estadio');
      expect(await bonusSalarialDePatrocinadores(db),
          bonusPorCategoria['estadio']);
    });

    test('caduca sola en el primer cierre, como hacía antes', () async {
      await filaVieja('bebida');
      await caducarPatrocinios(db);
      expect(await leerPatrociniosActivos(db), isEmpty);
    });

    test('su compromiso se aplica igual: sale de la categoría, no de la '
        'marca', () async {
      await filaVieja('ocio');
      await aplicarCompromisosDePatrocinio(db);
      expect(await leerPatrociniosActivos(db), {'ocio'});
    });

    test('firmar encima la sustituye por un contrato completo', () async {
      await filaVieja('camiseta');
      final nueva = ofertasDe('DEN', 'camiseta', temporada: 1)[2];
      await firmarPatrocinio(db, nueva);

      final contrato = (await leerContratosDePatrocinio(db))['camiseta']!;
      expect(contrato.clave, nueva.patrocinador.clave);
      expect(contrato.aniosRestantes, nueva.anios);
    });
  });


  test('firmar una oferta ocupa su categoría, y romperla la libera',
      () async {
    await firmarPatrocinio(db, oferta('estadio'));
    expect(await leerPatrociniosActivos(db), {'estadio'});

    await romperPatrocinio(db, 'estadio');
    expect(await leerPatrociniosActivos(db), isEmpty);
  });

  test('firmar guarda qué marca, cuánto paga y cuántos años dura', () async {
    final elegida = oferta('camiseta', puesto: 2);
    await firmarPatrocinio(db, elegida);

    final contrato = (await leerContratosDePatrocinio(db))['camiseta']!;
    expect(contrato.clave, elegida.patrocinador.clave);
    expect(contrato.bonusAnual, elegida.bonusAnual);
    expect(contrato.aniosRestantes, elegida.anios);
    expect(contrato.patrocinador?.nombre, elegida.patrocinador.nombre);
  });

  test('firmar otra oferta de la misma categoría sustituye a la anterior, '
      'sin duplicar', () async {
    await firmarPatrocinio(db, oferta('camiseta'));
    await firmarPatrocinio(db, oferta('camiseta', puesto: 1));

    expect(await leerPatrociniosActivos(db), {'camiseta'});
    final contrato = (await leerContratosDePatrocinio(db))['camiseta']!;
    expect(contrato.clave, oferta('camiseta', puesto: 1).patrocinador.clave);
  });

  test('el bonus suma lo que prometió cada contrato, no el fijo de la '
      'categoría', () async {
    final unEstadio = oferta('estadio');
    final unOcio = oferta('ocio');
    await firmarPatrocinio(db, unEstadio);
    await firmarPatrocinio(db, unOcio);

    expect(await bonusSalarialDePatrocinadores(db),
        unEstadio.bonusAnual + unOcio.bonusAnual);
  });

  test('caducarPatrocinios descuenta un año y deja vivo lo que dura más',
      () async {
    // La de cuatro años. Va en 'bebida' y no en 'estadio' porque Denver
    // solo tiene dos marcas de estadio: ahí no hay tercera oferta.
    await firmarPatrocinio(db, oferta('bebida', puesto: 2));

    await caducarPatrocinios(db);

    final contrato = (await leerContratosDePatrocinio(db))['bebida'];
    expect(contrato, isNotNull,
        reason: 'un contrato de 4 años no caduca al año');
    expect(contrato!.aniosRestantes, 3);
  });

  test('un contrato de un año se va en el primer cierre', () async {
    await firmarPatrocinio(db, oferta('estadio'));
    expect(oferta('estadio').anios, 1);

    await caducarPatrocinios(db);

    expect(await leerPatrociniosActivos(db), isEmpty);
    expect(await bonusSalarialDePatrocinadores(db), 0);
  });

  test('uno de cuatro años aguanta cuatro cierres y se va al cuarto',
      () async {
    final larga = oferta('bebida', puesto: 2);
    expect(larga.anios, 4);
    await firmarPatrocinio(db, larga);

    for (var cierre = 1; cierre <= 3; cierre++) {
      await caducarPatrocinios(db);
      final contrato = (await leerContratosDePatrocinio(db))['bebida'];
      expect(contrato, isNotNull, reason: 'seguía vivo tras $cierre cierres');
      expect(contrato!.aniosRestantes, 4 - cierre);
      // Y sigue pagando lo mismo todos esos años.
      expect(await bonusSalarialDePatrocinadores(db), larga.bonusAnual);
    }

    await caducarPatrocinios(db);
    expect(await leerPatrociniosActivos(db), isEmpty);
  });

  test('caducar no toca las categorías vacías', () async {
    await caducarPatrocinios(db);
    expect(await leerPatrociniosActivos(db), isEmpty);
  });

  test('limpiarPatrocinios se lleva todo, caduque o no', () async {
    await firmarPatrocinio(db, oferta('camiseta', puesto: 2));
    await firmarPatrocinio(db, oferta('bebida', puesto: 2));

    await limpiarPatrocinios(db);

    expect(await leerPatrociniosActivos(db), isEmpty);
    expect(await bonusSalarialDePatrocinadores(db), 0);
  });

  test('el bonus de patrocinadores llega al espacio salarial, y solo al '
      'tuyo', () async {
    final antesTuyo = await espacioSalarial(db, 'DEN');
    final antesRival = await espacioSalarial(db, 'LAL');

    final elegida = oferta('camiseta');
    await firmarPatrocinio(db, elegida);

    expect(await espacioSalarial(db, 'DEN'), antesTuyo + elegida.bonusAnual,
        reason: 'el margen es para tu equipo');
    expect(await espacioSalarial(db, 'LAL'), antesRival,
        reason: 'los otros 29 no eligen patrocinadores: no les toca nada');
  });

  test('nuevaFranquicia deja los patrocinios de la partida anterior fuera',
      () async {
    await firmarPatrocinio(db, oferta('bebida', puesto: 2));
    expect(await leerPatrociniosActivos(db), isNotEmpty);

    await nuevaFranquicia(db);

    expect(await leerPatrociniosActivos(db), isEmpty);
  });
}
