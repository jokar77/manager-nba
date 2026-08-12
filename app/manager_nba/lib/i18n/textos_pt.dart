part of 'textos.dart';

/// Português do Brasil, que é onde se joga basquete de verdade em
/// português. Por isso "basquete" e não "basquetebol", "técnico" e não
/// "treinador", e "elenco" e não "plantel".
class TextosPt extends Textos {
  const TextosPt();

  @override
  String get aceptar => 'Aceitar';
  @override
  String get cancelar => 'Cancelar';
  @override
  String get cerrar => 'Fechar';
  @override
  String get guardar => 'Salvar';
  @override
  String get continuar => 'Continuar';
  @override
  String get si => 'Sim';
  @override
  String get no => 'Não';
  @override
  String get cargando => 'Carregando…';

  @override
  String get nuevaPartida => 'Novo jogo';
  @override
  String get ajustes => 'Configurações';
  @override
  String get elegirEquipo => 'Escolha seu time';
  @override
  String get sobrescribir => 'Sobrescrever';
  @override
  String get ranuraOcupada => 'Este espaço já tem um jogo salvo';
  @override
  String get avisoSobrescribir =>
      'Se continuar, o jogo salvo aqui será apagado.';

  @override
  String get modoOscuro => 'Modo escuro';
  @override
  String get modoOscuroDetalle => 'Cinzas e pretos em vez de brancos claros';
  @override
  String get idioma => 'Idioma';
  @override
  String get idiomaDetalle => 'O idioma de todo o jogo';

  @override
  String get calendario => 'Calendário';
  @override
  String get calendarioDetalle => 'Veja sua temporada e simule jogos';
  @override
  String get tuEquipo => 'Seu time';
  @override
  String get tuEquipoDetalle => 'Elenco e escalação';
  @override
  String get entrenador => 'Técnico';
  @override
  String get banquilloVacante => 'Seu banco está vago';
  @override
  String get clasificacion => 'Classificação';
  @override
  String get clasificacionDetalle => 'Times e líderes de estatísticas';
  @override
  String get mercado => 'Mercado';
  @override
  String get traspasos => 'Trocas';
  @override
  String get traspasosDetalle => 'Negocie trocas com o resto da liga';
  @override
  String get ofertasRecibidas => 'Propostas recebidas';
  @override
  String get agenciaLibre => 'Agência livre';
  @override
  String get agenciaLibreDetalle => 'Jogadores sem time e espaço salarial';
  @override
  String get competicion => 'Competição';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Votação, Jogo das Estrelas e MVP';
  @override
  String get resumenTemporada => 'Resumo da temporada';
  @override
  String get resumenTemporadaDetalle => 'Campanha, todos os jogos e médias';
  @override
  String get playoffs => 'Playoffs';
  @override
  String get premios => 'Prêmios';
  @override
  String get legado => 'Legado';

  @override
  String get record => 'Campanha';
  @override
  String get masaSalarial => 'Folha salarial';
  @override
  String get temporada => 'Temporada';

  @override
  String get sinEntrenador => 'Sem técnico';
  @override
  String get sinEntrenadorDetalle =>
      'Seu time está jogando sem técnico. Contrate alguém da lista abaixo.';
  @override
  String get despedir => 'Demitir';
  @override
  String get contratar => 'Contratar';
  @override
  String get negociar => 'Negociar';
  @override
  String get ofrecer => 'Propor';
  @override
  String get sueldo => 'Salário';
  @override
  String get duracion => 'Duração';
  @override
  String get ataque => 'Ataque';
  @override
  String get defensa => 'Defesa';
  @override
  String get desarrollo => 'Desenvolvimento';
  @override
  String get equilibrado => 'Equilibrado';
  @override
  String get especialistaAtaque => 'Especialista em ataque';
  @override
  String get especialistaDefensa => 'Especialista em defesa';
  @override
  String get formadorDeJovenes => 'Formador de jovens';
  @override
  String get loQuePuedesOfrecer => 'O que você pode oferecer';
  @override
  String get topeDeLaFranquicia => 'Teto da franquia';
  @override
  String get finiquitos => 'Rescisões de técnicos demitidos';
  @override
  String get aceptariaLaOferta => 'Ele aceitaria esta proposta.';
  @override
  String get todaviaNo =>
      'Ainda não. Com mais dinheiro ou mais anos ele pode mudar de ideia.';
  @override
  String get noVaAAceptar =>
      'Ele não vai aceitar: seu projeto está longe demais e dinheiro não resolve.';

  @override
  String anios(int n) => n == 1 ? '1 temporada' : '$n temporadas';
  @override
  String alAnio(String importe) => '$importe por ano';
}
