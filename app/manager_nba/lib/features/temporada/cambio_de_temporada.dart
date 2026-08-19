import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/draft_repository.dart';
import '../../domain/nueva_temporada_repository.dart';
import '../../domain/entrenadores_repository.dart';
import '../mercado/agencia_libre_screen.dart';
import '../mercado/entrenador_screen.dart';
import '../mercado/renovaciones_screen.dart';
import 'camisetas_nuevas_screen.dart';
import 'draft_screen.dart';
import 'hall_fama_screen.dart';
import 'pretemporada_screen.dart';
import 'retirados_screen.dart';

/// Cierra el año y arranca el siguiente: envejecimiento, retiradas, Hall of
/// Fame, renovaciones, draft, agencia libre y resumen de pretemporada, cada
/// paso en su pantalla y en ese orden.
///
/// Vive aquí y no dentro del Calendario porque se puede lanzar desde dos
/// sitios: el panel de playoffs del calendario y el bracket, que es donde
/// estás cuando ganas el anillo y quieres seguir tirando de hilo sin volver
/// atrás.
///
/// Devuelve true si el cambio se completó (siempre, salvo que el contexto
/// muera por el camino), para que quien llame recargue lo suyo.
Future<bool> ejecutarCambioDeTemporada(
  BuildContext context,
  AppDatabase db,
  String equipoUsuario,
) async {
  // Cierre de año por pasos: envejecer y retiradas, luego el draft (que
  // lo juegas tú), y solo al final se genera la temporada nueva.
  final cierre = await cerrarTemporada(db);
  if (!context.mounted) return false;

  // 1) Quién se retira (y si le retiras la camiseta).
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (context) => RetiradosScreen(
      db: db,
      equipoUsuario: equipoUsuario,
      cierre: cierre,
      onContinuar: () => Navigator.of(context).pop(),
    ),
  ));
  if (!context.mounted) return false;

  // 2) Quién entra en el Hall of Fame: solo los nuevos, no la lista entera.
  if (cierre.nuevosEnHallDeLaFama.isNotEmpty) {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => NuevosEnHallDeLaFamaScreen(
        db: db,
        nuevos: cierre.nuevosEnHallDeLaFama,
        onContinuar: () => Navigator.of(context).pop(),
      ),
    ));
    if (!context.mounted) return false;
  }

  // 2b) Y qué camisetas ha colgado la liga este verano. Mismo trato que el
  // Hall of Fame: es un honor que pasaba en silencio y solo se descubría
  // meses después, entrando en Legado por tu cuenta.
  if (cierre.nuevasCamisetasRetiradas.isNotEmpty) {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => CamisetasNuevasScreen(
        nuevas: cierre.nuevasCamisetasRetiradas,
        onContinuar: () => Navigator.of(context).pop(),
      ),
    ));
    if (!context.mounted) return false;
  }

  // 3) Renovaciones de los contratos que se acaban.
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (context) => RenovacionesScreen(
      db: db,
      equipoUsuario: equipoUsuario,
      onContinuar: () => Navigator.of(context).pop(),
    ),
  ));
  if (!context.mounted) return false;

  // 4) El draft.
  final rookies = await Navigator.of(context).push<List<RookieElegido>>(
        MaterialPageRoute(
          builder: (context) =>
              DraftScreen(db: db, equipoUsuario: equipoUsuario),
        ),
      ) ??
      const <RookieElegido>[];
  if (!context.mounted) return false;

  final resumen = await finalizarPretemporada(db, cierre, rookies);
  if (!context.mounted) return false;

  // 4.5) El banquillo, ANTES que la agencia libre de jugadores. Si tu
  // entrenador se retiró o se le acabó el contrato, lo primero que hay que
  // resolver es quién dirige: sin entrenador no se juega, igual que no se
  // juega con doce jugadores. Y va primero porque el sueldo del entrenador
  // sale de la misma masa salarial que los fichajes — saber lo que te
  // cuesta el banquillo antes de repartir el resto es el orden que tiene
  // sentido.
  final sinEntrenador = await leerEntrenadorDe(db, equipoUsuario) == null;
  if (!context.mounted) return false;
  if (sinEntrenador) {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => EntrenadorScreen(
        db: db,
        equipoUsuario: equipoUsuario,
        onContinuar: () => Navigator.of(context).pop(),
      ),
    ));
    if (!context.mounted) return false;
  }

  // 5) Agencia libre: obligatorio dejar la plantilla lista para jugar. Es
  // TU ventana de mercado: hasta que no sales de aquí, los otros 29 no
  // pueden llevarse a los agentes libres de nivel.
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (context) => AgenciaLibreScreen(
      db: db,
      equipoUsuario: equipoUsuario,
      onContinuar: () => Navigator.of(context).pop(),
    ),
  ));
  await cerrarVentanaDeAgenciaLibre(db,
      equipoUsuario: equipoUsuario,
      temporadaCerrada: cierre.temporadaCerrada,
      claseDelDraft: cierre.anioDraft);
  if (!context.mounted) return false;

  // 6) Cómo queda tu plantilla de cara al año nuevo.
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (context) => PretemporadaScreen(
      resumen: resumen,
      equipoUsuario: equipoUsuario,
      onContinuar: () => Navigator.of(context).pop(),
    ),
  ));
  return context.mounted;
}
