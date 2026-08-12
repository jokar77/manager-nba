part of 'textos.dart';

/// English. Basketball terms use the ones the NBA itself uses (roster, cap,
/// front office) rather than literal translations from Spanish.
class TextosEn extends Textos {
  const TextosEn();

  @override
  String get aceptar => 'Accept';
  @override
  String get cancelar => 'Cancel';
  @override
  String get cerrar => 'Close';
  @override
  String get guardar => 'Save';
  @override
  String get continuar => 'Continue';
  @override
  String get si => 'Yes';
  @override
  String get no => 'No';
  @override
  String get cargando => 'Loading…';

  @override
  String get nuevaPartida => 'New game';
  @override
  String get ajustes => 'Settings';
  @override
  String get elegirEquipo => 'Pick your team';
  @override
  String get sobrescribir => 'Overwrite';
  @override
  String get ranuraOcupada => 'This slot already has a saved game';
  @override
  String get avisoSobrescribir =>
      'If you continue, the game saved here will be deleted.';

  @override
  String get modoOscuro => 'Dark mode';
  @override
  String get modoOscuroDetalle => 'Greys and blacks instead of bright whites';
  @override
  String get idioma => 'Language';
  @override
  String get idiomaDetalle => 'The language of the whole game';

  @override
  String get calendario => 'Schedule';
  @override
  String get calendarioDetalle => 'See your season and simulate games';
  @override
  String get tuEquipo => 'Your team';
  @override
  String get tuEquipoDetalle => 'Roster and lineup';
  @override
  String get entrenador => 'Head coach';
  @override
  String get banquilloVacante => 'Your bench is vacant';
  @override
  String get clasificacion => 'Standings';
  @override
  String get clasificacionDetalle => 'Teams and statistical leaders';
  @override
  String get mercado => 'Market';
  @override
  String get traspasos => 'Trades';
  @override
  String get traspasosDetalle => 'Negotiate deals with the rest of the league';
  @override
  String get ofertasRecibidas => 'Offers received';
  @override
  String get agenciaLibre => 'Free agency';
  @override
  String get agenciaLibreDetalle => 'Unsigned players and cap space';
  @override
  String get competicion => 'Competition';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Voting, the All-Star Game and its MVP';
  @override
  String get resumenTemporada => 'Season summary';
  @override
  String get resumenTemporadaDetalle => 'Record, every game and averages';
  @override
  String get playoffs => 'Playoffs';
  @override
  String get premios => 'Awards';
  @override
  String get legado => 'Legacy';

  @override
  String get record => 'Record';
  @override
  String get masaSalarial => 'Payroll';
  @override
  String get temporada => 'Season';

  @override
  String get sinEntrenador => 'No head coach';
  @override
  String get sinEntrenadorDetalle =>
      'Your team is playing without a coach. Sign one from the list below.';
  @override
  String get despedir => 'Fire';
  @override
  String get contratar => 'Hire';
  @override
  String get negociar => 'Negotiate';
  @override
  String get ofrecer => 'Offer';
  @override
  String get sueldo => 'Salary';
  @override
  String get duracion => 'Length';
  @override
  String get ataque => 'Offence';
  @override
  String get defensa => 'Defence';
  @override
  String get desarrollo => 'Development';
  @override
  String get equilibrado => 'Balanced';
  @override
  String get especialistaAtaque => 'Offensive specialist';
  @override
  String get especialistaDefensa => 'Defensive specialist';
  @override
  String get formadorDeJovenes => 'Player developer';
  @override
  String get loQuePuedesOfrecer => 'What you can offer';
  @override
  String get topeDeLaFranquicia => 'Franchise cap';
  @override
  String get finiquitos => 'Buyouts of fired coaches';
  @override
  String get aceptariaLaOferta => 'He would accept this offer.';
  @override
  String get todaviaNo =>
      'Not yet. More money or more years might change his mind.';
  @override
  String get noVaAAceptar =>
      'He will not accept: your project is too far off and money will not fix it.';

  @override
  String anios(int n) => n == 1 ? '1 season' : '$n seasons';
  @override
  String alAnio(String importe) => '$importe per year';
}
