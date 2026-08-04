import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'draft_repository.dart';
import 'equipos_especiales.dart';

/// Cuántos drafts por delante tiene picks cada equipo. Cuatro años es lo
/// que permite montar un traspaso a futuro sin que la liga se convierta en
/// un mercado de papeletas de dentro de una década.
const aniosDePicksFuturos = 4;

/// Cuántos jugadores de la plantilla cuentan para medir la fuerza de un
/// equipo. Son los de la rotación: el fondo de banquillo no dice nada de
/// dónde va a acabar clasificado.
const _jugadoresQueMidenLaFuerza = 10;

/// Genera las elecciones de los próximos [aniosDePicksFuturos] drafts para
/// todos los equipos, si no existen ya. Idempotente: se puede llamar al
/// crear la franquicia y en cada cambio de temporada, y solo añade el año
/// nuevo que falta.
Future<void> asegurarPicksFuturos(
  AppDatabase db, {
  required int primerAnioDeDraft,
  required List<String> equipos,
}) async {
  final existentes = await db.select(db.picksDraft).get();
  final yaHay = {
    for (final p in existentes) '${p.temporada}|${p.ronda}|${p.equipoOriginal}',
  };

  final nuevas = <PicksDraftCompanion>[];
  for (var i = 0; i < aniosDePicksFuturos; i++) {
    final anio = primerAnioDeDraft + i;
    for (var ronda = 1; ronda <= rondasDeDraft; ronda++) {
      for (final equipo in equipos) {
        if (yaHay.contains('$anio|$ronda|$equipo')) continue;
        nuevas.add(PicksDraftCompanion.insert(
          temporada: anio,
          ronda: ronda,
          equipoOriginal: equipo,
          equipoActual: equipo,
        ));
      }
    }
  }
  if (nuevas.isEmpty) return;
  await db.batch((batch) => batch.insertAll(db.picksDraft, nuevas));
}

/// Las elecciones que posee [equipo] ahora mismo, de la más cercana a la
/// más lejana.
Future<List<PickDraft>> picksDe(AppDatabase db, String equipo) {
  return (db.select(db.picksDraft)
        ..where((t) => t.equipoActual.equals(equipo) & t.usado.equals(false))
        ..orderBy([
          (t) => OrderingTerm.asc(t.temporada),
          (t) => OrderingTerm.asc(t.ronda),
        ]))
      .get();
}

/// Todas las elecciones vivas (sin usar) de la liga.
Future<List<PickDraft>> picksVivos(AppDatabase db) {
  return (db.select(db.picksDraft)..where((t) => t.usado.equals(false))).get();
}

/// Cambia de dueño las elecciones indicadas.
Future<void> traspasarPicks(
  AppDatabase db,
  List<int> pickIds,
  String nuevoEquipo,
) async {
  if (pickIds.isEmpty) return;
  await (db.update(db.picksDraft)..where((t) => t.id.isIn(pickIds)))
      .write(PicksDraftCompanion(equipoActual: Value(nuevoEquipo)));
}

/// Marca como gastadas las elecciones del draft de [anioDraft]. Se llama al
/// cerrar el draft: a partir de ahí ya no se pueden traspasar.
Future<void> marcarPicksUsados(AppDatabase db, int anioDraft) async {
  await (db.update(db.picksDraft)
        ..where((t) => t.temporada.isSmallerOrEqualValue(anioDraft)))
      .write(const PicksDraftCompanion(usado: Value(true)));
}

/// Fuerza actual de cada equipo: la media de sus [_jugadoresQueMidenLaFuerza]
/// mejores jugadores. Es lo que se usa para adivinar en qué puesto del draft
/// va a caer su elección.
Future<Map<String, double>> fuerzaDeLosEquipos(AppDatabase db) async {
  final jugadores = await (db.select(db.jugadores)
        ..where((t) => t.retirado.equals(false)))
      .get();

  final porEquipo = <String, List<int>>{};
  for (final j in jugadores) {
    if (!esFranquicia(j.equipo)) continue;
    porEquipo.putIfAbsent(j.equipo, () => []).add(j.media);
  }

  return {
    for (final entry in porEquipo.entries)
      entry.key: _mediaDeLosMejores(entry.value),
  };
}

double _mediaDeLosMejores(List<int> medias) {
  final ordenadas = [...medias]..sort((a, b) => b.compareTo(a));
  final cuantos = min(_jugadoresQueMidenLaFuerza, ordenadas.length);
  if (cuantos == 0) return 0;
  return ordenadas.take(cuantos).reduce((a, b) => a + b) / cuantos;
}

/// Dónde se espera que caiga cada equipo en el orden de draft: 1 el peor
/// (elige primero), 30 el mejor. Se deduce de la fuerza actual de plantilla,
/// que es lo único que se sabe de un draft que aún no se ha jugado.
Map<String, int> puestosEsperadosDeDraft(Map<String, double> fuerza) {
  final ordenados = fuerza.keys.toList()
    ..sort((a, b) {
      final cmp = fuerza[a]!.compareTo(fuerza[b]!);
      return cmp != 0 ? cmp : a.compareTo(b);
    });
  return {for (var i = 0; i < ordenados.length; i++) ordenados[i]: i + 1};
}

/// Lo que vale una elección de draft, en la misma escala que
/// `valorDeTraspaso` (ver traspasos_repository.dart).
///
/// Se estima el jugador que va a salir de ese puesto —la clase de draft se
/// genera con la calidad decayendo del 1 al 60— y se le aplica un descuento
/// gordo: un pick no es un jugador, es la posibilidad de un jugador, y
/// encima tarda años en rendir. Con esta calibración un pick alto de un
/// equipo malo vale como un titular sólido y un segunda ronda apenas mueve
/// la aguja.
double valorDePick(
  PickDraft pick, {
  required Map<String, int> puestosEsperados,
  required int anioActualDeDraft,
  int equiposEnLaLiga = 30,
}) {
  final puesto = puestosEsperados[pick.equipoOriginal] ?? equiposEnLaLiga ~/ 2;
  final numeroGlobal = (pick.ronda - 1) * equiposEnLaLiga + puesto;
  final totalDeElecciones = equiposEnLaLiga * rondasDeDraft;
  final relativa = ((numeroGlobal - 1) / (totalDeElecciones - 1)).clamp(0.0, 1.0);

  // La misma curva que usa `generarClaseDeDraft`, mirando a lo que el
  // chaval puede llegar a ser (por eso pesa el potencial) y no a lo que es
  // el día que le eliges.
  final mediaDeSalida = 74 - relativa * 16;
  final margenDePotencial = 22 - relativa * 12;
  final nivelProyectado = mediaDeSalida + margenDePotencial * 0.6;

  final nivel = pow(max(0.0, nivelProyectado - 55), 2.0).toDouble();

  // Prima de juventud, la misma que un jugador de 23 o menos.
  const juventud = 1.25;
  // Descuento por riesgo: la mayoría de los elegidos no llegan a lo que
  // prometían, y los que llegan tardan.
  const riesgo = 0.45;
  final espera = max(0, pick.temporada - anioActualDeDraft);
  final descuentoPorEspera = pow(0.88, espera).toDouble();

  return nivel * juventud * riesgo * descuentoPorEspera;
}

/// Etiqueta corta de un pick para la interfaz: "1ª ronda 2028 (LAL)".
String etiquetaDePick(PickDraft pick) {
  final ronda = pick.ronda == 1 ? '1ª ronda' : '2ª ronda';
  return '$ronda ${pick.temporada} (${pick.equipoOriginal})';
}
