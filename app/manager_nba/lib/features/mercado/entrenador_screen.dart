import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/entrenadores_repository.dart';
import '../../domain/equipos_info.dart';
import '../../shared/pantalla.dart';

/// Tu banquillo: quién lo ocupa, qué hace por el equipo, y el mercado de
/// entrenadores libres para cambiarlo.
class EntrenadorScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  const EntrenadorScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
  });

  @override
  State<EntrenadorScreen> createState() => _EntrenadorScreenState();
}

class _EstadoDelBanquillo {
  final Entrenador? actual;
  final ({int victorias, int derrotas}) record;
  final List<Entrenador> libres;

  /// Quién de los libres aceptaría venir. Se resuelve aquí y no en la fila
  /// para no lanzar una consulta por cada candidato mientras se dibuja.
  final Set<int> aceptarian;

  final int mediaDelEquipo;

  const _EstadoDelBanquillo({
    required this.actual,
    required this.record,
    required this.libres,
    required this.aceptarian,
    required this.mediaDelEquipo,
  });
}

class _EntrenadorScreenState extends State<EntrenadorScreen> {
  late Future<_EstadoDelBanquillo> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<_EstadoDelBanquillo> _cargar() async {
    final actual = await leerEntrenadorDe(widget.db, widget.equipoUsuario);
    final libres = await leerEntrenadoresLibres(widget.db);
    final aceptarian = <int>{};
    for (final candidato in libres) {
      if (await aceptariaDirigirA(widget.db, candidato, widget.equipoUsuario)) {
        aceptarian.add(candidato.id);
      }
    }
    return _EstadoDelBanquillo(
      actual: actual,
      record: await recordDeEstaTemporada(widget.db, widget.equipoUsuario),
      libres: libres,
      aceptarian: aceptarian,
      mediaDelEquipo:
          await mediaDeLosCincoMejores(widget.db, widget.equipoUsuario),
    );
  }

  void _recargar() => setState(() => _futuro = _cargar());

  Future<void> _contratar(Entrenador candidato) async {
    final motivo = await contratarEntrenador(
        widget.db, candidato.id, widget.equipoUsuario);
    if (!mounted) return;

    final mensaje = switch (motivo) {
      null => '${candidato.nombreFicticio} es tu nuevo entrenador',
      MotivoDeRechazo.yaTieneEquipo =>
        '${candidato.nombreFicticio} ya ha firmado por otro equipo',
      MotivoDeRechazo.noLeConvenceElProyecto =>
        '${candidato.nombreFicticio} ha rechazado la oferta: no le convence '
            'el proyecto',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
    _recargar();
  }

  Future<void> _despedir(Entrenador actual) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Despedir a ${actual.nombreFicticio}?'),
        content: const Text(
            'Se quedará libre y podrá firmar por cualquier equipo, tú '
            'incluido. Hasta que fiches a otro, tu equipo jugará sin '
            'entrenador.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Despedir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await despedirEntrenador(widget.db, widget.equipoUsuario);
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrenador')),
      body: FutureBuilder<_EstadoDelBanquillo>(
        future: _futuro,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final estado = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              _BanquilloActual(
                entrenador: estado.actual,
                equipo: widget.equipoUsuario,
                record: estado.record,
                onDespedir: estado.actual == null
                    ? null
                    : () => _despedir(estado.actual!),
              ),
              const SizedBox(height: 20),
              Text('Entrenadores libres',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'La media de tu equipo es ${estado.mediaDelEquipo}. Cuanto '
                'mejor es un entrenador, mejor tiene que ser el proyecto para '
                'que acepte.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              if (estado.libres.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                      child: Text('No hay ningún entrenador sin equipo')),
                )
              else
                ...estado.libres.map((candidato) => _FilaCandidato(
                      entrenador: candidato,
                      aceptaria: estado.aceptarian.contains(candidato.id),
                      onContratar: () => _contratar(candidato),
                    )),
            ],
          );
        },
      ),
    );
  }
}

/// La ficha grande del que dirige ahora mismo.
class _BanquilloActual extends StatelessWidget {
  final Entrenador? entrenador;
  final String equipo;
  final ({int victorias, int derrotas}) record;
  final VoidCallback? onDespedir;

  const _BanquilloActual({
    required this.entrenador,
    required this.equipo,
    required this.record,
    required this.onDespedir,
  });

  @override
  Widget build(BuildContext context) {
    final e = entrenador;
    if (e == null) {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: ListTile(
            leading: Icon(Icons.person_off),
            title: Text('Sin entrenador'),
            subtitle: Text(
                'Tu equipo juega sin banquillo. Ficha a alguien de la lista '
                'de abajo.'),
          ),
        ),
      );
    }

    final compacto = tamanoDe(context).esCompacto;
    final media = mediaDe(e);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Media(valor: media, grande: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.nombreFicticio,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        '${infoDe(equipo).apodo} · ${e.edad} años · '
                        '${estiloDeEntrenador(ataque: e.atrAtaque, defensa: e.atrDefensa, desarrollo: e.atrDesarrollo)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Facetas(entrenador: e, compacto: compacto),
            const SizedBox(height: 12),
            Text(
              _trayectoria(e, record),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onDespedir,
                icon: const Icon(Icons.logout),
                label: const Text('Despedir'),
                style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _trayectoria(Entrenador e, ({int victorias, int derrotas}) record) {
    final partes = <String>[
      'Esta temporada: ${record.victorias}-${record.derrotas}',
      if (e.temporadas > 0) '${e.temporadas} temporadas dirigiendo',
      if (e.anillos == 1) '1 anillo',
      if (e.anillos > 1) '${e.anillos} anillos',
      if (e.premios == 1) '1 Entrenador del Año',
      if (e.premios > 1) '${e.premios} veces Entrenador del Año',
    ];
    return partes.join(' · ');
  }
}

/// Una fila del mercado.
class _FilaCandidato extends StatelessWidget {
  final Entrenador entrenador;
  final bool aceptaria;
  final VoidCallback onContratar;

  const _FilaCandidato({
    required this.entrenador,
    required this.aceptaria,
    required this.onContratar,
  });

  @override
  Widget build(BuildContext context) {
    final e = entrenador;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Media(valor: mediaDe(e), grande: false),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.nombreFicticio,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        '${e.edad} años · '
                        '${estiloDeEntrenador(ataque: e.atrAtaque, defensa: e.atrDefensa, desarrollo: e.atrDesarrollo)}'
                        '${e.anillos > 0 ? ' · ${e.anillos} anillo${e.anillos > 1 ? 's' : ''}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                // El botón se deja siempre activo aunque se sepa que va a
                // decir que no: pulsarlo y que te rechacen es información
                // (te dice que tu equipo no da para tanto), y esconderlo
                // dejaría al usuario sin saber por qué no puede fichar.
                FilledButton(
                  onPressed: onContratar,
                  child: Text(aceptaria ? 'Contratar' : 'Ofrecer'),
                ),
              ],
            ),
            if (!aceptaria)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'No le convence tu proyecto ahora mismo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 8),
            _Facetas(entrenador: e, compacto: tamanoDe(context).esCompacto),
          ],
        ),
      ),
    );
  }
}

/// Las tres barras: ataque, defensa y desarrollo.
class _Facetas extends StatelessWidget {
  final Entrenador entrenador;
  final bool compacto;

  const _Facetas({required this.entrenador, required this.compacto});

  @override
  Widget build(BuildContext context) {
    final barras = [
      ('Ataque', entrenador.atrAtaque, const Color(0xFFE08A1E)),
      ('Defensa', entrenador.atrDefensa, const Color(0xFF3D7BFF)),
      ('Desarrollo', entrenador.atrDesarrollo, const Color(0xFF2E9E5B)),
    ];
    final widgets = barras
        .map((b) => _Barra(etiqueta: b.$1, valor: b.$2, color: b.$3))
        .toList();

    // En pantalla estrecha las tres barras van apiladas; en cuanto hay sitio,
    // en fila, que es donde se comparan de un vistazo.
    if (compacto) {
      return Column(
        children: [
          for (var i = 0; i < widgets.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            widgets[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < widgets.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: widgets[i]),
        ],
      ],
    );
  }
}

class _Barra extends StatelessWidget {
  final String etiqueta;
  final int valor;
  final Color color;

  const _Barra(
      {required this.etiqueta, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(etiqueta, style: Theme.of(context).textTheme.labelSmall),
            Text('$valor',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: valor / 99,
            minHeight: 6,
            color: color,
            backgroundColor: color.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}

class _Media extends StatelessWidget {
  final int valor;
  final bool grande;

  const _Media({required this.valor, required this.grande});

  @override
  Widget build(BuildContext context) {
    final lado = grande ? 56.0 : 42.0;
    return Container(
      width: lado,
      height: lado,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$valor',
          style: (grande
                  ? Theme.of(context).textTheme.headlineSmall
                  : Theme.of(context).textTheme.titleMedium)
              ?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      )),
    );
  }
}
