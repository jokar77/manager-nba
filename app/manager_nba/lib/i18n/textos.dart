/// Los textos de la interfaz, en los idiomas que habla el juego.
///
/// Por qué una clase abstracta y no los ficheros .arb de Flutter: aquí el
/// compilador es el que vigila. Si se añade un texto y falta en un idioma,
/// `flutter analyze` falla y no se puede publicar; con .arb el que falte
/// sale en tiempo de ejecución, en inglés, delante del usuario.
///
/// Cómo añadir un texto: se pone en [Textos] y el analizador dirá los seis
/// sitios donde falta. Cómo añadir un idioma: se crea la clase, se mete en
/// [Idioma] y en [textosDe].
library;

import 'package:flutter/widgets.dart';

import 'textos_eventos.dart';

export 'textos_eventos.dart' show TextosDeEventos, TextoDeEvento, TextoDeOpcion;

part 'textos_es.dart';
part 'textos_en.dart';
part 'textos_fr.dart';
part 'textos_pt.dart';
part 'textos_de.dart';
part 'textos_it.dart';
part 'textos_zh.dart';

/// Los idiomas disponibles. El código es el de la etiqueta BCP-47 que se
/// guarda en la tabla `Ajustes` y que entiende `MaterialApp.locale`.
enum Idioma {
  espanol('es', 'Español'),
  ingles('en', 'English'),
  frances('fr', 'Français'),
  portugues('pt', 'Português (Brasil)'),
  aleman('de', 'Deutsch'),
  italiano('it', 'Italiano'),
  chino('zh', '简体中文');

  const Idioma(this.codigo, this.nombre);

  /// Código guardado en ajustes ('es', 'en'...).
  final String codigo;

  /// Cómo se llama el idioma EN ESE IDIOMA. Un menú de idiomas que traduce
  /// los nombres al idioma actual es inservible justo para quien lo
  /// necesita: alguien que no entiende el idioma en el que está la app.
  final String nombre;

  Locale get locale => Locale(codigo);

  /// El idioma guardado, o español si el código no se reconoce (una partida
  /// vieja, o un código que ya no existe).
  static Idioma desdeCodigo(String? codigo) => Idioma.values.firstWhere(
    (i) => i.codigo == codigo,
    orElse: () => Idioma.espanol,
  );
}

Textos textosDe(Idioma idioma) => switch (idioma) {
  Idioma.espanol => const TextosEs(),
  Idioma.ingles => const TextosEn(),
  Idioma.frances => const TextosFr(),
  Idioma.portugues => const TextosPt(),
  Idioma.aleman => const TextosDe(),
  Idioma.italiano => const TextosIt(),
  Idioma.chino => const TextosZh(),
};

/// Deja los textos del idioma activo al alcance de toda la interfaz.
///
/// Ojo al `orElse`: si no hay ninguno por encima se devuelve español en vez
/// de reventar. Eso es lo que permite que los tests de widget existentes
/// monten una pantalla suelta sin tener que envolverla, y que un widget
/// nuevo nunca tumbe la app por un olvido de fontanería.
class Idiomas extends InheritedWidget {
  final Textos textos;

  const Idiomas({super.key, required this.textos, required super.child});

  static Textos de(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Idiomas>()?.textos ??
      const TextosEs();

  @override
  bool updateShouldNotify(Idiomas anterior) => anterior.textos != textos;
}

/// Atajo para no escribir `Idiomas.de(context)` en cada línea.
Textos t(BuildContext context) => Idiomas.de(context);

/// Todos los textos de la interfaz. Ver la nota de arriba sobre por qué es
/// una clase y no un fichero de traducción.
abstract class Textos {
  const Textos();

  // --- Eventos narrativos ------------------------------------------------
  /// El guion de los eventos de vestuario, que vive aparte por su tamaño.
  /// Ver `textos_eventos.dart`.
  TextosDeEventos get eventos;

  // --- Genéricos ---------------------------------------------------------
  String get aceptar;
  String get cancelar;
  String get cerrar;
  String get guardar;
  String get continuar;
  String get si;
  String get no;
  String get cargando;

  // --- Menú de inicio ----------------------------------------------------
  String get nuevaPartida;
  String get ajustes;
  String get elegirEquipo;
  String get sobrescribir;
  String get ranuraOcupada;
  String get avisoSobrescribir;

  // --- Ajustes -----------------------------------------------------------
  String get modoOscuro;
  String get modoOscuroDetalle;
  String get idioma;
  String get idiomaDetalle;

  // --- Menú principal ----------------------------------------------------
  String get calendario;
  String get calendarioDetalle;
  String get tuEquipo;
  String get tuEquipoDetalle;
  String get entrenador;
  String get banquilloVacante;
  String get clasificacion;
  String get clasificacionDetalle;
  String get mercado;
  String get traspasos;
  String get traspasosDetalle;
  String get ofertasRecibidas;
  String get agenciaLibre;
  String get agenciaLibreDetalle;
  String get competicion;
  String get nbaCup;
  String get allStar;
  String get allStarDetalle;
  String get resumenTemporada;
  String get resumenTemporadaDetalle;
  String get playoffs;
  String get premios;
  String get legado;

  // --- Cabecera del equipo ----------------------------------------------
  String get record;
  String get masaSalarial;
  String get temporada;

  // --- Entrenador --------------------------------------------------------
  String get sinEntrenador;
  String get sinEntrenadorDetalle;
  String get despedir;
  String get contratar;
  String get negociar;
  String get ofrecer;
  String get sueldo;
  String get duracion;
  String get ataque;
  String get defensa;
  String get desarrollo;
  String get equilibrado;
  String get especialistaAtaque;
  String get especialistaDefensa;
  String get formadorDeJovenes;
  String get loQuePuedesOfrecer;
  String get topeDeLaFranquicia;
  String get finiquitos;
  String get aceptariaLaOferta;
  String get todaviaNo;
  String get noVaAAceptar;

  /// "5 años" / "1 año": el plural cambia de forma en cada idioma, así que
  /// se pide entero en vez de pegar un "s" al final.
  String anios(int n);

  /// "58,5M" ya formateado -> "58,5M al año".
  String alAnio(String importe);

  // --- Clasificación -------------------------------------------------
  String get pestanaEquipos;
  String get pestanaJugadores;
  String get conferenciaEste;
  String get conferenciaOeste;

  /// Cabecera de sección tal cual se enseña, ya compuesta entera: el
  /// orden "CONFERENCIA ESTE" no es el mismo en todos los idiomas.
  String get tituloConferenciaEste;
  String get tituloConferenciaOeste;
  String get fronteraPlayIn;
  String get fronteraFueraDePlayoffs;
  String get ordenPuntos;
  String get ordenAsistencias;
  String get ordenRebotes;
  String get sinPartidosJugados;

  // --- Ficha rápida de jugador ----------------------------------------
  /// "25 años" / "25 years old": el orden de palabras cambia entero de
  /// idioma a idioma, así que se pide la frase hecha en vez de pegar un
  /// número a una palabra suelta.
  String edadJugador(int n);

  /// "Media 82" ya con la etiqueta puesta.
  String mediaJugador(int n);
  String get estaTemporada;
  String get todaviaNoHaJugado;
  String get contrato;
  String get intentarTraspasar;
  String traspasoCerradoCon(String equipo);
  String get fechaLimiteTraspasosPasada;

  /// "¿Cómo fichar a Fulanito?", título de la hoja que enseña
  /// propuestas de traspaso para conseguir a un jugador ajeno.
  String comoFicharA(String nombre);
  String get sinConQueConvencerles;

  // --- Diálogo de campeón (playoffs y NBA Cup) ------------------------
  String get campeonesDeLaNba;
  String get campeonesDeLaCup;
  String get exclamacionCampeones;
  String seLlevaElTitulo(String nombre);
  String get enhorabuenaAnillo;
  String get enhorabuenaCup;
  String get aCelebrarlo;
  String mvpDeLasFinales(String nombre);
  String partidosDeSerie(int n);
  String get verEstadisticas;

  // --- Calendario ------------------------------------------------------
  String get confirmarSimularTitulo;
  String get seJugaraProximoPartido;
  String seJugaranDeUnaVez(int partidos, int dia, int mes);
  String get simular;
  String finalCupVs(String enfrentamiento);
  String get tituloEventoFinAgenciaLibre;
  String get tituloEventoFechaLimiteTraspasos;
  String get tituloEventoAllStar;
  String get descEventoFinAgenciaLibre;
  String get descEventoFechaLimiteTraspasos;
  String get descEventoAllStar;

  /// Los doce meses, enero primero. Se usa en la cabecera de cada mes del
  /// calendario.
  List<String> get nombresMeses;

  /// Las siete iniciales de la semana, lunes primero — el mismo orden que
  /// usa el propio calendario.
  List<String> get diasSemanaAbrev;

  String get simularUnPartido;
  String get unaSemana;
  String get simularUnaSemana;
  String get unMes;
  String get simularUnMes;

  /// Simular de golpe todo lo que queda de temporada regular. Se lanza
  /// desde el hub y lleva al Calendario, que es donde se ve avanzar.
  String get simularTemporadaEntera;
  String get verBracketCompleto;
  String get empezarSiguienteTemporada;
  String get simularPartidoDePlayoffs;
  String get noClasificasteAPlayoffs;
  String get simularPlayoffsCompletos;
  String get serieDecididaFaltaResto;
  String get simularRestoDeRonda;

  // --- Avisos durante la simulación ------------------------------------
  String ofertaTitulo(int n);
  String ofertaMensaje(int n);
  String get masTarde;
  String verOfertaBoton(int n);
  String get preguntaSeguirSimulando;
  String get irAAgenciaLibre;
  String get irATraspasos;
  String get seguirSimulando;
  String get allStarWeekendMayus;
  String resultadoAllStar({
    required bool esteGana,
    required int local,
    required int visitante,
    String? mvp,
  });
  String get verFinDeSemana;
  String finalCupProgramada(String fecha);

  /// "14 de marzo" (o el orden que toque en cada idioma), a partir del mes
  /// 1-12: reutiliza [nombresMeses] para no mantener dos listas.
  String fechaCorta(int dia, int mes);

  String get sinPartidosTitulo;
  String resumenPartidos(int n, int ganados, int perdidos);
  String get lesionesActivasAhora;
  String get verLosPremios;

  // --- Playoffs ----------------------------------------------------------
  String get playoffsSeSiembranAlTerminar;
  String get verCelebracion;
  String get siguienteTemporadaBtn;
  String get resolverPlayIn;
  String get simularRondaCompleta;
  String get simularTodoBtn;
  String get bracketTitulo;
  String get primeraRondaEsperaPlayIn;
  String get playInGanadorEntra7;
  String get playInPerdedorEliminado;
  String get playInGanadorEntra8;
  String get conferenciaOesteTitulo;
  String get conferenciaEsteTitulo;
  String get sinPlayIn;
  String get jugarBtn;
  String get porJugar;
  String get rondaPrimeraRonda;
  String get rondaSemifinalConferencia;
  String get rondaFinalConferencia;
  String get rondaFinalNba;

  /// Las siete etiquetas de fila del bracket vertical, de arriba abajo, con
  /// salto de línea incluido donde haga falta (la columna es estrecha).
  List<String> get nombresDeRondaBracket;

  String get esperandoAlPlayIn;
  String get porDefinir;

  // --- Pantalla de entrenador (mercado) --------------------------------
  String despedirConfirmacion(String nombre);
  String despedirConTiempoRestante(int anios, String importe);
  String get despedirSinContrato;
  String get ficharPorElMinimoBtn;
  String get noHayEntrenadorSinEquipo;
  String get dirigiendoAOtroEquipo;
  String get sePuedeOfertarPeroTrabajo;
  String get avisoObligatorioTexto;
  String mediaDeTuEquipoEs(int n);
  String pideAlAnioYTemporadas(String importe, int anios);
  String noLlegaMasaSalarial(String importe);
  String get tuEntrenadorLabel;
  String get masaSalarialConBanquillo;
  String get porEncimaDelTopeSoloMinimo;
  String get sueldoEntrenadorCuentaEnMasa;
  String contratoResumen(String importeAlAnio, String duracion);
  String trayectoriaEstaTemporada(int victorias, int derrotas);
  String temporadasDirigiendo(int n);
  String anillos(int n);
  String entrenadorDelAnio(int n);
  String dirigeAEquipo(String apodo);
  String pideImportePorAnios(String importe, int anios);
  String get noCabeEnPresupuesto;
  String get proyectoLeQuedaLejos;
  String get asuPrecioNo;

  // --- Ficha de equipo (partida nueva) ----------------------------------
  String get volver;
  String get elegirEsteEquipo;

  String mediaDelEquipo(int n);
  String get torneoDeMitadDeTemporada;
  String get campeonNba;

  // --- Alineación (RosterConfigScreen) ----------------------------------
  String descripcionHueco(bool esTitular, String nombrePosicion);
  String get tituloTitular;
  String get tituloSuplente;

  /// Los cinco puestos con su nombre completo, en el mismo orden que
  /// [posicionesEquipo] del dominio (PG, SG, SF, PF, C).
  Map<String, String> get nombresDePosiciones;

  String get minutosTitularLabel;
  String fueraPorLesion(String nombres);
  String get alinearAutomaticamenteBtn;
  String get pestanaAlineacion;
  String get pestanaEstadisticas;
  String get tusPicksDeDraft;
  String get empezarTemporadaBtn;
  String get guardarRotacionBtn;
  String get elegirJugadorPlaceholder;
  String lesionConDetalle(String motivo, int partidos, String fecha);
  String get fueraDeSusDosPosiciones;
  String get sinPartidosJugadosTemporada;
  String get estrellaAtaqueLabel;
  String get estrellaDefensaLabel;
  String get sextoHombreLabel;
  String get ningunaOpcion;

  /// Al intentar guardar con la alineación a medias. Sustituye al botón
  /// muerto de antes: deshabilitado no decía QUÉ faltaba.
  String get faltaAlineacionAviso;

  /// Al intentar guardar sin haber elegido los tres roles. Va con la banda
  /// resaltada, que es lo que señala dónde hay que mirar.
  String get faltanRolesAviso;

  String get sinPicksPropios;
  String get traspasadoATiPorOtroEquipo;
  String get quintetoInicial;
  String get rotacionCompleta;

  String nombreConPosicionYMedia(String nombre, String posicion, int media);
  String yaAsignadoIntercambio(String descripcionHueco);
  String get tituloTusPicksDeDraft;
  String lesionSimple(String motivo, String fecha);

  String get rechazar;
  String get proponer;
  String get tituloAgenciaLibre;
  String get verTuPlantilla;
  String get agenciaLibreCerrada;
  String get completarConContratosMinimos;
  String get plantillaCompletada;
  String fichadosPorElMinimo(int n);
  String get quePuedaPagar;
  String get noQuedaNadieEnMercado;
  String get nadieEncajaConFiltro;
  String contadorAgentesLibres(int n);
  String contadorAgentesLibresFiltrado(int visibles, int total);
  String get empezarLaTemporadaBtn;
  String get completaLaPlantillaParaContinuar;
  String plantillaAlCompletoConN(int n);
  String plantillaDeMax(int n, int max);
  String faltanFichajesParaMinimo(int n);
  String otrosEquiposJuegan(int max, int n, int atras);
  String sinRecambioEn(String lista);
  String libresBajoElTope(String cantidad);
  String get yaNoNegocia;
  String negociarConN(int n);
  String ofertaA(String nombre);
  String pideAlAnio(String cantidad);
  String sueldoLabel(String cantidad);
  String get insultoOferta;
  String get ofertaImprobable;
  String get ofertaSePuedePensar;
  String get ofertaProbableAceptar;
  String get ofertaSeguraAceptar;
  String get aniosLabelDosPuntos;
  String get tituloRenovaciones;
  String get ningunContratoSeAcaba;
  String continuarConNAgenciaLibre(int n);
  String porEncimaDelTope(String cantidad);
  String teQuedanBajoElTope(String espacio, String tope);
  String get seAcaboLaNegociacion;
  String ofrecerConN(int n);
  String get cerramosElTraspaso;
  String seVanYLlegan(String piden, String ofrecen);
  String get tituloOfertasRecibidasScreen;
  String get nadieTePideNadaAhora;
  String get ofertaAnterior;
  String get ofertaSiguiente;
  String ofertaNDeM(int n, int m);
  // Sin estadísticas de la temporada: en una oferta de traspaso lo que
  // se juzga es el jugador (nivel y contrato), no cómo le ha ido en la
  // temporada que ya se está negociando dejar atrás.
  String lineaJugadorOferta(
    String nombre,
    String posicion,
    int media,
    String contrato,
  );
  /// "1 año" / "3 años" — el año que le queda de contrato a un jugador,
  /// singular incluido: un contrato a punto de acabar dice "1 año", no
  /// "último año" (Lista 15 punto 11).
  String aniosDeContrato(int n);
  String contratoAnioMillones(String anios, String millones);
  String get tePiden;
  String get teOfrecen;
  String get contraofertar;
  String get teVasAQuedarCorto;
  String avisoLoCierras(String aviso);
  String get mejorNo;
  String get cerrarloIgual;
  String get traspasoCerradoSimple;
  String get fechaLimiteTraspasosNoMasOperaciones;
  String quienSeLlevaA(String nombre);
  String quienSeLlevaPaquete(int n);
  String get ningunEquipoTeDariaNada;
  String get noTienesConQueConvencer;
  String get tituloTraspasos;
  String get fechaLimiteTraspasosBanner;
  String get noCuadraMeteATercero;
  String get cerrarTraspasoBtn;
  String get tuEquipoLabel;
  String get tercerEquipoLabel;
  String get rivalLabel;
  String get buscarQuienCompraria;
  String get buscarQueDarPorEl;
  String anadirDe(String equipo);
  String get eleccionesDeDraft;
  String get yaHasPuestoTodo;
  String get sacarDeLaOperacion;
  String get noCuadraMeteATerceroLarga;
  String get anadirEquipoBtn;
  String get tocaParaElegirJugadoresOPicks;

  String get mercadoCerradoNoSeBuscan;
  String get tituloLegado;
  String get explicacionPuntuacionCarreraTooltip;
  String get hallOfFame;
  String get pestanaCamisetasRetiradas;
  String get pestanaLideresHistoricos;
  String get camisetaRetiradaSingular;
  String get unDorsalQueNoVolvera;
  String get dorsalesQueNoVolveran;
  String get tituloPartidosDeLaSerie;
  String partidoNMarcador(
    int n,
    String local,
    int marcadorLocal,
    int marcadorVisitante,
    String visitante,
  );
  String get unNuevoNombreHof;
  String nNombresNuevosHof(int n);
  String entroEnAnio(int anio);
  String get queEsPuntuacionCarrera;
  String get explicacionPuntuacionCarreraTexto;
  String get entendido;
  String noSePudoCargarHof(String error);
  String get todaviaNadieEnHof;
  String get nuevoChip;

  String get enActivoLeyenda;
  String get todaviaNoHayEstadisticas;
  String noSePudieronCargarCamisetas(String error);
  String get todaviaNoHayCamisetaEnLiga;
  String get franquiciaLabel;
  String get todaLaLigaOpcion;
  String equipoTodaviaNoHaRetirado(String equipo);
  String get tuEquipoBadge;
  String get retiradaRealDeLaFranquicia;
  String retiradaEnLaTemporada(String etiquetaTemporada);
  String nPartidos(int n);
  String get enElVestuario;

  String get premioMvp;
  String get premioMejorDefensor;
  String get premioRookieDelAno;
  String get premioMasMejorado;
  String get premioPrimerQuinteto;
  String get premioSegundoQuinteto;
  String get risingStars;
  String premioMvpAllStar(String allStar);
  String premioMvpRisingStars(String risingStars);
  String get tituloPremiosDeLaTemporada;
  String noSePudieronCargarPremios(String error);
  String get verCalendarioBtn;
  String statsPremioLinea(String pts, String ast, String reb);

  String temporadaN(int n);
  String arrancaLaTemporada(int n, int anioInicio, int anioFin);
  String get plantillaHaCambiadoAviso;
  String get tusEleccionesDelDraft;
  String get seRetiranDeTuEquipo;
  String cuelgaLasBotasCon(int edad, int media);
  String get hanDadoUnPasoAdelante;
  String get empiezanABajar;
  String get topDelDraft;
  String get movimientosEnLaLiga;
  String recibeA(String equipoA, String jugadorB, String posicionB);
  String get tambienSeRetiran;
  String yNMas(int n);
  String posicionMediaSeparador(String posicion, int media);

  String camisetaDeXRetirada(String nombre);
  String get tituloSeRetiran;
  String get estaTemporadaNoSeRetiraNadie;
  String get restoDeLaLiga;
  String get suCamisetaYaRetiradaSola;
  String get camisetaRetiradaSufijo;

  String get tituloResultadoPartido;
  String get columnaTotal;
  String get columnaJugador;
  String get columnaMin;
  String get columnaPts;
  String get columnaAst;
  String get columnaReb;
  String get prefijoCuarto;
  String get prefijoProrroga;

  String get ordenPotencial;
  String get ordenMediaDesc;
  String get ordenMediaAsc;
  String get tituloDraft;
  String get eligiendoElRestoDeEquipos;
  String get queElijaLaCpuPorMi;
  String get draftCompletado;
  String eleccionNumero(int n);
  String get teTocaElegir;
  String get ordenarPorLabel;

  String cuartosCopaSeSiembranAviso(String nbaCup);
  String get finalSeJuegaDesdeCalendarioAviso;
  String get cuartosDeFinalLabel;
  String get semifinalLabel;
  String finalDeLaCopaLabel(String nbaCup);
  String get cuartosRondaLabel;
  String get finalRondaLabel;
  String get pendienteLabel;

  String get tituloResumenDeLaTemporada;
  String noSePudoCargarResumen(String error);
  String temporadaConEtiqueta(String etiqueta);
  String get pestanaBalance;
  String puestoEnConferencia(String conferencia);
  String puestoValor(int puesto);
  String puestoEnLaLigaNota(int puesto);
  String get puntosPorPartidoLabel;
  String encajadosLabel(String valor);
  String get diferenciaLabel;
  String get porPartidoLabel;
  String get mejorRachaLabel;
  String get victoriasSeguidasLabel;
  String get peorRachaLabel;
  String get derrotasSeguidasLabel;
  String get mejorVictoriaLabel;
  String get peorDerrotaLabel;
  String partidosJugadosVictoriasPct(int partidos, int pct);
  String get todaviaNoHayClasificacion;
  String get columnaPJ;
  String posicionMedia(String posicion, int media);

  String get allStarSubtituloPendiente;
  String get risingStarsSubtituloPendiente;
  String get votacionAbreCuandoRuedeBalonAviso;
  String get verEstadisticasBtn;
  String mvpConNombre(String nombre);
  String lineaMvpPtsAstReb(int pts, int ast, int reb);
  String escrutadoPorcentaje(int pct);
  String get recuentoCerradoAviso;
  String votacionAbiertaConPorcentaje(int pct);
  String get votacionFinalLabel;
  String get votacionDeAficionadosLabel;
  String conferenciaConNombre(String conferenciaLabel);
  String get titularesLabel;
  String get suplentesLabel;
  String get seQuedanFueraLabel;
  String posicionValoracion(String posicion, String valoracion);

  String get noLlegoACompletarNingunaTemporada;
  String get tituloTrayectoria;
  String get tituloPalmares;
  String get noRetirarElDorsal;
  String get retirarSuCamiseta;
  String get mvpFinalesCorto;
  String get mvpDeLasFinalesLabel;
  String quintetosAllNba(int n);
  String vecesConEtiqueta(int n, String etiqueta);
  String copasGanadas(int n, String nbaCup);
  String get premioCampeonDeLaNba;
  String get premioTercerQuinteto;
  String get premioMaximoAnotador;
  String get premioMasMejoradoCorto;
  String get sinTitulosNiPremiosCarreraNba;
  String get sinTitulosNiPremiosIndividuales;
  String resumenCarreraTotales(int temporadas, String posicion, int partidos);
  String totalesCarreraLinea(String pts, String ast, String reb);
  String temporadasPreviasAviso(int n);
  String get antesDeTuPartidaTitulo;
  String temporadasYaJugadasCuandoCogisteElEquipo(int n);
  String get produccionDeReferenciaAviso;
  String sinEstadisticasDeCarreraAviso(String nombre);
  String get suCarreraEnLaNbaReal;
  String conEquipoEnLaNbaReal(String equipo);
  String temporadasPartidos(int temporadas, int partidos);
  String rangoTemporadasPartidos(String desde, String hasta, int partidos);
  String rangoPartidos(String rango, int partidos);
  String temporadaMinuscula(int n);

  String get nadieTePropuestoNadaAhora;
  String get unEquipoQuiereAUnoDeTusJugadores;
  String nEquiposHanPreguntado(int n);
  String cuadroYResultadosDeLaCopa(String nbaCup);
  String get seDesbloqueaAlTerminarFaseDeGrupos;
  String get premiosDeFinDeTemporadaSubtitulo;
  String get seDesbloqueaAlTerminarTemporadaRegular;
  String get bracketDeEliminatorias;
  String hallOfFameYCamisetasRetiradasSubtitulo(
    String hallOfFame,
    String camisetas,
  );
  String get salarialLabel;

  String get sigueDondeLoDejaste;
  String get empiezaTuCarrera;
  String get enQueRanuraQuieresEmpezar;
  String get eligeLaPartidaQueQuieresCargar;
  String get nuevaPartidaBtn;
  String get cargarPartidaBtn;
  String sobrescribirLaPartidaN(int n);
  String get sePerderaEnteraAviso;
  String get sobrescribirBtn;
  String get eligeTuEquipoTitulo;
  String borrarLaPartidaN(int n);
  String sePierdeCarreraDeAviso(String nombre);
  String get borrarBtn;
  String get lasTresRanurasOcupadasAviso;

  /// La ranura que solo trae la versión completa. Sale con candado en vez
  /// de esconderse: lo que se vende es comodidad, no un secreto.
  String get ranuraDeVersionCompleta;

  String partidaNumero(int n);
  String get borrarEstaPartidaTooltip;
  String get ranuraVaciaLabel;
  String get empezarBtn;

  String get lesionLabel;
  String get recibesLabel;
  String get entregasLabel;
  String get traspasarBtn;
  String get potencialElite;
  String get potencialMuyAlto;
  String get potencialAlto;
  String get potencialMedio;
  String get potencialBajo;
  String potencialTooltip(String etiqueta);
  String get volverAlMenuPrincipalTooltip;

  /// El botón del hub que sale de la partida actual y vuelve a la
  /// pantalla de arranque (nueva partida, cargar, ajustes). Distinto de
  /// [volverAlMenuPrincipalTooltip], que vuelve AL hub desde una pantalla
  /// colgada de él, no MÁS ALLÁ del hub.
  String get volverAInicioTooltip;

  String get margenSalarialEvento;

  /// Rotulo de la primera seccion del menu principal.
  String get tuFranquiciaSeccion;

  // --- Tarjeta de próximo partido (menú principal) ------------------------
  String get proximoPartidoTitulo;
  String get enCasaLabel;
  String get fueraLabel;
  String get vsAbreviatura;

  // --- Patrocinadores (elección de pretemporada) ---------------------------
  String get tituloPatrocinadores;
  String get explicacionPatrocinadores;
  String get patrocinioEstadioLabel;
  String get patrocinioCamisetaLabel;

  /// Lista 15 punto 8: el catálogo de esta categoría (clave `bebida` en
  /// `patrocinadores.dart`) mezcla marcas de bebida de verdad con
  /// restaurantes, panaderías y tiendas de comida — son muchas más las
  /// segundas. "Bebida oficial" prometía algo que la mayoría de las
  /// marcas no eran; el nombre en pantalla ya no se restringe a bebida.
  String get patrocinioBebidaLabel;
  String get patrocinioOcioLabel;
  String fundadoEnAnio(int anio);

  /// El sufijo del dinero de una oferta: "al año". Va suelto, en pequeño y
  /// al lado de la cifra, que es lo que se lee de verdad.
  String get alAnioSufijo;

  /// La cabecera de una categoría sin firmar, con cuántas ofertas hay
  /// dentro. Son hasta tres, pero algunas ciudades tienen menos marcas de
  /// ese tipo (ver `ofertasDe`), así que el número va por delante.
  String sinPatrocinioFirmado(int ofertas);
  String margenPatrocinio(String importe);

  // --- Patrocinadores bloqueados (versión gratuita) ------------------------
  /// Por qué salen los cuatro apagados y qué hacer para abrirlos.
  String get patrocinadoresBloqueados;

  /// El botón que enseña el vídeo recompensado.
  String get verVideoPatrocinadores;

  /// Cuando el vídeo se cierra antes de tiempo. No es un error del juego,
  /// así que se cuenta sin dramatismo y se deja volver a intentarlo.
  String get videoSinTerminar;

  // --- Modo Carrera ---------------------------------------------------------
  /// Controlas a un único jugador, de los 16 años al retiro, en vez de una
  /// franquicia entera.
  String get modoFranquiciaOpcion;
  String get modoCarreraOpcion;

  String get crearJugadorTitulo;
  String get apellidoLabel;
  String get dorsalLabel;
  String get posicionLabel;
  String get nacionalidadLabel;
  String get confirmarIdentidadBtn;

  String get ofertaJuvenilTitulo;
  String get ofertaJuvenilDescripcion;
  String ficharPorBtn(String organizacion);

  String get avanzarTemporadaBtn;
  String get entrarAlDraftBtn;

  String get edadLabel;
  String get mediaLabel;
  String get potencialLabel;
  String get valorLabel;
  String get equipoActualLabel;
  String get organizacionActualLabel;

  String get carreraRetiradaTitulo;
  String draftResultadoMensaje(String equipo);
  String get entraEnHallDeLaFamaMensaje;
  String get noEntraEnHallDeLaFamaMensaje;
  String seRetiraMensaje(int edad);
  String cambioDeEquipoMensaje(String equipo);
}
