import '../domain/entrenadores.dart';
import '../i18n/textos.dart';

/// Traduce el [EstiloDeEntrenador] que calcula el dominio (puro, sin
/// idiomas) al texto que corresponde en el idioma activo.
String etiquetaDeEstilo(Textos textos, EstiloDeEntrenador estilo) =>
    switch (estilo) {
      EstiloDeEntrenador.equilibrado => textos.equilibrado,
      EstiloDeEntrenador.especialistaAtaque => textos.especialistaAtaque,
      EstiloDeEntrenador.especialistaDefensa => textos.especialistaDefensa,
      EstiloDeEntrenador.formadorDeJovenes => textos.formadorDeJovenes,
    };
