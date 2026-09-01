import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/entrenadores_repository.dart';
import '../../domain/equipos_especiales.dart' show esFranquicia;
import '../../domain/equipos_info.dart';
import '../../domain/salarios.dart' show topeSalarial;
import '../../i18n/textos.dart';
import '../../shared/estilo.dart';
import '../../shared/barra_de_club.dart';
import '../../shared/entrenador_ui.dart';
import '../../shared/pantalla.dart';

const _colorAtaque = Color(0xFFE08A1E);
const _colorDefensa = Color(0xFF3D7BFF);
const _colorDesarrollo = Color(0xFF2E9E5B);

/// Tu banquillo: quién lo ocupa, qué contrato tiene, cuánto te queda de
/// presupuesto y el mercado de entrenadores libres.
class EntrenadorScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;

  /// Con esto puesto la pantalla es un TRÁMITE OBLIGATORIO: aparece una
  /// barra abajo con un botón de seguir que no se activa hasta que hay
  /// alguien en el banquillo, y otro para firmar al mejor que acepte el
  /// mínimo. Es lo que se usa en la pretemporada y cuando te quedas sin
  /// entrenador a mitad de año — jugar sin entrenador no es una opción, del
  /// mismo modo que no lo es salir a la pista con doce jugadores.
  ///
  /// Sin esto es la pantalla normal, a la que se entra desde el menú.
  final VoidCallback? onContinuar;

  const EntrenadorScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    this.onContinuar,
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

  /// La franquicia que dirige ahora mismo, o null si está sin equipo.
  /// Robarle el entrenador a otro cuesta más de convencer y deja a ese
  /// equipo buscando sustituto, así que hay que decirlo.
  final String? dirigeA;

  /// Cuánto proyecto le falta si le ofreces exactamente lo que pide. Sirve
  /// para saber si el dinero puede arreglarlo o no hay nada que hacer.
  final double loQueFalta;

  const _Candidato({
    required this.entrenador,
    required this.pide,
    required this.aniosQuePide,
    required this.aceptariaSuPrecio,
    required this.loQueFalta,
    this.dirigeA,
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
    for (final e in await leerEntrenadoresFichablesPor(db, equipo)) {
      final respuesta = await valorarOfertaDe(db, e, equipo);
      candidatos.add(_Candidato(
        entrenador: e,
        pide: salarioQuePide(e),
        aniosQuePide: aniosQuePide(e),
        aceptariaSuPrecio: respuesta.acepta,
        loQueFalta: respuesta.loQueFalta,
        dirigeA: esFranquicia(e.equipo) ? e.equipo : null,
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
        title: Text(t(context).despedirConfirmacion(actual.nombreFicticio)),
        content: Text(coste > 0
            ? t(context).despedirConTiempoRestante(
                actual.aniosContrato, formatearMillones(coste))
            : t(context).despedirSinContrato),
        actions: [
          BotonDialogoSecundario(
            texto: t(context).cancelar,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          BotonDialogoPrincipal(
            texto: t(context).despedir,
            color: Estilo.de(context).mal,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await despedirEntrenador(widget.db, widget.equipoUsuario);
    if (mounted) _recargar();
  }

  /// Firma al mejor que acepte el mínimo. Es la salida que impide que el
  /// trámite obligatorio se convierta en una trampa: siempre hay alguien.
  Future<void> _ficharPorElMinimo() async {
    final resultado =
        await ficharEntrenadorPorElMinimo(widget.db, widget.equipoUsuario);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(resultado.mensaje)));
    if (resultado.firmado) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final obligatorio = widget.onContinuar != null;
    final e = Estilo.de(context);
    return Scaffold(
      // La flecha de volver no hace nada en modo trámite: la barra usa
      // `maybePop`, y con la ruta marcada como no descartable se queda
      // quieta en vez de dejarte salir sin entrenador.
      appBar: barraDeClub(widget.equipoUsuario, t(context).entrenador),
      body: FutureBuilder<_EstadoDelBanquillo>(
        future: _futuro,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final estado = snapshot.data!;
          final tope = estado.presupuesto.libre;
          final libres = estado.libres.where((c) => c.dirigeA == null).toList();
          final conEquipo =
              estado.libres.where((c) => c.dirigeA != null).toList();

          Widget lista(List<_Candidato> cs) => Column(
                children: [
                  for (final c in cs) ...[
                    _FilaCandidato(
                      candidato: c,
                      cabeEnElPresupuesto: c.pide <= tope,
                      onNegociar: () => _negociar(c, tope),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              );

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              if (obligatorio && estado.actual == null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _AvisoObligatorio(),
                ),
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
              SeparadorSeccion(
                  titulo: '${t(context).agenciaLibre} · ${t(context).entrenador}',
                  acento: e.marca),
              const SizedBox(height: 6),
              Text(
                t(context).mediaDeTuEquipoEs(estado.mediaDelEquipo),
                style: TextStyle(fontSize: 12, color: e.textoTenue),
              ),
              const SizedBox(height: 10),
              if (libres.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                      child: Text(t(context).noHayEntrenadorSinEquipo)),
                )
              else
                lista(libres),
              if (conEquipo.isNotEmpty) ...[
                const SizedBox(height: 20),
                SeparadorSeccion(
                    titulo: t(context).dirigiendoAOtroEquipo, acento: e.marca),
                const SizedBox(height: 6),
                Text(
                  t(context).sePuedeOfertarPeroTrabajo,
                  style: TextStyle(fontSize: 12, color: e.textoTenue),
                ),
                const SizedBox(height: 10),
                lista(conEquipo),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: obligatorio
          ? SafeArea(
              child: FutureBuilder<_EstadoDelBanquillo>(
                future: _futuro,
                builder: (context, snapshot) {
                  final tieneEntrenador = snapshot.data?.actual != null;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        if (!tieneEntrenador) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _ficharPorElMinimo,
                              child: Text(t(context).ficharPorElMinimoBtn),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: FilledButton(
                            onPressed:
                                tieneEntrenador ? widget.onContinuar : null,
                            child: Text(t(context).continuar),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}

/// El cartel de "de aquí no se sale sin entrenador".
class _AvisoObligatorio extends StatelessWidget {
  const _AvisoObligatorio();

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return PanelCortado(
      fondo: e.mal.withValues(alpha: 0.14),
      corte: 12,
      borde: Border.all(color: e.mal),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: e.mal),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t(context).avisoObligatorioTexto,
                style: TextStyle(color: e.texto),
              ),
            ),
          ],
        ),
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
      title: Text(mayus(e.nombreFicticio)),
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
                  t(context).pideAlAnioYTemporadas(
                      formatearMillones(widget.candidato.pide),
                      widget.candidato.aniosQuePide),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Text('${t(context).sueldo}: '
                    '${t(context).alAnio(formatearMillones(_salario))}'),
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
                Text('${t(context).duracion}: ${t(context).anios(_anios)}'),
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
        BotonDialogoSecundario(
          texto: t(context).cancelar,
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        ),
        BotonDialogoPrincipal(
          texto: t(context).ofrecer,
          onPressed: _enviando || sinPresupuesto ? null : _ofrecer,
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
    final e = Estilo.de(context);
    if (sinPresupuesto) {
      return _Aviso(
        icono: Icons.money_off,
        color: e.mal,
        texto: t(context).noLlegaMasaSalarial(formatearMillones(topeDisponible)),
      );
    }
    if (respuesta.acepta) {
      return _Aviso(
        icono: Icons.check_circle,
        color: e.bien,
        texto: t(context).aceptariaLaOferta,
      );
    }
    // Que se distinga "sube un poco" de "olvídalo" es la información que
    // más falta hace: sin ella el usuario sube el deslizador a ciegas.
    final aTiro = respuesta.loQueFalta <= maxPuntosQueCompraElDinero;
    return _Aviso(
      icono: aTiro ? Icons.trending_up : Icons.block,
      color: e.mal,
      texto: aTiro
          ? t(context).todaviaNo
          : t(context).noVaAAceptar,
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
          child: Text(texto, style: TextStyle(fontSize: 12, color: color)),
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
    final e = Estilo.de(context);
    return PanelCortado(
      fondo: e.panel,
      corte: 12,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Todo flexible: en un iPhone estrecho el título y la cifra se
            // dan de bruces si van a lo ancho sin ceder.
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: e.marca),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(mayus(t(context).loQuePuedesOfrecer),
                      style: rotulo(e, tamano: 11)),
                ),
                const SizedBox(width: 8),
                Text(
                  formatearMillones(presupuesto.libre),
                  style: titular(e,
                      tamano: 17,
                      color: presupuesto.espacioEnElTope <= 0
                          ? e.mal
                          : e.texto),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LineaDeGasto(
                etiqueta: t(context).tuEntrenadorLabel,
                importe: presupuesto.sueldoDelActual),
            if (presupuesto.finiquitos > 0)
              _LineaDeGasto(
                etiqueta: t(context).finiquitos,
                importe: presupuesto.finiquitos,
                enRojo: true,
              ),
            _LineaDeGasto(
                etiqueta: t(context).masaSalarialConBanquillo,
                importe: presupuesto.masaSalarialTotal),
            _LineaDeGasto(
                etiqueta: t(context).topeDeLaFranquicia, importe: topeSalarial),
            const SizedBox(height: 8),
            Text(
              presupuesto.espacioEnElTope <= 0
                  ? t(context).porEncimaDelTopeSoloMinimo
                  : t(context).sueldoEntrenadorCuentaEnMasa,
              style: TextStyle(fontSize: 11.5, color: e.textoTenue),
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
    final e = Estilo.de(context);
    final color = enRojo ? e.mal : e.textoTenue;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(etiqueta, style: TextStyle(fontSize: 12, color: color))),
          const SizedBox(width: 8),
          Text(formatearMillones(importe),
              style: TextStyle(fontSize: 12, color: color)),
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
    final estilo = Estilo.de(context);
    final e = entrenador;
    if (e == null) {
      return PanelCortado(
        fondo: estilo.mal.withValues(alpha: 0.14),
        corte: 12,
        borde: Border.all(color: estilo.mal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.person_off, color: estilo.mal),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mayus(t(context).sinEntrenador),
                        style: titular(estilo, tamano: 16)),
                    const SizedBox(height: 2),
                    Text(t(context).sinEntrenadorDetalle,
                        style: TextStyle(
                            fontSize: 12, color: estilo.textoTenue)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final compacto = tamanoDe(context).esCompacto;
    return PanelCortado(
      fondo: estilo.panel,
      corte: 14,
      borde: Border.all(color: estilo.linea),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PlacaMedia(media: mediaDe(e), tamano: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mayus(e.nombreFicticio),
                          style: titular(estilo, tamano: 19)),
                      const SizedBox(height: 2),
                      Text(
                        '${infoDe(equipo).apodo} · '
                        '${t(context).edadJugador(e.edad)} · '
                        '${etiquetaDeEstilo(t(context), estiloDeEntrenador(ataque: e.atrAtaque, defensa: e.atrDefensa, desarrollo: e.atrDesarrollo))}',
                        style: TextStyle(
                            fontSize: 12, color: estilo.textoTenue),
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
              t(context).contratoResumen(
                  t(context).alAnio(formatearMillones(e.salario)),
                  t(context).anios(e.aniosContrato)),
              style: titular(estilo, tamano: 14),
            ),
            const SizedBox(height: 2),
            Text(
              _trayectoria(t(context), e, record),
              style: TextStyle(fontSize: 12, color: estilo.textoTenue),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onDespedir,
                icon: const Icon(Icons.logout),
                label: Text(t(context).despedir),
                style: TextButton.styleFrom(foregroundColor: estilo.mal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _trayectoria(
      Textos t, Entrenador e, ({int victorias, int derrotas}) record) {
    final partes = <String>[
      t.trayectoriaEstaTemporada(record.victorias, record.derrotas),
      if (e.temporadas > 0) t.temporadasDirigiendo(e.temporadas),
      if (e.anillos > 0) t.anillos(e.anillos),
      if (e.premios > 0) t.entrenadorDelAnio(e.premios),
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
    final estilo = Estilo.de(context);
    final e = candidato.entrenador;
    final compacto = tamanoDe(context).esCompacto;

    // El botón se deja activo aunque se sepa que va a decir que no: abrir la
    // negociación y ver POR QUÉ no acepta es información, y esconderlo
    // dejaría al usuario a ciegas.
    final boton = FilledButton(
      onPressed: onNegociar,
      child: Text(candidato.aceptariaSuPrecio
          ? t(context).negociar
          : t(context).ofrecer),
    );

    final identidad = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(mayus(e.nombreFicticio),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titular(estilo, tamano: 16)),
        if (candidato.dirigeA != null)
          Text(
            t(context).dirigeAEquipo(infoDe(candidato.dirigeA!).apodo),
            style: TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: estilo.marca),
          ),
        Text(
          '${t(context).edadJugador(e.edad)} · '
          '${etiquetaDeEstilo(t(context), estiloDeEntrenador(ataque: e.atrAtaque, defensa: e.atrDefensa, desarrollo: e.atrDesarrollo))}'
          '${e.anillos > 0 ? ' · ${t(context).anillos(e.anillos)}' : ''}',
          style: TextStyle(fontSize: 11.5, color: estilo.textoTenue),
        ),
        Text(
          t(context).pideImportePorAnios(
              formatearMillones(candidato.pide), candidato.aniosQuePide),
          style: titular(estilo, tamano: 13),
        ),
      ],
    );

    return PanelCortado(
      fondo: estilo.panelSuave,
      corte: 10,
      borde: Border.all(color: estilo.linea),
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
                PlacaMedia(media: mediaDe(e), tamano: 42),
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
                      ? t(context).noCabeEnPresupuesto
                      : candidato.imposible
                          ? t(context).proyectoLeQuedaLejos
                          : t(context).asuPrecioNo,
                  style: TextStyle(fontSize: 11.5, color: estilo.mal),
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
      (t(context).ataque, entrenador.atrAtaque, _colorAtaque),
      (t(context).defensa, entrenador.atrDefensa, _colorDefensa),
      (t(context).desarrollo, entrenador.atrDesarrollo, _colorDesarrollo),
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
    final e = Estilo.de(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(mayus(etiqueta), style: rotulo(e, tamano: 9)),
            Text('$valor', style: titular(e, tamano: 12)),
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
