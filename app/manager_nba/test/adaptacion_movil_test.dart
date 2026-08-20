import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import 'package:manager_nba/data/importer/entrenadores_importer.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/allstar_repository.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/playoffs_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:manager_nba/features/calendario/calendario_screen.dart';
import 'package:manager_nba/features/partido/boxscore_screen.dart';
import 'package:manager_nba/features/hub/home_hub_screen.dart';
import 'package:manager_nba/features/mercado/agencia_libre_screen.dart';
import 'package:manager_nba/features/mercado/entrenador_screen.dart';
import 'package:manager_nba/features/mercado/traspasos_screen.dart';
import 'package:manager_nba/features/playoffs/playoffs_screen.dart';
import 'package:manager_nba/features/roster/roster_config_screen.dart';
import 'package:manager_nba/features/temporada/legado_screen.dart';
import 'package:manager_nba/features/temporada/resumen_temporada_screen.dart';

import 'package:manager_nba/shared/estilo.dart';

import 'tipografia_de_prueba.dart';

/// El mismo juego tiene que poder jugarse en un iPhone en vertical, en un
/// iPad y en una ventana de escritorio. Un desborde de layout en Flutter
/// sale como excepción en test, así que montar cada pantalla a los tres
/// tamaños y comprobar que no salta ninguna es una red de verdad, no una
/// captura que haya que mirar a ojo.
///
/// Los tamaños son de dispositivos reales: iPhone 14 en vertical, iPad de
/// 11" en vertical y una ventana de Windows normal.
const _tamanos = <String, Size>{
  'iPhone vertical': Size(390, 844),
  'iPad vertical': Size(820, 1180),
  'escritorio': Size(1600, 900),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Con la fuente de verdad, no con la de relleno: si no, lo que se mide
  // aquí no es lo que se ve (ver tipografia_de_prueba.dart).
  setUpAll(cargarTipografiaDelJuego);

  late AppDatabase db;
  late AlmacenDeSlotsEnMemoria almacen;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'DEN');
    await importarEntrenadoresSiHaceFalta(db);

    almacen = AlmacenDeSlotsEnMemoria();
    almacenDeSlots = almacen;

    final equipos = await db.select(db.resultadoTemporada).get();
    for (var i = 0; i < equipos.length; i++) {
      await (db.update(db.resultadoTemporada)
            ..where((t) => t.equipo.equals(equipos[i].equipo)))
          .write(ResultadoTemporadaCompanion(
        victorias: Value(82 - i),
        derrotas: Value(i),
      ));
    }
  });

  tearDown(() async {
    await db.close();
    await almacen.cerrarTodo();
    almacenDeSlots = AlmacenDeSlotsEnDisco();
  });

  /// Monta [pantalla] a [tamano] y devuelve la excepción de layout, si la
  /// hubo. Se dan varios `pump` porque casi todas cargan sus datos con un
  /// `FutureBuilder`: sin eso solo se estaría comprobando el indicador de
  /// carga, que no desborda nunca.
  Future<Object?> montar(
    WidgetTester tester,
    Size tamano,
    Widget pantalla,
  ) async {
    tester.view.physicalSize = tamano;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
        MaterialApp(theme: temaDeApp(Brightness.light), home: pantalla));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return tester.takeException();
  }

  void pruebaEnLosTresTamanos(
    String nombre,
    Widget Function() construir, {
    Future<void> Function()? preparar,
  }) {
    for (final entrada in _tamanos.entries) {
      testWidgets('$nombre se ve bien en ${entrada.key}',
          (WidgetTester tester) async {
        await preparar?.call();
        expect(await montar(tester, entrada.value, construir()), isNull,
            reason: '$nombre desborda a ${entrada.value.width.toInt()}x'
                '${entrada.value.height.toInt()}');
      });
    }
  }

  pruebaEnLosTresTamanos(
      'el menú principal', () => HomeHubScreen(db: db, equipo: 'DEN'));

  pruebaEnLosTresTamanos(
      'el calendario', () => CalendarioScreen(db: db, equipoUsuario: 'DEN'));

  pruebaEnLosTresTamanos('el resumen de la temporada',
      () => ResumenTemporadaScreen(db: db, equipoUsuario: 'DEN'));

  // Las tres barras de facetas van en fila cuando hay sitio y apiladas
  // cuando no; es justo el tipo de cosa que desborda en un iPhone si se
  // deja en fila siempre.
  pruebaEnLosTresTamanos('la pantalla de entrenador',
      () => EntrenadorScreen(db: db, equipoUsuario: 'DEN'));

  pruebaEnLosTresTamanos(
    'el bracket de playoffs',
    () => PlayoffsScreen(db: db, equipoUsuario: 'DEN'),
    preparar: () => sembrarPlayoffs(db),
  );

  pruebaEnLosTresTamanos(
    'los playoffs ya resueltos',
    () => PlayoffsScreen(db: db, equipoUsuario: 'DEN'),
    preparar: () async {
      await sembrarPlayoffs(db);
      await simularPlayoffsCompletos(db);
    },
  );

  pruebaEnLosTresTamanos(
      'la mesa de traspasos',
      () => TraspasosScreen(db: db, equipoUsuario: 'DEN'));

  pruebaEnLosTresTamanos(
      'la agencia libre',
      () => AgenciaLibreScreen(db: db, equipoUsuario: 'DEN'));

  pruebaEnLosTresTamanos(
    'la alineación',
    () => RosterConfigScreen(
      db: db,
      equipo: 'DEN',
      esConfiguracionInicial: false,
      onGuardado: () {},
    ),
  );

  pruebaEnLosTresTamanos(
      'el legado', () => LegadoScreen(db: db, equipoUsuario: 'DEN'));

  // El boxscore necesita un partido de verdad: el del All-Star sirve y se
  // juega en una línea.
  sim.Boxscore? boxscore;
  pruebaEnLosTresTamanos(
    'el boxscore',
    () => BoxscoreScreen(boxscore: boxscore!),
    preparar: () async => boxscore = await jugarAllStarSiHaceFalta(db),
  );

  testWidgets('en móvil la mesa de traspasos cabe en dos columnas, sin '
      'scroll horizontal', (WidgetTester tester) async {
    expect(
        await montar(tester, const Size(390, 844),
            TraspasosScreen(db: db, equipoUsuario: 'DEN')),
        isNull);

    // Las dos columnas que importan están a la vista a la vez: es lo que
    // permite comparar sin perder de vista un lado.
    expect(find.text('TU EQUIPO'), findsOneWidget);
    expect(find.text('RIVAL'), findsOneWidget);
    // Y el tercer equipo no se come una columna: baja a botón.
    expect(find.textContaining('Mete a un tercero'), findsOneWidget);
  });

  /// El cuadro va de arriba abajo —el Oeste baja, el Este sube y la Final
  /// NBA queda en medio— y cabe entero en el ancho que haya. Nada de scroll
  /// horizontal: las dos conferencias tienen que estar a la vista a la vez.
  Future<void> comprobarCuadroEntero(WidgetTester tester, Size tamano) async {
    expect(
        await montar(
            tester, tamano, PlayoffsScreen(db: db, equipoUsuario: 'DEN')),
        isNull);

    expect(find.text('CONFERENCIA OESTE'), findsOneWidget);
    expect(find.text('CONFERENCIA ESTE'), findsOneWidget);
    expect(find.textContaining('FINAL'), findsWidgets);

    // Lo que se vigila NO es que quepa, sino que se lea.
    //
    // Antes esto comprobaba que el cuadro entrara en el ancho de la
    // pantalla, y por eso el bug del punto 16 pasaba desapercibido: el
    // cuadro cabía, sí, pero encogido al 55% en un móvil, con los nombres
    // de 11px dibujados a 6. Cabía y era ilegible, que es justo lo que se
    // reportó. Ahora se deja a tamaño real y se arrastra.
    //
    // 714 = 66 de la columna de etiquetas + 4 huecos de 162 de la primera
    // ronda (ver las constantes de _BracketVisual).
    const anchoNatural = 714.0;
    const escalaMinima = 0.9;
    final cuadro = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey('cuadro-playoffs')));
    final escala = cuadro.size.width / anchoNatural;
    expect(escala, greaterThanOrEqualTo(escalaMinima),
        reason: 'el cuadro se ha encogido al '
            '${(escala * 100).toStringAsFixed(0)}% en una pantalla de '
            '${tamano.width}: a ese tamaño no se leen los nombres');
  }

  testWidgets('en móvil el cuadro de playoffs se lee, con las dos '
      'conferencias a la vez', (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await comprobarCuadroEntero(tester, const Size(390, 844));

    // Y si no cabe, se puede arrastrar: sin esto el cuadro a tamaño real
    // se quedaría recortado por la derecha y sin forma de llegar al Este.
    final scrollables = tester
        .widgetList<Scrollable>(find.byType(Scrollable))
        .where((s) => s.axisDirection == AxisDirection.right ||
            s.axisDirection == AxisDirection.left);
    expect(scrollables, isNotEmpty,
        reason: 'a tamaño real el cuadro no cabe en 390px: tiene que '
            'poder arrastrarse en horizontal');
  });

  testWidgets('y en un iPad en vertical, igual', (WidgetTester tester) async {
    await sembrarPlayoffs(db);
    await comprobarCuadroEntero(tester, const Size(820, 1180));
  });

  /// Comprueba que el primer mes del calendario cabe entero en lo que se ve
  /// sin arrastrar, y que no se ha apretado tanto la celda que deje de
  /// leerse. Devuelve el alto del mes, para poder contarlo en el mensaje.
  double comprobarQueElMesCabe(WidgetTester tester) {
    // El alto de la zona de scroll: lo que de verdad se ve de calendario, ya
    // descontados la barra, los botones de avance y el panel de playoffs.
    final viewport =
        tester.renderObject<RenderBox>(find.byType(Scrollable).first);
    final grid = tester.renderObject<RenderBox>(find.byType(GridView).first);
    final cabecera = tester.renderObject<RenderBox>(find
        // En mayúsculas desde el rediseño: la cabecera de mes usa el
        // mismo separador de sección que el resto del juego.
        .textContaining(RegExp(r'(OCTUBRE|NOVIEMBRE|DICIEMBRE) \d{4}'))
        .first);

    // La rejilla, el nombre del mes y la fila de iniciales de los días.
    final altoDelMes = grid.size.height + cabecera.size.height + 30;
    expect(altoDelMes, lessThanOrEqualTo(viewport.size.height),
        reason: 'el mes mide ${altoDelMes.toStringAsFixed(0)}px y en la '
            'pantalla caben ${viewport.size.height.toStringAsFixed(0)}: hay '
            'que arrastrar para ver la última semana');
    expect(grid.size.height / 6, greaterThanOrEqualTo(50),
        reason: 'la celda se ha quedado tan baja que no cabe el rival');
    return altoDelMes;
  }

  testWidgets('un mes del calendario cabe en la pantalla de un móvil',
      (WidgetTester tester) async {
    expect(
        await montar(tester, const Size(390, 844),
            CalendarioScreen(db: db, equipoUsuario: 'DEN')),
        isNull);
    comprobarQueElMesCabe(tester);
  });

  testWidgets('y también en el teléfono más bajo que sigue en circulación',
      (WidgetTester tester) async {
    // 375x667 es un iPhone SE. Con la proporción de celda fija de antes el
    // mes medía siempre lo mismo pasara lo que pasara arriba; ahora la
    // cuadrícula se reparte el alto que de verdad le queda (ver
    // _SeccionMes.alturaDisponible), así que esto se cumple aunque encima
    // aparezcan los botones, el panel de playoffs o un aviso.
    expect(
        await montar(tester, const Size(375, 667),
            CalendarioScreen(db: db, equipoUsuario: 'DEN')),
        isNull);
    comprobarQueElMesCabe(tester);
  });
}
