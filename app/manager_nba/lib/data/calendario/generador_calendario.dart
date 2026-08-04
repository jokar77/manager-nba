import 'dart:math';

import 'package:drift/drift.dart';

import '../../domain/equipos_especiales.dart';
import '../../domain/grupos_torneo.dart';
import '../../domain/tipo_evento_temporada.dart';
import '../database/app_database.dart';

const numPartidosTemporada = 82;
const _diasEntrePartidos = 2;

/// Valores de `PartidosCalendario.fase`. Solo los de [faseRegular] cuentan
/// para el récord y para dar la temporada por terminada; [faseFinalCopa] es
/// la Final de la NBA Cup, que tiene fila de calendario propia (para poder
/// jugarla desde el calendario, como cualquier otro día) pero no suma ni
/// victoria ni estadísticas.
const faseRegular = 'regular';
const faseFinalCopa = 'copa_final';

/// Resultado de generar una temporada: los partidos de los 30 equipos y
/// los eventos especiales (no son partidos), listos para insertar en la BD.
class CalendarioGenerado {
  final List<PartidosCalendarioCompanion> partidos;
  final List<EventosTemporadaCompanion> eventos;

  const CalendarioGenerado({required this.partidos, required this.eventos});
}

/// El 22 de octubre más próximo a partir de hoy (si ya pasó este año, el
/// del año que viene) — fecha de inicio de temporada realista.
DateTime proximoInicioDeTemporada() {
  final ahora = DateTime.now();
  var fecha = DateTime(ahora.year, 10, 22);
  if (fecha.isBefore(DateTime(ahora.year, ahora.month, ahora.day))) {
    fecha = DateTime(ahora.year + 1, 10, 22);
  }
  return fecha;
}

DateTime _primerDiaDeLaSemana(int anio, int mes, int diaSemana) {
  var fecha = DateTime(anio, mes, 1);
  while (fecha.weekday != diaSemana) {
    fecha = fecha.add(const Duration(days: 1));
  }
  return fecha;
}

/// Un partido de cada equipo cae en día par respecto a [fechaInicio]; para
/// que una fecha especial nunca coincida con la fecha exacta de un
/// partido (si coincidiesen, `CalendarioScreen` no podría distinguir cuál
/// mostrar), se empuja un día más allá si hace falta.
DateTime _evitarDiaDePartido(DateTime fecha, DateTime fechaInicio) {
  final offset = fecha.difference(fechaInicio).inDays;
  return (offset >= 0 && offset.isEven)
      ? fecha.add(const Duration(days: 1))
      : fecha;
}

bool _enVentanaDeTorneo(DateTime fecha, DateTime fechaInicio) {
  final inicioTorneo = DateTime(fechaInicio.year, 11, 1);
  final finTorneo = DateTime(fechaInicio.year, 12, 17);
  return !fecha.isBefore(inicioTorneo) && !fecha.isAfter(finTorneo);
}

/// Genera el calendario de la temporada de **un** equipo: un partido cada
/// [_diasEntrePartidos] días desde [fechaInicio], contra rivales sacados
/// de [rivalesPosibles] (se baraja y se cicla si hace falta más partidos
/// que rivales posibles), alternando local/visitante.
///
/// Dentro de la ventana del 1 de noviembre al 17 de diciembre (fase de
/// grupos de la NBA Cup), se reservan 4 huecos concretos — 2 en los que ya
/// tocaba jugar en casa, 2 en los que tocaba fuera — para los 4 rivales de
/// grupo de [equipo] ([rivalesDeGrupo]), marcados `esTorneoTemporada`. El
/// resto de partidos de esa ventana son partidos normales (pueden repetir
/// rival, incluido alguno de grupo, como cualquier otro tramo de la
/// temporada).
///
/// Nota de diseño: cada equipo tiene su temporada calculada de forma
/// independiente (no es una liga real entrelazada — el partido de A contra
/// B en el calendario de A no es "el mismo partido" que uno de B contra A
/// en el suyo, ni siquiera los de grupo de la Cup). Es una simplificación
/// deliberada: así cada uno de los 30 equipos mantiene siempre exactamente
/// [numPartidos] partidos propios, sin tener que resolver un calendario de
/// liga mutuamente consistente.
List<PartidosCalendarioCompanion> generarCalendarioEquipo({
  required String equipo,
  required List<String> rivalesPosibles,
  required DateTime fechaInicio,
  required int numPartidos,
  required Random random,
  List<String> rivalesDeGrupo = const [],
}) {
  if (rivalesPosibles.isEmpty) {
    throw ArgumentError('No hay rivales disponibles para generar calendario');
  }

  final partidos = <PartidosCalendarioCompanion>[];
  var ciclo = [...rivalesPosibles]..shuffle(random);
  var indiceEnCiclo = 0;

  for (var i = 0; i < numPartidos; i++) {
    if (indiceEnCiclo >= ciclo.length) {
      ciclo = [...rivalesPosibles]..shuffle(random);
      indiceEnCiclo = 0;
    }
    final rival = ciclo[indiceEnCiclo];
    indiceEnCiclo++;

    final fecha = fechaInicio.add(Duration(days: i * _diasEntrePartidos));
    partidos.add(PartidosCalendarioCompanion.insert(
      equipoPropietario: equipo,
      fecha: fecha,
      rival: rival,
      esLocal: i.isEven,
      // Explícito (no solo el default de la tabla): _asignarPartidosDeGrupo
      // reescribe algunas filas antes de insertar, y sin esto `.value`
      // sobre las que no toque revienta (Value.absent no tiene valor hasta
      // que se inserta).
      esTorneoTemporada: const Value(false),
    ));
  }

  _asignarPartidosDeGrupo(partidos, rivalesDeGrupo, fechaInicio);

  return partidos;
}

/// Sustituye 2 partidos en casa y 2 fuera dentro de la ventana de la NBA
/// Cup por los 4 rivales de grupo, marcándolos como partido de torneo. Si
/// la ventana no tuviera suficientes huecos de algún tipo (no debería
/// pasar: ~23 partidos caen en esas ~7 semanas para solo 4 huecos), se
/// completa con lo que haya en vez de forzar el 2-2 exacto.
void _asignarPartidosDeGrupo(
  List<PartidosCalendarioCompanion> partidos,
  List<String> rivalesDeGrupo,
  DateTime fechaInicio,
) {
  if (rivalesDeGrupo.isEmpty) return;

  final indicesEnVentana = [
    for (var i = 0; i < partidos.length; i++)
      if (_enVentanaDeTorneo(partidos[i].fecha.value, fechaInicio)) i,
  ];
  final slots = [
    ...indicesEnVentana.where((i) => i.isEven).take(2),
    ...indicesEnVentana.where((i) => i.isOdd).take(2),
  ];

  for (var j = 0; j < rivalesDeGrupo.length && j < slots.length; j++) {
    final indice = slots[j];
    partidos[indice] = partidos[indice].copyWith(
      rival: Value(rivalesDeGrupo[j]),
      esTorneoTemporada: const Value(true),
    );
  }
}

/// Genera las fechas especiales de la temporada (no dependen de ningún
/// equipo en concreto: son las mismas para todos), con el calendario NBA
/// real como referencia: All-Star el tercer sábado de febrero, fecha
/// límite de traspasos el primer jueves de febrero, y cierre del mercado
/// de agentes libres el 1 de marzo.
List<EventosTemporadaCompanion> generarEventosTemporada({
  required DateTime fechaInicio,
  required int numPartidos,
}) {
  final anioFebrero = fechaInicio.year + 1;
  final primerJueves = _primerDiaDeLaSemana(anioFebrero, 2, DateTime.thursday);
  final tercerSabado =
      _primerDiaDeLaSemana(anioFebrero, 2, DateTime.saturday)
          .add(const Duration(days: 14));

  return [
    EventosTemporadaCompanion.insert(
      // El 1 de marzo, como en la NBA de verdad: es el último día para
      // firmar a alguien y que pueda jugar los playoffs.
      //
      // Antes esto caía nueve días después del primer partido. Mientras la
      // fecha solo servía para sacar un aviso nadie lo notaba, pero en
      // cuanto empezó a cerrar el mercado de verdad dejaba la agencia libre
      // inservible desde octubre: los otros 73 partidos de la temporada no
      // se podía fichar a nadie.
      fecha: _evitarDiaDePartido(DateTime(anioFebrero, 3, 1), fechaInicio),
      tipo: TipoEventoTemporada.finAgenciaLibre.name,
    ),
    EventosTemporadaCompanion.insert(
      fecha: _evitarDiaDePartido(tercerSabado, fechaInicio),
      tipo: TipoEventoTemporada.allStar.name,
    ),
    EventosTemporadaCompanion.insert(
      fecha: _evitarDiaDePartido(primerJueves, fechaInicio),
      tipo: TipoEventoTemporada.fechaLimiteTraspasos.name,
    ),
  ];
}

/// Genera la temporada regular completa de los 30 equipos (incluido
/// [equipoUsuario]) más las fechas especiales, todo compartiendo el mismo
/// rango de fechas para poder simularse a la vez y consultar
/// clasificaciones en cualquier momento. Por defecto empieza el 22 de
/// octubre más próximo, como una temporada NBA real (82 partidos cada ~2
/// días acaban sobre principios de abril).
CalendarioGenerado generarCalendarioLiga({
  required String equipoUsuario,
  required List<String> equiposDisponibles,
  DateTime? fechaInicio,
  int numPartidos = numPartidosTemporada,
  Random? random,
}) {
  final inicio = fechaInicio ?? proximoInicioDeTemporada();
  final rng = random ?? Random();

  final equipos =
      equiposDisponibles.where(esFranquicia).toSet().toList()..sort();
  if (!equipos.contains(equipoUsuario)) {
    throw ArgumentError('$equipoUsuario no está en equiposDisponibles');
  }

  final partidos = <PartidosCalendarioCompanion>[];
  for (final equipo in equipos) {
    final rivalesPosibles = equipos.where((e) => e != equipo).toList();
    partidos.addAll(generarCalendarioEquipo(
      equipo: equipo,
      rivalesPosibles: rivalesPosibles,
      fechaInicio: inicio,
      numPartidos: numPartidos,
      random: rng,
      rivalesDeGrupo:
          rivalesDeGrupo(equipo).where((r) => equipos.contains(r)).toList(),
    ));
  }

  final eventos = generarEventosTemporada(
    fechaInicio: inicio,
    numPartidos: numPartidos,
  );

  return CalendarioGenerado(partidos: partidos, eventos: eventos);
}
