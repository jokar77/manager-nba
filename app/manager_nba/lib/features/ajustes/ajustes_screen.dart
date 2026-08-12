import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/ajustes_repository.dart';
import '../../i18n/textos.dart';

/// Ajustes: modo claro/oscuro e idioma. Los dos se guardan en la base de
/// ajustes de la app (no en la de cada partida) y se aplican al momento.
class AjustesScreen extends StatefulWidget {
  final AppDatabase db;
  final ValueNotifier<ThemeMode>? temaNotifier;
  final ValueNotifier<Idioma>? idiomaNotifier;

  const AjustesScreen({
    super.key,
    required this.db,
    this.temaNotifier,
    this.idiomaNotifier,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _modoOscuro = false;
  Idioma _idioma = Idioma.espanol;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final activo = await leerModoOscuro(widget.db);
    final idioma = await leerIdioma(widget.db);
    if (!mounted) return;
    setState(() {
      _modoOscuro = activo;
      _idioma = idioma;
      _cargando = false;
    });
  }

  Future<void> _cambiarModoOscuro(bool activo) async {
    setState(() => _modoOscuro = activo);
    await guardarModoOscuro(widget.db, activo);
    widget.temaNotifier?.value = activo ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _cambiarIdioma(Idioma idioma) async {
    setState(() => _idioma = idioma);
    await guardarIdioma(widget.db, idioma);
    // Esto repinta la app entera, no solo esta pantalla: el idioma vive en
    // el notificador de main.dart, por encima de todas las rutas.
    widget.idiomaNotifier?.value = idioma;
  }

  @override
  Widget build(BuildContext context) {
    final textos = t(context);
    return Scaffold(
      appBar: AppBar(title: Text(textos.ajustes)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: Text(textos.modoOscuro),
                  subtitle: Text(textos.modoOscuroDetalle),
                  value: _modoOscuro,
                  onChanged: _cambiarModoOscuro,
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text(textos.idioma),
                  subtitle: Text(textos.idiomaDetalle),
                ),
                // Cada idioma se escribe EN SU IDIOMA. Una lista traducida
                // al idioma actual es inservible justo para quien la
                // necesita: alguien que no entiende en qué está la app.
                //
                // Filas normales con un tick en vez de RadioListTile: el
                // radio de Material está en desuso desde 3.32 y obliga a
                // montar un RadioGroup alrededor para nada — aquí una fila
                // que se toca y un tick dicen lo mismo.
                ...Idioma.values.map(
                  (idioma) => ListTile(
                    title: Text(idioma.nombre),
                    trailing: idioma == _idioma
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    selected: idioma == _idioma,
                    onTap: () => _cambiarIdioma(idioma),
                  ),
                ),
              ],
            ),
    );
  }
}
