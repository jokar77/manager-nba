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
}
