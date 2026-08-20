import 'package:flutter/material.dart';

import '../domain/equipos_info.dart';
import 'estilo.dart';

/// La barra superior con el color de tu club, lista para el hueco
/// `appBar:` de un `Scaffold`.
///
/// Es una función y no un widget más para que cambiar la cabecera de una
/// pantalla ya escrita sea una sola línea: `appBar: barraDeClub(equipo,
/// titulo)`. Se le pasa el código del equipo y ella busca sus colores, que
/// es lo único que repetían todas las pantallas.
PreferredSizeWidget barraDeClub(
  String equipo,
  String titulo, {
  String? sobretitulo,
  List<Widget> acciones = const [],
  PreferredSizeWidget? bottom,
  bool conVolver = true,
}) {
  final info = infoDe(equipo);
  return BarraDeTituloAppBar(
    codigo: equipo,
    primario: info.colorPrimario,
    secundario: info.colorSecundario,
    titulo: titulo,
    sobretitulo: sobretitulo,
    acciones: acciones,
    bottom: bottom,
    conVolver: conVolver,
  );
}
