import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/estilo.dart';
import 'comprar_screen.dart';

/// El aviso genérico de "esto es de la versión completa": mismo diálogo
/// para cualquier función bloqueada por compra (hoy, las ranuras extra),
/// para no repetir texto ni comportamiento en cada sitio que lo necesite.
///
/// [mensaje] es lo único que cambia de un caso a otro: qué es concretamente
/// lo que se está pidiendo. El título, y el camino a la tienda, son
/// siempre los mismos.
Future<void> mostrarAvisoVersionCompleta(
  BuildContext context, {
  required String mensaje,
}) async {
  final irATienda = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t(context).avisoVersionCompletaTitulo),
      content: Text(mensaje),
      actions: [
        BotonDialogoSecundario(
          texto: t(context).cancelar,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        BotonDialogoPrincipal(
          texto: t(context).verVersionCompletaBtn,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if (irATienda == true && context.mounted) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ComprarScreen()),
    );
  }
}
