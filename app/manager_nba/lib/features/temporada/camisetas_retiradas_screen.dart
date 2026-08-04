import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/camisetas_repository.dart';
import '../../domain/carrera_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import 'carrera_jugador_screen.dart';

/// Las camisetas retiradas, como pantalla propia. En el menú vive dentro de
/// "Legado", que reutiliza [CamisetasRetiradasBody].
class CamisetasRetiradasScreen extends StatelessWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const CamisetasRetiradasScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camisetas retiradas')),
      body: CamisetasRetiradasBody(db: db, equipoUsuario: equipoUsuario),
    );
  }
}

/// Los números que ya no se vuelven a repartir, filtrados por franquicia:
/// se abre en la tuya, que es la que te interesa, y desde el desplegable se
/// puede ver la de cualquier otro equipo o la liga entera.
class CamisetasRetiradasBody extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const CamisetasRetiradasBody({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  State<CamisetasRetiradasBody> createState() => _CamisetasRetiradasBodyState();
}

/// Valor del desplegable que significa "todas las franquicias".
const _todaLaLiga = '__todos__';

class _CamisetasRetiradasBodyState extends State<CamisetasRetiradasBody> {
  late String _filtro = widget.equipoUsuario;
  late final Future<
      ({Map<String, List<CamisetaRetirada>> porEquipo, TemporadaData actual})>
      _futuro = _cargar();

  Future<
      ({
        Map<String, List<CamisetaRetirada>> porEquipo,
        TemporadaData actual
      })> _cargar() async {
    final porEquipo = await leerCamisetasRetiradasPorEquipo(widget.db);
    final actual = await leerTemporada(widget.db);
    return (porEquipo: porEquipo, actual: actual);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
        ({
          Map<String, List<CamisetaRetirada>> porEquipo,
          TemporadaData actual
        })>(
      future: _futuro,
      builder: (context, snapshot) {
        // Un fallo al leer tiene que verse: enseñar el mismo "no hay nada"
        // que cuando de verdad no hay nada convierte cualquier error en un
        // misterio de "la pantalla sale vacía".
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No se han podido cargar las camisetas '
                  'retiradas.\n${snapshot.error}'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final porEquipo = snapshot.data!.porEquipo;
        final actual = snapshot.data!.actual;
        // "temporada 1" no le dice nada a nadie: se traduce al mismo
        // formato de año que se usa en el resto del juego ("25-26"). Cada
        // temporada avanza el año en 1 al mismo ritmo que su número, así
        // que basta con la distancia a la actual.
        String etiquetaTemporada(int numero) => etiquetaDeTemporada(
            actual.anioInicio - (actual.numero - numero));
        if (porEquipo.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no hay ninguna camiseta retirada en la liga. '
                'Cuando se retire una leyenda podrás honrarla.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Tu equipo primero; el resto por nombre.
        final conCamisetas = porEquipo.keys.toList()
          ..sort((a, b) {
            if (a == widget.equipoUsuario) return -1;
            if (b == widget.equipoUsuario) return 1;
            return nombreDeEquipoEnFicha(a)
                .compareTo(nombreDeEquipoEnFicha(b));
          });

        final visibles = _filtro == _todaLaLiga
            ? conCamisetas
            : conCamisetas.where((e) => e == _filtro).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Franquicia',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                initialValue: _filtro,
                items: [
                  const DropdownMenuItem(
                    value: _todaLaLiga,
                    child: Text('Toda la liga'),
                  ),
                  // Tu equipo sale aunque no tenga ninguna todavía: es el
                  // que abres por defecto y tiene que poder elegirse.
                  for (final equipo in {widget.equipoUsuario, ...conCamisetas})
                    DropdownMenuItem(
                      value: equipo,
                      // Ojo con el ancho aquí: para medir sus opciones, el
                      // desplegable las monta sin límite horizontal, y
                      // cualquier hijo con flex (Flexible o Expanded) revienta
                      // el layout contra esa anchura infinita — y se lleva por
                      // delante la pantalla entera, que se queda en blanco.
                      // De ahí el ancho fijo y el mainAxisSize.min.
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EquipoLogo(codigoEquipo: equipo, tamano: 18),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 200,
                            child: Text(nombreDeEquipoEnFicha(equipo),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                ],
                onChanged: (valor) =>
                    valor == null ? null : setState(() => _filtro = valor),
              ),
            ),
            Expanded(
              child: visibles.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '${nombreDeEquipoEnFicha(_filtro)} todavía no ha '
                          'retirado ninguna camiseta.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: visibles
                          .map((equipo) => _BloqueEquipo(
                                db: widget.db,
                                equipo: equipo,
                                camisetas: porEquipo[equipo]!,
                                esTuEquipo: equipo == widget.equipoUsuario,
                                etiquetaTemporada: etiquetaTemporada,
                              ))
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _BloqueEquipo extends StatelessWidget {
  final AppDatabase db;
  final String equipo;
  final List<CamisetaRetirada> camisetas;
  final bool esTuEquipo;
  final String Function(int numero) etiquetaTemporada;

  const _BloqueEquipo({
    required this.db,
    required this.equipo,
    required this.camisetas,
    required this.esTuEquipo,
    required this.etiquetaTemporada,
  });

  @override
  Widget build(BuildContext context) {
    final info = infoDe(equipo);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: info.colorPrimario),
            child: Row(
              children: [
                EquipoLogo(codigoEquipo: equipo, tamano: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    // `nombreDeEquipoEnFicha` y no `info.nombreCompleto`:
                    // las camisetas se retiran también en franquicias que ya
                    // no existen —Chris Paul la tiene en los New Orleans
                    // Hornets (NOH)— y para esos códigos `infoDe` devuelve
                    // una ficha vacía, así que la cabecera salía en blanco.
                    nombreDeEquipoEnFicha(equipo),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textoSobre(info.colorPrimario)),
                  ),
                ),
                if (esTuEquipo)
                  Text('TU EQUIPO',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textoSecundarioSobre(info.colorPrimario))),
              ],
            ),
          ),
          ...camisetas.map((c) => ListTile(
                dense: true,
                leading: SizedBox(
                  width: 44,
                  child: Text('#${c.dorsal}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                title: Text(c.nombreJugador),
                // 0 marca historia real, de antes de tu partida (ver
                // legado_historico_repository.dart): ninguna temporada
                // jugada de verdad llega nunca a valer 0.
                subtitle: Text(c.temporada == 0
                    ? 'Retirada real de la franquicia'
                    : 'Retirada en la ${etiquetaTemporada(c.temporada)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  // Para ficha, no para Hall of Fame: una leyenda que se
                  // retire en tu primera temporada no tiene ni un año
                  // archivado, y su carrera existe igual.
                  final carrera =
                      await leerCarreraParaFicha(db, c.jugadorId);
                  if (!context.mounted) return;
                  await Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => CarreraJugadorScreen(
                      db: db,
                      carrera: carrera,
                      nombreSiNoHayCarrera: c.nombreJugador,
                      equipoDestacado: equipo,
                      esHistoriaReal: c.jugadorId < 0,
                      // Esta ficha va de ESTA camiseta: sus años y sus
                      // números con esta franquicia, no su carrera entera
                      // (alguien puede tenerla retirada en tres equipos).
                      equipoDeLaCamiseta: equipo,
                    ),
                  ));
                },
              )),
        ],
      ),
    );
  }
}
