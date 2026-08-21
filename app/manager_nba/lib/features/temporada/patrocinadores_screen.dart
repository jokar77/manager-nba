import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';
import '../../domain/patrocinadores.dart';
import '../../domain/patrocinadores_repository.dart';
import '../../domain/salarios.dart' show formatearSalario;
import '../../i18n/textos.dart';
import '../../shared/barra_de_club.dart';
import '../../shared/estilo.dart';

/// Un icono por categoría, para reconocerlas de un vistazo sin tener que
/// leer la etiqueta cada vez.
const _iconoPorCategoria = <String, IconData>{
  'estadio': Icons.stadium,
  'camiseta': Icons.checkroom,
  'bebida': Icons.local_drink,
  'ocio': Icons.park,
};

String _etiquetaDe(BuildContext context, String categoria) {
  final textos = t(context);
  switch (categoria) {
    case 'estadio':
      return textos.patrocinioEstadioLabel;
    case 'camiseta':
      return textos.patrocinioCamisetaLabel;
    case 'bebida':
      return textos.patrocinioBebidaLabel;
    default:
      return textos.patrocinioOcioLabel;
  }
}

/// La pretemporada te deja elegir qué patrocinios firma la franquicia este
/// año: el pabellón, la camiseta, la bebida oficial y el de ocio. Cada uno
/// activo suma margen de tope salarial (ver `bonusSalarialDePatrocinadores`
/// en `patrocinadores_repository.dart`); se decide de nuevo cada temporada,
/// no se hereda solo.
///
/// Y cada uno PIDE algo a cambio, que se enseña en su tarjeta al lado del
/// dinero. Sin eso esto no era una pantalla de decisiones: cuatro
/// interruptores que solo dan dinero se encienden los cuatro y ya está.
/// Ver `compromisoPorCategoria` en `patrocinadores.dart`.
class PatrocinadoresScreen extends StatefulWidget {
  final AppDatabase db;
  final String equipoUsuario;
  final VoidCallback onContinuar;

  const PatrocinadoresScreen({
    super.key,
    required this.db,
    required this.equipoUsuario,
    required this.onContinuar,
  });

  @override
  State<PatrocinadoresScreen> createState() => _PatrocinadoresScreenState();
}

class _PatrocinadoresScreenState extends State<PatrocinadoresScreen> {
  Set<String>? _activos;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final activos = await leerPatrociniosActivos(widget.db);
    if (!mounted) return;
    setState(() => _activos = activos);
  }

  Future<void> _alternar(String categoria, bool activo) async {
    // Optimista: se actualiza la pantalla al toque y se confirma con la
    // base después. Un patrocinio no tiene animación de carga que valga
    // la pena esperar.
    setState(() {
      if (activo) {
        _activos!.add(categoria);
      } else {
        _activos!.remove(categoria);
      }
    });
    await alternarPatrocinio(widget.db, categoria, activo: activo);
  }

  /// Cierra la pantalla dejando puestos los compromisos de lo que hayas
  /// firmado. Se hace al confirmar y no en cada toque del interruptor: así
  /// puedes probar combinaciones sin que cada una deje rastro, y lo que
  /// cuenta es con lo que sales de aquí.
  Future<void> _confirmar() async {
    await aplicarCompromisosDePatrocinio(widget.db,
        equipoUsuario: widget.equipoUsuario);
    if (!mounted) return;
    widget.onContinuar();
  }

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final activos = _activos;

    return Scaffold(
      appBar: barraDeClub(
          widget.equipoUsuario, textos.tituloPatrocinadores,
          conVolver: false),
      body: activos == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Text(textos.explicacionPatrocinadores,
                    style: TextStyle(fontSize: 13, color: e.textoTenue)),
                const SizedBox(height: 14),
                for (final categoria in categoriasPatrocinio)
                  _TarjetaPatrocinador(
                    categoria: categoria,
                    patrocinador:
                        patrocinadorDe(widget.equipoUsuario, categoria),
                    activo: activos.contains(categoria),
                    onCambiar: (v) => _alternar(categoria, v),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activos != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    textos.margenPatrocinio(formatearSalario(activos.fold<int>(
                        0,
                        (a, c) =>
                            a +
                            (patrocinadorDe(widget.equipoUsuario, c)
                                    ?.bonusSalarial ??
                                0)))),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: e.bien),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _confirmar,
                  child: Text(textos.continuar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaPatrocinador extends StatelessWidget {
  final String categoria;
  final Patrocinador? patrocinador;
  final bool activo;
  final ValueChanged<bool> onCambiar;

  const _TarjetaPatrocinador({
    required this.categoria,
    required this.patrocinador,
    required this.activo,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    final e = Estilo.de(context);
    final textos = t(context);
    final p = patrocinador;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PanelCortado(
        fondo: e.panel,
        corte: 12,
        borde: Border.all(color: activo ? e.bien : e.linea),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconoPorCategoria[categoria], color: e.textoTenue,
                  size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mayus(_etiquetaDe(context, categoria)),
                        style: rotulo(e, tamano: 9)),
                    const SizedBox(height: 3),
                    if (p != null) ...[
                      Text(p.nombre, style: titular(e, tamano: 16)),
                      const SizedBox(height: 3),
                      Text(textos.fundadoEnAnio(p.fundacion),
                          style:
                              TextStyle(fontSize: 11, color: e.textoTenue)),
                      const SizedBox(height: 3),
                      Text(p.historia,
                          style:
                              TextStyle(fontSize: 12, color: e.textoTenue)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                              '+${formatearSalario(p.bonusSalarial)}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: e.bien)),
                          const SizedBox(width: 12),
                          // Lo que pide a cambio, y AQUÍ, junto al dinero:
                          // un coste que se descubre después de firmar no
                          // es una decisión, es una trampa.
                          Flexible(
                            child: Row(
                              children: [
                                Icon(
                                    p.compromiso.esBueno
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    size: 15,
                                    color:
                                        p.compromiso.esBueno ? e.bien : e.mal),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    t(context).eventos.etiquetaDeEfecto(
                                            p.compromiso.clave) ??
                                        p.compromiso.clave,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: p.compromiso.esBueno
                                            ? e.bien
                                            : e.mal),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                    t(context)
                                        .nPartidos(p.compromiso.partidos),
                                    maxLines: 1,
                                    style: rotulo(e, tamano: 9)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: activo,
                onChanged: p == null ? null : onCambiar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
