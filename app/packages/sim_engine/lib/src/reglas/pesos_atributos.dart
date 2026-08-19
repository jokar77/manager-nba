/// Constantes de balance del motor de simulación. Centralizadas aquí para
/// poder ajustarlas sin tocar la lógica de [SimuladorPartido].
class PesosAtributos {
  PesosAtributos._();

  /// Rating ofensivo/defensivo medio de la liga, en la misma escala (0-99)
  /// que los atributos del dataset.
  ///
  /// Medido sobre las rotaciones reales de los 30 equipos: los ratings de
  /// equipo caen entre 73 y 86, con media ~79. Antes estaba en 70, que no
  /// era la media de nada: los dos factores (ataque propio / defensa rival)
  /// se compensaban de casualidad y el marcador medio salía bien, pero las
  /// constantes mentían sobre lo que hacían.
  static const double ratingLigaMedio = 79;

  /// Cuánto se traduce en marcador la distancia de un equipo respecto a la
  /// media de la liga: el factor aplicado es
  /// `1 + (rating/ratingLigaMedio - 1) * sensibilidadAlRating`.
  ///
  /// Sin compresión (equivalente a 1.0) un punto de rating movía 1,4 puntos
  /// de marcador, y como los ratings de equipo se separan unos ±5 de la
  /// media, salían diferencias de ±15 puntos por partido. Medido sobre una
  /// temporada completa daba 76-6 arriba y 5-77 abajo, con una desviación
  /// del porcentaje de victorias de 0,237 cuando la NBA real ronda 0,145.
  ///
  /// Con 0,55 las diferencias de puntos quedan en el ±9 real (el mejor
  /// equipo de la NBA ronda +9 y el peor -9) y los récords caen donde tienen
  /// que caer: el mejor por los 60 y pico y el peor por los 15-20, en vez de
  /// que el mejor gane el 93% de sus partidos.
  static const double sensibilidadAlRating = 0.55;

  /// Puntos medios de un equipo NBA moderno, usados como ancla de la
  /// conversión rating -> marcador.
  static const double puntosLigaMedios = 112;

  /// Atributo de un entrenador del montón, y cuánto se separan de él los
  /// extremos. Medido sobre los 30 entrenadores del asset: la media de
  /// ataque y de defensa es 76 y el recorrido a cada lado ronda los 16
  /// puntos (el mejor anda por 93-94, el peor por 60-62).
  static const double atributoEntrenadorMedio = 76;
  static const double recorridoEntrenador = 16;

  /// Lo que suma (o resta) un entrenador al rating de equipo, en puntos de
  /// rating, cuando está un recorrido entero por encima (o por debajo) de
  /// la media.
  ///
  /// El número parece pequeño y no lo es. Medido sobre 40.000 partidos entre
  /// dos plantillas idénticas, cambiando solo el banquillo:
  ///
  ///   sin entrenador / entrenador medio ... 41,1 victorias de 82
  ///   el mejor de la liga ................. 43,8  (+2,7)
  ///   el peor de la liga .................. 38,2  (-2,9)
  ///   recorrido completo .................. 5,6 victorias
  ///
  /// Que es justo lo que la NBA real le atribuye a un banquillo. Y nótese
  /// que un entrenador medio da exactamente lo mismo que no tener ninguno:
  /// la escala está centrada, así que el entrenador desempata, no infla.
  ///
  /// Subirlo más convertiría el juego en "ficha al mejor entrenador y
  /// olvídate de la plantilla", que es exactamente lo que no se quiere:
  /// el equipo lo hacen los jugadores y el entrenador desempata.
  static const double maxAporteEntrenador = 0.7;

  /// Tope del desvío del entrenador, en recorridos. Evita que un asset
  /// futuro con un entrenador de 99 se salga de la escala prevista.
  static const double desvioMaximoEntrenador = 1.25;

  /// Minutos de referencia para "un titular con carga normal", usados para
  /// escalar pts_pg/ast_pg/trb_pg reales según los minutos asignados.
  static const double minutosReferencia = 36;

  /// Parte del escalado por minutos que NO depende de los minutos: el
  /// factor real es `pesoFijoDeMinutos + (1 - pesoFijoDeMinutos) *
  /// minutos/minutosReferencia`.
  ///
  /// Escalar los pts_pg reales directamente por `minutos/36` cuenta dos
  /// veces la reducción de los suplentes: sus pts_pg reales ya reflejan que
  /// juegan pocos minutos. Con el escalado crudo, la suma de "puntos
  /// esperados" de una rotación se quedaba muy por debajo de los 112 puntos
  /// que anota el equipo, y al normalizar el reparto todo el mundo subía —
  /// sobre todo el primer anotador, que se plantaba en 36-43 de media en
  /// vez de los 28-33 de un anotador élite real.
  static const double pesoFijoDeMinutos = 0.5;

  /// Multiplicador de peso (no de estadística directa) para la estrella de
  /// ataque/defensa designada, a la hora de calcular el rating de equipo.
  static const double multiplicadorEstrella = 1.25;

  /// Multiplicador para la estrella de ataque al repartir puntos
  /// individuales — deliberadamente más pequeño que [multiplicadorEstrella]:
  /// combinado con [multiplicadorAtributoMax] sin moderar, antes hacía que
  /// una estrella de alto rating rondara sistemáticamente los 40-50 puntos
  /// de media en la temporada en vez de los 28-33 de un anotador élite real.
  static const double multiplicadorEstrellaIndividual = 1.03;

  /// Rango del multiplicador por índice ofensivo al repartir puntos
  /// individuales (0-99 de índice mapea a
  /// [multiplicadorAtributoMin]-[multiplicadorAtributoMax]).
  static const double multiplicadorAtributoMin = 0.94;
  static const double multiplicadorAtributoMax = 1.04;

  /// Desviación estándar del ruido aplicado al marcador de cada equipo.
  ///
  /// Este ruido es INDEPENDIENTE para cada equipo, así que es el único que
  /// crea diferencia en el marcador final; el ritmo, al ser compartido, se
  /// cancela al restar los dos marcadores. Con 5,5 la diferencia de un
  /// partido tenía una desviación de solo 7,8 puntos y el mejor equipo
  /// ganaba casi siempre: en la NBA real ronda los 13,5, que es lo que hace
  /// que cualquiera pueda ganar cualquier noche.
  static const double sigmaRuidoMarcador = 8.0;

  /// Ritmo del partido: un factor compartido entre los dos equipos —se
  /// sortea una sola vez por partido, no por equipo— que sube o baja el
  /// marcador de ambos a la vez. Sin esto, cada equipo anotaba con su
  /// propio ruido independiente, y como el ruido de uno tiende a
  /// compensar el del otro, el TOTAL del partido (la suma de los dos
  /// marcadores) quedaba casi siempre en la misma franja estrecha: no
  /// había partidos de anotación claramente baja o claramente alta, todos
  /// se parecían. Con el ritmo compartido, una noche de mal tiro o de
  /// partido físico baja a los dos equipos a la vez (anotación baja de
  /// verdad) y una noche rápida los sube a los dos (tiroteo de verdad),
  /// que es como varía el ritmo en la NBA real.
  ///
  /// Bajado de 0,11 a 0,07 al subir [sigmaRuidoMarcador]: entre los dos, el
  /// total de un partido tenía una desviación de 25,6 puntos cuando la NBA
  /// real anda por los 18. Con 0,07 siguen distinguiéndose perfectamente la
  /// noche de 95-92 y el tiroteo de 130-125, pero sin totales absurdos.
  static const double sigmaRitmo = 0.07;
  static const double factorRitmoMinimo = 0.80;
  static const double factorRitmoMaximo = 1.25;

  /// Límite inferior/superior de puntos por equipo, para evitar resultados
  /// absurdos en los extremos de la distribución.
  static const int marcadorMinimo = 70;
  static const int marcadorMaximo = 165;

  /// Puntos medios de un equipo en una prórroga de 5 minutos.
  static const double puntosProrrogaMedios = 12;

  /// Desviación estándar del ruido de una prórroga. Deliberadamente más
  /// ancha de lo que saldría escalando proporcionalmente
  /// [sigmaRuidoMarcador] por la duración (5/48): con ese escalado directo
  /// el marcador de la prórroga queda tan poco disperso que dos equipos
  /// vuelven a empatar demasiado a menudo. Con este valor, una segunda
  /// prórroga (dos empates seguidos) debe rondar el ~5-8% de las veces que
  /// se llega a la primera.
  static const double sigmaRuidoProrroga = 4.5;

  /// Cuánto varía de un partido a otro lo que anota un jugador, como
  /// desviación típica sobre su reparto normal.
  ///
  /// Es lo que hace que un anotador de 30 haga 38 un día y 21 al siguiente,
  /// que es como se comporta la NBA de verdad. Medido con 2.000 partidos de
  /// un anotador de 32 puntos de media:
  ///
  ///   ruido uniforme de +-15% (lo que había) ... desviación 4,0
  ///   este ruido gaussiano ..................... desviación ~7,5
  ///   la NBA real .............................. 7-8
  ///
  /// Con el ruido viejo, de esos 2.000 partidos solo UNO bajaba de 20
  /// puntos. Una estrella que nunca tiene una mala noche no se parece a un
  /// jugador de baloncesto, se parece a una media.
  static const double sigmaRuidoAnotacion = 0.27;

  /// Suelo del multiplicador de ruido. Sin él, la cola izquierda de la
  /// campana puede dar un peso negativo y romper el reparto; y además un
  /// jugador siempre anota algo.
  static const double minRuidoAnotacion = 0.15;

  static const int marcadorProrrogaMinimo = 2;
  static const int marcadorProrrogaMaximo = 30;
}
