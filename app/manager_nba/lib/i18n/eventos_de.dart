part of 'textos_eventos.dart';

/// El guion en alemán.
class EventosDe extends TextosDeEventos {
  const EventosDe();

  @override
  String get jugadorGenerico => 'der Spieler';

  @override
  Map<String, String> get etiquetasDeEfecto => const {
    'buen_rollo': 'Gute Stimmung in der Kabine',
    'piernas_cansadas': 'Schwere Beine',
    'piernas_frescas': 'Frische Beine',
    'grupo_frio': 'Kühle Stimmung',
    'vestuario_tenso': 'Angespannte Kabine',
    'disciplina': 'Disziplin',
    'vestuario_roto': 'Zerrissene Kabine',
    'sin_tu_mejor_jugador': 'Ohne deinen besten Spieler',
    'plantilla_fresca': 'Ausgeruhter Kader',
    'plantilla_al_limite': 'Kader am Limit',
    'rotacion_verde': 'Unerfahrene Rotation',
    'grupo_enchufado': 'Mannschaft zieht mit',
    'banquillo_descontento': 'Unzufriedene Bank',
    'el_grupo_va_contigo': 'Die Mannschaft steht hinter dir',
    'nadie_se_da_por_aludido': 'Keiner fühlt sich angesprochen',
    'vestuario_dolido': 'Gekränkte Kabine',
    'nadie_dio_la_cara': 'Niemand hat sich vor sie gestellt',
    'el_ruido_se_apaga': 'Der Lärm verstummt',
    'a_todo_gas': 'Vollgas',
    'desgaste_acumulado': 'Angesammelter Verschleiß',
    'se_corta_la_racha': 'Die Serie reißt',
    'cargas_controladas': 'Kontrollierte Belastung',
    'la_grada_empuja': 'Die Halle pusht',
    'una_manana_sin_entrenar': 'Ein Vormittag ohne Training',
    'manana_de_trabajo': 'Vormittag voller Arbeit',
    'la_grada_fria': 'Kühle Ränge',
    'dia_de_rodaje': 'Drehtag',
    'manana_de_fotos': 'Foto-Vormittag',
    'plantilla_descansada': 'Erholter Kader',
    'un_partido_de_mas': 'Ein Spiel zu viel',
    'la_ciudad_se_vuelca': 'Die Stadt steht hinter euch',
    'el_banquillo_coge_ritmo': 'Die Bank kommt in Fahrt',
    'semana_de_descanso': 'Eine Woche Erholung',
    'bien_descansados': 'Gut erholt',
    'sin_trabajo_tactico': 'Keine Taktikarbeit',
    'se_han_dicho_las_cosas': 'Es wurde alles ausgesprochen',
    'el_vestuario_va_por_libre': 'Die Kabine macht ihr eigenes Ding',
    'la_charla_no_llego_a_pasar': 'Das Gespräch fand nie wirklich statt',
    'sabes_lo_que_hay': 'Du weißt, woran du bist',
    'rotacion_corta': 'Kurze Rotation',
    'titulares_fundidos': 'Ausgebrannte Starter',
    'suplentes_en_pista': 'Ersatzspieler auf dem Feld',
    // Segunda tanda.
    'jugador_liberado': 'Spieler befreit',
    'nadie_teme_por_su_puesto': 'Keiner bangt um seinen Platz',
    'jugador_tocado': 'Spieler getroffen',
    'se_juegan_el_puesto': 'Alle spielen um ihren Platz',
    'duda_en_el_vestuario': 'Zweifel in der Kabine',
    'equipo_desarmado': 'Mannschaft auseinandergenommen',
    'orgullo_del_grupo': 'Der Stolz der Mannschaft',
    'jugador_agradecido': 'Spieler dankbar',
    'el_resto_toma_nota': 'Die anderen merken es sich',
    'sin_uno_de_la_rotacion': 'Einer aus der Rotation fehlt',
    'norma_clara': 'Die Regel ist klar',
    'descanso_roto': 'Zerrissene Halbzeit',
    'homenaje_discreto': 'Stille Ehrung',
    'rutina_intacta': 'Routine unangetastet',
    'la_leyenda_dolida': 'Die Legende, gekränkt',
    'entrenador_con_las_riendas': 'Trainer hat die Zügel',
    'pierdes_el_banquillo': 'Du hast die Bank verloren',
    'equilibrio_incomodo': 'Unbequemes Gleichgewicht',
    'nadie_se_desmarca': 'Keiner kann sich wegducken',
    'mano_firme': 'Feste Hand',
    'entrenador_dolido': 'Trainer gekränkt',
    'jugador_resentido': 'Spieler nachtragend',
    'disculpa_forzada': 'Erzwungene Entschuldigung',
    'algo_de_ruido_en_la_grada': 'Etwas Murren auf den Rängen',
    'protestas_en_el_comedor': 'Gemecker im Speisesaal',
    'plantilla_mejor_alimentada': 'Kader isst richtig',
    'pequeno_cambio': 'Eine kleine Umstellung',
    'mismo_de_siempre': 'Alles beim Alten',
    // Compromisos de patrocinio (ver patrocinadores.dart).
    'dias_de_medios': 'Medientage',
    'pabellon_con_otro_nombre': 'Die Halle unter anderem Namen',
    'compromisos_de_marca': 'Verpflichtungen der Marke',
    'trabajo_con_la_ciudad': 'Arbeit mit der Stadt',
  };

  @override
  Map<String, TextoDeEvento> get eventos => const {
    'cena_de_equipo': TextoDeEvento(
      titulo: 'Mannschaftsessen',
      texto:
          'Die Routiniers wollen ein Essen für den ganzen Kader '
          'organisieren, Trainerstab inklusive. Sie sagen, alle müssten '
          'mal locker werden.',
      opciones: {
        'noche_larga': TextoDeOpcion(
          'Soll eine lange Nacht werden',
          'Die Kabine ist wirklich aufgetaut, und man sieht es auf dem '
              'Feld. Die nächsten zwei Spiele werden zäh: keiner hat '
              'geschlafen, wie er sollte.',
        ),
        'cena_corta': TextoDeOpcion(
          'Kurz essen und ab ins Bett',
          'Zwei Stunden, ein paar Lacher und nach Hause. Das rettet nicht '
              'die Welt, aber die Mannschaft ist etwas enger zusammen und '
              'morgen wird trainiert.',
        ),
        'ahora_no_toca': TextoDeOpcion(
          'Jetzt ist nicht der Moment',
          'Trainieren und ausruhen. Die Beine sind frisch für das nächste '
              'Spiel, aber keiner hat vergessen, dass du Nein gesagt hast: '
              'die Stimmung ist kühler als vorher.',
        ),
      },
    ),
    'bronca_en_el_entrenamiento': TextoDeEvento(
      titulo: 'Im Training ist es eskaliert',
      texto:
          'Zwei Spieler sind bei einem Fünf-gegen-fünf von Worten zu '
          'Schubsereien übergegangen. Sie sind in der Kabine getrennt '
          'worden und die Presse weiß es schon.',
      opciones: {
        'multar_a_los_dos': TextoDeOpcion(
          'Beide bestrafen',
          'Jetzt ist klar, wer das Sagen hat. Die Kabine ist ein paar Tage '
              'angespannt, aber das macht keiner noch mal.',
        ),
        'que_lo_arreglen_ellos': TextoDeOpcion(
          'Sollen sie das unter sich klären',
          'Sie geben sich vor der Mannschaft die Hand. Es wirkt ehrlich.',
        ),
        'mirar_a_otro_lado': TextoDeOpcion(
          'Wegschauen',
          'Keiner sagt etwas und die Sache frisst sich fest. Auf dem Feld '
              'sieht man es: der Ball läuft nicht mehr wie vorher.',
        ),
      },
    ),
    'estrella_pide_descanso': TextoDeEvento(
      titulo: '{jugador} bittet um Pause',
      texto:
          'Er spielt seit November mit Beschwerden. Verletzt ist er '
          'nicht, aber er möchte ein paar Spiele aussetzen, um zum '
          'Saisonende heil zu sein.',
      opciones: {
        'que_descanse': TextoDeOpcion(
          'Soll er pausieren',
          'Ihr verliert ein paar Spiele und sein Fehlen tut weh, aber er '
              'kommt frisch und hungrig zurück für die Phase, auf die es '
              'wirklich ankommt.',
        ),
        'te_necesito_ahora': TextoDeOpcion(
          'Ich brauche dich jetzt',
          'Er versteht es und beißt die Zähne zusammen. Er liefert, aber '
              'man sieht ihn das Bein nachziehen und der Rest der '
              'Mannschaft merkt es.',
        ),
      },
    ),
    'joven_pide_minutos': TextoDeEvento(
      titulo: '{jugador} will Spielzeit',
      texto:
          '{jugador} klebt seit einer halben Saison auf der '
          'Bank. Sein Berater hat angerufen: entweder er spielt, oder er '
          'sucht sich im Sommer etwas anderes.',
      opciones: {
        'dale_minutos': TextoDeOpcion(
          'Gib ihm Minuten',
          'In den ersten Spielen sieht man die Lücken, aber er taut schnell '
              'auf und die Kabine sieht, dass hier Arbeit belohnt wird.',
        ),
        'que_se_lo_gane': TextoDeOpcion(
          'Er soll es sich im Training verdienen',
          'Er nimmt es übel und man sieht es ihm an. Die anderen Jungen '
              'merken sich, wie es hier läuft.',
        ),
      },
    ),
    'prensa_dura': TextoDeEvento(
      titulo: 'Die Presse zerlegt euch',
      texto:
          'Nach der letzten Niederlage hat die Stadtzeitung geschrieben, '
          'die Kabine sei tot und hier seien Leute zu viel. Man erwartet '
          'eine Antwort von dir.',
      opciones: {
        'defender_al_grupo': TextoDeOpcion(
          'Die Mannschaft öffentlich verteidigen',
          'Die Spieler rechnen es dir an: du hast den Kopf hingehalten, als '
              'es sonst keiner tat. Das Problem ist, dass jetzt du im '
              'Rampenlicht stehst — und drinnen fühlt sich niemand für '
              'seine Fehler verantwortlich.',
        ),
        'darles_la_razon': TextoDeOpcion(
          'Ihnen recht geben',
          'Du hast öffentlich zugegeben, dass die Mannschaft nicht gut '
              'genug ist. Stimmt ja, aber drinnen kam es schlecht an.',
        ),
        'no_entrar_al_trapo': TextoDeOpcion(
          'Nicht darauf eingehen',
          'Zwei Floskeln und zurück ins Training. Ohne Futter erlischt die '
              'Geschichte in ein paar Tagen von selbst. Drinnen bleibt '
              'hängen, dass du dich nicht vor sie gestellt hast.',
        ),
      },
    ),
    'racha_buena': TextoDeEvento(
      titulo: 'Euch hält niemand auf',
      texto:
          'Die Mannschaft läuft und man redet schon von euch als '
          'Titelkandidaten. Der Trainer fragt, ob er Gas gibt oder den Fuß '
          'vom Pedal nimmt, damit niemand ausbrennt.',
      opciones: {
        'apretar_mientras_dure': TextoDeOpcion(
          'Gas geben, solange es läuft',
          'Volles Training und die Serie wird länger. Der Verschleiß kommt, '
              'nur später.',
        ),
        'levantar_el_pie': TextoDeOpcion(
          'Fuß vom Gas',
          'Leichtere Einheiten und verteilte Minuten. Die Serie reißt '
              'früher, als sie mit Vollgas gerissen wäre, aber die '
              'Mannschaft kommt heil durch.',
        ),
      },
    ),
    'aficion_llena_el_pabellon': TextoDeEvento(
      titulo: 'Die Halle füllt sich',
      texto:
          'Die Tickets gehen weg und die Fans wollen eine Geste: ein '
          'offenes Training, Autogramme, Fotos. Das kostet einen ganzen '
          'Arbeitsvormittag.',
      opciones: {
        'abrir_las_puertas': TextoDeOpcion(
          'Die Türen öffnen',
          'Die Halle wird in den nächsten Spielen richtig pushen, und im '
              'Fanshop war den ganzen Vormittag Betrieb. Die verlorene '
              'Einheit zahlt sich im nächsten Spiel.',
        ),
        'a_entrenar': TextoDeOpcion(
          'Trainieren, dafür sind wir da',
          'Es wird den ganzen Vormittag gearbeitet und man sieht es im '
              'nächsten Spiel. Die Fans verstehen es halb: auf den Rängen '
              'hing das eine oder andere Transparent.',
        ),
      },
    ),
    'acto_publicitario': TextoDeEvento(
      titulo: 'Ein Sponsor will den ganzen Kader',
      texto:
          'Eine Marke aus der Stadt legt Geld auf den Tisch für einen '
          'ganzen Drehtag: kompletter Kader, Fotoshooting und Werbespot. '
          'Das kostet einen Arbeitstag und die Spieler ziehen schon '
          'Gesichter.',
      opciones: {
        'firmar_el_acuerdo_entero': TextoDeOpcion(
          'Den ganzen Vertrag unterschreiben',
          'Dreh bis in die Nacht und schlecht gelaunte Spieler, aber der '
              'Klub nimmt einen ordentlichen Batzen mit, der unter der '
              'Gehaltsobergrenze Luft verschafft.',
        ),
        'negociar_algo_mas_corto': TextoDeOpcion(
          'Etwas Kürzeres aushandeln',
          'Einen halben Vormittag Fotos und zurück ins Training. Es gibt '
              'weniger Geld, aber keiner hat den ganzen Tag verloren.',
        ),
        'decirles_que_no': TextoDeOpcion(
          'Absagen',
          'Der Kader erfährt, dass du ihnen die Sache erspart hast, und '
              'kommt mit frischen Beinen ins nächste Spiel. Das Geld gibt '
              'es dann eben ein andermal.',
        ),
      },
    ),
    'partido_benefico': TextoDeEvento(
      titulo: 'Benefizspiel unter der Woche',
      texto:
          'Die Stadt organisiert ein Benefiz-Freundschaftsspiel und will '
          'die Mannschaft. Es fällt genau zwischen zwei Ligaspiele.',
      opciones: {
        'ir_con_los_titulares': TextoDeOpcion(
          'Mit den Startern hingehen',
          'Volle Halle und die ganze Stadt hinter der Mannschaft. Es ist '
              'ein Spiel mehr in Beinen, die ohnehin schon am Limit waren.',
        ),
        'mandar_a_los_suplentes': TextoDeOpcion(
          'Die Ersatzspieler schicken',
          'Die vom Ende der Bank bekommen echte Minuten und spielen frei '
              'auf. Die Einnahmen sind kleiner, aber niemand Wichtiges hat '
              'sich verausgabt.',
        ),
        'no_ir': TextoDeOpcion(
          'Nicht hingehen',
          'Eine saubere Woche Arbeit und Erholung. Die Veranstaltung findet '
              'auch ohne euch statt, die Stadt liest es als Affront und der '
              'Klub gleicht es am Ende aus eigener Tasche aus.',
        ),
      },
    ),
    'viaje_infernal': TextoDeEvento(
      titulo: 'Fünf Auswärtsspiele in acht Tagen',
      texto:
          'Der Spielplan hat euch eine brutale Reise beschert. Der '
          'Athletiktrainer schlägt vor, in jede Stadt einen Tag früher zu '
          'fliegen: teuer, spart aber Stunden im Flugzeug.',
      opciones: {
        'viajar_con_margen': TextoDeOpcion(
          'Mit Puffer reisen',
          'Die Mannschaft kommt zu jedem Spiel ausgeruht an. Verloren gehen '
              'Videositzungen und Training: viel Reisen und wenig Arbeit.',
        ),
        'como_siempre': TextoDeOpcion(
          'Wie immer',
          'Nachtflüge und Hotels um drei Uhr morgens. Das wird man merken.',
        ),
      },
    ),
    'veterano_de_vestuario': TextoDeEvento(
      titulo: '{jugador} will mit der Mannschaft reden',
      texto:
          '{jugador}, der Älteste im Kader, bittet dich um fünf Minuten '
          'mit dem Team, ohne Trainerstab im Raum. Er sagt, manche Dinge '
          'bespreche man besser unter Spielern.',
      opciones: {
        'dejales_solos': TextoDeOpcion(
          'Lass sie allein',
          'Keiner hat erzählt, was da drinnen gesagt wurde, aber die '
              'Mannschaft kam beim nächsten Spiel anders heraus. Was auch '
              'immer entschieden wurde, sie haben es entschieden: du warst '
              'bei diesem Gespräch nicht dabei.',
        ),
        'prefiero_estar_delante': TextoDeOpcion(
          'Ich bin lieber dabei',
          'Das Gespräch bleibt auf halbem Weg stecken — mit dem Chef im '
              'Raum sagt keiner, was er denkt — aber du gehst raus und '
              'weißt genau, wer in dieser Kabine zu wem hält.',
        ),
      },
    ),
    'recta_final': TextoDeEvento(
      titulo: 'In drei Wochen beginnen die Playoffs',
      texto:
          'Es sind nur noch wenige Spiele und alles ist eng. Der Stab '
          'fragt, ob die Rotation verkürzt und auf die Besten gesetzt '
          'wird.',
      opciones: {
        'tirar_de_los_titulares': TextoDeOpcion(
          'Auf die Starter setzen',
          'Die Besten werden fast alles spielen. Das zahlt sich jetzt aus '
              'und die Rechnung kommt im April.',
        ),
        'repartir_minutos': TextoDeOpcion(
          'Die Minuten verteilen',
          'Keiner kommt ausgebrannt in die Playoffs, aber auf der '
              'Zielgeraden geht das eine oder andere Spiel verloren — und '
              'die Platzierung entscheidet sich genau jetzt.',
        ),
      },
    ),

    // --- Segunda tanda -------------------------------------------
    'rumor_de_traspaso': TextoDeEvento(
      titulo: '{jugador} hat seinen Namen in den Gerüchten gelesen',
      texto:
          'Ein Journalist hat geschrieben, dass du Angebote für '
          '{jugador} anhörst. Er fragt dich direkt, vor der halben '
          'Kabine.',
      opciones: {
        'prometerle_que_se_queda': TextoDeOpcion(
          'Ihm versprechen, dass er bleibt',
          'Ihm fällt ein Stein vom Herzen, und man sieht es ab dem ersten '
              'Ballbesitz. Gehört haben aber alle auch, dass man seinen '
              'Platz hier nicht durch schlechte Spiele verliert.',
        ),
        'decirle_la_verdad': TextoDeOpcion(
          'Ihm die Wahrheit sagen',
          'Du hast ihm gesagt, dass du zuhörst. Ein paar Wochen ist er '
              'getroffen, aber von jetzt an hält keiner in dieser Kabine '
              'seinen Platz für sicher.',
        ),
        'no_contestar': TextoDeOpcion(
          'Nichts sagen',
          'Eine Antwort, die nichts sagt. Er geht raus, wie er reinkam, und '
              'die anderen bleiben mit dem Zweifel zurück: du hast es '
              'nicht dementiert, also ist da was dran.',
        ),
      },
    ),
    'tanking_de_la_directiva': TextoDeEvento(
      titulo: 'Die Vereinsführung schaut schon auf den Draft',
      texto:
          'Für die Playoffs reicht es rechnerisch nicht, und oben wäre '
          'man lieber weit unten in der Tabelle, um weit oben zu draften. '
          'Laut sagen wird es niemand, aber die Botschaft ist angekommen.',
      opciones: {
        'mirar_al_draft': TextoDeOpcion(
          'An nächstes Jahr denken',
          'Minuten für das Ende der Bank und diffuse Beschwerden bei den '
              'Besten, die niemand so recht erklärt. Der Rest der Saison '
              'wird schwer anzusehen, aber oben ist man zufrieden und das '
              'merkt man am Budget.',
        ),
        'competir_hasta_el_final': TextoDeOpcion(
          'Bis zum letzten Spiel kämpfen',
          'Man geht raus, um zu gewinnen, auch wenn es für nichts mehr '
              'zählt. Die Kabine versteht genau, was das heißt, und '
              'antwortet: keiner will die Mannschaft sein, die sich hat '
              'fallen lassen.',
        ),
      },
    ),
    'jugador_llega_tarde': TextoDeEvento(
      titulo: '{jugador} kommt schon wieder zu spät',
      texto:
          'Zum dritten Mal in diesem Monat steht er erst da, als das '
          'Training längst läuft. Die ersten beiden Male hast du es '
          'durchgehen lassen. Dieses Mal haben es alle gesehen.',
      opciones: {
        'multarle': TextoDeOpcion(
          'Ihn bestrafen',
          'Über die Strafe wird in der Kabine geredet und sie kommt nicht '
              'gut an, aber in der Woche darauf kommt niemand mehr zu '
              'spät.',
        ),
        'hablar_en_privado': TextoDeOpcion(
          'Unter vier Augen mit ihm reden',
          'Er verlässt das Büro getroffen und dankbar zugleich, und er '
              'liefert. Das Problem ist, dass alle anderen gerade gesehen '
              'haben, dass dreimal zu spät kommen nichts kostet.',
        ),
        'sentarle_un_partido': TextoDeOpcion(
          'Ihn ein Spiel draußen lassen',
          'Er verpasst das nächste Spiel und die Lücke in der Rotation ist '
              'zu sehen. Dafür steht die Regel jetzt fest, ohne dass sie '
              'jemand aufschreiben musste.',
        ),
      },
    ),
    'camiseta_de_una_leyenda': TextoDeEvento(
      titulo: 'Das Trikot einer Legende unter die Hallendecke',
      texto:
          'Der Klub will sein Trikot noch in dieser Saison aufhängen. '
          'Das Datum suchst du aus, und die Zeremonie frisst einen Teil '
          'des Spieltags.',
      opciones: {
        'ceremonia_a_lo_grande': TextoDeOpcion(
          'Groß aufziehen, in der Halbzeit',
          'Eine halbe Stunde Zeremonie, die Halle steht und die Stadt redet '
              'eine Woche darüber. Die Spieler kamen kalt aus der Kabine '
              'und dieses Spiel hat es gekostet.',
        ),
        'algo_breve': TextoDeOpcion(
          'Eine kurze Ehrung vor dem Spiel',
          'Zehn Minuten, Trikot hoch, Ball rein. Es stört niemanden und es '
              'füllt die Halle auch nicht so, wie es das andere getan '
              'hätte.',
        ),
        'dejarlo_para_el_verano': TextoDeOpcion(
          'Auf den Sommer verschieben',
          'Eine saubere Arbeitswoche ohne Unterbrechung. Die Legende hat '
              'öffentlich nichts gesagt, geht aber seitdem nicht mehr ans '
              'Telefon.',
        ),
      },
    ),
    'entrenador_pide_mando': TextoDeEvento(
      titulo: 'Der Trainer will die volle Verantwortung',
      texto:
          'Er will Rotation und Minuten selbst bestimmen, ohne dass ihm '
          'jemand von oben sagt, wen er setzt. Er sagt, wenn er für die '
          'Ergebnisse geradesteht, will er auch für die Entscheidungen '
          'geradestehen.',
      opciones: {
        'darle_mando': TextoDeOpcion(
          'Sie ihm geben',
          'Er wirkt wie ausgewechselt: zwei sehr gute Spiele, sobald er es '
              'auf seine Art machen darf. Verloren hast du die Bank — ab '
              'jetzt erfährst du die Dinge, wenn sie schon entschieden '
              'sind.',
        ),
        'mando_compartido': TextoDeOpcion(
          'Gemeinsam entscheiden',
          'Die ersten Wochen sind unbequem, und es gibt zwei Sitzungen, wo '
              'früher eine war. Aber hinterher kann sich keiner '
              'wegducken, weil ihr alles zu zweit abgesegnet habt.',
        ),
        'decidir_tu': TextoDeOpcion(
          'Du triffst die Entscheidungen',
          'Es ist klar, wer bestimmt, und die Mannschaft nimmt es ein paar '
              'Spiele lang dankbar an. Der Trainer sagte, das sei kein '
              'Problem — schlägt aber nichts mehr vor.',
        ),
      },
    ),
    'metida_de_pata_en_redes': TextoDeEvento(
      titulo: '{jugador} hat es in den sozialen Medien verbockt',
      texto:
          'Er hat um drei Uhr nachts gepostet, die Schiedsrichter hätten '
          'es auf ihn abgesehen. Nach zwanzig Minuten hat er es gelöscht; '
          'da hatte es längst jeder als Screenshot.',
      opciones: {
        'multarle_y_zanjarlo': TextoDeOpcion(
          'Bestrafen und abhaken',
          'In einem Tag erledigt, und die anderen wissen, wo die Grenze '
              'liegt. Er verdaut die Strafe schlecht und man merkt es ein '
              'paar Wochen.',
        ),
        'defenderle_en_publico': TextoDeOpcion(
          'Sich öffentlich vor ihn stellen',
          'Du hast auf der Pressekonferenz gesagt, dass er nicht ganz '
              'unrecht hat. Die Kabine wird dir das die ganze Saison nicht '
              'vergessen; die Liga auch nicht, und die Strafe zahlt der '
              'Klub.',
        ),
        'obligarle_a_disculparse': TextoDeOpcion(
          'Ihn zu einer öffentlichen Entschuldigung zwingen',
          'Er liest eine Erklärung vor, die er nicht geschrieben hat, und '
              'man sieht es ihm an. Unangenehm für alle, aber nach drei '
              'Tagen redet keiner mehr davon.',
        ),
      },
    ),
    'precio_de_las_entradas': TextoDeEvento(
      titulo: 'Oben will man die Ticketpreise erhöhen',
      texto:
          'Die Mannschaft läuft, die Halle ist voll, und die Eigentümer '
          'sehen den Moment gekommen, die Preise für den Rest des Jahres '
          'anzuheben.',
      opciones: {
        'subirlas': TextoDeOpcion(
          'Erhöhen',
          'Es kommt richtig Geld herein und die Gehaltsobergrenze atmet '
              'auf. Die Stammgäste haben es nicht verstanden, und die '
              'Halle klingt nicht mehr, wie sie geklungen hat.',
        ),
        'subirlas_un_poco': TextoDeOpcion(
          'Nur ein wenig erhöhen',
          'Eine Anpassung, die man weder an der Kasse noch an der '
              'Stimmung groß merkt. Am ersten Abend gab es ein paar Pfiffe, '
              'mehr nicht.',
        ),
        'no_tocarlas': TextoDeOpcion(
          'Die Preise lassen',
          'Die Fans erfahren, dass du Nein gesagt hast, und die Halle wird '
              'zum Problem für jeden, der hier antreten muss. Das Geld '
              'gibt es dann eben ein andermal.',
        ),
      },
    ),
    'nutricionista': TextoDeEvento(
      titulo: 'Der Ernährungsberater will alles umstellen',
      texto:
          'Er will die Verpflegung des Klubs von Grund auf neu machen: '
          'neue Menüs, eigene Küche und Schluss mit Burgern im Flugzeug. '
          'Das kostet Geld und dem halben Kader passt es überhaupt nicht.',
      opciones: {
        'cambiarlo_todo': TextoDeOpcion(
          'Alles umstellen',
          'Zwei Wochen Gemecker und lange Gesichter im Speisesaal. Danach '
              'kommt die Mannschaft deutlich besser ins letzte Viertel, '
              'und das bestreitet dann keiner mehr.',
        ),
        'solo_en_los_viajes': TextoDeOpcion(
          'Nur auf Auswärtsfahrten',
          'Das Schlimmste ist behoben — Essen zu unmöglichen Zeiten im '
              'Flugzeug — und keiner meckert, weil zu Hause alles bleibt, '
              'wie es war.',
        ),
        'dejarlo_como_esta': TextoDeOpcion(
          'Alles so lassen',
          'Keiner beschwert sich und die Routine bleibt unangetastet. Der '
              'Ernährungsberater legt seinen Bericht ab und bringt ihn nie '
              'wieder zur Sprache; wahr ist darin trotzdem alles.',
        ),
      },
    ),
  };
}
