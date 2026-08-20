import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/ajustes_repository.dart';
import '../../domain/slots_repository.dart';
import '../../i18n/textos.dart';
import '../../shared/estilo.dart';
import '../../shared/preferencias.dart';

/// Ajustes: modo claro/oscuro e idioma.
///
/// No recibe ni la base de datos ni los notificadores a propósito. Los coge
/// siempre de donde tiene que cogerlos —[abrirAjustes], que es la base de la
/// APP y no la de la partida, y los notificadores globales de
/// `shared/preferencias.dart`—, así que da igual desde dónde se abra: desde
/// el menú de inicio o desde dentro de una partida se comporta igual.
///
/// Antes se le pasaba todo por el constructor y desde el menú de la partida
/// se le pasaba la base equivocada y ningún notificador: cambiar el idioma
/// ahí dentro no hacía nada de nada.
class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  late final AppDatabase _db = abrirAjustes();
  bool _modoOscuro = false;
  Idioma _idioma = Idioma.espanol;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final activo = await leerModoOscuro(_db);
    final idioma = await leerIdioma(_db);
    if (!mounted) return;
    setState(() {
      _modoOscuro = activo;
      _idioma = idioma;
      _cargando = false;
    });
  }

  Future<void> _cambiarModoOscuro(bool activo) async {
    setState(() => _modoOscuro = activo);
    await guardarModoOscuro(_db, activo);
    temaNotifier.value = activo ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _cambiarIdioma(Idioma idioma) async {
    setState(() => _idioma = idioma);
    await guardarIdioma(_db, idioma);
    // Esto repinta la app entera, no solo esta pantalla: el idioma cuelga
    // por encima de todas las rutas, en el `MaterialApp` de `main.dart`.
    idiomaNotifier.value = idioma;
  }

  @override
  Widget build(BuildContext context) {
    final textos = t(context);
    return Scaffold(
      appBar: BarraNeutraAppBar(titulo: textos.ajustes),
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
