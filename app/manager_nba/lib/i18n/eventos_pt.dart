part of 'textos_eventos.dart';

/// El guion en portugués de Brasil, que es el que habla el juego (ver
/// [Idioma.portugues]): vocabulario de vestiário brasileño, no de Portugal.
class EventosPt extends TextosDeEventos {
  const EventosPt();

  @override
  String get jugadorGenerico => 'o jogador';

  @override
  Map<String, String> get etiquetasDeEfecto => const {
    'buen_rollo': 'Clima bom no vestiário',
    'piernas_cansadas': 'Pernas pesadas',
    'piernas_frescas': 'Pernas descansadas',
    'grupo_frio': 'Grupo frio',
    'vestuario_tenso': 'Vestiário tenso',
    'disciplina': 'Disciplina',
    'vestuario_roto': 'Vestiário rachado',
    'sin_tu_mejor_jugador': 'Sem seu melhor jogador',
    'plantilla_fresca': 'Elenco descansado',
    'plantilla_al_limite': 'Elenco no limite',
    'rotacion_verde': 'Rotação verde',
    'grupo_enchufado': 'Grupo ligado',
    'banquillo_descontento': 'Banco insatisfeito',
    'el_grupo_va_contigo': 'O grupo está com você',
    'nadie_se_da_por_aludido': 'Ninguém se dá por aludido',
    'vestuario_dolido': 'Vestiário magoado',
    'nadie_dio_la_cara': 'Ninguém deu a cara por eles',
    'el_ruido_se_apaga': 'O barulho passa',
    'a_todo_gas': 'A todo vapor',
    'desgaste_acumulado': 'Desgaste acumulado',
    'se_corta_la_racha': 'A sequência acaba',
    'cargas_controladas': 'Cargas controladas',
    'la_grada_empuja': 'A torcida empurra',
    'una_manana_sin_entrenar': 'Uma manhã sem treino',
    'manana_de_trabajo': 'Manhã de trabalho',
    'la_grada_fria': 'Torcida fria',
    'dia_de_rodaje': 'Dia de gravação',
    'manana_de_fotos': 'Manhã de fotos',
    'plantilla_descansada': 'Elenco descansado',
    'un_partido_de_mas': 'Um jogo a mais',
    'la_ciudad_se_vuelca': 'A cidade abraça o time',
    'el_banquillo_coge_ritmo': 'O banco pega ritmo',
    'semana_de_descanso': 'Semana de descanso',
    'bien_descansados': 'Bem descansados',
    'sin_trabajo_tactico': 'Sem trabalho tático',
    'se_han_dicho_las_cosas': 'Puseram tudo em pratos limpos',
    'el_vestuario_va_por_libre': 'O vestiário se manda sozinho',
    'la_charla_no_llego_a_pasar': 'A conversa não rolou de verdade',
    'sabes_lo_que_hay': 'Você sabe com quem conta',
    'rotacion_corta': 'Rotação curta',
    'titulares_fundidos': 'Titulares desgastados',
    'suplentes_en_pista': 'Reservas em quadra',
    // Segunda tanda.
    'jugador_liberado': 'Jogador aliviado',
    'nadie_teme_por_su_puesto': 'Ninguém teme perder a vaga',
    'jugador_tocado': 'Jogador abalado',
    'se_juegan_el_puesto': 'Todo mundo jogando pela vaga',
    'duda_en_el_vestuario': 'Dúvida no vestiário',
    'equipo_desarmado': 'Time desmontado',
    'orgullo_del_grupo': 'O orgulho do grupo',
    'jugador_agradecido': 'Jogador agradecido',
    'el_resto_toma_nota': 'O resto toma nota',
    'sin_uno_de_la_rotacion': 'Um a menos na rotação',
    'norma_clara': 'A regra ficou clara',
    'descanso_roto': 'Intervalo quebrado',
    'homenaje_discreto': 'Homenagem discreta',
    'rutina_intacta': 'Rotina intacta',
    'la_leyenda_dolida': 'O ídolo, magoado',
    'entrenador_con_las_riendas': 'Treinador no comando',
    'pierdes_el_banquillo': 'Você perdeu o banco',
    'equilibrio_incomodo': 'Equilíbrio incômodo',
    'nadie_se_desmarca': 'Ninguém consegue se esquivar',
    'mano_firme': 'Mão firme',
    'entrenador_dolido': 'Treinador magoado',
    'jugador_resentido': 'Jogador ressentido',
    'disculpa_forzada': 'Desculpa forçada',
    'algo_de_ruido_en_la_grada': 'Algum resmungo na arquibancada',
    'protestas_en_el_comedor': 'Reclamação no refeitório',
    'plantilla_mejor_alimentada': 'Elenco melhor alimentado',
    'pequeno_cambio': 'Uma mudança pequena',
    'mismo_de_siempre': 'Tudo como sempre',
    // Compromisos de patrocinio (ver patrocinadores.dart).
    'dias_de_medios': 'Dias de mídia',
    'pabellon_con_otro_nombre': 'O ginásio com outro nome',
    'compromisos_de_marca': 'Compromissos de marca',
    'trabajo_con_la_ciudad': 'Trabalho com a cidade',
  };

  @override
  Map<String, TextoDeEvento> get eventos => const {
    'cena_de_equipo': TextoDeEvento(
      titulo: 'Jantar do time',
      texto:
          'Os veteranos querem organizar um jantar para o elenco '
          'inteiro, comissão técnica incluída. Dizem que todo mundo '
          'precisa relaxar um pouco.',
      opciones: {
        'noche_larga': TextoDeOpcion(
          'Que a noite seja longa',
          'O vestiário relaxou de verdade e dá para ver em quadra. Os dois '
              'próximos jogos vão custar caro: ninguém dormiu o que '
              'devia.',
        ),
        'cena_corta': TextoDeOpcion(
          'Jantar rápido e todo mundo dormir',
          'Duas horas, umas risadas e cada um para casa. Não resolve tudo, '
              'mas o grupo está um pouco mais unido e amanhã tem treino.',
        ),
        'ahora_no_toca': TextoDeOpcion(
          'Agora não é hora',
          'Treino e descanso. As pernas chegam novas no próximo jogo, mas '
              'ninguém esqueceu que você disse não: o grupo está mais frio '
              'do que estava.',
        ),
      },
    ),
    'bronca_en_el_entrenamiento': TextoDeEvento(
      titulo: 'Deu confusão no treino',
      texto:
          'Dois jogadores saíram das palavras para os empurrões num '
          'coletivo. Estão separados no vestiário e a imprensa já sabe.',
      opciones: {
        'multar_a_los_dos': TextoDeOpcion(
          'Multar os dois',
          'Fica claro quem manda. O vestiário fica tenso alguns dias, mas '
              'ninguém vai repetir a dose.',
        ),
        'que_lo_arreglen_ellos': TextoDeOpcion(
          'Que eles resolvam entre si',
          'Apertam a mão na frente do grupo. Parece sincero.',
        ),
        'mirar_a_otro_lado': TextoDeOpcion(
          'Fazer vista grossa',
          'Ninguém fala nada e o assunto azeda. Em quadra dá para ver: a '
              'bola não corre igual.',
        ),
      },
    ),
    'estrella_pide_descanso': TextoDeEvento(
      titulo: '{jugador} pede descanso',
      texto:
          'Ele joga com dores desde novembro. Não está machucado, mas '
          'pede para ficar de fora de alguns jogos e chegar inteiro no '
          'fim da temporada.',
      opciones: {
        'que_descanse': TextoDeOpcion(
          'Que descanse',
          'Ele perde alguns jogos e a ausência pesa, mas volta novo e com '
              'vontade para o trecho que realmente importa.',
        ),
        'te_necesito_ahora': TextoDeOpcion(
          'Preciso de você agora',
          'Ele entende e range os dentes. Rende, mas dá para ver que está '
              'arrastando a perna e o resto do grupo percebe.',
        ),
      },
    ),
    'joven_pide_minutos': TextoDeEvento(
      titulo: '{jugador} quer minutos',
      texto:
          '{jugador} passou meia temporada grudado no banco. '
          'O empresário ligou: ou ele joga, ou no verão que vem procura a '
          'vida em outro lugar.',
      opciones: {
        'dale_minutos': TextoDeOpcion(
          'Dê minutos a ele',
          'Nos primeiros jogos aparecem as falhas, mas ele se solta rápido '
              'e o vestiário vê que aqui trabalho é recompensado.',
        ),
        'que_se_lo_gane': TextoDeOpcion(
          'Que conquiste no treino',
          'Ele leva a mal e dá para ver na cara. O resto dos garotos toma '
              'nota de como as coisas funcionam por aqui.',
        ),
      },
    ),
    'prensa_dura': TextoDeEvento(
      titulo: 'A imprensa está detonando vocês',
      texto:
          'Depois da última derrota, o jornal da cidade publicou que o '
          'vestiário está morto e que tem gente sobrando aqui. Querem uma '
          'resposta sua.',
      opciones: {
        'defender_al_grupo': TextoDeOpcion(
          'Defender o grupo em público',
          'Os jogadores agradecem: você deu a cara a tapa quando ninguém '
              'dava. O problema é que agora o holofote está em você, e lá '
              'dentro ninguém se sente cobrado pelo que está fazendo de '
              'errado.',
        ),
        'darles_la_razon': TextoDeOpcion(
          'Dar razão a eles',
          'Você admitiu em público que o time não está à altura. É verdade, '
              'mas lá dentro não caiu bem.',
        ),
        'no_entrar_al_trapo': TextoDeOpcion(
          'Não entrar no jogo',
          'Duas frases prontas e volta ao treino. Sem lenha, o assunto '
              'morre sozinho em alguns dias. O que fica lá dentro é que '
              'você não saiu em defesa deles.',
        ),
      },
    ),
    'racha_buena': TextoDeEvento(
      titulo: 'Ninguém segura vocês',
      texto:
          'O time está embalado e já falam de vocês como candidatos ao '
          'título. O treinador pergunta se aperta ou se tira o pé para não '
          'queimar ninguém.',
      opciones: {
        'apretar_mientras_dure': TextoDeOpcion(
          'Apertar enquanto dura',
          'Treino no talo e a sequência se estica. O desgaste vai chegar, '
              'mas mais tarde.',
        ),
        'levantar_el_pie': TextoDeOpcion(
          'Tirar o pé',
          'Cargas mais leves e minutos divididos. A sequência acaba antes '
              'do que acabaria apertando, mas o time chega inteiro.',
        ),
      },
    ),
    'aficion_llena_el_pabellon': TextoDeEvento(
      titulo: 'A arena está lotando',
      texto:
          'Os ingressos estão acabando e a torcida pede um gesto: treino '
          'aberto, autógrafos, fotos. Custa uma manhã inteira de trabalho.',
      opciones: {
        'abrir_las_puertas': TextoDeOpcion(
          'Abrir as portas',
          'A arena vai empurrar de verdade nos próximos jogos, e a loja do '
              'clube não parou a manhã toda. A sessão de trabalho perdida '
              'se paga no jogo seguinte.',
        ),
        'a_entrenar': TextoDeOpcion(
          'Treinar, que é o que interessa',
          'Trabalha-se a manhã inteira e dá para ver no jogo seguinte. A '
              'torcida entende pela metade: apareceu faixa na '
              'arquibancada.',
        ),
      },
    ),
    'acto_publicitario': TextoDeEvento(
      titulo: 'Um patrocinador quer o elenco inteiro',
      texto:
          'Uma marca da cidade põe dinheiro na mesa por um dia inteiro '
          'de gravação: elenco completo, sessão de fotos e comercial. É um '
          'dia de trabalho perdido e os jogadores já fizeram cara feia.',
      opciones: {
        'firmar_el_acuerdo_entero': TextoDeOpcion(
          'Assinar o acordo inteiro',
          'Gravação até tarde e jogadores de mau humor, mas o clube leva '
              'uma boa bolada que dá folga no teto salarial.',
        ),
        'negociar_algo_mas_corto': TextoDeOpcion(
          'Negociar algo mais curto',
          'Meia manhã de fotos e de volta ao treino. Entra menos dinheiro, '
              'mas ninguém perdeu o dia inteiro.',
        ),
        'decirles_que_no': TextoDeOpcion(
          'Dizer que não',
          'O elenco fica sabendo que você livrou eles do abacaxi e chega no '
              'próximo jogo com as pernas novas. O dinheiro fica para '
              'outro ano.',
        ),
      },
    ),
    'partido_benefico': TextoDeEvento(
      titulo: 'Jogo beneficente no meio da semana',
      texto:
          'A prefeitura organiza um amistoso beneficente e quer o time. '
          'Cai bem no meio de dois jogos da temporada.',
      opciones: {
        'ir_con_los_titulares': TextoDeOpcion(
          'Ir com os titulares',
          'Ginásio lotado e a cidade inteira com o time. É mais um jogo em '
              'pernas que já vinham no limite.',
        ),
        'mandar_a_los_suplentes': TextoDeOpcion(
          'Mandar os reservas',
          'A turma do fim do banco pega minutos de verdade e joga solta. A '
              'renda é menor, mas ninguém importante se cansou.',
        ),
        'no_ir': TextoDeOpcion(
          'Não ir',
          'Semana limpa de trabalho e descanso. O evento acontece do mesmo '
              'jeito sem vocês, a cidade entende como desfeita e o clube '
              'acaba compensando do próprio bolso.',
        ),
      },
    ),
    'viaje_infernal': TextoDeEvento(
      titulo: 'Cinco jogos fora em oito dias',
      texto:
          'O calendário deixou uma viagem muito dura. O preparador '
          'físico propõe viajar um dia antes para cada cidade: sai caro, '
          'mas economiza horas de avião.',
      opciones: {
        'viajar_con_margen': TextoDeOpcion(
          'Viajar com folga',
          'O time chega descansado em todos os jogos. O que se perde são as '
              'sessões de vídeo e treino: viaja-se muito e trabalha-se '
              'pouco.',
        ),
        'como_siempre': TextoDeOpcion(
          'Como sempre',
          'Voos de madrugada e hotel às três da manhã. Vai pesar.',
        ),
      },
    ),
    'veterano_de_vestuario': TextoDeEvento(
      titulo: '{jugador} se oferece para falar com o grupo',
      texto:
          '{jugador}, o mais rodado do elenco, pede cinco minutos com o '
          'time, sem a comissão técnica na sala. Diz que tem coisa que se '
          'resolve melhor entre jogadores.',
      opciones: {
        'dejales_solos': TextoDeOpcion(
          'Deixe eles sozinhos',
          'Ninguém contou o que foi dito lá dentro, mas o time entrou '
              'diferente no jogo seguinte. O que ficou decidido, decidiram '
              'eles: você ficou de fora dessa conversa.',
        ),
        'prefiero_estar_delante': TextoDeOpcion(
          'Prefiro estar presente',
          'A conversa fica pela metade — com o chefe na sala ninguém fala o '
              'que pensa — mas você sai sabendo exatamente quem está com '
              'quem naquele vestiário.',
        ),
      },
    ),
    'recta_final': TextoDeEvento(
      titulo: 'Os playoffs começam em três semanas',
      texto:
          'Faltam poucos jogos e está tudo apertado. A comissão técnica '
          'pergunta se encurta a rotação para puxar pelos melhores.',
      opciones: {
        'tirar_de_los_titulares': TextoDeOpcion(
          'Puxar pelos titulares',
          'Os melhores vão jogar quase tudo. Rende agora e a conta chega '
              'em abril.',
        ),
        'repartir_minutos': TextoDeOpcion(
          'Dividir os minutos',
          'Ninguém chega queimado nos playoffs, mas na reta final se perde '
              'algum jogo pelo caminho — e a posição na tabela se decide '
              'justo agora.',
        ),
      },
    ),

    // --- Segunda tanda -------------------------------------------
    'rumor_de_traspaso': TextoDeEvento(
      titulo: '{jugador} leu o nome dele nos rumores',
      texto:
          'Um jornalista publicou que você está ouvindo propostas por '
          '{jugador}. Ele pergunta na sua cara, com meio '
          'vestiário ali do lado.',
      opciones: {
        'prometerle_que_se_queda': TextoDeOpcion(
          'Prometer que ele não sai',
          'Sai um peso das costas dele e dá para ver desde a primeira '
              'posse. O que todo mundo também ouviu é que aqui ninguém '
              'perde a vaga jogando mal.',
        ),
        'decirle_la_verdad': TextoDeOpcion(
          'Contar a verdade',
          'Você disse que sim, que está ouvindo. Ele fica abalado algumas '
              'semanas, mas daqui para frente ninguém naquele vestiário '
              'acha que a vaga é dele por direito.',
        ),
        'no_contestar': TextoDeOpcion(
          'Não responder',
          'Uma resposta que não diz nada. Ele sai como entrou e o resto '
              'fica com a dúvida: se você não negou, é porque tem coisa '
              'aí.',
        ),
      },
    ),
    'tanking_de_la_directiva': TextoDeEvento(
      titulo: 'A diretoria já está olhando o draft',
      texto:
          'A conta não fecha para os playoffs e lá em cima preferem '
          'terminar embaixo para escolher bem no draft. Ninguém vai dizer '
          'em voz alta, mas o recado chegou.',
      opciones: {
        'mirar_al_draft': TextoDeOpcion(
          'Pensar no ano que vem',
          'Minutos para a turma do fim do banco e dores vagas que ninguém '
              'explica direito nos melhores. O resto da temporada vai ser '
              'feio de assistir, mas lá em cima estão felizes e isso '
              'aparece no orçamento.',
        ),
        'competir_hasta_el_final': TextoDeOpcion(
          'Competir até o último jogo',
          'Entra-se para ganhar mesmo quando não vale nada. O vestiário '
              'entende exatamente o que isso significa e responde: '
              'ninguém quer ser o time que entregou.',
        ),
      },
    ),
    'jugador_llega_tarde': TextoDeEvento(
      titulo: '{jugador} chegou atrasado de novo',
      texto:
          'Terceira vez no mês que ele aparece com o treino já '
          'começado. Nas duas primeiras você deixou passar. Essa aqui todo '
          'mundo viu.',
      opciones: {
        'multarle': TextoDeOpcion(
          'Multar',
          'A multa vira assunto no vestiário e não cai bem, mas na semana '
              'seguinte ninguém chega atrasado.',
        ),
        'hablar_en_privado': TextoDeOpcion(
          'Conversar a sós',
          'Ele sai da sala tocado e agradecido ao mesmo tempo, e responde. '
              'O problema é que os outros acabaram de ver que atrasar três '
              'vezes não custa nada.',
        ),
        'sentarle_un_partido': TextoDeOpcion(
          'Deixar de fora um jogo',
          'Ele perde o próximo e o buraco na rotação aparece. Em troca, a '
              'regra ficou escrita sem ninguém precisar escrever.',
        ),
      },
    ),
    'camiseta_de_una_leyenda': TextoDeEvento(
      titulo: 'Aposentar a camisa de um ídolo',
      texto:
          'O clube quer pendurar a camisa dele no ginásio nesta '
          'temporada. A data é você quem escolhe, e a cerimônia come parte '
          'do dia de jogo.',
      opciones: {
        'ceremonia_a_lo_grande': TextoDeOpcion(
          'Fazer bonito, no intervalo',
          'Meia hora de cerimônia, o ginásio de pé e a cidade falando disso '
              'por uma semana. Os jogadores voltaram frios para o segundo '
              'tempo e aquele jogo foi cobrado.',
        ),
        'algo_breve': TextoDeOpcion(
          'Um ato curto antes do jogo',
          'Dez minutos, camisa lá em cima e bola ao alto. Não atrapalha '
              'ninguém e também não lota o ginásio como o outro teria '
              'lotado.',
        ),
        'dejarlo_para_el_verano': TextoDeOpcion(
          'Deixar para a pré-temporada',
          'Semana limpa de trabalho, sem interrupção. O ídolo não falou '
              'nada em público, mas não atende o telefone desde então.',
        ),
      },
    ),
    'entrenador_pide_mando': TextoDeEvento(
      titulo: 'O treinador quer comando total',
      texto:
          'Ele quer decidir sozinho a rotação e os minutos, sem ninguém '
          'lá de cima dizendo quem senta. Diz que, se responde pelos '
          'resultados, quer responder pelas decisões.',
      opciones: {
        'darle_mando': TextoDeOpcion(
          'Dar o comando a ele',
          'Parece outro: dois jogos muito bons assim que pode fazer do '
              'jeito dele. O que você perdeu foi o banco — de agora em '
              'diante você fica sabendo das coisas depois de decididas.',
        ),
        'mando_compartido': TextoDeOpcion(
          'Decidir junto',
          'As primeiras semanas são desconfortáveis e há duas reuniões onde '
              'antes havia uma. Mas ninguém consegue se esquivar depois, '
              'porque tudo foi assinado pelos dois.',
        ),
        'decidir_tu': TextoDeOpcion(
          'Quem decide é você',
          'Fica claro quem manda e o time agradece por alguns jogos. O '
              'treinador disse que não tem problema, mas parou de propor '
              'qualquer coisa.',
        ),
      },
    ),
    'metida_de_pata_en_redes': TextoDeEvento(
      titulo: '{jugador} se enrolou nas redes',
      texto:
          'Postou às três da manhã que a arbitragem está pegando no pé '
          'dele. Apagou em vinte minutos; a essa altura todo mundo já '
          'tinha o print.',
      opciones: {
        'multarle_y_zanjarlo': TextoDeOpcion(
          'Multar e encerrar o assunto',
          'Resolvido em um dia, e o resto entende onde está o limite. Ele '
              'engole mal a multa e isso aparece por algumas semanas.',
        ),
        'defenderle_en_publico': TextoDeOpcion(
          'Sair em defesa dele',
          'Você disse na coletiva que ele não está de todo errado. O '
              'vestiário não vai esquecer isso o ano inteiro; a liga '
              'também não, e a multa quem paga é o clube.',
        ),
        'obligarle_a_disculparse': TextoDeOpcion(
          'Obrigar a se desculpar em público',
          'Ele lê uma nota que não escreveu e dá para ver na cara dele. '
              'Constrangedor para todo mundo, mas em três dias ninguém '
              'fala mais no assunto.',
        ),
      },
    ),
    'precio_de_las_entradas': TextoDeEvento(
      titulo: 'Querem aumentar o preço dos ingressos',
      texto:
          'O time está bem, o ginásio lota, e a diretoria vê a hora de '
          'aumentar os ingressos para o resto do ano.',
      opciones: {
        'subirlas': TextoDeOpcion(
          'Aumentar',
          'Entra dinheiro de verdade e o teto salarial respira. A torcida '
              'de sempre não entendeu, e o ginásio já não soa como '
              'soava.',
        ),
        'subirlas_un_poco': TextoDeOpcion(
          'Aumentar só um pouco',
          'Um ajuste que quase não se nota na bilheteria nem no clima. '
              'Teve uma vaia na primeira noite e pouco mais.',
        ),
        'no_tocarlas': TextoDeOpcion(
          'Não mexer',
          'A torcida fica sabendo que você disse não, e o ginásio vira um '
              'problema para quem vem jogar aqui. O dinheiro fica para '
              'outro ano.',
        ),
      },
    ),
    'nutricionista': TextoDeEvento(
      titulo: 'O nutricionista quer mudar tudo',
      texto:
          'Propõe refazer a alimentação do clube de cabo a rabo: '
          'cardápio novo, cozinha própria e chega de hambúrguer no avião. '
          'Custa dinheiro e metade do elenco não gostou nada.',
      opciones: {
        'cambiarlo_todo': TextoDeOpcion(
          'Mudar tudo',
          'Duas semanas de reclamação e cara feia no refeitório. Depois '
              'disso, chega-se muito melhor no último quarto, e isso '
              'ninguém discute mais.',
        ),
        'solo_en_los_viajes': TextoDeOpcion(
          'Só nas viagens',
          'Resolve-se o pior — comer em horário maluco dentro de um avião — '
              'e ninguém reclama, porque em casa continua tudo igual.',
        ),
        'dejarlo_como_esta': TextoDeOpcion(
          'Deixar como está',
          'Ninguém reclama e a rotina fica intacta. O nutricionista guarda '
              'o relatório e não toca mais no assunto; tudo o que estava '
              'ali continua sendo verdade.',
        ),
      },
    ),
  };
}
