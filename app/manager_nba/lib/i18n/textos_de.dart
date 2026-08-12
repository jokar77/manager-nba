part of 'textos.dart';

/// Deutsch. NBA-Begriffe, die auch die deutschsprachige Presse unübersetzt
/// benutzt (Playoffs, All-Star, NBA Cup, Trade), bleiben stehen — eine
/// Übersetzung würde fremder klingen als das Original.
class TextosDe extends Textos {
  const TextosDe();

  @override
  String get aceptar => 'Bestätigen';
  @override
  String get cancelar => 'Abbrechen';
  @override
  String get cerrar => 'Schließen';
  @override
  String get guardar => 'Speichern';
  @override
  String get continuar => 'Fortfahren';
  @override
  String get si => 'Ja';
  @override
  String get no => 'Nein';
  @override
  String get cargando => 'Wird geladen…';

  @override
  String get nuevaPartida => 'Neues Spiel';
  @override
  String get ajustes => 'Einstellungen';
  @override
  String get elegirEquipo => 'Wähle dein Team';
  @override
  String get sobrescribir => 'Überschreiben';
  @override
  String get ranuraOcupada => 'In diesem Speicherplatz liegt schon ein Spiel';
  @override
  String get avisoSobrescribir =>
      'Wenn du fortfährst, wird der hier gespeicherte Spielstand gelöscht.';

  @override
  String get modoOscuro => 'Dunkelmodus';
  @override
  String get modoOscuroDetalle => 'Grau- und Schwarztöne statt hellem Weiß';
  @override
  String get idioma => 'Sprache';
  @override
  String get idiomaDetalle => 'Die Sprache des ganzen Spiels';

  @override
  String get calendario => 'Spielplan';
  @override
  String get calendarioDetalle => 'Deine Saison ansehen und Spiele simulieren';
  @override
  String get tuEquipo => 'Dein Team';
  @override
  String get tuEquipoDetalle => 'Kader und Aufstellung';
  @override
  String get entrenador => 'Head Coach';
  @override
  String get banquilloVacante => 'Deine Bank ist unbesetzt';
  @override
  String get clasificacion => 'Tabelle';
  @override
  String get clasificacionDetalle => 'Teams und Statistikführende';
  @override
  String get mercado => 'Markt';
  @override
  String get traspasos => 'Trades';
  @override
  String get traspasosDetalle => 'Verhandle Tauschgeschäfte mit der Liga';
  @override
  String get ofertasRecibidas => 'Erhaltene Angebote';
  @override
  String get agenciaLibre => 'Free Agency';
  @override
  String get agenciaLibreDetalle => 'Vereinslose Spieler und Gehaltsspielraum';
  @override
  String get competicion => 'Wettbewerb';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Abstimmung, All-Star Game und MVP';
  @override
  String get resumenTemporada => 'Saisonübersicht';
  @override
  String get resumenTemporadaDetalle => 'Bilanz, alle Spiele und Durchschnitte';
  @override
  String get playoffs => 'Playoffs';
  @override
  String get premios => 'Auszeichnungen';
  @override
  String get legado => 'Vermächtnis';

  @override
  String get record => 'Bilanz';
  @override
  String get masaSalarial => 'Gehaltssumme';
  @override
  String get temporada => 'Saison';

  @override
  String get sinEntrenador => 'Kein Head Coach';
  @override
  String get sinEntrenadorDetalle =>
      'Dein Team spielt ohne Coach. Verpflichte jemanden aus der Liste unten.';
  @override
  String get despedir => 'Entlassen';
  @override
  String get contratar => 'Verpflichten';
  @override
  String get negociar => 'Verhandeln';
  @override
  String get ofrecer => 'Anbieten';
  @override
  String get sueldo => 'Gehalt';
  @override
  String get duracion => 'Laufzeit';
  @override
  String get ataque => 'Angriff';
  @override
  String get defensa => 'Verteidigung';
  @override
  String get desarrollo => 'Entwicklung';
  @override
  String get equilibrado => 'Ausgeglichen';
  @override
  String get especialistaAtaque => 'Angriffsspezialist';
  @override
  String get especialistaDefensa => 'Verteidigungsspezialist';
  @override
  String get formadorDeJovenes => 'Talentförderer';
  @override
  String get loQuePuedesOfrecer => 'Was du bieten kannst';
  @override
  String get topeDeLaFranquicia => 'Obergrenze der Franchise';
  @override
  String get finiquitos => 'Abfindungen entlassener Coaches';
  @override
  String get aceptariaLaOferta => 'Er würde dieses Angebot annehmen.';
  @override
  String get todaviaNo =>
      'Noch nicht. Mit mehr Geld oder mehr Jahren überlegt er es sich vielleicht.';
  @override
  String get noVaAAceptar =>
      'Er wird ablehnen: dein Projekt ist zu weit weg, und Geld ändert daran nichts.';

  @override
  String anios(int n) => n == 1 ? '1 Saison' : '$n Saisons';
  @override
  String alAnio(String importe) => '$importe pro Jahr';
}
