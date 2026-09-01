/// Códigos de "equipo" que no son franquicias: sirven para aparcar
/// jugadores fuera de las 30 plantillas sin borrarlos de la base.
///
/// Cualquier consulta que recorra plantillas tiene que descartarlos — para
/// eso está [esFranquicia].
library;

/// Agentes libres: sin equipo, disponibles para fichar.
const equipoAgenciaLibre = 'FA';

/// Retirados. Siguen en la base porque el palmarés, el Hall of Fame y las
/// camisetas retiradas necesitan resolver su nombre años después.
const equipoRetirados = 'RET';

/// Prospectos de un draft que todavía se está celebrando: aún no son de
/// nadie, pero ya existen como jugadores para poder enseñarlos y elegirlos.
const equipoProspectos = 'DRAFT';

/// Las dos selecciones del All-Star y las dos del Rising Stars. Viven en
/// `equiposInfo` (`equipos_info.dart`) para reusar sus mismos widgets de
/// logo/colores, pero no son una de las 30 franquicias — nadie puede
/// "jugar" para ellas fuera del propio fin de semana de las estrellas.
const equiposDeAllStar = {'Este', 'Oeste', 'Novatos', 'Sophomores'};

/// ¿Es [equipo] una de las 30 franquicias de verdad?
bool esFranquicia(String equipo) =>
    equipo != equipoAgenciaLibre &&
    equipo != equipoRetirados &&
    equipo != equipoProspectos &&
    !equiposDeAllStar.contains(equipo);
