import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../domain/eventos_narrativos_repository.dart';
import '../../domain/salarios.dart' show formatearSalario;
import '../../shared/estilo.dart';
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
      title: Text(evento.titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: titular(Estilo.de(context), tamano: 20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(opcion.consecuencia),
          if (opcion.efectos.isNotEmpty || opcion.bonusSalarial != 0) ...[
            const SizedBox(height: 16),
            ...opcion.efectos.map((e) => _FilaDeEfecto(efecto: e)),
            // El dinero tiene que verse aquí o no existe: a diferencia de
            // los efectos de vestuario, que se notan en la pista, el margen
            // salarial solo se aprecia al ir a fichar — semanas después y
            // sin que nada lo relacione con esta decisión.
            if (opcion.bonusSalarial != 0)
              _FilaDeDinero(dolares: opcion.bonusSalarial),
          ],
        ],
      ),
      actions: [
        BotonDialogoPrincipal(
          texto: t(context).entendido,
          onPressed: () => Navigator.of(context).pop(),
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

    final e = Estilo.de(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.forum, color: e.marca),
          const SizedBox(width: 10),
          Expanded(
            // Sin mayúsculas: el título de un evento es una frase del
            // guion, y los demás diálogos del juego tampoco las usan.
            child: Text(evento.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titular(e, tamano: 20)),
          ),
        ],
      ),
      content: SizedBox(
        width: compacto ? double.maxFinite : 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(evento.texto,
                  style: TextStyle(fontSize: 14.5, height: 1.4, color: e.texto)),
              const SizedBox(height: 18),
              // Los botones van en el cuerpo y no en `actions` porque son
              // hasta tres, con texto largo: en la fila de acciones de un
              // AlertDialog se desbordan en cuanto la pantalla es la de un
              // móvil. Apilados y a todo el ancho caben siempre y además el
              // objetivo táctil queda grande.
              ...evento.opciones.map(
                (opcion) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BotonPerfilado(
                    texto: opcion.etiqueta,
                    color: e.texto,
                    alto: 52,
                    // Tal cual está escrita: es una frase, no un rótulo.
                    mayusculas: false,
                    onTap: () => Navigator.of(context).pop(opcion),
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
    final e = Estilo.de(context);
    final bueno = efecto.esBueno;
    final color = bueno ? e.bien : e.mal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(bueno ? Icons.trending_up : Icons.trending_down,
              size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(efecto.etiqueta,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: color)),
          ),
          const SizedBox(width: 8),
          Text(t(context).nPartidos(efecto.partidos),
              maxLines: 1,
              style: rotulo(e, tamano: 9)),
        ],
      ),
    );
  }
}

/// El margen de tope salarial que deja una decisión. Verde si entra dinero,
/// rojo si sale.
class _FilaDeDinero extends StatelessWidget {
  final int dolares;

  const _FilaDeDinero({required this.dolares});

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final entra = dolares > 0;
    final color = entra ? e.bien : e.mal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(entra ? Icons.savings : Icons.money_off, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(t(context).margenSalarialEvento,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: color)),
          ),
          const SizedBox(width: 8),
          Text('${entra ? '+' : '−'}${formatearSalario(dolares.abs())}',
              maxLines: 1,
              style: cifra(e, tamano: 16, color: color)),
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
    final e = Estilo.de(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PanelCortado(
        fondo: e.panel,
        corte: 12,
        borde: Border(
          left: BorderSide(color: e.marca, width: 3),
          top: BorderSide(color: e.linea),
          right: BorderSide(color: e.linea),
          bottom: BorderSide(color: e.linea),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.forum, size: 16, color: e.marca),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(mayus(t(context).enElVestuario),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: rotulo(e, tamano: 10, color: e.marca)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...efectos.map((efecto) => _FilaDeEfecto(efecto: efecto)),
            ],
          ),
        ),
      ),
    );
  }
}
