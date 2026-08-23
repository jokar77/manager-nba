import 'package:drift/drift.dart' show Value;

import '../data/database/app_database.dart';
// Solo para dejar la etiqueta en español guardada junto al efecto, igual
// que hace `eventos_narrativos_repository.dart`: lo que se ENSEÑA se
// traduce en pantalla con el idioma que tenga puesto el usuario.
import '../i18n/textos_eventos.dart';
import 'eventos_narrativos.dart' show EfectoDeEvento;
import 'patrocinadores.dart';

/// Un patrocinio firmado: qué categoría ocupa, qué marca, cuánto paga al
/// año y cuántas temporadas le quedan.
///
/// Es lo que hay en la tabla, ya normalizado. Ver [_contratoDeFila] para
/// qué se hace con las partidas viejas, anteriores a que los patrocinios
/// fueran contratos.
class ContratoDePatrocinio {
  final String categoria;

  /// La clave del catálogo (`ATL_01`), o `null` si viene de una partida
  /// anterior al esquema 29, cuando no se guardaba qué marca era.
  final String? clave;

  final int bonusAnual;

  /// Temporadas que le quedan, esta incluida. Siempre 1 o más: cuando
  /// llega a cero, [caducarPatrocinios] borra la fila.
  final int aniosRestantes;

  const ContratoDePatrocinio({
    required this.categoria,
    required this.clave,
    required this.bonusAnual,
    required this.aniosRestantes,
  });

  /// La marca, si se sabe cuál es y sigue en el catálogo.
  Patrocinador? get patrocinador {
    final c = clave;
    return c == null ? null : patrocinadorPorClave(c);
  }

  /// Lo que pide a cambio, que es cosa de la categoría y no de la marca.
  CompromisoDePatrocinio? get compromiso => compromisoPorCategoria[categoria];
}

/// Traduce una fila a un contrato, rellenando lo que las partidas viejas no
/// tienen.
///
/// Antes del esquema 29 un patrocinio era un interruptor: sin marca, con el
/// dinero fijo de su categoría y con un año de duración implícito (se
/// borraba todo en cada cambio de temporada). Se lee exactamente así, y en
/// el primer cierre de año caduca solo. Es el ÚNICO sitio donde se mira si
/// esas columnas vienen nulas.
ContratoDePatrocinio _contratoDeFila(PatrociniosActivo fila) =>
    ContratoDePatrocinio(
      categoria: fila.categoria,
      clave: fila.clave,
      bonusAnual: fila.bonusAnual ?? bonusPorCategoria[fila.categoria] ?? 0,
      aniosRestantes: fila.aniosRestantes ?? 1,
    );

/// Los patrocinios que tienes firmados ahora mismo, por categoría.
Future<Map<String, ContratoDePatrocinio>> leerContratosDePatrocinio(
    AppDatabase db) async {
  final filas = await db.select(db.patrociniosActivos).get();
  return {
    for (final fila in filas) fila.categoria: _contratoDeFila(fila),
  };
}

/// Las categorías que tienes ocupadas ahora mismo.
Future<Set<String>> leerPatrociniosActivos(AppDatabase db) async {
  final filas = await db.select(db.patrociniosActivos).get();
  return filas.map((f) => f.categoria).toSet();
}

/// Firma [oferta]: ocupa su categoría durante los años que dure.
///
/// Si esa categoría ya tenía algo firmado, lo sustituye. La pantalla solo
/// lo permite con lo que hayas firmado en esa misma pretemporada — un
/// contrato heredado del año pasado sale con candado y no llega aquí — pero
/// el repositorio no lo impone: quien manda sobre eso es quien enseña las
/// tarjetas.
Future<void> firmarPatrocinio(AppDatabase db, OfertaDePatrocinio oferta) async {
  // Se borra primero y no con insertOnConflictUpdate: el conflicto que
  // importa es sobre `categoria` (única por fila), pero drift genera el
  // upsert sobre la clave primaria `id` — con `id` autoincremental esa
  // fila siempre es nueva, así que el upsert nunca detecta el duplicado y
  // la restricción UNIQUE de la tabla salta como un error de verdad en
  // vez de actualizar.
  await _borrarCategoria(db, oferta.categoria);
  await db.into(db.patrociniosActivos).insert(
        PatrociniosActivosCompanion.insert(
          categoria: oferta.categoria,
          clave: Value(oferta.patrocinador.clave),
          bonusAnual: Value(oferta.bonusAnual),
          aniosRestantes: Value(oferta.anios),
        ),
      );
}

/// Deja libre [categoria]. Para desmarcar algo que acabas de firmar en esta
/// misma pretemporada; un contrato en marcha no se rompe desde la UI.
Future<void> romperPatrocinio(AppDatabase db, String categoria) =>
    _borrarCategoria(db, categoria);

Future<void> _borrarCategoria(AppDatabase db, String categoria) =>
    (db.delete(db.patrociniosActivos)
          ..where((t) => t.categoria.equals(categoria)))
        .go();

/// El margen de tope salarial que dan tus patrocinios firmados esta
/// temporada. Lo suma [espacioSalarial], igual que el margen de los
/// eventos narrativos — son dos fuentes de dinero distintas que se
/// acumulan, no se pisan.
///
/// Sale de lo que se guardó al firmar, no del catálogo de hoy: un contrato
/// de cuatro años paga lo que prometió el día que se firmó aunque las
/// ofertas de este verano sean otras.
Future<int> bonusSalarialDePatrocinadores(AppDatabase db) async {
  final contratos = await leerContratosDePatrocinio(db);
  var total = 0;
  for (final contrato in contratos.values) {
    total += contrato.bonusAnual;
  }
  return total;
}

/// Descuenta un año a todos los contratos y borra los que se acaban.
///
/// Se llama al CERRAR la temporada, antes de que la pantalla de
/// patrocinadores enseñe las ofertas del año nuevo: lo que sobreviva a esto
/// es lo que sale con candado, y las categorías que queden libres son las
/// que se pueden firmar.
///
/// Sustituye al `limpiarPatrocinios` de antes, que borraba todo cada año
/// porque entonces ningún patrocinio duraba más de una temporada.
Future<void> caducarPatrocinios(AppDatabase db) async {
  final filas = await db.select(db.patrociniosActivos).get();
  for (final fila in filas) {
    final quedan = _contratoDeFila(fila).aniosRestantes - 1;
    if (quedan <= 0) {
      await (db.delete(db.patrociniosActivos)
            ..where((t) => t.id.equals(fila.id)))
          .go();
    } else {
      await (db.update(db.patrociniosActivos)
            ..where((t) => t.id.equals(fila.id)))
          .write(PatrociniosActivosCompanion(aniosRestantes: Value(quedan)));
    }
  }
}

/// Borra todos los patrocinios, caduquen o no. Es para empezar de cero
/// —franquicia nueva—, no para el paso de un año al siguiente: eso es
/// [caducarPatrocinios].
Future<void> limpiarPatrocinios(AppDatabase db) async {
  await db.delete(db.patrociniosActivos).go();
}

/// La clave con la que se guardan los compromisos en `EfectosDeEvento`.
/// Comparte tabla con los eventos narrativos a propósito (ver
/// [CompromisoDePatrocinio]), y esta clave es lo que permite distinguirlos
/// para volver a calcularlos sin tocar los de los eventos.
const claveDeCompromisoDePatrocinio = 'patrocinio';

/// Deja en el vestuario lo que piden los patrocinios firmados.
///
/// Se llama al confirmar la pantalla de patrocinadores, y es idempotente:
/// borra primero los compromisos que hubiera puesto una confirmación
/// anterior. Sin eso, volver a entrar en la pantalla iría acumulando
/// compromisos encima de los de antes.
///
/// Los contratos heredados de años anteriores también cuentan: **lo que
/// pide un patrocinador se paga todos los años que dure**, no solo el que
/// se firma. Es la otra cara de atarse a cuatro años.
///
/// Solo toca las filas con [claveDeCompromisoDePatrocinio]: una bronca de
/// vestuario que estuviera corriendo no se ve afectada.
Future<void> aplicarCompromisosDePatrocinio(AppDatabase db) async {
  await (db.delete(db.efectosDeEvento)
        ..where((t) => t.clave.equals(claveDeCompromisoDePatrocinio)))
      .go();

  final contratos = await leerContratosDePatrocinio(db);
  for (final contrato in contratos.values) {
    final compromiso = contrato.compromiso;
    if (compromiso == null) continue;
    // Por el mismo camino que un efecto de evento: acotado a los topes
    // medidos, para que un compromiso nuevo no pueda valer más que todo el
    // sistema de entrenadores junto.
    final efecto = EfectoDeEvento(
      clave: compromiso.clave,
      factor: compromiso.factor,
      partidos: compromiso.partidos,
    ).acotado;
    await db.into(db.efectosDeEvento).insert(EfectosDeEventoCompanion.insert(
          clave: claveDeCompromisoDePatrocinio,
          claveEfecto: Value(efecto.clave),
          etiqueta:
              const EventosEs().etiquetaDeEfecto(efecto.clave) ?? efecto.clave,
          factor: efecto.factor,
          partidosRestantes: efecto.partidos,
        ));
  }
}
