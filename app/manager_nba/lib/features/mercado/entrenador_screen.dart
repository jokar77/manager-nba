import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/entrenadores_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/salarios.dart' show topeSalarial;
import '../../shared/pantalla.dart';

/// Tu banquillo: quién lo ocupa, qué contrato tiene, cuánto te queda de
/// presupuesto y el mercado de entrenadores libres.
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

/// Un candidato del mercado con lo que ya se sabe de él sin abrir la
/// negociación: qué pide y si le convencería tal cual.
class _Candidato {
  final Entrenador entrenador;
  final int pide;
  final int aniosQuePide;
  final bool aceptariaSuPrecio;

  /// Cuánto proyecto le falta si le ofreces exactamente lo que pide. Sirve
  /// para saber si el dinero puede arreglarlo o no hay nada que hacer.
  final double loQueFalta;

  const _Candidato({
    required this.entrenador,
    required this.pide,
    required this.aniosQuePide,
    required this.aceptariaSuPrecio,
    required this.loQueFalta,
  });

  /// Ni con el máximo de dinero y años se le convence.
  bool get imposible => loQueFalta > maxPuntosQueCompraElDinero + 1.2;
}

class _EstadoDelBanquillo {
  final Entrenador? actual;
  final ({int victorias, int derrotas}) record;
  final PresupuestoDeBanquillo presupuesto;
  final int costeDeDespido;
  final List<_Candidato> libres;
  final int mediaDelEquipo;

  const _EstadoDelBanquillo({
    required this.actual,
    required this.record,
    required this.presupuesto,
    required this.costeDeDespido,
    required this.libres,
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
    final db = widget.db;
    final equipo = widget.equipoUsuario;

    final candidatos = <_Candidato>[];
    for (final e in await leerEntrenadoresLibres(db)) {
      final respuesta = await valorarOfertaDe(db, e, equipo);
      candidatos.add(_Candidato(
        entrenador: e,
        pide: salarioQuePide(e),
        aniosQuePide: aniosQuePide(e),
        aceptariaSuPrecio: respuesta.acepta,
        loQueFalta: respuesta.loQueFalta,
      ));
    }

    return _EstadoDelBanquillo(
      actual: await leerEntrenadorDe(db, equipo),
      record: await recordDeEstaTemporada(db, equipo),
      presupuesto: await presupuestoDe(db, equipo),
      costeDeDespido: await costeDeDespedir(db, equipo),
      libres: candidatos,
      mediaDelEquipo: await mediaDeLosCincoMejores(db, equipo),
    );
  }

  void _recargar() => setState(() => _futuro = _cargar());

  Future<void> _negociar(_Candidato candidato, int tope) async {
    final resultado = await showDialog<ResultadoDeFichaje>(
      context: context,
      builder: (context) => _DialogoDeNegociacion(
        db: widget.db,
        equipoUsuario: widget.equipoUsuario,
        candidato: candidato,
        tope: tope,
      ),
    );
    if (resultado == null || !mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(resultado.mensaje)));
    if (resultado.firmado) _recargar();
  }

  Future<void> _despedir(Entrenador actual, int coste) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Despedir a ${actual.nombreFicticio}?'),
        content: Text(coste > 0
            ? 'Le quedan ${actual.aniosContrato} '
                '${actual.aniosContrato == 1 ? 'temporada' : 'temporadas'} de '
                'contrato y hay que pagárselas igual: '
                '${formatearMillones(coste)} que NO podrás gastarte en su '
                'sustituto hasta que se cumplan.'
            : 'Se quedará libre y podrá firmar por cualquier equipo. Hasta '
                'que fiches a otro, tu equipo jugará sin entrenador.'),
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
          final tope = estado.presupuesto.libre;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              _BanquilloActual(
                entrenador: estado.actual,
                equipo: widget.equipoUsuario,
                record: estado.record,
                onDespedir: estado.actual == null
                    ? null
                    : () => _despedir(estado.actual!, estado.costeDeDespido),
              ),
              const SizedBox(height: 12),
              _Presupuesto(presupuesto: estado.presupuesto),
              const SizedBox(height: 20),
              Text('Agencia libre de entrenadores',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'La media de tu equipo es ${estado.mediaDelEquipo}. Cuanto '
                'mejor es un entrenador, mejor proyecto pide — y el dinero '
                'solo tapa parte de la diferencia.',
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
                ...estado.libres.map((c) => _FilaCandidato(
                      candidato: c,
                      cabeEnElPresupuesto: c.pide <= tope,
                      onNegociar: () => _negociar(c, tope),
                    )),
            ],
          );
        },
      ),
    );
  }
}

/// El diálogo de oferta: sueldo y años, con la respuesta en vivo.
class _DialogoDeNegociacion extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final _Candidato candidato;
  final int tope;

  const _DialogoDeNegociacion({
    required this.db,
    required this.equipoUsuario,
    required this.candidato,
    required this.tope,
  });

  @override
  State<_DialogoDeNegociacion> createState() => _DialogoDeNegociacionState();
}

class _DialogoDeNegociacionState extends State<_DialogoDeNegociacion> {
  late int _salario;
  late int _anios;
  bool _enviando = false;

  /// El deslizador se mueve de cien mil en cien mil, igual que redondea la
  /// escala de sueldos.
  static const _paso = 100000;

  @override
  void initState() {
    super.initState();
    // Se empieza en lo que pide (o en el tope, si no da el presupuesto):
    // es la oferta que el usuario va a querer el 90% de las veces.
    _salario = widget.candidato.pide.clamp(
        salarioMinimoEntrenador, _maximo);
    _anios = widget.candidato.aniosQuePide;
  }

  int get _maximo {
    final tope = widget.tope;
    // Nunca por debajo del mínimo, o el deslizador se queda sin recorrido.
    return tope < salarioMinimoEntrenador ? salarioMinimoEntrenador : tope;
  }

  RespuestaDelEntrenador _respuestaCon(int mediaEquipo, int v, int d) {
    final e = widget.candidato.entrenador;
    return valorarOferta(
      mediaDelEntrenador: mediaDe(e),
      desarrolloDelEntrenador: e.atrDesarrollo,
      mediaDelEquipo: mediaEquipo,
      victorias: v,
      derrotas: d,
      salarioOfrecido: _salario,
      salarioPedido: widget.candidato.pide,
      aniosOfrecidos: _anios,
      aniosPedidos: widget.candidato.aniosQuePide,
    );
  }

  Future<void> _ofrecer() async {
    setState(() => _enviando = true);
    final resultado = await contratarEntrenador(
      widget.db,
      widget.candidato.entrenador.id,
      widget.equipoUsuario,
      salario: _salario,
      anios: _anios,
    );
    if (mounted) Navigator.of(context).pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.candidato.entrenador;
    final sinPresupuesto = widget.tope < salarioMinimoEntrenador;

    return AlertDialog(
      title: Text(e.nombreFicticio),
      content: SizedBox(
        // Alto fijo: sin esto el diálogo cambia de tamaño al mover el
        // deslizador, que es un tirón muy feo (ya pasó con las ofertas de
        // traspaso).
        width: 340,
        height: 300,
        child: FutureBuilder<
            ({int media, ({int victorias, int derrotas}) record})>(
          future: () async {
            return (
              media: await mediaDeLosCincoMejores(
                  widget.db, widget.equipoUsuario),
              record:
                  await recordDeEstaTemporada(widget.db, widget.equipoUsuario),
            );
          }(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final datos = snapshot.data!;
            final respuesta = _respuestaCon(
                datos.media, datos.record.victorias, datos.record.derrotas);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pide ${formatearMillones(widget.candidato.pide)} al año y '
                  '${widget.candidato.aniosQuePide} temporadas.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text('Sueldo: ${formatearMillones(_salario)} al año'),
                Slider(
                  value: _salario.toDouble().clamp(
                      salarioMinimoEntrenador.toDouble(), _maximo.toDouble()),
                  min: salarioMinimoEntrenador.toDouble(),
                  max: _maximo.toDouble(),
                  divisions: ((_maximo - salarioMinimoEntrenador) ~/ _paso)
                      .clamp(1, 1000),
                  onChanged: sinPresupuesto
                      ? null
                      : (v) => setState(() => _salario =
                          (v / _paso).round() * _paso),
                ),
                Text('Duración: $_anios '
                    '${_anios == 1 ? 'temporada' : 'temporadas'}'),
                Slider(
                  value: _anios.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) => setState(() => _anios = v.round()),
                ),
                const Spacer(),
                _Veredicto(
                  respuesta: respuesta,
                  sinPresupuesto: sinPresupuesto,
                  topeDisponible: widget.tope,
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando || sinPresupuesto ? null : _ofrecer,
          child: const Text('Ofrecer'),
        ),
      ],
    );
  }
}

/// Qué diría el entrenador a la oferta que hay puesta ahora mismo.
class _Veredicto extends StatelessWidget {
  final RespuestaDelEntrenador respuesta;
  final bool sinPresupuesto;
  final int topeDisponible;

  const _Veredicto({
    required this.respuesta,
    required this.sinPresupuesto,
    required this.topeDisponible,
  });

  @override
  Widget build(BuildContext context) {
    if (sinPresupuesto) {
      return _Aviso(
        icono: Icons.money_off,
        color: Theme.of(context).colorScheme.error,
        texto: 'No te llega la masa salarial: solo puedes ofrecer '
            '${formatearMillones(topeDisponible)}.',
      );
    }
    if (respuesta.acepta) {
      return _Aviso(
        icono: Icons.check_circle,
        color: const Color(0xFF2E9E5B),
        texto: 'Aceptaría esta oferta.',
      );
    }
    // Que se distinga "sube un poco" de "olvídalo" es la información que
    // más falta hace: sin ella el usuario sube el deslizador a ciegas.
    final aTiro = respuesta.loQueFalta <= maxPuntosQueCompraElDinero;
    return _Aviso(
      icono: aTiro ? Icons.trending_up : Icons.block,
      color: Theme.of(context).colorScheme.error,
      texto: aTiro
          ? 'Todavía no. Con más dinero o más años puede cambiar de idea.'
          : 'No va a aceptar: tu proyecto le queda lejos y el dinero no lo '
              'arregla.',
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;

  const _Aviso(
      {required this.icono, required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(texto,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color)),
        ),
      ],
    );
  }
}

/// En qué se te va el presupuesto de banquillo.
class _Presupuesto extends StatelessWidget {
  final PresupuestoDeBanquillo presupuesto;

  const _Presupuesto({required this.presupuesto});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Todo flexible: en un iPhone estrecho el título y la cifra se
            // dan de bruces si van a lo ancho sin ceder.
            // Todo flexible: en un iPhone estrecho el título y la cifra se
            // dan de bruces si van a lo ancho sin ceder.
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Lo que puedes ofrecer',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                const SizedBox(width: 8),
                Text(
                  formatearMillones(presupuesto.libre),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: presupuesto.espacioEnElTope <= 0
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _LineaDeGasto(
                etiqueta: 'Tu entrenador',
                importe: presupuesto.sueldoDelActual),
            if (presupuesto.finiquitos > 0)
              _LineaDeGasto(
                etiqueta: 'Finiquitos de despedidos',
                importe: presupuesto.finiquitos,
                enRojo: true,
              ),
            _LineaDeGasto(
                etiqueta: 'Masa salarial (con banquillo)',
                importe: presupuesto.masaSalarialTotal),
            _LineaDeGasto(
                etiqueta: 'Tope de la franquicia', importe: topeSalarial),
            const SizedBox(height: 6),
            Text(
              presupuesto.espacioEnElTope <= 0
                  ? 'Estás por encima del tope: solo puedes firmar por el '
                      'sueldo mínimo.'
                  : 'El sueldo del entrenador cuenta en tu masa salarial: lo '
                      'que gastes aquí no lo tienes para jugadores.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LineaDeGasto extends StatelessWidget {
  final String etiqueta;
  final int importe;
  final bool enRojo;

  const _LineaDeGasto({
    required this.etiqueta,
    required this.importe,
    this.enRojo = false,
  });

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodySmall?.copyWith(
        color: enRojo ? Theme.of(context).colorScheme.error : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(child: Text(etiqueta, style: estilo)),
          const SizedBox(width: 8),
          Text(formatearMillones(importe), style: estilo),
        ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Media(valor: mediaDe(e), grande: true),
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
              '${formatearMillones(e.salario)} al año · '
              '${e.aniosContrato} '
              '${e.aniosContrato == 1 ? 'temporada' : 'temporadas'} de '
              'contrato',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              _trayectoria(e, record),
              style: Theme.of(context).textTheme.bodySmall,
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
  final _Candidato candidato;
  final bool cabeEnElPresupuesto;
  final VoidCallback onNegociar;

  const _FilaCandidato({
    required this.candidato,
    required this.cabeEnElPresupuesto,
    required this.onNegociar,
  });

  @override
  Widget build(BuildContext context) {
    final e = candidato.entrenador;
    final compacto = tamanoDe(context).esCompacto;

    // El botón se deja activo aunque se sepa que va a decir que no: abrir la
    // negociación y ver POR QUÉ no acepta es información, y esconderlo
    // dejaría al usuario a ciegas.
    final boton = FilledButton(
      onPressed: onNegociar,
      child: Text(candidato.aceptariaSuPrecio ? 'Negociar' : 'Ofrecer'),
    );

    final identidad = Column(
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
        Text(
          'Pide ${formatearMillones(candidato.pide)} × '
          '${candidato.aniosQuePide} '
          '${candidato.aniosQuePide == 1 ? 'año' : 'años'}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En un iPhone en vertical no caben a lo ancho la media, el
            // nombre con lo que pide y el botón: se desbordaba por 204px.
            // Con el botón debajo cabe todo y además el objetivo táctil
            // queda más grande.
            Row(
              children: [
                _Media(valor: mediaDe(e), grande: false),
                const SizedBox(width: 12),
                Expanded(child: identidad),
                if (!compacto) boton,
              ],
            ),
            if (compacto)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(width: double.infinity, child: boton),
              ),
            if (!cabeEnElPresupuesto || !candidato.aceptariaSuPrecio)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  !cabeEnElPresupuesto
                      ? 'No te cabe en el presupuesto de banquillo'
                      : candidato.imposible
                          ? 'Tu proyecto le queda lejos'
                          : 'A su precio diría que no; con más dinero, quizá',
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
