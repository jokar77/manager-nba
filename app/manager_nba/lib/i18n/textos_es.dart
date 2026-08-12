part of 'textos.dart';

/// Castellano: el idioma en el que se escribió el juego, y el que se usa de
/// respaldo si un ajuste guardado trae un código raro.
class TextosEs extends Textos {
  const TextosEs();

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
  String get resumenTemporadaDetalle => 'Récord, todos tus partidos y promedios';
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
}
