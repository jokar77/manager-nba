part of 'textos_eventos.dart';

/// El guion en chino simplificado.
///
/// Frases cortas y sin florituras: el chino ocupa mucho menos espacio que
/// el español, así que una traducción literal del original deja el diálogo
/// medio vacío. Se ha escrito directamente en el registro que usaría un
/// entrenador hablando con su plantilla.
class EventosZh extends TextosDeEventos {
  const EventosZh();

  @override
  Map<String, String> get etiquetasDeEfecto => const {
    'buen_rollo': '更衣室气氛融洽',
    'piernas_cansadas': '双腿疲惫',
    'piernas_frescas': '双腿轻快',
    'grupo_frio': '球队气氛冷淡',
    'vestuario_tenso': '更衣室紧张',
    'disciplina': '纪律严明',
    'vestuario_roto': '更衣室分裂',
    'sin_tu_mejor_jugador': '缺少头号球星',
    'plantilla_fresca': '阵容充分休息',
    'plantilla_al_limite': '阵容濒临极限',
    'rotacion_verde': '轮换太年轻',
    'grupo_enchufado': '全队干劲十足',
    'banquillo_descontento': '替补席不满',
    'el_grupo_va_contigo': '球队站在你这边',
    'nadie_se_da_por_aludido': '没人觉得是在说自己',
    'vestuario_dolido': '更衣室受伤',
    'nadie_dio_la_cara': '没人替他们出头',
    'el_ruido_se_apaga': '风波平息',
    'a_todo_gas': '全力冲刺',
    'desgaste_acumulado': '消耗累积',
    'se_corta_la_racha': '连胜中断',
    'cargas_controladas': '负荷可控',
    'la_grada_empuja': '主场助威',
    'una_manana_sin_entrenar': '少了一个上午的训练',
    'manana_de_trabajo': '一上午的扎实训练',
    'la_grada_fria': '看台冷清',
    'dia_de_rodaje': '整天拍摄',
    'manana_de_fotos': '一上午拍照',
    'plantilla_descansada': '阵容得到休息',
    'un_partido_de_mas': '多打了一场',
    'la_ciudad_se_vuelca': '全城力挺球队',
    'el_banquillo_coge_ritmo': '替补找到节奏',
    'semana_de_descanso': '一周休整',
    'bien_descansados': '休息充分',
    'sin_trabajo_tactico': '没有战术训练',
    'se_han_dicho_las_cosas': '话都说开了',
    'el_vestuario_va_por_libre': '更衣室各行其是',
    'la_charla_no_llego_a_pasar': '那次谈话没谈成',
    'sabes_lo_que_hay': '你摸清了底细',
    'rotacion_corta': '轮换收紧',
    'titulares_fundidos': '首发被榨干',
    'suplentes_en_pista': '替补上场',
    // Segunda tanda.
    'jugador_liberado': '球员卸下包袱',
    'nadie_teme_por_su_puesto': '没人担心自己的位置',
    'jugador_tocado': '球员受到打击',
    'se_juegan_el_puesto': '人人都在争位置',
    'duda_en_el_vestuario': '更衣室起了疑心',
    'equipo_desarmado': '阵容被拆散',
    'orgullo_del_grupo': '球队的骨气',
    'jugador_agradecido': '球员心存感激',
    'el_resto_toma_nota': '其他人都记下了',
    'sin_uno_de_la_rotacion': '轮换少了一人',
    'norma_clara': '规矩立住了',
    'descanso_roto': '中场被打断',
    'homenaje_discreto': '低调的致敬',
    'rutina_intacta': '作息没被打乱',
    'la_leyenda_dolida': '功勋球员寒了心',
    'entrenador_con_las_riendas': '教练大权在握',
    'pierdes_el_banquillo': '你失去了替补席',
    'equilibrio_incomodo': '别扭的平衡',
    'nadie_se_desmarca': '谁也甩不掉责任',
    'mano_firme': '强硬手腕',
    'entrenador_dolido': '教练寒了心',
    'jugador_resentido': '球员心怀不满',
    'disculpa_forzada': '被迫的道歉',
    'algo_de_ruido_en_la_grada': '看台有些怨言',
    'protestas_en_el_comedor': '餐厅里怨声载道',
    'plantilla_mejor_alimentada': '全队吃得更科学',
    'pequeno_cambio': '一点小改动',
    'mismo_de_siempre': '一切照旧',
    // Compromisos de patrocinio (ver patrocinadores.dart).
    'dias_de_medios': '媒体日',
    'pabellon_con_otro_nombre': '球馆改了名字',
    'compromisos_de_marca': '品牌活动缠身',
    'trabajo_con_la_ciudad': '与城市共建',
  };

  @override
  Map<String, TextoDeEvento> get eventos => const {
    'cena_de_equipo': TextoDeEvento(
      titulo: '球队聚餐',
      texto: '老将们想给全队办一次聚餐，教练组也算上。他们说，大家需要放松一下。',
      opciones: {
        'noche_larga': TextoDeOpcion(
          '那就玩个通宵',
          '更衣室是真的放开了，场上看得出来。但接下来两场会很吃力：没人睡够觉。',
        ),
        'cena_corta': TextoDeOpcion(
          '吃完早点回去休息',
          '两个小时，笑一笑就散了。解决不了所有问题，但球队更紧密了一些，明天照常训练。',
        ),
        'ahora_no_toca': TextoDeOpcion(
          '现在不是时候',
          '照常训练、照常休息。下一场大家双腿轻快，但没人忘记你拒绝了：球队比之前冷了。',
        ),
      },
    ),
    'bronca_en_el_entrenamiento': TextoDeEvento(
      titulo: '训练中打起来了',
      texto: '两名球员在五对五中从口角发展到了推搡。人已经在更衣室里被拉开，媒体也知道了。',
      opciones: {
        'multar_a_los_dos': TextoDeOpcion(
          '两个都罚',
          '谁说了算，一清二楚。更衣室紧张几天，但没人敢再来一次。',
        ),
        'que_lo_arreglen_ellos': TextoDeOpcion(
          '让他们自己解决',
          '两人当着全队的面握了手，看起来是真心的。',
        ),
        'mirar_a_otro_lado': TextoDeOpcion(
          '装作没看见',
          '没人吭声，事情就烂在那儿。场上看得出来：球不像以前那样传了。',
        ),
      },
    ),
    'estrella_pide_descanso': TextoDeEvento(
      titulo: '头号球星想休息',
      texto: '他从十一月起就带着伤病在打。人没伤，但想歇几场，好在赛季末保持完整状态。',
      opciones: {
        'que_descanse': TextoDeOpcion(
          '让他休息',
          '少了他要输几场，缺阵很明显，但他会在真正要紧的阶段带着新鲜的双腿回来。',
        ),
        'te_necesito_ahora': TextoDeOpcion(
          '现在需要你',
          '他理解，咬牙上了。数据还在，但看得出来腿在拖，队里其他人也都看在眼里。',
        ),
      },
    ),
    'joven_pide_minutos': TextoDeEvento(
      titulo: '年轻球员想要出场时间',
      texto: '你的一个小将半个赛季都钉在板凳上。他的经纪人来电话了：要么给他上，要么明夏另谋出路。',
      opciones: {
        'dale_minutos': TextoDeOpcion(
          '给他上场时间',
          '头几场毛病都露出来了，但他很快就放开了，更衣室也看到在这里努力有回报。',
        ),
        'que_se_lo_gane': TextoDeOpcion(
          '先在训练里挣出来',
          '他很不服气，脸上都写着。其他年轻人也记住了这里的规矩。',
        ),
      },
    ),
    'prensa_dura': TextoDeEvento(
      titulo: '媒体正在狠批你们',
      texto: '上一场输球之后，本地报纸发文说更衣室已经死了，队里有人是多余的。他们要你一个回应。',
      opciones: {
        'defender_al_grupo': TextoDeOpcion(
          '公开维护球队',
          '球员们领情：没人替他们说话的时候你顶了上去。问题是现在焦点都在你身上，队内没人觉得自己被点名了。',
        ),
        'darles_la_razon': TextoDeOpcion(
          '承认他们说得对',
          '你公开承认球队不够格。是实话，但队里听着很不舒服。',
        ),
        'no_entrar_al_trapo': TextoDeOpcion(
          '不接这个话茬',
          '两句场面话，回去训练。没人添柴，几天就自己灭了。留在队内的是：你没站出来护着他们。',
        ),
      },
    ),
    'racha_buena': TextoDeEvento(
      titulo: '没人拦得住你们',
      texto: '球队势头正猛，外界开始把你们当夺冠热门。教练问是继续加码，还是松一松免得有人累垮。',
      opciones: {
        'apretar_mientras_dure': TextoDeOpcion(
          '趁热打铁',
          '训练拉满，连胜还能延续。消耗迟早会来，但会晚一些。',
        ),
        'levantar_el_pie': TextoDeOpcion(
          '松一松',
          '负荷放轻，时间分散。连胜比硬撑着断得更早，但全队能囫囵着走出来。',
        ),
      },
    ),
    'aficion_llena_el_pabellon': TextoDeEvento(
      titulo: '球馆快坐满了',
      texto: '门票就要卖光，球迷希望有点表示：开放训练、签名、合影。这要占掉一整个上午的训练。',
      opciones: {
        'abrir_las_puertas': TextoDeOpcion(
          '打开大门',
          '接下来几场主场会真的推着你们走，球队商店一上午没停过。少的那次训练，下一场就得还。',
        ),
        'a_entrenar': TextoDeOpcion(
          '训练要紧',
          '踏踏实实练了一上午，下一场看得出来。球迷只理解了一半：看台上挂出了几条横幅。',
        ),
      },
    ),
    'acto_publicitario': TextoDeEvento(
      titulo: '赞助商想要全队出镜',
      texto: '本地一个品牌拿钱来谈整天的拍摄：全队到场，拍照加广告。这要搭进一整天，球员们已经拉下脸了。',
      opciones: {
        'firmar_el_acuerdo_entero': TextoDeOpcion(
          '整份合同都签',
          '拍到很晚，球员一肚子怨气，但俱乐部拿到一笔不小的钱，工资帽上能松口气。',
        ),
        'negociar_algo_mas_corto': TextoDeOpcion(
          '谈个短一点的',
          '拍半个上午照片就回去训练。钱少一些，但没人整天都搭进去。',
        ),
        'decirles_que_no': TextoDeOpcion(
          '直接回绝',
          '球队知道你替他们挡掉了这桩麻烦，下一场带着新鲜的双腿上场。钱，留到别的年份再说。',
        ),
      },
    ),
    'partido_benefico': TextoDeEvento(
      titulo: '周中的慈善赛',
      texto: '市政府办一场慈善友谊赛，想请球队出场。时间正好卡在两场联赛之间。',
      opciones: {
        'ir_con_los_titulares': TextoDeOpcion(
          '带首发去',
          '球馆爆满，全城都站在球队这边。但这是多打的一场，而大家的腿本来就紧巴巴的。',
        ),
        'mandar_a_los_suplentes': TextoDeOpcion(
          '让替补去',
          '板凳末端的球员拿到了真正的出场时间，打得很放松。收入少了些，但重要的人一个都没累到。',
        ),
        'no_ir': TextoDeOpcion(
          '不去',
          '一周干干净净地训练和休息。活动照办不误，城里把这当成怠慢，俱乐部最后自掏腰包补上。',
        ),
      },
    ),
    'viaje_infernal': TextoDeEvento(
      titulo: '八天五个客场',
      texto: '赛程留下了一趟极其难熬的客场之旅。体能教练建议每座城市都提前一天飞过去：花钱，但能省下不少飞行时间。',
      opciones: {
        'viajar_con_margen': TextoDeOpcion(
          '提前出发',
          '每场比赛球队都是养足了精神到的。代价是录像课和训练：路上时间多，练得少。',
        ),
        'como_siempre': TextoDeOpcion('照老样子', '半夜的航班，凌晨三点进酒店。这个会显出来的。'),
      },
    ),
    'veterano_de_vestuario': TextoDeEvento(
      titulo: '一名老将想跟全队谈谈',
      texto: '队里资历最老的球员想跟球队单独待五分钟，教练组不在场。他说有些话球员之间讲更合适。',
      opciones: {
        'dejales_solos': TextoDeOpcion(
          '让他们单独谈',
          '没人说过里面讲了什么，但下一场球队的样子不一样了。不管定下了什么，都是他们定的：那场对话里没有你。',
        ),
        'prefiero_estar_delante': TextoDeOpcion(
          '我要在场',
          '话只说了一半——老板在场，没人讲真心话——但你走出来的时候，清清楚楚知道那间更衣室里谁跟谁站在一起。',
        ),
      },
    ),
    'recta_final': TextoDeEvento(
      titulo: '三周后就是季后赛',
      texto: '只剩几场比赛，形势胶着。教练组问要不要收紧轮换，多用主力。',
      opciones: {
        'tirar_de_los_titulares': TextoDeOpcion(
          '压主力',
          '最好的几个人几乎要打满。现在见效，四月还账。',
        ),
        'repartir_minutos': TextoDeOpcion(
          '分摊时间',
          '没人会累垮着进季后赛，但冲刺阶段难免丢掉一两场——而排名恰恰就在这时候定下来。',
        ),
      },
    ),

    // --- Segunda tanda -------------------------------------------
    'rumor_de_traspaso': TextoDeEvento(
      titulo: '他在流言里看到了自己的名字',
      texto: '有记者写道，你正在听关于某位首发的报价。他当着半个更衣室的面，直接问到你脸上。',
      opciones: {
        'prometerle_que_se_queda': TextoDeOpcion(
          '答应他不会走',
          '他心里的石头落了地，第一个回合就看得出来。但所有人也听明白了一件事：在这里，打得差是丢不了位置的。',
        ),
        'decirle_la_verdad': TextoDeOpcion(
          '跟他说实话',
          '你承认了，你确实在听。他消沉了几周，但从今往后，那间更衣室里没人再把位置当成自己的。',
        ),
        'no_contestar': TextoDeOpcion(
          '不作回答',
          '一句等于没说的话。他怎么进来就怎么出去，其他人心里留了疑影：你没否认，那就是有事。',
        ),
      },
    ),
    'tanking_de_la_directiva': TextoDeEvento(
      titulo: '高层已经在看选秀了',
      texto: '账怎么算都进不了季后赛，上面宁可排名靠后、顺位靠前。没人会明说，但话已经递到你这儿了。',
      opciones: {
        'mirar_al_draft': TextoDeOpcion(
          '为明年打算',
          '板凳末端拿到时间，主力则接连出现没人说得清的"小伤病"。剩下的赛季会很难看，但上面很满意，预算上也看得出来。',
        ),
        'competir_hasta_el_final': TextoDeOpcion(
          '打到最后一场',
          '哪怕毫无意义也要出去争胜。更衣室完全明白这意味着什么，也回应了你：没人愿意当那支放弃的球队。',
        ),
      },
    ),
    'jugador_llega_tarde': TextoDeEvento(
      titulo: '又有人迟到了',
      texto: '这个月第三次了，他到的时候训练早就开始。前两次你都放过去了。这一次，所有人都看见了。',
      opciones: {
        'multarle': TextoDeOpcion('罚款', '罚单在更衣室里被议论，大家心里都不痛快，但接下来一周没人再迟到。'),
        'hablar_en_privado': TextoDeOpcion(
          '单独找他谈',
          '他从办公室出来，又难受又感激，之后表现也确实拿了出来。问题是其他人刚刚看清楚：迟到三次一点代价都没有。',
        ),
        'sentarle_un_partido': TextoDeOpcion(
          '让他坐一场',
          '他缺席下一场，轮换的缺口看得见。但换来的是：规矩不用写出来，也已经立住了。',
        ),
      },
    ),
    'camiseta_de_una_leyenda': TextoDeEvento(
      titulo: '为功勋球员退役球衣',
      texto: '俱乐部想在本赛季把他的球衣升上球馆顶棚。日子由你定，而典礼会占掉比赛日的一部分。',
      opciones: {
        'ceremonia_a_lo_grande': TextoDeOpcion(
          '中场休息，办得隆重些',
          '半个小时的典礼，全场起立，整座城市议论了一个星期。球员下半场出来的时候手是凉的，那场球付了代价。',
        ),
        'algo_breve': TextoDeOpcion(
          '赛前简短致敬',
          '十分钟，球衣升上去，开球。谁也不耽误，但也没有像另一种办法那样把球馆填满。',
        ),
        'dejarlo_para_el_verano': TextoDeOpcion(
          '留到夏天再办',
          '一周训练干干净净，没有打扰。他没有公开说什么，但从那之后再没接过电话。',
        ),
      },
    ),
    'entrenador_pide_mando': TextoDeEvento(
      titulo: '教练想要完全的话语权',
      texto: '他要求由自己决定轮换和出场时间，不许上面的人指定谁该坐板凳。他说既然成绩要他背，决定也该他做。',
      opciones: {
        'darle_mando': TextoDeOpcion(
          '给他',
          '他像换了个人：能按自己的想法来之后，立刻打出两场很漂亮的比赛。你失去的是替补席——从现在起，事情都是定下来之后你才知道。',
        ),
        'mando_compartido': TextoDeOpcion(
          '两个人一起决定',
          '头几周很别扭，本来一个会现在要开两个。但往后谁也甩不掉责任，因为每一条都是你们俩共同签下的。',
        ),
        'decidir_tu': TextoDeOpcion(
          '决定权在你',
          '谁说了算很清楚，球队有几场也确实买账。教练说没问题——但从此再也不提任何建议。',
        ),
      },
    ),
    'metida_de_pata_en_redes': TextoDeEvento(
      titulo: '有球员在社交媒体上捅了篓子',
      texto: '他凌晨三点发文说裁判在针对他。二十分钟后删了；那时候截图早就传遍了。',
      opciones: {
        'multarle_y_zanjarlo': TextoDeOpcion(
          '罚款，就此翻篇',
          '一天之内了结，其他人也知道了界线在哪。他这口气咽得不顺，几周里都看得出来。',
        ),
        'defenderle_en_publico': TextoDeOpcion(
          '公开替他说话',
          '你在发布会上说他讲的不是全无道理。更衣室一整年都会记着这件事；联盟也记着，罚单由俱乐部来扛。',
        ),
        'obligarle_a_disculparse': TextoDeOpcion(
          '让他公开道歉',
          '他念了一份不是自己写的声明，脸上什么都写着。所有人都尴尬，但三天之后就没人再提了。',
        ),
      },
    ),
    'precio_de_las_entradas': TextoDeEvento(
      titulo: '上面想涨票价',
      texto: '球队战绩好，球馆场场爆满，老板觉得是时候把剩下这半年的票价提上去了。',
      opciones: {
        'subirlas': TextoDeOpcion(
          '涨',
          '实打实的一笔钱进账，工资帽松了口气。但常来的那批球迷不理解，球馆的声音也不像从前那样了。',
        ),
        'subirlas_un_poco': TextoDeOpcion(
          '只涨一点',
          '票房和气氛都几乎察觉不到的小幅调整。第一晚有几声嘘，也就这样了。',
        ),
        'no_tocarlas': TextoDeOpcion('不动', '球迷知道了你拒绝，主场变成了所有客队的噩梦。钱，留到别的年份再说。'),
      },
    ),
    'nutricionista': TextoDeEvento(
      titulo: '营养师想全部推倒重来',
      texto: '他提议把俱乐部的伙食从头改一遍：新菜单、自建厨房，飞机上的汉堡到此为止。这要花钱，而且半支球队一点都不乐意。',
      opciones: {
        'cambiarlo_todo': TextoDeOpcion(
          '全部改掉',
          '餐厅里怨了两周，人人拉着脸。但从那以后，球队进入第四节的状态明显不一样了，这一点再没人反驳。',
        ),
        'solo_en_los_viajes': TextoDeOpcion(
          '只改客场',
          '把最糟的部分解决掉——在飞机上乱点吃饭——而且没人抱怨，因为在主场吃的还是老一套。',
        ),
        'dejarlo_como_esta': TextoDeOpcion(
          '维持原样',
          '没人抱怨，作息一点没变。营养师把报告收了起来，再没提过；只是里面写的每一条，依然是对的。',
        ),
      },
    ),
  };
}
