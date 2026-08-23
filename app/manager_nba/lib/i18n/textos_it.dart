part of 'textos.dart';

/// Italiano. I termini NBA che anche la stampa italiana lascia in inglese
/// (playoff, All-Star, NBA Cup) restano tali: tradurli suonerebbe più
/// strano dell'originale.
class TextosIt extends Textos {
  const TextosIt();

  @override
  TextosDeEventos get eventos => const EventosIt();

  @override
  String get aceptar => 'Conferma';
  @override
  String get cancelar => 'Annulla';
  @override
  String get cerrar => 'Chiudi';
  @override
  String get guardar => 'Salva';
  @override
  String get continuar => 'Continua';
  @override
  String get si => 'Sì';
  @override
  String get no => 'No';
  @override
  String get cargando => 'Caricamento…';

  @override
  String get nuevaPartida => 'Nuova partita';
  @override
  String get ajustes => 'Impostazioni';
  @override
  String get elegirEquipo => 'Scegli la tua squadra';
  @override
  String get sobrescribir => 'Sovrascrivi';
  @override
  String get ranuraOcupada => 'Questo slot ha già una partita salvata';
  @override
  String get avisoSobrescribir =>
      'Se continui, la partita salvata qui verrà cancellata.';

  @override
  String get modoOscuro => 'Modalità scura';
  @override
  String get modoOscuroDetalle => 'Grigi e neri invece dei bianchi accesi';
  @override
  String get idioma => 'Lingua';
  @override
  String get idiomaDetalle => 'La lingua di tutto il gioco';

  @override
  String get calendario => 'Calendario';
  @override
  String get calendarioDetalle => 'Guarda la stagione e simula le partite';
  @override
  String get tuEquipo => 'La tua squadra';
  @override
  String get tuEquipoDetalle => 'Roster e quintetto';
  @override
  String get entrenador => 'Allenatore';
  @override
  String get banquilloVacante => 'La tua panchina è libera';
  @override
  String get clasificacion => 'Classifica';
  @override
  String get clasificacionDetalle => 'Squadre e leader statistici';
  @override
  String get mercado => 'Mercato';
  @override
  String get traspasos => 'Scambi';
  @override
  String get traspasosDetalle => 'Tratta scambi con il resto della lega';
  @override
  String get ofertasRecibidas => 'Offerte ricevute';
  @override
  String get agenciaLibre => 'Free agency';
  @override
  String get agenciaLibreDetalle => 'Giocatori svincolati e spazio salariale';
  @override
  String get competicion => 'Competizione';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Votazione, All-Star Game e MVP';
  @override
  String get resumenTemporada => 'Riepilogo della stagione';
  @override
  String get resumenTemporadaDetalle => 'Record, tutte le partite e le medie';
  @override
  String get playoffs => 'Playoff';
  @override
  String get premios => 'Premi';
  @override
  String get legado => 'Eredità';

  @override
  String get record => 'Record';
  @override
  String get masaSalarial => 'Monte ingaggi';
  @override
  String get temporada => 'Stagione';

  @override
  String get sinEntrenador => 'Senza allenatore';
  @override
  String get sinEntrenadorDetalle =>
      'La tua squadra gioca senza allenatore. Ingaggia qualcuno dalla lista qui sotto.';
  @override
  String get despedir => 'Esonerare';
  @override
  String get contratar => 'Ingaggiare';
  @override
  String get negociar => 'Tratta';
  @override
  String get ofrecer => 'Offri';
  @override
  String get sueldo => 'Stipendio';
  @override
  String get duracion => 'Durata';
  @override
  String get ataque => 'Attacco';
  @override
  String get defensa => 'Difesa';
  @override
  String get desarrollo => 'Sviluppo';
  @override
  String get equilibrado => 'Equilibrato';
  @override
  String get especialistaAtaque => 'Specialista d\'attacco';
  @override
  String get especialistaDefensa => 'Specialista di difesa';
  @override
  String get formadorDeJovenes => 'Formatore di giovani';
  @override
  String get loQuePuedesOfrecer => 'Quello che puoi offrire';
  @override
  String get topeDeLaFranquicia => 'Tetto della franchigia';
  @override
  String get finiquitos => 'Buonuscite degli allenatori esonerati';
  @override
  String get aceptariaLaOferta => 'Accetterebbe questa offerta.';
  @override
  String get todaviaNo =>
      'Non ancora. Con più soldi o più anni potrebbe cambiare idea.';
  @override
  String get noVaAAceptar =>
      'Non accetterà: il tuo progetto è troppo lontano e i soldi non bastano.';

  @override
  String anios(int n) => n == 1 ? '1 stagione' : '$n stagioni';
  @override
  String alAnio(String importe) => '$importe all\'anno';

  @override
  String get pestanaEquipos => 'Squadre';
  @override
  String get pestanaJugadores => 'Giocatori';
  @override
  String get conferenciaEste => 'Est';
  @override
  String get conferenciaOeste => 'Ovest';
  @override
  String get fronteraPlayIn => 'Play-In';
  @override
  String get fronteraFueraDePlayoffs => 'Fuori dai playoff';
  @override
  String get ordenPuntos => 'Punti';
  @override
  String get ordenAsistencias => 'Assist';
  @override
  String get ordenRebotes => 'Rimbalzi';
  @override
  String get sinPartidosJugados => 'Non è stata ancora giocata nessuna partita';
  @override
  String edadJugador(int n) => '$n anni';
  @override
  String mediaJugador(int n) => 'Valutazione $n';
  @override
  String get estaTemporada => 'Questa stagione';
  @override
  String get todaviaNoHaJugado => 'Non ha ancora giocato';
  @override
  String get contrato => 'Contratto';
  @override
  String get intentarTraspasar => 'Tentare la cessione';
  @override
  String traspasoCerradoCon(String equipo) => 'Scambio concluso con $equipo.';
  @override
  String get fechaLimiteTraspasosPasada => 'La scadenza per gli scambi è già passata: questa stagione non si possono concludere altre operazioni.';

  @override
  String get tituloConferenciaEste => 'CONFERENCE EST';
  @override
  String get tituloConferenciaOeste => 'CONFERENCE OVEST';

  @override
  String comoFicharA(String nombre) => 'Come ingaggiare $nombre?';
  @override
  String get sinConQueConvencerles => 'Al momento non hai nulla di convincente da offrire: né la tua rosa né le tue scelte bastano senza indebolirti.';

  @override
  String get campeonesDeLaNba => 'Campioni NBA';
  @override
  String get campeonesDeLaCup => 'Campioni della NBA Cup';
  @override
  String get exclamacionCampeones => 'CAMPIONI!';
  @override
  String seLlevaElTitulo(String nombre) => '$nombre si aggiudica il titolo.';
  @override
  String get enhorabuenaAnillo => "Complimenti! Ce l'avete fatta: l'anello è vostro. La prossima stagione toccherà difenderlo.";
  @override
  String get enhorabuenaCup => "Complimenti! Avete vinto la NBA Cup. L'anello è un'altra storia: la stagione continua.";
  @override
  String get aCelebrarlo => 'Si festeggia!';
  @override
  String mvpDeLasFinales(String nombre) => 'MVP delle Finals · $nombre';
  @override
  String partidosDeSerie(int n) => n == 1 ? 'in 1 partita' : 'in $n partite';
  @override
  String get verEstadisticas => 'Vedi statistiche';
  @override
  String get confirmarSimularTitulo => 'Simulare fino a questo giorno?';
  @override
  String get seJugaraProximoPartido => 'Verrà giocata la tua prossima partita.';
  @override
  String seJugaranDeUnaVez(int partidos, int dia, int mes) => 'Verranno giocate tutte insieme le $partidos partite che ti restano fino al $dia/$mes.';
  @override
  String get simular => 'Simula';
  @override
  String finalCupVs(String enfrentamiento) => 'Finale NBA Cup — $enfrentamiento';
  @override
  String get tituloEventoFinAgenciaLibre => 'Fine del mercato dei free agent';
  @override
  String get tituloEventoFechaLimiteTraspasos => 'Scadenza per gli scambi';
  @override
  String get tituloEventoAllStar => 'Weekend delle stelle';
  @override
  String get descEventoFinAgenciaLibre => 'Da qui in poi non si possono più ingaggiare free agent.';
  @override
  String get descEventoFechaLimiteTraspasos => 'Ultimo giorno per fare scambi in questa stagione.';
  @override
  String get descEventoAllStar => 'Questo weekend non hai partite. Approfittane per controllare la Classifica.';
  @override
  List<String> get nombresMeses => ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];
  @override
  List<String> get diasSemanaAbrev => ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
  @override
  String get unPartido => '1 partita';
  @override
  String get simularUnPartido => 'Simula 1 partita';
  @override
  String get unaSemana => '1 settimana';
  @override
  String get simularUnaSemana => 'Simula 1 settimana';
  @override
  String get unMes => '1 mese';
  @override
  String get simularUnMes => 'Simula 1 mese';
  @override
  String get simularTemporadaEntera => 'Stagione intera';
  @override
  String get verBracketCompleto => 'Vedi tabellone completo';
  @override
  String get empezarSiguienteTemporada => 'Inizia la prossima stagione';
  @override
  String get simularPartidoDePlayoffs => 'Simula partita di playoff';
  @override
  String get noClasificasteAPlayoffs => 'Non ti sei qualificato per i playoff questa stagione.';
  @override
  String get simularPlayoffsCompletos => 'Simula tutti i playoff';
  @override
  String get serieDecididaFaltaResto => 'La tua serie è decisa — manca il resto del tabellone per sapere chi sarà il tuo prossimo avversario.';
  @override
  String get simularRestoDeRonda => 'Simula il resto del turno';

  @override
  String ofertaTitulo(int n) => n == 1 ? "Hai ricevuto un'offerta" : 'Hai delle offerte';
  @override
  String ofertaMensaje(int n) => n == 1 ? 'Una squadra ha chiesto di un tuo giocatore e ha messo una proposta sul tavolo.' : '$n squadre hanno chiesto dei tuoi giocatori.';
  @override
  String get masTarde => 'Più tardi';
  @override
  String verOfertaBoton(int n) => n == 1 ? "Vedi l'offerta" : 'Vedi le offerte';
  @override
  String get preguntaSeguirSimulando => 'Hai raggiunto questa scadenza della stagione. Continui a simulare o ti fermi per fare le tue mosse?';
  @override
  String get irAAgenciaLibre => 'Vai al mercato free agent';
  @override
  String get irATraspasos => 'Vai agli scambi';
  @override
  String get seguirSimulando => 'Continua a simulare';
  @override
  String get allStarWeekendMayus => 'ALL STAR WEEKEND';
  @override
  String resultadoAllStar(
      {required bool esteGana,
      required int local,
      required int visitante,
      String? mvp}) => 'L\'All-Star Game è stato giocato. ${esteGana ? "L'Est" : "L'Ovest"} vince la partita $local-$visitante.${mvp == null ? "" : "\n\nMVP della partita: $mvp."}';
  @override
  String get verFinDeSemana => 'Vedi il weekend';
  @override
  String finalCupProgramada(String fecha) => 'Sei in finale di NBA Cup! La giochi il $fecha: simula fino a quel giorno.';
  @override
  String fechaCorta(int dia, int mes) => '$dia ${nombresMeses[mes - 1].toLowerCase()}';

  @override
  String get sinPartidosTitulo => 'Nessuna partita';
  @override
  String resumenPartidos(int n, int ganados, int perdidos) {
    final g = ganados;
    final p = perdidos;
    return '$n partite · $g-$p';
  }
  @override
  String get lesionesActivasAhora => 'Infortuni attivi in questo momento';
  @override
  String get verLosPremios => 'Vedi i premi';

  @override
  String get playoffsSeSiembranAlTerminar => 'I playoff vengono composti al termine della tua stagione regolare (82 partite).';
  @override
  String get verCelebracion => 'Vedi la celebrazione';
  @override
  String get siguienteTemporadaBtn => 'Prossima stagione';
  @override
  String get resolverPlayIn => 'Risolvi il Play-in';
  @override
  String get simularRondaCompleta => 'Simula il turno completo';
  @override
  String get simularTodoBtn => 'Simula tutto';
  @override
  String get bracketTitulo => 'Tabellone';
  @override
  String get primeraRondaEsperaPlayIn => "Il primo turno non inizia finché il Play-in non decide chi sarà il 7° e l'8°.";
  @override
  String get playInGanadorEntra7 => 'Il vincitore entra come 7°';
  @override
  String get playInPerdedorEliminado => 'Il perdente viene eliminato';
  @override
  String get playInGanadorEntra8 => 'Il vincitore entra come 8°';
  @override
  String get conferenciaOesteTitulo => 'Conference Ovest';
  @override
  String get conferenciaEsteTitulo => 'Conference Est';
  @override
  String get sinPlayIn => 'Nessun play-in';
  @override
  String get jugarBtn => 'Gioca';
  @override
  String get porJugar => 'Da giocare';
  @override
  String get rondaPrimeraRonda => 'Primo turno';
  @override
  String get rondaSemifinalConferencia => 'Semifinale di conference';
  @override
  String get rondaFinalConferencia => 'Finale di conference';
  @override
  String get rondaFinalNba => 'Finali NBA';
  @override
  List<String> get nombresDeRondaBracket => ['Primo\nturno', 'Semifinali', 'Finale\nOvest', 'FINALI\nNBA', 'Finale\nEst', 'Semifinali', 'Primo\nturno'];
  @override
  String get esperandoAlPlayIn => 'In attesa del Play-in';
  @override
  String get porDefinir => 'Da definire';

  @override
  String despedirConfirmacion(String nombre) => 'Esonerare $nombre?';
  @override
  String despedirConTiempoRestante(int anios, String importe) => "Gli restano $anios ${anios == 1 ? 'stagione' : 'stagioni'} di contratto e vanno pagate comunque: $importe che NON potrai spendere per il suo sostituto finché non saranno concluse.";
  @override
  String get despedirSinContrato => 'Diventerà free agent e potrà firmare con qualsiasi squadra. Finché non ingaggi qualcun altro, la tua squadra giocherà senza allenatore.';
  @override
  String get ficharPorElMinimoBtn => 'Ingaggia al minimo';
  @override
  String get noHayEntrenadorSinEquipo => "Non c'è nessun allenatore senza squadra";
  @override
  String get dirigiendoAOtroEquipo => "Allena un'altra squadra";
  @override
  String get sePuedeOfertarPeroTrabajo => "Puoi fare loro un'offerta, ma hanno già un lavoro: serve molto di più per convincerli, e la squadra a cui lo porti via cercherà subito un sostituto.";
  @override
  String get avisoObligatorioTexto => 'Non puoi giocare senza allenatore. Ingaggia qualcuno per continuare: se nessuno ti convince o il budget non basta, puoi sempre ingaggiarne uno al minimo.';
  @override
  String mediaDeTuEquipoEs(int n) => 'La media della tua squadra è $n. Più forte è un allenatore, più ambizioso deve essere il progetto — e i soldi coprono solo parte della differenza.';
  @override
  String pideAlAnioYTemporadas(String importe, int anios) => "Chiede $importe all'anno e $anios stagioni.";
  @override
  String noLlegaMasaSalarial(String importe) => 'Il tuo monte ingaggi non basta: puoi offrire al massimo $importe.';
  @override
  String get tuEntrenadorLabel => 'Il tuo allenatore';
  @override
  String get masaSalarialConBanquillo => 'Monte ingaggi (staff incluso)';
  @override
  String get porEncimaDelTopeSoloMinimo => 'Sei sopra il tetto salariale: puoi ingaggiare solo allo stipendio minimo.';
  @override
  String get sueldoEntrenadorCuentaEnMasa => 'Lo stipendio dell\'allenatore conta nel tuo monte ingaggi: quello che spendi qui non lo hai per i giocatori.';
  @override
  String contratoResumen(String importeAlAnio, String duracion) => '$importeAlAnio · contratto di $duracion';
  @override
  String trayectoriaEstaTemporada(int victorias, int derrotas) => 'Questa stagione: $victorias-$derrotas';
  @override
  String temporadasDirigiendo(int n) => '$n stagioni da allenatore';
  @override
  String anillos(int n) => n == 1 ? '1 anello' : '$n anelli';
  @override
  String entrenadorDelAnio(int n) => n == 1 ? "1 volta allenatore dell'anno" : '$n volte allenatore dell\'anno';
  @override
  String dirigeAEquipo(String apodo) => 'Allena $apodo';
  @override
  String pideImportePorAnios(String importe, int anios) => 'Chiede $importe × $anios ${anios == 1 ? "anno" : "anni"}';
  @override
  String get noCabeEnPresupuesto => 'Non rientra nel tuo budget per lo staff';
  @override
  String get proyectoLeQuedaLejos => 'Il tuo progetto è troppo lontano dalle sue aspettative';
  @override
  String get asuPrecioNo => 'Al suo prezzo direbbe di no; con più soldi, forse';
  @override
  String get volver => 'Indietro';
  @override
  String get elegirEsteEquipo => 'Scegli questa squadra';

  @override
  String mediaDelEquipo(int n) => 'Media della squadra: $n';
  @override
  String get torneoDeMitadDeTemporada => 'Torneo di metà stagione';
  @override
  String get campeonNba => 'Campione NBA';

  @override
  String descripcionHueco(bool esTitular, String nombrePosicion) => esTitular ? 'titolare in $nombrePosicion' : 'riserva in $nombrePosicion';
  @override
  String get tituloTitular => 'Titolare';
  @override
  String get tituloSuplente => 'Riserva';
  @override
  Map<String, String> get nombresDePosiciones => {'PG': 'Playmaker (PG)', 'SG': 'Guardia (SG)', 'SF': 'Ala piccola (SF)', 'PF': 'Ala grande (PF)', 'C': 'Centro (C)'};
  @override
  String get minutosTitularLabel => 'Minuti da titolare: ';
  @override
  String fueraPorLesion(String nombres) => 'Fuori per infortunio: $nombres';
  @override
  String get alinearAutomaticamenteBtn => 'Schiera automaticamente';
  @override
  String get pestanaAlineacion => 'Formazione';
  @override
  String get pestanaEstadisticas => 'Statistiche';
  @override
  String alineacionDeEquipo(String equipo) => 'Formazione: $equipo';
  @override
  String get tusPicksDeDraft => 'Le tue scelte al draft';
  @override
  String get empezarTemporadaBtn => 'Inizia la stagione';
  @override
  String get guardarRotacionBtn => 'Salva la formazione';
  @override
  String get elegirJugadorPlaceholder => '— scegli giocatore —';
  @override
  String huecoConJugador(String etiqueta, String nombre, String posicion, int media) => '$etiqueta: $nombre ($posicion, valutazione $media)';
  @override
  String lesionConDetalle(String motivo, int partidos, String fecha) => '$motivo ($partidos partite) — rientro il $fecha — nel frattempo giocherà la riserva';
  @override
  String get fueraDeSusDosPosiciones => "Fuori dai suoi due ruoli (renderà un po' peggio)";
  @override
  String get sinPartidosJugadosTemporada => 'Nessuna partita giocata questa stagione';
  @override
  String get estrellaAtaqueLabel => 'Stella offensiva';
  @override
  String get estrellaDefensaLabel => 'Stella difensiva';
  @override
  String get sextoHombreLabel => 'Sesto uomo';
  @override
  String get ningunaOpcion => 'Nessuna';
  @override
  String get sinPicksPropios => 'Non ti resta nessuna scelta di tua proprietà: le hai scambiate tutte.';
  @override
  String get traspasadoATiPorOtroEquipo => "Scambiato a te da un'altra squadra";
  @override
  String get ataqueYDefensaTitulo => 'Attacco e difesa';
  @override
  String get quintetoInicial => 'Quintetto titolare';
  @override
  String get rotacionCompleta => 'Rotazione completa';

  @override
  String nombreConPosicionYMedia(String nombre, String posicion, int media) => '$nombre ($posicion, valutazione $media)';
  @override
  String yaAsignadoIntercambio(String descripcionHueco) => 'attualmente $descripcionHueco — verranno scambiati';
  @override
  String get tituloTusPicksDeDraft => 'Le tue scelte al draft';

  @override
  String lesionSimple(String motivo, String fecha) => '$motivo, rientro il $fecha';

  @override
  String get rechazar => 'Rifiuta';
  @override
  String get proponer => 'Proponi';
  @override
  String get tituloAgenciaLibre => 'Free agency';
  @override
  String get verTuPlantilla => 'Vedi la tua rosa';
  @override
  String get agenciaLibreCerrada => 'La free agency si è chiusa per questa stagione: la scadenza è passata. Puoi continuare a guardare il mercato, ma non firmare nessuno fino al prossimo anno.';
  @override
  String get completarConContratosMinimos => 'Completa con contratti minimi';
  @override
  String get plantillaCompletada => 'Rosa completata.';
  @override
  String fichadosPorElMinimo(int n) => 'Firmati $n giocatori al minimo.';
  @override
  String get quePuedaPagar => 'Accessibile';
  @override
  String get noQuedaNadieEnMercado => 'Non resta nessuno sul mercato.';
  @override
  String get nadieEncajaConFiltro => 'Nessuno sul mercato corrisponde a quanto richiesto. Prova a togliere un filtro.';
  @override
  String contadorAgentesLibres(int n) => '$n free agent';
  @override
  String contadorAgentesLibresFiltrado(int visibles, int total) => '$visibles free agent su $total (filtri attivi)';
  @override
  String get empezarLaTemporadaBtn => 'Inizia la stagione';
  @override
  String get completaLaPlantillaParaContinuar => 'Completa la rosa per continuare';
  @override
  String plantillaAlCompletoConN(int n) => 'Rosa al completo: $n giocatori.';
  @override
  String plantillaDeMax(int n, int max) => 'Rosa: $n di $max giocatori.';
  @override
  String faltanFichajesParaMinimo(int n) => 'Mancano $n ingaggi per il minimo.';
  @override
  String otrosEquiposJuegan(int max, int n, int atras) => 'Le altre 29 squadre giocano con $max. Con $n puoi iniziare, ma sei indietro di $atras.';
  @override
  String sinRecambioEn(String lista) => 'Nessun cambio in: $lista.';
  @override
  String libresBajoElTope(String cantidad) => '$cantidad liberi sotto il tetto.';
  @override
  String get yaNoNegocia => 'Non negozia più';
  @override
  String negociarConN(int n) => 'Negozia ($n)';
  @override
  String ofertaA(String nombre) => 'Offerta a $nombre';
  @override
  String pideAlAnio(String cantidad) => 'Chiede $cantidad all\'anno';
  @override
  String sueldoLabel(String cantidad) => 'Stipendio: $cantidad';
  @override
  String get insultoOferta => 'Lo prenderà come un insulto.';
  @override
  String get ofertaImprobable => 'Molto improbabile che accetti così: lo stipendio, gli anni o entrambi sono insufficienti.';
  @override
  String get ofertaSePuedePensar => 'Potrebbe pensarci; non è del tutto convinto.';
  @override
  String get ofertaProbableAceptar => 'È probabile che accetti.';
  @override
  String get ofertaSeguraAceptar => 'Quasi certo che dirà di sì.';
  @override
  String get aniosLabelDosPuntos => 'Anni: ';
  @override
  String get tituloRenovaciones => 'Rinnovi';
  @override
  String get ningunContratoSeAcaba => 'Nessun contratto in scadenza: la rosa resta legata per un altro anno.';
  @override
  String continuarConNAgenciaLibre(int n) => 'Continua ($n vanno in free agency)';
  @override
  String porEncimaDelTope(String cantidad) => 'Sei $cantidad sopra il tetto salariale: puoi offrire solo contratti minimi.';
  @override
  String teQuedanBajoElTope(String espacio, String tope) => 'Ti restano $espacio sotto il tetto di $tope.';
  @override
  String get seAcaboLaNegociacion => 'Trattativa\nconclusa';
  @override
  String ofrecerConN(int n) => 'Offri ($n)';
  @override
  String subtituloRenovacion(String posicion, int edad, int media, String cobraba, String pide) => '$posicion · $edad anni · valutazione $media\nGuadagnava $cobraba · chiede $pide';
  @override
  String get cerramosElTraspaso => 'Chiudiamo lo scambio?';
  @override
  String seVanYLlegan(String piden, String ofrecen) => 'Se ne vanno $piden e arrivano $ofrecen.';
  @override
  String get tituloOfertasRecibidasScreen => 'Offerte ricevute';
  @override
  String get nadieTePideNadaAhora => 'Al momento nessuno ti ha proposto nulla. Continua a simulare: le offerte arrivano durante la stagione.';
  @override
  String get ofertaAnterior => 'Offerta precedente';
  @override
  String get ofertaSiguiente => 'Offerta successiva';
  @override
  String ofertaNDeM(int n, int m) => 'Offerta $n di $m';
  @override
  String lineaJugadorOferta(
          String nombre, String posicion, int media, String contrato) => '$nombre · $posicion · $media · $contrato';
  @override
  String get ultimoAnioContrato => 'Ultimo anno';
  @override
  String aniosDeContrato(int n) => '$n anni';
  @override
  String contratoAnioMillones(String anios, String millones) => '$anios · $millones all\'anno';
  @override
  String get tePiden => 'Ti chiedono';
  @override
  String get teOfrecen => 'Ti offrono';
  @override
  String get contraofertar => 'Controproposta';
  @override
  String get teVasAQuedarCorto => 'Rimarrai corto';
  @override
  String avisoLoCierras(String aviso) => '$aviso\n\nLo chiudi comunque?';
  @override
  String get mejorNo => 'Meglio di no';
  @override
  String get cerrarloIgual => 'Chiudi comunque';
  @override
  String get traspasoCerradoSimple => 'Scambio concluso.';
  @override
  String get fechaLimiteTraspasosNoMasOperaciones => 'La scadenza degli scambi è passata: non si possono chiudere altre operazioni questa stagione.';
  @override
  String quienSeLlevaA(String nombre) => 'Chi prenderebbe $nombre?';
  @override
  String quienSeLlevaPaquete(int n) => 'Chi prenderebbe il pacchetto da $n pezzi?';
  @override
  String get ningunEquipoTeDariaNada => 'Nessuna squadra ti darebbe nulla che valga la pena in cambio.';
  @override
  String get noTienesConQueConvencer => 'Non hai nulla per convincerli: né la tua rosa né le tue scelte bastano senza smembrarti.';
  @override
  String get tituloTraspasos => 'Scambi';
  @override
  String get fechaLimiteTraspasosBanner => 'La scadenza degli scambi è già passata questa stagione: puoi continuare a guardare il mercato, ma non chiudere nulla fino al prossimo anno.';
  @override
  String get noCuadraMeteATercero => 'Non torna? Aggiungi una terza squadra';
  @override
  String get cerrarTraspasoBtn => 'Chiudi scambio';
  @override
  String get tuEquipoLabel => 'La tua squadra';
  @override
  String get tercerEquipoLabel => 'Terza squadra';
  @override
  String get rivalLabel => 'Avversario';
  @override
  String get buscarQuienCompraria => 'Cerca chi lo comprerebbe';
  @override
  String get buscarQueDarPorEl => 'Cerca cosa servirebbe per prenderlo';
  @override
  String anadirDe(String equipo) => 'Aggiungi da $equipo';
  @override
  String get eleccionesDeDraft => 'Scelte al draft';
  @override
  String get yaHasPuestoTodo => 'Hai già messo sul tavolo tutto ciò che questa squadra aveva disponibile.';
  @override
  String get sacarDeLaOperacion => 'Rimuovi dall\'operazione';
  @override
  String get noCuadraMeteATerceroLarga => 'Non torna?\nAggiungi una terza squadra';
  @override
  String get anadirEquipoBtn => 'Aggiungi squadra';
  @override
  String get tocaParaElegirJugadoresOPicks => 'Tocca per scegliere\ngiocatori o scelte';

  @override
  String get mercadoCerradoNoSeBuscan => 'Il mercato è chiuso: la scadenza degli scambi è passata. Non si possono cercare operazioni fino al prossimo anno.';
  @override
  String get ultimoAnioMinuscula => 'ultimo anno';

  @override
  String get tituloLegado => 'Eredità';
  @override
  String get explicacionPuntuacionCarreraTooltip => 'Cosa significa il punteggio di carriera';
  @override
  String get hallOfFame => 'Hall of Fame';
  @override
  String get pestanaCamisetasRetiradas => 'Maglie ritirate';
  @override
  String get pestanaLideresHistoricos => 'Record all-time';
  @override
  String get camisetaRetiradaSingular => 'Maglia ritirata';
  @override
  String get unDorsalQueNoVolvera => 'Un numero che non verrà più indossato';
  @override
  String get dorsalesQueNoVolveran => 'Numeri che non verranno più indossati';
  @override
  String get tituloPartidosDeLaSerie => 'Partite della serie';
  @override
  String partidoNMarcador(int n, String local, int marcadorLocal, int marcadorVisitante, String visitante) => 'Partita $n: $local $marcadorLocal - $marcadorVisitante $visitante';
  @override
  String get unNuevoNombreHof => 'Un nuovo nome entra nella Hall of Fame.';
  @override
  String nNombresNuevosHof(int n) => '$n nuovi nomi entrano nella Hall of Fame.';
  @override
  String entroEnAnio(int anio) => 'Entrato nel $anio';
  @override
  String get queEsPuntuacionCarrera => 'Cos\'è il punteggio di carriera?';
  @override
  String get explicacionPuntuacionCarreraTexto => 'Riassume l\'intera carriera di un giocatore, non un semplice numero isolato:\n\n• Premi individuali (MVP, Miglior Difensore, quintetti All-NBA, Rookie dell\'Anno, Giocatore più Migliorato).\n• Anelli da campione e titoli della NBA Cup.\n• Il picco di livello raggiunto.\n• I punti, gli assist e i rimbalzi accumulati, in base a quante stagioni ha giocato.\n\nServono almeno 6 stagioni giocate e superare una soglia per entrare: un titolare solido senza premi non basta, deve essere stato davvero importante.';
  @override
  String get entendido => 'Capito';
  @override
  String noSePudoCargarHof(String error) => 'Impossibile caricare la Hall of Fame.\n$error';
  @override
  String get todaviaNadieEnHof => 'Non c\'è ancora nessuno nella Hall of Fame. Entrano solo giocatori già ritirati con una carriera delle grandi: premi, anelli e tanti anni ad alto livello.';
  @override
  String get nuevoChip => 'NUOVO';

  @override
  String get enActivoLeyenda => 'In attività: può ancora salire in classifica';
  @override
  String get todaviaNoHayEstadisticas => 'Non ci sono ancora statistiche da mostrare.';
  @override
  String noSePudieronCargarCamisetas(String error) => 'Impossibile caricare le maglie ritirate.\n$error';
  @override
  String get todaviaNoHayCamisetaEnLiga => 'Non è ancora stata ritirata nessuna maglia nella lega. Quando una leggenda si ritira potrai onorarla.';
  @override
  String get franquiciaLabel => 'Franchigia';
  @override
  String get todaLaLigaOpcion => 'Tutta la lega';
  @override
  String equipoTodaviaNoHaRetirado(String equipo) => '$equipo non ha ancora ritirato nessuna maglia.';
  @override
  String get tuEquipoBadge => 'LA TUA SQUADRA';
  @override
  String get retiradaRealDeLaFranquicia => 'Ritiro reale della franchigia';
  @override
  String retiradaEnLaTemporada(String etiquetaTemporada) => 'Ritirata nella $etiquetaTemporada';
  @override
  String nPartidos(int n) => n == 1 ? '1 partita' : '$n partite';
  @override
  String get enElVestuario => 'Nello spogliatoio';

  @override
  String get premioMvp => 'MVP';
  @override
  String get premioMejorDefensor => 'Miglior Difensore';
  @override
  String get premioRookieDelAno => 'Rookie dell\'Anno';
  @override
  String get premioMasMejorado => 'Giocatore più Migliorato';
  @override
  String get premioPrimerQuinteto => 'Miglior Quintetto';
  @override
  String get premioSegundoQuinteto => 'Secondo Quintetto';
  @override
  String get risingStars => 'Rising Stars';
  @override
  String premioMvpAllStar(String allStar) => 'MVP dell\'$allStar';
  @override
  String premioMvpRisingStars(String risingStars) => 'MVP del $risingStars';
  @override
  String get tituloPremiosDeLaTemporada => 'Premi della stagione';
  @override
  String noSePudieronCargarPremios(String error) => 'Impossibile caricare i premi.\n$error';
  @override
  String get verCalendarioBtn => 'Vedi calendario';
  @override
  String statsPremioLinea(String pts, String ast, String reb) => '$pts pt, $ast ast, $reb rmb';

  @override
  String temporadaN(int n) => 'Stagione $n';
  @override
  String arrancaLaTemporada(int n, int anioInicio, int anioFin) => 'Inizia la stagione $n ($anioInicio-$anioFin)';
  @override
  String get plantillaHaCambiadoAviso => 'La tua rosa è cambiata: controllala prima della prima partita — è stata preparata una formazione automatica.';
  @override
  String get tusEleccionesDelDraft => 'Le tue scelte al draft';
  @override
  String get seRetiranDeTuEquipo => 'Si ritirano dalla tua squadra';
  @override
  String cuelgaLasBotasCon(int edad, int media) => 'Appende le scarpette al chiodo a $edad anni, valutazione $media';
  @override
  String get hanDadoUnPasoAdelante => 'Hanno fatto un passo avanti';
  @override
  String get empiezanABajar => 'Iniziano a calare';
  @override
  String get topDelDraft => 'Top del draft';
  @override
  String get movimientosEnLaLiga => 'Movimenti nella lega';
  @override
  String recibeA(String equipoA, String jugadorB, String posicionB) => '$equipoA riceve $jugadorB ($posicionB)';
  @override
  String get tambienSeRetiran => 'Si ritirano anche';
  @override
  String yNMas(int n) => 'e altri $n';
  @override
  String posicionMediaSeparador(String posicion, int media) => '$posicion · valutazione $media · ';

  @override
  String camisetaDeXRetirada(String nombre) => 'Maglia di $nombre ritirata.';
  @override
  String get tituloSeRetiran => 'Si ritirano';
  @override
  String get estaTemporadaNoSeRetiraNadie => 'Questa stagione nessuno si ritira.';
  @override
  String get restoDeLaLiga => 'Resto della lega';
  @override
  String get suCamisetaYaRetiradaSola => ' · la sua maglia è già stata ritirata da sola (leggenda reale)';
  @override
  String get camisetaRetiradaSufijo => ' · maglia ritirata';

  @override
  String get tituloResultadoPartido => 'Risultato della partita';
  @override
  String get columnaTotal => 'Totale';
  @override
  String get columnaJugador => 'Giocatore';
  @override
  String get columnaMin => 'Min';
  @override
  String get columnaPts => 'Pt';
  @override
  String get columnaAst => 'Ass';
  @override
  String get columnaReb => 'Rmb';
  @override
  String get prefijoCuarto => 'Q';
  @override
  String get prefijoProrroga => 'P';

  @override
  String get ordenPotencial => 'Potenziale';
  @override
  String get ordenMediaDesc => 'Valutazione ↓';
  @override
  String get ordenMediaAsc => 'Valutazione ↑';
  @override
  String get tituloDraft => 'Draft';
  @override
  String get eligiendoElRestoDeEquipos => 'Le altre squadre stanno scegliendo...';
  @override
  String get queElijaLaCpuPorMi => 'Fai scegliere alla CPU per me';
  @override
  String get draftCompletado => 'Draft completato';
  @override
  String eleccionNumero(int n) => 'Scelta numero $n';
  @override
  String get teTocaElegir => 'Tocca a te scegliere!';
  @override
  String get ordenarPorLabel => 'Ordina per: ';
  @override
  String posicionEdadMedia(String posicion, int edad, int media) => '$posicion · $edad anni · valutazione $media';

  @override
  String cuartosCopaSeSiembranAviso(String nbaCup) => 'I quarti di finale della $nbaCup vengono definiti non appena termina la fase a gironi di tutta la lega.';
  @override
  String get finalSeJuegaDesdeCalendarioAviso => 'La Finale si gioca dal calendario: se sei finalista è segnata come un altro giorno della tua stagione.';
  @override
  String get cuartosDeFinalLabel => 'Quarti di finale';
  @override
  String get semifinalLabel => 'Semifinale';
  @override
  String finalDeLaCopaLabel(String nbaCup) => 'Finale della $nbaCup';
  @override
  String get cuartosRondaLabel => 'Quarti';
  @override
  String get finalRondaLabel => 'Finale';
  @override
  String get pendienteLabel => 'In attesa';

  @override
  String get tituloResumenDeLaTemporada => 'Riepilogo della stagione';
  @override
  String noSePudoCargarResumen(String error) => 'Impossibile caricare il riepilogo.\n$error';
  @override
  String temporadaConEtiqueta(String etiqueta) => 'Stagione $etiqueta';
  @override
  String get pestanaBalance => 'Bilancio';
  @override
  String puestoEnConferencia(String conferencia) => 'Posizione a $conferencia';
  @override
  String puestoValor(int puesto) => '#$puesto';
  @override
  String puestoEnLaLigaNota(int puesto) => '#$puesto della lega';
  @override
  String get puntosPorPartidoLabel => 'Punti a partita';
  @override
  String encajadosLabel(String valor) => 'subiti $valor';
  @override
  String get diferenciaLabel => 'Differenza';
  @override
  String get porPartidoLabel => 'a partita';
  @override
  String get mejorRachaLabel => 'Miglior striscia';
  @override
  String get victoriasSeguidasLabel => 'vittorie consecutive';
  @override
  String get peorRachaLabel => 'Peggior striscia';
  @override
  String get derrotasSeguidasLabel => 'sconfitte consecutive';
  @override
  String get mejorVictoriaLabel => 'Miglior vittoria';
  @override
  String get peorDerrotaLabel => 'Peggior sconfitta';
  @override
  String partidosJugadosVictoriasPct(int partidos, int pct) => '$partidos partite · $pct% di vittorie';
  @override
  String get todaviaNoHayClasificacion => 'Non c\'è ancora una classifica.';
  @override
  String get columnaPJ => 'PG';
  @override
  String posicionMedia(String posicion, int media) => '$posicion · valutazione $media';

  @override
  String get allStarSubtituloPendiente => 'Si gioca durante la pausa di febbraio. Simula fino al weekend delle stelle per vederlo.';
  @override
  String get risingStarsSubtituloPendiente => 'I migliori rookie contro quelli del secondo anno, nello stesso weekend.';
  @override
  String get votacionAbreCuandoRuedeBalonAviso => 'Il voto si apre quando la palla comincia a rotolare. Giocando le giornate vedrai chi si sta guadagnando il posto e con quanti voti.';
  @override
  String get verEstadisticasBtn => 'Vedi statistiche';
  @override
  String mvpConNombre(String nombre) => 'MVP · $nombre';
  @override
  String lineaMvpPtsAstReb(int pts, int ast, int reb) => '$pts pt · $ast ass · $reb rmb';
  @override
  String escrutadoPorcentaje(int pct) => 'Scrutinato il $pct% dei voti...';
  @override
  String get recuentoCerradoAviso => 'Scrutinio chiuso: questi sono stati i prescelti.';
  @override
  String votacionAbiertaConPorcentaje(int pct) => 'Votazione aperta, con il $pct% della stagione giocato. Continua a simulare e i voti si muoveranno.';
  @override
  String get votacionFinalLabel => 'Voto finale';
  @override
  String get votacionDeAficionadosLabel => 'Voto dei tifosi';
  @override
  String conferenciaConNombre(String conferenciaLabel) => 'Conference $conferenciaLabel';
  @override
  String get titularesLabel => 'Titolari';
  @override
  String get suplentesLabel => 'Riserve';
  @override
  String get seQuedanFueraLabel => 'Rimangono fuori';
  @override
  String posicionValoracion(String posicion, String valoracion) => '$posicion · valutazione $valoracion';

  @override
  String get noLlegoACompletarNingunaTemporada => 'Non ha mai completato una stagione con te.';
  @override
  String get tituloTrayectoria => 'Percorso';
  @override
  String get tituloPalmares => 'Palmarès';
  @override
  String get noRetirarElDorsal => 'Non ritirare il numero';
  @override
  String get retirarSuCamiseta => 'Ritira la maglia';
  @override
  String get mvpFinalesCorto => 'MVP delle Finali';
  @override
  String get mvpDeLasFinalesLabel => 'MVP delle Finali';
  @override
  String quintetosAllNba(int n) => '$n quintetti All-NBA';
  @override
  String vecesConEtiqueta(int n, String etiqueta) => '$n $etiqueta';
  @override
  String copasGanadas(int n, String nbaCup) => '$n $nbaCup';
  @override
  String get premioCampeonDeLaNba => 'Campione NBA';
  @override
  String get premioTercerQuinteto => 'Terzo Quintetto';
  @override
  String get premioMaximoAnotador => 'Miglior marcatore';
  @override
  String get premioMasMejoradoCorto => 'Più Migliorato';
  @override
  String get sinTitulosNiPremiosCarreraNba => 'Nessun titolo o premio nella sua carriera NBA.';
  @override
  String get sinTitulosNiPremiosIndividuales => 'Nessun titolo o premio individuale.';
  @override
  String resumenCarreraTotales(int temporadas, String posicion, int partidos) => '$temporadas stagioni · $posicion · $partidos partite';
  @override
  String totalesCarreraLinea(String pts, String ast, String reb) => 'Totali: $pts pt · $ast ass · $reb rmb';
  @override
  String temporadasPreviasAviso(int n) => '$n di queste prima che tu prendessi il comando: di quelle non ci sono statistiche, le medie qui sotto sono della tua era.';
  @override
  String get antesDeTuPartidaTitulo => 'Prima della tua partita';
  @override
  String temporadasYaJugadasCuandoCogisteElEquipo(int n) => '$n ${n == 1 ? 'stagione' : 'stagioni'} già giocate quando hai preso in mano la squadra.';
  @override
  String get produccionDeReferenciaAviso => 'La sua produzione di riferimento all\'inizio della partita. Di quegli anni non ci sono statistiche partita per partita.';
  @override
  String sinEstadisticasDeCarreraAviso(String nombre) => 'Di $nombre non ci sono statistiche di carriera: viene da un\'epoca precedente a quella coperta dai dati del gioco. Il suo posto nella storia c\'è, i numeri no.';
  @override
  String get suCarreraEnLaNbaReal => 'La sua carriera nella vera NBA';
  @override
  String conEquipoEnLaNbaReal(String equipo) => 'Con $equipo nella vera NBA';
  @override
  String temporadasPartidos(int temporadas, int partidos) => '$temporadas stagioni · $partidos partite';
  @override
  String rangoTemporadasPartidos(String desde, String hasta, int partidos) => '$desde a $hasta · $partidos partite';
  @override
  String rangoPartidos(String rango, int partidos) => '$rango · $partidos partite';
  @override
  String temporadaMinuscula(int n) => 'stagione $n';

  @override
  String get nadieTePropuestoNadaAhora => 'Al momento nessuno ti ha proposto nulla';
  @override
  String get unEquipoQuiereAUnoDeTusJugadores => 'Una squadra vuole un tuo giocatore';
  @override
  String nEquiposHanPreguntado(int n) => '$n squadre hanno chiesto informazioni sui tuoi giocatori';
  @override
  String cuadroYResultadosDeLaCopa(String nbaCup) => 'Tabellone e risultati della $nbaCup';
  @override
  String get seDesbloqueaAlTerminarFaseDeGrupos => 'Si sblocca al termine della fase a gironi';
  @override
  String get premiosDeFinDeTemporadaSubtitulo => 'Premi di fine stagione';
  @override
  String get seDesbloqueaAlTerminarTemporadaRegular => 'Si sblocca al termine della regular season';
  @override
  String get bracketDeEliminatorias => 'Tabellone dei playoff';
  @override
  String hallOfFameYCamisetasRetiradasSubtitulo(String hallOfFame, String camisetas) => '$hallOfFame e $camisetas';
  @override
  String get salarialLabel => 'Monte ingaggi';

  @override
  String get sigueDondeLoDejaste => 'Riprendi da dove avevi lasciato';
  @override
  String get empiezaTuCarrera => 'Inizia la tua carriera';
  @override
  String get enQueRanuraQuieresEmpezar => 'In quale slot vuoi iniziare?';
  @override
  String get eligeLaPartidaQueQuieresCargar => 'Scegli la partita da caricare';
  @override
  String get nuevaPartidaBtn => 'Nuova partita';
  @override
  String get cargarPartidaBtn => 'Carica partita';
  @override
  String sobrescribirLaPartidaN(int n) => 'Sovrascrivere la partita $n?';
  @override
  String get sePerderaEnteraAviso => 'Quello slot ha già una carriera in corso che andrà persa del tutto: rose, calendario e palmarès. Non si può annullare.';
  @override
  String get sobrescribirBtn => 'Sovrascrivi';
  @override
  String get eligeTuEquipoTitulo => 'Scegli la tua squadra';
  @override
  String borrarLaPartidaN(int n) => 'Eliminare la partita $n?';
  @override
  String sePierdeCarreraDeAviso(String nombre) => 'Andrà persa tutta la carriera di $nombre: rose, calendario, palmarès, leggende e maglie ritirate. Non si può annullare.';
  @override
  String get borrarBtn => 'Elimina';
  @override
  String get lasTresRanurasOcupadasAviso => 'I tre slot sono tutti occupati: eliminane uno per iniziare da capo, oppure continua uno di quelli che hai già.';
  @override
  String get ranuraDeVersionCompleta => 'Slot della versione completa';
  @override
  String partidaNumero(int n) => 'PARTITA $n';
  @override
  String get borrarEstaPartidaTooltip => 'Elimina questa partita';
  @override
  String get ranuraVaciaLabel => 'Slot vuoto';
  @override
  String get empezarBtn => 'Inizia';

  @override
  String get lesionLabel => 'Infortunio';
  @override
  String get recibesLabel => 'Ricevi: ';
  @override
  String get entregasLabel => 'Cedi: ';
  @override
  String get traspasarBtn => 'Scambia';
  @override
  String get potencialElite => 'Elite';
  @override
  String get potencialMuyAlto => 'Molto alto';
  @override
  String get potencialAlto => 'Alto';
  @override
  String get potencialMedio => 'Medio';
  @override
  String get potencialBajo => 'Basso';
  @override
  String potencialTooltip(String etiqueta) => 'Potenziale: $etiqueta';
  @override
  String get volverAlMenuPrincipalTooltip => 'Torna al menu principale';

  @override
  String get margenSalarialEvento => 'Spazio salariale';

  @override
  String get tuFranquiciaSeccion => 'La tua franchigia';

  @override
  String get proximoPartidoTitulo => 'Prossima partita';

  @override
  String get enCasaLabel => 'Casa';

  @override
  String get fueraLabel => 'Trasferta';

  @override
  String get vsAbreviatura => 'VS';

  @override
  String get tituloPatrocinadores => 'Sponsor';
  @override
  String get explicacionPatrocinadores =>
      "Ogni sponsorizzazione ha più offerte: più lungo è il contratto, meno "
      "paga all'anno. Quello che firmi occupa quella categoria fino alla "
      "scadenza.";
  @override
  String get patrocinioEstadioLabel => 'Sponsor del palazzetto';
  @override
  String get patrocinioCamisetaLabel => 'Sponsor di maglia';
  @override
  String get patrocinioBebidaLabel => 'Bevanda ufficiale';
  @override
  String get patrocinioOcioLabel => 'Sponsor della comunità';
  @override
  String fundadoEnAnio(int anio) => 'Fondata nel $anio';
  @override
  String get alAnioSufijo => "all'anno";
  @override
  String sinPatrocinioFirmado(int ofertas) => ofertas == 1 ? 'Non firmato · 1 offerta' : 'Non firmato ·  offerte';
  @override
  String margenPatrocinio(String importe) => '+$importe di margine salariale';
  @override
  String get totalPatrociniosLabel => "Margine totale quest'anno";
  @override
  String get patrocinadoresBloqueados => 'Gli sponsor sono della versione completa. Guarda un video e li hai tutti e quattro per questa stagione.';
  @override
  String get verVideoPatrocinadores => 'GUARDA IL VIDEO E SBLOCCA';
  @override
  String get videoSinTerminar => 'Il video non è stato visto per intero, quindi restano bloccati. Puoi riprovare.';
}
