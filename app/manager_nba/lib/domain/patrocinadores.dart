/// El catálogo de patrocinadores: quién puede patrocinarte, ciudad por
/// ciudad, y por qué. Es dato de referencia fijo (como `equiposInfo`), no
/// algo que se guarde en la base — lo único que se guarda es QUÉ categorías
/// tienes activas ahora mismo (ver `patrocinadores_repository.dart`).
///
/// Cuatro categorías fijas por equipo, una empresa candidata en cada una:
/// el pabellón (infraestructura/energía), la camiseta (banca/finanzas, el
/// patrocinio de más prestigio), la bebida oficial (alimentación) y el de
/// ocio/comunidad (parques, transporte, turismo). No compites entre varias
/// empresas dentro de la misma categoría — la decisión real es CUÁLES de
/// las cuatro firmas, no con quién de cada una.
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
      clave: 'dias_de_medios', factor: 0.98, partidos: 6),
  'estadio': CompromisoDePatrocinio(
      clave: 'pabellon_con_otro_nombre', factor: 0.99, partidos: 12),
  'bebida': CompromisoDePatrocinio(
      clave: 'compromisos_de_marca', factor: 0.99, partidos: 6),
  'ocio': CompromisoDePatrocinio(
      clave: 'trabajo_con_la_ciudad', factor: 1.01, partidos: 6),
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
  final String equipo;
  final String categoria;
  final String nombre;
  final int fundacion;
  final String historia;

  const Patrocinador({
    required this.equipo,
    required this.categoria,
    required this.nombre,
    required this.fundacion,
    required this.historia,
  });

  int get bonusSalarial => bonusPorCategoria[categoria]!;

  /// Lo que pide a cambio, que es la mitad de la decisión.
  CompromisoDePatrocinio get compromiso => compromisoPorCategoria[categoria]!;
}

/// Los cuatro patrocinadores candidatos de [equipo], uno por categoría.
List<Patrocinador> patrocinadoresDe(String equipo) =>
    catalogoPatrocinadores.where((p) => p.equipo == equipo).toList();

Patrocinador? patrocinadorDe(String equipo, String categoria) {
  for (final p in catalogoPatrocinadores) {
    if (p.equipo == equipo && p.categoria == categoria) return p;
  }
  return null;
}

/// Historias de marca ficticias basadas en la identidad real de cada
/// ciudad — nombres, fundación y anécdota tomados o inspirados en la hoja
/// de patrocinadores preparada para el juego. Cuatro por equipo, en las
/// cuatro categorías de arriba.
const catalogoPatrocinadores = <Patrocinador>[
  // --- Atlanta (ATL) ---
  Patrocinador(
    equipo: 'ATL',
    categoria: 'estadio',
    nombre: 'Peachtree Power',
    fundacion: 1969,
    historia: 'Compañía eléctrica fundada en 1969, con sede en la avenida '
        'más famosa de la ciudad, suministra energía al centro financiero.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'camiseta',
    nombre: 'Peach State Capital',
    fundacion: 1996,
    historia: 'Firma de banca de inversión fundada en 1996, el año de los '
        'Juegos Olímpicos que transformaron el centro de la ciudad.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'bebida',
    nombre: 'World Fizz Co',
    fundacion: 1886,
    historia: 'Embotelladora fundada en 1886, homenaje al origen de la '
        'bebida más famosa nacida en la ciudad.',
  ),
  Patrocinador(
    equipo: 'ATL',
    categoria: 'ocio',
    nombre: 'BeltLine Bikes',
    fundacion: 2008,
    historia: 'Empresa de movilidad urbana fundada en 2008, con rutas '
        'ciclistas por el antiguo corredor ferroviario reconvertido en '
        'parque lineal.',
  ),

  // --- Boston (BOS) ---
  Patrocinador(
    equipo: 'BOS',
    categoria: 'estadio',
    nombre: 'Beacon Hill Power',
    fundacion: 1897,
    historia: 'Compañía eléctrica fundada en 1897, con sede en el histórico '
        'barrio de las farolas de gas.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'camiseta',
    nombre: 'Harbor Trust Bank',
    fundacion: 1784,
    historia: 'Uno de los bancos más antiguos del país, fundado en 1784 '
        'junto al puerto de la ciudad.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'bebida',
    nombre: 'Freedom Trail Brew',
    fundacion: 1975,
    historia: 'Cervecería fundada en 1975, con ruta de degustación que '
        'sigue el célebre sendero histórico de la ciudad.',
  ),
  Patrocinador(
    equipo: 'BOS',
    categoria: 'ocio',
    nombre: 'Charles River Rowing',
    fundacion: 1854,
    historia: 'Club de remo fundado en 1854, activo en el río que separa '
        'Boston de Cambridge.',
  ),

  // --- Brooklyn (BRK) ---
  Patrocinador(
    equipo: 'BRK',
    categoria: 'estadio',
    nombre: 'Bridge Watt Co',
    fundacion: 1883,
    historia: 'Compañía eléctrica fundada en 1883, el mismo año de '
        'inauguración del puente que da nombre al distrito.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'camiseta',
    nombre: 'DUMBO Capital',
    fundacion: 2001,
    historia: 'Firma de inversión fundada en 2001, con sede bajo el paso '
        'elevado del puente de Manhattan.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'bebida',
    nombre: 'Coney Island Cola',
    fundacion: 1904,
    historia: 'Embotelladora fundada en 1904, homenaje al parque de '
        'atracciones más antiguo de la ciudad.',
  ),
  Patrocinador(
    equipo: 'BRK',
    categoria: 'ocio',
    nombre: 'Prospect Park Paddle',
    fundacion: 1868,
    historia: 'Empresa de botes de remo fundada en 1868, operando en el '
        'lago del parque diseñado por los creadores de Central Park.',
  ),

  // --- Chicago (CHI) ---
  Patrocinador(
    equipo: 'CHI',
    categoria: 'estadio',
    nombre: 'Loop Line Power',
    fundacion: 1902,
    historia: 'Compañía eléctrica fundada en 1902, suministrando energía '
        'al distrito financiero elevado del Loop.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'camiseta',
    nombre: 'Mag Mile Bank',
    fundacion: 1920,
    historia: 'Banco fundado en 1920, con sede en la avenida comercial más '
        'elegante de la ciudad.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'bebida',
    nombre: 'Deep Dish Draft',
    fundacion: 1978,
    historia: 'Cervecería fundada en 1978, homenaje a la pizza de masa '
        'profunda que hizo famosa a la ciudad.',
  ),
  Patrocinador(
    equipo: 'CHI',
    categoria: 'ocio',
    nombre: 'Windy City Sail',
    fundacion: 1932,
    historia: 'Empresa de deportes acuáticos fundada en 1932, operando '
        'veleros en el lago Michigan.',
  ),

  // --- Charlotte (CHO) ---
  Patrocinador(
    equipo: 'CHO',
    categoria: 'estadio',
    nombre: 'Uptown Utility',
    fundacion: 1958,
    historia: 'Compañía eléctrica fundada en 1958, con sede en el distrito '
        'financiero elevado del centro.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'camiseta',
    nombre: 'Queen City Capital',
    fundacion: 1874,
    historia: 'Banco de inversión fundado en 1874, homenaje al apodo real '
        'de la ciudad.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'bebida',
    nombre: 'Carolina Crown Cola',
    fundacion: 1947,
    historia: 'Embotelladora fundada en 1947, con recetas inspiradas en la '
        'tradición sureña de las Carolinas.',
  ),
  Patrocinador(
    equipo: 'CHO',
    categoria: 'ocio',
    nombre: 'Speedway Circuit Tours',
    fundacion: 1985,
    historia: 'Empresa de turismo fundada en 1985, con visitas guiadas al '
        'Salón de la Fama de NASCAR.',
  ),

  // --- Cleveland (CLE) ---
  Patrocinador(
    equipo: 'CLE',
    categoria: 'estadio',
    nombre: 'Terminal Tower Tech',
    fundacion: 1930,
    historia: 'Empresa de telecomunicaciones fundada en 1930, año de '
        'inauguración de la icónica Terminal Tower.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'camiseta',
    nombre: 'MetroHealth Mint',
    fundacion: 1837,
    historia: 'Sistema de clínicas fundado en 1837, uno de los proveedores '
        'de salud pública más antiguos de Ohio.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'bebida',
    nombre: 'Burning River Brew',
    fundacion: 1998,
    historia: 'Cervecería fundada en 1998, con nombre irónico que recuerda '
        'al famoso incendio del río Cuyahoga de 1969, hoy símbolo de la '
        'recuperación ecológica de la ciudad.',
  ),
  Patrocinador(
    equipo: 'CLE',
    categoria: 'ocio',
    nombre: 'Emerald Necklace Trail',
    fundacion: 1917,
    historia: 'Empresa de senderismo fundada en 1917, gestora de la red de '
        'parques metropolitanos que rodea la ciudad como un collar verde.',
  ),

  // --- Dallas (DAL) ---
  Patrocinador(
    equipo: 'DAL',
    categoria: 'estadio',
    nombre: 'Reunion Tower Light',
    fundacion: 1978,
    historia: 'Compañía eléctrica boutique fundada en 1978, el año de '
        'inauguración de la esfera iluminada que corona el horizonte.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'camiseta',
    nombre: 'Big D Bank',
    fundacion: 1901,
    historia: 'Banco fundado en 1901, en plena fiebre del petróleo '
        'texano, financiando los primeros pozos de la región.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'bebida',
    nombre: 'Deep Ellum Draft',
    fundacion: 2005,
    historia: 'Cervecería artesanal fundada en 2005, en el histórico '
        'barrio del blues y el jazz texano.',
  ),
  Patrocinador(
    equipo: 'DAL',
    categoria: 'ocio',
    nombre: 'Klyde Park Canopy',
    fundacion: 2012,
    historia: 'Empresa de paisajismo fundada en 2012, el año de apertura '
        'del parque elevado sobre la autopista central.',
  ),

  // --- Denver (DEN) ---
  Patrocinador(
    equipo: 'DEN',
    categoria: 'estadio',
    nombre: 'Mile High Power',
    fundacion: 1969,
    historia: 'Compañía eléctrica fundada en 1969, homenaje al apodo de la '
        'ciudad por su altitud exacta de una milla.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'camiseta',
    nombre: 'Rocky Peak Capital',
    fundacion: 1988,
    historia: 'Firma de inversión fundada en 1988, con vistas a la '
        'cordillera que domina el horizonte de la ciudad.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'bebida',
    nombre: 'LoDo Lager',
    fundacion: 1988,
    historia: 'Cervecería artesanal fundada en 1988, en el histórico '
        'distrito de almacenes del centro reconvertido.',
  ),
  Patrocinador(
    equipo: 'DEN',
    categoria: 'ocio',
    nombre: 'Red Rocks Trails',
    fundacion: 1941,
    historia: 'Empresa de turismo de naturaleza fundada en 1941, con '
        'excursiones por el anfiteatro natural más famoso del estado.',
  ),

  // --- Detroit (DET) ---
  Patrocinador(
    equipo: 'DET',
    categoria: 'estadio',
    nombre: 'Renaissance Grid',
    fundacion: 1977,
    historia: 'Compañía eléctrica fundada en 1977, el año de inauguración '
        'del complejo de rascacielos que renovó el horizonte de la ciudad.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'camiseta',
    nombre: 'Motor City Trust',
    fundacion: 1908,
    historia: 'Banco fundado en 1908, el mismo año en que salió de '
        'fábrica el primer modelo T de la ciudad.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'bebida',
    nombre: 'Belle Isle Brew',
    fundacion: 1996,
    historia: 'Cervecería fundada en 1996, junto a la isla-parque más '
        'grande del país sobre un río urbano.',
  ),
  Patrocinador(
    equipo: 'DET',
    categoria: 'ocio',
    nombre: 'Woodward Avenue Wheels',
    fundacion: 2010,
    historia: 'Empresa de rutas en bicicleta fundada en 2010, operando '
        'por la histórica avenida del motor.',
  ),

  // --- Golden State / San Francisco (GSW) ---
  Patrocinador(
    equipo: 'GSW',
    categoria: 'estadio',
    nombre: 'Golden Gate Grid',
    fundacion: 1987,
    historia: 'Fundada en 1987 por ingenieros eléctricos que trabajaron en '
        'el mantenimiento del puente Golden Gate. Eléctrica regional que '
        'suministra energía a media Bahía.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'camiseta',
    nombre: 'Bay Bytes Bank',
    fundacion: 2015,
    historia: 'Fintech fundada en 2015 por antiguos empleados de bancos de '
        'inversión de la bahía, especializada en préstamos para startups '
        'tecnológicas.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'bebida',
    nombre: 'Cable Car Cola',
    fundacion: 1962,
    historia: 'Embotelladora fundada en 1962 que homenajea los icónicos '
        'tranvías de la ciudad; sus latas antiguas se venden hoy como '
        'reliquia local.',
  ),
  Patrocinador(
    equipo: 'GSW',
    categoria: 'ocio',
    nombre: 'Lombard Loops',
    fundacion: 2018,
    historia: 'Startup de movilidad urbana fundada en 2018 que diseña '
        'rutas turísticas en bicicleta eléctrica por las calles más '
        'empinadas de la ciudad.',
  ),

  // --- Houston (HOU) ---
  Patrocinador(
    equipo: 'HOU',
    categoria: 'estadio',
    nombre: 'AstroWatt Solar',
    fundacion: 1965,
    historia: 'Empresa de energía solar fundada en 1965, el año de '
        'inauguración del Astrodome, el primer estadio cubierto del '
        'mundo.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'camiseta',
    nombre: 'TMC Med',
    fundacion: 1945,
    historia: 'Empresa biotecnológica fundada en 1945, con sede en el '
        'complejo médico más grande del mundo, el Texas Medical Center.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'bebida',
    nombre: 'Buffalo Bayou Brew',
    fundacion: 2011,
    historia: 'Cervecería artesanal fundada en 2011, junto al arroyo que '
        'da origen histórico a la ciudad.',
  ),
  Patrocinador(
    equipo: 'HOU',
    categoria: 'ocio',
    nombre: 'Clutch City Coffee',
    fundacion: 1995,
    historia: 'Cafetería fundada en 1995, homenaje al apodo "Clutch City" '
        'ganado por el baloncesto local tras sus títulos.',
  ),

  // --- Indiana / Indianapolis (IND) ---
  Patrocinador(
    equipo: 'IND',
    categoria: 'estadio',
    nombre: 'White River Watts',
    fundacion: 1913,
    historia: 'Central hidroeléctrica fundada en 1913, aprovechando el '
        'caudal del río White que cruza la ciudad.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'camiseta',
    nombre: 'Union Station Vault',
    fundacion: 1888,
    historia: 'Banco fundado en 1888, el año de construcción de la '
        'estación ferroviaria Union Station.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'bebida',
    nombre: 'Speedway Sips',
    fundacion: 1911,
    historia: 'Marca de bebidas energéticas fundada en 1911, el año de la '
        'primera carrera de las 500 Millas de Indianápolis.',
  ),
  Patrocinador(
    equipo: 'IND',
    categoria: 'ocio',
    nombre: 'Canal Walk Coffee',
    fundacion: 1988,
    historia: 'Cafetería fundada en 1988, junto al canal restaurado del '
        'centro de la ciudad.',
  ),

  // --- LA Clippers (LAC) ---
  Patrocinador(
    equipo: 'LAC',
    categoria: 'estadio',
    nombre: 'Sunset Solar',
    fundacion: 2008,
    historia: 'Empresa de energía renovable fundada en 2008, con paneles '
        'instalados a lo largo del icónico Sunset Boulevard.',
  ),
  Patrocinador(
    equipo: 'LAC',
    categoria: 'camiseta',
    nombre: 'CityView Capital',
    fundacion: 1990,
    historia: 'Firma de inversión inmobiliaria fundada en 1990, '
        'especializada en el desarrollo urbano del downtown.',
  ),
  Patrocinador(
    equipo: 'LAC',
    categoria: 'bebida',
    nombre: 'Pacific Waves Beverages',
    fundacion: 1965,
    historia: 'Embotelladora fundada en 1965, con primeras plantas junto a '
        'las playas del Pacífico.',
  ),
  Patrocinador(
    equipo: 'LAC',
    categoria: 'ocio',
    nombre: 'Griffith Realty',
    fundacion: 1896,
    historia: 'Inmobiliaria fundada en 1896, el año de donación del '
        'parque Griffith a la ciudad por su fundador filantrópico.',
  ),

  // --- LA Lakers (LAL) ---
  Patrocinador(
    equipo: 'LAL',
    categoria: 'estadio',
    nombre: 'Sunset Solar',
    fundacion: 2008,
    historia: 'Empresa de energía renovable fundada en 2008, con paneles '
        'instalados a lo largo del icónico Sunset Boulevard.',
  ),
  Patrocinador(
    equipo: 'LAL',
    categoria: 'camiseta',
    nombre: 'CityView Capital',
    fundacion: 1990,
    historia: 'Firma de inversión inmobiliaria fundada en 1990, '
        'especializada en el desarrollo urbano del downtown.',
  ),
  Patrocinador(
    equipo: 'LAL',
    categoria: 'bebida',
    nombre: 'Pacific Waves Beverages',
    fundacion: 1965,
    historia: 'Embotelladora fundada en 1965, con primeras plantas junto a '
        'las playas del Pacífico.',
  ),
  Patrocinador(
    equipo: 'LAL',
    categoria: 'ocio',
    nombre: 'Griffith Realty',
    fundacion: 1896,
    historia: 'Inmobiliaria fundada en 1896, el año de donación del '
        'parque Griffith a la ciudad por su fundador filantrópico.',
  ),

  // --- Memphis (MEM) ---
  Patrocinador(
    equipo: 'MEM',
    categoria: 'estadio',
    nombre: 'Pyramid Power',
    fundacion: 1991,
    historia: 'Compañía eléctrica fundada en 1991, el año de inauguración '
        'de la icónica Pirámide de Memphis.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'camiseta',
    nombre: 'Bluff City Bank',
    fundacion: 1864,
    historia: 'Banco fundado en 1864, homenaje al apodo "Ciudad del '
        'Acantilado" por su ubicación sobre los altos del río.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'bebida',
    nombre: 'Delta Drift Cola',
    fundacion: 1922,
    historia: 'Embotelladora fundada en 1922, inspirada en el meandro del '
        'delta del Mississippi.',
  ),
  Patrocinador(
    equipo: 'MEM',
    categoria: 'ocio',
    nombre: 'Mud Island Marine',
    fundacion: 1982,
    historia: 'Empresa de turismo fluvial fundada en 1982, operando en la '
        'isla artificial del río Mississippi.',
  ),

  // --- Miami (MIA) ---
  Patrocinador(
    equipo: 'MIA',
    categoria: 'estadio',
    nombre: 'PortMiami Pack',
    fundacion: 1960,
    historia: 'Empresa de logística portuaria fundada en 1960, operando '
        'en uno de los puertos de cruceros más activos del mundo.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'camiseta',
    nombre: 'Brickell Capital',
    fundacion: 2003,
    historia: 'Firma de banca de inversión fundada en 2003, con sede en '
        'el distrito financiero de Brickell.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'bebida',
    nombre: 'Heatwave Hydro',
    fundacion: 2001,
    historia: 'Marca de bebidas isotónicas fundada en 2001, pensada para '
        'combatir el calor tropical de la ciudad.',
  ),
  Patrocinador(
    equipo: 'MIA',
    categoria: 'ocio',
    nombre: 'Everglades Eco Tours',
    fundacion: 1974,
    historia: 'Empresa de ecoturismo fundada en 1974, con excursiones '
        'guiadas por el parque nacional de los Everglades.',
  ),

  // --- Milwaukee (MIL) ---
  Patrocinador(
    equipo: 'MIL',
    categoria: 'estadio',
    nombre: 'Hoan Bridge Steel',
    fundacion: 1972,
    historia: 'Empresa de ingeniería fundada en 1972, el año de '
        'construcción del puente amarillo Hoan sobre la bahía.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'camiseta',
    nombre: 'Harley Harbor Parts',
    fundacion: 1903,
    historia: 'Taller de motocicletas fundado en 1903, el mismo año de '
        'fundación de la legendaria marca motociclista de la ciudad.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'bebida',
    nombre: 'Lakefront Lager',
    fundacion: 1987,
    historia: 'Cervecería fundada en 1987, junto a las orillas del lago '
        'Michigan.',
  ),
  Patrocinador(
    equipo: 'MIL',
    categoria: 'ocio',
    nombre: 'Bradford Beach Breeze',
    fundacion: 1915,
    historia: 'Club de playa fundado en 1915, en la playa urbana más '
        'popular de la ciudad junto al lago Michigan.',
  ),

  // --- Minnesota / Minneapolis (MIN) ---
  Patrocinador(
    equipo: 'MIN',
    categoria: 'estadio',
    nombre: 'Prairie Wind Power',
    fundacion: 2005,
    historia: 'Compañía de energía eólica fundada en 2005, con parques de '
        'turbinas en las praderas de Minnesota.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'camiseta',
    nombre: 'Foshay Financial',
    fundacion: 1929,
    historia: 'Firma de asesoría financiera fundada en 1929, con sede en '
        'el histórico rascacielos Foshay Tower.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'bebida',
    nombre: 'Minnehaha Mist',
    fundacion: 1965,
    historia: 'Marca de bebidas fundada en 1965, inspirada en la cascada '
        'Minnehaha del parque homónimo.',
  ),
  Patrocinador(
    equipo: 'MIN',
    categoria: 'ocio',
    nombre: 'Chain of Lakes Canoes',
    fundacion: 1925,
    historia: 'Empresa de alquiler de canoas fundada en 1925, operando en '
        'la cadena de lagos urbanos del sur de la ciudad.',
  ),

  // --- New Orleans (NOP) ---
  Patrocinador(
    equipo: 'NOP',
    categoria: 'estadio',
    nombre: 'Superdome Sound',
    fundacion: 1975,
    historia: 'Empresa de sonido e iluminación fundada en 1975, el año de '
        'inauguración del emblemático estadio Superdome.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'camiseta',
    nombre: 'Crescent City Cargo',
    fundacion: 1901,
    historia: 'Empresa naviera fundada en 1901, homenaje al apodo de '
        '"Ciudad Creciente" por la curva del río Mississippi.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'bebida',
    nombre: 'French Quarter Fizz',
    fundacion: 1920,
    historia: 'Embotelladora fundada en 1920, con primeras bodegas en el '
        'histórico Barrio Francés.',
  ),
  Patrocinador(
    equipo: 'NOP',
    categoria: 'ocio',
    nombre: 'St Charles Streetcar',
    fundacion: 1835,
    historia: 'Operador de tranvías fundado en 1835, gestor de una de las '
        'líneas de tranvía más antiguas en funcionamiento del país.',
  ),

  // --- New York (NYK) ---
  Patrocinador(
    equipo: 'NYK',
    categoria: 'estadio',
    nombre: 'Hudson Hydro',
    fundacion: 1917,
    historia: 'Compañía de gestión hídrica fundada en 1917, encargada del '
        'suministro de agua desde el río Hudson.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'camiseta',
    nombre: 'Empire Edge Bank',
    fundacion: 1931,
    historia: 'Banco de inversión fundado en 1931, el mismo año de '
        'inauguración del Empire State Building que inspira su logo.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'bebida',
    nombre: 'MetroCard Meals',
    fundacion: 1994,
    historia: 'Cadena de comida rápida fundada en 1994, el mismo año de '
        'introducción de la MetroCard en el sistema de transporte.',
  ),
  Patrocinador(
    equipo: 'NYK',
    categoria: 'ocio',
    nombre: 'High Line Horticulture',
    fundacion: 2009,
    historia: 'Empresa de jardinería urbana fundada en 2009, encargada '
        'del mantenimiento del parque elevado High Line.',
  ),

  // --- Oklahoma City (OKC) ---
  Patrocinador(
    equipo: 'OKC',
    categoria: 'estadio',
    nombre: 'Bricktown Power',
    fundacion: 1989,
    historia: 'Compañía eléctrica fundada en 1989, con sede en el '
        'histórico distrito de almacenes de ladrillo reconvertido.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'camiseta',
    nombre: 'Route 66 Capital',
    fundacion: 1926,
    historia: 'Firma de inversión fundada en 1926, el año de inauguración '
        'de la histórica carretera que cruza la ciudad.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'bebida',
    nombre: 'Derrick Draft Co',
    fundacion: 1928,
    historia: 'Embotelladora fundada en 1928, en plena fiebre del '
        'petróleo de Oklahoma.',
  ),
  Patrocinador(
    equipo: 'OKC',
    categoria: 'ocio',
    nombre: 'Myriad Gardens Trail',
    fundacion: 1988,
    historia: 'Jardín botánico y vivero fundado en 1988, en pleno corazón '
        'del centro de la ciudad.',
  ),

  // --- Orlando (ORL) ---
  Patrocinador(
    equipo: 'ORL',
    categoria: 'estadio',
    nombre: 'ThemePark Power',
    fundacion: 1971,
    historia: 'Compañía eléctrica fundada en 1971, coincidiendo con la '
        'apertura de los primeros grandes parques temáticos de la '
        'ciudad.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'camiseta',
    nombre: 'Citrus Circuit',
    fundacion: 1995,
    historia: 'Empresa de tecnología fundada en 1995, con nombre '
        'inspirado en los antiguos naranjales que ocupaban la región '
        'antes del turismo.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'bebida',
    nombre: 'Orange Blossom Brew',
    fundacion: 2009,
    historia: 'Cervecería artesanal fundada en 2009, elaborando cervezas '
        'con notas cítricas de flor de azahar.',
  ),
  Patrocinador(
    equipo: 'ORL',
    categoria: 'ocio',
    nombre: 'Boggy Creek Boats',
    fundacion: 1975,
    historia: 'Empresa de turismo de aventura fundada en 1975, con '
        'excursiones en aerodeslizador por los pantanos cercanos.',
  ),

  // --- Philadelphia (PHI) ---
  Patrocinador(
    equipo: 'PHI',
    categoria: 'estadio',
    nombre: 'Schuylkill Solar',
    fundacion: 2010,
    historia: 'Empresa de energía renovable fundada en 2010, instalada a '
        'orillas del río Schuylkill.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'camiseta',
    nombre: 'Liberty Bell Bank',
    fundacion: 1876,
    historia: 'Banco fundado en 1876, en el centenario de la '
        'independencia, con sede cercana a la histórica campana de la '
        'libertad.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'bebida',
    nombre: 'Philly Pretzel Co',
    fundacion: 1861,
    historia: 'Panadería fundada en 1861, productora de los tradicionales '
        'pretzels blandos de la ciudad.',
  ),
  Patrocinador(
    equipo: 'PHI',
    categoria: 'ocio',
    nombre: 'Fairmount Park',
    fundacion: 1855,
    historia: 'Empresa de gestión forestal fundada en 1855, encargada del '
        'mantenimiento de uno de los parques urbanos más grandes del '
        'país.',
  ),

  // --- Phoenix (PHO) ---
  Patrocinador(
    equipo: 'PHO',
    categoria: 'estadio',
    nombre: 'Desert Sun Solar',
    fundacion: 1998,
    historia: 'Compañía de energía solar fundada en 1998, pionera en '
        'aprovechar los más de 300 días de sol al año del desierto de '
        'Sonora.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'camiseta',
    nombre: 'Copper State Steel',
    fundacion: 1912,
    historia: 'Fundición metalúrgica fundada en 1912, homenaje al apodo '
        'de Arizona como el "Estado del Cobre".',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'bebida',
    nombre: 'Cactus Cooler Co',
    fundacion: 1972,
    historia: 'Embotelladora fundada en 1972, famosa por sus refrescos '
        'con sabor a fruta del desierto.',
  ),
  Patrocinador(
    equipo: 'PHO',
    categoria: 'ocio',
    nombre: 'Papago Park Peaks',
    fundacion: 1990,
    historia: 'Empresa de turismo de aventura fundada en 1990, con '
        'excursiones por las formaciones rocosas del parque Papago.',
  ),

  // --- Portland (POR) ---
  Patrocinador(
    equipo: 'POR',
    categoria: 'estadio',
    nombre: 'Willamette Watts',
    fundacion: 1889,
    historia: 'Central hidroeléctrica fundada en 1889, generando energía '
        'a partir de las cascadas del río Willamette.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'camiseta',
    nombre: 'Timberline Tech',
    fundacion: 2010,
    historia: 'Empresa de software fundada en 2010, nombrada por la línea '
        'de árboles del monte Hood visible desde la ciudad.',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'bebida',
    nombre: 'Rose City Roasters',
    fundacion: 1993,
    historia: 'Tostadero de café fundado en 1993, homenaje al apodo '
        'floral de la ciudad, "la Ciudad de las Rosas".',
  ),
  Patrocinador(
    equipo: 'POR',
    categoria: 'ocio',
    nombre: 'Bridgetown Bikes',
    fundacion: 2001,
    historia: 'Fabricante de bicicletas fundado en 2001, aprovechando el '
        'apodo "Bridgetown" por los múltiples puentes que cruzan el río '
        'Willamette.',
  ),

  // --- Sacramento (SAC) ---
  Patrocinador(
    equipo: 'SAC',
    categoria: 'estadio',
    nombre: 'Folsom Dam Power',
    fundacion: 1955,
    historia: 'Central hidroeléctrica fundada en 1955, responsable del '
        'suministro energético desde la presa de Folsom.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'camiseta',
    nombre: 'Gold Rush Grid',
    fundacion: 1852,
    historia: 'Banco fundado en 1852, en plena Fiebre del Oro, uno de los '
        'primeros en operar en la capital californiana.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'bebida',
    nombre: 'Delta Breeze',
    fundacion: 1988,
    historia: 'Marca de bebidas refrescantes fundada en 1988, nombrada '
        'por la brisa fresca que llega desde el delta del río '
        'Sacramento.',
  ),
  Patrocinador(
    equipo: 'SAC',
    categoria: 'ocio',
    nombre: 'American River Rafts',
    fundacion: 1979,
    historia: 'Empresa de deportes de aventura fundada en 1979, '
        'especializada en descensos de rafting por el Río Americano.',
  ),

  // --- San Antonio (SAS) ---
  Patrocinador(
    equipo: 'SAS',
    categoria: 'estadio',
    nombre: 'Alamo Alloy',
    fundacion: 1926,
    historia: 'Fundición metalúrgica fundada en 1926, cercana al '
        'histórico fuerte de El Álamo, proveedora de estructuras de '
        'acero para toda la región.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'camiseta',
    nombre: 'Mission Trail Bank',
    fundacion: 1890,
    historia: 'Banco regional fundado en 1890, con sucursales originales '
        'situadas junto a las cinco misiones históricas españolas.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'bebida',
    nombre: 'Fiesta Fizz',
    fundacion: 1959,
    historia: 'Embotelladora fundada en 1959, lanzada para las '
        'celebraciones anuales de Fiesta San Antonio.',
  ),
  Patrocinador(
    equipo: 'SAS',
    categoria: 'ocio',
    nombre: 'Brackenridge Botanical',
    fundacion: 1980,
    historia: 'Jardín botánico fundado en 1980, construido sobre los '
        'antiguos terrenos del parque Brackenridge.',
  ),

  // --- Toronto (TOR) ---
  Patrocinador(
    equipo: 'TOR',
    categoria: 'estadio',
    nombre: 'CN Grid Energy',
    fundacion: 1976,
    historia: 'Compañía eléctrica fundada en 1976, el mismo año de '
        'inauguración de la Torre CN, responsable del suministro '
        'energético del distrito financiero.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'camiseta',
    nombre: 'Bay Street Bullion',
    fundacion: 1978,
    historia: 'Casa de inversión fundada en 1978 en el corazón del '
        'distrito financiero de Bay Street, el "Wall Street canadiense".',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'bebida',
    nombre: 'Distillery Drafts',
    fundacion: 1998,
    historia: 'Cervecería artesanal instalada en 1998 en los antiguos '
        'edificios de ladrillo del Distillery District, reconvertidos de '
        'una destilería de whisky del siglo XIX.',
  ),
  Patrocinador(
    equipo: 'TOR',
    categoria: 'ocio',
    nombre: 'Scarborough Bluffs',
    fundacion: 1985,
    historia: 'Empresa de turismo de naturaleza fundada en 1985, dedicada '
        'a excursiones guiadas por los acantilados de arcilla más '
        'famosos de la ciudad.',
  ),

  // --- Utah / Salt Lake City (UTA) ---
  Patrocinador(
    equipo: 'UTA',
    categoria: 'estadio',
    nombre: 'Wasatch Watts',
    fundacion: 1964,
    historia: 'Cooperativa eléctrica de montaña fundada en 1964, que '
        'aprovecha la nieve derretida de la cordillera Wasatch para '
        'generar energía hidroeléctrica.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'camiseta',
    nombre: 'Beehive Bank',
    fundacion: 1896,
    historia: 'Banco fundado en 1896, cuyo nombre y logo homenajean el '
        'símbolo pionero de la colmena que representa la industriosidad '
        'del estado de Utah.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'bebida',
    nombre: 'Canyon Cola',
    fundacion: 1958,
    historia: 'Embotelladora regional fundada en 1958, inspirada en los '
        'cañones rojizos del desierto que rodean la ciudad.',
  ),
  Patrocinador(
    equipo: 'UTA',
    categoria: 'ocio',
    nombre: 'Liberty Park Paddles',
    fundacion: 1975,
    historia: 'Empresa de ocio acuático fundada en 1975, operadora de '
        'botes de remo en el lago del parque Liberty.',
  ),

  // --- Washington (WAS) ---
  Patrocinador(
    equipo: 'WAS',
    categoria: 'estadio',
    nombre: 'Capitol Current DC',
    fundacion: 1932,
    historia: 'Compañía eléctrica federal fundada en 1932, proveedora '
        'histórica de energía a los edificios gubernamentales del '
        'National Mall.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'camiseta',
    nombre: 'Potomac Power Bank',
    fundacion: 1901,
    historia: 'Banco de inversión fundado en 1901 a orillas del río '
        'Potomac, especializado en financiar infraestructuras públicas.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'bebida',
    nombre: 'Dupont Drinks',
    fundacion: 1977,
    historia: 'Compañía de bebidas fundada en 1977, con sede junto a la '
        'histórica fuente de Dupont Circle.',
  ),
  Patrocinador(
    equipo: 'WAS',
    categoria: 'ocio',
    nombre: 'Tidal Basin Boats',
    fundacion: 1920,
    historia: 'Empresa de alquiler de embarcaciones fundada en 1920, '
        'operando botes de pedal en la cuenca frente al monumento a '
        'Jefferson.',
  ),
];
