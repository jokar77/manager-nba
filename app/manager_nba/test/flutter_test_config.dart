import 'dart:async';

import 'package:manager_nba/domain/slots_repository.dart';

/// Red de seguridad para toda la suite: sustituye el almacén de ranuras
/// (ficheros SQLite reales vía `path_provider`) por uno en memoria antes de
/// que se ejecute ningún test de este directorio.
///
/// Hace falta porque el registro compartido de campeones
/// (`campeones_repository.dart`) vive ahí, y se toca en cuanto se resuelve
/// un campeón de la NBA o de la NBA Cup — algo a lo que puede llegar
/// cualquier test que simule un tramo de temporada lo bastante largo, no
/// solo los que prueban playoffs o el torneo directamente. Sin esto,
/// `path_provider` revienta con un `MissingPluginException` fuera de una
/// app real.
///
/// Los tests que necesitan aislar el palmarés entre sí (uno por caso, no
/// compartido con el resto del archivo) siguen creando su propio
/// `AlmacenDeSlotsEnMemoria` en su `setUp`, que sencillamente sustituye a
/// este por la duración de ese test.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  almacenDeSlots = AlmacenDeSlotsEnMemoria();
  await testMain();
}
