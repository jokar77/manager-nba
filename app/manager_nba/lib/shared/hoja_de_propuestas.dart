import 'package:flutter/material.dart';

import '../data/database/app_database.dart';
import '../domain/picks_repository.dart';
import '../domain/posiciones.dart';
import '../domain/traspasos_repository.dart';
import 'equipo_logo.dart';

/// Los nombres de un lado del traspaso, con la ficha de cada jugador entre
/// paréntesis. Sin la media no se puede juzgar una propuesta: la lista era
/// una fila de nombres sueltos y había que salirse a mirarlos uno a uno.
String _conFicha(List<Jugador> jugadores, List<PickDraft> picks) => [
      ...jugadores.map((j) =>
          '${j.nombreFicticio} (${etiquetaPosicion(j)}, ${j.media}, '
          '${j.edad} años)'),
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
                          'Recibes: '
                          '${_conFicha(p.jugadoresQueLlegan, p.picksQueLlegan)}',
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(
                          'Entregas: '
                          '${_conFicha(p.jugadoresQueSalen, p.picksQueSalen)}',
                          style: const TextStyle(fontSize: 13)),
                      trailing: FilledButton(
                        onPressed: () => Navigator.of(context).pop(p),
                        child: const Text('Traspasar'),
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
