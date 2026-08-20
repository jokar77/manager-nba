import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/entrenadores_importer.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/slots_repository.dart';
import 'package:sim_engine/sim_engine.dart' as sim;

import 'package:manager_nba/features/calendario/calendario_screen.dart';
import 'package:manager_nba/features/partido/boxscore_screen.dart';
import 'package:manager_nba/features/clasificacion/clasificacion_screen.dart';
import 'package:manager_nba/features/mercado/agencia_libre_screen.dart';
import 'package:manager_nba/features/mercado/ofertas_screen.dart';
import 'package:manager_nba/features/mercado/traspasos_screen.dart';
import 'package:manager_nba/features/temporada/legado_screen.dart';
import 'package:manager_nba/features/hub/home_hub_screen.dart';
import 'package:manager_nba/features/inicio/start_menu_screen.dart';
import 'package:manager_nba/features/roster/roster_config_screen.dart';
import 'package:manager_nba/features/roster/team_preview_screen.dart';
import 'package:manager_nba/features/roster/team_selector_screen.dart';
import 'package:manager_nba/shared/estilo.dart';

import 'tipografia_de_prueba.dart';

/// El juego se puede jugar en claro y en oscuro, y las pantallas
/// rediseñadas traen su propia paleta (ver `shared/estilo.dart`) en vez de
/// heredar los grises de Material. Eso abre dos formas de romperlo que
/// ningún otro test veía:
///
/// 1. Que una pantalla desborde en un modo y en el otro no, porque los
///    tamaños dependen de widgets distintos.
/// 2. Que la paleta del segundo modo, que se mira mucho menos al
///    desarrollar, deje texto ilegible sobre su propio fondo.
///
/// Lo segundo se comprueba con números y no a ojo: el contraste WCAG entre
/// cada tinta y el fondo sobre el que se pinta de verdad.
const _tamanos = <String, Size>{
  'móvil': Size(390, 844),
  'tablet': Size(820, 1180),
  'escritorio': Size(1600, 900),
};

/// Contraste WCAG entre dos colores opacos, de 1 (iguales) a 21
/// (blanco contra negro).
double _contraste(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final claro = la > lb ? la : lb;
  final oscuro = la > lb ? lb : la;
  return (claro + 0.05) / (oscuro + 0.05);
}

/// Aplana [encima] —que puede ser semitransparente— sobre [debajo].
///
/// Hace falta porque las tintas secundarias de la paleta se declaran con
/// alfa: comparar su contraste sin componerlas primero daría un número que
/// no se corresponde con lo que se ve.
Color _sobre(Color encima, Color debajo) {
  final a = encima.a;
  return Color.from(
    alpha: 1,
    red: encima.r * a + debajo.r * (1 - a),
    green: encima.g * a + debajo.g * (1 - a),
    blue: encima.b * a + debajo.b * (1 - a),
  );
}

/// Un boxscore cualquiera, para poder montar la pantalla de resultado sin
/// tener que simular un partido de verdad.
sim.Boxscore _boxscoreDeEjemplo() => const sim.Boxscore(
      equipoLocal: 'DEN',
      equipoVisitante: 'LAL',
      marcadorLocal: 118,
      marcadorVisitante: 112,
      statsLocal: [
        sim.EstadisticasJugador(
          jugadorId: '1',
          nombreFicticio: 'Nikole Jukić',
          minutos: 36,
          puntos: 31,
          asistencias: 12,
          rebotes: 14,
        ),
      ],
      statsVisitante: [
        sim.EstadisticasJugador(
          jugadorId: '2',
          nombreFicticio: 'Lebrun Jamez',
          minutos: 34,
          puntos: 28,
          asistencias: 8,
          rebotes: 7,
        ),
      ],
      parcialesLocal: [30, 28, 31, 29],
      parcialesVisitante: [29, 27, 30, 26],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(cargarTipografiaDelJuego);

  group('la paleta se lee en los dos modos', () {
    for (final entrada in {'claro': Estilo.claro, 'oscuro': Estilo.oscuro}.entries) {
      final nombre = entrada.key;
      final e = entrada.value;

      test('modo $nombre: el texto contrasta con su fondo', () {
        for (final fondo in {
          'fondo': e.fondo,
          'panel': e.panel,
          'panelSuave': e.panelSuave,
          'marcador': e.marcador,
        }.entries) {
          // 4.5 es el mínimo de la norma para texto normal.
          expect(_contraste(_sobre(e.texto, fondo.value), fondo.value),
              greaterThanOrEqualTo(4.5),
              reason: '$nombre: el texto principal sobre ${fondo.key}');

          // Los subtítulos y los rótulos son texto pequeño pero secundario:
          // se les pide 3, que es el mínimo de texto grande, y no 4.5. Por
          // debajo de eso dejan de leerse de un vistazo.
          for (final tenue in {
            'textoTenue': e.textoTenue,
            'textoRotulo': e.textoRotulo,
          }.entries) {
            expect(_contraste(_sobre(tenue.value, fondo.value), fondo.value),
                greaterThanOrEqualTo(3.0),
                reason: '$nombre: ${tenue.key} sobre ${fondo.key}');
          }
        }
      });

      test('modo $nombre: los acentos se distinguen del fondo', () {
        for (final color in {'bien': e.bien, 'mal': e.mal}.entries) {
          expect(_contraste(color.value, e.marcador), greaterThanOrEqualTo(3.0),
              reason: '$nombre: ${color.key} sobre el marcador');
        }
        // El acento del juego se usa como texto y como contorno de botón en
        // el menú de inicio, así que tiene que despegarse del suelo.
        expect(_contraste(e.marca, e.fondo), greaterThanOrEqualTo(3.0),
            reason: '$nombre: la marca sobre el fondo');
      });

      test('modo $nombre: la cifra de cada placa de media se lee', () {
        // Una placa por tramo, con un valor de dentro de cada uno.
        for (final media in [98, 87, 82, 71]) {
          final placa = e.placaDeMedia(media);
          expect(_contraste(placa.texto, placa.fondo),
              greaterThanOrEqualTo(4.5),
              reason: '$nombre: el $media dentro de su placa');
          // Y la placa tiene que despegarse del panel donde se apoya, o un
          // 82 gris sobre panel gris no se ve como placa.
          expect(_contraste(placa.fondo, e.panel), greaterThanOrEqualTo(1.25),
              reason: '$nombre: la placa del $media contra el panel');
        }
      });
    }
  });

  group('las pantallas rediseñadas no desbordan en ningún modo', () {
    late AppDatabase db;
    late AlmacenDeSlotsEnMemoria almacen;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await importarJugadoresSiHaceFalta(db);
      await crearFranquicia(db, 'DEN');
      await importarEntrenadoresSiHaceFalta(db);
      almacen = AlmacenDeSlotsEnMemoria();
      almacenDeSlots = almacen;
    });

    tearDown(() async {
      await db.close();
      await almacen.cerrarTodo();
      almacenDeSlots = AlmacenDeSlotsEnDisco();
    });

    Future<Object?> montar(
      WidgetTester tester,
      Brightness brillo,
      Size tamano,
      Widget pantalla,
    ) async {
      tester.view.physicalSize = tamano;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        // El tema de verdad del juego, no uno de Material genérico: es el
        // que trae la letra condensada en los títulos y la esquina cortada
        // en botones y tarjetas, y por tanto el que cambia las medidas.
        theme: temaDeApp(brillo),
        home: pantalla,
      ));
      // Las dos cargan sus datos con un FutureBuilder: sin varios pump solo
      // se estaría midiendo el indicador de carga, que no desborda nunca.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      return tester.takeException();
    }

    for (final brillo in Brightness.values) {
      for (final entrada in _tamanos.entries) {
        testWidgets('el menú principal en ${brillo.name}, ${entrada.key}',
            (tester) async {
          expect(
              await montar(tester, brillo, entrada.value,
                  HomeHubScreen(db: db, equipo: 'DEN')),
              isNull);
        });

        testWidgets('el calendario en ${brillo.name}, ${entrada.key}',
            (tester) async {
          expect(
              await montar(tester, brillo, entrada.value,
                  CalendarioScreen(db: db, equipoUsuario: 'DEN')),
              isNull);
        });

        // Las demás pantallas de la franquicia. Van juntas porque todas se
        // montan igual —db y equipo— y lo que se comprueba es lo mismo: que
        // ninguna desborde con la paleta y la letra de cada modo.
        for (final pantalla in <String, Widget Function()>{
          'la clasificación': () =>
              ClasificacionScreen(db: db, equipoUsuario: 'DEN'),
          'la agencia libre': () =>
              AgenciaLibreScreen(db: db, equipoUsuario: 'DEN'),
          'la mesa de traspasos': () =>
              TraspasosScreen(db: db, equipoUsuario: 'DEN'),
          'las ofertas recibidas': () =>
              OfertasScreen(db: db, equipoUsuario: 'DEN'),
          'el legado': () => LegadoScreen(db: db, equipoUsuario: 'DEN'),
          'el boxscore': () => BoxscoreScreen(boxscore: _boxscoreDeEjemplo()),
        }.entries) {
          testWidgets('${pantalla.key} en ${brillo.name}, ${entrada.key}',
              (tester) async {
            expect(
                await montar(
                    tester, brillo, entrada.value, pantalla.value()),
                isNull);
          });
        }

        testWidgets('la alineación en ${brillo.name}, ${entrada.key}',
            (tester) async {
          expect(
              await montar(
                  tester,
                  brillo,
                  entrada.value,
                  RosterConfigScreen(
                    db: db,
                    equipo: 'DEN',
                    esConfiguracionInicial: false,
                    onGuardado: () {},
                  )),
              isNull);
        });

        testWidgets('el menú de inicio en ${brillo.name}, ${entrada.key}',
            (tester) async {
          expect(
              await montar(
                  tester, brillo, entrada.value, const StartMenuScreen()),
              isNull);
        });

        testWidgets('la elección de equipo en ${brillo.name}, ${entrada.key}',
            (tester) async {
          expect(
              await montar(
                  tester,
                  brillo,
                  entrada.value,
                  TeamSelectorScreen(
                    db: db,
                    titulo: 'Elige tu equipo',
                    onSeleccionado: (_) {},
                  )),
              isNull);
        });

        testWidgets('la vista previa de un club en ${brillo.name}, '
            '${entrada.key}', (tester) async {
          expect(
              await montar(
                  tester,
                  brillo,
                  entrada.value,
                  TeamPreviewScreen(
                      db: db, equipo: 'DEN', onElegir: () {})),
              isNull);
        });
      }
    }
  });
}
