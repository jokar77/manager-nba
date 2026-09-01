/// De dónde sale un jugador antes de llegar a la NBA: a los 16 años, según
/// su nacionalidad, entra a una organización juvenil de un tipo distinto
/// (cantera de club, universidad, academia deportiva) — el mismo sistema
/// real que sigue cada país. Empezó con 12 nacionalidades; el 26 de
/// agosto de 2026 se amplió a 20, comparando con las 24+ (con "ver más")
/// que ofrece Copero en su simulador de carrera de fútbol. Se puede
/// seguir ampliando sin tocar nada de lo que ya existe.
///
/// Los nombres de las organizaciones están cambiados a propósito (mismo
/// criterio que ya se usa en el resto del juego para jugadores y equipos
/// NBA: 1-2 letras distintas del real), ver `equipos_info.dart` y el
/// README.
library;

enum TipoOrganizacionJuvenil { clubDeCantera, universidad, academiaDeportiva }

class RutaJuvenil {
  final String nombrePais;

  /// El emoji de bandera del país (dato público, no hace falta disimularlo
  /// como los nombres de jugadores/equipos reales).
  final String bandera;
  final TipoOrganizacionJuvenil tipo;
  final List<String> organizaciones;

  const RutaJuvenil({
    required this.nombrePais,
    required this.bandera,
    required this.tipo,
    required this.organizaciones,
  });
}

/// Clave: código de país (ISO 3166-1 alfa-3).
const rutasJuveniles = <String, RutaJuvenil>{
  'ESP': RutaJuvenil(
    nombrePais: 'España',
    bandera: '🇪🇸',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Real Madird', 'Barza', 'Baskonya'],
  ),
  'USA': RutaJuvenil(
    nombrePais: 'Estados Unidos',
    bandera: '🇺🇸',
    tipo: TipoOrganizacionJuvenil.universidad,
    organizaciones: ['Duqe', 'Kentucki', 'Kanzas'],
  ),
  'ARG': RutaJuvenil(
    nombrePais: 'Argentina',
    bandera: '🇦🇷',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Peñarrol', 'San Lorenzzo', 'Kimsa'],
  ),
  'FRA': RutaJuvenil(
    nombrePais: 'Francia',
    bandera: '🇫🇷',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Asvel', 'Le Manz', 'Nantere'],
  ),
  'SRB': RutaJuvenil(
    nombrePais: 'Serbia',
    bandera: '🇷🇸',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Partizzan', 'Crvena Zvedza', 'Mega Baskett'],
  ),
  'LTU': RutaJuvenil(
    nombrePais: 'Lituania',
    bandera: '🇱🇹',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Zalgyris', 'Rytass', 'Lietkabellis'],
  ),
  'AUS': RutaJuvenil(
    nombrePais: 'Australia',
    bandera: '🇦🇺',
    tipo: TipoOrganizacionJuvenil.academiaDeportiva,
    organizaciones: ['Academia Global de Básquet', 'Centro de Alto Rendimiento', 'Instituto del Deporte'],
  ),
  'CAN': RutaJuvenil(
    nombrePais: 'Canadá',
    bandera: '🇨🇦',
    tipo: TipoOrganizacionJuvenil.academiaDeportiva,
    organizaciones: ['Academia CanBall', 'Instituto Toronto Prep', 'Academia Ontario Elite'],
  ),
  'DEU': RutaJuvenil(
    nombrePais: 'Alemania',
    bandera: '🇩🇪',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Bayern Múnich', 'Alba Berlín', 'Ratiopharm Ulmm'],
  ),
  'GRC': RutaJuvenil(
    nombrePais: 'Grecia',
    bandera: '🇬🇷',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Panathinaikoss', 'Olimpiacos', 'AEK Atenas'],
  ),
  'HRV': RutaJuvenil(
    nombrePais: 'Croacia',
    bandera: '🇭🇷',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Cybona', 'Cedevita Junior', 'Split Basket'],
  ),
  'BRA': RutaJuvenil(
    nombrePais: 'Brasil',
    bandera: '🇧🇷',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Flamengu', 'Franka Basquete', 'Pinheiros'],
  ),
  'ITA': RutaJuvenil(
    nombrePais: 'Italia',
    bandera: '🇮🇹',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Olimpya Milano', 'Virtuss Bolonia', 'Fortitudoo Bolonia'],
  ),
  'TUR': RutaJuvenil(
    nombrePais: 'Turquía',
    bandera: '🇹🇷',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Anadolu Efess', 'Fenerbache', 'Galatasarai'],
  ),
  'SVN': RutaJuvenil(
    nombrePais: 'Eslovenia',
    bandera: '🇸🇮',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Cedevita Olimpia', 'Krkka', 'Helios Sunz'],
  ),
  'ISR': RutaJuvenil(
    nombrePais: 'Israel',
    bandera: '🇮🇱',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Macabi Tel Aviv', 'Hapoel Jerusalen', 'Macabi Rishon'],
  ),
  'DOM': RutaJuvenil(
    nombrePais: 'República Dominicana',
    bandera: '🇩🇴',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Cañeross del Este', 'Metros de Santiagoo', 'Indioz de San Francisco'],
  ),
  'PRI': RutaJuvenil(
    nombrePais: 'Puerto Rico',
    bandera: '🇵🇷',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Cangrejeross de Santurce', 'Vakeros de Bayamón', 'Leonez de Ponce'],
  ),
  'CHN': RutaJuvenil(
    nombrePais: 'China',
    bandera: '🇨🇳',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Liaonning Leopardoss', 'Guangdung Tigers', 'Beijing Duckz'],
  ),
  'MEX': RutaJuvenil(
    nombrePais: 'México',
    bandera: '🇲🇽',
    tipo: TipoOrganizacionJuvenil.clubDeCantera,
    organizaciones: ['Fuersa Regia', 'Soles de Mexicalli', 'Halconez de Xalapa'],
  ),
};

/// Las tres ofertas iniciales de un país: siempre sus tres organizaciones
/// definidas arriba, en orden. Cuando haya más de tres por país (para variar
/// entre partidas) esto pasará a elegir al azar; de momento con tres alcanza
/// para la primera oferta.
List<String> ofertasJuvenilesIniciales(String codigoPais) {
  final ruta = rutasJuveniles[codigoPais];
  if (ruta == null) {
    throw ArgumentError('País sin ruta juvenil definida: $codigoPais');
  }
  return ruta.organizaciones;
}
