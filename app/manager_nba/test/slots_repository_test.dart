import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';

/// Las ranuras de guardado: tres carreras que no se pisan entre ellas.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() {
    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;
  });

  tearDown(() async {
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  Future<void> partidaEn(int slot, String equipo) async {
    final db = abrirSlot(slot);
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, equipo);
  }

  test('sin partidas, las tres ranuras están vacías', () async {
    final resumenes = await leerResumenDeSlots();
    expect(resumenes, hasLength(numeroDeSlots));
    expect(resumenes.every((r) => !r.ocupada), isTrue);
    expect(await primeraRanuraLibre(), 1);
  });

  test('cada ranura guarda su propia carrera: equipo, temporada y récord',
      () async {
    await partidaEn(1, 'DEN');
    await partidaEn(3, 'BOS');

    final resumenes = await leerResumenDeSlots();
    expect(resumenes[0].equipo, 'DEN');
    expect(resumenes[1].ocupada, isFalse);
    expect(resumenes[2].equipo, 'BOS');
    expect(resumenes[0].temporada, 1);
    expect(resumenes[0].etiquetaTemporada, contains('temporada 1'));
    expect(await primeraRanuraLibre(), 2);
  });

  test('lo que pasa en una ranura no toca a las otras: es el punto de '
      'tenerlas', () async {
    await partidaEn(1, 'DEN');
    await partidaEn(2, 'BOS');

    // Se avanza la temporada solo en la ranura 1.
    final db1 = abrirSlot(1);
    await (db1.update(db1.resultadoTemporada)
          ..where((t) => t.equipo.equals('DEN')))
        .write(const ResultadoTemporadaCompanion(
            victorias: Value(40), derrotas: Value(12)));

    final resumenes = await leerResumenDeSlots();
    expect(resumenes[0].victorias, 40);
    expect(resumenes[0].derrotas, 12);
    expect(resumenes[1].equipo, 'BOS');
    expect(resumenes[1].victorias, 0,
        reason: 'la partida de al lado no se entera de nada');
  });

  test('borrar una ranura la deja libre y no se lleva por delante las '
      'demás', () async {
    await partidaEn(1, 'DEN');
    await partidaEn(2, 'BOS');

    await borrarSlot(1);

    final resumenes = await leerResumenDeSlots();
    expect(resumenes[0].ocupada, isFalse);
    expect(resumenes[1].equipo, 'BOS');
    expect(await primeraRanuraLibre(), 1);
  });

  test('una ranura que se abre pero no llega a tener franquicia sigue '
      'contando como vacía', () async {
    final db = abrirSlot(2);
    await importarJugadoresSiHaceFalta(db);

    final resumen = await leerResumenDeSlot(2);
    expect(resumen.ocupada, isFalse,
        reason: 'sin equipo elegido no hay partida que continuar');
  });

  test('los ajustes son de la app, no de una partida: sobreviven a borrar '
      'la ranura', () async {
    final ajustes = abrirAjustes();
    await ajustes.into(ajustes.ajustes).insertOnConflictUpdate(
        const AjustesCompanion(id: Value(0), modoOscuro: Value(true)));

    await partidaEn(1, 'DEN');
    await borrarSlot(1);

    final fila = await (ajustes.select(ajustes.ajustes)
          ..where((t) => t.id.equals(0)))
        .getSingle();
    expect(fila.modoOscuro, isTrue);
  });
}
