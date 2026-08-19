import 'package:flutter/material.dart';

import '../i18n/textos.dart';

/// El modo claro/oscuro y el idioma son ajustes de la APP, no de la partida:
/// se eligen una vez y valen para el menú de inicio, para las tres ranuras y
/// para todas las pantallas.
///
/// Viven aquí sueltos, y no colgando de `main.dart` pasándose de constructor
/// en constructor, por un fallo que costó encontrar: la pantalla de Ajustes
/// se abre desde DOS sitios —el menú de inicio y el menú de dentro de una
/// partida— y la segunda se quedó sin recibir nada. Guardaba el idioma en la
/// base de datos de la PARTIDA, donde nadie lo lee nunca, y no avisaba a
/// nadie de que había cambiado, así que desde dentro de una partida los
/// ajustes parecían no hacer absolutamente nada.
///
/// Con los notificadores aquí arriba ese fallo no se puede repetir: no hay
/// nada que recordar pasar.
final temaNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
final idiomaNotifier = ValueNotifier<Idioma>(Idioma.espanol);
