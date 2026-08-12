import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/carrera_repository.dart';
import '../../domain/hall_fama_repository.dart';
import '../../domain/nueva_temporada_repository.dart';
import 'carrera_jugador_screen.dart';

/// El Hall of Fame como pantalla propia. Se usa durante el cambio de año
/// (con [onContinuar]); en el menú vive dentro de "Legado", que reutiliza
/// [HallDeLaFamaBody].
///
/// Con [nuevosIds] se resaltan los que acaban de entrar esta temporada.
class HallDeLaFamaScreen extends StatelessWidget {
  final AppDatabase db;
  final Set<int> nuevosIds;
  final VoidCallback? onContinuar;

  const HallDeLaFamaScreen({
    super.key,
    required this.db,
    this.nuevosIds = const {},
    this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hall of Fame'),
        automaticallyImplyLeading: onContinuar == null,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Qué significa la puntuación de carrera',
            onPressed: () => mostrarExplicacionPuntuacionHof(context),
          ),
        ],
      ),
      body: HallDeLaFamaBody(db: db, nuevosIds: nuevosIds),
      bottomNavigationBar: onContinuar == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onContinuar,
                  child: const Text('Continuar'),
                ),
              ),
            ),
    );
  }
}

/// El aviso de fin de temporada cuando alguien entra en el Hall of Fame:
/// solo los que acaban de entrar, no la lista de los 150+ que ya estaban.
/// Volcarla entera para anunciar dos o tres nombres nuevos era ruido, y con
/// las leyendas reales de Kaggle sumadas la lista se había vuelto larga de
/// verdad.
class NuevosEnHallDeLaFamaScreen extends StatefulWidget {
  final AppDatabase db;
  final List<MiembroHallDeLaFama> nuevos;
  final VoidCallback onContinuar;

  const NuevosEnHallDeLaFamaScreen({
    super.key,
    required this.db,
    required this.nuevos,
    required this.onContinuar,
  });

  @override
  State<NuevosEnHallDeLaFamaScreen> createState() =>
      _NuevosEnHallDeLaFamaScreenState();
}

class _NuevosEnHallDeLaFamaScreenState
    extends State<NuevosEnHallDeLaFamaScreen> {
  /// Las carreras y el año en curso, de una sola espera. El año hace falta
  /// para poder decir "entró en 2029" en vez de "temporada 3", que no le
  /// dice nada a nadie.
  late final Future<(TemporadaData, Map<int, CarreraJugador>)> _todo =
      _cargar();

  Future<(TemporadaData, Map<int, CarreraJugador>)> _cargar() async {
    final temporada = await leerTemporada(widget.db);
    final carreras = await leerCarrerasParaFichas(
        widget.db, widget.nuevos.map((m) => m.jugadorId));
    return (temporada, carreras);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hall of Fame'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Qué significa la puntuación de carrera',
            onPressed: () => mostrarExplicacionPuntuacionHof(context),
          ),
        ],
      ),
      // Se espera a tener las DOS cosas antes de pintar. Antes eran dos
      // FutureBuilder anidados y la lista se dibujaba con lo que hubiera:
      // en el primer fotograma la temporada todavía no había llegado, así
      // que el año de ingreso no salía — justo lo que sí enseña la lista
      // grande del Hall of Fame, que espera a tener sus datos.
      body: FutureBuilder<(TemporadaData, Map<int, CarreraJugador>)>(
        future: _todo,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (temporada, carreras) = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.nuevos.length == 1
                    ? 'Un nuevo nombre entra en el Hall of Fame.'
                    : '${widget.nuevos.length} nombres nuevos entran en el '
                        'Hall of Fame.',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final m in widget.nuevos)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading:
                        const Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text(m.nombreJugador,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    // El día que entras en el Hall of Fame lo que importa es
                    // que has entrado, y en qué año. Sus números están a un
                    // toque de distancia, en la ficha.
                    // Negativo = historia real (el año de verdad); positivo =
                    // una temporada de tu partida, que se traduce a año.
                    subtitle: Text(
                      m.temporadaIngreso < 0
                          ? 'Entró en ${-m.temporadaIngreso}'
                          : 'Entró en '
                              '${anioDeTemporadaDesde(temporada, m.temporadaIngreso)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (context) => CarreraJugadorScreen(
                        db: widget.db,
                        carrera: carreras[m.jugadorId],
                        nombreSiNoHayCarrera: m.nombreJugador,
                        esHistoriaReal: m.jugadorId < 0,
                      ),
                    )),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onContinuar,
            child: const Text('Continuar'),
          ),
        ),
      ),
    );
  }
}

/// Texto explicativo, a juego con `puntuacionDeCarrera` en
/// hall_fama_repository.dart: sin esto, el número que se ve junto a cada
/// nombre no dice nada por sí solo.
void mostrarExplicacionPuntuacionHof(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Qué es la puntuación de carrera?'),
      content: const SingleChildScrollView(
        child: Text(
          'Resume lo que ha dado de sí toda la carrera de un jugador, no '
          'un solo número aislado:\n\n'
          '• Trofeos individuales (MVP, Mejor Defensor, quintetos, Rookie '
          'del Año, Más Mejorado).\n'
          '• Anillos de campeón y títulos de la NBA Cup.\n'
          '• El pico de nivel que llegó a alcanzar.\n'
          '• Los puntos, asistencias y rebotes que acumuló, según cuántas '
          'temporadas jugó.\n\n'
          'Hace falta al menos 6 temporadas jugadas y superar un umbral '
          'para entrar: un titular sólido sin premios no basta, tiene que '
          'haber sido importante de verdad.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}

/// Lo que hace falta para pintar la lista entera, leído de una sola vez.
class _DatosDelHall {
  final List<MiembroHallDeLaFama> miembros;
  final Map<int, CarreraJugador> carreras;

  /// Para traducir el número de temporada de ingreso al año de verdad.
  final TemporadaData temporada;

  const _DatosDelHall({
    required this.miembros,
    required this.carreras,
    required this.temporada,
  });
}

/// La lista del Hall of Fame por orden de ingreso, del más antiguo al más
/// reciente: primero las leyendas reales por su año de verdad, y detrás las
/// que entren dentro de tu partida. Tocar a cualquiera abre su carrera.
class HallDeLaFamaBody extends StatefulWidget {
  final AppDatabase db;
  final Set<int> nuevosIds;

  const HallDeLaFamaBody({
    super.key,
    required this.db,
    this.nuevosIds = const {},
  });

  @override
  State<HallDeLaFamaBody> createState() => _HallDeLaFamaBodyState();
}

class _HallDeLaFamaBodyState extends State<HallDeLaFamaBody> {
  // El futuro se crea UNA vez y se guarda. Creado dentro de `build` —que es
  // como estaba— cada repintado lanzaba la carga entera otra vez.
  late final Future<_DatosDelHall> _futuro = _cargar();

  Future<_DatosDelHall> _cargar() async {
    final miembros = await leerHallDeLaFama(widget.db);
    // Una sola tanda de consultas para todas las carreras, en vez de cuatro
    // por cada miembro de la lista (ver leerCarrerasParaFichas).
    final carreras = await leerCarrerasParaFichas(
        widget.db, miembros.map((m) => m.jugadorId));

    // Cronológico INVERSO: lo último que ha pasado en tu partida arriba, y
    // las leyendas reales al fondo. `temporadaIngreso` negativa codifica el
    // año real (ver legado_historico_repository.dart).
    final ordenados = [...miembros]..sort((a, b) {
        final aEsReal = a.temporadaIngreso < 0;
        final bEsReal = b.temporadaIngreso < 0;
        if (aEsReal != bEsReal) return aEsReal ? 1 : -1;
        final anioA = aEsReal ? -a.temporadaIngreso : a.temporadaIngreso;
        final anioB = bEsReal ? -b.temporadaIngreso : b.temporadaIngreso;
        final cmp = anioB.compareTo(anioA);
        return cmp != 0 ? cmp : a.nombreJugador.compareTo(b.nombreJugador);
      });

    return _DatosDelHall(
      miembros: ordenados,
      carreras: carreras,
      temporada: await leerTemporada(widget.db),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DatosDelHall>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No se ha podido cargar el Hall of Fame.\n'
                  '${snapshot.error}'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final miembros = snapshot.data!.miembros;
        final carreras = snapshot.data!.carreras;
        if (miembros.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no hay nadie en el Hall of Fame. Solo entran '
                'jugadores ya retirados con una carrera de las grandes: '
                'premios, anillos y muchos años a buen nivel.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Dos columnas como mucho: con 460 de ancho máximo por tarjeta se
        // llegaban a montar seis columnas en una ventana grande y la lista
        // se volvía ilegible. En móvil sigue quedando una sola.
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.sizeOf(context).width < 640 ? 1 : 2,
            mainAxisExtent: 84,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: miembros.length,
          itemBuilder: (context, i) => _FilaMiembro(
            db: widget.db,
            miembro: miembros[i],
            carrera: carreras[miembros[i].jugadorId],
            esNuevo: widget.nuevosIds.contains(miembros[i].jugadorId),
            temporadaActual: snapshot.data!.temporada,
          ),
        );
      },
    );
  }
}

class _FilaMiembro extends StatelessWidget {
  final AppDatabase db;
  final MiembroHallDeLaFama miembro;

  /// Ya resuelta por quien pinta la lista: null si no hay nada simulado
  /// suyo (una leyenda real, o alguien que no llegó a jugar contigo).
  final CarreraJugador? carrera;
  final bool esNuevo;
  final TemporadaData temporadaActual;

  const _FilaMiembro({
    required this.db,
    required this.miembro,
    required this.carrera,
    required this.esNuevo,
    required this.temporadaActual,
  });

  @override
  Widget build(BuildContext context) {
    final c = carrera;
    final equipoPrincipal = c == null || c.etapas.isEmpty
        ? null
        : (c.etapas.toList()..sort((a, b) => b.partidos.compareTo(a.partidos)))
            .first
            .equipo;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        // El Hall of Fame va con su propio emblema, no con el escudo del
        // equipo: aquí lo que se honra es al jugador, no a la franquicia
        // (el equipo ya sale en la ficha, al tocar).
        leading: const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
        title: Row(
          children: [
            Flexible(
              child: Text(miembro.nombreJugador,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
            if (esNuevo) ...[
              const SizedBox(width: 6),
              const Chip(
                label: Text('NUEVO', style: TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
        // Negativo marca historia real (el año de verdad en que entró,
        // ver legado_historico_repository.dart); las temporadas de tu
        // partida siempre son positivas.
        subtitle: Text(
          // Corto a propósito: en un móvil la tarjeta da para una línea, y
          // "Entró en el Hall of Fame real en 1996" se cortaba a la mitad.
          c == null
              ? (miembro.temporadaIngreso < 0
                  ? 'Entró en ${-miembro.temporadaIngreso}'
                  // El año de verdad, no el número interno: "temporada 2"
                  // no le dice nada a nadie.
                  : 'Entró en la '
                      '${etiquetaTemporadaDesde(temporadaActual, miembro.temporadaIngreso)}')
              : '${c.temporadasTotales} temporadas · '
                  '${c.puntosPorPartido.toStringAsFixed(1)} pts · '
                  '${c.asistenciasPorPartido.toStringAsFixed(1)} ast · '
                  '${c.rebotesPorPartido.toStringAsFixed(1)} reb'
                  '${c.anillos.isEmpty ? '' : ' · ${c.anillos.length} anillos'}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (context) => CarreraJugadorScreen(
            db: db,
            carrera: c,
            nombreSiNoHayCarrera: miembro.nombreJugador,
            equipoDestacado: equipoPrincipal,
            esHistoriaReal: miembro.jugadorId < 0,
          ),
        )),
      ),
    );
  }
}
