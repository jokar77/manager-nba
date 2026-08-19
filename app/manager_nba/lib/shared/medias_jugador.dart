import 'package:flutter/material.dart';

import '../data/database/app_database.dart';

/// Los dos colores con los que se habla de ataque y defensa en todo el
/// juego: los mismos que usan las barras del entrenador, para que el
/// naranja signifique siempre "ataque" y el azul siempre "defensa".
const colorAtaque = Color(0xFFE08A1E);
const colorDefensa = Color(0xFF3D7BFF);

/// Las medias de ataque y defensa de un jugador, en dos etiquetas.
///
/// La media a secas dice lo bueno que es alguien, pero no en qué. Dos
/// jugadores de 82 pueden ser un anotador que no defiende y un especialista
/// defensivo, y elegir entre ellos sin verlo es elegir a ciegas — que es lo
/// que pasaba al fichar, al traspasar y al hacer la alineación.
class MediasAtaqueDefensa extends StatelessWidget {
  final int ataque;
  final int defensa;
  final bool compacto;

  const MediasAtaqueDefensa({
    super.key,
    required this.ataque,
    required this.defensa,
    this.compacto = false,
  });

  /// Atajo para no tener que escribir los dos campos en cada llamada.
  MediasAtaqueDefensa.de(Jugador jugador, {super.key, this.compacto = false})
      : ataque = jugador.atrAtaque,
        defensa = jugador.atrDefensa;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Etiqueta(texto: 'ATA', valor: ataque, color: colorAtaque,
            compacto: compacto),
        SizedBox(width: compacto ? 4 : 6),
        _Etiqueta(texto: 'DEF', valor: defensa, color: colorDefensa,
            compacto: compacto),
      ],
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final int valor;
  final Color color;
  final bool compacto;

  const _Etiqueta({
    required this.texto,
    required this.valor,
    required this.color,
    required this.compacto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compacto ? 5 : 7, vertical: 2),
      decoration: BoxDecoration(
        // Un fondo tenue del color en vez del color pleno: así se lee igual
        // de bien en claro y en oscuro sin tener que calcular contraste.
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$texto $valor',
        style: TextStyle(
          fontSize: compacto ? 10 : 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

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
