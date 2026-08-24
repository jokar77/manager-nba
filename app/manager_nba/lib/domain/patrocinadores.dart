/// El catálogo de patrocinadores: quién puede patrocinarte, ciudad por
/// ciudad, y por qué. Es dato de referencia fijo (como `equiposInfo`), no
/// algo que se guarde en la base — lo único que se guarda es QUÉ categorías
/// tienes activas ahora mismo (ver `patrocinadores_repository.dart`).
///
/// Cuatro categorías fijas por equipo: el pabellón (energía, industria,
/// obra), la camiseta (banca, finanzas, tecnología y moda, el patrocinio de
/// más prestigio), la bebida oficial (alimentación) y el de ocio/comunidad
/// (parques, transporte, turismo, cultura). Cuáles de las cuatro firmas
/// sigue siendo la decisión de fondo: cada una paga, y cada una pide algo
/// a cambio (ver [compromisoPorCategoria]).
///
/// Lo que SÍ cambia es la marca concreta. Cada ciudad tiene una cantera de
/// once a quince empresas propias, con su logo, y **hasta tres de ellas
/// ponen oferta cada temporada** en cada categoría, con dinero distinto y
/// con contratos de uno, dos o cuatro años (ver [ofertasDe]).
///
/// Firmar largo ocupa esa categoría durante años: no se puede cambiar de
/// marca ni romper, y su compromiso de vestuario se paga todos los años.
/// Firmar corto deja más dinero ahora y te devuelve a esta pantalla el
/// verano que viene, con otras marcas encima de la mesa.
library;

/// Las cuatro categorías de patrocinio, en el orden en que se enseñan.
const categoriasPatrocinio = ['estadio', 'camiseta', 'bebida', 'ocio'];

/// Cuánto da cada categoría de margen de tope salarial si la tienes activa.
/// Fijo por categoría y no por empresa: todos los equipos tienen la misma
/// fuerza de patrocinio disponible, solo cambia el sabor local. La
/// camiseta es el patrocinio más visible de un equipo real y por eso el
/// que más paga; el de ocio es el más pequeño, casi simbólico.
const bonusPorCategoria = <String, int>{
  'estadio': 2500000,
  'camiseta': 3000000,
  'bebida': 1500000,
  'ocio': 1000000,
};

/// Lo que te pide a cambio cada categoría, como efecto de vestuario de los
/// primeros partidos de la temporada.
///
/// Sin esto el sistema no era una decisión. Cuatro interruptores que solo
/// dan dinero tienen una respuesta óptima obvia —encenderlos los cuatro— y
/// eso es un botón de cobrar, no una elección. Es exactamente lo que la
/// regla de diseño número 1 de `eventos_narrativos.dart` prohíbe: *"toda
/// opción tiene un coste o no es una decisión"*.
///
/// Las magnitudes NO son proporcionales al dinero a propósito. Si lo
/// fueran, la respuesta volvería a ser aritmética (firmar por orden de
/// ratio) y seguiría sin haber nada que pensar. Aquí:
///
/// * **camiseta** es el que más paga y el que más molesta — es el
///   patrocinio más visible y se cobra en días de medios y rodajes.
/// * **estadio** cuesta el nombre del pabellón: la grada tarda en
///   perdonarlo, así que pesa poco pero dura toda una racha larga.
/// * **bebida** es el término medio en las dos cosas.
/// * **ocio** casi no paga, pero el trabajo con la ciudad SUMA. Es la
///   opción que un equipo hecho firma sin pensar y la que un equipo que
///   necesita tope salarial no se puede permitir como única fuente.
///
/// Con esto la respuesta correcta depende de algo que la pantalla no sabe:
/// si te falta espacio para fichar o no. Que es justo lo que se busca.
const compromisoPorCategoria = <String, CompromisoDePatrocinio>{
  'camiseta': CompromisoDePatrocinio(
    clave: 'dias_de_medios',
    factor: 0.98,
    partidos: 6,
  ),
  'estadio': CompromisoDePatrocinio(
    clave: 'pabellon_con_otro_nombre',
    factor: 0.99,
    partidos: 12,
  ),
  'bebida': CompromisoDePatrocinio(
    clave: 'compromisos_de_marca',
    factor: 0.99,
    partidos: 6,
  ),
  'ocio': CompromisoDePatrocinio(
    clave: 'trabajo_con_la_ciudad',
    factor: 1.01,
    partidos: 6,
  ),
};

/// Lo que un patrocinio deja en el vestuario mientras se cumple.
///
/// Es a propósito la misma forma que un `EfectoDeEvento`: se guarda en la
/// misma tabla, se enseña en la misma tarjeta del menú y se gasta partido
/// a partido igual. Para el jugador es un efecto de vestuario más, y da
/// igual que venga de una cena de equipo o de un contrato de camiseta.
class CompromisoDePatrocinio {
  /// Con qué nombre se busca su texto. Ver `etiquetasDeEfecto` en
  /// `i18n/textos_eventos.dart`.
  final String clave;

  /// Multiplicador sobre el rendimiento del equipo, en el mismo rango
  /// acotado que los eventos (ver `maxFactorDeEvento`).
  final double factor;

  final int partidos;

  const CompromisoDePatrocinio({
    required this.clave,
    required this.factor,
    required this.partidos,
  });

  bool get esBueno => factor > 1.0;
}

/// Un patrocinador candidato para un equipo y una categoría.
class Patrocinador {
  /// El código de la HOJA de la que sale, que casi siempre es el del
  /// equipo. La excepción son los dos de Los Ángeles: comparten ciudad y
  /// comparten marcas, así que comparten hoja (`LA`). Ver [hojaDe].
  final String equipo;

  final String categoria;
  final String nombre;
  final int fundacion;
  final String historia;

  /// El nombre del fichero de su logo, sin carpeta ni extensión —
  /// `ATL_01`. Es también su identificador único dentro del catálogo.
  final String clave;

  const Patrocinador({
    required this.equipo,
    required this.categoria,
    required this.nombre,
    required this.fundacion,
    required this.historia,
    required this.clave,
  });

  /// La ruta del logo, para un `Image.asset`.
  String get logo => 'assets/logos/$clave.jpg';

  int get bonusSalarial => bonusPorCategoria[categoria]!;

  /// Lo que pide a cambio, que es la mitad de la decisión.
  CompromisoDePatrocinio get compromiso => compromisoPorCategoria[categoria]!;
}

/// De qué hoja de marcas bebe [equipo].
///
/// Los Clippers y los Lakers juegan en la misma ciudad, así que las
/// empresas de Los Ángeles son candidatas de los dos. No se duplicaron las
/// entradas: comparten la hoja `LA` y es [ofertasDe] quien los separa,
/// porque su semilla lleva el código del equipo y no el de la hoja — el
/// mismo año los dos reciben ofertas de marcas distintas.
String hojaDe(String equipo) =>
    (equipo == 'LAC' || equipo == 'LAL') ? 'LA' : equipo;

/// Todas las marcas de la ciudad de [equipo]: su cantera de patrocinadores,
/// una docena larga. De aquí salen los cuatro de cada temporada.
List<Patrocinador> patrocinadoresDe(String equipo) {
  final hoja = hojaDe(equipo);
  return catalogoPatrocinadores.where((p) => p.equipo == hoja).toList();
}

/// Cuántos años puede durar un contrato, de la oferta más corta a la más
/// larga. Hay una oferta por duración, y en ese orden.
const aniosDeOferta = [1, 2, 4];

/// Cuántas ofertas se enseñan por categoría. Es `aniosDeOferta.length`; la
/// constante existe para poder decir "tres" en los sitios que lo necesitan
/// sin que se descuadre si algún día son cuatro.
const ofertasPorCategoria = 3;

/// Lo que paga al año cada duración, sobre el bonus base de la categoría.
///
/// **Van al revés a propósito: cuanto más largo, menos paga al año.** Si
/// el contrato largo pagara más, no habría decisión — se firmaría siempre
/// el más largo y las otras dos tarjetas serían decorado. Así el corto es
/// dinero YA para fichar este verano, y el largo es tranquilidad barata.
const _factorPorDuracion = <int, double>{1: 1.35, 2: 1.05, 4: 0.82};

/// Lo que se redondea el dinero de una oferta. Sin esto salen cifras como
/// 3.412.750 €, que no se leen de un vistazo y fingen una precisión que el
/// juego no tiene.
const _redondeo = 50000;

/// Una oferta de patrocinio encima de la mesa: una marca, un dinero al año
/// y unos años de contrato.
///
/// La firma vale para [anios] temporadas, no solo para esta. Es lo que
/// convierte la pantalla en una decisión con consecuencias: durante esos
/// años esa categoría está ocupada, no se puede cambiar por otra marca ni
/// romper, y su compromiso de vestuario se paga todos los años.
class OfertaDePatrocinio {
  final Patrocinador patrocinador;

  /// Cuántas temporadas dura, esta incluida.
  final int anios;

  /// Lo que suma al tope salarial cada una de esas temporadas.
  final int bonusAnual;

  const OfertaDePatrocinio({
    required this.patrocinador,
    required this.anios,
    required this.bonusAnual,
  });

  String get categoria => patrocinador.categoria;

  /// Lo que deja en el vestuario mientras se cumple, que es lo mismo para
  /// todas las ofertas de una categoría: lo que cambia entre ellas es el
  /// dinero y los años, no lo que piden.
  CompromisoDePatrocinio get compromiso => patrocinador.compromiso;

  /// El total del contrato. No decide nada por sí solo —el dinero de los
  /// años cuatro y cinco no te ficha a nadie este verano— pero es lo que
  /// alguien quiere comparar de un vistazo.
  int get bonusTotal => bonusAnual * anios;
}

/// Las ofertas que tiene [equipo] en [categoria] esta [temporada]:
/// **hasta tres**, de marcas distintas de su ciudad, cada una con sus años
/// y su dinero.
///
/// Son *hasta* tres y no siempre tres. Ocho de las 116 canteras
/// —ciudad × categoría— tienen menos de tres marcas porque la hoja de esa
/// ciudad no traía más de ese tipo: Charlotte, Cleveland y Milwaukee en
/// camiseta, Nueva York en estadio y en bebida. Ahí salen las que hay.
/// `patrocinadores_test.dart` vigila que nunca salgan más de tres ni menos
/// de una.
///
/// Las marcas se sacan de la cantera en orden, empezando por donde toque
/// esta temporada.
///
/// **El hueco de tres se mueve entero cada año, no de uno en uno**
/// (Lista 15 punto 9). La cantera "de once a quince" de la nota de la
/// clase es POR CIUDAD, repartida entre las cuatro categorías — la que
/// de verdad importa aquí es la de cada ciudad×categoría, y esa es mucho
/// más corta (4 candidatas es la más común; medido con un script de
/// diagnóstico sobre las 116 canteras). Con un desplazamiento de solo 1,
/// dos de las tres ofertas de este año volvían a salir el año que viene
/// SIEMPRE, fuera cual fuera el tamaño de la cantera. Saltando de tres en
/// tres, el solape baja al mínimo que permite cada tamaño:
///
/// * Con 4 candidatas, dos de tres SIGUEN repitiendo — no es un fallo de
///   esta función, es que solo hay 4 combinaciones posibles de 3 sobre 4
///   y dos combinaciones distintas cualesquiera comparten al menos 2
///   (principio del palomar). No hay desplazamiento que lo evite.
/// * Con 5, el mínimo posible es 1 y aquí se alcanza.
/// * Con 6 o más, el mínimo posible es 0 y aquí se alcanza: el año que
///   viene trae tres marcas completamente distintas.
///
/// (Comprobado a mano con un script de diagnóstico, no hay test que fije
/// estos números exactos porque dependen del tamaño de cada cantera real,
/// que puede cambiar si se regenera el catálogo.)
///
/// Cuando la cantera NO da para más de tres (`cuantas == candidatas.length`,
/// las ocho canteras cortas de la nota de arriba), saltar de tres en tres
/// se queda siempre en el mismo resto y deja de rotar del todo — ahí, y
/// solo ahí, se sigue usando el salto de uno en uno de siempre: con tan
/// pocas marcas ya se enseñan todas cada año, y lo único que puede
/// cambiar es el ORDEN (qué le toca el contrato de un año, cuál el de
/// cuatro), que sí sigue rotando.
List<OfertaDePatrocinio> ofertasDe(
  String equipo,
  String categoria, {
  required int temporada,
}) {
  final candidatas = catalogoPatrocinadores
      .where((p) => p.equipo == hojaDe(equipo) && p.categoria == categoria)
      .toList();
  if (candidatas.isEmpty) return const [];

  final base = bonusPorCategoria[categoria];
  if (base == null) return const [];

  final desplazamiento = _semilla('$equipo|$categoria');
  final cuantas = candidatas.length < ofertasPorCategoria
      ? candidatas.length
      : ofertasPorCategoria;
  final paso = candidatas.length > cuantas ? cuantas : 1;

  return [
    for (var i = 0; i < cuantas; i++)
      () {
        final p = candidatas[
            (desplazamiento + temporada * paso + i) % candidatas.length];
        final anios = aniosDeOferta[i];
        return OfertaDePatrocinio(
          patrocinador: p,
          anios: anios,
          bonusAnual: _dinero(
            base,
            anios,
            p.clave,
            equipo,
            categoria,
            temporada,
          ),
        );
      }(),
  ];
}

/// Todas las ofertas de [equipo] en [temporada], por categoría y en el
/// orden de [categoriasPatrocinio].
Map<String, List<OfertaDePatrocinio>> ofertasDeTemporada(
  String equipo,
  int temporada,
) => {
  for (final categoria in categoriasPatrocinio)
    categoria: ofertasDe(equipo, categoria, temporada: temporada),
};

/// La marca con esa [clave], o `null` si no existe.
///
/// Hace falta para los contratos ya firmados: en la base se guarda la
/// clave, y al cabo de tres años hay que volver a saber de quién era el
/// logo y el nombre sin depender de en qué posición de la cantera cayó
/// aquel año.
Patrocinador? patrocinadorPorClave(String clave) {
  for (final p in catalogoPatrocinadores) {
    if (p.clave == clave) return p;
  }
  return null;
}

/// Lo que paga al año una oferta.
///
/// Son tres factores sobre el bonus base de la categoría, y **están
/// separados así a propósito**:
///
/// 1. **La duración**, fija (ver [_factorPorDuracion]). Cuanto más largo,
///    menos al año.
/// 2. **El año**, entre 0,85 y 1,15. Es el mismo para las tres ofertas de
///    una categoría, así que mueve el nivel entero de un verano a otro sin
///    tocar el orden entre ellas. Es lo que hace que **merezca la pena
///    atarse a un contrato largo**: sin él, el corto de dentro de tres años
///    pagaría lo mismo que el de hoy y esperar no costaría nada.
/// 3. **La marca**, entre 0,96 y 1,04. Un empujón pequeño para que dos
///    ofertas no salgan clavadas.
///
/// El tercero es pequeño por una razón concreta, y la cazó un test: cuando
/// dependía de la marca y valía ±15%, se comía la diferencia entre el
/// factor de un año (1,35) y el de dos (1,05), y **el contrato corto podía
/// acabar pagando menos al año que el largo**. Con eso la decisión
/// desaparece: firmas el largo, que da más dinero y encima más años. Con el
/// nivel compartido por temporada, el orden está garantizado por
/// construcción y no por suerte.
int _dinero(
  int base,
  int anios,
  String clave,
  String equipo,
  String categoria,
  int temporada,
) {
  final porDuracion = _factorPorDuracion[anios] ?? 1.0;
  // 0,85 a 1,15 en pasos de 0,01, igual para las tres ofertas del año.
  final porAnio =
      0.85 + (_semilla('$equipo|$categoria|$temporada|nivel') % 31) / 100;
  // 0,96 a 1,04: demasiado pequeño para invertir el orden de arriba.
  final porMarca = 0.96 + (_semilla('$clave|marca') % 9) / 100;
  final bruto = base * porDuracion * porAnio * porMarca;
  return (bruto / _redondeo).round() * _redondeo;
}

/// Un número estable a partir de un texto. Es el hash FNV-1a de 32 bits,
/// escrito a mano en vez de usar `texto.hashCode` a propósito:
/// `String.hashCode` de Dart NO está garantizado entre versiones ni entre
/// plataformas, y aquí hace falta que el patrocinador de la temporada 12
/// sea el mismo en el móvil, en la web y dentro de tres versiones.
int _semilla(String texto) {
  var h = 0x811c9dc5;
  for (final c in texto.codeUnits) {
    h = (h ^ c) & 0xffffffff;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h % 1000;
}

/// La cantera entera: 386 marcas ficticias, once a quince por ciudad, con
/// nombre, año y anécdota inspirados en la identidad real del sitio. Cada
/// una tiene su logo en `assets/logos/`, con el mismo nombre que su
/// [Patrocinador.clave].
///
/// **Esto se genera, no se escribe a mano.** Sale de dos ficheros de
/// `docs/`: `patrocinadores_hojas.tsv` (nombre e historia) y
/// `patrocinadores_categorias.tsv` (en cuál de las cuatro cae cada una).
/// Para rehacerlo, desde `app/manager_nba`:
///
/// ```
/// dart run tool/generar_patrocinadores.dart
/// ```
// === CATÁLOGO GENERADO — no editar a mano, ver el comentario de arriba ===
const catalogoPatrocinadores = <Patrocinador>[
  // --- ATL ---
  Patrocinador(
    equipo: 'ATL',
    categoria: 'estadio',
    clave: 'ATL_01',
    nombre: 'Peachvolt Energy',
    fundacion: 1969,
    historia:
        'Compañía eléctrica fundada en 1969, cuyo logo cruza el '
        'melocotón del estado con un rayo. Suministra energía a '
        'todo el centro financiero.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'bebida',
    clave: 'ATL_02',
    nombre: 'Beltline Bites',
    fundacion: 2011,
    historia:
        'Cadena de restaurantes al aire libre fundada en 2011, '
        'con locales repartidos por el antiguo corredor '
        'ferroviario reconvertido en parque lineal.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'bebida',
    clave: 'ATL_03',
    nombre: 'Hartsfield Hop',
    fundacion: 1998,
    historia:
        'Cervecería fundada en 1998 junto al aeropuerto más '
        'transitado del mundo, célebre por su lúpulo de '
        'aterrizaje y sus latas con torre de control.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'camiseta',
    clave: 'ATL_05',
    nombre: 'Piedmont Pixels',
    fundacion: 2006,
    historia:
        'Estudio de software y pantallas gigantes fundado en '
        '2006, con sede junto al parque Piedmont y su mosaico '
        'verde por logo.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'estadio',
    clave: 'ATL_06',
    nombre: 'ATL Forge Steel',
    fundacion: 1874,
    historia:
        'Fundición y forja fundada en 1874, superviviente del '
        'incendio que arrasó la ciudad y proveedora del acero de '
        'sus primeros rascacielos.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'camiseta',
    clave: 'ATL_07',
    nombre: 'Phoenix Rising Bank',
    fundacion: 1889,
    historia:
        'Banco fundado en 1889, cuyo nombre y logo recogen el ave '
        'fénix del sello municipal: la ciudad renacida de sus '
        'cenizas.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'bebida',
    clave: 'ATL_08',
    nombre: 'Dogwood Blossom Dairy',
    fundacion: 1952,
    historia:
        'Lácteos fundados en 1952, con la flor de cornejo que '
        'llena la ciudad cada primavera como marca de la casa.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'ocio',
    clave: 'ATL_09',
    nombre: 'Ponce Corridor Motors',
    fundacion: 1948,
    historia:
        'Concesionario y taller fundado en 1948 en la avenida '
        'Ponce de Leon, la vía comercial más larga y más rara de '
        'la ciudad.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'estadio',
    clave: 'ATL_10',
    nombre: 'Stone Mountain Granite',
    fundacion: 1869,
    historia:
        'Cantera fundada en 1869, extractora del granito gris que '
        'pavimentó media ciudad y llegó hasta las escaleras del '
        'Capitolio.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'ocio',
    clave: 'ATL_12',
    nombre: 'Chattahoochee Rapids',
    fundacion: 1976,
    historia:
        'Empresa de ocio fluvial fundada en 1976, dedicada al '
        'descenso en balsa por el río que da agua y fin de semana '
        'a la ciudad.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'ocio',
    clave: 'ATL_13',
    nombre: 'Krog Tunnel Art',
    fundacion: 2004,
    historia:
        'Colectivo de arte urbano fundado en 2004, encargado de '
        'repintar cada temporada el túnel de grafitis más '
        'fotografiado del sureste.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'bebida',
    clave: 'ATL_14',
    nombre: 'World of Fizz Aquatics',
    fundacion: 1993,
    historia:
        'Embotelladora y parque acuático fundados en 1993, con '
        'una atracción por cada sabor de su catálogo.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'camiseta',
    clave: 'ATL_15',
    nombre: 'Cabbagetown Cotton Mill',
    fundacion: 1881,
    historia:
        'Fábrica textil fundada en 1881, cerrada en 1977 y '
        'reabierta como taller de moda por los nietos de sus '
        'antiguas hilanderas.',
  ),

  // --- BOS ---
  Patrocinador(
    equipo: 'BOS',
    categoria: 'bebida',
    clave: 'BOS_01',
    nombre: 'Harbor Bean Co',
    fundacion: 1832,
    historia:
        'Tostadero de café fundado en 1832 en los muelles, '
        'heredero del comercio que traía el grano desde las '
        'Antillas.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'camiseta',
    clave: 'BOS_02',
    nombre: 'Freedom Trail Fits',
    fundacion: 1984,
    historia:
        'Marca de calzado fundada en 1984, especializada en botas '
        'cómodas para las cuatro millas de la ruta histórica de '
        'la ciudad.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'camiseta',
    clave: 'BOS_03',
    nombre: 'Beantown Bytes',
    fundacion: 1997,
    historia:
        'Empresa de software fundada en 1997 por estudiantes de '
        'las universidades del río, con una alubia verde por '
        'icono.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'camiseta',
    clave: 'BOS_04',
    nombre: 'Charles River Bank',
    fundacion: 1822,
    historia:
        'Banco fundado en 1822, con sedes gemelas en las dos '
        'orillas del río que separa la ciudad de Cambridge.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'bebida',
    clave: 'BOS_05',
    nombre: 'North End Noodles',
    fundacion: 1911,
    historia:
        'Fábrica de pasta fundada en 1911 por una familia '
        'siciliana, todavía en la misma calle estrecha del barrio '
        'italiano.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'ocio',
    clave: 'BOS_06',
    nombre: 'Greenline Transit+',
    fundacion: 1897,
    historia:
        'Operador de tranvías fundado en 1897, el mismo año en '
        'que la ciudad estrenó el primer metro del país.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'estadio',
    clave: 'BOS_08',
    nombre: 'Beacon Hill Gaslight',
    fundacion: 1853,
    historia:
        'Compañía de alumbrado fundada en 1853, la única que '
        'sigue encendiendo a mano las farolas de gas del barrio '
        'histórico.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'bebida',
    clave: 'BOS_09',
    nombre: 'Cod Fisher\'s Catch',
    fundacion: 1748,
    historia:
        'Pesquería fundada en 1748, dedicada al bacalao que dio '
        'nombre y dinero a la colonia entera.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'camiseta',
    clave: 'BOS_11',
    nombre: 'Newbury Street Threads',
    fundacion: 1938,
    historia:
        'Casa de moda fundada en 1938 en la calle de las tiendas, '
        'con taller propio en un sótano de piedra rojiza.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'estadio',
    clave: 'BOS_12',
    nombre: 'Tea Party Trade Co',
    fundacion: 1790,
    historia:
        'Importadora fundada en 1790, con un guiño al cargamento '
        'que acabó en el puerto diecisiete años antes de que ella '
        'existiera.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'bebida',
    clave: 'BOS_13',
    nombre: 'Faneuil Hall Fare',
    fundacion: 1826,
    historia:
        'Comercializadora de mercado fundada en 1826, con puesto '
        'propio en la lonja que lleva doscientos años sin cerrar.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'ocio',
    clave: 'BOS_15',
    nombre: 'Swan Boat Sails',
    fundacion: 1877,
    historia:
        'Empresa de ocio fundada en 1877, operadora de los botes '
        'con forma de cisne del estanque del jardín público.',
  ),

  // --- BRK ---
  Patrocinador(
    equipo: 'BRK',
    categoria: 'bebida',
    clave: 'BRK_01',
    nombre: 'Borough Brew Labs',
    fundacion: 2009,
    historia:
        'Cervecería experimental fundada en 2009, con una B de '
        'ladrillo por logo y un puente colgante en cada etiqueta.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'camiseta',
    clave: 'BRK_02',
    nombre: 'Dumbo Drone Co',
    fundacion: 2014,
    historia:
        'Fabricante de drones fundado en 2014 en un almacén bajo '
        'el puente, especializado en tomas aéreas del skyline.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'camiseta',
    clave: 'BRK_03',
    nombre: 'Coney Circuit',
    fundacion: 1987,
    historia:
        'Empresa de electrónica de ocio fundada en 1987, '
        'proveedora de las máquinas del paseo marítimo desde su '
        'primera recreativa.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'camiseta',
    clave: 'BRK_04',
    nombre: 'Stoop Sneaker Lab',
    fundacion: 2005,
    historia:
        'Marca de zapatillas fundada en 2005, nacida de las '
        'escalinatas de entrada donde el barrio se sienta a mirar '
        'pasar la tarde.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'camiseta',
    clave: 'BRK_05',
    nombre: 'Navy Yard Netsync',
    fundacion: 1999,
    historia:
        'Empresa de redes fundada en 1999 en el antiguo astillero '
        'militar, hoy vivero de talleres y estudios.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'bebida',
    clave: 'BRK_06',
    nombre: 'Brownstone Bites',
    fundacion: 1968,
    historia:
        'Cadena de sándwiches fundada en 1968, con el mismo pan '
        'de centeno desde el primer local en un bajo de piedra '
        'rojiza.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'ocio',
    clave: 'BRK_07',
    nombre: 'Williamsburg Waves',
    fundacion: 1946,
    historia:
        'Emisora y estudio de sonido fundados en 1946 junto a los '
        'depósitos de agua del barrio, antena incluida.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'bebida',
    clave: 'BRK_08',
    nombre: 'Prospect Park Provisions',
    fundacion: 1973,
    historia:
        'Cooperativa de alimentación fundada en 1973, con puestos '
        'de temporada en las entradas del parque grande del '
        'distrito.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'ocio',
    clave: 'BRK_09',
    nombre: 'Cyclone Coasters',
    fundacion: 1927,
    historia:
        'Constructora de montañas rusas de madera fundada en '
        '1927, el año de la que todavía funciona en el paseo '
        'marítimo.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'estadio',
    clave: 'BRK_11',
    nombre: 'Red Hook Rope Works',
    fundacion: 1855,
    historia:
        'Cordelería fundada en 1855 en los muelles, proveedora de '
        'amarras para los cargueros del puerto.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'estadio',
    clave: 'BRK_13',
    nombre: 'Greenpoint Glassworks',
    fundacion: 1861,
    historia:
        'Vidriería fundada en 1861, una de las cinco industrias '
        'que dieron fama al barrio antes de que el vidrio se '
        'fuera.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'bebida',
    clave: 'BRK_14',
    nombre: 'Flatbush Fresh Produce',
    fundacion: 1962,
    historia:
        'Distribuidora de fruta y verdura fundada en 1962 por '
        'comerciantes caribeños, con cajón de colores por logo.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'estadio',
    clave: 'BRK_15',
    nombre: 'Gowanus Canal Current',
    fundacion: 1989,
    historia:
        'Eléctrica de barrio fundada en 1989, con turbinas en el '
        'canal más famoso y peor oliente del distrito.',
  ),

  // --- CHI ---
  Patrocinador(
    equipo: 'CHI',
    categoria: 'estadio',
    clave: 'CHI_01',
    nombre: 'Windy Watt Power',
    fundacion: 1954,
    historia:
        'Eléctrica fundada en 1954, con parques eólicos plantados '
        'en el lago y el apodo de la ciudad en el nombre.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'camiseta',
    clave: 'CHI_02',
    nombre: 'DeepDish Digital',
    fundacion: 2001,
    historia:
        'Estudio de software fundado en 2001, cuyo logo es la '
        'porción de pizza gruesa por la que se discute en toda la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'ocio',
    clave: 'CHI_03',
    nombre: 'El Loop Transit',
    fundacion: 1892,
    historia:
        'Operador del tren elevado fundado en 1892, dueño del '
        'anillo de raíles que rodea y bautiza el centro.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'camiseta',
    clave: 'CHI_04',
    nombre: 'Lake Shore Layers',
    fundacion: 1962,
    historia:
        'Marca de ropa de abrigo fundada en 1962, especializada '
        'en capas para el viento que entra del lago en enero.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'camiseta',
    clave: 'CHI_05',
    nombre: 'Steelbeam Bank',
    fundacion: 1885,
    historia:
        'Banco fundado en 1885, el año del primer rascacielos con '
        'estructura de acero, financiado por esta misma casa.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'bebida',
    clave: 'CHI_06',
    nombre: 'Navy Pier Nosh',
    fundacion: 1976,
    historia:
        'Cadena de puestos de comida fundada en 1976, repartida '
        'por el muelle que la ciudad recuperó para pasear.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'ocio',
    clave: 'CHI_07',
    nombre: 'Bean Reflection Studios',
    fundacion: 2006,
    historia:
        'Estudio de fotografía fundado en 2006, nacido a la '
        'sombra de la escultura de acero pulido del parque del '
        'milenio.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'camiseta',
    clave: 'CHI_09',
    nombre: 'Magnificent Mile Threads',
    fundacion: 1971,
    historia:
        'Casa de moda fundada en 1971, con escaparate en la '
        'avenida de las tiendas caras.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'bebida',
    clave: 'CHI_10',
    nombre: 'River Walk Roasters',
    fundacion: 1999,
    historia:
        'Tostadero de café fundado en 1999, con terrazas en el '
        'paseo que baja hasta el río en el corazón del centro.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'estadio',
    clave: 'CHI_12',
    nombre: 'Union Station Steam',
    fundacion: 1925,
    historia:
        'Empresa de calefacción urbana fundada en 1925, con la '
        'caldera original bajo la bóveda de la estación.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'bebida',
    clave: 'CHI_13',
    nombre: 'Maxwell Street Grill',
    fundacion: 1943,
    historia:
        'Cadena de perritos fundada en 1943 en el mercado '
        'callejero de inmigrantes, con la salchicha polaca por '
        'bandera.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'bebida',
    clave: 'CHI_15',
    nombre: 'Buckingham Fountain Fizz',
    fundacion: 1927,
    historia:
        'Embotelladora de refrescos fundada en 1927, homenaje a '
        'la fuente monumental estrenada aquel mismo verano.',
  ),

  // --- CHO ---
  Patrocinador(
    equipo: 'CHO',
    categoria: 'camiseta',
    clave: 'CHO_01',
    nombre: 'Queen City Credit',
    fundacion: 1913,
    historia:
        'Cooperativa de crédito fundada en 1913, con la corona de '
        'la reina que da apodo a la ciudad grabada en cada '
        'tarjeta.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'ocio',
    clave: 'CHO_02',
    nombre: 'Carolina Canopy',
    fundacion: 1965,
    historia:
        'Empresa de arboricultura fundada en 1965, responsable de '
        'las hileras de robles que hacen de la ciudad un bosque '
        'urbano.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'estadio',
    clave: 'CHO_03',
    nombre: 'Banktown Bolts',
    fundacion: 1972,
    historia:
        'Eléctrica fundada en 1972, encargada de mantener '
        'encendidas las torres de la segunda plaza financiera del '
        'país.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'bebida',
    clave: 'CHO_04',
    nombre: 'Hornet Honey Co',
    fundacion: 1957,
    historia:
        'Apicultura y mieles fundadas en 1957, con el avispero de '
        'la ciudad como emblema desde el primer tarro.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'ocio',
    clave: 'CHO_05',
    nombre: 'Uptown Rails',
    fundacion: 2007,
    historia:
        'Operador del tranvía urbano fundado en 2007, con la U '
        'azul de sus paradas por logotipo.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'ocio',
    clave: 'CHO_06',
    nombre: 'Mint Hill Media',
    fundacion: 1994,
    historia:
        'Productora audiovisual fundada en 1994, nombrada por la '
        'antigua casa de la moneda que acuñó el oro de la región.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'ocio',
    clave: 'CHO_08',
    nombre: 'Freedom Park Flora',
    fundacion: 1980,
    historia:
        'Vivero y floristería fundados en 1980, proveedores de '
        'los parterres del parque más visitado de la ciudad.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'ocio',
    clave: 'CHO_09',
    nombre: 'NoDa Neon Arts',
    fundacion: 1998,
    historia:
        'Colectivo de artistas del neón fundado en 1998, motor de '
        'las galerías del distrito artístico del norte.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'ocio',
    clave: 'CHO_10',
    nombre: 'Catawba River Rapids',
    fundacion: 1991,
    historia:
        'Empresa de deportes de aguas bravas fundada en 1991, con '
        'base en el río que abastece a media región.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'estadio',
    clave: 'CHO_11',
    nombre: 'Panther Paw Steel',
    fundacion: 1934,
    historia:
        'Acería fundada en 1934, con la huella de pantera que '
        'estampa en cada viga desde los años sesenta.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'ocio',
    clave: 'CHO_12',
    nombre: 'South End Streetcar',
    fundacion: 1927,
    historia:
        'Operador de tranvía histórico fundado en 1927, '
        'restaurador de los coches rojos que recorren el antiguo '
        'barrio industrial.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'bebida',
    clave: 'CHO_13',
    nombre: 'Plaza Midwood Provisions',
    fundacion: 1946,
    historia:
        'Tienda de ultramarinos fundada en 1946 en el barrio de '
        'los bungalós, mitad colmado y mitad cafetería.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'estadio',
    clave: 'CHO_14',
    nombre: 'Camp North End Cargo',
    fundacion: 1924,
    historia:
        'Operador logístico fundado en 1924 en la antigua fábrica '
        'de camiones, hoy nave de almacenes y estudios.',
  ),

  // --- CLE ---
  Patrocinador(
    equipo: 'CLE',
    categoria: 'estadio',
    clave: 'CLE_01',
    nombre: 'Erie Edge Steel',
    fundacion: 1904,
    historia:
        'Fundición industrial fundada en 1904, junto a las '
        'orillas del lago Erie, corazón del acero del medio '
        'oeste.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'bebida',
    clave: 'CLE_03',
    nombre: 'Cuyahoga Chips',
    fundacion: 1969,
    historia:
        'Marca de snacks fundada en 1969, con nombre del sinuoso '
        'río Cuyahoga que atraviesa la ciudad.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'bebida',
    clave: 'CLE_05',
    nombre: 'Flats Forge Coffee',
    fundacion: 1990,
    historia:
        'Cafetería fundada en 1990, en el histórico distrito '
        'industrial de Los Flats junto al río.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'ocio',
    clave: 'CLE_06',
    nombre: 'Script CLE Travel',
    fundacion: 2016,
    historia:
        'Agencia de viajes fundada en 2016, con logo inspirado en '
        'la caligrafía tradicional del apodo "CLE".',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'camiseta',
    clave: 'CLE_07',
    nombre: 'Terminal Tower Tech',
    fundacion: 1930,
    historia:
        'Empresa de telecomunicaciones fundada en 1930, año de '
        'inauguración de la icónica Terminal Tower.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'estadio',
    clave: 'CLE_09',
    nombre: 'Lakeview Solar',
    fundacion: 2013,
    historia:
        'Empresa de energía renovable fundada en 2013, con '
        'paneles orientados hacia el lago Erie.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'ocio',
    clave: 'CLE_10',
    nombre: 'Emerald Necklace Trail',
    fundacion: 1917,
    historia:
        'Empresa de senderismo y ocio fundada en 1917, gestora de '
        'la red de parques metropolitanos que rodea la ciudad '
        'como un collar verde.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'ocio',
    clave: 'CLE_11',
    nombre: 'North Coast Marine',
    fundacion: 1950,
    historia:
        'Empresa naviera fundada en 1950, homenaje al apodo '
        '"Costa Norte" de la orilla del lago Erie.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'ocio',
    clave: 'CLE_12',
    nombre: 'Cultural Gardens',
    fundacion: 1936,
    historia:
        'Fundación cultural creada en 1936, gestora de los '
        'jardines internacionales que representan a las '
        'comunidades étnicas de la ciudad.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'ocio',
    clave: 'CLE_13',
    nombre: 'Playhouse Square Arts',
    fundacion: 1921,
    historia:
        'Organización teatral fundada en 1921, año de apertura '
        'del distrito de teatros más grande fuera de Nueva York.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'bebida',
    clave: 'CLE_14',
    nombre: 'Ohio City Brewery',
    fundacion: 1836,
    historia:
        'Cervecería fundada en 1836, en el histórico vecindario '
        'de Ohio City, cuna de la cerveza artesanal local.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'bebida',
    clave: 'CLE_15',
    nombre: 'Burning River Brew',
    fundacion: 1998,
    historia:
        'Cervecería fundada en 1998, con nombre irónico que '
        'recuerda al famoso incendio del río Cuyahoga de 1969, '
        'hoy símbolo de la recuperación ecológica de la ciudad.',
  ),

  // --- DAL ---
  Patrocinador(
    equipo: 'DAL',
    categoria: 'estadio',
    clave: 'DAL_01',
    nombre: 'Lone Star Lithium',
    fundacion: 2010,
    historia:
        'Fabricante de baterías fundado en 2010, con la estrella '
        'solitaria del estado recortada en cada celda.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'bebida',
    clave: 'DAL_02',
    nombre: 'Cattle Drive Cuts',
    fundacion: 1873,
    historia:
        'Carnicería mayorista fundada en 1873, heredera de las '
        'rutas ganaderas que cruzaban el norte del estado.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'camiseta',
    clave: 'DAL_03',
    nombre: 'Reunion Tower Bits',
    fundacion: 1978,
    historia:
        'Empresa de telecomunicaciones fundada en 1978, con '
        'antenas en la bola de luces que preside el skyline.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'estadio',
    clave: 'DAL_04',
    nombre: 'Prairie Oil Co',
    fundacion: 1931,
    historia:
        'Petrolera fundada en 1931, nacida del pozo que cambió la '
        'economía del este del estado.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'camiseta',
    clave: 'DAL_05',
    nombre: 'Big D Denim',
    fundacion: 1955,
    historia:
        'Marca de vaqueros fundada en 1955, con la inicial de la '
        'ciudad cosida en el bolsillo trasero.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'camiseta',
    clave: 'DAL_06',
    nombre: 'Trinity Trail Gear',
    fundacion: 1988,
    historia:
        'Marca de equipamiento de senderismo fundada en 1988, '
        'especializada en las rutas del cinturón verde del río.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'ocio',
    clave: 'DAL_07',
    nombre: 'Deep Ellum Vinyl',
    fundacion: 1968,
    historia:
        'Sello discográfico fundado en 1968 en el barrio del '
        'blues, todavía prensando en vinilo en su primera nave.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'bebida',
    clave: 'DAL_08',
    nombre: 'Fair Park Fizz',
    fundacion: 1936,
    historia:
        'Embotelladora fundada en 1936, el año de la exposición '
        'del centenario del estado, celebrada en ese mismo '
        'parque.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'ocio',
    clave: 'DAL_09',
    nombre: 'White Rock Boats',
    fundacion: 1930,
    historia:
        'Club náutico y alquiler de veleros fundado en 1930 en el '
        'lago del este de la ciudad.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'bebida',
    clave: 'DAL_10',
    nombre: 'Bishop Arts Bites',
    fundacion: 2004,
    historia:
        'Colectivo de restaurantes fundado en 2004 en el distrito '
        'de galerías al sur del río.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'ocio',
    clave: 'DAL_11',
    nombre: 'DFW Hop',
    fundacion: 1974,
    historia:
        'Aerolínea regional fundada en 1974, el año de apertura '
        'del aeropuerto que la hizo posible.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'camiseta',
    clave: 'DAL_13',
    nombre: 'Victory Park Vault',
    fundacion: 1999,
    historia:
        'Firma de inversión fundada en 1999, con sede en el '
        'distrito levantado alrededor del pabellón.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'bebida',
    clave: 'DAL_14',
    nombre: 'Tortilla Flatiron Bakes',
    fundacion: 1962,
    historia:
        'Panadería y tortillería fundada en 1962, con horno en el '
        'edificio triangular del centro.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'ocio',
    clave: 'DAL_15',
    nombre: 'Katy Trail Cycles',
    fundacion: 1997,
    historia:
        'Tienda y taller de bicicletas fundado en 1997, junto a '
        'la vía de tren reconvertida en carril verde.',
  ),

  // --- DEN ---
  Patrocinador(
    equipo: 'DEN',
    categoria: 'bebida',
    clave: 'DEN_01',
    nombre: 'Mile High Malt',
    fundacion: 1873,
    historia:
        'Cervecera fundada en 1873, la primera en ajustar sus '
        'recetas a la altitud exacta de la ciudad: 5.280 pies.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'camiseta',
    clave: 'DEN_02',
    nombre: 'Front Range Fiber',
    fundacion: 2004,
    historia:
        'Operador de fibra óptica fundado en 2004, con el perfil '
        'de las montañas convertido en señal en su logo.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'bebida',
    clave: 'DEN_03',
    nombre: 'Cherry Creek Chips',
    fundacion: 1958,
    historia:
        'Fábrica de aperitivos fundada en 1958 junto al arroyo '
        'donde se encontró el oro que fundó la ciudad.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'ocio',
    clave: 'DEN_04',
    nombre: 'Powderline Parks',
    fundacion: 1961,
    historia:
        'Operador de estaciones de esquí fundado en 1961, dueño '
        'de los circuitos de nieve polvo de las montañas del '
        'oeste.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'camiseta',
    clave: 'DEN_05',
    nombre: 'Bronco Bronze Bank',
    fundacion: 1908,
    historia:
        'Banco fundado en 1908, con la herradura de bronce del '
        'caballo salvaje en la puerta de su sede.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'ocio',
    clave: 'DEN_06',
    nombre: 'Altitude Air',
    fundacion: 1983,
    historia:
        'Aerolínea regional fundada en 1983, especializada en los '
        'aeropuertos de montaña más altos del país.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'ocio',
    clave: 'DEN_07',
    nombre: 'Red Rocks Audio',
    fundacion: 1972,
    historia:
        'Empresa de sonido fundada en 1972, encargada del equipo '
        'del anfiteatro natural entre paredes de arenisca roja.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'camiseta',
    clave: 'DEN_08',
    nombre: 'Union Station Clock',
    fundacion: 1914,
    historia:
        'Relojería y mantenimiento de relojes públicos fundada en '
        '1914, el año de la torre de la estación central.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'bebida',
    clave: 'DEN_09',
    nombre: 'LoDo Lager',
    fundacion: 1994,
    historia:
        'Cervecería fundada en 1994 en los almacenes de ladrillo '
        'del casco bajo, primera de la ola que revivió el barrio.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'camiseta',
    clave: 'DEN_10',
    nombre: 'Buffalo Bill Bytes',
    fundacion: 1996,
    historia:
        'Empresa de software fundada en 1996, con el bisonte del '
        'oeste por icono y sede junto a la montaña del mismo '
        'nombre.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'bebida',
    clave: 'DEN_11',
    nombre: 'Highlands Honey',
    fundacion: 1969,
    historia:
        'Apicultura fundada en 1969, con colmenas repartidas por '
        'las laderas del noroeste de la ciudad.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'estadio',
    clave: 'DEN_12',
    nombre: 'Platte River Pack',
    fundacion: 1980,
    historia:
        'Empresa de mensajería fundada en 1980, con rutas que '
        'siguen el río que parte la ciudad en dos.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'estadio',
    clave: 'DEN_13',
    nombre: 'Bluebird Solar',
    fundacion: 2008,
    historia:
        'Instaladora de placas solares fundada en 2008, que '
        'aprovecha los trescientos días de sol al año de la '
        'meseta.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'camiseta',
    clave: 'DEN_14',
    nombre: 'Capitol Dome Credit',
    fundacion: 1901,
    historia:
        'Cooperativa de crédito fundada en 1901, con la cúpula '
        'dorada del capitolio del estado en su moneda-logo.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'ocio',
    clave: 'DEN_15',
    nombre: 'RiNo Mural Co',
    fundacion: 2005,
    historia:
        'Colectivo de muralistas fundado en 2005, autor de las '
        'fachadas pintadas del antiguo distrito industrial del '
        'norte.',
  ),

  // --- DET ---
  Patrocinador(
    equipo: 'DET',
    categoria: 'estadio',
    clave: 'DET_01',
    nombre: 'Motorcity Motors',
    fundacion: 1903,
    historia:
        'Fabricante de motores fundado en 1903, el año en que la '
        'ciudad se convirtió en la capital del automóvil.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'bebida',
    clave: 'DET_02',
    nombre: 'Belle Isle Brew',
    fundacion: 1957,
    historia:
        'Cervecería fundada en 1957, con terraza frente a la '
        'fuente de la isla-parque del río.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'estadio',
    clave: 'DET_03',
    nombre: 'Renaissance Rivets',
    fundacion: 1977,
    historia:
        'Fábrica de remaches y tornillería fundada en 1977, el '
        'año del complejo de torres que dio nombre al '
        'renacimiento de la ciudad.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'estadio',
    clave: 'DET_04',
    nombre: 'Great Lakes Grid',
    fundacion: 1919,
    historia:
        'Eléctrica fundada en 1919, con la silueta de los cinco '
        'lagos partida por un rayo en su emblema.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'estadio',
    clave: 'DET_07',
    nombre: 'Ambassador Span',
    fundacion: 1929,
    historia:
        'Constructora de puentes fundada en 1929, el año del que '
        'cruza el río hasta Canadá.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'bebida',
    clave: 'DET_08',
    nombre: 'Eastern Market Eats',
    fundacion: 1891,
    historia:
        'Distribuidora de alimentación fundada en 1891, con nave '
        'propia en el mercado de productores más grande del país.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'estadio',
    clave: 'DET_09',
    nombre: 'Riverwalk Watts',
    fundacion: 1948,
    historia:
        'Hidroeléctrica fundada en 1948, con turbinas en la '
        'orilla que la ciudad convirtió en paseo.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'bebida',
    clave: 'DET_10',
    nombre: 'Corktown Coffee',
    fundacion: 1936,
    historia:
        'Tostadero fundado en 1936 en el barrio irlandés más '
        'antiguo de la ciudad.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'camiseta',
    clave: 'DET_11',
    nombre: 'Assembly Line Apps',
    fundacion: 2011,
    historia:
        'Empresa de software industrial fundada en 2011, '
        'especializada en automatizar lo que aquí se inventó en '
        '1913.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'ocio',
    clave: 'DET_12',
    nombre: 'Spirit Plaza Sound',
    fundacion: 1958,
    historia:
        'Empresa de sonido para eventos fundada en 1958, con el '
        'espíritu de bronce de la plaza mayor por logo.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'camiseta',
    clave: 'DET_13',
    nombre: 'Fisher Building Financial',
    fundacion: 1928,
    historia:
        'Firma financiera fundada en 1928, con oficinas en el '
        'rascacielos dorado que llaman el mayor edificio de arte '
        'del mundo.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'estadio',
    clave: 'DET_14',
    nombre: 'Eastern Market Ironworks',
    fundacion: 1902,
    historia:
        'Herrería y estructuras fundadas en 1902, autora de las '
        'marquesinas de los cobertizos del mercado.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'bebida',
    clave: 'DET_15',
    nombre: 'Chili Coney Co',
    fundacion: 1917,
    historia:
        'Cadena de perritos con chile fundada en 1917 por dos '
        'hermanos griegos, con dos locales pared con pared que '
        'llevan un siglo compitiendo.',
  ),

  // --- GSW ---
  Patrocinador(
    equipo: 'GSW',
    categoria: 'estadio',
    clave: 'GSW_01',
    nombre: 'Golden Gate Grid',
    fundacion: 1987,
    historia:
        'Fundada en 1987 por un grupo de ingenieros eléctricos '
        'que trabajaron en el mantenimiento del puente Golden '
        'Gate. Hoy es la eléctrica regional que suministra '
        'energía a media Bahía, con una flota de torres de alta '
        'tensión pintadas del mismo naranja internacional del '
        'puente.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'camiseta',
    clave: 'GSW_02',
    nombre: 'FogCity Fiber',
    fundacion: 2011,
    historia:
        'Empresa de telecomunicaciones lanzada en 2011 en un '
        'garaje de SoMa. Su eslogan original, "más rápido que la '
        'niebla", se convirtió en la campaña que la hizo famosa; '
        'hoy tiende fibra óptica por todo el norte de California.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'bebida',
    clave: 'GSW_03',
    nombre: 'Mission Market',
    fundacion: 1974,
    historia:
        'Puesto de burritos familiar abierto en 1974 en el '
        'Distrito de la Misión, ahora convertido en cadena '
        'regional de comida rápida mexicana con más de 40 '
        'locales.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'camiseta',
    clave: 'GSW_04',
    nombre: 'Bay Bytes Bank',
    fundacion: 2015,
    historia:
        'Fintech fundada en 2015 por antiguos empleados de bancos '
        'de inversión de la bahía, especializada en préstamos '
        'para startups tecnológicas.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'camiseta',
    clave: 'GSW_05',
    nombre: 'Alcatraz Apps',
    fundacion: 2009,
    historia:
        'Estudio de software fundado en 2009 que desarrolla '
        'aplicaciones de seguridad y ciberdefensa; su nombre '
        'juega con la idea de un sistema "imposible de hackear, '
        'como la prisión".',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'bebida',
    clave: 'GSW_06',
    nombre: 'Cable Car Cola',
    fundacion: 1962,
    historia:
        'Embotelladora fundada en 1962 que homenajea los icónicos '
        'tranvías de la ciudad; sus latas antiguas de '
        'coleccionista se venden hoy como reliquia local.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'estadio',
    clave: 'GSW_07',
    nombre: 'Painted Ladies Paint',
    fundacion: 1968,
    historia:
        'Empresa familiar de pinturas fundada en 1968, '
        'especializada en los tonos pastel históricos de las '
        'casas victorianas de Alamo Square.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'estadio',
    clave: 'GSW_09',
    nombre: 'Coit Tower Light',
    fundacion: 1995,
    historia:
        'Compañía eléctrica boutique fundada en 1995, '
        'especializada en iluminación arquitectónica de '
        'monumentos y edificios históricos.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'ocio',
    clave: 'GSW_10',
    nombre: 'Lombard Loops',
    fundacion: 2018,
    historia:
        'Startup de movilidad urbana fundada en 2018 que diseña '
        'rutas turísticas en bicicleta eléctrica por las calles '
        'más empinadas de la ciudad.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'camiseta',
    clave: 'GSW_11',
    nombre: 'Ferry Clock Credit',
    fundacion: 1930,
    historia:
        'Cooperativa de crédito fundada en 1930 cerca del Ferry '
        'Building, que originalmente prestaba dinero a '
        'estibadores y pescadores del puerto.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'estadio',
    clave: 'GSW_12',
    nombre: 'Chinatown Gate Co',
    fundacion: 1955,
    historia:
        'Importadora y distribuidora mayorista fundada en 1955 '
        'por una familia inmigrante, proveedora de mercancía para '
        'los comercios del barrio chino más antiguo de EE.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'bebida',
    clave: 'GSW_13',
    nombre: 'Sourdough Steam',
    fundacion: 1889,
    historia:
        'Panadería artesanal fundada en 1889, heredera de la '
        'receta original de masa madre que trajeron los '
        'buscadores de oro de la Fiebre de 1849.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'estadio',
    clave: 'GSW_14',
    nombre: 'Sea Lion Solar',
    fundacion: 2012,
    historia:
        'Empresa de energía solar fundada en 2012, cuyo nombre '
        'rinde homenaje a los leones marinos que colonizaron el '
        'muelle 39 en los noventa.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'ocio',
    clave: 'GSW_15',
    nombre: 'Twin Peaks Transit',
    fundacion: 1948,
    historia:
        'Operador de transporte público fundado en 1948, '
        'encargado históricamente de las líneas de tranvía que '
        'suben las colinas más pronunciadas de la ciudad.',
  ),

  // --- HOU ---
  Patrocinador(
    equipo: 'HOU',
    categoria: 'estadio',
    clave: 'HOU_01',
    nombre: 'Gulfstream Gas',
    fundacion: 1921,
    historia:
        'Compañía petrolera fundada en 1921, con operaciones en '
        'las plataformas del Golfo de México.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'ocio',
    clave: 'HOU_02',
    nombre: 'Space City Semis',
    fundacion: 1969,
    historia:
        'Empresa de logística fundada en 1969, año del primer '
        'paseo lunar transmitido desde el Centro Espacial '
        'Johnson.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'bebida',
    clave: 'HOU_03',
    nombre: 'Bayou Bites BBQ',
    fundacion: 1952,
    historia:
        'Restaurante de barbacoa fundado en 1952, junto a los '
        'pantanos y arroyos que cruzan la ciudad.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'estadio',
    clave: 'HOU_05',
    nombre: 'ShipChannel Steel',
    fundacion: 1914,
    historia:
        'Fundición industrial fundada en 1914, año de apertura '
        'del Canal de Navegación de Houston.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'camiseta',
    clave: 'HOU_06',
    nombre: 'TexMex Threads',
    fundacion: 1978,
    historia:
        'Marca de moda fundada en 1978, con diseños inspirados en '
        'la cultura fronteriza tex-mex.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'camiseta',
    clave: 'HOU_08',
    nombre: 'Montrose Mint',
    fundacion: 1985,
    historia:
        'Farmacéutica fundada en 1985, con sede en el vibrante y '
        'diverso barrio de Montrose.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'bebida',
    clave: 'HOU_09',
    nombre: 'Buffalo Bayou Brew',
    fundacion: 2011,
    historia:
        'Cervecería artesanal fundada en 2011, junto al arroyo '
        'que da origen histórico a la ciudad.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'camiseta',
    clave: 'HOU_10',
    nombre: 'Galleria Gold',
    fundacion: 1970,
    historia:
        'Empresa inmobiliaria fundada en 1970, año de apertura '
        'del centro comercial Galleria.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'camiseta',
    clave: 'HOU_11',
    nombre: 'TMC Med',
    fundacion: 1945,
    historia:
        'Empresa biotecnológica fundada en 1945, con sede en el '
        'complejo médico más grande del mundo, el Texas Medical '
        'Center.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'bebida',
    clave: 'HOU_12',
    nombre: 'Clutch City Coffee',
    fundacion: 1995,
    historia:
        'Cafetería fundada en 1995, homenaje al apodo "Clutch '
        'City" que la ciudad se ganó en los años noventa.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'estadio',
    clave: 'HOU_13',
    nombre: 'Sam Houston Solar',
    fundacion: 1836,
    historia:
        'Empresa de energía fundada en 1836, año de fundación de '
        'la ciudad en honor al héroe de la independencia texana.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'bebida',
    clave: 'HOU_14',
    nombre: 'Space Coast Snacks',
    fundacion: 1962,
    historia:
        'Marca de aperitivos fundada en 1962, año de fundación '
        'del Centro Espacial Johnson.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'ocio',
    clave: 'HOU_15',
    nombre: 'Loop 610 Logistics',
    fundacion: 1965,
    historia:
        'Empresa de transporte fundada en 1965, año de '
        'finalización del anillo de circunvalación I-610.',
  ),

  // --- IND ---
  Patrocinador(
    equipo: 'IND',
    categoria: 'camiseta',
    clave: 'IND_02',
    nombre: 'Circle City Credit',
    fundacion: 1821,
    historia:
        'Cooperativa de crédito fundada en 1821, año de fundación '
        'de la ciudad diseñada en torno al Monumento Circle.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'bebida',
    clave: 'IND_03',
    nombre: 'Cornbelt Chips',
    fundacion: 1965,
    historia:
        'Marca de snacks fundada en 1965, homenaje al cinturón '
        'maicero que rodea la capital de Indiana.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'bebida',
    clave: 'IND_05',
    nombre: 'Canal Walk Coffee',
    fundacion: 1988,
    historia:
        'Cafetería fundada en 1988, junto al canal restaurado del '
        'centro de la ciudad.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'camiseta',
    clave: 'IND_06',
    nombre: 'Hoosier Health+',
    fundacion: 1946,
    historia:
        'Cadena de clínicas fundada en 1946, con nombre derivado '
        'del gentilicio tradicional de los habitantes de Indiana.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'estadio',
    clave: 'IND_07',
    nombre: 'White River Watts',
    fundacion: 1913,
    historia:
        'Central hidroeléctrica fundada en 1913, aprovechando el '
        'caudal del río White que cruza la ciudad.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'ocio',
    clave: 'IND_08',
    nombre: 'Mass Ave Media',
    fundacion: 2001,
    historia:
        'Agencia de comunicación fundada en 2001, con sede en el '
        'distrito cultural de Massachusetts Avenue.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'estadio',
    clave: 'IND_09',
    nombre: 'Fountain Square Foundry',
    fundacion: 1954,
    historia:
        'Taller artesanal fundado en 1954, en el histórico barrio '
        'bohemio de Fountain Square.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'bebida',
    clave: 'IND_10',
    nombre: 'Broad Ripple Brew',
    fundacion: 1994,
    historia:
        'Cervecería artesanal fundada en 1994, en el animado '
        'barrio de Broad Ripple junto al canal.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'ocio',
    clave: 'IND_11',
    nombre: 'Crossroads Cargo',
    fundacion: 1937,
    historia:
        'Empresa de transporte fundada en 1937, homenaje al lema '
        'de Indiana como "el cruce de caminos de América".',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'camiseta',
    clave: 'IND_12',
    nombre: 'Market Street Motors',
    fundacion: 2018,
    historia:
        'Concesionario de vehículos eléctricos fundado en 2018, '
        'con sede en la histórica calle del mercado.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'camiseta',
    clave: 'IND_13',
    nombre: 'Union Station Vault',
    fundacion: 1888,
    historia:
        'Banco fundado en 1888, año de construcción de la '
        'estación ferroviaria Union Station.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'estadio',
    clave: 'IND_14',
    nombre: 'Pogues Run Pipes',
    fundacion: 1920,
    historia:
        'Empresa de fontanería fundada en 1920, nombrada por el '
        'arroyo subterráneo que atraviesa el centro de la ciudad.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'bebida',
    clave: 'IND_15',
    nombre: 'Mile Square Meals',
    fundacion: 2010,
    historia:
        'Cadena de restaurantes fundada en 2010, en el kilómetro '
        'cuadrado original que dio forma al trazado urbano.',
  ),

  // --- LA ---
  Patrocinador(
    equipo: 'LA',
    categoria: 'estadio',
    clave: 'LA_01',
    nombre: 'Sunset Solar',
    fundacion: 2008,
    historia:
        'Empresa de energía renovable fundada en 2008, con '
        'paneles instalados a lo largo del icónico Sunset '
        'Boulevard.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'ocio',
    clave: 'LA_02',
    nombre: 'Hollywood Studios',
    fundacion: 1912,
    historia:
        'Productora audiovisual fundada en 1912, en los primeros '
        'años de la industria cinematográfica del barrio.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'bebida',
    clave: 'LA_03',
    nombre: 'LA Street Tacos',
    fundacion: 1978,
    historia:
        'Cadena de comida callejera fundada en 1978, pionera del '
        'boom de food trucks mexicanos de la ciudad.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'camiseta',
    clave: 'LA_04',
    nombre: 'CityView Capital',
    fundacion: 1990,
    historia:
        'Firma de inversión inmobiliaria fundada en 1990, '
        'especializada en el desarrollo urbano del downtown de '
        'Los Ángeles.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'ocio',
    clave: 'LA_05',
    nombre: 'LAX Global',
    fundacion: 1930,
    historia:
        'Empresa de logística aeroportuaria fundada en 1930, con '
        'operaciones centradas en el aeropuerto internacional de '
        'la ciudad.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'camiseta',
    clave: 'LA_07',
    nombre: 'LA Icons Apparel',
    fundacion: 2002,
    historia:
        'Marca de ropa fundada en 2002, inspirada en el Paseo de '
        'la Fama de Hollywood Boulevard.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'camiseta',
    clave: 'LA_08',
    nombre: 'Angelus Health',
    fundacion: 1945,
    historia:
        'Cadena de clínicas fundada en 1945, con nombre derivado '
        'del apodo histórico "La Ciudad de los Ángeles".',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'bebida',
    clave: 'LA_09',
    nombre: 'Pacific Waves Beverages',
    fundacion: 1965,
    historia:
        'Embotelladora fundada en 1965, con primeras plantas '
        'junto a las playas del Pacífico.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'camiseta',
    clave: 'LA_10',
    nombre: 'Griffith Realty',
    fundacion: 1896,
    historia:
        'Inmobiliaria fundada en 1896, año de donación del parque '
        'Griffith a la ciudad por su fundador filantrópico.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'ocio',
    clave: 'LA_11',
    nombre: 'LA Live Music',
    fundacion: 1971,
    historia:
        'Sello discográfico fundado en 1971, motor de la escena '
        'musical del centro de Los Ángeles.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'ocio',
    clave: 'LA_12',
    nombre: 'Metro Connect',
    fundacion: 1990,
    historia:
        'Operador de transporte público fundado en 1990, gestor '
        'de la red de metro ligero de la ciudad.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'bebida',
    clave: 'LA_13',
    nombre: 'Downtown Dining',
    fundacion: 2015,
    historia:
        'Colectivo gastronómico fundado en 2015, impulsor de la '
        'revitalización culinaria del centro histórico.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'estadio',
    clave: 'LA_14',
    nombre: 'LA Clean Energy',
    fundacion: 2012,
    historia:
        'Empresa de energía eólica y solar fundada en 2012, con '
        'instalaciones en las colinas del área metropolitana.',
  ),
  Patrocinador(
    equipo: 'LA',
    categoria: 'ocio',
    clave: 'LA_15',
    nombre: 'Coastline Logistics',
    fundacion: 1958,
    historia:
        'Empresa de transporte fundada en 1958, operando a lo '
        'largo de la autopista costera 101.',
  ),

  // --- MEM ---
  Patrocinador(
    equipo: 'MEM',
    categoria: 'ocio',
    clave: 'MEM_01',
    nombre: 'Beale Street Blues',
    fundacion: 1909,
    historia:
        'Sello discográfico fundado en 1909, en la histórica '
        'calle Beale, cuna del blues americano.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'bebida',
    clave: 'MEM_02',
    nombre: 'River City Ribs',
    fundacion: 1948,
    historia:
        'Restaurante de barbacoa fundado en 1948, homenaje al '
        'apodo de Memphis como "la Ciudad del Río".',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'ocio',
    clave: 'MEM_04',
    nombre: 'Cotton Belt Cargo',
    fundacion: 1873,
    historia:
        'Empresa de logística fundada en 1873, en la época dorada '
        'del comercio de algodón por el río Mississippi.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'bebida',
    clave: 'MEM_05',
    nombre: 'Delta Drift Cola',
    fundacion: 1922,
    historia:
        'Embotelladora fundada en 1922, inspirada en el meandro '
        'del delta del Mississippi.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'estadio',
    clave: 'MEM_06',
    nombre: 'Soulshine Solar',
    fundacion: 2014,
    historia:
        'Empresa de energía renovable fundada en 2014, con nombre '
        'inspirado en la música soul nacida en los estudios de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'estadio',
    clave: 'MEM_07',
    nombre: 'Hernando Steel',
    fundacion: 1949,
    historia:
        'Empresa de construcción metálica fundada en 1949, año de '
        'planificación del puente Hernando de Soto sobre el '
        'Mississippi.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'estadio',
    clave: 'MEM_08',
    nombre: 'Pyramid Power',
    fundacion: 1991,
    historia:
        'Compañía eléctrica fundada en 1991, año de inauguración '
        'de la icónica Pirámide de Memphis.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'camiseta',
    clave: 'MEM_09',
    nombre: 'Bluff City Bank',
    fundacion: 1864,
    historia:
        'Banco fundado en 1864, homenaje al apodo "Ciudad del '
        'Acantilado" por su ubicación sobre los altos del río.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'camiseta',
    clave: 'MEM_11',
    nombre: 'Overton Park Outdoor',
    fundacion: 1901,
    historia:
        'Marca de ropa outdoor fundada en 1901, año de fundación '
        'del parque urbano Overton.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'ocio',
    clave: 'MEM_12',
    nombre: 'Peabody Paddle',
    fundacion: 1869,
    historia:
        'Empresa de ocio fundada en 1869, en homenaje a los '
        'icónicos patos del hotel Peabody.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'ocio',
    clave: 'MEM_13',
    nombre: 'Main Street Trolley+',
    fundacion: 1993,
    historia:
        'Operador de tranvías fundado en 1993, gestionando la '
        'línea histórica de la calle principal.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'ocio',
    clave: 'MEM_15',
    nombre: 'Mud Island Marine',
    fundacion: 1982,
    historia:
        'Empresa de turismo fluvial fundada en 1982, operando en '
        'la isla artificial del río Mississippi.',
  ),

  // --- MIA ---
  Patrocinador(
    equipo: 'MIA',
    categoria: 'camiseta',
    clave: 'MIA_01',
    nombre: 'Ocean Drive Optics',
    fundacion: 1985,
    historia:
        'Óptica fundada en 1985, con boutique original en el '
        'corazón art decó de Ocean Drive.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'bebida',
    clave: 'MIA_02',
    nombre: 'Calle Ocho Café',
    fundacion: 1959,
    historia:
        'Cafetería fundada en 1959, en plena Pequeña Habana, '
        'sirviendo café cubano tradicional desde su fundación.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'bebida',
    clave: 'MIA_03',
    nombre: 'Heatwave Hydro',
    fundacion: 2001,
    historia:
        'Marca de bebidas isotónicas fundada en 2001, pensada '
        'para combatir el calor tropical de la ciudad.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'estadio',
    clave: 'MIA_04',
    nombre: 'PortMiami Pack',
    fundacion: 1960,
    historia:
        'Empresa de logística portuaria fundada en 1960, operando '
        'en uno de los puertos de cruceros más activos del mundo.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'camiseta',
    clave: 'MIA_05',
    nombre: 'Neon Nights Bank',
    fundacion: 1988,
    historia:
        'Banco fundado en 1988, en la época dorada de la estética '
        'neón de South Beach.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'camiseta',
    clave: 'MIA_06',
    nombre: 'Biscayne Breeze',
    fundacion: 1995,
    historia:
        'Marca de moda náutica fundada en 1995, inspirada en las '
        'aguas turquesas de la bahía de Biscayne.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'ocio',
    clave: 'MIA_07',
    nombre: 'Wynwood Walls',
    fundacion: 2009,
    historia:
        'Empresa de pintura y arte urbano fundada en 2009, '
        'coincidiendo con el nacimiento del distrito de murales '
        'Wynwood.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'camiseta',
    clave: 'MIA_08',
    nombre: 'Brickell Capital',
    fundacion: 2003,
    historia:
        'Firma de banca de inversión fundada en 2003, con sede en '
        'el distrito financiero de Brickell.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'ocio',
    clave: 'MIA_09',
    nombre: 'Everglades Eco Tours',
    fundacion: 1974,
    historia:
        'Empresa de ecoturismo fundada en 1974, operando '
        'excursiones guiadas por el parque nacional de los '
        'Everglades.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'camiseta',
    clave: 'MIA_10',
    nombre: 'South Beach Sun',
    fundacion: 1978,
    historia:
        'Marca de protección solar fundada en 1978, nacida en las '
        'playas más famosas de Miami.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'camiseta',
    clave: 'MIA_11',
    nombre: 'Freedom Tower Tech',
    fundacion: 1997,
    historia:
        'Empresa tecnológica fundada en 1997, con sede en la '
        'histórica Freedom Tower, antiguo centro de recepción de '
        'refugiados cubanos.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'bebida',
    clave: 'MIA_12',
    nombre: 'Coconut Grove Co',
    fundacion: 1873,
    historia:
        'Empresa agrícola fundada en 1873, en el barrio más '
        'antiguo y frondoso de la ciudad.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'bebida',
    clave: 'MIA_13',
    nombre: 'Little Havana Cigars',
    fundacion: 1961,
    historia:
        'Tabaquería fundada en 1961, heredera de la tradición '
        'cubana de torcido de puros a mano.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'estadio',
    clave: 'MIA_14',
    nombre: 'Coral Gables Granite',
    fundacion: 1925,
    historia:
        'Empresa de construcción fundada en 1925, año de '
        'fundación de la ciudad planificada de Coral Gables.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'ocio',
    clave: 'MIA_15',
    nombre: 'Venetian Pool Resorts',
    fundacion: 1923,
    historia:
        'Cadena hotelera fundada en 1923, año de apertura de la '
        'histórica piscina de estilo veneciano.',
  ),

  // --- MIL ---
  Patrocinador(
    equipo: 'MIL',
    categoria: 'bebida',
    clave: 'MIL_01',
    nombre: 'Lakefront Lager',
    fundacion: 1987,
    historia:
        'Cervecería fundada en 1987, junto a las orillas del lago '
        'Michigan.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'estadio',
    clave: 'MIL_04',
    nombre: 'Cream City Concrete',
    fundacion: 1868,
    historia:
        'Empresa de construcción fundada en 1868, en referencia '
        'al ladrillo color crema típico de la arquitectura local.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'camiseta',
    clave: 'MIL_05',
    nombre: 'Third Ward Threads',
    fundacion: 1992,
    historia:
        'Taller de costura fundado en 1992, en el histórico '
        'distrito industrial reconvertido en zona de moda.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'bebida',
    clave: 'MIL_06',
    nombre: 'Frozen Custard Co',
    fundacion: 1938,
    historia:
        'Heladería fundada en 1938, especializada en el postre '
        'helado clásico del medio oeste americano.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'estadio',
    clave: 'MIL_08',
    nombre: 'Hoan Bridge Steel',
    fundacion: 1972,
    historia:
        'Empresa de ingeniería fundada en 1972, año de '
        'construcción del puente amarillo Hoan sobre la bahía.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'estadio',
    clave: 'MIL_09',
    nombre: 'Menomonee Millwork',
    fundacion: 1885,
    historia:
        'Carpintería industrial fundada en 1885, en el valle del '
        'río Menomonee, corazón industrial histórico de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'ocio',
    clave: 'MIL_11',
    nombre: 'Domes Flora Tech',
    fundacion: 1967,
    historia:
        'Empresa de horticultura fundada en 1967, año de '
        'construcción de las tres cúpulas del jardín botánico '
        'Mitchell Park.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'estadio',
    clave: 'MIL_12',
    nombre: 'Jones Island Salt',
    fundacion: 1925,
    historia:
        'Empresa de tratamiento de aguas fundada en 1925, con '
        'planta en la isla industrial Jones.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'bebida',
    clave: 'MIL_13',
    nombre: 'Bay View Brew Labs',
    fundacion: 2015,
    historia:
        'Tostadero de café fundado en 2015, en el vecindario '
        'junto a la bahía.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'ocio',
    clave: 'MIL_14',
    nombre: 'KK Kayaks',
    fundacion: 1995,
    historia:
        'Empresa de deportes acuáticos fundada en 1995, operando '
        'en el río Kinnickinnic.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'ocio',
    clave: 'MIL_15',
    nombre: 'Bradford Beach Breeze',
    fundacion: 1915,
    historia:
        'Club de playa fundado en 1915, en la playa urbana más '
        'popular de la ciudad junto al lago Michigan.',
  ),

  // --- MIN ---
  Patrocinador(
    equipo: 'MIN',
    categoria: 'camiseta',
    clave: 'MIN_01',
    nombre: 'Twin Cities Fiber',
    fundacion: 1999,
    historia:
        'Empresa de telecomunicaciones fundada en 1999, con red '
        'compartida entre Minneapolis y su ciudad hermana, St. '
        'Paul.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'bebida',
    clave: 'MIN_02',
    nombre: 'North Loop Noodles',
    fundacion: 2011,
    historia:
        'Restaurante fundado en 2011 en el antiguo distrito de '
        'almacenes reconvertido en zona gastronómica.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'camiseta',
    clave: 'MIN_03',
    nombre: 'Lake Ice Labs',
    fundacion: 2014,
    historia:
        'Empresa de tecnología fundada en 2014, nombrada por los '
        'más de 10.000 lagos que se congelan cada invierno en la '
        'región.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'bebida',
    clave: 'MIN_04',
    nombre: 'Mill City Malt',
    fundacion: 1880,
    historia:
        'Fábrica de malta fundada en 1880, heredera de la época '
        'dorada de los molinos harineros junto al río '
        'Mississippi.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'estadio',
    clave: 'MIN_05',
    nombre: 'Prairie Wind Power',
    fundacion: 2005,
    historia:
        'Compañía de energía eólica fundada en 2005, con parques '
        'de turbinas en las praderas de Minnesota.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'bebida',
    clave: 'MIN_06',
    nombre: 'Skyway Snacks',
    fundacion: 1962,
    historia:
        'Cadena de tiendas fundada en 1962, ubicada en la red de '
        'pasillos elevados que conectan el centro de la ciudad.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'estadio',
    clave: 'MIN_07',
    nombre: 'Stone Arch Solar',
    fundacion: 2016,
    historia:
        'Empresa de energía solar fundada en 2016, instalada '
        'junto al histórico puente de piedra sobre el río '
        'Mississippi.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'ocio',
    clave: 'MIN_08',
    nombre: 'Cherry Spoon Creative',
    fundacion: 1998,
    historia:
        'Agencia de diseño fundada en 1998, inspirada en la '
        'icónica escultura de la cuchara y la cereza del Jardín '
        'de Esculturas de Walker.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'ocio',
    clave: 'MIN_09',
    nombre: 'Chain of Lakes Canoes',
    fundacion: 1925,
    historia:
        'Empresa de alquiler de canoas fundada en 1925, operando '
        'en la cadena de lagos urbanos del sur de la ciudad.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'camiseta',
    clave: 'MIN_10',
    nombre: 'Foshay Financial',
    fundacion: 1929,
    historia:
        'Firma de asesoría financiera fundada en 1929, con sede '
        'en el histórico rascacielos Foshay Tower.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'bebida',
    clave: 'MIN_11',
    nombre: 'Loon Lake Water',
    fundacion: 1978,
    historia:
        'Embotelladora de agua fundada en 1978, nombrada por el '
        'somorgujo, ave emblema del estado de Minnesota.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'estadio',
    clave: 'MIN_13',
    nombre: 'St Anthony Forge',
    fundacion: 1848,
    historia:
        'Fundición fundada en 1848, aprovechando la energía de '
        'las cataratas de San Antonio en los inicios industriales '
        'de la ciudad.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'bebida',
    clave: 'MIN_14',
    nombre: 'Minnehaha Mist',
    fundacion: 1965,
    historia:
        'Marca de bebidas fundada en 1965, inspirada en la '
        'cascada Minnehaha del parque homónimo.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'ocio',
    clave: 'MIN_15',
    nombre: 'Nicollet Mall',
    fundacion: 1990,
    historia:
        'Empresa de transporte urbano fundada en 1990, operando '
        'la línea de autobuses de la calle comercial peatonal '
        'Nicollet.',
  ),

  // --- NOP ---
  Patrocinador(
    equipo: 'NOP',
    categoria: 'bebida',
    clave: 'NOP_01',
    nombre: 'French Quarter Fizz',
    fundacion: 1920,
    historia:
        'Embotelladora fundada en 1920, con primeras bodegas en '
        'el histórico Barrio Francés.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'camiseta',
    clave: 'NOP_02',
    nombre: 'Bayou Bytes',
    fundacion: 2012,
    historia:
        'Empresa de tecnología fundada en 2012, nombrada por los '
        'pantanos de cipreses que rodean la ciudad.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'ocio',
    clave: 'NOP_03',
    nombre: 'Mardi Gras Mask Co',
    fundacion: 1890,
    historia:
        'Taller artesanal de máscaras fundado en 1890, proveedor '
        'tradicional de los desfiles de Carnaval.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'ocio',
    clave: 'NOP_04',
    nombre: 'Crescent City Cargo',
    fundacion: 1901,
    historia:
        'Empresa naviera fundada en 1901, homenaje al apodo de '
        '"Ciudad Creciente" por la curva del río Mississippi.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'ocio',
    clave: 'NOP_05',
    nombre: 'Jazz Alley Audio',
    fundacion: 1917,
    historia:
        'Discográfica fundada en 1917, coincidiendo con el '
        'nacimiento del jazz en los clubes de la ciudad.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'bebida',
    clave: 'NOP_06',
    nombre: 'Gumbo Grill',
    fundacion: 1955,
    historia:
        'Restaurante fundado en 1955, especializado en el guiso '
        'criollo más representativo de Luisiana.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'ocio',
    clave: 'NOP_07',
    nombre: 'St Charles Streetcar',
    fundacion: 1835,
    historia:
        'Operador de tranvías fundado en 1835, gestor de una de '
        'las líneas de tranvía más antiguas en funcionamiento del '
        'país.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'bebida',
    clave: 'NOP_08',
    nombre: 'Beignet Boys',
    fundacion: 1862,
    historia:
        'Pastelería fundada en 1862, célebre por sus '
        'tradicionales beignets espolvoreados con azúcar glas.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'estadio',
    clave: 'NOP_09',
    nombre: 'Pontchartrain Power',
    fundacion: 1956,
    historia:
        'Compañía eléctrica fundada en 1956, año de construcción '
        'de la calzada que cruza el lago Pontchartrain.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'estadio',
    clave: 'NOP_11',
    nombre: 'Jackson Square Iron',
    fundacion: 1803,
    historia:
        'Herrería artística fundada en 1803, especializada en las '
        'rejas ornamentales del Barrio Francés.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'bebida',
    clave: 'NOP_12',
    nombre: 'Voodoo Vod',
    fundacion: 1994,
    historia:
        'Empresa de bebidas espirituosas fundada en 1994, '
        'inspirada en la tradición vudú de Luisiana.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'ocio',
    clave: 'NOP_13',
    nombre: 'Riverboat Steam',
    fundacion: 1812,
    historia:
        'Compañía naviera fundada en 1812, operadora de los '
        'históricos barcos de vapor de paletas del Mississippi.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'camiseta',
    clave: 'NOP_14',
    nombre: 'Magazine St Market',
    fundacion: 1988,
    historia:
        'Colectivo de boutiques fundado en 1988, en la histórica '
        'calle comercial Magazine Street.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'ocio',
    clave: 'NOP_15',
    nombre: 'Algiers Point',
    fundacion: 1827,
    historia:
        'Empresa de transporte fluvial fundada en 1827, gestora '
        'del ferry que cruza el Mississippi hacia el barrio de '
        'Algiers.',
  ),

  // --- NYK ---
  Patrocinador(
    equipo: 'NYK',
    categoria: 'camiseta',
    clave: 'NYK_01',
    nombre: 'Empire Edge Bank',
    fundacion: 1931,
    historia:
        'Banco de inversión fundado en 1931, el mismo año de '
        'inauguración del Empire State Building que inspira su '
        'logo.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'camiseta',
    clave: 'NYK_02',
    nombre: 'Broadway Bytes',
    fundacion: 1998,
    historia:
        'Empresa de software para artes escénicas fundada en '
        '1998, proveedora de sistemas de venta de entradas para '
        'los teatros de Broadway.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'bebida',
    clave: 'NYK_03',
    nombre: 'Hudson Hydro',
    fundacion: 1917,
    historia:
        'Compañía de gestión hídrica fundada en 1917, encargada '
        'del suministro de agua desde el río Hudson.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'camiseta',
    clave: 'NYK_04',
    nombre: 'Fifth Ave Fits',
    fundacion: 1955,
    historia:
        'Casa de moda de lujo fundada en 1955, con boutique '
        'insignia en la Quinta Avenida.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'estadio',
    clave: 'NYK_06',
    nombre: 'Liberty Lithium',
    fundacion: 2019,
    historia:
        'Fabricante de baterías fundado en 2019, homenaje a la '
        'antorcha de la Estatua de la Libertad.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'ocio',
    clave: 'NYK_08',
    nombre: 'Central Park Canopy',
    fundacion: 1962,
    historia:
        'Empresa de paisajismo fundada en 1962, encargada del '
        'mantenimiento de la vegetación del parque más famoso de '
        'Manhattan.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'camiseta',
    clave: 'NYK_09',
    nombre: 'Wall Street Wealth',
    fundacion: 1889,
    historia:
        'Firma de gestión de patrimonio fundada en 1889, con sede '
        'en el corazón del distrito financiero.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'camiseta',
    clave: 'NYK_10',
    nombre: 'Flatiron Fintech',
    fundacion: 2013,
    historia:
        'Startup financiera fundada en 2013, con oficinas en el '
        'histórico edificio Flatiron.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'ocio',
    clave: 'NYK_11',
    nombre: 'Yellow Cab Cargo',
    fundacion: 1907,
    historia:
        'Empresa de logística urbana fundada en 1907, el mismo '
        'año de introducción del primer taxi amarillo de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'ocio',
    clave: 'NYK_12',
    nombre: 'High Line Horticulture',
    fundacion: 2009,
    historia:
        'Empresa de jardinería urbana fundada en 2009, encargada '
        'del mantenimiento del parque elevado High Line.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'camiseta',
    clave: 'NYK_13',
    nombre: 'Grand Central Clock',
    fundacion: 1913,
    historia:
        'Empresa de relojería fundada en 1913, el año de '
        'inauguración de la Terminal Grand Central.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'ocio',
    clave: 'NYK_14',
    nombre: 'Harlem Horns Jazz',
    fundacion: 1932,
    historia:
        'Sello discográfico fundado en 1932, en pleno '
        'Renacimiento de Harlem, cuna del jazz neoyorquino.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'camiseta',
    clave: 'NYK_15',
    nombre: 'Times Square Tensor',
    fundacion: 2020,
    historia:
        'Empresa de inteligencia artificial fundada en 2020, con '
        'sede en los rascacielos digitales de Times Square.',
  ),

  // --- OKC ---
  Patrocinador(
    equipo: 'OKC',
    categoria: 'camiseta',
    clave: 'OKC_01',
    nombre: 'Tornado Trail Gear',
    fundacion: 1991,
    historia:
        'Marca de equipamiento de exterior fundada en 1991, '
        'especializada en refugios y kits para la temporada de '
        'tornados.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'bebida',
    clave: 'OKC_02',
    nombre: 'Bricktown Brew',
    fundacion: 1993,
    historia:
        'Cervecería fundada en 1993 en los almacenes de ladrillo '
        'junto al canal, primera del barrio reconvertido.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'estadio',
    clave: 'OKC_03',
    nombre: 'Plains Petroleum',
    fundacion: 1928,
    historia:
        'Petrolera fundada en 1928, con pozos entre los trigales '
        'que rodean la ciudad.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'camiseta',
    clave: 'OKC_04',
    nombre: 'Thunderhead Tech',
    fundacion: 2003,
    historia:
        'Empresa de meteorología y sensores fundada en 2003, '
        'dedicada a avisar de las tormentas del corredor central.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'bebida',
    clave: 'OKC_05',
    nombre: 'Cattlemen Cuts',
    fundacion: 1910,
    historia:
        'Carnicería y asador fundados en 1910 junto a los '
        'corrales, con el sello de ganadería marcado en la '
        'puerta.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'ocio',
    clave: 'OKC_06',
    nombre: 'Route 66 Retro',
    fundacion: 1946,
    historia:
        'Cadena de moteles y cafeterías fundada en 1946 en la '
        'carretera madre, restaurada entera en los años noventa.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'estadio',
    clave: 'OKC_08',
    nombre: 'Scissortail Solar',
    fundacion: 2010,
    historia:
        'Instaladora de energía solar fundada en 2010, con el '
        'pájaro tijereta del estado posado en cada panel.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'estadio',
    clave: 'OKC_09',
    nombre: 'Stockyards Steel',
    fundacion: 1910,
    historia:
        'Acería y fabricante de vallado ganadero fundada en 1910, '
        'proveedora de los corrales históricos del oeste de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'ocio',
    clave: 'OKC_10',
    nombre: 'Myriad Gardens Flora',
    fundacion: 1988,
    historia:
        'Vivero y jardinería fundados en 1988, encargados del '
        'invernadero tubular del jardín botánico del centro.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'ocio',
    clave: 'OKC_11',
    nombre: 'Red Earth Pottery',
    fundacion: 1978,
    historia:
        'Alfarería fundada en 1978, con arcilla roja de la región '
        'y motivos de las naciones originarias del estado.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'ocio',
    clave: 'OKC_12',
    nombre: 'Plaza District Prints',
    fundacion: 1997,
    historia:
        'Imprenta y serigrafía fundadas en 1997, autora de los '
        'carteles del distrito de galerías y su feria anual.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'estadio',
    clave: 'OKC_13',
    nombre: 'Overholser Oils',
    fundacion: 1936,
    historia:
        'Refinería de aceites industriales fundada en 1936, '
        'nombrada por el lago y la mansión del fundador de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'estadio',
    clave: 'OKC_14',
    nombre: 'Paseo Arts Paint',
    fundacion: 1929,
    historia:
        'Fábrica de pinturas fundada en 1929, proveedora del '
        'barrio de estudios de estilo español desde su primera '
        'galería.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'ocio',
    clave: 'OKC_15',
    nombre: 'Lake Hefner Lighthouse',
    fundacion: 1999,
    historia:
        'Empresa de ocio náutico fundada en 1999, operadora de '
        'las escuelas de vela del lago y su faro postizo.',
  ),

  // --- ORL ---
  Patrocinador(
    equipo: 'ORL',
    categoria: 'estadio',
    clave: 'ORL_01',
    nombre: 'ThemePark Power',
    fundacion: 1971,
    historia:
        'Compañía eléctrica fundada en 1971, coincidiendo con la '
        'apertura de los primeros grandes parques temáticos de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'camiseta',
    clave: 'ORL_02',
    nombre: 'Citrus Circuit',
    fundacion: 1995,
    historia:
        'Empresa de tecnología fundada en 1995, con nombre '
        'inspirado en los antiguos naranjales que ocupaban la '
        'región antes del turismo.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'estadio',
    clave: 'ORL_03',
    nombre: 'Lake Eola Lights',
    fundacion: 1985,
    historia:
        'Compañía de iluminación fundada en 1985, responsable del '
        'alumbrado ornamental de la fuente del lago Eola.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'ocio',
    clave: 'ORL_04',
    nombre: 'I-Drive Inns',
    fundacion: 1978,
    historia:
        'Cadena hotelera fundada en 1978, con sus primeros '
        'establecimientos en la famosa International Drive.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'ocio',
    clave: 'ORL_05',
    nombre: 'MagicHour Media',
    fundacion: 2001,
    historia:
        'Productora de espectáculos fundada en 2001, '
        'especializada en shows nocturnos y de fuegos '
        'artificiales.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'bebida',
    clave: 'ORL_06',
    nombre: 'SpaceCoast Snacks',
    fundacion: 1988,
    historia:
        'Marca de aperitivos fundada en 1988, nombrada por la '
        'cercana Costa Espacial de Florida y su historia '
        'aeroespacial.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'bebida',
    clave: 'ORL_08',
    nombre: 'Orange Blossom Brew',
    fundacion: 2009,
    historia:
        'Cervecería artesanal fundada en 2009, elaborando '
        'cervezas con notas cítricas de flor de azahar.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'camiseta',
    clave: 'ORL_09',
    nombre: 'Gator Creek Gear',
    fundacion: 1992,
    historia:
        'Marca de ropa outdoor fundada en 1992, inspirada en los '
        'caimanes que habitan los pantanos y lagos de la región.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'estadio',
    clave: 'ORL_10',
    nombre: 'Winter Park Woods',
    fundacion: 1965,
    historia:
        'Ebanistería fundada en 1965 en el elegante barrio de '
        'Winter Park, célebre por sus robles centenarios.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'estadio',
    clave: 'ORL_11',
    nombre: 'Pulse City Power',
    fundacion: 2005,
    historia:
        'Empresa de energía urbana fundada en 2005, proveedora de '
        'electricidad para el centro de la ciudad.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'ocio',
    clave: 'ORL_12',
    nombre: 'Boggy Creek Boats',
    fundacion: 1975,
    historia:
        'Empresa de turismo de aventura fundada en 1975, operando '
        'excursiones en aerodeslizador por los pantanos cercanos.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'bebida',
    clave: 'ORL_13',
    nombre: 'Milk District Malt',
    fundacion: 1940,
    historia:
        'Lechería histórica fundada en 1940, en el barrio '
        'conocido como "Milk District" por sus antiguas fábricas '
        'lácteas.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'estadio',
    clave: 'ORL_14',
    nombre: 'Celebration Solar',
    fundacion: 2011,
    historia:
        'Empresa de energía renovable fundada en 2011, instalada '
        'en la comunidad planificada de Celebration.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'bebida',
    clave: 'ORL_15',
    nombre: 'Kissimmee Cattle Co',
    fundacion: 1890,
    historia:
        'Ganadería fundada en 1890, heredera de la tradición '
        'vaquera de los ranchos de Kissimmee anteriores al '
        'turismo.',
  ),

  // --- PHI ---
  Patrocinador(
    equipo: 'PHI',
    categoria: 'camiseta',
    clave: 'PHI_01',
    nombre: 'Liberty Bell Bank',
    fundacion: 1876,
    historia:
        'Banco fundado en 1876, en el centenario de la '
        'independencia, con sede cercana a la histórica campana '
        'de la libertad.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'bebida',
    clave: 'PHI_02',
    nombre: 'Cheesesteak Co',
    fundacion: 1930,
    historia:
        'Cadena de restaurantes fundada en 1930, especializada en '
        'el sándwich más famoso de la ciudad.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'estadio',
    clave: 'PHI_03',
    nombre: 'Schuylkill Solar',
    fundacion: 2010,
    historia:
        'Empresa de energía renovable fundada en 2010, instalada '
        'a orillas del río Schuylkill.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'estadio',
    clave: 'PHI_04',
    nombre: 'Broad Street Bolts',
    fundacion: 1954,
    historia:
        'Ferretería industrial fundada en 1954, ubicada en la '
        'histórica avenida Broad Street.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'ocio',
    clave: 'PHI_05',
    nombre: 'Independence Ink',
    fundacion: 1776,
    historia:
        'Editorial e imprenta fundada en 1776, coincidiendo con '
        'la firma de la Declaración de Independencia en la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'camiseta',
    clave: 'PHI_06',
    nombre: 'Rocky Steps Wear',
    fundacion: 1976,
    historia:
        'Marca de ropa deportiva fundada en 1976, inspirada en la '
        'célebre escalinata del Museo de Arte.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'estadio',
    clave: 'PHI_07',
    nombre: 'Keystone Kilns',
    fundacion: 1901,
    historia:
        'Fábrica de cerámica industrial fundada en 1901, homenaje '
        'al apodo de Pensilvania como el "Estado Clave".',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'camiseta',
    clave: 'PHI_08',
    nombre: 'City Hall Spire',
    fundacion: 1994,
    historia:
        'Empresa de telecomunicaciones fundada en 1994, con '
        'antena principal en la torre del Ayuntamiento.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'estadio',
    clave: 'PHI_09',
    nombre: 'Ben Franklin Bridge',
    fundacion: 1926,
    historia:
        'Compañía de ingeniería civil fundada en 1926, año de '
        'inauguración del puente que lleva el nombre del fundador '
        'de la ciudad.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'bebida',
    clave: 'PHI_10',
    nombre: 'Reading Terminal Roast',
    fundacion: 1893,
    historia:
        'Tostadero de café fundado en 1893, dentro del histórico '
        'mercado de la Terminal Reading.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'ocio',
    clave: 'PHI_12',
    nombre: 'Fairmount Park',
    fundacion: 1855,
    historia:
        'Empresa de gestión forestal fundada en 1855, encargada '
        'del mantenimiento de uno de los parques urbanos más '
        'grandes del país.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'ocio',
    clave: 'PHI_13',
    nombre: 'South Street Sound',
    fundacion: 1977,
    historia:
        'Tienda de discos fundada en 1977, epicentro de la escena '
        'musical alternativa de la calle South.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'ocio',
    clave: 'PHI_14',
    nombre: 'Penns Landing Marine',
    fundacion: 1682,
    historia:
        'Empresa naviera fundada en 1682, con sede en el punto '
        'donde William Penn desembarcó por primera vez.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'ocio',
    clave: 'PHI_15',
    nombre: 'Boathouse Row',
    fundacion: 1858,
    historia:
        'Club de remo fundado en 1858, operador de las históricas '
        'casas de botes iluminadas del río Schuylkill.',
  ),

  // --- PHO ---
  Patrocinador(
    equipo: 'PHO',
    categoria: 'estadio',
    clave: 'PHO_01',
    nombre: 'Desert Sun Solar',
    fundacion: 1998,
    historia:
        'Compañía de energía solar fundada en 1998, pionera en '
        'aprovechar los más de 300 días de sol al año del '
        'desierto de Sonora.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'camiseta',
    clave: 'PHO_02',
    nombre: 'Valley Volt',
    fundacion: 2015,
    historia:
        'Fabricante de vehículos eléctricos fundado en 2015, con '
        'sede en el Valle del Sol.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'camiseta',
    clave: 'PHO_04',
    nombre: 'Red Rock Realty',
    fundacion: 1985,
    historia:
        'Inmobiliaria fundada en 1985, especializada en '
        'propiedades con vistas a las formaciones rocosas rojas '
        'de la región.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'bebida',
    clave: 'PHO_05',
    nombre: 'Camelback Chips',
    fundacion: 1991,
    historia:
        'Marca de snacks fundada en 1991, nombrada por la icónica '
        'montaña con forma de camello que domina el paisaje '
        'urbano.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'ocio',
    clave: 'PHO_06',
    nombre: 'Monsoon Media',
    fundacion: 2003,
    historia:
        'Productora audiovisual fundada en 2003, inspirada en las '
        'intensas tormentas monzónicas del verano del desierto.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'estadio',
    clave: 'PHO_07',
    nombre: 'Copper State Steel',
    fundacion: 1912,
    historia:
        'Fundición metalúrgica fundada en 1912, homenaje al apodo '
        'de Arizona como el "Estado del Cobre".',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'ocio',
    clave: 'PHO_08',
    nombre: 'Papago Park Peaks',
    fundacion: 1990,
    historia:
        'Empresa de turismo de aventura fundada en 1990, operando '
        'excursiones por las formaciones rocosas del parque '
        'Papago.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'bebida',
    clave: 'PHO_09',
    nombre: 'Salt River Sips',
    fundacion: 1980,
    historia:
        'Marca de bebidas fundada en 1980, con agua de manantial '
        'proveniente del Río Salado.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'ocio',
    clave: 'PHO_10',
    nombre: 'Desert Botanical',
    fundacion: 1939,
    historia:
        'Empresa de investigación agrícola fundada en 1939, '
        'vinculada al histórico jardín botánico del desierto.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'estadio',
    clave: 'PHO_11',
    nombre: 'Superstition Gold',
    fundacion: 1875,
    historia:
        'Compañía minera fundada en 1875, en referencia a las '
        'leyendas de oro perdido en las Montañas Superstition.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'ocio',
    clave: 'PHO_12',
    nombre: 'Roosevelt Row',
    fundacion: 2002,
    historia:
        'Colectivo de arte urbano fundado en 2002, motor del '
        'distrito artístico y de murales más vibrante de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'estadio',
    clave: 'PHO_13',
    nombre: 'Haboob Hydro',
    fundacion: 2008,
    historia:
        'Empresa de gestión hídrica fundada en 2008, nombrada por '
        'las intensas tormentas de polvo del desierto conocidas '
        'como "haboob".',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'camiseta',
    clave: 'PHO_14',
    nombre: 'Scottsdale Saddles',
    fundacion: 1948,
    historia:
        'Talabartería fundada en 1948, proveedora tradicional de '
        'monturas y arreos para ranchos de la zona.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'ocio',
    clave: 'PHO_15',
    nombre: 'Grand Canyon Cargo',
    fundacion: 1965,
    historia:
        'Empresa de logística aérea fundada en 1965, con rutas de '
        'carga que sobrevuelan el célebre cañón del estado.',
  ),

  // --- POR ---
  Patrocinador(
    equipo: 'POR',
    categoria: 'bebida',
    clave: 'POR_01',
    nombre: 'Rose City Roasters',
    fundacion: 1993,
    historia:
        'Tostadero de café fundado en 1993, homenaje al apodo '
        'floral de la ciudad, "la Ciudad de las Rosas".',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'ocio',
    clave: 'POR_02',
    nombre: 'Bridgetown Bikes',
    fundacion: 2001,
    historia:
        'Fabricante de bicicletas fundado en 2001, aprovechando '
        'el apodo "Bridgetown" por los múltiples puentes que '
        'cruzan el río Willamette.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'camiseta',
    clave: 'POR_03',
    nombre: 'Rainier Rain Gear',
    fundacion: 1979,
    historia:
        'Marca de ropa impermeable fundada en 1979, diseñada para '
        'el clima lluvioso característico del Pacífico Noroeste.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'camiseta',
    clave: 'POR_04',
    nombre: 'Timberline Tech',
    fundacion: 2010,
    historia:
        'Empresa de software fundada en 2010, nombrada por la '
        'línea de árboles del monte Hood visible desde la ciudad.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'estadio',
    clave: 'POR_06',
    nombre: 'Willamette Watts',
    fundacion: 1889,
    historia:
        'Central hidroeléctrica fundada en 1889, generando '
        'energía a partir de las cascadas del río Willamette.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'estadio',
    clave: 'POR_07',
    nombre: 'St Johns Steel',
    fundacion: 1931,
    historia:
        'Empresa de construcción metálica fundada en 1931, '
        'responsable del mantenimiento del puente gótico de St. '
        'Johns.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'bebida',
    clave: 'POR_08',
    nombre: 'Food Cart Fleet',
    fundacion: 2004,
    historia:
        'Colectivo de food trucks fundado en 2004, pionero del '
        'boom de cocina callejera que hizo famosa a la ciudad.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'bebida',
    clave: 'POR_09',
    nombre: 'Forest Park Forage',
    fundacion: 2013,
    historia:
        'Empresa de alimentos silvestres fundada en 2013, '
        'recolectora de setas y plantas comestibles del bosque '
        'urbano más grande del país.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'bebida',
    clave: 'POR_10',
    nombre: 'Doughnut Vault',
    fundacion: 1955,
    historia:
        'Pastelería fundada en 1955, inspirada en la icónica '
        'tradición de donuts excéntricos de la ciudad.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'ocio',
    clave: 'POR_13',
    nombre: 'Pearl District Pottery',
    fundacion: 1999,
    historia:
        'Estudio de cerámica fundado en 1999, en el antiguo '
        'distrito industrial reconvertido en zona artística.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'ocio',
    clave: 'POR_15',
    nombre: 'Columbia Cargo',
    fundacion: 1938,
    historia:
        'Empresa naviera fundada en 1938, especializada en el '
        'transporte de mercancías por el río Columbia.',
  ),

  // --- SAC ---
  Patrocinador(
    equipo: 'SAC',
    categoria: 'estadio',
    clave: 'SAC_01',
    nombre: 'Capitol Current',
    fundacion: 1911,
    historia:
        'Compañía eléctrica estatal fundada en 1911, proveedora '
        'histórica de energía al Capitolio de California.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'bebida',
    clave: 'SAC_03',
    nombre: 'Almond Avenue',
    fundacion: 1963,
    historia:
        'Cooperativa agrícola fundada en 1963, exportadora de '
        'almendras del Valle Central californiano.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'camiseta',
    clave: 'SAC_04',
    nombre: 'Tower Bridge Bits',
    fundacion: 2012,
    historia:
        'Startup tecnológica fundada en 2012, con sede junto al '
        'icónico puente elevadizo dorado que da nombre a la '
        'marca.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'bebida',
    clave: 'SAC_05',
    nombre: 'Farm to Fork Co',
    fundacion: 2005,
    historia:
        'Colectivo de restaurantes fundado en 2005, pionero del '
        'movimiento "de la granja a la mesa" que hizo famosa a la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'camiseta',
    clave: 'SAC_06',
    nombre: 'Gold Rush Grid',
    fundacion: 1852,
    historia:
        'Banco fundado en 1852, en plena Fiebre del Oro, uno de '
        'los primeros en operar en la capital californiana.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'ocio',
    clave: 'SAC_07',
    nombre: 'Old Sac Steamworks',
    fundacion: 1863,
    historia:
        'Compañía ferroviaria fundada en 1863, operadora de las '
        'primeras locomotoras de vapor del Oeste americano.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'bebida',
    clave: 'SAC_08',
    nombre: 'Delta Breeze',
    fundacion: 1988,
    historia:
        'Marca de bebidas refrescantes fundada en 1988, nombrada '
        'por la brisa fresca que llega desde el delta del río '
        'Sacramento.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'ocio',
    clave: 'SAC_09',
    nombre: 'American River Rafts',
    fundacion: 1979,
    historia:
        'Empresa de deportes de aventura fundada en 1979, '
        'especializada en descensos de rafting por el Río '
        'Americano.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'camiseta',
    clave: 'SAC_10',
    nombre: 'Camellia City',
    fundacion: 1935,
    historia:
        'Empresa de cosmética fundada en 1935, inspirada en la '
        'flor oficial de la ciudad.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'estadio',
    clave: 'SAC_11',
    nombre: 'Railyards Solar',
    fundacion: 2017,
    historia:
        'Compañía de energía renovable fundada en 2017, instalada '
        'en los antiguos patios ferroviarios reconvertidos de '
        'Sacramento.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'estadio',
    clave: 'SAC_12',
    nombre: 'Sutter\'s Fort',
    fundacion: 1839,
    historia:
        'Empresa de materiales de construcción fundada en 1839, '
        'con nombre del fuerte pionero que dio origen a la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'bebida',
    clave: 'SAC_13',
    nombre: 'Central Valley Citrus',
    fundacion: 1920,
    historia:
        'Cooperativa citrícola fundada en 1920, exportadora de '
        'naranjas del Valle Central.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'camiseta',
    clave: 'SAC_14',
    nombre: 'K Street Kickers',
    fundacion: 1998,
    historia:
        'Marca de calzado urbano fundada en 1998, nacida en la '
        'calle comercial peatonal más famosa del centro.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'estadio',
    clave: 'SAC_15',
    nombre: 'Folsom Dam Power',
    fundacion: 1955,
    historia:
        'Central hidroeléctrica fundada en 1955, responsable del '
        'suministro energético desde la presa de Folsom.',
  ),

  // --- SAS ---
  Patrocinador(
    equipo: 'SAS',
    categoria: 'estadio',
    clave: 'SAS_01',
    nombre: 'Alamo Alloy',
    fundacion: 1926,
    historia:
        'Fundición metalúrgica fundada en 1926, cercana al '
        'histórico fuerte de El Álamo, proveedora de estructuras '
        'de acero para toda la región.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'bebida',
    clave: 'SAS_02',
    nombre: 'Riverwalk Roasts',
    fundacion: 1968,
    historia:
        'Cafetería fundada en 1968 a orillas del célebre Paseo '
        'del Río, primera terraza flotante de café de la ciudad.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'estadio',
    clave: 'SAS_03',
    nombre: 'Spurside Steel',
    fundacion: 1954,
    historia:
        'Fábrica de herrajes fundada en 1954, especializada en '
        'espuelas y accesorios de montar de estilo vaquero '
        'tradicional.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'bebida',
    clave: 'SAS_04',
    nombre: 'Fiesta Fizz',
    fundacion: 1959,
    historia:
        'Embotelladora fundada en 1959, lanzada para las '
        'celebraciones anuales de Fiesta San Antonio con sus '
        'colores característicos.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'camiseta',
    clave: 'SAS_05',
    nombre: 'Mission Trail Bank',
    fundacion: 1890,
    historia:
        'Banco regional fundado en 1890, con sucursales '
        'originales situadas junto a las cinco misiones '
        'históricas españolas.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'bebida',
    clave: 'SAS_06',
    nombre: 'Hill Country Honey',
    fundacion: 1972,
    historia:
        'Apicultura familiar fundada en 1972 en las colinas '
        'calizas del Texas Hill Country.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'camiseta',
    clave: 'SAS_07',
    nombre: 'Tower Tech',
    fundacion: 1968,
    historia:
        'Empresa de telecomunicaciones fundada en 1968, el mismo '
        'año de construcción de la Torre de las Américas para la '
        'Feria Mundial.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'camiseta',
    clave: 'SAS_08',
    nombre: 'Pearl Lofts',
    fundacion: 2006,
    historia:
        'Promotora inmobiliaria fundada en 2006, encargada de '
        'reconvertir la antigua fábrica de cerveza Pearl Brewery '
        'en lofts residenciales.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'bebida',
    clave: 'SAS_09',
    nombre: 'Market Square Masa',
    fundacion: 1942,
    historia:
        'Fábrica de tortillas fundada en 1942 junto al Mercado '
        'histórico, proveedora de masa fresca a restaurantes de '
        'todo el estado.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'camiseta',
    clave: 'SAS_10',
    nombre: 'Military City Motors',
    fundacion: 1945,
    historia:
        'Concesionario de vehículos fundado en 1945, homenaje al '
        'apodo de la ciudad como "Military City USA" por su alta '
        'concentración de bases militares.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'bebida',
    clave: 'SAS_11',
    nombre: 'San Pedro Springs',
    fundacion: 1889,
    historia:
        'Embotelladora de agua mineral fundada en 1889, con '
        'manantial propio en el segundo parque público más '
        'antiguo del país.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'ocio',
    clave: 'SAS_12',
    nombre: 'Tejano Tunes',
    fundacion: 1975,
    historia:
        'Sello discográfico fundado en 1975, pionero en la '
        'difusión de música tejana y conjunto por toda la '
        'frontera.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'ocio',
    clave: 'SAS_13',
    nombre: 'Brackenridge Botanical',
    fundacion: 1980,
    historia:
        'Jardín botánico fundado en 1980, construido sobre los '
        'antiguos terrenos del parque Brackenridge.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'estadio',
    clave: 'SAS_14',
    nombre: 'King William Crafts',
    fundacion: 1890,
    historia:
        'Taller de ebanistería fundado en 1890 en el histórico '
        'barrio victoriano de King William.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'estadio',
    clave: 'SAS_15',
    nombre: 'Confluence Canopy',
    fundacion: 2015,
    historia:
        'Estudio de arquitectura fundado en 2015, responsable del '
        'diseño de pabellones sostenibles junto a la confluencia '
        'de los ríos de la ciudad.',
  ),

  // --- TOR ---
  Patrocinador(
    equipo: 'TOR',
    categoria: 'estadio',
    clave: 'TOR_01',
    nombre: 'CN Grid Energy',
    fundacion: 1976,
    historia:
        'Compañía eléctrica fundada en 1976, el mismo año de '
        'inauguración de la Torre CN, responsable del suministro '
        'energético del distrito financiero.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'camiseta',
    clave: 'TOR_02',
    nombre: 'Maple Circuit',
    fundacion: 2001,
    historia:
        'Empresa de semiconductores fundada en 2001 en Waterloo, '
        'célebre por fabricar los primeros microchips "hechos en '
        'Canadá".',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'estadio',
    clave: 'TOR_03',
    nombre: 'Harbourfront Hydro',
    fundacion: 1922,
    historia:
        'Utility hidroeléctrica fundada en 1922, que aprovecha '
        'las corrientes del lago Ontario para abastecer los '
        'muelles del puerto.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'bebida',
    clave: 'TOR_04',
    nombre: 'Distillery Drafts',
    fundacion: 1998,
    historia:
        'Cervecería artesanal instalada en 1998 en los antiguos '
        'edificios de ladrillo del Distillery District, '
        'reconvertidos de una destilería de whisky del siglo XIX.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'ocio',
    clave: 'TOR_05',
    nombre: 'T-Dot Transit+',
    fundacion: 1954,
    historia:
        'Operador de transporte metropolitano fundado en 1954, '
        'apodado con el mote callejero "T-Dot" que los propios '
        'torontonianos usan para su ciudad.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'camiseta',
    clave: 'TOR_07',
    nombre: 'Bay Street Bullion',
    fundacion: 1978,
    historia:
        'Casa de inversión fundada en 1978 en el corazón del '
        'distrito financiero de Bay Street, el "Wall Street '
        'canadiense".',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'bebida',
    clave: 'TOR_08',
    nombre: 'Kensington Market',
    fundacion: 1911,
    historia:
        'Colectivo de comerciantes fundado en 1911 por '
        'inmigrantes judíos y portugueses, hoy un mercado '
        'multicultural icónico de la ciudad.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'estadio',
    clave: 'TOR_09',
    nombre: 'Casa Loma Stone',
    fundacion: 1937,
    historia:
        'Empresa de cantería y restauración fundada en 1937, '
        'especializada en la conservación del castillo gótico '
        'Casa Loma y otras edificaciones históricas.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'camiseta',
    clave: 'TOR_10',
    nombre: 'Queen West Quilt',
    fundacion: 2007,
    historia:
        'Taller textil y de moda fundado en 2007 en el barrio '
        'bohemio de Queen West, cuna de diseñadores '
        'independientes canadienses.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'ocio',
    clave: 'TOR_11',
    nombre: 'Scarborough Bluffs',
    fundacion: 1985,
    historia:
        'Empresa de turismo de naturaleza fundada en 1985, '
        'dedicada a excursiones guiadas por los acantilados de '
        'arcilla más famosos de la ciudad.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'bebida',
    clave: 'TOR_12',
    nombre: 'High Park Cherry',
    fundacion: 1999,
    historia:
        'Productora de bebidas fundada en 1999, célebre por su '
        'edición de temporada inspirada en los cerezos en flor de '
        'High Park.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'bebida',
    clave: 'TOR_13',
    nombre: 'St Lawrence Peameal',
    fundacion: 1803,
    historia:
        'Charcutería histórica fundada en 1803, la más antigua '
        'del mercado St. Lawrence, inventora del clásico sándwich '
        'de bacon peameal.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'estadio',
    clave: 'TOR_15',
    nombre: 'Don Valley Brickworks',
    fundacion: 1889,
    historia:
        'Fábrica de ladrillos fundada en 1889 en la cantera del '
        'valle Don, que suministró el material de construcción de '
        'medio Toronto antiguo.',
  ),

  // --- UTA ---
  Patrocinador(
    equipo: 'UTA',
    categoria: 'estadio',
    clave: 'UTA_01',
    nombre: 'Wasatch Watts',
    fundacion: 1964,
    historia:
        'Cooperativa eléctrica de montaña fundada en 1964, que '
        'aprovecha la nieve derretida de la cordillera Wasatch '
        'para generar energía hidroeléctrica.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'estadio',
    clave: 'UTA_02',
    nombre: 'Great Salt Grid',
    fundacion: 1930,
    historia:
        'Empresa de minerales industriales fundada en 1930, que '
        'extrae y procesa sal del Gran Lago Salado para uso '
        'energético y comercial.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'bebida',
    clave: 'UTA_03',
    nombre: 'Temple Square Tea',
    fundacion: 1978,
    historia:
        'Casa de infusiones fundada en 1978, ubicada cerca de las '
        'icónicas torres del templo, especializada en tés '
        'herbales sin cafeína.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'camiseta',
    clave: 'UTA_04',
    nombre: 'Powder Basin Gear',
    fundacion: 1985,
    historia:
        'Marca de equipamiento de esquí fundada en 1985, nacida '
        'entre las estaciones de nieve en polvo que hicieron '
        'famosa la región.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'camiseta',
    clave: 'UTA_05',
    nombre: 'Beehive Bank',
    fundacion: 1896,
    historia:
        'Banco fundado en 1896, cuyo nombre y logo homenajean el '
        'símbolo pionero de la colmena que representa la '
        'industriosidad del estado de Utah.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'bebida',
    clave: 'UTA_06',
    nombre: 'Canyon Cola',
    fundacion: 1958,
    historia:
        'Embotelladora regional fundada en 1958, inspirada en los '
        'cañones rojizos del desierto que rodean la ciudad.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'camiseta',
    clave: 'UTA_07',
    nombre: 'Bonneville Speed',
    fundacion: 2016,
    historia:
        'Fabricante de vehículos eléctricos de alto rendimiento '
        'fundado en 2016, que realiza pruebas de velocidad en las '
        'salinas de Bonneville.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'bebida',
    clave: 'UTA_08',
    nombre: 'Alta Alpine Oats',
    fundacion: 2010,
    historia:
        'Empresa de alimentación saludable fundada en 2010, '
        'productora de avenas y cereales inspirados en los prados '
        'alpinos de Alta.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'ocio',
    clave: 'UTA_10',
    nombre: 'Red Butte Botanical',
    fundacion: 1961,
    historia:
        'Jardín botánico y vivero fundado en 1961, dedicado a la '
        'conservación de flora nativa del desierto de Utah.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'camiseta',
    clave: 'UTA_12',
    nombre: 'Zion Trail Tech',
    fundacion: 2014,
    historia:
        'Startup de cartografía GPS fundada en 2014, '
        'especializada en rutas de senderismo por los parques '
        'nacionales del estado.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'bebida',
    clave: 'UTA_13',
    nombre: 'Sugar House Sweets',
    fundacion: 1908,
    historia:
        'Confitería histórica fundada en 1908 en el barrio de '
        'Sugar House, herencia de una antigua fábrica de azúcar '
        'de remolacha.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'ocio',
    clave: 'UTA_14',
    nombre: 'Liberty Park Paddles',
    fundacion: 1975,
    historia:
        'Empresa de ocio acuático fundada en 1975, operadora de '
        'botes de remo en el lago del parque Liberty.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'camiseta',
    clave: 'UTA_15',
    nombre: 'Oquirrh Optical',
    fundacion: 1992,
    historia:
        'Fabricante de lentes de precisión fundado en 1992, '
        'nombrado por la cordillera Oquirrh que enmarca el valle '
        'por el oeste.',
  ),

  // --- WAS ---
  Patrocinador(
    equipo: 'WAS',
    categoria: 'estadio',
    clave: 'WAS_01',
    nombre: 'Capitol Current DC',
    fundacion: 1932,
    historia:
        'Compañía eléctrica federal fundada en 1932, proveedora '
        'histórica de energía a los edificios gubernamentales del '
        'National Mall.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'camiseta',
    clave: 'WAS_02',
    nombre: 'Potomac Power Bank',
    fundacion: 1901,
    historia:
        'Banco de inversión fundado en 1901 a orillas del río '
        'Potomac, especializado en financiar infraestructuras '
        'públicas.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'ocio',
    clave: 'WAS_03',
    nombre: 'Mall Mile Media',
    fundacion: 1994,
    historia:
        'Agencia de publicidad fundada en 1994, célebre por sus '
        'campañas visibles a lo largo de la milla que separa el '
        'Capitolio del monumento a Lincoln.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'bebida',
    clave: 'WAS_04',
    nombre: 'Cherry Blossom Chips',
    fundacion: 1965,
    historia:
        'Marca de snacks fundada en 1965, lanzada para coincidir '
        'con el festival anual de los cerezos en flor de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'estadio',
    clave: 'WAS_05',
    nombre: 'Beltway Bolts',
    fundacion: 1971,
    historia:
        'Taller mecánico y de repuestos fundado en 1971, nombrado '
        'por la autopista de circunvalación I-495 que rodea la '
        'capital.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'camiseta',
    clave: 'WAS_06',
    nombre: 'Monument Mint',
    fundacion: 1958,
    historia:
        'Compañía farmacéutica fundada en 1958, especializada en '
        'productos de bienestar y salud básica.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'camiseta',
    clave: 'WAS_07',
    nombre: 'Georgetown Gowns',
    fundacion: 1949,
    historia:
        'Casa de moda fundada en 1949 en el histórico barrio de '
        'Georgetown, proveedora de vestidos de gala para eventos '
        'diplomáticos.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'ocio',
    clave: 'WAS_09',
    nombre: 'Metro Motion',
    fundacion: 1976,
    historia:
        'Operador del metro fundado en 1976, el mismo año de '
        'inauguración del sistema de transporte subterráneo de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'ocio',
    clave: 'WAS_10',
    nombre: 'Tidal Basin Boats',
    fundacion: 1920,
    historia:
        'Empresa de alquiler de embarcaciones fundada en 1920, '
        'operando botes de pedal en la cuenca frente al monumento '
        'a Jefferson.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'ocio',
    clave: 'WAS_11',
    nombre: 'Adams Morgan Arts',
    fundacion: 1991,
    historia:
        'Colectivo cultural fundado en 1991, motor de festivales '
        'multiculturales en uno de los barrios más diversos de la '
        'capital.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'camiseta',
    clave: 'WAS_12',
    nombre: 'Lincoln Ledger',
    fundacion: 1922,
    historia:
        'Firma de contabilidad fundada en 1922, en el año de '
        'inauguración del monumento a Lincoln que inspira su '
        'nombre.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'bebida',
    clave: 'WAS_13',
    nombre: 'Dupont Drinks',
    fundacion: 1977,
    historia:
        'Compañía de bebidas fundada en 1977, con sede junto a la '
        'histórica fuente de Dupont Circle.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'bebida',
    clave: 'WAS_14',
    nombre: 'Eastern Market Eats',
    fundacion: 1873,
    historia:
        'Mercado de alimentos fundado en 1873, el más antiguo en '
        'funcionamiento continuo de la ciudad.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'ocio',
    clave: 'WAS_15',
    nombre: 'Anacostia Roots',
    fundacion: 2003,
    historia:
        'Organización de conservación ambiental fundada en 2003, '
        'dedicada a la restauración de los humedales del río '
        'Anacostia.',
  ),
];
