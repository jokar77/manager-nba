import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/estilo.dart';
import '../../data/database/app_database.dart';
import '../../domain/carrera_repository.dart';
import '../../domain/lideres_historicos_repository.dart';
import 'carrera_jugador_screen.dart';

/// Los líderes históricos de la liga: puntos, asistencias y rebotes de toda
/// la carrera (real más simulada, sin separar), en tres pestañas. Los que
/// siguen en activo van resaltados, para que se vea de un vistazo quién
/// puede todavía subir puestos. Tocar un nombre abre su ficha.
class LideresHistoricosBody extends StatefulWidget {
  final AppDatabase db;

  const LideresHistoricosBody({super.key, required this.db});

  @override
  State<LideresHistoricosBody> createState() => _LideresHistoricosBodyState();
}

class _LideresHistoricosBodyState extends State<LideresHistoricosBody> {
  late final Future<LideresHistoricos> _futuro =
      leerLideresHistoricos(widget.db);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LideresHistoricos>(
      future: _futuro,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final lideres = snapshot.data!;
        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(tabs: [
                Tab(text: t(context).ordenPuntos),
                Tab(text: t(context).ordenAsistencias),
                Tab(text: t(context).ordenRebotes),
              ]),
              const _LeyendaDeColor(),
              Expanded(
                child: TabBarView(
                  children: [
                    _ListaDeLideres(db: widget.db, lideres: lideres.puntos),
                    _ListaDeLideres(
                        db: widget.db, lideres: lideres.asistencias),
                    _ListaDeLideres(db: widget.db, lideres: lideres.rebotes),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Sin esto, el color de los activos es un misterio: un nombre en otro
/// color y a saber por qué.
class _LeyendaDeColor extends StatelessWidget {
  const _LeyendaDeColor();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: _colorDeActivo(context)),
          const SizedBox(width: 8),
          Text(
            t(context).enActivoLeyenda,
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

/// El color de los que siguen jugando. Sale del tema para que funcione
/// igual en claro y en oscuro.
Color _colorDeActivo(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

class _ListaDeLideres extends StatelessWidget {
  final AppDatabase db;
  final List<LiderHistorico> lideres;

  const _ListaDeLideres({required this.db, required this.lideres});

  @override
  Widget build(BuildContext context) {
    if (lideres.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(t(context).todaviaNoHayEstadisticas,
              textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: lideres.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final l = lideres[i];
        final color = l.enActivo ? _colorDeActivo(context) : null;
        final e = Estilo.de(context);
        return ListTile(
          dense: true,
          leading: SizedBox(
            width: 32,
            child: Text('${i + 1}',
                textAlign: TextAlign.center,
                style: cifra(e, tamano: 16, color: e.textoRotulo)),
          ),
          title: Text(
            mayus(l.nombre),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Los que siguen jugando, con su color; los retirados, en la
            // tinta apagada. Es la misma distinción de siempre, pero por
            // tinta y no por grosor: la condensada ya va gruesa.
            style: titular(e, tamano: 16, color: color ?? e.textoTenue),
          ),
          trailing: Text(
            _conSeparadores(l.total),
            maxLines: 1,
            style: cifra(e, tamano: 18, color: color),
          ),
          onTap: () => _abrirFicha(context, l),
        );
      },
    );
  }

  Future<void> _abrirFicha(BuildContext context, LiderHistorico l) async {
    // Las leyendas puras no tienen fila en `Jugadores`: su ficha se abre
    // solo con el nombre real y el bloque de carrera NBA se encarga del
    // resto.
    final carrera = l.jugadorId == null
        ? null
        : await leerCarreraParaFicha(db, l.jugadorId!);
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => CarreraJugadorScreen(
        db: db,
        carrera: carrera,
        nombreSiNoHayCarrera: l.nombreReal.isEmpty ? l.nombre : l.nombreReal,
        esHistoriaReal: l.jugadorId == null,
      ),
    ));
  }
}

/// 32292 -> "32.292". Los totales de carrera son números largos.
String _conSeparadores(int valor) {
  final texto = valor.toString();
  final partes = <String>[];
  for (var i = texto.length; i > 0; i -= 3) {
    partes.insert(0, texto.substring(i - 3 < 0 ? 0 : i - 3, i));
  }
  return partes.join('.');
}
