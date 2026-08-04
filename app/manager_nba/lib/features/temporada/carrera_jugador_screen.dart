import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/carrera_repository.dart';
import '../../domain/equipos_info.dart';
import '../../domain/legado_real_repository.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/tipo_premio.dart';
import '../../shared/equipo_logo.dart';

/// La carrera real (Kaggle) completa de alguien, con sus etapas por
/// equipo. Se pide en dos sitios de esta pantalla (la ficha entera y el
/// bloque de "solo esta camiseta"), así que el propio fetch vive en
/// [_cargarCarreraReal] para no repetirlo.
typedef CarreraYEtapasReales = ({CarreraReal? carrera, List<EtapaReal> etapas});

/// [carreraRealDe] y [etapasRealesDe] no dependen una de la otra: se lanzan
/// las dos a la vez (sin esperar la primera para pedir la segunda) y solo
/// se espera al final, en vez de encadenarlas en serie.
Future<CarreraYEtapasReales> _cargarCarreraReal(String nombreReal) async {
  final futuroCarrera = carreraRealDe(nombreReal);
  final futuroEtapas = etapasRealesDe(nombreReal);
  return (carrera: await futuroCarrera, etapas: await futuroEtapas);
}

/// La carrera completa de un jugador: sus etapas (equipo y de qué temporada
/// a cuál), sus medias, y sus trofeos colectivos e individuales.
///
/// Con [preguntarPorCamiseta] la pantalla termina con la decisión de
/// retirarle el dorsal, y devuelve `true` si dices que sí. En ese caso se
/// resaltan sus números en [equipoDestacado], que es donde se retiraría.
///
/// Con [esHistoriaReal] el mensaje sin datos cambia: no es que no llegara a
/// jugar contigo, es que es una leyenda real de antes de tu partida (ver
/// legado_historico_repository.dart) y el juego nunca simuló nada suyo.
///
/// Con [equipoDeLaCamiseta] la ficha se abre desde una camiseta retirada
/// concreta: el bloque de carrera real enseña solo lo que hizo con ESA
/// franquicia. Sin él (desde el Hall of Fame) enseña la carrera entera —
/// alguien como LeBron tiene la camiseta retirada en tres equipos, y cada
/// ficha tiene que hablar de la suya.
class CarreraJugadorScreen extends StatefulWidget {
  final AppDatabase db;
  final CarreraJugador? carrera;
  final String nombreSiNoHayCarrera;
  final String? equipoDestacado;
  final bool preguntarPorCamiseta;
  final bool esHistoriaReal;
  final String? equipoDeLaCamiseta;

  const CarreraJugadorScreen({
    super.key,
    required this.db,
    required this.carrera,
    required this.nombreSiNoHayCarrera,
    this.equipoDestacado,
    this.preguntarPorCamiseta = false,
    this.esHistoriaReal = false,
    this.equipoDeLaCamiseta,
  });

  @override
  State<CarreraJugadorScreen> createState() => _CarreraJugadorScreenState();
}

class _CarreraJugadorScreenState extends State<CarreraJugadorScreen> {
  // La carrera real (Kaggle) de quien SÍ tiene temporadas simuladas: se
  // unifica con lo simulado en una sola trayectoria y un solo palmarés, en
  // vez de contarse por separado como si fueran dos jugadores distintos.
  // No hace falta si ya se abre desde una camiseta concreta (esa vista va
  // de un único equipo, no de la carrera entera) ni si no hay nombre real
  // que buscar.
  // Se le añade la temporada en curso porque las etapas de tu partida se
  // guardan por número (1, 2, 3...) y en pantalla tienen que salir como
  // años de verdad.
  late final Future<({CarreraYEtapasReales real, TemporadaData temporada})>
      _realFuture = _cargarReal();

  Future<({CarreraYEtapasReales real, TemporadaData temporada})>
      _cargarReal() async {
    final c = widget.carrera;
    final futuroTemporada = leerTemporada(widget.db);
    // La carrera real se carga también cuando la ficha se abre desde una
    // camiseta retirada: es lo que hace que un jugador retirado DENTRO de tu
    // partida enseñe lo que hizo con esa franquicia en la NBA de verdad, y
    // no solo sus temporadas simuladas. Antes se saltaba este bloque y la
    // ficha de un recién retirado salía coja al lado de la de una leyenda.
    if (c == null || c.nombreReal.isEmpty) {
      return (
        real: (carrera: null, etapas: const <EtapaReal>[]),
        temporada: await futuroTemporada,
      );
    }
    return (
      real: await _cargarCarreraReal(c.nombreReal),
      temporada: await futuroTemporada,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.carrera;

    return Scaffold(
      appBar: AppBar(title: Text(c?.nombre ?? widget.nombreSiNoHayCarrera)),
      body: c == null
          // Sin carrera simulada. Si es una leyenda real (id negativo, ver
          // legado_historico_repository.dart) el nombre guardado ES su
          // nombre real, así que su carrera NBA de verdad sí se puede
          // enseñar directamente: es toda su historia. El mensaje
          // explicativo de antes ("es una leyenda real...") sobraba una vez
          // que el bloque de abajo ya lo cuenta todo por sí solo.
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!widget.esHistoriaReal)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'No llegó a completar ninguna temporada contigo.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                _CarreraRealBloque(
                  nombreReal: widget.nombreSiNoHayCarrera,
                  soloEsteEquipo: widget.equipoDeLaCamiseta,
                ),
              ],
            )
          : FutureBuilder<({CarreraYEtapasReales real, TemporadaData temporada})>(
              future: _realFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final real = snapshot.data!.real.carrera;
                final etapasReales = snapshot.data!.real.etapas;
                final temporada = snapshot.data!.temporada;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ResumenUnificado(carrera: c, real: real),
                    const SizedBox(height: 12),
                    // El bloque de "antes de tu partida" era una estimación
                    // (ptsPgReferencia y compañía) para cuando no había otra
                    // fuente; con carrera real de Kaggle disponible, esa
                    // historia ya sale con pelos y señales en la trayectoria
                    // de abajo, así que la estimación sobra.
                    if (c.vieneDeAntes && real == null)
                      _AntesDeTuPartida(carrera: c),
                    _Bloque(
                      titulo: 'Trayectoria',
                      hijos: _trayectoriaUnificada(
                          c, etapasReales, widget.equipoDestacado, temporada),
                    ),
                    _PalmaresBloque(db: widget.db, carrera: c, real: real),
                  ],
                );
              },
            ),
      bottomNavigationBar: !widget.preguntarPorCamiseta
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No retirar el dorsal'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.checkroom),
                      label: const Text('Retirar su camiseta'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

}

/// Una etapa de la trayectoria, venga de la NBA real o de tu partida. Los
/// años son de inicio de temporada (2025 = la 2025-26), que es lo que
/// permite ordenar y encadenar las dos fuentes en la misma escala.
typedef _Etapa = ({
  String equipo,
  int desdeAnio,
  int hastaAnio,
  int partidos,
  double puntos,
  double asistencias,
  double rebotes,
  List<String> trofeos,
});

/// Una sola lista de equipos en orden cronológico, del primero al último:
/// primero lo que jugó de verdad en la NBA real (si lo hay), después lo
/// simulado en tu partida — la carrera real siempre queda antes en el
/// tiempo, nunca se solapan. Antes eran dos bloques separados ("Su carrera
/// en la NBA real" iba aparte y encima), como si fueran dos jugadores.
///
/// Y si sigue en el mismo equipo al pasar de una fuente a la otra, va en UNA
/// fila: alguien que jugó su última temporada real en Houston y sigue ahí en
/// tu partida salía dos veces seguidas con el mismo escudo, una con "2025-26
/// a 2025-26" y otra con "temporada 1".
List<Widget> _trayectoriaUnificada(
  CarreraJugador c,
  List<EtapaReal> etapasReales,
  String? equipoDestacado,
  TemporadaData? temporadaActual,
) {
  final etapas = <_Etapa>[
    for (final e in [...etapasReales]
      ..sort((a, b) => a.primeraTemporada.compareTo(b.primeraTemporada)))
      (
        equipo: e.equipo,
        // El dataset nombra la temporada por el año en que TERMINA.
        desdeAnio: e.primeraTemporada - 1,
        hastaAnio: e.ultimaTemporada - 1,
        partidos: e.partidos,
        puntos: e.puntosPorPartido * e.partidos,
        asistencias: e.asistenciasPorPartido * e.partidos,
        rebotes: e.rebotesPorPartido * e.partidos,
        trofeos: <String>[
          if (e.anillos > 0)
            '${e.anillos} anillo${e.anillos == 1 ? '' : 's'}',
          if (e.mvpFinales > 0) '${e.mvpFinales} MVP de Finales',
          if (e.mvp > 0) '${e.mvp} MVP',
          if (e.mejorDefensor > 0) '${e.mejorDefensor} DPOY',
          if (e.allStar > 0) '${e.allStar} All-Star',
          if (e.quintetos > 0) '${e.quintetos} quintetos All-NBA',
        ],
      ),
    for (final e in c.etapas)
      (
        equipo: e.equipo,
        desdeAnio: temporadaActual == null
            ? e.desdeTemporada
            : anioDeTemporadaDesde(temporadaActual, e.desdeTemporada),
        hastaAnio: temporadaActual == null
            ? e.hastaTemporada
            : anioDeTemporadaDesde(temporadaActual, e.hastaTemporada),
        partidos: e.partidos,
        puntos: e.puntosPorPartido * e.partidos,
        asistencias: e.asistenciasPorPartido * e.partidos,
        rebotes: e.rebotesPorPartido * e.partidos,
        trofeos: const <String>[],
      ),
  ];

  final unidas = <_Etapa>[];
  for (final etapa in etapas) {
    final anterior = unidas.isEmpty ? null : unidas.last;
    if (anterior == null || anterior.equipo != etapa.equipo) {
      unidas.add(etapa);
      continue;
    }
    unidas[unidas.length - 1] = (
      equipo: anterior.equipo,
      desdeAnio: anterior.desdeAnio,
      hastaAnio: etapa.hastaAnio > anterior.hastaAnio
          ? etapa.hastaAnio
          : anterior.hastaAnio,
      partidos: anterior.partidos + etapa.partidos,
      puntos: anterior.puntos + etapa.puntos,
      asistencias: anterior.asistencias + etapa.asistencias,
      rebotes: anterior.rebotes + etapa.rebotes,
      trofeos: [...anterior.trofeos, ...etapa.trofeos],
    );
  }

  if (unidas.isEmpty) {
    return const [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No llegó a completar ninguna temporada contigo.'),
      )
    ];
  }
  return [
    for (final etapa in unidas)
      _FilaEtapa(
        etapa: etapa,
        destacado: etapa.equipo == equipoDestacado,
        sinAnioReal: temporadaActual == null,
      ),
  ];
}

/// El resumen de arriba, con los totales de carrera. Si hay carrera real de
/// Kaggle, sus partidos y estadísticas se suman a los simulados: la ficha
/// no debe distinguir entre "lo que hizo antes" y "lo que hizo contigo",
/// solo contar su carrera entera.
class _ResumenUnificado extends StatelessWidget {
  final CarreraJugador carrera;
  final CarreraReal? real;

  const _ResumenUnificado({required this.carrera, this.real});

  @override
  Widget build(BuildContext context) {
    final r = real;
    if (r == null) return _TarjetaResumen(carrera: carrera);

    final temporadas = r.temporadas + carrera.temporadas;
    final partidos = r.partidos + carrera.partidos;
    final puntos = r.puntos + carrera.puntos;
    final asistencias = r.asistencias + carrera.asistencias;
    final rebotes = r.rebotes + carrera.rebotes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('$temporadas temporadas · ${carrera.posicion} · '
                '$partidos partidos'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Dato('PTS', partidos == 0 ? 0 : puntos / partidos),
                _Dato('AST', partidos == 0 ? 0 : asistencias / partidos),
                _Dato('REB', partidos == 0 ? 0 : rebotes / partidos),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Totales: $puntos pts · $asistencias ast · $rebotes reb',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

/// El bloque de "Palmarés". Necesita la temporada actual de la partida para
/// traducir el número de temporada de cada premio al año real ("25-26"), así
/// que se carga una vez (cacheado en el estado, no en cada build) y hasta
/// entonces se enseña sin años — es mejor que bloquear toda la pantalla por
/// un dato que no cambia nunca a mitad de sesión.
class _PalmaresBloque extends StatefulWidget {
  final AppDatabase db;
  final CarreraJugador carrera;
  final CarreraReal? real;

  const _PalmaresBloque({required this.db, required this.carrera, this.real});

  @override
  State<_PalmaresBloque> createState() => _PalmaresBloqueState();
}

class _PalmaresBloqueState extends State<_PalmaresBloque> {
  late final Future<TemporadaData> _futuro = leerTemporada(widget.db);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TemporadaData>(
      future: _futuro,
      builder: (context, snapshot) {
        final actual = snapshot.data;
        String? etiquetaDe(int numero) =>
            actual == null ? null : etiquetaTemporadaDesde(actual, numero);
        return _Bloque(
          titulo: 'Palmarés',
          hijos: _palmares(widget.carrera, widget.real, etiquetaDe),
        );
      },
    );
  }

  /// Suma los premios reales (Kaggle) y los simulados en tu partida bajo la
  /// misma fila: antes iban en dos bloques distintos, como si un MVP real y
  /// un MVP ganado contigo no fueran el mismo trofeo. Los premios sin
  /// equivalente en el otro lado (MVP de Finales, All-Star y quintetos real
  /// solo existen en Kaggle; Rookie del Año y Más Mejorado solo se calculan
  /// dentro de la partida) se quedan como una fila propia.
  List<Widget> _palmares(
    CarreraJugador c,
    CarreraReal? real,
    String? Function(int) etiquetaDe,
  ) {
    final filas = <Widget>[];

    void agregar(
      String etiqueta,
      IconData icono,
      Color color, {
      int vecesSim = 0,
      int vecesReal = 0,
      List<int> temporadasSim = const [],
      List<int> aniosReales = const [],
    }) {
      final veces = vecesSim + vecesReal;
      if (veces <= 0) return;
      // El año va en los premios individuales que no se repiten en rachas
      // largas: un "x2" suelto dice menos que "MVP (1998, 24-25)". Los
      // reales van primero — siempre son anteriores en el tiempo a
      // cualquier temporada de tu partida. Los quintetos y el All-Star se
      // quedan solo con la cantidad: con carreras largas, listar cada año
      // sería ruido.
      final anios = [
        ...aniosReales.map(etiquetaTemporadaReal),
        ...temporadasSim.map(etiquetaDe).nonNulls,
      ];
      filas.add(_FilaTrofeo(
          etiqueta: etiqueta, icono: icono, color: color, veces: veces, anios: anios));
    }

    agregar('Campeón de la NBA', Icons.emoji_events, Colors.amber.shade700,
        vecesSim: c.anillos.length, vecesReal: real?.anillos ?? 0);
    agregar('NBA Cup', Icons.military_tech, Colors.blueAccent,
        vecesSim: c.copas.length);
    agregar('MVP', Icons.star, Colors.amber,
        vecesSim: c.vecesGano(TipoPremio.mvp),
        vecesReal: real?.mvp ?? 0,
        temporadasSim: c.temporadasDeGano(TipoPremio.mvp),
        aniosReales: real?.aniosMvp ?? const []);
    agregar('MVP de las Finales', Icons.workspace_premium,
        Colors.amber.shade800,
        vecesReal: real?.mvpFinales ?? 0,
        aniosReales: real?.aniosMvpFinales ?? const []);
    agregar('Mejor Defensor', Icons.shield, Colors.blueGrey,
        vecesSim: c.vecesGano(TipoPremio.mejorDefensor),
        vecesReal: real?.mejorDefensor ?? 0,
        temporadasSim: c.temporadasDeGano(TipoPremio.mejorDefensor),
        aniosReales: real?.aniosMejorDefensor ?? const []);
    agregar('All-Star', Icons.people, Colors.redAccent,
        vecesReal: real?.allStar ?? 0);
    agregar('Primer quinteto', Icons.looks_one, Colors.deepPurple,
        vecesSim: c.vecesGano(TipoPremio.primerQuinteto),
        vecesReal: real?.primerQuinteto ?? 0);
    agregar('Segundo quinteto', Icons.looks_two, Colors.deepPurple.shade200,
        vecesSim: c.vecesGano(TipoPremio.segundoQuinteto),
        vecesReal: real?.segundoQuinteto ?? 0);
    agregar('Tercer quinteto', Icons.looks_3, Colors.deepPurple.shade100,
        vecesReal: real?.tercerQuinteto ?? 0);
    agregar('Máximo anotador', Icons.local_fire_department, Colors.orange,
        vecesReal: real?.titulosDeAnotacion ?? 0,
        aniosReales: real?.aniosMaximoAnotador ?? const []);
    agregar('Rookie del Año', Icons.auto_awesome, Colors.teal,
        vecesSim: c.vecesGano(TipoPremio.rookieDelAno),
        temporadasSim: c.temporadasDeGano(TipoPremio.rookieDelAno));
    agregar('Más Mejorado', Icons.trending_up, Colors.green,
        vecesSim: c.vecesGano(TipoPremio.masMejorado),
        temporadasSim: c.temporadasDeGano(TipoPremio.masMejorado));

    if (filas.isEmpty) {
      filas.add(const ListTile(
        dense: true,
        title: Text('Sin títulos ni premios individuales.'),
      ));
    }
    return filas;
  }
}

class _TarjetaResumen extends StatelessWidget {
  final CarreraJugador carrera;

  const _TarjetaResumen({required this.carrera});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('${carrera.temporadasTotales} temporadas · '
                '${carrera.posicion} · ${carrera.partidos} partidos'),
            if (carrera.temporadasPrevias > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${carrera.temporadasPrevias} de ellas antes de que '
                  'cogieras el mando: de esas no hay estadísticas, las '
                  'medias de abajo son las de tu era.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Dato('PTS', carrera.puntosPorPartido),
                _Dato('AST', carrera.asistenciasPorPartido),
                _Dato('REB', carrera.rebotesPorPartido),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Totales: ${carrera.puntos} pts · ${carrera.asistencias} ast · '
              '${carrera.rebotes} reb',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

/// La carrera anterior a tu partida. De aquellos años el juego no tiene
/// boxscores —empezó a simular contigo—, así que se enseña lo único que se
/// sabe de verdad: cuántas temporadas llevaba y con qué producción llegó.
/// Mezclarlo con lo simulado sería inventarse unas medias de carrera.
class _AntesDeTuPartida extends StatelessWidget {
  final CarreraJugador carrera;

  const _AntesDeTuPartida({required this.carrera});

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: 18, color: outline),
                const SizedBox(width: 8),
                const Text('Antes de tu partida',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${carrera.temporadasPrevias} '
              '${carrera.temporadasPrevias == 1 ? "temporada" : "temporadas"} '
              'ya jugadas cuando cogiste el equipo.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Dato('PTS', carrera.ptsPgReferencia),
                _Dato('AST', carrera.astPgReferencia),
                _Dato('REB', carrera.trbPgReferencia),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Su producción de referencia al empezar la partida. De aquellos '
              'años no hay estadísticas partido a partido.',
              style: TextStyle(fontSize: 11, color: outline),
            ),
          ],
        ),
      ),
    );
  }
}

/// Su carrera en la NBA de verdad (datos de Kaggle), que es casi toda la
/// historia de un jugador que ya venía hecho cuando empezó tu partida: lo
/// simulado son cuatro años al final, y sin esto la ficha de una leyenda se
/// veía prácticamente vacía (un campeón real con Golden State que no vuelve
/// a ganar nada contigo aparecía sin un solo título).
///
/// Con [soloEsteEquipo] se enseña únicamente su etapa en esa franquicia —
/// es lo que pide la ficha de una camiseta retirada, que va de un equipo
/// concreto y no de la carrera entera: LeBron tiene tres camisetas
/// retiradas y cada una habla de sus años allí.
class _CarreraRealBloque extends StatefulWidget {
  final String nombreReal;
  final String? soloEsteEquipo;

  const _CarreraRealBloque({required this.nombreReal, this.soloEsteEquipo});

  @override
  State<_CarreraRealBloque> createState() => _CarreraRealBloqueState();
}

class _CarreraRealBloqueState extends State<_CarreraRealBloque> {
  // Cacheado en el estado: un FutureBuilder con el future creado en build()
  // relanzaría la lectura del asset en cada repintado.
  late final Future<CarreraYEtapasReales> _futuro = _cargar();

  Future<CarreraYEtapasReales> _cargar() async {
    final soloEquipo = widget.soloEsteEquipo;
    if (soloEquipo != null) {
      final etapa = await etapaRealCon(widget.nombreReal, soloEquipo);
      return (carrera: null, etapas: etapa == null ? <EtapaReal>[] : [etapa]);
    }
    return _cargarCarreraReal(widget.nombreReal);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CarreraYEtapasReales>(
      future: _futuro,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final carrera = snapshot.data!.carrera;
        final etapas = snapshot.data!.etapas;
        // Sin datos no se deja la pantalla en blanco: pasa con los pioneros
        // (Chuck Cooper, Bob Davies y compañía), que tienen la camiseta
        // retirada o están en el Hall of Fame pero jugaron antes de donde
        // llegan las estadísticas del dataset.
        if (carrera == null && etapas.isEmpty) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'De ${widget.nombreReal} no hay estadísticas de carrera: es '
                'de una época anterior a la que cubren los datos del juego. '
                'Su sitio en la historia está, los números no.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.soloEsteEquipo == null
                      ? 'Su carrera en la NBA real'
                      : 'Con ${infoDe(widget.soloEsteEquipo!).nombreCompleto} '
                          'en la NBA real',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (carrera != null) ...[
                  _ResumenReal(carrera: carrera),
                  const Divider(height: 24),
                  ..._trofeosDeCarrera(carrera),
                ],
                for (final etapa in etapas) _EtapaRealFila(etapa: etapa),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _trofeosDeCarrera(CarreraReal c) {
    final filas = <Widget>[];

    void agregar(String etiqueta, int veces, IconData icono, Color color,
        {List<int> anios = const []}) {
      if (veces <= 0) return;
      // El año va en los premios individuales que no se repiten en rachas
      // largas (MVP, DPOY...): "MVP (1988, 1991)" dice mucho más que un
      // "x2" suelto. All-Star y quintetos se quedan solo con la cantidad
      // — con carreras de 15+ apariciones, listar cada año sería ruido.
      filas.add(_FilaTrofeo(
        etiqueta: etiqueta,
        icono: icono,
        color: color,
        veces: veces,
        anios: anios.map(etiquetaTemporadaReal).toList(),
        contentPadding: EdgeInsets.zero,
      ));
    }

    agregar('Campeón de la NBA', c.anillos, Icons.emoji_events,
        Colors.amber.shade700);
    agregar('MVP', c.mvp, Icons.star, Colors.amber, anios: c.aniosMvp);
    agregar('MVP de las Finales', c.mvpFinales, Icons.workspace_premium,
        Colors.amber.shade800, anios: c.aniosMvpFinales);
    agregar('Mejor Defensor', c.mejorDefensor, Icons.shield, Colors.blueGrey,
        anios: c.aniosMejorDefensor);
    agregar('All-Star', c.allStar, Icons.people, Colors.redAccent);
    agregar('Primer quinteto', c.primerQuinteto, Icons.looks_one,
        Colors.deepPurple);
    agregar('Segundo quinteto', c.segundoQuinteto, Icons.looks_two,
        Colors.deepPurple.shade200);
    agregar('Tercer quinteto', c.tercerQuinteto, Icons.looks_3,
        Colors.deepPurple.shade100);
    agregar('Máximo anotador', c.titulosDeAnotacion, Icons.local_fire_department,
        Colors.orange, anios: c.aniosMaximoAnotador);

    if (filas.isEmpty) {
      filas.add(const ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text('Sin títulos ni premios en su carrera NBA.'),
      ));
    }
    return filas;
  }
}

class _ResumenReal extends StatelessWidget {
  final CarreraReal carrera;

  const _ResumenReal({required this.carrera});

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return Column(
      children: [
        Text(
          '${carrera.temporadas} temporadas · ${carrera.partidos} partidos',
          style: TextStyle(color: outline),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Dato('PTS', carrera.puntosPorPartido),
            _Dato('AST', carrera.asistenciasPorPartido),
            _Dato('REB', carrera.rebotesPorPartido),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Totales: ${carrera.puntos} pts · ${carrera.asistencias} ast · '
          '${carrera.rebotes} reb',
          style: TextStyle(fontSize: 12, color: outline),
        ),
      ],
    );
  }
}

class _EtapaRealFila extends StatelessWidget {
  final EtapaReal etapa;

  const _EtapaRealFila({required this.etapa});

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final trofeos = <String>[
      if (etapa.anillos > 0) '${etapa.anillos} anillo'
          '${etapa.anillos == 1 ? '' : 's'}',
      if (etapa.mvpFinales > 0) '${etapa.mvpFinales} MVP de Finales',
      if (etapa.mvp > 0) '${etapa.mvp} MVP',
      if (etapa.mejorDefensor > 0) '${etapa.mejorDefensor} DPOY',
      if (etapa.allStar > 0) '${etapa.allStar} All-Star',
      if (etapa.quintetos > 0) '${etapa.quintetos} quintetos All-NBA',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EquipoLogo(codigoEquipo: etapa.equipo, tamano: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombreDeEquipoEnFicha(etapa.equipo),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${etiquetaTemporadaReal(etapa.primeraTemporada)} a '
                  '${etiquetaTemporadaReal(etapa.ultimaTemporada)} · '
                  '${etapa.partidos} partidos',
                  style: TextStyle(fontSize: 12, color: outline),
                ),
                if (trofeos.isNotEmpty)
                  Text(trofeos.join(' · '),
                      style: TextStyle(fontSize: 12, color: outline)),
              ],
            ),
          ),
          Text(
            '${etapa.puntosPorPartido.toStringAsFixed(1)} / '
            '${etapa.asistenciasPorPartido.toStringAsFixed(1)} / '
            '${etapa.rebotesPorPartido.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Una fila de trofeo (icono + etiqueta + años opcionales + contador "xN").
/// La usan tanto el palmarés unificado (real+simulado) como el bloque de
/// "solo esta camiseta" — antes cada uno construía su propio ListTile con
/// la misma forma.
class _FilaTrofeo extends StatelessWidget {
  final String etiqueta;
  final IconData icono;
  final Color color;
  final int veces;
  final List<String> anios;
  final EdgeInsetsGeometry? contentPadding;

  const _FilaTrofeo({
    required this.etiqueta,
    required this.icono,
    required this.color,
    required this.veces,
    this.anios = const [],
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: contentPadding,
      leading: Icon(icono, color: color),
      title: Text(etiqueta),
      subtitle: anios.isEmpty ? null : Text(anios.join(', ')),
      trailing: Text('x$veces',
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _Dato extends StatelessWidget {
  final String etiqueta;
  final double valor;

  const _Dato(this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor.toStringAsFixed(1),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(etiqueta,
            style: TextStyle(color: Theme.of(context).colorScheme.outline)),
      ],
    );
  }
}

class _Bloque extends StatelessWidget {
  final String titulo;
  final List<Widget> hijos;

  const _Bloque({required this.titulo, required this.hijos});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            ...hijos,
          ],
        ),
      ),
    );
  }
}

/// Una etapa de la trayectoria: escudo, equipo, de qué temporada a cuál y lo
/// que hizo allí. El rango va siempre en temporadas de verdad ("2026-27"),
/// no en "temporada 1": el número interno no le dice nada a nadie.
class _FilaEtapa extends StatelessWidget {
  final _Etapa etapa;
  final bool destacado;

  /// Solo mientras no se sabe en qué año va la partida (la temporada actual
  /// se carga de la base). Se cae de vuelta al número de temporada.
  final bool sinAnioReal;

  const _FilaEtapa({
    required this.etapa,
    required this.destacado,
    this.sinAnioReal = false,
  });

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    String temporada(int anio) =>
        sinAnioReal ? 'temporada $anio' : etiquetaDeTemporada(anio);
    final rango = etapa.desdeAnio == etapa.hastaAnio
        ? temporada(etapa.desdeAnio)
        : '${temporada(etapa.desdeAnio)} a ${temporada(etapa.hastaAnio)}';
    final partidos = etapa.partidos;

    return ListTile(
      dense: true,
      leading: EquipoLogo(codigoEquipo: etapa.equipo, tamano: 28),
      title: Text(
        nombreDeEquipoEnFicha(etapa.equipo),
        style: TextStyle(
            fontWeight: destacado ? FontWeight.bold : FontWeight.normal),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$rango · $partidos partidos'),
          if (etapa.trofeos.isNotEmpty)
            Text(etapa.trofeos.join(' · '),
                style: TextStyle(fontSize: 12, color: outline)),
        ],
      ),
      trailing: Text(
        partidos == 0
            ? '—'
            : '${(etapa.puntos / partidos).toStringAsFixed(1)} / '
                '${(etapa.asistencias / partidos).toStringAsFixed(1)} / '
                '${(etapa.rebotes / partidos).toStringAsFixed(1)}',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
