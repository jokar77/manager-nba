part of 'textos_eventos.dart';

/// El guion en inglés. Traducido por sentido, no palabra por palabra: el
/// español tira de expresiones de vestuario que en inglés suenan raras
/// literales ("no entrar al trapo" no es "not entering the rag"), así que
/// se ha buscado la frase que diría un entrenador de la NBA en esa misma
/// situación.
class EventosEn extends TextosDeEventos {
  const EventosEn();

  @override
  Map<String, String> get etiquetasDeEfecto => const {
    'buen_rollo': 'Good vibes in the locker room',
    'piernas_cansadas': 'Heavy legs',
    'piernas_frescas': 'Fresh legs',
    'grupo_frio': 'Cold locker room',
    'vestuario_tenso': 'Tense locker room',
    'disciplina': 'Discipline',
    'vestuario_roto': 'Locker room split',
    'sin_tu_mejor_jugador': 'Without your best player',
    'plantilla_fresca': 'Rested roster',
    'plantilla_al_limite': 'Roster running on empty',
    'rotacion_verde': 'Green rotation',
    'grupo_enchufado': 'Team bought in',
    'banquillo_descontento': 'Unhappy bench',
    'el_grupo_va_contigo': 'The team is behind you',
    'nadie_se_da_por_aludido': 'Nobody takes the blame',
    'vestuario_dolido': 'Locker room stung',
    'nadie_dio_la_cara': 'Nobody stood up for them',
    'el_ruido_se_apaga': 'The noise dies down',
    'a_todo_gas': 'Full throttle',
    'desgaste_acumulado': 'Mileage piling up',
    'se_corta_la_racha': 'The streak ends',
    'cargas_controladas': 'Managed workload',
    'la_grada_empuja': 'The crowd is behind you',
    'una_manana_sin_entrenar': 'A morning without practice',
    'manana_de_trabajo': 'A morning of work',
    'la_grada_fria': 'Cold crowd',
    'dia_de_rodaje': 'All-day shoot',
    'manana_de_fotos': 'Photo-shoot morning',
    'plantilla_descansada': 'Roster rested',
    'un_partido_de_mas': 'One game too many',
    'la_ciudad_se_vuelca': 'The city rallies behind you',
    'el_banquillo_coge_ritmo': 'The bench finds a rhythm',
    'semana_de_descanso': 'A week of rest',
    'bien_descansados': 'Well rested',
    'sin_trabajo_tactico': 'No tactical work',
    'se_han_dicho_las_cosas': 'They cleared the air',
    'el_vestuario_va_por_libre': 'The locker room runs itself',
    'la_charla_no_llego_a_pasar': 'The talk never really happened',
    'sabes_lo_que_hay': 'You know where everyone stands',
    'rotacion_corta': 'Short rotation',
    'titulares_fundidos': 'Starters worn down',
    'suplentes_en_pista': 'Backups on the floor',
    // Segunda tanda.
    'jugador_liberado': 'A weight off his shoulders',
    'nadie_teme_por_su_puesto': 'Nobody fears for their spot',
    'jugador_tocado': 'Player shaken',
    'se_juegan_el_puesto': 'Everyone playing for their spot',
    'duda_en_el_vestuario': 'Doubt in the locker room',
    'equipo_desarmado': 'Team stripped down',
    'orgullo_del_grupo': 'The group has its pride',
    'jugador_agradecido': 'Player grateful',
    'el_resto_toma_nota': 'The rest take note',
    'sin_uno_de_la_rotacion': 'Down a rotation player',
    'norma_clara': 'The rule is clear',
    'descanso_roto': 'Halftime broken up',
    'homenaje_discreto': 'A quiet tribute',
    'rutina_intacta': 'Routine untouched',
    'la_leyenda_dolida': 'The legend, slighted',
    'entrenador_con_las_riendas': 'Coach holding the reins',
    'pierdes_el_banquillo': 'You have lost the bench',
    'equilibrio_incomodo': 'An awkward balance',
    'nadie_se_desmarca': 'Nobody can duck the call',
    'mano_firme': 'A firm hand',
    'entrenador_dolido': 'Coach slighted',
    'jugador_resentido': 'Player resentful',
    'disculpa_forzada': 'A forced apology',
    'algo_de_ruido_en_la_grada': 'Some grumbling in the stands',
    'protestas_en_el_comedor': 'Complaints in the dining room',
    'plantilla_mejor_alimentada': 'Roster eating properly',
    'pequeno_cambio': 'A small change',
    'mismo_de_siempre': 'Same as it ever was',
    // Compromisos de patrocinio (ver patrocinadores.dart).
    'dias_de_medios': 'Media days',
    'pabellon_con_otro_nombre': 'The arena under another name',
    'compromisos_de_marca': 'Brand commitments',
    'trabajo_con_la_ciudad': 'Work with the city',
  };

  @override
  Map<String, TextoDeEvento> get eventos => const {
    'cena_de_equipo': TextoDeEvento(
      titulo: 'Team dinner',
      texto:
          'The veterans want to put together a dinner for the whole '
          'roster, coaching staff included. They say everyone needs to '
          'loosen up a little.',
      opciones: {
        'noche_larga': TextoDeOpcion(
          'Make it a long night',
          'The locker room really did loosen up, and you can see it on the '
              'floor. The next couple of games will be rough, though: '
              'nobody got the sleep they should have.',
        ),
        'cena_corta': TextoDeOpcion(
          'Quick dinner, then bed',
          'A couple of hours, some laughs, and home. It does not fix '
              'everything, but the group is a little tighter and practice '
              'is on in the morning.',
        ),
        'ahora_no_toca': TextoDeOpcion(
          'Not the right time',
          'Practice and rest instead. Legs are fresh for the next game, but '
              'nobody has forgotten that you said no: the group is colder '
              'than it was.',
        ),
      },
    ),
    'bronca_en_el_entrenamiento': TextoDeEvento(
      titulo: 'A fight broke out at practice',
      texto:
          'Two players went from words to shoving during a five-on-five. '
          'They have been separated in the locker room and the press '
          'already knows.',
      opciones: {
        'multar_a_los_dos': TextoDeOpcion(
          'Fine them both',
          'Everyone knows who is in charge now. The locker room is tense '
              'for a few days, but nobody is going to try that again.',
        ),
        'que_lo_arreglen_ellos': TextoDeOpcion(
          'Let them sort it out',
          'They shake hands in front of the group. It looks genuine.',
        ),
        'mirar_a_otro_lado': TextoDeOpcion(
          'Look the other way',
          'Nobody says a word and the thing festers. You can see it on the '
              'floor: the ball does not move the way it used to.',
        ),
      },
    ),
    'estrella_pide_descanso': TextoDeEvento(
      titulo: 'Your best player wants rest',
      texto:
          'He has been playing through soreness since November. He is '
          'not injured, but he is asking to sit a few games so he is whole '
          'for the end of the season.',
      opciones: {
        'que_descanse': TextoDeOpcion(
          'Sit him down',
          'You lose a few games and his absence shows, but he comes back '
              'fresh and hungry for the stretch that actually matters.',
        ),
        'te_necesito_ahora': TextoDeOpcion(
          'I need you now',
          'He gets it and grits his teeth. He produces, but you can see him '
              'dragging that leg and the rest of the group notices.',
        ),
      },
    ),
    'joven_pide_minutos': TextoDeEvento(
      titulo: 'A young player wants minutes',
      texto:
          'One of your kids has spent half a season glued to the bench. '
          'His agent called: either he plays, or he finds somewhere else '
          'next summer.',
      opciones: {
        'dale_minutos': TextoDeOpcion(
          'Give him minutes',
          'The first few games expose him, but he settles in fast and the '
              'locker room sees that work gets rewarded here.',
        ),
        'que_se_lo_gane': TextoDeOpcion(
          'He earns it in practice',
          'He takes it badly and it shows on his face. The rest of the '
              'young guys take note of how things work around here.',
        ),
      },
    ),
    'prensa_dura': TextoDeEvento(
      titulo: 'The press is hammering you',
      texto:
          'After the last loss, the city paper ran a piece saying the '
          'locker room is dead and there are people here who should not '
          'be. They want a response.',
      opciones: {
        'defender_al_grupo': TextoDeOpcion(
          'Defend the group publicly',
          'The players appreciate it: you took the hit for them when nobody '
              'else would. The problem is the spotlight is on you now, and '
              'inside nobody feels called out for what they are doing '
              'wrong.',
        ),
        'darles_la_razon': TextoDeOpcion(
          'Admit they are right',
          'You said publicly that the team is not good enough. It is true, '
              'but it did not go down well inside.',
        ),
        'no_entrar_al_trapo': TextoDeOpcion(
          'Refuse to take the bait',
          'Two stock lines and back to practice. With no fuel, the story '
              'burns out on its own in a few days. What sticks inside is '
              'that you did not stand up for them.',
        ),
      },
    ),
    'racha_buena': TextoDeEvento(
      titulo: 'Nobody can stop you',
      texto:
          'The team is rolling and people are starting to talk about you '
          'as contenders. The coach is asking whether to push or ease off '
          'so nobody burns out.',
      opciones: {
        'apretar_mientras_dure': TextoDeOpcion(
          'Push while it lasts',
          'Full-tilt practices and the streak stretches out. The mileage '
              'will come due, just later.',
        ),
        'levantar_el_pie': TextoDeOpcion(
          'Ease off',
          'Lighter loads and minutes spread around. The streak ends sooner '
              'than it would have, but the team comes through it whole.',
        ),
      },
    ),
    'aficion_llena_el_pabellon': TextoDeEvento(
      titulo: 'The arena is selling out',
      texto:
          'Tickets are running out and the fans want something back: an '
          'open practice, autographs, photos. It costs a full morning of '
          'work.',
      opciones: {
        'abrir_las_puertas': TextoDeOpcion(
          'Open the doors',
          'The building is going to be loud for the next few games, and the '
              'team store has not stopped all morning. The lost session '
              'gets paid for in the next game.',
        ),
        'a_entrenar': TextoDeOpcion(
          'Practice, like we are supposed to',
          'A full morning of work and it shows in the next game. The fans '
              'half understand: a couple of banners went up in the stands.',
        ),
      },
    ),
    'acto_publicitario': TextoDeEvento(
      titulo: 'A sponsor wants the whole roster',
      texto:
          'A local brand is putting money on the table for a full day of '
          'shooting: the entire roster, a photo session and a commercial. '
          'It costs a working day and the players are already pulling '
          'faces.',
      opciones: {
        'firmar_el_acuerdo_entero': TextoDeOpcion(
          'Sign the whole deal',
          'Shooting until all hours and players in a foul mood, but the '
              'club takes home a decent chunk that gives you room under the '
              'cap.',
        ),
        'negociar_algo_mas_corto': TextoDeOpcion(
          'Negotiate something shorter',
          'Half a morning of photos and back to practice. Less money, but '
              'nobody lost the whole day.',
        ),
        'decirles_que_no': TextoDeOpcion(
          'Turn them down',
          'The roster finds out you spared them the hassle and shows up to '
              'the next game with fresh legs. The money can wait for '
              'another year.',
        ),
      },
    ),
    'partido_benefico': TextoDeEvento(
      titulo: 'Midweek charity game',
      texto:
          'City hall is organising a charity exhibition and wants the '
          'team. It falls right between two league games.',
      opciones: {
        'ir_con_los_titulares': TextoDeOpcion(
          'Send the starters',
          'A packed arena and the whole city behind the team. It is one '
              'more game on legs that were already stretched thin.',
        ),
        'mandar_a_los_suplentes': TextoDeOpcion(
          'Send the backups',
          'The guys at the end of the bench get real minutes and look loose '
              'out there. The gate is smaller, but nobody important got '
              'tired.',
        ),
        'no_ir': TextoDeOpcion(
          'Skip it',
          'A clean week of work and rest. The event goes ahead without you, '
              'the city reads it as a snub, and the club ends up making up '
              'for it out of its own pocket.',
        ),
      },
    ),
    'viaje_infernal': TextoDeEvento(
      titulo: 'Five road games in eight days',
      texto:
          'The schedule has left you a brutal trip. The strength coach '
          'suggests flying into each city a day early — expensive, but it '
          'saves hours in the air.',
      opciones: {
        'viajar_con_margen': TextoDeOpcion(
          'Travel with room to spare',
          'The team arrives rested for every game. What you lose is film '
              'and practice: a lot of travelling and very little work.',
        ),
        'como_siempre': TextoDeOpcion(
          'Same as always',
          'Red-eye flights and hotels at three in the morning. It is going '
              'to show.',
        ),
      },
    ),
    'veterano_de_vestuario': TextoDeEvento(
      titulo: 'A veteran offers to talk to the group',
      texto:
          'The oldest man on the roster asks for five minutes with the '
          'team, no coaching staff in the room. He says some things are '
          'better said player to player.',
      opciones: {
        'dejales_solos': TextoDeOpcion(
          'Leave them to it',
          'Nobody has said what went on in there, but the team came out '
              'different for the next game. Whatever got decided, they '
              'decided it: you were left out of that conversation.',
        ),
        'prefiero_estar_delante': TextoDeOpcion(
          'I would rather be in the room',
          'The talk goes half-way — with the boss standing there nobody '
              'says what they think — but you walk out knowing exactly who '
              'stands with whom in that locker room.',
        ),
      },
    ),
    'recta_final': TextoDeEvento(
      titulo: 'The playoffs start in three weeks',
      texto:
          'Few games left and everything is tight. The staff is asking '
          'whether to shorten the rotation and lean on the best players.',
      opciones: {
        'tirar_de_los_titulares': TextoDeOpcion(
          'Lean on the starters',
          'The best players are going to play almost everything. It pays '
              'off now and you settle the bill in April.',
        ),
        'repartir_minutos': TextoDeOpcion(
          'Spread the minutes',
          'Nobody arrives at the playoffs burnt out, but you drop a game or '
              'two down the stretch — and seeding is being decided right '
              'now.',
        ),
      },
    ),

    // --- Segunda tanda -------------------------------------------
    'rumor_de_traspaso': TextoDeEvento(
      titulo: 'He read his name in the rumours',
      texto:
          'A reporter wrote that you are listening to offers for one of '
          'your starters. He asks you straight out, with half the locker '
          'room standing there.',
      opciones: {
        'prometerle_que_se_queda': TextoDeOpcion(
          'Promise him he is not going anywhere',
          'The weight comes off him and you can see it from the first '
              'possession. What everyone else also heard is that a spot '
              'here does not get lost by playing badly.',
        ),
        'decirle_la_verdad': TextoDeOpcion(
          'Tell him the truth',
          'You told him yes, you are listening. It knocks him for a few '
              'weeks, but from now on nobody in that room assumes their '
              'spot is theirs.',
        ),
        'no_contestar': TextoDeOpcion(
          'Say nothing',
          'An answer that answers nothing. He walks out the way he walked '
              'in and the rest are left wondering: you did not deny it, so '
              'there must be something.',
        ),
      },
    ),
    'tanking_de_la_directiva': TextoDeEvento(
      titulo: 'The front office is already looking at the draft',
      texto:
          'The math does not add up for the playoffs and upstairs they '
          'would rather finish low and pick high. Nobody is going to say '
          'it out loud, but the message reached you.',
      opciones: {
        'mirar_al_draft': TextoDeOpcion(
          'Think about next year',
          'Minutes for the guys at the end of the bench and vague soreness '
              'nobody quite explains for the best ones. The rest of the '
              'season will be ugly to watch, but upstairs they are happy '
              'and it shows in the budget.',
        ),
        'competir_hasta_el_final': TextoDeOpcion(
          'Compete to the last game',
          'You go out to win even when it counts for nothing. The locker '
              'room understands exactly what that means and answers: '
              'nobody wants to be the team that let go.',
        ),
      },
    ),
    'jugador_llega_tarde': TextoDeEvento(
      titulo: 'Somebody is late again',
      texto:
          'Third time this month he has walked in after practice '
          'started. You let the first two slide. Everybody saw this one.',
      opciones: {
        'multarle': TextoDeOpcion(
          'Fine him',
          'The fine gets talked about in the locker room and it does not go '
              'down well, but the following week nobody is late.',
        ),
        'hablar_en_privado': TextoDeOpcion(
          'Talk to him alone',
          'He walks out of the office stung and grateful at the same time, '
              'and he responds. The problem is everyone else just watched '
              'being late three times cost nothing.',
        ),
        'sentarle_un_partido': TextoDeOpcion(
          'Sit him a game',
          'He misses the next one and the hole in the rotation shows. In '
              'exchange, the rule got written down without anyone having '
              'to write it.',
        ),
      },
    ),
    'camiseta_de_una_leyenda': TextoDeEvento(
      titulo: 'Retiring a legend’s jersey',
      texto:
          'The club wants to raise his jersey to the rafters this '
          'season. The date is yours to pick, and the ceremony eats into '
          'game day.',
      opciones: {
        'ceremonia_a_lo_grande': TextoDeOpcion(
          'Do it properly, at halftime',
          'Half an hour of ceremony, the building on its feet and the city '
              'talking about it for a week. The players came out cold for '
              'the second half and that game got paid for.',
        ),
        'algo_breve': TextoDeOpcion(
          'A short tribute before tip-off',
          'Ten minutes, jersey up, play ball. It gets in nobody’s way and '
              'it does not fill the building the way the other one would '
              'have.',
        ),
        'dejarlo_para_el_verano': TextoDeOpcion(
          'Leave it for the summer',
          'A clean week of work, no interruptions. The legend has not said '
              'anything publicly, but he has not picked up the phone '
              'since.',
        ),
      },
    ),
    'entrenador_pide_mando': TextoDeEvento(
      titulo: 'The coach wants full control',
      texto:
          'He wants to decide the rotation and the minutes himself, with '
          'nobody upstairs telling him who sits. He says if he answers for '
          'the results, he wants to answer for the decisions.',
      opciones: {
        'darle_mando': TextoDeOpcion(
          'Give it to him',
          'He looks like a different man: a couple of very good games as '
              'soon as he can do it his way. What you lost is the bench — '
              'from now on you find things out once they are decided.',
        ),
        'mando_compartido': TextoDeOpcion(
          'Decide it together',
          'The first few weeks are awkward and there are two meetings where '
              'there used to be one. But nobody gets to duck it later, '
              'because you both signed off on all of it.',
        ),
        'decidir_tu': TextoDeOpcion(
          'You make the calls',
          'It is clear who is in charge and the team appreciates it for a '
              'few games. The coach said it was no problem, but he does '
              'not suggest anything any more.',
        ),
      },
    ),
    'metida_de_pata_en_redes': TextoDeEvento(
      titulo: 'A player blew up on social media',
      texto:
          'He posted at three in the morning that the officials are out '
          'to get him. He deleted it in twenty minutes; by then everyone '
          'had a screenshot.',
      opciones: {
        'multarle_y_zanjarlo': TextoDeOpcion(
          'Fine him and move on',
          'Closed in a day, and the rest understand where the line is. He '
              'takes the fine badly and it shows for a few weeks.',
        ),
        'defenderle_en_publico': TextoDeOpcion(
          'Back him publicly',
          'You said at the press conference that he has a point. The locker '
              'room will not forget it all year; neither will the league, '
              'and the club eats the fine.',
        ),
        'obligarle_a_disculparse': TextoDeOpcion(
          'Make him apologise publicly',
          'He reads out a statement he did not write and you can see it on '
              'his face. Uncomfortable for everyone, but in three days '
              'nobody is talking about it.',
        ),
      },
    ),
    'precio_de_las_entradas': TextoDeEvento(
      titulo: 'They want to raise ticket prices',
      texto:
          'The team is winning, the building is full, and ownership sees '
          'the moment to put ticket prices up for the rest of the year.',
      opciones: {
        'subirlas': TextoDeOpcion(
          'Raise them',
          'Real money comes in and the cap breathes. The regulars did not '
              'take it well, and the building does not sound the way it '
              'used to.',
        ),
        'subirlas_un_poco': TextoDeOpcion(
          'Raise them a little',
          'An adjustment you barely notice at the gate or in the '
              'atmosphere. A few boos on the first night and not much '
              'else.',
        ),
        'no_tocarlas': TextoDeOpcion(
          'Leave them alone',
          'The fans find out you said no, and the building becomes a '
              'problem for whoever visits. The money can wait for another '
              'year.',
        ),
      },
    ),
    'nutricionista': TextoDeEvento(
      titulo: 'The nutritionist wants to change everything',
      texto:
          'He wants to rebuild the club’s food from the ground up: new '
          'menus, a proper kitchen, and no more burgers on the plane. It '
          'costs money and half the roster is not amused.',
      opciones: {
        'cambiarlo_todo': TextoDeOpcion(
          'Change all of it',
          'Two weeks of complaints and long faces in the dining room. After '
              'that, the team gets to the fourth quarter in better shape, '
              'and nobody argues with that any more.',
        ),
        'solo_en_los_viajes': TextoDeOpcion(
          'Only on the road',
          'You fix the worst of it — eating at odd hours on a plane — and '
              'nobody complains, because at home they still eat the same.',
        ),
        'dejarlo_como_esta': TextoDeOpcion(
          'Leave it as it is',
          'Nobody complains and the routine stays untouched. The '
              'nutritionist files the report away and never brings it up '
              'again; everything in it is still true.',
        ),
      },
    ),
  };
}
