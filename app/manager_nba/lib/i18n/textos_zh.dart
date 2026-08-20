part of 'textos.dart';

/// 简体中文 (chino simplificado).
///
/// Se usan los términos que emplea la prensa china de la NBA: 常规赛
/// (temporada regular), 季后赛 (playoffs), 自由球员 (agente libre),
/// 工资帽 (tope salarial), 主教练 (entrenador principal).
///
/// AVISO DE FUENTE: el juego se compila con `--no-web-resources-cdn` para
/// poder jugarse sin conexión, así que CanvasKit no puede descargarse las
/// fuentes CJK de Google al vuelo. Si estos caracteres salen como
/// cuadraditos en la web, hay que empaquetar una fuente con glifos chinos
/// (ver la nota en docs/plan.md). En Android e iOS los coge del sistema.
class TextosZh extends Textos {
  const TextosZh();

  @override
  String get aceptar => '确定';
  @override
  String get cancelar => '取消';
  @override
  String get cerrar => '关闭';
  @override
  String get guardar => '保存';
  @override
  String get continuar => '继续';
  @override
  String get si => '是';
  @override
  String get no => '否';
  @override
  String get cargando => '加载中…';

  @override
  String get nuevaPartida => '新游戏';
  @override
  String get ajustes => '设置';
  @override
  String get elegirEquipo => '选择你的球队';
  @override
  String get sobrescribir => '覆盖';
  @override
  String get ranuraOcupada => '该存档位已有游戏进度';
  @override
  String get avisoSobrescribir => '如果继续，此处保存的进度将被删除。';

  @override
  String get modoOscuro => '深色模式';
  @override
  String get modoOscuroDetalle => '用灰色和黑色代替亮白色';
  @override
  String get idioma => '语言';
  @override
  String get idiomaDetalle => '整个游戏的语言';

  @override
  String get calendario => '赛程';
  @override
  String get calendarioDetalle => '查看赛季并模拟比赛';
  @override
  String get tuEquipo => '你的球队';
  @override
  String get tuEquipoDetalle => '阵容与首发';
  @override
  String get entrenador => '主教练';
  @override
  String get banquilloVacante => '你的教练席空缺';
  @override
  String get clasificacion => '排名';
  @override
  String get clasificacionDetalle => '球队与数据领跑者';
  @override
  String get mercado => '市场';
  @override
  String get traspasos => '交易';
  @override
  String get traspasosDetalle => '与联盟其他球队谈交易';
  @override
  String get ofertasRecibidas => '收到的报价';
  @override
  String get agenciaLibre => '自由球员市场';
  @override
  String get agenciaLibreDetalle => '无球队球员与薪资空间';
  @override
  String get competicion => '赛事';
  @override
  String get nbaCup => 'NBA 杯';
  @override
  String get allStar => '全明星';
  @override
  String get allStarDetalle => '投票、全明星赛与最有价值球员';
  @override
  String get resumenTemporada => '赛季总结';
  @override
  String get resumenTemporadaDetalle => '战绩、全部比赛与场均数据';
  @override
  String get playoffs => '季后赛';
  @override
  String get premios => '奖项';
  @override
  String get legado => '传承';

  @override
  String get record => '战绩';
  @override
  String get masaSalarial => '薪资总额';
  @override
  String get temporada => '赛季';

  @override
  String get sinEntrenador => '没有主教练';
  @override
  String get sinEntrenadorDetalle => '你的球队没有主教练。请从下面的名单中签一位。';
  @override
  String get despedir => '解雇';
  @override
  String get contratar => '签约';
  @override
  String get negociar => '谈判';
  @override
  String get ofrecer => '报价';
  @override
  String get sueldo => '年薪';
  @override
  String get duracion => '合同年限';
  @override
  String get ataque => '进攻';
  @override
  String get defensa => '防守';
  @override
  String get desarrollo => '培养';
  @override
  String get equilibrado => '均衡型';
  @override
  String get especialistaAtaque => '进攻专家';
  @override
  String get especialistaDefensa => '防守专家';
  @override
  String get formadorDeJovenes => '青年培养型';
  @override
  String get loQuePuedesOfrecer => '你能提供的上限';
  @override
  String get topeDeLaFranquicia => '球队工资帽';
  @override
  String get finiquitos => '已解雇教练的买断费';
  @override
  String get aceptariaLaOferta => '他会接受这份报价。';
  @override
  String get todaviaNo => '还不行。更多的钱或更长的合同也许能让他改变主意。';
  @override
  String get noVaAAceptar => '他不会接受：你的球队离他的要求太远，钱也解决不了。';

  @override
  String anios(int n) => '$n 个赛季';
  @override
  String alAnio(String importe) => '每年 $importe';

  @override
  String get pestanaEquipos => '球队';
  @override
  String get pestanaJugadores => '球员';
  @override
  String get conferenciaEste => '东部';
  @override
  String get conferenciaOeste => '西部';
  @override
  String get fronteraPlayIn => '附加赛';
  @override
  String get fronteraFueraDePlayoffs => '无缘季后赛';
  @override
  String get ordenPuntos => '得分';
  @override
  String get ordenAsistencias => '助攻';
  @override
  String get ordenRebotes => '篮板';
  @override
  String get sinPartidosJugados => '目前还没有比赛进行';
  @override
  String edadJugador(int n) => '$n岁';
  @override
  String mediaJugador(int n) => '综合评分$n';
  @override
  String get estaTemporada => '本赛季';
  @override
  String get todaviaNoHaJugado => '尚未出场';
  @override
  String get contrato => '合同';
  @override
  String get intentarTraspasar => '尝试交易';
  @override
  String traspasoCerradoCon(String equipo) => '已与$equipo完成交易。';
  @override
  String get fechaLimiteTraspasosPasada => '交易截止日期已过，本赛季无法再完成任何交易。';

  @override
  String get tituloConferenciaEste => '东部联盟';
  @override
  String get tituloConferenciaOeste => '西部联盟';

  @override
  String comoFicharA(String nombre) => '怎样签下$nombre？';
  @override
  String get sinConQueConvencerles => '你现在拿不出有说服力的筹码：无论是阵容还是选秀权，都不足以在不伤筋动骨的情况下打动对方。';

  @override
  String get campeonesDeLaNba => 'NBA总冠军';
  @override
  String get campeonesDeLaCup => 'NBA杯总冠军';
  @override
  String get exclamacionCampeones => '总冠军！';
  @override
  String seLlevaElTitulo(String nombre) => '$nombre夺得冠军。';
  @override
  String get enhorabuenaAnillo => '恭喜！你们做到了：冠军戒指到手了。下个赛季要开始卫冕了。';
  @override
  String get enhorabuenaCup => '恭喜！你们赢得了NBA杯。冠军戒指是另一回事——赛季还在继续。';
  @override
  String get aCelebrarlo => '庆祝一下！';
  @override
  String mvpDeLasFinales(String nombre) => '总决赛MVP·$nombre';
  @override
  String partidosDeSerie(int n) => '$n场';
  @override
  String get verEstadisticas => '查看数据';
  @override
  String get confirmarSimularTitulo => '模拟到这一天？';
  @override
  String get seJugaraProximoPartido => '将进行你的下一场比赛。';
  @override
  String seJugaranDeUnaVez(int partidos, int dia, int mes) => '截至$mes月$dia日剩余的$partidos场比赛将一次性模拟完成。';
  @override
  String get simular => '模拟';
  @override
  String finalCupVs(String enfrentamiento) => 'NBA杯决赛——$enfrentamiento';
  @override
  String get tituloEventoFinAgenciaLibre => '自由市场结束';
  @override
  String get tituloEventoFechaLimiteTraspasos => '交易截止日';
  @override
  String get tituloEventoAllStar => '全明星周末';
  @override
  String get descEventoFinAgenciaLibre => '从现在起，将无法再签下自由球员。';
  @override
  String get descEventoFechaLimiteTraspasos => '本赛季最后交易日。';
  @override
  String get descEventoAllStar => '本周末你没有比赛。趁这个机会看看联盟排名吧。';
  @override
  List<String> get nombresMeses => ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
  @override
  List<String> get diasSemanaAbrev => ['一', '二', '三', '四', '五', '六', '日'];
  @override
  String get unPartido => '1场';
  @override
  String get simularUnPartido => '模拟1场比赛';
  @override
  String get unaSemana => '1周';
  @override
  String get simularUnaSemana => '模拟1周';
  @override
  String get unMes => '1个月';
  @override
  String get simularUnMes => '模拟1个月';
  @override
  String get verBracketCompleto => '查看完整对阵图';
  @override
  String get empezarSiguienteTemporada => '开始下个赛季';
  @override
  String get simularPartidoDePlayoffs => '模拟季后赛比赛';
  @override
  String get noClasificasteAPlayoffs => '本赛季你未能晋级季后赛。';
  @override
  String get simularPlayoffsCompletos => '模拟完整季后赛';
  @override
  String get serieDecididaFaltaResto => '你的系列赛已经结束——还需要等对阵图的其余部分揭晓，才能知道你的下一个对手。';
  @override
  String get simularRestoDeRonda => '模拟本轮剩余比赛';

  @override
  String ofertaTitulo(int n) => n == 1 ? '你收到了一份报价' : '你有多份报价';
  @override
  String ofertaMensaje(int n) => n == 1 ? '一支球队询问了你的一名球员，并提出了报价。' : '有$n支球队询问了你的球员。';
  @override
  String get masTarde => '稍后再看';
  @override
  String verOfertaBoton(int n) => '查看报价';
  @override
  String get preguntaSeguirSimulando => '你已经到达本赛季的这个截止日期。要继续模拟，还是暂停进行操作？';
  @override
  String get irAAgenciaLibre => '前往自由市场';
  @override
  String get irATraspasos => '前往交易';
  @override
  String get seguirSimulando => '继续模拟';
  @override
  String get allStarWeekendMayus => 'ALL STAR WEEKEND';
  @override
  String resultadoAllStar(
      {required bool esteGana,
      required int local,
      required int visitante,
      String? mvp}) => '全明星赛已经结束。${esteGana ? "东部" : "西部"}以$local-$visitante赢得比赛。${mvp == null ? "" : "\n\n全场MVP：$mvp。"}';
  @override
  String get verFinDeSemana => '查看全明星周末';
  @override
  String finalCupProgramada(String fecha) => '你晋级NBA杯决赛了！比赛在$fecha进行：模拟到那一天即可。';
  @override
  String fechaCorta(int dia, int mes) => '${nombresMeses[mes - 1]}$dia日';

  @override
  String get sinPartidosTitulo => '没有比赛';
  @override
  String resumenPartidos(int n, int ganados, int perdidos) {
    final g = ganados;
    final p = perdidos;
    return '$n场比赛·$g胜$p负';
  }
  @override
  String get lesionesActivasAhora => '当前的伤病情况';
  @override
  String get verLosPremios => '查看奖项';

  @override
  String get playoffsSeSiembranAlTerminar => '常规赛（82场）结束后将生成季后赛对阵。';
  @override
  String get verCelebracion => '查看庆祝';
  @override
  String get siguienteTemporadaBtn => '下个赛季';
  @override
  String get resolverPlayIn => '完成附加赛';
  @override
  String get simularRondaCompleta => '模拟整轮比赛';
  @override
  String get simularTodoBtn => '全部模拟';
  @override
  String get bracketTitulo => '对阵图';
  @override
  String get primeraRondaEsperaPlayIn => '附加赛决出7号种子和8号种子之前，第一轮不会开始。';
  @override
  String get playInGanadorEntra7 => '胜者获得7号种子';
  @override
  String get playInPerdedorEliminado => '负者被淘汰';
  @override
  String get playInGanadorEntra8 => '胜者获得8号种子';
  @override
  String get conferenciaOesteTitulo => '西部联盟';
  @override
  String get conferenciaEsteTitulo => '东部联盟';
  @override
  String get sinPlayIn => '无附加赛';
  @override
  String get jugarBtn => '开始';
  @override
  String get porJugar => '待进行';
  @override
  String get rondaPrimeraRonda => '第一轮';
  @override
  String get rondaSemifinalConferencia => '联盟半决赛';
  @override
  String get rondaFinalConferencia => '联盟决赛';
  @override
  String get rondaFinalNba => 'NBA总决赛';
  @override
  List<String> get nombresDeRondaBracket => ['第一\n轮', '半决赛', '西部\n决赛', 'NBA\n总决赛', '东部\n决赛', '半决赛', '第一\n轮'];
  @override
  String get esperandoAlPlayIn => '等待附加赛结果';
  @override
  String get porDefinir => '待定';

  @override
  String despedirConfirmacion(String nombre) => '解雇$nombre？';
  @override
  String despedirConTiempoRestante(int anios, String importe) => '他的合同还剩$anios个赛季，这笔钱你必须照付：$importe在合同到期前都无法用来签下他的继任者。';
  @override
  String get despedirSinContrato => '他将成为自由身，可以与任何球队签约。在你找到新教练之前，你的球队将没有教练执教。';
  @override
  String get ficharPorElMinimoBtn => '以底薪签约';
  @override
  String get noHayEntrenadorSinEquipo => '目前没有无球队的教练';
  @override
  String get dirigiendoAOtroEquipo => '正在执教其他球队';
  @override
  String get sePuedeOfertarPeroTrabajo => '你可以向他们发出报价，但他们已有工作在身：需要开出更有诚意的条件才能说服他们，而且你挖走教练的球队会立刻寻找替代人选。';
  @override
  String get avisoObligatorioTexto => '没有教练无法继续比赛。请签下一位教练：如果没有中意的人选或预算不够，你随时可以以底薪签下一位。';
  @override
  String mediaDeTuEquipoEs(int n) => '你球队的平均能力值是$n。教练越出色，对球队前景的要求就越高——金钱只能弥补部分差距。';
  @override
  String pideAlAnioYTemporadas(String importe, int anios) => '要求年薪$importe，合同$anios个赛季。';
  @override
  String noLlegaMasaSalarial(String importe) => '你的薪资空间不够：最多只能提供$importe。';
  @override
  String get tuEntrenadorLabel => '你的教练';
  @override
  String get masaSalarialConBanquillo => '薪资总额（含教练组）';
  @override
  String get porEncimaDelTopeSoloMinimo => '你已经超过薪资帽：只能以底薪签约。';
  @override
  String get sueldoEntrenadorCuentaEnMasa => '教练的薪水计入你的薪资总额：在这里花掉的钱就不能用来签球员了。';
  @override
  String contratoResumen(String importeAlAnio, String duracion) => '$importeAlAnio·合同$duracion';
  @override
  String trayectoriaEstaTemporada(int victorias, int derrotas) => '本赛季：$victorias胜$derrotas负';
  @override
  String temporadasDirigiendo(int n) => '执教$n个赛季';
  @override
  String anillos(int n) => '$n枚戒指';
  @override
  String entrenadorDelAnio(int n) => '$n次最佳教练';
  @override
  String dirigeAEquipo(String apodo) => '正在执教$apodo';
  @override
  String pideImportePorAnios(String importe, int anios) => '要求$importe×$anios年';
  @override
  String get noCabeEnPresupuesto => '超出你的教练组预算';
  @override
  String get proyectoLeQuedaLejos => '你的球队前景与他的期望相差太远';
  @override
  String get asuPrecioNo => '按他要的价钱他会拒绝；给更多钱也许有机会';
  @override
  String get volver => '返回';
  @override
  String get elegirEsteEquipo => '选择这支球队';

  @override
  String mediaDelEquipo(int n) => '球队平均值：$n';
  @override
  String get torneoDeMitadDeTemporada => '赛季中期锦标赛';
  @override
  String get campeonNba => 'NBA总冠军';

  @override
  String descripcionHueco(bool esTitular, String nombrePosicion) => esTitular ? '$nombrePosicion首发' : '$nombrePosicion替补';
  @override
  String get tituloTitular => '首发';
  @override
  String get tituloSuplente => '替补';
  @override
  Map<String, String> get nombresDePosiciones => {'PG': '控球后卫 (PG)', 'SG': '得分后卫 (SG)', 'SF': '小前锋 (SF)', 'PF': '大前锋 (PF)', 'C': '中锋 (C)'};
  @override
  String get minutosTitularLabel => '首发时间：';
  @override
  String fueraPorLesion(String nombres) => '因伤缺阵：$nombres';
  @override
  String get alinearAutomaticamenteBtn => '自动排阵';
  @override
  String get pestanaAlineacion => '阵容';
  @override
  String get pestanaEstadisticas => '数据统计';
  @override
  String alineacionDeEquipo(String equipo) => '阵容：$equipo';
  @override
  String get tusPicksDeDraft => '你的选秀权';
  @override
  String get empezarTemporadaBtn => '开始赛季';
  @override
  String get guardarRotacionBtn => '保存阵容';
  @override
  String get elegirJugadorPlaceholder => '——选择球员——';
  @override
  String huecoConJugador(String etiqueta, String nombre, String posicion, int media) => '$etiqueta：$nombre（$posicion，综合评分$media）';
  @override
  String lesionConDetalle(String motivo, int partidos, String fecha) => '$motivo（$partidos场）——预计$fecha复出——期间由替补出场';
  @override
  String get fueraDeSusDosPosiciones => '不在其擅长的两个位置（表现会略差）';
  @override
  String get sinPartidosJugadosTemporada => '本赛季尚未出场';
  @override
  String get estrellaAtaqueLabel => '进攻核心';
  @override
  String get estrellaDefensaLabel => '防守核心';
  @override
  String get ningunaOpcion => '无';
  @override
  String get sinPicksPropios => '你没有属于自己的选秀权了：全部交易出去了。';
  @override
  String get traspasadoATiPorOtroEquipo => '由其他球队交易而来';
  @override
  String get ataqueYDefensaTitulo => '进攻与防守';
  @override
  String get quintetoInicial => '首发五人';
  @override
  String get rotacionCompleta => '完整轮换';

  @override
  String nombreConPosicionYMedia(String nombre, String posicion, int media) => '$nombre（$posicion，综合评分$media）';
  @override
  String yaAsignadoIntercambio(String descripcionHueco) => '目前是$descripcionHueco——将互换位置';
  @override
  String get tituloTusPicksDeDraft => '你的选秀权';

  @override
  String lesionSimple(String motivo, String fecha) => '$motivo，预计$fecha复出';

  @override
  String get rechazar => '拒绝';
  @override
  String get proponer => '提出方案';
  @override
  String get todosFiltro => '全部';
  @override
  String get tituloAgenciaLibre => '自由市场';
  @override
  String get verTuPlantilla => '查看你的阵容';
  @override
  String get agenciaLibreCerrada => '本赛季自由市场已关闭：截止日期已过。你还能继续浏览市场，但要到明年才能签约。';
  @override
  String get completarConContratosMinimos => '用底薪合同补齐阵容';
  @override
  String get plantillaCompletada => '阵容已补齐。';
  @override
  String fichadosPorElMinimo(int n) => '已签下$n名底薪球员。';
  @override
  String get quePuedaPagar => '我能负担的';
  @override
  String get noQuedaNadieEnMercado => '市场上已经没有球员了。';
  @override
  String get nadieEncajaConFiltro => '市场上没有符合你筛选条件的球员，试试去掉某个筛选项。';
  @override
  String contadorAgentesLibres(int n) => '$n名自由球员';
  @override
  String contadorAgentesLibresFiltrado(int visibles, int total) => '共$total名自由球员中的$visibles名（已应用筛选）';
  @override
  String get empezarLaTemporadaBtn => '开始赛季';
  @override
  String get completaLaPlantillaParaContinuar => '请先补齐阵容才能继续';
  @override
  String plantillaAlCompletoConN(int n) => '阵容已满：共$n名球员。';
  @override
  String plantillaDeMax(int n, int max) => '阵容：共$max人中的$n人。';
  @override
  String faltanFichajesParaMinimo(int n) => '还差$n名球员才达到最低人数。';
  @override
  String otrosEquiposJuegan(int max, int n, int atras) => '其他29支球队都有$max人。你有$n人也能开始，但少了$atras人。';
  @override
  String sinRecambioEn(String lista) => '以下位置无替补：$lista。';
  @override
  String libresBajoElTope(String cantidad) => '工资帽下还有$cantidad空间。';
  @override
  String get yaNoNegocia => '已停止谈判';
  @override
  String negociarConN(int n) => '谈判（$n）';
  @override
  String ofertaA(String nombre) => '向$nombre报价';
  @override
  String pideAlAnio(String cantidad) => '要价$cantidad/年';
  @override
  String sueldoLabel(String cantidad) => '薪水：$cantidad';
  @override
  String get insultoOferta => '他会把这当作一种侮辱。';
  @override
  String get ofertaImprobable => '他基本不会接受：薪水、年限或两者都不够。';
  @override
  String get ofertaSePuedePensar => '他可能会考虑一下，但还不太确定。';
  @override
  String get ofertaProbableAceptar => '他很可能会接受。';
  @override
  String get ofertaSeguraAceptar => '他几乎肯定会同意。';
  @override
  String get aniosLabelDosPuntos => '年限：';
  @override
  String get tituloRenovaciones => '续约';
  @override
  String get ningunContratoSeAcaba => '没有合同到期：你的阵容还会再锁定一年。';
  @override
  String continuarConNAgenciaLibre(int n) => '继续（$n人将进入自由市场）';
  @override
  String porEncimaDelTope(String cantidad) => '你已超出工资帽$cantidad：只能开出底薪合同。';
  @override
  String teQuedanBajoElTope(String espacio, String tope) => '在$tope的工资帽下，你还剩$espacio空间。';
  @override
  String get seAcaboLaNegociacion => '谈判\n已结束';
  @override
  String ofrecerConN(int n) => '报价（$n）';
  @override
  String subtituloRenovacion(String posicion, int edad, int media, String cobraba, String pide) => '$posicion·$edad岁·综合评分$media\n原薪水$cobraba·要价$pide';
  @override
  String get cerramosElTraspaso => '确认成交？';
  @override
  String seVanYLlegan(String piden, String ofrecen) => '送出$piden，得到$ofrecen。';
  @override
  String get tituloOfertasRecibidasScreen => '收到的报价';
  @override
  String get nadieTePideNadaAhora => '目前还没有人向你提出报价。继续模拟比赛，报价会在赛季中出现。';
  @override
  String get ofertaAnterior => '上一个报价';
  @override
  String get ofertaSiguiente => '下一个报价';
  @override
  String ofertaNDeM(int n, int m) => '第$n个报价（共$m个）';
  @override
  String lineaJugadorOferta(String nombre, String posicion, int media, String pts, String ast, String reb, String contrato) => '$nombre·$posicion·$media·场均$pts分$ast助攻$reb篮板·$contrato';
  @override
  String get ultimoAnioContrato => '最后一年';
  @override
  String aniosDeContrato(int n) => '$n年';
  @override
  String contratoAnioMillones(String anios, String millones) => '$anios·$millones/年';
  @override
  String get tePiden => '对方索要';
  @override
  String get teOfrecen => '对方提供';
  @override
  String get contraofertar => '还价';
  @override
  String get teVasAQuedarCorto => '你的阵容会不够用';
  @override
  String avisoLoCierras(String aviso) => '$aviso\n\n仍要完成交易吗？';
  @override
  String get mejorNo => '还是算了';
  @override
  String get cerrarloIgual => '仍要成交';
  @override
  String get traspasoCerradoSimple => '交易已完成。';
  @override
  String get fechaLimiteTraspasosNoMasOperaciones => '交易截止日期已过：本赛季无法再完成任何交易。';
  @override
  String quienSeLlevaA(String nombre) => '谁会想要$nombre？';
  @override
  String quienSeLlevaPaquete(int n) => '谁会想要这个包含$n项的方案？';
  @override
  String get ningunEquipoTeDariaNada => '没有球队愿意给出值得的回报。';
  @override
  String get noTienesConQueConvencer => '你没有足够的筹码说服对方：无论是阵容还是选秀权，都不够，除非掏空自己。';
  @override
  String get tituloTraspasos => '交易';
  @override
  String get fechaLimiteTraspasosBanner => '本赛季交易截止日期已过：你还能继续浏览市场，但要到明年才能完成任何交易。';
  @override
  String get noCuadraMeteATercero => '凑不齐？加入第三支球队';
  @override
  String get cerrarTraspasoBtn => '完成交易';
  @override
  String get tuEquipoLabel => '你的球队';
  @override
  String get tercerEquipoLabel => '第三方球队';
  @override
  String get rivalLabel => '对方球队';
  @override
  String get buscarQuienCompraria => '查找谁会想要他';
  @override
  String get buscarQueDarPorEl => '查找得到他需要付出什么';
  @override
  String anadirDe(String equipo) => '从$equipo添加';
  @override
  String get eleccionesDeDraft => '选秀权';
  @override
  String get yaHasPuestoTodo => '你已经把这支球队所有可用的资产都放到桌面上了。';
  @override
  String get sacarDeLaOperacion => '从交易中移除';
  @override
  String get noCuadraMeteATerceroLarga => '凑不齐？\n加入第三支球队';
  @override
  String get anadirEquipoBtn => '添加球队';
  @override
  String get tocaParaElegirJugadoresOPicks => '点击选择\n球员或选秀权';

  @override
  String get mercadoCerradoNoSeBuscan => '市场已关闭：交易截止日期已过。要到明年才能查找交易方案。';
  @override
  String get ultimoAnioMinuscula => '最后一年';

  @override
  String get tituloLegado => '传承';
  @override
  String get explicacionPuntuacionCarreraTooltip => '生涯评分代表什么';
  @override
  String get hallOfFame => 'Hall of Fame';
  @override
  String get pestanaCamisetasRetiradas => '退役球衣';
  @override
  String get pestanaLideresHistoricos => '历史数据榜';
  @override
  String get camisetaRetiradaSingular => '退役球衣';
  @override
  String get unDorsalQueNoVolvera => '一个永远不会再被穿上的号码';
  @override
  String get dorsalesQueNoVolveran => '这些号码永远不会再被穿上';
  @override
  String get tituloPartidosDeLaSerie => '系列赛比赛';
  @override
  String partidoNMarcador(int n, String local, int marcadorLocal, int marcadorVisitante, String visitante) => '第$n场：$local $marcadorLocal - $marcadorVisitante $visitante';
  @override
  String get unNuevoNombreHof => '一位新成员入选名人堂。';
  @override
  String nNombresNuevosHof(int n) => '$n位新成员入选名人堂。';
  @override
  String entroEnAnio(int anio) => '$anio年入选';
  @override
  String get queEsPuntuacionCarrera => '什么是生涯评分？';
  @override
  String get explicacionPuntuacionCarreraTexto => '概括球员的整个职业生涯，而不是单一的孤立数字：\n\n• 个人荣誉（MVP、最佳防守球员、最佳阵容、最佳新秀、进步最快球员）。\n• 总冠军戒指和NBA杯冠军头衔。\n• 曾经达到的巅峰水平。\n• 根据出场赛季数累积的得分、助攻和篮板。\n\n至少需要打满6个赛季并超过某个门槛才能入选：一个没有荣誉的稳定首发是不够的，必须真正举足轻重。';
  @override
  String get entendido => '知道了';
  @override
  String noSePudoCargarHof(String error) => '无法加载名人堂。\n$error';
  @override
  String get todaviaNadieEnHof => '名人堂目前还没有成员。只有已退役、拥有伟大生涯的球员才能入选：荣誉、戒指和多年的高水准表现。';
  @override
  String get nuevoChip => '新';
  @override
  String statsCarreraSufijo(String pts, String ast, String reb) => ' · 场均$pts分 $ast助攻 $reb篮板';

  @override
  String get enActivoLeyenda => '现役：排名仍有可能上升';
  @override
  String get todaviaNoHayEstadisticas => '暂时还没有数据可以显示。';
  @override
  String noSePudieronCargarCamisetas(String error) => '无法加载退役球衣。\n$error';
  @override
  String get todaviaNoHayCamisetaEnLiga => '联盟中还没有球衣退役。当一位传奇球员退役时，你就可以向他致敬了。';
  @override
  String get franquiciaLabel => '球队';
  @override
  String get todaLaLigaOpcion => '整个联盟';
  @override
  String equipoTodaviaNoHaRetirado(String equipo) => '$equipo还没有退役任何球衣。';
  @override
  String get tuEquipoBadge => '你的球队';
  @override
  String get retiradaRealDeLaFranquicia => '球队真实退役记录';
  @override
  String retiradaEnLaTemporada(String etiquetaTemporada) => '$etiquetaTemporada退役';
  @override
  String nPartidos(int n) => '$n场比赛';
  @override
  String get enElVestuario => '更衣室动态';

  @override
  String get premioMvp => 'MVP';
  @override
  String get premioMejorDefensor => '最佳防守球员';
  @override
  String get premioRookieDelAno => '最佳新秀';
  @override
  String get premioMasMejorado => '进步最快球员';
  @override
  String get premioPrimerQuinteto => '最佳阵容一阵';
  @override
  String get premioSegundoQuinteto => '最佳阵容二阵';
  @override
  String get risingStars => '菜鸟精英赛';
  @override
  String premioMvpAllStar(String allStar) => '$allStar MVP';
  @override
  String premioMvpRisingStars(String risingStars) => '$risingStars MVP';
  @override
  String get tituloPremiosDeLaTemporada => '赛季荣誉';
  @override
  String noSePudieronCargarPremios(String error) => '无法加载荣誉信息。\n$error';
  @override
  String get verCalendarioBtn => '查看赛程';
  @override
  String statsPremioLinea(String pts, String ast, String reb) => '场均$pts分, $ast助攻, $reb篮板';

  @override
  String temporadaN(int n) => '第$n赛季';
  @override
  String arrancaLaTemporada(int n, int anioInicio, int anioFin) => '第$n赛季开幕（$anioInicio-$anioFin）';
  @override
  String get plantillaHaCambiadoAviso => '你的阵容发生了变化：请在第一场比赛前检查一下——系统已经自动生成了一套首发阵容。';
  @override
  String get tusEleccionesDelDraft => '你的选秀权';
  @override
  String get seRetiranDeTuEquipo => '从你的球队退役';
  @override
  String cuelgaLasBotasCon(int edad, int media) => '以$edad岁、综合评分$media的状态挂靴';
  @override
  String get hanDadoUnPasoAdelante => '实现了进步';
  @override
  String get empiezanABajar => '开始走下坡路';
  @override
  String get topDelDraft => '选秀亮点';
  @override
  String get movimientosEnLaLiga => '联盟动态';
  @override
  String recibeA(String equipoA, String jugadorB, String posicionB) => '$equipoA得到$jugadorB（$posicionB）';
  @override
  String get tambienSeRetiran => '同时退役的还有';
  @override
  String yNMas(int n) => '另外还有$n人';
  @override
  String posicionMediaSeparador(String posicion, int media) => '$posicion·综合评分$media· ';

  @override
  String camisetaDeXRetirada(String nombre) => '$nombre的球衣已退役。';
  @override
  String get tituloSeRetiran => '退役球员';
  @override
  String get estaTemporadaNoSeRetiraNadie => '本赛季没有球员退役。';
  @override
  String get restoDeLaLiga => '联盟其他球队';
  @override
  String seRetiraConEdadYMedia(String procedencia, int edad, int media, String aviso) => '$procedencia·以$edad岁、综合评分$media退役$aviso';
  @override
  String get suCamisetaYaRetiradaSola => ' · 该球衣已自动退役（真实传奇球员）';
  @override
  String get camisetaRetiradaSufijo => ' · 球衣已退役';

  @override
  String get tituloResultadoPartido => '比赛结果';
  @override
  String get columnaTotal => '总计';
  @override
  String get columnaJugador => '球员';
  @override
  String get columnaMin => '分钟';
  @override
  String get columnaPts => '得分';
  @override
  String get columnaAst => '助攻';
  @override
  String get columnaReb => '篮板';
  @override
  String get prefijoCuarto => 'Q';
  @override
  String get prefijoProrroga => '加';

  @override
  String get ordenPotencial => '潜力';
  @override
  String get ordenMediaDesc => '评分 ↓';
  @override
  String get ordenMediaAsc => '评分 ↑';
  @override
  String get tituloDraft => '选秀';
  @override
  String get eligiendoElRestoDeEquipos => '其他球队正在选人……';
  @override
  String get queElijaLaCpuPorMi => '让电脑替我选择';
  @override
  String get draftCompletado => '选秀结束';
  @override
  String eleccionNumero(int n) => '第$n顺位';
  @override
  String get teTocaElegir => '轮到你选择了！';
  @override
  String get ordenarPorLabel => '排序方式：';
  @override
  String posicionEdadMedia(String posicion, int edad, int media) => '$posicion·$edad岁·综合评分$media';

  @override
  String cuartosCopaSeSiembranAviso(String nbaCup) => '当全联盟的小组赛阶段结束后，$nbaCup八强对阵就会确定。';
  @override
  String get finalSeJuegaDesdeCalendarioAviso => '决赛需要在赛程中进行：如果你晋级决赛，它会像赛季中的普通一天一样标注出来。';
  @override
  String get cuartosDeFinalLabel => '四分之一决赛';
  @override
  String get semifinalLabel => '半决赛';
  @override
  String finalDeLaCopaLabel(String nbaCup) => '$nbaCup决赛';
  @override
  String get cuartosRondaLabel => '八强';
  @override
  String get finalRondaLabel => '决赛';
  @override
  String get pendienteLabel => '待定';

  @override
  String get tituloResumenDeLaTemporada => '赛季总结';
  @override
  String noSePudoCargarResumen(String error) => '无法加载总结。\n$error';
  @override
  String temporadaConEtiqueta(String etiqueta) => '$etiqueta赛季';
  @override
  String get pestanaBalance => '概览';
  @override
  String puestoEnConferencia(String conferencia) => '$conferencia排名';
  @override
  String puestoValor(int puesto) => '#$puesto';
  @override
  String puestoEnLaLigaNota(int puesto) => '联盟第#$puesto';
  @override
  String get puntosPorPartidoLabel => '场均得分';
  @override
  String encajadosLabel(String valor) => '失分$valor';
  @override
  String get diferenciaLabel => '净胜分';
  @override
  String get porPartidoLabel => '场均';
  @override
  String get mejorRachaLabel => '最长连胜';
  @override
  String get victoriasSeguidasLabel => '连胜';
  @override
  String get peorRachaLabel => '最长连败';
  @override
  String get derrotasSeguidasLabel => '连败';
  @override
  String get mejorVictoriaLabel => '最佳胜利';
  @override
  String get peorDerrotaLabel => '最差失利';
  @override
  String partidosJugadosVictoriasPct(int partidos, int pct) => '$partidos场比赛·胜率$pct%';
  @override
  String get todaviaNoHayClasificacion => '暂无排名。';
  @override
  String get columnaPJ => '场次';
  @override
  String posicionMedia(String posicion, int media) => '$posicion·综合评分$media';

  @override
  String get allStarSubtituloPendiente => '在二月的全明星周末休赛期举行。继续模拟到全明星周末即可看到。';
  @override
  String get risingStarsSubtituloPendiente => '最佳新秀对阵二年级球员，同一个周末举行。';
  @override
  String get votacionAbreCuandoRuedeBalonAviso => '投票会在赛季开打后开启。随着你模拟比赛，你会看到谁正在凭借多少票数赢得名额。';
  @override
  String get verEstadisticasBtn => '查看数据';
  @override
  String mvpConNombre(String nombre) => 'MVP·$nombre';
  @override
  String lineaMvpPtsAstReb(int pts, int ast, int reb) => '$pts分·$ast助攻·$reb篮板';
  @override
  String escrutadoPorcentaje(int pct) => '已统计$pct%的选票……';
  @override
  String get recuentoCerradoAviso => '投票已结束：以下是最终当选名单。';
  @override
  String votacionAbiertaConPorcentaje(int pct) => '投票进行中，本赛季已完成$pct%。继续模拟，票数还会变化。';
  @override
  String get votacionFinalLabel => '最终投票结果';
  @override
  String get votacionDeAficionadosLabel => '球迷投票';
  @override
  String conferenciaConNombre(String conferenciaLabel) => '$conferenciaLabel联盟';
  @override
  String get titularesLabel => '首发';
  @override
  String get suplentesLabel => '替补';
  @override
  String get seQuedanFueraLabel => '落选球员';
  @override
  String posicionValoracion(String posicion, String valoracion) => '$posicion·评分$valoracion';

  @override
  String get noLlegoACompletarNingunaTemporada => '从未在你手下完整效力过一个赛季。';
  @override
  String get tituloTrayectoria => '生涯轨迹';
  @override
  String get tituloPalmares => '荣誉';
  @override
  String get noRetirarElDorsal => '不退役该号码';
  @override
  String get retirarSuCamiseta => '退役球衣';
  @override
  String get mvpFinalesCorto => '总决赛MVP';
  @override
  String get mvpDeLasFinalesLabel => '总决赛MVP';
  @override
  String quintetosAllNba(int n) => '$n次最佳阵容';
  @override
  String vecesConEtiqueta(int n, String etiqueta) => '$n次$etiqueta';
  @override
  String copasGanadas(int n, String nbaCup) => '$n次$nbaCup';
  @override
  String get premioCampeonDeLaNba => 'NBA总冠军';
  @override
  String get premioTercerQuinteto => '最佳阵容三阵';
  @override
  String get premioMaximoAnotador => '得分王';
  @override
  String get premioMasMejoradoCorto => '进步最快';
  @override
  String get sinTitulosNiPremiosCarreraNba => 'NBA生涯没有获得任何冠军或荣誉。';
  @override
  String get sinTitulosNiPremiosIndividuales => '没有冠军或个人荣誉。';
  @override
  String resumenCarreraTotales(int temporadas, String posicion, int partidos) => '$temporadas个赛季·$posicion·$partidos场比赛';
  @override
  String totalesCarreraLinea(String pts, String ast, String reb) => '总计：$pts分·$ast助攻·$reb篮板';
  @override
  String temporadasPreviasAviso(int n) => '其中$n个赛季是在你接手之前：那些赛季没有数据记录，下面的平均数据是你执教以来的。';
  @override
  String get antesDeTuPartidaTitulo => '在你的存档之前';
  @override
  String temporadasYaJugadasCuandoCogisteElEquipo(int n) => '在你接手球队之前，他已经打了$n个赛季。';
  @override
  String get produccionDeReferenciaAviso => '存档开始时他的参考数据。那些赛季没有逐场比赛的数据记录。';
  @override
  String sinEstadisticasDeCarreraAviso(String nombre) => '$nombre没有生涯数据记录：他所处的年代早于游戏数据覆盖的范围。他在历史上的地位是真实的，只是没有具体数字。';
  @override
  String get suCarreraEnLaNbaReal => '他的真实NBA生涯';
  @override
  String conEquipoEnLaNbaReal(String equipo) => '在真实NBA效力$equipo期间';
  @override
  String temporadasPartidos(int temporadas, int partidos) => '$temporadas个赛季·$partidos场比赛';
  @override
  String rangoTemporadasPartidos(String desde, String hasta, int partidos) => '$desde至$hasta·$partidos场比赛';
  @override
  String rangoPartidos(String rango, int partidos) => '$rango·$partidos场比赛';
  @override
  String temporadaMinuscula(int n) => '第$n赛季';

  @override
  String get nadieTePropuestoNadaAhora => '目前还没有人向你提出方案';
  @override
  String get unEquipoQuiereAUnoDeTusJugadores => '有一支球队想要你的一名球员';
  @override
  String nEquiposHanPreguntado(int n) => '有$n支球队询问了你的球员';
  @override
  String cuadroYResultadosDeLaCopa(String nbaCup) => '$nbaCup对阵表和战绩';
  @override
  String get seDesbloqueaAlTerminarFaseDeGrupos => '小组赛阶段结束后解锁';
  @override
  String get premiosDeFinDeTemporadaSubtitulo => '赛季末荣誉';
  @override
  String get seDesbloqueaAlTerminarTemporadaRegular => '常规赛结束后解锁';
  @override
  String get bracketDeEliminatorias => '季后赛对阵表';
  @override
  String hallOfFameYCamisetasRetiradasSubtitulo(String hallOfFame, String camisetas) => '$hallOfFame和$camisetas';
  @override
  String get salarialLabel => '薪资';

  @override
  String get sigueDondeLoDejaste => '从你离开的地方继续';
  @override
  String get empiezaTuCarrera => '开启你的生涯';
  @override
  String get enQueRanuraQuieresEmpezar => '你想在哪个存档位开始？';
  @override
  String get eligeLaPartidaQueQuieresCargar => '选择要读取的存档';
  @override
  String get nuevaPartidaBtn => '新存档';
  @override
  String get cargarPartidaBtn => '读取存档';
  @override
  String sobrescribirLaPartidaN(int n) => '覆盖存档$n？';
  @override
  String get sePerderaEnteraAviso => '该存档位已经有一段正在进行的生涯，将会被完全清除：阵容、赛程和荣誉。此操作无法撤销。';
  @override
  String get sobrescribirBtn => '覆盖';
  @override
  String get eligeTuEquipoTitulo => '选择你的球队';
  @override
  String borrarLaPartidaN(int n) => '删除存档$n？';
  @override
  String sePierdeCarreraDeAviso(String nombre) => '$nombre的整段生涯都会消失：阵容、赛程、荣誉、传奇球员和退役球衣。此操作无法撤销。';
  @override
  String get borrarBtn => '删除';
  @override
  String get lasTresRanurasOcupadasAviso => '三个存档位都已占满：删除一个才能重新开始，或者继续你已有的存档。';
  @override
  String partidaNumero(int n) => '存档$n';
  @override
  String get borrarEstaPartidaTooltip => '删除此存档';
  @override
  String get ranuraVaciaLabel => '空存档位';
  @override
  String get empezarBtn => '开始';

  @override
  String get lesionLabel => '伤病';
  @override
  String get recibesLabel => '获得：';
  @override
  String get entregasLabel => '送出：';
  @override
  String get traspasarBtn => '完成交易';
  @override
  String jugadorConFicha(String nombre, String posicion, int media, int edad) => '$nombre（$posicion，$media，$edad岁）';
  @override
  String get potencialElite => '顶级';
  @override
  String get potencialMuyAlto => '很高';
  @override
  String get potencialAlto => '高';
  @override
  String get potencialMedio => '中等';
  @override
  String get potencialBajo => '低';
  @override
  String potencialTooltip(String etiqueta) => '潜力：$etiqueta';
  @override
  String get volverAlMenuPrincipalTooltip => '返回主菜单';

  @override
  String get margenSalarialEvento => '工资空间';

  @override
  String get tuFranquiciaSeccion => '你的球队';

  @override
  String get proximoPartidoTitulo => '下一场比赛';

  @override
  String get enCasaLabel => '主场';

  @override
  String get fueraLabel => '客场';

  @override
  String get vsAbreviatura => 'VS';
}
