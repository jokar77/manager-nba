part of 'textos.dart';

/// Castellano: el idioma en el que se escribió el juego, y el que se usa de
/// respaldo si un ajuste guardado trae un código raro.
class TextosEs extends Textos {
  const TextosEs();

  @override
  TextosDeEventos get eventos => const EventosEs();

  @override
  String get aceptar => 'Aceptar';
  @override
  String get cancelar => 'Cancelar';
  @override
  String get cerrar => 'Cerrar';
  @override
  String get guardar => 'Guardar';
  @override
  String get continuar => 'Continuar';
  @override
  String get si => 'Sí';
  @override
  String get no => 'No';
  @override
  String get cargando => 'Cargando…';

  @override
  String get nuevaPartida => 'Nueva partida';
  @override
  String get ajustes => 'Ajustes';
  @override
  String get elegirEquipo => 'Elige tu equipo';
  @override
  String get sobrescribir => 'Sobrescribir';
  @override
  String get ranuraOcupada => 'Esta ranura ya tiene una partida';
  @override
  String get avisoSobrescribir =>
      'Si sigues, se borrará la partida guardada aquí.';

  @override
  String get modoOscuro => 'Modo oscuro';
  @override
  String get modoOscuroDetalle => 'Grises y negros en vez de blancos claros';
  @override
  String get idioma => 'Idioma';
  @override
  String get idiomaDetalle => 'El idioma de todo el juego';

  @override
  String get calendario => 'Calendario';
  @override
  String get calendarioDetalle => 'Ve tu temporada y simula partidos';
  @override
  String get tuEquipo => 'Tu equipo';
  @override
  String get tuEquipoDetalle => 'Jugadores y alineación';
  @override
  String get entrenador => 'Entrenador';
  @override
  String get banquilloVacante => 'Tu banquillo está vacante';
  @override
  String get clasificacion => 'Clasificación';
  @override
  String get clasificacionDetalle => 'Equipos y líderes de estadísticas';
  @override
  String get mercado => 'Mercado';
  @override
  String get traspasos => 'Traspasos';
  @override
  String get traspasosDetalle => 'Negocia intercambios con el resto de la liga';
  @override
  String get ofertasRecibidas => 'Ofertas recibidas';
  @override
  String get agenciaLibre => 'Agencia libre';
  @override
  String get agenciaLibreDetalle => 'Jugadores sin equipo y espacio salarial';
  @override
  String get competicion => 'Competición';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Votación, partido de las estrellas y MVP';
  @override
  String get resumenTemporada => 'Resumen de la temporada';
  @override
  String get resumenTemporadaDetalle =>
      'Récord, todos tus partidos y promedios';
  @override
  String get playoffs => 'Playoffs';
  @override
  String get premios => 'Premios';
  @override
  String get legado => 'Legado';

  @override
  String get record => 'Récord';
  @override
  String get masaSalarial => 'Masa salarial';
  @override
  String get temporada => 'Temporada';

  @override
  String get sinEntrenador => 'Sin entrenador';
  @override
  String get sinEntrenadorDetalle =>
      'Tu equipo juega sin banquillo. Ficha a alguien de la lista de abajo.';
  @override
  String get despedir => 'Despedir';
  @override
  String get contratar => 'Contratar';
  @override
  String get negociar => 'Negociar';
  @override
  String get ofrecer => 'Ofrecer';
  @override
  String get sueldo => 'Sueldo';
  @override
  String get duracion => 'Duración';
  @override
  String get ataque => 'Ataque';
  @override
  String get defensa => 'Defensa';
  @override
  String get desarrollo => 'Desarrollo';
  @override
  String get equilibrado => 'Equilibrado';
  @override
  String get especialistaAtaque => 'Especialista en ataque';
  @override
  String get especialistaDefensa => 'Especialista en defensa';
  @override
  String get formadorDeJovenes => 'Formador de jóvenes';
  @override
  String get loQuePuedesOfrecer => 'Lo que puedes ofrecer';
  @override
  String get topeDeLaFranquicia => 'Tope de la franquicia';
  @override
  String get finiquitos => 'Finiquitos de despedidos';
  @override
  String get aceptariaLaOferta => 'Aceptaría esta oferta.';
  @override
  String get todaviaNo =>
      'Todavía no. Con más dinero o más años puede cambiar de idea.';
  @override
  String get noVaAAceptar =>
      'No va a aceptar: tu proyecto le queda lejos y el dinero no lo arregla.';

  @override
  String anios(int n) => n == 1 ? '1 temporada' : '$n temporadas';
  @override
  String alAnio(String importe) => '$importe al año';

  @override
  String get pestanaEquipos => 'Equipos';
  @override
  String get pestanaJugadores => 'Jugadores';
  @override
  String get conferenciaEste => 'Este';
  @override
  String get conferenciaOeste => 'Oeste';
  @override
  String get fronteraPlayIn => 'Play-In';
  @override
  String get fronteraFueraDePlayoffs => 'Fuera de playoffs';
  @override
  String get ordenPuntos => 'Puntos';
  @override
  String get ordenAsistencias => 'Asistencias';
  @override
  String get ordenRebotes => 'Rebotes';
  @override
  String get sinPartidosJugados => 'Todavía no se ha jugado ningún partido';
  @override
  String edadJugador(int n) => '$n años';
  @override
  String mediaJugador(int n) => 'Media $n';
  @override
  String get estaTemporada => 'Esta temporada';
  @override
  String get todaviaNoHaJugado => 'Todavía no ha jugado';
  @override
  String get contrato => 'Contrato';
  @override
  String get intentarTraspasar => 'Intentar traspasar';
  @override
  String traspasoCerradoCon(String equipo) => 'Traspaso cerrado con $equipo.';
  @override
  String get fechaLimiteTraspasosPasada =>
      'Ya ha pasado la fecha límite de traspasos: no se pueden cerrar más operaciones esta temporada.';

  @override
  String get tituloConferenciaEste => 'CONFERENCIA ESTE';
  @override
  String get tituloConferenciaOeste => 'CONFERENCIA OESTE';

  @override
  String comoFicharA(String nombre) => '¿Cómo fichar a $nombre?';
  @override
  String get sinConQueConvencerles =>
      'No tienes con qué convencerles ahora mismo: ni tu plantilla ni tus picks les llegan sin dejarte roto.';

  @override
  String get campeonesDeLaNba => 'Campeones de la NBA';
  @override
  String get campeonesDeLaCup => 'Campeones de la NBA Cup';
  @override
  String get exclamacionCampeones => '¡CAMPEONES!';
  @override
  String seLlevaElTitulo(String nombre) => '$nombre se lleva el título.';
  @override
  String get enhorabuenaAnillo =>
      '¡Enhorabuena! Lo has conseguido: el anillo es vuestro. La próxima temporada toca defenderlo.';
  @override
  String get enhorabuenaCup =>
      '¡Enhorabuena! Habéis ganado la NBA Cup. El anillo es otra historia: la temporada sigue.';
  @override
  String get aCelebrarlo => '¡A celebrarlo!';
  @override
  String mvpDeLasFinales(String nombre) => 'MVP de las Finales · $nombre';
  @override
  String partidosDeSerie(int n) => n == 1 ? 'en 1 partido' : 'en $n partidos';
  @override
  String get verEstadisticas => 'Ver estadísticas';
  @override
  String get confirmarSimularTitulo => '¿Simular hasta este día?';
  @override
  String get seJugaraProximoPartido => 'Se jugará tu próximo partido.';
  @override
  String seJugaranDeUnaVez(int partidos, int dia, int mes) =>
      'Se jugarán de una vez los $partidos partidos que te quedan hasta el $dia/$mes.';
  @override
  String get simular => 'Simular';
  @override
  String finalCupVs(String enfrentamiento) => 'Final NBA Cup — $enfrentamiento';
  @override
  String get tituloEventoFinAgenciaLibre => 'Fin de la agencia libre';
  @override
  String get tituloEventoFechaLimiteTraspasos => 'Fecha límite de traspasos';
  @override
  String get tituloEventoAllStar => 'Fin de semana de las estrellas';
  @override
  String get descEventoFinAgenciaLibre =>
      'A partir de aquí ya no se puede fichar agentes libres.';
  @override
  String get descEventoFechaLimiteTraspasos =>
      'Último día para hacer traspasos esta temporada.';
  @override
  String get descEventoAllStar =>
      'No hay partido tuyo este fin de semana. Aprovecha para revisar la Clasificación.';
  @override
  List<String> get nombresMeses => [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  @override
  List<String> get diasSemanaAbrev => ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  @override
  String get simularUnPartido => 'Simular 1 partido';
  @override
  String get unaSemana => '1 semana';
  @override
  String get simularUnaSemana => 'Simular 1 semana';
  @override
  String get unMes => '1 mes';
  @override
  String get simularUnMes => 'Simular 1 mes';
  @override
  String get simularTemporadaEntera => 'Temporada entera';
  @override
  String get verBracketCompleto => 'Ver bracket completo';
  @override
  String get empezarSiguienteTemporada => 'Empezar la siguiente temporada';
  @override
  String get simularPartidoDePlayoffs => 'Simular partido de playoffs';
  @override
  String get noClasificasteAPlayoffs =>
      'No clasificaste a los playoffs esta temporada.';
  @override
  String get simularPlayoffsCompletos => 'Simular playoffs completos';
  @override
  String get serieDecididaFaltaResto =>
      'Tu serie está decidida — falta el resto del bracket para saber tu próximo rival.';
  @override
  String get simularRestoDeRonda => 'Simular el resto de la ronda';

  @override
  String ofertaTitulo(int n) =>
      n == 1 ? 'Te ha llegado una oferta' : 'Tienes ofertas';
  @override
  String ofertaMensaje(int n) => n == 1
      ? 'Un equipo ha preguntado por uno de tus jugadores y te ha puesto una propuesta sobre la mesa.'
      : 'Hay $n equipos que han preguntado por jugadores tuyos.';
  @override
  String get masTarde => 'Más tarde';
  @override
  String verOfertaBoton(int n) => n == 1 ? 'Ver la oferta' : 'Ver las ofertas';
  @override
  String get preguntaSeguirSimulando =>
      'Has llegado a esta fecha límite de la temporada. ¿Sigues simulando o paras para hacer movimientos?';
  @override
  String get irAAgenciaLibre => 'Ir a Agencia libre';
  @override
  String get irATraspasos => 'Ir a Traspasos';
  @override
  String get seguirSimulando => 'Seguir simulando';
  @override
  String get allStarWeekendMayus => 'ALL STAR WEEKEND';
  @override
  String resultadoAllStar({
    required bool esteGana,
    required int local,
    required int visitante,
    String? mvp,
  }) =>
      'Se ha jugado el All-Star. ${esteGana ? "El Este" : "El Oeste"} se lleva el partido por $local-$visitante.${mvp == null ? "" : "\n\nMVP del partido: $mvp."}';
  @override
  String get verFinDeSemana => 'Ver el fin de semana';
  @override
  String finalCupProgramada(String fecha) =>
      '¡A la Final de la NBA Cup! La juegas el $fecha: simula hasta ese día.';
  @override
  String fechaCorta(int dia, int mes) =>
      '$dia de ${nombresMeses[mes - 1].toLowerCase()}';

  @override
  String get sinPartidosTitulo => 'Sin partidos';
  @override
  String resumenPartidos(int n, int ganados, int perdidos) {
    final g = ganados;
    final p = perdidos;
    return '$n partidos · $g-$p';
  }

  @override
  String get lesionesActivasAhora => 'Lesiones activas ahora mismo';
  @override
  String get verLosPremios => 'Ver los premios';

  @override
  String get playoffsSeSiembranAlTerminar =>
      'Los playoffs se siembran al terminar tu temporada regular (82 partidos).';
  @override
  String get verCelebracion => 'Ver celebración';
  @override
  String get siguienteTemporadaBtn => 'Siguiente temporada';
  @override
  String get resolverPlayIn => 'Resolver el Play-In';
  @override
  String get simularRondaCompleta => 'Simular ronda completa';
  @override
  String get simularTodoBtn => 'Simular todo';
  @override
  String get bracketTitulo => 'Bracket';
  @override
  String get primeraRondaEsperaPlayIn =>
      'La primera ronda no empieza hasta que el Play-In decida quién es el 7 y el 8.';
  @override
  String get playInGanadorEntra7 => 'El ganador entra como 7';
  @override
  String get playInPerdedorEliminado => 'El perdedor queda eliminado';
  @override
  String get playInGanadorEntra8 => 'El ganador entra como 8';
  @override
  String get conferenciaOesteTitulo => 'Conferencia Oeste';
  @override
  String get conferenciaEsteTitulo => 'Conferencia Este';
  @override
  String get sinPlayIn => 'Sin play-in';
  @override
  String get jugarBtn => 'Jugar';
  @override
  String get porJugar => 'Por jugar';
  @override
  String get rondaPrimeraRonda => 'Primera ronda';
  @override
  String get rondaSemifinalConferencia => 'Semifinal de conferencia';
  @override
  String get rondaFinalConferencia => 'Final de conferencia';
  @override
  String get rondaFinalNba => 'Final NBA';
  @override
  List<String> get nombresDeRondaBracket => [
    'Primera\nronda',
    'Semifinales',
    'Final\nOeste',
    'FINAL\nNBA',
    'Final\nEste',
    'Semifinales',
    'Primera\nronda',
  ];
  @override
  String get esperandoAlPlayIn => 'Esperando al Play-In';
  @override
  String get porDefinir => 'Por definir';

  @override
  String despedirConfirmacion(String nombre) => '¿Despedir a $nombre?';
  @override
  String despedirConTiempoRestante(int anios, String importe) =>
      'Le quedan $anios ${anios == 1 ? "temporada" : "temporadas"} de contrato y hay que pagárselas igual: $importe que NO podrás gastarte en su sustituto hasta que se cumplan.';
  @override
  String get despedirSinContrato =>
      'Se quedará libre y podrá firmar por cualquier equipo. Hasta que fiches a otro, tu equipo jugará sin entrenador.';
  @override
  String get ficharPorElMinimoBtn => 'Fichar por el mínimo';
  @override
  String get noHayEntrenadorSinEquipo => 'No hay ningún entrenador sin equipo';
  @override
  String get dirigiendoAOtroEquipo => 'Dirigiendo a otro equipo';
  @override
  String get sePuedeOfertarPeroTrabajo =>
      'Se les puede hacer una oferta, pero tienen trabajo: hace falta bastante más para convencerles, y el equipo al que se lo quites buscará sustituto en el acto.';
  @override
  String get avisoObligatorioTexto =>
      'No puedes jugar sin entrenador. Ficha a alguien para seguir: si no te convence nadie o no te llega el presupuesto, siempre puedes firmar a uno por el mínimo.';
  @override
  String mediaDeTuEquipoEs(int n) =>
      'La media de tu equipo es $n. Cuanto mejor es un entrenador, mejor proyecto pide — y el dinero solo tapa parte de la diferencia.';
  @override
  String pideAlAnioYTemporadas(String importe, int anios) =>
      'Pide $importe al año y $anios temporadas.';
  @override
  String noLlegaMasaSalarial(String importe) =>
      'No te llega la masa salarial: solo puedes ofrecer $importe.';
  @override
  String get tuEntrenadorLabel => 'Tu entrenador';
  @override
  String get masaSalarialConBanquillo => 'Masa salarial (con banquillo)';
  @override
  String get porEncimaDelTopeSoloMinimo =>
      'Estás por encima del tope: solo puedes firmar por el sueldo mínimo.';
  @override
  String get sueldoEntrenadorCuentaEnMasa =>
      'El sueldo del entrenador cuenta en tu masa salarial: lo que gastes aquí no lo tienes para jugadores.';
  @override
  String contratoResumen(String importeAlAnio, String duracion) =>
      '$importeAlAnio · $duracion de contrato';
  @override
  String trayectoriaEstaTemporada(int victorias, int derrotas) =>
      'Esta temporada: $victorias-$derrotas';
  @override
  String temporadasDirigiendo(int n) => '$n temporadas dirigiendo';
  @override
  String anillos(int n) => n == 1 ? '1 anillo' : '$n anillos';
  @override
  String entrenadorDelAnio(int n) =>
      n == 1 ? '1 Entrenador del Año' : '$n veces Entrenador del Año';
  @override
  String dirigeAEquipo(String apodo) => 'Dirige a $apodo';
  @override
  String pideImportePorAnios(String importe, int anios) =>
      'Pide $importe × $anios ${anios == 1 ? "año" : "años"}';
  @override
  String get noCabeEnPresupuesto => 'No te cabe en el presupuesto de banquillo';
  @override
  String get proyectoLeQuedaLejos => 'Tu proyecto le queda lejos';
  @override
  String get asuPrecioNo => 'A su precio diría que no; con más dinero, quizá';
  @override
  String get volver => 'Volver';
  @override
  String get elegirEsteEquipo => 'Elegir este equipo';

  @override
  String mediaDelEquipo(int n) => 'Media del equipo: $n';
  @override
  String get torneoDeMitadDeTemporada => 'Torneo de mitad de temporada';
  @override
  String get campeonNba => 'Campeón NBA';

  @override
  String descripcionHueco(bool esTitular, String nombrePosicion) =>
      esTitular ? 'titular de $nombrePosicion' : 'suplente de $nombrePosicion';
  @override
  String get tituloTitular => 'Titular';
  @override
  String get tituloSuplente => 'Suplente';
  @override
  Map<String, String> get nombresDePosiciones => {
    'PG': 'Base (PG)',
    'SG': 'Escolta (SG)',
    'SF': 'Alero (SF)',
    'PF': 'Ala-pívot (PF)',
    'C': 'Pívot (C)',
  };
  @override
  String get minutosTitularLabel => 'Minutos titular: ';
  @override
  String fueraPorLesion(String nombres) => 'Fuera por lesión: $nombres';
  @override
  String get alinearAutomaticamenteBtn => 'Alinear automáticamente';
  @override
  String get pestanaAlineacion => 'Alineación';
  @override
  String get pestanaEstadisticas => 'Estadísticas';
  @override
  String get tusPicksDeDraft => 'Tus picks de draft';
  @override
  String get empezarTemporadaBtn => 'Empezar temporada';
  @override
  String get guardarRotacionBtn => 'Guardar rotación';
  @override
  String get elegirJugadorPlaceholder => '— elegir jugador —';
  @override
  String lesionConDetalle(String motivo, int partidos, String fecha) =>
      '$motivo ($partidos partidos) — vuelve el $fecha — jugará el suplente mientras tanto';
  @override
  String get fueraDeSusDosPosiciones =>
      'Fuera de sus dos posiciones (rendirá algo peor)';
  @override
  String get sinPartidosJugadosTemporada =>
      'Sin partidos jugados esta temporada';
  @override
  String get estrellaAtaqueLabel => 'Estrella ataque';
  @override
  String get estrellaDefensaLabel => 'Estrella defensa';
  @override
  String get sextoHombreLabel => 'Sexto hombre';
  @override
  String get ningunaOpcion => 'Ninguna';
  @override
  String get faltaAlineacionAviso =>
      "Completa la alineación: cada puesto necesita titular y suplente.";
  @override
  String get faltanRolesAviso =>
      "Te falta elegir la estrella de ataque, la de defensa y el sexto hombre.";
  @override
  String get sinPicksPropios =>
      'No te queda ninguna elección propia: las has traspasado todas.';
  @override
  String get traspasadoATiPorOtroEquipo => 'Traspasado a ti por otro equipo';
  @override
  String get quintetoInicial => 'Quinteto inicial';
  @override
  String get rotacionCompleta => 'Rotación completa';

  @override
  String nombreConPosicionYMedia(String nombre, String posicion, int media) =>
      '$nombre ($posicion, media $media)';
  @override
  String yaAsignadoIntercambio(String descripcionHueco) =>
      'ahora $descripcionHueco — se intercambian';
  @override
  String get tituloTusPicksDeDraft => 'Tus picks de draft';

  @override
  String lesionSimple(String motivo, String fecha) =>
      '$motivo, vuelve el $fecha';

  @override
  String get rechazar => 'Rechazar';
  @override
  String get proponer => 'Proponer';
  @override
  String get tituloAgenciaLibre => 'Agencia libre';
  @override
  String get verTuPlantilla => 'Ver tu plantilla';
  @override
  String get agenciaLibreCerrada =>
      'La agencia libre ha cerrado por esta temporada: ya se pasó la fecha límite. Puedes seguir mirando el mercado, pero no fichar hasta el año que viene.';
  @override
  String get completarConContratosMinimos => 'Completar con contratos mínimos';
  @override
  String get plantillaCompletada => 'Plantilla completada.';
  @override
  String fichadosPorElMinimo(int n) => 'Fichados $n jugadores por el mínimo.';
  @override
  String get quePuedaPagar => 'Asequible';
  @override
  String get noQuedaNadieEnMercado => 'No queda nadie en el mercado.';
  @override
  String get nadieEncajaConFiltro =>
      'Nadie del mercado encaja con lo que has pedido. Prueba a quitar algún filtro.';
  @override
  String contadorAgentesLibres(int n) => '$n agentes libres';
  @override
  String contadorAgentesLibresFiltrado(int visibles, int total) =>
      '$visibles de $total agentes libres (hay filtros puestos)';
  @override
  String get empezarLaTemporadaBtn => 'Empezar la temporada';
  @override
  String get completaLaPlantillaParaContinuar =>
      'Completa la plantilla para continuar';
  @override
  String plantillaAlCompletoConN(int n) =>
      'Plantilla al completo: $n jugadores.';
  @override
  String plantillaDeMax(int n, int max) => 'Plantilla: $n de $max jugadores.';
  @override
  String faltanFichajesParaMinimo(int n) =>
      'Faltan $n fichajes para el mínimo.';
  @override
  String otrosEquiposJuegan(int max, int n, int atras) =>
      'Los otros 29 equipos juegan con $max. Con $n puedes empezar, pero vas $atras por detrás.';
  @override
  String sinRecambioEn(String lista) => 'Sin recambio en: $lista.';
  @override
  String libresBajoElTope(String cantidad) => '$cantidad libres bajo el tope.';
  @override
  String get yaNoNegocia => 'Ya no negocia';
  @override
  String negociarConN(int n) => 'Negociar ($n)';
  @override
  String ofertaA(String nombre) => 'Oferta a $nombre';
  @override
  String pideAlAnio(String cantidad) => 'Pide $cantidad al año';
  @override
  String sueldoLabel(String cantidad) => 'Sueldo: $cantidad';
  @override
  String get insultoOferta => 'Se lo va a tomar como un insulto.';
  @override
  String get ofertaImprobable =>
      'Muy improbable que la acepte así: el sueldo, los años o ambos se quedan cortos.';
  @override
  String get ofertaSePuedePensar =>
      'Se lo puede pensar; no las tiene todas consigo.';
  @override
  String get ofertaProbableAceptar => 'Es probable que acepte.';
  @override
  String get ofertaSeguraAceptar => 'Prácticamente seguro que dice que sí.';
  @override
  String get aniosLabelDosPuntos => 'Años: ';
  @override
  String get tituloRenovaciones => 'Renovaciones';
  @override
  String get ningunContratoSeAcaba =>
      'No se te acaba ningún contrato: la plantilla sigue atada un año más.';
  @override
  String continuarConNAgenciaLibre(int n) =>
      'Continuar ($n se van a la agencia libre)';
  @override
  String porEncimaDelTope(String cantidad) =>
      'Estás $cantidad por encima del tope: solo puedes ofrecer contratos del mínimo.';
  @override
  String teQuedanBajoElTope(String espacio, String tope) =>
      'Te quedan $espacio bajo el tope de $tope.';
  @override
  String get seAcaboLaNegociacion => 'Se acabó\nla negociación';
  @override
  String ofrecerConN(int n) => 'Ofrecer ($n)';
  @override
  String get cerramosElTraspaso => '¿Cerramos el traspaso?';
  @override
  String seVanYLlegan(String piden, String ofrecen) =>
      'Se van $piden y llegan $ofrecen.';
  @override
  String get tituloOfertasRecibidasScreen => 'Ofertas recibidas';
  @override
  String get nadieTePideNadaAhora =>
      'Ahora mismo nadie te ha pedido nada. Sigue simulando: las ofertas llegan durante la temporada.';
  @override
  String get ofertaAnterior => 'Oferta anterior';
  @override
  String get ofertaSiguiente => 'Oferta siguiente';
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
  String aniosDeContrato(int n) => n == 1 ? '1 año' : '$n años';
  @override
  String contratoAnioMillones(String anios, String millones) =>
      '$anios · $millones al año';
  @override
  String get tePiden => 'Te piden';
  @override
  String get teOfrecen => 'Te ofrecen';
  @override
  String get contraofertar => 'Contraofertar';
  @override
  String get teVasAQuedarCorto => 'Te vas a quedar corto';
  @override
  String avisoLoCierras(String aviso) => '$aviso\n\n¿Lo cierras igualmente?';
  @override
  String get mejorNo => 'Mejor no';
  @override
  String get cerrarloIgual => 'Cerrarlo igual';
  @override
  String get traspasoCerradoSimple => 'Traspaso cerrado.';
  @override
  String get fechaLimiteTraspasosNoMasOperaciones =>
      'Ya ha pasado la fecha límite de traspasos: no se pueden cerrar más operaciones esta temporada.';
  @override
  String quienSeLlevaA(String nombre) => '¿Quién se lleva a $nombre?';
  @override
  String quienSeLlevaPaquete(int n) =>
      '¿Quién se lleva el paquete de $n piezas?';
  @override
  String get ningunEquipoTeDariaNada =>
      'Ningún equipo te daría a cambio nada que merezca la pena.';
  @override
  String get noTienesConQueConvencer =>
      'No tienes con qué convencerles: ni tu plantilla ni tus picks les llegan sin dejarte roto.';
  @override
  String get tituloTraspasos => 'Traspasos';
  @override
  String get fechaLimiteTraspasosBanner =>
      'La fecha límite de traspasos ya ha pasado esta temporada: puedes seguir mirando el mercado, pero no cerrar nada hasta el año que viene.';
  @override
  String get noCuadraMeteATercero => '¿No cuadra? Mete a un tercero';
  @override
  String get cerrarTraspasoBtn => 'Cerrar traspaso';
  @override
  String get tuEquipoLabel => 'Tu equipo';
  @override
  String get tercerEquipoLabel => 'Tercer equipo';
  @override
  String get rivalLabel => 'Rival';
  @override
  String get buscarQuienCompraria => 'Buscar quién te lo compraría';
  @override
  String get buscarQueDarPorEl => 'Buscar qué tendrías que dar por él';
  @override
  String anadirDe(String equipo) => 'Añadir de $equipo';
  @override
  String get eleccionesDeDraft => 'Elecciones de draft';
  @override
  String get yaHasPuestoTodo =>
      'Ya has puesto sobre la mesa todo lo que este equipo tenía disponible.';
  @override
  String get sacarDeLaOperacion => 'Sacar de la operación';
  @override
  String get noCuadraMeteATerceroLarga => '¿No cuadra?\nMete a un tercero';
  @override
  String get anadirEquipoBtn => 'Añadir equipo';
  @override
  String get tocaParaElegirJugadoresOPicks =>
      'Toca para elegir\njugadores o picks';

  @override
  String get mercadoCerradoNoSeBuscan =>
      'El mercado está cerrado: ya pasó la fecha límite de traspasos. No se pueden buscar operaciones hasta el año que viene.';
  @override
  String get tituloLegado => 'Legado';
  @override
  String get explicacionPuntuacionCarreraTooltip =>
      'Qué significa la puntuación de carrera';
  @override
  String get hallOfFame => 'Hall of Fame';
  @override
  String get pestanaCamisetasRetiradas => 'Camisetas retiradas';
  @override
  String get pestanaLideresHistoricos => 'Líderes históricos';
  @override
  String get camisetaRetiradaSingular => 'Camiseta retirada';
  @override
  String get unDorsalQueNoVolvera => 'Un dorsal que ya no volverá a jugarse';
  @override
  String get dorsalesQueNoVolveran => 'Dorsales que ya no volverán a jugarse';
  @override
  String get tituloPartidosDeLaSerie => 'Partidos de la serie';
  @override
  String partidoNMarcador(
    int n,
    String local,
    int marcadorLocal,
    int marcadorVisitante,
    String visitante,
  ) => 'Partido $n: $local $marcadorLocal - $marcadorVisitante $visitante';
  @override
  String get unNuevoNombreHof => 'Un nuevo nombre entra en el Hall of Fame.';
  @override
  String nNombresNuevosHof(int n) =>
      '$n nombres nuevos entran en el Hall of Fame.';
  @override
  String entroEnAnio(int anio) => 'Entró en $anio';
  @override
  String get queEsPuntuacionCarrera => '¿Qué es la puntuación de carrera?';
  @override
  String get explicacionPuntuacionCarreraTexto =>
      'Resume lo que ha dado de sí toda la carrera de un jugador, no un solo número aislado:\n\n• Trofeos individuales (MVP, Mejor Defensor, quintetos, Rookie del Año, Más Mejorado).\n• Anillos de campeón y títulos de la NBA Cup.\n• El pico de nivel que llegó a alcanzar.\n• Los puntos, asistencias y rebotes que acumuló, según cuántas temporadas jugó.\n\nHace falta al menos 6 temporadas jugadas y superar un umbral para entrar: un titular sólido sin premios no basta, tiene que haber sido importante de verdad.';
  @override
  String get entendido => 'Entendido';
  @override
  String noSePudoCargarHof(String error) =>
      'No se ha podido cargar el Hall of Fame.\n$error';
  @override
  String get todaviaNadieEnHof =>
      'Todavía no hay nadie en el Hall of Fame. Solo entran jugadores ya retirados con una carrera de las grandes: premios, anillos y muchos años a buen nivel.';
  @override
  String get nuevoChip => 'NUEVO';

  @override
  String get enActivoLeyenda => 'En activo: todavía puede subir puestos';
  @override
  String get todaviaNoHayEstadisticas =>
      'Todavía no hay estadísticas que mostrar.';
  @override
  String noSePudieronCargarCamisetas(String error) =>
      'No se han podido cargar las camisetas retiradas.\n$error';
  @override
  String get todaviaNoHayCamisetaEnLiga =>
      'Todavía no hay ninguna camiseta retirada en la liga. Cuando se retire una leyenda podrás honrarla.';
  @override
  String get franquiciaLabel => 'Franquicia';
  @override
  String get todaLaLigaOpcion => 'Toda la liga';
  @override
  String equipoTodaviaNoHaRetirado(String equipo) =>
      '$equipo todavía no ha retirado ninguna camiseta.';
  @override
  String get tuEquipoBadge => 'TU EQUIPO';
  @override
  String get retiradaRealDeLaFranquicia => 'Retirada real de la franquicia';
  @override
  String retiradaEnLaTemporada(String etiquetaTemporada) =>
      'Retirada en la $etiquetaTemporada';
  @override
  String nPartidos(int n) => n == 1 ? '1 partido' : '$n partidos';
  @override
  String get enElVestuario => 'En el vestuario';

  @override
  String get premioMvp => 'MVP';
  @override
  String get premioMejorDefensor => 'Mejor Defensor';
  @override
  String get premioRookieDelAno => 'Rookie del Año';
  @override
  String get premioMasMejorado => 'Jugador Más Mejorado';
  @override
  String get premioPrimerQuinteto => 'Primer Quinteto';
  @override
  String get premioSegundoQuinteto => 'Segundo Quinteto';
  @override
  String get risingStars => 'Rising Stars';
  @override
  String premioMvpAllStar(String allStar) => 'MVP del $allStar';
  @override
  String premioMvpRisingStars(String risingStars) => 'MVP del $risingStars';
  @override
  String get tituloPremiosDeLaTemporada => 'Premios de la temporada';
  @override
  String noSePudieronCargarPremios(String error) =>
      'No se han podido cargar los premios.\n$error';
  @override
  String get verCalendarioBtn => 'Ver calendario';
  @override
  String statsPremioLinea(String pts, String ast, String reb) =>
      '$pts pts, $ast ast, $reb reb';

  @override
  String temporadaN(int n) => 'Temporada $n';
  @override
  String arrancaLaTemporada(int n, int anioInicio, int anioFin) =>
      'Arranca la temporada $n ($anioInicio-$anioFin)';
  @override
  String get plantillaHaCambiadoAviso =>
      'Tu plantilla ha cambiado: revísala antes del primer partido — se ha dejado una alineación automática hecha.';
  @override
  String get tusEleccionesDelDraft => 'Tus elecciones del draft';
  @override
  String get seRetiranDeTuEquipo => 'Se retiran de tu equipo';
  @override
  String cuelgaLasBotasCon(int edad, int media) =>
      'Cuelga las botas con $edad años y media $media';
  @override
  String get hanDadoUnPasoAdelante => 'Han dado un paso adelante';
  @override
  String get empiezanABajar => 'Empiezan a bajar';
  @override
  String get topDelDraft => 'Top del draft';
  @override
  String get movimientosEnLaLiga => 'Movimientos en la liga';
  @override
  String recibeA(String equipoA, String jugadorB, String posicionB) =>
      '$equipoA recibe a $jugadorB ($posicionB)';
  @override
  String get tambienSeRetiran => 'También se retiran';
  @override
  String yNMas(int n) => 'y $n más';
  @override
  String posicionMediaSeparador(String posicion, int media) =>
      '$posicion · media $media · ';

  @override
  String camisetaDeXRetirada(String nombre) => 'Camiseta de $nombre retirada.';
  @override
  String get tituloSeRetiran => 'Se retiran';
  @override
  String get estaTemporadaNoSeRetiraNadie =>
      'Esta temporada no se retira nadie.';
  @override
  String get restoDeLaLiga => 'Resto de la liga';
  @override
  String get suCamisetaYaRetiradaSola =>
      ' · su camiseta ya se ha retirado sola (leyenda real)';
  @override
  String get camisetaRetiradaSufijo => ' · camiseta retirada';

  @override
  String get tituloResultadoPartido => 'Resultado del partido';
  @override
  String get columnaTotal => 'Total';
  @override
  String get columnaJugador => 'Jugador';
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
  String get ordenMediaDesc => 'Media ↓';
  @override
  String get ordenMediaAsc => 'Media ↑';
  @override
  String get tituloDraft => 'Draft';
  @override
  String get eligiendoElRestoDeEquipos => 'Eligiendo el resto de equipos...';
  @override
  String get queElijaLaCpuPorMi => 'Que elija la CPU por mí';
  @override
  String get draftCompletado => 'Draft completado';
  @override
  String eleccionNumero(int n) => 'Elección número $n';
  @override
  String get teTocaElegir => '¡Te toca elegir!';
  @override
  String get ordenarPorLabel => 'Ordenar por: ';

  @override
  String cuartosCopaSeSiembranAviso(String nbaCup) =>
      'Los cuartos de la $nbaCup se siembran en cuanto termina la fase de grupos de toda la liga.';
  @override
  String get finalSeJuegaDesdeCalendarioAviso =>
      'La Final se juega desde el calendario: si eres finalista la tienes marcada como un día más de tu temporada.';
  @override
  String get cuartosDeFinalLabel => 'Cuartos de final';
  @override
  String get semifinalLabel => 'Semifinal';
  @override
  String finalDeLaCopaLabel(String nbaCup) => 'Final de la $nbaCup';
  @override
  String get cuartosRondaLabel => 'Cuartos';
  @override
  String get finalRondaLabel => 'Final';
  @override
  String get pendienteLabel => 'Pendiente';

  @override
  String get tituloResumenDeLaTemporada => 'Resumen de la temporada';
  @override
  String noSePudoCargarResumen(String error) =>
      'No se ha podido cargar el resumen.\n$error';
  @override
  String temporadaConEtiqueta(String etiqueta) => 'Temporada $etiqueta';
  @override
  String get pestanaBalance => 'Balance';
  @override
  String puestoEnConferencia(String conferencia) => 'Puesto en el $conferencia';
  @override
  String puestoValor(int puesto) => '#$puesto';
  @override
  String puestoEnLaLigaNota(int puesto) => '#$puesto de la liga';
  @override
  String get puntosPorPartidoLabel => 'Puntos por partido';
  @override
  String encajadosLabel(String valor) => 'encajados $valor';
  @override
  String get diferenciaLabel => 'Diferencia';
  @override
  String get porPartidoLabel => 'por partido';
  @override
  String get mejorRachaLabel => 'Mejor racha';
  @override
  String get victoriasSeguidasLabel => 'victorias seguidas';
  @override
  String get peorRachaLabel => 'Peor racha';
  @override
  String get derrotasSeguidasLabel => 'derrotas seguidas';
  @override
  String get mejorVictoriaLabel => 'Mejor victoria';
  @override
  String get peorDerrotaLabel => 'Peor derrota';
  @override
  String partidosJugadosVictoriasPct(int partidos, int pct) =>
      '$partidos partidos · $pct% de victorias';
  @override
  String get todaviaNoHayClasificacion => 'Todavía no hay clasificación.';
  @override
  String get columnaPJ => 'PJ';
  @override
  String posicionMedia(String posicion, int media) =>
      '$posicion · media $media';

  @override
  String get allStarSubtituloPendiente =>
      'Se juega en el descanso de febrero. Simula hasta el fin de semana de las estrellas para verlo.';
  @override
  String get risingStarsSubtituloPendiente =>
      'Los mejores rookies contra los de segundo año, el mismo fin de semana.';
  @override
  String get votacionAbreCuandoRuedeBalonAviso =>
      'La votación abre cuando ruede el balón. Según vayas jugando jornadas irás viendo quién se está ganando el puesto y por cuántos votos.';
  @override
  String get verEstadisticasBtn => 'Ver estadísticas';
  @override
  String mvpConNombre(String nombre) => 'MVP · $nombre';
  @override
  String lineaMvpPtsAstReb(int pts, int ast, int reb) =>
      '$pts pts · $ast ast · $reb reb';
  @override
  String escrutadoPorcentaje(int pct) => 'Escrutado el $pct% de los votos...';
  @override
  String get recuentoCerradoAviso =>
      'Recuento cerrado: estos fueron los elegidos.';
  @override
  String votacionAbiertaConPorcentaje(int pct) =>
      'Votación abierta, con el $pct% de la temporada jugado. Sigue simulando y los votos se moverán.';
  @override
  String get votacionFinalLabel => 'Votación final';
  @override
  String get votacionDeAficionadosLabel => 'Votación de aficionados';
  @override
  String conferenciaConNombre(String conferenciaLabel) =>
      'Conferencia $conferenciaLabel';
  @override
  String get titularesLabel => 'Titulares';
  @override
  String get suplentesLabel => 'Suplentes';
  @override
  String get seQuedanFueraLabel => 'Se quedan fuera';
  @override
  String posicionValoracion(String posicion, String valoracion) =>
      '$posicion · $valoracion de valoración';

  @override
  String get noLlegoACompletarNingunaTemporada =>
      'No llegó a completar ninguna temporada contigo.';
  @override
  String get tituloTrayectoria => 'Trayectoria';
  @override
  String get tituloPalmares => 'Palmarés';
  @override
  String get noRetirarElDorsal => 'No retirar el dorsal';
  @override
  String get retirarSuCamiseta => 'Retirar su camiseta';
  @override
  String get mvpFinalesCorto => 'MVP de Finales';
  @override
  String get mvpDeLasFinalesLabel => 'MVP de las Finales';
  @override
  String quintetosAllNba(int n) => '$n quintetos All-NBA';
  @override
  String vecesConEtiqueta(int n, String etiqueta) => '$n $etiqueta';
  @override
  String copasGanadas(int n, String nbaCup) => '$n $nbaCup${n == 1 ? '' : 's'}';
  @override
  String get premioCampeonDeLaNba => 'Campeón de la NBA';
  @override
  String get premioTercerQuinteto => 'Tercer quinteto';
  @override
  String get premioMaximoAnotador => 'Máximo anotador';
  @override
  String get premioMasMejoradoCorto => 'Más Mejorado';
  @override
  String get sinTitulosNiPremiosCarreraNba =>
      'Sin títulos ni premios en su carrera NBA.';
  @override
  String get sinTitulosNiPremiosIndividuales =>
      'Sin títulos ni premios individuales.';
  @override
  String resumenCarreraTotales(int temporadas, String posicion, int partidos) =>
      '$temporadas temporadas · $posicion · $partidos partidos';
  @override
  String totalesCarreraLinea(String pts, String ast, String reb) =>
      'Totales: $pts pts · $ast ast · $reb reb';
  @override
  String temporadasPreviasAviso(int n) =>
      '$n de ellas antes de que cogieras el mando: de esas no hay estadísticas, las medias de abajo son las de tu era.';
  @override
  String get antesDeTuPartidaTitulo => 'Antes de tu partida';
  @override
  String temporadasYaJugadasCuandoCogisteElEquipo(int n) =>
      '$n ${n == 1 ? 'temporada' : 'temporadas'} ya jugadas cuando cogiste el equipo.';
  @override
  String get produccionDeReferenciaAviso =>
      'Su producción de referencia al empezar la partida. De aquellos años no hay estadísticas partido a partido.';
  @override
  String sinEstadisticasDeCarreraAviso(String nombre) =>
      'De $nombre no hay estadísticas de carrera: es de una época anterior a la que cubren los datos del juego. Su sitio en la historia está, los números no.';
  @override
  String get suCarreraEnLaNbaReal => 'Su carrera en la NBA real';
  @override
  String conEquipoEnLaNbaReal(String equipo) => 'Con $equipo en la NBA real';
  @override
  String temporadasPartidos(int temporadas, int partidos) =>
      '$temporadas temporadas · $partidos partidos';
  @override
  String rangoTemporadasPartidos(String desde, String hasta, int partidos) =>
      '$desde a $hasta · $partidos partidos';
  @override
  String rangoPartidos(String rango, int partidos) =>
      '$rango · $partidos partidos';
  @override
  String temporadaMinuscula(int n) => 'temporada $n';

  @override
  String get nadieTePropuestoNadaAhora =>
      'Nadie te ha propuesto nada por ahora';
  @override
  String get unEquipoQuiereAUnoDeTusJugadores =>
      'Un equipo quiere a uno de tus jugadores';
  @override
  String nEquiposHanPreguntado(int n) =>
      '$n equipos han preguntado por jugadores tuyos';
  @override
  String cuadroYResultadosDeLaCopa(String nbaCup) =>
      'Cuadro y resultados de la $nbaCup';
  @override
  String get seDesbloqueaAlTerminarFaseDeGrupos =>
      'Se desbloquea al terminar la fase de grupos';
  @override
  String get premiosDeFinDeTemporadaSubtitulo => 'Premios de fin de temporada';
  @override
  String get seDesbloqueaAlTerminarTemporadaRegular =>
      'Se desbloquea al terminar la temporada regular';
  @override
  String get bracketDeEliminatorias => 'Bracket de eliminatorias';
  @override
  String hallOfFameYCamisetasRetiradasSubtitulo(
    String hallOfFame,
    String camisetas,
  ) => '$hallOfFame y $camisetas';
  @override
  String get salarialLabel => 'Salarial';

  @override
  String get sigueDondeLoDejaste => 'Sigue donde lo dejaste';
  @override
  String get empiezaTuCarrera => 'Empieza tu carrera';
  @override
  String get enQueRanuraQuieresEmpezar => '¿En qué ranura quieres empezar?';
  @override
  String get eligeLaPartidaQueQuieresCargar =>
      'Elige la partida que quieres cargar';
  @override
  String get nuevaPartidaBtn => 'Nueva partida';
  @override
  String get cargarPartidaBtn => 'Cargar partida';
  @override
  String sobrescribirLaPartidaN(int n) => '¿Sobrescribir la partida $n?';
  @override
  String get sePerderaEnteraAviso =>
      'Esa ranura ya tiene una carrera en marcha y se perderá entera: plantillas, calendario y palmarés. Esto no se puede deshacer.';
  @override
  String get sobrescribirBtn => 'Sobrescribir';
  @override
  String get eligeTuEquipoTitulo => 'Elige tu equipo';
  @override
  String borrarLaPartidaN(int n) => '¿Borrar la partida $n?';
  @override
  String sePierdeCarreraDeAviso(String nombre) =>
      'Se pierde toda la carrera de $nombre: plantillas, calendario, palmarés, leyendas y camisetas retiradas. Esto no se puede deshacer.';
  @override
  String get borrarBtn => 'Borrar';
  @override
  String get lasTresRanurasOcupadasAviso =>
      'Las tres ranuras están ocupadas: borra una para empezar de nuevo, o continúa una de las que ya tienes.';
  @override
  String get ranuraDeVersionCompleta => 'Ranura de la versión completa';
  @override
  String partidaNumero(int n) => 'PARTIDA $n';
  @override
  String get borrarEstaPartidaTooltip => 'Borrar esta partida';
  @override
  String get ranuraVaciaLabel => 'Ranura vacía';
  @override
  String get empezarBtn => 'Empezar';

  @override
  String get lesionLabel => 'Lesión';
  @override
  String get recibesLabel => 'Recibes: ';
  @override
  String get entregasLabel => 'Entregas: ';
  @override
  String get traspasarBtn => 'Traspasar';
  @override
  String get potencialElite => 'Elite';
  @override
  String get potencialMuyAlto => 'Muy alto';
  @override
  String get potencialAlto => 'Alto';
  @override
  String get potencialMedio => 'Medio';
  @override
  String get potencialBajo => 'Bajo';
  @override
  String potencialTooltip(String etiqueta) => 'Potencial: $etiqueta';
  @override
  String get volverAlMenuPrincipalTooltip => 'Volver al menú principal';
  @override
  String get volverAInicioTooltip => 'Salir a la pantalla de inicio';

  @override
  String get margenSalarialEvento => 'Margen salarial';

  @override
  String get tuFranquiciaSeccion => 'Tu franquicia';

  @override
  String get proximoPartidoTitulo => 'Próximo partido';

  @override
  String get enCasaLabel => 'En casa';

  @override
  String get fueraLabel => 'Fuera';

  @override
  String get vsAbreviatura => 'VS';

  @override
  String get tituloPatrocinadores => 'Patrocinadores';
  @override
  String get explicacionPatrocinadores =>
      'Cada patrocinio tiene varias ofertas: cuanto más largo el contrato, menos paga al año. Lo que firmes ocupa esa categoría hasta que caduque.';
  @override
  String get patrocinioEstadioLabel => 'Patrocinador del pabellón';
  @override
  String get patrocinioCamisetaLabel => 'Patrocinador de la camiseta';
  @override
  String get patrocinioBebidaLabel => 'Patrocinador de comida y bebida';
  @override
  String get patrocinioOcioLabel => 'Patrocinador de ocio';
  @override
  String fundadoEnAnio(int anio) => 'Fundado en $anio';
  @override
  String get alAnioSufijo => 'al año';
  @override
  String sinPatrocinioFirmado(int ofertas) =>
      ofertas == 1 ? 'Sin firmar · 1 oferta' : 'Sin firmar ·  ofertas';
  @override
  String margenPatrocinio(String importe) => '+$importe de margen salarial';
  @override
  String get patrocinadoresBloqueados =>
      'Los patrocinadores son de la versión completa. Mira un vídeo y los tienes los cuatro durante esta temporada.';
  @override
  String get verVideoPatrocinadores => 'VER VÍDEO Y DESBLOQUEAR';
  @override
  String get videoSinTerminar =>
      'El vídeo no se vio entero, así que siguen bloqueados. Puedes intentarlo otra vez.';

  @override
  String get modoFranquiciaOpcion => 'Modo Franquicia';
  @override
  String get modoCarreraOpcion => 'Modo Jugador';

  @override
  String get crearJugadorTitulo => 'Crea tu jugador';
  @override
  String get apellidoLabel => 'Apellido';
  @override
  String get dorsalLabel => 'Dorsal';
  @override
  String get posicionLabel => 'Posición';
  @override
  String get nacionalidadLabel => 'Nacionalidad';
  @override
  String get confirmarIdentidadBtn => 'Confirmar identidad';

  @override
  String get ofertaJuvenilTitulo => 'Oferta de cantera';
  @override
  String get ofertaJuvenilDescripcion =>
      'Organizaciones juveniles de tu país quieren sumarte a su proyecto. Elige dónde empieza tu carrera.';
  @override
  String ficharPorBtn(String organizacion) => 'Fichar por $organizacion';

  @override
  String get avanzarTemporadaBtn => 'Avanzar temporada';
  @override
  String get entrarAlDraftBtn => 'Entrar al draft';

  @override
  String get edadLabel => 'Edad';
  @override
  String get mediaLabel => 'Media';
  @override
  String get potencialLabel => 'Potencial';
  @override
  String get valorLabel => 'Valor';
  @override
  String get equipoActualLabel => 'Equipo';
  @override
  String get organizacionActualLabel => 'Organización';

  @override
  String get carreraRetiradaTitulo => 'Carrera terminada';
  @override
  String draftResultadoMensaje(String equipo) => 'Te ha drafteado $equipo.';
  @override
  String get entraEnHallDeLaFamaMensaje => '¡Entra en el Salón de la Fama!';
  @override
  String get noEntraEnHallDeLaFamaMensaje => 'No llega al Salón de la Fama.';
  @override
  String seRetiraMensaje(int edad) => 'Se retira a los $edad años.';
  @override
  String cambioDeEquipoMensaje(String equipo) => 'Nuevo equipo: $equipo.';
}
