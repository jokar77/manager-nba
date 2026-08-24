import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/anuncios.dart';
import '../../domain/nueva_temporada_repository.dart' show leerTemporada;
import '../../domain/patrocinadores.dart';
import '../../domain/patrocinadores_repository.dart';
import '../../domain/permisos.dart';
import '../../domain/salarios.dart' show formatearSalario;
import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../shared/estilo.dart';

/// Un icono por categoría, para reconocerlas de un vistazo sin tener que
/// leer la etiqueta cada vez. Se usa de respaldo cuando no hay logo que
/// enseñar: ver `_LogoDePatrocinador`.
const _iconoPorCategoria = <String, IconData>{
  'estadio': Icons.stadium,
  'camiseta': Icons.checkroom,
  'bebida': Icons.local_drink,
  'ocio': Icons.park,
};

String _etiquetaDe(BuildContext context, String categoria) {
  final textos = t(context);
  switch (categoria) {
    case 'estadio':
      return textos.patrocinioEstadioLabel;
    case 'camiseta':
      return textos.patrocinioCamisetaLabel;
    case 'bebida':
      return textos.patrocinioBebidaLabel;
    default:
      return textos.patrocinioOcioLabel;
  }
}

/// La pretemporada te deja negociar los patrocinios del año: el pabellón,
/// la camiseta, la bebida oficial y el de ocio.
///
/// Cada categoría se despliega y enseña **hasta tres ofertas** de marcas
/// distintas de tu ciudad, cada una con su dinero al año y sus años de
/// contrato (ver `ofertasDe` en `patrocinadores.dart`). Se firma una, o
/// ninguna.
///
/// Tres cosas hacen que esto sea una decisión y no un botón de cobrar:
///
/// 1. **Cada una PIDE algo**, y se enseña en su tarjeta al lado del dinero
///    (ver `compromisoPorCategoria`). Un coste que se descubre después de
///    firmar no es una decisión, es una trampa.
/// 2. **Cuanto más largo el contrato, menos paga al año.** El corto es
///    dinero ya para fichar este verano; el largo es tranquilidad barata.
/// 3. **Lo firmado ocupa la categoría hasta que caduque.** Un contrato
///    heredado de un año anterior sale con candado: ni se cambia de marca
///    ni se rompe. Eso es lo que compraste al firmar largo.
class PatrocinadoresScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final VoidCallback onContinuar;

  const PatrocinadoresScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    required this.onContinuar,
  });

  @override
  State<PatrocinadoresScreen> createState() => _PatrocinadoresScreenState();
}

class _PatrocinadoresScreenState extends State<PatrocinadoresScreen> {
  Map<String, ContratoDePatrocinio>? _contratos;

  /// En qué temporada estamos. Hace falta para dos cosas: sacar las ofertas
  /// del año (`ofertasDe`) y porque el desbloqueo por vídeo dura exactamente
  /// una temporada (ver `permisos.dart`).
  int? _temporada;

  /// Las categorías que has firmado TÚ en esta visita a la pantalla.
  ///
  /// Es lo que separa "lo puedo cambiar" de "está firmado y no se toca". Un
  /// contrato que ya estaba al abrir la pantalla viene de un año anterior y
  /// sale con candado; lo que firmes aquí puedes deshacerlo mientras no
  /// pulses Continuar. Se lleva en memoria a propósito: en cuanto sales de
  /// la pantalla, deja de ser reciente, que es exactamente lo que significa.
  final _firmadosAhora = <String>{};

  /// Qué categoría está abierta. Solo una a la vez: con las cuatro abiertas
  /// son doce tarjetas y la pantalla deja de leerse.
  String? _abierta;

  /// Si se está enseñando el vídeo ahora mismo, para no dejar que se toque
  /// el botón dos veces y salgan dos anuncios.
  bool _viendoVideo = false;

  /// Si se puede firmar, sea por edición, por compra o porque ya se vio el
  /// vídeo de esta temporada.
  bool get _desbloqueados =>
      _temporada != null &&
      permisos.puede(Funcion.patrocinadores, temporada: _temporada);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final contratos = await leerContratosDePatrocinio(widget.db);
    final temporada = await leerTemporada(widget.db);
    if (!mounted) return;
    setState(() {
      _contratos = contratos;
      _temporada = temporada.numero;
    });
  }

  /// Enseña el vídeo recompensado y, si se vio entero, abre los cuatro
  /// patrocinadores durante esta temporada.
  ///
  /// Un vídeo abre los CUATRO, no uno. Que cada patrocinador costara el
  /// suyo sería peor diseño: lo óptimo pasaría a ser verlos los cuatro y
  /// se perdería la decisión, que es justo lo que dan los compromisos de
  /// `compromisoPorCategoria`.
  Future<void> _verVideo() async {
    if (_viendoVideo || _temporada == null) return;
    setState(() => _viendoVideo = true);

    final visto = await anuncios.mostrarRecompensado();
    if (!mounted) return;

    if (visto) {
      permisos.desbloquearPorVideo(Funcion.patrocinadores,
          temporada: _temporada!);
    }
    setState(() => _viendoVideo = false);

    if (!visto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(context).videoSinTerminar)),
      );
    }
  }

  /// Firma [oferta], o la deshace si ya estaba firmada.
  ///
  /// Optimista: se actualiza la pantalla al toque y se confirma con la base
  /// después. Firmar un patrocinio no tiene animación de carga que valga la
  /// pena esperar.
  Future<void> _alternarOferta(OfertaDePatrocinio oferta) async {
    final categoria = oferta.categoria;
    final yaEsta = _contratos?[categoria]?.clave == oferta.patrocinador.clave;

    setState(() {
      if (yaEsta) {
        _contratos!.remove(categoria);
        _firmadosAhora.remove(categoria);
      } else {
        _contratos![categoria] = ContratoDePatrocinio(
          categoria: categoria,
          clave: oferta.patrocinador.clave,
          bonusAnual: oferta.bonusAnual,
          aniosRestantes: oferta.anios,
        );
        _firmadosAhora.add(categoria);
      }
    });

    if (yaEsta) {
      await romperPatrocinio(widget.db, categoria);
    } else {
      await firmarPatrocinio(widget.db, oferta);
    }
  }

  /// Cierra la pantalla dejando puestos los compromisos de lo que hayas
  /// firmado. Se hace al confirmar y no en cada toque: así puedes probar
  /// combinaciones sin que cada una deje rastro, y lo que cuenta es con lo
  /// que sales de aquí.
  Future<void> _confirmar() async {
    await aplicarCompromisosDePatrocinio(widget.db);
    if (!mounted) return;
    widget.onContinuar();
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final contratos = _contratos;
    final temporada = _temporada;

    return Scaffold(
      appBar: barraDeClub(widget.equipoUsuario, textos.tituloPatrocinadores,
          conVolver: false),
      body: (contratos == null || temporada == null)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Text(textos.explicacionPatrocinadores,
                    style: TextStyle(fontSize: 13, color: e.textoTenue)),
                if (!_desbloqueados) ...[
                  const SizedBox(height: 14),
                  _AvisoBloqueados(
                    viendoVideo: _viendoVideo,
                    onVerVideo: _verVideo,
                  ),
                ],
                const SizedBox(height: 14),
                for (final categoria in categoriasPatrocinio)
                  _BloqueDeCategoria(
                    categoria: categoria,
                    ofertas: ofertasDe(widget.equipoUsuario, categoria,
                        temporada: temporada),
                    contrato: contratos[categoria],
                    // Con candado si venía firmado de un año anterior: eso
                    // no se toca hasta que caduque.
                    enVigorDeAntes: contratos.containsKey(categoria) &&
                        !_firmadosAhora.contains(categoria),
                    abierta: _abierta == categoria,
                    onAbrir: () => setState(
                        () => _abierta = _abierta == categoria ? null : categoria),
                    // Bloqueados, no se firma nada.
                    onFirmar: _desbloqueados ? _alternarOferta : null,
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (contratos != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    textos.margenPatrocinio(formatearSalario(
                        contratos.values.fold<int>(
                            0, (a, c) => a + c.bonusAnual))),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: e.bien),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _confirmar,
                  child: Text(textos.continuar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// El aviso de que los patrocinadores están bloqueados, con el botón del
/// vídeo. Solo sale en la versión gratuita y solo hasta que se ve el vídeo
/// de esa temporada.
class _AvisoBloqueados extends StatelessWidget {
  final bool viendoVideo;
  final VoidCallback onVerVideo;

  const _AvisoBloqueados({
    required this.viendoVideo,
    required this.onVerVideo,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);

    return PanelCortado(
      fondo: e.panel,
      corte: 12,
      borde: Border.all(color: e.linea),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, color: e.textoTenue, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(textos.patrocinadoresBloqueados,
                      style: TextStyle(fontSize: 13, color: e.textoTenue)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              // Deshabilitado mientras se enseña: dos toques seguidos
              // pedirían dos anuncios.
              onPressed: viendoVideo ? null : onVerVideo,
              icon: const Icon(Icons.play_circle_outline, size: 20),
              label: Text(textos.verVideoPatrocinadores),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una categoría: la cabecera que se toca para desplegar, y debajo sus
/// ofertas.
///
/// Se despliega en vez de enseñarlo todo porque cuatro categorías por tres
/// ofertas son doce tarjetas con su historia cada una: en un móvil eso es
/// scroll infinito y nadie compara nada. Cerrada, la cabecera ya dice lo
/// único que importa de un vistazo — si está firmada y por cuánto.
class _BloqueDeCategoria extends StatelessWidget {
  final String categoria;
  final List<OfertaDePatrocinio> ofertas;
  final ContratoDePatrocinio? contrato;

  /// Viene firmado de un año anterior: ni se cambia ni se rompe.
  final bool enVigorDeAntes;

  final bool abierta;
  final VoidCallback onAbrir;

  /// Null cuando está bloqueado por la edición gratuita.
  final ValueChanged<OfertaDePatrocinio>? onFirmar;

  const _BloqueDeCategoria({
    required this.categoria,
    required this.ofertas,
    required this.contrato,
    required this.enVigorDeAntes,
    required this.abierta,
    required this.onAbrir,
    required this.onFirmar,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final firmado = contrato != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PanelCortado(
        fondo: e.panel,
        corte: 12,
        borde: Border.all(color: firmado ? e.bien : e.linea),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Un contrato heredado no se despliega: no hay nada que elegir
            // hasta que caduque.
            InkWell(
              onTap: enVigorDeAntes ? null : onAbrir,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _Cabecera(
                  categoria: categoria,
                  contrato: contrato,
                  cuantasOfertas: ofertas.length,
                  enVigorDeAntes: enVigorDeAntes,
                  abierta: abierta,
                ),
              ),
            ),
            if (abierta && !enVigorDeAntes)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final oferta in ofertas)
                      _TarjetaDeOferta(
                        oferta: oferta,
                        elegida:
                            contrato?.clave == oferta.patrocinador.clave,
                        onFirmar: onFirmar == null
                            ? null
                            : () => onFirmar!(oferta),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// La línea de arriba de una categoría: qué es, qué tienes firmado y la
/// flecha de desplegar.
class _Cabecera extends StatelessWidget {
  final String categoria;
  final ContratoDePatrocinio? contrato;
  final int cuantasOfertas;
  final bool enVigorDeAntes;
  final bool abierta;

  const _Cabecera({
    required this.categoria,
    required this.contrato,
    required this.cuantasOfertas,
    required this.enVigorDeAntes,
    required this.abierta,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final c = contrato;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _LogoDePatrocinador(
            patrocinador: c?.patrocinador, categoria: categoria),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mayus(_etiquetaDe(context, categoria)),
                  style: rotulo(e, tamano: 9)),
              const SizedBox(height: 3),
              if (c == null)
                Text(textos.sinPatrocinioFirmado(cuantasOfertas),
                    style: TextStyle(fontSize: 12, color: e.textoTenue))
              else ...[
                Text(c.patrocinador?.nombre ?? _etiquetaDe(context, categoria),
                    style: titular(e, tamano: 15)),
                const SizedBox(height: 2),
                Text(
                  '+${formatearSalario(c.bonusAnual)} · '
                  '${textos.anios(c.aniosRestantes)}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: e.bien),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        // El candado sustituye a la flecha: si no se puede desplegar, una
        // flecha sería mentira.
        Icon(
          enVigorDeAntes
              ? Icons.lock_outline
              : (abierta ? Icons.expand_less : Icons.expand_more),
          color: e.textoTenue,
          size: 22,
        ),
      ],
    );
  }
}

/// Una oferta concreta: la marca, lo que paga, cuánto dura y lo que pide.
class _TarjetaDeOferta extends StatelessWidget {
  final OfertaDePatrocinio oferta;
  final bool elegida;

  /// Null cuando está bloqueado por la edición gratuita.
  final VoidCallback? onFirmar;

  const _TarjetaDeOferta({
    required this.oferta,
    required this.elegida,
    required this.onFirmar,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final p = oferta.patrocinador;
    final compromiso = oferta.compromiso;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: PanelCortado(
        fondo: elegida ? e.bien.withValues(alpha: 0.10) : e.fondo,
        corte: 10,
        borde: Border.all(color: elegida ? e.bien : e.linea),
        child: InkWell(
          onTap: onFirmar,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LogoDePatrocinador(
                        patrocinador: p, categoria: oferta.categoria),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nombre, style: titular(e, tamano: 15)),
                          const SizedBox(height: 2),
                          Text(textos.fundadoEnAnio(p.fundacion),
                              style: TextStyle(
                                  fontSize: 11, color: e.textoTenue)),
                          const SizedBox(height: 3),
                          // Lista 15 punto 7: con 2 líneas se cortaba la
                          // mayoría de las historias (153 de 386 ocupan 3
                          // en el catálogo). Con 3 se leen enteras casi
                          // todas; las 4 más largas del catálogo siguen
                          // recortándose, pero es la excepción, no la
                          // norma. La pantalla ya scrollea, así que una
                          // línea más no deja nada fuera de pantalla.
                          Text(p.historia,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: e.textoTenue)),
                        ],
                      ),
                    ),
                    Icon(
                      elegida
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: elegida ? e.bien : e.textoTenue,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // El dinero y los años juntos y en grande: es lo que
                // distingue una oferta de otra, y lo que se compara.
                Row(
                  children: [
                    Text('+${formatearSalario(oferta.bonusAnual)}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: e.bien)),
                    const SizedBox(width: 5),
                    Text(textos.alAnioSufijo,
                        style: TextStyle(fontSize: 11, color: e.textoTenue)),
                    const SizedBox(width: 10),
                    Icon(Icons.event_repeat, size: 14, color: e.textoTenue),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(textos.anios(oferta.anios),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: rotulo(e, tamano: 9)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Lo que pide a cambio, y AQUÍ, junto al dinero: un coste
                // que se descubre después de firmar no es una decisión, es
                // una trampa.
                Row(
                  children: [
                    Icon(
                        compromiso.esBueno
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 15,
                        color: compromiso.esBueno ? e.bien : e.mal),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        textos.eventos.etiquetaDeEfecto(compromiso.clave) ??
                            compromiso.clave,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: compromiso.esBueno ? e.bien : e.mal),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(textos.nPartidos(compromiso.partidos),
                        maxLines: 1, style: rotulo(e, tamano: 9)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// El logo de la marca, o el icono de la categoría si por lo que sea no hay
/// patrocinador o el fichero falta.
///
/// Va con un tamaño fijo de 46 px y no con el ancho suelto: los 386 logos
/// vienen recortados de hojas de contacto y no todos tienen exactamente la
/// misma proporción. Dejarlos crecer a su aire descuadraría las tarjetas
/// entre sí, que es lo primero que se nota al mirar la pantalla.
class _LogoDePatrocinador extends StatelessWidget {
  final Patrocinador? patrocinador;
  final String categoria;

  const _LogoDePatrocinador({
    required this.patrocinador,
    required this.categoria,
  });

  static const _lado = 46.0;

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final p = patrocinador;
    final respaldo =
        Icon(_iconoPorCategoria[categoria], color: e.textoTenue, size: 26);

    if (p == null) {
      return SizedBox(
          width: _lado, height: _lado, child: Center(child: respaldo));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        p.logo,
        width: _lado,
        height: _lado,
        fit: BoxFit.cover,
        // Un logo que falte no puede tumbar la pretemporada: se cae al
        // icono de la categoría, que es lo que había antes de que hubiera
        // logos.
        errorBuilder: (_, _, _) => SizedBox(
            width: _lado, height: _lado, child: Center(child: respaldo)),
      ),
    );
  }
}
