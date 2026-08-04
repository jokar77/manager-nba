import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/ajustes_repository.dart';

/// Ajustes: modo claro/oscuro (funcional) e idioma (selector deshabilitado
/// por ahora — llega en la siguiente fase).
class AjustesScreen extends StatefulWidget {
  final AppDatabase db;
  final ValueNotifier<ThemeMode>? temaNotifier;

  const AjustesScreen({super.key, required this.db, this.temaNotifier});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool _modoOscuro = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final activo = await leerModoOscuro(widget.db);
    if (!mounted) return;
    setState(() {
      _modoOscuro = activo;
      _cargando = false;
    });
  }

  Future<void> _cambiarModoOscuro(bool activo) async {
    setState(() => _modoOscuro = activo);
    await guardarModoOscuro(widget.db, activo);
    widget.temaNotifier?.value = activo ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Modo oscuro'),
                  subtitle:
                      const Text('Grises y negros en vez de blancos claros'),
                  value: _modoOscuro,
                  onChanged: _cambiarModoOscuro,
                ),
                const ListTile(
                  title: Text('Idioma'),
                  subtitle: Text('Próximamente: inglés y español'),
                  trailing: Icon(Icons.lock_outline),
                ),
              ],
            ),
    );
  }
}
