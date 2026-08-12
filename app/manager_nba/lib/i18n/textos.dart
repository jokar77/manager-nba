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
}
