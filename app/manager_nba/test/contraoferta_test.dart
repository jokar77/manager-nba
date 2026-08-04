import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/traspasos_repository.dart';
import 'package:manager_nba/features/mercado/traspasos_screen.dart';

/// Contraofertar es abrir la oferta recibida en la mesa de traspasos con las
/// piezas ya puestas: desde ahí se quita, se añade o se mete a un tercero, y
/// el motor la vuelve a evaluar como cualquier otra propuesta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('una propuesta se convierte en movimientos con el destino correcto: '
      'lo tuyo va al rival y lo suyo viene a ti', () {
    const propuesta = PropuestaDePartida(
      equipoRival: 'BOS',
      tusJugadores: [1, 2],
      susJugadores: [3],
      tusPicks: [10],
      susPicks: [20, 21],
    );

    final movimientos =
        movimientosDePropuesta(propuesta, equipoUsuario: 'LAL');
    final origenes = origenesDePropuesta(propuesta, equipoUsuario: 'LAL');

    expect(movimientos, hasLength(6));
    expect(movimientos['j1']!.destino, 'BOS');
    expect(movimientos['j2']!.destino, 'BOS');
    expect(movimientos['p10']!.destino, 'BOS');
    expect(movimientos['j3']!.destino, 'LAL');
    expect(movimientos['p20']!.destino, 'LAL');
    expect(movimientos['p21']!.destino, 'LAL');

    expect(origenes['j1'], 'LAL');
    expect(origenes['p10'], 'LAL');
    expect(origenes['j3'], 'BOS');
    expect(origenes['p21'], 'BOS');

    expect(movimientos['j1']!.esPick, isFalse);
    expect(movimientos['p10']!.esPick, isTrue);
  });

  test('la oferta cargada tal cual la evalúa el motor igual que si la '
      'hubieras montado a mano', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'LAL');

    // Un uno por uno de sueldos y valor parecidos: lo que llegaría en una
    // oferta razonable.
    final mios = await plantillaParaTraspasos(db, 'LAL');
    final suyos = await plantillaParaTraspasos(db, 'BOS');
    final propuesta = PropuestaDePartida(
      equipoRival: 'BOS',
      tusJugadores: [mios.first.id],
      susJugadores: [suyos.last.id],
    );

    final movimientos =
        movimientosDePropuesta(propuesta, equipoUsuario: 'LAL').values.toList();
    final desdeLaOferta = await evaluarTraspasoMultiple(db,
        equipoUsuario: 'LAL',
        equipos: ['LAL', 'BOS'],
        movimientos: movimientos,
        dejarRompertePlantilla: true);

    final aMano = await evaluarTraspaso(db,
        equipoUsuario: 'LAL',
        equipoRival: 'BOS',
        tuyos: [mios.first.id],
        suyos: [suyos.last.id],
        dejarRompertePlantilla: true);

    expect(desdeLaOferta.aceptado, aMano.aceptado);
    expect(desdeLaOferta.mensaje, aMano.mensaje);

    await db.close();
  });
}
