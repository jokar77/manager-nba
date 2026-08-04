import 'dart:math';

import 'package:drift/drift.dart';

import '../data/database/app_database.dart';
import 'picks_repository.dart';
import 'posiciones.dart';
import 'tipo_evento_temporada.dart';
import 'traspasos_repository.dart';

/// Cuántas ofertas te pueden tener esperando a la vez. Más que esto y la
/// pantalla se convierte en una bandeja de correo.
const maxOfertasPendientes = 3;

/// Cuántas ofertas nuevas pueden llegar en total a lo largo de UNA
/// temporada. Se cuenta con `temporada.ofertasGeneradasEstaTemporada`, que
/// a diferencia de las filas de `OfertasTraspaso` (se borran al aceptar o
/// rechazar) no baja nunca dentro del mismo año — así el tope es real, no
/// solo "como mucho 3 sin resolver a la vez". Antes de esto, medido con
/// varias partidas simuladas iguales, la temporada 2 en adelante generaba
/// sistemáticamente más ofertas que la 1 (efecto real, no ruido: creciente
/// en 5 de 5 semillas probadas).
const maxOfertasPorTemporada = 3;

/// Con qué probabilidad se fija alguien en tu plantilla por cada partido
/// que se simula. Con 82 partidos salen unos 5 intentos por temporada, de
/// los que varios se caen porque no hay ningún paquete que cuadre: en la
/// práctica se llega al tope de [maxOfertasPorTemporada] casi siempre y
/// quedarse a cero es raro (0,6% de las temporadas si nunca cuajara
/// ninguno).
const probabilidadPorPartido = 0.06;

/// Una oferta que te ha llegado, ya resuelta a jugadores y picks de verdad.
class OfertaEntrante {
  final int id;
  final String equipoOfertante;

  /// Lo que te piden (sale de tu plantilla).
  final List<Jugador> tePiden;

  /// Lo que te dan.
  final List<Jugador> teOfrecen;
  final List<PickDraft> teOfrecenPicks;

  const OfertaEntrante({
    required this.id,
    required this.equipoOfertante,
    required this.tePiden,
    required this.teOfrecen,
    required this.teOfrecenPicks,
  });

  String get resumenQuePiden => tePiden.map((j) => j.nombreFicticio).join(', ');

  String get resumenQueOfrecen => [
        ...teOfrecen.map((j) => j.nombreFicticio),
        ...teOfrecenPicks.map(etiquetaDePick),
      ].join(', ');
}

/// Mientras simulas, los otros equipos también trabajan: de vez en cuando
/// alguno se fija en uno de tus jugadores y te manda una propuesta.
///
/// La probabilidad va con el trozo de temporada simulado —un día casi nunca,
/// un mes entero bastante a menudo— y la oferta que te llega es de verdad:
/// es un paquete que ese equipo aceptaría si se lo propusieras tú, así que
/// aceptarla no puede acabar en "pues ahora que lo pienso, no".
Future<int> generarOfertasEntrantes(
  AppDatabase db, {
  required String equipoUsuario,
  required int partidosSimulados,
  required DateTime fecha,
  Random? random,
}) async {
  final rng = random ?? Random();

  final pendientes = await db.select(db.ofertasTraspaso).get();
  if (pendientes.length >= maxOfertasPendientes) return 0;
  if (partidosSimulados <= 0) return 0;

  // Con el mercado cerrado no llama nadie. Faltaba esta comprobación: las
  // ofertas se seguían generando en marzo y abril, y al abrirlas te decían
  // que ya no se podían cerrar — un teléfono que suena para nada.
  final eventoLimite = await (db.select(db.eventosTemporada)
        ..where((t) =>
            t.tipo.equals(TipoEventoTemporada.fechaLimiteTraspasos.name)))
      .getSingleOrNull();
  if (eventoLimite != null && fecha.isAfter(eventoLimite.fecha)) return 0;

  final temporada = await (db.select(db.temporada)..where((t) => t.id.equals(0)))
      .getSingleOrNull();
  if ((temporada?.ofertasGeneradasEstaTemporada ?? 0) >= maxOfertasPorTemporada) {
    return 0;
  }

  // El ritmo va por partido simulado, no por tramo, para que dé igual si
  // avanzas día a día o mes a mes: una temporada completa son siempre los
  // mismos 82 tiros.
  //
  // Con 0,022 la media medida era de 1,4 ofertas por temporada y 1 de cada
  // 12 temporadas no traía ninguna — te podías jugar el año entero sin que
  // sonara el teléfono. Con 0,06 se esperan ~5 intentos, de los que algunos
  // se caen porque no hay ningún paquete que cuadre, así que en la práctica
  // se llega al tope de [maxOfertasPorTemporada] casi siempre y quedarse a
  // cero pasa a ser una rareza. El tope sigue siendo 3: esto solo hace que
  // el que manda sea el tope y no la suerte.
  // Una tirada por partido, no una por llamada. Esto es lo que hace que dé
  // igual cómo avances: antes se tiraba UNA vez por tramo con probabilidad
  // `min(0,35; partidos*0,06)`, así que quien simulaba semana a semana
  // tenía ~27 oportunidades por temporada y quien le daba a "simular hasta
  // el final" tenía dos o tres. Medido por el camino real del calendario,
  // simulando la temporada de una tacada: 0, 0, 0 y 1 oferta en cuatro
  // años. El comentario de arriba ya decía que el ritmo iba por partido;
  // el código no lo cumplía.
  var intentos = 0;
  for (var i = 0; i < partidosSimulados; i++) {
    if (rng.nextDouble() < probabilidadPorPartido) intentos++;
  }
  if (intentos == 0) return 0;

  final mercado = await cargarMercado(db);
  final tuya = mercado.plantillaDe(equipoUsuario);
  if (tuya.isEmpty) return 0;

  // Se fijan en los que valen algo, no en el duodécimo hombre.
  final apetecibles = [...tuya]
    ..sort((a, b) => valorDeTraspaso(b).compareTo(valorDeTraspaso(a)));
  final objetivos = apetecibles.take(8).toList()..shuffle(rng);
  final yaPedidos = pendientes
      .expand((o) => _ids(o.pideJugadores))
      .toSet();

  var creadas = 0;
  var contador = temporada?.ofertasGeneradasEstaTemporada ?? 0;

  for (final objetivo in objetivos) {
    // Los topes mandan sobre los intentos: ni más de las que caben en la
    // bandeja ni más de las que permite la temporada.
    if (creadas >= intentos) break;
    if (pendientes.length + creadas >= maxOfertasPendientes) break;
    if (contador >= maxOfertasPorTemporada) break;
    if (yaPedidos.contains(objetivo.id)) continue;

    final propuestas = buscarSalidaEnMercado(
      mercado,
      equipoUsuario: equipoUsuario,
      jugadorIds: [objetivo.id],
      maxPropuestas: 12,
    );
    if (propuestas.isEmpty) continue;

    // Quien más lo quiere es quien peor anda de ese puesto.
    bool leHaceFalta(PropuestaTraspaso p) {
      final plantilla = mercado.plantillaDe(p.equipoRival);
      return plantilla
              .where((j) => juegaComodoDe(j, objetivo.posicion))
              .length <=
          2;
    }

    final conNecesidad = propuestas.where(leHaceFalta).toList();
    final elegibles = conNecesidad.isNotEmpty ? conNecesidad : propuestas;
    final elegida = elegibles[rng.nextInt(min(3, elegibles.length))];

    await db.into(db.ofertasTraspaso).insert(OfertasTraspasoCompanion.insert(
          equipoOfertante: elegida.equipoRival,
          pideJugadores: elegida.idsQueSalen.join(','),
          ofreceJugadores: elegida.idsQueLlegan.join(','),
          ofrecePicks: Value(elegida.idsPicksQueLlegan.join(',')),
          fecha: fecha,
        ));
    creadas++;
    contador++;
    await (db.update(db.temporada)..where((t) => t.id.equals(0))).write(
      TemporadaCompanion(
        ofertasGeneradasEstaTemporada: Value(contador),
      ),
    );
  }

  return creadas;
}

List<int> _ids(String csv) => csv
    .split(',')
    .where((s) => s.trim().isNotEmpty)
    .map(int.parse)
    .toList();

/// Las ofertas que tienes encima de la mesa, ya resueltas. Las que se han
/// quedado obsoletas (el jugador cambió de equipo, el pick ya se gastó) se
/// borran por el camino en vez de enseñarse rotas.
Future<List<OfertaEntrante>> ofertasPendientes(
  AppDatabase db,
  String equipoUsuario,
) async {
  final filas = await (db.select(db.ofertasTraspaso)
        ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
      .get();
  if (filas.isEmpty) return [];

  final jugadores = await db.select(db.jugadores).get();
  final porId = {for (final j in jugadores) j.id: j};
  final picks = await picksVivos(db);
  final picksPorId = {for (final p in picks) p.id: p};

  final vivas = <OfertaEntrante>[];
  final caducadas = <int>[];

  for (final fila in filas) {
    final tePiden = _ids(fila.pideJugadores).map((id) => porId[id]).toList();
    final teOfrecen =
        _ids(fila.ofreceJugadores).map((id) => porId[id]).toList();
    final teOfrecenPicks =
        _ids(fila.ofrecePicks).map((id) => picksPorId[id]).toList();

    final sigueValiendo = tePiden.every((j) => j?.equipo == equipoUsuario) &&
        teOfrecen.every((j) => j?.equipo == fila.equipoOfertante) &&
        teOfrecenPicks.every((p) => p?.equipoActual == fila.equipoOfertante);
    if (!sigueValiendo) {
      caducadas.add(fila.id);
      continue;
    }

    vivas.add(OfertaEntrante(
      id: fila.id,
      equipoOfertante: fila.equipoOfertante,
      tePiden: tePiden.nonNulls.toList(),
      teOfrecen: teOfrecen.nonNulls.toList(),
      teOfrecenPicks: teOfrecenPicks.nonNulls.toList(),
    ));
  }

  if (caducadas.isNotEmpty) {
    await (db.delete(db.ofertasTraspaso)..where((t) => t.id.isIn(caducadas)))
        .go();
  }
  return vivas;
}

/// Cuántas ofertas nuevas hay sin mirar. Es lo que dispara el aviso al
/// terminar de simular.
Future<int> ofertasSinVer(AppDatabase db) async {
  final filas = await (db.select(db.ofertasTraspaso)
        ..where((t) => t.vista.equals(false)))
      .get();
  return filas.length;
}

/// Marca todas como vistas: ya no vuelven a avisarte, pero siguen ahí hasta
/// que las aceptes o las rechaces.
Future<void> marcarOfertasComoVistas(AppDatabase db) async {
  await db
      .update(db.ofertasTraspaso)
      .write(const OfertasTraspasoCompanion(vista: Value(true)));
}

/// Acepta una oferta: se ejecuta el traspaso y desaparece de la bandeja.
/// El resto de ofertas por los mismos jugadores se caen solas la próxima vez
/// que se leen (ver [ofertasPendientes]).
///
/// Devuelve false —y deja la oferta donde estaba— si ya pasó la fecha
/// límite de traspasos: aceptar una oferta es cerrar un traspaso, y esa
/// puerta también tiene que estar cerrada.
Future<bool> aceptarOferta(
  AppDatabase db,
  OfertaEntrante oferta, {
  required String equipoUsuario,
}) async {
  final hecho = await ejecutarTraspaso(
    db,
    equipoUsuario: equipoUsuario,
    equipoRival: oferta.equipoOfertante,
    tuyos: oferta.tePiden.map((j) => j.id).toList(),
    suyos: oferta.teOfrecen.map((j) => j.id).toList(),
    susPicks: oferta.teOfrecenPicks.map((p) => p.id).toList(),
  );
  if (!hecho) return false;
  await rechazarOferta(db, oferta.id);
  return true;
}

/// Descarta una oferta.
Future<void> rechazarOferta(AppDatabase db, int ofertaId) async {
  await (db.delete(db.ofertasTraspaso)..where((t) => t.id.equals(ofertaId)))
      .go();
}

/// Vacía la bandeja. Se llama al cambiar de temporada: una oferta de mayo no
/// tiene sentido en la pretemporada siguiente.
Future<void> borrarOfertas(AppDatabase db) async {
  await db.delete(db.ofertasTraspaso).go();
}
