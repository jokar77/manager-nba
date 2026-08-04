import 'package:flutter/material.dart';

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
              const TabBar(tabs: [
                Tab(text: 'Puntos'),
                Tab(text: 'Asistencias'),
                Tab(text: 'Rebotes'),
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
            'En activo: todavía puede subir puestos',
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Todavía no hay estadísticas que mostrar.',
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
        return ListTile(
          dense: true,
          leading: SizedBox(
            width: 32,
            child: Text('${i + 1}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          title: Text(
            l.nombre,
            style: TextStyle(
              color: color,
              fontWeight: l.enActivo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: Text(
            _conSeparadores(l.total),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
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
