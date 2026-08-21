import '../data/database/app_database.dart';

/// Días que tiene que esperar un agente libre recién fichado antes de poder
/// ser traspasado: la regla real de la NBA (tres meses desde la firma). No
/// se ha modelado el resto del reglamento de traspasos de la NBA real —
/// derechos de tanteo, sign-and-trade, la regla de los mayores de 38 años,
/// etc.— solo esta, que es la que de verdad se nota al jugar: fichar a
/// alguien y ofrecerlo esa misma semana.
const diasMinimosTrasFichaje = 90;

/// Null si [jugador] ya se puede traspasar, o el motivo si no.
///
/// Solo mira `fechaFichaje`, que únicamente se rellena al firmar como
/// agente libre (ver `agencia_libre_repository.dart`): los importados, los
/// drafteados y los que renuevan con su propio equipo se quedan a null y
/// nunca caen en esta restricción — en la NBA real un rookie sí puede
/// traspasarse la misma noche del draft, y una renovación no es un fichaje
/// nuevo.
String? restriccionDeFichajeReciente(Jugador jugador, DateTime fechaActual) {
  final fichaje = jugador.fechaFichaje;
  if (fichaje == null) return null;
  final dias = fechaActual.difference(fichaje).inDays;
  if (dias >= diasMinimosTrasFichaje) return null;
  return '${jugador.nombreFicticio} no se puede traspasar todavía: fichó '
      'hace menos de tres meses.';
}
