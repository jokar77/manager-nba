import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/database/app_database.dart';
import 'domain/ajustes_repository.dart';
import 'domain/slots_repository.dart';
import 'features/inicio/start_menu_screen.dart';
import 'i18n/textos.dart';
import 'shared/pantalla.dart';
import 'shared/preferencias.dart';

void main() {
  // Los ajustes son de la app y viven en su propio fichero; cada partida
  // guardada tiene el suyo y se abre al entrar en su ranura.
  runApp(ManagerNbaApp(ajustesDb: abrirAjustes()));
}

/// Observador global de rutas: lo usa `StartMenuScreen` para saber cuándo
/// vuelve a ser la pantalla visible (p. ej. al pulsar "atrás" desde el
/// menú principal) y así recargar si ya existe una franquicia — sin esto,
/// una franquicia creada después de que `StartMenuScreen` se construyera
/// se queda "invisible" para ella (el botón "Continuar" parece no
/// encontrarla) hasta reiniciar la app.
final routeObserver = RouteObserver<PageRoute<void>>();

class ManagerNbaApp extends StatefulWidget {
  final AppDatabase ajustesDb;

  const ManagerNbaApp({super.key, required this.ajustesDb});

  @override
  State<ManagerNbaApp> createState() => _ManagerNbaAppState();
}

class _ManagerNbaAppState extends State<ManagerNbaApp> {
  // El tema y el idioma son globales (ver shared/preferencias.dart): la
  // pantalla de Ajustes se abre desde dos sitios y tiene que dar igual
  // desde cuál. Aquí solo se escuchan para repintar la app entera.

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Idioma>(
      valueListenable: idiomaNotifier,
      builder: (context, idioma, _) => _conTema(idioma),
    );
  }

  Widget _conTema(Idioma idioma) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaNotifier,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'Manager NBA',
          navigatorObservers: [routeObserver],
          themeMode: modo,
          locale: idioma.locale,
          supportedLocales: Idioma.values.map((i) => i.locale),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.light,
            ).copyWith(surface: Colors.white),
            scaffoldBackgroundColor: const Color(0xFFFAFAFA),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.dark,
            ).copyWith(surface: const Color(0xFF1A1A1A)),
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          // La densidad se decide aquí y no pantalla por pantalla. Media
          // interfaz usa `ListTile(dense: true)` e iconos de 18px, que con
          // ratón está bien —cabe más información— y con el dedo se queda
          // por debajo de los 48px que piden tanto Apple como Google. Un
          // `dense: true` puesto en el widget gana al tema, pero
          // `minTileHeight` no: se aplica igual, así que sube el alto de
          // TODAS las filas sin tener que tocar una por una.
          builder: (context, child) {
            final tema = Theme.of(context);
            // Los textos se cuelgan aquí, por encima de todas las rutas,
            // para que cualquier pantalla los tenga sin pasarlos a mano.
            final conIdioma =
                Idiomas(textos: textosDe(idioma), child: child!);
            if (!tamanoDe(context).esTactil) return conIdioma;
            return Theme(
              data: tema.copyWith(
                visualDensity: VisualDensity.standard,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                listTileTheme: tema.listTileTheme.copyWith(
                  minTileHeight: alturaTactilMinima(context),
                ),
              ),
              child: conIdioma,
            );
          },
          home: _ArranqueScreen(ajustesDb: widget.ajustesDb),
        );
      },
    );
  }
}

/// Rescata la partida de las versiones sin ranuras, carga el modo
/// claro/oscuro guardado y muestra el menú de partidas. El dataset ya no se
/// importa aquí: se importa dentro de cada ranura al empezar su carrera,
/// porque cada partida tiene su propia liga.
class _ArranqueScreen extends StatefulWidget {
  final AppDatabase ajustesDb;

  const _ArranqueScreen({required this.ajustesDb});

  @override
  State<_ArranqueScreen> createState() => _ArranqueScreenState();
}

class _ArranqueScreenState extends State<_ArranqueScreen> {
  late final Future<void> _arranque;

  @override
  void initState() {
    super.initState();
    _arranque = _prepararArranque();
  }

  Future<void> _prepararArranque() async {
    await migrarPartidaSinSlots();
    final modoOscuro = await leerModoOscuro(widget.ajustesDb);
    temaNotifier.value = modoOscuro ? ThemeMode.dark : ThemeMode.light;
    idiomaNotifier.value = await leerIdioma(widget.ajustesDb);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _arranque,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error cargando datos: ${snapshot.error}')),
          );
        }

        return const StartMenuScreen();
      },
    );
  }
}
