part of 'textos_eventos.dart';

/// El guion en italiano.
class EventosIt extends TextosDeEventos {
  const EventosIt();

  @override
  Map<String, String> get etiquetasDeEfecto => const {
    'buen_rollo': 'Bel clima nello spogliatoio',
    'piernas_cansadas': 'Gambe pesanti',
    'piernas_frescas': 'Gambe fresche',
    'grupo_frio': 'Gruppo freddo',
    'vestuario_tenso': 'Spogliatoio teso',
    'disciplina': 'Disciplina',
    'vestuario_roto': 'Spogliatoio spaccato',
    'sin_tu_mejor_jugador': 'Senza il tuo giocatore migliore',
    'plantilla_fresca': 'Rosa riposata',
    'plantilla_al_limite': 'Rosa al limite',
    'rotacion_verde': 'Rotazione acerba',
    'grupo_enchufado': 'Gruppo carico',
    'banquillo_descontento': 'Panchina scontenta',
    'el_grupo_va_contigo': 'Il gruppo è con te',
    'nadie_se_da_por_aludido': 'Nessuno si sente chiamato in causa',
    'vestuario_dolido': 'Spogliatoio ferito',
    'nadie_dio_la_cara': 'Nessuno li ha difesi',
    'el_ruido_se_apaga': 'Il rumore si spegne',
    'a_todo_gas': 'A tutto gas',
    'desgaste_acumulado': 'Usura accumulata',
    'se_corta_la_racha': 'La striscia si interrompe',
    'cargas_controladas': 'Carichi controllati',
    'la_grada_empuja': 'Il palazzetto spinge',
    'una_manana_sin_entrenar': 'Una mattina senza allenamento',
    'manana_de_trabajo': 'Mattina di lavoro',
    'la_grada_fria': 'Pubblico freddo',
    'dia_de_rodaje': 'Giornata di riprese',
    'manana_de_fotos': 'Mattina di foto',
    'plantilla_descansada': 'Rosa riposata',
    'un_partido_de_mas': 'Una partita di troppo',
    'la_ciudad_se_vuelca': 'La città si stringe alla squadra',
    'el_banquillo_coge_ritmo': 'La panchina prende ritmo',
    'semana_de_descanso': 'Settimana di riposo',
    'bien_descansados': 'Ben riposati',
    'sin_trabajo_tactico': 'Niente lavoro tattico',
    'se_han_dicho_las_cosas': 'Si sono detti tutto',
    'el_vestuario_va_por_libre': 'Lo spogliatoio va per conto suo',
    'la_charla_no_llego_a_pasar': 'Il confronto non c’è mai stato davvero',
    'sabes_lo_que_hay': 'Sai come stanno le cose',
    'rotacion_corta': 'Rotazione corta',
    'titulares_fundidos': 'Titolari spompati',
    'suplentes_en_pista': 'Riserve in campo',
    // Segunda tanda.
    'jugador_liberado': 'Giocatore liberato',
    'nadie_teme_por_su_puesto': 'Nessuno teme per il proprio posto',
    'jugador_tocado': 'Giocatore toccato',
    'se_juegan_el_puesto': 'Tutti si giocano il posto',
    'duda_en_el_vestuario': 'Il dubbio nello spogliatoio',
    'equipo_desarmado': 'Squadra smontata',
    'orgullo_del_grupo': 'L’orgoglio del gruppo',
    'jugador_agradecido': 'Giocatore riconoscente',
    'el_resto_toma_nota': 'Gli altri prendono nota',
    'sin_uno_de_la_rotacion': 'Uno in meno nelle rotazioni',
    'norma_clara': 'La regola è chiara',
    'descanso_roto': 'Intervallo spezzato',
    'homenaje_discreto': 'Omaggio discreto',
    'rutina_intacta': 'Routine intatta',
    'la_leyenda_dolida': 'La bandiera, offesa',
    'entrenador_con_las_riendas': 'Allenatore con le redini',
    'pierdes_el_banquillo': 'Hai perso la panchina',
    'equilibrio_incomodo': 'Equilibrio scomodo',
    'nadie_se_desmarca': 'Nessuno può chiamarsi fuori',
    'mano_firme': 'Mano ferma',
    'entrenador_dolido': 'Allenatore offeso',
    'jugador_resentido': 'Giocatore risentito',
    'disculpa_forzada': 'Scuse forzate',
    'algo_de_ruido_en_la_grada': 'Qualche mugugno sugli spalti',
    'protestas_en_el_comedor': 'Proteste in sala mensa',
    'plantilla_mejor_alimentada': 'Rosa che mangia come si deve',
    'pequeno_cambio': 'Un piccolo cambiamento',
    'mismo_de_siempre': 'Tutto come prima',
    // Compromisos de patrocinio (ver patrocinadores.dart).
    'dias_de_medios': 'Giornate media',
    'pabellon_con_otro_nombre': 'Il palazzetto con un altro nome',
    'compromisos_de_marca': 'Impegni con il marchio',
    'trabajo_con_la_ciudad': 'Lavoro con la città',
  };

  @override
  Map<String, TextoDeEvento> get eventos => const {
    'cena_de_equipo': TextoDeEvento(
      titulo: 'Cena di squadra',
      texto:
          'I veterani vogliono organizzare una cena per tutta la rosa, '
          'staff tecnico compreso. Dicono che serve sciogliersi un po’.',
      opciones: {
        'noche_larga': TextoDeOpcion(
          'Che sia una notte lunga',
          'Lo spogliatoio si è sciolto sul serio e si vede in campo. Le '
              'prossime due partite saranno dure: nessuno ha dormito quanto '
              'doveva.',
        ),
        'cena_corta': TextoDeOpcion(
          'Cena veloce e tutti a letto',
          'Un paio d’ore, due risate e a casa. Non risolve tutto, ma il '
              'gruppo è un po’ più unito e domani ci si allena.',
        ),
        'ahora_no_toca': TextoDeOpcion(
          'Non è il momento',
          'Si lavora e si riposa. Alla prossima partita si arriva con le '
              'gambe fresche, ma nessuno ha dimenticato che hai detto di '
              'no: il gruppo è più freddo di prima.',
        ),
      },
    ),
    'bronca_en_el_entrenamiento': TextoDeEvento(
      titulo: 'Rissa in allenamento',
      texto:
          'Due giocatori sono passati dalle parole agli spintoni in un '
          'cinque contro cinque. Li hanno separati nello spogliatoio e la '
          'stampa lo sa già.',
      opciones: {
        'multar_a_los_dos': TextoDeOpcion(
          'Multarli entrambi',
          'È chiaro chi comanda. Lo spogliatoio resta teso qualche giorno, '
              'ma nessuno ci riproverà.',
        ),
        'que_lo_arreglen_ellos': TextoDeOpcion(
          'Che se la vedano tra loro',
          'Si stringono la mano davanti al gruppo. Sembra sincero.',
        ),
        'mirar_a_otro_lado': TextoDeOpcion(
          'Far finta di niente',
          'Nessuno dice niente e la cosa incancrenisce. In campo si vede: '
              'la palla non gira più come prima.',
        ),
      },
    ),
    'estrella_pide_descanso': TextoDeEvento(
      titulo: 'Il tuo giocatore migliore chiede riposo',
      texto:
          'Gioca con dei fastidi da novembre. Non è infortunato, ma '
          'chiede di saltare qualche partita per arrivare intero a fine '
          'stagione.',
      opciones: {
        'que_descanse': TextoDeOpcion(
          'Che riposi',
          'Salta qualche partita e la sua assenza si sente, ma torna fresco '
              'e con voglia per il tratto che conta davvero.',
        ),
        'te_necesito_ahora': TextoDeOpcion(
          'Ho bisogno di te adesso',
          'Capisce e stringe i denti. Rende, ma lo si vede trascinare la '
              'gamba e il resto del gruppo se ne accorge.',
        ),
      },
    ),
    'joven_pide_minutos': TextoDeEvento(
      titulo: 'Un giovane chiede minuti',
      texto:
          'Uno dei tuoi ragazzi è incollato alla panchina da mezza '
          'stagione. Il suo agente ha chiamato: o gioca, o l’estate '
          'prossima si cerca sistemazione altrove.',
      opciones: {
        'dale_minutos': TextoDeOpcion(
          'Dagli minuti',
          'Nelle prime partite si vedono le crepe, ma si scioglie in fretta '
              'e lo spogliatoio capisce che qui il lavoro viene premiato.',
        ),
        'que_se_lo_gane': TextoDeOpcion(
          'Che se li guadagni in allenamento',
          'La prende male e si vede in faccia. Gli altri giovani prendono '
              'nota di come funzionano le cose qui.',
        ),
      },
    ),
    'prensa_dura': TextoDeEvento(
      titulo: 'La stampa vi sta massacrando',
      texto:
          'Dopo l’ultima sconfitta, il giornale cittadino ha scritto che '
          'lo spogliatoio è morto e che qui c’è gente di troppo. Aspettano '
          'una tua risposta.',
      opciones: {
        'defender_al_grupo': TextoDeOpcion(
          'Difendere il gruppo in pubblico',
          'I giocatori te ne sono grati: ci hai messo la faccia quando non '
              'lo faceva nessuno. Il problema è che ora i riflettori sono '
              'su di te, e dentro nessuno si sente chiamato in causa per '
              'quello che sta sbagliando.',
        ),
        'darles_la_razon': TextoDeOpcion(
          'Dargli ragione',
          'Hai ammesso in pubblico che la squadra non è all’altezza. È '
              'vero, ma dentro non è andata giù.',
        ),
        'no_entrar_al_trapo': TextoDeOpcion(
          'Non abboccare',
          'Due frasi fatte e tutti in allenamento. Senza legna, la cosa si '
              'spegne da sola in qualche giorno. Dentro resta che non sei '
              'uscito a difenderli.',
        ),
      },
    ),
    'racha_buena': TextoDeEvento(
      titulo: 'Non vi ferma nessuno',
      texto:
          'La squadra è lanciata e si comincia a parlare di voi come '
          'candidati. L’allenatore chiede se spingere o alzare il piede per '
          'non bruciare nessuno.',
      opciones: {
        'apretar_mientras_dure': TextoDeOpcion(
          'Spingere finché dura',
          'Si lavora a tutta e la striscia si allunga. L’usura arriverà, ma '
              'più avanti.',
        ),
        'levantar_el_pie': TextoDeOpcion(
          'Alzare il piede',
          'Carichi più leggeri e minuti distribuiti. La striscia si '
              'interrompe prima di quanto sarebbe successo spingendo, ma la '
              'squadra arriva intera.',
        ),
      },
    ),
    'aficion_llena_el_pabellon': TextoDeEvento(
      titulo: 'Il palazzetto si riempie',
      texto:
          'I biglietti stanno finendo e il pubblico chiede un gesto: un '
          'allenamento a porte aperte, autografi, foto. Costa un’intera '
          'mattina di lavoro.',
      opciones: {
        'abrir_las_puertas': TextoDeOpcion(
          'Aprire le porte',
          'Il palazzetto spingerà sul serio nelle prossime partite, e il '
              'negozio del club non si è fermato tutta la mattina. La '
              'seduta persa si paga alla partita dopo.',
        ),
        'a_entrenar': TextoDeOpcion(
          'Ad allenarsi, che è il mestiere',
          'Si lavora tutta la mattina e si vede alla partita dopo. Il '
              'pubblico capisce a metà: sugli spalti è spuntato qualche '
              'striscione.',
        ),
      },
    ),
    'acto_publicitario': TextoDeEvento(
      titulo: 'Uno sponsor vuole tutta la rosa',
      texto:
          'Un marchio della città mette soldi sul tavolo per un’intera '
          'giornata di riprese: rosa al completo, servizio fotografico e '
          'spot. È una giornata di lavoro persa e i giocatori hanno già '
          'fatto la faccia.',
      opciones: {
        'firmar_el_acuerdo_entero': TextoDeOpcion(
          'Firmare l’accordo intero',
          'Riprese fino a tardi e giocatori di malumore, ma il club porta a '
              'casa una bella cifra che dà respiro sotto il tetto '
              'salariale.',
        ),
        'negociar_algo_mas_corto': TextoDeOpcion(
          'Trattare qualcosa di più corto',
          'Mezza mattina di foto e poi in palestra. Si incassa meno, ma '
              'nessuno ha perso la giornata intera.',
        ),
        'decirles_que_no': TextoDeOpcion(
          'Dire di no',
          'La rosa scopre che gli hai risparmiato la rottura e arriva alla '
              'partita dopo con le gambe nuove. I soldi, un altro anno.',
        ),
      },
    ),
    'partido_benefico': TextoDeEvento(
      titulo: 'Partita di beneficenza infrasettimanale',
      texto:
          'Il comune organizza un’amichevole di beneficenza e vuole la '
          'squadra. Cade proprio tra due partite di campionato.',
      opciones: {
        'ir_con_los_titulares': TextoDeOpcion(
          'Andarci con i titolari',
          'Palazzetto pieno e città tutta con la squadra. È una partita in '
              'più su gambe che erano già tirate.',
        ),
        'mandar_a_los_suplentes': TextoDeOpcion(
          'Mandare le riserve',
          'Quelli in fondo alla panchina prendono minuti veri e si vedono '
              'sciolti. L’incasso è minore, ma nessuno di importante si è '
              'stancato.',
        ),
        'no_ir': TextoDeOpcion(
          'Non andarci',
          'Settimana pulita di lavoro e riposo. L’evento si fa lo stesso '
              'senza di voi, la città lo legge come uno sgarbo e il club '
              'finisce per rimediare di tasca propria.',
        ),
      },
    ),
    'viaje_infernal': TextoDeEvento(
      titulo: 'Cinque trasferte in otto giorni',
      texto:
          'Il calendario ha lasciato un viaggio durissimo. Il '
          'preparatore propone di partire un giorno prima per ogni città: '
          'costa caro ma risparmia ore di aereo.',
      opciones: {
        'viajar_con_margen': TextoDeOpcion(
          'Viaggiare con margine',
          'La squadra arriva riposata a ogni partita. Quello che si perde '
              'sono le sedute video e l’allenamento: si viaggia molto e si '
              'lavora poco.',
        ),
        'como_siempre': TextoDeOpcion(
          'Come sempre',
          'Aerei di notte e hotel alle tre del mattino. Si farà sentire.',
        ),
      },
    ),
    'veterano_de_vestuario': TextoDeEvento(
      titulo: 'Un veterano si offre di parlare al gruppo',
      texto:
          'Il più anziano della rosa ti chiede cinque minuti con la '
          'squadra, senza staff tecnico nella stanza. Dice che certe cose '
          'si dicono meglio tra giocatori.',
      opciones: {
        'dejales_solos': TextoDeOpcion(
          'Lasciali soli',
          'Nessuno ha raccontato cosa si sono detti lì dentro, ma la '
              'squadra è uscita diversa alla partita dopo. Qualunque cosa '
              'abbiano deciso, l’hanno decisa loro: tu sei rimasto fuori da '
              'quella conversazione.',
        ),
        'prefiero_estar_delante': TextoDeOpcion(
          'Preferisco esserci',
          'Il confronto resta a metà — con il capo nella stanza nessuno '
              'dice quello che pensa — ma esci sapendo esattamente chi sta '
              'con chi in quello spogliatoio.',
        ),
      },
    ),
    'recta_final': TextoDeEvento(
      titulo: 'I playoff cominciano tra tre settimane',
      texto:
          'Mancano poche partite ed è tutto corto. Lo staff chiede se '
          'accorciare le rotazioni e tirare la carretta ai migliori.',
      opciones: {
        'tirar_de_los_titulares': TextoDeOpcion(
          'Tirare con i titolari',
          'I migliori giocheranno quasi tutto. Rende adesso e il conto '
              'arriva ad aprile.',
        ),
        'repartir_minutos': TextoDeOpcion(
          'Distribuire i minuti',
          'Nessuno arriva ai playoff spompato, ma in volata si perde '
              'qualche partita per strada — e la posizione in classifica si '
              'decide proprio adesso.',
        ),
      },
    ),

    // --- Segunda tanda -------------------------------------------
    'rumor_de_traspaso': TextoDeEvento(
      titulo: 'Ha letto il suo nome tra le voci di mercato',
      texto:
          'Un giornalista ha scritto che stai ascoltando offerte per uno '
          'dei tuoi titolari. Te lo chiede in faccia, davanti a mezzo '
          'spogliatoio.',
      opciones: {
        'prometerle_que_se_queda': TextoDeOpcion(
          'Promettergli che non si muove',
          'Gli si toglie un peso e si vede dal primo possesso. Quello che '
              'hanno sentito tutti, però, è che qui il posto non lo perdi '
              'giocando male.',
        ),
        'decirle_la_verdad': TextoDeOpcion(
          'Dirgli la verità',
          'Gli hai detto di sì, che ascolti. Resta toccato per qualche '
              'settimana, ma da adesso nessuno in quello spogliatoio dà '
              'per scontato il proprio posto.',
        ),
        'no_contestar': TextoDeOpcion(
          'Non rispondere',
          'Una risposta che non dice niente. Lui esce come è entrato e gli '
              'altri restano con il dubbio: non lo hai smentito, quindi '
              'qualcosa c’è.',
        ),
      },
    ),
    'tanking_de_la_directiva': TextoDeEvento(
      titulo: 'La dirigenza guarda già al draft',
      texto:
          'I conti non portano ai playoff e in alto preferirebbero '
          'chiudere in basso per scegliere in alto al draft. Nessuno lo '
          'dirà ad alta voce, ma il messaggio è arrivato.',
      opciones: {
        'mirar_al_draft': TextoDeOpcion(
          'Pensare all’anno prossimo',
          'Minuti per quelli in fondo alla panchina e fastidi vaghi che '
              'nessuno spiega davvero per i migliori. Il resto della '
              'stagione sarà brutto da vedere, ma in alto sono contenti e '
              'si vede sul bilancio.',
        ),
        'competir_hasta_el_final': TextoDeOpcion(
          'Competere fino all’ultima partita',
          'Si scende in campo per vincere anche quando non serve a niente. '
              'Lo spogliatoio capisce benissimo e risponde: nessuno vuole '
              'essere la squadra che si è lasciata andare.',
        ),
      },
    ),
    'jugador_llega_tarde': TextoDeEvento(
      titulo: 'Uno arriva tardi un’altra volta',
      texto:
          'Terza volta questo mese che si presenta ad allenamento già '
          'iniziato. Le prime due hai lasciato correre. Questa l’hanno '
          'vista tutti.',
      opciones: {
        'multarle': TextoDeOpcion(
          'Multarlo',
          'La multa si commenta nello spogliatoio e non va giù, ma la '
              'settimana dopo non arriva tardi nessuno.',
        ),
        'hablar_en_privado': TextoDeOpcion(
          'Parlargli da solo',
          'Esce dall’ufficio toccato e riconoscente allo stesso tempo, e '
              'risponde. Il problema è che gli altri hanno appena visto '
              'che arrivare tardi tre volte non costa niente.',
        ),
        'sentarle_un_partido': TextoDeOpcion(
          'Lasciarlo fuori una partita',
          'Salta la prossima e il buco nelle rotazioni si vede. In cambio, '
              'la regola è scritta senza che nessuno abbia dovuto '
              'scriverla.',
        ),
      },
    ),
    'camiseta_de_una_leyenda': TextoDeEvento(
      titulo: 'Ritirare la maglia di una bandiera',
      texto:
          'Il club vuole appendere la sua maglia sotto il tetto del '
          'palazzetto in questa stagione. La data la scegli tu, e la '
          'cerimonia si mangia una parte della giornata di partita.',
      opciones: {
        'ceremonia_a_lo_grande': TextoDeOpcion(
          'Farla in grande, all’intervallo',
          'Mezz’ora di cerimonia, il palazzetto in piedi e la città che ne '
              'parla per una settimana. I giocatori sono rientrati freddi '
              'nel secondo tempo e quella partita si è pagata.',
        ),
        'algo_breve': TextoDeOpcion(
          'Un momento breve prima della palla a due',
          'Dieci minuti, maglia su e si gioca. Non dà fastidio a nessuno e '
              'non riempie il palazzetto come l’avrebbe riempito '
              'l’altra.',
        ),
        'dejarlo_para_el_verano': TextoDeOpcion(
          'Rimandare all’estate',
          'Settimana di lavoro pulita, senza interruzioni. La bandiera non '
              'ha detto niente in pubblico, ma da allora non risponde più '
              'al telefono.',
        ),
      },
    ),
    'entrenador_pide_mando': TextoDeEvento(
      titulo: 'L’allenatore vuole pieni poteri',
      texto:
          'Chiede di decidere lui rotazioni e minuti, senza che nessuno '
          'dall’alto gli dica chi far sedere. Dice che se risponde dei '
          'risultati, vuole rispondere delle decisioni.',
      opciones: {
        'darle_mando': TextoDeOpcion(
          'Darglieli',
          'Sembra un altro: due partite molto buone appena può fare le cose '
              'a modo suo. Quello che hai perso è la panchina — d’ora in '
              'poi le cose le sai quando sono già decise.',
        ),
        'mando_compartido': TextoDeOpcion(
          'Decidere in due',
          'Le prime settimane sono scomode e ci sono due riunioni dove '
              'prima ce n’era una. Ma dopo nessuno può chiamarsi fuori, '
              'perché avete firmato tutto in due.',
        ),
        'decidir_tu': TextoDeOpcion(
          'Decidi tu',
          'È chiaro chi comanda e la squadra lo apprezza per qualche '
              'partita. L’allenatore ha detto che non c’è problema, ma non '
              'propone più niente.',
        ),
      },
    ),
    'metida_de_pata_en_redes': TextoDeEvento(
      titulo: 'Un giocatore l’ha combinata sui social',
      texto:
          'Ha scritto alle tre di notte che gli arbitri ce l’hanno con '
          'lui. L’ha cancellato in venti minuti; a quel punto lo avevano '
          'già salvato tutti.',
      opciones: {
        'multarle_y_zanjarlo': TextoDeOpcion(
          'Multarlo e chiudere la questione',
          'Chiuso in un giorno, e gli altri capiscono dov’è il limite. Lui '
              'digerisce male la multa e si vede per qualche settimana.',
        ),
        'defenderle_en_publico': TextoDeOpcion(
          'Difenderlo in pubblico',
          'Hai detto in conferenza stampa che non ha tutti i torti. Lo '
              'spogliatoio non lo dimenticherà per tutta la stagione; la '
              'lega nemmeno, e la multa se la mangia il club.',
        ),
        'obligarle_a_disculparse': TextoDeOpcion(
          'Costringerlo a scusarsi in pubblico',
          'Legge un comunicato che non ha scritto lui e si vede in faccia. '
              'Imbarazzante per tutti, ma in tre giorni non ne parla più '
              'nessuno.',
        ),
      },
    ),
    'precio_de_las_entradas': TextoDeEvento(
      titulo: 'Vogliono alzare il prezzo dei biglietti',
      texto:
          'La squadra va bene, il palazzetto si riempie, e la proprietà '
          'vede il momento giusto per alzare i biglietti per quello che '
          'resta dell’anno.',
      opciones: {
        'subirlas': TextoDeOpcion(
          'Alzarli',
          'Entrano soldi veri e il tetto salariale respira. Il pubblico di '
              'sempre non l’ha presa bene, e il palazzetto non suona più '
              'come suonava.',
        ),
        'subirlas_un_poco': TextoDeOpcion(
          'Alzarli solo un po’',
          'Un ritocco che non si nota quasi né al botteghino né '
              'nell’atmosfera. Qualche fischio la prima sera e poco '
              'altro.',
        ),
        'no_tocarlas': TextoDeOpcion(
          'Non toccarli',
          'Il pubblico viene a sapere che hai detto di no, e il palazzetto '
              'diventa un problema per chi viene a giocarci. I soldi, un '
              'altro anno.',
        ),
      },
    ),
    'nutricionista': TextoDeEvento(
      titulo: 'Il nutrizionista vuole cambiare tutto',
      texto:
          'Propone di rifare da capo l’alimentazione del club: menù '
          'nuovi, cucina interna e basta hamburger in aereo. Costa soldi e '
          'a metà rosa non va giù per niente.',
      opciones: {
        'cambiarlo_todo': TextoDeOpcion(
          'Cambiare tutto',
          'Due settimane di proteste e facce lunghe in sala mensa. Da lì in '
              'poi si arriva molto meglio all’ultimo quarto, e quello non '
              'lo discute più nessuno.',
        ),
        'solo_en_los_viajes': TextoDeOpcion(
          'Solo in trasferta',
          'Si sistema la cosa peggiore — mangiare a orari impossibili in '
              'aereo — e nessuno protesta, perché a casa si mangia come '
              'sempre.',
        ),
        'dejarlo_como_esta': TextoDeOpcion(
          'Lasciare tutto com’è',
          'Nessuno si lamenta e la routine resta intatta. Il nutrizionista '
              'archivia la relazione e non la tira più fuori; quello che '
              'c’era scritto dentro resta vero.',
        ),
      },
    ),
  };
}
