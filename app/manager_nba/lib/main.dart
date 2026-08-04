import 'package:flutter/material.dart';

import 'data/database/app_database.dart';
import 'domain/ajustes_repository.dart';
import 'domain/slots_repository.dart';
import 'features/inicio/start_menu_screen.dart';
import 'shared/pantalla.dart';

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
  final _temaNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  void dispose() {
    _temaNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _temaNotifier,
      builder: (context, modo, _) {
        return MaterialApp(
          title: 'Manager NBA',
          navigatorObservers: [routeObserver],
          themeMode: modo,
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
            if (!tamanoDe(context).esTactil) return child!;
            return Theme(
              data: tema.copyWith(
                visualDensity: VisualDensity.standard,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                listTileTheme: tema.listTileTheme.copyWith(
                  minTileHeight: alturaTactilMinima(context),
                ),
              ),
              child: child!,
            );
          },
          home: _ArranqueScreen(
              ajustesDb: widget.ajustesDb, temaNotifier: _temaNotifier),
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
  final ValueNotifier<ThemeMode> temaNotifier;

  const _ArranqueScreen({required this.ajustesDb, required this.temaNotifier});

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
    widget.temaNotifier.value = modoOscuro ? ThemeMode.dark : ThemeMode.light;
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

        return StartMenuScreen(
            ajustesDb: widget.ajustesDb, temaNotifier: widget.temaNotifier);
      },
    );
  }
}
