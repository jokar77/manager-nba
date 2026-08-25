part of 'textos.dart';

/// Português do Brasil, que é onde se joga basquete de verdade em
/// português. Por isso "basquete" e não "basquetebol", "técnico" e não
/// "treinador", e "elenco" e não "plantel".
class TextosPt extends Textos {
  const TextosPt();

  @override
  TextosDeEventos get eventos => const EventosPt();

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

  @override
  String get pestanaEquipos => 'Times';
  @override
  String get pestanaJugadores => 'Jogadores';
  @override
  String get conferenciaEste => 'Leste';
  @override
  String get conferenciaOeste => 'Oeste';
  @override
  String get fronteraPlayIn => 'Play-In';
  @override
  String get fronteraFueraDePlayoffs => 'Fora dos playoffs';
  @override
  String get ordenPuntos => 'Pontos';
  @override
  String get ordenAsistencias => 'Assistências';
  @override
  String get ordenRebotes => 'Rebotes';
  @override
  String get sinPartidosJugados => 'Ainda não foi disputada nenhuma partida';
  @override
  String edadJugador(int n) => '$n anos';
  @override
  String mediaJugador(int n) => 'Nível $n';
  @override
  String get estaTemporada => 'Esta temporada';
  @override
  String get todaviaNoHaJugado => 'Ainda não jogou';
  @override
  String get contrato => 'Contrato';
  @override
  String get intentarTraspasar => 'Tentar negociar';
  @override
  String traspasoCerradoCon(String equipo) => 'Negociação fechada com $equipo.';
  @override
  String get fechaLimiteTraspasosPasada =>
      'O prazo final de negociações já passou: não é possível fechar mais operações nesta temporada.';

  @override
  String get tituloConferenciaEste => 'CONFERÊNCIA LESTE';
  @override
  String get tituloConferenciaOeste => 'CONFERÊNCIA OESTE';

  @override
  String comoFicharA(String nombre) => 'Como contratar $nombre?';
  @override
  String get sinConQueConvencerles =>
      'Você não tem com que convencê-los agora: nem seu elenco nem suas escolhas bastam sem te deixar no vermelho.';

  @override
  String get campeonesDeLaNba => 'Campeões da NBA';
  @override
  String get campeonesDeLaCup => 'Campeões da NBA Cup';
  @override
  String get exclamacionCampeones => 'CAMPEÕES!';
  @override
  String seLlevaElTitulo(String nombre) => '$nombre leva o título.';
  @override
  String get enhorabuenaAnillo =>
      'Parabéns! Você conseguiu: o anel é seu. Na próxima temporada é hora de defendê-lo.';
  @override
  String get enhorabuenaCup =>
      'Parabéns! Vocês venceram a NBA Cup. O anel é outra história: a temporada continua.';
  @override
  String get aCelebrarlo => 'Hora de comemorar!';
  @override
  String mvpDeLasFinales(String nombre) => 'MVP das Finais · $nombre';
  @override
  String partidosDeSerie(int n) => n == 1 ? 'em 1 jogo' : 'em $n jogos';
  @override
  String get verEstadisticas => 'Ver estatísticas';
  @override
  String get confirmarSimularTitulo => 'Simular até este dia?';
  @override
  String get seJugaraProximoPartido => 'Sua próxima partida será disputada.';
  @override
  String seJugaranDeUnaVez(int partidos, int dia, int mes) =>
      'Serão disputadas de uma vez as $partidos partidas que faltam até $dia/$mes.';
  @override
  String get simular => 'Simular';
  @override
  String finalCupVs(String enfrentamiento) =>
      'Final da NBA Cup — $enfrentamiento';
  @override
  String get tituloEventoFinAgenciaLibre => 'Fim da agência livre';
  @override
  String get tituloEventoFechaLimiteTraspasos => 'Prazo final de negociações';
  @override
  String get tituloEventoAllStar => 'Fim de semana das estrelas';
  @override
  String get descEventoFinAgenciaLibre =>
      'A partir daqui, não é mais possível contratar agentes livres.';
  @override
  String get descEventoFechaLimiteTraspasos =>
      'Último dia para fazer negociações nesta temporada.';
  @override
  String get descEventoAllStar =>
      'Você não tem partida neste fim de semana. Aproveite para conferir a Classificação.';
  @override
  List<String> get nombresMeses => [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  @override
  List<String> get diasSemanaAbrev => ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
  @override
  String get simularUnPartido => 'Simular 1 partida';
  @override
  String get unaSemana => '1 semana';
  @override
  String get simularUnaSemana => 'Simular 1 semana';
  @override
  String get unMes => '1 mês';
  @override
  String get simularUnMes => 'Simular 1 mês';
  @override
  String get simularTemporadaEntera => 'Temporada inteira';
  @override
  String get verBracketCompleto => 'Ver chaveamento completo';
  @override
  String get empezarSiguienteTemporada => 'Começar a próxima temporada';
  @override
  String get simularPartidoDePlayoffs => 'Simular partida de playoffs';
  @override
  String get noClasificasteAPlayoffs =>
      'Você não se classificou para os playoffs nesta temporada.';
  @override
  String get simularPlayoffsCompletos => 'Simular playoffs completos';
  @override
  String get serieDecididaFaltaResto =>
      'Sua série está decidida — falta o resto do chaveamento para saber seu próximo adversário.';
  @override
  String get simularRestoDeRonda => 'Simular o restante da rodada';

  @override
  String ofertaTitulo(int n) =>
      n == 1 ? 'Você recebeu uma oferta' : 'Você tem ofertas';
  @override
  String ofertaMensaje(int n) => n == 1
      ? 'Um time perguntou sobre um dos seus jogadores e colocou uma proposta na mesa.'
      : '$n times perguntaram sobre seus jogadores.';
  @override
  String get masTarde => 'Mais tarde';
  @override
  String verOfertaBoton(int n) => n == 1 ? 'Ver a oferta' : 'Ver as ofertas';
  @override
  String get preguntaSeguirSimulando =>
      'Você chegou a este prazo final da temporada. Continua simulando ou para para fazer movimentações?';
  @override
  String get irAAgenciaLibre => 'Ir para Agência livre';
  @override
  String get irATraspasos => 'Ir para Negociações';
  @override
  String get seguirSimulando => 'Continuar simulando';
  @override
  String get allStarWeekendMayus => 'ALL STAR WEEKEND';
  @override
  String resultadoAllStar({
    required bool esteGana,
    required int local,
    required int visitante,
    String? mvp,
  }) =>
      'O All-Star Game foi disputado. ${esteGana ? "O Leste" : "O Oeste"} vence a partida por $local-$visitante.${mvp == null ? "" : "\n\nMVP da partida: $mvp."}';
  @override
  String get verFinDeSemana => 'Ver o fim de semana';
  @override
  String finalCupProgramada(String fecha) =>
      'Você está na Final da NBA Cup! Você joga em $fecha: simule até esse dia.';
  @override
  String fechaCorta(int dia, int mes) =>
      '$dia de ${nombresMeses[mes - 1].toLowerCase()}';

  @override
  String get sinPartidosTitulo => 'Nenhuma partida';
  @override
  String resumenPartidos(int n, int ganados, int perdidos) {
    final g = ganados;
    final p = perdidos;
    return '$n partidas · $g-$p';
  }

  @override
  String get lesionesActivasAhora => 'Lesões ativas neste momento';
  @override
  String get verLosPremios => 'Ver os prêmios';

  @override
  String get playoffsSeSiembranAlTerminar =>
      'Os playoffs são definidos quando sua temporada regular (82 partidas) termina.';
  @override
  String get verCelebracion => 'Ver a comemoração';
  @override
  String get siguienteTemporadaBtn => 'Próxima temporada';
  @override
  String get resolverPlayIn => 'Resolver o Play-in';
  @override
  String get simularRondaCompleta => 'Simular rodada completa';
  @override
  String get simularTodoBtn => 'Simular tudo';
  @override
  String get bracketTitulo => 'Chaveamento';
  @override
  String get primeraRondaEsperaPlayIn =>
      'A primeira rodada só começa depois que o Play-in decidir quem é o 7º e o 8º.';
  @override
  String get playInGanadorEntra7 => 'O vencedor entra como 7º';
  @override
  String get playInPerdedorEliminado => 'O perdedor é eliminado';
  @override
  String get playInGanadorEntra8 => 'O vencedor entra como 8º';
  @override
  String get conferenciaOesteTitulo => 'Conferência Oeste';
  @override
  String get conferenciaEsteTitulo => 'Conferência Leste';
  @override
  String get sinPlayIn => 'Sem play-in';
  @override
  String get jugarBtn => 'Jogar';
  @override
  String get porJugar => 'A disputar';
  @override
  String get rondaPrimeraRonda => 'Primeira rodada';
  @override
  String get rondaSemifinalConferencia => 'Semifinal de conferência';
  @override
  String get rondaFinalConferencia => 'Final de conferência';
  @override
  String get rondaFinalNba => 'Finais da NBA';
  @override
  List<String> get nombresDeRondaBracket => [
    'Primeira\nrodada',
    'Semifinais',
    'Final\nOeste',
    'FINAIS\nNBA',
    'Final\nLeste',
    'Semifinais',
    'Primeira\nrodada',
  ];
  @override
  String get esperandoAlPlayIn => 'Aguardando o Play-in';
  @override
  String get porDefinir => 'A definir';

  @override
  String despedirConfirmacion(String nombre) => 'Demitir $nombre?';
  @override
  String despedirConTiempoRestante(int anios, String importe) =>
      'Faltam $anios ${anios == 1 ? "temporada" : "temporadas"} de contrato e você tem que pagá-las de qualquer forma: $importe que você NÃO vai poder gastar com o substituto até elas terminarem.';
  @override
  String get despedirSinContrato =>
      'Ele ficará livre e poderá assinar com qualquer time. Até você contratar outro, seu time vai jogar sem técnico.';
  @override
  String get ficharPorElMinimoBtn => 'Contratar pelo mínimo';
  @override
  String get noHayEntrenadorSinEquipo => 'Não há nenhum técnico sem time';
  @override
  String get dirigiendoAOtroEquipo => 'Treinando outro time';
  @override
  String get sePuedeOfertarPeroTrabajo =>
      'Você pode fazer uma oferta, mas eles têm emprego: é preciso muito mais para convencê-los, e o time do qual você o tirar vai procurar um substituto na hora.';
  @override
  String get avisoObligatorioTexto =>
      'Você não pode jogar sem técnico. Contrate alguém para continuar: se ninguém te convencer ou o orçamento não permitir, você sempre pode contratar um pelo mínimo.';
  @override
  String mediaDeTuEquipoEs(int n) =>
      'A média do seu time é $n. Quanto melhor é um técnico, melhor projeto ele exige — e o dinheiro só cobre parte da diferença.';
  @override
  String pideAlAnioYTemporadas(String importe, int anios) =>
      'Pede $importe por ano e $anios temporadas.';
  @override
  String noLlegaMasaSalarial(String importe) =>
      'Sua folha salarial não é suficiente: você só pode oferecer $importe.';
  @override
  String get tuEntrenadorLabel => 'Seu técnico';
  @override
  String get masaSalarialConBanquillo =>
      'Folha salarial (com comissão técnica)';
  @override
  String get porEncimaDelTopeSoloMinimo =>
      'Você está acima do teto: só pode contratar pelo salário mínimo.';
  @override
  String get sueldoEntrenadorCuentaEnMasa =>
      'O salário do técnico conta na sua folha salarial: o que você gastar aqui não sobra para os jogadores.';
  @override
  String contratoResumen(String importeAlAnio, String duracion) =>
      '$importeAlAnio · contrato de $duracion';
  @override
  String trayectoriaEstaTemporada(int victorias, int derrotas) =>
      'Esta temporada: $victorias-$derrotas';
  @override
  String temporadasDirigiendo(int n) => '$n temporadas treinando';
  @override
  String anillos(int n) => n == 1 ? '1 anel' : '$n anéis';
  @override
  String entrenadorDelAnio(int n) =>
      n == 1 ? '1 vez Técnico do Ano' : '$n vezes Técnico do Ano';
  @override
  String dirigeAEquipo(String apodo) => 'Treina o $apodo';
  @override
  String pideImportePorAnios(String importe, int anios) =>
      'Pede $importe × $anios ${anios == 1 ? "ano" : "anos"}';
  @override
  String get noCabeEnPresupuesto =>
      'Não cabe no seu orçamento de comissão técnica';
  @override
  String get proyectoLeQuedaLejos => 'Seu projeto está longe do que ele quer';
  @override
  String get asuPrecioNo =>
      'No preço que ele pede, diria não; com mais dinheiro, talvez';
  @override
  String get volver => 'Voltar';
  @override
  String get elegirEsteEquipo => 'Escolher este time';

  @override
  String mediaDelEquipo(int n) => 'Média do time: $n';
  @override
  String get torneoDeMitadDeTemporada => 'Torneio de meio de temporada';
  @override
  String get campeonNba => 'Campeão da NBA';

  @override
  String descripcionHueco(bool esTitular, String nombrePosicion) =>
      esTitular ? 'titular de $nombrePosicion' : 'reserva de $nombrePosicion';
  @override
  String get tituloTitular => 'Titular';
  @override
  String get tituloSuplente => 'Reserva';
  @override
  Map<String, String> get nombresDePosiciones => {
    'PG': 'Armador (PG)',
    'SG': 'Ala-armador (SG)',
    'SF': 'Ala (SF)',
    'PF': 'Ala-pivô (PF)',
    'C': 'Pivô (C)',
  };
  @override
  String get minutosTitularLabel => 'Minutos do titular: ';
  @override
  String fueraPorLesion(String nombres) => 'Fora por lesão: $nombres';
  @override
  String get alinearAutomaticamenteBtn => 'Escalar automaticamente';
  @override
  String get pestanaAlineacion => 'Escalação';
  @override
  String get pestanaEstadisticas => 'Estatísticas';
  @override
  String get tusPicksDeDraft => 'Suas escolhas de draft';
  @override
  String get empezarTemporadaBtn => 'Começar temporada';
  @override
  String get guardarRotacionBtn => 'Salvar escalação';
  @override
  String get elegirJugadorPlaceholder => '— escolher jogador —';
  @override
  String lesionConDetalle(String motivo, int partidos, String fecha) =>
      '$motivo ($partidos partidas) — volta em $fecha — o reserva vai jogar enquanto isso';
  @override
  String get fueraDeSusDosPosiciones =>
      'Fora das suas duas posições (vai render um pouco pior)';
  @override
  String get sinPartidosJugadosTemporada =>
      'Sem partidas disputadas nesta temporada';
  @override
  String get estrellaAtaqueLabel => 'Estrela do ataque';
  @override
  String get estrellaDefensaLabel => 'Estrela da defesa';
  @override
  String get sextoHombreLabel => 'Sexto homem';
  @override
  String get ningunaOpcion => 'Nenhuma';
  @override
  String get faltaAlineacionAviso =>
      "Completa o cinco: cada posição precisa de titular e suplente.";
  @override
  String get faltanRolesAviso =>
      "Falta escolher a estrela de ataque, a de defesa e o sexto homem.";
  @override
  String get sinPicksPropios =>
      'Você não tem mais nenhuma escolha própria: negociou todas.';
  @override
  String get traspasadoATiPorOtroEquipo => 'Negociado para você por outro time';
  @override
  String get quintetoInicial => 'Quinteto titular';
  @override
  String get rotacionCompleta => 'Rotação completa';

  @override
  String nombreConPosicionYMedia(String nombre, String posicion, int media) =>
      '$nombre ($posicion, nível $media)';
  @override
  String yaAsignadoIntercambio(String descripcionHueco) =>
      'atualmente $descripcionHueco — eles vão trocar de lugar';
  @override
  String get tituloTusPicksDeDraft => 'Suas escolhas de draft';

  @override
  String lesionSimple(String motivo, String fecha) =>
      '$motivo, volta em $fecha';

  @override
  String get rechazar => 'Recusar';
  @override
  String get proponer => 'Propor';
  @override
  String get tituloAgenciaLibre => 'Agência livre';
  @override
  String get verTuPlantilla => 'Ver seu elenco';
  @override
  String get agenciaLibreCerrada =>
      'A agência livre fechou por esta temporada: o prazo já passou. Você pode continuar olhando o mercado, mas não pode contratar até o ano que vem.';
  @override
  String get completarConContratosMinimos => 'Completar com contratos mínimos';
  @override
  String get plantillaCompletada => 'Elenco completado.';
  @override
  String fichadosPorElMinimo(int n) => 'Contratados $n jogadores pelo mínimo.';
  @override
  String get quePuedaPagar => 'Acessível';
  @override
  String get noQuedaNadieEnMercado => 'Não sobrou ninguém no mercado.';
  @override
  String get nadieEncajaConFiltro =>
      'Ninguém no mercado combina com o que você pediu. Tente remover algum filtro.';
  @override
  String contadorAgentesLibres(int n) => '$n agentes livres';
  @override
  String contadorAgentesLibresFiltrado(int visibles, int total) =>
      '$visibles de $total agentes livres (há filtros aplicados)';
  @override
  String get empezarLaTemporadaBtn => 'Começar a temporada';
  @override
  String get completaLaPlantillaParaContinuar =>
      'Complete o elenco para continuar';
  @override
  String plantillaAlCompletoConN(int n) => 'Elenco completo: $n jogadores.';
  @override
  String plantillaDeMax(int n, int max) => 'Elenco: $n de $max jogadores.';
  @override
  String faltanFichajesParaMinimo(int n) =>
      'Faltam $n contratações para o mínimo.';
  @override
  String otrosEquiposJuegan(int max, int n, int atras) =>
      'Os outros 29 times jogam com $max. Com $n você pode começar, mas está $atras atrás.';
  @override
  String sinRecambioEn(String lista) => 'Sem reserva em: $lista.';
  @override
  String libresBajoElTope(String cantidad) =>
      '$cantidad livres abaixo do teto.';
  @override
  String get yaNoNegocia => 'Não negocia mais';
  @override
  String negociarConN(int n) => 'Negociar ($n)';
  @override
  String ofertaA(String nombre) => 'Oferta a $nombre';
  @override
  String pideAlAnio(String cantidad) => 'Pede $cantidad por ano';
  @override
  String sueldoLabel(String cantidad) => 'Salário: $cantidad';
  @override
  String get insultoOferta => 'Ele vai levar isso como um insulto.';
  @override
  String get ofertaImprobable =>
      'Muito improvável que ele aceite assim: o salário, os anos ou ambos estão curtos.';
  @override
  String get ofertaSePuedePensar =>
      'Ele pode pensar; não está totalmente convencido.';
  @override
  String get ofertaProbableAceptar => 'É provável que aceite.';
  @override
  String get ofertaSeguraAceptar => 'Praticamente certo que ele vai aceitar.';
  @override
  String get aniosLabelDosPuntos => 'Anos: ';
  @override
  String get tituloRenovaciones => 'Renovações';
  @override
  String get ningunContratoSeAcaba =>
      'Nenhum contrato está vencendo: seu elenco continua amarrado por mais um ano.';
  @override
  String continuarConNAgenciaLibre(int n) =>
      'Continuar ($n vão para a agência livre)';
  @override
  String porEncimaDelTope(String cantidad) =>
      'Você está $cantidad acima do teto: só pode oferecer contratos mínimos.';
  @override
  String teQuedanBajoElTope(String espacio, String tope) =>
      'Restam $espacio abaixo do teto de $tope.';
  @override
  String get seAcaboLaNegociacion => 'A negociação\nacabou';
  @override
  String ofrecerConN(int n) => 'Oferecer ($n)';
  @override
  String get cerramosElTraspaso => 'Fechamos a troca?';
  @override
  String seVanYLlegan(String piden, String ofrecen) =>
      'Saem $piden e chegam $ofrecen.';
  @override
  String get tituloOfertasRecibidasScreen => 'Ofertas recebidas';
  @override
  String get nadieTePideNadaAhora =>
      'No momento ninguém te propôs nada. Continue simulando: as ofertas chegam durante a temporada.';
  @override
  String get ofertaAnterior => 'Oferta anterior';
  @override
  String get ofertaSiguiente => 'Próxima oferta';
  @override
  String ofertaNDeM(int n, int m) => 'Oferta $n de $m';
  @override
  String lineaJugadorOferta(
    String nombre,
    String posicion,
    int media,
    String contrato,
  ) => '$nombre · $posicion · $media · $contrato';
  @override
  String aniosDeContrato(int n) => n == 1 ? '1 ano' : '$n anos';
  @override
  String contratoAnioMillones(String anios, String millones) =>
      '$anios · $millones por ano';
  @override
  String get tePiden => 'Pedem de você';
  @override
  String get teOfrecen => 'Oferecem a você';
  @override
  String get contraofertar => 'Contraproposta';
  @override
  String get teVasAQuedarCorto => 'Você vai ficar apertado';
  @override
  String avisoLoCierras(String aviso) => '$aviso\n\nFecha mesmo assim?';
  @override
  String get mejorNo => 'Melhor não';
  @override
  String get cerrarloIgual => 'Fechar mesmo assim';
  @override
  String get traspasoCerradoSimple => 'Troca concluída.';
  @override
  String get fechaLimiteTraspasosNoMasOperaciones =>
      'O prazo de trocas já passou: não é possível fechar mais negócios nesta temporada.';
  @override
  String quienSeLlevaA(String nombre) => 'Quem levaria $nombre?';
  @override
  String quienSeLlevaPaquete(int n) => 'Quem levaria o pacote de $n peças?';
  @override
  String get ningunEquipoTeDariaNada =>
      'Nenhum time te daria algo que valha a pena em troca.';
  @override
  String get noTienesConQueConvencer =>
      'Você não tem com o que convencê-los: nem seu elenco nem suas escolhas chegam lá sem te destruir.';
  @override
  String get tituloTraspasos => 'Trocas';
  @override
  String get fechaLimiteTraspasosBanner =>
      'O prazo de trocas já passou nesta temporada: você pode continuar olhando o mercado, mas não pode fechar nada até o ano que vem.';
  @override
  String get noCuadraMeteATercero => 'Não fecha? Coloque um terceiro time';
  @override
  String get cerrarTraspasoBtn => 'Fechar troca';
  @override
  String get tuEquipoLabel => 'Seu time';
  @override
  String get tercerEquipoLabel => 'Terceiro time';
  @override
  String get rivalLabel => 'Adversário';
  @override
  String get buscarQuienCompraria => 'Buscar quem compraria';
  @override
  String get buscarQueDarPorEl => 'Buscar o que seria preciso dar por ele';
  @override
  String anadirDe(String equipo) => 'Adicionar de $equipo';
  @override
  String get eleccionesDeDraft => 'Escolhas de draft';
  @override
  String get yaHasPuestoTodo =>
      'Você já colocou na mesa tudo que este time tinha disponível.';
  @override
  String get sacarDeLaOperacion => 'Tirar da negociação';
  @override
  String get noCuadraMeteATerceroLarga =>
      'Não fecha?\nColoque um terceiro time';
  @override
  String get anadirEquipoBtn => 'Adicionar time';
  @override
  String get tocaParaElegirJugadoresOPicks =>
      'Toque para escolher\njogadores ou picks';

  @override
  String get mercadoCerradoNoSeBuscan =>
      'O mercado está fechado: o prazo de trocas já passou. Não é possível buscar negócios até o ano que vem.';
  @override
  String get tituloLegado => 'Legado';
  @override
  String get explicacionPuntuacionCarreraTooltip =>
      'O que significa a pontuação de carreira';
  @override
  String get hallOfFame => 'Hall of Fame';
  @override
  String get pestanaCamisetasRetiradas => 'Camisas aposentadas';
  @override
  String get pestanaLideresHistoricos => 'Líderes históricos';
  @override
  String get camisetaRetiradaSingular => 'Camisa aposentada';
  @override
  String get unDorsalQueNoVolvera => 'Um número que nunca mais será usado';
  @override
  String get dorsalesQueNoVolveran => 'Números que nunca mais serão usados';
  @override
  String get tituloPartidosDeLaSerie => 'Jogos da série';
  @override
  String partidoNMarcador(
    int n,
    String local,
    int marcadorLocal,
    int marcadorVisitante,
    String visitante,
  ) => 'Jogo $n: $local $marcadorLocal - $marcadorVisitante $visitante';
  @override
  String get unNuevoNombreHof => 'Um novo nome entra no Hall of Fame.';
  @override
  String nNombresNuevosHof(int n) => '$n novos nomes entram no Hall of Fame.';
  @override
  String entroEnAnio(int anio) => 'Entrou em $anio';
  @override
  String get queEsPuntuacionCarrera => 'O que é a pontuação de carreira?';
  @override
  String get explicacionPuntuacionCarreraTexto =>
      'Resume o que toda a carreira de um jogador rendeu, não um único número isolado:\n\n• Prêmios individuais (MVP, Melhor Defensor, quintetos, Novato do Ano, Mais Melhorou).\n• Anéis de campeão e títulos da NBA Cup.\n• O pico de nível que chegou a alcançar.\n• Os pontos, assistências e rebotes que acumulou, conforme quantas temporadas jogou.\n\nÉ preciso pelo menos 6 temporadas jogadas e superar um limite para entrar: um titular sólido sem prêmios não basta, precisa ter sido realmente importante.';
  @override
  String get entendido => 'Entendi';
  @override
  String noSePudoCargarHof(String error) =>
      'Não foi possível carregar o Hall of Fame.\n$error';
  @override
  String get todaviaNadieEnHof =>
      'Ainda não há ninguém no Hall of Fame. Só entram jogadores já aposentados com uma carreira das grandes: prêmios, anéis e muitos anos em bom nível.';
  @override
  String get nuevoChip => 'NOVO';

  @override
  String get enActivoLeyenda => 'Em atividade: ainda pode subir posições';
  @override
  String get todaviaNoHayEstadisticas =>
      'Ainda não há estatísticas para mostrar.';
  @override
  String noSePudieronCargarCamisetas(String error) =>
      'Não foi possível carregar as camisas aposentadas.\n$error';
  @override
  String get todaviaNoHayCamisetaEnLiga =>
      'Ainda não há nenhuma camisa aposentada na liga. Quando uma lenda se aposentar, você poderá homenageá-la.';
  @override
  String get franquiciaLabel => 'Franquia';
  @override
  String get todaLaLigaOpcion => 'Toda a liga';
  @override
  String equipoTodaviaNoHaRetirado(String equipo) =>
      '$equipo ainda não aposentou nenhuma camisa.';
  @override
  String get tuEquipoBadge => 'SEU TIME';
  @override
  String get retiradaRealDeLaFranquicia => 'Aposentadoria real da franquia';
  @override
  String retiradaEnLaTemporada(String etiquetaTemporada) =>
      'Aposentada na $etiquetaTemporada';
  @override
  String nPartidos(int n) => n == 1 ? '1 jogo' : '$n jogos';
  @override
  String get enElVestuario => 'No vestiário';

  @override
  String get premioMvp => 'MVP';
  @override
  String get premioMejorDefensor => 'Melhor Defensor';
  @override
  String get premioRookieDelAno => 'Novato do Ano';
  @override
  String get premioMasMejorado => 'Jogador Mais Melhorou';
  @override
  String get premioPrimerQuinteto => 'Primeiro Quinteto';
  @override
  String get premioSegundoQuinteto => 'Segundo Quinteto';
  @override
  String get risingStars => 'Rising Stars';
  @override
  String premioMvpAllStar(String allStar) => 'MVP do $allStar';
  @override
  String premioMvpRisingStars(String risingStars) => 'MVP do $risingStars';
  @override
  String get tituloPremiosDeLaTemporada => 'Prêmios da temporada';
  @override
  String noSePudieronCargarPremios(String error) =>
      'Não foi possível carregar os prêmios.\n$error';
  @override
  String get verCalendarioBtn => 'Ver calendário';
  @override
  String statsPremioLinea(String pts, String ast, String reb) =>
      '$pts pts, $ast ast, $reb reb';

  @override
  String temporadaN(int n) => 'Temporada $n';
  @override
  String arrancaLaTemporada(int n, int anioInicio, int anioFin) =>
      'Começa a temporada $n ($anioInicio-$anioFin)';
  @override
  String get plantillaHaCambiadoAviso =>
      'Seu elenco mudou: revise antes do primeiro jogo — uma escalação automática já foi feita.';
  @override
  String get tusEleccionesDelDraft => 'Suas escolhas de draft';
  @override
  String get seRetiranDeTuEquipo => 'Se aposentam do seu time';
  @override
  String cuelgaLasBotasCon(int edad, int media) =>
      'Pendura as chuteiras aos $edad anos, com nível $media';
  @override
  String get hanDadoUnPasoAdelante => 'Deram um passo à frente';
  @override
  String get empiezanABajar => 'Começam a cair';
  @override
  String get topDelDraft => 'Top do draft';
  @override
  String get movimientosEnLaLiga => 'Movimentações na liga';
  @override
  String recibeA(String equipoA, String jugadorB, String posicionB) =>
      '$equipoA recebe $jugadorB ($posicionB)';
  @override
  String get tambienSeRetiran => 'Também se aposentam';
  @override
  String yNMas(int n) => 'e mais $n';
  @override
  String posicionMediaSeparador(String posicion, int media) =>
      '$posicion · nível $media · ';

  @override
  String camisetaDeXRetirada(String nombre) => 'Camisa de $nombre aposentada.';
  @override
  String get tituloSeRetiran => 'Se aposentam';
  @override
  String get estaTemporadaNoSeRetiraNadie =>
      'Ninguém se aposenta nesta temporada.';
  @override
  String get restoDeLaLiga => 'Resto da liga';
  @override
  String get suCamisetaYaRetiradaSola =>
      ' · sua camisa já foi aposentada sozinha (lenda real)';
  @override
  String get camisetaRetiradaSufijo => ' · camisa aposentada';

  @override
  String get tituloResultadoPartido => 'Resultado do jogo';
  @override
  String get columnaTotal => 'Total';
  @override
  String get columnaJugador => 'Jogador';
  @override
  String get columnaMin => 'Min';
  @override
  String get columnaPts => 'Pts';
  @override
  String get columnaAst => 'Ast';
  @override
  String get columnaReb => 'Reb';
  @override
  String get prefijoCuarto => 'Q';
  @override
  String get prefijoProrroga => 'P';

  @override
  String get ordenPotencial => 'Potencial';
  @override
  String get ordenMediaDesc => 'Nível ↓';
  @override
  String get ordenMediaAsc => 'Nível ↑';
  @override
  String get tituloDraft => 'Draft';
  @override
  String get eligiendoElRestoDeEquipos => 'Escolhendo o resto dos times...';
  @override
  String get queElijaLaCpuPorMi => 'Deixar a CPU escolher por mim';
  @override
  String get draftCompletado => 'Draft concluído';
  @override
  String eleccionNumero(int n) => 'Escolha número $n';
  @override
  String get teTocaElegir => 'Sua vez de escolher!';
  @override
  String get ordenarPorLabel => 'Ordenar por: ';

  @override
  String cuartosCopaSeSiembranAviso(String nbaCup) =>
      'As quartas de final da $nbaCup são definidas assim que a fase de grupos de toda a liga termina.';
  @override
  String get finalSeJuegaDesdeCalendarioAviso =>
      'A Final é jogada a partir do calendário: se você for finalista, ela aparece marcada como mais um dia da sua temporada.';
  @override
  String get cuartosDeFinalLabel => 'Quartas de final';
  @override
  String get semifinalLabel => 'Semifinal';
  @override
  String finalDeLaCopaLabel(String nbaCup) => 'Final da $nbaCup';
  @override
  String get cuartosRondaLabel => 'Quartas';
  @override
  String get finalRondaLabel => 'Final';
  @override
  String get pendienteLabel => 'Pendente';

  @override
  String get tituloResumenDeLaTemporada => 'Resumo da temporada';
  @override
  String noSePudoCargarResumen(String error) =>
      'Não foi possível carregar o resumo.\n$error';
  @override
  String temporadaConEtiqueta(String etiqueta) => 'Temporada $etiqueta';
  @override
  String get pestanaBalance => 'Balanço';
  @override
  String puestoEnConferencia(String conferencia) => 'Posição no $conferencia';
  @override
  String puestoValor(int puesto) => '#$puesto';
  @override
  String puestoEnLaLigaNota(int puesto) => '#$puesto da liga';
  @override
  String get puntosPorPartidoLabel => 'Pontos por jogo';
  @override
  String encajadosLabel(String valor) => 'sofridos $valor';
  @override
  String get diferenciaLabel => 'Diferença';
  @override
  String get porPartidoLabel => 'por jogo';
  @override
  String get mejorRachaLabel => 'Melhor sequência';
  @override
  String get victoriasSeguidasLabel => 'vitórias seguidas';
  @override
  String get peorRachaLabel => 'Pior sequência';
  @override
  String get derrotasSeguidasLabel => 'derrotas seguidas';
  @override
  String get mejorVictoriaLabel => 'Melhor vitória';
  @override
  String get peorDerrotaLabel => 'Pior derrota';
  @override
  String partidosJugadosVictoriasPct(int partidos, int pct) =>
      '$partidos jogos · $pct% de vitórias';
  @override
  String get todaviaNoHayClasificacion => 'Ainda não há classificação.';
  @override
  String get columnaPJ => 'JJ';
  @override
  String posicionMedia(String posicion, int media) =>
      '$posicion · nível $media';

  @override
  String get allStarSubtituloPendiente =>
      'Acontece na pausa de fevereiro. Simule até o fim de semana das estrelas para ver.';
  @override
  String get risingStarsSubtituloPendiente =>
      'Os melhores calouros contra os de segundo ano, no mesmo fim de semana.';
  @override
  String get votacionAbreCuandoRuedeBalonAviso =>
      'A votação abre quando a bola rolar. Conforme você for jogando rodadas, vai vendo quem está ganhando a vaga e por quantos votos.';
  @override
  String get verEstadisticasBtn => 'Ver estatísticas';
  @override
  String mvpConNombre(String nombre) => 'MVP · $nombre';
  @override
  String lineaMvpPtsAstReb(int pts, int ast, int reb) =>
      '$pts pts · $ast ast · $reb reb';
  @override
  String escrutadoPorcentaje(int pct) => 'Apurados $pct% dos votos...';
  @override
  String get recuentoCerradoAviso =>
      'Apuração encerrada: estes foram os escolhidos.';
  @override
  String votacionAbiertaConPorcentaje(int pct) =>
      'Votação aberta, com $pct% da temporada jogada. Continue simulando e os votos vão mudar.';
  @override
  String get votacionFinalLabel => 'Votação final';
  @override
  String get votacionDeAficionadosLabel => 'Votação dos torcedores';
  @override
  String conferenciaConNombre(String conferenciaLabel) =>
      'Conferência $conferenciaLabel';
  @override
  String get titularesLabel => 'Titulares';
  @override
  String get suplentesLabel => 'Reservas';
  @override
  String get seQuedanFueraLabel => 'Ficam de fora';
  @override
  String posicionValoracion(String posicion, String valoracion) =>
      '$posicion · avaliação de $valoracion';

  @override
  String get noLlegoACompletarNingunaTemporada =>
      'Nunca completou uma temporada com você.';
  @override
  String get tituloTrayectoria => 'Trajetória';
  @override
  String get tituloPalmares => 'Títulos e prêmios';
  @override
  String get noRetirarElDorsal => 'Não aposentar o número';
  @override
  String get retirarSuCamiseta => 'Aposentar a camisa';
  @override
  String get mvpFinalesCorto => 'MVP das Finais';
  @override
  String get mvpDeLasFinalesLabel => 'MVP das Finais';
  @override
  String quintetosAllNba(int n) => '$n quintetos All-NBA';
  @override
  String vecesConEtiqueta(int n, String etiqueta) => '$n $etiqueta';
  @override
  String copasGanadas(int n, String nbaCup) => '$n $nbaCup${n == 1 ? '' : 's'}';
  @override
  String get premioCampeonDeLaNba => 'Campeão da NBA';
  @override
  String get premioTercerQuinteto => 'Terceiro Quinteto';
  @override
  String get premioMaximoAnotador => 'Maior pontuador';
  @override
  String get premioMasMejoradoCorto => 'Mais Melhorou';
  @override
  String get sinTitulosNiPremiosCarreraNba =>
      'Sem títulos ou prêmios em sua carreira na NBA.';
  @override
  String get sinTitulosNiPremiosIndividuales =>
      'Sem títulos ou prêmios individuais.';
  @override
  String resumenCarreraTotales(int temporadas, String posicion, int partidos) =>
      '$temporadas temporadas · $posicion · $partidos jogos';
  @override
  String totalesCarreraLinea(String pts, String ast, String reb) =>
      'Totais: $pts pts · $ast ast · $reb reb';
  @override
  String temporadasPreviasAviso(int n) =>
      '$n delas antes de você assumir o comando: dessas não há estatísticas, as médias abaixo são da sua era.';
  @override
  String get antesDeTuPartidaTitulo => 'Antes da sua partida';
  @override
  String temporadasYaJugadasCuandoCogisteElEquipo(int n) =>
      '$n ${n == 1 ? 'temporada' : 'temporadas'} já jogadas quando você assumiu o time.';
  @override
  String get produccionDeReferenciaAviso =>
      'A produção de referência dele ao começar a partida. Daqueles anos não há estatísticas jogo a jogo.';
  @override
  String sinEstadisticasDeCarreraAviso(String nombre) =>
      'De $nombre não há estatísticas de carreira: é de uma época anterior à coberta pelos dados do jogo. O lugar dele na história existe, os números não.';
  @override
  String get suCarreraEnLaNbaReal => 'Sua carreira na NBA real';
  @override
  String conEquipoEnLaNbaReal(String equipo) => 'Com $equipo na NBA real';
  @override
  String temporadasPartidos(int temporadas, int partidos) =>
      '$temporadas temporadas · $partidos jogos';
  @override
  String rangoTemporadasPartidos(String desde, String hasta, int partidos) =>
      '$desde a $hasta · $partidos jogos';
  @override
  String rangoPartidos(String rango, int partidos) =>
      '$rango · $partidos jogos';
  @override
  String temporadaMinuscula(int n) => 'temporada $n';

  @override
  String get nadieTePropuestoNadaAhora =>
      'Ninguém propôs nada a você por enquanto';
  @override
  String get unEquipoQuiereAUnoDeTusJugadores =>
      'Um time quer um dos seus jogadores';
  @override
  String nEquiposHanPreguntado(int n) =>
      '$n times perguntaram sobre seus jogadores';
  @override
  String cuadroYResultadosDeLaCopa(String nbaCup) =>
      'Chaveamento e resultados da $nbaCup';
  @override
  String get seDesbloqueaAlTerminarFaseDeGrupos =>
      'Desbloqueia ao terminar a fase de grupos';
  @override
  String get premiosDeFinDeTemporadaSubtitulo => 'Prêmios de fim de temporada';
  @override
  String get seDesbloqueaAlTerminarTemporadaRegular =>
      'Desbloqueia ao terminar a temporada regular';
  @override
  String get bracketDeEliminatorias => 'Chaveamento eliminatório';
  @override
  String hallOfFameYCamisetasRetiradasSubtitulo(
    String hallOfFame,
    String camisetas,
  ) => '$hallOfFame e $camisetas';
  @override
  String get salarialLabel => 'Salarial';

  @override
  String get sigueDondeLoDejaste => 'Continue de onde parou';
  @override
  String get empiezaTuCarrera => 'Comece sua carreira';
  @override
  String get enQueRanuraQuieresEmpezar => 'Em qual slot você quer começar?';
  @override
  String get eligeLaPartidaQueQuieresCargar =>
      'Escolha a partida que você quer carregar';
  @override
  String get nuevaPartidaBtn => 'Nova partida';
  @override
  String get cargarPartidaBtn => 'Carregar partida';
  @override
  String sobrescribirLaPartidaN(int n) => 'Sobrescrever a partida $n?';
  @override
  String get sePerderaEnteraAviso =>
      'Esse slot já tem uma carreira em andamento e ela será perdida por completo: elencos, calendário e títulos. Isso não pode ser desfeito.';
  @override
  String get sobrescribirBtn => 'Sobrescrever';
  @override
  String get eligeTuEquipoTitulo => 'Escolha seu time';
  @override
  String borrarLaPartidaN(int n) => 'Apagar a partida $n?';
  @override
  String sePierdeCarreraDeAviso(String nombre) =>
      'Toda a carreira de $nombre será perdida: elencos, calendário, títulos, lendas e camisas aposentadas. Isso não pode ser desfeito.';
  @override
  String get borrarBtn => 'Apagar';
  @override
  String get lasTresRanurasOcupadasAviso =>
      'Os três slots estão ocupados: apague um para começar de novo, ou continue um dos que já tem.';
  @override
  String get ranuraDeVersionCompleta => 'Slot da versão completa';
  @override
  String partidaNumero(int n) => 'PARTIDA $n';
  @override
  String get borrarEstaPartidaTooltip => 'Apagar esta partida';
  @override
  String get ranuraVaciaLabel => 'Slot vazio';
  @override
  String get empezarBtn => 'Começar';

  @override
  String get lesionLabel => 'Lesão';
  @override
  String get recibesLabel => 'Você recebe: ';
  @override
  String get entregasLabel => 'Você entrega: ';
  @override
  String get traspasarBtn => 'Trocar';
  @override
  String get potencialElite => 'Elite';
  @override
  String get potencialMuyAlto => 'Muito alto';
  @override
  String get potencialAlto => 'Alto';
  @override
  String get potencialMedio => 'Médio';
  @override
  String get potencialBajo => 'Baixo';
  @override
  String potencialTooltip(String etiqueta) => 'Potencial: $etiqueta';
  @override
  String get volverAlMenuPrincipalTooltip => 'Voltar ao menu principal';
  @override
  String get volverAInicioTooltip => 'Voltar à tela inicial';

  @override
  String get margenSalarialEvento => 'Margem salarial';

  @override
  String get tuFranquiciaSeccion => 'A tua franquia';

  @override
  String get proximoPartidoTitulo => 'Próximo jogo';

  @override
  String get enCasaLabel => 'Em casa';

  @override
  String get fueraLabel => 'Fora';

  @override
  String get vsAbreviatura => 'VS';

  @override
  String get tituloPatrocinadores => 'Patrocinadores';
  @override
  String get explicacionPatrocinadores =>
      'Cada patrocínio tem várias propostas: quanto mais longo o contrato, menos paga por ano. O que assinares ocupa essa categoria até expirar.';
  @override
  String get patrocinioEstadioLabel => 'Patrocinador do ginásio';
  @override
  String get patrocinioCamisetaLabel => 'Patrocinador da camisa';
  @override
  String get patrocinioBebidaLabel => 'Patrocinador de alimentação e bebidas';
  @override
  String get patrocinioOcioLabel => 'Patrocinador de lazer';
  @override
  String fundadoEnAnio(int anio) => 'Fundada em $anio';
  @override
  String get alAnioSufijo => 'por ano';
  @override
  String sinPatrocinioFirmado(int ofertas) =>
      ofertas == 1 ? 'Sem assinar · 1 proposta' : 'Sem assinar ·  propostas';
  @override
  String margenPatrocinio(String importe) => '+$importe de margem salarial';
  @override
  String get patrocinadoresBloqueados =>
      'Os patrocinadores são da versão completa. Vê um vídeo e ficas com os quatro durante esta temporada.';
  @override
  String get verVideoPatrocinadores => 'VER VÍDEO E DESBLOQUEAR';
  @override
  String get videoSinTerminar =>
      'O vídeo não foi visto até ao fim, por isso continuam bloqueados. Podes tentar outra vez.';

  @override
  String get modoFranquiciaOpcion => 'Modo Franquia';
  @override
  String get modoCarreraOpcion => 'Modo Jogador';

  @override
  String get crearJugadorTitulo => 'Crie seu jogador';
  @override
  String get apellidoLabel => 'Sobrenome';
  @override
  String get dorsalLabel => 'Número';
  @override
  String get posicionLabel => 'Posição';
  @override
  String get nacionalidadLabel => 'Nacionalidade';
  @override
  String get confirmarIdentidadBtn => 'Confirmar identidade';

  @override
  String get ofertaJuvenilTitulo => 'Oferta de base';
  @override
  String get ofertaJuvenilDescripcion =>
      'Organizações de base do seu país querem te levar para o projeto delas. Escolha onde sua carreira começa.';
  @override
  String ficharPorBtn(String organizacion) => 'Assinar com $organizacion';

  @override
  String get avanzarTemporadaBtn => 'Avançar temporada';
  @override
  String get entrarAlDraftBtn => 'Entrar no draft';

  @override
  String get edadLabel => 'Idade';
  @override
  String get mediaLabel => 'Média';
  @override
  String get potencialLabel => 'Potencial';
  @override
  String get equipoActualLabel => 'Time';
  @override
  String get organizacionActualLabel => 'Organização';

  @override
  String get carreraRetiradaTitulo => 'Carreira encerrada';
  @override
  String draftResultadoMensaje(String equipo) =>
      'Você foi escolhido pelo $equipo.';
  @override
  String get entraEnHallDeLaFamaMensaje => 'Você entra no Hall da Fama!';
  @override
  String get noEntraEnHallDeLaFamaMensaje =>
      'Você não entra no Hall da Fama.';
  @override
  String seRetiraMensaje(int edad) => 'Se aposenta aos $edad anos.';
  @override
  String cambioDeEquipoMensaje(String equipo) => 'Novo time: $equipo.';
}
