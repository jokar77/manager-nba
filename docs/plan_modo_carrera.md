# Modo Carrera — bitácora

Diario de sesión a sesión del Modo Carrera únicamente. El diario del modo
Franquicia (el juego original) sigue en `plan.md` — se separaron el 25 de
agosto de 2026 porque ya son dos juegos dentro del mismo repo y mezclar sus
historias en un solo fichero los hacía más difíciles de seguir a los dos.
Lo que es común a los dos modos (cómo publicar, credenciales de git, reglas
de la casa) sigue solo en `plan.md`; no se duplica aquí.

## ESTADO ACTUAL (leer esto primero)

**Jugable, publicado, y con más profundidad que un slice mínimo** —
inspirado en el simulador de carrera de fútbol de Copero, controlas a UN
jugador de baloncesto de los 16 años al retiro. Mismo sitio que el modo
Franquicia: [jokar77.github.io/manager-nba](https://jokar77.github.io/manager-nba/),
"Modo Jugador" en el menú de inicio (botón azul oscuro, distinto del
naranja de Franquicia).

**El camino completo, tal y como está hoy:**
1. Crear jugador — apellido y dorsal en vivo sobre una camiseta dibujada a
   mano, posición, nacionalidad (20, con bandera, hoja inferior a ancho
   completo), y la cadencia de decisión (cada 1, 2 o 3 años —
   `PartidaCarrera.cadenciaAnios`): las temporadas de en medio de una
   tanda se resuelven solas, solo la última pregunta y enseña su resumen.
2. Fase juvenil (16 → 19 años) — eliges organización de tu país
   (`rutas_juveniles.dart`), y cada temporada un evento de decisión
   (`eventos_de_carrera.dart`) te empuja la media un poco.
3. Draft — lotería de un solo jugador con la misma fórmula de valoración
   que usa la CPU en el draft real, no las 60 elecciones completas.
4. Temporadas NBA — se simulan tus partidos con el motor real
   (`simularPartido`) contra un rival sintético; evento de decisión cada
   año; MVP/Mejor Defensor/Rookie del Año/selección al All-Star por umbral
   de tu nivel con algo de azar (sin liga completa que simular, no hay 450
   candidatos reales con los que comparar). Al cerrar cada temporada, un
   aviso estilo Copero (no una tirada de dados): te quedas donde estás o
   fichas por una de dos ofertas de traspaso, cada una con su salario y
   años de contrato calculados con las fórmulas reales de mercado
   (`OfertaDeEquipo`, `elegirEquipoTemporada`). La ficha enseña tu vitrina
   de trofeos en vivo, temporada a temporada, y el escudo de tu equipo
   (`EquipoLogo`, el mismo de Franquicia) aparece en la ficha, la línea de
   tiempo, el diálogo de fin de temporada y los avisos de draft/traspaso.
5. Retiro — Salón de la Fama y camiseta retirada evaluados con las mismas
   funciones que usa cualquier jugador de franquicia; resumen final con
   PTS/AST/REB de carrera, camisetas retiradas y medallero completo.

**Piezas clave** (todas en `app/manager_nba/`):
`lib/domain/modo_carrera_repository.dart` (el motor entero),
`rutas_juveniles.dart`, `eventos_de_carrera.dart`,
`lib/features/modo_carrera/` (las tres pantallas),
`test/modo_carrera_repository_test.dart` + `crear_jugador_screen_test.dart`
+ `oferta_juvenil_screen_test.dart` + `modo_carrera_hub_screen_test.dart`.

**Reusa sin tocar, del modo Franquicia**: `CarreraJugador`/`leerCarrera()`,
`evaluarIngresosHallDeLaFama`, `retirarCamiseta`,
`salarioEstimado`/`aniosContratoEstimados`, las curvas de estadísticas, y
`HistorialPremios`/`TipoPremio` (con un valor nuevo, `allStar`, que
Franquicia nunca concede).

**Fuera de alcance, a propósito** (se puede añadir después sin rediseñar
lo que ya hay): el draft completo de 60 elecciones, premios calculados
contra una liga real de 450 jugadores en vez de por umbral, simular las
30 franquicias de fondo, más de 12 nacionalidades, las dificultades
Intensa/Normal/Exprés de Copero (hoy: un evento por temporada, siempre).

**Verificación de siempre antes de subir**: `dart analyze` limpio (o
`dart analyze` si `flutter analyze` falla por un problema de sesión del
propio analizador, no del código — ver nota más abajo) y `flutter test`
completo en verde — 708 tests a fecha de la última sesión.

**Lección de testing que costó cara dos veces**: una pantalla más
alta/rica puede dejar widgets fuera del viewport por defecto de un test
(800×600) sin ningún error real — sube `tester.view.physicalSize` antes
de dudar del widget. Y `pumpAndSettle()` nunca se asienta si hay una
`LinearProgressIndicator` indeterminada en pantalla (el `_procesando` del
menú de inicio, por ejemplo) — usa `pump()` con duración fija ahí.

---

Sesión del 25 de agosto de 2026. El usuario pidió un modo nuevo, inspirado
en el simulador de carrera de fútbol de Copero
(`copero.com.ar/juegos/simulador-carrera`): controlar a UN jugador desde
los 16 años hasta el retiro, en vez de una franquicia entera. Plan completo
en la sesión de Claude Code (no en este repo); resumen de lo decidido y
hecho:

**Alcance de esta primera entrega (confirmado con el usuario, dos veces se
recortó sobre la marcha):**
- Slice mínimo jugable de punta a punta: crear jugador → fase juvenil (16
  años, elige nacionalidad de 12 y una organización juvenil de su país) →
  draft → temporadas NBA → retiro → resumen (Hall of Fama, camiseta
  retirada si toca). **Sin** catálogo de eventos narrativos todavía.
- El draft real (`iniciarDraft`/`celebrarDraft`) y los premios de fin de
  temporada (`calcularPremios`) están construidos para una liga de 30
  franquicias jugando su temporada COMPLETA con un único equipo humano —
  reusarlos tal cual habría obligado a simular las 30 franquicias enteras
  en segundo plano cada año. Se optó por una versión ligera: draft =
  lotería de un solo jugador con la MISMA fórmula de valoración que usa la
  CPU real (`elegirPorLaCpu`); temporada NBA = solo se simulan los
  partidos de TU jugador (con el motor real `simularPartido`, contra un
  rival sintético de nivel medio) y contrato/traspaso salen de una
  probabilidad basada en las fórmulas reales de mercado, no de una
  negociación CPU-a-CPU. **Quedan fuera de esta entrega**: premios de liga
  (MVP/DPOY/ROY) y el draft completo de 60 elecciones — se podrían añadir
  si algún día se decide simular la liga entera de fondo.

**Hecho y verificado (`flutter analyze` limpio, 696 tests en verde,
subidos desde 685 — 11 nuevos en `test/modo_carrera_repository_test.dart`):**
- `lib/domain/rutas_juveniles.dart`: 12 nacionalidades (España, EEUU,
  Argentina, Francia, Serbia, Lituania, Australia, Canadá, Alemania,
  Grecia, Croacia, Brasil) con su tipo de camino juvenil (club de cantera /
  universidad / academia deportiva) y 3 organizaciones cada una (nombres
  ligeramente alterados, mismo criterio que el resto del juego).
- Tablas nuevas `PartidaCarrera` y `HistorialTemporadaJuvenil`
  (`lib/data/database/tables.dart`), migración aditiva `schemaVersion` 29
  → 30 en `app_database.dart` (una partida de franquicia en curso no se
  entera de que existen).
- `progresion_repository.dart`: la antigua `_mediaTrasUnAno` (privada, solo
  para `envejecerLiga`) pasa a ser pública (`progresionAnualDeMedia`) y
  toma números sueltos en vez de un `Jugador` de tabla — así la puede
  llamar también el jugador de carrera, que durante la fase juvenil
  todavía no tiene fila en `Jugadores`. Mismo cálculo exacto, cero cambio
  de comportamiento (los tests de progresión ya existentes lo confirman).
- `lib/domain/modo_carrera_repository.dart`: el motor entero —
  `crearPartidaCarrera`, `elegirOrganizacionJuvenil`,
  `avanzarTemporadaJuvenil`, `entrarAlDraft`, `avanzarTemporadaNba`,
  `leerPartidaCarrera`. Reusa sin tocar: `CarreraJugador`/`leerCarrera()`
  (ya lee cualquier jugador de `Jugadores`), `evaluarIngresosHallDeLaFama`,
  `retirarCamiseta`, `salarioEstimado`/`aniosContratoEstimados`,
  `puntosTipicos`/`asistenciasTipicas`/`rebotesTipicos`.

**Pendiente para que se pueda jugar de verdad**: la UI
(`lib/features/modo_carrera/`, pantallas de crear jugador, ofertas
juveniles, avance de temporada, hub NBA, retiro), entrada desde
`StartMenuScreen`, y traducir las cadenas nuevas a los 7 idiomas. Nada de
esto se ha subido a git — instrucción de siempre, se deja dicho y decide
el usuario.

## Continuación misma sesión — UI construida y enganchada al menú

- `lib/features/modo_carrera/crear_jugador_screen.dart`,
  `oferta_juvenil_screen.dart`, `modo_carrera_hub_screen.dart`: las tres
  pantallas del modo, reusando los mismos componentes visuales del resto
  del juego (`PanelCortado`, `BotonPrincipal`, `BarraNeutraAppBar`,
  `PlacaMedia`...). El hub es una única pantalla que cambia de contenido y
  de botón según la fase (juvenil → predraft → nba → retirado) en vez de
  cuatro pantallas casi vacías.
- `StartMenuScreen`: al pedirlo el usuario, "Modo Franquicia" y "Modo
  Jugador" (el nombre que se le da en la interfaz al Modo Carrera) son dos
  botones directos en el menú principal, no un botón "Nueva partida"
  genérico con un diálogo detrás — cada modo es un juego aparte desde la
  primera pantalla. Las ranuras de Modo Jugador se ven y se
  continúan/borran igual que las de franquicia, con una ficha propia sin
  colores de equipo (`ResumenSlot.carrera`, `slots_repository.dart`).
- 26 textos nuevos en los 7 idiomas (`i18n/textos_*.dart`).
- `docs/plan.md` y `docs/plan_modo_carrera.md` se separaron: cada modo
  lleva su propia bitácora desde aquí en adelante.
- Verificado: `flutter analyze` limpio, **696 tests en verde** (se
  actualizaron 3 tests de `start_menu_screen_test.dart`/`widget_test.dart`/
  `flujo_completo_test.dart` que asumían el botón "Nueva partida" de
  antes). No se ha podido probar visualmente en navegador dentro de la
  sesión de Claude Code (el panel de la herramienta no componía frames);
  queda pendiente un pase manual de verdad jugando una carrera completa.

## Misma sesión — "Modo Franquicia"/"Modo Jugador" directos, tests de las
## pantallas nuevas, y subida a `main`

- El diálogo "¿Qué quieres jugar?" se quitó: a petición del usuario, los
  dos modos van directos como botones en la primera pantalla del menú
  ("Modo Franquicia" / "Modo Jugador" — así se llama en la interfaz, el
  código y esta bitácora lo siguen llamando "carrera" por dentro).
- Tests de widgets para las tres pantallas nuevas
  (`crear_jugador_screen_test.dart`, `oferta_juvenil_screen_test.dart`,
  `modo_carrera_hub_screen_test.dart`) — **704 tests en total**.
- **Bug de CI encontrado y corregido**: el test de la fase retirado del
  hub simulaba ~40 temporadas NBA de verdad dentro de un test de widgets
  y tardaba varios minutos (el mismo camino en un test de dominio puro es
  instantáneo) — con eso el job de tests de `publicar.yml` se habría
  quedado colgado y la publicación automática nunca habría terminado.
  Corregido: una sola temporada real y el resto del estado retirado se
  fuerza directamente en la base — lo que prueba ese test es que el hub
  pinta bien esa fase, no el camino de 40 años hasta llegar a ella (eso ya
  lo cubre `modo_carrera_repository_test.dart`).
- A petición del usuario, esta sesión sí subió a git: dos commits en
  `respaldo/trabajo-en-curso`, adelantados a `main` sin merge (fast-forward
  limpio) para que se publique solo en
  [jokar77.github.io/manager-nba](https://jokar77.github.io/manager-nba/).

## Misma sesión, tramo final (04:00-05:00 del 25 de agosto) — tres arreglos
## más, todos subidos a `main`

1. **Choques de dorsal al draftear.** El dorsal se elige al crear el
   personaje, antes de saber qué equipo te va a fichar, así que podía
   coincidir con el de alguien ya en esa plantilla. Se reusa
   `asignarDorsalesQueFalten` (`dorsales_repository.dart`) justo después de
   insertar al jugador en `entrarAlDraft` — el mismo mecanismo que ya
   resuelve esto para los rookies del draft real: se queda con el número
   quien tenga mejor media, al otro se le asigna uno libre. Test de
   regresión en `modo_carrera_repository_test.dart`.
2. **Cobertura de renovación/traspaso de contrato.** Hasta ahora ningún
   test comprobaba directamente que, al agotarse el contrato o saltar la
   probabilidad de traspaso a mitad de temporada, salario y años de
   contrato quedaran en un estado válido. Nuevo test con semilla 3: en 10
   temporadas se ve al menos una renovación fallida o un traspaso.
3. **Bug de verdad, no de test: el Modo Carrera nunca importaba a los 646
   jugadores reales.** `_empezarCarreraEn` (en `start_menu_screen.dart`)
   no llamaba a `importarJugadoresSiHaceFalta`, a diferencia de `_empezarEn`
   (su equivalente en franquicia) — así que toda partida de Modo Carrera
   empezada desde el menú arrancaba con la tabla `Jugadores` vacía. Sin
   jugadores reales, `entrarAlDraft` evaluaba 30 plantillas vacías y el
   draft caía casi al azar en vez de mirar necesidades de plantilla de
   verdad. Corregido con la misma llamada que usa franquicia, más el
   backfill (`anadirJugadoresQueFaltenDelDataset`) al continuar una
   carrera ya empezada. **Esto no lo detectó ningún test de esta sesión**
   porque `modo_carrera_repository_test.dart` importa los jugadores en su
   propio `setUp` — probaba el motor con datos reales, pero nunca probó
   que el CAMINO DESDE EL MENÚ también los pusiera ahí. Lección para la
   próxima vez que se añada un modo nuevo: un test de integración que
   arranque desde `StartMenuScreen` de verdad, no solo tests del
   repositorio con el `setUp` ya preparado.

**Por qué el punto 3 no tiene test de interfaz**: al tocar "EMPEZAR", el
menú de detrás sigue visible tapado por la pantalla nueva y enseña una
`LinearProgressIndicator` indeterminada mientras `_procesando` es true
(hasta que termina TODA la cadena de pantallas, no solo la importación) —
eso anima sin parar y ni `pumpAndSettle()` ni `pump()` repetido con
duración fija consiguen que el árbol se "asiente" para poder comprobar
que `CrearJugadorScreen` ya está en pantalla. Se verificó a mano leyendo
el código (llamada simétrica a la de `_empezarEn`, que sí está probada) y
con `modo_carrera_repository_test.dart`, que ya prueba el draft con
jugadores reales importados.

Verificado antes de subir: `dart analyze` limpio, **706 tests en verde**
(`flutter test` completo, no solo los ficheros tocados).

## Sesión del 25 de agosto (tarde) — se parece a Copero de verdad

El usuario mandó una captura de la ficha de jugador de Copero y pidió que
el Modo Carrera se le pareciera más:

- **Identidad propia**: botón "Modo Jugador" y acento de las tres
  pantallas en azul oscuro (`colorModoCarrera`,
  `lib/shared/estilo.dart`), en vez del naranja de franquicia.
- **Camiseta grande en "Crea tu jugador"**: silueta de camiseta de
  básquet dibujada a mano con `CustomPainter` (sin imagen ni asset), con
  el dorsal y el apellido cambiando en vivo mientras escribes —
  `CamisetaJugador`, `lib/features/modo_carrera/crear_jugador_screen.dart`.
- **Selector de nacionalidad con bandera**: hoja inferior con las 12
  banderas a ancho completo en vez del desplegable nativo; cada
  `RutaJuvenil` lleva ahora su `bandera` (emoji, `rutas_juveniles.dart`).
- **Hub con línea de tiempo**: la ficha enseña bandera + dorsal/puesto +
  PJ/PTS/AST de la última temporada, y debajo una fila por cada
  temporada jugada (edad, club/organización, media, PJ/PTS/AST) — nueva
  `leerLineaDeTiempo()` en `modo_carrera_repository.dart`, que junta las
  dos tablas de historial que ya existían sin tocarlas.

**Lección de testing que se repitió dos veces esta sesión**: una pantalla
más alta/rica (camiseta grande, línea de tiempo) puede dejar widgets
fuera del viewport por defecto de un test (800×600) sin que haya ningún
error real — `find.byType`/`find.text` simplemente no encuentran nada
porque Flutter no construye lo que está fuera de la vista dentro de un
`ListView`/sliver. Antes de dar un test por roto, subir el tamaño de
vista del test (`tester.view.physicalSize`) como ya hacía
`start_menu_screen_test.dart`.

Verificado: `dart analyze` limpio, 706 tests en verde. **No se ha podido
verificar visualmente en navegador** en ninguna sesión de hoy — el panel
de Claude Code no compone frames en este entorno y la extensión de
Chrome no está conectada; toda la verificación de esta entrega es por
tests automatizados + lectura del código, no por haberlo visto
renderizado. Pendiente de que el usuario lo confirme jugando en
[jokar77.github.io/manager-nba](https://jokar77.github.io/manager-nba/).

## Misma tarde — primer catálogo de eventos de decisión

El usuario pidió eventos que, por ejemplo, sumen media — el "Fuera de
alcance" que el plan original dejaba para más adelante (ver el aviso de
alcance al principio de este documento: los eventos con protagonista
propio del jugador de carrera). Primera versión, deliberadamente simple:

- `lib/domain/eventos_de_carrera.dart`: catálogo de 6 eventos (plan de
  pretemporada, horas de tiro, estudiar vídeo, molestia en la rodilla,
  preparador físico, vida fuera de la cancha), cada uno con 2-3 opciones
  y un efecto directo en la media (de -1 a +2). Sin condiciones de
  contexto todavía — un evento al azar del catálogo, cada temporada.
- `avanzarTemporadaJuvenil`/`avanzarTemporadaNba` (`modo_carrera_
  repository.dart`) aceptan ahora un `efectoMedia` opcional (por defecto
  0, así que los tests y llamadas antiguas no cambian de comportamiento)
  que se suma DESPUÉS de la progresión normal — nunca sustituye el
  crecimiento natural, solo lo empuja un poco.
- Hub: antes de simular la temporada (juvenil o NBA — la entrada al
  draft no lleva evento), un diálogo no descartable presenta el evento y
  sus opciones; la elegida se aplica a esa misma temporada y su mensaje
  sale en el resumen.

Fuera de esta entrega todavía: eventos con condición de contexto (edad,
fase, forma...) y otros efectos además de la media (lesiones, dinero,
moral...) — el mismo patrón de `efectoMedia` se puede ampliar sin tocar
cómo se dispara ni se elige el evento.

Verificado: `dart analyze` limpio, **708 tests en verde**, incluidos dos
nuevos que comprueban que el efecto se nota de verdad en la media
(juvenil y NBA). Los tests de widgets del hub se actualizaron para
elegir una opción del evento antes de esperar el resumen de temporada.

## Misma tarde — premios individuales y resumen final más completo

El usuario pidió que entrar al All-Star o ganar premios individuales
contara para algo, y que al retirarte salga un resumen de verdad.

- **`TipoPremio.allStar`**: valor nuevo en el enum COMPARTIDO con el modo
  Franquicia (`tipo_premio.dart`) — selección al All-Star, distinto de
  `mvpAllStar` (que ya existía y es ganar el partido). Franquicia nunca
  lo concede (no simula votación de aficionados), así que no cambia nada
  del juego de siempre; hizo falta añadir un caso a
  `premios_screen.dart` (switch exhaustivo) y un peso en
  `hall_fama_repository.dart` (4 puntos, cuenta para el Salón de la
  Fama) — ningún jugador de franquicia real puede ganarlo, así que
  tampoco cambia su puntuación.
- **Sin liga completa que simular, no hay con qué comparar candidatos de
  verdad** (mismo motivo de alcance de siempre) — así que MVP, Mejor
  Defensor, Rookie del Año y la propia selección al All-Star son un
  umbral de tu nivel (`jugador.media`/`atrDefensa`) con una probabilidad,
  no el cálculo real de `premios_repository.dart`. Se calculan en
  `avanzarTemporadaNba` y se guardan en `HistorialPremios` — LA MISMA
  tabla que usa el resto del juego — así que cuentan solos para el Salón
  de la Fama y para `leerCarrera()`/`CarreraJugador`, sin tocar ese
  código.
- **Resumen de temporada**: el diálogo de cada temporada NBA anuncia los
  premios ganados ese año.
- **Resumen final de verdad**: `_ResumenDeRetiro` (la tarjeta que se
  queda en pantalla al terminar la carrera, no un diálogo que
  desaparece) ahora enseña, además de PTS/AST/REB: si entraste en el
  Salón de la Fama, qué camisetas se retiraron y en qué equipos, y una
  fila de medallas con cada premio individual y cuántas veces lo
  ganaste.

Verificado: `dart analyze` limpio, 708 tests en verde. Un test de
dominio (`el contrato se renueva o cambia de equipo...`) dejó de
cumplirse con su semilla de siempre porque los nuevos sorteos de premios
desplazan la secuencia de números aleatorios que consume esa semilla
— no es un bug, es lo esperable al añadir tiradas de azar nuevas antes
en la misma función. Se cambió la semilla (de 3 a 2) hasta encontrar una
que sí cumple la condición dentro de las mismas 10 temporadas.

## Misma tarde — vitrina de trofeos también DURANTE la carrera

La ficha de la fase NBA solo enseñaba los premios en el resumen final de
retiro; ahora también los enseña en vivo, temporada a temporada, con la
misma "vitrina vacía" de Copero cuando todavía no has ganado nada
(`vitrinaVaciaLabel`, nuevo en los 7 idiomas). Nuevo `Future<CarreraJugador?>`
en el estado del hub, refrescado junto a la línea de tiempo cada vez que
avanzas — la ficha activa y el resumen de retiro comparten ahora el mismo
patrón de medallas (`_EtiquetaDePremio`).

Verificado: `dart analyze` limpio, 708 tests en verde (incluidos los del
modo Franquicia que tocan `TipoPremio`/`premios_repository.dart`, sin
cambios de comportamiento ahí).

## Sesión del 25 de agosto de 2026 (tarde) — el traspaso de fin de
temporada pasa a ser una decisión tuya, como en Copero

El usuario lo pidió explícito: "tiene que haber una simulacion de
traspasos despues de cada temporada... debe aparecer un aviso de
quedarme en el equipo o ser traspasado a 2 opciones de equipos". Antes,
`avanzarTemporadaNba` decidía equipo/contrato en solitario (probabilidad
de renovar o de traspaso a mitad de contrato) y solo informaba del
resultado a toro pasado — nada que elegir.

Rediseño en `lib/domain/modo_carrera_repository.dart`:
- Nueva clase `OfertaDeEquipo` (equipo, salario, años de contrato).
- `ResumenTemporadaNba` cambia `cambioDeEquipo: bool` por
  `ofertaQuedarse: OfertaDeEquipo` + `ofertasDeTraspaso: List<OfertaDeEquipo>`
  (siempre 2, calculadas con `_mejorEquipoPara` — que ahora excluye un
  `Set<String>` en vez de un único equipo, para poder pedir "el mejor
  EXCLUYENDO estos dos"). Las tres ofertas usan las mismas fórmulas reales
  de mercado que ya existían (`salarioEstimado`/`aniosContratoEstimados`).
- `avanzarTemporadaNba` ya NO escribe equipo/salario/años de contrato en
  `Jugadores` — solo edad/media/potencial (que no dependen de la
  decisión) y las tres ofertas del resumen. Se quitaron las constantes de
  probabilidad (`_probabilidadDeTraspaso`, `_probabilidadDeRenovar`), ya
  no tienen sentido con una decisión explícita.
- Nueva función `elegirEquipoTemporada(db, ofertaElegida)`: aplica la
  oferta que haya tomado el jugador a la fila real. Hay que llamarla
  siempre tras `avanzarTemporadaNba` en fase NBA activa (si no se llama,
  el contrato se queda congelado — lo hace la propia UI del hub, que no
  deja seguir sin elegir).

UI (`modo_carrera_hub_screen.dart`): tras el resumen de la temporada, un
diálogo no descartable con hasta 3 botones — "Quedarme en X" primero,
luego las dos ofertas de traspaso, cada uno con el contrato en una línea
(`contratoAnioMillones`/`formatearMillones`, reusados de
`hoja_de_propuestas.dart`). Si eliges un equipo distinto del actual, se
enseña el mismo aviso de "nuevo equipo" que ya existía.

i18n: 2 claves nuevas en los 7 idiomas (`decisionDeEquipoTitulo`,
`quedarmeEnMiEquipoBtn`); `ficharPorBtn` se reusó tal cual (ya existía
para las ofertas juveniles, mismo patrón "Fichar por X").

El test de dominio que antes dependía de una semilla concreta para forzar
un cambio de equipo por azar (`Random(2)`, comentado arriba) se rehízo
sin depender de azar: ahora alterna a propósito quedarse/traspasarse
cada temporada durante 10 temporadas y comprueba que las tres ofertas son
de equipos distintos y que la fila de `Jugadores` queda exactamente como
la oferta elegida — más determinista y ya no es rehén de futuros cambios
de secuencia de `Random`. El test de widget de la fase NBA se amplió para
tapear también el nuevo diálogo (3 `OutlinedButton`, se toca el primero
= quedarse).

Verificado: `dart analyze` limpio (fichero por fichero y luego el
paquete entero), `flutter test` completo — 708 tests en verde (mismo
número: se sustituyó un test, no se añadió). Intento de verificación
visual en navegador (`flutter run -d web-server`): la app carga y arranca
sin errores en consola, pero este entorno concreto no tiene el panel de
navegador visible para hacer capturas, y Flutter Web (CanvasKit) no
expone árbol de accesibilidad por defecto — así que la verificación aquí
se apoyó en los tests de widget (que sí tapean el diálogo real) en vez de
una inspección visual pixel a pixel.

## Misma tarde — el escudo del equipo, en todos los sitios donde antes
solo había texto (o el código en crudo)

El usuario lo pidió mirando a Copero otra vez: "que salga el logo del
equipo". Modo Carrera nunca usaba `EquipoLogo` (el escudo de dos colores
que ya usan las treinta pantallas del modo Franquicia — sin imágenes
reales, ver la nota legal de `roadmap.md`) — llevaba el nombre del
equipo siempre en texto plano. Se añadió en los cinco sitios de
`modo_carrera_hub_screen.dart` donde aparece un equipo real de los 30:

- La ficha del jugador (equipo actual, junto al nombre completo).
- Cada fila de la línea de tiempo con partidos jugados — de paso se
  arregló que enseñaba el CÓDIGO en crudo del equipo ("ATL") en vez del
  nombre completo, algo que ya hacían bien las filas de la fase juvenil.
- El diálogo de fin de temporada (quedarme / las dos ofertas de
  traspaso): escudo junto al nombre en cada uno de los 3 botones.
- El resultado del draft y el aviso de "nuevo equipo": diálogo nuevo,
  `_dialogoConEquipo`, con el escudo grande (56) por delante del mensaje
  — mismo patrón que el diálogo simple de siempre, pero con protagonismo
  para el escudo, como en Copero.
- Las camisetas retiradas del resumen final: antes una lista de nombres
  separada por comas, ahora un escudo + nombre por cada una.

Verificado: `dart analyze` limpio, `flutter test` completo — 708 tests
en verde (ningún test dependía del texto exacto que se tocó). No se
pudo repetir la verificación visual en navegador por la misma limitación
de entorno de la entrada anterior (sin panel visible, sin árbol de
accesibilidad en CanvasKit).

## Cuatro fallos y una función nueva, jugando de verdad (a 2026-08-26)

El usuario lo reportó jugando una partida real. Cinco pedidos, resueltos
todos en la misma sesión:

**1. El sueldo, no el "valor" estimado, una vez en la NBA.** La ficha
enseñaba `salarioEstimado(media, edad)` (una estimación de mercado)
incluso ya con un contrato real firmado. `EstadoCarrera` gana
`salario`/`aniosContrato` (de `Jugador`, `null` en fase juvenil); la
ficha enseña el contrato real con el mismo formato que el resto del
juego (`contratoAnioMillones`/`aniosDeContrato`/`formatearMillones`) en
cuanto hay uno, y sigue con la estimación mientras no lo hay.

**2. Estadísticas también antes de la NBA.** La fila PJ/PTS/AST de la
ficha filtraba por `partidos > 0` — y las temporadas juveniles
(`HistorialTemporadaJuvenil`) nunca tuvieron columna de partidos
(no se sigue boxscore ahí, solo medias por partido), así que ese filtro
las descartaba TODAS y la ficha enseñaba ceros durante toda la fase
juvenil. Arreglo: se usa la temporada más reciente sin filtrar por
partidos — la fase NBA ya traía sus PJ de verdad, la juvenil ahora
enseña sus PTS/AST reales (con PJ en 0, porque de verdad no se cuentan
ahí).

**3. "Me han drafteado en zona Este" — bug de verdad, no una forma
rara de hablar.** `equiposInfo` (`equipos_info.dart`) también contiene
4 entradas que NO son de las 30 franquicias: `'Este'`, `'Oeste'`
(las selecciones del All-Star) y `'Novatos'`/`'Sophomores'` (Rising
Stars) — viven ahí para reusar el mismo widget de escudo/colores en las
pantallas del All-Star. `_mejorEquipoPara` (el motor de draft y de
ofertas de traspaso de Modo Carrera) iteraba `equiposInfo.keys` en
crudo, así que estas 4 entradas podían "ficharte" como si fueran un
equipo real. Arreglo en dos sitios: `equipos_especiales.dart` gana
`equiposDeAllStar` y `esFranquicia` ahora también las excluye;
`_mejorEquipoPara` filtra por `esFranquicia` antes de evaluar cada
"equipo". Tests nuevos en `modo_carrera_repository_test.dart`
comprobando que ni el draft ni las ofertas de traspaso caen nunca en
una de las 4.

**4. Botón para volver al menú principal.** El hub tenía
`conVolver: false` a propósito en `BarraNeutraAppBar` — quitado. Se
comprobó que todos los caminos de navegación hasta el hub (continuar
una carrera, o crear una nueva con `pushAndRemoveUntil(...,
(route) => route.isFirst)` de por medio) dejan el menú de inicio justo
debajo en la pila, así que un `pop()` normal ya vuelve al sitio
correcto sin más cambios.

**5. Cadencia de decisión: cada 1, 2 o 3 años.** Pedido nuevo: "antes
de empezar a jugar" poder elegir cada cuánto para la carrera a
preguntar (evento de la temporada, resumen, oferta de equipo) en vez de
cada temporada sin falta. Se eligió UNA VEZ al crear el jugador
(`crear_jugador_screen.dart`, tres `ChoiceChip` junto al resto del
formulario) y se guarda en la partida:
- `PartidaCarrera.cadenciaAnios` (columna nueva, esquema 30→31,
  aditiva con valor por defecto 1 — una carrera ya empezada sigue
  preguntando cada año hasta que se cree una nueva).
- `IdentidadCarrera.cadenciaAnios` (opcional, por defecto 1) y
  `EstadoCarrera.cadenciaAnios` hacen de transporte hasta la UI.

El motor (`avanzarTemporadaJuvenil`/`avanzarTemporadaNba`) NO cambió —
sigue haciendo una temporada por llamada, con su contrato de siempre.
Toda la "tanda" vive en `modo_carrera_hub_screen.dart`: `_avanzarJuvenil`
y `_avanzarNba` ahora llaman al motor en un bucle de `cadenciaAnios`
vueltas; en las que NO son la última de la tanda, el evento se resuelve
con su primera opción y (en NBA) la decisión de equipo es "quedarme",
sin enseñar ningún diálogo — solo la última pregunta de verdad y enseña
su resumen, exactamente como con cadencia de 1. Dos salidas tempranas
que cortan la tanda aunque no sea la última vuelta: pasar a fase
predraft (fase juvenil) y el retiro (fase NBA) — ninguna de las dos se
salta nunca, aunque caigan en medio de una tanda de 2 o 3 años.

Un fallo de mi propio primer intento, cazado por el test antes de subir
nada: había puesto el diálogo de "elegir equipo" ANTES del resumen de
la temporada en vez de después, rompiendo el orden que ya esperaba
`modo_carrera_hub_screen_test.dart` (evento → resumen → equipo). Quedó
todo dentro del cuerpo del bucle, en el orden correcto, en vez de
repartido antes/después del bucle.

Verificado: `dart run build_runner build` (esquema 31), `dart analyze`
limpio, `flutter test` completo. Tests nuevos: 2 en
`modo_carrera_repository_test.dart` (cadencia se guarda y se lee;
cadencia fuera de 1-3 rechazada) + 2 en `modo_carrera_repository_test.dart`
para el bug de las selecciones del All-Star + 1 en
`crear_jugador_screen_test.dart` (elegir "Cada 2 años" viaja hasta la
partida) + 1 en `modo_carrera_hub_screen_test.dart` (con cadencia 2, un
solo toque simula dos temporadas y solo pregunta una vez). 716 tests en
total tras esta entrada.

## Más variedad en los eventos de temporada (a 2026-08-26)

Pedido corto: "más variedad de opciones al terminar la temporada... irte
de vacaciones o entrenar todo el verano etc". El catálogo de
`eventos_de_carrera.dart` tenía 6 eventos desde que se creó; pasa a 12,
doblando la variedad con la que sale un evento al azar cada temporada.
Nuevos, todos con el mismo patrón de siempre (`EventoDeCarrera` con 2-3
`OpcionDeEventoDeCarrera`, cada una con su `efectoMedia`):

- **"Se acaba la temporada: ¿y el verano?"** — el pedido explícito:
  desconectar del todo, vacaciones con algo de trabajo, o entrenar todo
  el verano (de -1 a +2 de media, el extremo más arriesgado da más).
- Torneo de verano, cambio de dieta, oferta publicitaria (dinero fácil
  a cambio de tiempo de entrenamiento), sesiones con un psicólogo
  deportivo, y dar un paso adelante cuando se lesiona un compañero de
  posición en pretemporada.

Nota para la próxima vez que se toque este fichero: sigue siendo
Spanish-only, sin pasar por `Textos`/los 7 idiomas — es una
simplificación que ya venía de cuando se creó el catálogo (a diferencia
de `eventos_narrativos.dart` del modo Franquicia, que sí tiene su propio
`TextosDeEventos` traducido). No se ha cambiado eso aquí, solo se ha
seguido el mismo patrón que ya había.

Verificado: `dart analyze` limpio, `dart format` sobre el fichero (las
líneas nuevas se pasaban de largo — ojo, el proyecto entero tiene
desviaciones de formato preexistentes en unos 200 ficheros más, nada que
ver con esta entrada, así que no se corrió `dart format` sobre nada más
que este fichero). Tests de Modo Carrera en verde; no hace falta test
dedicado para el catálogo (nada depende de su longitud ni de qué evento
concreto sale, `eventoDeCarreraAleatorio` solo se usa desde la UI).

## Comparado con Copero de verdad, y 8 nacionalidades más (a 2026-08-26)

El usuario pidió explícitamente seguir mejorando Modo Carrera fijándome
en Copero, así que esta vez se abrió el simulador de verdad
(`copero.com.ar/juegos/simulador-carrera`) y se jugó una partida entera
para comparar pantalla a pantalla en vez de trabajar de memoria.

**Confirmado que ya tenemos paridad real** en varias cosas que se
construyeron sin haber visto Copero en detalle todavía:
- La cadencia Intensa/Normal/Exprés de Copero es literalmente
  "decisión cada 1/2/3 temporadas" — el mismo concepto que se añadió
  hoy mismo antes de mirar la web.
- Su "Mercado de pases" (quedarte o fichar por una de dos ofertas al
  cerrar cada tramo) es el mismo mecanismo que
  `avanzarTemporadaNba`/`elegirEquipoTemporada` ya hacen.
- La "vitrina vacía" cuando no has ganado nada tiene el mismo nombre
  (🏆 VITRINA VACÍA) que ya usábamos.
- El aviso legal de nombres de clubes ficticios es del mismo tipo que
  el que ya lleva este juego para equipos/jugadores NBA.

**La diferencia real y accionable**: Copero ofrece 24 nacionalidades en
su selector inicial, con un botón "VER MÁS" que da a entender que hay
todavía más — nosotros teníamos 12. Se amplió a 20, doblando casi la
lista, con el mismo criterio ya establecido (organización real del
país, nombre alterado 1-2 letras): Italia, Turquía, Eslovenia, Israel,
República Dominicana, Puerto Rico, China y México — todos con tradición
real de baloncesto (Eslovenia por Dončić, Turquía/Israel por la
Euroliga, República Dominicana/Puerto Rico por el baloncesto
caribeño, China por la CBA). Solo toca `rutas_juveniles.dart`, ningún
otro fichero — el resto del sistema (selector de nacionalidad, ofertas
juveniles) ya estaba escrito para leer del mapa sin asumir un número
fijo de entradas.

**Cosas de Copero que NO se han portado, a propósito:**
- Logros/"Ver logros": requiere cuenta de usuario propia (login) para
  sincronizar entre dispositivos — sigue fuera de alcance, ya estaba
  anotado así desde la sesión de creación.
- "Pierna hábil" (dominante): específico de fútbol, sin equivalente
  claro y valioso en baloncesto.
- Los tramos de carrera en Copero muestran también la categoría/liga
  del club en cada oferta (p. ej. "Primera Nacional", "Liga
  Profesional") — nuestras organizaciones no llevan ese dato. Se podría
  añadir un campo de categoría a `RutaJuvenil` más adelante si se
  decide que aporta.

Verificado: `dart analyze` limpio, `flutter test` completo — sin tests
nuevos (nada depende del número de nacionalidades, y no hay ningún test
que asuma que son 12).
