import 'dart:async';

import 'package:manager_nba/domain/slots_repository.dart';

/// Flutter llama a este fichero UNA vez por cada fichero de test, antes de
/// ejecutarlo. Aquí se deja el almacén de partidas en memoria para todos.
///
/// Sin esto hay una carrera entre ficheros de test que costó tres
/// "tests inestables" distintos antes de encontrarla:
///
/// `almacenDeSlots` vale por defecto [AlmacenDeSlotsEnDisco], que es lo
/// correcto para la app. Pero cualquier test que llegue a `registrarCampeon`
/// —o sea, cualquiera que simule unos playoffs— acaba llamando a
/// `abrirAjustes()`, y eso abre el fichero SQLite de verdad
/// (`manager_nba_ajustes.sqlite`). `flutter test` ejecuta varios ficheros de
/// test A LA VEZ en procesos distintos, así que dos ficheros cualesquiera
/// que simulen playoffs se ponían a escribir en el MISMO fichero al mismo
/// tiempo.
///
/// De ahí el síntoma que despistaba: el test pasaba ocho de ocho veces
/// ejecutado solo y caía en la tanda completa. No era aleatoriedad de la
/// simulación —eso también existe, y está documentado aparte—: era una
/// carrera por un fichero compartido.
///
/// Los ficheros que ya montan su propio [AlmacenDeSlotsEnMemoria] siguen
/// funcionando igual: lo sustituyen después de esto.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  almacenDeSlots = AlmacenDeSlotsEnMemoria();
  await testMain();
}
