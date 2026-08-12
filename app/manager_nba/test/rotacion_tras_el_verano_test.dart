import 'dart:math';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/database/app_database.dart';
import 'package:manager_nba/data/importer/jugadores_importer.dart';
import 'package:manager_nba/domain/equipos_especiales.dart';
import 'package:manager_nba/domain/franquicia_repository.dart';
import 'package:manager_nba/domain/nueva_temporada_repository.dart';
import 'package:manager_nba/domain/posiciones.dart';
import 'package:manager_nba/domain/slots_repository.dart';

/// Tras el verano, tu rotación tiene que estar hecha con la plantilla que de
/// verdad vas a tener, fichajes incluidos.
///
/// El bug que esto vigila: la rotación se regeneraba dentro de
/// `finalizarPretemporada`, que corre ANTES de que se abra la ventana de
/// agencia libre. O sea, se hacía con la plantilla en su peor momento —ya
/// sin los retirados ni los contratos vencidos, y todavía sin ningún
/// fichaje—, así que todo lo que firmases después se quedaba fuera de los
/// diez de la rotación. Mientras tanto los 29 equipos de la CPU se
/// realinean con lo mejor que tengan en CADA partido, así que la desventaja
/// era solo para ti y crecía cada verano.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('un fichaje del verano entra en la rotación, no se queda fuera',
      () async {
    almacenDeSlots = AlmacenDeSlotsEnMemoria();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await importarJugadoresSiHaceFalta(db);
    await crearFranquicia(db, 'MIN');

    final cierre = await cerrarTemporada(db, random: Random(5));
    await finalizarPretemporada(db, cierre, const [], random: Random(5));

    // Fichas a la mejor estrella que haya en el mercado, que es justo lo que
    // hace el jugador en la pantalla de agencia libre.
    final libres = await (db.select(db.jugadores)
          ..where((t) =>
              t.equipo.equals(equipoAgenciaLibre) & t.retirado.equals(false)))
        .get();
    expect(libres, isNotEmpty);
    final fichaje = (libres..sort((a, b) => b.media.compareTo(a.media))).first;
    await (db.update(db.jugadores)..where((t) => t.id.equals(fichaje.id)))
        .write(const JugadoresCompanion(equipo: Value('MIN')));

    await cerrarVentanaDeAgenciaLibre(db,
        equipoUsuario: 'MIN',
        temporadaCerrada: cierre.temporadaCerrada,
        claseDelDraft: cierre.anioDraft,
        random: Random(5));

    final plantilla = await (db.select(db.jugadores)
          ..where((t) => t.equipo.equals('MIN')))
        .get();
    final rotacion = await leerRotacion(db);
    expect(rotacionEstaCompleta(rotacion), isTrue);
    final enRotacion = rotacion.map((f) => f.jugadorId).toSet();

    // Nadie que se haya quedado fuera puede rendir más que alguien de
    // dentro en su mismo puesto. Es la comprobación de fondo: da igual por
    // qué camino llegue el jugador —fichaje, traspaso, draft—, si es de los
    // diez mejores tiene que jugar.
    final porId = {for (final j in plantilla) j.id: j};
    for (final fila in rotacion) {
      final dentro = porId[fila.jugadorId];
      if (dentro == null) continue;
      final rindeDentro =
          dentro.media * factorDePuesto(dentro, fila.posicion);
      for (final fuera in plantilla) {
        if (enRotacion.contains(fuera.id)) continue;
        final rindeFuera =
            fuera.media * factorDePuesto(fuera, fila.posicion);

        // El margen es el desempate por comodidad: con estos factores dos
        // candidatos muy distintos quedan a un pelo (aquí, 69,30 contra
        // 69,12) y en un empate técnico juega quien está en su puesto. Lo
        // que este test sigue vigilando es lo que importa: que no se quede
        // fuera nadie que rinda BASTANTE más.
        expect(rindeFuera,
            lessThanOrEqualTo(rindeDentro + margenDeComodidadAlRepartir),
            reason: '${fuera.nombreFicticio} (media ${fuera.media}) se queda '
                'fuera de la rotación mientras ${dentro.nombreFicticio} '
                '(media ${dentro.media}) juega de ${fila.posicion}');
      }
    }

    // Y el fichaje estrella, en concreto, tiene que estar dentro.
    expect(enRotacion, contains(fichaje.id),
        reason: 'has fichado a ${fichaje.nombreFicticio} (media '
            '${fichaje.media}) y no está en la rotación');

    await db.close();
  });
}
