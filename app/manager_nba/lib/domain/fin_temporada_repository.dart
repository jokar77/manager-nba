import 'package:drift/drift.dart';

import '../data/calendario/generador_calendario.dart';
import '../data/database/app_database.dart';
import 'playoffs_repository.dart';
import 'premios_repository.dart';

/// true cuando ya se han jugado los [numPartidosTemporada] partidos
/// originales del calendario de [equipo]. Se basa en cuántas filas de
/// `PartidosCalendario` están `jugado`, no en el récord acumulado de
/// `ResultadoTemporada` — los cuartos y semifinal de la NBA Cup también
/// suman victorias/derrotas a ese récord (ver torneo_repository.dart) sin
/// añadir una fila nueva al calendario, así que usar el récord agregado
/// como disparador haría que la temporada se diera por terminada un
/// partido antes de tiempo para los equipos que llegan lejos en la Copa.
/// Por el mismo motivo solo cuentan las filas de fase `regular`: la Final
/// de la NBA Cup sí tiene fila de calendario propia (para poder jugarla sin
/// salir del calendario) pero es un partido extra que no cuenta para nada.
Future<bool> temporadaRegularCompleta(AppDatabase db, String equipo) async {
  final jugados = await (db.select(db.partidosCalendario)
        ..where((t) =>
            t.equipoPropietario.equals(equipo) &
            t.jugado.equals(true) &
            t.fase.equals(faseRegular)))
      .get();
  return jugados.length >= numPartidosTemporada;
}

/// Si la temporada regular de [equipoUsuario] (82 partidos) ya está
/// completa y todavía no se ha cerrado, calcula los premios y siembra los
/// playoffs. Devuelve `true` si acaba de cerrar la temporada ahora mismo
/// (para que la UI pueda avisar).
/// Idempotente: en llamadas posteriores no vuelve a hacer nada.
Future<bool> cerrarTemporadaRegularSiToca(
  AppDatabase db,
  String equipoUsuario,
) async {
  if (!await temporadaRegularCompleta(db, equipoUsuario)) return false;

  // "¿Ya está cerrada?" se pregunta mirando si hay bracket, que es
  // exactamente lo que esta función crea. Antes se miraba si la tabla de
  // premios tenía algo, y eso fallaba por los dos lados:
  //
  // - Los MVP del fin de semana de las estrellas viven en esa misma tabla
  //   y se conceden en FEBRERO. En cuanto se jugaba el All-Star la tabla
  //   dejaba de estar vacía, así que al llegar abril esta función se daba
  //   por hecha y NO sembraba los playoffs: la temporada regular acababa y
  //   no aparecían por ningún lado.
  // - Y al revés: si `calcularPremios` no encontrara a nadie a quien
  //   premiar, la tabla se quedaría vacía y se volvería a sembrar el
  //   bracket entero en cada llamada.
  final yaSembrados = await db.select(db.seriesPlayoffs).get();
  if (yaSembrados.isNotEmpty) return false;

  await calcularPremios(db);
  await sembrarPlayoffs(db);
  return true;
}
