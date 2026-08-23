part of 'textos.dart';

/// English. Basketball terms use the ones the NBA itself uses (roster, cap,
/// front office) rather than literal translations from Spanish.
class TextosEn extends Textos {
  const TextosEn();

  @override
  TextosDeEventos get eventos => const EventosEn();

  @override
  String get aceptar => 'Accept';
  @override
  String get cancelar => 'Cancel';
  @override
  String get cerrar => 'Close';
  @override
  String get guardar => 'Save';
  @override
  String get continuar => 'Continue';
  @override
  String get si => 'Yes';
  @override
  String get no => 'No';
  @override
  String get cargando => 'Loading…';

  @override
  String get nuevaPartida => 'New game';
  @override
  String get ajustes => 'Settings';
  @override
  String get elegirEquipo => 'Pick your team';
  @override
  String get sobrescribir => 'Overwrite';
  @override
  String get ranuraOcupada => 'This slot already has a saved game';
  @override
  String get avisoSobrescribir =>
      'If you continue, the game saved here will be deleted.';

  @override
  String get modoOscuro => 'Dark mode';
  @override
  String get modoOscuroDetalle => 'Greys and blacks instead of bright whites';
  @override
  String get idioma => 'Language';
  @override
  String get idiomaDetalle => 'The language of the whole game';

  @override
  String get calendario => 'Schedule';
  @override
  String get calendarioDetalle => 'See your season and simulate games';
  @override
  String get tuEquipo => 'Your team';
  @override
  String get tuEquipoDetalle => 'Roster and lineup';
  @override
  String get entrenador => 'Head coach';
  @override
  String get banquilloVacante => 'Your bench is vacant';
  @override
  String get clasificacion => 'Standings';
  @override
  String get clasificacionDetalle => 'Teams and statistical leaders';
  @override
  String get mercado => 'Market';
  @override
  String get traspasos => 'Trades';
  @override
  String get traspasosDetalle => 'Negotiate deals with the rest of the league';
  @override
  String get ofertasRecibidas => 'Offers received';
  @override
  String get agenciaLibre => 'Free agency';
  @override
  String get agenciaLibreDetalle => 'Unsigned players and cap space';
  @override
  String get competicion => 'Competition';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Voting, the All-Star Game and its MVP';
  @override
  String get resumenTemporada => 'Season summary';
  @override
  String get resumenTemporadaDetalle => 'Record, every game and averages';
  @override
  String get playoffs => 'Playoffs';
  @override
  String get premios => 'Awards';
  @override
  String get legado => 'Legacy';

  @override
  String get record => 'Record';
  @override
  String get masaSalarial => 'Payroll';
  @override
  String get temporada => 'Season';

  @override
  String get sinEntrenador => 'No head coach';
  @override
  String get sinEntrenadorDetalle =>
      'Your team is playing without a coach. Sign one from the list below.';
  @override
  String get despedir => 'Fire';
  @override
  String get contratar => 'Hire';
  @override
  String get negociar => 'Negotiate';
  @override
  String get ofrecer => 'Offer';
  @override
  String get sueldo => 'Salary';
  @override
  String get duracion => 'Length';
  @override
  String get ataque => 'Offence';
  @override
  String get defensa => 'Defence';
  @override
  String get desarrollo => 'Development';
  @override
  String get equilibrado => 'Balanced';
  @override
  String get especialistaAtaque => 'Offensive specialist';
  @override
  String get especialistaDefensa => 'Defensive specialist';
  @override
  String get formadorDeJovenes => 'Player developer';
  @override
  String get loQuePuedesOfrecer => 'What you can offer';
  @override
  String get topeDeLaFranquicia => 'Franchise cap';
  @override
  String get finiquitos => 'Buyouts of fired coaches';
  @override
  String get aceptariaLaOferta => 'He would accept this offer.';
  @override
  String get todaviaNo =>
      'Not yet. More money or more years might change his mind.';
  @override
  String get noVaAAceptar =>
      'He will not accept: your project is too far off and money will not fix it.';

  @override
  String anios(int n) => n == 1 ? '1 season' : '$n seasons';
  @override
  String alAnio(String importe) => '$importe per year';

  @override
  String get pestanaEquipos => 'Teams';
  @override
  String get pestanaJugadores => 'Players';
  @override
  String get conferenciaEste => 'East';
  @override
  String get conferenciaOeste => 'West';
  @override
  String get fronteraPlayIn => 'Play-In';
  @override
  String get fronteraFueraDePlayoffs => 'Out of playoffs';
  @override
  String get ordenPuntos => 'Points';
  @override
  String get ordenAsistencias => 'Assists';
  @override
  String get ordenRebotes => 'Rebounds';
  @override
  String get sinPartidosJugados => 'No games have been played yet';
  @override
  String edadJugador(int n) => '$n years old';
  @override
  String mediaJugador(int n) => 'Overall $n';
  @override
  String get estaTemporada => 'This season';
  @override
  String get todaviaNoHaJugado => "Hasn't played yet";
  @override
  String get contrato => 'Contract';
  @override
  String get intentarTraspasar => 'Try to trade';
  @override
  String traspasoCerradoCon(String equipo) => 'Trade completed with $equipo.';
  @override
  String get fechaLimiteTraspasosPasada =>
      'The trade deadline has already passed: no more deals can be closed this season.';

  @override
  String get tituloConferenciaEste => 'EASTERN CONFERENCE';
  @override
  String get tituloConferenciaOeste => 'WESTERN CONFERENCE';

  @override
  String comoFicharA(String nombre) => 'How to sign $nombre?';
  @override
  String get sinConQueConvencerles =>
      "You don't have anything convincing to offer right now: neither your roster nor your picks are enough without leaving you short.";

  @override
  String get campeonesDeLaNba => 'NBA Champions';
  @override
  String get campeonesDeLaCup => 'NBA Cup Champions';
  @override
  String get exclamacionCampeones => 'CHAMPIONS!';
  @override
  String seLlevaElTitulo(String nombre) => '$nombre takes the title.';
  @override
  String get enhorabuenaAnillo =>
      "Congratulations! You've done it: the ring is yours. Next season you'll have to defend it.";
  @override
  String get enhorabuenaCup =>
      "Congratulations! You've won the NBA Cup. The ring is a different story: the season goes on.";
  @override
  String get aCelebrarlo => 'Time to celebrate!';
  @override
  String mvpDeLasFinales(String nombre) => 'Finals MVP · $nombre';
  @override
  String partidosDeSerie(int n) => n == 1 ? 'in 1 game' : 'in $n games';
  @override
  String get verEstadisticas => 'View stats';
  @override
  String get confirmarSimularTitulo => 'Simulate up to this day?';
  @override
  String get seJugaraProximoPartido => 'Your next game will be played.';
  @override
  String seJugaranDeUnaVez(int partidos, int dia, int mes) =>
      'All $partidos games you have left until $mes/$dia will be played at once.';
  @override
  String get simular => 'Simulate';
  @override
  String finalCupVs(String enfrentamiento) => 'NBA Cup Final — $enfrentamiento';
  @override
  String get tituloEventoFinAgenciaLibre => 'Free agency ends';
  @override
  String get tituloEventoFechaLimiteTraspasos => 'Trade deadline';
  @override
  String get tituloEventoAllStar => 'All-Star Weekend';
  @override
  String get descEventoFinAgenciaLibre =>
      'From here on, free agents can no longer be signed.';
  @override
  String get descEventoFechaLimiteTraspasos =>
      'Last day to make trades this season.';
  @override
  String get descEventoAllStar =>
      "You don't have a game this weekend. Take the chance to check the Standings.";
  @override
  List<String> get nombresMeses => [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  @override
  List<String> get diasSemanaAbrev => ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  @override
  String get simularUnPartido => 'Simulate 1 game';
  @override
  String get unaSemana => '1 week';
  @override
  String get simularUnaSemana => 'Simulate 1 week';
  @override
  String get unMes => '1 month';
  @override
  String get simularUnMes => 'Simulate 1 month';
  @override
  String get simularTemporadaEntera => 'Whole season';
  @override
  String get verBracketCompleto => 'View full bracket';
  @override
  String get empezarSiguienteTemporada => 'Start next season';
  @override
  String get simularPartidoDePlayoffs => 'Simulate playoff game';
  @override
  String get noClasificasteAPlayoffs =>
      "You didn't make the playoffs this season.";
  @override
  String get simularPlayoffsCompletos => 'Simulate full playoffs';
  @override
  String get serieDecididaFaltaResto =>
      'Your series is decided — the rest of the bracket needs to play out to know your next opponent.';
  @override
  String get simularRestoDeRonda => 'Simulate rest of the round';

  @override
  String ofertaTitulo(int n) =>
      n == 1 ? "You've got an offer" : 'You have offers';
  @override
  String ofertaMensaje(int n) => n == 1
      ? 'A team has asked about one of your players and put a proposal on the table.'
      : '$n teams have asked about your players.';
  @override
  String get masTarde => 'Later';
  @override
  String verOfertaBoton(int n) => n == 1 ? 'View offer' : 'View offers';
  @override
  String get preguntaSeguirSimulando =>
      "You've reached this deadline of the season. Keep simulating, or stop to make moves?";
  @override
  String get irAAgenciaLibre => 'Go to Free Agency';
  @override
  String get irATraspasos => 'Go to Trades';
  @override
  String get seguirSimulando => 'Keep simulating';
  @override
  String get allStarWeekendMayus => 'ALL STAR WEEKEND';
  @override
  String resultadoAllStar({
    required bool esteGana,
    required int local,
    required int visitante,
    String? mvp,
  }) =>
      'The All-Star Game has been played. ${esteGana ? "The East" : "The West"} takes it $local-$visitante.${mvp == null ? "" : "\n\nGame MVP: $mvp."}';
  @override
  String get verFinDeSemana => 'View the weekend';
  @override
  String finalCupProgramada(String fecha) =>
      "You're through to the NBA Cup Final! You play it on $fecha: simulate up to that day.";
  @override
  String fechaCorta(int dia, int mes) => '${nombresMeses[mes - 1]} $dia';

  @override
  String get sinPartidosTitulo => 'No games';
  @override
  String resumenPartidos(int n, int ganados, int perdidos) {
    final g = ganados;
    final p = perdidos;
    return '$n games · $g-$p';
  }

  @override
  String get lesionesActivasAhora => 'Currently active injuries';
  @override
  String get verLosPremios => 'View the awards';

  @override
  String get playoffsSeSiembranAlTerminar =>
      'The playoffs are seeded once your regular season (82 games) is over.';
  @override
  String get verCelebracion => 'View celebration';
  @override
  String get siguienteTemporadaBtn => 'Next season';
  @override
  String get resolverPlayIn => 'Resolve the Play-in';
  @override
  String get simularRondaCompleta => 'Simulate full round';
  @override
  String get simularTodoBtn => 'Simulate everything';
  @override
  String get bracketTitulo => 'Bracket';
  @override
  String get primeraRondaEsperaPlayIn =>
      "The first round doesn't start until the Play-in decides who gets the 7 and 8 seeds.";
  @override
  String get playInGanadorEntra7 => 'Winner enters as 7';
  @override
  String get playInPerdedorEliminado => 'Loser is eliminated';
  @override
  String get playInGanadorEntra8 => 'Winner enters as 8';
  @override
  String get conferenciaOesteTitulo => 'Western Conference';
  @override
  String get conferenciaEsteTitulo => 'Eastern Conference';
  @override
  String get sinPlayIn => 'No play-in';
  @override
  String get jugarBtn => 'Play';
  @override
  String get porJugar => 'To be played';
  @override
  String get rondaPrimeraRonda => 'First round';
  @override
  String get rondaSemifinalConferencia => 'Conference semifinal';
  @override
  String get rondaFinalConferencia => 'Conference final';
  @override
  String get rondaFinalNba => 'NBA Finals';
  @override
  List<String> get nombresDeRondaBracket => [
    'First\nround',
    'Semifinals',
    'West\nFinal',
    'NBA\nFINALS',
    'East\nFinal',
    'Semifinals',
    'First\nround',
  ];
  @override
  String get esperandoAlPlayIn => 'Waiting on Play-in';
  @override
  String get porDefinir => 'TBD';

  @override
  String despedirConfirmacion(String nombre) => 'Fire $nombre?';
  @override
  String despedirConTiempoRestante(int anios, String importe) =>
      "He has $anios ${anios == 1 ? 'season' : 'seasons'} left on his contract and you have to pay them anyway: $importe you WON'T be able to spend on his replacement until then.";
  @override
  String get despedirSinContrato =>
      "He'll become a free agent and can sign with any team. Until you hire someone else, your team will play without a coach.";
  @override
  String get ficharPorElMinimoBtn => 'Sign for the minimum';
  @override
  String get noHayEntrenadorSinEquipo => 'There are no coaches without a team';
  @override
  String get dirigiendoAOtroEquipo => 'Coaching another team';
  @override
  String get sePuedeOfertarPeroTrabajo =>
      'You can make them an offer, but they have a job: it takes a lot more to convince them, and the team you poach them from will look for a replacement right away.';
  @override
  String get avisoObligatorioTexto =>
      "You can't play without a coach. Sign someone to continue: if no one convinces you or the budget doesn't allow it, you can always sign one for the minimum.";
  @override
  String mediaDeTuEquipoEs(int n) =>
      "Your team's average is $n. The better a coach is, the better a project he demands — and money only covers part of the difference.";
  @override
  String pideAlAnioYTemporadas(String importe, int anios) =>
      'Wants $importe a year and $anios seasons.';
  @override
  String noLlegaMasaSalarial(String importe) =>
      "You don't have enough cap space: you can only offer $importe.";
  @override
  String get tuEntrenadorLabel => 'Your coach';
  @override
  String get masaSalarialConBanquillo => 'Payroll (including bench)';
  @override
  String get porEncimaDelTopeSoloMinimo =>
      "You're over the cap: you can only sign for the minimum salary.";
  @override
  String get sueldoEntrenadorCuentaEnMasa =>
      "The coach's salary counts toward your payroll: what you spend here you don't have for players.";
  @override
  String contratoResumen(String importeAlAnio, String duracion) =>
      '$importeAlAnio · $duracion contract';
  @override
  String trayectoriaEstaTemporada(int victorias, int derrotas) =>
      'This season: $victorias-$derrotas';
  @override
  String temporadasDirigiendo(int n) => '$n seasons coaching';
  @override
  String anillos(int n) => n == 1 ? '1 ring' : '$n rings';
  @override
  String entrenadorDelAnio(int n) =>
      n == 1 ? '1-time Coach of the Year' : '$n-time Coach of the Year';
  @override
  String dirigeAEquipo(String apodo) => 'Coaches $apodo';
  @override
  String pideImportePorAnios(String importe, int anios) =>
      'Wants $importe × $anios ${anios == 1 ? "year" : "years"}';
  @override
  String get noCabeEnPresupuesto => "Doesn't fit your coaching budget";
  @override
  String get proyectoLeQuedaLejos =>
      'Your project is too far from what he wants';
  @override
  String get asuPrecioNo =>
      "At his asking price he'd say no; with more money, maybe";
  @override
  String get volver => 'Back';
  @override
  String get elegirEsteEquipo => 'Choose this team';

  @override
  String mediaDelEquipo(int n) => 'Team average: $n';
  @override
  String get torneoDeMitadDeTemporada => 'Midseason tournament';
  @override
  String get campeonNba => 'NBA Champion';

  @override
  String descripcionHueco(bool esTitular, String nombrePosicion) =>
      esTitular ? '$nombrePosicion starter' : '$nombrePosicion backup';
  @override
  String get tituloTitular => 'Starter';
  @override
  String get tituloSuplente => 'Backup';
  @override
  Map<String, String> get nombresDePosiciones => {
    'PG': 'Point Guard (PG)',
    'SG': 'Shooting Guard (SG)',
    'SF': 'Small Forward (SF)',
    'PF': 'Power Forward (PF)',
    'C': 'Center (C)',
  };
  @override
  String get minutosTitularLabel => 'Starter minutes: ';
  @override
  String fueraPorLesion(String nombres) => 'Out injured: $nombres';
  @override
  String get alinearAutomaticamenteBtn => 'Auto-lineup';
  @override
  String get pestanaAlineacion => 'Lineup';
  @override
  String get pestanaEstadisticas => 'Stats';
  @override
  String get tusPicksDeDraft => 'Your draft picks';
  @override
  String get empezarTemporadaBtn => 'Start season';
  @override
  String get guardarRotacionBtn => 'Save lineup';
  @override
  String get elegirJugadorPlaceholder => '— pick a player —';
  @override
  String lesionConDetalle(String motivo, int partidos, String fecha) =>
      '$motivo ($partidos games) — back on $fecha — the backup will play meanwhile';
  @override
  String get fueraDeSusDosPosiciones =>
      'Out of both his positions (will perform a bit worse)';
  @override
  String get sinPartidosJugadosTemporada => "Hasn't played this season";
  @override
  String get estrellaAtaqueLabel => 'Offensive star';
  @override
  String get estrellaDefensaLabel => 'Defensive star';
  @override
  String get sextoHombreLabel => 'Sixth man';
  @override
  String get ningunaOpcion => 'None';
  @override
  String get faltaAlineacionAviso =>
      "Finish the lineup: every slot needs a starter and a backup.";
  @override
  String get faltanRolesAviso =>
      "You still have to pick your offensive star, defensive star and sixth man.";
  @override
  String get sinPicksPropios =>
      "You have no picks of your own left: you've traded them all away.";
  @override
  String get traspasadoATiPorOtroEquipo => 'Traded to you by another team';
  @override
  String get quintetoInicial => 'Starting five';
  @override
  String get rotacionCompleta => 'Full rotation';

  @override
  String nombreConPosicionYMedia(String nombre, String posicion, int media) =>
      '$nombre ($posicion, overall $media)';
  @override
  String yaAsignadoIntercambio(String descripcionHueco) =>
      'currently $descripcionHueco — they will swap';
  @override
  String get tituloTusPicksDeDraft => 'Your draft picks';

  @override
  String lesionSimple(String motivo, String fecha) => '$motivo, back on $fecha';

  @override
  String get rechazar => 'Decline';
  @override
  String get proponer => 'Propose';
  @override
  String get tituloAgenciaLibre => 'Free agency';
  @override
  String get verTuPlantilla => 'View your roster';
  @override
  String get agenciaLibreCerrada =>
      'Free agency has closed for this season: the deadline has passed. You can keep browsing the market, but you cannot sign anyone until next year.';
  @override
  String get completarConContratosMinimos => 'Fill out with minimum contracts';
  @override
  String get plantillaCompletada => 'Roster filled out.';
  @override
  String fichadosPorElMinimo(int n) => 'Signed $n players to minimum deals.';
  @override
  String get quePuedaPagar => 'Affordable';
  @override
  String get noQuedaNadieEnMercado => 'Nobody left on the market.';
  @override
  String get nadieEncajaConFiltro =>
      'Nobody on the market matches what you asked for. Try removing a filter.';
  @override
  String contadorAgentesLibres(int n) => '$n free agents';
  @override
  String contadorAgentesLibresFiltrado(int visibles, int total) =>
      '$visibles of $total free agents (filters applied)';
  @override
  String get empezarLaTemporadaBtn => 'Start the season';
  @override
  String get completaLaPlantillaParaContinuar =>
      'Fill out the roster to continue';
  @override
  String plantillaAlCompletoConN(int n) => 'Full roster: $n players.';
  @override
  String plantillaDeMax(int n, int max) => 'Roster: $n of $max players.';
  @override
  String faltanFichajesParaMinimo(int n) =>
      '$n more signings needed to reach the minimum.';
  @override
  String otrosEquiposJuegan(int max, int n, int atras) =>
      'The other 29 teams play with $max. You can start with $n, but you\'re $atras behind.';
  @override
  String sinRecambioEn(String lista) => 'No backup at: $lista.';
  @override
  String libresBajoElTope(String cantidad) =>
      '$cantidad available under the cap.';
  @override
  String get yaNoNegocia => 'No longer negotiating';
  @override
  String negociarConN(int n) => 'Negotiate ($n)';
  @override
  String ofertaA(String nombre) => 'Offer to $nombre';
  @override
  String pideAlAnio(String cantidad) => 'Asking $cantidad a year';
  @override
  String sueldoLabel(String cantidad) => 'Salary: $cantidad';
  @override
  String get insultoOferta => 'He\'ll take it as an insult.';
  @override
  String get ofertaImprobable =>
      'Very unlikely he accepts this: the salary, the years, or both fall short.';
  @override
  String get ofertaSePuedePensar =>
      'He might think it over; he\'s not fully convinced.';
  @override
  String get ofertaProbableAceptar => 'He\'ll likely accept.';
  @override
  String get ofertaSeguraAceptar => 'Almost certain to say yes.';
  @override
  String get aniosLabelDosPuntos => 'Years: ';
  @override
  String get tituloRenovaciones => 'Re-signings';
  @override
  String get ningunContratoSeAcaba =>
      'No contracts are expiring: your roster stays locked in for another year.';
  @override
  String continuarConNAgenciaLibre(int n) =>
      'Continue ($n heading to free agency)';
  @override
  String porEncimaDelTope(String cantidad) =>
      'You\'re $cantidad over the cap: you can only offer minimum contracts.';
  @override
  String teQuedanBajoElTope(String espacio, String tope) =>
      'You have $espacio left under the $tope cap.';
  @override
  String get seAcaboLaNegociacion => 'Negotiation\nis over';
  @override
  String ofrecerConN(int n) => 'Offer ($n)';
  @override
  String get cerramosElTraspaso => 'Close the trade?';
  @override
  String seVanYLlegan(String piden, String ofrecen) =>
      '$piden leave and $ofrecen arrive.';
  @override
  String get tituloOfertasRecibidasScreen => 'Offers received';
  @override
  String get nadieTePideNadaAhora =>
      'Nobody has offered you anything right now. Keep simming: offers arrive during the season.';
  @override
  String get ofertaAnterior => 'Previous offer';
  @override
  String get ofertaSiguiente => 'Next offer';
  @override
  String ofertaNDeM(int n, int m) => 'Offer $n of $m';
  @override
  String lineaJugadorOferta(
    String nombre,
    String posicion,
    int media,
    String contrato,
  ) => '$nombre · $posicion · $media · $contrato';
  @override
  String get ultimoAnioContrato => 'Last year';
  @override
  String aniosDeContrato(int n) => '$n years';
  @override
  String contratoAnioMillones(String anios, String millones) =>
      '$anios · $millones a year';
  @override
  String get tePiden => 'They want';
  @override
  String get teOfrecen => 'They offer';
  @override
  String get contraofertar => 'Counteroffer';
  @override
  String get teVasAQuedarCorto => 'You\'re going to fall short';
  @override
  String avisoLoCierras(String aviso) => '$aviso\n\nClose it anyway?';
  @override
  String get mejorNo => 'Better not';
  @override
  String get cerrarloIgual => 'Close it anyway';
  @override
  String get traspasoCerradoSimple => 'Trade completed.';
  @override
  String get fechaLimiteTraspasosNoMasOperaciones =>
      'The trade deadline has passed: no more deals can be closed this season.';
  @override
  String quienSeLlevaA(String nombre) => 'Who would take $nombre?';
  @override
  String quienSeLlevaPaquete(int n) => 'Who would take this $n-piece package?';
  @override
  String get ningunEquipoTeDariaNada =>
      'No team would give you anything worthwhile in return.';
  @override
  String get noTienesConQueConvencer =>
      'You have nothing to convince them with: neither your roster nor your picks get there without gutting you.';
  @override
  String get tituloTraspasos => 'Trades';
  @override
  String get fechaLimiteTraspasosBanner =>
      'The trade deadline has already passed this season: you can keep browsing the market, but can\'t close anything until next year.';
  @override
  String get noCuadraMeteATercero => 'Doesn\'t add up? Bring in a third team';
  @override
  String get cerrarTraspasoBtn => 'Close trade';
  @override
  String get tuEquipoLabel => 'Your team';
  @override
  String get tercerEquipoLabel => 'Third team';
  @override
  String get rivalLabel => 'Opponent';
  @override
  String get buscarQuienCompraria => 'Find who would buy him';
  @override
  String get buscarQueDarPorEl => 'Find what it would cost to get him';
  @override
  String anadirDe(String equipo) => 'Add from $equipo';
  @override
  String get eleccionesDeDraft => 'Draft picks';
  @override
  String get yaHasPuestoTodo =>
      'You\'ve already put everything this team had on the table.';
  @override
  String get sacarDeLaOperacion => 'Remove from the deal';
  @override
  String get noCuadraMeteATerceroLarga =>
      'Doesn\'t add up?\nBring in a third team';
  @override
  String get anadirEquipoBtn => 'Add team';
  @override
  String get tocaParaElegirJugadoresOPicks => 'Tap to pick\nplayers or picks';

  @override
  String get mercadoCerradoNoSeBuscan =>
      'The market is closed: the trade deadline has passed. You can\'t search for deals until next year.';
  @override
  String get ultimoAnioMinuscula => 'last year';

  @override
  String get tituloLegado => 'Legacy';
  @override
  String get explicacionPuntuacionCarreraTooltip =>
      'What the career score means';
  @override
  String get hallOfFame => 'Hall of Fame';
  @override
  String get pestanaCamisetasRetiradas => 'Retired jerseys';
  @override
  String get pestanaLideresHistoricos => 'All-time leaders';
  @override
  String get camisetaRetiradaSingular => 'Retired jersey';
  @override
  String get unDorsalQueNoVolvera => 'A number that will never be worn again';
  @override
  String get dorsalesQueNoVolveran => 'Numbers that will never be worn again';
  @override
  String get tituloPartidosDeLaSerie => 'Series games';
  @override
  String partidoNMarcador(
    int n,
    String local,
    int marcadorLocal,
    int marcadorVisitante,
    String visitante,
  ) => 'Game $n: $local $marcadorLocal - $marcadorVisitante $visitante';
  @override
  String get unNuevoNombreHof => 'A new name joins the Hall of Fame.';
  @override
  String nNombresNuevosHof(int n) => '$n new names join the Hall of Fame.';
  @override
  String entroEnAnio(int anio) => 'Inducted in $anio';
  @override
  String get queEsPuntuacionCarrera => 'What is the career score?';
  @override
  String get explicacionPuntuacionCarreraTexto =>
      'Sums up a player\'s whole career, not a single isolated number:\n\n• Individual awards (MVP, Defensive Player of the Year, All-NBA teams, Rookie of the Year, Most Improved).\n• Championship rings and NBA Cup titles.\n• The peak level he reached.\n• The points, assists and rebounds he racked up, relative to how many seasons he played.\n\nAt least 6 seasons played and a threshold to clear are required: a solid starter with no awards isn\'t enough — he has to have truly mattered.';
  @override
  String get entendido => 'Got it';
  @override
  String noSePudoCargarHof(String error) =>
      'The Hall of Fame couldn\'t be loaded.\n$error';
  @override
  String get todaviaNadieEnHof =>
      'Nobody\'s in the Hall of Fame yet. Only retired players with a truly great career get in: awards, rings and many years at a high level.';
  @override
  String get nuevoChip => 'NEW';

  @override
  String get enActivoLeyenda => 'Active: can still climb the ranking';
  @override
  String get todaviaNoHayEstadisticas => 'No stats to show yet.';
  @override
  String noSePudieronCargarCamisetas(String error) =>
      'The retired jerseys couldn\'t be loaded.\n$error';
  @override
  String get todaviaNoHayCamisetaEnLiga =>
      'No jersey has been retired in the league yet. When a legend retires you\'ll be able to honor them.';
  @override
  String get franquiciaLabel => 'Franchise';
  @override
  String get todaLaLigaOpcion => 'Whole league';
  @override
  String equipoTodaviaNoHaRetirado(String equipo) =>
      '$equipo hasn\'t retired any jersey yet.';
  @override
  String get tuEquipoBadge => 'YOUR TEAM';
  @override
  String get retiradaRealDeLaFranquicia => 'Real franchise retirement';
  @override
  String retiradaEnLaTemporada(String etiquetaTemporada) =>
      'Retired in $etiquetaTemporada';
  @override
  String nPartidos(int n) => n == 1 ? '1 game' : '$n games';
  @override
  String get enElVestuario => 'In the locker room';

  @override
  String get premioMvp => 'MVP';
  @override
  String get premioMejorDefensor => 'Defensive Player of the Year';
  @override
  String get premioRookieDelAno => 'Rookie of the Year';
  @override
  String get premioMasMejorado => 'Most Improved Player';
  @override
  String get premioPrimerQuinteto => 'All-NBA First Team';
  @override
  String get premioSegundoQuinteto => 'All-NBA Second Team';
  @override
  String get risingStars => 'Rising Stars';
  @override
  String premioMvpAllStar(String allStar) => '$allStar MVP';
  @override
  String premioMvpRisingStars(String risingStars) => '$risingStars MVP';
  @override
  String get tituloPremiosDeLaTemporada => 'Season awards';
  @override
  String noSePudieronCargarPremios(String error) =>
      'The awards couldn\'t be loaded.\n$error';
  @override
  String get verCalendarioBtn => 'View calendar';
  @override
  String statsPremioLinea(String pts, String ast, String reb) =>
      '$pts pts, $ast ast, $reb reb';

  @override
  String temporadaN(int n) => 'Season $n';
  @override
  String arrancaLaTemporada(int n, int anioInicio, int anioFin) =>
      'Season $n begins ($anioInicio-$anioFin)';
  @override
  String get plantillaHaCambiadoAviso =>
      'Your roster has changed: review it before the first game — an automatic lineup has been set for you.';
  @override
  String get tusEleccionesDelDraft => 'Your draft picks';
  @override
  String get seRetiranDeTuEquipo => 'Retiring from your team';
  @override
  String cuelgaLasBotasCon(int edad, int media) =>
      'Hangs it up at $edad, overall $media';
  @override
  String get hanDadoUnPasoAdelante => 'Took a step forward';
  @override
  String get empiezanABajar => 'Starting to decline';
  @override
  String get topDelDraft => 'Draft standouts';
  @override
  String get movimientosEnLaLiga => 'League moves';
  @override
  String recibeA(String equipoA, String jugadorB, String posicionB) =>
      '$equipoA gets $jugadorB ($posicionB)';
  @override
  String get tambienSeRetiran => 'Also retiring';
  @override
  String yNMas(int n) => 'and $n more';
  @override
  String posicionMediaSeparador(String posicion, int media) =>
      '$posicion · overall $media · ';

  @override
  String camisetaDeXRetirada(String nombre) => '$nombre\'s jersey retired.';
  @override
  String get tituloSeRetiran => 'Retiring';
  @override
  String get estaTemporadaNoSeRetiraNadie => 'Nobody is retiring this season.';
  @override
  String get restoDeLaLiga => 'Rest of the league';
  @override
  String get suCamisetaYaRetiradaSola =>
      ' · their jersey was already retired on its own (real legend)';
  @override
  String get camisetaRetiradaSufijo => ' · jersey retired';

  @override
  String get tituloResultadoPartido => 'Game result';
  @override
  String get columnaTotal => 'Total';
  @override
  String get columnaJugador => 'Player';
  @override
  String get columnaMin => 'Min';
  @override
  String get columnaPts => 'Pts';
  @override
  String get columnaAst => 'Ast';
  @override
  String get columnaReb => 'Reb';
  @override
  String get prefijoCuarto => 'Q';
  @override
  String get prefijoProrroga => 'OT';

  @override
  String get ordenPotencial => 'Potential';
  @override
  String get ordenMediaDesc => 'Overall ↓';
  @override
  String get ordenMediaAsc => 'Overall ↑';
  @override
  String get tituloDraft => 'Draft';
  @override
  String get eligiendoElRestoDeEquipos =>
      'The rest of the teams are picking...';
  @override
  String get queElijaLaCpuPorMi => 'Let the CPU pick for me';
  @override
  String get draftCompletado => 'Draft complete';
  @override
  String eleccionNumero(int n) => 'Pick number $n';
  @override
  String get teTocaElegir => 'Your turn to pick!';
  @override
  String get ordenarPorLabel => 'Sort by: ';

  @override
  String cuartosCopaSeSiembranAviso(String nbaCup) =>
      'The $nbaCup quarterfinals are seeded as soon as the group stage finishes across the whole league.';
  @override
  String get finalSeJuegaDesdeCalendarioAviso =>
      'The Final is played from the calendar: if you\'re a finalist, it\'s marked as just another day of your season.';
  @override
  String get cuartosDeFinalLabel => 'Quarterfinals';
  @override
  String get semifinalLabel => 'Semifinal';
  @override
  String finalDeLaCopaLabel(String nbaCup) => '$nbaCup Final';
  @override
  String get cuartosRondaLabel => 'Quarters';
  @override
  String get finalRondaLabel => 'Final';
  @override
  String get pendienteLabel => 'Pending';

  @override
  String get tituloResumenDeLaTemporada => 'Season summary';
  @override
  String noSePudoCargarResumen(String error) =>
      'The summary couldn\'t be loaded.\n$error';
  @override
  String temporadaConEtiqueta(String etiqueta) => 'Season $etiqueta';
  @override
  String get pestanaBalance => 'Overview';
  @override
  String puestoEnConferencia(String conferencia) =>
      'Position in the $conferencia';
  @override
  String puestoValor(int puesto) => '#$puesto';
  @override
  String puestoEnLaLigaNota(int puesto) => '#$puesto in the league';
  @override
  String get puntosPorPartidoLabel => 'Points per game';
  @override
  String encajadosLabel(String valor) => 'allowed $valor';
  @override
  String get diferenciaLabel => 'Point differential';
  @override
  String get porPartidoLabel => 'per game';
  @override
  String get mejorRachaLabel => 'Best streak';
  @override
  String get victoriasSeguidasLabel => 'wins in a row';
  @override
  String get peorRachaLabel => 'Worst streak';
  @override
  String get derrotasSeguidasLabel => 'losses in a row';
  @override
  String get mejorVictoriaLabel => 'Best win';
  @override
  String get peorDerrotaLabel => 'Worst loss';
  @override
  String partidosJugadosVictoriasPct(int partidos, int pct) =>
      '$partidos games · $pct% wins';
  @override
  String get todaviaNoHayClasificacion => 'No standings yet.';
  @override
  String get columnaPJ => 'GP';
  @override
  String posicionMedia(String posicion, int media) =>
      '$posicion · overall $media';

  @override
  String get allStarSubtituloPendiente =>
      'Played during the February break. Sim forward to All-Star weekend to see it.';
  @override
  String get risingStarsSubtituloPendiente =>
      'The best rookies against second-year players, the same weekend.';
  @override
  String get votacionAbreCuandoRuedeBalonAviso =>
      'Voting opens once the ball starts rolling. As you play through the season you\'ll see who\'s earning a spot and by how many votes.';
  @override
  String get verEstadisticasBtn => 'View stats';
  @override
  String mvpConNombre(String nombre) => 'MVP · $nombre';
  @override
  String lineaMvpPtsAstReb(int pts, int ast, int reb) =>
      '$pts pts · $ast ast · $reb reb';
  @override
  String escrutadoPorcentaje(int pct) => '$pct% of the votes counted...';
  @override
  String get recuentoCerradoAviso =>
      'Count closed: these were the ones chosen.';
  @override
  String votacionAbiertaConPorcentaje(int pct) =>
      'Voting open, with $pct% of the season played. Keep simming and the votes will shift.';
  @override
  String get votacionFinalLabel => 'Final vote';
  @override
  String get votacionDeAficionadosLabel => 'Fan vote';
  @override
  String conferenciaConNombre(String conferenciaLabel) =>
      '$conferenciaLabel Conference';
  @override
  String get titularesLabel => 'Starters';
  @override
  String get suplentesLabel => 'Reserves';
  @override
  String get seQuedanFueraLabel => 'Snubbed';
  @override
  String posicionValoracion(String posicion, String valoracion) =>
      '$posicion · $valoracion rating';

  @override
  String get noLlegoACompletarNingunaTemporada =>
      'Never completed a full season with you.';
  @override
  String get tituloTrayectoria => 'Career path';
  @override
  String get tituloPalmares => 'Honors';
  @override
  String get noRetirarElDorsal => 'Don\'t retire the number';
  @override
  String get retirarSuCamiseta => 'Retire the jersey';
  @override
  String get mvpFinalesCorto => 'Finals MVP';
  @override
  String get mvpDeLasFinalesLabel => 'Finals MVP';
  @override
  String quintetosAllNba(int n) => '$n All-NBA teams';
  @override
  String vecesConEtiqueta(int n, String etiqueta) => '$n $etiqueta';
  @override
  String copasGanadas(int n, String nbaCup) => '$n $nbaCup${n == 1 ? '' : 's'}';
  @override
  String get premioCampeonDeLaNba => 'NBA Champion';
  @override
  String get premioTercerQuinteto => 'All-NBA Third Team';
  @override
  String get premioMaximoAnotador => 'Scoring champion';
  @override
  String get premioMasMejoradoCorto => 'Most Improved';
  @override
  String get sinTitulosNiPremiosCarreraNba =>
      'No titles or awards in his NBA career.';
  @override
  String get sinTitulosNiPremiosIndividuales =>
      'No titles or individual awards.';
  @override
  String resumenCarreraTotales(int temporadas, String posicion, int partidos) =>
      '$temporadas seasons · $posicion · $partidos games';
  @override
  String totalesCarreraLinea(String pts, String ast, String reb) =>
      'Totals: $pts pts · $ast ast · $reb reb';
  @override
  String temporadasPreviasAviso(int n) =>
      '$n of them before you took over: there are no stats for those, the averages below are from your era.';
  @override
  String get antesDeTuPartidaTitulo => 'Before your save';
  @override
  String temporadasYaJugadasCuandoCogisteElEquipo(int n) =>
      '$n ${n == 1 ? 'season' : 'seasons'} already played by the time you took over the team.';
  @override
  String get produccionDeReferenciaAviso =>
      'His baseline production when the save started. There are no game-by-game stats from those years.';
  @override
  String sinEstadisticasDeCarreraAviso(String nombre) =>
      'There are no career stats for $nombre: he\'s from an era before the game\'s data coverage. His place in history is there, the numbers aren\'t.';
  @override
  String get suCarreraEnLaNbaReal => 'His real NBA career';
  @override
  String conEquipoEnLaNbaReal(String equipo) => 'With $equipo in the real NBA';
  @override
  String temporadasPartidos(int temporadas, int partidos) =>
      '$temporadas seasons · $partidos games';
  @override
  String rangoTemporadasPartidos(String desde, String hasta, int partidos) =>
      '$desde to $hasta · $partidos games';
  @override
  String rangoPartidos(String rango, int partidos) =>
      '$rango · $partidos games';
  @override
  String temporadaMinuscula(int n) => 'season $n';

  @override
  String get nadieTePropuestoNadaAhora =>
      'Nobody has proposed anything to you yet';
  @override
  String get unEquipoQuiereAUnoDeTusJugadores =>
      'A team wants one of your players';
  @override
  String nEquiposHanPreguntado(int n) =>
      '$n teams have asked about your players';
  @override
  String cuadroYResultadosDeLaCopa(String nbaCup) =>
      '$nbaCup bracket and results';
  @override
  String get seDesbloqueaAlTerminarFaseDeGrupos =>
      'Unlocks once the group stage ends';
  @override
  String get premiosDeFinDeTemporadaSubtitulo => 'End-of-season awards';
  @override
  String get seDesbloqueaAlTerminarTemporadaRegular =>
      'Unlocks once the regular season ends';
  @override
  String get bracketDeEliminatorias => 'Playoff bracket';
  @override
  String hallOfFameYCamisetasRetiradasSubtitulo(
    String hallOfFame,
    String camisetas,
  ) => '$hallOfFame and $camisetas';
  @override
  String get salarialLabel => 'Payroll';

  @override
  String get sigueDondeLoDejaste => 'Pick up where you left off';
  @override
  String get empiezaTuCarrera => 'Start your career';
  @override
  String get enQueRanuraQuieresEmpezar => 'Which slot do you want to start in?';
  @override
  String get eligeLaPartidaQueQuieresCargar =>
      'Choose the save you want to load';
  @override
  String get nuevaPartidaBtn => 'New game';
  @override
  String get cargarPartidaBtn => 'Load game';
  @override
  String sobrescribirLaPartidaN(int n) => 'Overwrite save $n?';
  @override
  String get sePerderaEnteraAviso =>
      'That slot already has a career in progress and it will be lost entirely: rosters, calendar and honors. This can\'t be undone.';
  @override
  String get sobrescribirBtn => 'Overwrite';
  @override
  String get eligeTuEquipoTitulo => 'Choose your team';
  @override
  String borrarLaPartidaN(int n) => 'Delete save $n?';
  @override
  String sePierdeCarreraDeAviso(String nombre) =>
      'The whole $nombre career will be lost: rosters, calendar, honors, legends and retired jerseys. This can\'t be undone.';
  @override
  String get borrarBtn => 'Delete';
  @override
  String get lasTresRanurasOcupadasAviso =>
      'All three slots are full: delete one to start fresh, or continue one you already have.';
  @override
  String get ranuraDeVersionCompleta => 'Full version slot';
  @override
  String partidaNumero(int n) => 'SAVE $n';
  @override
  String get borrarEstaPartidaTooltip => 'Delete this save';
  @override
  String get ranuraVaciaLabel => 'Empty slot';
  @override
  String get empezarBtn => 'Start';

  @override
  String get lesionLabel => 'Injury';
  @override
  String get recibesLabel => 'You receive: ';
  @override
  String get entregasLabel => 'You give up: ';
  @override
  String get traspasarBtn => 'Trade';
  @override
  String get potencialElite => 'Elite';
  @override
  String get potencialMuyAlto => 'Very high';
  @override
  String get potencialAlto => 'High';
  @override
  String get potencialMedio => 'Medium';
  @override
  String get potencialBajo => 'Low';
  @override
  String potencialTooltip(String etiqueta) => 'Potential: $etiqueta';
  @override
  String get volverAlMenuPrincipalTooltip => 'Back to main menu';

  @override
  String get margenSalarialEvento => 'Cap space';

  @override
  String get tuFranquiciaSeccion => 'Your franchise';

  @override
  String get proximoPartidoTitulo => 'Next game';

  @override
  String get enCasaLabel => 'Home';

  @override
  String get fueraLabel => 'Away';

  @override
  String get vsAbreviatura => 'VS';

  @override
  String get tituloPatrocinadores => 'Sponsors';
  @override
  String get explicacionPatrocinadores =>
      'Each sponsorship has several offers: the longer the deal, the less it pays per year. Whatever you sign ties up that slot until it expires.';
  @override
  String get patrocinioEstadioLabel => 'Arena sponsor';
  @override
  String get patrocinioCamisetaLabel => 'Jersey sponsor';
  @override
  String get patrocinioBebidaLabel => 'Official drink';
  @override
  String get patrocinioOcioLabel => 'Community sponsor';
  @override
  String fundadoEnAnio(int anio) => 'Founded in $anio';
  @override
  String get alAnioSufijo => 'a year';
  @override
  String sinPatrocinioFirmado(int ofertas) =>
      ofertas == 1 ? 'Unsigned · 1 offer' : 'Unsigned ·  offers';
  @override
  String margenPatrocinio(String importe) => '+$importe salary cap room';
  @override
  String get patrocinadoresBloqueados =>
      'Sponsors are part of the full version. Watch a video and all four are yours for this season.';
  @override
  String get verVideoPatrocinadores => 'WATCH VIDEO TO UNLOCK';
  @override
  String get videoSinTerminar =>
      "The video wasn't watched all the way through, so they stay locked. You can try again.";
}
