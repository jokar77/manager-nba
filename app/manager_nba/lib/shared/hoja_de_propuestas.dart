import 'package:flutter/material.dart';

import '../i18n/textos.dart';
import '../data/database/app_database.dart';
import '../domain/entrenadores_repository.dart' show formatearMillones;
import '../domain/picks_repository.dart';
import '../domain/posiciones.dart';
import '../domain/traspasos_repository.dart';
import 'equipo_logo.dart';

/// El contrato de un jugador en una línea: "3 años · 40,0M al año". La usan
/// tanto las ofertas entrantes de la CPU como el buscador automático de la
/// mesa de traspasos — antes cada una tenía la suya y no enseñaban lo mismo
/// (una el contrato, la otra la edad), así que juzgabas una propuesta con
/// menos datos que la otra según por dónde hubiera llegado.
String contratoEnUnaLinea(BuildContext context, Jugador j) {
  final anios = j.aniosContrato <= 1
      ? t(context).ultimoAnioContrato
      : t(context).aniosDeContrato(j.aniosContrato);
  return t(context).contratoAnioMillones(anios, formatearMillones(j.salario));
}

/// Los nombres de un lado del traspaso, con la ficha de cada jugador entre
/// paréntesis: posición, media y contrato — lo mismo que enseña una oferta
/// entrante de la CPU (ver `_lineaJugador` en `ofertas_screen.dart`), para
/// que buscar un traspaso a mano no se juzgue con menos información que
/// aceptar uno que te llega solo.
String _conFicha(
        BuildContext context, List<Jugador> jugadores, List<PickDraft> picks) =>
    [
      ...jugadores.map((j) => t(context).lineaJugadorOferta(j.nombreFicticio,
          etiquetaPosicion(j), j.media, contratoEnUnaLinea(context, j))),
      ...picks.map(etiquetaDePick),
    ].join(', ');

/// La lista de traspasos que ha encontrado el buscador automático. Todos
/// están ya aprobados por el otro equipo: si eliges uno, se cierra. La
/// usan tanto la mesa de traspasos (lupa sobre un jugador) como cualquier
/// otro sitio desde el que quieras "intentar traspasar" a alguien, p. ej.
/// la ficha de un jugador rival desde Clasificación.
class HojaDePropuestas extends StatelessWidget {
  final String titulo;
  final String vacio;
  final List<PropuestaTraspaso> propuestas;

  const HojaDePropuestas({
    super.key,
    required this.titulo,
    required this.vacio,
    required this.propuestas,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (propuestas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(vacio),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: propuestas.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = propuestas[i];
                    return ListTile(
                      isThreeLine: true,
                      leading: EquipoLogo(codigoEquipo: p.equipoRival),
                      title: Text(
                          t(context).recibesLabel +
                              _conFicha(context, p.jugadoresQueLlegan,
                                  p.picksQueLlegan),
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(
                          t(context).entregasLabel +
                              _conFicha(context, p.jugadoresQueSalen,
                                  p.picksQueSalen),
                          style: const TextStyle(fontSize: 13)),
                      trailing: FilledButton(
                        onPressed: () => Navigator.of(context).pop(p),
                        child: Text(t(context).traspasarBtn),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
