import 'package:flutter/material.dart';

import '../i18n/textos.dart';
/// Nombres de ruta para las pantallas a las que hace falta poder volver de
/// un salto, sin pasar por todo lo que se haya apilado por el camino
/// (premios, resumen de partidos simulados, boxscores...).
class RutasPrincipales {
  static const hub = '/hub';
  static const calendario = '/calendario';
}

/// Vuelve directamente al menú principal, saltándose cualquier pantalla
/// intermedia que se haya apilado por el camino (premios, resumen de
/// partidos simulados, boxscores, la mesa de traspasos...).
///
/// Antes de esto, el único "volver" era el de la flecha de cada pantalla,
/// que retrocedía paso a paso — cómodo si vienes de una sola pantalla,
/// desesperante si vienes de un flujo encadenado (simular -> resumen ->
/// premios) y solo quieres estar en el menú.
///
/// Si por lo que sea el hub no está en la pila (no debería pasar en el
/// flujo normal: siempre se llega aquí desde dentro de él), no hace nada
/// en vez de navegar a un sitio inesperado.
void volverAlMenuPrincipal(BuildContext context) {
  final navigator = Navigator.of(context);
  if (!navigator.canPop()) return;
  navigator.popUntil((route) => route.settings.name == RutasPrincipales.hub);
}

/// Vuelve al Calendario ya abierto más abajo en la pila, en vez de apilar
/// una instancia nueva encima (que es justo lo que dejaba "Ver calendario"
/// acumulando pantallas cada vez que se pulsaba desde Premios).
///
/// Solo se puede usar cuando quien llama sabe con certeza que hay un
/// Calendario más abajo — `popUntil` con un predicado que nunca encuentra
/// coincidencia seguiría vaciando la pila hasta la primera ruta, así que no
/// es un "a lo mejor está" sino un "sé que está".
void volverAlCalendario(BuildContext context) {
  Navigator.of(context)
      .popUntil((route) => route.settings.name == RutasPrincipales.calendario);
}

/// Botón de acción para la AppBar de las pantallas que cuelgan del menú
/// principal (premios, resumen de simulación...), para poder saltar
/// directamente de vuelta sin deshacer paso a paso.
class BotonMenuPrincipal extends StatelessWidget {
  const BotonMenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home),
      tooltip: t(context).volverAlMenuPrincipalTooltip,
      onPressed: () => volverAlMenuPrincipal(context),
    );
  }
}
