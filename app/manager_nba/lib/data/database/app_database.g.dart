// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JugadoresTable extends Jugadores
    with TableInfo<$JugadoresTable, Jugador> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JugadoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreFicticioMeta = const VerificationMeta(
    'nombreFicticio',
  );
  @override
  late final GeneratedColumn<String> nombreFicticio = GeneratedColumn<String>(
    'nombre_ficticio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreRealMeta = const VerificationMeta(
    'nombreReal',
  );
  @override
  late final GeneratedColumn<String> nombreReal = GeneratedColumn<String>(
    'nombre_real',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posicionMeta = const VerificationMeta(
    'posicion',
  );
  @override
  late final GeneratedColumn<String> posicion = GeneratedColumn<String>(
    'posicion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posicionSecundariaMeta =
      const VerificationMeta('posicionSecundaria');
  @override
  late final GeneratedColumn<String> posicionSecundaria =
      GeneratedColumn<String>(
        'posicion_secundaria',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _edadMeta = const VerificationMeta('edad');
  @override
  late final GeneratedColumn<int> edad = GeneratedColumn<int>(
    'edad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaMeta = const VerificationMeta('media');
  @override
  late final GeneratedColumn<int> media = GeneratedColumn<int>(
    'media',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _potencialMeta = const VerificationMeta(
    'potencial',
  );
  @override
  late final GeneratedColumn<int> potencial = GeneratedColumn<int>(
    'potencial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atrTiro3Meta = const VerificationMeta(
    'atrTiro3',
  );
  @override
  late final GeneratedColumn<int> atrTiro3 = GeneratedColumn<int>(
    'atr_tiro3',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atrAtaqueMeta = const VerificationMeta(
    'atrAtaque',
  );
  @override
  late final GeneratedColumn<int> atrAtaque = GeneratedColumn<int>(
    'atr_ataque',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atrDefensaMeta = const VerificationMeta(
    'atrDefensa',
  );
  @override
  late final GeneratedColumn<int> atrDefensa = GeneratedColumn<int>(
    'atr_defensa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ptsPgMeta = const VerificationMeta('ptsPg');
  @override
  late final GeneratedColumn<double> ptsPg = GeneratedColumn<double>(
    'pts_pg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _astPgMeta = const VerificationMeta('astPg');
  @override
  late final GeneratedColumn<double> astPg = GeneratedColumn<double>(
    'ast_pg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trbPgMeta = const VerificationMeta('trbPg');
  @override
  late final GeneratedColumn<double> trbPg = GeneratedColumn<double>(
    'trb_pg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factorLongevidadMeta = const VerificationMeta(
    'factorLongevidad',
  );
  @override
  late final GeneratedColumn<double> factorLongevidad = GeneratedColumn<double>(
    'factor_longevidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _edadRetiroMeta = const VerificationMeta(
    'edadRetiro',
  );
  @override
  late final GeneratedColumn<int> edadRetiro = GeneratedColumn<int>(
    'edad_retiro',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _draftYearMeta = const VerificationMeta(
    'draftYear',
  );
  @override
  late final GeneratedColumn<int> draftYear = GeneratedColumn<int>(
    'draft_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retiradoMeta = const VerificationMeta(
    'retirado',
  );
  @override
  late final GeneratedColumn<bool> retirado = GeneratedColumn<bool>(
    'retirado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("retirado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dorsalMeta = const VerificationMeta('dorsal');
  @override
  late final GeneratedColumn<int> dorsal = GeneratedColumn<int>(
    'dorsal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temporadasPreviasMeta = const VerificationMeta(
    'temporadasPrevias',
  );
  @override
  late final GeneratedColumn<int> temporadasPrevias = GeneratedColumn<int>(
    'temporadas_previas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _salarioMeta = const VerificationMeta(
    'salario',
  );
  @override
  late final GeneratedColumn<int> salario = GeneratedColumn<int>(
    'salario',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aniosContratoMeta = const VerificationMeta(
    'aniosContrato',
  );
  @override
  late final GeneratedColumn<int> aniosContrato = GeneratedColumn<int>(
    'anios_contrato',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _ofertasRechazadasMeta = const VerificationMeta(
    'ofertasRechazadas',
  );
  @override
  late final GeneratedColumn<int> ofertasRechazadas = GeneratedColumn<int>(
    'ofertas_rechazadas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _prestigioPrevioMeta = const VerificationMeta(
    'prestigioPrevio',
  );
  @override
  late final GeneratedColumn<double> prestigioPrevio = GeneratedColumn<double>(
    'prestigio_previo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombreFicticio,
    nombreReal,
    posicion,
    posicionSecundaria,
    equipo,
    edad,
    media,
    potencial,
    atrTiro3,
    atrAtaque,
    atrDefensa,
    ptsPg,
    astPg,
    trbPg,
    factorLongevidad,
    edadRetiro,
    draftYear,
    retirado,
    dorsal,
    temporadasPrevias,
    salario,
    aniosContrato,
    ofertasRechazadas,
    prestigioPrevio,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jugadores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Jugador> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre_ficticio')) {
      context.handle(
        _nombreFicticioMeta,
        nombreFicticio.isAcceptableOrUnknown(
          data['nombre_ficticio']!,
          _nombreFicticioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreFicticioMeta);
    }
    if (data.containsKey('nombre_real')) {
      context.handle(
        _nombreRealMeta,
        nombreReal.isAcceptableOrUnknown(data['nombre_real']!, _nombreRealMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreRealMeta);
    }
    if (data.containsKey('posicion')) {
      context.handle(
        _posicionMeta,
        posicion.isAcceptableOrUnknown(data['posicion']!, _posicionMeta),
      );
    } else if (isInserting) {
      context.missing(_posicionMeta);
    }
    if (data.containsKey('posicion_secundaria')) {
      context.handle(
        _posicionSecundariaMeta,
        posicionSecundaria.isAcceptableOrUnknown(
          data['posicion_secundaria']!,
          _posicionSecundariaMeta,
        ),
      );
    }
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    if (data.containsKey('edad')) {
      context.handle(
        _edadMeta,
        edad.isAcceptableOrUnknown(data['edad']!, _edadMeta),
      );
    } else if (isInserting) {
      context.missing(_edadMeta);
    }
    if (data.containsKey('media')) {
      context.handle(
        _mediaMeta,
        media.isAcceptableOrUnknown(data['media']!, _mediaMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaMeta);
    }
    if (data.containsKey('potencial')) {
      context.handle(
        _potencialMeta,
        potencial.isAcceptableOrUnknown(data['potencial']!, _potencialMeta),
      );
    } else if (isInserting) {
      context.missing(_potencialMeta);
    }
    if (data.containsKey('atr_tiro3')) {
      context.handle(
        _atrTiro3Meta,
        atrTiro3.isAcceptableOrUnknown(data['atr_tiro3']!, _atrTiro3Meta),
      );
    } else if (isInserting) {
      context.missing(_atrTiro3Meta);
    }
    if (data.containsKey('atr_ataque')) {
      context.handle(
        _atrAtaqueMeta,
        atrAtaque.isAcceptableOrUnknown(data['atr_ataque']!, _atrAtaqueMeta),
      );
    } else if (isInserting) {
      context.missing(_atrAtaqueMeta);
    }
    if (data.containsKey('atr_defensa')) {
      context.handle(
        _atrDefensaMeta,
        atrDefensa.isAcceptableOrUnknown(data['atr_defensa']!, _atrDefensaMeta),
      );
    } else if (isInserting) {
      context.missing(_atrDefensaMeta);
    }
    if (data.containsKey('pts_pg')) {
      context.handle(
        _ptsPgMeta,
        ptsPg.isAcceptableOrUnknown(data['pts_pg']!, _ptsPgMeta),
      );
    } else if (isInserting) {
      context.missing(_ptsPgMeta);
    }
    if (data.containsKey('ast_pg')) {
      context.handle(
        _astPgMeta,
        astPg.isAcceptableOrUnknown(data['ast_pg']!, _astPgMeta),
      );
    } else if (isInserting) {
      context.missing(_astPgMeta);
    }
    if (data.containsKey('trb_pg')) {
      context.handle(
        _trbPgMeta,
        trbPg.isAcceptableOrUnknown(data['trb_pg']!, _trbPgMeta),
      );
    } else if (isInserting) {
      context.missing(_trbPgMeta);
    }
    if (data.containsKey('factor_longevidad')) {
      context.handle(
        _factorLongevidadMeta,
        factorLongevidad.isAcceptableOrUnknown(
          data['factor_longevidad']!,
          _factorLongevidadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_factorLongevidadMeta);
    }
    if (data.containsKey('edad_retiro')) {
      context.handle(
        _edadRetiroMeta,
        edadRetiro.isAcceptableOrUnknown(data['edad_retiro']!, _edadRetiroMeta),
      );
    } else if (isInserting) {
      context.missing(_edadRetiroMeta);
    }
    if (data.containsKey('draft_year')) {
      context.handle(
        _draftYearMeta,
        draftYear.isAcceptableOrUnknown(data['draft_year']!, _draftYearMeta),
      );
    }
    if (data.containsKey('retirado')) {
      context.handle(
        _retiradoMeta,
        retirado.isAcceptableOrUnknown(data['retirado']!, _retiradoMeta),
      );
    }
    if (data.containsKey('dorsal')) {
      context.handle(
        _dorsalMeta,
        dorsal.isAcceptableOrUnknown(data['dorsal']!, _dorsalMeta),
      );
    }
    if (data.containsKey('temporadas_previas')) {
      context.handle(
        _temporadasPreviasMeta,
        temporadasPrevias.isAcceptableOrUnknown(
          data['temporadas_previas']!,
          _temporadasPreviasMeta,
        ),
      );
    }
    if (data.containsKey('salario')) {
      context.handle(
        _salarioMeta,
        salario.isAcceptableOrUnknown(data['salario']!, _salarioMeta),
      );
    }
    if (data.containsKey('anios_contrato')) {
      context.handle(
        _aniosContratoMeta,
        aniosContrato.isAcceptableOrUnknown(
          data['anios_contrato']!,
          _aniosContratoMeta,
        ),
      );
    }
    if (data.containsKey('ofertas_rechazadas')) {
      context.handle(
        _ofertasRechazadasMeta,
        ofertasRechazadas.isAcceptableOrUnknown(
          data['ofertas_rechazadas']!,
          _ofertasRechazadasMeta,
        ),
      );
    }
    if (data.containsKey('prestigio_previo')) {
      context.handle(
        _prestigioPrevioMeta,
        prestigioPrevio.isAcceptableOrUnknown(
          data['prestigio_previo']!,
          _prestigioPrevioMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Jugador map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Jugador(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombreFicticio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_ficticio'],
      )!,
      nombreReal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_real'],
      )!,
      posicion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posicion'],
      )!,
      posicionSecundaria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posicion_secundaria'],
      ),
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
      edad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edad'],
      )!,
      media: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media'],
      )!,
      potencial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}potencial'],
      )!,
      atrTiro3: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}atr_tiro3'],
      )!,
      atrAtaque: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}atr_ataque'],
      )!,
      atrDefensa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}atr_defensa'],
      )!,
      ptsPg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pts_pg'],
      )!,
      astPg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ast_pg'],
      )!,
      trbPg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}trb_pg'],
      )!,
      factorLongevidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}factor_longevidad'],
      )!,
      edadRetiro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edad_retiro'],
      )!,
      draftYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}draft_year'],
      ),
      retirado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}retirado'],
      )!,
      dorsal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dorsal'],
      ),
      temporadasPrevias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporadas_previas'],
      )!,
      salario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salario'],
      )!,
      aniosContrato: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anios_contrato'],
      )!,
      ofertasRechazadas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ofertas_rechazadas'],
      )!,
      prestigioPrevio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prestigio_previo'],
      )!,
    );
  }

  @override
  $JugadoresTable createAlias(String alias) {
    return $JugadoresTable(attachedDatabase, alias);
  }
}

class Jugador extends DataClass implements Insertable<Jugador> {
  final int id;
  final String nombreFicticio;
  final String nombreReal;
  final String posicion;

  /// Segundo puesto que el jugador puede cubrir sin penalización real. El
  /// dataset casi nunca la trae, así que se deriva de su juego al importar
  /// (ver posiciones.dart) — en la NBA real casi todo el mundo puede jugar
  /// el puesto de al lado.
  final String? posicionSecundaria;
  final String equipo;
  final int edad;
  final int media;
  final int potencial;
  final int atrTiro3;
  final int atrAtaque;
  final int atrDefensa;
  final double ptsPg;
  final double astPg;
  final double trbPg;
  final double factorLongevidad;
  final int edadRetiro;
  final int? draftYear;

  /// Los retirados no se borran (siguen en el palmarés y en los premios de
  /// temporadas pasadas): se marcan aquí y su `equipo` pasa a
  /// [equipoRetirados], que ninguna consulta de plantilla busca.
  final bool retirado;

  /// Dorsal. El dataset no lo trae: se asigna al importar y al fichar, único
  /// dentro del equipo y respetando los números ya retirados por esa
  /// franquicia (ver dorsales_repository.dart).
  final int? dorsal;

  /// Temporadas que el jugador ya llevaba jugadas cuando empieza tu
  /// partida, deducidas de su año de draft (o de su edad).
  final int temporadasPrevias;

  /// Salario de esta temporada, en dólares, y años que le quedan de
  /// contrato (incluido este). De los jugadores conocidos son los reales
  /// (assets/data/datos_reales.json); del resto se estiman a partir de su
  /// nivel, calibrados contra esa misma escala.
  final int salario;
  final int aniosContrato;

  /// Ofertas de renovación que ya ha rechazado esta pretemporada. A la
  /// tercera se acabó la negociación: o va a la agencia libre o lo firma
  /// otro. Se pone a cero cuando firma.
  final int ofertasRechazadas;

  /// Crédito de carrera anterior a tu partida, de cara al Hall of Fame.
  ///
  /// Sin esto, las leyendas que ya están al final de su carrera —LeBron,
  /// Curry, Durant— se retirarían habiendo jugado dos temporadas contigo y
  /// no entrarían nunca, porque el juego solo sabe de lo que ha simulado.
  /// Ver hall_fama_repository.dart.
  final double prestigioPrevio;
  const Jugador({
    required this.id,
    required this.nombreFicticio,
    required this.nombreReal,
    required this.posicion,
    this.posicionSecundaria,
    required this.equipo,
    required this.edad,
    required this.media,
    required this.potencial,
    required this.atrTiro3,
    required this.atrAtaque,
    required this.atrDefensa,
    required this.ptsPg,
    required this.astPg,
    required this.trbPg,
    required this.factorLongevidad,
    required this.edadRetiro,
    this.draftYear,
    required this.retirado,
    this.dorsal,
    required this.temporadasPrevias,
    required this.salario,
    required this.aniosContrato,
    required this.ofertasRechazadas,
    required this.prestigioPrevio,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre_ficticio'] = Variable<String>(nombreFicticio);
    map['nombre_real'] = Variable<String>(nombreReal);
    map['posicion'] = Variable<String>(posicion);
    if (!nullToAbsent || posicionSecundaria != null) {
      map['posicion_secundaria'] = Variable<String>(posicionSecundaria);
    }
    map['equipo'] = Variable<String>(equipo);
    map['edad'] = Variable<int>(edad);
    map['media'] = Variable<int>(media);
    map['potencial'] = Variable<int>(potencial);
    map['atr_tiro3'] = Variable<int>(atrTiro3);
    map['atr_ataque'] = Variable<int>(atrAtaque);
    map['atr_defensa'] = Variable<int>(atrDefensa);
    map['pts_pg'] = Variable<double>(ptsPg);
    map['ast_pg'] = Variable<double>(astPg);
    map['trb_pg'] = Variable<double>(trbPg);
    map['factor_longevidad'] = Variable<double>(factorLongevidad);
    map['edad_retiro'] = Variable<int>(edadRetiro);
    if (!nullToAbsent || draftYear != null) {
      map['draft_year'] = Variable<int>(draftYear);
    }
    map['retirado'] = Variable<bool>(retirado);
    if (!nullToAbsent || dorsal != null) {
      map['dorsal'] = Variable<int>(dorsal);
    }
    map['temporadas_previas'] = Variable<int>(temporadasPrevias);
    map['salario'] = Variable<int>(salario);
    map['anios_contrato'] = Variable<int>(aniosContrato);
    map['ofertas_rechazadas'] = Variable<int>(ofertasRechazadas);
    map['prestigio_previo'] = Variable<double>(prestigioPrevio);
    return map;
  }

  JugadoresCompanion toCompanion(bool nullToAbsent) {
    return JugadoresCompanion(
      id: Value(id),
      nombreFicticio: Value(nombreFicticio),
      nombreReal: Value(nombreReal),
      posicion: Value(posicion),
      posicionSecundaria: posicionSecundaria == null && nullToAbsent
          ? const Value.absent()
          : Value(posicionSecundaria),
      equipo: Value(equipo),
      edad: Value(edad),
      media: Value(media),
      potencial: Value(potencial),
      atrTiro3: Value(atrTiro3),
      atrAtaque: Value(atrAtaque),
      atrDefensa: Value(atrDefensa),
      ptsPg: Value(ptsPg),
      astPg: Value(astPg),
      trbPg: Value(trbPg),
      factorLongevidad: Value(factorLongevidad),
      edadRetiro: Value(edadRetiro),
      draftYear: draftYear == null && nullToAbsent
          ? const Value.absent()
          : Value(draftYear),
      retirado: Value(retirado),
      dorsal: dorsal == null && nullToAbsent
          ? const Value.absent()
          : Value(dorsal),
      temporadasPrevias: Value(temporadasPrevias),
      salario: Value(salario),
      aniosContrato: Value(aniosContrato),
      ofertasRechazadas: Value(ofertasRechazadas),
      prestigioPrevio: Value(prestigioPrevio),
    );
  }

  factory Jugador.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Jugador(
      id: serializer.fromJson<int>(json['id']),
      nombreFicticio: serializer.fromJson<String>(json['nombreFicticio']),
      nombreReal: serializer.fromJson<String>(json['nombreReal']),
      posicion: serializer.fromJson<String>(json['posicion']),
      posicionSecundaria: serializer.fromJson<String?>(
        json['posicionSecundaria'],
      ),
      equipo: serializer.fromJson<String>(json['equipo']),
      edad: serializer.fromJson<int>(json['edad']),
      media: serializer.fromJson<int>(json['media']),
      potencial: serializer.fromJson<int>(json['potencial']),
      atrTiro3: serializer.fromJson<int>(json['atrTiro3']),
      atrAtaque: serializer.fromJson<int>(json['atrAtaque']),
      atrDefensa: serializer.fromJson<int>(json['atrDefensa']),
      ptsPg: serializer.fromJson<double>(json['ptsPg']),
      astPg: serializer.fromJson<double>(json['astPg']),
      trbPg: serializer.fromJson<double>(json['trbPg']),
      factorLongevidad: serializer.fromJson<double>(json['factorLongevidad']),
      edadRetiro: serializer.fromJson<int>(json['edadRetiro']),
      draftYear: serializer.fromJson<int?>(json['draftYear']),
      retirado: serializer.fromJson<bool>(json['retirado']),
      dorsal: serializer.fromJson<int?>(json['dorsal']),
      temporadasPrevias: serializer.fromJson<int>(json['temporadasPrevias']),
      salario: serializer.fromJson<int>(json['salario']),
      aniosContrato: serializer.fromJson<int>(json['aniosContrato']),
      ofertasRechazadas: serializer.fromJson<int>(json['ofertasRechazadas']),
      prestigioPrevio: serializer.fromJson<double>(json['prestigioPrevio']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombreFicticio': serializer.toJson<String>(nombreFicticio),
      'nombreReal': serializer.toJson<String>(nombreReal),
      'posicion': serializer.toJson<String>(posicion),
      'posicionSecundaria': serializer.toJson<String?>(posicionSecundaria),
      'equipo': serializer.toJson<String>(equipo),
      'edad': serializer.toJson<int>(edad),
      'media': serializer.toJson<int>(media),
      'potencial': serializer.toJson<int>(potencial),
      'atrTiro3': serializer.toJson<int>(atrTiro3),
      'atrAtaque': serializer.toJson<int>(atrAtaque),
      'atrDefensa': serializer.toJson<int>(atrDefensa),
      'ptsPg': serializer.toJson<double>(ptsPg),
      'astPg': serializer.toJson<double>(astPg),
      'trbPg': serializer.toJson<double>(trbPg),
      'factorLongevidad': serializer.toJson<double>(factorLongevidad),
      'edadRetiro': serializer.toJson<int>(edadRetiro),
      'draftYear': serializer.toJson<int?>(draftYear),
      'retirado': serializer.toJson<bool>(retirado),
      'dorsal': serializer.toJson<int?>(dorsal),
      'temporadasPrevias': serializer.toJson<int>(temporadasPrevias),
      'salario': serializer.toJson<int>(salario),
      'aniosContrato': serializer.toJson<int>(aniosContrato),
      'ofertasRechazadas': serializer.toJson<int>(ofertasRechazadas),
      'prestigioPrevio': serializer.toJson<double>(prestigioPrevio),
    };
  }

  Jugador copyWith({
    int? id,
    String? nombreFicticio,
    String? nombreReal,
    String? posicion,
    Value<String?> posicionSecundaria = const Value.absent(),
    String? equipo,
    int? edad,
    int? media,
    int? potencial,
    int? atrTiro3,
    int? atrAtaque,
    int? atrDefensa,
    double? ptsPg,
    double? astPg,
    double? trbPg,
    double? factorLongevidad,
    int? edadRetiro,
    Value<int?> draftYear = const Value.absent(),
    bool? retirado,
    Value<int?> dorsal = const Value.absent(),
    int? temporadasPrevias,
    int? salario,
    int? aniosContrato,
    int? ofertasRechazadas,
    double? prestigioPrevio,
  }) => Jugador(
    id: id ?? this.id,
    nombreFicticio: nombreFicticio ?? this.nombreFicticio,
    nombreReal: nombreReal ?? this.nombreReal,
    posicion: posicion ?? this.posicion,
    posicionSecundaria: posicionSecundaria.present
        ? posicionSecundaria.value
        : this.posicionSecundaria,
    equipo: equipo ?? this.equipo,
    edad: edad ?? this.edad,
    media: media ?? this.media,
    potencial: potencial ?? this.potencial,
    atrTiro3: atrTiro3 ?? this.atrTiro3,
    atrAtaque: atrAtaque ?? this.atrAtaque,
    atrDefensa: atrDefensa ?? this.atrDefensa,
    ptsPg: ptsPg ?? this.ptsPg,
    astPg: astPg ?? this.astPg,
    trbPg: trbPg ?? this.trbPg,
    factorLongevidad: factorLongevidad ?? this.factorLongevidad,
    edadRetiro: edadRetiro ?? this.edadRetiro,
    draftYear: draftYear.present ? draftYear.value : this.draftYear,
    retirado: retirado ?? this.retirado,
    dorsal: dorsal.present ? dorsal.value : this.dorsal,
    temporadasPrevias: temporadasPrevias ?? this.temporadasPrevias,
    salario: salario ?? this.salario,
    aniosContrato: aniosContrato ?? this.aniosContrato,
    ofertasRechazadas: ofertasRechazadas ?? this.ofertasRechazadas,
    prestigioPrevio: prestigioPrevio ?? this.prestigioPrevio,
  );
  Jugador copyWithCompanion(JugadoresCompanion data) {
    return Jugador(
      id: data.id.present ? data.id.value : this.id,
      nombreFicticio: data.nombreFicticio.present
          ? data.nombreFicticio.value
          : this.nombreFicticio,
      nombreReal: data.nombreReal.present
          ? data.nombreReal.value
          : this.nombreReal,
      posicion: data.posicion.present ? data.posicion.value : this.posicion,
      posicionSecundaria: data.posicionSecundaria.present
          ? data.posicionSecundaria.value
          : this.posicionSecundaria,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
      edad: data.edad.present ? data.edad.value : this.edad,
      media: data.media.present ? data.media.value : this.media,
      potencial: data.potencial.present ? data.potencial.value : this.potencial,
      atrTiro3: data.atrTiro3.present ? data.atrTiro3.value : this.atrTiro3,
      atrAtaque: data.atrAtaque.present ? data.atrAtaque.value : this.atrAtaque,
      atrDefensa: data.atrDefensa.present
          ? data.atrDefensa.value
          : this.atrDefensa,
      ptsPg: data.ptsPg.present ? data.ptsPg.value : this.ptsPg,
      astPg: data.astPg.present ? data.astPg.value : this.astPg,
      trbPg: data.trbPg.present ? data.trbPg.value : this.trbPg,
      factorLongevidad: data.factorLongevidad.present
          ? data.factorLongevidad.value
          : this.factorLongevidad,
      edadRetiro: data.edadRetiro.present
          ? data.edadRetiro.value
          : this.edadRetiro,
      draftYear: data.draftYear.present ? data.draftYear.value : this.draftYear,
      retirado: data.retirado.present ? data.retirado.value : this.retirado,
      dorsal: data.dorsal.present ? data.dorsal.value : this.dorsal,
      temporadasPrevias: data.temporadasPrevias.present
          ? data.temporadasPrevias.value
          : this.temporadasPrevias,
      salario: data.salario.present ? data.salario.value : this.salario,
      aniosContrato: data.aniosContrato.present
          ? data.aniosContrato.value
          : this.aniosContrato,
      ofertasRechazadas: data.ofertasRechazadas.present
          ? data.ofertasRechazadas.value
          : this.ofertasRechazadas,
      prestigioPrevio: data.prestigioPrevio.present
          ? data.prestigioPrevio.value
          : this.prestigioPrevio,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Jugador(')
          ..write('id: $id, ')
          ..write('nombreFicticio: $nombreFicticio, ')
          ..write('nombreReal: $nombreReal, ')
          ..write('posicion: $posicion, ')
          ..write('posicionSecundaria: $posicionSecundaria, ')
          ..write('equipo: $equipo, ')
          ..write('edad: $edad, ')
          ..write('media: $media, ')
          ..write('potencial: $potencial, ')
          ..write('atrTiro3: $atrTiro3, ')
          ..write('atrAtaque: $atrAtaque, ')
          ..write('atrDefensa: $atrDefensa, ')
          ..write('ptsPg: $ptsPg, ')
          ..write('astPg: $astPg, ')
          ..write('trbPg: $trbPg, ')
          ..write('factorLongevidad: $factorLongevidad, ')
          ..write('edadRetiro: $edadRetiro, ')
          ..write('draftYear: $draftYear, ')
          ..write('retirado: $retirado, ')
          ..write('dorsal: $dorsal, ')
          ..write('temporadasPrevias: $temporadasPrevias, ')
          ..write('salario: $salario, ')
          ..write('aniosContrato: $aniosContrato, ')
          ..write('ofertasRechazadas: $ofertasRechazadas, ')
          ..write('prestigioPrevio: $prestigioPrevio')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    nombreFicticio,
    nombreReal,
    posicion,
    posicionSecundaria,
    equipo,
    edad,
    media,
    potencial,
    atrTiro3,
    atrAtaque,
    atrDefensa,
    ptsPg,
    astPg,
    trbPg,
    factorLongevidad,
    edadRetiro,
    draftYear,
    retirado,
    dorsal,
    temporadasPrevias,
    salario,
    aniosContrato,
    ofertasRechazadas,
    prestigioPrevio,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Jugador &&
          other.id == this.id &&
          other.nombreFicticio == this.nombreFicticio &&
          other.nombreReal == this.nombreReal &&
          other.posicion == this.posicion &&
          other.posicionSecundaria == this.posicionSecundaria &&
          other.equipo == this.equipo &&
          other.edad == this.edad &&
          other.media == this.media &&
          other.potencial == this.potencial &&
          other.atrTiro3 == this.atrTiro3 &&
          other.atrAtaque == this.atrAtaque &&
          other.atrDefensa == this.atrDefensa &&
          other.ptsPg == this.ptsPg &&
          other.astPg == this.astPg &&
          other.trbPg == this.trbPg &&
          other.factorLongevidad == this.factorLongevidad &&
          other.edadRetiro == this.edadRetiro &&
          other.draftYear == this.draftYear &&
          other.retirado == this.retirado &&
          other.dorsal == this.dorsal &&
          other.temporadasPrevias == this.temporadasPrevias &&
          other.salario == this.salario &&
          other.aniosContrato == this.aniosContrato &&
          other.ofertasRechazadas == this.ofertasRechazadas &&
          other.prestigioPrevio == this.prestigioPrevio);
}

class JugadoresCompanion extends UpdateCompanion<Jugador> {
  final Value<int> id;
  final Value<String> nombreFicticio;
  final Value<String> nombreReal;
  final Value<String> posicion;
  final Value<String?> posicionSecundaria;
  final Value<String> equipo;
  final Value<int> edad;
  final Value<int> media;
  final Value<int> potencial;
  final Value<int> atrTiro3;
  final Value<int> atrAtaque;
  final Value<int> atrDefensa;
  final Value<double> ptsPg;
  final Value<double> astPg;
  final Value<double> trbPg;
  final Value<double> factorLongevidad;
  final Value<int> edadRetiro;
  final Value<int?> draftYear;
  final Value<bool> retirado;
  final Value<int?> dorsal;
  final Value<int> temporadasPrevias;
  final Value<int> salario;
  final Value<int> aniosContrato;
  final Value<int> ofertasRechazadas;
  final Value<double> prestigioPrevio;
  const JugadoresCompanion({
    this.id = const Value.absent(),
    this.nombreFicticio = const Value.absent(),
    this.nombreReal = const Value.absent(),
    this.posicion = const Value.absent(),
    this.posicionSecundaria = const Value.absent(),
    this.equipo = const Value.absent(),
    this.edad = const Value.absent(),
    this.media = const Value.absent(),
    this.potencial = const Value.absent(),
    this.atrTiro3 = const Value.absent(),
    this.atrAtaque = const Value.absent(),
    this.atrDefensa = const Value.absent(),
    this.ptsPg = const Value.absent(),
    this.astPg = const Value.absent(),
    this.trbPg = const Value.absent(),
    this.factorLongevidad = const Value.absent(),
    this.edadRetiro = const Value.absent(),
    this.draftYear = const Value.absent(),
    this.retirado = const Value.absent(),
    this.dorsal = const Value.absent(),
    this.temporadasPrevias = const Value.absent(),
    this.salario = const Value.absent(),
    this.aniosContrato = const Value.absent(),
    this.ofertasRechazadas = const Value.absent(),
    this.prestigioPrevio = const Value.absent(),
  });
  JugadoresCompanion.insert({
    this.id = const Value.absent(),
    required String nombreFicticio,
    required String nombreReal,
    required String posicion,
    this.posicionSecundaria = const Value.absent(),
    required String equipo,
    required int edad,
    required int media,
    required int potencial,
    required int atrTiro3,
    required int atrAtaque,
    required int atrDefensa,
    required double ptsPg,
    required double astPg,
    required double trbPg,
    required double factorLongevidad,
    required int edadRetiro,
    this.draftYear = const Value.absent(),
    this.retirado = const Value.absent(),
    this.dorsal = const Value.absent(),
    this.temporadasPrevias = const Value.absent(),
    this.salario = const Value.absent(),
    this.aniosContrato = const Value.absent(),
    this.ofertasRechazadas = const Value.absent(),
    this.prestigioPrevio = const Value.absent(),
  }) : nombreFicticio = Value(nombreFicticio),
       nombreReal = Value(nombreReal),
       posicion = Value(posicion),
       equipo = Value(equipo),
       edad = Value(edad),
       media = Value(media),
       potencial = Value(potencial),
       atrTiro3 = Value(atrTiro3),
       atrAtaque = Value(atrAtaque),
       atrDefensa = Value(atrDefensa),
       ptsPg = Value(ptsPg),
       astPg = Value(astPg),
       trbPg = Value(trbPg),
       factorLongevidad = Value(factorLongevidad),
       edadRetiro = Value(edadRetiro);
  static Insertable<Jugador> custom({
    Expression<int>? id,
    Expression<String>? nombreFicticio,
    Expression<String>? nombreReal,
    Expression<String>? posicion,
    Expression<String>? posicionSecundaria,
    Expression<String>? equipo,
    Expression<int>? edad,
    Expression<int>? media,
    Expression<int>? potencial,
    Expression<int>? atrTiro3,
    Expression<int>? atrAtaque,
    Expression<int>? atrDefensa,
    Expression<double>? ptsPg,
    Expression<double>? astPg,
    Expression<double>? trbPg,
    Expression<double>? factorLongevidad,
    Expression<int>? edadRetiro,
    Expression<int>? draftYear,
    Expression<bool>? retirado,
    Expression<int>? dorsal,
    Expression<int>? temporadasPrevias,
    Expression<int>? salario,
    Expression<int>? aniosContrato,
    Expression<int>? ofertasRechazadas,
    Expression<double>? prestigioPrevio,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreFicticio != null) 'nombre_ficticio': nombreFicticio,
      if (nombreReal != null) 'nombre_real': nombreReal,
      if (posicion != null) 'posicion': posicion,
      if (posicionSecundaria != null) 'posicion_secundaria': posicionSecundaria,
      if (equipo != null) 'equipo': equipo,
      if (edad != null) 'edad': edad,
      if (media != null) 'media': media,
      if (potencial != null) 'potencial': potencial,
      if (atrTiro3 != null) 'atr_tiro3': atrTiro3,
      if (atrAtaque != null) 'atr_ataque': atrAtaque,
      if (atrDefensa != null) 'atr_defensa': atrDefensa,
      if (ptsPg != null) 'pts_pg': ptsPg,
      if (astPg != null) 'ast_pg': astPg,
      if (trbPg != null) 'trb_pg': trbPg,
      if (factorLongevidad != null) 'factor_longevidad': factorLongevidad,
      if (edadRetiro != null) 'edad_retiro': edadRetiro,
      if (draftYear != null) 'draft_year': draftYear,
      if (retirado != null) 'retirado': retirado,
      if (dorsal != null) 'dorsal': dorsal,
      if (temporadasPrevias != null) 'temporadas_previas': temporadasPrevias,
      if (salario != null) 'salario': salario,
      if (aniosContrato != null) 'anios_contrato': aniosContrato,
      if (ofertasRechazadas != null) 'ofertas_rechazadas': ofertasRechazadas,
      if (prestigioPrevio != null) 'prestigio_previo': prestigioPrevio,
    });
  }

  JugadoresCompanion copyWith({
    Value<int>? id,
    Value<String>? nombreFicticio,
    Value<String>? nombreReal,
    Value<String>? posicion,
    Value<String?>? posicionSecundaria,
    Value<String>? equipo,
    Value<int>? edad,
    Value<int>? media,
    Value<int>? potencial,
    Value<int>? atrTiro3,
    Value<int>? atrAtaque,
    Value<int>? atrDefensa,
    Value<double>? ptsPg,
    Value<double>? astPg,
    Value<double>? trbPg,
    Value<double>? factorLongevidad,
    Value<int>? edadRetiro,
    Value<int?>? draftYear,
    Value<bool>? retirado,
    Value<int?>? dorsal,
    Value<int>? temporadasPrevias,
    Value<int>? salario,
    Value<int>? aniosContrato,
    Value<int>? ofertasRechazadas,
    Value<double>? prestigioPrevio,
  }) {
    return JugadoresCompanion(
      id: id ?? this.id,
      nombreFicticio: nombreFicticio ?? this.nombreFicticio,
      nombreReal: nombreReal ?? this.nombreReal,
      posicion: posicion ?? this.posicion,
      posicionSecundaria: posicionSecundaria ?? this.posicionSecundaria,
      equipo: equipo ?? this.equipo,
      edad: edad ?? this.edad,
      media: media ?? this.media,
      potencial: potencial ?? this.potencial,
      atrTiro3: atrTiro3 ?? this.atrTiro3,
      atrAtaque: atrAtaque ?? this.atrAtaque,
      atrDefensa: atrDefensa ?? this.atrDefensa,
      ptsPg: ptsPg ?? this.ptsPg,
      astPg: astPg ?? this.astPg,
      trbPg: trbPg ?? this.trbPg,
      factorLongevidad: factorLongevidad ?? this.factorLongevidad,
      edadRetiro: edadRetiro ?? this.edadRetiro,
      draftYear: draftYear ?? this.draftYear,
      retirado: retirado ?? this.retirado,
      dorsal: dorsal ?? this.dorsal,
      temporadasPrevias: temporadasPrevias ?? this.temporadasPrevias,
      salario: salario ?? this.salario,
      aniosContrato: aniosContrato ?? this.aniosContrato,
      ofertasRechazadas: ofertasRechazadas ?? this.ofertasRechazadas,
      prestigioPrevio: prestigioPrevio ?? this.prestigioPrevio,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombreFicticio.present) {
      map['nombre_ficticio'] = Variable<String>(nombreFicticio.value);
    }
    if (nombreReal.present) {
      map['nombre_real'] = Variable<String>(nombreReal.value);
    }
    if (posicion.present) {
      map['posicion'] = Variable<String>(posicion.value);
    }
    if (posicionSecundaria.present) {
      map['posicion_secundaria'] = Variable<String>(posicionSecundaria.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    if (edad.present) {
      map['edad'] = Variable<int>(edad.value);
    }
    if (media.present) {
      map['media'] = Variable<int>(media.value);
    }
    if (potencial.present) {
      map['potencial'] = Variable<int>(potencial.value);
    }
    if (atrTiro3.present) {
      map['atr_tiro3'] = Variable<int>(atrTiro3.value);
    }
    if (atrAtaque.present) {
      map['atr_ataque'] = Variable<int>(atrAtaque.value);
    }
    if (atrDefensa.present) {
      map['atr_defensa'] = Variable<int>(atrDefensa.value);
    }
    if (ptsPg.present) {
      map['pts_pg'] = Variable<double>(ptsPg.value);
    }
    if (astPg.present) {
      map['ast_pg'] = Variable<double>(astPg.value);
    }
    if (trbPg.present) {
      map['trb_pg'] = Variable<double>(trbPg.value);
    }
    if (factorLongevidad.present) {
      map['factor_longevidad'] = Variable<double>(factorLongevidad.value);
    }
    if (edadRetiro.present) {
      map['edad_retiro'] = Variable<int>(edadRetiro.value);
    }
    if (draftYear.present) {
      map['draft_year'] = Variable<int>(draftYear.value);
    }
    if (retirado.present) {
      map['retirado'] = Variable<bool>(retirado.value);
    }
    if (dorsal.present) {
      map['dorsal'] = Variable<int>(dorsal.value);
    }
    if (temporadasPrevias.present) {
      map['temporadas_previas'] = Variable<int>(temporadasPrevias.value);
    }
    if (salario.present) {
      map['salario'] = Variable<int>(salario.value);
    }
    if (aniosContrato.present) {
      map['anios_contrato'] = Variable<int>(aniosContrato.value);
    }
    if (ofertasRechazadas.present) {
      map['ofertas_rechazadas'] = Variable<int>(ofertasRechazadas.value);
    }
    if (prestigioPrevio.present) {
      map['prestigio_previo'] = Variable<double>(prestigioPrevio.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JugadoresCompanion(')
          ..write('id: $id, ')
          ..write('nombreFicticio: $nombreFicticio, ')
          ..write('nombreReal: $nombreReal, ')
          ..write('posicion: $posicion, ')
          ..write('posicionSecundaria: $posicionSecundaria, ')
          ..write('equipo: $equipo, ')
          ..write('edad: $edad, ')
          ..write('media: $media, ')
          ..write('potencial: $potencial, ')
          ..write('atrTiro3: $atrTiro3, ')
          ..write('atrAtaque: $atrAtaque, ')
          ..write('atrDefensa: $atrDefensa, ')
          ..write('ptsPg: $ptsPg, ')
          ..write('astPg: $astPg, ')
          ..write('trbPg: $trbPg, ')
          ..write('factorLongevidad: $factorLongevidad, ')
          ..write('edadRetiro: $edadRetiro, ')
          ..write('draftYear: $draftYear, ')
          ..write('retirado: $retirado, ')
          ..write('dorsal: $dorsal, ')
          ..write('temporadasPrevias: $temporadasPrevias, ')
          ..write('salario: $salario, ')
          ..write('aniosContrato: $aniosContrato, ')
          ..write('ofertasRechazadas: $ofertasRechazadas, ')
          ..write('prestigioPrevio: $prestigioPrevio')
          ..write(')'))
        .toString();
  }
}

class $FranquiciaTable extends Franquicia
    with TableInfo<$FranquiciaTable, FranquiciaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FranquiciaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, equipo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'franquicia';
  @override
  VerificationContext validateIntegrity(
    Insertable<FranquiciaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FranquiciaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FranquiciaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
    );
  }

  @override
  $FranquiciaTable createAlias(String alias) {
    return $FranquiciaTable(attachedDatabase, alias);
  }
}

class FranquiciaData extends DataClass implements Insertable<FranquiciaData> {
  final int id;
  final String equipo;
  const FranquiciaData({required this.id, required this.equipo});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['equipo'] = Variable<String>(equipo);
    return map;
  }

  FranquiciaCompanion toCompanion(bool nullToAbsent) {
    return FranquiciaCompanion(id: Value(id), equipo: Value(equipo));
  }

  factory FranquiciaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FranquiciaData(
      id: serializer.fromJson<int>(json['id']),
      equipo: serializer.fromJson<String>(json['equipo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'equipo': serializer.toJson<String>(equipo),
    };
  }

  FranquiciaData copyWith({int? id, String? equipo}) =>
      FranquiciaData(id: id ?? this.id, equipo: equipo ?? this.equipo);
  FranquiciaData copyWithCompanion(FranquiciaCompanion data) {
    return FranquiciaData(
      id: data.id.present ? data.id.value : this.id,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FranquiciaData(')
          ..write('id: $id, ')
          ..write('equipo: $equipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, equipo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FranquiciaData &&
          other.id == this.id &&
          other.equipo == this.equipo);
}

class FranquiciaCompanion extends UpdateCompanion<FranquiciaData> {
  final Value<int> id;
  final Value<String> equipo;
  const FranquiciaCompanion({
    this.id = const Value.absent(),
    this.equipo = const Value.absent(),
  });
  FranquiciaCompanion.insert({
    this.id = const Value.absent(),
    required String equipo,
  }) : equipo = Value(equipo);
  static Insertable<FranquiciaData> custom({
    Expression<int>? id,
    Expression<String>? equipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (equipo != null) 'equipo': equipo,
    });
  }

  FranquiciaCompanion copyWith({Value<int>? id, Value<String>? equipo}) {
    return FranquiciaCompanion(
      id: id ?? this.id,
      equipo: equipo ?? this.equipo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FranquiciaCompanion(')
          ..write('id: $id, ')
          ..write('equipo: $equipo')
          ..write(')'))
        .toString();
  }
}

class $RotacionJugadorTable extends RotacionJugador
    with TableInfo<$RotacionJugadorTable, RotacionJugadorData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RotacionJugadorTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _posicionMeta = const VerificationMeta(
    'posicion',
  );
  @override
  late final GeneratedColumn<String> posicion = GeneratedColumn<String>(
    'posicion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _esTitularMeta = const VerificationMeta(
    'esTitular',
  );
  @override
  late final GeneratedColumn<bool> esTitular = GeneratedColumn<bool>(
    'es_titular',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_titular" IN (0, 1))',
    ),
  );
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutosMeta = const VerificationMeta(
    'minutos',
  );
  @override
  late final GeneratedColumn<int> minutos = GeneratedColumn<int>(
    'minutos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _esEstrellaAtaqueMeta = const VerificationMeta(
    'esEstrellaAtaque',
  );
  @override
  late final GeneratedColumn<bool> esEstrellaAtaque = GeneratedColumn<bool>(
    'es_estrella_ataque',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_estrella_ataque" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _esEstrellaDefensaMeta = const VerificationMeta(
    'esEstrellaDefensa',
  );
  @override
  late final GeneratedColumn<bool> esEstrellaDefensa = GeneratedColumn<bool>(
    'es_estrella_defensa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_estrella_defensa" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    posicion,
    esTitular,
    jugadorId,
    minutos,
    esEstrellaAtaque,
    esEstrellaDefensa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rotacion_jugador';
  @override
  VerificationContext validateIntegrity(
    Insertable<RotacionJugadorData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('posicion')) {
      context.handle(
        _posicionMeta,
        posicion.isAcceptableOrUnknown(data['posicion']!, _posicionMeta),
      );
    } else if (isInserting) {
      context.missing(_posicionMeta);
    }
    if (data.containsKey('es_titular')) {
      context.handle(
        _esTitularMeta,
        esTitular.isAcceptableOrUnknown(data['es_titular']!, _esTitularMeta),
      );
    } else if (isInserting) {
      context.missing(_esTitularMeta);
    }
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jugadorIdMeta);
    }
    if (data.containsKey('minutos')) {
      context.handle(
        _minutosMeta,
        minutos.isAcceptableOrUnknown(data['minutos']!, _minutosMeta),
      );
    } else if (isInserting) {
      context.missing(_minutosMeta);
    }
    if (data.containsKey('es_estrella_ataque')) {
      context.handle(
        _esEstrellaAtaqueMeta,
        esEstrellaAtaque.isAcceptableOrUnknown(
          data['es_estrella_ataque']!,
          _esEstrellaAtaqueMeta,
        ),
      );
    }
    if (data.containsKey('es_estrella_defensa')) {
      context.handle(
        _esEstrellaDefensaMeta,
        esEstrellaDefensa.isAcceptableOrUnknown(
          data['es_estrella_defensa']!,
          _esEstrellaDefensaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RotacionJugadorData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RotacionJugadorData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      posicion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posicion'],
      )!,
      esTitular: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_titular'],
      )!,
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
      minutos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutos'],
      )!,
      esEstrellaAtaque: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_estrella_ataque'],
      )!,
      esEstrellaDefensa: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_estrella_defensa'],
      )!,
    );
  }

  @override
  $RotacionJugadorTable createAlias(String alias) {
    return $RotacionJugadorTable(attachedDatabase, alias);
  }
}

class RotacionJugadorData extends DataClass
    implements Insertable<RotacionJugadorData> {
  final int id;
  final String posicion;
  final bool esTitular;
  final int jugadorId;
  final int minutos;
  final bool esEstrellaAtaque;
  final bool esEstrellaDefensa;
  const RotacionJugadorData({
    required this.id,
    required this.posicion,
    required this.esTitular,
    required this.jugadorId,
    required this.minutos,
    required this.esEstrellaAtaque,
    required this.esEstrellaDefensa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['posicion'] = Variable<String>(posicion);
    map['es_titular'] = Variable<bool>(esTitular);
    map['jugador_id'] = Variable<int>(jugadorId);
    map['minutos'] = Variable<int>(minutos);
    map['es_estrella_ataque'] = Variable<bool>(esEstrellaAtaque);
    map['es_estrella_defensa'] = Variable<bool>(esEstrellaDefensa);
    return map;
  }

  RotacionJugadorCompanion toCompanion(bool nullToAbsent) {
    return RotacionJugadorCompanion(
      id: Value(id),
      posicion: Value(posicion),
      esTitular: Value(esTitular),
      jugadorId: Value(jugadorId),
      minutos: Value(minutos),
      esEstrellaAtaque: Value(esEstrellaAtaque),
      esEstrellaDefensa: Value(esEstrellaDefensa),
    );
  }

  factory RotacionJugadorData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RotacionJugadorData(
      id: serializer.fromJson<int>(json['id']),
      posicion: serializer.fromJson<String>(json['posicion']),
      esTitular: serializer.fromJson<bool>(json['esTitular']),
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
      minutos: serializer.fromJson<int>(json['minutos']),
      esEstrellaAtaque: serializer.fromJson<bool>(json['esEstrellaAtaque']),
      esEstrellaDefensa: serializer.fromJson<bool>(json['esEstrellaDefensa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'posicion': serializer.toJson<String>(posicion),
      'esTitular': serializer.toJson<bool>(esTitular),
      'jugadorId': serializer.toJson<int>(jugadorId),
      'minutos': serializer.toJson<int>(minutos),
      'esEstrellaAtaque': serializer.toJson<bool>(esEstrellaAtaque),
      'esEstrellaDefensa': serializer.toJson<bool>(esEstrellaDefensa),
    };
  }

  RotacionJugadorData copyWith({
    int? id,
    String? posicion,
    bool? esTitular,
    int? jugadorId,
    int? minutos,
    bool? esEstrellaAtaque,
    bool? esEstrellaDefensa,
  }) => RotacionJugadorData(
    id: id ?? this.id,
    posicion: posicion ?? this.posicion,
    esTitular: esTitular ?? this.esTitular,
    jugadorId: jugadorId ?? this.jugadorId,
    minutos: minutos ?? this.minutos,
    esEstrellaAtaque: esEstrellaAtaque ?? this.esEstrellaAtaque,
    esEstrellaDefensa: esEstrellaDefensa ?? this.esEstrellaDefensa,
  );
  RotacionJugadorData copyWithCompanion(RotacionJugadorCompanion data) {
    return RotacionJugadorData(
      id: data.id.present ? data.id.value : this.id,
      posicion: data.posicion.present ? data.posicion.value : this.posicion,
      esTitular: data.esTitular.present ? data.esTitular.value : this.esTitular,
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
      minutos: data.minutos.present ? data.minutos.value : this.minutos,
      esEstrellaAtaque: data.esEstrellaAtaque.present
          ? data.esEstrellaAtaque.value
          : this.esEstrellaAtaque,
      esEstrellaDefensa: data.esEstrellaDefensa.present
          ? data.esEstrellaDefensa.value
          : this.esEstrellaDefensa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RotacionJugadorData(')
          ..write('id: $id, ')
          ..write('posicion: $posicion, ')
          ..write('esTitular: $esTitular, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('minutos: $minutos, ')
          ..write('esEstrellaAtaque: $esEstrellaAtaque, ')
          ..write('esEstrellaDefensa: $esEstrellaDefensa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    posicion,
    esTitular,
    jugadorId,
    minutos,
    esEstrellaAtaque,
    esEstrellaDefensa,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RotacionJugadorData &&
          other.id == this.id &&
          other.posicion == this.posicion &&
          other.esTitular == this.esTitular &&
          other.jugadorId == this.jugadorId &&
          other.minutos == this.minutos &&
          other.esEstrellaAtaque == this.esEstrellaAtaque &&
          other.esEstrellaDefensa == this.esEstrellaDefensa);
}

class RotacionJugadorCompanion extends UpdateCompanion<RotacionJugadorData> {
  final Value<int> id;
  final Value<String> posicion;
  final Value<bool> esTitular;
  final Value<int> jugadorId;
  final Value<int> minutos;
  final Value<bool> esEstrellaAtaque;
  final Value<bool> esEstrellaDefensa;
  const RotacionJugadorCompanion({
    this.id = const Value.absent(),
    this.posicion = const Value.absent(),
    this.esTitular = const Value.absent(),
    this.jugadorId = const Value.absent(),
    this.minutos = const Value.absent(),
    this.esEstrellaAtaque = const Value.absent(),
    this.esEstrellaDefensa = const Value.absent(),
  });
  RotacionJugadorCompanion.insert({
    this.id = const Value.absent(),
    required String posicion,
    required bool esTitular,
    required int jugadorId,
    required int minutos,
    this.esEstrellaAtaque = const Value.absent(),
    this.esEstrellaDefensa = const Value.absent(),
  }) : posicion = Value(posicion),
       esTitular = Value(esTitular),
       jugadorId = Value(jugadorId),
       minutos = Value(minutos);
  static Insertable<RotacionJugadorData> custom({
    Expression<int>? id,
    Expression<String>? posicion,
    Expression<bool>? esTitular,
    Expression<int>? jugadorId,
    Expression<int>? minutos,
    Expression<bool>? esEstrellaAtaque,
    Expression<bool>? esEstrellaDefensa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (posicion != null) 'posicion': posicion,
      if (esTitular != null) 'es_titular': esTitular,
      if (jugadorId != null) 'jugador_id': jugadorId,
      if (minutos != null) 'minutos': minutos,
      if (esEstrellaAtaque != null) 'es_estrella_ataque': esEstrellaAtaque,
      if (esEstrellaDefensa != null) 'es_estrella_defensa': esEstrellaDefensa,
    });
  }

  RotacionJugadorCompanion copyWith({
    Value<int>? id,
    Value<String>? posicion,
    Value<bool>? esTitular,
    Value<int>? jugadorId,
    Value<int>? minutos,
    Value<bool>? esEstrellaAtaque,
    Value<bool>? esEstrellaDefensa,
  }) {
    return RotacionJugadorCompanion(
      id: id ?? this.id,
      posicion: posicion ?? this.posicion,
      esTitular: esTitular ?? this.esTitular,
      jugadorId: jugadorId ?? this.jugadorId,
      minutos: minutos ?? this.minutos,
      esEstrellaAtaque: esEstrellaAtaque ?? this.esEstrellaAtaque,
      esEstrellaDefensa: esEstrellaDefensa ?? this.esEstrellaDefensa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (posicion.present) {
      map['posicion'] = Variable<String>(posicion.value);
    }
    if (esTitular.present) {
      map['es_titular'] = Variable<bool>(esTitular.value);
    }
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    if (minutos.present) {
      map['minutos'] = Variable<int>(minutos.value);
    }
    if (esEstrellaAtaque.present) {
      map['es_estrella_ataque'] = Variable<bool>(esEstrellaAtaque.value);
    }
    if (esEstrellaDefensa.present) {
      map['es_estrella_defensa'] = Variable<bool>(esEstrellaDefensa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RotacionJugadorCompanion(')
          ..write('id: $id, ')
          ..write('posicion: $posicion, ')
          ..write('esTitular: $esTitular, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('minutos: $minutos, ')
          ..write('esEstrellaAtaque: $esEstrellaAtaque, ')
          ..write('esEstrellaDefensa: $esEstrellaDefensa')
          ..write(')'))
        .toString();
  }
}

class $PartidosCalendarioTable extends PartidosCalendario
    with TableInfo<$PartidosCalendarioTable, PartidosCalendarioData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartidosCalendarioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _equipoPropietarioMeta = const VerificationMeta(
    'equipoPropietario',
  );
  @override
  late final GeneratedColumn<String> equipoPropietario =
      GeneratedColumn<String>(
        'equipo_propietario',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rivalMeta = const VerificationMeta('rival');
  @override
  late final GeneratedColumn<String> rival = GeneratedColumn<String>(
    'rival',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _esLocalMeta = const VerificationMeta(
    'esLocal',
  );
  @override
  late final GeneratedColumn<bool> esLocal = GeneratedColumn<bool>(
    'es_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_local" IN (0, 1))',
    ),
  );
  static const VerificationMeta _jugadoMeta = const VerificationMeta('jugado');
  @override
  late final GeneratedColumn<bool> jugado = GeneratedColumn<bool>(
    'jugado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("jugado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _esTorneoTemporadaMeta = const VerificationMeta(
    'esTorneoTemporada',
  );
  @override
  late final GeneratedColumn<bool> esTorneoTemporada = GeneratedColumn<bool>(
    'es_torneo_temporada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_torneo_temporada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _faseMeta = const VerificationMeta('fase');
  @override
  late final GeneratedColumn<String> fase = GeneratedColumn<String>(
    'fase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('regular'),
  );
  static const VerificationMeta _marcadorPropietarioMeta =
      const VerificationMeta('marcadorPropietario');
  @override
  late final GeneratedColumn<int> marcadorPropietario = GeneratedColumn<int>(
    'marcador_propietario',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _marcadorRivalMeta = const VerificationMeta(
    'marcadorRival',
  );
  @override
  late final GeneratedColumn<int> marcadorRival = GeneratedColumn<int>(
    'marcador_rival',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    equipoPropietario,
    fecha,
    rival,
    esLocal,
    jugado,
    esTorneoTemporada,
    fase,
    marcadorPropietario,
    marcadorRival,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'partidos_calendario';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartidosCalendarioData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('equipo_propietario')) {
      context.handle(
        _equipoPropietarioMeta,
        equipoPropietario.isAcceptableOrUnknown(
          data['equipo_propietario']!,
          _equipoPropietarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipoPropietarioMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('rival')) {
      context.handle(
        _rivalMeta,
        rival.isAcceptableOrUnknown(data['rival']!, _rivalMeta),
      );
    } else if (isInserting) {
      context.missing(_rivalMeta);
    }
    if (data.containsKey('es_local')) {
      context.handle(
        _esLocalMeta,
        esLocal.isAcceptableOrUnknown(data['es_local']!, _esLocalMeta),
      );
    } else if (isInserting) {
      context.missing(_esLocalMeta);
    }
    if (data.containsKey('jugado')) {
      context.handle(
        _jugadoMeta,
        jugado.isAcceptableOrUnknown(data['jugado']!, _jugadoMeta),
      );
    }
    if (data.containsKey('es_torneo_temporada')) {
      context.handle(
        _esTorneoTemporadaMeta,
        esTorneoTemporada.isAcceptableOrUnknown(
          data['es_torneo_temporada']!,
          _esTorneoTemporadaMeta,
        ),
      );
    }
    if (data.containsKey('fase')) {
      context.handle(
        _faseMeta,
        fase.isAcceptableOrUnknown(data['fase']!, _faseMeta),
      );
    }
    if (data.containsKey('marcador_propietario')) {
      context.handle(
        _marcadorPropietarioMeta,
        marcadorPropietario.isAcceptableOrUnknown(
          data['marcador_propietario']!,
          _marcadorPropietarioMeta,
        ),
      );
    }
    if (data.containsKey('marcador_rival')) {
      context.handle(
        _marcadorRivalMeta,
        marcadorRival.isAcceptableOrUnknown(
          data['marcador_rival']!,
          _marcadorRivalMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartidosCalendarioData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartidosCalendarioData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      equipoPropietario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_propietario'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      rival: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rival'],
      )!,
      esLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_local'],
      )!,
      jugado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}jugado'],
      )!,
      esTorneoTemporada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_torneo_temporada'],
      )!,
      fase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fase'],
      )!,
      marcadorPropietario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}marcador_propietario'],
      ),
      marcadorRival: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}marcador_rival'],
      ),
    );
  }

  @override
  $PartidosCalendarioTable createAlias(String alias) {
    return $PartidosCalendarioTable(attachedDatabase, alias);
  }
}

class PartidosCalendarioData extends DataClass
    implements Insertable<PartidosCalendarioData> {
  final int id;
  final String equipoPropietario;
  final DateTime fecha;
  final String rival;
  final bool esLocal;
  final bool jugado;
  final bool esTorneoTemporada;

  /// 'regular' o 'playoffs'.
  final String fase;
  final int? marcadorPropietario;
  final int? marcadorRival;
  const PartidosCalendarioData({
    required this.id,
    required this.equipoPropietario,
    required this.fecha,
    required this.rival,
    required this.esLocal,
    required this.jugado,
    required this.esTorneoTemporada,
    required this.fase,
    this.marcadorPropietario,
    this.marcadorRival,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['equipo_propietario'] = Variable<String>(equipoPropietario);
    map['fecha'] = Variable<DateTime>(fecha);
    map['rival'] = Variable<String>(rival);
    map['es_local'] = Variable<bool>(esLocal);
    map['jugado'] = Variable<bool>(jugado);
    map['es_torneo_temporada'] = Variable<bool>(esTorneoTemporada);
    map['fase'] = Variable<String>(fase);
    if (!nullToAbsent || marcadorPropietario != null) {
      map['marcador_propietario'] = Variable<int>(marcadorPropietario);
    }
    if (!nullToAbsent || marcadorRival != null) {
      map['marcador_rival'] = Variable<int>(marcadorRival);
    }
    return map;
  }

  PartidosCalendarioCompanion toCompanion(bool nullToAbsent) {
    return PartidosCalendarioCompanion(
      id: Value(id),
      equipoPropietario: Value(equipoPropietario),
      fecha: Value(fecha),
      rival: Value(rival),
      esLocal: Value(esLocal),
      jugado: Value(jugado),
      esTorneoTemporada: Value(esTorneoTemporada),
      fase: Value(fase),
      marcadorPropietario: marcadorPropietario == null && nullToAbsent
          ? const Value.absent()
          : Value(marcadorPropietario),
      marcadorRival: marcadorRival == null && nullToAbsent
          ? const Value.absent()
          : Value(marcadorRival),
    );
  }

  factory PartidosCalendarioData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartidosCalendarioData(
      id: serializer.fromJson<int>(json['id']),
      equipoPropietario: serializer.fromJson<String>(json['equipoPropietario']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      rival: serializer.fromJson<String>(json['rival']),
      esLocal: serializer.fromJson<bool>(json['esLocal']),
      jugado: serializer.fromJson<bool>(json['jugado']),
      esTorneoTemporada: serializer.fromJson<bool>(json['esTorneoTemporada']),
      fase: serializer.fromJson<String>(json['fase']),
      marcadorPropietario: serializer.fromJson<int?>(
        json['marcadorPropietario'],
      ),
      marcadorRival: serializer.fromJson<int?>(json['marcadorRival']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'equipoPropietario': serializer.toJson<String>(equipoPropietario),
      'fecha': serializer.toJson<DateTime>(fecha),
      'rival': serializer.toJson<String>(rival),
      'esLocal': serializer.toJson<bool>(esLocal),
      'jugado': serializer.toJson<bool>(jugado),
      'esTorneoTemporada': serializer.toJson<bool>(esTorneoTemporada),
      'fase': serializer.toJson<String>(fase),
      'marcadorPropietario': serializer.toJson<int?>(marcadorPropietario),
      'marcadorRival': serializer.toJson<int?>(marcadorRival),
    };
  }

  PartidosCalendarioData copyWith({
    int? id,
    String? equipoPropietario,
    DateTime? fecha,
    String? rival,
    bool? esLocal,
    bool? jugado,
    bool? esTorneoTemporada,
    String? fase,
    Value<int?> marcadorPropietario = const Value.absent(),
    Value<int?> marcadorRival = const Value.absent(),
  }) => PartidosCalendarioData(
    id: id ?? this.id,
    equipoPropietario: equipoPropietario ?? this.equipoPropietario,
    fecha: fecha ?? this.fecha,
    rival: rival ?? this.rival,
    esLocal: esLocal ?? this.esLocal,
    jugado: jugado ?? this.jugado,
    esTorneoTemporada: esTorneoTemporada ?? this.esTorneoTemporada,
    fase: fase ?? this.fase,
    marcadorPropietario: marcadorPropietario.present
        ? marcadorPropietario.value
        : this.marcadorPropietario,
    marcadorRival: marcadorRival.present
        ? marcadorRival.value
        : this.marcadorRival,
  );
  PartidosCalendarioData copyWithCompanion(PartidosCalendarioCompanion data) {
    return PartidosCalendarioData(
      id: data.id.present ? data.id.value : this.id,
      equipoPropietario: data.equipoPropietario.present
          ? data.equipoPropietario.value
          : this.equipoPropietario,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      rival: data.rival.present ? data.rival.value : this.rival,
      esLocal: data.esLocal.present ? data.esLocal.value : this.esLocal,
      jugado: data.jugado.present ? data.jugado.value : this.jugado,
      esTorneoTemporada: data.esTorneoTemporada.present
          ? data.esTorneoTemporada.value
          : this.esTorneoTemporada,
      fase: data.fase.present ? data.fase.value : this.fase,
      marcadorPropietario: data.marcadorPropietario.present
          ? data.marcadorPropietario.value
          : this.marcadorPropietario,
      marcadorRival: data.marcadorRival.present
          ? data.marcadorRival.value
          : this.marcadorRival,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartidosCalendarioData(')
          ..write('id: $id, ')
          ..write('equipoPropietario: $equipoPropietario, ')
          ..write('fecha: $fecha, ')
          ..write('rival: $rival, ')
          ..write('esLocal: $esLocal, ')
          ..write('jugado: $jugado, ')
          ..write('esTorneoTemporada: $esTorneoTemporada, ')
          ..write('fase: $fase, ')
          ..write('marcadorPropietario: $marcadorPropietario, ')
          ..write('marcadorRival: $marcadorRival')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    equipoPropietario,
    fecha,
    rival,
    esLocal,
    jugado,
    esTorneoTemporada,
    fase,
    marcadorPropietario,
    marcadorRival,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartidosCalendarioData &&
          other.id == this.id &&
          other.equipoPropietario == this.equipoPropietario &&
          other.fecha == this.fecha &&
          other.rival == this.rival &&
          other.esLocal == this.esLocal &&
          other.jugado == this.jugado &&
          other.esTorneoTemporada == this.esTorneoTemporada &&
          other.fase == this.fase &&
          other.marcadorPropietario == this.marcadorPropietario &&
          other.marcadorRival == this.marcadorRival);
}

class PartidosCalendarioCompanion
    extends UpdateCompanion<PartidosCalendarioData> {
  final Value<int> id;
  final Value<String> equipoPropietario;
  final Value<DateTime> fecha;
  final Value<String> rival;
  final Value<bool> esLocal;
  final Value<bool> jugado;
  final Value<bool> esTorneoTemporada;
  final Value<String> fase;
  final Value<int?> marcadorPropietario;
  final Value<int?> marcadorRival;
  const PartidosCalendarioCompanion({
    this.id = const Value.absent(),
    this.equipoPropietario = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rival = const Value.absent(),
    this.esLocal = const Value.absent(),
    this.jugado = const Value.absent(),
    this.esTorneoTemporada = const Value.absent(),
    this.fase = const Value.absent(),
    this.marcadorPropietario = const Value.absent(),
    this.marcadorRival = const Value.absent(),
  });
  PartidosCalendarioCompanion.insert({
    this.id = const Value.absent(),
    required String equipoPropietario,
    required DateTime fecha,
    required String rival,
    required bool esLocal,
    this.jugado = const Value.absent(),
    this.esTorneoTemporada = const Value.absent(),
    this.fase = const Value.absent(),
    this.marcadorPropietario = const Value.absent(),
    this.marcadorRival = const Value.absent(),
  }) : equipoPropietario = Value(equipoPropietario),
       fecha = Value(fecha),
       rival = Value(rival),
       esLocal = Value(esLocal);
  static Insertable<PartidosCalendarioData> custom({
    Expression<int>? id,
    Expression<String>? equipoPropietario,
    Expression<DateTime>? fecha,
    Expression<String>? rival,
    Expression<bool>? esLocal,
    Expression<bool>? jugado,
    Expression<bool>? esTorneoTemporada,
    Expression<String>? fase,
    Expression<int>? marcadorPropietario,
    Expression<int>? marcadorRival,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (equipoPropietario != null) 'equipo_propietario': equipoPropietario,
      if (fecha != null) 'fecha': fecha,
      if (rival != null) 'rival': rival,
      if (esLocal != null) 'es_local': esLocal,
      if (jugado != null) 'jugado': jugado,
      if (esTorneoTemporada != null) 'es_torneo_temporada': esTorneoTemporada,
      if (fase != null) 'fase': fase,
      if (marcadorPropietario != null)
        'marcador_propietario': marcadorPropietario,
      if (marcadorRival != null) 'marcador_rival': marcadorRival,
    });
  }

  PartidosCalendarioCompanion copyWith({
    Value<int>? id,
    Value<String>? equipoPropietario,
    Value<DateTime>? fecha,
    Value<String>? rival,
    Value<bool>? esLocal,
    Value<bool>? jugado,
    Value<bool>? esTorneoTemporada,
    Value<String>? fase,
    Value<int?>? marcadorPropietario,
    Value<int?>? marcadorRival,
  }) {
    return PartidosCalendarioCompanion(
      id: id ?? this.id,
      equipoPropietario: equipoPropietario ?? this.equipoPropietario,
      fecha: fecha ?? this.fecha,
      rival: rival ?? this.rival,
      esLocal: esLocal ?? this.esLocal,
      jugado: jugado ?? this.jugado,
      esTorneoTemporada: esTorneoTemporada ?? this.esTorneoTemporada,
      fase: fase ?? this.fase,
      marcadorPropietario: marcadorPropietario ?? this.marcadorPropietario,
      marcadorRival: marcadorRival ?? this.marcadorRival,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (equipoPropietario.present) {
      map['equipo_propietario'] = Variable<String>(equipoPropietario.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (rival.present) {
      map['rival'] = Variable<String>(rival.value);
    }
    if (esLocal.present) {
      map['es_local'] = Variable<bool>(esLocal.value);
    }
    if (jugado.present) {
      map['jugado'] = Variable<bool>(jugado.value);
    }
    if (esTorneoTemporada.present) {
      map['es_torneo_temporada'] = Variable<bool>(esTorneoTemporada.value);
    }
    if (fase.present) {
      map['fase'] = Variable<String>(fase.value);
    }
    if (marcadorPropietario.present) {
      map['marcador_propietario'] = Variable<int>(marcadorPropietario.value);
    }
    if (marcadorRival.present) {
      map['marcador_rival'] = Variable<int>(marcadorRival.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartidosCalendarioCompanion(')
          ..write('id: $id, ')
          ..write('equipoPropietario: $equipoPropietario, ')
          ..write('fecha: $fecha, ')
          ..write('rival: $rival, ')
          ..write('esLocal: $esLocal, ')
          ..write('jugado: $jugado, ')
          ..write('esTorneoTemporada: $esTorneoTemporada, ')
          ..write('fase: $fase, ')
          ..write('marcadorPropietario: $marcadorPropietario, ')
          ..write('marcadorRival: $marcadorRival')
          ..write(')'))
        .toString();
  }
}

class $EventosTemporadaTable extends EventosTemporada
    with TableInfo<$EventosTemporadaTable, EventosTemporadaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosTemporadaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fecha, tipo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos_temporada';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventosTemporadaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventosTemporadaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventosTemporadaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
    );
  }

  @override
  $EventosTemporadaTable createAlias(String alias) {
    return $EventosTemporadaTable(attachedDatabase, alias);
  }
}

class EventosTemporadaData extends DataClass
    implements Insertable<EventosTemporadaData> {
  final int id;
  final DateTime fecha;
  final String tipo;
  const EventosTemporadaData({
    required this.id,
    required this.fecha,
    required this.tipo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<DateTime>(fecha);
    map['tipo'] = Variable<String>(tipo);
    return map;
  }

  EventosTemporadaCompanion toCompanion(bool nullToAbsent) {
    return EventosTemporadaCompanion(
      id: Value(id),
      fecha: Value(fecha),
      tipo: Value(tipo),
    );
  }

  factory EventosTemporadaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventosTemporadaData(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      tipo: serializer.fromJson<String>(json['tipo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<DateTime>(fecha),
      'tipo': serializer.toJson<String>(tipo),
    };
  }

  EventosTemporadaData copyWith({int? id, DateTime? fecha, String? tipo}) =>
      EventosTemporadaData(
        id: id ?? this.id,
        fecha: fecha ?? this.fecha,
        tipo: tipo ?? this.tipo,
      );
  EventosTemporadaData copyWithCompanion(EventosTemporadaCompanion data) {
    return EventosTemporadaData(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventosTemporadaData(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fecha, tipo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventosTemporadaData &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.tipo == this.tipo);
}

class EventosTemporadaCompanion extends UpdateCompanion<EventosTemporadaData> {
  final Value<int> id;
  final Value<DateTime> fecha;
  final Value<String> tipo;
  const EventosTemporadaCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
  });
  EventosTemporadaCompanion.insert({
    this.id = const Value.absent(),
    required DateTime fecha,
    required String tipo,
  }) : fecha = Value(fecha),
       tipo = Value(tipo);
  static Insertable<EventosTemporadaData> custom({
    Expression<int>? id,
    Expression<DateTime>? fecha,
    Expression<String>? tipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (tipo != null) 'tipo': tipo,
    });
  }

  EventosTemporadaCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? fecha,
    Value<String>? tipo,
  }) {
    return EventosTemporadaCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventosTemporadaCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }
}

class $LesionesTable extends Lesiones with TableInfo<$LesionesTable, Lesion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LesionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaFinMeta = const VerificationMeta(
    'fechaFin',
  );
  @override
  late final GeneratedColumn<DateTime> fechaFin = GeneratedColumn<DateTime>(
    'fecha_fin',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gravedadMeta = const VerificationMeta(
    'gravedad',
  );
  @override
  late final GeneratedColumn<String> gravedad = GeneratedColumn<String>(
    'gravedad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _partidosEstimadosMeta = const VerificationMeta(
    'partidosEstimados',
  );
  @override
  late final GeneratedColumn<int> partidosEstimados = GeneratedColumn<int>(
    'partidos_estimados',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jugadorId,
    fechaFin,
    gravedad,
    motivo,
    partidosEstimados,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesiones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lesion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jugadorIdMeta);
    }
    if (data.containsKey('fecha_fin')) {
      context.handle(
        _fechaFinMeta,
        fechaFin.isAcceptableOrUnknown(data['fecha_fin']!, _fechaFinMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaFinMeta);
    }
    if (data.containsKey('gravedad')) {
      context.handle(
        _gravedadMeta,
        gravedad.isAcceptableOrUnknown(data['gravedad']!, _gravedadMeta),
      );
    } else if (isInserting) {
      context.missing(_gravedadMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    }
    if (data.containsKey('partidos_estimados')) {
      context.handle(
        _partidosEstimadosMeta,
        partidosEstimados.isAcceptableOrUnknown(
          data['partidos_estimados']!,
          _partidosEstimadosMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lesion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lesion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
      fechaFin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_fin'],
      )!,
      gravedad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gravedad'],
      )!,
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      )!,
      partidosEstimados: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partidos_estimados'],
      )!,
    );
  }

  @override
  $LesionesTable createAlias(String alias) {
    return $LesionesTable(attachedDatabase, alias);
  }
}

class Lesion extends DataClass implements Insertable<Lesion> {
  final int id;
  final int jugadorId;
  final DateTime fechaFin;

  /// 'leve' o 'grave'.
  final String gravedad;

  /// Frase corta ("esguince de tobillo", "rotura de ligamento cruzado"...).
  final String motivo;

  /// Partidos que se pierde, estimados al crear la lesión (días / ritmo de
  /// un partido cada ~2 días).
  final int partidosEstimados;
  const Lesion({
    required this.id,
    required this.jugadorId,
    required this.fechaFin,
    required this.gravedad,
    required this.motivo,
    required this.partidosEstimados,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jugador_id'] = Variable<int>(jugadorId);
    map['fecha_fin'] = Variable<DateTime>(fechaFin);
    map['gravedad'] = Variable<String>(gravedad);
    map['motivo'] = Variable<String>(motivo);
    map['partidos_estimados'] = Variable<int>(partidosEstimados);
    return map;
  }

  LesionesCompanion toCompanion(bool nullToAbsent) {
    return LesionesCompanion(
      id: Value(id),
      jugadorId: Value(jugadorId),
      fechaFin: Value(fechaFin),
      gravedad: Value(gravedad),
      motivo: Value(motivo),
      partidosEstimados: Value(partidosEstimados),
    );
  }

  factory Lesion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lesion(
      id: serializer.fromJson<int>(json['id']),
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
      fechaFin: serializer.fromJson<DateTime>(json['fechaFin']),
      gravedad: serializer.fromJson<String>(json['gravedad']),
      motivo: serializer.fromJson<String>(json['motivo']),
      partidosEstimados: serializer.fromJson<int>(json['partidosEstimados']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jugadorId': serializer.toJson<int>(jugadorId),
      'fechaFin': serializer.toJson<DateTime>(fechaFin),
      'gravedad': serializer.toJson<String>(gravedad),
      'motivo': serializer.toJson<String>(motivo),
      'partidosEstimados': serializer.toJson<int>(partidosEstimados),
    };
  }

  Lesion copyWith({
    int? id,
    int? jugadorId,
    DateTime? fechaFin,
    String? gravedad,
    String? motivo,
    int? partidosEstimados,
  }) => Lesion(
    id: id ?? this.id,
    jugadorId: jugadorId ?? this.jugadorId,
    fechaFin: fechaFin ?? this.fechaFin,
    gravedad: gravedad ?? this.gravedad,
    motivo: motivo ?? this.motivo,
    partidosEstimados: partidosEstimados ?? this.partidosEstimados,
  );
  Lesion copyWithCompanion(LesionesCompanion data) {
    return Lesion(
      id: data.id.present ? data.id.value : this.id,
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
      fechaFin: data.fechaFin.present ? data.fechaFin.value : this.fechaFin,
      gravedad: data.gravedad.present ? data.gravedad.value : this.gravedad,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      partidosEstimados: data.partidosEstimados.present
          ? data.partidosEstimados.value
          : this.partidosEstimados,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lesion(')
          ..write('id: $id, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('gravedad: $gravedad, ')
          ..write('motivo: $motivo, ')
          ..write('partidosEstimados: $partidosEstimados')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, jugadorId, fechaFin, gravedad, motivo, partidosEstimados);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lesion &&
          other.id == this.id &&
          other.jugadorId == this.jugadorId &&
          other.fechaFin == this.fechaFin &&
          other.gravedad == this.gravedad &&
          other.motivo == this.motivo &&
          other.partidosEstimados == this.partidosEstimados);
}

class LesionesCompanion extends UpdateCompanion<Lesion> {
  final Value<int> id;
  final Value<int> jugadorId;
  final Value<DateTime> fechaFin;
  final Value<String> gravedad;
  final Value<String> motivo;
  final Value<int> partidosEstimados;
  const LesionesCompanion({
    this.id = const Value.absent(),
    this.jugadorId = const Value.absent(),
    this.fechaFin = const Value.absent(),
    this.gravedad = const Value.absent(),
    this.motivo = const Value.absent(),
    this.partidosEstimados = const Value.absent(),
  });
  LesionesCompanion.insert({
    this.id = const Value.absent(),
    required int jugadorId,
    required DateTime fechaFin,
    required String gravedad,
    this.motivo = const Value.absent(),
    this.partidosEstimados = const Value.absent(),
  }) : jugadorId = Value(jugadorId),
       fechaFin = Value(fechaFin),
       gravedad = Value(gravedad);
  static Insertable<Lesion> custom({
    Expression<int>? id,
    Expression<int>? jugadorId,
    Expression<DateTime>? fechaFin,
    Expression<String>? gravedad,
    Expression<String>? motivo,
    Expression<int>? partidosEstimados,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jugadorId != null) 'jugador_id': jugadorId,
      if (fechaFin != null) 'fecha_fin': fechaFin,
      if (gravedad != null) 'gravedad': gravedad,
      if (motivo != null) 'motivo': motivo,
      if (partidosEstimados != null) 'partidos_estimados': partidosEstimados,
    });
  }

  LesionesCompanion copyWith({
    Value<int>? id,
    Value<int>? jugadorId,
    Value<DateTime>? fechaFin,
    Value<String>? gravedad,
    Value<String>? motivo,
    Value<int>? partidosEstimados,
  }) {
    return LesionesCompanion(
      id: id ?? this.id,
      jugadorId: jugadorId ?? this.jugadorId,
      fechaFin: fechaFin ?? this.fechaFin,
      gravedad: gravedad ?? this.gravedad,
      motivo: motivo ?? this.motivo,
      partidosEstimados: partidosEstimados ?? this.partidosEstimados,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    if (fechaFin.present) {
      map['fecha_fin'] = Variable<DateTime>(fechaFin.value);
    }
    if (gravedad.present) {
      map['gravedad'] = Variable<String>(gravedad.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (partidosEstimados.present) {
      map['partidos_estimados'] = Variable<int>(partidosEstimados.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LesionesCompanion(')
          ..write('id: $id, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('gravedad: $gravedad, ')
          ..write('motivo: $motivo, ')
          ..write('partidosEstimados: $partidosEstimados')
          ..write(')'))
        .toString();
  }
}

class $EstadisticasTemporadaJugadorTable extends EstadisticasTemporadaJugador
    with
        TableInfo<
          $EstadisticasTemporadaJugadorTable,
          EstadisticasTemporadaJugadorData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstadisticasTemporadaJugadorTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partidosJugadosMeta = const VerificationMeta(
    'partidosJugados',
  );
  @override
  late final GeneratedColumn<int> partidosJugados = GeneratedColumn<int>(
    'partidos_jugados',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _puntosTotalesMeta = const VerificationMeta(
    'puntosTotales',
  );
  @override
  late final GeneratedColumn<int> puntosTotales = GeneratedColumn<int>(
    'puntos_totales',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _asistenciasTotalesMeta =
      const VerificationMeta('asistenciasTotales');
  @override
  late final GeneratedColumn<int> asistenciasTotales = GeneratedColumn<int>(
    'asistencias_totales',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rebotesTotalesMeta = const VerificationMeta(
    'rebotesTotales',
  );
  @override
  late final GeneratedColumn<int> rebotesTotales = GeneratedColumn<int>(
    'rebotes_totales',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    jugadorId,
    partidosJugados,
    puntosTotales,
    asistenciasTotales,
    rebotesTotales,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'estadisticas_temporada_jugador';
  @override
  VerificationContext validateIntegrity(
    Insertable<EstadisticasTemporadaJugadorData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    }
    if (data.containsKey('partidos_jugados')) {
      context.handle(
        _partidosJugadosMeta,
        partidosJugados.isAcceptableOrUnknown(
          data['partidos_jugados']!,
          _partidosJugadosMeta,
        ),
      );
    }
    if (data.containsKey('puntos_totales')) {
      context.handle(
        _puntosTotalesMeta,
        puntosTotales.isAcceptableOrUnknown(
          data['puntos_totales']!,
          _puntosTotalesMeta,
        ),
      );
    }
    if (data.containsKey('asistencias_totales')) {
      context.handle(
        _asistenciasTotalesMeta,
        asistenciasTotales.isAcceptableOrUnknown(
          data['asistencias_totales']!,
          _asistenciasTotalesMeta,
        ),
      );
    }
    if (data.containsKey('rebotes_totales')) {
      context.handle(
        _rebotesTotalesMeta,
        rebotesTotales.isAcceptableOrUnknown(
          data['rebotes_totales']!,
          _rebotesTotalesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jugadorId};
  @override
  EstadisticasTemporadaJugadorData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EstadisticasTemporadaJugadorData(
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
      partidosJugados: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partidos_jugados'],
      )!,
      puntosTotales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}puntos_totales'],
      )!,
      asistenciasTotales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asistencias_totales'],
      )!,
      rebotesTotales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rebotes_totales'],
      )!,
    );
  }

  @override
  $EstadisticasTemporadaJugadorTable createAlias(String alias) {
    return $EstadisticasTemporadaJugadorTable(attachedDatabase, alias);
  }
}

class EstadisticasTemporadaJugadorData extends DataClass
    implements Insertable<EstadisticasTemporadaJugadorData> {
  final int jugadorId;
  final int partidosJugados;
  final int puntosTotales;
  final int asistenciasTotales;
  final int rebotesTotales;
  const EstadisticasTemporadaJugadorData({
    required this.jugadorId,
    required this.partidosJugados,
    required this.puntosTotales,
    required this.asistenciasTotales,
    required this.rebotesTotales,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jugador_id'] = Variable<int>(jugadorId);
    map['partidos_jugados'] = Variable<int>(partidosJugados);
    map['puntos_totales'] = Variable<int>(puntosTotales);
    map['asistencias_totales'] = Variable<int>(asistenciasTotales);
    map['rebotes_totales'] = Variable<int>(rebotesTotales);
    return map;
  }

  EstadisticasTemporadaJugadorCompanion toCompanion(bool nullToAbsent) {
    return EstadisticasTemporadaJugadorCompanion(
      jugadorId: Value(jugadorId),
      partidosJugados: Value(partidosJugados),
      puntosTotales: Value(puntosTotales),
      asistenciasTotales: Value(asistenciasTotales),
      rebotesTotales: Value(rebotesTotales),
    );
  }

  factory EstadisticasTemporadaJugadorData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EstadisticasTemporadaJugadorData(
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
      partidosJugados: serializer.fromJson<int>(json['partidosJugados']),
      puntosTotales: serializer.fromJson<int>(json['puntosTotales']),
      asistenciasTotales: serializer.fromJson<int>(json['asistenciasTotales']),
      rebotesTotales: serializer.fromJson<int>(json['rebotesTotales']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jugadorId': serializer.toJson<int>(jugadorId),
      'partidosJugados': serializer.toJson<int>(partidosJugados),
      'puntosTotales': serializer.toJson<int>(puntosTotales),
      'asistenciasTotales': serializer.toJson<int>(asistenciasTotales),
      'rebotesTotales': serializer.toJson<int>(rebotesTotales),
    };
  }

  EstadisticasTemporadaJugadorData copyWith({
    int? jugadorId,
    int? partidosJugados,
    int? puntosTotales,
    int? asistenciasTotales,
    int? rebotesTotales,
  }) => EstadisticasTemporadaJugadorData(
    jugadorId: jugadorId ?? this.jugadorId,
    partidosJugados: partidosJugados ?? this.partidosJugados,
    puntosTotales: puntosTotales ?? this.puntosTotales,
    asistenciasTotales: asistenciasTotales ?? this.asistenciasTotales,
    rebotesTotales: rebotesTotales ?? this.rebotesTotales,
  );
  EstadisticasTemporadaJugadorData copyWithCompanion(
    EstadisticasTemporadaJugadorCompanion data,
  ) {
    return EstadisticasTemporadaJugadorData(
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
      partidosJugados: data.partidosJugados.present
          ? data.partidosJugados.value
          : this.partidosJugados,
      puntosTotales: data.puntosTotales.present
          ? data.puntosTotales.value
          : this.puntosTotales,
      asistenciasTotales: data.asistenciasTotales.present
          ? data.asistenciasTotales.value
          : this.asistenciasTotales,
      rebotesTotales: data.rebotesTotales.present
          ? data.rebotesTotales.value
          : this.rebotesTotales,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EstadisticasTemporadaJugadorData(')
          ..write('jugadorId: $jugadorId, ')
          ..write('partidosJugados: $partidosJugados, ')
          ..write('puntosTotales: $puntosTotales, ')
          ..write('asistenciasTotales: $asistenciasTotales, ')
          ..write('rebotesTotales: $rebotesTotales')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    jugadorId,
    partidosJugados,
    puntosTotales,
    asistenciasTotales,
    rebotesTotales,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EstadisticasTemporadaJugadorData &&
          other.jugadorId == this.jugadorId &&
          other.partidosJugados == this.partidosJugados &&
          other.puntosTotales == this.puntosTotales &&
          other.asistenciasTotales == this.asistenciasTotales &&
          other.rebotesTotales == this.rebotesTotales);
}

class EstadisticasTemporadaJugadorCompanion
    extends UpdateCompanion<EstadisticasTemporadaJugadorData> {
  final Value<int> jugadorId;
  final Value<int> partidosJugados;
  final Value<int> puntosTotales;
  final Value<int> asistenciasTotales;
  final Value<int> rebotesTotales;
  const EstadisticasTemporadaJugadorCompanion({
    this.jugadorId = const Value.absent(),
    this.partidosJugados = const Value.absent(),
    this.puntosTotales = const Value.absent(),
    this.asistenciasTotales = const Value.absent(),
    this.rebotesTotales = const Value.absent(),
  });
  EstadisticasTemporadaJugadorCompanion.insert({
    this.jugadorId = const Value.absent(),
    this.partidosJugados = const Value.absent(),
    this.puntosTotales = const Value.absent(),
    this.asistenciasTotales = const Value.absent(),
    this.rebotesTotales = const Value.absent(),
  });
  static Insertable<EstadisticasTemporadaJugadorData> custom({
    Expression<int>? jugadorId,
    Expression<int>? partidosJugados,
    Expression<int>? puntosTotales,
    Expression<int>? asistenciasTotales,
    Expression<int>? rebotesTotales,
  }) {
    return RawValuesInsertable({
      if (jugadorId != null) 'jugador_id': jugadorId,
      if (partidosJugados != null) 'partidos_jugados': partidosJugados,
      if (puntosTotales != null) 'puntos_totales': puntosTotales,
      if (asistenciasTotales != null) 'asistencias_totales': asistenciasTotales,
      if (rebotesTotales != null) 'rebotes_totales': rebotesTotales,
    });
  }

  EstadisticasTemporadaJugadorCompanion copyWith({
    Value<int>? jugadorId,
    Value<int>? partidosJugados,
    Value<int>? puntosTotales,
    Value<int>? asistenciasTotales,
    Value<int>? rebotesTotales,
  }) {
    return EstadisticasTemporadaJugadorCompanion(
      jugadorId: jugadorId ?? this.jugadorId,
      partidosJugados: partidosJugados ?? this.partidosJugados,
      puntosTotales: puntosTotales ?? this.puntosTotales,
      asistenciasTotales: asistenciasTotales ?? this.asistenciasTotales,
      rebotesTotales: rebotesTotales ?? this.rebotesTotales,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    if (partidosJugados.present) {
      map['partidos_jugados'] = Variable<int>(partidosJugados.value);
    }
    if (puntosTotales.present) {
      map['puntos_totales'] = Variable<int>(puntosTotales.value);
    }
    if (asistenciasTotales.present) {
      map['asistencias_totales'] = Variable<int>(asistenciasTotales.value);
    }
    if (rebotesTotales.present) {
      map['rebotes_totales'] = Variable<int>(rebotesTotales.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstadisticasTemporadaJugadorCompanion(')
          ..write('jugadorId: $jugadorId, ')
          ..write('partidosJugados: $partidosJugados, ')
          ..write('puntosTotales: $puntosTotales, ')
          ..write('asistenciasTotales: $asistenciasTotales, ')
          ..write('rebotesTotales: $rebotesTotales')
          ..write(')'))
        .toString();
  }
}

class $ResultadoTemporadaTable extends ResultadoTemporada
    with TableInfo<$ResultadoTemporadaTable, ResultadoTemporadaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResultadoTemporadaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _victoriasMeta = const VerificationMeta(
    'victorias',
  );
  @override
  late final GeneratedColumn<int> victorias = GeneratedColumn<int>(
    'victorias',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _derrotasMeta = const VerificationMeta(
    'derrotas',
  );
  @override
  late final GeneratedColumn<int> derrotas = GeneratedColumn<int>(
    'derrotas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [equipo, victorias, derrotas];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resultado_temporada';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResultadoTemporadaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    if (data.containsKey('victorias')) {
      context.handle(
        _victoriasMeta,
        victorias.isAcceptableOrUnknown(data['victorias']!, _victoriasMeta),
      );
    }
    if (data.containsKey('derrotas')) {
      context.handle(
        _derrotasMeta,
        derrotas.isAcceptableOrUnknown(data['derrotas']!, _derrotasMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {equipo};
  @override
  ResultadoTemporadaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResultadoTemporadaData(
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
      victorias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}victorias'],
      )!,
      derrotas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}derrotas'],
      )!,
    );
  }

  @override
  $ResultadoTemporadaTable createAlias(String alias) {
    return $ResultadoTemporadaTable(attachedDatabase, alias);
  }
}

class ResultadoTemporadaData extends DataClass
    implements Insertable<ResultadoTemporadaData> {
  final String equipo;
  final int victorias;
  final int derrotas;
  const ResultadoTemporadaData({
    required this.equipo,
    required this.victorias,
    required this.derrotas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['equipo'] = Variable<String>(equipo);
    map['victorias'] = Variable<int>(victorias);
    map['derrotas'] = Variable<int>(derrotas);
    return map;
  }

  ResultadoTemporadaCompanion toCompanion(bool nullToAbsent) {
    return ResultadoTemporadaCompanion(
      equipo: Value(equipo),
      victorias: Value(victorias),
      derrotas: Value(derrotas),
    );
  }

  factory ResultadoTemporadaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResultadoTemporadaData(
      equipo: serializer.fromJson<String>(json['equipo']),
      victorias: serializer.fromJson<int>(json['victorias']),
      derrotas: serializer.fromJson<int>(json['derrotas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'equipo': serializer.toJson<String>(equipo),
      'victorias': serializer.toJson<int>(victorias),
      'derrotas': serializer.toJson<int>(derrotas),
    };
  }

  ResultadoTemporadaData copyWith({
    String? equipo,
    int? victorias,
    int? derrotas,
  }) => ResultadoTemporadaData(
    equipo: equipo ?? this.equipo,
    victorias: victorias ?? this.victorias,
    derrotas: derrotas ?? this.derrotas,
  );
  ResultadoTemporadaData copyWithCompanion(ResultadoTemporadaCompanion data) {
    return ResultadoTemporadaData(
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
      victorias: data.victorias.present ? data.victorias.value : this.victorias,
      derrotas: data.derrotas.present ? data.derrotas.value : this.derrotas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResultadoTemporadaData(')
          ..write('equipo: $equipo, ')
          ..write('victorias: $victorias, ')
          ..write('derrotas: $derrotas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(equipo, victorias, derrotas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResultadoTemporadaData &&
          other.equipo == this.equipo &&
          other.victorias == this.victorias &&
          other.derrotas == this.derrotas);
}

class ResultadoTemporadaCompanion
    extends UpdateCompanion<ResultadoTemporadaData> {
  final Value<String> equipo;
  final Value<int> victorias;
  final Value<int> derrotas;
  final Value<int> rowid;
  const ResultadoTemporadaCompanion({
    this.equipo = const Value.absent(),
    this.victorias = const Value.absent(),
    this.derrotas = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResultadoTemporadaCompanion.insert({
    required String equipo,
    this.victorias = const Value.absent(),
    this.derrotas = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : equipo = Value(equipo);
  static Insertable<ResultadoTemporadaData> custom({
    Expression<String>? equipo,
    Expression<int>? victorias,
    Expression<int>? derrotas,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (equipo != null) 'equipo': equipo,
      if (victorias != null) 'victorias': victorias,
      if (derrotas != null) 'derrotas': derrotas,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResultadoTemporadaCompanion copyWith({
    Value<String>? equipo,
    Value<int>? victorias,
    Value<int>? derrotas,
    Value<int>? rowid,
  }) {
    return ResultadoTemporadaCompanion(
      equipo: equipo ?? this.equipo,
      victorias: victorias ?? this.victorias,
      derrotas: derrotas ?? this.derrotas,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    if (victorias.present) {
      map['victorias'] = Variable<int>(victorias.value);
    }
    if (derrotas.present) {
      map['derrotas'] = Variable<int>(derrotas.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResultadoTemporadaCompanion(')
          ..write('equipo: $equipo, ')
          ..write('victorias: $victorias, ')
          ..write('derrotas: $derrotas, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PremiosTemporadaTable extends PremiosTemporada
    with TableInfo<$PremiosTemporadaTable, PremiosTemporadaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PremiosTemporadaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, tipo, jugadorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'premios_temporada';
  @override
  VerificationContext validateIntegrity(
    Insertable<PremiosTemporadaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jugadorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PremiosTemporadaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PremiosTemporadaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
    );
  }

  @override
  $PremiosTemporadaTable createAlias(String alias) {
    return $PremiosTemporadaTable(attachedDatabase, alias);
  }
}

class PremiosTemporadaData extends DataClass
    implements Insertable<PremiosTemporadaData> {
  final int id;
  final String tipo;
  final int jugadorId;
  const PremiosTemporadaData({
    required this.id,
    required this.tipo,
    required this.jugadorId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo'] = Variable<String>(tipo);
    map['jugador_id'] = Variable<int>(jugadorId);
    return map;
  }

  PremiosTemporadaCompanion toCompanion(bool nullToAbsent) {
    return PremiosTemporadaCompanion(
      id: Value(id),
      tipo: Value(tipo),
      jugadorId: Value(jugadorId),
    );
  }

  factory PremiosTemporadaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PremiosTemporadaData(
      id: serializer.fromJson<int>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipo': serializer.toJson<String>(tipo),
      'jugadorId': serializer.toJson<int>(jugadorId),
    };
  }

  PremiosTemporadaData copyWith({int? id, String? tipo, int? jugadorId}) =>
      PremiosTemporadaData(
        id: id ?? this.id,
        tipo: tipo ?? this.tipo,
        jugadorId: jugadorId ?? this.jugadorId,
      );
  PremiosTemporadaData copyWithCompanion(PremiosTemporadaCompanion data) {
    return PremiosTemporadaData(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PremiosTemporadaData(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('jugadorId: $jugadorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tipo, jugadorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PremiosTemporadaData &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.jugadorId == this.jugadorId);
}

class PremiosTemporadaCompanion extends UpdateCompanion<PremiosTemporadaData> {
  final Value<int> id;
  final Value<String> tipo;
  final Value<int> jugadorId;
  const PremiosTemporadaCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.jugadorId = const Value.absent(),
  });
  PremiosTemporadaCompanion.insert({
    this.id = const Value.absent(),
    required String tipo,
    required int jugadorId,
  }) : tipo = Value(tipo),
       jugadorId = Value(jugadorId);
  static Insertable<PremiosTemporadaData> custom({
    Expression<int>? id,
    Expression<String>? tipo,
    Expression<int>? jugadorId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (jugadorId != null) 'jugador_id': jugadorId,
    });
  }

  PremiosTemporadaCompanion copyWith({
    Value<int>? id,
    Value<String>? tipo,
    Value<int>? jugadorId,
  }) {
    return PremiosTemporadaCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      jugadorId: jugadorId ?? this.jugadorId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PremiosTemporadaCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('jugadorId: $jugadorId')
          ..write(')'))
        .toString();
  }
}

class $SeriesPlayoffsTable extends SeriesPlayoffs
    with TableInfo<$SeriesPlayoffsTable, Serie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesPlayoffsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conferenciaMeta = const VerificationMeta(
    'conferencia',
  );
  @override
  late final GeneratedColumn<String> conferencia = GeneratedColumn<String>(
    'conferencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rondaMeta = const VerificationMeta('ronda');
  @override
  late final GeneratedColumn<int> ronda = GeneratedColumn<int>(
    'ronda',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etapaMeta = const VerificationMeta('etapa');
  @override
  late final GeneratedColumn<String> etapa = GeneratedColumn<String>(
    'etapa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoAMeta = const VerificationMeta(
    'equipoA',
  );
  @override
  late final GeneratedColumn<String> equipoA = GeneratedColumn<String>(
    'equipo_a',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoBMeta = const VerificationMeta(
    'equipoB',
  );
  @override
  late final GeneratedColumn<String> equipoB = GeneratedColumn<String>(
    'equipo_b',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedAMeta = const VerificationMeta('seedA');
  @override
  late final GeneratedColumn<int> seedA = GeneratedColumn<int>(
    'seed_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedBMeta = const VerificationMeta('seedB');
  @override
  late final GeneratedColumn<int> seedB = GeneratedColumn<int>(
    'seed_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _victoriasAMeta = const VerificationMeta(
    'victoriasA',
  );
  @override
  late final GeneratedColumn<int> victoriasA = GeneratedColumn<int>(
    'victorias_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _victoriasBMeta = const VerificationMeta(
    'victoriasB',
  );
  @override
  late final GeneratedColumn<int> victoriasB = GeneratedColumn<int>(
    'victorias_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _victoriasNecesariasMeta =
      const VerificationMeta('victoriasNecesarias');
  @override
  late final GeneratedColumn<int> victoriasNecesarias = GeneratedColumn<int>(
    'victorias_necesarias',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _ganadorMeta = const VerificationMeta(
    'ganador',
  );
  @override
  late final GeneratedColumn<String> ganador = GeneratedColumn<String>(
    'ganador',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conferencia,
    ronda,
    etapa,
    equipoA,
    equipoB,
    seedA,
    seedB,
    victoriasA,
    victoriasB,
    victoriasNecesarias,
    ganador,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_playoffs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Serie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conferencia')) {
      context.handle(
        _conferenciaMeta,
        conferencia.isAcceptableOrUnknown(
          data['conferencia']!,
          _conferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conferenciaMeta);
    }
    if (data.containsKey('ronda')) {
      context.handle(
        _rondaMeta,
        ronda.isAcceptableOrUnknown(data['ronda']!, _rondaMeta),
      );
    } else if (isInserting) {
      context.missing(_rondaMeta);
    }
    if (data.containsKey('etapa')) {
      context.handle(
        _etapaMeta,
        etapa.isAcceptableOrUnknown(data['etapa']!, _etapaMeta),
      );
    } else if (isInserting) {
      context.missing(_etapaMeta);
    }
    if (data.containsKey('equipo_a')) {
      context.handle(
        _equipoAMeta,
        equipoA.isAcceptableOrUnknown(data['equipo_a']!, _equipoAMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoAMeta);
    }
    if (data.containsKey('equipo_b')) {
      context.handle(
        _equipoBMeta,
        equipoB.isAcceptableOrUnknown(data['equipo_b']!, _equipoBMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoBMeta);
    }
    if (data.containsKey('seed_a')) {
      context.handle(
        _seedAMeta,
        seedA.isAcceptableOrUnknown(data['seed_a']!, _seedAMeta),
      );
    } else if (isInserting) {
      context.missing(_seedAMeta);
    }
    if (data.containsKey('seed_b')) {
      context.handle(
        _seedBMeta,
        seedB.isAcceptableOrUnknown(data['seed_b']!, _seedBMeta),
      );
    } else if (isInserting) {
      context.missing(_seedBMeta);
    }
    if (data.containsKey('victorias_a')) {
      context.handle(
        _victoriasAMeta,
        victoriasA.isAcceptableOrUnknown(data['victorias_a']!, _victoriasAMeta),
      );
    }
    if (data.containsKey('victorias_b')) {
      context.handle(
        _victoriasBMeta,
        victoriasB.isAcceptableOrUnknown(data['victorias_b']!, _victoriasBMeta),
      );
    }
    if (data.containsKey('victorias_necesarias')) {
      context.handle(
        _victoriasNecesariasMeta,
        victoriasNecesarias.isAcceptableOrUnknown(
          data['victorias_necesarias']!,
          _victoriasNecesariasMeta,
        ),
      );
    }
    if (data.containsKey('ganador')) {
      context.handle(
        _ganadorMeta,
        ganador.isAcceptableOrUnknown(data['ganador']!, _ganadorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Serie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Serie(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conferencia'],
      )!,
      ronda: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ronda'],
      )!,
      etapa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etapa'],
      )!,
      equipoA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_a'],
      )!,
      equipoB: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_b'],
      )!,
      seedA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed_a'],
      )!,
      seedB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed_b'],
      )!,
      victoriasA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}victorias_a'],
      )!,
      victoriasB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}victorias_b'],
      )!,
      victoriasNecesarias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}victorias_necesarias'],
      )!,
      ganador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ganador'],
      ),
    );
  }

  @override
  $SeriesPlayoffsTable createAlias(String alias) {
    return $SeriesPlayoffsTable(attachedDatabase, alias);
  }
}

class Serie extends DataClass implements Insertable<Serie> {
  final int id;
  final String conferencia;
  final int ronda;
  final String etapa;
  final String equipoA;
  final String equipoB;
  final int seedA;
  final int seedB;
  final int victoriasA;
  final int victoriasB;
  final int victoriasNecesarias;
  final String? ganador;
  const Serie({
    required this.id,
    required this.conferencia,
    required this.ronda,
    required this.etapa,
    required this.equipoA,
    required this.equipoB,
    required this.seedA,
    required this.seedB,
    required this.victoriasA,
    required this.victoriasB,
    required this.victoriasNecesarias,
    this.ganador,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conferencia'] = Variable<String>(conferencia);
    map['ronda'] = Variable<int>(ronda);
    map['etapa'] = Variable<String>(etapa);
    map['equipo_a'] = Variable<String>(equipoA);
    map['equipo_b'] = Variable<String>(equipoB);
    map['seed_a'] = Variable<int>(seedA);
    map['seed_b'] = Variable<int>(seedB);
    map['victorias_a'] = Variable<int>(victoriasA);
    map['victorias_b'] = Variable<int>(victoriasB);
    map['victorias_necesarias'] = Variable<int>(victoriasNecesarias);
    if (!nullToAbsent || ganador != null) {
      map['ganador'] = Variable<String>(ganador);
    }
    return map;
  }

  SeriesPlayoffsCompanion toCompanion(bool nullToAbsent) {
    return SeriesPlayoffsCompanion(
      id: Value(id),
      conferencia: Value(conferencia),
      ronda: Value(ronda),
      etapa: Value(etapa),
      equipoA: Value(equipoA),
      equipoB: Value(equipoB),
      seedA: Value(seedA),
      seedB: Value(seedB),
      victoriasA: Value(victoriasA),
      victoriasB: Value(victoriasB),
      victoriasNecesarias: Value(victoriasNecesarias),
      ganador: ganador == null && nullToAbsent
          ? const Value.absent()
          : Value(ganador),
    );
  }

  factory Serie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Serie(
      id: serializer.fromJson<int>(json['id']),
      conferencia: serializer.fromJson<String>(json['conferencia']),
      ronda: serializer.fromJson<int>(json['ronda']),
      etapa: serializer.fromJson<String>(json['etapa']),
      equipoA: serializer.fromJson<String>(json['equipoA']),
      equipoB: serializer.fromJson<String>(json['equipoB']),
      seedA: serializer.fromJson<int>(json['seedA']),
      seedB: serializer.fromJson<int>(json['seedB']),
      victoriasA: serializer.fromJson<int>(json['victoriasA']),
      victoriasB: serializer.fromJson<int>(json['victoriasB']),
      victoriasNecesarias: serializer.fromJson<int>(
        json['victoriasNecesarias'],
      ),
      ganador: serializer.fromJson<String?>(json['ganador']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conferencia': serializer.toJson<String>(conferencia),
      'ronda': serializer.toJson<int>(ronda),
      'etapa': serializer.toJson<String>(etapa),
      'equipoA': serializer.toJson<String>(equipoA),
      'equipoB': serializer.toJson<String>(equipoB),
      'seedA': serializer.toJson<int>(seedA),
      'seedB': serializer.toJson<int>(seedB),
      'victoriasA': serializer.toJson<int>(victoriasA),
      'victoriasB': serializer.toJson<int>(victoriasB),
      'victoriasNecesarias': serializer.toJson<int>(victoriasNecesarias),
      'ganador': serializer.toJson<String?>(ganador),
    };
  }

  Serie copyWith({
    int? id,
    String? conferencia,
    int? ronda,
    String? etapa,
    String? equipoA,
    String? equipoB,
    int? seedA,
    int? seedB,
    int? victoriasA,
    int? victoriasB,
    int? victoriasNecesarias,
    Value<String?> ganador = const Value.absent(),
  }) => Serie(
    id: id ?? this.id,
    conferencia: conferencia ?? this.conferencia,
    ronda: ronda ?? this.ronda,
    etapa: etapa ?? this.etapa,
    equipoA: equipoA ?? this.equipoA,
    equipoB: equipoB ?? this.equipoB,
    seedA: seedA ?? this.seedA,
    seedB: seedB ?? this.seedB,
    victoriasA: victoriasA ?? this.victoriasA,
    victoriasB: victoriasB ?? this.victoriasB,
    victoriasNecesarias: victoriasNecesarias ?? this.victoriasNecesarias,
    ganador: ganador.present ? ganador.value : this.ganador,
  );
  Serie copyWithCompanion(SeriesPlayoffsCompanion data) {
    return Serie(
      id: data.id.present ? data.id.value : this.id,
      conferencia: data.conferencia.present
          ? data.conferencia.value
          : this.conferencia,
      ronda: data.ronda.present ? data.ronda.value : this.ronda,
      etapa: data.etapa.present ? data.etapa.value : this.etapa,
      equipoA: data.equipoA.present ? data.equipoA.value : this.equipoA,
      equipoB: data.equipoB.present ? data.equipoB.value : this.equipoB,
      seedA: data.seedA.present ? data.seedA.value : this.seedA,
      seedB: data.seedB.present ? data.seedB.value : this.seedB,
      victoriasA: data.victoriasA.present
          ? data.victoriasA.value
          : this.victoriasA,
      victoriasB: data.victoriasB.present
          ? data.victoriasB.value
          : this.victoriasB,
      victoriasNecesarias: data.victoriasNecesarias.present
          ? data.victoriasNecesarias.value
          : this.victoriasNecesarias,
      ganador: data.ganador.present ? data.ganador.value : this.ganador,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Serie(')
          ..write('id: $id, ')
          ..write('conferencia: $conferencia, ')
          ..write('ronda: $ronda, ')
          ..write('etapa: $etapa, ')
          ..write('equipoA: $equipoA, ')
          ..write('equipoB: $equipoB, ')
          ..write('seedA: $seedA, ')
          ..write('seedB: $seedB, ')
          ..write('victoriasA: $victoriasA, ')
          ..write('victoriasB: $victoriasB, ')
          ..write('victoriasNecesarias: $victoriasNecesarias, ')
          ..write('ganador: $ganador')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conferencia,
    ronda,
    etapa,
    equipoA,
    equipoB,
    seedA,
    seedB,
    victoriasA,
    victoriasB,
    victoriasNecesarias,
    ganador,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Serie &&
          other.id == this.id &&
          other.conferencia == this.conferencia &&
          other.ronda == this.ronda &&
          other.etapa == this.etapa &&
          other.equipoA == this.equipoA &&
          other.equipoB == this.equipoB &&
          other.seedA == this.seedA &&
          other.seedB == this.seedB &&
          other.victoriasA == this.victoriasA &&
          other.victoriasB == this.victoriasB &&
          other.victoriasNecesarias == this.victoriasNecesarias &&
          other.ganador == this.ganador);
}

class SeriesPlayoffsCompanion extends UpdateCompanion<Serie> {
  final Value<int> id;
  final Value<String> conferencia;
  final Value<int> ronda;
  final Value<String> etapa;
  final Value<String> equipoA;
  final Value<String> equipoB;
  final Value<int> seedA;
  final Value<int> seedB;
  final Value<int> victoriasA;
  final Value<int> victoriasB;
  final Value<int> victoriasNecesarias;
  final Value<String?> ganador;
  const SeriesPlayoffsCompanion({
    this.id = const Value.absent(),
    this.conferencia = const Value.absent(),
    this.ronda = const Value.absent(),
    this.etapa = const Value.absent(),
    this.equipoA = const Value.absent(),
    this.equipoB = const Value.absent(),
    this.seedA = const Value.absent(),
    this.seedB = const Value.absent(),
    this.victoriasA = const Value.absent(),
    this.victoriasB = const Value.absent(),
    this.victoriasNecesarias = const Value.absent(),
    this.ganador = const Value.absent(),
  });
  SeriesPlayoffsCompanion.insert({
    this.id = const Value.absent(),
    required String conferencia,
    required int ronda,
    required String etapa,
    required String equipoA,
    required String equipoB,
    required int seedA,
    required int seedB,
    this.victoriasA = const Value.absent(),
    this.victoriasB = const Value.absent(),
    this.victoriasNecesarias = const Value.absent(),
    this.ganador = const Value.absent(),
  }) : conferencia = Value(conferencia),
       ronda = Value(ronda),
       etapa = Value(etapa),
       equipoA = Value(equipoA),
       equipoB = Value(equipoB),
       seedA = Value(seedA),
       seedB = Value(seedB);
  static Insertable<Serie> custom({
    Expression<int>? id,
    Expression<String>? conferencia,
    Expression<int>? ronda,
    Expression<String>? etapa,
    Expression<String>? equipoA,
    Expression<String>? equipoB,
    Expression<int>? seedA,
    Expression<int>? seedB,
    Expression<int>? victoriasA,
    Expression<int>? victoriasB,
    Expression<int>? victoriasNecesarias,
    Expression<String>? ganador,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conferencia != null) 'conferencia': conferencia,
      if (ronda != null) 'ronda': ronda,
      if (etapa != null) 'etapa': etapa,
      if (equipoA != null) 'equipo_a': equipoA,
      if (equipoB != null) 'equipo_b': equipoB,
      if (seedA != null) 'seed_a': seedA,
      if (seedB != null) 'seed_b': seedB,
      if (victoriasA != null) 'victorias_a': victoriasA,
      if (victoriasB != null) 'victorias_b': victoriasB,
      if (victoriasNecesarias != null)
        'victorias_necesarias': victoriasNecesarias,
      if (ganador != null) 'ganador': ganador,
    });
  }

  SeriesPlayoffsCompanion copyWith({
    Value<int>? id,
    Value<String>? conferencia,
    Value<int>? ronda,
    Value<String>? etapa,
    Value<String>? equipoA,
    Value<String>? equipoB,
    Value<int>? seedA,
    Value<int>? seedB,
    Value<int>? victoriasA,
    Value<int>? victoriasB,
    Value<int>? victoriasNecesarias,
    Value<String?>? ganador,
  }) {
    return SeriesPlayoffsCompanion(
      id: id ?? this.id,
      conferencia: conferencia ?? this.conferencia,
      ronda: ronda ?? this.ronda,
      etapa: etapa ?? this.etapa,
      equipoA: equipoA ?? this.equipoA,
      equipoB: equipoB ?? this.equipoB,
      seedA: seedA ?? this.seedA,
      seedB: seedB ?? this.seedB,
      victoriasA: victoriasA ?? this.victoriasA,
      victoriasB: victoriasB ?? this.victoriasB,
      victoriasNecesarias: victoriasNecesarias ?? this.victoriasNecesarias,
      ganador: ganador ?? this.ganador,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conferencia.present) {
      map['conferencia'] = Variable<String>(conferencia.value);
    }
    if (ronda.present) {
      map['ronda'] = Variable<int>(ronda.value);
    }
    if (etapa.present) {
      map['etapa'] = Variable<String>(etapa.value);
    }
    if (equipoA.present) {
      map['equipo_a'] = Variable<String>(equipoA.value);
    }
    if (equipoB.present) {
      map['equipo_b'] = Variable<String>(equipoB.value);
    }
    if (seedA.present) {
      map['seed_a'] = Variable<int>(seedA.value);
    }
    if (seedB.present) {
      map['seed_b'] = Variable<int>(seedB.value);
    }
    if (victoriasA.present) {
      map['victorias_a'] = Variable<int>(victoriasA.value);
    }
    if (victoriasB.present) {
      map['victorias_b'] = Variable<int>(victoriasB.value);
    }
    if (victoriasNecesarias.present) {
      map['victorias_necesarias'] = Variable<int>(victoriasNecesarias.value);
    }
    if (ganador.present) {
      map['ganador'] = Variable<String>(ganador.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesPlayoffsCompanion(')
          ..write('id: $id, ')
          ..write('conferencia: $conferencia, ')
          ..write('ronda: $ronda, ')
          ..write('etapa: $etapa, ')
          ..write('equipoA: $equipoA, ')
          ..write('equipoB: $equipoB, ')
          ..write('seedA: $seedA, ')
          ..write('seedB: $seedB, ')
          ..write('victoriasA: $victoriasA, ')
          ..write('victoriasB: $victoriasB, ')
          ..write('victoriasNecesarias: $victoriasNecesarias, ')
          ..write('ganador: $ganador')
          ..write(')'))
        .toString();
  }
}

class $AjustesTable extends Ajustes with TableInfo<$AjustesTable, Ajuste> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AjustesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modoOscuroMeta = const VerificationMeta(
    'modoOscuro',
  );
  @override
  late final GeneratedColumn<bool> modoOscuro = GeneratedColumn<bool>(
    'modo_oscuro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("modo_oscuro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idiomaMeta = const VerificationMeta('idioma');
  @override
  late final GeneratedColumn<String> idioma = GeneratedColumn<String>(
    'idioma',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('es'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, modoOscuro, idioma];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ajustes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ajuste> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('modo_oscuro')) {
      context.handle(
        _modoOscuroMeta,
        modoOscuro.isAcceptableOrUnknown(data['modo_oscuro']!, _modoOscuroMeta),
      );
    }
    if (data.containsKey('idioma')) {
      context.handle(
        _idiomaMeta,
        idioma.isAcceptableOrUnknown(data['idioma']!, _idiomaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ajuste map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ajuste(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modoOscuro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}modo_oscuro'],
      )!,
      idioma: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idioma'],
      )!,
    );
  }

  @override
  $AjustesTable createAlias(String alias) {
    return $AjustesTable(attachedDatabase, alias);
  }
}

class Ajuste extends DataClass implements Insertable<Ajuste> {
  final int id;
  final bool modoOscuro;

  /// 'es' o 'en' — el selector real llega en la Fase 3b.
  final String idioma;
  const Ajuste({
    required this.id,
    required this.modoOscuro,
    required this.idioma,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['modo_oscuro'] = Variable<bool>(modoOscuro);
    map['idioma'] = Variable<String>(idioma);
    return map;
  }

  AjustesCompanion toCompanion(bool nullToAbsent) {
    return AjustesCompanion(
      id: Value(id),
      modoOscuro: Value(modoOscuro),
      idioma: Value(idioma),
    );
  }

  factory Ajuste.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ajuste(
      id: serializer.fromJson<int>(json['id']),
      modoOscuro: serializer.fromJson<bool>(json['modoOscuro']),
      idioma: serializer.fromJson<String>(json['idioma']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modoOscuro': serializer.toJson<bool>(modoOscuro),
      'idioma': serializer.toJson<String>(idioma),
    };
  }

  Ajuste copyWith({int? id, bool? modoOscuro, String? idioma}) => Ajuste(
    id: id ?? this.id,
    modoOscuro: modoOscuro ?? this.modoOscuro,
    idioma: idioma ?? this.idioma,
  );
  Ajuste copyWithCompanion(AjustesCompanion data) {
    return Ajuste(
      id: data.id.present ? data.id.value : this.id,
      modoOscuro: data.modoOscuro.present
          ? data.modoOscuro.value
          : this.modoOscuro,
      idioma: data.idioma.present ? data.idioma.value : this.idioma,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ajuste(')
          ..write('id: $id, ')
          ..write('modoOscuro: $modoOscuro, ')
          ..write('idioma: $idioma')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, modoOscuro, idioma);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ajuste &&
          other.id == this.id &&
          other.modoOscuro == this.modoOscuro &&
          other.idioma == this.idioma);
}

class AjustesCompanion extends UpdateCompanion<Ajuste> {
  final Value<int> id;
  final Value<bool> modoOscuro;
  final Value<String> idioma;
  const AjustesCompanion({
    this.id = const Value.absent(),
    this.modoOscuro = const Value.absent(),
    this.idioma = const Value.absent(),
  });
  AjustesCompanion.insert({
    this.id = const Value.absent(),
    this.modoOscuro = const Value.absent(),
    this.idioma = const Value.absent(),
  });
  static Insertable<Ajuste> custom({
    Expression<int>? id,
    Expression<bool>? modoOscuro,
    Expression<String>? idioma,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modoOscuro != null) 'modo_oscuro': modoOscuro,
      if (idioma != null) 'idioma': idioma,
    });
  }

  AjustesCompanion copyWith({
    Value<int>? id,
    Value<bool>? modoOscuro,
    Value<String>? idioma,
  }) {
    return AjustesCompanion(
      id: id ?? this.id,
      modoOscuro: modoOscuro ?? this.modoOscuro,
      idioma: idioma ?? this.idioma,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modoOscuro.present) {
      map['modo_oscuro'] = Variable<bool>(modoOscuro.value);
    }
    if (idioma.present) {
      map['idioma'] = Variable<String>(idioma.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AjustesCompanion(')
          ..write('id: $id, ')
          ..write('modoOscuro: $modoOscuro, ')
          ..write('idioma: $idioma')
          ..write(')'))
        .toString();
  }
}

class $HistorialCampeonesTable extends HistorialCampeones
    with TableInfo<$HistorialCampeonesTable, Campeonato> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistorialCampeonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temporadaMeta = const VerificationMeta(
    'temporada',
  );
  @override
  late final GeneratedColumn<int> temporada = GeneratedColumn<int>(
    'temporada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _logradoPorUsuarioMeta = const VerificationMeta(
    'logradoPorUsuario',
  );
  @override
  late final GeneratedColumn<bool> logradoPorUsuario = GeneratedColumn<bool>(
    'logrado_por_usuario',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("logrado_por_usuario" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    equipo,
    tipo,
    fecha,
    temporada,
    logradoPorUsuario,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historial_campeones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Campeonato> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('temporada')) {
      context.handle(
        _temporadaMeta,
        temporada.isAcceptableOrUnknown(data['temporada']!, _temporadaMeta),
      );
    }
    if (data.containsKey('logrado_por_usuario')) {
      context.handle(
        _logradoPorUsuarioMeta,
        logradoPorUsuario.isAcceptableOrUnknown(
          data['logrado_por_usuario']!,
          _logradoPorUsuarioMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Campeonato map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Campeonato(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      temporada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporada'],
      )!,
      logradoPorUsuario: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}logrado_por_usuario'],
      )!,
    );
  }

  @override
  $HistorialCampeonesTable createAlias(String alias) {
    return $HistorialCampeonesTable(attachedDatabase, alias);
  }
}

class Campeonato extends DataClass implements Insertable<Campeonato> {
  final int id;
  final String equipo;
  final String tipo;
  final DateTime fecha;
  final int temporada;
  final bool logradoPorUsuario;
  const Campeonato({
    required this.id,
    required this.equipo,
    required this.tipo,
    required this.fecha,
    required this.temporada,
    required this.logradoPorUsuario,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['equipo'] = Variable<String>(equipo);
    map['tipo'] = Variable<String>(tipo);
    map['fecha'] = Variable<DateTime>(fecha);
    map['temporada'] = Variable<int>(temporada);
    map['logrado_por_usuario'] = Variable<bool>(logradoPorUsuario);
    return map;
  }

  HistorialCampeonesCompanion toCompanion(bool nullToAbsent) {
    return HistorialCampeonesCompanion(
      id: Value(id),
      equipo: Value(equipo),
      tipo: Value(tipo),
      fecha: Value(fecha),
      temporada: Value(temporada),
      logradoPorUsuario: Value(logradoPorUsuario),
    );
  }

  factory Campeonato.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Campeonato(
      id: serializer.fromJson<int>(json['id']),
      equipo: serializer.fromJson<String>(json['equipo']),
      tipo: serializer.fromJson<String>(json['tipo']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      temporada: serializer.fromJson<int>(json['temporada']),
      logradoPorUsuario: serializer.fromJson<bool>(json['logradoPorUsuario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'equipo': serializer.toJson<String>(equipo),
      'tipo': serializer.toJson<String>(tipo),
      'fecha': serializer.toJson<DateTime>(fecha),
      'temporada': serializer.toJson<int>(temporada),
      'logradoPorUsuario': serializer.toJson<bool>(logradoPorUsuario),
    };
  }

  Campeonato copyWith({
    int? id,
    String? equipo,
    String? tipo,
    DateTime? fecha,
    int? temporada,
    bool? logradoPorUsuario,
  }) => Campeonato(
    id: id ?? this.id,
    equipo: equipo ?? this.equipo,
    tipo: tipo ?? this.tipo,
    fecha: fecha ?? this.fecha,
    temporada: temporada ?? this.temporada,
    logradoPorUsuario: logradoPorUsuario ?? this.logradoPorUsuario,
  );
  Campeonato copyWithCompanion(HistorialCampeonesCompanion data) {
    return Campeonato(
      id: data.id.present ? data.id.value : this.id,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      temporada: data.temporada.present ? data.temporada.value : this.temporada,
      logradoPorUsuario: data.logradoPorUsuario.present
          ? data.logradoPorUsuario.value
          : this.logradoPorUsuario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Campeonato(')
          ..write('id: $id, ')
          ..write('equipo: $equipo, ')
          ..write('tipo: $tipo, ')
          ..write('fecha: $fecha, ')
          ..write('temporada: $temporada, ')
          ..write('logradoPorUsuario: $logradoPorUsuario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, equipo, tipo, fecha, temporada, logradoPorUsuario);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Campeonato &&
          other.id == this.id &&
          other.equipo == this.equipo &&
          other.tipo == this.tipo &&
          other.fecha == this.fecha &&
          other.temporada == this.temporada &&
          other.logradoPorUsuario == this.logradoPorUsuario);
}

class HistorialCampeonesCompanion extends UpdateCompanion<Campeonato> {
  final Value<int> id;
  final Value<String> equipo;
  final Value<String> tipo;
  final Value<DateTime> fecha;
  final Value<int> temporada;
  final Value<bool> logradoPorUsuario;
  const HistorialCampeonesCompanion({
    this.id = const Value.absent(),
    this.equipo = const Value.absent(),
    this.tipo = const Value.absent(),
    this.fecha = const Value.absent(),
    this.temporada = const Value.absent(),
    this.logradoPorUsuario = const Value.absent(),
  });
  HistorialCampeonesCompanion.insert({
    this.id = const Value.absent(),
    required String equipo,
    required String tipo,
    required DateTime fecha,
    this.temporada = const Value.absent(),
    this.logradoPorUsuario = const Value.absent(),
  }) : equipo = Value(equipo),
       tipo = Value(tipo),
       fecha = Value(fecha);
  static Insertable<Campeonato> custom({
    Expression<int>? id,
    Expression<String>? equipo,
    Expression<String>? tipo,
    Expression<DateTime>? fecha,
    Expression<int>? temporada,
    Expression<bool>? logradoPorUsuario,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (equipo != null) 'equipo': equipo,
      if (tipo != null) 'tipo': tipo,
      if (fecha != null) 'fecha': fecha,
      if (temporada != null) 'temporada': temporada,
      if (logradoPorUsuario != null) 'logrado_por_usuario': logradoPorUsuario,
    });
  }

  HistorialCampeonesCompanion copyWith({
    Value<int>? id,
    Value<String>? equipo,
    Value<String>? tipo,
    Value<DateTime>? fecha,
    Value<int>? temporada,
    Value<bool>? logradoPorUsuario,
  }) {
    return HistorialCampeonesCompanion(
      id: id ?? this.id,
      equipo: equipo ?? this.equipo,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      temporada: temporada ?? this.temporada,
      logradoPorUsuario: logradoPorUsuario ?? this.logradoPorUsuario,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (temporada.present) {
      map['temporada'] = Variable<int>(temporada.value);
    }
    if (logradoPorUsuario.present) {
      map['logrado_por_usuario'] = Variable<bool>(logradoPorUsuario.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistorialCampeonesCompanion(')
          ..write('id: $id, ')
          ..write('equipo: $equipo, ')
          ..write('tipo: $tipo, ')
          ..write('fecha: $fecha, ')
          ..write('temporada: $temporada, ')
          ..write('logradoPorUsuario: $logradoPorUsuario')
          ..write(')'))
        .toString();
  }
}

class $IstTemporadaTable extends IstTemporada
    with TableInfo<$IstTemporadaTable, IstTemporadaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IstTemporadaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _faseGruposActivaMeta = const VerificationMeta(
    'faseGruposActiva',
  );
  @override
  late final GeneratedColumn<bool> faseGruposActiva = GeneratedColumn<bool>(
    'fase_grupos_activa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fase_grupos_activa" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _campeonAnunciadoMeta = const VerificationMeta(
    'campeonAnunciado',
  );
  @override
  late final GeneratedColumn<bool> campeonAnunciado = GeneratedColumn<bool>(
    'campeon_anunciado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("campeon_anunciado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _equipoCampeonMeta = const VerificationMeta(
    'equipoCampeon',
  );
  @override
  late final GeneratedColumn<String> equipoCampeon = GeneratedColumn<String>(
    'equipo_campeon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    faseGruposActiva,
    campeonAnunciado,
    equipoCampeon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ist_temporada';
  @override
  VerificationContext validateIntegrity(
    Insertable<IstTemporadaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fase_grupos_activa')) {
      context.handle(
        _faseGruposActivaMeta,
        faseGruposActiva.isAcceptableOrUnknown(
          data['fase_grupos_activa']!,
          _faseGruposActivaMeta,
        ),
      );
    }
    if (data.containsKey('campeon_anunciado')) {
      context.handle(
        _campeonAnunciadoMeta,
        campeonAnunciado.isAcceptableOrUnknown(
          data['campeon_anunciado']!,
          _campeonAnunciadoMeta,
        ),
      );
    }
    if (data.containsKey('equipo_campeon')) {
      context.handle(
        _equipoCampeonMeta,
        equipoCampeon.isAcceptableOrUnknown(
          data['equipo_campeon']!,
          _equipoCampeonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IstTemporadaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IstTemporadaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      faseGruposActiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fase_grupos_activa'],
      )!,
      campeonAnunciado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}campeon_anunciado'],
      )!,
      equipoCampeon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_campeon'],
      ),
    );
  }

  @override
  $IstTemporadaTable createAlias(String alias) {
    return $IstTemporadaTable(attachedDatabase, alias);
  }
}

class IstTemporadaData extends DataClass
    implements Insertable<IstTemporadaData> {
  final int id;
  final bool faseGruposActiva;
  final bool campeonAnunciado;
  final String? equipoCampeon;
  const IstTemporadaData({
    required this.id,
    required this.faseGruposActiva,
    required this.campeonAnunciado,
    this.equipoCampeon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fase_grupos_activa'] = Variable<bool>(faseGruposActiva);
    map['campeon_anunciado'] = Variable<bool>(campeonAnunciado);
    if (!nullToAbsent || equipoCampeon != null) {
      map['equipo_campeon'] = Variable<String>(equipoCampeon);
    }
    return map;
  }

  IstTemporadaCompanion toCompanion(bool nullToAbsent) {
    return IstTemporadaCompanion(
      id: Value(id),
      faseGruposActiva: Value(faseGruposActiva),
      campeonAnunciado: Value(campeonAnunciado),
      equipoCampeon: equipoCampeon == null && nullToAbsent
          ? const Value.absent()
          : Value(equipoCampeon),
    );
  }

  factory IstTemporadaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IstTemporadaData(
      id: serializer.fromJson<int>(json['id']),
      faseGruposActiva: serializer.fromJson<bool>(json['faseGruposActiva']),
      campeonAnunciado: serializer.fromJson<bool>(json['campeonAnunciado']),
      equipoCampeon: serializer.fromJson<String?>(json['equipoCampeon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'faseGruposActiva': serializer.toJson<bool>(faseGruposActiva),
      'campeonAnunciado': serializer.toJson<bool>(campeonAnunciado),
      'equipoCampeon': serializer.toJson<String?>(equipoCampeon),
    };
  }

  IstTemporadaData copyWith({
    int? id,
    bool? faseGruposActiva,
    bool? campeonAnunciado,
    Value<String?> equipoCampeon = const Value.absent(),
  }) => IstTemporadaData(
    id: id ?? this.id,
    faseGruposActiva: faseGruposActiva ?? this.faseGruposActiva,
    campeonAnunciado: campeonAnunciado ?? this.campeonAnunciado,
    equipoCampeon: equipoCampeon.present
        ? equipoCampeon.value
        : this.equipoCampeon,
  );
  IstTemporadaData copyWithCompanion(IstTemporadaCompanion data) {
    return IstTemporadaData(
      id: data.id.present ? data.id.value : this.id,
      faseGruposActiva: data.faseGruposActiva.present
          ? data.faseGruposActiva.value
          : this.faseGruposActiva,
      campeonAnunciado: data.campeonAnunciado.present
          ? data.campeonAnunciado.value
          : this.campeonAnunciado,
      equipoCampeon: data.equipoCampeon.present
          ? data.equipoCampeon.value
          : this.equipoCampeon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IstTemporadaData(')
          ..write('id: $id, ')
          ..write('faseGruposActiva: $faseGruposActiva, ')
          ..write('campeonAnunciado: $campeonAnunciado, ')
          ..write('equipoCampeon: $equipoCampeon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, faseGruposActiva, campeonAnunciado, equipoCampeon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IstTemporadaData &&
          other.id == this.id &&
          other.faseGruposActiva == this.faseGruposActiva &&
          other.campeonAnunciado == this.campeonAnunciado &&
          other.equipoCampeon == this.equipoCampeon);
}

class IstTemporadaCompanion extends UpdateCompanion<IstTemporadaData> {
  final Value<int> id;
  final Value<bool> faseGruposActiva;
  final Value<bool> campeonAnunciado;
  final Value<String?> equipoCampeon;
  const IstTemporadaCompanion({
    this.id = const Value.absent(),
    this.faseGruposActiva = const Value.absent(),
    this.campeonAnunciado = const Value.absent(),
    this.equipoCampeon = const Value.absent(),
  });
  IstTemporadaCompanion.insert({
    this.id = const Value.absent(),
    this.faseGruposActiva = const Value.absent(),
    this.campeonAnunciado = const Value.absent(),
    this.equipoCampeon = const Value.absent(),
  });
  static Insertable<IstTemporadaData> custom({
    Expression<int>? id,
    Expression<bool>? faseGruposActiva,
    Expression<bool>? campeonAnunciado,
    Expression<String>? equipoCampeon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (faseGruposActiva != null) 'fase_grupos_activa': faseGruposActiva,
      if (campeonAnunciado != null) 'campeon_anunciado': campeonAnunciado,
      if (equipoCampeon != null) 'equipo_campeon': equipoCampeon,
    });
  }

  IstTemporadaCompanion copyWith({
    Value<int>? id,
    Value<bool>? faseGruposActiva,
    Value<bool>? campeonAnunciado,
    Value<String?>? equipoCampeon,
  }) {
    return IstTemporadaCompanion(
      id: id ?? this.id,
      faseGruposActiva: faseGruposActiva ?? this.faseGruposActiva,
      campeonAnunciado: campeonAnunciado ?? this.campeonAnunciado,
      equipoCampeon: equipoCampeon ?? this.equipoCampeon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (faseGruposActiva.present) {
      map['fase_grupos_activa'] = Variable<bool>(faseGruposActiva.value);
    }
    if (campeonAnunciado.present) {
      map['campeon_anunciado'] = Variable<bool>(campeonAnunciado.value);
    }
    if (equipoCampeon.present) {
      map['equipo_campeon'] = Variable<String>(equipoCampeon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IstTemporadaCompanion(')
          ..write('id: $id, ')
          ..write('faseGruposActiva: $faseGruposActiva, ')
          ..write('campeonAnunciado: $campeonAnunciado, ')
          ..write('equipoCampeon: $equipoCampeon')
          ..write(')'))
        .toString();
  }
}

class $SeriesTorneoTable extends SeriesTorneo
    with TableInfo<$SeriesTorneoTable, SerieTorneo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTorneoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _conferenciaMeta = const VerificationMeta(
    'conferencia',
  );
  @override
  late final GeneratedColumn<String> conferencia = GeneratedColumn<String>(
    'conferencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rondaMeta = const VerificationMeta('ronda');
  @override
  late final GeneratedColumn<int> ronda = GeneratedColumn<int>(
    'ronda',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etapaMeta = const VerificationMeta('etapa');
  @override
  late final GeneratedColumn<String> etapa = GeneratedColumn<String>(
    'etapa',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoAMeta = const VerificationMeta(
    'equipoA',
  );
  @override
  late final GeneratedColumn<String> equipoA = GeneratedColumn<String>(
    'equipo_a',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoBMeta = const VerificationMeta(
    'equipoB',
  );
  @override
  late final GeneratedColumn<String> equipoB = GeneratedColumn<String>(
    'equipo_b',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedAMeta = const VerificationMeta('seedA');
  @override
  late final GeneratedColumn<int> seedA = GeneratedColumn<int>(
    'seed_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedBMeta = const VerificationMeta('seedB');
  @override
  late final GeneratedColumn<int> seedB = GeneratedColumn<int>(
    'seed_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ganadorMeta = const VerificationMeta(
    'ganador',
  );
  @override
  late final GeneratedColumn<String> ganador = GeneratedColumn<String>(
    'ganador',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conferencia,
    ronda,
    etapa,
    equipoA,
    equipoB,
    seedA,
    seedB,
    ganador,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_torneo';
  @override
  VerificationContext validateIntegrity(
    Insertable<SerieTorneo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conferencia')) {
      context.handle(
        _conferenciaMeta,
        conferencia.isAcceptableOrUnknown(
          data['conferencia']!,
          _conferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conferenciaMeta);
    }
    if (data.containsKey('ronda')) {
      context.handle(
        _rondaMeta,
        ronda.isAcceptableOrUnknown(data['ronda']!, _rondaMeta),
      );
    } else if (isInserting) {
      context.missing(_rondaMeta);
    }
    if (data.containsKey('etapa')) {
      context.handle(
        _etapaMeta,
        etapa.isAcceptableOrUnknown(data['etapa']!, _etapaMeta),
      );
    } else if (isInserting) {
      context.missing(_etapaMeta);
    }
    if (data.containsKey('equipo_a')) {
      context.handle(
        _equipoAMeta,
        equipoA.isAcceptableOrUnknown(data['equipo_a']!, _equipoAMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoAMeta);
    }
    if (data.containsKey('equipo_b')) {
      context.handle(
        _equipoBMeta,
        equipoB.isAcceptableOrUnknown(data['equipo_b']!, _equipoBMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoBMeta);
    }
    if (data.containsKey('seed_a')) {
      context.handle(
        _seedAMeta,
        seedA.isAcceptableOrUnknown(data['seed_a']!, _seedAMeta),
      );
    } else if (isInserting) {
      context.missing(_seedAMeta);
    }
    if (data.containsKey('seed_b')) {
      context.handle(
        _seedBMeta,
        seedB.isAcceptableOrUnknown(data['seed_b']!, _seedBMeta),
      );
    } else if (isInserting) {
      context.missing(_seedBMeta);
    }
    if (data.containsKey('ganador')) {
      context.handle(
        _ganadorMeta,
        ganador.isAcceptableOrUnknown(data['ganador']!, _ganadorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SerieTorneo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SerieTorneo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conferencia'],
      )!,
      ronda: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ronda'],
      )!,
      etapa: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etapa'],
      )!,
      equipoA: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_a'],
      )!,
      equipoB: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_b'],
      )!,
      seedA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed_a'],
      )!,
      seedB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed_b'],
      )!,
      ganador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ganador'],
      ),
    );
  }

  @override
  $SeriesTorneoTable createAlias(String alias) {
    return $SeriesTorneoTable(attachedDatabase, alias);
  }
}

class SerieTorneo extends DataClass implements Insertable<SerieTorneo> {
  final int id;
  final String conferencia;
  final int ronda;
  final String etapa;
  final String equipoA;
  final String equipoB;
  final int seedA;
  final int seedB;
  final String? ganador;
  const SerieTorneo({
    required this.id,
    required this.conferencia,
    required this.ronda,
    required this.etapa,
    required this.equipoA,
    required this.equipoB,
    required this.seedA,
    required this.seedB,
    this.ganador,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['conferencia'] = Variable<String>(conferencia);
    map['ronda'] = Variable<int>(ronda);
    map['etapa'] = Variable<String>(etapa);
    map['equipo_a'] = Variable<String>(equipoA);
    map['equipo_b'] = Variable<String>(equipoB);
    map['seed_a'] = Variable<int>(seedA);
    map['seed_b'] = Variable<int>(seedB);
    if (!nullToAbsent || ganador != null) {
      map['ganador'] = Variable<String>(ganador);
    }
    return map;
  }

  SeriesTorneoCompanion toCompanion(bool nullToAbsent) {
    return SeriesTorneoCompanion(
      id: Value(id),
      conferencia: Value(conferencia),
      ronda: Value(ronda),
      etapa: Value(etapa),
      equipoA: Value(equipoA),
      equipoB: Value(equipoB),
      seedA: Value(seedA),
      seedB: Value(seedB),
      ganador: ganador == null && nullToAbsent
          ? const Value.absent()
          : Value(ganador),
    );
  }

  factory SerieTorneo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SerieTorneo(
      id: serializer.fromJson<int>(json['id']),
      conferencia: serializer.fromJson<String>(json['conferencia']),
      ronda: serializer.fromJson<int>(json['ronda']),
      etapa: serializer.fromJson<String>(json['etapa']),
      equipoA: serializer.fromJson<String>(json['equipoA']),
      equipoB: serializer.fromJson<String>(json['equipoB']),
      seedA: serializer.fromJson<int>(json['seedA']),
      seedB: serializer.fromJson<int>(json['seedB']),
      ganador: serializer.fromJson<String?>(json['ganador']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conferencia': serializer.toJson<String>(conferencia),
      'ronda': serializer.toJson<int>(ronda),
      'etapa': serializer.toJson<String>(etapa),
      'equipoA': serializer.toJson<String>(equipoA),
      'equipoB': serializer.toJson<String>(equipoB),
      'seedA': serializer.toJson<int>(seedA),
      'seedB': serializer.toJson<int>(seedB),
      'ganador': serializer.toJson<String?>(ganador),
    };
  }

  SerieTorneo copyWith({
    int? id,
    String? conferencia,
    int? ronda,
    String? etapa,
    String? equipoA,
    String? equipoB,
    int? seedA,
    int? seedB,
    Value<String?> ganador = const Value.absent(),
  }) => SerieTorneo(
    id: id ?? this.id,
    conferencia: conferencia ?? this.conferencia,
    ronda: ronda ?? this.ronda,
    etapa: etapa ?? this.etapa,
    equipoA: equipoA ?? this.equipoA,
    equipoB: equipoB ?? this.equipoB,
    seedA: seedA ?? this.seedA,
    seedB: seedB ?? this.seedB,
    ganador: ganador.present ? ganador.value : this.ganador,
  );
  SerieTorneo copyWithCompanion(SeriesTorneoCompanion data) {
    return SerieTorneo(
      id: data.id.present ? data.id.value : this.id,
      conferencia: data.conferencia.present
          ? data.conferencia.value
          : this.conferencia,
      ronda: data.ronda.present ? data.ronda.value : this.ronda,
      etapa: data.etapa.present ? data.etapa.value : this.etapa,
      equipoA: data.equipoA.present ? data.equipoA.value : this.equipoA,
      equipoB: data.equipoB.present ? data.equipoB.value : this.equipoB,
      seedA: data.seedA.present ? data.seedA.value : this.seedA,
      seedB: data.seedB.present ? data.seedB.value : this.seedB,
      ganador: data.ganador.present ? data.ganador.value : this.ganador,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SerieTorneo(')
          ..write('id: $id, ')
          ..write('conferencia: $conferencia, ')
          ..write('ronda: $ronda, ')
          ..write('etapa: $etapa, ')
          ..write('equipoA: $equipoA, ')
          ..write('equipoB: $equipoB, ')
          ..write('seedA: $seedA, ')
          ..write('seedB: $seedB, ')
          ..write('ganador: $ganador')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conferencia,
    ronda,
    etapa,
    equipoA,
    equipoB,
    seedA,
    seedB,
    ganador,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SerieTorneo &&
          other.id == this.id &&
          other.conferencia == this.conferencia &&
          other.ronda == this.ronda &&
          other.etapa == this.etapa &&
          other.equipoA == this.equipoA &&
          other.equipoB == this.equipoB &&
          other.seedA == this.seedA &&
          other.seedB == this.seedB &&
          other.ganador == this.ganador);
}

class SeriesTorneoCompanion extends UpdateCompanion<SerieTorneo> {
  final Value<int> id;
  final Value<String> conferencia;
  final Value<int> ronda;
  final Value<String> etapa;
  final Value<String> equipoA;
  final Value<String> equipoB;
  final Value<int> seedA;
  final Value<int> seedB;
  final Value<String?> ganador;
  const SeriesTorneoCompanion({
    this.id = const Value.absent(),
    this.conferencia = const Value.absent(),
    this.ronda = const Value.absent(),
    this.etapa = const Value.absent(),
    this.equipoA = const Value.absent(),
    this.equipoB = const Value.absent(),
    this.seedA = const Value.absent(),
    this.seedB = const Value.absent(),
    this.ganador = const Value.absent(),
  });
  SeriesTorneoCompanion.insert({
    this.id = const Value.absent(),
    required String conferencia,
    required int ronda,
    required String etapa,
    required String equipoA,
    required String equipoB,
    required int seedA,
    required int seedB,
    this.ganador = const Value.absent(),
  }) : conferencia = Value(conferencia),
       ronda = Value(ronda),
       etapa = Value(etapa),
       equipoA = Value(equipoA),
       equipoB = Value(equipoB),
       seedA = Value(seedA),
       seedB = Value(seedB);
  static Insertable<SerieTorneo> custom({
    Expression<int>? id,
    Expression<String>? conferencia,
    Expression<int>? ronda,
    Expression<String>? etapa,
    Expression<String>? equipoA,
    Expression<String>? equipoB,
    Expression<int>? seedA,
    Expression<int>? seedB,
    Expression<String>? ganador,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conferencia != null) 'conferencia': conferencia,
      if (ronda != null) 'ronda': ronda,
      if (etapa != null) 'etapa': etapa,
      if (equipoA != null) 'equipo_a': equipoA,
      if (equipoB != null) 'equipo_b': equipoB,
      if (seedA != null) 'seed_a': seedA,
      if (seedB != null) 'seed_b': seedB,
      if (ganador != null) 'ganador': ganador,
    });
  }

  SeriesTorneoCompanion copyWith({
    Value<int>? id,
    Value<String>? conferencia,
    Value<int>? ronda,
    Value<String>? etapa,
    Value<String>? equipoA,
    Value<String>? equipoB,
    Value<int>? seedA,
    Value<int>? seedB,
    Value<String?>? ganador,
  }) {
    return SeriesTorneoCompanion(
      id: id ?? this.id,
      conferencia: conferencia ?? this.conferencia,
      ronda: ronda ?? this.ronda,
      etapa: etapa ?? this.etapa,
      equipoA: equipoA ?? this.equipoA,
      equipoB: equipoB ?? this.equipoB,
      seedA: seedA ?? this.seedA,
      seedB: seedB ?? this.seedB,
      ganador: ganador ?? this.ganador,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conferencia.present) {
      map['conferencia'] = Variable<String>(conferencia.value);
    }
    if (ronda.present) {
      map['ronda'] = Variable<int>(ronda.value);
    }
    if (etapa.present) {
      map['etapa'] = Variable<String>(etapa.value);
    }
    if (equipoA.present) {
      map['equipo_a'] = Variable<String>(equipoA.value);
    }
    if (equipoB.present) {
      map['equipo_b'] = Variable<String>(equipoB.value);
    }
    if (seedA.present) {
      map['seed_a'] = Variable<int>(seedA.value);
    }
    if (seedB.present) {
      map['seed_b'] = Variable<int>(seedB.value);
    }
    if (ganador.present) {
      map['ganador'] = Variable<String>(ganador.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesTorneoCompanion(')
          ..write('id: $id, ')
          ..write('conferencia: $conferencia, ')
          ..write('ronda: $ronda, ')
          ..write('etapa: $etapa, ')
          ..write('equipoA: $equipoA, ')
          ..write('equipoB: $equipoB, ')
          ..write('seedA: $seedA, ')
          ..write('seedB: $seedB, ')
          ..write('ganador: $ganador')
          ..write(')'))
        .toString();
  }
}

class $BoxscoresSerieTable extends BoxscoresSerie
    with TableInfo<$BoxscoresSerieTable, BoxscoresSerieData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoxscoresSerieTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _origenMeta = const VerificationMeta('origen');
  @override
  late final GeneratedColumn<String> origen = GeneratedColumn<String>(
    'origen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serieIdMeta = const VerificationMeta(
    'serieId',
  );
  @override
  late final GeneratedColumn<int> serieId = GeneratedColumn<int>(
    'serie_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _boxscoreJsonMeta = const VerificationMeta(
    'boxscoreJson',
  );
  @override
  late final GeneratedColumn<String> boxscoreJson = GeneratedColumn<String>(
    'boxscore_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    origen,
    serieId,
    fecha,
    boxscoreJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boxscores_serie';
  @override
  VerificationContext validateIntegrity(
    Insertable<BoxscoresSerieData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('origen')) {
      context.handle(
        _origenMeta,
        origen.isAcceptableOrUnknown(data['origen']!, _origenMeta),
      );
    } else if (isInserting) {
      context.missing(_origenMeta);
    }
    if (data.containsKey('serie_id')) {
      context.handle(
        _serieIdMeta,
        serieId.isAcceptableOrUnknown(data['serie_id']!, _serieIdMeta),
      );
    } else if (isInserting) {
      context.missing(_serieIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('boxscore_json')) {
      context.handle(
        _boxscoreJsonMeta,
        boxscoreJson.isAcceptableOrUnknown(
          data['boxscore_json']!,
          _boxscoreJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_boxscoreJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BoxscoresSerieData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BoxscoresSerieData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      origen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origen'],
      )!,
      serieId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serie_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      boxscoreJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}boxscore_json'],
      )!,
    );
  }

  @override
  $BoxscoresSerieTable createAlias(String alias) {
    return $BoxscoresSerieTable(attachedDatabase, alias);
  }
}

class BoxscoresSerieData extends DataClass
    implements Insertable<BoxscoresSerieData> {
  final int id;
  final String origen;
  final int serieId;
  final DateTime fecha;
  final String boxscoreJson;
  const BoxscoresSerieData({
    required this.id,
    required this.origen,
    required this.serieId,
    required this.fecha,
    required this.boxscoreJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['origen'] = Variable<String>(origen);
    map['serie_id'] = Variable<int>(serieId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['boxscore_json'] = Variable<String>(boxscoreJson);
    return map;
  }

  BoxscoresSerieCompanion toCompanion(bool nullToAbsent) {
    return BoxscoresSerieCompanion(
      id: Value(id),
      origen: Value(origen),
      serieId: Value(serieId),
      fecha: Value(fecha),
      boxscoreJson: Value(boxscoreJson),
    );
  }

  factory BoxscoresSerieData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BoxscoresSerieData(
      id: serializer.fromJson<int>(json['id']),
      origen: serializer.fromJson<String>(json['origen']),
      serieId: serializer.fromJson<int>(json['serieId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      boxscoreJson: serializer.fromJson<String>(json['boxscoreJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'origen': serializer.toJson<String>(origen),
      'serieId': serializer.toJson<int>(serieId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'boxscoreJson': serializer.toJson<String>(boxscoreJson),
    };
  }

  BoxscoresSerieData copyWith({
    int? id,
    String? origen,
    int? serieId,
    DateTime? fecha,
    String? boxscoreJson,
  }) => BoxscoresSerieData(
    id: id ?? this.id,
    origen: origen ?? this.origen,
    serieId: serieId ?? this.serieId,
    fecha: fecha ?? this.fecha,
    boxscoreJson: boxscoreJson ?? this.boxscoreJson,
  );
  BoxscoresSerieData copyWithCompanion(BoxscoresSerieCompanion data) {
    return BoxscoresSerieData(
      id: data.id.present ? data.id.value : this.id,
      origen: data.origen.present ? data.origen.value : this.origen,
      serieId: data.serieId.present ? data.serieId.value : this.serieId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      boxscoreJson: data.boxscoreJson.present
          ? data.boxscoreJson.value
          : this.boxscoreJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BoxscoresSerieData(')
          ..write('id: $id, ')
          ..write('origen: $origen, ')
          ..write('serieId: $serieId, ')
          ..write('fecha: $fecha, ')
          ..write('boxscoreJson: $boxscoreJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, origen, serieId, fecha, boxscoreJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BoxscoresSerieData &&
          other.id == this.id &&
          other.origen == this.origen &&
          other.serieId == this.serieId &&
          other.fecha == this.fecha &&
          other.boxscoreJson == this.boxscoreJson);
}

class BoxscoresSerieCompanion extends UpdateCompanion<BoxscoresSerieData> {
  final Value<int> id;
  final Value<String> origen;
  final Value<int> serieId;
  final Value<DateTime> fecha;
  final Value<String> boxscoreJson;
  const BoxscoresSerieCompanion({
    this.id = const Value.absent(),
    this.origen = const Value.absent(),
    this.serieId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.boxscoreJson = const Value.absent(),
  });
  BoxscoresSerieCompanion.insert({
    this.id = const Value.absent(),
    required String origen,
    required int serieId,
    required DateTime fecha,
    required String boxscoreJson,
  }) : origen = Value(origen),
       serieId = Value(serieId),
       fecha = Value(fecha),
       boxscoreJson = Value(boxscoreJson);
  static Insertable<BoxscoresSerieData> custom({
    Expression<int>? id,
    Expression<String>? origen,
    Expression<int>? serieId,
    Expression<DateTime>? fecha,
    Expression<String>? boxscoreJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (origen != null) 'origen': origen,
      if (serieId != null) 'serie_id': serieId,
      if (fecha != null) 'fecha': fecha,
      if (boxscoreJson != null) 'boxscore_json': boxscoreJson,
    });
  }

  BoxscoresSerieCompanion copyWith({
    Value<int>? id,
    Value<String>? origen,
    Value<int>? serieId,
    Value<DateTime>? fecha,
    Value<String>? boxscoreJson,
  }) {
    return BoxscoresSerieCompanion(
      id: id ?? this.id,
      origen: origen ?? this.origen,
      serieId: serieId ?? this.serieId,
      fecha: fecha ?? this.fecha,
      boxscoreJson: boxscoreJson ?? this.boxscoreJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (origen.present) {
      map['origen'] = Variable<String>(origen.value);
    }
    if (serieId.present) {
      map['serie_id'] = Variable<int>(serieId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (boxscoreJson.present) {
      map['boxscore_json'] = Variable<String>(boxscoreJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoxscoresSerieCompanion(')
          ..write('id: $id, ')
          ..write('origen: $origen, ')
          ..write('serieId: $serieId, ')
          ..write('fecha: $fecha, ')
          ..write('boxscoreJson: $boxscoreJson')
          ..write(')'))
        .toString();
  }
}

class $FormaTemporadaJugadorTable extends FormaTemporadaJugador
    with TableInfo<$FormaTemporadaJugadorTable, FormaJugador> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormaTemporadaJugadorTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _factorMeta = const VerificationMeta('factor');
  @override
  late final GeneratedColumn<double> factor = GeneratedColumn<double>(
    'factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [jugadorId, factor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'forma_temporada_jugador';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormaJugador> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    }
    if (data.containsKey('factor')) {
      context.handle(
        _factorMeta,
        factor.isAcceptableOrUnknown(data['factor']!, _factorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {jugadorId};
  @override
  FormaJugador map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormaJugador(
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
      factor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}factor'],
      )!,
    );
  }

  @override
  $FormaTemporadaJugadorTable createAlias(String alias) {
    return $FormaTemporadaJugadorTable(attachedDatabase, alias);
  }
}

class FormaJugador extends DataClass implements Insertable<FormaJugador> {
  final int jugadorId;
  final double factor;
  const FormaJugador({required this.jugadorId, required this.factor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['jugador_id'] = Variable<int>(jugadorId);
    map['factor'] = Variable<double>(factor);
    return map;
  }

  FormaTemporadaJugadorCompanion toCompanion(bool nullToAbsent) {
    return FormaTemporadaJugadorCompanion(
      jugadorId: Value(jugadorId),
      factor: Value(factor),
    );
  }

  factory FormaJugador.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormaJugador(
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
      factor: serializer.fromJson<double>(json['factor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'jugadorId': serializer.toJson<int>(jugadorId),
      'factor': serializer.toJson<double>(factor),
    };
  }

  FormaJugador copyWith({int? jugadorId, double? factor}) => FormaJugador(
    jugadorId: jugadorId ?? this.jugadorId,
    factor: factor ?? this.factor,
  );
  FormaJugador copyWithCompanion(FormaTemporadaJugadorCompanion data) {
    return FormaJugador(
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
      factor: data.factor.present ? data.factor.value : this.factor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormaJugador(')
          ..write('jugadorId: $jugadorId, ')
          ..write('factor: $factor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(jugadorId, factor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormaJugador &&
          other.jugadorId == this.jugadorId &&
          other.factor == this.factor);
}

class FormaTemporadaJugadorCompanion extends UpdateCompanion<FormaJugador> {
  final Value<int> jugadorId;
  final Value<double> factor;
  const FormaTemporadaJugadorCompanion({
    this.jugadorId = const Value.absent(),
    this.factor = const Value.absent(),
  });
  FormaTemporadaJugadorCompanion.insert({
    this.jugadorId = const Value.absent(),
    this.factor = const Value.absent(),
  });
  static Insertable<FormaJugador> custom({
    Expression<int>? jugadorId,
    Expression<double>? factor,
  }) {
    return RawValuesInsertable({
      if (jugadorId != null) 'jugador_id': jugadorId,
      if (factor != null) 'factor': factor,
    });
  }

  FormaTemporadaJugadorCompanion copyWith({
    Value<int>? jugadorId,
    Value<double>? factor,
  }) {
    return FormaTemporadaJugadorCompanion(
      jugadorId: jugadorId ?? this.jugadorId,
      factor: factor ?? this.factor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    if (factor.present) {
      map['factor'] = Variable<double>(factor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormaTemporadaJugadorCompanion(')
          ..write('jugadorId: $jugadorId, ')
          ..write('factor: $factor')
          ..write(')'))
        .toString();
  }
}

class $TemporadaTable extends Temporada
    with TableInfo<$TemporadaTable, TemporadaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemporadaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _anioInicioMeta = const VerificationMeta(
    'anioInicio',
  );
  @override
  late final GeneratedColumn<int> anioInicio = GeneratedColumn<int>(
    'anio_inicio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ofertasGeneradasEstaTemporadaMeta =
      const VerificationMeta('ofertasGeneradasEstaTemporada');
  @override
  late final GeneratedColumn<int> ofertasGeneradasEstaTemporada =
      GeneratedColumn<int>(
        'ofertas_generadas_esta_temporada',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _eventosVistosMeta = const VerificationMeta(
    'eventosVistos',
  );
  @override
  late final GeneratedColumn<String> eventosVistos = GeneratedColumn<String>(
    'eventos_vistos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bonusSalarialMeta = const VerificationMeta(
    'bonusSalarial',
  );
  @override
  late final GeneratedColumn<int> bonusSalarial = GeneratedColumn<int>(
    'bonus_salarial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    numero,
    anioInicio,
    ofertasGeneradasEstaTemporada,
    eventosVistos,
    bonusSalarial,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'temporada';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemporadaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    }
    if (data.containsKey('anio_inicio')) {
      context.handle(
        _anioInicioMeta,
        anioInicio.isAcceptableOrUnknown(data['anio_inicio']!, _anioInicioMeta),
      );
    } else if (isInserting) {
      context.missing(_anioInicioMeta);
    }
    if (data.containsKey('ofertas_generadas_esta_temporada')) {
      context.handle(
        _ofertasGeneradasEstaTemporadaMeta,
        ofertasGeneradasEstaTemporada.isAcceptableOrUnknown(
          data['ofertas_generadas_esta_temporada']!,
          _ofertasGeneradasEstaTemporadaMeta,
        ),
      );
    }
    if (data.containsKey('eventos_vistos')) {
      context.handle(
        _eventosVistosMeta,
        eventosVistos.isAcceptableOrUnknown(
          data['eventos_vistos']!,
          _eventosVistosMeta,
        ),
      );
    }
    if (data.containsKey('bonus_salarial')) {
      context.handle(
        _bonusSalarialMeta,
        bonusSalarial.isAcceptableOrUnknown(
          data['bonus_salarial']!,
          _bonusSalarialMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemporadaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemporadaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      )!,
      anioInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anio_inicio'],
      )!,
      ofertasGeneradasEstaTemporada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ofertas_generadas_esta_temporada'],
      )!,
      eventosVistos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eventos_vistos'],
      )!,
      bonusSalarial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_salarial'],
      )!,
    );
  }

  @override
  $TemporadaTable createAlias(String alias) {
    return $TemporadaTable(attachedDatabase, alias);
  }
}

class TemporadaData extends DataClass implements Insertable<TemporadaData> {
  final int id;
  final int numero;
  final int anioInicio;

  /// Cuántas ofertas de traspaso entrantes se han generado ya esta
  /// temporada (ver ofertas_repository.dart). A diferencia de la fila de
  /// `OfertasTraspaso`, que se borra al aceptar o rechazar, este contador
  /// no baja nunca dentro de una misma temporada — es lo que permite un
  /// tope real de verdad de como mucho unas pocas por temporada, no solo
  /// "como mucho 3 a la vez sin resolver". Se pone a 0 en cada cambio de
  /// año.
  final int ofertasGeneradasEstaTemporada;

  /// Las claves de los eventos narrativos que ya han salido esta temporada,
  /// separadas por comas. Es lo que evita que te salga la misma cena de
  /// equipo tres veces el mismo ano.
  ///
  /// Va como texto y no como tabla aparte a proposito: son un punado de
  /// cadenas cortas que solo se leen enteras y se resetean cada verano. Una
  /// tabla para esto seria mas ceremonia que dato (mismo criterio que las
  /// listas de ids de `OfertasTraspaso`).
  final String eventosVistos;

  /// Margen de tope salarial extra que han dejado los eventos narrativos
  /// esta temporada (patrocinios, actos publicitarios...). Se suma al tope
  /// SOLO para el equipo del usuario: los otros 29 no toman estas
  /// decisiones, así que no les puede tocar.
  ///
  /// Va en la fila de temporada y no en una tabla aparte porque es un
  /// número suelto que se resetea cada verano, igual que
  /// [eventosVistos]. Puede ser negativo (una multa) sin que nada se
  /// rompa: el espacio salarial ya sabía ser negativo de antes, es lo que
  /// significa estar por encima del tope.
  final int bonusSalarial;
  const TemporadaData({
    required this.id,
    required this.numero,
    required this.anioInicio,
    required this.ofertasGeneradasEstaTemporada,
    required this.eventosVistos,
    required this.bonusSalarial,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['numero'] = Variable<int>(numero);
    map['anio_inicio'] = Variable<int>(anioInicio);
    map['ofertas_generadas_esta_temporada'] = Variable<int>(
      ofertasGeneradasEstaTemporada,
    );
    map['eventos_vistos'] = Variable<String>(eventosVistos);
    map['bonus_salarial'] = Variable<int>(bonusSalarial);
    return map;
  }

  TemporadaCompanion toCompanion(bool nullToAbsent) {
    return TemporadaCompanion(
      id: Value(id),
      numero: Value(numero),
      anioInicio: Value(anioInicio),
      ofertasGeneradasEstaTemporada: Value(ofertasGeneradasEstaTemporada),
      eventosVistos: Value(eventosVistos),
      bonusSalarial: Value(bonusSalarial),
    );
  }

  factory TemporadaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemporadaData(
      id: serializer.fromJson<int>(json['id']),
      numero: serializer.fromJson<int>(json['numero']),
      anioInicio: serializer.fromJson<int>(json['anioInicio']),
      ofertasGeneradasEstaTemporada: serializer.fromJson<int>(
        json['ofertasGeneradasEstaTemporada'],
      ),
      eventosVistos: serializer.fromJson<String>(json['eventosVistos']),
      bonusSalarial: serializer.fromJson<int>(json['bonusSalarial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'numero': serializer.toJson<int>(numero),
      'anioInicio': serializer.toJson<int>(anioInicio),
      'ofertasGeneradasEstaTemporada': serializer.toJson<int>(
        ofertasGeneradasEstaTemporada,
      ),
      'eventosVistos': serializer.toJson<String>(eventosVistos),
      'bonusSalarial': serializer.toJson<int>(bonusSalarial),
    };
  }

  TemporadaData copyWith({
    int? id,
    int? numero,
    int? anioInicio,
    int? ofertasGeneradasEstaTemporada,
    String? eventosVistos,
    int? bonusSalarial,
  }) => TemporadaData(
    id: id ?? this.id,
    numero: numero ?? this.numero,
    anioInicio: anioInicio ?? this.anioInicio,
    ofertasGeneradasEstaTemporada:
        ofertasGeneradasEstaTemporada ?? this.ofertasGeneradasEstaTemporada,
    eventosVistos: eventosVistos ?? this.eventosVistos,
    bonusSalarial: bonusSalarial ?? this.bonusSalarial,
  );
  TemporadaData copyWithCompanion(TemporadaCompanion data) {
    return TemporadaData(
      id: data.id.present ? data.id.value : this.id,
      numero: data.numero.present ? data.numero.value : this.numero,
      anioInicio: data.anioInicio.present
          ? data.anioInicio.value
          : this.anioInicio,
      ofertasGeneradasEstaTemporada: data.ofertasGeneradasEstaTemporada.present
          ? data.ofertasGeneradasEstaTemporada.value
          : this.ofertasGeneradasEstaTemporada,
      eventosVistos: data.eventosVistos.present
          ? data.eventosVistos.value
          : this.eventosVistos,
      bonusSalarial: data.bonusSalarial.present
          ? data.bonusSalarial.value
          : this.bonusSalarial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemporadaData(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('anioInicio: $anioInicio, ')
          ..write(
            'ofertasGeneradasEstaTemporada: $ofertasGeneradasEstaTemporada, ',
          )
          ..write('eventosVistos: $eventosVistos, ')
          ..write('bonusSalarial: $bonusSalarial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    numero,
    anioInicio,
    ofertasGeneradasEstaTemporada,
    eventosVistos,
    bonusSalarial,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemporadaData &&
          other.id == this.id &&
          other.numero == this.numero &&
          other.anioInicio == this.anioInicio &&
          other.ofertasGeneradasEstaTemporada ==
              this.ofertasGeneradasEstaTemporada &&
          other.eventosVistos == this.eventosVistos &&
          other.bonusSalarial == this.bonusSalarial);
}

class TemporadaCompanion extends UpdateCompanion<TemporadaData> {
  final Value<int> id;
  final Value<int> numero;
  final Value<int> anioInicio;
  final Value<int> ofertasGeneradasEstaTemporada;
  final Value<String> eventosVistos;
  final Value<int> bonusSalarial;
  const TemporadaCompanion({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    this.anioInicio = const Value.absent(),
    this.ofertasGeneradasEstaTemporada = const Value.absent(),
    this.eventosVistos = const Value.absent(),
    this.bonusSalarial = const Value.absent(),
  });
  TemporadaCompanion.insert({
    this.id = const Value.absent(),
    this.numero = const Value.absent(),
    required int anioInicio,
    this.ofertasGeneradasEstaTemporada = const Value.absent(),
    this.eventosVistos = const Value.absent(),
    this.bonusSalarial = const Value.absent(),
  }) : anioInicio = Value(anioInicio);
  static Insertable<TemporadaData> custom({
    Expression<int>? id,
    Expression<int>? numero,
    Expression<int>? anioInicio,
    Expression<int>? ofertasGeneradasEstaTemporada,
    Expression<String>? eventosVistos,
    Expression<int>? bonusSalarial,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (numero != null) 'numero': numero,
      if (anioInicio != null) 'anio_inicio': anioInicio,
      if (ofertasGeneradasEstaTemporada != null)
        'ofertas_generadas_esta_temporada': ofertasGeneradasEstaTemporada,
      if (eventosVistos != null) 'eventos_vistos': eventosVistos,
      if (bonusSalarial != null) 'bonus_salarial': bonusSalarial,
    });
  }

  TemporadaCompanion copyWith({
    Value<int>? id,
    Value<int>? numero,
    Value<int>? anioInicio,
    Value<int>? ofertasGeneradasEstaTemporada,
    Value<String>? eventosVistos,
    Value<int>? bonusSalarial,
  }) {
    return TemporadaCompanion(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      anioInicio: anioInicio ?? this.anioInicio,
      ofertasGeneradasEstaTemporada:
          ofertasGeneradasEstaTemporada ?? this.ofertasGeneradasEstaTemporada,
      eventosVistos: eventosVistos ?? this.eventosVistos,
      bonusSalarial: bonusSalarial ?? this.bonusSalarial,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (anioInicio.present) {
      map['anio_inicio'] = Variable<int>(anioInicio.value);
    }
    if (ofertasGeneradasEstaTemporada.present) {
      map['ofertas_generadas_esta_temporada'] = Variable<int>(
        ofertasGeneradasEstaTemporada.value,
      );
    }
    if (eventosVistos.present) {
      map['eventos_vistos'] = Variable<String>(eventosVistos.value);
    }
    if (bonusSalarial.present) {
      map['bonus_salarial'] = Variable<int>(bonusSalarial.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemporadaCompanion(')
          ..write('id: $id, ')
          ..write('numero: $numero, ')
          ..write('anioInicio: $anioInicio, ')
          ..write(
            'ofertasGeneradasEstaTemporada: $ofertasGeneradasEstaTemporada, ',
          )
          ..write('eventosVistos: $eventosVistos, ')
          ..write('bonusSalarial: $bonusSalarial')
          ..write(')'))
        .toString();
  }
}

class $HistorialTemporadaEquipoTable extends HistorialTemporadaEquipo
    with TableInfo<$HistorialTemporadaEquipoTable, RecordHistorico> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistorialTemporadaEquipoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _temporadaMeta = const VerificationMeta(
    'temporada',
  );
  @override
  late final GeneratedColumn<int> temporada = GeneratedColumn<int>(
    'temporada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _victoriasMeta = const VerificationMeta(
    'victorias',
  );
  @override
  late final GeneratedColumn<int> victorias = GeneratedColumn<int>(
    'victorias',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _derrotasMeta = const VerificationMeta(
    'derrotas',
  );
  @override
  late final GeneratedColumn<int> derrotas = GeneratedColumn<int>(
    'derrotas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    temporada,
    equipo,
    victorias,
    derrotas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historial_temporada_equipo';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecordHistorico> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('temporada')) {
      context.handle(
        _temporadaMeta,
        temporada.isAcceptableOrUnknown(data['temporada']!, _temporadaMeta),
      );
    } else if (isInserting) {
      context.missing(_temporadaMeta);
    }
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    if (data.containsKey('victorias')) {
      context.handle(
        _victoriasMeta,
        victorias.isAcceptableOrUnknown(data['victorias']!, _victoriasMeta),
      );
    } else if (isInserting) {
      context.missing(_victoriasMeta);
    }
    if (data.containsKey('derrotas')) {
      context.handle(
        _derrotasMeta,
        derrotas.isAcceptableOrUnknown(data['derrotas']!, _derrotasMeta),
      );
    } else if (isInserting) {
      context.missing(_derrotasMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecordHistorico map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecordHistorico(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      temporada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporada'],
      )!,
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
      victorias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}victorias'],
      )!,
      derrotas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}derrotas'],
      )!,
    );
  }

  @override
  $HistorialTemporadaEquipoTable createAlias(String alias) {
    return $HistorialTemporadaEquipoTable(attachedDatabase, alias);
  }
}

class RecordHistorico extends DataClass implements Insertable<RecordHistorico> {
  final int id;
  final int temporada;
  final String equipo;
  final int victorias;
  final int derrotas;
  const RecordHistorico({
    required this.id,
    required this.temporada,
    required this.equipo,
    required this.victorias,
    required this.derrotas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['temporada'] = Variable<int>(temporada);
    map['equipo'] = Variable<String>(equipo);
    map['victorias'] = Variable<int>(victorias);
    map['derrotas'] = Variable<int>(derrotas);
    return map;
  }

  HistorialTemporadaEquipoCompanion toCompanion(bool nullToAbsent) {
    return HistorialTemporadaEquipoCompanion(
      id: Value(id),
      temporada: Value(temporada),
      equipo: Value(equipo),
      victorias: Value(victorias),
      derrotas: Value(derrotas),
    );
  }

  factory RecordHistorico.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecordHistorico(
      id: serializer.fromJson<int>(json['id']),
      temporada: serializer.fromJson<int>(json['temporada']),
      equipo: serializer.fromJson<String>(json['equipo']),
      victorias: serializer.fromJson<int>(json['victorias']),
      derrotas: serializer.fromJson<int>(json['derrotas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'temporada': serializer.toJson<int>(temporada),
      'equipo': serializer.toJson<String>(equipo),
      'victorias': serializer.toJson<int>(victorias),
      'derrotas': serializer.toJson<int>(derrotas),
    };
  }

  RecordHistorico copyWith({
    int? id,
    int? temporada,
    String? equipo,
    int? victorias,
    int? derrotas,
  }) => RecordHistorico(
    id: id ?? this.id,
    temporada: temporada ?? this.temporada,
    equipo: equipo ?? this.equipo,
    victorias: victorias ?? this.victorias,
    derrotas: derrotas ?? this.derrotas,
  );
  RecordHistorico copyWithCompanion(HistorialTemporadaEquipoCompanion data) {
    return RecordHistorico(
      id: data.id.present ? data.id.value : this.id,
      temporada: data.temporada.present ? data.temporada.value : this.temporada,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
      victorias: data.victorias.present ? data.victorias.value : this.victorias,
      derrotas: data.derrotas.present ? data.derrotas.value : this.derrotas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecordHistorico(')
          ..write('id: $id, ')
          ..write('temporada: $temporada, ')
          ..write('equipo: $equipo, ')
          ..write('victorias: $victorias, ')
          ..write('derrotas: $derrotas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, temporada, equipo, victorias, derrotas);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecordHistorico &&
          other.id == this.id &&
          other.temporada == this.temporada &&
          other.equipo == this.equipo &&
          other.victorias == this.victorias &&
          other.derrotas == this.derrotas);
}

class HistorialTemporadaEquipoCompanion
    extends UpdateCompanion<RecordHistorico> {
  final Value<int> id;
  final Value<int> temporada;
  final Value<String> equipo;
  final Value<int> victorias;
  final Value<int> derrotas;
  const HistorialTemporadaEquipoCompanion({
    this.id = const Value.absent(),
    this.temporada = const Value.absent(),
    this.equipo = const Value.absent(),
    this.victorias = const Value.absent(),
    this.derrotas = const Value.absent(),
  });
  HistorialTemporadaEquipoCompanion.insert({
    this.id = const Value.absent(),
    required int temporada,
    required String equipo,
    required int victorias,
    required int derrotas,
  }) : temporada = Value(temporada),
       equipo = Value(equipo),
       victorias = Value(victorias),
       derrotas = Value(derrotas);
  static Insertable<RecordHistorico> custom({
    Expression<int>? id,
    Expression<int>? temporada,
    Expression<String>? equipo,
    Expression<int>? victorias,
    Expression<int>? derrotas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (temporada != null) 'temporada': temporada,
      if (equipo != null) 'equipo': equipo,
      if (victorias != null) 'victorias': victorias,
      if (derrotas != null) 'derrotas': derrotas,
    });
  }

  HistorialTemporadaEquipoCompanion copyWith({
    Value<int>? id,
    Value<int>? temporada,
    Value<String>? equipo,
    Value<int>? victorias,
    Value<int>? derrotas,
  }) {
    return HistorialTemporadaEquipoCompanion(
      id: id ?? this.id,
      temporada: temporada ?? this.temporada,
      equipo: equipo ?? this.equipo,
      victorias: victorias ?? this.victorias,
      derrotas: derrotas ?? this.derrotas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (temporada.present) {
      map['temporada'] = Variable<int>(temporada.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    if (victorias.present) {
      map['victorias'] = Variable<int>(victorias.value);
    }
    if (derrotas.present) {
      map['derrotas'] = Variable<int>(derrotas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistorialTemporadaEquipoCompanion(')
          ..write('id: $id, ')
          ..write('temporada: $temporada, ')
          ..write('equipo: $equipo, ')
          ..write('victorias: $victorias, ')
          ..write('derrotas: $derrotas')
          ..write(')'))
        .toString();
  }
}

class $HistorialPremiosTable extends HistorialPremios
    with TableInfo<$HistorialPremiosTable, PremioHistorico> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistorialPremiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _temporadaMeta = const VerificationMeta(
    'temporada',
  );
  @override
  late final GeneratedColumn<int> temporada = GeneratedColumn<int>(
    'temporada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreJugadorMeta = const VerificationMeta(
    'nombreJugador',
  );
  @override
  late final GeneratedColumn<String> nombreJugador = GeneratedColumn<String>(
    'nombre_jugador',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    temporada,
    tipo,
    jugadorId,
    nombreJugador,
    equipo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historial_premios';
  @override
  VerificationContext validateIntegrity(
    Insertable<PremioHistorico> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('temporada')) {
      context.handle(
        _temporadaMeta,
        temporada.isAcceptableOrUnknown(data['temporada']!, _temporadaMeta),
      );
    } else if (isInserting) {
      context.missing(_temporadaMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jugadorIdMeta);
    }
    if (data.containsKey('nombre_jugador')) {
      context.handle(
        _nombreJugadorMeta,
        nombreJugador.isAcceptableOrUnknown(
          data['nombre_jugador']!,
          _nombreJugadorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreJugadorMeta);
    }
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PremioHistorico map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PremioHistorico(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      temporada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporada'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
      nombreJugador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_jugador'],
      )!,
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
    );
  }

  @override
  $HistorialPremiosTable createAlias(String alias) {
    return $HistorialPremiosTable(attachedDatabase, alias);
  }
}

class PremioHistorico extends DataClass implements Insertable<PremioHistorico> {
  final int id;
  final int temporada;
  final String tipo;
  final int jugadorId;
  final String nombreJugador;
  final String equipo;
  const PremioHistorico({
    required this.id,
    required this.temporada,
    required this.tipo,
    required this.jugadorId,
    required this.nombreJugador,
    required this.equipo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['temporada'] = Variable<int>(temporada);
    map['tipo'] = Variable<String>(tipo);
    map['jugador_id'] = Variable<int>(jugadorId);
    map['nombre_jugador'] = Variable<String>(nombreJugador);
    map['equipo'] = Variable<String>(equipo);
    return map;
  }

  HistorialPremiosCompanion toCompanion(bool nullToAbsent) {
    return HistorialPremiosCompanion(
      id: Value(id),
      temporada: Value(temporada),
      tipo: Value(tipo),
      jugadorId: Value(jugadorId),
      nombreJugador: Value(nombreJugador),
      equipo: Value(equipo),
    );
  }

  factory PremioHistorico.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PremioHistorico(
      id: serializer.fromJson<int>(json['id']),
      temporada: serializer.fromJson<int>(json['temporada']),
      tipo: serializer.fromJson<String>(json['tipo']),
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
      nombreJugador: serializer.fromJson<String>(json['nombreJugador']),
      equipo: serializer.fromJson<String>(json['equipo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'temporada': serializer.toJson<int>(temporada),
      'tipo': serializer.toJson<String>(tipo),
      'jugadorId': serializer.toJson<int>(jugadorId),
      'nombreJugador': serializer.toJson<String>(nombreJugador),
      'equipo': serializer.toJson<String>(equipo),
    };
  }

  PremioHistorico copyWith({
    int? id,
    int? temporada,
    String? tipo,
    int? jugadorId,
    String? nombreJugador,
    String? equipo,
  }) => PremioHistorico(
    id: id ?? this.id,
    temporada: temporada ?? this.temporada,
    tipo: tipo ?? this.tipo,
    jugadorId: jugadorId ?? this.jugadorId,
    nombreJugador: nombreJugador ?? this.nombreJugador,
    equipo: equipo ?? this.equipo,
  );
  PremioHistorico copyWithCompanion(HistorialPremiosCompanion data) {
    return PremioHistorico(
      id: data.id.present ? data.id.value : this.id,
      temporada: data.temporada.present ? data.temporada.value : this.temporada,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
      nombreJugador: data.nombreJugador.present
          ? data.nombreJugador.value
          : this.nombreJugador,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PremioHistorico(')
          ..write('id: $id, ')
          ..write('temporada: $temporada, ')
          ..write('tipo: $tipo, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('nombreJugador: $nombreJugador, ')
          ..write('equipo: $equipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, temporada, tipo, jugadorId, nombreJugador, equipo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PremioHistorico &&
          other.id == this.id &&
          other.temporada == this.temporada &&
          other.tipo == this.tipo &&
          other.jugadorId == this.jugadorId &&
          other.nombreJugador == this.nombreJugador &&
          other.equipo == this.equipo);
}

class HistorialPremiosCompanion extends UpdateCompanion<PremioHistorico> {
  final Value<int> id;
  final Value<int> temporada;
  final Value<String> tipo;
  final Value<int> jugadorId;
  final Value<String> nombreJugador;
  final Value<String> equipo;
  const HistorialPremiosCompanion({
    this.id = const Value.absent(),
    this.temporada = const Value.absent(),
    this.tipo = const Value.absent(),
    this.jugadorId = const Value.absent(),
    this.nombreJugador = const Value.absent(),
    this.equipo = const Value.absent(),
  });
  HistorialPremiosCompanion.insert({
    this.id = const Value.absent(),
    required int temporada,
    required String tipo,
    required int jugadorId,
    required String nombreJugador,
    required String equipo,
  }) : temporada = Value(temporada),
       tipo = Value(tipo),
       jugadorId = Value(jugadorId),
       nombreJugador = Value(nombreJugador),
       equipo = Value(equipo);
  static Insertable<PremioHistorico> custom({
    Expression<int>? id,
    Expression<int>? temporada,
    Expression<String>? tipo,
    Expression<int>? jugadorId,
    Expression<String>? nombreJugador,
    Expression<String>? equipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (temporada != null) 'temporada': temporada,
      if (tipo != null) 'tipo': tipo,
      if (jugadorId != null) 'jugador_id': jugadorId,
      if (nombreJugador != null) 'nombre_jugador': nombreJugador,
      if (equipo != null) 'equipo': equipo,
    });
  }

  HistorialPremiosCompanion copyWith({
    Value<int>? id,
    Value<int>? temporada,
    Value<String>? tipo,
    Value<int>? jugadorId,
    Value<String>? nombreJugador,
    Value<String>? equipo,
  }) {
    return HistorialPremiosCompanion(
      id: id ?? this.id,
      temporada: temporada ?? this.temporada,
      tipo: tipo ?? this.tipo,
      jugadorId: jugadorId ?? this.jugadorId,
      nombreJugador: nombreJugador ?? this.nombreJugador,
      equipo: equipo ?? this.equipo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (temporada.present) {
      map['temporada'] = Variable<int>(temporada.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    if (nombreJugador.present) {
      map['nombre_jugador'] = Variable<String>(nombreJugador.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistorialPremiosCompanion(')
          ..write('id: $id, ')
          ..write('temporada: $temporada, ')
          ..write('tipo: $tipo, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('nombreJugador: $nombreJugador, ')
          ..write('equipo: $equipo')
          ..write(')'))
        .toString();
  }
}

class $HistorialEstadisticasJugadorTable extends HistorialEstadisticasJugador
    with TableInfo<$HistorialEstadisticasJugadorTable, TemporadaDeCarrera> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistorialEstadisticasJugadorTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _temporadaMeta = const VerificationMeta(
    'temporada',
  );
  @override
  late final GeneratedColumn<int> temporada = GeneratedColumn<int>(
    'temporada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaMeta = const VerificationMeta('media');
  @override
  late final GeneratedColumn<int> media = GeneratedColumn<int>(
    'media',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partidosJugadosMeta = const VerificationMeta(
    'partidosJugados',
  );
  @override
  late final GeneratedColumn<int> partidosJugados = GeneratedColumn<int>(
    'partidos_jugados',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puntosTotalesMeta = const VerificationMeta(
    'puntosTotales',
  );
  @override
  late final GeneratedColumn<int> puntosTotales = GeneratedColumn<int>(
    'puntos_totales',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asistenciasTotalesMeta =
      const VerificationMeta('asistenciasTotales');
  @override
  late final GeneratedColumn<int> asistenciasTotales = GeneratedColumn<int>(
    'asistencias_totales',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rebotesTotalesMeta = const VerificationMeta(
    'rebotesTotales',
  );
  @override
  late final GeneratedColumn<int> rebotesTotales = GeneratedColumn<int>(
    'rebotes_totales',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    temporada,
    jugadorId,
    equipo,
    media,
    partidosJugados,
    puntosTotales,
    asistenciasTotales,
    rebotesTotales,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historial_estadisticas_jugador';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemporadaDeCarrera> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('temporada')) {
      context.handle(
        _temporadaMeta,
        temporada.isAcceptableOrUnknown(data['temporada']!, _temporadaMeta),
      );
    } else if (isInserting) {
      context.missing(_temporadaMeta);
    }
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jugadorIdMeta);
    }
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    if (data.containsKey('media')) {
      context.handle(
        _mediaMeta,
        media.isAcceptableOrUnknown(data['media']!, _mediaMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaMeta);
    }
    if (data.containsKey('partidos_jugados')) {
      context.handle(
        _partidosJugadosMeta,
        partidosJugados.isAcceptableOrUnknown(
          data['partidos_jugados']!,
          _partidosJugadosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partidosJugadosMeta);
    }
    if (data.containsKey('puntos_totales')) {
      context.handle(
        _puntosTotalesMeta,
        puntosTotales.isAcceptableOrUnknown(
          data['puntos_totales']!,
          _puntosTotalesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_puntosTotalesMeta);
    }
    if (data.containsKey('asistencias_totales')) {
      context.handle(
        _asistenciasTotalesMeta,
        asistenciasTotales.isAcceptableOrUnknown(
          data['asistencias_totales']!,
          _asistenciasTotalesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_asistenciasTotalesMeta);
    }
    if (data.containsKey('rebotes_totales')) {
      context.handle(
        _rebotesTotalesMeta,
        rebotesTotales.isAcceptableOrUnknown(
          data['rebotes_totales']!,
          _rebotesTotalesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rebotesTotalesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemporadaDeCarrera map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemporadaDeCarrera(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      temporada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporada'],
      )!,
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
      media: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}media'],
      )!,
      partidosJugados: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partidos_jugados'],
      )!,
      puntosTotales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}puntos_totales'],
      )!,
      asistenciasTotales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asistencias_totales'],
      )!,
      rebotesTotales: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rebotes_totales'],
      )!,
    );
  }

  @override
  $HistorialEstadisticasJugadorTable createAlias(String alias) {
    return $HistorialEstadisticasJugadorTable(attachedDatabase, alias);
  }
}

class TemporadaDeCarrera extends DataClass
    implements Insertable<TemporadaDeCarrera> {
  final int id;
  final int temporada;
  final int jugadorId;
  final String equipo;
  final int media;
  final int partidosJugados;
  final int puntosTotales;
  final int asistenciasTotales;
  final int rebotesTotales;
  const TemporadaDeCarrera({
    required this.id,
    required this.temporada,
    required this.jugadorId,
    required this.equipo,
    required this.media,
    required this.partidosJugados,
    required this.puntosTotales,
    required this.asistenciasTotales,
    required this.rebotesTotales,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['temporada'] = Variable<int>(temporada);
    map['jugador_id'] = Variable<int>(jugadorId);
    map['equipo'] = Variable<String>(equipo);
    map['media'] = Variable<int>(media);
    map['partidos_jugados'] = Variable<int>(partidosJugados);
    map['puntos_totales'] = Variable<int>(puntosTotales);
    map['asistencias_totales'] = Variable<int>(asistenciasTotales);
    map['rebotes_totales'] = Variable<int>(rebotesTotales);
    return map;
  }

  HistorialEstadisticasJugadorCompanion toCompanion(bool nullToAbsent) {
    return HistorialEstadisticasJugadorCompanion(
      id: Value(id),
      temporada: Value(temporada),
      jugadorId: Value(jugadorId),
      equipo: Value(equipo),
      media: Value(media),
      partidosJugados: Value(partidosJugados),
      puntosTotales: Value(puntosTotales),
      asistenciasTotales: Value(asistenciasTotales),
      rebotesTotales: Value(rebotesTotales),
    );
  }

  factory TemporadaDeCarrera.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemporadaDeCarrera(
      id: serializer.fromJson<int>(json['id']),
      temporada: serializer.fromJson<int>(json['temporada']),
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
      equipo: serializer.fromJson<String>(json['equipo']),
      media: serializer.fromJson<int>(json['media']),
      partidosJugados: serializer.fromJson<int>(json['partidosJugados']),
      puntosTotales: serializer.fromJson<int>(json['puntosTotales']),
      asistenciasTotales: serializer.fromJson<int>(json['asistenciasTotales']),
      rebotesTotales: serializer.fromJson<int>(json['rebotesTotales']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'temporada': serializer.toJson<int>(temporada),
      'jugadorId': serializer.toJson<int>(jugadorId),
      'equipo': serializer.toJson<String>(equipo),
      'media': serializer.toJson<int>(media),
      'partidosJugados': serializer.toJson<int>(partidosJugados),
      'puntosTotales': serializer.toJson<int>(puntosTotales),
      'asistenciasTotales': serializer.toJson<int>(asistenciasTotales),
      'rebotesTotales': serializer.toJson<int>(rebotesTotales),
    };
  }

  TemporadaDeCarrera copyWith({
    int? id,
    int? temporada,
    int? jugadorId,
    String? equipo,
    int? media,
    int? partidosJugados,
    int? puntosTotales,
    int? asistenciasTotales,
    int? rebotesTotales,
  }) => TemporadaDeCarrera(
    id: id ?? this.id,
    temporada: temporada ?? this.temporada,
    jugadorId: jugadorId ?? this.jugadorId,
    equipo: equipo ?? this.equipo,
    media: media ?? this.media,
    partidosJugados: partidosJugados ?? this.partidosJugados,
    puntosTotales: puntosTotales ?? this.puntosTotales,
    asistenciasTotales: asistenciasTotales ?? this.asistenciasTotales,
    rebotesTotales: rebotesTotales ?? this.rebotesTotales,
  );
  TemporadaDeCarrera copyWithCompanion(
    HistorialEstadisticasJugadorCompanion data,
  ) {
    return TemporadaDeCarrera(
      id: data.id.present ? data.id.value : this.id,
      temporada: data.temporada.present ? data.temporada.value : this.temporada,
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
      media: data.media.present ? data.media.value : this.media,
      partidosJugados: data.partidosJugados.present
          ? data.partidosJugados.value
          : this.partidosJugados,
      puntosTotales: data.puntosTotales.present
          ? data.puntosTotales.value
          : this.puntosTotales,
      asistenciasTotales: data.asistenciasTotales.present
          ? data.asistenciasTotales.value
          : this.asistenciasTotales,
      rebotesTotales: data.rebotesTotales.present
          ? data.rebotesTotales.value
          : this.rebotesTotales,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemporadaDeCarrera(')
          ..write('id: $id, ')
          ..write('temporada: $temporada, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('equipo: $equipo, ')
          ..write('media: $media, ')
          ..write('partidosJugados: $partidosJugados, ')
          ..write('puntosTotales: $puntosTotales, ')
          ..write('asistenciasTotales: $asistenciasTotales, ')
          ..write('rebotesTotales: $rebotesTotales')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    temporada,
    jugadorId,
    equipo,
    media,
    partidosJugados,
    puntosTotales,
    asistenciasTotales,
    rebotesTotales,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemporadaDeCarrera &&
          other.id == this.id &&
          other.temporada == this.temporada &&
          other.jugadorId == this.jugadorId &&
          other.equipo == this.equipo &&
          other.media == this.media &&
          other.partidosJugados == this.partidosJugados &&
          other.puntosTotales == this.puntosTotales &&
          other.asistenciasTotales == this.asistenciasTotales &&
          other.rebotesTotales == this.rebotesTotales);
}

class HistorialEstadisticasJugadorCompanion
    extends UpdateCompanion<TemporadaDeCarrera> {
  final Value<int> id;
  final Value<int> temporada;
  final Value<int> jugadorId;
  final Value<String> equipo;
  final Value<int> media;
  final Value<int> partidosJugados;
  final Value<int> puntosTotales;
  final Value<int> asistenciasTotales;
  final Value<int> rebotesTotales;
  const HistorialEstadisticasJugadorCompanion({
    this.id = const Value.absent(),
    this.temporada = const Value.absent(),
    this.jugadorId = const Value.absent(),
    this.equipo = const Value.absent(),
    this.media = const Value.absent(),
    this.partidosJugados = const Value.absent(),
    this.puntosTotales = const Value.absent(),
    this.asistenciasTotales = const Value.absent(),
    this.rebotesTotales = const Value.absent(),
  });
  HistorialEstadisticasJugadorCompanion.insert({
    this.id = const Value.absent(),
    required int temporada,
    required int jugadorId,
    required String equipo,
    required int media,
    required int partidosJugados,
    required int puntosTotales,
    required int asistenciasTotales,
    required int rebotesTotales,
  }) : temporada = Value(temporada),
       jugadorId = Value(jugadorId),
       equipo = Value(equipo),
       media = Value(media),
       partidosJugados = Value(partidosJugados),
       puntosTotales = Value(puntosTotales),
       asistenciasTotales = Value(asistenciasTotales),
       rebotesTotales = Value(rebotesTotales);
  static Insertable<TemporadaDeCarrera> custom({
    Expression<int>? id,
    Expression<int>? temporada,
    Expression<int>? jugadorId,
    Expression<String>? equipo,
    Expression<int>? media,
    Expression<int>? partidosJugados,
    Expression<int>? puntosTotales,
    Expression<int>? asistenciasTotales,
    Expression<int>? rebotesTotales,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (temporada != null) 'temporada': temporada,
      if (jugadorId != null) 'jugador_id': jugadorId,
      if (equipo != null) 'equipo': equipo,
      if (media != null) 'media': media,
      if (partidosJugados != null) 'partidos_jugados': partidosJugados,
      if (puntosTotales != null) 'puntos_totales': puntosTotales,
      if (asistenciasTotales != null) 'asistencias_totales': asistenciasTotales,
      if (rebotesTotales != null) 'rebotes_totales': rebotesTotales,
    });
  }

  HistorialEstadisticasJugadorCompanion copyWith({
    Value<int>? id,
    Value<int>? temporada,
    Value<int>? jugadorId,
    Value<String>? equipo,
    Value<int>? media,
    Value<int>? partidosJugados,
    Value<int>? puntosTotales,
    Value<int>? asistenciasTotales,
    Value<int>? rebotesTotales,
  }) {
    return HistorialEstadisticasJugadorCompanion(
      id: id ?? this.id,
      temporada: temporada ?? this.temporada,
      jugadorId: jugadorId ?? this.jugadorId,
      equipo: equipo ?? this.equipo,
      media: media ?? this.media,
      partidosJugados: partidosJugados ?? this.partidosJugados,
      puntosTotales: puntosTotales ?? this.puntosTotales,
      asistenciasTotales: asistenciasTotales ?? this.asistenciasTotales,
      rebotesTotales: rebotesTotales ?? this.rebotesTotales,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (temporada.present) {
      map['temporada'] = Variable<int>(temporada.value);
    }
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    if (media.present) {
      map['media'] = Variable<int>(media.value);
    }
    if (partidosJugados.present) {
      map['partidos_jugados'] = Variable<int>(partidosJugados.value);
    }
    if (puntosTotales.present) {
      map['puntos_totales'] = Variable<int>(puntosTotales.value);
    }
    if (asistenciasTotales.present) {
      map['asistencias_totales'] = Variable<int>(asistenciasTotales.value);
    }
    if (rebotesTotales.present) {
      map['rebotes_totales'] = Variable<int>(rebotesTotales.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistorialEstadisticasJugadorCompanion(')
          ..write('id: $id, ')
          ..write('temporada: $temporada, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('equipo: $equipo, ')
          ..write('media: $media, ')
          ..write('partidosJugados: $partidosJugados, ')
          ..write('puntosTotales: $puntosTotales, ')
          ..write('asistenciasTotales: $asistenciasTotales, ')
          ..write('rebotesTotales: $rebotesTotales')
          ..write(')'))
        .toString();
  }
}

class $CamisetasRetiradasTable extends CamisetasRetiradas
    with TableInfo<$CamisetasRetiradasTable, CamisetaRetirada> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CamisetasRetiradasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreJugadorMeta = const VerificationMeta(
    'nombreJugador',
  );
  @override
  late final GeneratedColumn<String> nombreJugador = GeneratedColumn<String>(
    'nombre_jugador',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dorsalMeta = const VerificationMeta('dorsal');
  @override
  late final GeneratedColumn<int> dorsal = GeneratedColumn<int>(
    'dorsal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temporadaMeta = const VerificationMeta(
    'temporada',
  );
  @override
  late final GeneratedColumn<int> temporada = GeneratedColumn<int>(
    'temporada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    equipo,
    jugadorId,
    nombreJugador,
    dorsal,
    temporada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camisetas_retiradas';
  @override
  VerificationContext validateIntegrity(
    Insertable<CamisetaRetirada> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jugadorIdMeta);
    }
    if (data.containsKey('nombre_jugador')) {
      context.handle(
        _nombreJugadorMeta,
        nombreJugador.isAcceptableOrUnknown(
          data['nombre_jugador']!,
          _nombreJugadorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreJugadorMeta);
    }
    if (data.containsKey('dorsal')) {
      context.handle(
        _dorsalMeta,
        dorsal.isAcceptableOrUnknown(data['dorsal']!, _dorsalMeta),
      );
    } else if (isInserting) {
      context.missing(_dorsalMeta);
    }
    if (data.containsKey('temporada')) {
      context.handle(
        _temporadaMeta,
        temporada.isAcceptableOrUnknown(data['temporada']!, _temporadaMeta),
      );
    } else if (isInserting) {
      context.missing(_temporadaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CamisetaRetirada map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CamisetaRetirada(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
      nombreJugador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_jugador'],
      )!,
      dorsal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dorsal'],
      )!,
      temporada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporada'],
      )!,
    );
  }

  @override
  $CamisetasRetiradasTable createAlias(String alias) {
    return $CamisetasRetiradasTable(attachedDatabase, alias);
  }
}

class CamisetaRetirada extends DataClass
    implements Insertable<CamisetaRetirada> {
  final int id;
  final String equipo;
  final int jugadorId;
  final String nombreJugador;
  final int dorsal;
  final int temporada;
  const CamisetaRetirada({
    required this.id,
    required this.equipo,
    required this.jugadorId,
    required this.nombreJugador,
    required this.dorsal,
    required this.temporada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['equipo'] = Variable<String>(equipo);
    map['jugador_id'] = Variable<int>(jugadorId);
    map['nombre_jugador'] = Variable<String>(nombreJugador);
    map['dorsal'] = Variable<int>(dorsal);
    map['temporada'] = Variable<int>(temporada);
    return map;
  }

  CamisetasRetiradasCompanion toCompanion(bool nullToAbsent) {
    return CamisetasRetiradasCompanion(
      id: Value(id),
      equipo: Value(equipo),
      jugadorId: Value(jugadorId),
      nombreJugador: Value(nombreJugador),
      dorsal: Value(dorsal),
      temporada: Value(temporada),
    );
  }

  factory CamisetaRetirada.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CamisetaRetirada(
      id: serializer.fromJson<int>(json['id']),
      equipo: serializer.fromJson<String>(json['equipo']),
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
      nombreJugador: serializer.fromJson<String>(json['nombreJugador']),
      dorsal: serializer.fromJson<int>(json['dorsal']),
      temporada: serializer.fromJson<int>(json['temporada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'equipo': serializer.toJson<String>(equipo),
      'jugadorId': serializer.toJson<int>(jugadorId),
      'nombreJugador': serializer.toJson<String>(nombreJugador),
      'dorsal': serializer.toJson<int>(dorsal),
      'temporada': serializer.toJson<int>(temporada),
    };
  }

  CamisetaRetirada copyWith({
    int? id,
    String? equipo,
    int? jugadorId,
    String? nombreJugador,
    int? dorsal,
    int? temporada,
  }) => CamisetaRetirada(
    id: id ?? this.id,
    equipo: equipo ?? this.equipo,
    jugadorId: jugadorId ?? this.jugadorId,
    nombreJugador: nombreJugador ?? this.nombreJugador,
    dorsal: dorsal ?? this.dorsal,
    temporada: temporada ?? this.temporada,
  );
  CamisetaRetirada copyWithCompanion(CamisetasRetiradasCompanion data) {
    return CamisetaRetirada(
      id: data.id.present ? data.id.value : this.id,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
      nombreJugador: data.nombreJugador.present
          ? data.nombreJugador.value
          : this.nombreJugador,
      dorsal: data.dorsal.present ? data.dorsal.value : this.dorsal,
      temporada: data.temporada.present ? data.temporada.value : this.temporada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CamisetaRetirada(')
          ..write('id: $id, ')
          ..write('equipo: $equipo, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('nombreJugador: $nombreJugador, ')
          ..write('dorsal: $dorsal, ')
          ..write('temporada: $temporada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, equipo, jugadorId, nombreJugador, dorsal, temporada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CamisetaRetirada &&
          other.id == this.id &&
          other.equipo == this.equipo &&
          other.jugadorId == this.jugadorId &&
          other.nombreJugador == this.nombreJugador &&
          other.dorsal == this.dorsal &&
          other.temporada == this.temporada);
}

class CamisetasRetiradasCompanion extends UpdateCompanion<CamisetaRetirada> {
  final Value<int> id;
  final Value<String> equipo;
  final Value<int> jugadorId;
  final Value<String> nombreJugador;
  final Value<int> dorsal;
  final Value<int> temporada;
  const CamisetasRetiradasCompanion({
    this.id = const Value.absent(),
    this.equipo = const Value.absent(),
    this.jugadorId = const Value.absent(),
    this.nombreJugador = const Value.absent(),
    this.dorsal = const Value.absent(),
    this.temporada = const Value.absent(),
  });
  CamisetasRetiradasCompanion.insert({
    this.id = const Value.absent(),
    required String equipo,
    required int jugadorId,
    required String nombreJugador,
    required int dorsal,
    required int temporada,
  }) : equipo = Value(equipo),
       jugadorId = Value(jugadorId),
       nombreJugador = Value(nombreJugador),
       dorsal = Value(dorsal),
       temporada = Value(temporada);
  static Insertable<CamisetaRetirada> custom({
    Expression<int>? id,
    Expression<String>? equipo,
    Expression<int>? jugadorId,
    Expression<String>? nombreJugador,
    Expression<int>? dorsal,
    Expression<int>? temporada,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (equipo != null) 'equipo': equipo,
      if (jugadorId != null) 'jugador_id': jugadorId,
      if (nombreJugador != null) 'nombre_jugador': nombreJugador,
      if (dorsal != null) 'dorsal': dorsal,
      if (temporada != null) 'temporada': temporada,
    });
  }

  CamisetasRetiradasCompanion copyWith({
    Value<int>? id,
    Value<String>? equipo,
    Value<int>? jugadorId,
    Value<String>? nombreJugador,
    Value<int>? dorsal,
    Value<int>? temporada,
  }) {
    return CamisetasRetiradasCompanion(
      id: id ?? this.id,
      equipo: equipo ?? this.equipo,
      jugadorId: jugadorId ?? this.jugadorId,
      nombreJugador: nombreJugador ?? this.nombreJugador,
      dorsal: dorsal ?? this.dorsal,
      temporada: temporada ?? this.temporada,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    if (nombreJugador.present) {
      map['nombre_jugador'] = Variable<String>(nombreJugador.value);
    }
    if (dorsal.present) {
      map['dorsal'] = Variable<int>(dorsal.value);
    }
    if (temporada.present) {
      map['temporada'] = Variable<int>(temporada.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CamisetasRetiradasCompanion(')
          ..write('id: $id, ')
          ..write('equipo: $equipo, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('nombreJugador: $nombreJugador, ')
          ..write('dorsal: $dorsal, ')
          ..write('temporada: $temporada')
          ..write(')'))
        .toString();
  }
}

class $HallDeLaFamaTable extends HallDeLaFama
    with TableInfo<$HallDeLaFamaTable, MiembroHallDeLaFama> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HallDeLaFamaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _jugadorIdMeta = const VerificationMeta(
    'jugadorId',
  );
  @override
  late final GeneratedColumn<int> jugadorId = GeneratedColumn<int>(
    'jugador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreJugadorMeta = const VerificationMeta(
    'nombreJugador',
  );
  @override
  late final GeneratedColumn<String> nombreJugador = GeneratedColumn<String>(
    'nombre_jugador',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temporadaIngresoMeta = const VerificationMeta(
    'temporadaIngreso',
  );
  @override
  late final GeneratedColumn<int> temporadaIngreso = GeneratedColumn<int>(
    'temporada_ingreso',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _puntuacionMeta = const VerificationMeta(
    'puntuacion',
  );
  @override
  late final GeneratedColumn<double> puntuacion = GeneratedColumn<double>(
    'puntuacion',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jugadorId,
    nombreJugador,
    temporadaIngreso,
    puntuacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hall_de_la_fama';
  @override
  VerificationContext validateIntegrity(
    Insertable<MiembroHallDeLaFama> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jugador_id')) {
      context.handle(
        _jugadorIdMeta,
        jugadorId.isAcceptableOrUnknown(data['jugador_id']!, _jugadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jugadorIdMeta);
    }
    if (data.containsKey('nombre_jugador')) {
      context.handle(
        _nombreJugadorMeta,
        nombreJugador.isAcceptableOrUnknown(
          data['nombre_jugador']!,
          _nombreJugadorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreJugadorMeta);
    }
    if (data.containsKey('temporada_ingreso')) {
      context.handle(
        _temporadaIngresoMeta,
        temporadaIngreso.isAcceptableOrUnknown(
          data['temporada_ingreso']!,
          _temporadaIngresoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temporadaIngresoMeta);
    }
    if (data.containsKey('puntuacion')) {
      context.handle(
        _puntuacionMeta,
        puntuacion.isAcceptableOrUnknown(data['puntuacion']!, _puntuacionMeta),
      );
    } else if (isInserting) {
      context.missing(_puntuacionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MiembroHallDeLaFama map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MiembroHallDeLaFama(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jugadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jugador_id'],
      )!,
      nombreJugador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_jugador'],
      )!,
      temporadaIngreso: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporada_ingreso'],
      )!,
      puntuacion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}puntuacion'],
      )!,
    );
  }

  @override
  $HallDeLaFamaTable createAlias(String alias) {
    return $HallDeLaFamaTable(attachedDatabase, alias);
  }
}

class MiembroHallDeLaFama extends DataClass
    implements Insertable<MiembroHallDeLaFama> {
  final int id;
  final int jugadorId;
  final String nombreJugador;
  final int temporadaIngreso;
  final double puntuacion;
  const MiembroHallDeLaFama({
    required this.id,
    required this.jugadorId,
    required this.nombreJugador,
    required this.temporadaIngreso,
    required this.puntuacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jugador_id'] = Variable<int>(jugadorId);
    map['nombre_jugador'] = Variable<String>(nombreJugador);
    map['temporada_ingreso'] = Variable<int>(temporadaIngreso);
    map['puntuacion'] = Variable<double>(puntuacion);
    return map;
  }

  HallDeLaFamaCompanion toCompanion(bool nullToAbsent) {
    return HallDeLaFamaCompanion(
      id: Value(id),
      jugadorId: Value(jugadorId),
      nombreJugador: Value(nombreJugador),
      temporadaIngreso: Value(temporadaIngreso),
      puntuacion: Value(puntuacion),
    );
  }

  factory MiembroHallDeLaFama.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MiembroHallDeLaFama(
      id: serializer.fromJson<int>(json['id']),
      jugadorId: serializer.fromJson<int>(json['jugadorId']),
      nombreJugador: serializer.fromJson<String>(json['nombreJugador']),
      temporadaIngreso: serializer.fromJson<int>(json['temporadaIngreso']),
      puntuacion: serializer.fromJson<double>(json['puntuacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jugadorId': serializer.toJson<int>(jugadorId),
      'nombreJugador': serializer.toJson<String>(nombreJugador),
      'temporadaIngreso': serializer.toJson<int>(temporadaIngreso),
      'puntuacion': serializer.toJson<double>(puntuacion),
    };
  }

  MiembroHallDeLaFama copyWith({
    int? id,
    int? jugadorId,
    String? nombreJugador,
    int? temporadaIngreso,
    double? puntuacion,
  }) => MiembroHallDeLaFama(
    id: id ?? this.id,
    jugadorId: jugadorId ?? this.jugadorId,
    nombreJugador: nombreJugador ?? this.nombreJugador,
    temporadaIngreso: temporadaIngreso ?? this.temporadaIngreso,
    puntuacion: puntuacion ?? this.puntuacion,
  );
  MiembroHallDeLaFama copyWithCompanion(HallDeLaFamaCompanion data) {
    return MiembroHallDeLaFama(
      id: data.id.present ? data.id.value : this.id,
      jugadorId: data.jugadorId.present ? data.jugadorId.value : this.jugadorId,
      nombreJugador: data.nombreJugador.present
          ? data.nombreJugador.value
          : this.nombreJugador,
      temporadaIngreso: data.temporadaIngreso.present
          ? data.temporadaIngreso.value
          : this.temporadaIngreso,
      puntuacion: data.puntuacion.present
          ? data.puntuacion.value
          : this.puntuacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MiembroHallDeLaFama(')
          ..write('id: $id, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('nombreJugador: $nombreJugador, ')
          ..write('temporadaIngreso: $temporadaIngreso, ')
          ..write('puntuacion: $puntuacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, jugadorId, nombreJugador, temporadaIngreso, puntuacion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MiembroHallDeLaFama &&
          other.id == this.id &&
          other.jugadorId == this.jugadorId &&
          other.nombreJugador == this.nombreJugador &&
          other.temporadaIngreso == this.temporadaIngreso &&
          other.puntuacion == this.puntuacion);
}

class HallDeLaFamaCompanion extends UpdateCompanion<MiembroHallDeLaFama> {
  final Value<int> id;
  final Value<int> jugadorId;
  final Value<String> nombreJugador;
  final Value<int> temporadaIngreso;
  final Value<double> puntuacion;
  const HallDeLaFamaCompanion({
    this.id = const Value.absent(),
    this.jugadorId = const Value.absent(),
    this.nombreJugador = const Value.absent(),
    this.temporadaIngreso = const Value.absent(),
    this.puntuacion = const Value.absent(),
  });
  HallDeLaFamaCompanion.insert({
    this.id = const Value.absent(),
    required int jugadorId,
    required String nombreJugador,
    required int temporadaIngreso,
    required double puntuacion,
  }) : jugadorId = Value(jugadorId),
       nombreJugador = Value(nombreJugador),
       temporadaIngreso = Value(temporadaIngreso),
       puntuacion = Value(puntuacion);
  static Insertable<MiembroHallDeLaFama> custom({
    Expression<int>? id,
    Expression<int>? jugadorId,
    Expression<String>? nombreJugador,
    Expression<int>? temporadaIngreso,
    Expression<double>? puntuacion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jugadorId != null) 'jugador_id': jugadorId,
      if (nombreJugador != null) 'nombre_jugador': nombreJugador,
      if (temporadaIngreso != null) 'temporada_ingreso': temporadaIngreso,
      if (puntuacion != null) 'puntuacion': puntuacion,
    });
  }

  HallDeLaFamaCompanion copyWith({
    Value<int>? id,
    Value<int>? jugadorId,
    Value<String>? nombreJugador,
    Value<int>? temporadaIngreso,
    Value<double>? puntuacion,
  }) {
    return HallDeLaFamaCompanion(
      id: id ?? this.id,
      jugadorId: jugadorId ?? this.jugadorId,
      nombreJugador: nombreJugador ?? this.nombreJugador,
      temporadaIngreso: temporadaIngreso ?? this.temporadaIngreso,
      puntuacion: puntuacion ?? this.puntuacion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jugadorId.present) {
      map['jugador_id'] = Variable<int>(jugadorId.value);
    }
    if (nombreJugador.present) {
      map['nombre_jugador'] = Variable<String>(nombreJugador.value);
    }
    if (temporadaIngreso.present) {
      map['temporada_ingreso'] = Variable<int>(temporadaIngreso.value);
    }
    if (puntuacion.present) {
      map['puntuacion'] = Variable<double>(puntuacion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HallDeLaFamaCompanion(')
          ..write('id: $id, ')
          ..write('jugadorId: $jugadorId, ')
          ..write('nombreJugador: $nombreJugador, ')
          ..write('temporadaIngreso: $temporadaIngreso, ')
          ..write('puntuacion: $puntuacion')
          ..write(')'))
        .toString();
  }
}

class $DraftEnCursoTable extends DraftEnCurso
    with TableInfo<$DraftEnCursoTable, DraftEnCursoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftEnCursoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _anioDraftMeta = const VerificationMeta(
    'anioDraft',
  );
  @override
  late final GeneratedColumn<int> anioDraft = GeneratedColumn<int>(
    'anio_draft',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenEquiposMeta = const VerificationMeta(
    'ordenEquipos',
  );
  @override
  late final GeneratedColumn<String> ordenEquipos = GeneratedColumn<String>(
    'orden_equipos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _indiceMeta = const VerificationMeta('indice');
  @override
  late final GeneratedColumn<int> indice = GeneratedColumn<int>(
    'indice',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, anioDraft, ordenEquipos, indice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draft_en_curso';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftEnCursoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('anio_draft')) {
      context.handle(
        _anioDraftMeta,
        anioDraft.isAcceptableOrUnknown(data['anio_draft']!, _anioDraftMeta),
      );
    } else if (isInserting) {
      context.missing(_anioDraftMeta);
    }
    if (data.containsKey('orden_equipos')) {
      context.handle(
        _ordenEquiposMeta,
        ordenEquipos.isAcceptableOrUnknown(
          data['orden_equipos']!,
          _ordenEquiposMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ordenEquiposMeta);
    }
    if (data.containsKey('indice')) {
      context.handle(
        _indiceMeta,
        indice.isAcceptableOrUnknown(data['indice']!, _indiceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftEnCursoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftEnCursoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      anioDraft: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anio_draft'],
      )!,
      ordenEquipos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}orden_equipos'],
      )!,
      indice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}indice'],
      )!,
    );
  }

  @override
  $DraftEnCursoTable createAlias(String alias) {
    return $DraftEnCursoTable(attachedDatabase, alias);
  }
}

class DraftEnCursoData extends DataClass
    implements Insertable<DraftEnCursoData> {
  final int id;
  final int anioDraft;
  final String ordenEquipos;
  final int indice;
  const DraftEnCursoData({
    required this.id,
    required this.anioDraft,
    required this.ordenEquipos,
    required this.indice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['anio_draft'] = Variable<int>(anioDraft);
    map['orden_equipos'] = Variable<String>(ordenEquipos);
    map['indice'] = Variable<int>(indice);
    return map;
  }

  DraftEnCursoCompanion toCompanion(bool nullToAbsent) {
    return DraftEnCursoCompanion(
      id: Value(id),
      anioDraft: Value(anioDraft),
      ordenEquipos: Value(ordenEquipos),
      indice: Value(indice),
    );
  }

  factory DraftEnCursoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftEnCursoData(
      id: serializer.fromJson<int>(json['id']),
      anioDraft: serializer.fromJson<int>(json['anioDraft']),
      ordenEquipos: serializer.fromJson<String>(json['ordenEquipos']),
      indice: serializer.fromJson<int>(json['indice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'anioDraft': serializer.toJson<int>(anioDraft),
      'ordenEquipos': serializer.toJson<String>(ordenEquipos),
      'indice': serializer.toJson<int>(indice),
    };
  }

  DraftEnCursoData copyWith({
    int? id,
    int? anioDraft,
    String? ordenEquipos,
    int? indice,
  }) => DraftEnCursoData(
    id: id ?? this.id,
    anioDraft: anioDraft ?? this.anioDraft,
    ordenEquipos: ordenEquipos ?? this.ordenEquipos,
    indice: indice ?? this.indice,
  );
  DraftEnCursoData copyWithCompanion(DraftEnCursoCompanion data) {
    return DraftEnCursoData(
      id: data.id.present ? data.id.value : this.id,
      anioDraft: data.anioDraft.present ? data.anioDraft.value : this.anioDraft,
      ordenEquipos: data.ordenEquipos.present
          ? data.ordenEquipos.value
          : this.ordenEquipos,
      indice: data.indice.present ? data.indice.value : this.indice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftEnCursoData(')
          ..write('id: $id, ')
          ..write('anioDraft: $anioDraft, ')
          ..write('ordenEquipos: $ordenEquipos, ')
          ..write('indice: $indice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, anioDraft, ordenEquipos, indice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftEnCursoData &&
          other.id == this.id &&
          other.anioDraft == this.anioDraft &&
          other.ordenEquipos == this.ordenEquipos &&
          other.indice == this.indice);
}

class DraftEnCursoCompanion extends UpdateCompanion<DraftEnCursoData> {
  final Value<int> id;
  final Value<int> anioDraft;
  final Value<String> ordenEquipos;
  final Value<int> indice;
  const DraftEnCursoCompanion({
    this.id = const Value.absent(),
    this.anioDraft = const Value.absent(),
    this.ordenEquipos = const Value.absent(),
    this.indice = const Value.absent(),
  });
  DraftEnCursoCompanion.insert({
    this.id = const Value.absent(),
    required int anioDraft,
    required String ordenEquipos,
    this.indice = const Value.absent(),
  }) : anioDraft = Value(anioDraft),
       ordenEquipos = Value(ordenEquipos);
  static Insertable<DraftEnCursoData> custom({
    Expression<int>? id,
    Expression<int>? anioDraft,
    Expression<String>? ordenEquipos,
    Expression<int>? indice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (anioDraft != null) 'anio_draft': anioDraft,
      if (ordenEquipos != null) 'orden_equipos': ordenEquipos,
      if (indice != null) 'indice': indice,
    });
  }

  DraftEnCursoCompanion copyWith({
    Value<int>? id,
    Value<int>? anioDraft,
    Value<String>? ordenEquipos,
    Value<int>? indice,
  }) {
    return DraftEnCursoCompanion(
      id: id ?? this.id,
      anioDraft: anioDraft ?? this.anioDraft,
      ordenEquipos: ordenEquipos ?? this.ordenEquipos,
      indice: indice ?? this.indice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (anioDraft.present) {
      map['anio_draft'] = Variable<int>(anioDraft.value);
    }
    if (ordenEquipos.present) {
      map['orden_equipos'] = Variable<String>(ordenEquipos.value);
    }
    if (indice.present) {
      map['indice'] = Variable<int>(indice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftEnCursoCompanion(')
          ..write('id: $id, ')
          ..write('anioDraft: $anioDraft, ')
          ..write('ordenEquipos: $ordenEquipos, ')
          ..write('indice: $indice')
          ..write(')'))
        .toString();
  }
}

class $PicksDraftTable extends PicksDraft
    with TableInfo<$PicksDraftTable, PickDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PicksDraftTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _temporadaMeta = const VerificationMeta(
    'temporada',
  );
  @override
  late final GeneratedColumn<int> temporada = GeneratedColumn<int>(
    'temporada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rondaMeta = const VerificationMeta('ronda');
  @override
  late final GeneratedColumn<int> ronda = GeneratedColumn<int>(
    'ronda',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoOriginalMeta = const VerificationMeta(
    'equipoOriginal',
  );
  @override
  late final GeneratedColumn<String> equipoOriginal = GeneratedColumn<String>(
    'equipo_original',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoActualMeta = const VerificationMeta(
    'equipoActual',
  );
  @override
  late final GeneratedColumn<String> equipoActual = GeneratedColumn<String>(
    'equipo_actual',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usadoMeta = const VerificationMeta('usado');
  @override
  late final GeneratedColumn<bool> usado = GeneratedColumn<bool>(
    'usado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("usado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    temporada,
    ronda,
    equipoOriginal,
    equipoActual,
    usado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'picks_draft';
  @override
  VerificationContext validateIntegrity(
    Insertable<PickDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('temporada')) {
      context.handle(
        _temporadaMeta,
        temporada.isAcceptableOrUnknown(data['temporada']!, _temporadaMeta),
      );
    } else if (isInserting) {
      context.missing(_temporadaMeta);
    }
    if (data.containsKey('ronda')) {
      context.handle(
        _rondaMeta,
        ronda.isAcceptableOrUnknown(data['ronda']!, _rondaMeta),
      );
    } else if (isInserting) {
      context.missing(_rondaMeta);
    }
    if (data.containsKey('equipo_original')) {
      context.handle(
        _equipoOriginalMeta,
        equipoOriginal.isAcceptableOrUnknown(
          data['equipo_original']!,
          _equipoOriginalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipoOriginalMeta);
    }
    if (data.containsKey('equipo_actual')) {
      context.handle(
        _equipoActualMeta,
        equipoActual.isAcceptableOrUnknown(
          data['equipo_actual']!,
          _equipoActualMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipoActualMeta);
    }
    if (data.containsKey('usado')) {
      context.handle(
        _usadoMeta,
        usado.isAcceptableOrUnknown(data['usado']!, _usadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PickDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PickDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      temporada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporada'],
      )!,
      ronda: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ronda'],
      )!,
      equipoOriginal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_original'],
      )!,
      equipoActual: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_actual'],
      )!,
      usado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}usado'],
      )!,
    );
  }

  @override
  $PicksDraftTable createAlias(String alias) {
    return $PicksDraftTable(attachedDatabase, alias);
  }
}

class PickDraft extends DataClass implements Insertable<PickDraft> {
  final int id;
  final int temporada;
  final int ronda;
  final String equipoOriginal;
  final String equipoActual;
  final bool usado;
  const PickDraft({
    required this.id,
    required this.temporada,
    required this.ronda,
    required this.equipoOriginal,
    required this.equipoActual,
    required this.usado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['temporada'] = Variable<int>(temporada);
    map['ronda'] = Variable<int>(ronda);
    map['equipo_original'] = Variable<String>(equipoOriginal);
    map['equipo_actual'] = Variable<String>(equipoActual);
    map['usado'] = Variable<bool>(usado);
    return map;
  }

  PicksDraftCompanion toCompanion(bool nullToAbsent) {
    return PicksDraftCompanion(
      id: Value(id),
      temporada: Value(temporada),
      ronda: Value(ronda),
      equipoOriginal: Value(equipoOriginal),
      equipoActual: Value(equipoActual),
      usado: Value(usado),
    );
  }

  factory PickDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PickDraft(
      id: serializer.fromJson<int>(json['id']),
      temporada: serializer.fromJson<int>(json['temporada']),
      ronda: serializer.fromJson<int>(json['ronda']),
      equipoOriginal: serializer.fromJson<String>(json['equipoOriginal']),
      equipoActual: serializer.fromJson<String>(json['equipoActual']),
      usado: serializer.fromJson<bool>(json['usado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'temporada': serializer.toJson<int>(temporada),
      'ronda': serializer.toJson<int>(ronda),
      'equipoOriginal': serializer.toJson<String>(equipoOriginal),
      'equipoActual': serializer.toJson<String>(equipoActual),
      'usado': serializer.toJson<bool>(usado),
    };
  }

  PickDraft copyWith({
    int? id,
    int? temporada,
    int? ronda,
    String? equipoOriginal,
    String? equipoActual,
    bool? usado,
  }) => PickDraft(
    id: id ?? this.id,
    temporada: temporada ?? this.temporada,
    ronda: ronda ?? this.ronda,
    equipoOriginal: equipoOriginal ?? this.equipoOriginal,
    equipoActual: equipoActual ?? this.equipoActual,
    usado: usado ?? this.usado,
  );
  PickDraft copyWithCompanion(PicksDraftCompanion data) {
    return PickDraft(
      id: data.id.present ? data.id.value : this.id,
      temporada: data.temporada.present ? data.temporada.value : this.temporada,
      ronda: data.ronda.present ? data.ronda.value : this.ronda,
      equipoOriginal: data.equipoOriginal.present
          ? data.equipoOriginal.value
          : this.equipoOriginal,
      equipoActual: data.equipoActual.present
          ? data.equipoActual.value
          : this.equipoActual,
      usado: data.usado.present ? data.usado.value : this.usado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PickDraft(')
          ..write('id: $id, ')
          ..write('temporada: $temporada, ')
          ..write('ronda: $ronda, ')
          ..write('equipoOriginal: $equipoOriginal, ')
          ..write('equipoActual: $equipoActual, ')
          ..write('usado: $usado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, temporada, ronda, equipoOriginal, equipoActual, usado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PickDraft &&
          other.id == this.id &&
          other.temporada == this.temporada &&
          other.ronda == this.ronda &&
          other.equipoOriginal == this.equipoOriginal &&
          other.equipoActual == this.equipoActual &&
          other.usado == this.usado);
}

class PicksDraftCompanion extends UpdateCompanion<PickDraft> {
  final Value<int> id;
  final Value<int> temporada;
  final Value<int> ronda;
  final Value<String> equipoOriginal;
  final Value<String> equipoActual;
  final Value<bool> usado;
  const PicksDraftCompanion({
    this.id = const Value.absent(),
    this.temporada = const Value.absent(),
    this.ronda = const Value.absent(),
    this.equipoOriginal = const Value.absent(),
    this.equipoActual = const Value.absent(),
    this.usado = const Value.absent(),
  });
  PicksDraftCompanion.insert({
    this.id = const Value.absent(),
    required int temporada,
    required int ronda,
    required String equipoOriginal,
    required String equipoActual,
    this.usado = const Value.absent(),
  }) : temporada = Value(temporada),
       ronda = Value(ronda),
       equipoOriginal = Value(equipoOriginal),
       equipoActual = Value(equipoActual);
  static Insertable<PickDraft> custom({
    Expression<int>? id,
    Expression<int>? temporada,
    Expression<int>? ronda,
    Expression<String>? equipoOriginal,
    Expression<String>? equipoActual,
    Expression<bool>? usado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (temporada != null) 'temporada': temporada,
      if (ronda != null) 'ronda': ronda,
      if (equipoOriginal != null) 'equipo_original': equipoOriginal,
      if (equipoActual != null) 'equipo_actual': equipoActual,
      if (usado != null) 'usado': usado,
    });
  }

  PicksDraftCompanion copyWith({
    Value<int>? id,
    Value<int>? temporada,
    Value<int>? ronda,
    Value<String>? equipoOriginal,
    Value<String>? equipoActual,
    Value<bool>? usado,
  }) {
    return PicksDraftCompanion(
      id: id ?? this.id,
      temporada: temporada ?? this.temporada,
      ronda: ronda ?? this.ronda,
      equipoOriginal: equipoOriginal ?? this.equipoOriginal,
      equipoActual: equipoActual ?? this.equipoActual,
      usado: usado ?? this.usado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (temporada.present) {
      map['temporada'] = Variable<int>(temporada.value);
    }
    if (ronda.present) {
      map['ronda'] = Variable<int>(ronda.value);
    }
    if (equipoOriginal.present) {
      map['equipo_original'] = Variable<String>(equipoOriginal.value);
    }
    if (equipoActual.present) {
      map['equipo_actual'] = Variable<String>(equipoActual.value);
    }
    if (usado.present) {
      map['usado'] = Variable<bool>(usado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PicksDraftCompanion(')
          ..write('id: $id, ')
          ..write('temporada: $temporada, ')
          ..write('ronda: $ronda, ')
          ..write('equipoOriginal: $equipoOriginal, ')
          ..write('equipoActual: $equipoActual, ')
          ..write('usado: $usado')
          ..write(')'))
        .toString();
  }
}

class $OfertasTraspasoTable extends OfertasTraspaso
    with TableInfo<$OfertasTraspasoTable, OfertaTraspaso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfertasTraspasoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _equipoOfertanteMeta = const VerificationMeta(
    'equipoOfertante',
  );
  @override
  late final GeneratedColumn<String> equipoOfertante = GeneratedColumn<String>(
    'equipo_ofertante',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pideJugadoresMeta = const VerificationMeta(
    'pideJugadores',
  );
  @override
  late final GeneratedColumn<String> pideJugadores = GeneratedColumn<String>(
    'pide_jugadores',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ofreceJugadoresMeta = const VerificationMeta(
    'ofreceJugadores',
  );
  @override
  late final GeneratedColumn<String> ofreceJugadores = GeneratedColumn<String>(
    'ofrece_jugadores',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ofrecePicksMeta = const VerificationMeta(
    'ofrecePicks',
  );
  @override
  late final GeneratedColumn<String> ofrecePicks = GeneratedColumn<String>(
    'ofrece_picks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vistaMeta = const VerificationMeta('vista');
  @override
  late final GeneratedColumn<bool> vista = GeneratedColumn<bool>(
    'vista',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vista" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    equipoOfertante,
    pideJugadores,
    ofreceJugadores,
    ofrecePicks,
    fecha,
    vista,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ofertas_traspaso';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfertaTraspaso> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('equipo_ofertante')) {
      context.handle(
        _equipoOfertanteMeta,
        equipoOfertante.isAcceptableOrUnknown(
          data['equipo_ofertante']!,
          _equipoOfertanteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipoOfertanteMeta);
    }
    if (data.containsKey('pide_jugadores')) {
      context.handle(
        _pideJugadoresMeta,
        pideJugadores.isAcceptableOrUnknown(
          data['pide_jugadores']!,
          _pideJugadoresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pideJugadoresMeta);
    }
    if (data.containsKey('ofrece_jugadores')) {
      context.handle(
        _ofreceJugadoresMeta,
        ofreceJugadores.isAcceptableOrUnknown(
          data['ofrece_jugadores']!,
          _ofreceJugadoresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ofreceJugadoresMeta);
    }
    if (data.containsKey('ofrece_picks')) {
      context.handle(
        _ofrecePicksMeta,
        ofrecePicks.isAcceptableOrUnknown(
          data['ofrece_picks']!,
          _ofrecePicksMeta,
        ),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('vista')) {
      context.handle(
        _vistaMeta,
        vista.isAcceptableOrUnknown(data['vista']!, _vistaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfertaTraspaso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfertaTraspaso(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      equipoOfertante: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_ofertante'],
      )!,
      pideJugadores: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pide_jugadores'],
      )!,
      ofreceJugadores: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ofrece_jugadores'],
      )!,
      ofrecePicks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ofrece_picks'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      vista: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vista'],
      )!,
    );
  }

  @override
  $OfertasTraspasoTable createAlias(String alias) {
    return $OfertasTraspasoTable(attachedDatabase, alias);
  }
}

class OfertaTraspaso extends DataClass implements Insertable<OfertaTraspaso> {
  final int id;
  final String equipoOfertante;
  final String pideJugadores;
  final String ofreceJugadores;
  final String ofrecePicks;
  final DateTime fecha;
  final bool vista;
  const OfertaTraspaso({
    required this.id,
    required this.equipoOfertante,
    required this.pideJugadores,
    required this.ofreceJugadores,
    required this.ofrecePicks,
    required this.fecha,
    required this.vista,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['equipo_ofertante'] = Variable<String>(equipoOfertante);
    map['pide_jugadores'] = Variable<String>(pideJugadores);
    map['ofrece_jugadores'] = Variable<String>(ofreceJugadores);
    map['ofrece_picks'] = Variable<String>(ofrecePicks);
    map['fecha'] = Variable<DateTime>(fecha);
    map['vista'] = Variable<bool>(vista);
    return map;
  }

  OfertasTraspasoCompanion toCompanion(bool nullToAbsent) {
    return OfertasTraspasoCompanion(
      id: Value(id),
      equipoOfertante: Value(equipoOfertante),
      pideJugadores: Value(pideJugadores),
      ofreceJugadores: Value(ofreceJugadores),
      ofrecePicks: Value(ofrecePicks),
      fecha: Value(fecha),
      vista: Value(vista),
    );
  }

  factory OfertaTraspaso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfertaTraspaso(
      id: serializer.fromJson<int>(json['id']),
      equipoOfertante: serializer.fromJson<String>(json['equipoOfertante']),
      pideJugadores: serializer.fromJson<String>(json['pideJugadores']),
      ofreceJugadores: serializer.fromJson<String>(json['ofreceJugadores']),
      ofrecePicks: serializer.fromJson<String>(json['ofrecePicks']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      vista: serializer.fromJson<bool>(json['vista']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'equipoOfertante': serializer.toJson<String>(equipoOfertante),
      'pideJugadores': serializer.toJson<String>(pideJugadores),
      'ofreceJugadores': serializer.toJson<String>(ofreceJugadores),
      'ofrecePicks': serializer.toJson<String>(ofrecePicks),
      'fecha': serializer.toJson<DateTime>(fecha),
      'vista': serializer.toJson<bool>(vista),
    };
  }

  OfertaTraspaso copyWith({
    int? id,
    String? equipoOfertante,
    String? pideJugadores,
    String? ofreceJugadores,
    String? ofrecePicks,
    DateTime? fecha,
    bool? vista,
  }) => OfertaTraspaso(
    id: id ?? this.id,
    equipoOfertante: equipoOfertante ?? this.equipoOfertante,
    pideJugadores: pideJugadores ?? this.pideJugadores,
    ofreceJugadores: ofreceJugadores ?? this.ofreceJugadores,
    ofrecePicks: ofrecePicks ?? this.ofrecePicks,
    fecha: fecha ?? this.fecha,
    vista: vista ?? this.vista,
  );
  OfertaTraspaso copyWithCompanion(OfertasTraspasoCompanion data) {
    return OfertaTraspaso(
      id: data.id.present ? data.id.value : this.id,
      equipoOfertante: data.equipoOfertante.present
          ? data.equipoOfertante.value
          : this.equipoOfertante,
      pideJugadores: data.pideJugadores.present
          ? data.pideJugadores.value
          : this.pideJugadores,
      ofreceJugadores: data.ofreceJugadores.present
          ? data.ofreceJugadores.value
          : this.ofreceJugadores,
      ofrecePicks: data.ofrecePicks.present
          ? data.ofrecePicks.value
          : this.ofrecePicks,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      vista: data.vista.present ? data.vista.value : this.vista,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfertaTraspaso(')
          ..write('id: $id, ')
          ..write('equipoOfertante: $equipoOfertante, ')
          ..write('pideJugadores: $pideJugadores, ')
          ..write('ofreceJugadores: $ofreceJugadores, ')
          ..write('ofrecePicks: $ofrecePicks, ')
          ..write('fecha: $fecha, ')
          ..write('vista: $vista')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    equipoOfertante,
    pideJugadores,
    ofreceJugadores,
    ofrecePicks,
    fecha,
    vista,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfertaTraspaso &&
          other.id == this.id &&
          other.equipoOfertante == this.equipoOfertante &&
          other.pideJugadores == this.pideJugadores &&
          other.ofreceJugadores == this.ofreceJugadores &&
          other.ofrecePicks == this.ofrecePicks &&
          other.fecha == this.fecha &&
          other.vista == this.vista);
}

class OfertasTraspasoCompanion extends UpdateCompanion<OfertaTraspaso> {
  final Value<int> id;
  final Value<String> equipoOfertante;
  final Value<String> pideJugadores;
  final Value<String> ofreceJugadores;
  final Value<String> ofrecePicks;
  final Value<DateTime> fecha;
  final Value<bool> vista;
  const OfertasTraspasoCompanion({
    this.id = const Value.absent(),
    this.equipoOfertante = const Value.absent(),
    this.pideJugadores = const Value.absent(),
    this.ofreceJugadores = const Value.absent(),
    this.ofrecePicks = const Value.absent(),
    this.fecha = const Value.absent(),
    this.vista = const Value.absent(),
  });
  OfertasTraspasoCompanion.insert({
    this.id = const Value.absent(),
    required String equipoOfertante,
    required String pideJugadores,
    required String ofreceJugadores,
    this.ofrecePicks = const Value.absent(),
    required DateTime fecha,
    this.vista = const Value.absent(),
  }) : equipoOfertante = Value(equipoOfertante),
       pideJugadores = Value(pideJugadores),
       ofreceJugadores = Value(ofreceJugadores),
       fecha = Value(fecha);
  static Insertable<OfertaTraspaso> custom({
    Expression<int>? id,
    Expression<String>? equipoOfertante,
    Expression<String>? pideJugadores,
    Expression<String>? ofreceJugadores,
    Expression<String>? ofrecePicks,
    Expression<DateTime>? fecha,
    Expression<bool>? vista,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (equipoOfertante != null) 'equipo_ofertante': equipoOfertante,
      if (pideJugadores != null) 'pide_jugadores': pideJugadores,
      if (ofreceJugadores != null) 'ofrece_jugadores': ofreceJugadores,
      if (ofrecePicks != null) 'ofrece_picks': ofrecePicks,
      if (fecha != null) 'fecha': fecha,
      if (vista != null) 'vista': vista,
    });
  }

  OfertasTraspasoCompanion copyWith({
    Value<int>? id,
    Value<String>? equipoOfertante,
    Value<String>? pideJugadores,
    Value<String>? ofreceJugadores,
    Value<String>? ofrecePicks,
    Value<DateTime>? fecha,
    Value<bool>? vista,
  }) {
    return OfertasTraspasoCompanion(
      id: id ?? this.id,
      equipoOfertante: equipoOfertante ?? this.equipoOfertante,
      pideJugadores: pideJugadores ?? this.pideJugadores,
      ofreceJugadores: ofreceJugadores ?? this.ofreceJugadores,
      ofrecePicks: ofrecePicks ?? this.ofrecePicks,
      fecha: fecha ?? this.fecha,
      vista: vista ?? this.vista,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (equipoOfertante.present) {
      map['equipo_ofertante'] = Variable<String>(equipoOfertante.value);
    }
    if (pideJugadores.present) {
      map['pide_jugadores'] = Variable<String>(pideJugadores.value);
    }
    if (ofreceJugadores.present) {
      map['ofrece_jugadores'] = Variable<String>(ofreceJugadores.value);
    }
    if (ofrecePicks.present) {
      map['ofrece_picks'] = Variable<String>(ofrecePicks.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (vista.present) {
      map['vista'] = Variable<bool>(vista.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfertasTraspasoCompanion(')
          ..write('id: $id, ')
          ..write('equipoOfertante: $equipoOfertante, ')
          ..write('pideJugadores: $pideJugadores, ')
          ..write('ofreceJugadores: $ofreceJugadores, ')
          ..write('ofrecePicks: $ofrecePicks, ')
          ..write('fecha: $fecha, ')
          ..write('vista: $vista')
          ..write(')'))
        .toString();
  }
}

class $EntrenadoresTable extends Entrenadores
    with TableInfo<$EntrenadoresTable, Entrenador> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntrenadoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreFicticioMeta = const VerificationMeta(
    'nombreFicticio',
  );
  @override
  late final GeneratedColumn<String> nombreFicticio = GeneratedColumn<String>(
    'nombre_ficticio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreRealMeta = const VerificationMeta(
    'nombreReal',
  );
  @override
  late final GeneratedColumn<String> nombreReal = GeneratedColumn<String>(
    'nombre_real',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipoMeta = const VerificationMeta('equipo');
  @override
  late final GeneratedColumn<String> equipo = GeneratedColumn<String>(
    'equipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _edadMeta = const VerificationMeta('edad');
  @override
  late final GeneratedColumn<int> edad = GeneratedColumn<int>(
    'edad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atrAtaqueMeta = const VerificationMeta(
    'atrAtaque',
  );
  @override
  late final GeneratedColumn<int> atrAtaque = GeneratedColumn<int>(
    'atr_ataque',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atrDefensaMeta = const VerificationMeta(
    'atrDefensa',
  );
  @override
  late final GeneratedColumn<int> atrDefensa = GeneratedColumn<int>(
    'atr_defensa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atrDesarrolloMeta = const VerificationMeta(
    'atrDesarrollo',
  );
  @override
  late final GeneratedColumn<int> atrDesarrollo = GeneratedColumn<int>(
    'atr_desarrollo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anillosMeta = const VerificationMeta(
    'anillos',
  );
  @override
  late final GeneratedColumn<int> anillos = GeneratedColumn<int>(
    'anillos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _premiosMeta = const VerificationMeta(
    'premios',
  );
  @override
  late final GeneratedColumn<int> premios = GeneratedColumn<int>(
    'premios',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _temporadasMeta = const VerificationMeta(
    'temporadas',
  );
  @override
  late final GeneratedColumn<int> temporadas = GeneratedColumn<int>(
    'temporadas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _victoriasMeta = const VerificationMeta(
    'victorias',
  );
  @override
  late final GeneratedColumn<int> victorias = GeneratedColumn<int>(
    'victorias',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _derrotasMeta = const VerificationMeta(
    'derrotas',
  );
  @override
  late final GeneratedColumn<int> derrotas = GeneratedColumn<int>(
    'derrotas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _salarioMeta = const VerificationMeta(
    'salario',
  );
  @override
  late final GeneratedColumn<int> salario = GeneratedColumn<int>(
    'salario',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aniosContratoMeta = const VerificationMeta(
    'aniosContrato',
  );
  @override
  late final GeneratedColumn<int> aniosContrato = GeneratedColumn<int>(
    'anios_contrato',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _equipoQuePagaFiniquitoMeta =
      const VerificationMeta('equipoQuePagaFiniquito');
  @override
  late final GeneratedColumn<String> equipoQuePagaFiniquito =
      GeneratedColumn<String>(
        'equipo_que_paga_finiquito',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _aniosDeFiniquitoMeta = const VerificationMeta(
    'aniosDeFiniquito',
  );
  @override
  late final GeneratedColumn<int> aniosDeFiniquito = GeneratedColumn<int>(
    'anios_de_finiquito',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombreFicticio,
    nombreReal,
    equipo,
    edad,
    atrAtaque,
    atrDefensa,
    atrDesarrollo,
    anillos,
    premios,
    temporadas,
    victorias,
    derrotas,
    salario,
    aniosContrato,
    equipoQuePagaFiniquito,
    aniosDeFiniquito,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entrenadores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entrenador> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre_ficticio')) {
      context.handle(
        _nombreFicticioMeta,
        nombreFicticio.isAcceptableOrUnknown(
          data['nombre_ficticio']!,
          _nombreFicticioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreFicticioMeta);
    }
    if (data.containsKey('nombre_real')) {
      context.handle(
        _nombreRealMeta,
        nombreReal.isAcceptableOrUnknown(data['nombre_real']!, _nombreRealMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreRealMeta);
    }
    if (data.containsKey('equipo')) {
      context.handle(
        _equipoMeta,
        equipo.isAcceptableOrUnknown(data['equipo']!, _equipoMeta),
      );
    } else if (isInserting) {
      context.missing(_equipoMeta);
    }
    if (data.containsKey('edad')) {
      context.handle(
        _edadMeta,
        edad.isAcceptableOrUnknown(data['edad']!, _edadMeta),
      );
    } else if (isInserting) {
      context.missing(_edadMeta);
    }
    if (data.containsKey('atr_ataque')) {
      context.handle(
        _atrAtaqueMeta,
        atrAtaque.isAcceptableOrUnknown(data['atr_ataque']!, _atrAtaqueMeta),
      );
    } else if (isInserting) {
      context.missing(_atrAtaqueMeta);
    }
    if (data.containsKey('atr_defensa')) {
      context.handle(
        _atrDefensaMeta,
        atrDefensa.isAcceptableOrUnknown(data['atr_defensa']!, _atrDefensaMeta),
      );
    } else if (isInserting) {
      context.missing(_atrDefensaMeta);
    }
    if (data.containsKey('atr_desarrollo')) {
      context.handle(
        _atrDesarrolloMeta,
        atrDesarrollo.isAcceptableOrUnknown(
          data['atr_desarrollo']!,
          _atrDesarrolloMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atrDesarrolloMeta);
    }
    if (data.containsKey('anillos')) {
      context.handle(
        _anillosMeta,
        anillos.isAcceptableOrUnknown(data['anillos']!, _anillosMeta),
      );
    }
    if (data.containsKey('premios')) {
      context.handle(
        _premiosMeta,
        premios.isAcceptableOrUnknown(data['premios']!, _premiosMeta),
      );
    }
    if (data.containsKey('temporadas')) {
      context.handle(
        _temporadasMeta,
        temporadas.isAcceptableOrUnknown(data['temporadas']!, _temporadasMeta),
      );
    }
    if (data.containsKey('victorias')) {
      context.handle(
        _victoriasMeta,
        victorias.isAcceptableOrUnknown(data['victorias']!, _victoriasMeta),
      );
    }
    if (data.containsKey('derrotas')) {
      context.handle(
        _derrotasMeta,
        derrotas.isAcceptableOrUnknown(data['derrotas']!, _derrotasMeta),
      );
    }
    if (data.containsKey('salario')) {
      context.handle(
        _salarioMeta,
        salario.isAcceptableOrUnknown(data['salario']!, _salarioMeta),
      );
    }
    if (data.containsKey('anios_contrato')) {
      context.handle(
        _aniosContratoMeta,
        aniosContrato.isAcceptableOrUnknown(
          data['anios_contrato']!,
          _aniosContratoMeta,
        ),
      );
    }
    if (data.containsKey('equipo_que_paga_finiquito')) {
      context.handle(
        _equipoQuePagaFiniquitoMeta,
        equipoQuePagaFiniquito.isAcceptableOrUnknown(
          data['equipo_que_paga_finiquito']!,
          _equipoQuePagaFiniquitoMeta,
        ),
      );
    }
    if (data.containsKey('anios_de_finiquito')) {
      context.handle(
        _aniosDeFiniquitoMeta,
        aniosDeFiniquito.isAcceptableOrUnknown(
          data['anios_de_finiquito']!,
          _aniosDeFiniquitoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entrenador map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entrenador(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombreFicticio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_ficticio'],
      )!,
      nombreReal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_real'],
      )!,
      equipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo'],
      )!,
      edad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edad'],
      )!,
      atrAtaque: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}atr_ataque'],
      )!,
      atrDefensa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}atr_defensa'],
      )!,
      atrDesarrollo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}atr_desarrollo'],
      )!,
      anillos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anillos'],
      )!,
      premios: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}premios'],
      )!,
      temporadas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temporadas'],
      )!,
      victorias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}victorias'],
      )!,
      derrotas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}derrotas'],
      )!,
      salario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salario'],
      )!,
      aniosContrato: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anios_contrato'],
      )!,
      equipoQuePagaFiniquito: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipo_que_paga_finiquito'],
      ),
      aniosDeFiniquito: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anios_de_finiquito'],
      )!,
    );
  }

  @override
  $EntrenadoresTable createAlias(String alias) {
    return $EntrenadoresTable(attachedDatabase, alias);
  }
}

class Entrenador extends DataClass implements Insertable<Entrenador> {
  final int id;
  final String nombreFicticio;
  final String nombreReal;
  final String equipo;
  final int edad;

  /// Las tres facetas, en la misma escala 0-99 que los atributos de un
  /// jugador. Ataque y defensa se notan en cada partido (van al rating de
  /// equipo, ver sim_engine); desarrollo se nota de verano en verano, en lo
  /// que crecen los jóvenes de la plantilla.
  final int atrAtaque;
  final int atrDefensa;
  final int atrDesarrollo;

  /// Palmarés previo a tu partida: anillos y premios de Entrenador del Año
  /// que ya tenía cuando empezaste. Lo que gane contigo se guarda aparte, en
  /// `HistorialCampeones` y `HistorialPremios`.
  final int anillos;
  final int premios;

  /// Temporadas dirigidas antes de tu partida, para poder decir "lleva 22
  /// años en esto" y para que la edad de retiro tenga sentido.
  final int temporadas;

  /// Récord acumulado EN TU PARTIDA, que es lo que sube o baja su cotización
  /// y lo que mira un equipo de la CPU antes de echarle.
  final int victorias;
  final int derrotas;

  /// Su contrato: lo que cobra al año y los años que le quedan (incluido
  /// este). Sale del presupuesto de banquillo, que es aparte del tope
  /// salarial de jugadores (ver entrenadores.dart).
  final int salario;
  final int aniosContrato;

  /// El finiquito: si le has despedido con años por delante, el equipo que
  /// le echó le sigue pagando hasta que se cumpla el contrato.
  ///
  /// Vive aquí y no en una tabla aparte porque es información del contrato
  /// del entrenador, no una entidad nueva — y así no puede quedarse
  /// huérfana si alguien vuelve a firmarle.
  final String? equipoQuePagaFiniquito;
  final int aniosDeFiniquito;
  const Entrenador({
    required this.id,
    required this.nombreFicticio,
    required this.nombreReal,
    required this.equipo,
    required this.edad,
    required this.atrAtaque,
    required this.atrDefensa,
    required this.atrDesarrollo,
    required this.anillos,
    required this.premios,
    required this.temporadas,
    required this.victorias,
    required this.derrotas,
    required this.salario,
    required this.aniosContrato,
    this.equipoQuePagaFiniquito,
    required this.aniosDeFiniquito,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre_ficticio'] = Variable<String>(nombreFicticio);
    map['nombre_real'] = Variable<String>(nombreReal);
    map['equipo'] = Variable<String>(equipo);
    map['edad'] = Variable<int>(edad);
    map['atr_ataque'] = Variable<int>(atrAtaque);
    map['atr_defensa'] = Variable<int>(atrDefensa);
    map['atr_desarrollo'] = Variable<int>(atrDesarrollo);
    map['anillos'] = Variable<int>(anillos);
    map['premios'] = Variable<int>(premios);
    map['temporadas'] = Variable<int>(temporadas);
    map['victorias'] = Variable<int>(victorias);
    map['derrotas'] = Variable<int>(derrotas);
    map['salario'] = Variable<int>(salario);
    map['anios_contrato'] = Variable<int>(aniosContrato);
    if (!nullToAbsent || equipoQuePagaFiniquito != null) {
      map['equipo_que_paga_finiquito'] = Variable<String>(
        equipoQuePagaFiniquito,
      );
    }
    map['anios_de_finiquito'] = Variable<int>(aniosDeFiniquito);
    return map;
  }

  EntrenadoresCompanion toCompanion(bool nullToAbsent) {
    return EntrenadoresCompanion(
      id: Value(id),
      nombreFicticio: Value(nombreFicticio),
      nombreReal: Value(nombreReal),
      equipo: Value(equipo),
      edad: Value(edad),
      atrAtaque: Value(atrAtaque),
      atrDefensa: Value(atrDefensa),
      atrDesarrollo: Value(atrDesarrollo),
      anillos: Value(anillos),
      premios: Value(premios),
      temporadas: Value(temporadas),
      victorias: Value(victorias),
      derrotas: Value(derrotas),
      salario: Value(salario),
      aniosContrato: Value(aniosContrato),
      equipoQuePagaFiniquito: equipoQuePagaFiniquito == null && nullToAbsent
          ? const Value.absent()
          : Value(equipoQuePagaFiniquito),
      aniosDeFiniquito: Value(aniosDeFiniquito),
    );
  }

  factory Entrenador.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entrenador(
      id: serializer.fromJson<int>(json['id']),
      nombreFicticio: serializer.fromJson<String>(json['nombreFicticio']),
      nombreReal: serializer.fromJson<String>(json['nombreReal']),
      equipo: serializer.fromJson<String>(json['equipo']),
      edad: serializer.fromJson<int>(json['edad']),
      atrAtaque: serializer.fromJson<int>(json['atrAtaque']),
      atrDefensa: serializer.fromJson<int>(json['atrDefensa']),
      atrDesarrollo: serializer.fromJson<int>(json['atrDesarrollo']),
      anillos: serializer.fromJson<int>(json['anillos']),
      premios: serializer.fromJson<int>(json['premios']),
      temporadas: serializer.fromJson<int>(json['temporadas']),
      victorias: serializer.fromJson<int>(json['victorias']),
      derrotas: serializer.fromJson<int>(json['derrotas']),
      salario: serializer.fromJson<int>(json['salario']),
      aniosContrato: serializer.fromJson<int>(json['aniosContrato']),
      equipoQuePagaFiniquito: serializer.fromJson<String?>(
        json['equipoQuePagaFiniquito'],
      ),
      aniosDeFiniquito: serializer.fromJson<int>(json['aniosDeFiniquito']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombreFicticio': serializer.toJson<String>(nombreFicticio),
      'nombreReal': serializer.toJson<String>(nombreReal),
      'equipo': serializer.toJson<String>(equipo),
      'edad': serializer.toJson<int>(edad),
      'atrAtaque': serializer.toJson<int>(atrAtaque),
      'atrDefensa': serializer.toJson<int>(atrDefensa),
      'atrDesarrollo': serializer.toJson<int>(atrDesarrollo),
      'anillos': serializer.toJson<int>(anillos),
      'premios': serializer.toJson<int>(premios),
      'temporadas': serializer.toJson<int>(temporadas),
      'victorias': serializer.toJson<int>(victorias),
      'derrotas': serializer.toJson<int>(derrotas),
      'salario': serializer.toJson<int>(salario),
      'aniosContrato': serializer.toJson<int>(aniosContrato),
      'equipoQuePagaFiniquito': serializer.toJson<String?>(
        equipoQuePagaFiniquito,
      ),
      'aniosDeFiniquito': serializer.toJson<int>(aniosDeFiniquito),
    };
  }

  Entrenador copyWith({
    int? id,
    String? nombreFicticio,
    String? nombreReal,
    String? equipo,
    int? edad,
    int? atrAtaque,
    int? atrDefensa,
    int? atrDesarrollo,
    int? anillos,
    int? premios,
    int? temporadas,
    int? victorias,
    int? derrotas,
    int? salario,
    int? aniosContrato,
    Value<String?> equipoQuePagaFiniquito = const Value.absent(),
    int? aniosDeFiniquito,
  }) => Entrenador(
    id: id ?? this.id,
    nombreFicticio: nombreFicticio ?? this.nombreFicticio,
    nombreReal: nombreReal ?? this.nombreReal,
    equipo: equipo ?? this.equipo,
    edad: edad ?? this.edad,
    atrAtaque: atrAtaque ?? this.atrAtaque,
    atrDefensa: atrDefensa ?? this.atrDefensa,
    atrDesarrollo: atrDesarrollo ?? this.atrDesarrollo,
    anillos: anillos ?? this.anillos,
    premios: premios ?? this.premios,
    temporadas: temporadas ?? this.temporadas,
    victorias: victorias ?? this.victorias,
    derrotas: derrotas ?? this.derrotas,
    salario: salario ?? this.salario,
    aniosContrato: aniosContrato ?? this.aniosContrato,
    equipoQuePagaFiniquito: equipoQuePagaFiniquito.present
        ? equipoQuePagaFiniquito.value
        : this.equipoQuePagaFiniquito,
    aniosDeFiniquito: aniosDeFiniquito ?? this.aniosDeFiniquito,
  );
  Entrenador copyWithCompanion(EntrenadoresCompanion data) {
    return Entrenador(
      id: data.id.present ? data.id.value : this.id,
      nombreFicticio: data.nombreFicticio.present
          ? data.nombreFicticio.value
          : this.nombreFicticio,
      nombreReal: data.nombreReal.present
          ? data.nombreReal.value
          : this.nombreReal,
      equipo: data.equipo.present ? data.equipo.value : this.equipo,
      edad: data.edad.present ? data.edad.value : this.edad,
      atrAtaque: data.atrAtaque.present ? data.atrAtaque.value : this.atrAtaque,
      atrDefensa: data.atrDefensa.present
          ? data.atrDefensa.value
          : this.atrDefensa,
      atrDesarrollo: data.atrDesarrollo.present
          ? data.atrDesarrollo.value
          : this.atrDesarrollo,
      anillos: data.anillos.present ? data.anillos.value : this.anillos,
      premios: data.premios.present ? data.premios.value : this.premios,
      temporadas: data.temporadas.present
          ? data.temporadas.value
          : this.temporadas,
      victorias: data.victorias.present ? data.victorias.value : this.victorias,
      derrotas: data.derrotas.present ? data.derrotas.value : this.derrotas,
      salario: data.salario.present ? data.salario.value : this.salario,
      aniosContrato: data.aniosContrato.present
          ? data.aniosContrato.value
          : this.aniosContrato,
      equipoQuePagaFiniquito: data.equipoQuePagaFiniquito.present
          ? data.equipoQuePagaFiniquito.value
          : this.equipoQuePagaFiniquito,
      aniosDeFiniquito: data.aniosDeFiniquito.present
          ? data.aniosDeFiniquito.value
          : this.aniosDeFiniquito,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entrenador(')
          ..write('id: $id, ')
          ..write('nombreFicticio: $nombreFicticio, ')
          ..write('nombreReal: $nombreReal, ')
          ..write('equipo: $equipo, ')
          ..write('edad: $edad, ')
          ..write('atrAtaque: $atrAtaque, ')
          ..write('atrDefensa: $atrDefensa, ')
          ..write('atrDesarrollo: $atrDesarrollo, ')
          ..write('anillos: $anillos, ')
          ..write('premios: $premios, ')
          ..write('temporadas: $temporadas, ')
          ..write('victorias: $victorias, ')
          ..write('derrotas: $derrotas, ')
          ..write('salario: $salario, ')
          ..write('aniosContrato: $aniosContrato, ')
          ..write('equipoQuePagaFiniquito: $equipoQuePagaFiniquito, ')
          ..write('aniosDeFiniquito: $aniosDeFiniquito')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nombreFicticio,
    nombreReal,
    equipo,
    edad,
    atrAtaque,
    atrDefensa,
    atrDesarrollo,
    anillos,
    premios,
    temporadas,
    victorias,
    derrotas,
    salario,
    aniosContrato,
    equipoQuePagaFiniquito,
    aniosDeFiniquito,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entrenador &&
          other.id == this.id &&
          other.nombreFicticio == this.nombreFicticio &&
          other.nombreReal == this.nombreReal &&
          other.equipo == this.equipo &&
          other.edad == this.edad &&
          other.atrAtaque == this.atrAtaque &&
          other.atrDefensa == this.atrDefensa &&
          other.atrDesarrollo == this.atrDesarrollo &&
          other.anillos == this.anillos &&
          other.premios == this.premios &&
          other.temporadas == this.temporadas &&
          other.victorias == this.victorias &&
          other.derrotas == this.derrotas &&
          other.salario == this.salario &&
          other.aniosContrato == this.aniosContrato &&
          other.equipoQuePagaFiniquito == this.equipoQuePagaFiniquito &&
          other.aniosDeFiniquito == this.aniosDeFiniquito);
}

class EntrenadoresCompanion extends UpdateCompanion<Entrenador> {
  final Value<int> id;
  final Value<String> nombreFicticio;
  final Value<String> nombreReal;
  final Value<String> equipo;
  final Value<int> edad;
  final Value<int> atrAtaque;
  final Value<int> atrDefensa;
  final Value<int> atrDesarrollo;
  final Value<int> anillos;
  final Value<int> premios;
  final Value<int> temporadas;
  final Value<int> victorias;
  final Value<int> derrotas;
  final Value<int> salario;
  final Value<int> aniosContrato;
  final Value<String?> equipoQuePagaFiniquito;
  final Value<int> aniosDeFiniquito;
  const EntrenadoresCompanion({
    this.id = const Value.absent(),
    this.nombreFicticio = const Value.absent(),
    this.nombreReal = const Value.absent(),
    this.equipo = const Value.absent(),
    this.edad = const Value.absent(),
    this.atrAtaque = const Value.absent(),
    this.atrDefensa = const Value.absent(),
    this.atrDesarrollo = const Value.absent(),
    this.anillos = const Value.absent(),
    this.premios = const Value.absent(),
    this.temporadas = const Value.absent(),
    this.victorias = const Value.absent(),
    this.derrotas = const Value.absent(),
    this.salario = const Value.absent(),
    this.aniosContrato = const Value.absent(),
    this.equipoQuePagaFiniquito = const Value.absent(),
    this.aniosDeFiniquito = const Value.absent(),
  });
  EntrenadoresCompanion.insert({
    this.id = const Value.absent(),
    required String nombreFicticio,
    required String nombreReal,
    required String equipo,
    required int edad,
    required int atrAtaque,
    required int atrDefensa,
    required int atrDesarrollo,
    this.anillos = const Value.absent(),
    this.premios = const Value.absent(),
    this.temporadas = const Value.absent(),
    this.victorias = const Value.absent(),
    this.derrotas = const Value.absent(),
    this.salario = const Value.absent(),
    this.aniosContrato = const Value.absent(),
    this.equipoQuePagaFiniquito = const Value.absent(),
    this.aniosDeFiniquito = const Value.absent(),
  }) : nombreFicticio = Value(nombreFicticio),
       nombreReal = Value(nombreReal),
       equipo = Value(equipo),
       edad = Value(edad),
       atrAtaque = Value(atrAtaque),
       atrDefensa = Value(atrDefensa),
       atrDesarrollo = Value(atrDesarrollo);
  static Insertable<Entrenador> custom({
    Expression<int>? id,
    Expression<String>? nombreFicticio,
    Expression<String>? nombreReal,
    Expression<String>? equipo,
    Expression<int>? edad,
    Expression<int>? atrAtaque,
    Expression<int>? atrDefensa,
    Expression<int>? atrDesarrollo,
    Expression<int>? anillos,
    Expression<int>? premios,
    Expression<int>? temporadas,
    Expression<int>? victorias,
    Expression<int>? derrotas,
    Expression<int>? salario,
    Expression<int>? aniosContrato,
    Expression<String>? equipoQuePagaFiniquito,
    Expression<int>? aniosDeFiniquito,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreFicticio != null) 'nombre_ficticio': nombreFicticio,
      if (nombreReal != null) 'nombre_real': nombreReal,
      if (equipo != null) 'equipo': equipo,
      if (edad != null) 'edad': edad,
      if (atrAtaque != null) 'atr_ataque': atrAtaque,
      if (atrDefensa != null) 'atr_defensa': atrDefensa,
      if (atrDesarrollo != null) 'atr_desarrollo': atrDesarrollo,
      if (anillos != null) 'anillos': anillos,
      if (premios != null) 'premios': premios,
      if (temporadas != null) 'temporadas': temporadas,
      if (victorias != null) 'victorias': victorias,
      if (derrotas != null) 'derrotas': derrotas,
      if (salario != null) 'salario': salario,
      if (aniosContrato != null) 'anios_contrato': aniosContrato,
      if (equipoQuePagaFiniquito != null)
        'equipo_que_paga_finiquito': equipoQuePagaFiniquito,
      if (aniosDeFiniquito != null) 'anios_de_finiquito': aniosDeFiniquito,
    });
  }

  EntrenadoresCompanion copyWith({
    Value<int>? id,
    Value<String>? nombreFicticio,
    Value<String>? nombreReal,
    Value<String>? equipo,
    Value<int>? edad,
    Value<int>? atrAtaque,
    Value<int>? atrDefensa,
    Value<int>? atrDesarrollo,
    Value<int>? anillos,
    Value<int>? premios,
    Value<int>? temporadas,
    Value<int>? victorias,
    Value<int>? derrotas,
    Value<int>? salario,
    Value<int>? aniosContrato,
    Value<String?>? equipoQuePagaFiniquito,
    Value<int>? aniosDeFiniquito,
  }) {
    return EntrenadoresCompanion(
      id: id ?? this.id,
      nombreFicticio: nombreFicticio ?? this.nombreFicticio,
      nombreReal: nombreReal ?? this.nombreReal,
      equipo: equipo ?? this.equipo,
      edad: edad ?? this.edad,
      atrAtaque: atrAtaque ?? this.atrAtaque,
      atrDefensa: atrDefensa ?? this.atrDefensa,
      atrDesarrollo: atrDesarrollo ?? this.atrDesarrollo,
      anillos: anillos ?? this.anillos,
      premios: premios ?? this.premios,
      temporadas: temporadas ?? this.temporadas,
      victorias: victorias ?? this.victorias,
      derrotas: derrotas ?? this.derrotas,
      salario: salario ?? this.salario,
      aniosContrato: aniosContrato ?? this.aniosContrato,
      equipoQuePagaFiniquito:
          equipoQuePagaFiniquito ?? this.equipoQuePagaFiniquito,
      aniosDeFiniquito: aniosDeFiniquito ?? this.aniosDeFiniquito,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombreFicticio.present) {
      map['nombre_ficticio'] = Variable<String>(nombreFicticio.value);
    }
    if (nombreReal.present) {
      map['nombre_real'] = Variable<String>(nombreReal.value);
    }
    if (equipo.present) {
      map['equipo'] = Variable<String>(equipo.value);
    }
    if (edad.present) {
      map['edad'] = Variable<int>(edad.value);
    }
    if (atrAtaque.present) {
      map['atr_ataque'] = Variable<int>(atrAtaque.value);
    }
    if (atrDefensa.present) {
      map['atr_defensa'] = Variable<int>(atrDefensa.value);
    }
    if (atrDesarrollo.present) {
      map['atr_desarrollo'] = Variable<int>(atrDesarrollo.value);
    }
    if (anillos.present) {
      map['anillos'] = Variable<int>(anillos.value);
    }
    if (premios.present) {
      map['premios'] = Variable<int>(premios.value);
    }
    if (temporadas.present) {
      map['temporadas'] = Variable<int>(temporadas.value);
    }
    if (victorias.present) {
      map['victorias'] = Variable<int>(victorias.value);
    }
    if (derrotas.present) {
      map['derrotas'] = Variable<int>(derrotas.value);
    }
    if (salario.present) {
      map['salario'] = Variable<int>(salario.value);
    }
    if (aniosContrato.present) {
      map['anios_contrato'] = Variable<int>(aniosContrato.value);
    }
    if (equipoQuePagaFiniquito.present) {
      map['equipo_que_paga_finiquito'] = Variable<String>(
        equipoQuePagaFiniquito.value,
      );
    }
    if (aniosDeFiniquito.present) {
      map['anios_de_finiquito'] = Variable<int>(aniosDeFiniquito.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntrenadoresCompanion(')
          ..write('id: $id, ')
          ..write('nombreFicticio: $nombreFicticio, ')
          ..write('nombreReal: $nombreReal, ')
          ..write('equipo: $equipo, ')
          ..write('edad: $edad, ')
          ..write('atrAtaque: $atrAtaque, ')
          ..write('atrDefensa: $atrDefensa, ')
          ..write('atrDesarrollo: $atrDesarrollo, ')
          ..write('anillos: $anillos, ')
          ..write('premios: $premios, ')
          ..write('temporadas: $temporadas, ')
          ..write('victorias: $victorias, ')
          ..write('derrotas: $derrotas, ')
          ..write('salario: $salario, ')
          ..write('aniosContrato: $aniosContrato, ')
          ..write('equipoQuePagaFiniquito: $equipoQuePagaFiniquito, ')
          ..write('aniosDeFiniquito: $aniosDeFiniquito')
          ..write(')'))
        .toString();
  }
}

class $EfectosDeEventoTable extends EfectosDeEvento
    with TableInfo<$EfectosDeEventoTable, EfectosDeEventoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EfectosDeEventoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etiquetaMeta = const VerificationMeta(
    'etiqueta',
  );
  @override
  late final GeneratedColumn<String> etiqueta = GeneratedColumn<String>(
    'etiqueta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _factorMeta = const VerificationMeta('factor');
  @override
  late final GeneratedColumn<double> factor = GeneratedColumn<double>(
    'factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partidosRestantesMeta = const VerificationMeta(
    'partidosRestantes',
  );
  @override
  late final GeneratedColumn<int> partidosRestantes = GeneratedColumn<int>(
    'partidos_restantes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clave,
    etiqueta,
    factor,
    partidosRestantes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'efectos_de_evento';
  @override
  VerificationContext validateIntegrity(
    Insertable<EfectosDeEventoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('etiqueta')) {
      context.handle(
        _etiquetaMeta,
        etiqueta.isAcceptableOrUnknown(data['etiqueta']!, _etiquetaMeta),
      );
    } else if (isInserting) {
      context.missing(_etiquetaMeta);
    }
    if (data.containsKey('factor')) {
      context.handle(
        _factorMeta,
        factor.isAcceptableOrUnknown(data['factor']!, _factorMeta),
      );
    } else if (isInserting) {
      context.missing(_factorMeta);
    }
    if (data.containsKey('partidos_restantes')) {
      context.handle(
        _partidosRestantesMeta,
        partidosRestantes.isAcceptableOrUnknown(
          data['partidos_restantes']!,
          _partidosRestantesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partidosRestantesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EfectosDeEventoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EfectosDeEventoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      etiqueta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etiqueta'],
      )!,
      factor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}factor'],
      )!,
      partidosRestantes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partidos_restantes'],
      )!,
    );
  }

  @override
  $EfectosDeEventoTable createAlias(String alias) {
    return $EfectosDeEventoTable(attachedDatabase, alias);
  }
}

class EfectosDeEventoData extends DataClass
    implements Insertable<EfectosDeEventoData> {
  final int id;

  /// Que evento lo produjo. Solo para poder contarlo; no se usa como clave.
  final String clave;

  /// Como se llama en pantalla ("Buen rollo en el vestuario").
  final String etiqueta;

  /// Multiplicador sobre el estado de forma de cada jugador del equipo.
  final double factor;
  final int partidosRestantes;
  const EfectosDeEventoData({
    required this.id,
    required this.clave,
    required this.etiqueta,
    required this.factor,
    required this.partidosRestantes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['clave'] = Variable<String>(clave);
    map['etiqueta'] = Variable<String>(etiqueta);
    map['factor'] = Variable<double>(factor);
    map['partidos_restantes'] = Variable<int>(partidosRestantes);
    return map;
  }

  EfectosDeEventoCompanion toCompanion(bool nullToAbsent) {
    return EfectosDeEventoCompanion(
      id: Value(id),
      clave: Value(clave),
      etiqueta: Value(etiqueta),
      factor: Value(factor),
      partidosRestantes: Value(partidosRestantes),
    );
  }

  factory EfectosDeEventoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EfectosDeEventoData(
      id: serializer.fromJson<int>(json['id']),
      clave: serializer.fromJson<String>(json['clave']),
      etiqueta: serializer.fromJson<String>(json['etiqueta']),
      factor: serializer.fromJson<double>(json['factor']),
      partidosRestantes: serializer.fromJson<int>(json['partidosRestantes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clave': serializer.toJson<String>(clave),
      'etiqueta': serializer.toJson<String>(etiqueta),
      'factor': serializer.toJson<double>(factor),
      'partidosRestantes': serializer.toJson<int>(partidosRestantes),
    };
  }

  EfectosDeEventoData copyWith({
    int? id,
    String? clave,
    String? etiqueta,
    double? factor,
    int? partidosRestantes,
  }) => EfectosDeEventoData(
    id: id ?? this.id,
    clave: clave ?? this.clave,
    etiqueta: etiqueta ?? this.etiqueta,
    factor: factor ?? this.factor,
    partidosRestantes: partidosRestantes ?? this.partidosRestantes,
  );
  EfectosDeEventoData copyWithCompanion(EfectosDeEventoCompanion data) {
    return EfectosDeEventoData(
      id: data.id.present ? data.id.value : this.id,
      clave: data.clave.present ? data.clave.value : this.clave,
      etiqueta: data.etiqueta.present ? data.etiqueta.value : this.etiqueta,
      factor: data.factor.present ? data.factor.value : this.factor,
      partidosRestantes: data.partidosRestantes.present
          ? data.partidosRestantes.value
          : this.partidosRestantes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EfectosDeEventoData(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('etiqueta: $etiqueta, ')
          ..write('factor: $factor, ')
          ..write('partidosRestantes: $partidosRestantes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, clave, etiqueta, factor, partidosRestantes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EfectosDeEventoData &&
          other.id == this.id &&
          other.clave == this.clave &&
          other.etiqueta == this.etiqueta &&
          other.factor == this.factor &&
          other.partidosRestantes == this.partidosRestantes);
}

class EfectosDeEventoCompanion extends UpdateCompanion<EfectosDeEventoData> {
  final Value<int> id;
  final Value<String> clave;
  final Value<String> etiqueta;
  final Value<double> factor;
  final Value<int> partidosRestantes;
  const EfectosDeEventoCompanion({
    this.id = const Value.absent(),
    this.clave = const Value.absent(),
    this.etiqueta = const Value.absent(),
    this.factor = const Value.absent(),
    this.partidosRestantes = const Value.absent(),
  });
  EfectosDeEventoCompanion.insert({
    this.id = const Value.absent(),
    required String clave,
    required String etiqueta,
    required double factor,
    required int partidosRestantes,
  }) : clave = Value(clave),
       etiqueta = Value(etiqueta),
       factor = Value(factor),
       partidosRestantes = Value(partidosRestantes);
  static Insertable<EfectosDeEventoData> custom({
    Expression<int>? id,
    Expression<String>? clave,
    Expression<String>? etiqueta,
    Expression<double>? factor,
    Expression<int>? partidosRestantes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clave != null) 'clave': clave,
      if (etiqueta != null) 'etiqueta': etiqueta,
      if (factor != null) 'factor': factor,
      if (partidosRestantes != null) 'partidos_restantes': partidosRestantes,
    });
  }

  EfectosDeEventoCompanion copyWith({
    Value<int>? id,
    Value<String>? clave,
    Value<String>? etiqueta,
    Value<double>? factor,
    Value<int>? partidosRestantes,
  }) {
    return EfectosDeEventoCompanion(
      id: id ?? this.id,
      clave: clave ?? this.clave,
      etiqueta: etiqueta ?? this.etiqueta,
      factor: factor ?? this.factor,
      partidosRestantes: partidosRestantes ?? this.partidosRestantes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (etiqueta.present) {
      map['etiqueta'] = Variable<String>(etiqueta.value);
    }
    if (factor.present) {
      map['factor'] = Variable<double>(factor.value);
    }
    if (partidosRestantes.present) {
      map['partidos_restantes'] = Variable<int>(partidosRestantes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EfectosDeEventoCompanion(')
          ..write('id: $id, ')
          ..write('clave: $clave, ')
          ..write('etiqueta: $etiqueta, ')
          ..write('factor: $factor, ')
          ..write('partidosRestantes: $partidosRestantes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JugadoresTable jugadores = $JugadoresTable(this);
  late final $FranquiciaTable franquicia = $FranquiciaTable(this);
  late final $RotacionJugadorTable rotacionJugador = $RotacionJugadorTable(
    this,
  );
  late final $PartidosCalendarioTable partidosCalendario =
      $PartidosCalendarioTable(this);
  late final $EventosTemporadaTable eventosTemporada = $EventosTemporadaTable(
    this,
  );
  late final $LesionesTable lesiones = $LesionesTable(this);
  late final $EstadisticasTemporadaJugadorTable estadisticasTemporadaJugador =
      $EstadisticasTemporadaJugadorTable(this);
  late final $ResultadoTemporadaTable resultadoTemporada =
      $ResultadoTemporadaTable(this);
  late final $PremiosTemporadaTable premiosTemporada = $PremiosTemporadaTable(
    this,
  );
  late final $SeriesPlayoffsTable seriesPlayoffs = $SeriesPlayoffsTable(this);
  late final $AjustesTable ajustes = $AjustesTable(this);
  late final $HistorialCampeonesTable historialCampeones =
      $HistorialCampeonesTable(this);
  late final $IstTemporadaTable istTemporada = $IstTemporadaTable(this);
  late final $SeriesTorneoTable seriesTorneo = $SeriesTorneoTable(this);
  late final $BoxscoresSerieTable boxscoresSerie = $BoxscoresSerieTable(this);
  late final $FormaTemporadaJugadorTable formaTemporadaJugador =
      $FormaTemporadaJugadorTable(this);
  late final $TemporadaTable temporada = $TemporadaTable(this);
  late final $HistorialTemporadaEquipoTable historialTemporadaEquipo =
      $HistorialTemporadaEquipoTable(this);
  late final $HistorialPremiosTable historialPremios = $HistorialPremiosTable(
    this,
  );
  late final $HistorialEstadisticasJugadorTable historialEstadisticasJugador =
      $HistorialEstadisticasJugadorTable(this);
  late final $CamisetasRetiradasTable camisetasRetiradas =
      $CamisetasRetiradasTable(this);
  late final $HallDeLaFamaTable hallDeLaFama = $HallDeLaFamaTable(this);
  late final $DraftEnCursoTable draftEnCurso = $DraftEnCursoTable(this);
  late final $PicksDraftTable picksDraft = $PicksDraftTable(this);
  late final $OfertasTraspasoTable ofertasTraspaso = $OfertasTraspasoTable(
    this,
  );
  late final $EntrenadoresTable entrenadores = $EntrenadoresTable(this);
  late final $EfectosDeEventoTable efectosDeEvento = $EfectosDeEventoTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jugadores,
    franquicia,
    rotacionJugador,
    partidosCalendario,
    eventosTemporada,
    lesiones,
    estadisticasTemporadaJugador,
    resultadoTemporada,
    premiosTemporada,
    seriesPlayoffs,
    ajustes,
    historialCampeones,
    istTemporada,
    seriesTorneo,
    boxscoresSerie,
    formaTemporadaJugador,
    temporada,
    historialTemporadaEquipo,
    historialPremios,
    historialEstadisticasJugador,
    camisetasRetiradas,
    hallDeLaFama,
    draftEnCurso,
    picksDraft,
    ofertasTraspaso,
    entrenadores,
    efectosDeEvento,
  ];
}

typedef $$JugadoresTableCreateCompanionBuilder =
    JugadoresCompanion Function({
      Value<int> id,
      required String nombreFicticio,
      required String nombreReal,
      required String posicion,
      Value<String?> posicionSecundaria,
      required String equipo,
      required int edad,
      required int media,
      required int potencial,
      required int atrTiro3,
      required int atrAtaque,
      required int atrDefensa,
      required double ptsPg,
      required double astPg,
      required double trbPg,
      required double factorLongevidad,
      required int edadRetiro,
      Value<int?> draftYear,
      Value<bool> retirado,
      Value<int?> dorsal,
      Value<int> temporadasPrevias,
      Value<int> salario,
      Value<int> aniosContrato,
      Value<int> ofertasRechazadas,
      Value<double> prestigioPrevio,
    });
typedef $$JugadoresTableUpdateCompanionBuilder =
    JugadoresCompanion Function({
      Value<int> id,
      Value<String> nombreFicticio,
      Value<String> nombreReal,
      Value<String> posicion,
      Value<String?> posicionSecundaria,
      Value<String> equipo,
      Value<int> edad,
      Value<int> media,
      Value<int> potencial,
      Value<int> atrTiro3,
      Value<int> atrAtaque,
      Value<int> atrDefensa,
      Value<double> ptsPg,
      Value<double> astPg,
      Value<double> trbPg,
      Value<double> factorLongevidad,
      Value<int> edadRetiro,
      Value<int?> draftYear,
      Value<bool> retirado,
      Value<int?> dorsal,
      Value<int> temporadasPrevias,
      Value<int> salario,
      Value<int> aniosContrato,
      Value<int> ofertasRechazadas,
      Value<double> prestigioPrevio,
    });

class $$JugadoresTableFilterComposer
    extends Composer<_$AppDatabase, $JugadoresTable> {
  $$JugadoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreFicticio => $composableBuilder(
    column: $table.nombreFicticio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreReal => $composableBuilder(
    column: $table.nombreReal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posicion => $composableBuilder(
    column: $table.posicion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posicionSecundaria => $composableBuilder(
    column: $table.posicionSecundaria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get edad => $composableBuilder(
    column: $table.edad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get media => $composableBuilder(
    column: $table.media,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get potencial => $composableBuilder(
    column: $table.potencial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atrTiro3 => $composableBuilder(
    column: $table.atrTiro3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atrAtaque => $composableBuilder(
    column: $table.atrAtaque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atrDefensa => $composableBuilder(
    column: $table.atrDefensa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ptsPg => $composableBuilder(
    column: $table.ptsPg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get astPg => $composableBuilder(
    column: $table.astPg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get trbPg => $composableBuilder(
    column: $table.trbPg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get factorLongevidad => $composableBuilder(
    column: $table.factorLongevidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get edadRetiro => $composableBuilder(
    column: $table.edadRetiro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get draftYear => $composableBuilder(
    column: $table.draftYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get retirado => $composableBuilder(
    column: $table.retirado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dorsal => $composableBuilder(
    column: $table.dorsal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporadasPrevias => $composableBuilder(
    column: $table.temporadasPrevias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salario => $composableBuilder(
    column: $table.salario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aniosContrato => $composableBuilder(
    column: $table.aniosContrato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ofertasRechazadas => $composableBuilder(
    column: $table.ofertasRechazadas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prestigioPrevio => $composableBuilder(
    column: $table.prestigioPrevio,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JugadoresTableOrderingComposer
    extends Composer<_$AppDatabase, $JugadoresTable> {
  $$JugadoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreFicticio => $composableBuilder(
    column: $table.nombreFicticio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreReal => $composableBuilder(
    column: $table.nombreReal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posicion => $composableBuilder(
    column: $table.posicion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posicionSecundaria => $composableBuilder(
    column: $table.posicionSecundaria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get edad => $composableBuilder(
    column: $table.edad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get media => $composableBuilder(
    column: $table.media,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get potencial => $composableBuilder(
    column: $table.potencial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atrTiro3 => $composableBuilder(
    column: $table.atrTiro3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atrAtaque => $composableBuilder(
    column: $table.atrAtaque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atrDefensa => $composableBuilder(
    column: $table.atrDefensa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ptsPg => $composableBuilder(
    column: $table.ptsPg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get astPg => $composableBuilder(
    column: $table.astPg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get trbPg => $composableBuilder(
    column: $table.trbPg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get factorLongevidad => $composableBuilder(
    column: $table.factorLongevidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get edadRetiro => $composableBuilder(
    column: $table.edadRetiro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get draftYear => $composableBuilder(
    column: $table.draftYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get retirado => $composableBuilder(
    column: $table.retirado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dorsal => $composableBuilder(
    column: $table.dorsal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporadasPrevias => $composableBuilder(
    column: $table.temporadasPrevias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salario => $composableBuilder(
    column: $table.salario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aniosContrato => $composableBuilder(
    column: $table.aniosContrato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ofertasRechazadas => $composableBuilder(
    column: $table.ofertasRechazadas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prestigioPrevio => $composableBuilder(
    column: $table.prestigioPrevio,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JugadoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $JugadoresTable> {
  $$JugadoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreFicticio => $composableBuilder(
    column: $table.nombreFicticio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombreReal => $composableBuilder(
    column: $table.nombreReal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get posicion =>
      $composableBuilder(column: $table.posicion, builder: (column) => column);

  GeneratedColumn<String> get posicionSecundaria => $composableBuilder(
    column: $table.posicionSecundaria,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);

  GeneratedColumn<int> get edad =>
      $composableBuilder(column: $table.edad, builder: (column) => column);

  GeneratedColumn<int> get media =>
      $composableBuilder(column: $table.media, builder: (column) => column);

  GeneratedColumn<int> get potencial =>
      $composableBuilder(column: $table.potencial, builder: (column) => column);

  GeneratedColumn<int> get atrTiro3 =>
      $composableBuilder(column: $table.atrTiro3, builder: (column) => column);

  GeneratedColumn<int> get atrAtaque =>
      $composableBuilder(column: $table.atrAtaque, builder: (column) => column);

  GeneratedColumn<int> get atrDefensa => $composableBuilder(
    column: $table.atrDefensa,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ptsPg =>
      $composableBuilder(column: $table.ptsPg, builder: (column) => column);

  GeneratedColumn<double> get astPg =>
      $composableBuilder(column: $table.astPg, builder: (column) => column);

  GeneratedColumn<double> get trbPg =>
      $composableBuilder(column: $table.trbPg, builder: (column) => column);

  GeneratedColumn<double> get factorLongevidad => $composableBuilder(
    column: $table.factorLongevidad,
    builder: (column) => column,
  );

  GeneratedColumn<int> get edadRetiro => $composableBuilder(
    column: $table.edadRetiro,
    builder: (column) => column,
  );

  GeneratedColumn<int> get draftYear =>
      $composableBuilder(column: $table.draftYear, builder: (column) => column);

  GeneratedColumn<bool> get retirado =>
      $composableBuilder(column: $table.retirado, builder: (column) => column);

  GeneratedColumn<int> get dorsal =>
      $composableBuilder(column: $table.dorsal, builder: (column) => column);

  GeneratedColumn<int> get temporadasPrevias => $composableBuilder(
    column: $table.temporadasPrevias,
    builder: (column) => column,
  );

  GeneratedColumn<int> get salario =>
      $composableBuilder(column: $table.salario, builder: (column) => column);

  GeneratedColumn<int> get aniosContrato => $composableBuilder(
    column: $table.aniosContrato,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ofertasRechazadas => $composableBuilder(
    column: $table.ofertasRechazadas,
    builder: (column) => column,
  );

  GeneratedColumn<double> get prestigioPrevio => $composableBuilder(
    column: $table.prestigioPrevio,
    builder: (column) => column,
  );
}

class $$JugadoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JugadoresTable,
          Jugador,
          $$JugadoresTableFilterComposer,
          $$JugadoresTableOrderingComposer,
          $$JugadoresTableAnnotationComposer,
          $$JugadoresTableCreateCompanionBuilder,
          $$JugadoresTableUpdateCompanionBuilder,
          (Jugador, BaseReferences<_$AppDatabase, $JugadoresTable, Jugador>),
          Jugador,
          PrefetchHooks Function()
        > {
  $$JugadoresTableTableManager(_$AppDatabase db, $JugadoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JugadoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JugadoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JugadoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombreFicticio = const Value.absent(),
                Value<String> nombreReal = const Value.absent(),
                Value<String> posicion = const Value.absent(),
                Value<String?> posicionSecundaria = const Value.absent(),
                Value<String> equipo = const Value.absent(),
                Value<int> edad = const Value.absent(),
                Value<int> media = const Value.absent(),
                Value<int> potencial = const Value.absent(),
                Value<int> atrTiro3 = const Value.absent(),
                Value<int> atrAtaque = const Value.absent(),
                Value<int> atrDefensa = const Value.absent(),
                Value<double> ptsPg = const Value.absent(),
                Value<double> astPg = const Value.absent(),
                Value<double> trbPg = const Value.absent(),
                Value<double> factorLongevidad = const Value.absent(),
                Value<int> edadRetiro = const Value.absent(),
                Value<int?> draftYear = const Value.absent(),
                Value<bool> retirado = const Value.absent(),
                Value<int?> dorsal = const Value.absent(),
                Value<int> temporadasPrevias = const Value.absent(),
                Value<int> salario = const Value.absent(),
                Value<int> aniosContrato = const Value.absent(),
                Value<int> ofertasRechazadas = const Value.absent(),
                Value<double> prestigioPrevio = const Value.absent(),
              }) => JugadoresCompanion(
                id: id,
                nombreFicticio: nombreFicticio,
                nombreReal: nombreReal,
                posicion: posicion,
                posicionSecundaria: posicionSecundaria,
                equipo: equipo,
                edad: edad,
                media: media,
                potencial: potencial,
                atrTiro3: atrTiro3,
                atrAtaque: atrAtaque,
                atrDefensa: atrDefensa,
                ptsPg: ptsPg,
                astPg: astPg,
                trbPg: trbPg,
                factorLongevidad: factorLongevidad,
                edadRetiro: edadRetiro,
                draftYear: draftYear,
                retirado: retirado,
                dorsal: dorsal,
                temporadasPrevias: temporadasPrevias,
                salario: salario,
                aniosContrato: aniosContrato,
                ofertasRechazadas: ofertasRechazadas,
                prestigioPrevio: prestigioPrevio,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombreFicticio,
                required String nombreReal,
                required String posicion,
                Value<String?> posicionSecundaria = const Value.absent(),
                required String equipo,
                required int edad,
                required int media,
                required int potencial,
                required int atrTiro3,
                required int atrAtaque,
                required int atrDefensa,
                required double ptsPg,
                required double astPg,
                required double trbPg,
                required double factorLongevidad,
                required int edadRetiro,
                Value<int?> draftYear = const Value.absent(),
                Value<bool> retirado = const Value.absent(),
                Value<int?> dorsal = const Value.absent(),
                Value<int> temporadasPrevias = const Value.absent(),
                Value<int> salario = const Value.absent(),
                Value<int> aniosContrato = const Value.absent(),
                Value<int> ofertasRechazadas = const Value.absent(),
                Value<double> prestigioPrevio = const Value.absent(),
              }) => JugadoresCompanion.insert(
                id: id,
                nombreFicticio: nombreFicticio,
                nombreReal: nombreReal,
                posicion: posicion,
                posicionSecundaria: posicionSecundaria,
                equipo: equipo,
                edad: edad,
                media: media,
                potencial: potencial,
                atrTiro3: atrTiro3,
                atrAtaque: atrAtaque,
                atrDefensa: atrDefensa,
                ptsPg: ptsPg,
                astPg: astPg,
                trbPg: trbPg,
                factorLongevidad: factorLongevidad,
                edadRetiro: edadRetiro,
                draftYear: draftYear,
                retirado: retirado,
                dorsal: dorsal,
                temporadasPrevias: temporadasPrevias,
                salario: salario,
                aniosContrato: aniosContrato,
                ofertasRechazadas: ofertasRechazadas,
                prestigioPrevio: prestigioPrevio,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JugadoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JugadoresTable,
      Jugador,
      $$JugadoresTableFilterComposer,
      $$JugadoresTableOrderingComposer,
      $$JugadoresTableAnnotationComposer,
      $$JugadoresTableCreateCompanionBuilder,
      $$JugadoresTableUpdateCompanionBuilder,
      (Jugador, BaseReferences<_$AppDatabase, $JugadoresTable, Jugador>),
      Jugador,
      PrefetchHooks Function()
    >;
typedef $$FranquiciaTableCreateCompanionBuilder =
    FranquiciaCompanion Function({Value<int> id, required String equipo});
typedef $$FranquiciaTableUpdateCompanionBuilder =
    FranquiciaCompanion Function({Value<int> id, Value<String> equipo});

class $$FranquiciaTableFilterComposer
    extends Composer<_$AppDatabase, $FranquiciaTable> {
  $$FranquiciaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FranquiciaTableOrderingComposer
    extends Composer<_$AppDatabase, $FranquiciaTable> {
  $$FranquiciaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FranquiciaTableAnnotationComposer
    extends Composer<_$AppDatabase, $FranquiciaTable> {
  $$FranquiciaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);
}

class $$FranquiciaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FranquiciaTable,
          FranquiciaData,
          $$FranquiciaTableFilterComposer,
          $$FranquiciaTableOrderingComposer,
          $$FranquiciaTableAnnotationComposer,
          $$FranquiciaTableCreateCompanionBuilder,
          $$FranquiciaTableUpdateCompanionBuilder,
          (
            FranquiciaData,
            BaseReferences<_$AppDatabase, $FranquiciaTable, FranquiciaData>,
          ),
          FranquiciaData,
          PrefetchHooks Function()
        > {
  $$FranquiciaTableTableManager(_$AppDatabase db, $FranquiciaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FranquiciaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FranquiciaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FranquiciaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> equipo = const Value.absent(),
              }) => FranquiciaCompanion(id: id, equipo: equipo),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String equipo,
              }) => FranquiciaCompanion.insert(id: id, equipo: equipo),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FranquiciaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FranquiciaTable,
      FranquiciaData,
      $$FranquiciaTableFilterComposer,
      $$FranquiciaTableOrderingComposer,
      $$FranquiciaTableAnnotationComposer,
      $$FranquiciaTableCreateCompanionBuilder,
      $$FranquiciaTableUpdateCompanionBuilder,
      (
        FranquiciaData,
        BaseReferences<_$AppDatabase, $FranquiciaTable, FranquiciaData>,
      ),
      FranquiciaData,
      PrefetchHooks Function()
    >;
typedef $$RotacionJugadorTableCreateCompanionBuilder =
    RotacionJugadorCompanion Function({
      Value<int> id,
      required String posicion,
      required bool esTitular,
      required int jugadorId,
      required int minutos,
      Value<bool> esEstrellaAtaque,
      Value<bool> esEstrellaDefensa,
    });
typedef $$RotacionJugadorTableUpdateCompanionBuilder =
    RotacionJugadorCompanion Function({
      Value<int> id,
      Value<String> posicion,
      Value<bool> esTitular,
      Value<int> jugadorId,
      Value<int> minutos,
      Value<bool> esEstrellaAtaque,
      Value<bool> esEstrellaDefensa,
    });

class $$RotacionJugadorTableFilterComposer
    extends Composer<_$AppDatabase, $RotacionJugadorTable> {
  $$RotacionJugadorTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posicion => $composableBuilder(
    column: $table.posicion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esTitular => $composableBuilder(
    column: $table.esTitular,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutos => $composableBuilder(
    column: $table.minutos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esEstrellaAtaque => $composableBuilder(
    column: $table.esEstrellaAtaque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esEstrellaDefensa => $composableBuilder(
    column: $table.esEstrellaDefensa,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RotacionJugadorTableOrderingComposer
    extends Composer<_$AppDatabase, $RotacionJugadorTable> {
  $$RotacionJugadorTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posicion => $composableBuilder(
    column: $table.posicion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esTitular => $composableBuilder(
    column: $table.esTitular,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutos => $composableBuilder(
    column: $table.minutos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esEstrellaAtaque => $composableBuilder(
    column: $table.esEstrellaAtaque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esEstrellaDefensa => $composableBuilder(
    column: $table.esEstrellaDefensa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RotacionJugadorTableAnnotationComposer
    extends Composer<_$AppDatabase, $RotacionJugadorTable> {
  $$RotacionJugadorTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get posicion =>
      $composableBuilder(column: $table.posicion, builder: (column) => column);

  GeneratedColumn<bool> get esTitular =>
      $composableBuilder(column: $table.esTitular, builder: (column) => column);

  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);

  GeneratedColumn<int> get minutos =>
      $composableBuilder(column: $table.minutos, builder: (column) => column);

  GeneratedColumn<bool> get esEstrellaAtaque => $composableBuilder(
    column: $table.esEstrellaAtaque,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get esEstrellaDefensa => $composableBuilder(
    column: $table.esEstrellaDefensa,
    builder: (column) => column,
  );
}

class $$RotacionJugadorTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RotacionJugadorTable,
          RotacionJugadorData,
          $$RotacionJugadorTableFilterComposer,
          $$RotacionJugadorTableOrderingComposer,
          $$RotacionJugadorTableAnnotationComposer,
          $$RotacionJugadorTableCreateCompanionBuilder,
          $$RotacionJugadorTableUpdateCompanionBuilder,
          (
            RotacionJugadorData,
            BaseReferences<
              _$AppDatabase,
              $RotacionJugadorTable,
              RotacionJugadorData
            >,
          ),
          RotacionJugadorData,
          PrefetchHooks Function()
        > {
  $$RotacionJugadorTableTableManager(
    _$AppDatabase db,
    $RotacionJugadorTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RotacionJugadorTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RotacionJugadorTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RotacionJugadorTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> posicion = const Value.absent(),
                Value<bool> esTitular = const Value.absent(),
                Value<int> jugadorId = const Value.absent(),
                Value<int> minutos = const Value.absent(),
                Value<bool> esEstrellaAtaque = const Value.absent(),
                Value<bool> esEstrellaDefensa = const Value.absent(),
              }) => RotacionJugadorCompanion(
                id: id,
                posicion: posicion,
                esTitular: esTitular,
                jugadorId: jugadorId,
                minutos: minutos,
                esEstrellaAtaque: esEstrellaAtaque,
                esEstrellaDefensa: esEstrellaDefensa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String posicion,
                required bool esTitular,
                required int jugadorId,
                required int minutos,
                Value<bool> esEstrellaAtaque = const Value.absent(),
                Value<bool> esEstrellaDefensa = const Value.absent(),
              }) => RotacionJugadorCompanion.insert(
                id: id,
                posicion: posicion,
                esTitular: esTitular,
                jugadorId: jugadorId,
                minutos: minutos,
                esEstrellaAtaque: esEstrellaAtaque,
                esEstrellaDefensa: esEstrellaDefensa,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RotacionJugadorTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RotacionJugadorTable,
      RotacionJugadorData,
      $$RotacionJugadorTableFilterComposer,
      $$RotacionJugadorTableOrderingComposer,
      $$RotacionJugadorTableAnnotationComposer,
      $$RotacionJugadorTableCreateCompanionBuilder,
      $$RotacionJugadorTableUpdateCompanionBuilder,
      (
        RotacionJugadorData,
        BaseReferences<
          _$AppDatabase,
          $RotacionJugadorTable,
          RotacionJugadorData
        >,
      ),
      RotacionJugadorData,
      PrefetchHooks Function()
    >;
typedef $$PartidosCalendarioTableCreateCompanionBuilder =
    PartidosCalendarioCompanion Function({
      Value<int> id,
      required String equipoPropietario,
      required DateTime fecha,
      required String rival,
      required bool esLocal,
      Value<bool> jugado,
      Value<bool> esTorneoTemporada,
      Value<String> fase,
      Value<int?> marcadorPropietario,
      Value<int?> marcadorRival,
    });
typedef $$PartidosCalendarioTableUpdateCompanionBuilder =
    PartidosCalendarioCompanion Function({
      Value<int> id,
      Value<String> equipoPropietario,
      Value<DateTime> fecha,
      Value<String> rival,
      Value<bool> esLocal,
      Value<bool> jugado,
      Value<bool> esTorneoTemporada,
      Value<String> fase,
      Value<int?> marcadorPropietario,
      Value<int?> marcadorRival,
    });

class $$PartidosCalendarioTableFilterComposer
    extends Composer<_$AppDatabase, $PartidosCalendarioTable> {
  $$PartidosCalendarioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoPropietario => $composableBuilder(
    column: $table.equipoPropietario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rival => $composableBuilder(
    column: $table.rival,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esLocal => $composableBuilder(
    column: $table.esLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get jugado => $composableBuilder(
    column: $table.jugado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esTorneoTemporada => $composableBuilder(
    column: $table.esTorneoTemporada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fase => $composableBuilder(
    column: $table.fase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get marcadorPropietario => $composableBuilder(
    column: $table.marcadorPropietario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get marcadorRival => $composableBuilder(
    column: $table.marcadorRival,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartidosCalendarioTableOrderingComposer
    extends Composer<_$AppDatabase, $PartidosCalendarioTable> {
  $$PartidosCalendarioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoPropietario => $composableBuilder(
    column: $table.equipoPropietario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rival => $composableBuilder(
    column: $table.rival,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esLocal => $composableBuilder(
    column: $table.esLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get jugado => $composableBuilder(
    column: $table.jugado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esTorneoTemporada => $composableBuilder(
    column: $table.esTorneoTemporada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fase => $composableBuilder(
    column: $table.fase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marcadorPropietario => $composableBuilder(
    column: $table.marcadorPropietario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get marcadorRival => $composableBuilder(
    column: $table.marcadorRival,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartidosCalendarioTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartidosCalendarioTable> {
  $$PartidosCalendarioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get equipoPropietario => $composableBuilder(
    column: $table.equipoPropietario,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get rival =>
      $composableBuilder(column: $table.rival, builder: (column) => column);

  GeneratedColumn<bool> get esLocal =>
      $composableBuilder(column: $table.esLocal, builder: (column) => column);

  GeneratedColumn<bool> get jugado =>
      $composableBuilder(column: $table.jugado, builder: (column) => column);

  GeneratedColumn<bool> get esTorneoTemporada => $composableBuilder(
    column: $table.esTorneoTemporada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fase =>
      $composableBuilder(column: $table.fase, builder: (column) => column);

  GeneratedColumn<int> get marcadorPropietario => $composableBuilder(
    column: $table.marcadorPropietario,
    builder: (column) => column,
  );

  GeneratedColumn<int> get marcadorRival => $composableBuilder(
    column: $table.marcadorRival,
    builder: (column) => column,
  );
}

class $$PartidosCalendarioTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartidosCalendarioTable,
          PartidosCalendarioData,
          $$PartidosCalendarioTableFilterComposer,
          $$PartidosCalendarioTableOrderingComposer,
          $$PartidosCalendarioTableAnnotationComposer,
          $$PartidosCalendarioTableCreateCompanionBuilder,
          $$PartidosCalendarioTableUpdateCompanionBuilder,
          (
            PartidosCalendarioData,
            BaseReferences<
              _$AppDatabase,
              $PartidosCalendarioTable,
              PartidosCalendarioData
            >,
          ),
          PartidosCalendarioData,
          PrefetchHooks Function()
        > {
  $$PartidosCalendarioTableTableManager(
    _$AppDatabase db,
    $PartidosCalendarioTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartidosCalendarioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartidosCalendarioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartidosCalendarioTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> equipoPropietario = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> rival = const Value.absent(),
                Value<bool> esLocal = const Value.absent(),
                Value<bool> jugado = const Value.absent(),
                Value<bool> esTorneoTemporada = const Value.absent(),
                Value<String> fase = const Value.absent(),
                Value<int?> marcadorPropietario = const Value.absent(),
                Value<int?> marcadorRival = const Value.absent(),
              }) => PartidosCalendarioCompanion(
                id: id,
                equipoPropietario: equipoPropietario,
                fecha: fecha,
                rival: rival,
                esLocal: esLocal,
                jugado: jugado,
                esTorneoTemporada: esTorneoTemporada,
                fase: fase,
                marcadorPropietario: marcadorPropietario,
                marcadorRival: marcadorRival,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String equipoPropietario,
                required DateTime fecha,
                required String rival,
                required bool esLocal,
                Value<bool> jugado = const Value.absent(),
                Value<bool> esTorneoTemporada = const Value.absent(),
                Value<String> fase = const Value.absent(),
                Value<int?> marcadorPropietario = const Value.absent(),
                Value<int?> marcadorRival = const Value.absent(),
              }) => PartidosCalendarioCompanion.insert(
                id: id,
                equipoPropietario: equipoPropietario,
                fecha: fecha,
                rival: rival,
                esLocal: esLocal,
                jugado: jugado,
                esTorneoTemporada: esTorneoTemporada,
                fase: fase,
                marcadorPropietario: marcadorPropietario,
                marcadorRival: marcadorRival,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartidosCalendarioTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartidosCalendarioTable,
      PartidosCalendarioData,
      $$PartidosCalendarioTableFilterComposer,
      $$PartidosCalendarioTableOrderingComposer,
      $$PartidosCalendarioTableAnnotationComposer,
      $$PartidosCalendarioTableCreateCompanionBuilder,
      $$PartidosCalendarioTableUpdateCompanionBuilder,
      (
        PartidosCalendarioData,
        BaseReferences<
          _$AppDatabase,
          $PartidosCalendarioTable,
          PartidosCalendarioData
        >,
      ),
      PartidosCalendarioData,
      PrefetchHooks Function()
    >;
typedef $$EventosTemporadaTableCreateCompanionBuilder =
    EventosTemporadaCompanion Function({
      Value<int> id,
      required DateTime fecha,
      required String tipo,
    });
typedef $$EventosTemporadaTableUpdateCompanionBuilder =
    EventosTemporadaCompanion Function({
      Value<int> id,
      Value<DateTime> fecha,
      Value<String> tipo,
    });

class $$EventosTemporadaTableFilterComposer
    extends Composer<_$AppDatabase, $EventosTemporadaTable> {
  $$EventosTemporadaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventosTemporadaTableOrderingComposer
    extends Composer<_$AppDatabase, $EventosTemporadaTable> {
  $$EventosTemporadaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventosTemporadaTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventosTemporadaTable> {
  $$EventosTemporadaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);
}

class $$EventosTemporadaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventosTemporadaTable,
          EventosTemporadaData,
          $$EventosTemporadaTableFilterComposer,
          $$EventosTemporadaTableOrderingComposer,
          $$EventosTemporadaTableAnnotationComposer,
          $$EventosTemporadaTableCreateCompanionBuilder,
          $$EventosTemporadaTableUpdateCompanionBuilder,
          (
            EventosTemporadaData,
            BaseReferences<
              _$AppDatabase,
              $EventosTemporadaTable,
              EventosTemporadaData
            >,
          ),
          EventosTemporadaData,
          PrefetchHooks Function()
        > {
  $$EventosTemporadaTableTableManager(
    _$AppDatabase db,
    $EventosTemporadaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosTemporadaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosTemporadaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosTemporadaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> tipo = const Value.absent(),
              }) => EventosTemporadaCompanion(id: id, fecha: fecha, tipo: tipo),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime fecha,
                required String tipo,
              }) => EventosTemporadaCompanion.insert(
                id: id,
                fecha: fecha,
                tipo: tipo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventosTemporadaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventosTemporadaTable,
      EventosTemporadaData,
      $$EventosTemporadaTableFilterComposer,
      $$EventosTemporadaTableOrderingComposer,
      $$EventosTemporadaTableAnnotationComposer,
      $$EventosTemporadaTableCreateCompanionBuilder,
      $$EventosTemporadaTableUpdateCompanionBuilder,
      (
        EventosTemporadaData,
        BaseReferences<
          _$AppDatabase,
          $EventosTemporadaTable,
          EventosTemporadaData
        >,
      ),
      EventosTemporadaData,
      PrefetchHooks Function()
    >;
typedef $$LesionesTableCreateCompanionBuilder =
    LesionesCompanion Function({
      Value<int> id,
      required int jugadorId,
      required DateTime fechaFin,
      required String gravedad,
      Value<String> motivo,
      Value<int> partidosEstimados,
    });
typedef $$LesionesTableUpdateCompanionBuilder =
    LesionesCompanion Function({
      Value<int> id,
      Value<int> jugadorId,
      Value<DateTime> fechaFin,
      Value<String> gravedad,
      Value<String> motivo,
      Value<int> partidosEstimados,
    });

class $$LesionesTableFilterComposer
    extends Composer<_$AppDatabase, $LesionesTable> {
  $$LesionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaFin => $composableBuilder(
    column: $table.fechaFin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gravedad => $composableBuilder(
    column: $table.gravedad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partidosEstimados => $composableBuilder(
    column: $table.partidosEstimados,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LesionesTableOrderingComposer
    extends Composer<_$AppDatabase, $LesionesTable> {
  $$LesionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaFin => $composableBuilder(
    column: $table.fechaFin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gravedad => $composableBuilder(
    column: $table.gravedad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partidosEstimados => $composableBuilder(
    column: $table.partidosEstimados,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LesionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LesionesTable> {
  $$LesionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaFin =>
      $composableBuilder(column: $table.fechaFin, builder: (column) => column);

  GeneratedColumn<String> get gravedad =>
      $composableBuilder(column: $table.gravedad, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<int> get partidosEstimados => $composableBuilder(
    column: $table.partidosEstimados,
    builder: (column) => column,
  );
}

class $$LesionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LesionesTable,
          Lesion,
          $$LesionesTableFilterComposer,
          $$LesionesTableOrderingComposer,
          $$LesionesTableAnnotationComposer,
          $$LesionesTableCreateCompanionBuilder,
          $$LesionesTableUpdateCompanionBuilder,
          (Lesion, BaseReferences<_$AppDatabase, $LesionesTable, Lesion>),
          Lesion,
          PrefetchHooks Function()
        > {
  $$LesionesTableTableManager(_$AppDatabase db, $LesionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LesionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LesionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LesionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jugadorId = const Value.absent(),
                Value<DateTime> fechaFin = const Value.absent(),
                Value<String> gravedad = const Value.absent(),
                Value<String> motivo = const Value.absent(),
                Value<int> partidosEstimados = const Value.absent(),
              }) => LesionesCompanion(
                id: id,
                jugadorId: jugadorId,
                fechaFin: fechaFin,
                gravedad: gravedad,
                motivo: motivo,
                partidosEstimados: partidosEstimados,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jugadorId,
                required DateTime fechaFin,
                required String gravedad,
                Value<String> motivo = const Value.absent(),
                Value<int> partidosEstimados = const Value.absent(),
              }) => LesionesCompanion.insert(
                id: id,
                jugadorId: jugadorId,
                fechaFin: fechaFin,
                gravedad: gravedad,
                motivo: motivo,
                partidosEstimados: partidosEstimados,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LesionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LesionesTable,
      Lesion,
      $$LesionesTableFilterComposer,
      $$LesionesTableOrderingComposer,
      $$LesionesTableAnnotationComposer,
      $$LesionesTableCreateCompanionBuilder,
      $$LesionesTableUpdateCompanionBuilder,
      (Lesion, BaseReferences<_$AppDatabase, $LesionesTable, Lesion>),
      Lesion,
      PrefetchHooks Function()
    >;
typedef $$EstadisticasTemporadaJugadorTableCreateCompanionBuilder =
    EstadisticasTemporadaJugadorCompanion Function({
      Value<int> jugadorId,
      Value<int> partidosJugados,
      Value<int> puntosTotales,
      Value<int> asistenciasTotales,
      Value<int> rebotesTotales,
    });
typedef $$EstadisticasTemporadaJugadorTableUpdateCompanionBuilder =
    EstadisticasTemporadaJugadorCompanion Function({
      Value<int> jugadorId,
      Value<int> partidosJugados,
      Value<int> puntosTotales,
      Value<int> asistenciasTotales,
      Value<int> rebotesTotales,
    });

class $$EstadisticasTemporadaJugadorTableFilterComposer
    extends Composer<_$AppDatabase, $EstadisticasTemporadaJugadorTable> {
  $$EstadisticasTemporadaJugadorTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partidosJugados => $composableBuilder(
    column: $table.partidosJugados,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get puntosTotales => $composableBuilder(
    column: $table.puntosTotales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get asistenciasTotales => $composableBuilder(
    column: $table.asistenciasTotales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rebotesTotales => $composableBuilder(
    column: $table.rebotesTotales,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EstadisticasTemporadaJugadorTableOrderingComposer
    extends Composer<_$AppDatabase, $EstadisticasTemporadaJugadorTable> {
  $$EstadisticasTemporadaJugadorTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partidosJugados => $composableBuilder(
    column: $table.partidosJugados,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get puntosTotales => $composableBuilder(
    column: $table.puntosTotales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get asistenciasTotales => $composableBuilder(
    column: $table.asistenciasTotales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rebotesTotales => $composableBuilder(
    column: $table.rebotesTotales,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EstadisticasTemporadaJugadorTableAnnotationComposer
    extends Composer<_$AppDatabase, $EstadisticasTemporadaJugadorTable> {
  $$EstadisticasTemporadaJugadorTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);

  GeneratedColumn<int> get partidosJugados => $composableBuilder(
    column: $table.partidosJugados,
    builder: (column) => column,
  );

  GeneratedColumn<int> get puntosTotales => $composableBuilder(
    column: $table.puntosTotales,
    builder: (column) => column,
  );

  GeneratedColumn<int> get asistenciasTotales => $composableBuilder(
    column: $table.asistenciasTotales,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rebotesTotales => $composableBuilder(
    column: $table.rebotesTotales,
    builder: (column) => column,
  );
}

class $$EstadisticasTemporadaJugadorTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EstadisticasTemporadaJugadorTable,
          EstadisticasTemporadaJugadorData,
          $$EstadisticasTemporadaJugadorTableFilterComposer,
          $$EstadisticasTemporadaJugadorTableOrderingComposer,
          $$EstadisticasTemporadaJugadorTableAnnotationComposer,
          $$EstadisticasTemporadaJugadorTableCreateCompanionBuilder,
          $$EstadisticasTemporadaJugadorTableUpdateCompanionBuilder,
          (
            EstadisticasTemporadaJugadorData,
            BaseReferences<
              _$AppDatabase,
              $EstadisticasTemporadaJugadorTable,
              EstadisticasTemporadaJugadorData
            >,
          ),
          EstadisticasTemporadaJugadorData,
          PrefetchHooks Function()
        > {
  $$EstadisticasTemporadaJugadorTableTableManager(
    _$AppDatabase db,
    $EstadisticasTemporadaJugadorTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EstadisticasTemporadaJugadorTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EstadisticasTemporadaJugadorTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EstadisticasTemporadaJugadorTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> jugadorId = const Value.absent(),
                Value<int> partidosJugados = const Value.absent(),
                Value<int> puntosTotales = const Value.absent(),
                Value<int> asistenciasTotales = const Value.absent(),
                Value<int> rebotesTotales = const Value.absent(),
              }) => EstadisticasTemporadaJugadorCompanion(
                jugadorId: jugadorId,
                partidosJugados: partidosJugados,
                puntosTotales: puntosTotales,
                asistenciasTotales: asistenciasTotales,
                rebotesTotales: rebotesTotales,
              ),
          createCompanionCallback:
              ({
                Value<int> jugadorId = const Value.absent(),
                Value<int> partidosJugados = const Value.absent(),
                Value<int> puntosTotales = const Value.absent(),
                Value<int> asistenciasTotales = const Value.absent(),
                Value<int> rebotesTotales = const Value.absent(),
              }) => EstadisticasTemporadaJugadorCompanion.insert(
                jugadorId: jugadorId,
                partidosJugados: partidosJugados,
                puntosTotales: puntosTotales,
                asistenciasTotales: asistenciasTotales,
                rebotesTotales: rebotesTotales,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EstadisticasTemporadaJugadorTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EstadisticasTemporadaJugadorTable,
      EstadisticasTemporadaJugadorData,
      $$EstadisticasTemporadaJugadorTableFilterComposer,
      $$EstadisticasTemporadaJugadorTableOrderingComposer,
      $$EstadisticasTemporadaJugadorTableAnnotationComposer,
      $$EstadisticasTemporadaJugadorTableCreateCompanionBuilder,
      $$EstadisticasTemporadaJugadorTableUpdateCompanionBuilder,
      (
        EstadisticasTemporadaJugadorData,
        BaseReferences<
          _$AppDatabase,
          $EstadisticasTemporadaJugadorTable,
          EstadisticasTemporadaJugadorData
        >,
      ),
      EstadisticasTemporadaJugadorData,
      PrefetchHooks Function()
    >;
typedef $$ResultadoTemporadaTableCreateCompanionBuilder =
    ResultadoTemporadaCompanion Function({
      required String equipo,
      Value<int> victorias,
      Value<int> derrotas,
      Value<int> rowid,
    });
typedef $$ResultadoTemporadaTableUpdateCompanionBuilder =
    ResultadoTemporadaCompanion Function({
      Value<String> equipo,
      Value<int> victorias,
      Value<int> derrotas,
      Value<int> rowid,
    });

class $$ResultadoTemporadaTableFilterComposer
    extends Composer<_$AppDatabase, $ResultadoTemporadaTable> {
  $$ResultadoTemporadaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get victorias => $composableBuilder(
    column: $table.victorias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get derrotas => $composableBuilder(
    column: $table.derrotas,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResultadoTemporadaTableOrderingComposer
    extends Composer<_$AppDatabase, $ResultadoTemporadaTable> {
  $$ResultadoTemporadaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get victorias => $composableBuilder(
    column: $table.victorias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get derrotas => $composableBuilder(
    column: $table.derrotas,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResultadoTemporadaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResultadoTemporadaTable> {
  $$ResultadoTemporadaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);

  GeneratedColumn<int> get victorias =>
      $composableBuilder(column: $table.victorias, builder: (column) => column);

  GeneratedColumn<int> get derrotas =>
      $composableBuilder(column: $table.derrotas, builder: (column) => column);
}

class $$ResultadoTemporadaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResultadoTemporadaTable,
          ResultadoTemporadaData,
          $$ResultadoTemporadaTableFilterComposer,
          $$ResultadoTemporadaTableOrderingComposer,
          $$ResultadoTemporadaTableAnnotationComposer,
          $$ResultadoTemporadaTableCreateCompanionBuilder,
          $$ResultadoTemporadaTableUpdateCompanionBuilder,
          (
            ResultadoTemporadaData,
            BaseReferences<
              _$AppDatabase,
              $ResultadoTemporadaTable,
              ResultadoTemporadaData
            >,
          ),
          ResultadoTemporadaData,
          PrefetchHooks Function()
        > {
  $$ResultadoTemporadaTableTableManager(
    _$AppDatabase db,
    $ResultadoTemporadaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResultadoTemporadaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResultadoTemporadaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResultadoTemporadaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> equipo = const Value.absent(),
                Value<int> victorias = const Value.absent(),
                Value<int> derrotas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResultadoTemporadaCompanion(
                equipo: equipo,
                victorias: victorias,
                derrotas: derrotas,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String equipo,
                Value<int> victorias = const Value.absent(),
                Value<int> derrotas = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResultadoTemporadaCompanion.insert(
                equipo: equipo,
                victorias: victorias,
                derrotas: derrotas,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResultadoTemporadaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResultadoTemporadaTable,
      ResultadoTemporadaData,
      $$ResultadoTemporadaTableFilterComposer,
      $$ResultadoTemporadaTableOrderingComposer,
      $$ResultadoTemporadaTableAnnotationComposer,
      $$ResultadoTemporadaTableCreateCompanionBuilder,
      $$ResultadoTemporadaTableUpdateCompanionBuilder,
      (
        ResultadoTemporadaData,
        BaseReferences<
          _$AppDatabase,
          $ResultadoTemporadaTable,
          ResultadoTemporadaData
        >,
      ),
      ResultadoTemporadaData,
      PrefetchHooks Function()
    >;
typedef $$PremiosTemporadaTableCreateCompanionBuilder =
    PremiosTemporadaCompanion Function({
      Value<int> id,
      required String tipo,
      required int jugadorId,
    });
typedef $$PremiosTemporadaTableUpdateCompanionBuilder =
    PremiosTemporadaCompanion Function({
      Value<int> id,
      Value<String> tipo,
      Value<int> jugadorId,
    });

class $$PremiosTemporadaTableFilterComposer
    extends Composer<_$AppDatabase, $PremiosTemporadaTable> {
  $$PremiosTemporadaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PremiosTemporadaTableOrderingComposer
    extends Composer<_$AppDatabase, $PremiosTemporadaTable> {
  $$PremiosTemporadaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PremiosTemporadaTableAnnotationComposer
    extends Composer<_$AppDatabase, $PremiosTemporadaTable> {
  $$PremiosTemporadaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);
}

class $$PremiosTemporadaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PremiosTemporadaTable,
          PremiosTemporadaData,
          $$PremiosTemporadaTableFilterComposer,
          $$PremiosTemporadaTableOrderingComposer,
          $$PremiosTemporadaTableAnnotationComposer,
          $$PremiosTemporadaTableCreateCompanionBuilder,
          $$PremiosTemporadaTableUpdateCompanionBuilder,
          (
            PremiosTemporadaData,
            BaseReferences<
              _$AppDatabase,
              $PremiosTemporadaTable,
              PremiosTemporadaData
            >,
          ),
          PremiosTemporadaData,
          PrefetchHooks Function()
        > {
  $$PremiosTemporadaTableTableManager(
    _$AppDatabase db,
    $PremiosTemporadaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PremiosTemporadaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PremiosTemporadaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PremiosTemporadaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int> jugadorId = const Value.absent(),
              }) => PremiosTemporadaCompanion(
                id: id,
                tipo: tipo,
                jugadorId: jugadorId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipo,
                required int jugadorId,
              }) => PremiosTemporadaCompanion.insert(
                id: id,
                tipo: tipo,
                jugadorId: jugadorId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PremiosTemporadaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PremiosTemporadaTable,
      PremiosTemporadaData,
      $$PremiosTemporadaTableFilterComposer,
      $$PremiosTemporadaTableOrderingComposer,
      $$PremiosTemporadaTableAnnotationComposer,
      $$PremiosTemporadaTableCreateCompanionBuilder,
      $$PremiosTemporadaTableUpdateCompanionBuilder,
      (
        PremiosTemporadaData,
        BaseReferences<
          _$AppDatabase,
          $PremiosTemporadaTable,
          PremiosTemporadaData
        >,
      ),
      PremiosTemporadaData,
      PrefetchHooks Function()
    >;
typedef $$SeriesPlayoffsTableCreateCompanionBuilder =
    SeriesPlayoffsCompanion Function({
      Value<int> id,
      required String conferencia,
      required int ronda,
      required String etapa,
      required String equipoA,
      required String equipoB,
      required int seedA,
      required int seedB,
      Value<int> victoriasA,
      Value<int> victoriasB,
      Value<int> victoriasNecesarias,
      Value<String?> ganador,
    });
typedef $$SeriesPlayoffsTableUpdateCompanionBuilder =
    SeriesPlayoffsCompanion Function({
      Value<int> id,
      Value<String> conferencia,
      Value<int> ronda,
      Value<String> etapa,
      Value<String> equipoA,
      Value<String> equipoB,
      Value<int> seedA,
      Value<int> seedB,
      Value<int> victoriasA,
      Value<int> victoriasB,
      Value<int> victoriasNecesarias,
      Value<String?> ganador,
    });

class $$SeriesPlayoffsTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesPlayoffsTable> {
  $$SeriesPlayoffsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conferencia => $composableBuilder(
    column: $table.conferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ronda => $composableBuilder(
    column: $table.ronda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etapa => $composableBuilder(
    column: $table.etapa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoA => $composableBuilder(
    column: $table.equipoA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoB => $composableBuilder(
    column: $table.equipoB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seedA => $composableBuilder(
    column: $table.seedA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seedB => $composableBuilder(
    column: $table.seedB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get victoriasA => $composableBuilder(
    column: $table.victoriasA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get victoriasB => $composableBuilder(
    column: $table.victoriasB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get victoriasNecesarias => $composableBuilder(
    column: $table.victoriasNecesarias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ganador => $composableBuilder(
    column: $table.ganador,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesPlayoffsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesPlayoffsTable> {
  $$SeriesPlayoffsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conferencia => $composableBuilder(
    column: $table.conferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ronda => $composableBuilder(
    column: $table.ronda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etapa => $composableBuilder(
    column: $table.etapa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoA => $composableBuilder(
    column: $table.equipoA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoB => $composableBuilder(
    column: $table.equipoB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seedA => $composableBuilder(
    column: $table.seedA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seedB => $composableBuilder(
    column: $table.seedB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get victoriasA => $composableBuilder(
    column: $table.victoriasA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get victoriasB => $composableBuilder(
    column: $table.victoriasB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get victoriasNecesarias => $composableBuilder(
    column: $table.victoriasNecesarias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ganador => $composableBuilder(
    column: $table.ganador,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesPlayoffsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesPlayoffsTable> {
  $$SeriesPlayoffsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conferencia => $composableBuilder(
    column: $table.conferencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ronda =>
      $composableBuilder(column: $table.ronda, builder: (column) => column);

  GeneratedColumn<String> get etapa =>
      $composableBuilder(column: $table.etapa, builder: (column) => column);

  GeneratedColumn<String> get equipoA =>
      $composableBuilder(column: $table.equipoA, builder: (column) => column);

  GeneratedColumn<String> get equipoB =>
      $composableBuilder(column: $table.equipoB, builder: (column) => column);

  GeneratedColumn<int> get seedA =>
      $composableBuilder(column: $table.seedA, builder: (column) => column);

  GeneratedColumn<int> get seedB =>
      $composableBuilder(column: $table.seedB, builder: (column) => column);

  GeneratedColumn<int> get victoriasA => $composableBuilder(
    column: $table.victoriasA,
    builder: (column) => column,
  );

  GeneratedColumn<int> get victoriasB => $composableBuilder(
    column: $table.victoriasB,
    builder: (column) => column,
  );

  GeneratedColumn<int> get victoriasNecesarias => $composableBuilder(
    column: $table.victoriasNecesarias,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ganador =>
      $composableBuilder(column: $table.ganador, builder: (column) => column);
}

class $$SeriesPlayoffsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesPlayoffsTable,
          Serie,
          $$SeriesPlayoffsTableFilterComposer,
          $$SeriesPlayoffsTableOrderingComposer,
          $$SeriesPlayoffsTableAnnotationComposer,
          $$SeriesPlayoffsTableCreateCompanionBuilder,
          $$SeriesPlayoffsTableUpdateCompanionBuilder,
          (Serie, BaseReferences<_$AppDatabase, $SeriesPlayoffsTable, Serie>),
          Serie,
          PrefetchHooks Function()
        > {
  $$SeriesPlayoffsTableTableManager(
    _$AppDatabase db,
    $SeriesPlayoffsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesPlayoffsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesPlayoffsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesPlayoffsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> conferencia = const Value.absent(),
                Value<int> ronda = const Value.absent(),
                Value<String> etapa = const Value.absent(),
                Value<String> equipoA = const Value.absent(),
                Value<String> equipoB = const Value.absent(),
                Value<int> seedA = const Value.absent(),
                Value<int> seedB = const Value.absent(),
                Value<int> victoriasA = const Value.absent(),
                Value<int> victoriasB = const Value.absent(),
                Value<int> victoriasNecesarias = const Value.absent(),
                Value<String?> ganador = const Value.absent(),
              }) => SeriesPlayoffsCompanion(
                id: id,
                conferencia: conferencia,
                ronda: ronda,
                etapa: etapa,
                equipoA: equipoA,
                equipoB: equipoB,
                seedA: seedA,
                seedB: seedB,
                victoriasA: victoriasA,
                victoriasB: victoriasB,
                victoriasNecesarias: victoriasNecesarias,
                ganador: ganador,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String conferencia,
                required int ronda,
                required String etapa,
                required String equipoA,
                required String equipoB,
                required int seedA,
                required int seedB,
                Value<int> victoriasA = const Value.absent(),
                Value<int> victoriasB = const Value.absent(),
                Value<int> victoriasNecesarias = const Value.absent(),
                Value<String?> ganador = const Value.absent(),
              }) => SeriesPlayoffsCompanion.insert(
                id: id,
                conferencia: conferencia,
                ronda: ronda,
                etapa: etapa,
                equipoA: equipoA,
                equipoB: equipoB,
                seedA: seedA,
                seedB: seedB,
                victoriasA: victoriasA,
                victoriasB: victoriasB,
                victoriasNecesarias: victoriasNecesarias,
                ganador: ganador,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesPlayoffsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesPlayoffsTable,
      Serie,
      $$SeriesPlayoffsTableFilterComposer,
      $$SeriesPlayoffsTableOrderingComposer,
      $$SeriesPlayoffsTableAnnotationComposer,
      $$SeriesPlayoffsTableCreateCompanionBuilder,
      $$SeriesPlayoffsTableUpdateCompanionBuilder,
      (Serie, BaseReferences<_$AppDatabase, $SeriesPlayoffsTable, Serie>),
      Serie,
      PrefetchHooks Function()
    >;
typedef $$AjustesTableCreateCompanionBuilder =
    AjustesCompanion Function({
      Value<int> id,
      Value<bool> modoOscuro,
      Value<String> idioma,
    });
typedef $$AjustesTableUpdateCompanionBuilder =
    AjustesCompanion Function({
      Value<int> id,
      Value<bool> modoOscuro,
      Value<String> idioma,
    });

class $$AjustesTableFilterComposer
    extends Composer<_$AppDatabase, $AjustesTable> {
  $$AjustesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get modoOscuro => $composableBuilder(
    column: $table.modoOscuro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idioma => $composableBuilder(
    column: $table.idioma,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AjustesTableOrderingComposer
    extends Composer<_$AppDatabase, $AjustesTable> {
  $$AjustesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get modoOscuro => $composableBuilder(
    column: $table.modoOscuro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idioma => $composableBuilder(
    column: $table.idioma,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AjustesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AjustesTable> {
  $$AjustesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get modoOscuro => $composableBuilder(
    column: $table.modoOscuro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idioma =>
      $composableBuilder(column: $table.idioma, builder: (column) => column);
}

class $$AjustesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AjustesTable,
          Ajuste,
          $$AjustesTableFilterComposer,
          $$AjustesTableOrderingComposer,
          $$AjustesTableAnnotationComposer,
          $$AjustesTableCreateCompanionBuilder,
          $$AjustesTableUpdateCompanionBuilder,
          (Ajuste, BaseReferences<_$AppDatabase, $AjustesTable, Ajuste>),
          Ajuste,
          PrefetchHooks Function()
        > {
  $$AjustesTableTableManager(_$AppDatabase db, $AjustesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AjustesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AjustesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AjustesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> modoOscuro = const Value.absent(),
                Value<String> idioma = const Value.absent(),
              }) => AjustesCompanion(
                id: id,
                modoOscuro: modoOscuro,
                idioma: idioma,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> modoOscuro = const Value.absent(),
                Value<String> idioma = const Value.absent(),
              }) => AjustesCompanion.insert(
                id: id,
                modoOscuro: modoOscuro,
                idioma: idioma,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AjustesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AjustesTable,
      Ajuste,
      $$AjustesTableFilterComposer,
      $$AjustesTableOrderingComposer,
      $$AjustesTableAnnotationComposer,
      $$AjustesTableCreateCompanionBuilder,
      $$AjustesTableUpdateCompanionBuilder,
      (Ajuste, BaseReferences<_$AppDatabase, $AjustesTable, Ajuste>),
      Ajuste,
      PrefetchHooks Function()
    >;
typedef $$HistorialCampeonesTableCreateCompanionBuilder =
    HistorialCampeonesCompanion Function({
      Value<int> id,
      required String equipo,
      required String tipo,
      required DateTime fecha,
      Value<int> temporada,
      Value<bool> logradoPorUsuario,
    });
typedef $$HistorialCampeonesTableUpdateCompanionBuilder =
    HistorialCampeonesCompanion Function({
      Value<int> id,
      Value<String> equipo,
      Value<String> tipo,
      Value<DateTime> fecha,
      Value<int> temporada,
      Value<bool> logradoPorUsuario,
    });

class $$HistorialCampeonesTableFilterComposer
    extends Composer<_$AppDatabase, $HistorialCampeonesTable> {
  $$HistorialCampeonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get logradoPorUsuario => $composableBuilder(
    column: $table.logradoPorUsuario,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistorialCampeonesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistorialCampeonesTable> {
  $$HistorialCampeonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get logradoPorUsuario => $composableBuilder(
    column: $table.logradoPorUsuario,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistorialCampeonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistorialCampeonesTable> {
  $$HistorialCampeonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get temporada =>
      $composableBuilder(column: $table.temporada, builder: (column) => column);

  GeneratedColumn<bool> get logradoPorUsuario => $composableBuilder(
    column: $table.logradoPorUsuario,
    builder: (column) => column,
  );
}

class $$HistorialCampeonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistorialCampeonesTable,
          Campeonato,
          $$HistorialCampeonesTableFilterComposer,
          $$HistorialCampeonesTableOrderingComposer,
          $$HistorialCampeonesTableAnnotationComposer,
          $$HistorialCampeonesTableCreateCompanionBuilder,
          $$HistorialCampeonesTableUpdateCompanionBuilder,
          (
            Campeonato,
            BaseReferences<_$AppDatabase, $HistorialCampeonesTable, Campeonato>,
          ),
          Campeonato,
          PrefetchHooks Function()
        > {
  $$HistorialCampeonesTableTableManager(
    _$AppDatabase db,
    $HistorialCampeonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistorialCampeonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistorialCampeonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistorialCampeonesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> equipo = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> temporada = const Value.absent(),
                Value<bool> logradoPorUsuario = const Value.absent(),
              }) => HistorialCampeonesCompanion(
                id: id,
                equipo: equipo,
                tipo: tipo,
                fecha: fecha,
                temporada: temporada,
                logradoPorUsuario: logradoPorUsuario,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String equipo,
                required String tipo,
                required DateTime fecha,
                Value<int> temporada = const Value.absent(),
                Value<bool> logradoPorUsuario = const Value.absent(),
              }) => HistorialCampeonesCompanion.insert(
                id: id,
                equipo: equipo,
                tipo: tipo,
                fecha: fecha,
                temporada: temporada,
                logradoPorUsuario: logradoPorUsuario,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistorialCampeonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistorialCampeonesTable,
      Campeonato,
      $$HistorialCampeonesTableFilterComposer,
      $$HistorialCampeonesTableOrderingComposer,
      $$HistorialCampeonesTableAnnotationComposer,
      $$HistorialCampeonesTableCreateCompanionBuilder,
      $$HistorialCampeonesTableUpdateCompanionBuilder,
      (
        Campeonato,
        BaseReferences<_$AppDatabase, $HistorialCampeonesTable, Campeonato>,
      ),
      Campeonato,
      PrefetchHooks Function()
    >;
typedef $$IstTemporadaTableCreateCompanionBuilder =
    IstTemporadaCompanion Function({
      Value<int> id,
      Value<bool> faseGruposActiva,
      Value<bool> campeonAnunciado,
      Value<String?> equipoCampeon,
    });
typedef $$IstTemporadaTableUpdateCompanionBuilder =
    IstTemporadaCompanion Function({
      Value<int> id,
      Value<bool> faseGruposActiva,
      Value<bool> campeonAnunciado,
      Value<String?> equipoCampeon,
    });

class $$IstTemporadaTableFilterComposer
    extends Composer<_$AppDatabase, $IstTemporadaTable> {
  $$IstTemporadaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get faseGruposActiva => $composableBuilder(
    column: $table.faseGruposActiva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get campeonAnunciado => $composableBuilder(
    column: $table.campeonAnunciado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoCampeon => $composableBuilder(
    column: $table.equipoCampeon,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IstTemporadaTableOrderingComposer
    extends Composer<_$AppDatabase, $IstTemporadaTable> {
  $$IstTemporadaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get faseGruposActiva => $composableBuilder(
    column: $table.faseGruposActiva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get campeonAnunciado => $composableBuilder(
    column: $table.campeonAnunciado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoCampeon => $composableBuilder(
    column: $table.equipoCampeon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IstTemporadaTableAnnotationComposer
    extends Composer<_$AppDatabase, $IstTemporadaTable> {
  $$IstTemporadaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get faseGruposActiva => $composableBuilder(
    column: $table.faseGruposActiva,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get campeonAnunciado => $composableBuilder(
    column: $table.campeonAnunciado,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipoCampeon => $composableBuilder(
    column: $table.equipoCampeon,
    builder: (column) => column,
  );
}

class $$IstTemporadaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IstTemporadaTable,
          IstTemporadaData,
          $$IstTemporadaTableFilterComposer,
          $$IstTemporadaTableOrderingComposer,
          $$IstTemporadaTableAnnotationComposer,
          $$IstTemporadaTableCreateCompanionBuilder,
          $$IstTemporadaTableUpdateCompanionBuilder,
          (
            IstTemporadaData,
            BaseReferences<_$AppDatabase, $IstTemporadaTable, IstTemporadaData>,
          ),
          IstTemporadaData,
          PrefetchHooks Function()
        > {
  $$IstTemporadaTableTableManager(_$AppDatabase db, $IstTemporadaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IstTemporadaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IstTemporadaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IstTemporadaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> faseGruposActiva = const Value.absent(),
                Value<bool> campeonAnunciado = const Value.absent(),
                Value<String?> equipoCampeon = const Value.absent(),
              }) => IstTemporadaCompanion(
                id: id,
                faseGruposActiva: faseGruposActiva,
                campeonAnunciado: campeonAnunciado,
                equipoCampeon: equipoCampeon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> faseGruposActiva = const Value.absent(),
                Value<bool> campeonAnunciado = const Value.absent(),
                Value<String?> equipoCampeon = const Value.absent(),
              }) => IstTemporadaCompanion.insert(
                id: id,
                faseGruposActiva: faseGruposActiva,
                campeonAnunciado: campeonAnunciado,
                equipoCampeon: equipoCampeon,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IstTemporadaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IstTemporadaTable,
      IstTemporadaData,
      $$IstTemporadaTableFilterComposer,
      $$IstTemporadaTableOrderingComposer,
      $$IstTemporadaTableAnnotationComposer,
      $$IstTemporadaTableCreateCompanionBuilder,
      $$IstTemporadaTableUpdateCompanionBuilder,
      (
        IstTemporadaData,
        BaseReferences<_$AppDatabase, $IstTemporadaTable, IstTemporadaData>,
      ),
      IstTemporadaData,
      PrefetchHooks Function()
    >;
typedef $$SeriesTorneoTableCreateCompanionBuilder =
    SeriesTorneoCompanion Function({
      Value<int> id,
      required String conferencia,
      required int ronda,
      required String etapa,
      required String equipoA,
      required String equipoB,
      required int seedA,
      required int seedB,
      Value<String?> ganador,
    });
typedef $$SeriesTorneoTableUpdateCompanionBuilder =
    SeriesTorneoCompanion Function({
      Value<int> id,
      Value<String> conferencia,
      Value<int> ronda,
      Value<String> etapa,
      Value<String> equipoA,
      Value<String> equipoB,
      Value<int> seedA,
      Value<int> seedB,
      Value<String?> ganador,
    });

class $$SeriesTorneoTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesTorneoTable> {
  $$SeriesTorneoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conferencia => $composableBuilder(
    column: $table.conferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ronda => $composableBuilder(
    column: $table.ronda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etapa => $composableBuilder(
    column: $table.etapa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoA => $composableBuilder(
    column: $table.equipoA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoB => $composableBuilder(
    column: $table.equipoB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seedA => $composableBuilder(
    column: $table.seedA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seedB => $composableBuilder(
    column: $table.seedB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ganador => $composableBuilder(
    column: $table.ganador,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesTorneoTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesTorneoTable> {
  $$SeriesTorneoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conferencia => $composableBuilder(
    column: $table.conferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ronda => $composableBuilder(
    column: $table.ronda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etapa => $composableBuilder(
    column: $table.etapa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoA => $composableBuilder(
    column: $table.equipoA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoB => $composableBuilder(
    column: $table.equipoB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seedA => $composableBuilder(
    column: $table.seedA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seedB => $composableBuilder(
    column: $table.seedB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ganador => $composableBuilder(
    column: $table.ganador,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesTorneoTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesTorneoTable> {
  $$SeriesTorneoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conferencia => $composableBuilder(
    column: $table.conferencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ronda =>
      $composableBuilder(column: $table.ronda, builder: (column) => column);

  GeneratedColumn<String> get etapa =>
      $composableBuilder(column: $table.etapa, builder: (column) => column);

  GeneratedColumn<String> get equipoA =>
      $composableBuilder(column: $table.equipoA, builder: (column) => column);

  GeneratedColumn<String> get equipoB =>
      $composableBuilder(column: $table.equipoB, builder: (column) => column);

  GeneratedColumn<int> get seedA =>
      $composableBuilder(column: $table.seedA, builder: (column) => column);

  GeneratedColumn<int> get seedB =>
      $composableBuilder(column: $table.seedB, builder: (column) => column);

  GeneratedColumn<String> get ganador =>
      $composableBuilder(column: $table.ganador, builder: (column) => column);
}

class $$SeriesTorneoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesTorneoTable,
          SerieTorneo,
          $$SeriesTorneoTableFilterComposer,
          $$SeriesTorneoTableOrderingComposer,
          $$SeriesTorneoTableAnnotationComposer,
          $$SeriesTorneoTableCreateCompanionBuilder,
          $$SeriesTorneoTableUpdateCompanionBuilder,
          (
            SerieTorneo,
            BaseReferences<_$AppDatabase, $SeriesTorneoTable, SerieTorneo>,
          ),
          SerieTorneo,
          PrefetchHooks Function()
        > {
  $$SeriesTorneoTableTableManager(_$AppDatabase db, $SeriesTorneoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTorneoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTorneoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTorneoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> conferencia = const Value.absent(),
                Value<int> ronda = const Value.absent(),
                Value<String> etapa = const Value.absent(),
                Value<String> equipoA = const Value.absent(),
                Value<String> equipoB = const Value.absent(),
                Value<int> seedA = const Value.absent(),
                Value<int> seedB = const Value.absent(),
                Value<String?> ganador = const Value.absent(),
              }) => SeriesTorneoCompanion(
                id: id,
                conferencia: conferencia,
                ronda: ronda,
                etapa: etapa,
                equipoA: equipoA,
                equipoB: equipoB,
                seedA: seedA,
                seedB: seedB,
                ganador: ganador,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String conferencia,
                required int ronda,
                required String etapa,
                required String equipoA,
                required String equipoB,
                required int seedA,
                required int seedB,
                Value<String?> ganador = const Value.absent(),
              }) => SeriesTorneoCompanion.insert(
                id: id,
                conferencia: conferencia,
                ronda: ronda,
                etapa: etapa,
                equipoA: equipoA,
                equipoB: equipoB,
                seedA: seedA,
                seedB: seedB,
                ganador: ganador,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesTorneoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesTorneoTable,
      SerieTorneo,
      $$SeriesTorneoTableFilterComposer,
      $$SeriesTorneoTableOrderingComposer,
      $$SeriesTorneoTableAnnotationComposer,
      $$SeriesTorneoTableCreateCompanionBuilder,
      $$SeriesTorneoTableUpdateCompanionBuilder,
      (
        SerieTorneo,
        BaseReferences<_$AppDatabase, $SeriesTorneoTable, SerieTorneo>,
      ),
      SerieTorneo,
      PrefetchHooks Function()
    >;
typedef $$BoxscoresSerieTableCreateCompanionBuilder =
    BoxscoresSerieCompanion Function({
      Value<int> id,
      required String origen,
      required int serieId,
      required DateTime fecha,
      required String boxscoreJson,
    });
typedef $$BoxscoresSerieTableUpdateCompanionBuilder =
    BoxscoresSerieCompanion Function({
      Value<int> id,
      Value<String> origen,
      Value<int> serieId,
      Value<DateTime> fecha,
      Value<String> boxscoreJson,
    });

class $$BoxscoresSerieTableFilterComposer
    extends Composer<_$AppDatabase, $BoxscoresSerieTable> {
  $$BoxscoresSerieTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serieId => $composableBuilder(
    column: $table.serieId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boxscoreJson => $composableBuilder(
    column: $table.boxscoreJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BoxscoresSerieTableOrderingComposer
    extends Composer<_$AppDatabase, $BoxscoresSerieTable> {
  $$BoxscoresSerieTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origen => $composableBuilder(
    column: $table.origen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serieId => $composableBuilder(
    column: $table.serieId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boxscoreJson => $composableBuilder(
    column: $table.boxscoreJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BoxscoresSerieTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoxscoresSerieTable> {
  $$BoxscoresSerieTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get origen =>
      $composableBuilder(column: $table.origen, builder: (column) => column);

  GeneratedColumn<int> get serieId =>
      $composableBuilder(column: $table.serieId, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get boxscoreJson => $composableBuilder(
    column: $table.boxscoreJson,
    builder: (column) => column,
  );
}

class $$BoxscoresSerieTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BoxscoresSerieTable,
          BoxscoresSerieData,
          $$BoxscoresSerieTableFilterComposer,
          $$BoxscoresSerieTableOrderingComposer,
          $$BoxscoresSerieTableAnnotationComposer,
          $$BoxscoresSerieTableCreateCompanionBuilder,
          $$BoxscoresSerieTableUpdateCompanionBuilder,
          (
            BoxscoresSerieData,
            BaseReferences<
              _$AppDatabase,
              $BoxscoresSerieTable,
              BoxscoresSerieData
            >,
          ),
          BoxscoresSerieData,
          PrefetchHooks Function()
        > {
  $$BoxscoresSerieTableTableManager(
    _$AppDatabase db,
    $BoxscoresSerieTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoxscoresSerieTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoxscoresSerieTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoxscoresSerieTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> origen = const Value.absent(),
                Value<int> serieId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> boxscoreJson = const Value.absent(),
              }) => BoxscoresSerieCompanion(
                id: id,
                origen: origen,
                serieId: serieId,
                fecha: fecha,
                boxscoreJson: boxscoreJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String origen,
                required int serieId,
                required DateTime fecha,
                required String boxscoreJson,
              }) => BoxscoresSerieCompanion.insert(
                id: id,
                origen: origen,
                serieId: serieId,
                fecha: fecha,
                boxscoreJson: boxscoreJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BoxscoresSerieTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BoxscoresSerieTable,
      BoxscoresSerieData,
      $$BoxscoresSerieTableFilterComposer,
      $$BoxscoresSerieTableOrderingComposer,
      $$BoxscoresSerieTableAnnotationComposer,
      $$BoxscoresSerieTableCreateCompanionBuilder,
      $$BoxscoresSerieTableUpdateCompanionBuilder,
      (
        BoxscoresSerieData,
        BaseReferences<_$AppDatabase, $BoxscoresSerieTable, BoxscoresSerieData>,
      ),
      BoxscoresSerieData,
      PrefetchHooks Function()
    >;
typedef $$FormaTemporadaJugadorTableCreateCompanionBuilder =
    FormaTemporadaJugadorCompanion Function({
      Value<int> jugadorId,
      Value<double> factor,
    });
typedef $$FormaTemporadaJugadorTableUpdateCompanionBuilder =
    FormaTemporadaJugadorCompanion Function({
      Value<int> jugadorId,
      Value<double> factor,
    });

class $$FormaTemporadaJugadorTableFilterComposer
    extends Composer<_$AppDatabase, $FormaTemporadaJugadorTable> {
  $$FormaTemporadaJugadorTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormaTemporadaJugadorTableOrderingComposer
    extends Composer<_$AppDatabase, $FormaTemporadaJugadorTable> {
  $$FormaTemporadaJugadorTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormaTemporadaJugadorTableAnnotationComposer
    extends Composer<_$AppDatabase, $FormaTemporadaJugadorTable> {
  $$FormaTemporadaJugadorTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);

  GeneratedColumn<double> get factor =>
      $composableBuilder(column: $table.factor, builder: (column) => column);
}

class $$FormaTemporadaJugadorTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FormaTemporadaJugadorTable,
          FormaJugador,
          $$FormaTemporadaJugadorTableFilterComposer,
          $$FormaTemporadaJugadorTableOrderingComposer,
          $$FormaTemporadaJugadorTableAnnotationComposer,
          $$FormaTemporadaJugadorTableCreateCompanionBuilder,
          $$FormaTemporadaJugadorTableUpdateCompanionBuilder,
          (
            FormaJugador,
            BaseReferences<
              _$AppDatabase,
              $FormaTemporadaJugadorTable,
              FormaJugador
            >,
          ),
          FormaJugador,
          PrefetchHooks Function()
        > {
  $$FormaTemporadaJugadorTableTableManager(
    _$AppDatabase db,
    $FormaTemporadaJugadorTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormaTemporadaJugadorTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FormaTemporadaJugadorTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FormaTemporadaJugadorTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> jugadorId = const Value.absent(),
                Value<double> factor = const Value.absent(),
              }) => FormaTemporadaJugadorCompanion(
                jugadorId: jugadorId,
                factor: factor,
              ),
          createCompanionCallback:
              ({
                Value<int> jugadorId = const Value.absent(),
                Value<double> factor = const Value.absent(),
              }) => FormaTemporadaJugadorCompanion.insert(
                jugadorId: jugadorId,
                factor: factor,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormaTemporadaJugadorTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FormaTemporadaJugadorTable,
      FormaJugador,
      $$FormaTemporadaJugadorTableFilterComposer,
      $$FormaTemporadaJugadorTableOrderingComposer,
      $$FormaTemporadaJugadorTableAnnotationComposer,
      $$FormaTemporadaJugadorTableCreateCompanionBuilder,
      $$FormaTemporadaJugadorTableUpdateCompanionBuilder,
      (
        FormaJugador,
        BaseReferences<
          _$AppDatabase,
          $FormaTemporadaJugadorTable,
          FormaJugador
        >,
      ),
      FormaJugador,
      PrefetchHooks Function()
    >;
typedef $$TemporadaTableCreateCompanionBuilder =
    TemporadaCompanion Function({
      Value<int> id,
      Value<int> numero,
      required int anioInicio,
      Value<int> ofertasGeneradasEstaTemporada,
      Value<String> eventosVistos,
      Value<int> bonusSalarial,
    });
typedef $$TemporadaTableUpdateCompanionBuilder =
    TemporadaCompanion Function({
      Value<int> id,
      Value<int> numero,
      Value<int> anioInicio,
      Value<int> ofertasGeneradasEstaTemporada,
      Value<String> eventosVistos,
      Value<int> bonusSalarial,
    });

class $$TemporadaTableFilterComposer
    extends Composer<_$AppDatabase, $TemporadaTable> {
  $$TemporadaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anioInicio => $composableBuilder(
    column: $table.anioInicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ofertasGeneradasEstaTemporada => $composableBuilder(
    column: $table.ofertasGeneradasEstaTemporada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventosVistos => $composableBuilder(
    column: $table.eventosVistos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusSalarial => $composableBuilder(
    column: $table.bonusSalarial,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TemporadaTableOrderingComposer
    extends Composer<_$AppDatabase, $TemporadaTable> {
  $$TemporadaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numero => $composableBuilder(
    column: $table.numero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anioInicio => $composableBuilder(
    column: $table.anioInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ofertasGeneradasEstaTemporada => $composableBuilder(
    column: $table.ofertasGeneradasEstaTemporada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventosVistos => $composableBuilder(
    column: $table.eventosVistos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusSalarial => $composableBuilder(
    column: $table.bonusSalarial,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemporadaTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemporadaTable> {
  $$TemporadaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get numero =>
      $composableBuilder(column: $table.numero, builder: (column) => column);

  GeneratedColumn<int> get anioInicio => $composableBuilder(
    column: $table.anioInicio,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ofertasGeneradasEstaTemporada => $composableBuilder(
    column: $table.ofertasGeneradasEstaTemporada,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventosVistos => $composableBuilder(
    column: $table.eventosVistos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonusSalarial => $composableBuilder(
    column: $table.bonusSalarial,
    builder: (column) => column,
  );
}

class $$TemporadaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemporadaTable,
          TemporadaData,
          $$TemporadaTableFilterComposer,
          $$TemporadaTableOrderingComposer,
          $$TemporadaTableAnnotationComposer,
          $$TemporadaTableCreateCompanionBuilder,
          $$TemporadaTableUpdateCompanionBuilder,
          (
            TemporadaData,
            BaseReferences<_$AppDatabase, $TemporadaTable, TemporadaData>,
          ),
          TemporadaData,
          PrefetchHooks Function()
        > {
  $$TemporadaTableTableManager(_$AppDatabase db, $TemporadaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemporadaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemporadaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemporadaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> numero = const Value.absent(),
                Value<int> anioInicio = const Value.absent(),
                Value<int> ofertasGeneradasEstaTemporada = const Value.absent(),
                Value<String> eventosVistos = const Value.absent(),
                Value<int> bonusSalarial = const Value.absent(),
              }) => TemporadaCompanion(
                id: id,
                numero: numero,
                anioInicio: anioInicio,
                ofertasGeneradasEstaTemporada: ofertasGeneradasEstaTemporada,
                eventosVistos: eventosVistos,
                bonusSalarial: bonusSalarial,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> numero = const Value.absent(),
                required int anioInicio,
                Value<int> ofertasGeneradasEstaTemporada = const Value.absent(),
                Value<String> eventosVistos = const Value.absent(),
                Value<int> bonusSalarial = const Value.absent(),
              }) => TemporadaCompanion.insert(
                id: id,
                numero: numero,
                anioInicio: anioInicio,
                ofertasGeneradasEstaTemporada: ofertasGeneradasEstaTemporada,
                eventosVistos: eventosVistos,
                bonusSalarial: bonusSalarial,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TemporadaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemporadaTable,
      TemporadaData,
      $$TemporadaTableFilterComposer,
      $$TemporadaTableOrderingComposer,
      $$TemporadaTableAnnotationComposer,
      $$TemporadaTableCreateCompanionBuilder,
      $$TemporadaTableUpdateCompanionBuilder,
      (
        TemporadaData,
        BaseReferences<_$AppDatabase, $TemporadaTable, TemporadaData>,
      ),
      TemporadaData,
      PrefetchHooks Function()
    >;
typedef $$HistorialTemporadaEquipoTableCreateCompanionBuilder =
    HistorialTemporadaEquipoCompanion Function({
      Value<int> id,
      required int temporada,
      required String equipo,
      required int victorias,
      required int derrotas,
    });
typedef $$HistorialTemporadaEquipoTableUpdateCompanionBuilder =
    HistorialTemporadaEquipoCompanion Function({
      Value<int> id,
      Value<int> temporada,
      Value<String> equipo,
      Value<int> victorias,
      Value<int> derrotas,
    });

class $$HistorialTemporadaEquipoTableFilterComposer
    extends Composer<_$AppDatabase, $HistorialTemporadaEquipoTable> {
  $$HistorialTemporadaEquipoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get victorias => $composableBuilder(
    column: $table.victorias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get derrotas => $composableBuilder(
    column: $table.derrotas,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistorialTemporadaEquipoTableOrderingComposer
    extends Composer<_$AppDatabase, $HistorialTemporadaEquipoTable> {
  $$HistorialTemporadaEquipoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get victorias => $composableBuilder(
    column: $table.victorias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get derrotas => $composableBuilder(
    column: $table.derrotas,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistorialTemporadaEquipoTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistorialTemporadaEquipoTable> {
  $$HistorialTemporadaEquipoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get temporada =>
      $composableBuilder(column: $table.temporada, builder: (column) => column);

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);

  GeneratedColumn<int> get victorias =>
      $composableBuilder(column: $table.victorias, builder: (column) => column);

  GeneratedColumn<int> get derrotas =>
      $composableBuilder(column: $table.derrotas, builder: (column) => column);
}

class $$HistorialTemporadaEquipoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistorialTemporadaEquipoTable,
          RecordHistorico,
          $$HistorialTemporadaEquipoTableFilterComposer,
          $$HistorialTemporadaEquipoTableOrderingComposer,
          $$HistorialTemporadaEquipoTableAnnotationComposer,
          $$HistorialTemporadaEquipoTableCreateCompanionBuilder,
          $$HistorialTemporadaEquipoTableUpdateCompanionBuilder,
          (
            RecordHistorico,
            BaseReferences<
              _$AppDatabase,
              $HistorialTemporadaEquipoTable,
              RecordHistorico
            >,
          ),
          RecordHistorico,
          PrefetchHooks Function()
        > {
  $$HistorialTemporadaEquipoTableTableManager(
    _$AppDatabase db,
    $HistorialTemporadaEquipoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistorialTemporadaEquipoTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HistorialTemporadaEquipoTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HistorialTemporadaEquipoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> temporada = const Value.absent(),
                Value<String> equipo = const Value.absent(),
                Value<int> victorias = const Value.absent(),
                Value<int> derrotas = const Value.absent(),
              }) => HistorialTemporadaEquipoCompanion(
                id: id,
                temporada: temporada,
                equipo: equipo,
                victorias: victorias,
                derrotas: derrotas,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int temporada,
                required String equipo,
                required int victorias,
                required int derrotas,
              }) => HistorialTemporadaEquipoCompanion.insert(
                id: id,
                temporada: temporada,
                equipo: equipo,
                victorias: victorias,
                derrotas: derrotas,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistorialTemporadaEquipoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistorialTemporadaEquipoTable,
      RecordHistorico,
      $$HistorialTemporadaEquipoTableFilterComposer,
      $$HistorialTemporadaEquipoTableOrderingComposer,
      $$HistorialTemporadaEquipoTableAnnotationComposer,
      $$HistorialTemporadaEquipoTableCreateCompanionBuilder,
      $$HistorialTemporadaEquipoTableUpdateCompanionBuilder,
      (
        RecordHistorico,
        BaseReferences<
          _$AppDatabase,
          $HistorialTemporadaEquipoTable,
          RecordHistorico
        >,
      ),
      RecordHistorico,
      PrefetchHooks Function()
    >;
typedef $$HistorialPremiosTableCreateCompanionBuilder =
    HistorialPremiosCompanion Function({
      Value<int> id,
      required int temporada,
      required String tipo,
      required int jugadorId,
      required String nombreJugador,
      required String equipo,
    });
typedef $$HistorialPremiosTableUpdateCompanionBuilder =
    HistorialPremiosCompanion Function({
      Value<int> id,
      Value<int> temporada,
      Value<String> tipo,
      Value<int> jugadorId,
      Value<String> nombreJugador,
      Value<String> equipo,
    });

class $$HistorialPremiosTableFilterComposer
    extends Composer<_$AppDatabase, $HistorialPremiosTable> {
  $$HistorialPremiosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistorialPremiosTableOrderingComposer
    extends Composer<_$AppDatabase, $HistorialPremiosTable> {
  $$HistorialPremiosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistorialPremiosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistorialPremiosTable> {
  $$HistorialPremiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get temporada =>
      $composableBuilder(column: $table.temporada, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);

  GeneratedColumn<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);
}

class $$HistorialPremiosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistorialPremiosTable,
          PremioHistorico,
          $$HistorialPremiosTableFilterComposer,
          $$HistorialPremiosTableOrderingComposer,
          $$HistorialPremiosTableAnnotationComposer,
          $$HistorialPremiosTableCreateCompanionBuilder,
          $$HistorialPremiosTableUpdateCompanionBuilder,
          (
            PremioHistorico,
            BaseReferences<
              _$AppDatabase,
              $HistorialPremiosTable,
              PremioHistorico
            >,
          ),
          PremioHistorico,
          PrefetchHooks Function()
        > {
  $$HistorialPremiosTableTableManager(
    _$AppDatabase db,
    $HistorialPremiosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistorialPremiosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistorialPremiosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistorialPremiosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> temporada = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int> jugadorId = const Value.absent(),
                Value<String> nombreJugador = const Value.absent(),
                Value<String> equipo = const Value.absent(),
              }) => HistorialPremiosCompanion(
                id: id,
                temporada: temporada,
                tipo: tipo,
                jugadorId: jugadorId,
                nombreJugador: nombreJugador,
                equipo: equipo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int temporada,
                required String tipo,
                required int jugadorId,
                required String nombreJugador,
                required String equipo,
              }) => HistorialPremiosCompanion.insert(
                id: id,
                temporada: temporada,
                tipo: tipo,
                jugadorId: jugadorId,
                nombreJugador: nombreJugador,
                equipo: equipo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistorialPremiosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistorialPremiosTable,
      PremioHistorico,
      $$HistorialPremiosTableFilterComposer,
      $$HistorialPremiosTableOrderingComposer,
      $$HistorialPremiosTableAnnotationComposer,
      $$HistorialPremiosTableCreateCompanionBuilder,
      $$HistorialPremiosTableUpdateCompanionBuilder,
      (
        PremioHistorico,
        BaseReferences<_$AppDatabase, $HistorialPremiosTable, PremioHistorico>,
      ),
      PremioHistorico,
      PrefetchHooks Function()
    >;
typedef $$HistorialEstadisticasJugadorTableCreateCompanionBuilder =
    HistorialEstadisticasJugadorCompanion Function({
      Value<int> id,
      required int temporada,
      required int jugadorId,
      required String equipo,
      required int media,
      required int partidosJugados,
      required int puntosTotales,
      required int asistenciasTotales,
      required int rebotesTotales,
    });
typedef $$HistorialEstadisticasJugadorTableUpdateCompanionBuilder =
    HistorialEstadisticasJugadorCompanion Function({
      Value<int> id,
      Value<int> temporada,
      Value<int> jugadorId,
      Value<String> equipo,
      Value<int> media,
      Value<int> partidosJugados,
      Value<int> puntosTotales,
      Value<int> asistenciasTotales,
      Value<int> rebotesTotales,
    });

class $$HistorialEstadisticasJugadorTableFilterComposer
    extends Composer<_$AppDatabase, $HistorialEstadisticasJugadorTable> {
  $$HistorialEstadisticasJugadorTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get media => $composableBuilder(
    column: $table.media,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partidosJugados => $composableBuilder(
    column: $table.partidosJugados,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get puntosTotales => $composableBuilder(
    column: $table.puntosTotales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get asistenciasTotales => $composableBuilder(
    column: $table.asistenciasTotales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rebotesTotales => $composableBuilder(
    column: $table.rebotesTotales,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistorialEstadisticasJugadorTableOrderingComposer
    extends Composer<_$AppDatabase, $HistorialEstadisticasJugadorTable> {
  $$HistorialEstadisticasJugadorTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get media => $composableBuilder(
    column: $table.media,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partidosJugados => $composableBuilder(
    column: $table.partidosJugados,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get puntosTotales => $composableBuilder(
    column: $table.puntosTotales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get asistenciasTotales => $composableBuilder(
    column: $table.asistenciasTotales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rebotesTotales => $composableBuilder(
    column: $table.rebotesTotales,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistorialEstadisticasJugadorTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistorialEstadisticasJugadorTable> {
  $$HistorialEstadisticasJugadorTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get temporada =>
      $composableBuilder(column: $table.temporada, builder: (column) => column);

  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);

  GeneratedColumn<int> get media =>
      $composableBuilder(column: $table.media, builder: (column) => column);

  GeneratedColumn<int> get partidosJugados => $composableBuilder(
    column: $table.partidosJugados,
    builder: (column) => column,
  );

  GeneratedColumn<int> get puntosTotales => $composableBuilder(
    column: $table.puntosTotales,
    builder: (column) => column,
  );

  GeneratedColumn<int> get asistenciasTotales => $composableBuilder(
    column: $table.asistenciasTotales,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rebotesTotales => $composableBuilder(
    column: $table.rebotesTotales,
    builder: (column) => column,
  );
}

class $$HistorialEstadisticasJugadorTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistorialEstadisticasJugadorTable,
          TemporadaDeCarrera,
          $$HistorialEstadisticasJugadorTableFilterComposer,
          $$HistorialEstadisticasJugadorTableOrderingComposer,
          $$HistorialEstadisticasJugadorTableAnnotationComposer,
          $$HistorialEstadisticasJugadorTableCreateCompanionBuilder,
          $$HistorialEstadisticasJugadorTableUpdateCompanionBuilder,
          (
            TemporadaDeCarrera,
            BaseReferences<
              _$AppDatabase,
              $HistorialEstadisticasJugadorTable,
              TemporadaDeCarrera
            >,
          ),
          TemporadaDeCarrera,
          PrefetchHooks Function()
        > {
  $$HistorialEstadisticasJugadorTableTableManager(
    _$AppDatabase db,
    $HistorialEstadisticasJugadorTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistorialEstadisticasJugadorTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$HistorialEstadisticasJugadorTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HistorialEstadisticasJugadorTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> temporada = const Value.absent(),
                Value<int> jugadorId = const Value.absent(),
                Value<String> equipo = const Value.absent(),
                Value<int> media = const Value.absent(),
                Value<int> partidosJugados = const Value.absent(),
                Value<int> puntosTotales = const Value.absent(),
                Value<int> asistenciasTotales = const Value.absent(),
                Value<int> rebotesTotales = const Value.absent(),
              }) => HistorialEstadisticasJugadorCompanion(
                id: id,
                temporada: temporada,
                jugadorId: jugadorId,
                equipo: equipo,
                media: media,
                partidosJugados: partidosJugados,
                puntosTotales: puntosTotales,
                asistenciasTotales: asistenciasTotales,
                rebotesTotales: rebotesTotales,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int temporada,
                required int jugadorId,
                required String equipo,
                required int media,
                required int partidosJugados,
                required int puntosTotales,
                required int asistenciasTotales,
                required int rebotesTotales,
              }) => HistorialEstadisticasJugadorCompanion.insert(
                id: id,
                temporada: temporada,
                jugadorId: jugadorId,
                equipo: equipo,
                media: media,
                partidosJugados: partidosJugados,
                puntosTotales: puntosTotales,
                asistenciasTotales: asistenciasTotales,
                rebotesTotales: rebotesTotales,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistorialEstadisticasJugadorTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistorialEstadisticasJugadorTable,
      TemporadaDeCarrera,
      $$HistorialEstadisticasJugadorTableFilterComposer,
      $$HistorialEstadisticasJugadorTableOrderingComposer,
      $$HistorialEstadisticasJugadorTableAnnotationComposer,
      $$HistorialEstadisticasJugadorTableCreateCompanionBuilder,
      $$HistorialEstadisticasJugadorTableUpdateCompanionBuilder,
      (
        TemporadaDeCarrera,
        BaseReferences<
          _$AppDatabase,
          $HistorialEstadisticasJugadorTable,
          TemporadaDeCarrera
        >,
      ),
      TemporadaDeCarrera,
      PrefetchHooks Function()
    >;
typedef $$CamisetasRetiradasTableCreateCompanionBuilder =
    CamisetasRetiradasCompanion Function({
      Value<int> id,
      required String equipo,
      required int jugadorId,
      required String nombreJugador,
      required int dorsal,
      required int temporada,
    });
typedef $$CamisetasRetiradasTableUpdateCompanionBuilder =
    CamisetasRetiradasCompanion Function({
      Value<int> id,
      Value<String> equipo,
      Value<int> jugadorId,
      Value<String> nombreJugador,
      Value<int> dorsal,
      Value<int> temporada,
    });

class $$CamisetasRetiradasTableFilterComposer
    extends Composer<_$AppDatabase, $CamisetasRetiradasTable> {
  $$CamisetasRetiradasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dorsal => $composableBuilder(
    column: $table.dorsal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CamisetasRetiradasTableOrderingComposer
    extends Composer<_$AppDatabase, $CamisetasRetiradasTable> {
  $$CamisetasRetiradasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dorsal => $composableBuilder(
    column: $table.dorsal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CamisetasRetiradasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CamisetasRetiradasTable> {
  $$CamisetasRetiradasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);

  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);

  GeneratedColumn<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dorsal =>
      $composableBuilder(column: $table.dorsal, builder: (column) => column);

  GeneratedColumn<int> get temporada =>
      $composableBuilder(column: $table.temporada, builder: (column) => column);
}

class $$CamisetasRetiradasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CamisetasRetiradasTable,
          CamisetaRetirada,
          $$CamisetasRetiradasTableFilterComposer,
          $$CamisetasRetiradasTableOrderingComposer,
          $$CamisetasRetiradasTableAnnotationComposer,
          $$CamisetasRetiradasTableCreateCompanionBuilder,
          $$CamisetasRetiradasTableUpdateCompanionBuilder,
          (
            CamisetaRetirada,
            BaseReferences<
              _$AppDatabase,
              $CamisetasRetiradasTable,
              CamisetaRetirada
            >,
          ),
          CamisetaRetirada,
          PrefetchHooks Function()
        > {
  $$CamisetasRetiradasTableTableManager(
    _$AppDatabase db,
    $CamisetasRetiradasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CamisetasRetiradasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CamisetasRetiradasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CamisetasRetiradasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> equipo = const Value.absent(),
                Value<int> jugadorId = const Value.absent(),
                Value<String> nombreJugador = const Value.absent(),
                Value<int> dorsal = const Value.absent(),
                Value<int> temporada = const Value.absent(),
              }) => CamisetasRetiradasCompanion(
                id: id,
                equipo: equipo,
                jugadorId: jugadorId,
                nombreJugador: nombreJugador,
                dorsal: dorsal,
                temporada: temporada,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String equipo,
                required int jugadorId,
                required String nombreJugador,
                required int dorsal,
                required int temporada,
              }) => CamisetasRetiradasCompanion.insert(
                id: id,
                equipo: equipo,
                jugadorId: jugadorId,
                nombreJugador: nombreJugador,
                dorsal: dorsal,
                temporada: temporada,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CamisetasRetiradasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CamisetasRetiradasTable,
      CamisetaRetirada,
      $$CamisetasRetiradasTableFilterComposer,
      $$CamisetasRetiradasTableOrderingComposer,
      $$CamisetasRetiradasTableAnnotationComposer,
      $$CamisetasRetiradasTableCreateCompanionBuilder,
      $$CamisetasRetiradasTableUpdateCompanionBuilder,
      (
        CamisetaRetirada,
        BaseReferences<
          _$AppDatabase,
          $CamisetasRetiradasTable,
          CamisetaRetirada
        >,
      ),
      CamisetaRetirada,
      PrefetchHooks Function()
    >;
typedef $$HallDeLaFamaTableCreateCompanionBuilder =
    HallDeLaFamaCompanion Function({
      Value<int> id,
      required int jugadorId,
      required String nombreJugador,
      required int temporadaIngreso,
      required double puntuacion,
    });
typedef $$HallDeLaFamaTableUpdateCompanionBuilder =
    HallDeLaFamaCompanion Function({
      Value<int> id,
      Value<int> jugadorId,
      Value<String> nombreJugador,
      Value<int> temporadaIngreso,
      Value<double> puntuacion,
    });

class $$HallDeLaFamaTableFilterComposer
    extends Composer<_$AppDatabase, $HallDeLaFamaTable> {
  $$HallDeLaFamaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporadaIngreso => $composableBuilder(
    column: $table.temporadaIngreso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get puntuacion => $composableBuilder(
    column: $table.puntuacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HallDeLaFamaTableOrderingComposer
    extends Composer<_$AppDatabase, $HallDeLaFamaTable> {
  $$HallDeLaFamaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jugadorId => $composableBuilder(
    column: $table.jugadorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporadaIngreso => $composableBuilder(
    column: $table.temporadaIngreso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get puntuacion => $composableBuilder(
    column: $table.puntuacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HallDeLaFamaTableAnnotationComposer
    extends Composer<_$AppDatabase, $HallDeLaFamaTable> {
  $$HallDeLaFamaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jugadorId =>
      $composableBuilder(column: $table.jugadorId, builder: (column) => column);

  GeneratedColumn<String> get nombreJugador => $composableBuilder(
    column: $table.nombreJugador,
    builder: (column) => column,
  );

  GeneratedColumn<int> get temporadaIngreso => $composableBuilder(
    column: $table.temporadaIngreso,
    builder: (column) => column,
  );

  GeneratedColumn<double> get puntuacion => $composableBuilder(
    column: $table.puntuacion,
    builder: (column) => column,
  );
}

class $$HallDeLaFamaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HallDeLaFamaTable,
          MiembroHallDeLaFama,
          $$HallDeLaFamaTableFilterComposer,
          $$HallDeLaFamaTableOrderingComposer,
          $$HallDeLaFamaTableAnnotationComposer,
          $$HallDeLaFamaTableCreateCompanionBuilder,
          $$HallDeLaFamaTableUpdateCompanionBuilder,
          (
            MiembroHallDeLaFama,
            BaseReferences<
              _$AppDatabase,
              $HallDeLaFamaTable,
              MiembroHallDeLaFama
            >,
          ),
          MiembroHallDeLaFama,
          PrefetchHooks Function()
        > {
  $$HallDeLaFamaTableTableManager(_$AppDatabase db, $HallDeLaFamaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HallDeLaFamaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HallDeLaFamaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HallDeLaFamaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jugadorId = const Value.absent(),
                Value<String> nombreJugador = const Value.absent(),
                Value<int> temporadaIngreso = const Value.absent(),
                Value<double> puntuacion = const Value.absent(),
              }) => HallDeLaFamaCompanion(
                id: id,
                jugadorId: jugadorId,
                nombreJugador: nombreJugador,
                temporadaIngreso: temporadaIngreso,
                puntuacion: puntuacion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jugadorId,
                required String nombreJugador,
                required int temporadaIngreso,
                required double puntuacion,
              }) => HallDeLaFamaCompanion.insert(
                id: id,
                jugadorId: jugadorId,
                nombreJugador: nombreJugador,
                temporadaIngreso: temporadaIngreso,
                puntuacion: puntuacion,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HallDeLaFamaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HallDeLaFamaTable,
      MiembroHallDeLaFama,
      $$HallDeLaFamaTableFilterComposer,
      $$HallDeLaFamaTableOrderingComposer,
      $$HallDeLaFamaTableAnnotationComposer,
      $$HallDeLaFamaTableCreateCompanionBuilder,
      $$HallDeLaFamaTableUpdateCompanionBuilder,
      (
        MiembroHallDeLaFama,
        BaseReferences<_$AppDatabase, $HallDeLaFamaTable, MiembroHallDeLaFama>,
      ),
      MiembroHallDeLaFama,
      PrefetchHooks Function()
    >;
typedef $$DraftEnCursoTableCreateCompanionBuilder =
    DraftEnCursoCompanion Function({
      Value<int> id,
      required int anioDraft,
      required String ordenEquipos,
      Value<int> indice,
    });
typedef $$DraftEnCursoTableUpdateCompanionBuilder =
    DraftEnCursoCompanion Function({
      Value<int> id,
      Value<int> anioDraft,
      Value<String> ordenEquipos,
      Value<int> indice,
    });

class $$DraftEnCursoTableFilterComposer
    extends Composer<_$AppDatabase, $DraftEnCursoTable> {
  $$DraftEnCursoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anioDraft => $composableBuilder(
    column: $table.anioDraft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ordenEquipos => $composableBuilder(
    column: $table.ordenEquipos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indice => $composableBuilder(
    column: $table.indice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftEnCursoTableOrderingComposer
    extends Composer<_$AppDatabase, $DraftEnCursoTable> {
  $$DraftEnCursoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anioDraft => $composableBuilder(
    column: $table.anioDraft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ordenEquipos => $composableBuilder(
    column: $table.ordenEquipos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indice => $composableBuilder(
    column: $table.indice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftEnCursoTableAnnotationComposer
    extends Composer<_$AppDatabase, $DraftEnCursoTable> {
  $$DraftEnCursoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get anioDraft =>
      $composableBuilder(column: $table.anioDraft, builder: (column) => column);

  GeneratedColumn<String> get ordenEquipos => $composableBuilder(
    column: $table.ordenEquipos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get indice =>
      $composableBuilder(column: $table.indice, builder: (column) => column);
}

class $$DraftEnCursoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DraftEnCursoTable,
          DraftEnCursoData,
          $$DraftEnCursoTableFilterComposer,
          $$DraftEnCursoTableOrderingComposer,
          $$DraftEnCursoTableAnnotationComposer,
          $$DraftEnCursoTableCreateCompanionBuilder,
          $$DraftEnCursoTableUpdateCompanionBuilder,
          (
            DraftEnCursoData,
            BaseReferences<_$AppDatabase, $DraftEnCursoTable, DraftEnCursoData>,
          ),
          DraftEnCursoData,
          PrefetchHooks Function()
        > {
  $$DraftEnCursoTableTableManager(_$AppDatabase db, $DraftEnCursoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftEnCursoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DraftEnCursoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DraftEnCursoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> anioDraft = const Value.absent(),
                Value<String> ordenEquipos = const Value.absent(),
                Value<int> indice = const Value.absent(),
              }) => DraftEnCursoCompanion(
                id: id,
                anioDraft: anioDraft,
                ordenEquipos: ordenEquipos,
                indice: indice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int anioDraft,
                required String ordenEquipos,
                Value<int> indice = const Value.absent(),
              }) => DraftEnCursoCompanion.insert(
                id: id,
                anioDraft: anioDraft,
                ordenEquipos: ordenEquipos,
                indice: indice,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftEnCursoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DraftEnCursoTable,
      DraftEnCursoData,
      $$DraftEnCursoTableFilterComposer,
      $$DraftEnCursoTableOrderingComposer,
      $$DraftEnCursoTableAnnotationComposer,
      $$DraftEnCursoTableCreateCompanionBuilder,
      $$DraftEnCursoTableUpdateCompanionBuilder,
      (
        DraftEnCursoData,
        BaseReferences<_$AppDatabase, $DraftEnCursoTable, DraftEnCursoData>,
      ),
      DraftEnCursoData,
      PrefetchHooks Function()
    >;
typedef $$PicksDraftTableCreateCompanionBuilder =
    PicksDraftCompanion Function({
      Value<int> id,
      required int temporada,
      required int ronda,
      required String equipoOriginal,
      required String equipoActual,
      Value<bool> usado,
    });
typedef $$PicksDraftTableUpdateCompanionBuilder =
    PicksDraftCompanion Function({
      Value<int> id,
      Value<int> temporada,
      Value<int> ronda,
      Value<String> equipoOriginal,
      Value<String> equipoActual,
      Value<bool> usado,
    });

class $$PicksDraftTableFilterComposer
    extends Composer<_$AppDatabase, $PicksDraftTable> {
  $$PicksDraftTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ronda => $composableBuilder(
    column: $table.ronda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoOriginal => $composableBuilder(
    column: $table.equipoOriginal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoActual => $composableBuilder(
    column: $table.equipoActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usado => $composableBuilder(
    column: $table.usado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PicksDraftTableOrderingComposer
    extends Composer<_$AppDatabase, $PicksDraftTable> {
  $$PicksDraftTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporada => $composableBuilder(
    column: $table.temporada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ronda => $composableBuilder(
    column: $table.ronda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoOriginal => $composableBuilder(
    column: $table.equipoOriginal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoActual => $composableBuilder(
    column: $table.equipoActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usado => $composableBuilder(
    column: $table.usado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PicksDraftTableAnnotationComposer
    extends Composer<_$AppDatabase, $PicksDraftTable> {
  $$PicksDraftTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get temporada =>
      $composableBuilder(column: $table.temporada, builder: (column) => column);

  GeneratedColumn<int> get ronda =>
      $composableBuilder(column: $table.ronda, builder: (column) => column);

  GeneratedColumn<String> get equipoOriginal => $composableBuilder(
    column: $table.equipoOriginal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipoActual => $composableBuilder(
    column: $table.equipoActual,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get usado =>
      $composableBuilder(column: $table.usado, builder: (column) => column);
}

class $$PicksDraftTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PicksDraftTable,
          PickDraft,
          $$PicksDraftTableFilterComposer,
          $$PicksDraftTableOrderingComposer,
          $$PicksDraftTableAnnotationComposer,
          $$PicksDraftTableCreateCompanionBuilder,
          $$PicksDraftTableUpdateCompanionBuilder,
          (
            PickDraft,
            BaseReferences<_$AppDatabase, $PicksDraftTable, PickDraft>,
          ),
          PickDraft,
          PrefetchHooks Function()
        > {
  $$PicksDraftTableTableManager(_$AppDatabase db, $PicksDraftTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PicksDraftTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PicksDraftTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PicksDraftTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> temporada = const Value.absent(),
                Value<int> ronda = const Value.absent(),
                Value<String> equipoOriginal = const Value.absent(),
                Value<String> equipoActual = const Value.absent(),
                Value<bool> usado = const Value.absent(),
              }) => PicksDraftCompanion(
                id: id,
                temporada: temporada,
                ronda: ronda,
                equipoOriginal: equipoOriginal,
                equipoActual: equipoActual,
                usado: usado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int temporada,
                required int ronda,
                required String equipoOriginal,
                required String equipoActual,
                Value<bool> usado = const Value.absent(),
              }) => PicksDraftCompanion.insert(
                id: id,
                temporada: temporada,
                ronda: ronda,
                equipoOriginal: equipoOriginal,
                equipoActual: equipoActual,
                usado: usado,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PicksDraftTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PicksDraftTable,
      PickDraft,
      $$PicksDraftTableFilterComposer,
      $$PicksDraftTableOrderingComposer,
      $$PicksDraftTableAnnotationComposer,
      $$PicksDraftTableCreateCompanionBuilder,
      $$PicksDraftTableUpdateCompanionBuilder,
      (PickDraft, BaseReferences<_$AppDatabase, $PicksDraftTable, PickDraft>),
      PickDraft,
      PrefetchHooks Function()
    >;
typedef $$OfertasTraspasoTableCreateCompanionBuilder =
    OfertasTraspasoCompanion Function({
      Value<int> id,
      required String equipoOfertante,
      required String pideJugadores,
      required String ofreceJugadores,
      Value<String> ofrecePicks,
      required DateTime fecha,
      Value<bool> vista,
    });
typedef $$OfertasTraspasoTableUpdateCompanionBuilder =
    OfertasTraspasoCompanion Function({
      Value<int> id,
      Value<String> equipoOfertante,
      Value<String> pideJugadores,
      Value<String> ofreceJugadores,
      Value<String> ofrecePicks,
      Value<DateTime> fecha,
      Value<bool> vista,
    });

class $$OfertasTraspasoTableFilterComposer
    extends Composer<_$AppDatabase, $OfertasTraspasoTable> {
  $$OfertasTraspasoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoOfertante => $composableBuilder(
    column: $table.equipoOfertante,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pideJugadores => $composableBuilder(
    column: $table.pideJugadores,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ofreceJugadores => $composableBuilder(
    column: $table.ofreceJugadores,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ofrecePicks => $composableBuilder(
    column: $table.ofrecePicks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vista => $composableBuilder(
    column: $table.vista,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfertasTraspasoTableOrderingComposer
    extends Composer<_$AppDatabase, $OfertasTraspasoTable> {
  $$OfertasTraspasoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoOfertante => $composableBuilder(
    column: $table.equipoOfertante,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pideJugadores => $composableBuilder(
    column: $table.pideJugadores,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ofreceJugadores => $composableBuilder(
    column: $table.ofreceJugadores,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ofrecePicks => $composableBuilder(
    column: $table.ofrecePicks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vista => $composableBuilder(
    column: $table.vista,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfertasTraspasoTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfertasTraspasoTable> {
  $$OfertasTraspasoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get equipoOfertante => $composableBuilder(
    column: $table.equipoOfertante,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pideJugadores => $composableBuilder(
    column: $table.pideJugadores,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ofreceJugadores => $composableBuilder(
    column: $table.ofreceJugadores,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ofrecePicks => $composableBuilder(
    column: $table.ofrecePicks,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<bool> get vista =>
      $composableBuilder(column: $table.vista, builder: (column) => column);
}

class $$OfertasTraspasoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfertasTraspasoTable,
          OfertaTraspaso,
          $$OfertasTraspasoTableFilterComposer,
          $$OfertasTraspasoTableOrderingComposer,
          $$OfertasTraspasoTableAnnotationComposer,
          $$OfertasTraspasoTableCreateCompanionBuilder,
          $$OfertasTraspasoTableUpdateCompanionBuilder,
          (
            OfertaTraspaso,
            BaseReferences<
              _$AppDatabase,
              $OfertasTraspasoTable,
              OfertaTraspaso
            >,
          ),
          OfertaTraspaso,
          PrefetchHooks Function()
        > {
  $$OfertasTraspasoTableTableManager(
    _$AppDatabase db,
    $OfertasTraspasoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfertasTraspasoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfertasTraspasoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfertasTraspasoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> equipoOfertante = const Value.absent(),
                Value<String> pideJugadores = const Value.absent(),
                Value<String> ofreceJugadores = const Value.absent(),
                Value<String> ofrecePicks = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<bool> vista = const Value.absent(),
              }) => OfertasTraspasoCompanion(
                id: id,
                equipoOfertante: equipoOfertante,
                pideJugadores: pideJugadores,
                ofreceJugadores: ofreceJugadores,
                ofrecePicks: ofrecePicks,
                fecha: fecha,
                vista: vista,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String equipoOfertante,
                required String pideJugadores,
                required String ofreceJugadores,
                Value<String> ofrecePicks = const Value.absent(),
                required DateTime fecha,
                Value<bool> vista = const Value.absent(),
              }) => OfertasTraspasoCompanion.insert(
                id: id,
                equipoOfertante: equipoOfertante,
                pideJugadores: pideJugadores,
                ofreceJugadores: ofreceJugadores,
                ofrecePicks: ofrecePicks,
                fecha: fecha,
                vista: vista,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfertasTraspasoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfertasTraspasoTable,
      OfertaTraspaso,
      $$OfertasTraspasoTableFilterComposer,
      $$OfertasTraspasoTableOrderingComposer,
      $$OfertasTraspasoTableAnnotationComposer,
      $$OfertasTraspasoTableCreateCompanionBuilder,
      $$OfertasTraspasoTableUpdateCompanionBuilder,
      (
        OfertaTraspaso,
        BaseReferences<_$AppDatabase, $OfertasTraspasoTable, OfertaTraspaso>,
      ),
      OfertaTraspaso,
      PrefetchHooks Function()
    >;
typedef $$EntrenadoresTableCreateCompanionBuilder =
    EntrenadoresCompanion Function({
      Value<int> id,
      required String nombreFicticio,
      required String nombreReal,
      required String equipo,
      required int edad,
      required int atrAtaque,
      required int atrDefensa,
      required int atrDesarrollo,
      Value<int> anillos,
      Value<int> premios,
      Value<int> temporadas,
      Value<int> victorias,
      Value<int> derrotas,
      Value<int> salario,
      Value<int> aniosContrato,
      Value<String?> equipoQuePagaFiniquito,
      Value<int> aniosDeFiniquito,
    });
typedef $$EntrenadoresTableUpdateCompanionBuilder =
    EntrenadoresCompanion Function({
      Value<int> id,
      Value<String> nombreFicticio,
      Value<String> nombreReal,
      Value<String> equipo,
      Value<int> edad,
      Value<int> atrAtaque,
      Value<int> atrDefensa,
      Value<int> atrDesarrollo,
      Value<int> anillos,
      Value<int> premios,
      Value<int> temporadas,
      Value<int> victorias,
      Value<int> derrotas,
      Value<int> salario,
      Value<int> aniosContrato,
      Value<String?> equipoQuePagaFiniquito,
      Value<int> aniosDeFiniquito,
    });

class $$EntrenadoresTableFilterComposer
    extends Composer<_$AppDatabase, $EntrenadoresTable> {
  $$EntrenadoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreFicticio => $composableBuilder(
    column: $table.nombreFicticio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreReal => $composableBuilder(
    column: $table.nombreReal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get edad => $composableBuilder(
    column: $table.edad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atrAtaque => $composableBuilder(
    column: $table.atrAtaque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atrDefensa => $composableBuilder(
    column: $table.atrDefensa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atrDesarrollo => $composableBuilder(
    column: $table.atrDesarrollo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anillos => $composableBuilder(
    column: $table.anillos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get premios => $composableBuilder(
    column: $table.premios,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temporadas => $composableBuilder(
    column: $table.temporadas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get victorias => $composableBuilder(
    column: $table.victorias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get derrotas => $composableBuilder(
    column: $table.derrotas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salario => $composableBuilder(
    column: $table.salario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aniosContrato => $composableBuilder(
    column: $table.aniosContrato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipoQuePagaFiniquito => $composableBuilder(
    column: $table.equipoQuePagaFiniquito,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aniosDeFiniquito => $composableBuilder(
    column: $table.aniosDeFiniquito,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntrenadoresTableOrderingComposer
    extends Composer<_$AppDatabase, $EntrenadoresTable> {
  $$EntrenadoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreFicticio => $composableBuilder(
    column: $table.nombreFicticio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreReal => $composableBuilder(
    column: $table.nombreReal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipo => $composableBuilder(
    column: $table.equipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get edad => $composableBuilder(
    column: $table.edad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atrAtaque => $composableBuilder(
    column: $table.atrAtaque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atrDefensa => $composableBuilder(
    column: $table.atrDefensa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atrDesarrollo => $composableBuilder(
    column: $table.atrDesarrollo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anillos => $composableBuilder(
    column: $table.anillos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get premios => $composableBuilder(
    column: $table.premios,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temporadas => $composableBuilder(
    column: $table.temporadas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get victorias => $composableBuilder(
    column: $table.victorias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get derrotas => $composableBuilder(
    column: $table.derrotas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salario => $composableBuilder(
    column: $table.salario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aniosContrato => $composableBuilder(
    column: $table.aniosContrato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipoQuePagaFiniquito => $composableBuilder(
    column: $table.equipoQuePagaFiniquito,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aniosDeFiniquito => $composableBuilder(
    column: $table.aniosDeFiniquito,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntrenadoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntrenadoresTable> {
  $$EntrenadoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreFicticio => $composableBuilder(
    column: $table.nombreFicticio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombreReal => $composableBuilder(
    column: $table.nombreReal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipo =>
      $composableBuilder(column: $table.equipo, builder: (column) => column);

  GeneratedColumn<int> get edad =>
      $composableBuilder(column: $table.edad, builder: (column) => column);

  GeneratedColumn<int> get atrAtaque =>
      $composableBuilder(column: $table.atrAtaque, builder: (column) => column);

  GeneratedColumn<int> get atrDefensa => $composableBuilder(
    column: $table.atrDefensa,
    builder: (column) => column,
  );

  GeneratedColumn<int> get atrDesarrollo => $composableBuilder(
    column: $table.atrDesarrollo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anillos =>
      $composableBuilder(column: $table.anillos, builder: (column) => column);

  GeneratedColumn<int> get premios =>
      $composableBuilder(column: $table.premios, builder: (column) => column);

  GeneratedColumn<int> get temporadas => $composableBuilder(
    column: $table.temporadas,
    builder: (column) => column,
  );

  GeneratedColumn<int> get victorias =>
      $composableBuilder(column: $table.victorias, builder: (column) => column);

  GeneratedColumn<int> get derrotas =>
      $composableBuilder(column: $table.derrotas, builder: (column) => column);

  GeneratedColumn<int> get salario =>
      $composableBuilder(column: $table.salario, builder: (column) => column);

  GeneratedColumn<int> get aniosContrato => $composableBuilder(
    column: $table.aniosContrato,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipoQuePagaFiniquito => $composableBuilder(
    column: $table.equipoQuePagaFiniquito,
    builder: (column) => column,
  );

  GeneratedColumn<int> get aniosDeFiniquito => $composableBuilder(
    column: $table.aniosDeFiniquito,
    builder: (column) => column,
  );
}

class $$EntrenadoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntrenadoresTable,
          Entrenador,
          $$EntrenadoresTableFilterComposer,
          $$EntrenadoresTableOrderingComposer,
          $$EntrenadoresTableAnnotationComposer,
          $$EntrenadoresTableCreateCompanionBuilder,
          $$EntrenadoresTableUpdateCompanionBuilder,
          (
            Entrenador,
            BaseReferences<_$AppDatabase, $EntrenadoresTable, Entrenador>,
          ),
          Entrenador,
          PrefetchHooks Function()
        > {
  $$EntrenadoresTableTableManager(_$AppDatabase db, $EntrenadoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntrenadoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntrenadoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntrenadoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombreFicticio = const Value.absent(),
                Value<String> nombreReal = const Value.absent(),
                Value<String> equipo = const Value.absent(),
                Value<int> edad = const Value.absent(),
                Value<int> atrAtaque = const Value.absent(),
                Value<int> atrDefensa = const Value.absent(),
                Value<int> atrDesarrollo = const Value.absent(),
                Value<int> anillos = const Value.absent(),
                Value<int> premios = const Value.absent(),
                Value<int> temporadas = const Value.absent(),
                Value<int> victorias = const Value.absent(),
                Value<int> derrotas = const Value.absent(),
                Value<int> salario = const Value.absent(),
                Value<int> aniosContrato = const Value.absent(),
                Value<String?> equipoQuePagaFiniquito = const Value.absent(),
                Value<int> aniosDeFiniquito = const Value.absent(),
              }) => EntrenadoresCompanion(
                id: id,
                nombreFicticio: nombreFicticio,
                nombreReal: nombreReal,
                equipo: equipo,
                edad: edad,
                atrAtaque: atrAtaque,
                atrDefensa: atrDefensa,
                atrDesarrollo: atrDesarrollo,
                anillos: anillos,
                premios: premios,
                temporadas: temporadas,
                victorias: victorias,
                derrotas: derrotas,
                salario: salario,
                aniosContrato: aniosContrato,
                equipoQuePagaFiniquito: equipoQuePagaFiniquito,
                aniosDeFiniquito: aniosDeFiniquito,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombreFicticio,
                required String nombreReal,
                required String equipo,
                required int edad,
                required int atrAtaque,
                required int atrDefensa,
                required int atrDesarrollo,
                Value<int> anillos = const Value.absent(),
                Value<int> premios = const Value.absent(),
                Value<int> temporadas = const Value.absent(),
                Value<int> victorias = const Value.absent(),
                Value<int> derrotas = const Value.absent(),
                Value<int> salario = const Value.absent(),
                Value<int> aniosContrato = const Value.absent(),
                Value<String?> equipoQuePagaFiniquito = const Value.absent(),
                Value<int> aniosDeFiniquito = const Value.absent(),
              }) => EntrenadoresCompanion.insert(
                id: id,
                nombreFicticio: nombreFicticio,
                nombreReal: nombreReal,
                equipo: equipo,
                edad: edad,
                atrAtaque: atrAtaque,
                atrDefensa: atrDefensa,
                atrDesarrollo: atrDesarrollo,
                anillos: anillos,
                premios: premios,
                temporadas: temporadas,
                victorias: victorias,
                derrotas: derrotas,
                salario: salario,
                aniosContrato: aniosContrato,
                equipoQuePagaFiniquito: equipoQuePagaFiniquito,
                aniosDeFiniquito: aniosDeFiniquito,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntrenadoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntrenadoresTable,
      Entrenador,
      $$EntrenadoresTableFilterComposer,
      $$EntrenadoresTableOrderingComposer,
      $$EntrenadoresTableAnnotationComposer,
      $$EntrenadoresTableCreateCompanionBuilder,
      $$EntrenadoresTableUpdateCompanionBuilder,
      (
        Entrenador,
        BaseReferences<_$AppDatabase, $EntrenadoresTable, Entrenador>,
      ),
      Entrenador,
      PrefetchHooks Function()
    >;
typedef $$EfectosDeEventoTableCreateCompanionBuilder =
    EfectosDeEventoCompanion Function({
      Value<int> id,
      required String clave,
      required String etiqueta,
      required double factor,
      required int partidosRestantes,
    });
typedef $$EfectosDeEventoTableUpdateCompanionBuilder =
    EfectosDeEventoCompanion Function({
      Value<int> id,
      Value<String> clave,
      Value<String> etiqueta,
      Value<double> factor,
      Value<int> partidosRestantes,
    });

class $$EfectosDeEventoTableFilterComposer
    extends Composer<_$AppDatabase, $EfectosDeEventoTable> {
  $$EfectosDeEventoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etiqueta => $composableBuilder(
    column: $table.etiqueta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partidosRestantes => $composableBuilder(
    column: $table.partidosRestantes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EfectosDeEventoTableOrderingComposer
    extends Composer<_$AppDatabase, $EfectosDeEventoTable> {
  $$EfectosDeEventoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etiqueta => $composableBuilder(
    column: $table.etiqueta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get factor => $composableBuilder(
    column: $table.factor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partidosRestantes => $composableBuilder(
    column: $table.partidosRestantes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EfectosDeEventoTableAnnotationComposer
    extends Composer<_$AppDatabase, $EfectosDeEventoTable> {
  $$EfectosDeEventoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get etiqueta =>
      $composableBuilder(column: $table.etiqueta, builder: (column) => column);

  GeneratedColumn<double> get factor =>
      $composableBuilder(column: $table.factor, builder: (column) => column);

  GeneratedColumn<int> get partidosRestantes => $composableBuilder(
    column: $table.partidosRestantes,
    builder: (column) => column,
  );
}

class $$EfectosDeEventoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EfectosDeEventoTable,
          EfectosDeEventoData,
          $$EfectosDeEventoTableFilterComposer,
          $$EfectosDeEventoTableOrderingComposer,
          $$EfectosDeEventoTableAnnotationComposer,
          $$EfectosDeEventoTableCreateCompanionBuilder,
          $$EfectosDeEventoTableUpdateCompanionBuilder,
          (
            EfectosDeEventoData,
            BaseReferences<
              _$AppDatabase,
              $EfectosDeEventoTable,
              EfectosDeEventoData
            >,
          ),
          EfectosDeEventoData,
          PrefetchHooks Function()
        > {
  $$EfectosDeEventoTableTableManager(
    _$AppDatabase db,
    $EfectosDeEventoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EfectosDeEventoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EfectosDeEventoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EfectosDeEventoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> clave = const Value.absent(),
                Value<String> etiqueta = const Value.absent(),
                Value<double> factor = const Value.absent(),
                Value<int> partidosRestantes = const Value.absent(),
              }) => EfectosDeEventoCompanion(
                id: id,
                clave: clave,
                etiqueta: etiqueta,
                factor: factor,
                partidosRestantes: partidosRestantes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String clave,
                required String etiqueta,
                required double factor,
                required int partidosRestantes,
              }) => EfectosDeEventoCompanion.insert(
                id: id,
                clave: clave,
                etiqueta: etiqueta,
                factor: factor,
                partidosRestantes: partidosRestantes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EfectosDeEventoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EfectosDeEventoTable,
      EfectosDeEventoData,
      $$EfectosDeEventoTableFilterComposer,
      $$EfectosDeEventoTableOrderingComposer,
      $$EfectosDeEventoTableAnnotationComposer,
      $$EfectosDeEventoTableCreateCompanionBuilder,
      $$EfectosDeEventoTableUpdateCompanionBuilder,
      (
        EfectosDeEventoData,
        BaseReferences<
          _$AppDatabase,
          $EfectosDeEventoTable,
          EfectosDeEventoData
        >,
      ),
      EfectosDeEventoData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JugadoresTableTableManager get jugadores =>
      $$JugadoresTableTableManager(_db, _db.jugadores);
  $$FranquiciaTableTableManager get franquicia =>
      $$FranquiciaTableTableManager(_db, _db.franquicia);
  $$RotacionJugadorTableTableManager get rotacionJugador =>
      $$RotacionJugadorTableTableManager(_db, _db.rotacionJugador);
  $$PartidosCalendarioTableTableManager get partidosCalendario =>
      $$PartidosCalendarioTableTableManager(_db, _db.partidosCalendario);
  $$EventosTemporadaTableTableManager get eventosTemporada =>
      $$EventosTemporadaTableTableManager(_db, _db.eventosTemporada);
  $$LesionesTableTableManager get lesiones =>
      $$LesionesTableTableManager(_db, _db.lesiones);
  $$EstadisticasTemporadaJugadorTableTableManager
  get estadisticasTemporadaJugador =>
      $$EstadisticasTemporadaJugadorTableTableManager(
        _db,
        _db.estadisticasTemporadaJugador,
      );
  $$ResultadoTemporadaTableTableManager get resultadoTemporada =>
      $$ResultadoTemporadaTableTableManager(_db, _db.resultadoTemporada);
  $$PremiosTemporadaTableTableManager get premiosTemporada =>
      $$PremiosTemporadaTableTableManager(_db, _db.premiosTemporada);
  $$SeriesPlayoffsTableTableManager get seriesPlayoffs =>
      $$SeriesPlayoffsTableTableManager(_db, _db.seriesPlayoffs);
  $$AjustesTableTableManager get ajustes =>
      $$AjustesTableTableManager(_db, _db.ajustes);
  $$HistorialCampeonesTableTableManager get historialCampeones =>
      $$HistorialCampeonesTableTableManager(_db, _db.historialCampeones);
  $$IstTemporadaTableTableManager get istTemporada =>
      $$IstTemporadaTableTableManager(_db, _db.istTemporada);
  $$SeriesTorneoTableTableManager get seriesTorneo =>
      $$SeriesTorneoTableTableManager(_db, _db.seriesTorneo);
  $$BoxscoresSerieTableTableManager get boxscoresSerie =>
      $$BoxscoresSerieTableTableManager(_db, _db.boxscoresSerie);
  $$FormaTemporadaJugadorTableTableManager get formaTemporadaJugador =>
      $$FormaTemporadaJugadorTableTableManager(_db, _db.formaTemporadaJugador);
  $$TemporadaTableTableManager get temporada =>
      $$TemporadaTableTableManager(_db, _db.temporada);
  $$HistorialTemporadaEquipoTableTableManager get historialTemporadaEquipo =>
      $$HistorialTemporadaEquipoTableTableManager(
        _db,
        _db.historialTemporadaEquipo,
      );
  $$HistorialPremiosTableTableManager get historialPremios =>
      $$HistorialPremiosTableTableManager(_db, _db.historialPremios);
  $$HistorialEstadisticasJugadorTableTableManager
  get historialEstadisticasJugador =>
      $$HistorialEstadisticasJugadorTableTableManager(
        _db,
        _db.historialEstadisticasJugador,
      );
  $$CamisetasRetiradasTableTableManager get camisetasRetiradas =>
      $$CamisetasRetiradasTableTableManager(_db, _db.camisetasRetiradas);
  $$HallDeLaFamaTableTableManager get hallDeLaFama =>
      $$HallDeLaFamaTableTableManager(_db, _db.hallDeLaFama);
  $$DraftEnCursoTableTableManager get draftEnCurso =>
      $$DraftEnCursoTableTableManager(_db, _db.draftEnCurso);
  $$PicksDraftTableTableManager get picksDraft =>
      $$PicksDraftTableTableManager(_db, _db.picksDraft);
  $$OfertasTraspasoTableTableManager get ofertasTraspaso =>
      $$OfertasTraspasoTableTableManager(_db, _db.ofertasTraspaso);
  $$EntrenadoresTableTableManager get entrenadores =>
      $$EntrenadoresTableTableManager(_db, _db.entrenadores);
  $$EfectosDeEventoTableTableManager get efectosDeEvento =>
      $$EfectosDeEventoTableTableManager(_db, _db.efectosDeEvento);
}
