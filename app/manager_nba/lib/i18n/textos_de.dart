part of 'textos.dart';

/// Deutsch. NBA-Begriffe, die auch die deutschsprachige Presse unübersetzt
/// benutzt (Playoffs, All-Star, NBA Cup, Trade), bleiben stehen — eine
/// Übersetzung würde fremder klingen als das Original.
class TextosDe extends Textos {
  const TextosDe();

  @override
  TextosDeEventos get eventos => const EventosDe();

  @override
  String get aceptar => 'Bestätigen';
  @override
  String get cancelar => 'Abbrechen';
  @override
  String get cerrar => 'Schließen';
  @override
  String get guardar => 'Speichern';
  @override
  String get continuar => 'Fortfahren';
  @override
  String get si => 'Ja';
  @override
  String get no => 'Nein';
  @override
  String get cargando => 'Wird geladen…';

  @override
  String get nuevaPartida => 'Neues Spiel';
  @override
  String get ajustes => 'Einstellungen';
  @override
  String get elegirEquipo => 'Wähle dein Team';
  @override
  String get sobrescribir => 'Überschreiben';
  @override
  String get ranuraOcupada => 'In diesem Speicherplatz liegt schon ein Spiel';
  @override
  String get avisoSobrescribir =>
      'Wenn du fortfährst, wird der hier gespeicherte Spielstand gelöscht.';

  @override
  String get modoOscuro => 'Dunkelmodus';
  @override
  String get modoOscuroDetalle => 'Grau- und Schwarztöne statt hellem Weiß';
  @override
  String get idioma => 'Sprache';
  @override
  String get idiomaDetalle => 'Die Sprache des ganzen Spiels';

  @override
  String get calendario => 'Spielplan';
  @override
  String get calendarioDetalle => 'Deine Saison ansehen und Spiele simulieren';
  @override
  String get tuEquipo => 'Dein Team';
  @override
  String get tuEquipoDetalle => 'Kader und Aufstellung';
  @override
  String get entrenador => 'Head Coach';
  @override
  String get banquilloVacante => 'Deine Bank ist unbesetzt';
  @override
  String get clasificacion => 'Tabelle';
  @override
  String get clasificacionDetalle => 'Teams und Statistikführende';
  @override
  String get mercado => 'Markt';
  @override
  String get traspasos => 'Trades';
  @override
  String get traspasosDetalle => 'Verhandle Tauschgeschäfte mit der Liga';
  @override
  String get ofertasRecibidas => 'Erhaltene Angebote';
  @override
  String get agenciaLibre => 'Free Agency';
  @override
  String get agenciaLibreDetalle => 'Vereinslose Spieler und Gehaltsspielraum';
  @override
  String get competicion => 'Wettbewerb';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Abstimmung, All-Star Game und MVP';
  @override
  String get resumenTemporada => 'Saisonübersicht';
  @override
  String get resumenTemporadaDetalle => 'Bilanz, alle Spiele und Durchschnitte';
  @override
  String get playoffs => 'Playoffs';
  @override
  String get premios => 'Auszeichnungen';
  @override
  String get legado => 'Vermächtnis';

  @override
  String get record => 'Bilanz';
  @override
  String get masaSalarial => 'Gehaltssumme';
  @override
  String get temporada => 'Saison';

  @override
  String get sinEntrenador => 'Kein Head Coach';
  @override
  String get sinEntrenadorDetalle =>
      'Dein Team spielt ohne Coach. Verpflichte jemanden aus der Liste unten.';
  @override
  String get despedir => 'Entlassen';
  @override
  String get contratar => 'Verpflichten';
  @override
  String get negociar => 'Verhandeln';
  @override
  String get ofrecer => 'Anbieten';
  @override
  String get sueldo => 'Gehalt';
  @override
  String get duracion => 'Laufzeit';
  @override
  String get ataque => 'Angriff';
  @override
  String get defensa => 'Verteidigung';
  @override
  String get desarrollo => 'Entwicklung';
  @override
  String get equilibrado => 'Ausgeglichen';
  @override
  String get especialistaAtaque => 'Angriffsspezialist';
  @override
  String get especialistaDefensa => 'Verteidigungsspezialist';
  @override
  String get formadorDeJovenes => 'Talentförderer';
  @override
  String get loQuePuedesOfrecer => 'Was du bieten kannst';
  @override
  String get topeDeLaFranquicia => 'Obergrenze der Franchise';
  @override
  String get finiquitos => 'Abfindungen entlassener Coaches';
  @override
  String get aceptariaLaOferta => 'Er würde dieses Angebot annehmen.';
  @override
  String get todaviaNo =>
      'Noch nicht. Mit mehr Geld oder mehr Jahren überlegt er es sich vielleicht.';
  @override
  String get noVaAAceptar =>
      'Er wird ablehnen: dein Projekt ist zu weit weg, und Geld ändert daran nichts.';

  @override
  String anios(int n) => n == 1 ? '1 Saison' : '$n Saisons';
  @override
  String alAnio(String importe) => '$importe pro Jahr';

  @override
  String get pestanaEquipos => 'Teams';
  @override
  String get pestanaJugadores => 'Spieler';
  @override
  String get conferenciaEste => 'Osten';
  @override
  String get conferenciaOeste => 'Westen';
  @override
  String get fronteraPlayIn => 'Play-In';
  @override
  String get fronteraFueraDePlayoffs => 'Außerhalb der Playoffs';
  @override
  String get ordenPuntos => 'Punkte';
  @override
  String get ordenAsistencias => 'Assists';
  @override
  String get ordenRebotes => 'Rebounds';
  @override
  String get sinPartidosJugados => 'Es wurde noch kein Spiel ausgetragen';
  @override
  String edadJugador(int n) => '$n Jahre';
  @override
  String mediaJugador(int n) => 'Gesamtwert $n';
  @override
  String get estaTemporada => 'Diese Saison';
  @override
  String get todaviaNoHaJugado => 'Hat noch nicht gespielt';
  @override
  String get contrato => 'Vertrag';
  @override
  String get intentarTraspasar => 'Transfer versuchen';
  @override
  String traspasoCerradoCon(String equipo) =>
      'Transfer mit $equipo abgeschlossen.';
  @override
  String get fechaLimiteTraspasosPasada =>
      'Die Transferfrist ist bereits abgelaufen: In dieser Saison können keine weiteren Transfers mehr abgeschlossen werden.';

  @override
  String get tituloConferenciaEste => 'OSTKONFERENZ';
  @override
  String get tituloConferenciaOeste => 'WESTKONFERENZ';

  @override
  String comoFicharA(String nombre) => 'Wie verpflichtet man $nombre?';
  @override
  String get sinConQueConvencerles =>
      'Du hast gerade nichts Überzeugendes anzubieten: Weder dein Kader noch deine Picks reichen aus, ohne dich zu schwächen.';

  @override
  String get campeonesDeLaNba => 'NBA-Meister';
  @override
  String get campeonesDeLaCup => 'NBA-Cup-Sieger';
  @override
  String get exclamacionCampeones => 'MEISTER!';
  @override
  String seLlevaElTitulo(String nombre) => '$nombre holt sich den Titel.';
  @override
  String get enhorabuenaAnillo =>
      "Glückwunsch! Ihr habt es geschafft: Der Ring gehört euch. Nächste Saison heißt es, ihn zu verteidigen.";
  @override
  String get enhorabuenaCup =>
      'Glückwunsch! Ihr habt den NBA Cup gewonnen. Der Ring ist eine andere Geschichte: Die Saison geht weiter.';
  @override
  String get aCelebrarlo => "Auf geht's, feiern!";
  @override
  String mvpDeLasFinales(String nombre) => 'Finals-MVP · $nombre';
  @override
  String partidosDeSerie(int n) => n == 1 ? 'in 1 Spiel' : 'in $n Spielen';
  @override
  String get verEstadisticas => 'Statistiken ansehen';
  @override
  String get confirmarSimularTitulo => 'Bis zu diesem Tag simulieren?';
  @override
  String get seJugaraProximoPartido => 'Dein nächstes Spiel wird ausgetragen.';
  @override
  String seJugaranDeUnaVez(int partidos, int dia, int mes) =>
      'Die verbleibenden $partidos Spiele bis zum $dia.$mes. werden auf einmal ausgetragen.';
  @override
  String get simular => 'Simulieren';
  @override
  String finalCupVs(String enfrentamiento) =>
      'NBA-Cup-Finale — $enfrentamiento';
  @override
  String get tituloEventoFinAgenciaLibre => 'Ende der Free Agency';
  @override
  String get tituloEventoFechaLimiteTraspasos => 'Transferfrist';
  @override
  String get tituloEventoAllStar => 'All-Star-Wochenende';
  @override
  String get descEventoFinAgenciaLibre =>
      'Ab jetzt können keine Free Agents mehr verpflichtet werden.';
  @override
  String get descEventoFechaLimiteTraspasos =>
      'Letzter Tag für Transfers in dieser Saison.';
  @override
  String get descEventoAllStar =>
      'Du hast an diesem Wochenende kein Spiel. Nutze die Zeit, um dir die Tabelle anzusehen.';
  @override
  List<String> get nombresMeses => [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  @override
  List<String> get diasSemanaAbrev => ['M', 'D', 'M', 'D', 'F', 'S', 'S'];
  @override
  String get simularUnPartido => '1 Spiel simulieren';
  @override
  String get unaSemana => '1 Woche';
  @override
  String get simularUnaSemana => '1 Woche simulieren';
  @override
  String get unMes => '1 Monat';
  @override
  String get simularUnMes => '1 Monat simulieren';
  @override
  String get simularTemporadaEntera => 'Ganze Saison';
  @override
  String get verBracketCompleto => 'Komplettes Playoff-Schema ansehen';
  @override
  String get empezarSiguienteTemporada => 'Nächste Saison beginnen';
  @override
  String get simularPartidoDePlayoffs => 'Playoff-Spiel simulieren';
  @override
  String get noClasificasteAPlayoffs =>
      'Du hast dich diese Saison nicht für die Playoffs qualifiziert.';
  @override
  String get simularPlayoffsCompletos => 'Komplette Playoffs simulieren';
  @override
  String get serieDecididaFaltaResto =>
      'Deine Serie ist entschieden — der Rest des Playoff-Schemas muss sich noch klären, um deinen nächsten Gegner zu kennen.';
  @override
  String get simularRestoDeRonda => 'Rest der Runde simulieren';

  @override
  String ofertaTitulo(int n) =>
      n == 1 ? 'Du hast ein Angebot bekommen' : 'Du hast Angebote';
  @override
  String ofertaMensaje(int n) => n == 1
      ? 'Ein Team hat nach einem deiner Spieler gefragt und ein Angebot vorgelegt.'
      : '$n Teams haben nach deinen Spielern gefragt.';
  @override
  String get masTarde => 'Später';
  @override
  String verOfertaBoton(int n) =>
      n == 1 ? 'Angebot ansehen' : 'Angebote ansehen';
  @override
  String get preguntaSeguirSimulando =>
      'Du hast diese Frist der Saison erreicht. Weiter simulieren oder anhalten, um Transfers zu tätigen?';
  @override
  String get irAAgenciaLibre => 'Zur Free Agency';
  @override
  String get irATraspasos => 'Zu Transfers';
  @override
  String get seguirSimulando => 'Weiter simulieren';
  @override
  String get allStarWeekendMayus => 'ALL STAR WEEKEND';
  @override
  String resultadoAllStar({
    required bool esteGana,
    required int local,
    required int visitante,
    String? mvp,
  }) =>
      'Das All-Star Game wurde gespielt. ${esteGana ? "Der Osten" : "Der Westen"} gewinnt mit $local:$visitante.${mvp == null ? "" : "\n\nMVP des Spiels: $mvp."}';
  @override
  String get verFinDeSemana => 'Wochenende ansehen';
  @override
  String finalCupProgramada(String fecha) =>
      'Ab ins NBA-Cup-Finale! Du spielst es am $fecha: simuliere bis zu diesem Tag.';
  @override
  String fechaCorta(int dia, int mes) => '$dia. ${nombresMeses[mes - 1]}';

  @override
  String get sinPartidosTitulo => 'Keine Spiele';
  @override
  String resumenPartidos(int n, int ganados, int perdidos) {
    final g = ganados;
    final p = perdidos;
    return '$n Spiele · $g-$p';
  }

  @override
  String get lesionesActivasAhora => 'Aktuell verletzte Spieler';
  @override
  String get verLosPremios => 'Auszeichnungen ansehen';

  @override
  String get playoffsSeSiembranAlTerminar =>
      'Die Playoffs werden ausgelost, sobald deine reguläre Saison (82 Spiele) vorbei ist.';
  @override
  String get verCelebracion => 'Feier ansehen';
  @override
  String get siguienteTemporadaBtn => 'Nächste Saison';
  @override
  String get resolverPlayIn => 'Play-in klären';
  @override
  String get simularRondaCompleta => 'Komplette Runde simulieren';
  @override
  String get simularTodoBtn => 'Alles simulieren';
  @override
  String get bracketTitulo => 'Playoff-Schema';
  @override
  String get primeraRondaEsperaPlayIn =>
      'Die erste Runde beginnt erst, wenn das Play-in geklärt hat, wer Platz 7 und 8 bekommt.';
  @override
  String get playInGanadorEntra7 => 'Sieger startet als Nr. 7';
  @override
  String get playInPerdedorEliminado => 'Verlierer scheidet aus';
  @override
  String get playInGanadorEntra8 => 'Sieger startet als Nr. 8';
  @override
  String get conferenciaOesteTitulo => 'Westkonferenz';
  @override
  String get conferenciaEsteTitulo => 'Ostkonferenz';
  @override
  String get sinPlayIn => 'Kein Play-in';
  @override
  String get jugarBtn => 'Spielen';
  @override
  String get porJugar => 'Noch zu spielen';
  @override
  String get rondaPrimeraRonda => 'Erste Runde';
  @override
  String get rondaSemifinalConferencia => 'Conference-Halbfinale';
  @override
  String get rondaFinalConferencia => 'Conference-Finale';
  @override
  String get rondaFinalNba => 'NBA-Finals';
  @override
  List<String> get nombresDeRondaBracket => [
    'Erste\nRunde',
    'Halbfinale',
    'West-\nFinale',
    'NBA-\nFINALS',
    'Ost-\nFinale',
    'Halbfinale',
    'Erste\nRunde',
  ];
  @override
  String get esperandoAlPlayIn => 'Warten auf Play-in';
  @override
  String get porDefinir => 'Offen';

  @override
  String despedirConfirmacion(String nombre) => '$nombre entlassen?';
  @override
  String despedirConTiempoRestante(int anios, String importe) =>
      'Er hat noch $anios ${anios == 1 ? "Saison" : "Saisons"} Vertrag, die trotzdem bezahlt werden müssen: $importe, die du bis dahin NICHT für seinen Nachfolger ausgeben kannst.';
  @override
  String get despedirSinContrato =>
      'Er wird frei und kann bei jedem Team unterschreiben. Bis du jemand anderen verpflichtest, spielt dein Team ohne Trainer.';
  @override
  String get ficharPorElMinimoBtn => 'Zum Minimum verpflichten';
  @override
  String get noHayEntrenadorSinEquipo => 'Es gibt keinen Trainer ohne Team';
  @override
  String get dirigiendoAOtroEquipo => 'Trainiert ein anderes Team';
  @override
  String get sePuedeOfertarPeroTrabajo =>
      'Du kannst ihnen ein Angebot machen, aber sie haben einen Job: Es braucht deutlich mehr, um sie zu überzeugen, und das Team, dem du ihn abwirbst, sucht sofort einen Ersatz.';
  @override
  String get avisoObligatorioTexto =>
      'Du kannst nicht ohne Trainer spielen. Verpflichte jemanden, um weiterzumachen: Wenn dich niemand überzeugt oder das Budget nicht reicht, kannst du immer jemanden zum Minimum verpflichten.';
  @override
  String mediaDeTuEquipoEs(int n) =>
      'Der Durchschnitt deines Teams liegt bei $n. Je besser ein Trainer ist, desto mehr Projekt verlangt er — und Geld gleicht nur einen Teil des Unterschieds aus.';
  @override
  String pideAlAnioYTemporadas(String importe, int anios) =>
      'Verlangt $importe pro Jahr und $anios Saisons.';
  @override
  String noLlegaMasaSalarial(String importe) =>
      'Dein Gehaltsbudget reicht nicht: Du kannst höchstens $importe bieten.';
  @override
  String get tuEntrenadorLabel => 'Dein Trainer';
  @override
  String get masaSalarialConBanquillo => 'Gehaltssumme (inkl. Trainerstab)';
  @override
  String get porEncimaDelTopeSoloMinimo =>
      'Du bist über dem Gehaltsdach: Du kannst nur zum Mindestgehalt verpflichten.';
  @override
  String get sueldoEntrenadorCuentaEnMasa =>
      'Das Trainergehalt zählt zu deiner Gehaltssumme: Was du hier ausgibst, hast du nicht mehr für Spieler.';
  @override
  String contratoResumen(String importeAlAnio, String duracion) =>
      '$importeAlAnio · Vertrag über $duracion';
  @override
  String trayectoriaEstaTemporada(int victorias, int derrotas) =>
      'Diese Saison: $victorias-$derrotas';
  @override
  String temporadasDirigiendo(int n) => '$n Saisons als Trainer';
  @override
  String anillos(int n) => n == 1 ? '1 Ring' : '$n Ringe';
  @override
  String entrenadorDelAnio(int n) =>
      n == 1 ? '1x Trainer des Jahres' : '${n}x Trainer des Jahres';
  @override
  String dirigeAEquipo(String apodo) => 'Trainiert $apodo';
  @override
  String pideImportePorAnios(String importe, int anios) =>
      'Verlangt $importe × $anios ${anios == 1 ? "Jahr" : "Jahre"}';
  @override
  String get noCabeEnPresupuesto => 'Passt nicht in dein Trainerbudget';
  @override
  String get proyectoLeQuedaLejos =>
      'Dein Projekt ist zu weit von seinen Vorstellungen entfernt';
  @override
  String get asuPrecioNo =>
      'Zu seinem Preis würde er ablehnen; mit mehr Geld vielleicht';
  @override
  String get volver => 'Zurück';
  @override
  String get elegirEsteEquipo => 'Dieses Team wählen';

  @override
  String mediaDelEquipo(int n) => 'Team-Durchschnitt: $n';
  @override
  String get torneoDeMitadDeTemporada => 'Mid-Season-Turnier';
  @override
  String get campeonNba => 'NBA-Meister';

  @override
  String descripcionHueco(bool esTitular, String nombrePosicion) =>
      esTitular ? '$nombrePosicion-Starter' : '$nombrePosicion-Ersatz';
  @override
  String get tituloTitular => 'Starter';
  @override
  String get tituloSuplente => 'Ersatz';
  @override
  Map<String, String> get nombresDePosiciones => {
    'PG': 'Point Guard (PG)',
    'SG': 'Shooting Guard (SG)',
    'SF': 'Small Forward (SF)',
    'PF': 'Power Forward (PF)',
    'C': 'Center (C)',
  };
  @override
  String get minutosTitularLabel => 'Starter-Minuten: ';
  @override
  String fueraPorLesion(String nombres) => 'Verletzt ausgefallen: $nombres';
  @override
  String get alinearAutomaticamenteBtn => 'Automatisch aufstellen';
  @override
  String get pestanaAlineacion => 'Aufstellung';
  @override
  String get pestanaEstadisticas => 'Statistiken';
  @override
  String get tusPicksDeDraft => 'Deine Draft-Picks';
  @override
  String get empezarTemporadaBtn => 'Saison starten';
  @override
  String get guardarRotacionBtn => 'Aufstellung speichern';
  @override
  String get elegirJugadorPlaceholder => '— Spieler wählen —';
  @override
  String lesionConDetalle(String motivo, int partidos, String fecha) =>
      '$motivo ($partidos Spiele) — zurück am $fecha — in der Zwischenzeit spielt der Ersatzspieler';
  @override
  String get fueraDeSusDosPosiciones =>
      'Außerhalb seiner beiden Positionen (spielt etwas schwächer)';
  @override
  String get sinPartidosJugadosTemporada => 'Diese Saison noch nicht gespielt';
  @override
  String get estrellaAtaqueLabel => 'Offensivstar';
  @override
  String get estrellaDefensaLabel => 'Defensivstar';
  @override
  String get sextoHombreLabel => 'Sechster Mann';
  @override
  String get ningunaOpcion => 'Keine';
  @override
  String get faltaAlineacionAviso =>
      "Vervollständige die Aufstellung: Jede Position braucht Starter und Ersatz.";
  @override
  String get faltanRolesAviso =>
      "Du musst noch Offensivstar, Defensivstar und sechsten Mann festlegen.";
  @override
  String get sinPicksPropios =>
      'Du hast keine eigenen Picks mehr: Du hast sie alle weggehandelt.';
  @override
  String get traspasadoATiPorOtroEquipo =>
      'Von einem anderen Team zu dir transferiert';
  @override
  String get quintetoInicial => 'Starting Five';
  @override
  String get rotacionCompleta => 'Komplette Rotation';

  @override
  String nombreConPosicionYMedia(String nombre, String posicion, int media) =>
      '$nombre ($posicion, Gesamtwert $media)';
  @override
  String yaAsignadoIntercambio(String descripcionHueco) =>
      'aktuell $descripcionHueco — sie werden getauscht';
  @override
  String get tituloTusPicksDeDraft => 'Deine Draft-Picks';

  @override
  String lesionSimple(String motivo, String fecha) =>
      '$motivo, zurück am $fecha';

  @override
  String get rechazar => 'Ablehnen';
  @override
  String get proponer => 'Vorschlagen';
  @override
  String get tituloAgenciaLibre => 'Free Agency';
  @override
  String get verTuPlantilla => 'Deinen Kader ansehen';
  @override
  String get agenciaLibreCerrada =>
      'Die Free Agency ist für diese Saison geschlossen: die Frist ist abgelaufen. Du kannst den Markt weiter ansehen, aber erst nächstes Jahr wieder verpflichten.';
  @override
  String get completarConContratosMinimos => 'Mit Minimalverträgen auffüllen';
  @override
  String get plantillaCompletada => 'Kader aufgefüllt.';
  @override
  String fichadosPorElMinimo(int n) =>
      '$n Spieler mit Minimalvertrag verpflichtet.';
  @override
  String get quePuedaPagar => 'Bezahlbar';
  @override
  String get noQuedaNadieEnMercado => 'Niemand mehr auf dem Markt.';
  @override
  String get nadieEncajaConFiltro =>
      'Niemand auf dem Markt passt zu deiner Anfrage. Versuch, einen Filter zu entfernen.';
  @override
  String contadorAgentesLibres(int n) => '$n Free Agents';
  @override
  String contadorAgentesLibresFiltrado(int visibles, int total) =>
      '$visibles von $total Free Agents (Filter aktiv)';
  @override
  String get empezarLaTemporadaBtn => 'Saison starten';
  @override
  String get completaLaPlantillaParaContinuar =>
      'Fülle den Kader auf, um fortzufahren';
  @override
  String plantillaAlCompletoConN(int n) => 'Kader komplett: $n Spieler.';
  @override
  String plantillaDeMax(int n, int max) => 'Kader: $n von $max Spielern.';
  @override
  String faltanFichajesParaMinimo(int n) =>
      'Es fehlen noch $n Verpflichtungen bis zum Minimum.';
  @override
  String otrosEquiposJuegan(int max, int n, int atras) =>
      'Die anderen 29 Teams spielen mit $max. Mit $n kannst du starten, liegst aber $atras zurück.';
  @override
  String sinRecambioEn(String lista) => 'Keine Vertretung bei: $lista.';
  @override
  String libresBajoElTope(String cantidad) => '$cantidad frei unter dem Cap.';
  @override
  String get yaNoNegocia => 'Verhandelt nicht mehr';
  @override
  String negociarConN(int n) => 'Verhandeln ($n)';
  @override
  String ofertaA(String nombre) => 'Angebot an $nombre';
  @override
  String pideAlAnio(String cantidad) => 'Fordert $cantidad pro Jahr';
  @override
  String sueldoLabel(String cantidad) => 'Gehalt: $cantidad';
  @override
  String get insultoOferta => 'Er wird das als Beleidigung auffassen.';
  @override
  String get ofertaImprobable =>
      'Sehr unwahrscheinlich, dass er das annimmt: Gehalt, Jahre oder beides reichen nicht.';
  @override
  String get ofertaSePuedePensar =>
      'Er könnte es sich überlegen; ganz sicher ist er sich nicht.';
  @override
  String get ofertaProbableAceptar => 'Er wird das wahrscheinlich annehmen.';
  @override
  String get ofertaSeguraAceptar => 'So gut wie sicher, dass er zusagt.';
  @override
  String get aniosLabelDosPuntos => 'Jahre: ';
  @override
  String get tituloRenovaciones => 'Vertragsverlängerungen';
  @override
  String get ningunContratoSeAcaba =>
      'Keine Verträge laufen aus: dein Kader bleibt ein weiteres Jahr gebunden.';
  @override
  String continuarConNAgenciaLibre(int n) =>
      'Weiter ($n gehen in die Free Agency)';
  @override
  String porEncimaDelTope(String cantidad) =>
      'Du liegst $cantidad über dem Cap: du kannst nur Minimalverträge anbieten.';
  @override
  String teQuedanBajoElTope(String espacio, String tope) =>
      'Dir bleiben $espacio unter dem Cap von $tope.';
  @override
  String get seAcaboLaNegociacion => 'Verhandlung\nbeendet';
  @override
  String ofrecerConN(int n) => 'Anbieten ($n)';
  @override
  String get cerramosElTraspaso => 'Deal abschließen?';
  @override
  String seVanYLlegan(String piden, String ofrecen) =>
      '$piden gehen und $ofrecen kommen.';
  @override
  String get tituloOfertasRecibidasScreen => 'Erhaltene Angebote';
  @override
  String get nadieTePideNadaAhora =>
      'Im Moment hat dir niemand etwas angeboten. Simulier weiter: Angebote kommen während der Saison.';
  @override
  String get ofertaAnterior => 'Vorheriges Angebot';
  @override
  String get ofertaSiguiente => 'Nächstes Angebot';
  @override
  String ofertaNDeM(int n, int m) => 'Angebot $n von $m';
  @override
  String lineaJugadorOferta(
    String nombre,
    String posicion,
    int media,
    String contrato,
  ) => '$nombre · $posicion · $media · $contrato';
  @override
  String aniosDeContrato(int n) => n == 1 ? '1 Jahr' : '$n Jahre';
  @override
  String contratoAnioMillones(String anios, String millones) =>
      '$anios · $millones pro Jahr';
  @override
  String get tePiden => 'Sie verlangen';
  @override
  String get teOfrecen => 'Sie bieten';
  @override
  String get contraofertar => 'Gegenangebot';
  @override
  String get teVasAQuedarCorto => 'Das wird knapp für dich';
  @override
  String avisoLoCierras(String aviso) => '$aviso\n\nTrotzdem abschließen?';
  @override
  String get mejorNo => 'Lieber nicht';
  @override
  String get cerrarloIgual => 'Trotzdem abschließen';
  @override
  String get traspasoCerradoSimple => 'Trade abgeschlossen.';
  @override
  String get fechaLimiteTraspasosNoMasOperaciones =>
      'Die Trade-Frist ist abgelaufen: diese Saison können keine weiteren Deals mehr abgeschlossen werden.';
  @override
  String quienSeLlevaA(String nombre) => 'Wer würde $nombre nehmen?';
  @override
  String quienSeLlevaPaquete(int n) =>
      'Wer würde dieses Paket mit $n Teilen nehmen?';
  @override
  String get ningunEquipoTeDariaNada =>
      'Kein Team würde dir im Gegenzug etwas Brauchbares geben.';
  @override
  String get noTienesConQueConvencer =>
      'Du hast nichts, um sie zu überzeugen: weder dein Kader noch deine Picks reichen, ohne dich auszubluten.';
  @override
  String get tituloTraspasos => 'Trades';
  @override
  String get fechaLimiteTraspasosBanner =>
      'Die Trade-Frist ist diese Saison bereits abgelaufen: du kannst den Markt weiter ansehen, aber erst nächstes Jahr wieder etwas abschließen.';
  @override
  String get noCuadraMeteATercero =>
      'Passt nicht? Ein drittes Team einbeziehen';
  @override
  String get cerrarTraspasoBtn => 'Trade abschließen';
  @override
  String get tuEquipoLabel => 'Dein Team';
  @override
  String get tercerEquipoLabel => 'Drittes Team';
  @override
  String get rivalLabel => 'Gegner';
  @override
  String get buscarQuienCompraria => 'Suchen, wer ihn nehmen würde';
  @override
  String get buscarQueDarPorEl =>
      'Suchen, was es kosten würde, ihn zu bekommen';
  @override
  String anadirDe(String equipo) => 'Von $equipo hinzufügen';
  @override
  String get eleccionesDeDraft => 'Draft-Picks';
  @override
  String get yaHasPuestoTodo =>
      'Du hast bereits alles auf den Tisch gelegt, was dieses Team verfügbar hatte.';
  @override
  String get sacarDeLaOperacion => 'Aus dem Deal entfernen';
  @override
  String get noCuadraMeteATerceroLarga =>
      'Passt nicht?\nEin drittes Team einbeziehen';
  @override
  String get anadirEquipoBtn => 'Team hinzufügen';
  @override
  String get tocaParaElegirJugadoresOPicks =>
      'Tippen, um Spieler\noder Picks zu wählen';

  @override
  String get mercadoCerradoNoSeBuscan =>
      'Der Markt ist geschlossen: die Trade-Frist ist abgelaufen. Es können erst nächstes Jahr wieder Deals gesucht werden.';
  @override
  String get tituloLegado => 'Vermächtnis';
  @override
  String get explicacionPuntuacionCarreraTooltip =>
      'Was die Karrierepunktzahl bedeutet';
  @override
  String get hallOfFame => 'Hall of Fame';
  @override
  String get pestanaCamisetasRetiradas => 'Zurückgezogene Trikots';
  @override
  String get pestanaLideresHistoricos => 'Ewige Bestenliste';
  @override
  String get camisetaRetiradaSingular => 'Zurückgezogenes Trikot';
  @override
  String get unDorsalQueNoVolvera =>
      'Eine Nummer, die nie wieder getragen wird';
  @override
  String get dorsalesQueNoVolveran => 'Nummern, die nie wieder getragen werden';
  @override
  String get tituloPartidosDeLaSerie => 'Spiele der Serie';
  @override
  String partidoNMarcador(
    int n,
    String local,
    int marcadorLocal,
    int marcadorVisitante,
    String visitante,
  ) => 'Spiel $n: $local $marcadorLocal - $marcadorVisitante $visitante';
  @override
  String get unNuevoNombreHof =>
      'Ein neuer Name zieht in die Hall of Fame ein.';
  @override
  String nNombresNuevosHof(int n) =>
      '$n neue Namen ziehen in die Hall of Fame ein.';
  @override
  String entroEnAnio(int anio) => 'Aufgenommen $anio';
  @override
  String get queEsPuntuacionCarrera => 'Was ist die Karrierepunktzahl?';
  @override
  String get explicacionPuntuacionCarreraTexto =>
      'Fasst die gesamte Karriere eines Spielers zusammen, nicht nur eine einzelne Zahl:\n\n• Individuelle Auszeichnungen (MVP, Defensive Player of the Year, All-NBA-Teams, Rookie of the Year, Most Improved Player).\n• Meisterringe und NBA-Cup-Titel.\n• Das Spitzenniveau, das er erreicht hat.\n• Die Punkte, Assists und Rebounds, die er je nach Anzahl gespielter Saisons gesammelt hat.\n\nEs braucht mindestens 6 gespielte Saisons und einen Schwellenwert: ein solider Starter ohne Auszeichnungen reicht nicht, er muss wirklich wichtig gewesen sein.';
  @override
  String get entendido => 'Verstanden';
  @override
  String noSePudoCargarHof(String error) =>
      'Die Hall of Fame konnte nicht geladen werden.\n$error';
  @override
  String get todaviaNadieEnHof =>
      'Noch ist niemand in der Hall of Fame. Es kommen nur zurückgetretene Spieler mit einer wirklich großen Karriere hinein: Auszeichnungen, Ringe und viele Jahre auf hohem Niveau.';
  @override
  String get nuevoChip => 'NEU';

  @override
  String get enActivoLeyenda => 'Aktiv: kann noch in der Rangliste aufsteigen';
  @override
  String get todaviaNoHayEstadisticas => 'Noch keine Statistiken vorhanden.';
  @override
  String noSePudieronCargarCamisetas(String error) =>
      'Die zurückgezogenen Trikots konnten nicht geladen werden.\n$error';
  @override
  String get todaviaNoHayCamisetaEnLiga =>
      'In der Liga wurde noch kein Trikot zurückgezogen. Wenn eine Legende zurücktritt, kannst du sie ehren.';
  @override
  String get franquiciaLabel => 'Franchise';
  @override
  String get todaLaLigaOpcion => 'Ganze Liga';
  @override
  String equipoTodaviaNoHaRetirado(String equipo) =>
      '$equipo hat noch kein Trikot zurückgezogen.';
  @override
  String get tuEquipoBadge => 'DEIN TEAM';
  @override
  String get retiradaRealDeLaFranquicia => 'Echte Ehrung der Franchise';
  @override
  String retiradaEnLaTemporada(String etiquetaTemporada) =>
      'Zurückgezogen in der $etiquetaTemporada';
  @override
  String nPartidos(int n) => n == 1 ? '1 Spiel' : '$n Spiele';
  @override
  String get enElVestuario => 'In der Kabine';

  @override
  String get premioMvp => 'MVP';
  @override
  String get premioMejorDefensor => 'Defensivspieler des Jahres';
  @override
  String get premioRookieDelAno => 'Rookie des Jahres';
  @override
  String get premioMasMejorado => 'Most Improved Player';
  @override
  String get premioPrimerQuinteto => 'All-NBA First Team';
  @override
  String get premioSegundoQuinteto => 'All-NBA Second Team';
  @override
  String get risingStars => 'Rising Stars';
  @override
  String premioMvpAllStar(String allStar) => '$allStar-MVP';
  @override
  String premioMvpRisingStars(String risingStars) => '$risingStars-MVP';
  @override
  String get tituloPremiosDeLaTemporada => 'Saisonauszeichnungen';
  @override
  String noSePudieronCargarPremios(String error) =>
      'Die Auszeichnungen konnten nicht geladen werden.\n$error';
  @override
  String get verCalendarioBtn => 'Kalender ansehen';
  @override
  String statsPremioLinea(String pts, String ast, String reb) =>
      '$pts Pkt, $ast Ass, $reb Reb';

  @override
  String temporadaN(int n) => 'Saison $n';
  @override
  String arrancaLaTemporada(int n, int anioInicio, int anioFin) =>
      'Saison $n beginnt ($anioInicio-$anioFin)';
  @override
  String get plantillaHaCambiadoAviso =>
      'Dein Kader hat sich geändert: überprüfe ihn vor dem ersten Spiel — es wurde bereits eine automatische Aufstellung erstellt.';
  @override
  String get tusEleccionesDelDraft => 'Deine Draft-Picks';
  @override
  String get seRetiranDeTuEquipo => 'Treten aus deinem Team zurück';
  @override
  String cuelgaLasBotasCon(int edad, int media) =>
      'Beendet die Karriere mit $edad Jahren, Gesamtwert $media';
  @override
  String get hanDadoUnPasoAdelante => 'Haben einen Schritt nach vorn gemacht';
  @override
  String get empiezanABajar => 'Beginnen nachzulassen';
  @override
  String get topDelDraft => 'Draft-Highlights';
  @override
  String get movimientosEnLaLiga => 'Transfers in der Liga';
  @override
  String recibeA(String equipoA, String jugadorB, String posicionB) =>
      '$equipoA bekommt $jugadorB ($posicionB)';
  @override
  String get tambienSeRetiran => 'Treten außerdem zurück';
  @override
  String yNMas(int n) => 'und $n weitere';
  @override
  String posicionMediaSeparador(String posicion, int media) =>
      '$posicion · Gesamtwert $media · ';

  @override
  String camisetaDeXRetirada(String nombre) =>
      'Trikot von $nombre zurückgezogen.';
  @override
  String get tituloSeRetiran => 'Treten zurück';
  @override
  String get estaTemporadaNoSeRetiraNadie =>
      'Diese Saison tritt niemand zurück.';
  @override
  String get restoDeLaLiga => 'Rest der Liga';
  @override
  String get suCamisetaYaRetiradaSola =>
      ' · sein Trikot wurde bereits automatisch zurückgezogen (echte Legende)';
  @override
  String get camisetaRetiradaSufijo => ' · Trikot zurückgezogen';

  @override
  String get tituloResultadoPartido => 'Spielergebnis';
  @override
  String get columnaTotal => 'Gesamt';
  @override
  String get columnaJugador => 'Spieler';
  @override
  String get columnaMin => 'Min';
  @override
  String get columnaPts => 'Pkt';
  @override
  String get columnaAst => 'Ass';
  @override
  String get columnaReb => 'Reb';
  @override
  String get prefijoCuarto => 'Q';
  @override
  String get prefijoProrroga => 'V';

  @override
  String get ordenPotencial => 'Potenzial';
  @override
  String get ordenMediaDesc => 'Gesamtwert ↓';
  @override
  String get ordenMediaAsc => 'Gesamtwert ↑';
  @override
  String get tituloDraft => 'Draft';
  @override
  String get eligiendoElRestoDeEquipos => 'Die restlichen Teams wählen...';
  @override
  String get queElijaLaCpuPorMi => 'Der Computer soll für mich wählen';
  @override
  String get draftCompletado => 'Draft abgeschlossen';
  @override
  String eleccionNumero(int n) => 'Pick Nummer $n';
  @override
  String get teTocaElegir => 'Du bist am Zug!';
  @override
  String get ordenarPorLabel => 'Sortieren nach: ';

  @override
  String cuartosCopaSeSiembranAviso(String nbaCup) =>
      'Die Viertelfinals des $nbaCup werden gesetzt, sobald die Gruppenphase der ganzen Liga beendet ist.';
  @override
  String get finalSeJuegaDesdeCalendarioAviso =>
      'Das Finale wird über den Kalender gespielt: als Finalist ist es einfach als ein weiterer Tag deiner Saison markiert.';
  @override
  String get cuartosDeFinalLabel => 'Viertelfinale';
  @override
  String get semifinalLabel => 'Halbfinale';
  @override
  String finalDeLaCopaLabel(String nbaCup) => '$nbaCup-Finale';
  @override
  String get cuartosRondaLabel => 'Viertelfinale';
  @override
  String get finalRondaLabel => 'Finale';
  @override
  String get pendienteLabel => 'Ausstehend';

  @override
  String get tituloResumenDeLaTemporada => 'Saisonübersicht';
  @override
  String noSePudoCargarResumen(String error) =>
      'Die Übersicht konnte nicht geladen werden.\n$error';
  @override
  String temporadaConEtiqueta(String etiqueta) => 'Saison $etiqueta';
  @override
  String get pestanaBalance => 'Bilanz';
  @override
  String puestoEnConferencia(String conferencia) => 'Platz im $conferencia';
  @override
  String puestoValor(int puesto) => '#$puesto';
  @override
  String puestoEnLaLigaNota(int puesto) => '#$puesto der Liga';
  @override
  String get puntosPorPartidoLabel => 'Punkte pro Spiel';
  @override
  String encajadosLabel(String valor) => '$valor zugelassen';
  @override
  String get diferenciaLabel => 'Differenz';
  @override
  String get porPartidoLabel => 'pro Spiel';
  @override
  String get mejorRachaLabel => 'Beste Serie';
  @override
  String get victoriasSeguidasLabel => 'Siege in Folge';
  @override
  String get peorRachaLabel => 'Schlechteste Serie';
  @override
  String get derrotasSeguidasLabel => 'Niederlagen in Folge';
  @override
  String get mejorVictoriaLabel => 'Bester Sieg';
  @override
  String get peorDerrotaLabel => 'Schlechteste Niederlage';
  @override
  String partidosJugadosVictoriasPct(int partidos, int pct) =>
      '$partidos Spiele · $pct% Siege';
  @override
  String get todaviaNoHayClasificacion => 'Noch keine Tabelle.';
  @override
  String get columnaPJ => 'Sp';
  @override
  String posicionMedia(String posicion, int media) =>
      '$posicion · Gesamtwert $media';

  @override
  String get allStarSubtituloPendiente =>
      'Wird in der Februarpause gespielt. Simulier bis zum All-Star-Wochenende, um es zu sehen.';
  @override
  String get risingStarsSubtituloPendiente =>
      'Die besten Rookies gegen Spieler im zweiten Jahr, am selben Wochenende.';
  @override
  String get votacionAbreCuandoRuedeBalonAviso =>
      'Die Abstimmung öffnet, sobald der Ball rollt. Während du die Saison spielst, siehst du, wer sich den Platz sichert und mit wie vielen Stimmen.';
  @override
  String get verEstadisticasBtn => 'Statistiken ansehen';
  @override
  String mvpConNombre(String nombre) => 'MVP · $nombre';
  @override
  String lineaMvpPtsAstReb(int pts, int ast, int reb) =>
      '$pts Pkt · $ast Ass · $reb Reb';
  @override
  String escrutadoPorcentaje(int pct) => '$pct% der Stimmen ausgezählt...';
  @override
  String get recuentoCerradoAviso =>
      'Auszählung beendet: das waren die Gewählten.';
  @override
  String votacionAbiertaConPorcentaje(int pct) =>
      'Abstimmung offen, $pct% der Saison gespielt. Simulier weiter, und die Stimmen werden sich verschieben.';
  @override
  String get votacionFinalLabel => 'Endabstimmung';
  @override
  String get votacionDeAficionadosLabel => 'Fan-Abstimmung';
  @override
  String conferenciaConNombre(String conferenciaLabel) =>
      'Conference $conferenciaLabel';
  @override
  String get titularesLabel => 'Starter';
  @override
  String get suplentesLabel => 'Reservisten';
  @override
  String get seQuedanFueraLabel => 'Bleiben außen vor';
  @override
  String posicionValoracion(String posicion, String valoracion) =>
      '$posicion · Bewertung $valoracion';

  @override
  String get noLlegoACompletarNingunaTemporada =>
      'Hat nie eine ganze Saison mit dir absolviert.';
  @override
  String get tituloTrayectoria => 'Laufbahn';
  @override
  String get tituloPalmares => 'Auszeichnungen';
  @override
  String get noRetirarElDorsal => 'Nummer nicht zurückziehen';
  @override
  String get retirarSuCamiseta => 'Trikot zurückziehen';
  @override
  String get mvpFinalesCorto => 'Finals-MVP';
  @override
  String get mvpDeLasFinalesLabel => 'Finals-MVP';
  @override
  String quintetosAllNba(int n) => '$n All-NBA-Team-Nominierungen';
  @override
  String vecesConEtiqueta(int n, String etiqueta) => '$n $etiqueta';
  @override
  String copasGanadas(int n, String nbaCup) => '$n× $nbaCup';
  @override
  String get premioCampeonDeLaNba => 'NBA-Meister';
  @override
  String get premioTercerQuinteto => 'All-NBA Third Team';
  @override
  String get premioMaximoAnotador => 'Topscorer';
  @override
  String get premioMasMejoradoCorto => 'Most Improved';
  @override
  String get sinTitulosNiPremiosCarreraNba =>
      'Keine Titel oder Auszeichnungen in seiner NBA-Karriere.';
  @override
  String get sinTitulosNiPremiosIndividuales =>
      'Keine Titel oder individuellen Auszeichnungen.';
  @override
  String resumenCarreraTotales(int temporadas, String posicion, int partidos) =>
      '$temporadas Saisons · $posicion · $partidos Spiele';
  @override
  String totalesCarreraLinea(String pts, String ast, String reb) =>
      'Gesamt: $pts Pkt · $ast Ass · $reb Reb';
  @override
  String temporadasPreviasAviso(int n) =>
      '$n davon, bevor du übernommen hast: dafür gibt es keine Statistiken, die Durchschnittswerte unten stammen aus deiner Ära.';
  @override
  String get antesDeTuPartidaTitulo => 'Vor deinem Spielstand';
  @override
  String temporadasYaJugadasCuandoCogisteElEquipo(int n) =>
      '$n bereits gespielte ${n == 1 ? 'Saison' : 'Saisons'}, als du das Team übernommen hast.';
  @override
  String get produccionDeReferenciaAviso =>
      'Seine Referenzleistung zu Beginn des Spielstands. Aus jenen Jahren gibt es keine Statistiken pro Spiel.';
  @override
  String sinEstadisticasDeCarreraAviso(String nombre) =>
      'Für $nombre gibt es keine Karrierestatistiken: er stammt aus einer Zeit vor der Datenabdeckung des Spiels. Sein Platz in der Geschichte ist da, die Zahlen nicht.';
  @override
  String get suCarreraEnLaNbaReal => 'Seine echte NBA-Karriere';
  @override
  String conEquipoEnLaNbaReal(String equipo) => 'Mit $equipo in der echten NBA';
  @override
  String temporadasPartidos(int temporadas, int partidos) =>
      '$temporadas Saisons · $partidos Spiele';
  @override
  String rangoTemporadasPartidos(String desde, String hasta, int partidos) =>
      '$desde bis $hasta · $partidos Spiele';
  @override
  String rangoPartidos(String rango, int partidos) =>
      '$rango · $partidos Spiele';
  @override
  String temporadaMinuscula(int n) => 'Saison $n';

  @override
  String get nadieTePropuestoNadaAhora =>
      'Bisher hat dir niemand etwas vorgeschlagen';
  @override
  String get unEquipoQuiereAUnoDeTusJugadores =>
      'Ein Team möchte einen deiner Spieler';
  @override
  String nEquiposHanPreguntado(int n) =>
      '$n Teams haben nach deinen Spielern gefragt';
  @override
  String cuadroYResultadosDeLaCopa(String nbaCup) =>
      'Turnierbaum und Ergebnisse des $nbaCup';
  @override
  String get seDesbloqueaAlTerminarFaseDeGrupos =>
      'Wird nach der Gruppenphase freigeschaltet';
  @override
  String get premiosDeFinDeTemporadaSubtitulo =>
      'Saisonabschluss-Auszeichnungen';
  @override
  String get seDesbloqueaAlTerminarTemporadaRegular =>
      'Wird nach der regulären Saison freigeschaltet';
  @override
  String get bracketDeEliminatorias => 'Playoff-Turnierbaum';
  @override
  String hallOfFameYCamisetasRetiradasSubtitulo(
    String hallOfFame,
    String camisetas,
  ) => '$hallOfFame und $camisetas';
  @override
  String get salarialLabel => 'Gehaltsdach';

  @override
  String get sigueDondeLoDejaste => 'Mach weiter, wo du aufgehört hast';
  @override
  String get empiezaTuCarrera => 'Starte deine Karriere';
  @override
  String get enQueRanuraQuieresEmpezar =>
      'In welchem Slot möchtest du starten?';
  @override
  String get eligeLaPartidaQueQuieresCargar =>
      'Wähle den Spielstand, den du laden möchtest';
  @override
  String get nuevaPartidaBtn => 'Neues Spiel';
  @override
  String get cargarPartidaBtn => 'Spiel laden';
  @override
  String sobrescribirLaPartidaN(int n) => 'Spielstand $n überschreiben?';
  @override
  String get sePerderaEnteraAviso =>
      'Dieser Slot hat bereits eine laufende Karriere, die komplett verloren geht: Kader, Kalender und Auszeichnungen. Das kann nicht rückgängig gemacht werden.';
  @override
  String get sobrescribirBtn => 'Überschreiben';
  @override
  String get eligeTuEquipoTitulo => 'Wähle dein Team';
  @override
  String borrarLaPartidaN(int n) => 'Spielstand $n löschen?';
  @override
  String sePierdeCarreraDeAviso(String nombre) =>
      'Die gesamte Karriere von $nombre geht verloren: Kader, Kalender, Auszeichnungen, Legenden und zurückgezogene Trikots. Das kann nicht rückgängig gemacht werden.';
  @override
  String get borrarBtn => 'Löschen';
  @override
  String get lasTresRanurasOcupadasAviso =>
      'Alle drei Slots sind belegt: lösche einen, um neu zu beginnen, oder setze einen deiner vorhandenen fort.';
  @override
  String get ranuraDeVersionCompleta => 'Slot der Vollversion';
  @override
  String partidaNumero(int n) => 'SPIELSTAND $n';
  @override
  String get borrarEstaPartidaTooltip => 'Diesen Spielstand löschen';
  @override
  String get ranuraVaciaLabel => 'Leerer Slot';
  @override
  String get empezarBtn => 'Starten';

  @override
  String get lesionLabel => 'Verletzung';
  @override
  String get recibesLabel => 'Du bekommst: ';
  @override
  String get entregasLabel => 'Du gibst ab: ';
  @override
  String get traspasarBtn => 'Traden';
  @override
  String get potencialElite => 'Elite';
  @override
  String get potencialMuyAlto => 'Sehr hoch';
  @override
  String get potencialAlto => 'Hoch';
  @override
  String get potencialMedio => 'Mittel';
  @override
  String get potencialBajo => 'Niedrig';
  @override
  String potencialTooltip(String etiqueta) => 'Potenzial: $etiqueta';
  @override
  String get volverAlMenuPrincipalTooltip => 'Zurück zum Hauptmenü';
  @override
  String get volverAInicioTooltip => 'Zum Startbildschirm';

  @override
  String get margenSalarialEvento => 'Gehaltsspielraum';

  @override
  String get tuFranquiciaSeccion => 'Dein Franchise';

  @override
  String get proximoPartidoTitulo => 'Nächstes Spiel';

  @override
  String get enCasaLabel => 'Heim';

  @override
  String get fueraLabel => 'Auswärts';

  @override
  String get vsAbreviatura => 'VS';

  @override
  String get tituloPatrocinadores => 'Sponsoren';
  @override
  String get explicacionPatrocinadores =>
      'Jedes Sponsoring hat mehrere Angebote: je länger der Vertrag, desto weniger zahlt er pro Jahr. Was du unterschreibst, belegt diese Kategorie bis zum Vertragsende.';
  @override
  String get patrocinioEstadioLabel => 'Hallensponsor';
  @override
  String get patrocinioCamisetaLabel => 'Trikotsponsor';
  @override
  String get patrocinioBebidaLabel => 'Gastronomiesponsor';
  @override
  String get patrocinioOcioLabel => 'Gemeinschaftssponsor';
  @override
  String fundadoEnAnio(int anio) => 'Gegründet $anio';
  @override
  String get alAnioSufijo => 'pro Jahr';
  @override
  String sinPatrocinioFirmado(int ofertas) => ofertas == 1
      ? 'Nicht unterschrieben · 1 Angebot'
      : 'Nicht unterschrieben ·  Angebote';
  @override
  String margenPatrocinio(String importe) => '+$importe Gehaltsspielraum';
  @override
  String get patrocinadoresBloqueados =>
      'Sponsoren gehören zur Vollversion. Sieh dir ein Video an und du hast alle vier für diese Saison.';
  @override
  String get verVideoPatrocinadores => 'VIDEO ANSEHEN UND FREISCHALTEN';
  @override
  String get videoSinTerminar =>
      'Das Video wurde nicht zu Ende gesehen, sie bleiben also gesperrt. Du kannst es noch einmal versuchen.';

  @override
  String get modoFranquiciaOpcion => 'Franchise-Modus';
  @override
  String get modoCarreraOpcion => 'Spielermodus';

  @override
  String get crearJugadorTitulo => 'Erstelle deinen Spieler';
  @override
  String get apellidoLabel => 'Nachname';
  @override
  String get dorsalLabel => 'Rückennummer';
  @override
  String get posicionLabel => 'Position';
  @override
  String get nacionalidadLabel => 'Nationalität';
  @override
  String get confirmarIdentidadBtn => 'Identität bestätigen';

  @override
  String get ofertaJuvenilTitulo => 'Nachwuchsangebot';
  @override
  String get ofertaJuvenilDescripcion =>
      'Nachwuchsorganisationen deines Landes wollen dich für ihr Projekt. Wähle, wo deine Karriere beginnt.';
  @override
  String ficharPorBtn(String organizacion) =>
      'Bei $organizacion unterschreiben';

  @override
  String get avanzarTemporadaBtn => 'Saison fortsetzen';
  @override
  String get entrarAlDraftBtn => 'Am Draft teilnehmen';

  @override
  String get edadLabel => 'Alter';
  @override
  String get mediaLabel => 'Bewertung';
  @override
  String get potencialLabel => 'Potenzial';
  @override
  String get equipoActualLabel => 'Team';
  @override
  String get organizacionActualLabel => 'Organisation';

  @override
  String get carreraRetiradaTitulo => 'Karriere beendet';
  @override
  String draftResultadoMensaje(String equipo) =>
      'Du wurdest von $equipo gedraftet.';
  @override
  String get entraEnHallDeLaFamaMensaje => 'Du kommst in die Hall of Fame!';
  @override
  String get noEntraEnHallDeLaFamaMensaje =>
      'Du schaffst es nicht in die Hall of Fame.';
  @override
  String seRetiraMensaje(int edad) => 'Beendet die Karriere mit $edad Jahren.';
  @override
  String cambioDeEquipoMensaje(String equipo) => 'Neues Team: $equipo.';
}
