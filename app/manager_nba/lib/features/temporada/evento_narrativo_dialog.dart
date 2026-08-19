import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../domain/eventos_narrativos_repository.dart';
import '../../shared/pantalla.dart';

/// Plantea un evento narrativo y devuelve la opción elegida.
///
/// No se puede cerrar sin elegir (`barrierDismissible: false` y sin botón de
/// cancelar): "no hacer nada" es una de las opciones del catálogo cuando
/// tiene sentido, así que escaparse tocando fuera sería una respuesta gratis
/// que no existe en el guion.
Future<OpcionDeEvento?> plantearEvento(
  BuildContext context,
  EventoNarrativo evento,
) {
  return showDialog<OpcionDeEvento>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _DialogoDeEvento(evento: evento),
  );
}

/// Cuenta lo que ha pasado tras elegir. Va aparte del diálogo de decisión a
/// propósito: leer la consecuencia DESPUÉS de haberte mojado es lo que
/// convierte esto en una decisión de la que se aprende, en vez de un texto
/// que se pasa sin leer.
Future<void> contarConsecuencia(
  BuildContext context,
  EventoNarrativo evento,
  OpcionDeEvento opcion,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(evento.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(opcion.consecuencia),
          if (opcion.efectos.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...opcion.efectos.map((e) => _FilaDeEfecto(efecto: e)),
          ],
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t(context).entendido),
        ),
      ],
    ),
  );
}

class _DialogoDeEvento extends StatelessWidget {
  final EventoNarrativo evento;

  const _DialogoDeEvento({required this.evento});

  @override
  Widget build(BuildContext context) {
    final compacto = tamanoDe(context).esCompacto;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.forum, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(evento.titulo)),
        ],
      ),
      content: SizedBox(
        width: compacto ? double.maxFinite : 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(evento.texto),
              const SizedBox(height: 18),
              // Los botones van en el cuerpo y no en `actions` porque son
              // hasta tres, con texto largo: en la fila de acciones de un
              // AlertDialog se desbordan en cuanto la pantalla es la de un
              // móvil. Apilados y a todo el ancho caben siempre y además el
              // objetivo táctil queda grande.
              ...evento.opciones.map(
                (opcion) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(opcion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(opcion.etiqueta,
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un efecto, con su color según sea bueno o malo y cuánto le queda.
class _FilaDeEfecto extends StatelessWidget {
  final EfectoDeEvento efecto;

  const _FilaDeEfecto({required this.efecto});

  @override
  Widget build(BuildContext context) {
    final bueno = efecto.esBueno;
    final color =
        bueno ? const Color(0xFF2E9E5B) : Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(bueno ? Icons.trending_up : Icons.trending_down,
              size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(efecto.etiqueta,
                style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(
            t(context).nPartidos(efecto.partidos),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// La tarjeta del menú principal con lo que hay activo en el vestuario.
/// No se enseña nada si no hay nada: un hueco vacío permanente es ruido.
class TarjetaDeEfectosActivos extends StatelessWidget {
  final List<EfectoDeEvento> efectos;

  const TarjetaDeEfectosActivos({super.key, required this.efectos});

  @override
  Widget build(BuildContext context) {
    if (efectos.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.forum, size: 18),
                const SizedBox(width: 8),
                Text(t(context).enElVestuario,
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            ...efectos.map((e) => _FilaDeEfecto(efecto: e)),
          ],
        ),
      ),
    );
  }
}
