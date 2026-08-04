import 'dart:math';

import '../data/database/app_database.dart';
import 'posiciones.dart';
import 'traspasos_repository.dart';

/// Cuánto tiene que separarse un puesto de la media del equipo para
/// considerarlo un punto fuerte (le sobra) o un agujero (le falta).
///
/// Se mide por nivel, no por número: con las segundas posiciones casi todos
/// los equipos tienen gente de sobra en todos los puestos sobre el papel, y
/// contar cabezas no distingue entre tener tres bases y tener tres bases
/// buenos.
const _margenDeProfundidad = 1.5;

/// Y para poder soltar a alguien de un puesto hay que tener al menos estos
/// jugadores cómodos ahí: los dos de la rotación más el que se va.
const _minimoParaSoltar = 3;

/// Cuánto puede desequilibrarse un intercambio entre dos equipos de la CPU.
/// Nadie regala a su mejor jugador: el cambio tiene que ser parejo en valor,
/// y lo que lo hace atractivo es el encaje de puestos, no el saldo.
const _desequilibrioMaximo = 0.20;

/// Un intercambio cerrado entre dos equipos de la CPU, para poder contarlo
/// en el resumen de pretemporada.
class TraspasoDeLaCpu {
  final String equipoA;
  final String equipoB;
  final String jugadorDeA;
  final String jugadorDeB;
  final String posicionDeA;
  final String posicionDeB;

  const TraspasoDeLaCpu({
    required this.equipoA,
    required this.equipoB,
    required this.jugadorDeA,
    required this.jugadorDeB,
    required this.posicionDeA,
    required this.posicionDeB,
  });

  String get resumen =>
      '$equipoA manda a $jugadorDeA ($posicionDeA) a $equipoB '
      'a cambio de $jugadorDeB ($posicionDeB)';
}

/// La liga se mueve sola: los 29 equipos de la CPU cierran entre ellos unos
/// cuantos intercambios en la pretemporada, para que la segunda temporada no
/// te encuentres exactamente las mismas plantillas que la primera.
///
/// No son traspasos por valor —eso sería un equipo regalándole un jugador a
/// otro—, son por encaje: A tiene cuatro aleros y le falta un pívot, B está
/// al revés, y se hacen un favor mutuo cambiando piezas de nivel parecido.
/// Tu equipo nunca entra aquí: contigo negocian pidiéndote permiso (ver la
/// mesa de traspasos y las ofertas entrantes).
Future<List<TraspasoDeLaCpu>> ejecutarTraspasosDeLaCpu(
  AppDatabase db, {
  required String equipoUsuario,
  int maxTraspasos = 10,
  Random? random,
}) async {
  final rng = random ?? Random();
  final mercado = await cargarMercado(db);

  final equipos = mercado.franquicias.where((e) => e != equipoUsuario).toList()
    ..shuffle(rng);

  // Cada equipo entra como mucho en un intercambio: así los cálculos se
  // hacen todos sobre la misma foto sin que se pisen entre ellos.
  final yaMovidos = <String>{};
  final cerrados = <TraspasoDeLaCpu>[];

  for (final a in equipos) {
    if (cerrados.length >= maxTraspasos) break;
    if (yaMovidos.contains(a)) continue;

    final plantillaA = mercado.plantillaDe(a);
    final sobraEnA = _puestosQueSobran(plantillaA);
    final faltaEnA = _puestosQueFaltan(plantillaA);
    if (sobraEnA.isEmpty || faltaEnA.isEmpty) continue;

    for (final b in equipos) {
      if (b == a || yaMovidos.contains(b)) continue;

      final plantillaB = mercado.plantillaDe(b);
      final sobraEnB = _puestosQueSobran(plantillaB);
      final faltaEnB = _puestosQueFaltan(plantillaB);

      // El puesto que le sobra a A tiene que ser justo el que le falta a B,
      // y al revés.
      final daA = sobraEnA.where(faltaEnB.contains).toList();
      final daB = sobraEnB.where(faltaEnA.contains).toList();
      if (daA.isEmpty || daB.isEmpty) continue;

      final trato = _buscarIntercambio(
        mercado,
        equipoA: a,
        equipoB: b,
        puestoQueSaleDeA: daA.first,
        puestoQueSaleDeB: daB.first,
      );
      if (trato == null) continue;

      await ejecutarTraspaso(
        db,
        equipoUsuario: a,
        equipoRival: b,
        tuyos: [trato.$1.id],
        suyos: [trato.$2.id],
        // Movimientos entre equipos de la CPU en pretemporada: la fecha
        // límite de la temporada que viene no les afecta.
        respetarFechaLimite: false,
      );
      yaMovidos.addAll([a, b]);
      cerrados.add(TraspasoDeLaCpu(
        equipoA: a,
        equipoB: b,
        jugadorDeA: trato.$1.nombreFicticio,
        jugadorDeB: trato.$2.nombreFicticio,
        posicionDeA: etiquetaPosicion(trato.$1),
        posicionDeB: etiquetaPosicion(trato.$2),
      ));
      break;
    }
  }

  return cerrados;
}

/// Nivel de cada puesto en una plantilla: la media de los dos que jugarían
/// ahí. Es la foto de dónde está fuerte y dónde flojo un equipo.
Map<String, double> _profundidadPorPuesto(List<Jugador> plantilla) {
  final mapa = <String, double>{};
  for (final puesto in posicionesEquipo) {
    final comodos = plantilla.where((j) => juegaComodoDe(j, puesto)).toList()
      ..sort((a, b) => b.media.compareTo(a.media));
    if (comodos.isEmpty) {
      mapa[puesto] = 0;
      continue;
    }
    final rotacion = comodos.take(2);
    mapa[puesto] =
        rotacion.map((j) => j.media).reduce((a, b) => a + b) / rotacion.length;
  }
  return mapa;
}

double _mediaDeProfundidad(Map<String, double> profundidad) =>
    profundidad.values.reduce((a, b) => a + b) / profundidad.length;

/// Los puestos donde el equipo está claramente por encima de su propio
/// nivel medio y además le queda gente detrás: de ahí puede soltar a alguien
/// sin debilitarse.
List<String> _puestosQueSobran(List<Jugador> plantilla) {
  final profundidad = _profundidadPorPuesto(plantilla);
  final media = _mediaDeProfundidad(profundidad);
  return [
    for (final puesto in posicionesEquipo)
      if (profundidad[puesto]! >= media + _margenDeProfundidad &&
          plantilla.where((j) => juegaComodoDe(j, puesto)).length >=
              _minimoParaSoltar)
        puesto,
  ];
}

/// Y los puestos donde está por debajo de su propio nivel: sus agujeros.
List<String> _puestosQueFaltan(List<Jugador> plantilla) {
  final profundidad = _profundidadPorPuesto(plantilla);
  final media = _mediaDeProfundidad(profundidad);
  return [
    for (final puesto in posicionesEquipo)
      if (profundidad[puesto]! <= media - _margenDeProfundidad) puesto,
  ];
}

/// Busca la pareja de jugadores que hace el intercambio: uno del puesto que
/// le sobra a A, otro del que le sobra a B, de valor parecido y sin que a
/// ninguno de los dos se le rompa la plantilla ni el tope salarial.
(Jugador, Jugador)? _buscarIntercambio(
  MercadoDeTraspasos mercado, {
  required String equipoA,
  required String equipoB,
  required String puestoQueSaleDeA,
  required String puestoQueSaleDeB,
}) {
  final plantillaA = mercado.plantillaDe(equipoA);
  final plantillaB = mercado.plantillaDe(equipoB);

  // Del excedente no se suelta al mejor: se suelta al que no le está
  // jugando, que es el tercero o cuarto del puesto.
  final candidatosA = _excedenteDe(plantillaA, puestoQueSaleDeA);
  final candidatosB = _excedenteDe(plantillaB, puestoQueSaleDeB);

  for (final ja in candidatosA) {
    final valorA = valorDeTraspaso(ja);
    for (final jb in candidatosB) {
      final valorB = valorDeTraspaso(jb);
      final referencia = max(valorA, valorB);
      if (referencia <= 0) continue;
      if ((valorA - valorB).abs() / referencia > _desequilibrioMaximo) continue;

      final nuevaA = [...plantillaA.where((j) => j.id != ja.id), jb];
      final nuevaB = [...plantillaB.where((j) => j.id != jb.id), ja];
      if (plantillaRota(nuevaA) != null || plantillaRota(nuevaB) != null) {
        continue;
      }

      final encajeA = encajeSalarialRoto(
          masaPrevia: mercado.masaSalarialDe(equipoA),
          salarioQueSale: ja.salario,
          salarioQueEntra: jb.salario);
      final encajeB = encajeSalarialRoto(
          masaPrevia: mercado.masaSalarialDe(equipoB),
          salarioQueSale: jb.salario,
          salarioQueEntra: ja.salario);
      if (encajeA != null || encajeB != null) continue;

      return (ja, jb);
    }
  }
  return null;
}

/// Los jugadores de [puesto] que ya no entran en la rotación de ese sitio,
/// del mejor al peor. Son los negociables: los dos primeros del puesto no se
/// tocan.
List<Jugador> _excedenteDe(List<Jugador> plantilla, String puesto) {
  final delPuesto = plantilla.where((j) => juegaComodoDe(j, puesto)).toList()
    ..sort((a, b) => b.media.compareTo(a.media));
  return delPuesto.skip(2).toList();
}
