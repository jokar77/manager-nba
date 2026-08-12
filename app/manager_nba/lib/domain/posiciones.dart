import '../data/database/app_database.dart';
import 'curva_estadisticas.dart';

/// Los 5 puestos de una alineación NBA, del exterior al interior. El orden
/// importa: dos puestos contiguos son "parecidos" (un base puede hacer de
/// escolta), dos separados no.
const posicionesEquipo = ['PG', 'SG', 'SF', 'PF', 'C'];

/// Multiplicador de rendimiento según lo cómodo que esté el jugador en el
/// puesto que le has asignado.
///
/// La penalización de jugar totalmente fuera de sitio es deliberadamente
/// suave (10%): si te falta un base natural de recambio, poner ahí a un
/// escolta bueno tiene que salirte mejor que sentar talento, no hundirte la
/// temporada. Lo que decide los partidos es la calidad y los minutos, no un
/// castigo posicional grande.
const factorPuestoNatural = 1.0;
const factorPuestoSecundario = 0.96;
const factorFueraDePosicion = 0.9;

/// Lo que pesa estar cómodo en el puesto **al repartir la alineación**, en
/// puntos de media. No toca la simulación: es solo un desempate.
///
/// Hace falta porque con estos factores dos candidatos muy distintos pueden
/// quedar a un pelo. Caso real de la plantilla de Denver: Strawther (76,
/// escolta) valía 76 × 0,9 = 68,40 como pívot suplente y Nnaji (71, PF/C)
/// valía 71 × 0,96 = 68,16. Ganaba el escolta por **0,24**, y la alineación
/// automática sacaba a un base-escolta de pívot teniendo un interior en el
/// banquillo. Decidir eso por 0,24 puntos es decidirlo por ruido.
///
/// Con un punto de margen, un empate técnico se resuelve a favor de quien
/// juega ahí de verdad, y el que está fuera de sitio sigue ganando el
/// puesto cuando es de verdad mejor (que era la intención original: hacen
/// falta unos 5 puntos de media para compensar la penalización).
const margenDeComodidadAlRepartir = 1.0;

/// La posición secundaria declarada en el dataset, si la trae ("SG / PG").
/// Devuelve null si solo trae una.
String? posicionSecundariaDeclarada(String posicionCruda) {
  final codigoEspacioNoSeparable = String.fromCharCode(0x00A0);
  final limpia = posicionCruda.replaceAll(codigoEspacioNoSeparable, ' ').trim();
  final partes = limpia.split('/').map((p) => p.trim()).toList();
  if (partes.length < 2) return null;
  final secundaria = partes[1];
  return posicionesEquipo.contains(secundaria) ? secundaria : null;
}

/// Segunda posición de un jugador cuando el dataset no la trae (que es casi
/// siempre: solo un jugador de los 641 viene con dos).
///
/// En la NBA real casi todo el mundo puede cubrir el puesto de al lado, así
/// que se le asigna el contiguo hacia el que tira su juego: si reparte más
/// de lo que rebotea, hacia fuera (un escolta que también hace de base); si
/// rebotea más, hacia dentro (un alero que también hace de ala-pívot). Los
/// extremos del espectro (base y pívot) solo pueden ir hacia un lado.
/// La comparación es **relativa a lo normal de su puesto**, no en absoluto.
///
/// Antes se miraba `astPg > trbPg` a secas, y eso en la práctica preguntaba
/// "¿es base?": en la NBA casi todo el mundo rebotea más de lo que asiste
/// (un alero tipo reparte 3,0 y coge 4,9). Medido sobre los 641 del
/// dataset, de los que pueden tirar hacia los dos lados —escoltas, aleros y
/// ala-pívots— **332 se iban hacia dentro y solo 45 hacia fuera**: 4 de 123
/// aleros pasaban a escolta y 2 de 123 ala-pívots a alero. La liga entera
/// se escoraba hacia el poste y nadie cubría el perímetro.
///
/// De ahí que Tatum saliera de "Ala-Pívot y Pívot": rebotea 10,0 y asiste
/// 5,3, así que la regla vieja lo mandaba hacia dentro sin mirar que para
/// un alero esas asistencias son muchas.
String derivarPosicionSecundaria({
  required String posicion,
  required double astPg,
  required double trbPg,
  required int media,
}) {
  final indice = posicionesEquipo.indexOf(posicion);
  if (indice < 0) return posicion;
  if (indice == 0) return posicionesEquipo[1];
  if (indice == posicionesEquipo.length - 1) {
    return posicionesEquipo[posicionesEquipo.length - 2];
  }

  // Cuánto se sale de lo esperable para alguien de su puesto y su nivel.
  // Si reparte más de lo suyo, tira hacia fuera; si rebotea más de lo suyo,
  // hacia dentro.
  final tiraFuera = astPg / asistenciasTipicas(media, posicion);
  final tiraDentro = trbPg / rebotesTipicos(media, posicion);
  return tiraFuera > tiraDentro
      ? posicionesEquipo[indice - 1]
      : posicionesEquipo[indice + 1];
}

/// ¿Cómo de cómodo está [jugador] jugando de [puesto]? Ver
/// [factorPuestoNatural] y compañía.
double factorDePuesto(Jugador jugador, String puesto) {
  if (jugador.posicion == puesto) return factorPuestoNatural;
  if (jugador.posicionSecundaria == puesto) return factorPuestoSecundario;
  return factorFueraDePosicion;
}

/// ¿Puede [jugador] jugar de [puesto] sin penalización real? (natural o
/// segunda posición). Lo usa la UI para avisar solo cuando toca.
bool juegaComodoDe(Jugador jugador, String puesto) =>
    jugador.posicion == puesto || jugador.posicionSecundaria == puesto;

/// Cómo se enseña la posición de un jugador: "SG" o "SG/PG".
String etiquetaPosicion(Jugador jugador) => jugador.posicionSecundaria == null
    ? jugador.posicion
    : '${jugador.posicion}/${jugador.posicionSecundaria}';

/// Reparte [plantilla] entre los cinco puestos, [porPuesto] jugadores en cada
/// uno (2 = titular y suplente), devolviendo la lista de cada puesto ordenada
/// de mejor a peor.
///
/// El criterio es lo que cada uno RINDE en cada puesto: su media por el
/// factor de comodidad ([factorDePuesto]). Se valoran todas las parejas
/// (jugador, puesto), se ordenan de mejor a peor y se reparten en una sola
/// pasada, quedándose cada hueco con la mejor pareja que le llegue.
///
/// Antes iba en tres pasadas —primero cada uno a su posición natural,
/// luego las segundas posiciones y al final el resto—, y eso le daba
/// prioridad absoluta a la etiqueta por encima del nivel: un base natural
/// de media 65 le ganaba el puesto de titular a un pívot de 86, que se
/// quedaba en el banquillo. Pero el motor solo penaliza un 10% por jugar
/// fuera de sitio, así que ese pívot rinde 77 de base — bastante más que
/// el 65 del que "le tocaba".
///
/// Valorando la pareja entera sale lo que se quiere por los dos lados: el
/// natural conserva su puesto salvo que el de fuera sea de verdad mucho
/// mejor (hace falta un ~11% más de media para compensar la penalización),
/// así que ni se sienta talento ni se montan disparates tipo pívot de
/// base.
Map<String, List<Jugador>> repartirPorPuestos(
  List<Jugador> plantilla, {
  int porPuesto = 2,
}) {
  final porPuestoAsignado = {
    for (final posicion in posicionesEquipo) posicion: <Jugador>[],
  };

  final parejas = <({Jugador jugador, String puesto, double valor})>[
    for (final jugador in plantilla)
      for (final puesto in posicionesEquipo)
        (
          jugador: jugador,
          puesto: puesto,
          valor: jugador.media * factorDePuesto(jugador, puesto) +
              (juegaComodoDe(jugador, puesto) ? margenDeComodidadAlRepartir : 0),
        ),
  ];
  // Desempates explícitos (id del jugador y orden de puesto) para que el
  // reparto sea siempre el mismo: List.sort no garantiza estabilidad.
  parejas.sort((a, b) {
    final porValor = b.valor.compareTo(a.valor);
    if (porValor != 0) return porValor;
    final porId = a.jugador.id.compareTo(b.jugador.id);
    if (porId != 0) return porId;
    return posicionesEquipo
        .indexOf(a.puesto)
        .compareTo(posicionesEquipo.indexOf(b.puesto));
  });

  final usados = <int>{};
  for (final pareja in parejas) {
    if (usados.contains(pareja.jugador.id)) continue;
    final hueco = porPuestoAsignado[pareja.puesto]!;
    if (hueco.length >= porPuesto) continue;
    hueco.add(pareja.jugador);
    usados.add(pareja.jugador.id);
  }

  return porPuestoAsignado;
}
