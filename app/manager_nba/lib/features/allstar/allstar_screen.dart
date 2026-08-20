import 'package:flutter/material.dart';

import '../../i18n/textos.dart';
import '../../shared/estilo.dart';import 'package:sim_engine/sim_engine.dart' as sim;

import '../../data/database/app_database.dart';
import '../../domain/allstar_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/posiciones.dart';
import '../../domain/tipo_premio.dart';
import '../../shared/contraste.dart';
import '../../shared/equipo_logo.dart';
import '../partido/boxscore_screen.dart';

/// El fin de semana de las estrellas. Antes de que llegue la fecha, la
/// votación en directo: quién está entrando en el quinteto de cada
/// conferencia y por cuántos votos. Después, el resultado de los dos
/// partidos con sus MVP.
///
/// La convocatoria no es un sorteo: son los diez mejores de cada conferencia
/// por lo que están haciendo esta temporada, y los cinco primeros salen de
/// titulares. Los votos se calculan de ahí, así que la lista que ves
/// votándose es exactamente la que va a jugar.
class AllStarScreen extends StatefulWidget {
  final AppDatabase db;

  const AllStarScreen({super.key, required this.db});

  @override
  State<AllStarScreen> createState() => _AllStarScreenState();
}

/// Todo lo que hace falta para pintar la pantalla, cargado de una vez.
class _DatosAllStar {
  final List<ConvocadoAllStar> este;
  final List<ConvocadoAllStar> oeste;
  final List<ConvocadoAllStar> aspirantesEste;
  final List<ConvocadoAllStar> aspirantesOeste;
  final sim.Boxscore? allStar;
  final sim.Boxscore? risingStars;
  final Jugador? mvpAllStar;
  final Jugador? mvpRisingStars;

  /// Cuánta temporada regular se lleva jugada, de 0 a 1: es lo que decide si
  /// hay votación que enseñar y por dónde va el recuento.
  final double avance;

  const _DatosAllStar({
    required this.este,
    required this.oeste,
    required this.aspirantesEste,
    required this.aspirantesOeste,
    required this.allStar,
    required this.risingStars,
    required this.mvpAllStar,
    required this.mvpRisingStars,
    required this.avance,
  });

  bool get yaSeJugo => allStar != null;

  /// Antes del primer partido no hay nada que votar.
  bool get hayVotacion => avance > 0;
}

class _AllStarScreenState extends State<AllStarScreen>
    with SingleTickerProviderStateMixin {
  _DatosAllStar? _datos;

  /// El recuento subiendo. Va de 0 a 1 una sola vez y se queda quieto: es un
  /// efecto de entrada, no una animación en bucle.
  late final AnimationController _escrutinio = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _escrutinio.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final db = widget.db;
    final datos = _DatosAllStar(
      este: await convocatoriaDe(db, 'Este'),
      oeste: await convocatoriaDe(db, 'Oeste'),
      aspirantesEste: await aspirantesDe(db, 'Este'),
      aspirantesOeste: await aspirantesDe(db, 'Oeste'),
      allStar: await leerBoxscoreAllStar(db),
      risingStars: await leerBoxscoreRisingStars(db),
      mvpAllStar: await mvpDeLaTemporada(db, TipoPremio.mvpAllStar),
      mvpRisingStars: await mvpDeLaTemporada(db, TipoPremio.mvpRisingStars),
      avance: await avanceDeLaTemporada(db),
    );
    if (!mounted) return;
    setState(() => _datos = datos);
    _escrutinio.forward();
  }

  @override
  Widget build(BuildContext context) {
    final datos = _datos;
    return Scaffold(
      appBar: BarraNeutraAppBar(titulo: t(context).allStarWeekendMayus),
      body: datos == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _TarjetaPartido(
                  titulo: t(context).allStar,
                  subtituloPendiente: t(context).allStarSubtituloPendiente,
                  boxscore: datos.allStar,
                  mvp: datos.mvpAllStar,
                  icono: Icons.star,
                ),
                const SizedBox(height: 12),
                _TarjetaPartido(
                  titulo: t(context).risingStars,
                  subtituloPendiente: t(context).risingStarsSubtituloPendiente,
                  boxscore: datos.risingStars,
                  mvp: datos.mvpRisingStars,
                  icono: Icons.trending_up,
                ),
                const SizedBox(height: 20),
                // Sin un solo partido jugado no hay votación: enseñar el
                // recuento cerrado el día de la presentación era pura
                // decoración, porque no se había votado nada todavía.
                if (!datos.hayVotacion)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        t(context).votacionAbreCuandoRuedeBalonAviso,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else ...[
                  _CabeceraVotacion(
                    yaSeJugo: datos.yaSeJugo,
                    avance: datos.avance,
                    escrutinio: _escrutinio,
                  ),
                  const SizedBox(height: 8),
                  _ListaConferencia(
                    conferencia: 'Este',
                    convocados: datos.este,
                    aspirantes: datos.aspirantesEste,
                    escrutinio: _escrutinio,
                  ),
                  const SizedBox(height: 16),
                  _ListaConferencia(
                    conferencia: 'Oeste',
                    convocados: datos.oeste,
                    aspirantes: datos.aspirantesOeste,
                    escrutinio: _escrutinio,
                  ),
                ],
              ],
            ),
    );
  }
}

/// Uno de los dos partidos del fin de semana: o el aviso de que aún no toca,
/// o el marcador con su MVP y la puerta al boxscore.
class _TarjetaPartido extends StatelessWidget {
  final String titulo;
  final String subtituloPendiente;
  final sim.Boxscore? boxscore;
  final Jugador? mvp;
  final IconData icono;

  const _TarjetaPartido({
    required this.titulo,
    required this.subtituloPendiente,
    required this.boxscore,
    required this.mvp,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final b = boxscore;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, size: 20),
                const SizedBox(width: 8),
                Text(titulo,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (b == null)
              Text(subtituloPendiente,
                  style: TextStyle(color: Theme.of(context).colorScheme.outline))
            else ...[
              _Marcador(boxscore: b),
              if (mvp != null) ...[
                const SizedBox(height: 12),
                _FilaMvp(mvp: mvp!, boxscore: b),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: Text(t(context).verEstadisticasBtn),
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (context) => BoxscoreScreen(boxscore: b),
                  )),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Marcador extends StatelessWidget {
  final sim.Boxscore boxscore;

  const _Marcador({required this.boxscore});

  @override
  Widget build(BuildContext context) {
    final ganaLocal = boxscore.marcadorLocal > boxscore.marcadorVisitante;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LadoMarcador(
            equipo: boxscore.equipoLocal,
            puntos: boxscore.marcadorLocal,
            gana: ganaLocal),
        const Text('-', style: TextStyle(fontSize: 22)),
        _LadoMarcador(
            equipo: boxscore.equipoVisitante,
            puntos: boxscore.marcadorVisitante,
            gana: !ganaLocal),
      ],
    );
  }
}

class _LadoMarcador extends StatelessWidget {
  final String equipo;
  final int puntos;
  final bool gana;

  const _LadoMarcador(
      {required this.equipo, required this.puntos, required this.gana});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EquipoLogo(codigoEquipo: equipo, tamano: 34),
        const SizedBox(height: 4),
        Text(infoDe(equipo).apodo, style: const TextStyle(fontSize: 12)),
        Text('$puntos',
            style: TextStyle(
                fontSize: 26,
                fontWeight: gana ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}

/// El MVP con la línea que hizo en el partido.
class _FilaMvp extends StatelessWidget {
  final Jugador mvp;
  final sim.Boxscore boxscore;

  const _FilaMvp({required this.mvp, required this.boxscore});

  @override
  Widget build(BuildContext context) {
    final linea = [...boxscore.statsLocal, ...boxscore.statsVisitante]
        .where((e) => e.jugadorId == mvp.id.toString())
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A017).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFD4A017), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t(context).mvpConNombre(mvp.nombreFicticio),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (linea != null)
                  Text(
                      t(context).lineaMvpPtsAstReb(
                          linea.puntos, linea.asistencias, linea.rebotes),
                      style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          EquipoLogo(codigoEquipo: mvp.equipo, tamano: 24),
        ],
      ),
    );
  }
}

/// "Escrutado el 87%..." mientras suben los contadores, o el titular de que
/// la votación está cerrada si el partido ya se jugó.
class _CabeceraVotacion extends StatelessWidget {
  final bool yaSeJugo;

  /// Parte de temporada disputada: mientras no se acabe, la votación sigue
  /// abierta y lo que se enseña es un parcial, no un resultado.
  final double avance;
  final Animation<double> escrutinio;

  const _CabeceraVotacion({
    required this.yaSeJugo,
    required this.avance,
    required this.escrutinio,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: escrutinio,
      builder: (context, _) {
        final porcentaje = (escrutinio.value * 100).round();
        final jornadas = (avance * 100).round();
        final estado = porcentaje < 100
            ? t(context).escrutadoPorcentaje(porcentaje)
            : yaSeJugo
                ? t(context).recuentoCerradoAviso
                : t(context).votacionAbiertaConPorcentaje(jornadas);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                yaSeJugo
                    ? t(context).votacionFinalLabel
                    : t(context).votacionDeAficionadosLabel,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              estado,
              style: TextStyle(
                  fontSize: 12, color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: escrutinio.value, minHeight: 3),
          ],
        );
      },
    );
  }
}

/// La votación de una conferencia: titulares, suplentes y los que se han
/// quedado fuera.
class _ListaConferencia extends StatelessWidget {
  final String conferencia;
  final List<ConvocadoAllStar> convocados;
  final List<ConvocadoAllStar> aspirantes;
  final Animation<double> escrutinio;

  const _ListaConferencia({
    required this.conferencia,
    required this.convocados,
    required this.aspirantes,
    required this.escrutinio,
  });

  @override
  Widget build(BuildContext context) {
    final info = infoDe(conferencia);
    final maximo = convocados.isEmpty ? 1 : convocados.first.votos;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: info.colorPrimario,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
                mayus(t(context).conferenciaConNombre(conferencia == 'Oeste'
                    ? t(context).conferenciaOeste
                    : t(context).conferenciaEste)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titular(Estilo.de(context),
                    tamano: 17, color: textoSobre(info.colorPrimario))),
          ),
          for (var i = 0; i < convocados.length; i++) ...[
            if (i == 0) _Etiqueta(texto: t(context).titularesLabel),
            if (i == titularesPorConferencia)
              _Etiqueta(texto: t(context).suplentesLabel),
            _FilaVoto(
                convocado: convocados[i],
                maximoVotos: maximo,
                escrutinio: escrutinio),
          ],
          if (aspirantes.isNotEmpty) ...[
            _Etiqueta(texto: t(context).seQuedanFueraLabel),
            for (final a in aspirantes)
              _FilaVoto(
                  convocado: a,
                  maximoVotos: maximo,
                  escrutinio: escrutinio,
                  apagado: true),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;

  const _Etiqueta({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: Text(texto.toUpperCase(),
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.outline)),
    );
  }
}

/// Un candidato con su barra de votos subiendo.
class _FilaVoto extends StatelessWidget {
  final ConvocadoAllStar convocado;
  final int maximoVotos;
  final Animation<double> escrutinio;
  final bool apagado;

  const _FilaVoto({
    required this.convocado,
    required this.maximoVotos,
    required this.escrutinio,
    this.apagado = false,
  });

  @override
  Widget build(BuildContext context) {
    final j = convocado.jugador;
    final color = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: escrutinio,
      builder: (context, _) {
        final votos = (convocado.votos * escrutinio.value).round();
        final proporcion =
            maximoVotos == 0 ? 0.0 : votos / maximoVotos;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Opacity(
            opacity: apagado ? 0.55 : 1,
            child: Row(
              children: [
                EquipoLogo(codigoEquipo: j.equipo, tamano: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mayus(j.nombreFicticio),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: titular(Estilo.de(context),
                              tamano: 15,
                              // Los titulares del All-Star, con la tinta
                              // principal; los suplentes, apagados.
                              color: convocado.titular
                                  ? Estilo.de(context).texto
                                  : Estilo.de(context).textoTenue)),
                      Text(
                          t(context).posicionValoracion(etiquetaPosicion(j),
                              convocado.valoracion.toStringAsFixed(1)),
                          style:
                              TextStyle(fontSize: 11, color: color.outline)),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                            value: proporcion.clamp(0.0, 1.0), minHeight: 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 66,
                  child: Text(_formatearVotos(votos),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 1234567 -> "1.234.567". Los votos se leen mejor separados.
String _formatearVotos(int votos) {
  final texto = votos.toString();
  final partes = <String>[];
  for (var i = texto.length; i > 0; i -= 3) {
    partes.insert(0, texto.substring(i - 3 < 0 ? 0 : i - 3, i));
  }
  return partes.join('.');
}
