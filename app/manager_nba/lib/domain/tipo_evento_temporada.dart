/// Fechas especiales de la temporada que se marcan en el calendario y no
/// son un partido tuyo. El `name` de cada valor es lo que se guarda en
/// `EventosTemporada.tipo`.
enum TipoEventoTemporada {
  finAgenciaLibre,
  fechaLimiteTraspasos,
  allStar;

  static TipoEventoTemporada desdeNombre(String nombre) {
    return TipoEventoTemporada.values.firstWhere((v) => v.name == nombre);
  }
}
