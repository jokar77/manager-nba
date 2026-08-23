// Reescribe el catálogo de `lib/domain/patrocinadores.dart` desde los dos
// TSV de `docs/`. Se ejecuta a mano, no en cada compilación:
//
//     dart run tool/generar_patrocinadores.dart
//
// Está en Dart y no en Python como los otros scripts de datos del repo
// porque quien pueda compilar el juego ya tiene el SDK de Dart, y así
// generar el catálogo no pide instalar nada más.
//
// Solo toca lo que hay DEBAJO de la línea marcadora. Todo lo de arriba del
// fichero —las categorías, los bonus, los compromisos, la clase y la
// rotación— está escrito a mano y se respeta tal cual.
import 'dart:io';

const _marcador =
    '// === CATÁLOGO GENERADO — no editar a mano, ver el comentario de '
    'arriba ===';

/// Cuántos caracteres caben en una línea de Dart antes de que `dart format`
/// la parta. Las historias se reparten a mano para no dejarle a `format` un
/// literal de 300 caracteres que no sabe cortar.
const _ancho = 72;

void main() {
  final raiz = _raizDelRepo();
  final hojas = File('$raiz/docs/patrocinadores_hojas.tsv');
  final categorias = File('$raiz/docs/patrocinadores_categorias.tsv');
  final destino = File('$raiz/app/manager_nba/lib/domain/patrocinadores.dart');
  final logos = Directory('$raiz/app/manager_nba/assets/logos');

  for (final f in [hojas, categorias, destino]) {
    if (!f.existsSync()) _morir('no encuentro ${f.path}');
  }

  final categoriaDe = <String, String>{};
  for (final linea in _lineas(categorias)) {
    final campos = linea.split('\t');
    if (campos.length != 2) _morir('categorías: línea rara -> $linea');
    categoriaDe[campos[0]] = campos[1];
  }

  final entradas = <_Entrada>[];
  for (final linea in _lineas(hojas)) {
    final campos = linea.split('\t');
    if (campos.length != 4) _morir('hojas: esperaba 4 columnas -> $linea');
    final clave = '${campos[0]}_${campos[1].padLeft(2, '0')}';
    final categoria = categoriaDe[clave];
    if (categoria == null) _morir('$clave no tiene categoría asignada');
    if (!logos.existsSync() || !File('${logos.path}/$clave.jpg').existsSync()) {
      _morir('$clave no tiene logo en assets/logos/$clave.jpg');
    }
    entradas.add(
      _Entrada(
        equipo: campos[0],
        clave: clave,
        categoria: categoria,
        nombre: campos[2],
        historia: campos[3],
      ),
    );
  }

  // Sin usar, pero se avisa: un logo que no sale en ninguna hoja es peso
  // muerto dentro del .apk.
  final usados = {for (final e in entradas) e.clave};
  final sueltos =
      logos
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last.replaceAll('.jpg', ''))
          .where((c) => !usados.contains(c))
          .toList()
        ..sort();
  if (sueltos.isNotEmpty) {
    stderr.writeln(
      'aviso: ${sueltos.length} logos sin fila en el TSV: '
      '${sueltos.take(5).join(", ")}...',
    );
  }

  entradas.sort((a, b) => a.clave.compareTo(b.clave));

  final texto = destino.readAsStringSync();
  final corte = texto.indexOf(_marcador);
  if (corte < 0) _morir('no encuentro la línea marcadora en ${destino.path}');

  final salida = StringBuffer()
    ..write(texto.substring(0, corte))
    ..writeln(_marcador)
    ..writeln('const catalogoPatrocinadores = <Patrocinador>[');

  String? equipoAnterior;
  for (final e in entradas) {
    if (e.equipo != equipoAnterior) {
      if (equipoAnterior != null) salida.writeln();
      salida.writeln('  // --- ${e.equipo} ---');
      equipoAnterior = e.equipo;
    }
    salida.write(e.aDart());
  }
  salida.writeln('];');

  destino.writeAsStringSync(salida.toString());
  stdout.writeln(
    '${entradas.length} patrocinadores escritos en '
    '${destino.path}',
  );
}

class _Entrada {
  final String equipo;
  final String clave;
  final String categoria;
  final String nombre;
  final String historia;

  _Entrada({
    required this.equipo,
    required this.clave,
    required this.categoria,
    required this.nombre,
    required this.historia,
  });

  /// El año que aparece en la historia. Cuatro de las 386 no lo dicen; para
  /// esas se deja 0 y el test de catálogo lo caza.
  int get fundacion {
    final m = RegExp(r'\b(1[6-9]\d\d|20[0-2]\d)\b').firstMatch(historia);
    return m == null ? 0 : int.parse(m.group(1)!);
  }

  String aDart() {
    final b = StringBuffer()
      ..writeln('  Patrocinador(')
      ..writeln("    equipo: '$equipo',")
      ..writeln("    categoria: '$categoria',")
      ..writeln("    clave: '$clave',")
      ..writeln('    nombre: ${_literal(nombre)},')
      ..writeln('    fundacion: $fundacion,')
      ..write('    historia: ${_troceada(historia, 14)},\n')
      ..writeln('  ),');
    return b.toString();
  }
}

/// Un literal de Dart con comillas simples, escapando lo que haga falta.
String _literal(String s) =>
    "'${s.replaceAll(r'\', r'\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'";

/// Parte un texto largo en varios literales pegados, cortando por espacios,
/// para que ninguna línea pase de [_ancho].
String _troceada(String texto, int sangria) {
  final palabras = texto.split(' ');
  final trozos = <String>[];
  var actual = '';
  for (final palabra in palabras) {
    final cabe = actual.isEmpty ? palabra : '$actual $palabra';
    if (_literal(cabe).length + sangria > _ancho && actual.isNotEmpty) {
      trozos.add('$actual ');
      actual = palabra;
    } else {
      actual = cabe;
    }
  }
  if (actual.isNotEmpty) trozos.add(actual);
  if (trozos.length == 1) return _literal(trozos.single);
  return trozos.map(_literal).join('\n${' ' * (sangria - 2)}');
}

Iterable<String> _lineas(File f) =>
    f.readAsLinesSync().map((l) => l.trimRight()).where((l) => l.isNotEmpty);

/// La raíz del repo, subiendo desde donde se haya lanzado el script.
String _raizDelRepo() {
  var dir = Directory.current;
  for (var i = 0; i < 5; i++) {
    if (Directory('${dir.path}/docs').existsSync() &&
        Directory('${dir.path}/app').existsSync()) {
      return dir.path.replaceAll(r'\', '/');
    }
    dir = dir.parent;
  }
  _morir('lánzalo dentro del repo (no encuentro docs/ ni app/)');
}

Never _morir(String mensaje) {
  stderr.writeln('generar_patrocinadores: $mensaje');
  exit(1);
}
