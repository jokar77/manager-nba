part of 'textos.dart';

/// Français. On garde les termes NBA que la presse francophone emploie tels
/// quels (playoffs, All-Star, NBA Cup) : les traduire ferait plus étrange
/// que les laisser.
class TextosFr extends Textos {
  const TextosFr();

  @override
  TextosDeEventos get eventos => const EventosFr();

  @override
  String get aceptar => 'Accepter';
  @override
  String get cancelar => 'Annuler';
  @override
  String get cerrar => 'Fermer';
  @override
  String get guardar => 'Enregistrer';
  @override
  String get continuar => 'Continuer';
  @override
  String get si => 'Oui';
  @override
  String get no => 'Non';
  @override
  String get cargando => 'Chargement…';

  @override
  String get nuevaPartida => 'Nouvelle partie';
  @override
  String get ajustes => 'Réglages';
  @override
  String get elegirEquipo => 'Choisis ton équipe';
  @override
  String get sobrescribir => 'Écraser';
  @override
  String get ranuraOcupada => 'Cet emplacement contient déjà une partie';
  @override
  String get avisoSobrescribir =>
      'Si tu continues, la partie enregistrée ici sera supprimée.';

  @override
  String get modoOscuro => 'Mode sombre';
  @override
  String get modoOscuroDetalle =>
      'Des gris et des noirs au lieu de blancs vifs';
  @override
  String get idioma => 'Langue';
  @override
  String get idiomaDetalle => 'La langue de tout le jeu';

  @override
  String get calendario => 'Calendrier';
  @override
  String get calendarioDetalle => 'Vois ta saison et simule des matchs';
  @override
  String get tuEquipo => 'Ton équipe';
  @override
  String get tuEquipoDetalle => 'Effectif et cinq de départ';
  @override
  String get entrenador => 'Entraîneur';
  @override
  String get banquilloVacante => 'Ton banc est vacant';
  @override
  String get clasificacion => 'Classement';
  @override
  String get clasificacionDetalle => 'Équipes et meilleurs statisticiens';
  @override
  String get mercado => 'Marché';
  @override
  String get traspasos => 'Transferts';
  @override
  String get traspasosDetalle =>
      'Négocie des échanges avec le reste de la ligue';
  @override
  String get ofertasRecibidas => 'Offres reçues';
  @override
  String get agenciaLibre => 'Agence libre';
  @override
  String get agenciaLibreDetalle => 'Joueurs sans équipe et marge salariale';
  @override
  String get competicion => 'Compétition';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Vote, match des étoiles et MVP';
  @override
  String get resumenTemporada => 'Résumé de la saison';
  @override
  String get resumenTemporadaDetalle =>
      'Bilan, tous tes matchs et tes moyennes';
  @override
  String get playoffs => 'Playoffs';
  @override
  String get premios => 'Trophées';
  @override
  String get legado => 'Héritage';

  @override
  String get record => 'Bilan';
  @override
  String get masaSalarial => 'Masse salariale';
  @override
  String get temporada => 'Saison';

  @override
  String get sinEntrenador => 'Sans entraîneur';
  @override
  String get sinEntrenadorDetalle =>
      'Ton équipe joue sans entraîneur. Recrute quelqu\'un dans la liste ci-dessous.';
  @override
  String get despedir => 'Licencier';
  @override
  String get contratar => 'Recruter';
  @override
  String get negociar => 'Négocier';
  @override
  String get ofrecer => 'Proposer';
  @override
  String get sueldo => 'Salaire';
  @override
  String get duracion => 'Durée';
  @override
  String get ataque => 'Attaque';
  @override
  String get defensa => 'Défense';
  @override
  String get desarrollo => 'Formation';
  @override
  String get equilibrado => 'Équilibré';
  @override
  String get especialistaAtaque => 'Spécialiste de l\'attaque';
  @override
  String get especialistaDefensa => 'Spécialiste de la défense';
  @override
  String get formadorDeJovenes => 'Formateur de jeunes';
  @override
  String get loQuePuedesOfrecer => 'Ce que tu peux proposer';
  @override
  String get topeDeLaFranquicia => 'Plafond de la franchise';
  @override
  String get finiquitos => 'Indemnités des entraîneurs licenciés';
  @override
  String get aceptariaLaOferta => 'Il accepterait cette offre.';
  @override
  String get todaviaNo =>
      'Pas encore. Avec plus d\'argent ou plus d\'années, il pourrait changer d\'avis.';
  @override
  String get noVaAAceptar =>
      'Il n\'acceptera pas : ton projet est trop loin et l\'argent n\'y changera rien.';

  @override
  String anios(int n) => n == 1 ? '1 saison' : '$n saisons';
  @override
  String alAnio(String importe) => '$importe par an';

  @override
  String get pestanaEquipos => 'Équipes';
  @override
  String get pestanaJugadores => 'Joueurs';
  @override
  String get conferenciaEste => 'Est';
  @override
  String get conferenciaOeste => 'Ouest';
  @override
  String get fronteraPlayIn => 'Play-In';
  @override
  String get fronteraFueraDePlayoffs => 'Hors playoffs';
  @override
  String get ordenPuntos => 'Points';
  @override
  String get ordenAsistencias => 'Passes décisives';
  @override
  String get ordenRebotes => 'Rebonds';
  @override
  String get sinPartidosJugados => 'Aucun match joué pour le moment';
  @override
  String edadJugador(int n) => '$n ans';
  @override
  String mediaJugador(int n) => 'Niveau $n';
  @override
  String get estaTemporada => 'Cette saison';
  @override
  String get todaviaNoHaJugado => "N'a pas encore joué";
  @override
  String get contrato => 'Contrat';
  @override
  String get intentarTraspasar => 'Tenter un échange';
  @override
  String traspasoCerradoCon(String equipo) => 'Échange conclu avec $equipo.';
  @override
  String get fechaLimiteTraspasosPasada =>
      'La date limite des échanges est déjà passée : plus aucune opération ne peut être conclue cette saison.';

  @override
  String get tituloConferenciaEste => 'CONFÉRENCE EST';
  @override
  String get tituloConferenciaOeste => 'CONFÉRENCE OUEST';

  @override
  String comoFicharA(String nombre) => 'Comment recruter $nombre ?';
  @override
  String get sinConQueConvencerles =>
      "Tu n'as rien d'assez convaincant à proposer pour l'instant : ni ton effectif ni tes picks ne suffisent sans t'affaiblir.";

  @override
  String get campeonesDeLaNba => 'Champions NBA';
  @override
  String get campeonesDeLaCup => 'Champions de la NBA Cup';
  @override
  String get exclamacionCampeones => 'CHAMPIONS !';
  @override
  String seLlevaElTitulo(String nombre) => '$nombre remporte le titre.';
  @override
  String get enhorabuenaAnillo =>
      "Félicitations ! Vous l'avez fait : la bague est à vous. La saison prochaine, il faudra la défendre.";
  @override
  String get enhorabuenaCup =>
      'Félicitations ! Vous avez remporté la NBA Cup. La bague, c\'est une autre histoire : la saison continue.';
  @override
  String get aCelebrarlo => 'À fêter ça !';
  @override
  String mvpDeLasFinales(String nombre) => 'MVP des Finales · $nombre';
  @override
  String partidosDeSerie(int n) => n == 1 ? 'en 1 match' : 'en $n matchs';
  @override
  String get verEstadisticas => 'Voir les statistiques';
  @override
  String get confirmarSimularTitulo => 'Simuler jusqu\'à ce jour ?';
  @override
  String get seJugaraProximoPartido => 'Ton prochain match va être joué.';
  @override
  String seJugaranDeUnaVez(int partidos, int dia, int mes) =>
      'Les $partidos matchs qu\'il te reste jusqu\'au $dia/$mes vont être joués d\'un coup.';
  @override
  String get simular => 'Simuler';
  @override
  String finalCupVs(String enfrentamiento) =>
      'Finale NBA Cup — $enfrentamiento';
  @override
  String get tituloEventoFinAgenciaLibre => 'Fin du marché des agents libres';
  @override
  String get tituloEventoFechaLimiteTraspasos => 'Date limite des échanges';
  @override
  String get tituloEventoAllStar => 'Week-end des étoiles';
  @override
  String get descEventoFinAgenciaLibre =>
      "À partir de maintenant, il n'est plus possible de signer des agents libres.";
  @override
  String get descEventoFechaLimiteTraspasos =>
      'Dernier jour pour faire des échanges cette saison.';
  @override
  String get descEventoAllStar =>
      "Tu n'as pas de match ce week-end. Profites-en pour consulter le Classement.";
  @override
  List<String> get nombresMeses => [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre',
  ];
  @override
  List<String> get diasSemanaAbrev => ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  @override
  String get simularUnPartido => 'Simuler 1 match';
  @override
  String get unaSemana => '1 semaine';
  @override
  String get simularUnaSemana => 'Simuler 1 semaine';
  @override
  String get unMes => '1 mois';
  @override
  String get simularUnMes => 'Simuler 1 mois';
  @override
  String get simularTemporadaEntera => 'Saison entière';
  @override
  String get verBracketCompleto => 'Voir le tableau complet';
  @override
  String get empezarSiguienteTemporada => 'Commencer la saison suivante';
  @override
  String get simularPartidoDePlayoffs => 'Simuler un match de playoffs';
  @override
  String get noClasificasteAPlayoffs =>
      "Tu ne t'es pas qualifié pour les playoffs cette saison.";
  @override
  String get simularPlayoffsCompletos => 'Simuler tous les playoffs';
  @override
  String get serieDecididaFaltaResto =>
      'Ta série est décidée — il faut attendre le reste du tableau pour connaître ton prochain adversaire.';
  @override
  String get simularRestoDeRonda => 'Simuler le reste du tour';

  @override
  String ofertaTitulo(int n) =>
      n == 1 ? 'Tu as reçu une offre' : 'Tu as des offres';
  @override
  String ofertaMensaje(int n) => n == 1
      ? "Une équipe s'est renseignée sur un de tes joueurs et a mis une proposition sur la table."
      : '$n équipes se sont renseignées sur tes joueurs.';
  @override
  String get masTarde => 'Plus tard';
  @override
  String verOfertaBoton(int n) => n == 1 ? "Voir l'offre" : 'Voir les offres';
  @override
  String get preguntaSeguirSimulando =>
      "Tu as atteint cette date limite de la saison. Tu continues à simuler ou tu t'arrêtes pour faire des mouvements ?";
  @override
  String get irAAgenciaLibre => 'Aller au marché des agents libres';
  @override
  String get irATraspasos => 'Aller aux échanges';
  @override
  String get seguirSimulando => 'Continuer à simuler';
  @override
  String get allStarWeekendMayus => 'ALL STAR WEEKEND';
  @override
  String resultadoAllStar({
    required bool esteGana,
    required int local,
    required int visitante,
    String? mvp,
  }) =>
      'Le All-Star Game a été joué. ${esteGana ? "L'Est" : "L'Ouest"} remporte la rencontre $local-$visitante.${mvp == null ? "" : "\n\nMVP du match : $mvp."}';
  @override
  String get verFinDeSemana => 'Voir le week-end';
  @override
  String finalCupProgramada(String fecha) =>
      'En route pour la finale de la NBA Cup ! Tu la joues le $fecha : simule jusqu\'à ce jour-là.';
  @override
  String fechaCorta(int dia, int mes) =>
      '$dia ${nombresMeses[mes - 1].toLowerCase()}';

  @override
  String get sinPartidosTitulo => 'Aucun match';
  @override
  String resumenPartidos(int n, int ganados, int perdidos) {
    final g = ganados;
    final p = perdidos;
    return '$n matchs · $g-$p';
  }

  @override
  String get lesionesActivasAhora => 'Blessures actives en ce moment';
  @override
  String get verLosPremios => 'Voir les récompenses';

  @override
  String get playoffsSeSiembranAlTerminar =>
      'Les playoffs se composent une fois ta saison régulière (82 matchs) terminée.';
  @override
  String get verCelebracion => 'Voir la célébration';
  @override
  String get siguienteTemporadaBtn => 'Saison suivante';
  @override
  String get resolverPlayIn => 'Résoudre le Play-in';
  @override
  String get simularRondaCompleta => 'Simuler le tour complet';
  @override
  String get simularTodoBtn => 'Tout simuler';
  @override
  String get bracketTitulo => 'Tableau';
  @override
  String get primeraRondaEsperaPlayIn =>
      "Le premier tour ne commence pas tant que le Play-in n'a pas désigné le 7e et le 8e.";
  @override
  String get playInGanadorEntra7 => 'Le vainqueur entre en 7';
  @override
  String get playInPerdedorEliminado => 'Le perdant est éliminé';
  @override
  String get playInGanadorEntra8 => 'Le vainqueur entre en 8';
  @override
  String get conferenciaOesteTitulo => 'Conférence Ouest';
  @override
  String get conferenciaEsteTitulo => 'Conférence Est';
  @override
  String get sinPlayIn => 'Pas de play-in';
  @override
  String get jugarBtn => 'Jouer';
  @override
  String get porJugar => 'À jouer';
  @override
  String get rondaPrimeraRonda => 'Premier tour';
  @override
  String get rondaSemifinalConferencia => 'Demi-finale de conférence';
  @override
  String get rondaFinalConferencia => 'Finale de conférence';
  @override
  String get rondaFinalNba => 'Finales NBA';
  @override
  List<String> get nombresDeRondaBracket => [
    'Premier\ntour',
    'Demi-finales',
    'Finale\nOuest',
    'FINALES\nNBA',
    'Finale\nEst',
    'Demi-finales',
    'Premier\ntour',
  ];
  @override
  String get esperandoAlPlayIn => 'En attente du Play-in';
  @override
  String get porDefinir => 'À déterminer';

  @override
  String despedirConfirmacion(String nombre) => 'Licencier $nombre ?';
  @override
  String despedirConTiempoRestante(int anios, String importe) =>
      "Il lui reste $anios ${anios == 1 ? 'saison' : 'saisons'} de contrat et il faut les payer quand même : $importe que tu ne pourras PAS dépenser sur son remplaçant tant qu'elles ne seront pas écoulées.";
  @override
  String get despedirSinContrato =>
      "Il redeviendra libre et pourra signer avec n'importe quelle équipe. Tant que tu n'auras pas recruté quelqu'un d'autre, ton équipe jouera sans entraîneur.";
  @override
  String get ficharPorElMinimoBtn => 'Recruter au minimum';
  @override
  String get noHayEntrenadorSinEquipo =>
      "Il n'y a aucun entraîneur sans équipe";
  @override
  String get dirigiendoAOtroEquipo => 'Entraîne une autre équipe';
  @override
  String get sePuedeOfertarPeroTrabajo =>
      "Tu peux leur faire une offre, mais ils ont un emploi : il faut bien plus pour les convaincre, et l'équipe à qui tu le prends cherchera un remplaçant sur-le-champ.";
  @override
  String get avisoObligatorioTexto =>
      "Tu ne peux pas jouer sans entraîneur. Recrute quelqu'un pour continuer : si personne ne te convainc ou que ton budget ne suit pas, tu peux toujours en recruter un au minimum.";
  @override
  String mediaDeTuEquipoEs(int n) =>
      "Le niveau moyen de ton équipe est $n. Meilleur est un entraîneur, meilleur est le projet qu'il exige — et l'argent ne comble qu'une partie de la différence.";
  @override
  String pideAlAnioYTemporadas(String importe, int anios) =>
      'Demande $importe par an et $anios saisons.';
  @override
  String noLlegaMasaSalarial(String importe) =>
      "Ta masse salariale ne suffit pas : tu ne peux proposer que $importe.";
  @override
  String get tuEntrenadorLabel => 'Ton entraîneur';
  @override
  String get masaSalarialConBanquillo => 'Masse salariale (banc inclus)';
  @override
  String get porEncimaDelTopeSoloMinimo =>
      'Tu es au-dessus du plafond : tu ne peux recruter qu\'au salaire minimum.';
  @override
  String get sueldoEntrenadorCuentaEnMasa =>
      "Le salaire de l'entraîneur compte dans ta masse salariale : ce que tu dépenses ici, tu ne l'as plus pour les joueurs.";
  @override
  String contratoResumen(String importeAlAnio, String duracion) =>
      '$importeAlAnio · contrat de $duracion';
  @override
  String trayectoriaEstaTemporada(int victorias, int derrotas) =>
      'Cette saison : $victorias-$derrotas';
  @override
  String temporadasDirigiendo(int n) => '$n saisons à entraîner';
  @override
  String anillos(int n) => n == 1 ? '1 bague' : '$n bagues';
  @override
  String entrenadorDelAnio(int n) => n == 1
      ? "1 fois entraîneur de l'année"
      : '$n fois entraîneur de l\'année';
  @override
  String dirigeAEquipo(String apodo) => 'Entraîne $apodo';
  @override
  String pideImportePorAnios(String importe, int anios) =>
      'Demande $importe × $anios ${anios == 1 ? "an" : "ans"}';
  @override
  String get noCabeEnPresupuesto => 'Ne rentre pas dans ton budget de banc';
  @override
  String get proyectoLeQuedaLejos => 'Ton projet est trop loin de ses attentes';
  @override
  String get asuPrecioNo =>
      'À son prix, il dirait non ; avec plus d\'argent, peut-être';
  @override
  String get volver => 'Retour';
  @override
  String get elegirEsteEquipo => 'Choisir cette équipe';

  @override
  String mediaDelEquipo(int n) => "Niveau de l'équipe : $n";
  @override
  String get torneoDeMitadDeTemporada => 'Tournoi de mi-saison';
  @override
  String get campeonNba => 'Champion NBA';

  @override
  String descripcionHueco(bool esTitular, String nombrePosicion) => esTitular
      ? 'titulaire au poste de $nombrePosicion'
      : 'remplaçant au poste de $nombrePosicion';
  @override
  String get tituloTitular => 'Titulaire';
  @override
  String get tituloSuplente => 'Remplaçant';
  @override
  Map<String, String> get nombresDePosiciones => {
    'PG': 'Meneur (PG)',
    'SG': 'Arrière (SG)',
    'SF': 'Ailier (SF)',
    'PF': 'Ailier fort (PF)',
    'C': 'Pivot (C)',
  };
  @override
  String get minutosTitularLabel => 'Minutes du titulaire : ';
  @override
  String fueraPorLesion(String nombres) => 'Absents sur blessure : $nombres';
  @override
  String get alinearAutomaticamenteBtn => 'Aligner automatiquement';
  @override
  String get pestanaAlineacion => 'Composition';
  @override
  String get pestanaEstadisticas => 'Statistiques';
  @override
  String get tusPicksDeDraft => 'Tes choix de draft';
  @override
  String get empezarTemporadaBtn => 'Commencer la saison';
  @override
  String get guardarRotacionBtn => 'Enregistrer la composition';
  @override
  String get elegirJugadorPlaceholder => '— choisir un joueur —';
  @override
  String lesionConDetalle(String motivo, int partidos, String fecha) =>
      '$motivo ($partidos matchs) — retour le $fecha — le remplaçant jouera en attendant';
  @override
  String get fueraDeSusDosPosiciones =>
      'Hors de ses deux postes (rendra un peu moins bien)';
  @override
  String get sinPartidosJugadosTemporada => 'Aucun match joué cette saison';
  @override
  String get estrellaAtaqueLabel => 'Star offensive';
  @override
  String get estrellaDefensaLabel => 'Star défensive';
  @override
  String get sextoHombreLabel => 'Sixième homme';
  @override
  String get ningunaOpcion => 'Aucune';
  @override
  String get faltaAlineacionAviso =>
      "Complétez le cinq : chaque poste a besoin d'un titulaire et d'un remplaçant.";
  @override
  String get faltanRolesAviso =>
      "Il vous reste à choisir la star offensive, la star défensive et le sixième homme.";
  @override
  String get sinPicksPropios =>
      "Il ne te reste aucun choix qui t'appartienne : tu les as tous échangés.";
  @override
  String get traspasadoATiPorOtroEquipo =>
      'Échangé vers toi par une autre équipe';
  @override
  String get quintetoInicial => 'Cinq de départ';
  @override
  String get rotacionCompleta => 'Rotation complète';

  @override
  String nombreConPosicionYMedia(String nombre, String posicion, int media) =>
      '$nombre ($posicion, niveau $media)';
  @override
  String yaAsignadoIntercambio(String descripcionHueco) =>
      'actuellement $descripcionHueco — ils vont être échangés';
  @override
  String get tituloTusPicksDeDraft => 'Tes choix de draft';

  @override
  String lesionSimple(String motivo, String fecha) =>
      '$motivo, retour le $fecha';

  @override
  String get rechazar => 'Refuser';
  @override
  String get proponer => 'Proposer';
  @override
  String get tituloAgenciaLibre => 'Agence libre';
  @override
  String get verTuPlantilla => 'Voir ton effectif';
  @override
  String get agenciaLibreCerrada =>
      'L\'agence libre est fermée pour cette saison : la date limite est passée. Tu peux continuer à consulter le marché, mais plus signer personne avant l\'année prochaine.';
  @override
  String get completarConContratosMinimos =>
      'Compléter avec des contrats minimums';
  @override
  String get plantillaCompletada => 'Effectif complété.';
  @override
  String fichadosPorElMinimo(int n) => '$n joueurs signés au contrat minimum.';
  @override
  String get quePuedaPagar => 'Abordable';
  @override
  String get noQuedaNadieEnMercado =>
      'Il ne reste plus personne sur le marché.';
  @override
  String get nadieEncajaConFiltro =>
      'Personne sur le marché ne correspond à ta demande. Essaie de retirer un filtre.';
  @override
  String contadorAgentesLibres(int n) => '$n agents libres';
  @override
  String contadorAgentesLibresFiltrado(int visibles, int total) =>
      '$visibles agents libres sur $total (filtres actifs)';
  @override
  String get empezarLaTemporadaBtn => 'Démarrer la saison';
  @override
  String get completaLaPlantillaParaContinuar =>
      'Complète l\'effectif pour continuer';
  @override
  String plantillaAlCompletoConN(int n) => 'Effectif au complet : $n joueurs.';
  @override
  String plantillaDeMax(int n, int max) => 'Effectif : $n joueurs sur $max.';
  @override
  String faltanFichajesParaMinimo(int n) =>
      'Il manque $n recrues pour atteindre le minimum.';
  @override
  String otrosEquiposJuegan(int max, int n, int atras) =>
      'Les 29 autres équipes jouent à $max. Tu peux démarrer avec $n, mais tu es en retard de $atras.';
  @override
  String sinRecambioEn(String lista) => 'Pas de remplaçant à : $lista.';
  @override
  String libresBajoElTope(String cantidad) =>
      '$cantidad disponibles sous le plafond.';
  @override
  String get yaNoNegocia => 'Ne négocie plus';
  @override
  String negociarConN(int n) => 'Négocier ($n)';
  @override
  String ofertaA(String nombre) => 'Offre à $nombre';
  @override
  String pideAlAnio(String cantidad) => 'Demande $cantidad par an';
  @override
  String sueldoLabel(String cantidad) => 'Salaire : $cantidad';
  @override
  String get insultoOferta => 'Il va le prendre comme une insulte.';
  @override
  String get ofertaImprobable =>
      'Très improbable qu\'il accepte comme ça : le salaire, les années, ou les deux sont insuffisants.';
  @override
  String get ofertaSePuedePensar =>
      'Il peut y réfléchir ; il n\'est pas totalement convaincu.';
  @override
  String get ofertaProbableAceptar => 'Il devrait accepter.';
  @override
  String get ofertaSeguraAceptar => 'Presque certain qu\'il dira oui.';
  @override
  String get aniosLabelDosPuntos => 'Années : ';
  @override
  String get tituloRenovaciones => 'Renouvellements';
  @override
  String get ningunContratoSeAcaba =>
      'Aucun contrat n\'expire : ton effectif reste engagé un an de plus.';
  @override
  String continuarConNAgenciaLibre(int n) =>
      'Continuer ($n partent en agence libre)';
  @override
  String porEncimaDelTope(String cantidad) =>
      'Tu es $cantidad au-dessus du plafond : tu ne peux offrir que des contrats minimums.';
  @override
  String teQuedanBajoElTope(String espacio, String tope) =>
      'Il te reste $espacio sous le plafond de $tope.';
  @override
  String get seAcaboLaNegociacion => 'Négociation\nterminée';
  @override
  String ofrecerConN(int n) => 'Offrir ($n)';
  @override
  String get cerramosElTraspaso => 'On conclut l\'échange ?';
  @override
  String seVanYLlegan(String piden, String ofrecen) =>
      '$piden partent et $ofrecen arrivent.';
  @override
  String get tituloOfertasRecibidasScreen => 'Offres reçues';
  @override
  String get nadieTePideNadaAhora =>
      'Personne ne te propose rien pour l\'instant. Continue à simuler : les offres arrivent en cours de saison.';
  @override
  String get ofertaAnterior => 'Offre précédente';
  @override
  String get ofertaSiguiente => 'Offre suivante';
  @override
  String ofertaNDeM(int n, int m) => 'Offre $n sur $m';
  @override
  String lineaJugadorOferta(
    String nombre,
    String posicion,
    int media,
    String contrato,
  ) => '$nombre · $posicion · $media · $contrato';
  @override
  String aniosDeContrato(int n) => n == 1 ? '1 an' : '$n ans';
  @override
  String contratoAnioMillones(String anios, String millones) =>
      '$anios · $millones par an';
  @override
  String get tePiden => 'On te demande';
  @override
  String get teOfrecen => 'On t\'offre';
  @override
  String get contraofertar => 'Contre-offre';
  @override
  String get teVasAQuedarCorto => 'Tu vas être en manque d\'effectif';
  @override
  String avisoLoCierras(String aviso) => '$aviso\n\nTu conclus quand même ?';
  @override
  String get mejorNo => 'Plutôt pas';
  @override
  String get cerrarloIgual => 'Conclure quand même';
  @override
  String get traspasoCerradoSimple => 'Échange conclu.';
  @override
  String get fechaLimiteTraspasosNoMasOperaciones =>
      'La date limite des échanges est passée : plus aucune opération ne peut être conclue cette saison.';
  @override
  String quienSeLlevaA(String nombre) => 'Qui prendrait $nombre ?';
  @override
  String quienSeLlevaPaquete(int n) => 'Qui prendrait ce lot de $n éléments ?';
  @override
  String get ningunEquipoTeDariaNada =>
      'Aucune équipe ne te donnerait quelque chose qui en vaille la peine.';
  @override
  String get noTienesConQueConvencer =>
      'Tu n\'as pas de quoi les convaincre : ni ton effectif ni tes choix n\'y suffisent sans te ruiner.';
  @override
  String get tituloTraspasos => 'Échanges';
  @override
  String get fechaLimiteTraspasosBanner =>
      'La date limite des échanges est déjà passée cette saison : tu peux continuer à consulter le marché, mais rien conclure avant l\'année prochaine.';
  @override
  String get noCuadraMeteATercero =>
      'Ça ne colle pas ? Ajoute une troisième équipe';
  @override
  String get cerrarTraspasoBtn => 'Conclure l\'échange';
  @override
  String get tuEquipoLabel => 'Ton équipe';
  @override
  String get tercerEquipoLabel => 'Troisième équipe';
  @override
  String get rivalLabel => 'Adversaire';
  @override
  String get buscarQuienCompraria => 'Chercher qui l\'achèterait';
  @override
  String get buscarQueDarPorEl => 'Chercher ce qu\'il faudrait donner pour lui';
  @override
  String anadirDe(String equipo) => 'Ajouter depuis $equipo';
  @override
  String get eleccionesDeDraft => 'Choix de draft';
  @override
  String get yaHasPuestoTodo =>
      'Tu as déjà mis sur la table tout ce que cette équipe avait de disponible.';
  @override
  String get sacarDeLaOperacion => 'Retirer de l\'opération';
  @override
  String get noCuadraMeteATerceroLarga =>
      'Ça ne colle pas ?\nAjoute une troisième équipe';
  @override
  String get anadirEquipoBtn => 'Ajouter une équipe';
  @override
  String get tocaParaElegirJugadoresOPicks =>
      'Touche pour choisir\ndes joueurs ou des choix';

  @override
  String get mercadoCerradoNoSeBuscan =>
      'Le marché est fermé : la date limite des échanges est passée. Impossible de chercher des opérations avant l\'année prochaine.';
  @override
  String get tituloLegado => 'Héritage';
  @override
  String get explicacionPuntuacionCarreraTooltip =>
      'Ce que signifie le score de carrière';
  @override
  String get hallOfFame => 'Hall of Fame';
  @override
  String get pestanaCamisetasRetiradas => 'Maillots retirés';
  @override
  String get pestanaLideresHistoricos => 'Meilleurs de tous les temps';
  @override
  String get camisetaRetiradaSingular => 'Maillot retiré';
  @override
  String get unDorsalQueNoVolvera => 'Un numéro qui ne sera plus jamais porté';
  @override
  String get dorsalesQueNoVolveran =>
      'Des numéros qui ne seront plus jamais portés';
  @override
  String get tituloPartidosDeLaSerie => 'Matchs de la série';
  @override
  String partidoNMarcador(
    int n,
    String local,
    int marcadorLocal,
    int marcadorVisitante,
    String visitante,
  ) => 'Match $n : $local $marcadorLocal - $marcadorVisitante $visitante';
  @override
  String get unNuevoNombreHof => 'Un nouveau nom entre au Hall of Fame.';
  @override
  String nNombresNuevosHof(int n) =>
      '$n nouveaux noms entrent au Hall of Fame.';
  @override
  String entroEnAnio(int anio) => 'Intronisé en $anio';
  @override
  String get queEsPuntuacionCarrera => 'Qu\'est-ce que le score de carrière ?';
  @override
  String get explicacionPuntuacionCarreraTexto =>
      'Résume toute la carrière d\'un joueur, pas un simple chiffre isolé :\n\n• Trophées individuels (MVP, Meilleur défenseur, équipes All-NBA, Rookie de l\'année, Progression de l\'année).\n• Bagues de champion et titres de la NBA Cup.\n• Le meilleur niveau atteint.\n• Les points, passes et rebonds accumulés, selon le nombre de saisons jouées.\n\nIl faut au moins 6 saisons jouées et dépasser un seuil pour entrer : un titulaire solide sans trophée ne suffit pas, il faut avoir vraiment compté.';
  @override
  String get entendido => 'Compris';
  @override
  String noSePudoCargarHof(String error) =>
      'Impossible de charger le Hall of Fame.\n$error';
  @override
  String get todaviaNadieEnHof =>
      'Personne n\'est encore au Hall of Fame. N\'y entrent que les joueurs retraités avec une grande carrière : trophées, bagues et de nombreuses années à haut niveau.';
  @override
  String get nuevoChip => 'NOUVEAU';

  @override
  String get enActivoLeyenda =>
      'En activité : peut encore grimper au classement';
  @override
  String get todaviaNoHayEstadisticas =>
      'Pas encore de statistiques à afficher.';
  @override
  String noSePudieronCargarCamisetas(String error) =>
      'Impossible de charger les maillots retirés.\n$error';
  @override
  String get todaviaNoHayCamisetaEnLiga =>
      'Aucun maillot n\'a encore été retiré dans la ligue. Quand une légende prendra sa retraite, tu pourras l\'honorer.';
  @override
  String get franquiciaLabel => 'Franchise';
  @override
  String get todaLaLigaOpcion => 'Toute la ligue';
  @override
  String equipoTodaviaNoHaRetirado(String equipo) =>
      '$equipo n\'a encore retiré aucun maillot.';
  @override
  String get tuEquipoBadge => 'TON ÉQUIPE';
  @override
  String get retiradaRealDeLaFranquicia => 'Retrait réel de la franchise';
  @override
  String retiradaEnLaTemporada(String etiquetaTemporada) =>
      'Retirée en $etiquetaTemporada';
  @override
  String nPartidos(int n) => n == 1 ? '1 match' : '$n matchs';
  @override
  String get enElVestuario => 'Dans le vestiaire';

  @override
  String get premioMvp => 'MVP';
  @override
  String get premioMejorDefensor => 'Meilleur défenseur';
  @override
  String get premioRookieDelAno => 'Rookie de l\'année';
  @override
  String get premioMasMejorado => 'Progression de l\'année';
  @override
  String get premioPrimerQuinteto => 'Meilleur cinq majeur';
  @override
  String get premioSegundoQuinteto => 'Deuxième cinq majeur';
  @override
  String get risingStars => 'Rising Stars';
  @override
  String premioMvpAllStar(String allStar) => 'MVP du $allStar';
  @override
  String premioMvpRisingStars(String risingStars) => 'MVP du $risingStars';
  @override
  String get tituloPremiosDeLaTemporada => 'Trophées de la saison';
  @override
  String noSePudieronCargarPremios(String error) =>
      'Impossible de charger les trophées.\n$error';
  @override
  String get verCalendarioBtn => 'Voir le calendrier';
  @override
  String statsPremioLinea(String pts, String ast, String reb) =>
      '$pts pts, $ast pd, $reb reb';

  @override
  String temporadaN(int n) => 'Saison $n';
  @override
  String arrancaLaTemporada(int n, int anioInicio, int anioFin) =>
      'La saison $n démarre ($anioInicio-$anioFin)';
  @override
  String get plantillaHaCambiadoAviso =>
      'Ton effectif a changé : vérifie-le avant le premier match — un alignement automatique a été préparé.';
  @override
  String get tusEleccionesDelDraft => 'Tes choix de draft';
  @override
  String get seRetiranDeTuEquipo => 'Prennent leur retraite de ton équipe';
  @override
  String cuelgaLasBotasCon(int edad, int media) =>
      'Prend sa retraite à $edad ans, niveau $media';
  @override
  String get hanDadoUnPasoAdelante => 'Ont franchi un cap';
  @override
  String get empiezanABajar => 'Commencent à décliner';
  @override
  String get topDelDraft => 'Top de la draft';
  @override
  String get movimientosEnLaLiga => 'Mouvements dans la ligue';
  @override
  String recibeA(String equipoA, String jugadorB, String posicionB) =>
      '$equipoA récupère $jugadorB ($posicionB)';
  @override
  String get tambienSeRetiran => 'Prennent aussi leur retraite';
  @override
  String yNMas(int n) => 'et $n autres';
  @override
  String posicionMediaSeparador(String posicion, int media) =>
      '$posicion · niveau $media · ';

  @override
  String camisetaDeXRetirada(String nombre) => 'Maillot de $nombre retiré.';
  @override
  String get tituloSeRetiran => 'Prennent leur retraite';
  @override
  String get estaTemporadaNoSeRetiraNadie =>
      'Personne ne prend sa retraite cette saison.';
  @override
  String get restoDeLaLiga => 'Reste de la ligue';
  @override
  String get suCamisetaYaRetiradaSola =>
      ' · son maillot a déjà été retiré automatiquement (légende réelle)';
  @override
  String get camisetaRetiradaSufijo => ' · maillot retiré';

  @override
  String get tituloResultadoPartido => 'Résultat du match';
  @override
  String get columnaTotal => 'Total';
  @override
  String get columnaJugador => 'Joueur';
  @override
  String get columnaMin => 'Min';
  @override
  String get columnaPts => 'Pts';
  @override
  String get columnaAst => 'Pd';
  @override
  String get columnaReb => 'Reb';
  @override
  String get prefijoCuarto => 'Q';
  @override
  String get prefijoProrroga => 'P';

  @override
  String get ordenPotencial => 'Potentiel';
  @override
  String get ordenMediaDesc => 'Niveau ↓';
  @override
  String get ordenMediaAsc => 'Niveau ↑';
  @override
  String get tituloDraft => 'Draft';
  @override
  String get eligiendoElRestoDeEquipos => 'Les autres équipes choisissent...';
  @override
  String get queElijaLaCpuPorMi => 'Laisser l\'IA choisir pour moi';
  @override
  String get draftCompletado => 'Draft terminée';
  @override
  String eleccionNumero(int n) => 'Choix numéro $n';
  @override
  String get teTocaElegir => 'À toi de choisir !';
  @override
  String get ordenarPorLabel => 'Trier par : ';

  @override
  String cuartosCopaSeSiembranAviso(String nbaCup) =>
      'Les quarts de finale de la $nbaCup sont établis dès que la phase de groupes de toute la ligue est terminée.';
  @override
  String get finalSeJuegaDesdeCalendarioAviso =>
      'La finale se joue depuis le calendrier : si tu es finaliste, elle est indiquée comme un jour de plus de ta saison.';
  @override
  String get cuartosDeFinalLabel => 'Quarts de finale';
  @override
  String get semifinalLabel => 'Demi-finale';
  @override
  String finalDeLaCopaLabel(String nbaCup) => 'Finale de la $nbaCup';
  @override
  String get cuartosRondaLabel => 'Quarts';
  @override
  String get finalRondaLabel => 'Finale';
  @override
  String get pendienteLabel => 'À venir';

  @override
  String get tituloResumenDeLaTemporada => 'Résumé de la saison';
  @override
  String noSePudoCargarResumen(String error) =>
      'Impossible de charger le résumé.\n$error';
  @override
  String temporadaConEtiqueta(String etiqueta) => 'Saison $etiqueta';
  @override
  String get pestanaBalance => 'Bilan';
  @override
  String puestoEnConferencia(String conferencia) =>
      'Position à l\'$conferencia';
  @override
  String puestoValor(int puesto) => '#$puesto';
  @override
  String puestoEnLaLigaNota(int puesto) => '#$puesto de la ligue';
  @override
  String get puntosPorPartidoLabel => 'Points par match';
  @override
  String encajadosLabel(String valor) => 'encaissés $valor';
  @override
  String get diferenciaLabel => 'Différentiel';
  @override
  String get porPartidoLabel => 'par match';
  @override
  String get mejorRachaLabel => 'Meilleure série';
  @override
  String get victoriasSeguidasLabel => 'victoires d\'affilée';
  @override
  String get peorRachaLabel => 'Pire série';
  @override
  String get derrotasSeguidasLabel => 'défaites d\'affilée';
  @override
  String get mejorVictoriaLabel => 'Meilleure victoire';
  @override
  String get peorDerrotaLabel => 'Pire défaite';
  @override
  String partidosJugadosVictoriasPct(int partidos, int pct) =>
      '$partidos matchs · $pct% de victoires';
  @override
  String get todaviaNoHayClasificacion => 'Pas encore de classement.';
  @override
  String get columnaPJ => 'MJ';
  @override
  String posicionMedia(String posicion, int media) =>
      '$posicion · niveau $media';

  @override
  String get allStarSubtituloPendiente =>
      'Se joue pendant la pause de février. Simule jusqu\'au week-end des étoiles pour le voir.';
  @override
  String get risingStarsSubtituloPendiente =>
      'Les meilleurs rookies contre les joueurs de deuxième année, le même week-end.';
  @override
  String get votacionAbreCuandoRuedeBalonAviso =>
      'Le vote ouvre dès le coup d\'envoi. Au fil des journées jouées, tu verras qui gagne sa place et par combien de voix.';
  @override
  String get verEstadisticasBtn => 'Voir les statistiques';
  @override
  String mvpConNombre(String nombre) => 'MVP · $nombre';
  @override
  String lineaMvpPtsAstReb(int pts, int ast, int reb) =>
      '$pts pts · $ast pd · $reb reb';
  @override
  String escrutadoPorcentaje(int pct) => '$pct% des voix dépouillées...';
  @override
  String get recuentoCerradoAviso => 'Dépouillement terminé : voici les élus.';
  @override
  String votacionAbiertaConPorcentaje(int pct) =>
      'Vote ouvert, avec $pct% de la saison jouée. Continue à simuler et les voix évolueront.';
  @override
  String get votacionFinalLabel => 'Vote final';
  @override
  String get votacionDeAficionadosLabel => 'Vote des supporters';
  @override
  String conferenciaConNombre(String conferenciaLabel) =>
      'Conférence $conferenciaLabel';
  @override
  String get titularesLabel => 'Titulaires';
  @override
  String get suplentesLabel => 'Remplaçants';
  @override
  String get seQuedanFueraLabel => 'Non retenus';
  @override
  String posicionValoracion(String posicion, String valoracion) =>
      '$posicion · note de $valoracion';

  @override
  String get noLlegoACompletarNingunaTemporada =>
      'N\'a jamais terminé une saison complète avec toi.';
  @override
  String get tituloTrayectoria => 'Parcours';
  @override
  String get tituloPalmares => 'Palmarès';
  @override
  String get noRetirarElDorsal => 'Ne pas retirer le numéro';
  @override
  String get retirarSuCamiseta => 'Retirer son maillot';
  @override
  String get mvpFinalesCorto => 'MVP des finales';
  @override
  String get mvpDeLasFinalesLabel => 'MVP des finales';
  @override
  String quintetosAllNba(int n) => '$n sélections All-NBA';
  @override
  String vecesConEtiqueta(int n, String etiqueta) => '$n $etiqueta';
  @override
  String copasGanadas(int n, String nbaCup) => '$n $nbaCup';
  @override
  String get premioCampeonDeLaNba => 'Champion NBA';
  @override
  String get premioTercerQuinteto => 'Troisième cinq majeur';
  @override
  String get premioMaximoAnotador => 'Meilleur marqueur';
  @override
  String get premioMasMejoradoCorto => 'Progression de l\'année';
  @override
  String get sinTitulosNiPremiosCarreraNba =>
      'Aucun titre ni trophée dans sa carrière NBA.';
  @override
  String get sinTitulosNiPremiosIndividuales =>
      'Aucun titre ni trophée individuel.';
  @override
  String resumenCarreraTotales(int temporadas, String posicion, int partidos) =>
      '$temporadas saisons · $posicion · $partidos matchs';
  @override
  String totalesCarreraLinea(String pts, String ast, String reb) =>
      'Totaux : $pts pts · $ast pd · $reb reb';
  @override
  String temporadasPreviasAviso(int n) =>
      '$n d\'entre elles avant que tu ne prennes les commandes : pas de statistiques pour celles-là, les moyennes ci-dessous sont celles de ton ère.';
  @override
  String get antesDeTuPartidaTitulo => 'Avant ta partie';
  @override
  String temporadasYaJugadasCuandoCogisteElEquipo(int n) =>
      '$n ${n == 1 ? 'saison' : 'saisons'} déjà jouées avant que tu prennes l\'équipe en main.';
  @override
  String get produccionDeReferenciaAviso =>
      'Sa production de référence au début de la partie. Il n\'y a pas de statistiques match par match pour ces années-là.';
  @override
  String sinEstadisticasDeCarreraAviso(String nombre) =>
      'Il n\'y a pas de statistiques de carrière pour $nombre : il vient d\'une époque antérieure à celle couverte par les données du jeu. Sa place dans l\'histoire existe, les chiffres non.';
  @override
  String get suCarreraEnLaNbaReal => 'Sa carrière dans la vraie NBA';
  @override
  String conEquipoEnLaNbaReal(String equipo) =>
      'Avec $equipo dans la vraie NBA';
  @override
  String temporadasPartidos(int temporadas, int partidos) =>
      '$temporadas saisons · $partidos matchs';
  @override
  String rangoTemporadasPartidos(String desde, String hasta, int partidos) =>
      '$desde à $hasta · $partidos matchs';
  @override
  String rangoPartidos(String rango, int partidos) =>
      '$rango · $partidos matchs';
  @override
  String temporadaMinuscula(int n) => 'saison $n';

  @override
  String get nadieTePropuestoNadaAhora =>
      'Personne ne t\'a rien proposé pour l\'instant';
  @override
  String get unEquipoQuiereAUnoDeTusJugadores =>
      'Une équipe veut l\'un de tes joueurs';
  @override
  String nEquiposHanPreguntado(int n) =>
      '$n équipes se sont renseignées sur tes joueurs';
  @override
  String cuadroYResultadosDeLaCopa(String nbaCup) =>
      'Tableau et résultats de la $nbaCup';
  @override
  String get seDesbloqueaAlTerminarFaseDeGrupos =>
      'Se débloque à la fin de la phase de groupes';
  @override
  String get premiosDeFinDeTemporadaSubtitulo => 'Trophées de fin de saison';
  @override
  String get seDesbloqueaAlTerminarTemporadaRegular =>
      'Se débloque à la fin de la saison régulière';
  @override
  String get bracketDeEliminatorias => 'Tableau des séries éliminatoires';
  @override
  String hallOfFameYCamisetasRetiradasSubtitulo(
    String hallOfFame,
    String camisetas,
  ) => '$hallOfFame et $camisetas';
  @override
  String get salarialLabel => 'Masse salariale';

  @override
  String get sigueDondeLoDejaste => 'Reprends où tu en étais';
  @override
  String get empiezaTuCarrera => 'Commence ta carrière';
  @override
  String get enQueRanuraQuieresEmpezar =>
      'Dans quel emplacement veux-tu commencer ?';
  @override
  String get eligeLaPartidaQueQuieresCargar =>
      'Choisis la partie que tu veux charger';
  @override
  String get nuevaPartidaBtn => 'Nouvelle partie';
  @override
  String get cargarPartidaBtn => 'Charger une partie';
  @override
  String sobrescribirLaPartidaN(int n) => 'Écraser la partie $n ?';
  @override
  String get sePerderaEnteraAviso =>
      'Cet emplacement a déjà une carrière en cours et elle sera entièrement perdue : effectifs, calendrier et palmarès. C\'est irréversible.';
  @override
  String get sobrescribirBtn => 'Écraser';
  @override
  String get eligeTuEquipoTitulo => 'Choisis ton équipe';
  @override
  String borrarLaPartidaN(int n) => 'Supprimer la partie $n ?';
  @override
  String sePierdeCarreraDeAviso(String nombre) =>
      'Toute la carrière de $nombre sera perdue : effectifs, calendrier, palmarès, légendes et maillots retirés. C\'est irréversible.';
  @override
  String get borrarBtn => 'Supprimer';
  @override
  String get lasTresRanurasOcupadasAviso =>
      'Les trois emplacements sont occupés : supprime-en un pour recommencer, ou continue l\'un de ceux que tu as déjà.';
  @override
  String get ranuraDeVersionCompleta => 'Emplacement de la version complète';
  @override
  String partidaNumero(int n) => 'PARTIE $n';
  @override
  String get borrarEstaPartidaTooltip => 'Supprimer cette partie';
  @override
  String get ranuraVaciaLabel => 'Emplacement vide';
  @override
  String get empezarBtn => 'Commencer';

  @override
  String get lesionLabel => 'Blessure';
  @override
  String get recibesLabel => 'Tu reçois : ';
  @override
  String get entregasLabel => 'Tu donnes : ';
  @override
  String get traspasarBtn => 'Échanger';
  @override
  String get potencialElite => 'Élite';
  @override
  String get potencialMuyAlto => 'Très élevé';
  @override
  String get potencialAlto => 'Élevé';
  @override
  String get potencialMedio => 'Moyen';
  @override
  String get potencialBajo => 'Faible';
  @override
  String potencialTooltip(String etiqueta) => 'Potentiel : $etiqueta';
  @override
  String get volverAlMenuPrincipalTooltip => 'Retour au menu principal';

  @override
  String get margenSalarialEvento => 'Marge salariale';

  @override
  String get tuFranquiciaSeccion => 'Ta franchise';

  @override
  String get proximoPartidoTitulo => 'Prochain match';

  @override
  String get enCasaLabel => 'À domicile';

  @override
  String get fueraLabel => "À l'extérieur";

  @override
  String get vsAbreviatura => 'VS';

  @override
  String get tituloPatrocinadores => 'Sponsors';
  @override
  String get explicacionPatrocinadores =>
      "Chaque partenariat a plusieurs offres : plus le contrat est long, "
      "moins il rapporte par an. Ce que vous signez bloque cette catégorie "
      "jusqu'à son terme.";
  @override
  String get patrocinioEstadioLabel => 'Sponsor de la salle';
  @override
  String get patrocinioCamisetaLabel => 'Sponsor maillot';
  @override
  String get patrocinioBebidaLabel => 'Sponsor de la restauration';
  @override
  String get patrocinioOcioLabel => 'Sponsor communautaire';
  @override
  String fundadoEnAnio(int anio) => 'Fondé en $anio';
  @override
  String get alAnioSufijo => 'par an';
  @override
  String sinPatrocinioFirmado(int ofertas) =>
      ofertas == 1 ? 'Non signé · 1 offre' : 'Non signé ·  offres';
  @override
  String margenPatrocinio(String importe) => '+$importe de marge salariale';
  @override
  String get patrocinadoresBloqueados =>
      'Les sponsors font partie de la version complète. Regarde une vidéo et tu as les quatre pour cette saison.';
  @override
  String get verVideoPatrocinadores => 'REGARDER LA VIDÉO ET DÉBLOQUER';
  @override
  String get videoSinTerminar =>
      "La vidéo n'a pas été regardée en entier, ils restent donc bloqués. Tu peux réessayer.";
}
