part of 'textos.dart';

/// Français. On garde les termes NBA que la presse francophone emploie tels
/// quels (playoffs, All-Star, NBA Cup) : les traduire ferait plus étrange
/// que les laisser.
class TextosFr extends Textos {
  const TextosFr();

  @override
  String get aceptar => 'Accepter';
  @override
  String get cancelar => 'Annuler';
  @override
  String get cerrar => 'Fermer';
  @override
  String get guardar => 'Enregistrer';
  @override
  String get continuar => 'Continuer';
  @override
  String get si => 'Oui';
  @override
  String get no => 'Non';
  @override
  String get cargando => 'Chargement…';

  @override
  String get nuevaPartida => 'Nouvelle partie';
  @override
  String get ajustes => 'Réglages';
  @override
  String get elegirEquipo => 'Choisis ton équipe';
  @override
  String get sobrescribir => 'Écraser';
  @override
  String get ranuraOcupada => 'Cet emplacement contient déjà une partie';
  @override
  String get avisoSobrescribir =>
      'Si tu continues, la partie enregistrée ici sera supprimée.';

  @override
  String get modoOscuro => 'Mode sombre';
  @override
  String get modoOscuroDetalle => 'Des gris et des noirs au lieu de blancs vifs';
  @override
  String get idioma => 'Langue';
  @override
  String get idiomaDetalle => 'La langue de tout le jeu';

  @override
  String get calendario => 'Calendrier';
  @override
  String get calendarioDetalle => 'Vois ta saison et simule des matchs';
  @override
  String get tuEquipo => 'Ton équipe';
  @override
  String get tuEquipoDetalle => 'Effectif et cinq de départ';
  @override
  String get entrenador => 'Entraîneur';
  @override
  String get banquilloVacante => 'Ton banc est vacant';
  @override
  String get clasificacion => 'Classement';
  @override
  String get clasificacionDetalle => 'Équipes et meilleurs statisticiens';
  @override
  String get mercado => 'Marché';
  @override
  String get traspasos => 'Transferts';
  @override
  String get traspasosDetalle => 'Négocie des échanges avec le reste de la ligue';
  @override
  String get ofertasRecibidas => 'Offres reçues';
  @override
  String get agenciaLibre => 'Agence libre';
  @override
  String get agenciaLibreDetalle => 'Joueurs sans équipe et marge salariale';
  @override
  String get competicion => 'Compétition';
  @override
  String get nbaCup => 'NBA Cup';
  @override
  String get allStar => 'All-Star';
  @override
  String get allStarDetalle => 'Vote, match des étoiles et MVP';
  @override
  String get resumenTemporada => 'Résumé de la saison';
  @override
  String get resumenTemporadaDetalle => 'Bilan, tous tes matchs et tes moyennes';
  @override
  String get playoffs => 'Playoffs';
  @override
  String get premios => 'Trophées';
  @override
  String get legado => 'Héritage';

  @override
  String get record => 'Bilan';
  @override
  String get masaSalarial => 'Masse salariale';
  @override
  String get temporada => 'Saison';

  @override
  String get sinEntrenador => 'Sans entraîneur';
  @override
  String get sinEntrenadorDetalle =>
      'Ton équipe joue sans entraîneur. Recrute quelqu\'un dans la liste ci-dessous.';
  @override
  String get despedir => 'Licencier';
  @override
  String get contratar => 'Recruter';
  @override
  String get negociar => 'Négocier';
  @override
  String get ofrecer => 'Proposer';
  @override
  String get sueldo => 'Salaire';
  @override
  String get duracion => 'Durée';
  @override
  String get ataque => 'Attaque';
  @override
  String get defensa => 'Défense';
  @override
  String get desarrollo => 'Formation';
  @override
  String get equilibrado => 'Équilibré';
  @override
  String get especialistaAtaque => 'Spécialiste de l\'attaque';
  @override
  String get especialistaDefensa => 'Spécialiste de la défense';
  @override
  String get formadorDeJovenes => 'Formateur de jeunes';
  @override
  String get loQuePuedesOfrecer => 'Ce que tu peux proposer';
  @override
  String get topeDeLaFranquicia => 'Plafond de la franchise';
  @override
  String get finiquitos => 'Indemnités des entraîneurs licenciés';
  @override
  String get aceptariaLaOferta => 'Il accepterait cette offre.';
  @override
  String get todaviaNo =>
      'Pas encore. Avec plus d\'argent ou plus d\'années, il pourrait changer d\'avis.';
  @override
  String get noVaAAceptar =>
      'Il n\'acceptera pas : ton projet est trop loin et l\'argent n\'y changera rien.';

  @override
  String anios(int n) => n == 1 ? '1 saison' : '$n saisons';
  @override
  String alAnio(String importe) => '$importe par an';
}
