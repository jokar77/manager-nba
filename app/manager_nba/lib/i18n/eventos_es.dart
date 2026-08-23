part of 'textos_eventos.dart';

/// El guion en español, que es el original: los demás idiomas se
/// escribieron a partir de este.
class EventosEs extends TextosDeEventos {
  const EventosEs();

  @override
  String get jugadorGenerico => 'el jugador';

  @override
  Map<String, String> get etiquetasDeEfecto => const {
    'buen_rollo': 'Buen rollo en el vestuario',
    'piernas_cansadas': 'Piernas cansadas',
    'piernas_frescas': 'Piernas frescas',
    'grupo_frio': 'Grupo frío',
    'vestuario_tenso': 'Vestuario tenso',
    'disciplina': 'Disciplina',
    'vestuario_roto': 'Vestuario roto',
    'sin_tu_mejor_jugador': 'Sin tu mejor jugador',
    'plantilla_fresca': 'Plantilla fresca',
    'plantilla_al_limite': 'Plantilla al límite',
    'rotacion_verde': 'Rotación verde',
    'grupo_enchufado': 'Grupo enchufado',
    'banquillo_descontento': 'Banquillo descontento',
    'el_grupo_va_contigo': 'El grupo va contigo',
    'nadie_se_da_por_aludido': 'Nadie se da por aludido',
    'vestuario_dolido': 'Vestuario dolido',
    'nadie_dio_la_cara': 'Nadie dio la cara por ellos',
    'el_ruido_se_apaga': 'El ruido se apaga',
    'a_todo_gas': 'A todo gas',
    'desgaste_acumulado': 'Desgaste acumulado',
    'se_corta_la_racha': 'Se corta la racha',
    'cargas_controladas': 'Cargas controladas',
    'la_grada_empuja': 'La grada empuja',
    'una_manana_sin_entrenar': 'Una mañana sin entrenar',
    'manana_de_trabajo': 'Mañana de trabajo',
    'la_grada_fria': 'La grada, fría',
    'dia_de_rodaje': 'Día de rodaje',
    'manana_de_fotos': 'Mañana de fotos',
    'plantilla_descansada': 'Plantilla descansada',
    'un_partido_de_mas': 'Un partido de más',
    'la_ciudad_se_vuelca': 'La ciudad se vuelca',
    'el_banquillo_coge_ritmo': 'El banquillo coge ritmo',
    'semana_de_descanso': 'Semana de descanso',
    'bien_descansados': 'Bien descansados',
    'sin_trabajo_tactico': 'Sin trabajo táctico',
    'se_han_dicho_las_cosas': 'Se han dicho las cosas',
    'el_vestuario_va_por_libre': 'El vestuario va por libre',
    'la_charla_no_llego_a_pasar': 'La charla no llegó a pasar',
    'sabes_lo_que_hay': 'Sabes lo que hay',
    'rotacion_corta': 'Rotación corta',
    'titulares_fundidos': 'Titulares fundidos',
    'suplentes_en_pista': 'Suplentes en pista',
    // Segunda tanda.
    'jugador_liberado': 'Jugador liberado',
    'nadie_teme_por_su_puesto': 'Nadie teme por su puesto',
    'jugador_tocado': 'Jugador tocado',
    'se_juegan_el_puesto': 'Se juegan el puesto',
    'duda_en_el_vestuario': 'Duda en el vestuario',
    'equipo_desarmado': 'Equipo desarmado',
    'orgullo_del_grupo': 'Orgullo del grupo',
    'jugador_agradecido': 'Jugador agradecido',
    'el_resto_toma_nota': 'El resto toma nota',
    'sin_uno_de_la_rotacion': 'Sin uno de la rotación',
    'norma_clara': 'Norma clara',
    'descanso_roto': 'Descanso roto',
    'homenaje_discreto': 'Homenaje discreto',
    'rutina_intacta': 'Rutina intacta',
    'la_leyenda_dolida': 'La leyenda, dolida',
    'entrenador_con_las_riendas': 'Entrenador con las riendas',
    'pierdes_el_banquillo': 'Pierdes el banquillo',
    'equilibrio_incomodo': 'Equilibrio incómodo',
    'nadie_se_desmarca': 'Nadie se desmarca',
    'mano_firme': 'Mano firme',
    'entrenador_dolido': 'Entrenador dolido',
    'jugador_resentido': 'Jugador resentido',
    'disculpa_forzada': 'Disculpa forzada',
    'algo_de_ruido_en_la_grada': 'Algo de ruido en la grada',
    'protestas_en_el_comedor': 'Protestas en el comedor',
    'plantilla_mejor_alimentada': 'Plantilla mejor alimentada',
    'pequeno_cambio': 'Un cambio pequeño',
    'mismo_de_siempre': 'Lo mismo de siempre',
    // Compromisos de patrocinio (ver patrocinadores.dart).
    'dias_de_medios': 'Días de medios',
    'pabellon_con_otro_nombre': 'El pabellón, con otro nombre',
    'compromisos_de_marca': 'Compromisos de marca',
    'trabajo_con_la_ciudad': 'Trabajo con la ciudad',
  };

  @override
  Map<String, TextoDeEvento> get eventos => const {
    'cena_de_equipo': TextoDeEvento(
      titulo: 'Cena de equipo',
      texto:
          'Los veteranos quieren organizar una cena para toda la '
          'plantilla, cuerpo técnico incluido. Dicen que hace falta '
          'soltarse un poco.',
      opciones: {
        'noche_larga': TextoDeOpcion(
          'Que sea una noche larga',
          'El vestuario se ha soltado de verdad y se nota en la pista. '
              'Los próximos dos partidos van a costar: nadie ha dormido '
              'lo que debía.',
        ),
        'cena_corta': TextoDeOpcion(
          'Cena corta y a dormir',
          'Un par de horas, risas y a casa. No arregla el mundo, pero el '
              'grupo está algo más unido y mañana se entrena.',
        ),
        'ahora_no_toca': TextoDeOpcion(
          'Ahora no toca',
          'Se entrena y se descansa. Se llega con las piernas frescas al '
              'siguiente partido, pero nadie se ha olvidado de que dijiste '
              'que no: el grupo anda más frío de lo que estaba.',
        ),
      },
    ),
    'bronca_en_el_entrenamiento': TextoDeEvento(
      titulo: 'Se han liado en el entrenamiento',
      texto:
          'Dos jugadores han pasado de las palabras a los empujones en '
          'un cinco contra cinco. Están separados en el vestuario y la '
          'prensa ya lo sabe.',
      opciones: {
        'multar_a_los_dos': TextoDeOpcion(
          'Multar a los dos',
          'Queda claro quién manda. El vestuario está tenso unos días, '
              'pero nadie va a volver a hacerlo.',
        ),
        'que_lo_arreglen_ellos': TextoDeOpcion(
          'Que lo arreglen ellos',
          'Se dan la mano delante del grupo. Parece sincero.',
        ),
        'mirar_a_otro_lado': TextoDeOpcion(
          'Mirar a otro lado',
          'Nadie dice nada y el asunto se enquista. En la pista se ve: no '
              'se pasan el balón igual.',
        ),
      },
    ),
    'estrella_pide_descanso': TextoDeEvento(
      titulo: '{jugador} pide descanso',
      texto:
          'Lleva jugando con molestias desde noviembre. No está '
          'lesionado, pero pide sentarse unos partidos para llegar entero '
          'al final de temporada.',
      opciones: {
        'que_descanse': TextoDeOpcion(
          'Que descanse',
          'Se pierde unos partidos y se nota su ausencia, pero vuelve '
              'fresco y con ganas para el tramo que de verdad importa.',
        ),
        'te_necesito_ahora': TextoDeOpcion(
          'Te necesito ahora',
          'Lo entiende y aprieta los dientes. Rinde, pero se le ve '
              'arrastrando la pierna y el resto del grupo lo nota.',
        ),
      },
    ),
    'joven_pide_minutos': TextoDeEvento(
      titulo: '{jugador} quiere minutos',
      texto:
          '{jugador} lleva media temporada pegado al '
          'banquillo. Su agente ha llamado: o juega, o el verano que viene '
          'se busca la vida en otro sitio.',
      opciones: {
        'dale_minutos': TextoDeOpcion(
          'Dale minutos',
          'Los primeros partidos se le ven las costuras, pero se suelta '
              'rápido y el vestuario ve que aquí se premia el trabajo.',
        ),
        'que_se_lo_gane': TextoDeOpcion(
          'Que se lo gane en el entrenamiento',
          'Se lo toma mal y se le nota en la cara. El resto de jóvenes '
              'toma nota de cómo funcionan las cosas aquí.',
        ),
      },
    ),
    'prensa_dura': TextoDeEvento(
      titulo: 'La prensa os está crujiendo',
      texto:
          'Después de la última derrota, el periódico de la ciudad ha '
          'publicado que el vestuario está muerto y que aquí sobra gente. '
          'Te piden una respuesta.',
      opciones: {
        'defender_al_grupo': TextoDeOpcion(
          'Defender al grupo en público',
          'Los jugadores lo agradecen: has puesto la cara por ellos cuando '
              'nadie lo hacía. El problema es que ahora el foco está en ti, '
              'y dentro nadie se siente señalado por lo que está haciendo '
              'mal.',
        ),
        'darles_la_razon': TextoDeOpcion(
          'Darles la razón',
          'Has admitido en público que el equipo no está a la altura. Es '
              'verdad, pero dentro no ha sentado bien.',
        ),
        'no_entrar_al_trapo': TextoDeOpcion(
          'No entrar al trapo',
          'Dos frases hechas y a entrenar. Sin leña, el asunto se apaga '
              'solo en unos días. Lo que queda dentro es que no saliste a '
              'dar la cara por ellos.',
        ),
      },
    ),
    'racha_buena': TextoDeEvento(
      titulo: 'Nadie os para',
      texto:
          'El equipo va lanzado y se empieza a hablar de vosotros como '
          'candidatos. El entrenador pregunta si aprieta o si levanta el '
          'pie para no quemar a nadie.',
      opciones: {
        'apretar_mientras_dure': TextoDeOpcion(
          'Apretar mientras dure',
          'Se entrena a tope y la racha se alarga. El desgaste llegará, '
              'pero más tarde.',
        ),
        'levantar_el_pie': TextoDeOpcion(
          'Levantar el pie',
          'Cargas más suaves y minutos repartidos. La racha se corta antes '
              'de lo que se habría cortado apretando, pero el equipo llega '
              'entero.',
        ),
      },
    ),
    'aficion_llena_el_pabellon': TextoDeEvento(
      titulo: 'El pabellón se llena',
      texto:
          'Las entradas se están agotando y la afición pide un gesto: '
          'un entrenamiento a puerta abierta, firmas, fotos. Ocupa una '
          'mañana entera de trabajo.',
      opciones: {
        'abrir_las_puertas': TextoDeOpcion(
          'Abrir las puertas',
          'El pabellón va a empujar de verdad los próximos partidos, y la '
              'tienda del club no ha parado en toda la mañana. La sesión de '
              'trabajo perdida se paga en el siguiente.',
        ),
        'a_entrenar': TextoDeOpcion(
          'A entrenar, que es lo que toca',
          'Se trabaja la mañana entera y se nota en el siguiente partido. '
              'La afición lo entiende a medias: alguna pancarta ha salido '
              'en la grada.',
        ),
      },
    ),
    'acto_publicitario': TextoDeEvento(
      titulo: 'Un patrocinador quiere a la plantilla',
      texto:
          'Una marca de la ciudad pone dinero encima de la mesa por un '
          'día entero de rodaje: toda la plantilla, sesión de fotos y '
          'anuncio. Es un día de trabajo perdido y los jugadores ya han '
          'puesto cara.',
      opciones: {
        'firmar_el_acuerdo_entero': TextoDeOpcion(
          'Firmar el acuerdo entero',
          'Rodaje hasta las tantas y jugadores de mal humor, pero el club '
              'se lleva un buen pellizco que da aire con el tope salarial.',
        ),
        'negociar_algo_mas_corto': TextoDeOpcion(
          'Negociar algo más corto',
          'Media mañana de fotos y a entrenar. Se cobra menos, pero nadie '
              'ha perdido el día entero.',
        ),
        'decirles_que_no': TextoDeOpcion(
          'Decirles que no',
          'La plantilla se entera de que les has ahorrado el marrón y '
              'llega al siguiente partido con las piernas nuevas. El '
              'dinero, para otro año.',
        ),
      },
    ),
    'partido_benefico': TextoDeEvento(
      titulo: 'Partido benéfico entre semana',
      texto:
          'El ayuntamiento organiza un amistoso benéfico y quiere al '
          'equipo. Cae justo entre dos partidos de liga.',
      opciones: {
        'ir_con_los_titulares': TextoDeOpcion(
          'Ir con los titulares',
          'Pabellón lleno y la ciudad volcada con el equipo. Es un partido '
              'más en unas piernas que ya venían justas.',
        ),
        'mandar_a_los_suplentes': TextoDeOpcion(
          'Mandar a los suplentes',
          'Los de abajo cogen minutos de verdad y se les ve sueltos. La '
              'recaudación es menor, pero nadie importante se ha cansado.',
        ),
        'no_ir': TextoDeOpcion(
          'No ir',
          'Semana limpia de trabajo y descanso. El acto se celebra igual '
              'sin vosotros, la ciudad lo lee como un feo y el club acaba '
              'compensándolo de su bolsillo.',
        ),
      },
    ),
    'viaje_infernal': TextoDeEvento(
      titulo: 'Cinco partidos fuera en ocho días',
      texto:
          'El calendario ha dejado un viaje muy duro. El preparador '
          'físico propone viajar un día antes a cada ciudad, que sale caro '
          'pero ahorra horas de avión.',
      opciones: {
        'viajar_con_margen': TextoDeOpcion(
          'Viajar con margen',
          'El equipo llega descansado a cada partido. Lo que se pierde son '
              'sesiones de vídeo y entrenamiento: se viaja mucho y se '
              'trabaja poco.',
        ),
        'como_siempre': TextoDeOpcion(
          'Como siempre',
          'Aviones de madrugada y hoteles a las tres de la mañana. Se va a '
              'notar.',
        ),
      },
    ),
    'veterano_de_vestuario': TextoDeEvento(
      titulo: '{jugador} se ofrece a hablar con el grupo',
      texto:
          '{jugador}, el más veterano de la plantilla, te pide cinco '
          'minutos con el equipo, sin cuerpo técnico delante. Dice que hay '
          'cosas que se '
          'hablan mejor entre jugadores.',
      opciones: {
        'dejales_solos': TextoDeOpcion(
          'Déjales solos',
          'Nadie ha contado qué se dijo ahí dentro, pero el equipo ha '
              'salido distinto al siguiente partido. Lo que se decidiera, '
              'lo decidieron ellos: tú te has quedado fuera de esa '
              'conversación.',
        ),
        'prefiero_estar_delante': TextoDeOpcion(
          'Prefiero estar delante',
          'La charla se queda a medias —con el jefe delante nadie dice lo '
              'que piensa— pero sales sabiendo exactamente quién está con '
              'quién en ese vestuario.',
        ),
      },
    ),
    'recta_final': TextoDeEvento(
      titulo: 'Se juegan los playoffs en tres semanas',
      texto:
          'Quedan pocos partidos y todo está apretado. El cuerpo '
          'técnico pregunta si se acortan las rotaciones para tirar de los '
          'mejores.',
      opciones: {
        'tirar_de_los_titulares': TextoDeOpcion(
          'Tirar de los titulares',
          'Los mejores van a jugarlo casi todo. Rinde ahora y se paga en '
              'abril.',
        ),
        'repartir_minutos': TextoDeOpcion(
          'Repartir minutos',
          'Nadie llega fundido a los playoffs, pero en la recta final se '
              'pierde algún partido por el camino — y el puesto en la '
              'clasificación se decide justo ahora.',
        ),
      },
    ),

    // --- Segunda tanda -------------------------------------------
    'rumor_de_traspaso': TextoDeEvento(
      titulo: '{jugador} ha leído su nombre en los rumores',
      texto:
          'Un periodista ha publicado que estás escuchando ofertas por '
          '{jugador}. Te lo pregunta a la cara, delante de '
          'medio vestuario.',
      opciones: {
        'prometerle_que_se_queda': TextoDeOpcion(
          'Prometerle que no se mueve',
          'Se le quita un peso de encima y se le nota desde el primer '
              'balón. Lo que también se ha oído es que aquí el sitio no se '
              'pierde jugando mal, y eso lo ha escuchado el vestuario '
              'entero.',
        ),
        'decirle_la_verdad': TextoDeOpcion(
          'Decirle la verdad',
          'Le has dicho que sí, que escuchas. Se queda tocado unas '
              'semanas, pero a partir de ahora nadie da por hecho que su '
              'sitio es suyo.',
        ),
        'no_contestar': TextoDeOpcion(
          'No contestar',
          'Una respuesta que no dice nada. Él sale igual que entró y el '
              'resto se queda con la duda: si no lo has negado, por algo '
              'será.',
        ),
      },
    ),
    'tanking_de_la_directiva': TextoDeEvento(
      titulo: 'La directiva mira ya al draft',
      texto:
          'Las cuentas no dan para playoffs y arriba prefieren caer bajo '
          'en la clasificación para elegir mejor en el draft. Nadie lo va '
          'a decir en voz alta, pero te lo han hecho llegar.',
      opciones: {
        'mirar_al_draft': TextoDeOpcion(
          'Pensar en el año que viene',
          'Minutos para los de abajo y los mejores con molestias que nadie '
              'termina de explicar. Lo que queda de temporada va a ser '
              'duro de ver, pero arriba están contentos y se nota en el '
              'presupuesto.',
        ),
        'competir_hasta_el_final': TextoDeOpcion(
          'Competir hasta el último partido',
          'Se sale a ganar aunque no sirva para nada. El vestuario lo '
              'entiende perfectamente y responde: nadie quiere ser el '
              'equipo que se dejó ir.',
        ),
      },
    ),
    'jugador_llega_tarde': TextoDeEvento(
      titulo: '{jugador} llega tarde otra vez',
      texto:
          'Tercera vez este mes que aparece con el entrenamiento '
          'empezado. Las dos anteriores lo dejaste pasar. Esta lo ha visto '
          'todo el mundo.',
      opciones: {
        'multarle': TextoDeOpcion(
          'Multarle',
          'La multa se comenta en el vestuario y no sienta bien, pero a la '
              'semana siguiente no llega tarde nadie.',
        ),
        'hablar_en_privado': TextoDeOpcion(
          'Hablar con él a solas',
          'Sale del despacho tocado y agradecido a la vez, y responde. El '
              'problema es que los demás han visto que llegar tarde tres '
              'veces no cuesta nada.',
        ),
        'sentarle_un_partido': TextoDeOpcion(
          'Sentarle un partido',
          'Se pierde el siguiente y se nota su hueco en la rotación. A '
              'cambio, la norma ha quedado escrita sin necesidad de '
              'escribirla.',
        ),
      },
    ),
    'camiseta_de_una_leyenda': TextoDeEvento(
      titulo: 'Retirar la camiseta de una leyenda',
      texto:
          'El club quiere subir su camiseta al techo del pabellón esta '
          'temporada. La fecha la eliges tú, y el acto se come parte del '
          'día de partido.',
      opciones: {
        'ceremonia_a_lo_grande': TextoDeOpcion(
          'Hacerlo a lo grande, en el descanso',
          'Media hora de ceremonia, el pabellón en pie y la ciudad hablando '
              'de ello una semana. Los jugadores salieron fríos a la '
              'segunda parte y ese partido se pagó.',
        ),
        'algo_breve': TextoDeOpcion(
          'Un acto corto antes del partido',
          'Diez minutos, la camiseta arriba y a jugar. Ni molesta ni llena '
              'el pabellón como lo habría llenado el otro.',
        ),
        'dejarlo_para_el_verano': TextoDeOpcion(
          'Dejarlo para el verano',
          'Semana de trabajo sin interrupciones. La leyenda no ha dicho '
              'nada en público, pero no ha cogido el teléfono desde '
              'entonces.',
        ),
      },
    ),
    'entrenador_pide_mando': TextoDeEvento(
      titulo: 'El entrenador quiere mando total',
      texto:
          'Pide decidir él la rotación y los minutos, sin que nadie de '
          'arriba le diga a quién sienta. Dice que si responde de los '
          'resultados, quiere responder de las decisiones.',
      opciones: {
        'darle_mando': TextoDeOpcion(
          'Dárselo',
          'Se le ve otro: firma un par de partidos muy buenos en cuanto '
              'puede hacer las cosas a su manera. Lo que has perdido es el '
              'banquillo — a partir de ahora te enteras de las cosas '
              'cuando ya están decididas.',
        ),
        'mando_compartido': TextoDeOpcion(
          'Decidirlo entre los dos',
          'Las primeras semanas son incómodas y hay dos reuniones donde '
              'antes había una. Pero nadie puede escurrir el bulto luego, '
              'porque todo lo habéis firmado los dos.',
        ),
        'decidir_tu': TextoDeOpcion(
          'Las decisiones las tomas tú',
          'Queda claro quién manda y el equipo lo agradece unos partidos. '
              'El entrenador ha dicho que sin problema, pero ya no propone '
              'nada.',
        ),
      },
    ),
    'metida_de_pata_en_redes': TextoDeEvento(
      titulo: '{jugador} la ha liado en redes',
      texto:
          'Ha publicado de madrugada que los árbitros van a por él. Lo '
          'borró en veinte minutos; para entonces ya lo tenía todo el '
          'mundo guardado.',
      opciones: {
        'multarle_y_zanjarlo': TextoDeOpcion(
          'Multarle y zanjarlo',
          'Asunto cerrado en un día y el resto entiende dónde está la '
              'raya. Él lleva la multa regular y se le nota unas semanas.',
        ),
        'defenderle_en_publico': TextoDeOpcion(
          'Salir a defenderle',
          'Dijiste en rueda de prensa que no le falta razón. El vestuario '
              'no lo va a olvidar en todo el año; la liga tampoco, y la '
              'multa se la come el club.',
        ),
        'obligarle_a_disculparse': TextoDeOpcion(
          'Que se disculpe en público',
          'Lee un comunicado que no ha escrito él y se le ve en la cara. '
              'Incómodo para todos, pero en tres días ya no habla nadie '
              'del asunto.',
        ),
      },
    ),
    'precio_de_las_entradas': TextoDeEvento(
      titulo: 'Quieren subir el precio de las entradas',
      texto:
          'El equipo va bien, el pabellón se llena y la propiedad ve el '
          'momento de subir las entradas para lo que queda de año.',
      opciones: {
        'subirlas': TextoDeOpcion(
          'Subirlas',
          'Entra dinero de verdad y el tope salarial respira. La grada de '
              'siempre no lo ha entendido, y el pabellón ya no suena como '
              'sonaba.',
        ),
        'subirlas_un_poco': TextoDeOpcion(
          'Subirlas solo un poco',
          'Un ajuste que casi no se nota en la taquilla ni en el '
              'ambiente. Hubo algún silbido el primer día y poco más.',
        ),
        'no_tocarlas': TextoDeOpcion(
          'No tocarlas',
          'La afición se entera de que te has negado y el pabellón se '
              'convierte en un problema para el que venga. El dinero, para '
              'otro año.',
        ),
      },
    ),
    'nutricionista': TextoDeEvento(
      titulo: 'El nutricionista quiere cambiarlo todo',
      texto:
          'Propone rehacer la comida del club de arriba abajo: menús '
          'nuevos, cocina propia y se acaban las hamburguesas del avión. '
          'Cuesta dinero y a media plantilla no le hace ninguna gracia.',
      opciones: {
        'cambiarlo_todo': TextoDeOpcion(
          'Cambiarlo todo',
          'Dos semanas de protestas y caras largas en el comedor. A partir '
              'de ahí se llega mejor al último cuarto, y eso ya no lo '
              'discute nadie.',
        ),
        'solo_en_los_viajes': TextoDeOpcion(
          'Solo en los viajes',
          'Se arregla lo que peor estaba —comer a deshoras en un avión— y '
              'nadie protesta porque en casa siguen comiendo igual.',
        ),
        'dejarlo_como_esta': TextoDeOpcion(
          'Dejarlo como está',
          'Nadie se queja y la rutina sigue intacta. El nutricionista '
              'guarda el informe y no vuelve a sacarlo; lo que decía en él '
              'sigue siendo verdad.',
        ),
      },
    ),
  };
}
