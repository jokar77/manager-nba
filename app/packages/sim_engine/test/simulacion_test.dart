import 'package:sim_engine/sim_engine.dart';
import 'package:test/test.dart';

Jugador _jugador({
  required String id,
  int atrAtaque = 70,
  int atrDefensa = 70,
  int atrTiro3 = 70,
  int media = 70,
  double ptsPg = 12,
  double astPg = 3,
  double trbPg = 5,
  double factorLongevidad = 1.0,
}) {
  return Jugador(
    id: id,
    nombreFicticio: 'Jugador $id',
    posicion: 'SF',
    equipo: 'TST',
    edad: 25,
    atrAtaque: atrAtaque,
    atrDefensa: atrDefensa,
    atrTiro3: atrTiro3,
    media: media,
    potencial: media,
    ptsPg: ptsPg,
    astPg: astPg,
    trbPg: trbPg,
    factorLongevidad: factorLongevidad,
  );
}

/// Construye un equipo de 5 jugadores con 48 minutos cada uno (suma 240),
/// todos con los mismos atributos salvo que se indique lo contrario.
EquipoPartido _equipoUniforme(
  String nombre, {
  int atrAtaque = 70,
  int atrDefensa = 70,
  int atrTiro3 = 70,
  double ptsPg = 12,
  double astPg = 3,
  double trbPg = 5,
  String? idEstrellaAtaque,
  EntrenadorEnPartido? entrenador,
}) {
  final jugadores = List.generate(5, (i) {
    final id = '$nombre-$i';
    return JugadorEnPartido(
      jugador: _jugador(
        id: id,
        atrAtaque: atrAtaque,
        atrDefensa: atrDefensa,
        atrTiro3: atrTiro3,
        ptsPg: ptsPg,
        astPg: astPg,
        trbPg: trbPg,
      ),
      minutos: 48,
      esEstrellaAtaque: id == idEstrellaAtaque,
    );
  });
  return EquipoPartido(
      nombre: nombre, jugadores: jugadores, entrenador: entrenador);
}

/// Victorias de 82 de [propio] contra [rival], con las mismas plantillas y
/// las mismas semillas: lo único que cambia entre dos llamadas es lo que se
/// le pase de entrenador.
double _victoriasDe82({
  EntrenadorEnPartido? propio,
  EntrenadorEnPartido? rival,
  int partidos = 6000,
}) {
  var ganados = 0;
  for (var seed = 0; seed < partidos; seed++) {
    final boxscore = simularPartido(
      local: _equipoUniforme('A', entrenador: propio),
      visitante: _equipoUniforme('B', entrenador: rival),
      seed: seed,
    );
    if (boxscore.marcadorLocal > boxscore.marcadorVisitante) ganados++;
  }
  return ganados / partidos * 82;
}

void main() {
  group('EquipoPartido', () {
    test('rechaza una plantilla cuyos minutos no suman 240', () {
      expect(
        () => EquipoPartido(nombre: 'Bad', jugadores: [
          JugadorEnPartido(jugador: _jugador(id: 'a'), minutos: 48),
          JugadorEnPartido(jugador: _jugador(id: 'b'), minutos: 40),
        ]),
        throwsArgumentError,
      );
    });

    test('rechaza más de una estrella de ataque', () {
      expect(
        () => EquipoPartido(nombre: 'Bad', jugadores: [
          JugadorEnPartido(
              jugador: _jugador(id: 'a'), minutos: 48, esEstrellaAtaque: true),
          JugadorEnPartido(
              jugador: _jugador(id: 'b'), minutos: 48, esEstrellaAtaque: true),
          JugadorEnPartido(jugador: _jugador(id: 'c'), minutos: 48),
          JugadorEnPartido(jugador: _jugador(id: 'd'), minutos: 48),
          JugadorEnPartido(jugador: _jugador(id: 'e'), minutos: 48),
        ]),
        throwsArgumentError,
      );
    });
  });

  group('simularPartido', () {
    test('es determinista con la misma seed', () {
      final local = _equipoUniforme('Local');
      final visitante = _equipoUniforme('Visitante');

      final boxscore1 =
          simularPartido(local: local, visitante: visitante, seed: 42);
      final boxscore2 =
          simularPartido(local: local, visitante: visitante, seed: 42);

      expect(boxscore1.marcadorLocal, boxscore2.marcadorLocal);
      expect(boxscore1.marcadorVisitante, boxscore2.marcadorVisitante);
      expect(
        boxscore1.statsLocal.map((s) => s.puntos).toList(),
        boxscore2.statsLocal.map((s) => s.puntos).toList(),
      );
    });

    test('los puntos de los jugadores de cada equipo suman el marcador', () {
      final local = _equipoUniforme('Local');
      final visitante = _equipoUniforme('Visitante');

      for (var seed = 0; seed < 20; seed++) {
        final boxscore =
            simularPartido(local: local, visitante: visitante, seed: seed);

        final sumaLocal =
            boxscore.statsLocal.fold<int>(0, (a, s) => a + s.puntos);
        final sumaVisitante =
            boxscore.statsVisitante.fold<int>(0, (a, s) => a + s.puntos);

        expect(sumaLocal, boxscore.marcadorLocal);
        expect(sumaVisitante, boxscore.marcadorVisitante);
      }
    });

    test('los parciales de cada cuarto suman el marcador final, y son '
        'siempre valores no negativos (4 cuartos, más una prórroga por '
        'cada una que haga falta)', () {
      final local = _equipoUniforme('Local');
      final visitante = _equipoUniforme('Visitante');

      for (var seed = 0; seed < 20; seed++) {
        final boxscore =
            simularPartido(local: local, visitante: visitante, seed: seed);

        // Al menos los 4 cuartos; si el partido se ha ido a la prórroga
        // (dos equipos iguales, es cuestión de suerte con cada seed) hay
        // periodos de más, pero siempre los mismos en los dos marcadores.
        expect(boxscore.parcialesLocal.length, greaterThanOrEqualTo(4));
        expect(boxscore.parcialesLocal.length, boxscore.parcialesVisitante.length);
        expect(boxscore.parcialesLocal.every((c) => c >= 0), isTrue);
        expect(boxscore.parcialesVisitante.every((c) => c >= 0), isTrue);
        expect(boxscore.parcialesLocal.reduce((a, b) => a + b),
            boxscore.marcadorLocal);
        expect(boxscore.parcialesVisitante.reduce((a, b) => a + b),
            boxscore.marcadorVisitante);
      }
    });

    test('nunca hay empates: si acaso, se juegan prórrogas y siguen '
        'sumando periodos hasta desempatar', () {
      final local = _equipoUniforme('Local');
      final visitante = _equipoUniforme('Visitante');

      for (var seed = 0; seed < 300; seed++) {
        final boxscore =
            simularPartido(local: local, visitante: visitante, seed: seed);

        expect(boxscore.marcadorLocal, isNot(boxscore.marcadorVisitante));
        expect(boxscore.parcialesLocal.length,
            boxscore.parcialesVisitante.length);
        expect(boxscore.parcialesLocal.length, greaterThanOrEqualTo(4));
        expect(boxscore.parcialesLocal.reduce((a, b) => a + b),
            boxscore.marcadorLocal);
        expect(boxscore.parcialesVisitante.reduce((a, b) => a + b),
            boxscore.marcadorVisitante);
      }
    });

    test('llegar a una segunda prórroga (dos empates seguidos) es raro: '
        'sucede muy por debajo de la mitad de las veces que hay prórroga',
        () {
      final local = _equipoUniforme('Local');
      final visitante = _equipoUniforme('Visitante');

      var conProrroga = 0;
      var conSegundaProrroga = 0;
      for (var seed = 0; seed < 2000; seed++) {
        final boxscore =
            simularPartido(local: local, visitante: visitante, seed: seed);
        final numProrrogas = boxscore.parcialesLocal.length - 4;
        if (numProrrogas >= 1) conProrroga++;
        if (numProrrogas >= 2) conSegundaProrroga++;
      }

      expect(conProrroga, greaterThan(0)); // el equipo uniforme sí debe
      // llegar a empatar en los 4 cuartos alguna vez, para que el test
      // tenga sentido.
      expect(conSegundaProrroga / conProrroga, lessThan(0.3));
    });

    test('un equipo con mejor ataque anota más de media que uno peor '
        'contra la misma defensa rival', () {
      final rival = _equipoUniforme('Rival', atrDefensa: 70);
      final equipoFuerte =
          _equipoUniforme('Fuerte', atrAtaque: 95, atrTiro3: 90, ptsPg: 25);
      final equipoDebil =
          _equipoUniforme('Debil', atrAtaque: 45, atrTiro3: 40, ptsPg: 6);

      const nMuestras = 60;
      var totalFuerte = 0;
      var totalDebil = 0;
      for (var seed = 0; seed < nMuestras; seed++) {
        totalFuerte += simularPartido(
                local: equipoFuerte, visitante: rival, seed: seed)
            .marcadorLocal;
        totalDebil += simularPartido(
                local: equipoDebil, visitante: rival, seed: seed)
            .marcadorLocal;
      }

      final mediaFuerte = totalFuerte / nMuestras;
      final mediaDebil = totalDebil / nMuestras;
      expect(mediaFuerte, greaterThan(mediaDebil));
    });

    test('mejor defensa rival reduce los puntos anotados de media', () {
      final atacante = _equipoUniforme('Atacante', atrAtaque: 80, ptsPg: 18);
      final defensaFuerte = _equipoUniforme('DefFuerte', atrDefensa: 95);
      final defensaDebil = _equipoUniforme('DefDebil', atrDefensa: 45);

      const nMuestras = 60;
      var totalVsFuerte = 0;
      var totalVsDebil = 0;
      for (var seed = 0; seed < nMuestras; seed++) {
        totalVsFuerte += simularPartido(
                local: atacante, visitante: defensaFuerte, seed: seed)
            .marcadorLocal;
        totalVsDebil += simularPartido(
                local: atacante, visitante: defensaDebil, seed: seed)
            .marcadorLocal;
      }

      expect(totalVsFuerte / nMuestras, lessThan(totalVsDebil / nMuestras));
    });

    test('la estrella de ataque anota más de media que un compañero '
        'con los mismos atributos', () {
      final rival = _equipoUniforme('Rival');
      final local = _equipoUniforme('Local', idEstrellaAtaque: 'Local-0');

      // Ochocientos partidos y no ochenta, que es con los que empezó esto.
      // Al ensanchar la variación de anotación entre partidos
      // (`sigmaRuidoAnotacion`, ~7,5 puntos de desviación como en la NBA
      // real), ochenta muestras dejaron de bastar para que la ventaja de la
      // estrella asomara por encima del ruido: salió 22,63 contra 22,70 y
      // el test cayó sin que nada estuviera roto.
      //
      // La cuenta: con una desviación de ~7,5 puntos, el error típico de la
      // media con n muestras es 7,5/raíz(n). Con 80 son 0,84 puntos, del
      // tamaño del efecto que se quiere medir; con 800 son 0,27, así que la
      // ventaja se ve holgada.
      const nMuestras = 800;
      var totalEstrella = 0.0;
      var totalCompanero = 0.0;
      for (var seed = 0; seed < nMuestras; seed++) {
        final boxscore =
            simularPartido(local: local, visitante: rival, seed: seed);
        totalEstrella += boxscore.statsLocal
            .firstWhere((s) => s.jugadorId == 'Local-0')
            .puntos;
        totalCompanero += boxscore.statsLocal
            .firstWhere((s) => s.jugadorId == 'Local-1')
            .puntos;
      }

      final estrella = totalEstrella / nMuestras;
      final companero = totalCompanero / nMuestras;
      expect(estrella, greaterThan(companero),
          reason: 'la estrella promedia ${estrella.toStringAsFixed(2)} y su '
              'compañero ${companero.toStringAsFixed(2)}');
    });

    test('un jugador que no juega (0 minutos) no aparece en el boxscore', () {
      final rival = _equipoUniforme('Rival');
      final jugadores = [
        JugadorEnPartido(jugador: _jugador(id: 'titular-0'), minutos: 48),
        JugadorEnPartido(jugador: _jugador(id: 'titular-1'), minutos: 48),
        JugadorEnPartido(jugador: _jugador(id: 'titular-2'), minutos: 48),
        JugadorEnPartido(jugador: _jugador(id: 'titular-3'), minutos: 48),
        JugadorEnPartido(jugador: _jugador(id: 'titular-4'), minutos: 48),
        JugadorEnPartido(jugador: _jugador(id: 'suplente-0'), minutos: 0),
      ];
      final local = EquipoPartido(nombre: 'Local', jugadores: jugadores);

      final boxscore =
          simularPartido(local: local, visitante: rival, seed: 1);

      expect(
        boxscore.statsLocal.any((s) => s.jugadorId == 'suplente-0'),
        isFalse,
      );
      expect(boxscore.statsLocal.length, 5);
    });

    test('el estado de forma mueve la producción de un jugador: en un año '
        'grande anota más que el mismo jugador en un año flojo', () {
      final rival = _equipoUniforme('Rival');

      EquipoPartido equipoConForma(double forma) {
        final jugadores = List.generate(5, (i) {
          final id = 'Local-$i';
          return JugadorEnPartido(
            jugador: _jugador(id: id, ptsPg: 20),
            minutos: 48,
            factorForma: i == 0 ? forma : 1.0,
          );
        });
        return EquipoPartido(nombre: 'Local', jugadores: jugadores);
      }

      final enRacha = equipoConForma(1.22);
      final enBaja = equipoConForma(0.78);

      const nMuestras = 60;
      var totalEnRacha = 0.0;
      var totalEnBaja = 0.0;
      for (var seed = 0; seed < nMuestras; seed++) {
        totalEnRacha +=
            simularPartido(local: enRacha, visitante: rival, seed: seed)
                .statsLocal
                .firstWhere((s) => s.jugadorId == 'Local-0')
                .puntos;
        totalEnBaja +=
            simularPartido(local: enBaja, visitante: rival, seed: seed)
                .statsLocal
                .firstWhere((s) => s.jugadorId == 'Local-0')
                .puntos;
      }

      expect(totalEnBaja / nMuestras, lessThan(totalEnRacha / nMuestras));
    });

    test('un jugador penalizado por jugar fuera de posición rinde menos '
        'que el mismo jugador sin penalizar, en igualdad de minutos', () {
      final rival = _equipoUniforme('Rival');

      EquipoPartido equipoConPenalizacion(double penalizacion) {
        final jugadores = List.generate(5, (i) {
          final id = 'Local-$i';
          return JugadorEnPartido(
            jugador: _jugador(id: id, ptsPg: 20),
            minutos: 48,
            penalizacionFueraDePosicion: i == 0 ? penalizacion : 1.0,
          );
        });
        return EquipoPartido(nombre: 'Local', jugadores: jugadores);
      }

      final conPenalizacion = equipoConPenalizacion(0.8);
      final sinPenalizacion = equipoConPenalizacion(1.0);

      const nMuestras = 60;
      var totalConPenalizacion = 0.0;
      var totalSinPenalizacion = 0.0;
      for (var seed = 0; seed < nMuestras; seed++) {
        totalConPenalizacion += simularPartido(
                local: conPenalizacion, visitante: rival, seed: seed)
            .statsLocal
            .firstWhere((s) => s.jugadorId == 'Local-0')
            .puntos;
        totalSinPenalizacion += simularPartido(
                local: sinPenalizacion, visitante: rival, seed: seed)
            .statsLocal
            .firstWhere((s) => s.jugadorId == 'Local-0')
            .puntos;
      }

      expect(totalConPenalizacion / nMuestras,
          lessThan(totalSinPenalizacion / nMuestras));
    });

    test('un equipo con un jugador fuera de posición anota menos de media '
        'que el mismo equipo sin nadie fuera de posición', () {
      final rival = _equipoUniforme('Rival');

      EquipoPartido equipoConUnoFueraDePosicion(bool conPenalizacion) {
        final jugadores = List.generate(5, (i) {
          return JugadorEnPartido(
            jugador: _jugador(id: 'Local-$i', atrAtaque: 85, ptsPg: 20),
            minutos: 48,
            penalizacionFueraDePosicion:
                (conPenalizacion && i == 0) ? 0.75 : 1.0,
          );
        });
        return EquipoPartido(nombre: 'Local', jugadores: jugadores);
      }

      final conFueraDePosicion = equipoConUnoFueraDePosicion(true);
      final sinFueraDePosicion = equipoConUnoFueraDePosicion(false);

      const nMuestras = 60;
      var totalCon = 0;
      var totalSin = 0;
      for (var seed = 0; seed < nMuestras; seed++) {
        totalCon += simularPartido(
                local: conFueraDePosicion, visitante: rival, seed: seed)
            .marcadorLocal;
        totalSin += simularPartido(
                local: sinFueraDePosicion, visitante: rival, seed: seed)
            .marcadorLocal;
      }

      expect(totalCon / nMuestras, lessThan(totalSin / nMuestras));
    });

    test('hay partidos de anotación claramente baja, media y alta — no '
        'todos se parecen', () {
      final local = _equipoUniforme('Local');
      final visitante = _equipoUniforme('Visitante');

      final totales = [
        for (var seed = 0; seed < 300; seed++)
          _totalDePartido(local: local, visitante: visitante, seed: seed),
      ];

      // Con dos equipos de nivel medio (rating 70, esperado ~112 cada uno,
      // ~224 de total), antes del ritmo compartido por partido el total
      // apenas se movía de esa franja porque el ruido de cada equipo iba
      // por su cuenta y tendía a compensarse. Con el ritmo, tiene que
      // haber partidos de verdad por debajo de 200 (grinding defensivo) y
      // por encima de 250 (tiroteo), no solo variación de un par de
      // puntos alrededor de la media.
      expect(totales.where((t) => t < 200), isNotEmpty,
          reason: 'debería haber partidos de anotación claramente baja');
      expect(totales.where((t) => t > 250), isNotEmpty,
          reason: 'debería haber partidos de anotación claramente alta');
    });

    test('el ritmo es del partido, no de cada equipo por separado: en un '
        'partido de anotación alta suben los dos marcadores a la vez',
        () {
      final local = _equipoUniforme('Local');
      final visitante = _equipoUniforme('Visitante');

      final boxscores = [
        for (var seed = 0; seed < 200; seed++)
          simularPartido(local: local, visitante: visitante, seed: seed),
      ];
      final mediaLocal =
          boxscores.map((b) => b.marcadorLocal).reduce((a, b) => a + b) /
              boxscores.length;
      final mediaVisitante =
          boxscores.map((b) => b.marcadorVisitante).reduce((a, b) => a + b) /
              boxscores.length;

      // Correlación (signo) entre cuánto se desvía cada marcador de su
      // propia media: si el ritmo es compartido, cuando el local anota
      // por encima de su media, el visitante también tiende a hacerlo.
      // Con ruido totalmente independiente por equipo esto rondaría el
      // 50%; con un ritmo de partido compartido, tiene que notarse.
      final mismoSentido = boxscores.where((b) =>
          (b.marcadorLocal - mediaLocal).sign ==
          (b.marcadorVisitante - mediaVisitante).sign);

      expect(mismoSentido.length / boxscores.length, greaterThan(0.62));
    });
  });

  group('entrenador', () {
    // La escala está centrada en la media de la liga (76), así que un
    // entrenador del montón tiene que dar EXACTAMENTE lo mismo que no tener
    // ninguno. Si no fuera así, quedarse sin banquillo sería un castigo
    // automático y despedir a alguien no sería nunca una opción.
    test('uno del montón no cambia nada respecto a no tener entrenador', () {
      const medio = EntrenadorEnPartido(ataque: 76, defensa: 76);
      expect(aporteDelEntrenador(76), 0);
      expect(
        _victoriasDe82(propio: medio, rival: medio),
        _victoriasDe82(),
      );
    });

    test('uno bueno gana más partidos que uno malo con la misma plantilla',
        () {
      const medio = EntrenadorEnPartido(ataque: 76, defensa: 76);
      const bueno = EntrenadorEnPartido(ataque: 86, defensa: 93);
      const malo = EntrenadorEnPartido(ataque: 64, defensa: 60);

      final conBueno = _victoriasDe82(propio: bueno, rival: medio);
      final neutro = _victoriasDe82(propio: medio, rival: medio);
      final conMalo = _victoriasDe82(propio: malo, rival: medio);

      expect(conBueno, greaterThan(neutro));
      expect(neutro, greaterThan(conMalo));

      // Y el recorrido tiene que quedarse donde lo pone la NBA real: unas
      // 5-7 victorias del mejor banquillo al peor. Por debajo de 3 el
      // entrenador sería decorativo; por encima de 10, el juego dejaría de
      // ir de construir una plantilla.
      final recorrido = conBueno - conMalo;
      expect(recorrido, greaterThan(3.0));
      expect(recorrido, lessThan(10.0));
    });

    test('el aporte está acotado: un entrenador de 99 no rompe la escala', () {
      // Sin tope, un asset futuro con valores extremos podría convertir al
      // entrenador en el factor dominante del partido.
      expect(aporteDelEntrenador(99),
          lessThanOrEqualTo(PesosAtributos.maxAporteEntrenador *
              PesosAtributos.desvioMaximoEntrenador));
      expect(aporteDelEntrenador(1),
          greaterThanOrEqualTo(-PesosAtributos.maxAporteEntrenador *
              PesosAtributos.desvioMaximoEntrenador));
    });
  });
}

int _totalDePartido({
  required EquipoPartido local,
  required EquipoPartido visitante,
  required int seed,
}) {
  final boxscore = simularPartido(local: local, visitante: visitante, seed: seed);
  return boxscore.marcadorLocal + boxscore.marcadorVisitante;
}
