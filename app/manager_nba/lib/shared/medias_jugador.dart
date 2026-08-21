import 'package:flutter/material.dart';

import '../data/database/app_database.dart';

/// Los dos colores con los que se habla de ataque y defensa en todo el
/// juego: los mismos que usan las barras del entrenador, para que el
/// naranja signifique siempre "ataque" y el azul siempre "defensa".
const colorAtaque = Color(0xFFE08A1E);
const colorDefensa = Color(0xFF3D7BFF);

/// El ataque y la defensa de un CONJUNTO de jugadores (los cinco titulares,
/// la rotación entera…), como media redondeada. Cero si no hay nadie.
({int ataque, int defensa}) mediasDe(List<Jugador> jugadores) {
  if (jugadores.isEmpty) return (ataque: 0, defensa: 0);
  var ata = 0;
  var def = 0;
  for (final j in jugadores) {
    ata += j.atrAtaque;
    def += j.atrDefensa;
  }
  return (
    ataque: (ata / jugadores.length).round(),
    defensa: (def / jugadores.length).round(),
  );
}
