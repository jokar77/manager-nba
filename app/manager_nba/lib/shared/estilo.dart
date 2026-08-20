import 'package:flutter/material.dart';

import 'contraste.dart';

/// La paleta y las formas del juego, en un único sitio.
///
/// El aspecto es el de un menú de videojuego deportivo: fondo plano, paneles
/// con la esquina cortada, rótulos en mayúsculas muy espaciadas y la media de
/// cada jugador como una placa de color. Nada de eso lo da Material por
/// defecto, así que se define aquí y las pantallas rediseñadas lo consumen —
/// en vez de que cada una se invente sus grises.
///
/// **Vale para los dos modos.** El claro no es el oscuro invertido: lo que se
/// conserva es la estructura (los cortes, las mayúsculas, la franja del
/// marcador, el color del equipo mandando en la cabecera) y lo que cambia es
/// el suelo y la tinta. La cabecera de equipo se queda con el color del club
/// en los dos, porque eso es identidad y no decoración.
class Estilo {
  /// El suelo de la pantalla.
  final Color fondo;

  /// Los paneles que se levantan del suelo: fichas del menú, bloques de
  /// puesto en la alineación.
  final Color panel;

  /// Las filas de acceso, un punto por debajo de [panel].
  final Color panelSuave;

  /// Lo bloqueado (playoffs antes de tiempo, la NBA Cup sin fase de grupos).
  final Color panelApagado;

  /// La franja de datos que va pegada bajo la cabecera del equipo.
  final Color marcador;

  final Color linea;
  final Color lineaFuerte;

  final Color texto;
  final Color textoTenue;

  /// El de los rótulos en mayúsculas pequeñas.
  final Color textoRotulo;

  /// Verde de "vas bien" (puesto de playoffs) y rojo de "ojo" (fuera de
  /// puestos, pasado de tope salarial, lesionado).
  final Color bien;
  final Color mal;

  /// El acento del juego para las pantallas que todavía no tienen equipo:
  /// el menú de inicio y la elección de club. Dentro de una franquicia
  /// manda el color del club, no este.
  final Color marca;

  /// Fondo y tinta de la placa de media, por tramos. Ver [placaDeMedia].
  final List<TramoDeMedia> tramos;

  const Estilo._({
    required this.fondo,
    required this.panel,
    required this.panelSuave,
    required this.panelApagado,
    required this.marcador,
    required this.linea,
    required this.lineaFuerte,
    required this.texto,
    required this.textoTenue,
    required this.textoRotulo,
    required this.bien,
    required this.mal,
    required this.marca,
    required this.tramos,
  });

  static const oscuro = Estilo._(
    fondo: Color(0xFF0A0C10),
    panel: Color(0xFF141922),
    panelSuave: Color(0xFF12161E),
    panelApagado: Color(0xFF0E1219),
    marcador: Color(0xFF05070B),
    linea: Color(0x12FFFFFF),
    lineaFuerte: Color(0x1AFFFFFF),
    texto: Color(0xFFF2F5F9),
    textoTenue: Color(0x8CF2F5F9),
    textoRotulo: Color(0x73F2F5F9),
    bien: Color(0xFF5FD98D),
    mal: Color(0xFFFF8A8E),
    marca: Color(0xFFF08A4B),
    tramos: [
      TramoDeMedia(90, Color(0xFFF2C037), Color(0xFF17120A)),
      TramoDeMedia(85, Color(0xFF48C98A), Color(0xFF06180F)),
      TramoDeMedia(80, Color(0xFFA9B4C2), Color(0xFF0A0F16)),
      TramoDeMedia(0, Color(0xFF59616D), Color(0xFFE7ECF3)),
    ],
  );

  static const claro = Estilo._(
    fondo: Color(0xFFE8EAEE),
    panel: Color(0xFFFFFFFF),
    panelSuave: Color(0xFFFAFBFD),
    panelApagado: Color(0xFFEDEFF3),
    marcador: Color(0xFFFFFFFF),
    linea: Color(0x1A10141B),
    lineaFuerte: Color(0x2610141B),
    texto: Color(0xFF10141B),
    textoTenue: Color(0x9E10141B),
    textoRotulo: Color(0x8A10141B),
    bien: Color(0xFF1E8A55),
    mal: Color(0xFFC0353A),
    marca: Color(0xFFA8410E),
    tramos: [
      TramoDeMedia(90, Color(0xFFE0A81E), Color(0xFF1A1405)),
      // El verde y el gris van más oscuros de lo que pedía el ojo: con los
      // tonos de antes el blanco encima se quedaba en 3,2 y 4,3 de
      // contraste, por debajo del 4,5 que hace falta para texto pequeño.
      TramoDeMedia(85, Color(0xFF127A48), Color(0xFFFFFFFF)),
      TramoDeMedia(80, Color(0xFF5A6675), Color(0xFFFFFFFF)),
      TramoDeMedia(0, Color(0xFFAEB6C2), Color(0xFF1A1F27)),
    ],
  );

  static Estilo de(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? oscuro : claro;

  /// Los colores de la placa de la media de un jugador.
  ///
  /// El tramo se ve antes que el número: de un vistazo sabes si una
  /// plantilla tiene estrellas o relleno sin leer catorce cifras.
  ({Color fondo, Color texto}) placaDeMedia(int media) {
    for (final tramo in tramos) {
      if (media >= tramo.desde) {
        return (fondo: tramo.fondo, texto: tramo.texto);
      }
    }
    return (fondo: tramos.last.fondo, texto: tramos.last.texto);
  }
}

/// Un tramo de la escala de medias: desde qué número aplica y con qué
/// colores se pinta la placa.
class TramoDeMedia {
  /// Media mínima del tramo.
  final int desde;
  final Color fondo;
  final Color texto;

  const TramoDeMedia(this.desde, this.fondo, this.texto);
}

/// La tipografía de los titulares: condensada, para que quepan nombres
/// largos en mayúsculas sin encoger la letra.
///
/// Va empaquetada (`assets/fonts`, declarada en `pubspec.yaml`) y no
/// descargada en tiempo de ejecución: el juego tiene que verse igual sin
/// conexión y sin que la primera pantalla parpadee al cambiar de fuente.
/// Solo se traen los pesos 700 y 800, que son los únicos que se usan.
///
/// Es el único sitio donde se nombra: cambiarla aquí la cambia en todo el
/// rediseño.
const String familiaTitular = 'Saira Condensed';

/// Mayúsculas para rótulos y titulares.
///
/// En Flutter no existe el `text-transform` de CSS, así que la conversión es
/// de la cadena. Se hace aquí y no a mano en cada sitio para que sea una sola
/// decisión y se pueda deshacer de una vez.
String mayus(String texto) => texto.toUpperCase();

/// Rótulo pequeño en mayúsculas espaciadas: "RÉCORD", "TITULAR", "MERCADO".
TextStyle rotulo(Estilo e, {Color? color, double tamano = 10}) => TextStyle(
      fontSize: tamano,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: color ?? e.textoRotulo,
    );

/// Titular condensado: el nombre de un destino del menú, el de un jugador,
/// el del puesto.
TextStyle titular(Estilo e, {Color? color, double tamano = 17}) => TextStyle(
      fontFamily: familiaTitular,
      fontSize: tamano,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      height: 1.08,
      color: color ?? e.texto,
    );

/// Una cifra grande de marcador: el récord, el puesto, la masa salarial.
TextStyle cifra(Estilo e, {Color? color, double tamano = 26}) => TextStyle(
      fontFamily: familiaTitular,
      fontSize: tamano,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.2,
      height: 1.05,
      color: color ?? e.texto,
    );

/// Recorta la esquina inferior derecha en diagonal.
///
/// Es la forma que se repite en todo el rediseño —fichas, filas, botones— y
/// lo que hace que un panel se lea como de videojuego y no como una tarjeta
/// de Material.
class EsquinaCortada extends CustomClipper<Path> {
  final double corte;

  const EsquinaCortada({this.corte = 12});

  @override
  Path getClip(Size size) {
    // Si el panel es más pequeño que el corte (puede pasar mientras se
    // anima o en un alto muy justo), se recorta lo que quepa en vez de
    // dibujar un polígono del revés.
    final c = corte.clamp(0.0, size.shortestSide);
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(EsquinaCortada anterior) => anterior.corte != corte;
}

/// Panel con la esquina cortada y, si se pide, una barra de color pegada al
/// borde izquierdo (el código de color de cada destino del menú).
class PanelCortado extends StatelessWidget {
  final Widget child;
  final Color fondo;
  final Color? barraIzquierda;
  final double corte;
  final Border? borde;

  const PanelCortado({
    super.key,
    required this.child,
    required this.fondo,
    this.barraIzquierda,
    this.corte = 12,
    this.borde,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: EsquinaCortada(corte: corte),
      child: Container(
        decoration: BoxDecoration(
          color: fondo,
          border: borde ??
              (barraIzquierda == null
                  ? null
                  : Border(
                      left: BorderSide(color: barraIzquierda!, width: 3))),
        ),
        child: child,
      ),
    );
  }
}

/// La cuña de color que va en la esquina superior derecha de las cabeceras.
class CunaEsquina extends StatelessWidget {
  final Color color;
  final double tamano;
  final double opacidad;

  const CunaEsquina({
    super.key,
    required this.color,
    this.tamano = 132,
    this.opacidad = 0.14,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipPath(
        clipper: const _TrianguloSuperiorDerecho(),
        child: Container(
          width: tamano,
          height: tamano,
          color: color.withValues(alpha: opacidad),
        ),
      ),
    );
  }
}

class _TrianguloSuperiorDerecho extends CustomClipper<Path> {
  const _TrianguloSuperiorDerecho();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, 0)
    ..close();

  @override
  bool shouldReclip(_TrianguloSuperiorDerecho anterior) => false;
}

/// La placa cuadrada del equipo: el cuadrado partido en diagonal con sus dos
/// colores y el código encima. Sustituye al círculo de `EquipoLogo` en las
/// pantallas rediseñadas — la esquina recta pega con el resto.
class PlacaEquipo extends StatelessWidget {
  final String codigo;
  final Color primario;
  final Color secundario;
  final double tamano;

  const PlacaEquipo({
    super.key,
    required this.codigo,
    required this.primario,
    required this.secundario,
    this.tamano = 54,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: primario,
              border: Border.all(color: Colors.white24),
            ),
          ),
          ClipPath(
            clipper: const _TrianguloInferiorIzquierdo(),
            child: Container(color: secundario),
          ),
          // Por debajo de 24 px el código saldría a 8 px o menos, así que
          // se queda solo el cuadrado partido: en una lista densa lo que
          // identifica al equipo son sus dos colores, no tres letras
          // ilegibles.
          if (tamano >= 24)
            Center(
              child: Text(
                codigo,
                style: TextStyle(
                  fontFamily: familiaTitular,
                  fontSize: tamano * 0.34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  // Blanco puro sobre los dos triángulos: con el color del
                  // equipo detrás, cualquier tinta fija falla en la mitad
                  // de los equipos, y aquí el fondo son DOS colores a la
                  // vez.
                  color: Colors.white,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 3),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrianguloInferiorIzquierdo extends CustomClipper<Path> {
  const _TrianguloInferiorIzquierdo();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_TrianguloInferiorIzquierdo anterior) => false;
}

/// El monograma enorme y casi transparente que va de fondo en las cabeceras.
class MonogramaFantasma extends StatelessWidget {
  final String texto;
  final double tamano;
  final Color color;
  final double opacidad;

  const MonogramaFantasma({
    super.key,
    required this.texto,
    this.tamano = 132,
    this.color = Colors.white,
    this.opacidad = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Text(
        texto,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: TextStyle(
          fontFamily: familiaTitular,
          fontSize: tamano,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: -tamano * 0.03,
          color: color.withValues(alpha: opacidad),
        ),
      ),
    );
  }
}

/// Cabecera de sección del menú: tick de color, rótulo y filete hasta el
/// borde.
class SeparadorSeccion extends StatelessWidget {
  final String titulo;
  final Color acento;

  const SeparadorSeccion({
    super.key,
    required this.titulo,
    required this.acento,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return Row(
      children: [
        Container(width: 3, height: 12, color: acento),
        const SizedBox(width: 9),
        Text(mayus(titulo), style: rotulo(e, tamano: 10)),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: e.lineaFuerte)),
      ],
    );
  }
}

/// La placa de media de un jugador, con el color de su tramo.
class PlacaMedia extends StatelessWidget {
  final int media;
  final double tamano;

  /// Los lesionados se apagan sin perder el color del tramo: se sigue
  /// sabiendo lo bueno que es el que no puede jugar.
  final bool apagada;

  const PlacaMedia({
    super.key,
    required this.media,
    this.tamano = 46,
    this.apagada = false,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Estilo.de(context).placaDeMedia(media);
    return Opacity(
      opacity: apagada ? 0.55 : 1,
      child: ClipPath(
        clipper: EsquinaCortada(corte: tamano * 0.2),
        child: Container(
          width: tamano,
          height: tamano,
          color: colores.fondo,
          alignment: Alignment.center,
          child: Text(
            '$media',
            style: TextStyle(
              fontFamily: familiaTitular,
              fontSize: tamano * 0.52,
              fontWeight: FontWeight.w800,
              height: 1,
              color: colores.texto,
            ),
          ),
        ),
      ),
    );
  }
}

/// El corte de la esquina inferior derecha, como forma de botón.
///
/// `BeveledRectangleBorder` con radio en una sola esquina da exactamente la
/// diagonal del diseño, y de paso recorta bien el chapoteo del InkWell —
/// cosa que un ClipPath por fuera no hace.
OutlinedBorder _formaCortada(double corte) => BeveledRectangleBorder(
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(corte)),
    );

/// La acción principal de una pantalla: bloque de color con la esquina
/// cortada.
///
/// Por dentro es un `FilledButton` de Material y no una pieza hecha a mano:
/// así se conservan el foco con teclado, el estado apagado y la semántica
/// que lee un lector de pantalla, y lo único propio es la forma y la letra.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final Color color;
  final VoidCallback? onTap;
  final double alto;

  /// Los rótulos de interfaz van en mayúsculas; las frases del guion, no.
  /// Gritarle al jugador "ACEPTAR LA CENA DEL EQUIPO" no es diseño, es
  /// ruido: en un texto largo las mayúsculas cuestan de leer.
  final bool mayusculas;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.color,
    required this.onTap,
    this.icono,
    this.alto = 54,
    this.mayusculas = true,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return SizedBox(
      height: alto,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textoSobre(color),
          disabledBackgroundColor: e.panelApagado,
          disabledForegroundColor: e.textoRotulo,
          shape: _formaCortada(alto * 0.22),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: TextStyle(
            fontFamily: familiaTitular,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        child: _EtiquetaDeBoton(
            texto: texto,
            icono: icono,
            tamano: 20,
            mayusculas: mayusculas),
      ),
    );
  }
}

/// Lo que no es la acción principal: mismo corte, solo contorno.
class BotonPerfilado extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final Color color;
  final VoidCallback? onTap;
  final double alto;

  /// Los rótulos de interfaz van en mayúsculas; las frases del guion, no.
  /// Gritarle al jugador "ACEPTAR LA CENA DEL EQUIPO" no es diseño, es
  /// ruido: en un texto largo las mayúsculas cuestan de leer.
  final bool mayusculas;

  const BotonPerfilado({
    super.key,
    required this.texto,
    required this.color,
    required this.onTap,
    this.icono,
    this.alto = 50,
    this.mayusculas = true,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    return SizedBox(
      height: alto,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: e.textoRotulo,
          side: BorderSide(
              color: (onTap == null ? e.textoRotulo : color)
                  .withValues(alpha: 0.55)),
          shape: _formaCortada(alto * 0.22),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: TextStyle(
            fontFamily: familiaTitular,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        child: _EtiquetaDeBoton(
            texto: texto,
            icono: icono,
            tamano: 17,
            mayusculas: mayusculas),
      ),
    );
  }
}

/// El contenido de los dos botones: icono opcional y el texto en
/// mayúsculas, recortado antes que desbordar.
class _EtiquetaDeBoton extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final double tamano;
  final bool mayusculas;

  const _EtiquetaDeBoton({
    required this.texto,
    required this.icono,
    required this.tamano,
    required this.mayusculas,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icono != null) ...[
          Icon(icono, size: tamano - 2),
          const SizedBox(width: 9),
        ],
        Flexible(
          child: Text(mayusculas ? mayus(texto) : texto,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// La barra superior de una pantalla de dentro de una franquicia: franja
/// con el color del club, su monograma de fondo, la flecha de volver y el
/// título en grande.
///
/// Sustituye al `AppBar` de Material en las pantallas rediseñadas. No es un
/// `PreferredSizeWidget` a propósito: va como primer hijo de un `Column`,
/// no en el hueco de `Scaffold.appBar`, porque debajo suele ir pegada otra
/// franja (el marcador, las pestañas) y con el AppBar quedaban separadas.
class BarraDeTitulo extends StatelessWidget {
  /// Código del equipo, para el monograma de fondo.
  final String codigo;

  final Color primario;
  final Color secundario;
  final String titulo;

  /// Rótulo pequeño encima del título, si hace falta situar.
  final String? sobretitulo;

  final List<Widget> acciones;

  /// Si se puede volver atrás. En false no se pinta la flecha.
  ///
  /// Hace falta para los pasos obligatorios del cambio de temporada
  /// (renovaciones, draft, retirados…): ahí la ruta SÍ se puede descartar,
  /// así que una flecha te dejaría escaparte de algo que el juego da por
  /// hecho. Antes lo resolvía el `automaticallyImplyLeading: false` del
  /// AppBar de Material.
  final bool conVolver;

  const BarraDeTitulo({
    super.key,
    required this.codigo,
    required this.primario,
    required this.secundario,
    required this.titulo,
    this.sobretitulo,
    this.acciones = const [],
    this.conVolver = true,
  });

  @override
  Widget build(BuildContext context) => _ContenidoDeBarra(
        codigo: codigo,
        primario: primario,
        secundario: secundario,
        titulo: titulo,
        sobretitulo: sobretitulo,
        acciones: acciones,
        conVolver: conVolver,
        conSafeArea: true,
      );
}

/// La misma barra, pero para el hueco `appBar:` de un `Scaffold`.
///
/// Existe para poder cambiar el `AppBar` de una pantalla ya escrita sin
/// tener que reordenarle el cuerpo: es un cambio de una línea. Aquí NO se
/// pone SafeArea porque el Scaffold ya le suma por su cuenta el alto de la
/// barra de estado a `preferredSize`.
class BarraDeTituloAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String codigo;
  final Color primario;
  final Color secundario;
  final String titulo;
  final String? sobretitulo;
  final List<Widget> acciones;

  /// Lo que cuelga debajo, normalmente un `TabBar`. Igual que en un
  /// `AppBar` de Material, su alto se suma al de la barra.
  final PreferredSizeWidget? bottom;

  /// Si se puede volver atrás. En false no se pinta la flecha.
  ///
  /// Hace falta para los pasos obligatorios del cambio de temporada
  /// (renovaciones, draft, retirados…): ahí la ruta SÍ se puede descartar,
  /// así que una flecha te dejaría escaparte de algo que el juego da por
  /// hecho. Antes lo resolvía el `automaticallyImplyLeading: false` del
  /// AppBar de Material.
  final bool conVolver;

  const BarraDeTituloAppBar({
    super.key,
    required this.codigo,
    required this.primario,
    required this.secundario,
    required this.titulo,
    this.sobretitulo,
    this.acciones = const [],
    this.bottom,
    this.conVolver = true,
  });

  @override
  Size get preferredSize => Size.fromHeight((sobretitulo == null ? 62 : 74) +
      (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final barra = _ContenidoDeBarra(
      codigo: codigo,
      primario: primario,
      secundario: secundario,
      titulo: titulo,
      sobretitulo: sobretitulo,
      acciones: acciones,
      conVolver: conVolver,
      conSafeArea: false,
    );
    if (bottom == null) return barra;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: barra), bottom!],
    );
  }
}

class _ContenidoDeBarra extends StatelessWidget {
  final String codigo;
  final Color primario;
  final Color secundario;
  final String titulo;
  final String? sobretitulo;
  final List<Widget> acciones;
  final bool conVolver;
  final bool conSafeArea;

  const _ContenidoDeBarra({
    required this.codigo,
    required this.primario,
    required this.secundario,
    required this.titulo,
    required this.sobretitulo,
    required this.acciones,
    required this.conVolver,
    required this.conSafeArea,
  });

  @override
  Widget build(BuildContext context) {
    final sobre = textoSobre(primario);
    final acento = acentoDeEquipo(primario, secundario);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primario, const Color(0xFF05070B)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
              top: 0,
              right: 0,
              child: CunaEsquina(color: acento, tamano: 104)),
          Positioned(
            top: -2,
            right: -6,
            child: MonogramaFantasma(texto: codigo, tamano: 100),
          ),
          _QuizaSafeArea(
            activa: conSafeArea,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 12),
              child: Row(
                children: [
                  if (conVolver)
                    // El `BackButton` de Flutter y no un IconButton a mano:
                    // trae el tooltip ya traducido, el icono que toca en
                    // cada plataforma y el `maybePop` de serie (si la ruta
                    // está marcada como no descartable, no hace nada en vez
                    // de reventar). Además es lo que busca `pageBack()` en
                    // los tests.
                    BackButton(color: sobre)
                  else
                    const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sobretitulo != null) ...[
                          Text(mayus(sobretitulo!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                  color: acento)),
                          const SizedBox(height: 2),
                        ],
                        Text(mayus(titulo),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: familiaTitular,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                color: sobre)),
                      ],
                    ),
                  ),
                  ...acciones,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// El tema de Material construido con esta paleta.
///
/// Existe para que las pantallas que TODAVÍA no están rediseñadas a mano no
/// se queden con el aspecto de Material por defecto: heredan de aquí el
/// suelo, los grises, la letra condensada de los títulos y la esquina
/// cortada de botones, tarjetas y diálogos. No las convierte en el diseño
/// nuevo, pero las deja en el mismo idioma mientras les llega el turno.
ThemeData temaDeApp(Brightness brillo) {
  final e = brillo == Brightness.dark ? Estilo.oscuro : Estilo.claro;
  final esquema = ColorScheme.fromSeed(
    seedColor: e.marca,
    brightness: brillo,
  ).copyWith(surface: e.panel, outline: e.textoRotulo);

  TextStyle enTitular(double tamano, {FontWeight peso = FontWeight.w700}) =>
      TextStyle(
        fontFamily: familiaTitular,
        fontSize: tamano,
        fontWeight: peso,
        letterSpacing: 0.5,
        color: e.texto,
      );

  final formaBotones = _formaCortada(11);

  return ThemeData(
    useMaterial3: true,
    brightness: brillo,
    colorScheme: esquema,
    scaffoldBackgroundColor: e.fondo,
    dividerTheme: DividerThemeData(color: e.linea, space: 1, thickness: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: e.marcador,
      foregroundColor: e.texto,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: enTitular(22, peso: FontWeight.w800),
      // El filete de acento debajo, que es lo que ata el AppBar de Material
      // con las barras propias de las pantallas rediseñadas.
      shape: Border(bottom: BorderSide(color: e.marca, width: 2)),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: enTitular(15),
      unselectedLabelStyle: enTitular(15),
      indicatorColor: e.marca,
      dividerColor: e.linea,
    ),
    cardTheme: CardThemeData(
      color: e.panel,
      elevation: 0,
      shape: BeveledRectangleBorder(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(12)),
        side: BorderSide(color: e.linea),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: e.panel,
      elevation: 0,
      shape: BeveledRectangleBorder(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(14)),
        side: BorderSide(color: e.linea),
      ),
      titleTextStyle: enTitular(20, peso: FontWeight.w800),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
          shape: formaBotones, textStyle: enTitular(16, peso: FontWeight.w800)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          shape: formaBotones, textStyle: enTitular(16, peso: FontWeight.w800)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          shape: formaBotones, textStyle: enTitular(15, peso: FontWeight.w800)),
    ),
    chipTheme: ChipThemeData(
      shape: BeveledRectangleBorder(
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(8)),
        side: BorderSide(color: e.linea),
      ),
      backgroundColor: e.panelSuave,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: e.panel,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: e.lineaFuerte)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: e.lineaFuerte)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: e.marca,
      linearTrackColor: e.panel,
    ),
  );
}

/// SafeArea solo cuando hace falta. Ver [BarraDeTituloAppBar].
class _QuizaSafeArea extends StatelessWidget {
  final bool activa;
  final Widget child;

  const _QuizaSafeArea({required this.activa, required this.child});

  @override
  Widget build(BuildContext context) =>
      activa ? SafeArea(bottom: false, child: child) : child;
}

/// La barra de arriba para las pantallas que NO son de un club: el Hall of
/// Fame, el All-Star, los ajustes, la ficha de un jugador.
///
/// Misma forma que [BarraDeTituloAppBar] pero con el acento del juego en
/// vez del color de un equipo. Sin ella, estas pantallas se quedaban con el
/// `AppBar` de Material al lado de las que sí llevan la franja del club.
class BarraNeutraAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String titulo;
  final List<Widget> acciones;
  final bool conVolver;
  final PreferredSizeWidget? bottom;

  const BarraNeutraAppBar({
    super.key,
    required this.titulo,
    this.acciones = const [],
    this.conVolver = true,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(62 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);

    final barra = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: e.marcador,
        border: Border(bottom: BorderSide(color: e.marca, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 10),
        child: Row(
          children: [
            if (conVolver)
              BackButton(color: e.texto)
            else
              const SizedBox(width: 14),
            Expanded(
              child: Text(mayus(titulo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: familiaTitular,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: e.texto)),
            ),
            ...acciones,
          ],
        ),
      ),
    );

    if (bottom == null) return barra;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: barra), bottom!],
    );
  }
}
