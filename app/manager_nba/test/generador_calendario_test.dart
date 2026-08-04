import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:manager_nba/data/calendario/generador_calendario.dart';
import 'package:manager_nba/domain/tipo_evento_temporada.dart';

void main() {
  const equipos = [
    'ATL', 'BOS', 'BRK', 'CHI', 'CHO', 'CLE', 'DAL', 'DEN', 'DET', 'GSW',
    'HOU', 'IND', 'LAC', 'LAL', 'MEM', 'MIA', 'MIL', 'MIN', 'NOP', 'NYK',
    'OKC', 'ORL', 'PHI', 'PHO', 'POR', 'SAC', 'SAS', 'TOR', 'UTA', 'WAS',
    'FA',
  ];
  const equiposReales = 30; // equipos - 'FA'

  group('generarCalendarioEquipo', () {
    test('genera 82 partidos por defecto, todos con el mismo dueño', () {
      final partidos = generarCalendarioEquipo(
        equipo: 'DEN',
        rivalesPosibles: equipos.where((e) => e != 'DEN' && e != 'FA').toList(),
        fechaInicio: DateTime(2026, 10, 21),
        numPartidos: numPartidosTemporada,
        random: Random(1),
      );

      expect(partidos.length, 82);
      for (final p in partidos) {
        expect(p.equipoPropietario.value, 'DEN');
        expect(p.rival.value, isNot('DEN'));
      }
    });

    test('no repite rival mientras numPartidos <= rivales disponibles', () {
      final partidos = generarCalendarioEquipo(
        equipo: 'DEN',
        rivalesPosibles: equipos.where((e) => e != 'DEN' && e != 'FA').toList(),
        fechaInicio: DateTime(2026, 10, 21),
        numPartidos: 20,
        random: Random(1),
      );

      final rivales = partidos.map((p) => p.rival.value).toList();
      expect(rivales.toSet().length, rivales.length);
    });

    test('las fechas son estrictamente crecientes', () {
      final partidos = generarCalendarioEquipo(
        equipo: 'DEN',
        rivalesPosibles: equipos.where((e) => e != 'DEN' && e != 'FA').toList(),
        fechaInicio: DateTime(2026, 10, 21),
        numPartidos: numPartidosTemporada,
        random: Random(1),
      );

      for (var i = 1; i < partidos.length; i++) {
        expect(
          partidos[i].fecha.value.isAfter(partidos[i - 1].fecha.value),
          isTrue,
        );
      }
    });

    test('sin rivalesDeGrupo, ningún partido se marca como torneo', () {
      final partidos = generarCalendarioEquipo(
        equipo: 'DEN',
        rivalesPosibles: equipos.where((e) => e != 'DEN' && e != 'FA').toList(),
        fechaInicio: DateTime(2026, 10, 21),
        numPartidos: numPartidosTemporada,
        random: Random(1),
      );

      expect(partidos.where((p) => p.esTorneoTemporada.value), isEmpty);
    });

    test('con rivalesDeGrupo, marca exactamente esos 4 rivales como torneo '
        '(2 en casa, 2 fuera), dentro de la ventana de la NBA Cup', () {
      const rivalesDeGrupo = ['BOS', 'MIA', 'CHI', 'ATL'];
      final partidos = generarCalendarioEquipo(
        equipo: 'DEN',
        rivalesPosibles: equipos.where((e) => e != 'DEN' && e != 'FA').toList(),
        fechaInicio: DateTime(2026, 10, 21),
        numPartidos: numPartidosTemporada,
        random: Random(1),
        rivalesDeGrupo: rivalesDeGrupo,
      );

      final deTorneo = partidos.where((p) => p.esTorneoTemporada.value).toList();
      expect(deTorneo.length, 4);
      expect(deTorneo.map((p) => p.rival.value).toSet(), rivalesDeGrupo.toSet());
      expect(deTorneo.where((p) => p.esLocal.value).length, 2);
      expect(deTorneo.where((p) => !p.esLocal.value).length, 2);

      final inicioTorneo = DateTime(2026, 11, 1);
      final finTorneo = DateTime(2026, 12, 17);
      for (final p in deTorneo) {
        expect(p.fecha.value.isBefore(inicioTorneo), isFalse);
        expect(p.fecha.value.isAfter(finTorneo), isFalse);
      }
    });
  });

  group('generarEventosTemporada', () {
    test('genera 3 eventos dentro del rango de temporada', () {
      final fechaInicio = DateTime(2026, 10, 21);
      final eventos = generarEventosTemporada(
        fechaInicio: fechaInicio,
        numPartidos: numPartidosTemporada,
      );

      expect(eventos.length, 3);
      final tipos = eventos.map((e) => e.tipo.value).toSet();
      expect(tipos, {
        TipoEventoTemporada.finAgenciaLibre.name,
        TipoEventoTemporada.fechaLimiteTraspasos.name,
        TipoEventoTemporada.allStar.name,
      });

      final ultimaFecha = fechaInicio
          .add(Duration(days: (numPartidosTemporada - 1) * 2));
      for (final evento in eventos) {
        expect(evento.fecha.value.isBefore(ultimaFecha), isTrue);
        expect(evento.fecha.value.difference(fechaInicio).inDays.isOdd, isTrue);
      }
    });

    test('el cierre del mercado de agentes libres cae a primeros de marzo, '
        'no a los pocos días de empezar', () {
      // Estaba puesto a fechaInicio + 9 días. Mientras solo servía para
      // sacar un aviso pasaba desapercibido, pero en cuanto empezó a
      // cerrar el mercado de verdad (ver haPasadoFechaLimite) dejaba la
      // agencia libre inservible desde octubre.
      final fechaInicio = DateTime(2026, 10, 21);
      final eventos = generarEventosTemporada(
        fechaInicio: fechaInicio,
        numPartidos: numPartidosTemporada,
      );

      final cierre = eventos
          .firstWhere(
              (e) => e.tipo.value == TipoEventoTemporada.finAgenciaLibre.name)
          .fecha
          .value;
      expect(cierre.year, 2027);
      expect(cierre.month, 3);
      expect(cierre.day, lessThanOrEqualTo(3),
          reason: 'el 1 de marzo, o el día siguiente libre de partido');
      expect(cierre.difference(fechaInicio).inDays, greaterThan(120),
          reason: 'con casi toda la temporada por delante para fichar');
    });

    test('All-Star cae en sábado y la fecha límite de traspasos en jueves, '
        'ambos en febrero del año siguiente', () {
      final fechaInicio = DateTime(2026, 10, 21);
      final eventos = generarEventosTemporada(
        fechaInicio: fechaInicio,
        numPartidos: numPartidosTemporada,
      );

      final allStar = eventos
          .firstWhere((e) => e.tipo.value == TipoEventoTemporada.allStar.name);
      final tradeDeadline = eventos.firstWhere(
          (e) => e.tipo.value == TipoEventoTemporada.fechaLimiteTraspasos.name);

      expect(allStar.fecha.value.month, 2);
      expect(allStar.fecha.value.year, 2027);
      // Puede haberse desplazado 1 día si coincidía con un partido.
      expect(
        {DateTime.saturday, DateTime.sunday}.contains(allStar.fecha.value.weekday),
        isTrue,
      );

      expect(tradeDeadline.fecha.value.month, 2);
      expect(tradeDeadline.fecha.value.year, 2027);
      expect(
        {DateTime.thursday, DateTime.friday}
            .contains(tradeDeadline.fecha.value.weekday),
        isTrue,
      );
    });
  });

  group('proximoInicioDeTemporada', () {
    test('siempre cae un 22 de octubre, hoy o en el futuro', () {
      final fecha = proximoInicioDeTemporada();
      expect(fecha.month, 10);
      expect(fecha.day, 22);
      expect(fecha.isBefore(DateTime.now().subtract(const Duration(days: 1))),
          isFalse);
    });
  });

  group('generarCalendarioLiga', () {
    test('genera 82 partidos para cada uno de los 30 equipos', () {
      final calendario = generarCalendarioLiga(
        equipoUsuario: 'DEN',
        equiposDisponibles: equipos,
        fechaInicio: DateTime(2026, 10, 21),
        random: Random(1),
      );

      expect(calendario.partidos.length, equiposReales * 82);
      final porEquipo = <String, int>{};
      for (final p in calendario.partidos) {
        porEquipo.update(p.equipoPropietario.value, (v) => v + 1,
            ifAbsent: () => 1);
      }
      expect(porEquipo.length, equiposReales);
      expect(porEquipo.values.every((v) => v == 82), isTrue);
    });

    test('lanza si el equipo del usuario no está en la lista', () {
      expect(
        () => generarCalendarioLiga(
          equipoUsuario: 'ZZZ',
          equiposDisponibles: equipos,
          fechaInicio: DateTime(2026, 10, 21),
        ),
        throwsArgumentError,
      );
    });
  });
}
