part of 'textos.dart';

/// Italiano. I termini NBA che anche la stampa italiana lascia in inglese
/// (playoff, All-Star, NBA Cup) restano tali: tradurli suonerebbe più
/// strano dell'originale.
class TextosIt extends Textos {
  const TextosIt();

  @override
  String get aceptar => 'Conferma';
  @override
  String get cancelar => 'Annulla';
  @override
  String get cerrar => 'Chiudi';
  @override
  String get guardar => 'Salva';
  @override
  String get continuar => 'Continua';
  @override
  String get si => 'Sì';
  @override
  String get no => 'No';
  @override
  String get cargando => 'Caricamento…';

  @override
  String get nuevaPartida => 'Nuova partita';
  @override
  String get ajustes => 'Impostazioni';
  @override
  String get elegirEquipo => 'Scegli la tua squadra';
  @override
  String get sobrescribir => 'Sovrascrivi';
  @override
  String get ranuraOcupada => 'Questo slot ha già una partita salvata';
  @override
  String get avisoSobrescribir =>
      'Se continui, la partita salvata qui verrà cancellata.';

  @override
  String get modoOscuro => 'Modalità scura';
  @override
  String get modoOscuroDetalle => 'Grigi e neri invece dei bianchi accesi';
  @override
  String get idioma => 'Lingua';
  @override
  String get idiomaDetalle => 'La lingua di tutto il gioco';

  @override
  String get calendario => 'Calendario';
  @override
  String get calendarioDetalle => 'Guarda la stagione e simula le partite';
  @override
  String get tuEquipo => 'La tua squadra';
  @override
  String get tuEquipoDetalle => 'Roster e quintetto';
  @override
  String get entrenador => 'Allenatore';
  @override
  String get banquilloVacante => 'La tua panchina è libera';
  @override
  String get clasificacion => 'Classifica';
  @override
  String get clasificacionDetalle => 'Squadre e leader statistici';
  @override
  String get mercado => 'Mercato';
  @override
  String get traspasos => 'Scambi';
  @override
  String get traspasosDetalle => 'Tratta scambi con il resto della lega';
  @override
  String get ofertasRecibidas => 'Offerte ricevute';
  @override
  String get agenciaLibre => 'Free agency';
  @override
  String get agenciaLibreDetalle => 'Giocatori svincolati e spazio salariale';
  @override
  String get competicion => 'Competizione';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Votazione, All-Star Game e MVP';
  @override
  String get resumenTemporada => 'Riepilogo della stagione';
  @override
  String get resumenTemporadaDetalle => 'Record, tutte le partite e le medie';
  @override
  String get playoffs => 'Playoff';
  @override
  String get premios => 'Premi';
  @override
  String get legado => 'Eredità';

  @override
  String get record => 'Record';
  @override
  String get masaSalarial => 'Monte ingaggi';
  @override
  String get temporada => 'Stagione';

  @override
  String get sinEntrenador => 'Senza allenatore';
  @override
  String get sinEntrenadorDetalle =>
      'La tua squadra gioca senza allenatore. Ingaggia qualcuno dalla lista qui sotto.';
  @override
  String get despedir => 'Esonerare';
  @override
  String get contratar => 'Ingaggiare';
  @override
  String get negociar => 'Tratta';
  @override
  String get ofrecer => 'Offri';
  @override
  String get sueldo => 'Stipendio';
  @override
  String get duracion => 'Durata';
  @override
  String get ataque => 'Attacco';
  @override
  String get defensa => 'Difesa';
  @override
  String get desarrollo => 'Sviluppo';
  @override
  String get equilibrado => 'Equilibrato';
  @override
  String get especialistaAtaque => 'Specialista d\'attacco';
  @override
  String get especialistaDefensa => 'Specialista di difesa';
  @override
  String get formadorDeJovenes => 'Formatore di giovani';
  @override
  String get loQuePuedesOfrecer => 'Quello che puoi offrire';
  @override
  String get topeDeLaFranquicia => 'Tetto della franchigia';
  @override
  String get finiquitos => 'Buonuscite degli allenatori esonerati';
  @override
  String get aceptariaLaOferta => 'Accetterebbe questa offerta.';
  @override
  String get todaviaNo =>
      'Non ancora. Con più soldi o più anni potrebbe cambiare idea.';
  @override
  String get noVaAAceptar =>
      'Non accetterà: il tuo progetto è troppo lontano e i soldi non bastano.';

  @override
  String anios(int n) => n == 1 ? '1 stagione' : '$n stagioni';
  @override
  String alAnio(String importe) => '$importe all\'anno';
}
