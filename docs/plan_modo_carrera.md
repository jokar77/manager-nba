# Modo Carrera — bitácora

Diario de sesión a sesión del Modo Carrera únicamente. El diario del modo
Franquicia (el juego original) sigue en `plan.md` — se separaron el 25 de
agosto de 2026 porque ya son dos juegos dentro del mismo repo y mezclar sus
historias en un solo fichero los hacía más difíciles de seguir a los dos.
Lo que es común a los dos modos (cómo publicar, credenciales de git, reglas
de la casa) sigue solo en `plan.md`; no se duplica aquí.

## EN CURSO — motor de dominio hecho (fases juvenil + NBA), construyendo la UI

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
