part of 'textos_eventos.dart';

/// El guion en francés.
class EventosFr extends TextosDeEventos {
  const EventosFr();

  @override
  String get jugadorGenerico => 'le joueur';

  @override
  Map<String, String> get etiquetasDeEfecto => const {
    'buen_rollo': 'Bonne ambiance dans le vestiaire',
    'piernas_cansadas': 'Jambes lourdes',
    'piernas_frescas': 'Jambes fraîches',
    'grupo_frio': 'Groupe refroidi',
    'vestuario_tenso': 'Vestiaire tendu',
    'disciplina': 'Discipline',
    'vestuario_roto': 'Vestiaire divisé',
    'sin_tu_mejor_jugador': 'Sans ton meilleur joueur',
    'plantilla_fresca': 'Effectif reposé',
    'plantilla_al_limite': 'Effectif à bout',
    'rotacion_verde': 'Rotation trop jeune',
    'grupo_enchufado': 'Groupe à fond',
    'banquillo_descontento': 'Banc mécontent',
    'el_grupo_va_contigo': 'Le groupe est avec toi',
    'nadie_se_da_por_aludido': 'Personne ne se remet en question',
    'vestuario_dolido': 'Vestiaire blessé',
    'nadie_dio_la_cara': 'Personne ne les a défendus',
    'el_ruido_se_apaga': 'Le bruit retombe',
    'a_todo_gas': 'À plein régime',
    'desgaste_acumulado': 'Usure accumulée',
    'se_corta_la_racha': 'La série s’arrête',
    'cargas_controladas': 'Charges maîtrisées',
    'la_grada_empuja': 'Le public pousse',
    'una_manana_sin_entrenar': 'Une matinée sans entraînement',
    'manana_de_trabajo': 'Matinée de travail',
    'la_grada_fria': 'Public refroidi',
    'dia_de_rodaje': 'Journée de tournage',
    'manana_de_fotos': 'Matinée photo',
    'plantilla_descansada': 'Effectif au repos',
    'un_partido_de_mas': 'Un match de trop',
    'la_ciudad_se_vuelca': 'La ville se mobilise',
    'el_banquillo_coge_ritmo': 'Le banc prend le rythme',
    'semana_de_descanso': 'Semaine de repos',
    'bien_descansados': 'Bien reposés',
    'sin_trabajo_tactico': 'Pas de travail tactique',
    'se_han_dicho_las_cosas': 'Ils se sont tout dit',
    'el_vestuario_va_por_libre': 'Le vestiaire se gère seul',
    'la_charla_no_llego_a_pasar': 'La discussion n’a pas eu lieu',
    'sabes_lo_que_hay': 'Tu sais à quoi t’en tenir',
    'rotacion_corta': 'Rotation courte',
    'titulares_fundidos': 'Titulaires cramés',
    'suplentes_en_pista': 'Remplaçants sur le parquet',
    // Segunda tanda.
    'jugador_liberado': 'Joueur libéré',
    'nadie_teme_por_su_puesto': 'Plus personne ne craint pour sa place',
    'jugador_tocado': 'Joueur touché',
    'se_juegan_el_puesto': 'Chacun joue sa place',
    'duda_en_el_vestuario': 'Le doute dans le vestiaire',
    'equipo_desarmado': 'Équipe démantelée',
    'orgullo_del_grupo': 'La fierté du groupe',
    'jugador_agradecido': 'Joueur reconnaissant',
    'el_resto_toma_nota': 'Les autres prennent note',
    'sin_uno_de_la_rotacion': 'Un rotation en moins',
    'norma_clara': 'La règle est claire',
    'descanso_roto': 'Mi-temps hachée',
    'homenaje_discreto': 'Hommage discret',
    'rutina_intacta': 'Routine intacte',
    'la_leyenda_dolida': 'La légende, vexée',
    'entrenador_con_las_riendas': 'Le coach a les rênes',
    'pierdes_el_banquillo': 'Tu as perdu le banc',
    'equilibrio_incomodo': 'Équilibre inconfortable',
    'nadie_se_desmarca': 'Personne ne peut se défiler',
    'mano_firme': 'Main ferme',
    'entrenador_dolido': 'Coach vexé',
    'jugador_resentido': 'Joueur rancunier',
    'disculpa_forzada': 'Excuses forcées',
    'algo_de_ruido_en_la_grada': 'Quelques murmures en tribunes',
    'protestas_en_el_comedor': 'Ça râle au réfectoire',
    'plantilla_mejor_alimentada': 'Effectif mieux nourri',
    'pequeno_cambio': 'Un petit changement',
    'mismo_de_siempre': 'Comme avant',
    // Compromisos de patrocinio (ver patrocinadores.dart).
    'dias_de_medios': 'Journées médias',
    'pabellon_con_otro_nombre': 'La salle sous un autre nom',
    'compromisos_de_marca': 'Obligations de marque',
    'trabajo_con_la_ciudad': 'Travail avec la ville',
  };

  @override
  Map<String, TextoDeEvento> get eventos => const {
    'cena_de_equipo': TextoDeEvento(
      titulo: 'Dîner d’équipe',
      texto:
          'Les cadres veulent organiser un dîner pour tout l’effectif, '
          'staff compris. Ils disent qu’il faut relâcher la pression.',
      opciones: {
        'noche_larga': TextoDeOpcion(
          'Qu’elle dure toute la nuit',
          'Le vestiaire s’est vraiment lâché et ça se voit sur le '
              'parquet. Les deux prochains matchs vont piquer : personne '
              'n’a dormi ce qu’il fallait.',
        ),
        'cena_corta': TextoDeOpcion(
          'Dîner rapide et au lit',
          'Deux heures, quelques rires et tout le monde rentre. Ça ne règle '
              'pas tout, mais le groupe est un peu plus soudé et '
              'l’entraînement tient demain.',
        ),
        'ahora_no_toca': TextoDeOpcion(
          'Ce n’est pas le moment',
          'Entraînement et repos. Les jambes sont fraîches pour le prochain '
              'match, mais personne n’a oublié que tu as dit non : le '
              'groupe est plus froid qu’avant.',
        ),
      },
    ),
    'bronca_en_el_entrenamiento': TextoDeEvento(
      titulo: 'Ça a dégénéré à l’entraînement',
      texto:
          'Deux joueurs sont passés des mots aux mains pendant un cinq '
          'contre cinq. On les a séparés au vestiaire et la presse est '
          'déjà au courant.',
      opciones: {
        'multar_a_los_dos': TextoDeOpcion(
          'Sanctionner les deux',
          'Tout le monde sait qui commande. Le vestiaire est tendu quelques '
              'jours, mais personne ne recommencera.',
        ),
        'que_lo_arreglen_ellos': TextoDeOpcion(
          'Qu’ils règlent ça entre eux',
          'Ils se serrent la main devant le groupe. Ça a l’air sincère.',
        ),
        'mirar_a_otro_lado': TextoDeOpcion(
          'Fermer les yeux',
          'Personne ne dit rien et l’affaire s’envenime. Sur le '
              'parquet ça se voit : le ballon ne circule plus pareil.',
        ),
      },
    ),
    'estrella_pide_descanso': TextoDeEvento(
      titulo: '{jugador} demande à souffler',
      texto:
          'Il joue avec des douleurs depuis novembre. Il n’est pas '
          'blessé, mais il demande à s’asseoir quelques matchs pour '
          'arriver entier en fin de saison.',
      opciones: {
        'que_descanse': TextoDeOpcion(
          'Qu’il se repose',
          'Il rate quelques matchs et son absence se voit, mais il revient '
              'frais et affamé pour la période qui compte vraiment.',
        ),
        'te_necesito_ahora': TextoDeOpcion(
          'J’ai besoin de toi maintenant',
          'Il comprend et serre les dents. Il produit, mais on le voit '
              'traîner la jambe et le reste du groupe le remarque.',
        ),
      },
    ),
    'joven_pide_minutos': TextoDeEvento(
      titulo: '{jugador} réclame du temps de jeu',
      texto:
          '{jugador} passe la moitié de la saison scotché au '
          'banc. Son agent a appelé : soit il joue, soit il voit ailleurs '
          'l’été prochain.',
      opciones: {
        'dale_minutos': TextoDeOpcion(
          'Donne-lui du temps de jeu',
          'Les premiers matchs, on voit les coutures, mais il se libère vite '
              'et le vestiaire comprend qu’ici le travail est '
              'récompensé.',
        ),
        'que_se_lo_gane': TextoDeOpcion(
          'Qu’il le mérite à l’entraînement',
          'Il le prend mal et ça se lit sur son visage. Les autres jeunes '
              'notent comment ça marche ici.',
        ),
      },
    ),
    'prensa_dura': TextoDeEvento(
      titulo: 'La presse vous démolit',
      texto:
          'Après la dernière défaite, le journal de la ville a écrit que '
          'le vestiaire est mort et qu’il y a des gens en trop ici. On '
          'attend ta réponse.',
      opciones: {
        'defender_al_grupo': TextoDeOpcion(
          'Défendre le groupe en public',
          'Les joueurs l’apprécient : tu as pris pour eux quand '
              'personne ne le faisait. Le problème, c’est que les '
              'projecteurs sont sur toi et qu’à l’intérieur '
              'personne ne se sent visé par ce qu’il fait mal.',
        ),
        'darles_la_razon': TextoDeOpcion(
          'Leur donner raison',
          'Tu as reconnu en public que l’équipe n’est pas à la '
              'hauteur. C’est vrai, mais à l’intérieur ça passe '
              'mal.',
        ),
        'no_entrar_al_trapo': TextoDeOpcion(
          'Ne pas entrer dans le jeu',
          'Deux phrases toutes faites et retour à l’entraînement. Sans '
              'carburant, l’affaire s’éteint toute seule en '
              'quelques jours. Ce qui reste à l’intérieur, c’est '
              'que tu ne les as pas défendus.',
        ),
      },
    ),
    'racha_buena': TextoDeEvento(
      titulo: 'Personne ne vous arrête',
      texto:
          'L’équipe est lancée et on commence à parler de vous comme '
          'candidats. Le coach demande s’il pousse ou s’il lève '
          'le pied pour ne cramer personne.',
      opciones: {
        'apretar_mientras_dure': TextoDeOpcion(
          'Pousser tant que ça dure',
          'Entraînements à fond et la série s’allonge. L’usure '
              'viendra, mais plus tard.',
        ),
        'levantar_el_pie': TextoDeOpcion(
          'Lever le pied',
          'Charges allégées et minutes réparties. La série s’arrête '
              'plus tôt qu’en poussant, mais l’équipe arrive '
              'entière.',
        ),
      },
    ),
    'aficion_llena_el_pabellon': TextoDeEvento(
      titulo: 'La salle se remplit',
      texto:
          'Les billets partent et le public réclame un geste : un '
          'entraînement ouvert, des autographes, des photos. Ça coûte une '
          'matinée entière de travail.',
      opciones: {
        'abrir_las_puertas': TextoDeOpcion(
          'Ouvrir les portes',
          'La salle va vraiment pousser sur les prochains matchs, et la '
              'boutique du club n’a pas désempli de la matinée. La '
              'séance perdue se paie au match suivant.',
        ),
        'a_entrenar': TextoDeOpcion(
          'À l’entraînement, c’est le métier',
          'On travaille toute la matinée et ça se voit au match suivant. Le '
              'public comprend à moitié : quelques banderoles sont apparues '
              'dans les tribunes.',
        ),
      },
    ),
    'acto_publicitario': TextoDeEvento(
      titulo: 'Un sponsor veut tout l’effectif',
      texto:
          'Une marque de la ville met de l’argent sur la table pour '
          'une journée entière de tournage : tout l’effectif, séance '
          'photo et publicité. C’est une journée de travail perdue et '
          'les joueurs font déjà la tête.',
      opciones: {
        'firmar_el_acuerdo_entero': TextoDeOpcion(
          'Signer l’accord complet',
          'Tournage jusqu’à pas d’heure et joueurs de mauvaise '
              'humeur, mais le club empoche une belle somme qui donne de '
              'l’air sous le plafond salarial.',
        ),
        'negociar_algo_mas_corto': TextoDeOpcion(
          'Négocier plus court',
          'Une demi-matinée de photos et retour à l’entraînement. On '
              'touche moins, mais personne n’a perdu sa journée.',
        ),
        'decirles_que_no': TextoDeOpcion(
          'Refuser',
          'L’effectif apprend que tu leur as évité la corvée et arrive '
              'au match suivant avec des jambes neuves. L’argent, ce '
              'sera pour une autre année.',
        ),
      },
    ),
    'partido_benefico': TextoDeEvento(
      titulo: 'Match caritatif en semaine',
      texto:
          'La mairie organise un match de gala caritatif et veut '
          'l’équipe. Ça tombe pile entre deux matchs de saison '
          'régulière.',
      opciones: {
        'ir_con_los_titulares': TextoDeOpcion(
          'Y aller avec les titulaires',
          'Salle pleine et ville derrière l’équipe. C’est un match '
              'de plus dans des jambes qui étaient déjà justes.',
        ),
        'mandar_a_los_suplentes': TextoDeOpcion(
          'Envoyer les remplaçants',
          'Ceux du bout du banc prennent de vraies minutes et se libèrent. '
              'La recette est moindre, mais personne d’important ne '
              's’est fatigué.',
        ),
        'no_ir': TextoDeOpcion(
          'Ne pas y aller',
          'Une semaine propre de travail et de repos. L’événement a '
              'lieu sans vous, la ville le prend comme un affront et le club '
              'finit par compenser de sa poche.',
        ),
      },
    ),
    'viaje_infernal': TextoDeEvento(
      titulo: 'Cinq matchs à l’extérieur en huit jours',
      texto:
          'Le calendrier a lâché un déplacement très dur. Le préparateur '
          'physique propose de partir un jour plus tôt dans chaque ville : '
          'ça coûte cher mais ça économise des heures d’avion.',
      opciones: {
        'viajar_con_margen': TextoDeOpcion(
          'Voyager avec de la marge',
          'L’équipe arrive reposée à chaque match. Ce qu’on perd, '
              'ce sont les séances vidéo et l’entraînement : on voyage '
              'beaucoup et on travaille peu.',
        ),
        'como_siempre': TextoDeOpcion(
          'Comme d’habitude',
          'Avions de nuit et hôtels à trois heures du matin. Ça va se '
              'sentir.',
        ),
      },
    ),
    'veterano_de_vestuario': TextoDeEvento(
      titulo: '{jugador} propose de parler au groupe',
      texto:
          '{jugador}, le plus ancien de l’effectif, te demande cinq '
          'minutes avec l’équipe, sans le staff. Il dit qu’il y a des '
          'choses qui se disent mieux entre joueurs.',
      opciones: {
        'dejales_solos': TextoDeOpcion(
          'Laisse-les entre eux',
          'Personne n’a raconté ce qui s’est dit là-dedans, mais '
              'l’équipe est sortie différente au match suivant. Ce qui '
              'a été décidé, ce sont eux qui l’ont décidé : tu es resté '
              'en dehors de cette conversation.',
        ),
        'prefiero_estar_delante': TextoDeOpcion(
          'Je préfère être présent',
          'La discussion reste à moitié faite — avec le patron dans la '
              'pièce personne ne dit ce qu’il pense — mais tu en sors '
              'en sachant exactement qui est avec qui dans ce vestiaire.',
        ),
      },
    ),
    'recta_final': TextoDeEvento(
      titulo: 'Les playoffs dans trois semaines',
      texto:
          'Il reste peu de matchs et tout est serré. Le staff demande '
          's’il faut raccourcir les rotations et s’appuyer sur '
          'les meilleurs.',
      opciones: {
        'tirar_de_los_titulares': TextoDeOpcion(
          'Tirer sur les titulaires',
          'Les meilleurs vont presque tout jouer. Ça paie maintenant et la '
              'facture arrive en avril.',
        ),
        'repartir_minutos': TextoDeOpcion(
          'Répartir les minutes',
          'Personne n’arrive cramé aux playoffs, mais on laisse filer '
              'un match ou deux dans la dernière ligne droite — et le '
              'classement se joue maintenant.',
        ),
      },
    ),

    // --- Segunda tanda -------------------------------------------
    'rumor_de_traspaso': TextoDeEvento(
      titulo: '{jugador} a lu son nom dans les rumeurs',
      texto:
          'Un journaliste a écrit que tu écoutes des offres pour '
          '{jugador}. Il te pose la question en face, devant la '
          'moitié du vestiaire.',
      opciones: {
        'prometerle_que_se_queda': TextoDeOpcion(
          'Lui promettre qu’il ne bouge pas',
          'Un poids en moins, et ça se voit dès la première possession. Ce '
              'que tout le monde a entendu aussi, c’est qu’ici on ne perd '
              'pas sa place en jouant mal.',
        ),
        'decirle_la_verdad': TextoDeOpcion(
          'Lui dire la vérité',
          'Tu lui as dit que oui, tu écoutes. Il reste touché quelques '
              'semaines, mais à partir de maintenant plus personne ne '
              'considère sa place comme acquise.',
        ),
        'no_contestar': TextoDeOpcion(
          'Ne pas répondre',
          'Une réponse qui ne dit rien. Il ressort comme il est entré et '
              'les autres restent avec le doute : tu n’as pas démenti, '
              'donc il y a quelque chose.',
        ),
      },
    ),
    'tanking_de_la_directiva': TextoDeEvento(
      titulo: 'La direction regarde déjà la draft',
      texto:
          'Les comptes ne mènent pas aux playoffs et en haut on '
          'préférerait finir bas pour choisir haut à la draft. Personne ne '
          'le dira à voix haute, mais le message est passé.',
      opciones: {
        'mirar_al_draft': TextoDeOpcion(
          'Penser à l’an prochain',
          'Des minutes pour le bout du banc et des douleurs vagues que '
              'personne n’explique vraiment chez les meilleurs. La fin de '
              'saison va être dure à regarder, mais en haut ils sont '
              'contents et ça se voit sur le budget.',
        ),
        'competir_hasta_el_final': TextoDeOpcion(
          'Jouer jusqu’au dernier match',
          'On sort pour gagner même quand ça ne sert à rien. Le vestiaire '
              'comprend parfaitement et répond : personne ne veut être '
              'l’équipe qui a lâché.',
        ),
      },
    ),
    'jugador_llega_tarde': TextoDeEvento(
      titulo: '{jugador} arrive encore en retard',
      texto:
          'Troisième fois ce mois-ci qu’il arrive après le début de '
          'l’entraînement. Les deux premières, tu as laissé passer. '
          'Celle-là, tout le monde l’a vue.',
      opciones: {
        'multarle': TextoDeOpcion(
          'Le sanctionner',
          'L’amende fait jaser dans le vestiaire et ça passe mal, mais la '
              'semaine suivante plus personne n’arrive en retard.',
        ),
        'hablar_en_privado': TextoDeOpcion(
          'Lui parler en tête-à-tête',
          'Il sort du bureau touché et reconnaissant à la fois, et il '
              'répond. Le problème, c’est que les autres viennent de voir '
              'que trois retards ne coûtent rien.',
        ),
        'sentarle_un_partido': TextoDeOpcion(
          'Le laisser sur le banc un match',
          'Il rate le suivant et son trou dans la rotation se voit. En '
              'échange, la règle est écrite sans que personne ait eu à '
              'l’écrire.',
        ),
      },
    ),
    'camiseta_de_una_leyenda': TextoDeEvento(
      titulo: 'Retirer le maillot d’une légende',
      texto:
          'Le club veut hisser son maillot sous le toit cette saison. La '
          'date, c’est toi qui la choisis, et la cérémonie mange une '
          'partie du jour de match.',
      opciones: {
        'ceremonia_a_lo_grande': TextoDeOpcion(
          'En faire un grand moment, à la mi-temps',
          'Une demi-heure de cérémonie, la salle debout et la ville qui en '
              'parle une semaine. Les joueurs sont revenus froids en '
              'deuxième mi-temps et ce match s’est payé.',
        ),
        'algo_breve': TextoDeOpcion(
          'Un hommage court avant le match',
          'Dix minutes, le maillot en haut et on joue. Ça ne gêne personne '
              'et ça ne remplit pas la salle comme l’autre l’aurait '
              'remplie.',
        ),
        'dejarlo_para_el_verano': TextoDeOpcion(
          'Repousser à l’été',
          'Une semaine de travail sans interruption. La légende n’a rien '
              'dit en public, mais elle ne décroche plus depuis.',
        ),
      },
    ),
    'entrenador_pide_mando': TextoDeEvento(
      titulo: 'Le coach veut les pleins pouvoirs',
      texto:
          'Il veut décider lui-même de la rotation et des minutes, sans '
          'que personne d’en haut lui dise qui s’assoit. Il dit que s’il '
          'répond des résultats, il veut répondre des décisions.',
      opciones: {
        'darle_mando': TextoDeOpcion(
          'Les lui donner',
          'On dirait un autre homme : deux très bons matchs dès qu’il peut '
              'faire les choses à sa façon. Ce que tu as perdu, c’est le '
              'banc — désormais tu apprends les choses une fois '
              'décidées.',
        ),
        'mando_compartido': TextoDeOpcion(
          'Décider à deux',
          'Les premières semaines sont inconfortables et il y a deux '
              'réunions là où il y en avait une. Mais plus personne ne '
              'pourra se défiler : vous avez tout signé ensemble.',
        ),
        'decidir_tu': TextoDeOpcion(
          'C’est toi qui décides',
          'On sait qui commande et l’équipe apprécie quelques matchs. Le '
              'coach a dit qu’il n’y avait pas de souci, mais il ne '
              'propose plus rien.',
        ),
      },
    ),
    'metida_de_pata_en_redes': TextoDeEvento(
      titulo: '{jugador} a dérapé sur les réseaux',
      texto:
          'Il a publié à trois heures du matin que les arbitres l’ont '
          'dans le viseur. Il a supprimé au bout de vingt minutes ; tout '
          'le monde avait déjà la capture.',
      opciones: {
        'multarle_y_zanjarlo': TextoDeOpcion(
          'Le sanctionner et clore le sujet',
          'Réglé en une journée, et les autres comprennent où est la '
              'limite. Lui digère mal l’amende et ça se voit quelques '
              'semaines.',
        ),
        'defenderle_en_publico': TextoDeOpcion(
          'Le défendre publiquement',
          'Tu as dit en conférence de presse qu’il n’a pas tout à fait '
              'tort. Le vestiaire ne l’oubliera pas de la saison ; la '
              'ligue non plus, et c’est le club qui paie l’amende.',
        ),
        'obligarle_a_disculparse': TextoDeOpcion(
          'L’obliger à s’excuser en public',
          'Il lit un communiqué qu’il n’a pas écrit et ça se lit sur son '
              'visage. Gênant pour tout le monde, mais en trois jours plus '
              'personne n’en parle.',
        ),
      },
    ),
    'precio_de_las_entradas': TextoDeEvento(
      titulo: 'On veut augmenter le prix des places',
      texto:
          'L’équipe gagne, la salle se remplit, et la propriété voit le '
          'moment d’augmenter les billets pour la fin de saison.',
      opciones: {
        'subirlas': TextoDeOpcion(
          'Augmenter',
          'De l’argent qui rentre pour de bon et le plafond salarial '
              'respire. Les habitués n’ont pas compris, et la salle ne '
              'sonne plus comme avant.',
        ),
        'subirlas_un_poco': TextoDeOpcion(
          'Augmenter juste un peu',
          'Un ajustement qui ne se voit ni à la billetterie ni dans '
              'l’ambiance. Quelques sifflets le premier soir, rien de '
              'plus.',
        ),
        'no_tocarlas': TextoDeOpcion(
          'Ne pas y toucher',
          'Le public apprend que tu as refusé, et la salle devient un '
              'problème pour celui qui vient jouer. L’argent, ce sera pour '
              'une autre année.',
        ),
      },
    ),
    'nutricionista': TextoDeEvento(
      titulo: 'Le nutritionniste veut tout changer',
      texto:
          'Il propose de refaire l’alimentation du club de fond en '
          'comble : nouveaux menus, cuisine sur place, et fini les burgers '
          'dans l’avion. Ça coûte cher et la moitié de l’effectif fait la '
          'grimace.',
      opciones: {
        'cambiarlo_todo': TextoDeOpcion(
          'Tout changer',
          'Deux semaines de râleries et de têtes fermées au réfectoire. '
              'Ensuite, on arrive nettement mieux dans le quatrième '
              'quart-temps, et ça, plus personne ne le discute.',
        ),
        'solo_en_los_viajes': TextoDeOpcion(
          'Seulement en déplacement',
          'On règle le pire — manger à des heures impossibles dans un avion '
              '— et personne ne râle, puisqu’à la maison rien ne change.',
        ),
        'dejarlo_como_esta': TextoDeOpcion(
          'Laisser comme ça',
          'Personne ne se plaint et la routine reste intacte. Le '
              'nutritionniste range son rapport et n’en reparle jamais ; '
              'tout ce qu’il y avait dedans reste vrai.',
        ),
      },
    ),
  };
}
