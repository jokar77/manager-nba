# ESTADO ACTUAL (leer esto primero)

**El juego está PUBLICADO y jugable en:**

```
https://jokar77.github.io/manager-nba/
```

Verificado con peticiones reales: HTTP 200, `base href = /manager-nba/`, el
service worker se registra, y los nueve ficheros críticos se sirven —
incluidos `sqlite3.wasm` (731 KB) y `canvaskit.wasm` (7 MB).

- **Repositorio:** `https://github.com/jokar77/manager-nba` (público, rama
  `main`). El usuario es `jokar77`.
- **Publicación automática:** cada `git push` dispara
  `.github/workflows/publicar.yml`, que compila, **pasa los 320 tests** y
  despliega en GitHub Pages. Si los tests fallan NO se publica.
- En Settings → Pages, *Source* está en **GitHub Actions** (ya configurado).
- `gh` CLI NO está instalado; `git` sí (2.55). El push lo hace el usuario a
  mano porque necesita autenticarse.
- Verificación local: `flutter analyze` limpio y **322/322 tests pasando**.

## Hecho el 4 de agosto de 2026

**Almacenamiento persistente: HECHO.** `web/index.html` pide
`navigator.storage.persist()` al arrancar (solo si no lo tiene ya). Sin
esto Safari podía borrar los datos de una web que llevara semanas sin
abrirse y llevarse por delante una partida de diez temporadas. iOS lo
concede sin preguntar cuando la web está añadida a la pantalla de inicio;
si el navegador dice que no, se avisa por consola y se sigue jugando.

Con ello **`CACHE` en `web/sw.js` sube a `manager-nba-v2`**. Es
obligatorio y se olvida fácil: `index.html` está en la lista de
precacheados, así que sin subir la versión los navegadores que ya tengan
el juego seguirían sirviendo el `index.html` viejo y el cambio no llegaría
nunca. Vale para cualquier cambio en `web/`, no solo en `sw.js`.

**README:** el enlace ya apunta a `https://jokar77.github.io/manager-nba/`
(antes tenía el marcador `USUARIO/REPOSITORIO`).

### Tu equipo se descolgaba de la liga cada verano (dos asimetrías)

El bug más gordo encontrado hasta ahora, y estuvo escondido detrás de
tests verdes desde siempre. Medido jugando **cuatro temporadas completas
por el camino real** (partidos incluidos) con tres comportamientos de
usuario distintos y la misma semilla:

| | T1 | T2 | T3 | T4 | top-8 final |
|---|---|---|---|---|---|
| ni renueva ni ficha | 41-41 | 35-47 | 12-70 | **4-78** | 74,4 |
| solo renueva | 57-25 | 18-64 | 33-49 | 38-44 | 81,0 |
| renueva y ficha hasta 18 | 55-27 | 29-53 | 51-31 | 50-32 | 87,0 |

Su masa salarial caía de 237M a 54M mientras la liga se movía en 200M.
Dos causas independientes, las dos silenciosas:

1. **13 contra 18.** El único objetivo de plantilla que existía para tu
   equipo era `plantillaMinima` (13). Las 29 de la CPU acaban el verano en
   `plantillaMaxima` (18). Y la pantalla de agencia libre te ponía
   "Plantilla lista" en verde al llegar a 13, sin decirte que ibas cinco
   por detrás de todos tus rivales.
2. **Sin mecanismo de reequilibrio.** `colocarAgentesLibresDeNivel`
   convierte espacio salarial en jugadores cada verano ofreciendo a los
   agentes libres buenos al equipo con más margen — y **excluía a tu
   equipo siempre**, no solo durante tu ventana de mercado. Con 150M sin
   gastar no se te ofrecía a nadie nunca, así que un año malo no tenía
   suelo.

**Arreglo.** `HuecosDePlantilla` gana `fichajesRecomendados` y
`plantillaAlCompleto` (el listón de 18) junto al mínimo de 13, que sigue
siendo el que bloquea. `completarPlantillaConElMinimo` acepta `hasta:`.
Al cerrar tu ventana, tu equipo se completa hasta 18 con los restos y
entra en el reparto de agentes libres **con un tope: nada de media 82 o
más**. La pantalla dice ahora "Plantilla: 13 de 18" y explica el hueco.

**El tope importa tanto como el reparto.** Sin él la medición se iba al
otro extremo: el usuario que no tocaba nada acababa 59-23 con la mejor
plantilla de la liga —le fichaban solo a un jugador de media 98—, o sea
que jugar el mercado dejaba de servir para nada. Con tope, el usuario
ausente se queda en 30-52: mediocre, que es la consecuencia correcta.

Regresión en `test/tu_equipo_no_se_descuelga_test.dart`, con los dos
lados cubiertos y **comprobado que falla con el código viejo** (13 contra
18) y que el segundo falla si se quita el tope.

**Aviso honesto sobre lo medido:** con el arreglo, la diferencia entre
jugar el mercado y no jugarlo queda en ~8 victorias sobre una sola
semilla y cuatro temporadas. Eso está dentro del ruido de esta
simulación: sirve para afirmar que la espiral desapareció, no para
afirmar que el equilibrio esté fino. Si se quiere ajustar, hay que medir
con varias semillas.

## Cómo se reparte a los amigos

Se les pasa el enlace y ya: no hay registro ni instalación. En **iPhone hay
que abrirlo con Safari** (Chrome en iOS no sabe instalar webs) → Compartir →
Añadir a pantalla de inicio. En Android, Chrome ofrece "Instalar aplicación".

La primera apertura necesita conexión (~17 MB); después funciona sin datos.
Cada persona tiene su partida en su propio dispositivo: no se comparten ni
se sincronizan entre el móvil y el PC de la misma persona.

## Cómo se trabaja aquí (lo que ha funcionado)

Escrito porque se ha demostrado tres veces en las últimas dos listas, y
porque razonar sobre el código en vez de medirlo llevó a conclusiones
falsas varias veces:

**Medir por el camino real ANTES de arreglar.** Los bugs gordos de las
partes 7 y 8 se encontraron todos escribiendo un test de diagnóstico
desechable que replicaba el flujo del juego, no leyendo el código. En los
cuatro casos los tests existentes pasaban mientras el camino real estaba
roto.

**Descartar hipótesis con números, no con intuición.** En P8-1 ("los Wolves
acaban últimos") se descartaron por medición: las lesiones (2 frente a 3,7
de media), que la alineación del usuario fuera peor que la de la CPU (50,1%
en 9000 partidos) y que la media no prediga la fuerza (r=0,84, sí la
predice). La causa real —el orden del verano— no se parecía a ninguna de
las tres.

**Cuidado con las muestras pequeñas.** Una medición de 4 temporadas dio "10
victorias de diferencia" que resultó ser ruido; la plantilla se genera con
aleatoriedad en cada partida y MIN oscilaba entre 25 y 54 victorias. Los
estadísticos de baja varianza (medias sobre 9000 partidos, huecos de rating
día a día) dijeron la verdad; el máximo o una muestra de 4, no.

**Probar que el test falla con el código viejo.** Antes de dar por bueno un
arreglo. Si el test pasa igual sin el arreglo, no está midiendo el bug.

**Los diagnósticos desechables se borran** al terminar (`zz_diag_*.dart`),
dejando solo el test de regresión definitivo.

---

# Objetivo del proyecto (leer antes que nada)

**Manager NBA se hace para jugarlo en móvil y en tablet, y tiene que poder
jugarse igual en PC.** No son dos versiones: es una sola app que se
reordena según el ancho disponible (ver `lib/shared/pantalla.dart`, cortes
en 600 y 1024).

Esto estuvo sin escribir durante las seis primeras fases y se perdió: todo
se construyó y se verificó con `flutter run -d windows`, y de las 31
pantallas solo 3 tenían algo de diseño adaptable. La Fase 7 corrige ese
rumbo. **Cualquier pantalla nueva o cambiada tiene que verse bien en las
tres medidas** y entrar en `test/adaptacion_movil_test.dart`, que monta las
pantallas a 390x844 (iPhone), 820x1180 (iPad) y 1600x900 (escritorio) y
falla si alguna desborda.

## Distribución: el móvil del usuario es un iPhone

Android compila desde el PC tal cual, pero **el móvil es iOS**, y desde
Windows no se puede compilar para iOS: Xcode solo existe en macOS. Quedan
dos caminos, y solo uno se puede recorrer desde este PC:

1. Un Mac (propio, prestado o alquilado) → instalación directa o TestFlight.
2. **Web + PWA**: se abre en Safari y se añade a la pantalla de inicio. Sin
   Mac y sin App Store. Es el camino elegido, y ya está hecho (abajo).

### El port a WASM (hecho)

La capa de datos ya no sabe en qué plataforma está. Tres ficheros:

- `data/database/almacenamiento.dart` — la fachada. Es lo único que ven
  `app_database.dart` y `slots_repository.dart`.
- `almacenamiento_nativo.dart` — escritorio y móvil: ficheros SQLite en la
  carpeta de documentos. **El camino de siempre, sin tocar.**
- `almacenamiento_web.dart` — navegador: `WasmDatabase` sobre OPFS o
  IndexedDB (lo elige drift solo), y `localStorage` para saber qué ranuras
  tienen partida sin abrirlas.

Los assets `web/sqlite3.wasm` y `web/drift_worker.js` están fijados a las
mismas versiones del `pubspec.lock` (sqlite3 3.5.0 y drift 2.34.3). Si se
sube cualquiera de las dos dependencias hay que volver a bajarlos de los
releases de `simolus3/sqlite3.dart` y `simolus3/drift`, o la web dejará de
arrancar.

Dos trampas que costaron un rato y conviene no repetir:

- Cualquier `NativeDatabase` o `dart:io` que quede en `lib/` tumba la
  compilación web entera con `dart:ffi is not available on this platform`,
  aunque sea código que en web no se ejecute nunca. Por eso las bases en
  memoria de los tests salen de `baseDeDatosEnMemoria()` y no de
  `NativeDatabase.memory()` escrito directamente.
- Flutter web solo pinta con `requestAnimationFrame`, que no se dispara en
  una pestaña oculta. Una pantalla en blanco al comprobarlo en un navegador
  sin mostrar no significa que la app esté rota — hay que mirarla visible.

Rendimiento en WASM: **confirmado por el usuario**, va bien y sin cargas
largas tras dos temporadas jugadas. Las partidas del escritorio NO se
transfieren al navegador (son almacenamientos distintos: en el navegador se
empieza de cero).

### Sin conexión (hecho y verificado)

El juego funciona en el metro o en un avión. Piezas:

- `web/sw.js` — service worker escrito a mano. Hace falta porque
  `flutter build web` deja el suyo **vacío (0 bytes)** en esta versión, así
  que sin él no se guardaba nada. Precarga 28 ficheros al instalar y luego
  va a caché primero, guardando por el camino lo que no estuviera.
- `web/index.html` — lo registra, y añade lo que iOS necesita para abrirse
  como app desde la pantalla de inicio (`apple-mobile-web-app-capable`,
  `viewport-fit=cover` para el notch, sin rebote elástico al arrastrar).
- `web/manifest.json` — nombre, colores e iconos de verdad.

**Compilar SIEMPRE así**, o no funcionará sin conexión:

```
flutter build web --release --no-web-resources-cdn --pwa-strategy=none
```

`--no-web-resources-cdn` es el que importa: por defecto CanvasKit (el motor
de dibujo, 7 MB) se descarga de `gstatic.com`, y sin red eso deja la
pantalla en blanco. Con el flag se usa la copia local, que sí se cachea.
`--pwa-strategy=none` evita que Flutter registre su service worker vacío
compitiendo con el nuestro.

Verificado apagando el servidor y recargando: los 28 ficheros (17,5 MB) se
sirven desde la caché, mientras que una ruta no cacheada falla con
`Failed to fetch` — o sea que de verdad no había red.

Al tocar `sw.js` o cambiar la lista de ficheros hay que **subir la versión
de `CACHE`** (`manager-nba-v1` → `-v2`): el `activate` borra las cachés
viejas y evita quedarse con mitad de una build y mitad de otra.

Hosting: **hecho, GitHub Pages** (ver el estado al principio del fichero).
Los service workers no arrancan en `http://` salvo en localhost, así que
servirlo desde el PC por la wifi de casa NO vale para el iPhone — hace falta
HTTPS de verdad. El `--base-href` lo pone el workflow solo, sacándolo del
nombre del repositorio.

### El repositorio de git (montado en esta sesión)

`git init` se hizo en la raíz del proyecto. Detalle importante: la carpeta
pesa **4,7 GB**, pero al repositorio solo van **305 ficheros y 5,1 MB**. Lo
que se queda fuera vía `.gitignore`:

- `data/draft/` — 4,4 GB entre `nba.sqlite` (2,2 GB) y los CSV crudos de
  Kaggle. De ahí salieron una vez los JSON de `assets/data`, que sí están
  versionados. No hacen falta para jugar ni para compilar.
- `build/`, `.dart_tool/` y los `ephemeral/` de cada plataforma (el de
  Windows solo son ya 309 MB).

Si algún día hay que regenerar los datos, esos 4,4 GB están **solo en el
disco local**: no hay copia en GitHub.

## Lista parte 8 — terminada

Confirmado por el usuario: **el juego en navegador funciona bien, sin
tiempos de carga largos tras 2 temporadas jugadas.** El port a WASM vale.

Los diez puntos están hechos, cada crítico con su test de regresión:
`rotacion_tras_el_verano_test.dart`, `tope_de_ofertas_test.dart` y
`estrellas_sin_equipo_test.dart`.

1. ~~**CRÍTICO.** Los Wolves terminan últimos.~~ **HECHO.** No era el motor:
   era el ORDEN del verano. La rotación se rehacía dentro de
   `finalizarPretemporada`, que corre antes de la ventana de agencia libre,
   o sea con la plantilla en su peor momento del año; todo lo que fichabas
   después se quedaba fuera de los diez que juegan (medido: un 89 en el
   banquillo y un 67 de titular). Y como los 29 equipos de la CPU se
   realinean cada partido, la desventaja era solo tuya y se repetía cada
   verano. Ahora se rehace al final de `cerrarVentanaDeAgenciaLibre`.
   Descartado con medidas, no con intuición: lesiones (2 frente a 3,7 de
   media), alineación del usuario peor que la de la CPU (50,1% en 9000
   partidos), y la media no predice la fuerza (r=0,84, sí la predice).
   Ojo: los Wolves son 17º por media y 15º por fuerza en este dataset.
2. ~~**CRÍTICO.** Exceso de ofertas en la temporada 2.~~ **HECHO.** El tope
   funcionaba (medido: 3, 3 y 3 en las tres primeras temporadas). Lo que
   fallaba era el aviso: pulsar "Más tarde" no marcaba las ofertas como
   vistas —solo lo hacía `OfertasScreen`—, así que el aviso volvía a saltar
   en CADA tramo simulado, cortando la simulación con las mismas tres
   propuestas. Ahora se marcan al cerrar el aviso; la oferta sigue en la
   bandeja hasta que la aceptes o la rechaces.
3. ~~Harden y DeRozan sin firmar toda la temporada.~~ **HECHO.** No eran los
   topes salariales: los dos **arrancan el dataset ya como agentes libres**
   (Harden con 88, DeRozan con 84, `equipo: FA`) y el reparto de estrellas
   de la CPU solo corría en el verano. En la temporada 1 no había verano
   previo, así que se quedaban en la calle el año entero — 7 jugadores de
   78+ al empezar la partida. Ahora ese reparto también se dispara al
   cruzarse la fecha límite de agencia libre, que es justo lo que pedías
   (fichajes de la IA a mitad de temporada): tú tienes toda la ventana para
   ficharlos primero y, si no lo haces, se los lleva la liga.
   De paso, un `break` que debía ser `continue`: si a UN jugador no se le
   encontraba sitio, el reparto cortaba y dejaba en la calle a todos los de
   detrás.
4. ~~Chris Paul: segundo equipo vacío y dorsal 43 en vez del 3.~~ **HECHO.**
   Dos fallos encadenados. El nombre salía vacío porque sus etapas reales
   incluyen **NOH** (New Orleans Hornets), franquicia desaparecida para la
   que `infoDe()` devuelve una ficha vacía; las pantallas de camisetas usan
   ahora `nombreDeEquipoEnFicha`, que sí conoce las históricas. Y el 43 era
   un dorsal **sorteado** por el juego: ni LAC ni NOH estaban en
   `codigoPorNombreReal`, así que su número real no se encontraba. Añadidos
   los dos códigos, más sus entradas con el 3 en `camisetas_futuras.json`.
5. ~~Bracket.~~ **HECHO.** Vuelta a las dos conferencias enfrentadas con la
   Final NBA en el centro. Mide 1400px, así que se encoge hasta caber
   entero en el ancho disponible y va dentro de un `InteractiveViewer` para
   poder acercarse. Se eliminó `_BracketPorConferencia`.
6. ~~Hall of Fame, nuevo inducido.~~ **HECHO.** Dice "Entró en 2029" en vez
   de la puntuación de carrera.
7. ~~Cabecera solapada.~~ **HECHO.** Era altura: el apodo lo pinta
   `FlexibleSpaceBar` pegado abajo y los datos llegaban hasta ahí.
   `expandedHeight` 190 → 214 y margen inferior 46 → 58.
8. ~~Logo junto al marcador.~~ **HECHO.**
9. ~~Victorias/derrotas en el resumen.~~ **HECHO:** "12 partidos · 8-4".
10. ~~Puesto en la conferencia.~~ **HECHO.** Tercer dato en la cabecera,
    calculado por porcentaje de victorias (no por victorias a secas, que a
    mitad de temporada engañaría). En rojo si caes del 10º, que es quedarse
    fuera del play-in.

## Lista parte 7 — terminada

Los quince puntos están hechos. Lo que hay que recordar de los cinco
últimos, porque no es evidente leyendo el código:

- **4. Récords irreales.** No era de lesiones ni de alineaciones: era
  balance del motor. Medido sobre una temporada completa salía el mejor
  76-6 y el peor 5-77, con una desviación del % de victorias de 0,237
  (la NBA real ronda 0,145) y diferencias de puntos de ±15 (la real es
  ±9). Dos causas: la ventaja de rating se traducía a marcador casi sin
  comprimir, y el único ruido que separa a los dos equipos era pequeño
  (el ritmo es compartido, así que se cancela al restar los marcadores).
  Se añadió `PesosAtributos.sensibilidadAlRating` (0,55), se subió
  `sigmaRuidoMarcador` a 8,0 y se bajó `sigmaRitmo` a 0,07. Ahora el mejor
  ronda 61-21 y el peor 15-67, y OKC —el caso del reporte— sale 51-31.
  Lo vigila `realismo_estadisticas_test.dart`.
- **5. Alineación automática.** Confirmado: `repartirPorPuestos` no puede
  producirlo, el fallo estaba en `repararRotacion`. Cuando se iba el
  SUPLENTE de un puesto, el que entraba heredaba ese hueco tal cual, así
  que un 87 recién llegado se sentaba detrás del 81 que ya estaba. Además
  elegía "el mejor libre" por etiqueta de posición antes que por nivel.
  Ahora el que entra pasa a titular si rinde más, y el mejor disponible se
  mide por media × factor de comodidad, igual que en el resto del juego.
- **6.** Nueva `ResumenTemporadaScreen` (balance, los 82 partidos y los
  promedios de cada jugador), encadenada antes de los premios y accesible
  desde el menú.
- **7 y 8.** `equiposQueRetiranCamisetaReal` devuelve TODOS los equipos que
  le corresponden, y `retirarCamiseta` ya no aborta por tener camiseta en
  otro equipo (la comprobación de duplicado no miraba el equipo). El aviso
  es `CamisetasNuevasScreen`, a pantalla completa.
- **12 y 13.** El cuadro de playoffs usa la vista por conferencia en todo
  lo táctil (< 1024), no solo en el teléfono: mide 1400px y en un iPad en
  vertical también se cortaba. El calendario reparte el alto disponible
  entre las semanas del mes en vez de usar una proporción fija, así que un
  mes cabe entero aunque encima haya botones, panel de playoffs o avisos.
  Aviso honesto: a 390x844 y a 375x667 el mes ya cabía antes del cambio —
  no se pudo reproducir el recorte, así que si sigue viéndose cortado hace
  falta la resolución real del móvil.

---

# Manager NBA — Fase 4: menú de inicio, prórrogas, NBA Cup real y arreglos varios

## Contexto

Feedback tras probar la app real (incluye un crash y un overflow detectados
en vivo mientras la ejecutaba: `flutter run -d windows` lanzó una
`SqliteException` al crear franquicia — `UNIQUE constraint failed:
resultado_temporada.equipo` — y un `RenderFlex overflowed` en la caja de
serie del bracket de playoffs). Se arreglan como parte de esta fase porque
tocan directamente las pantallas que hay que tocar de todos modos.

## 0. Arreglos ya detectados en vivo

- **Crash al crear franquicia**: `crearFranquicia` (en
  `franquicia_repository.dart`) inserta en `resultadoTemporada` con
  `batch.insertAll` sin manejar conflicto; si la fila ya existe (doble tap
  en "Comenzar", o datos residuales) revienta con `UNIQUE constraint
  failed`. Se cambia a `insertOnConflictUpdate` y además se deshabilita el
  botón mientras se está creando la franquicia, para que no se pueda volver
  a pulsar.
- **Overflow en el bracket de playoffs**: `_CajaSerie` (en
  `playoffs_screen.dart`) tiene una altura fija (`_boxHeight`) que no deja
  sitio para las dos filas de equipo + el botón "Simular" cuando la serie es
  la tuya. Se sube `_boxHeight`/`_slot` lo suficiente para que quepa siempre
  el caso con botón.

## 1. Menú de inicio: Continuar / Nueva partida / Ajustes

- `StartMenuScreen` pasa a tener tres botones en vez de dos:
  - **Continuar**: solo habilitado si ya existe una franquicia guardada
    (`leerEquipoFranquicia`); lleva directo a `HomeHubScreen`.
  - **Nueva partida**: siempre habilitado. Si ya había una franquicia,
    pide confirmación (mismo diálogo que hoy tiene "Nueva franquicia" en
    Ajustes: se pierde calendario/rotación/lesiones/resultados/premios/
    playoffs, los títulos no) antes de borrarla y arrancar el flujo de
    selección de equipo → alineación inicial.
  - **Ajustes**: igual que ahora (tema, idioma).
- Se quita la entrada "Nueva franquicia" de `AjustesScreen` (o se deja como
  atajo redundante hacia el mismo flujo — se decide al implementar cuál
  queda más limpio); la lógica de borrado (`nuevaFranquicia`) no cambia,
  solo desde dónde se dispara.

## 2. Media de equipo con los 5 mejores, no 10

- `TeamSelectorScreen`: la media que se muestra junto a cada equipo pasa de
  calcularse con los 10 mejores jugadores a los 5 mejores (titulares reales
  de una rotación NBA), para que se parezca más a la calidad real de un
  quinteto inicial.

## 3. Botón de alineación automática

- En `RosterConfigScreen` (tanto en el onboarding inicial como al editar
  desde el menú) se añade un botón "Alinear automáticamente": rellena los 5
  puestos (titular + suplente) con los mejores jugadores de la plantilla en
  su posición real (reutilizando la misma idea que
  `generarAlineacionAutomatica`, pero respetando el modelo de
  titular/suplente por puesto en vez de la curva de minutos genérica de la
  IA), y deja minutos por defecto (32/16). El usuario puede seguir
  ajustando a mano después de pulsarlo.

## 4. Prórrogas: no puede haber empates

- `sim_engine`: `simularPartido` no puede devolver un marcador empatado.
  Si al terminar los 4 cuartos hay empate, se juega una prórroga de 5
  minutos (un "cuarto" adicional más corto, con su propio reparto de
  puntos) y se repite hasta que alguien gane. Con el ruido actual del
  marcador esto debe ser raro más allá de una o dos prórrogas — se ajustan
  las constantes de la prórroga para que así sea.
- `Boxscore.parcialesLocal`/`parcialesVisitante` pasan a poder tener más de
  4 elementos (uno por prórroga jugada); `BoxscoreScreen` etiqueta esas
  columnas extra como "P1", "P2"... en vez de "Q5", "Q6".
- Nuevo test: forzando una situación de empate estadísticamente probable
  (dos equipos idénticos con seed fija que empatan a 4 cuartos), el
  marcador final nunca es empate y `parciales` tiene más de 4 valores.

## 5. Colores de equipo en el boxscore

- `BoxscoreScreen`: la cabecera de cada tabla de estadísticas
  (`_TablaEquipo`) usa el color primario de ese equipo
  (`infoDe(equipo).colorPrimario`) en vez de texto neutro para los dos
  equipos, para diferenciarlos a simple vista.
- Se quita el `color: Colors.green` del marcador del ganador en
  `_EquipoMarcador` (el mismo bug que ya se arregló en el resumen de
  simulación, pero seguía en esta pantalla): el marcador se queda en negrita
  si ganó, sin colorear en verde — ni en modo claro ni en oscuro.

## 6. Orden local-visitante en la lista de partidos simulados

- `ResumenSimulacionScreen`: cada fila de partido simulado deja de mostrar
  siempre "tu equipo - marcador - rival" y pasa a mostrar el orden real
  local-visitante (`equipo local - marcador - equipo visitante"), igual que
  ya se hace en el diálogo de "partido ya jugado" del calendario. Ganar o
  perder se sigue marcando con negrita + el fondo verde/rojo ya existente,
  independientemente de si jugaste en casa o fuera.

## 7. NBA Cup real (sustituye el torneo de mitad de temporada simplificado)

Reescritura completa de la Fase 3b (`coronarCampeonTorneoSiToca` y el
aviso simplificado "mejor récord de torneo") por la estructura real:

- **Grupos**: 30 equipos → 2 conferencias → 3 grupos de 5 por conferencia
  (6 grupos en total). Simplificación explícita: los grupos se fijan de
  forma estática en código (un nuevo mapeo `grupoTorneoPorEquipo`, al
  estilo de `conferenciaPorEquipo`), en vez de sortearse cada temporada —
  la NBA real resortea los grupos cada año, pero esta app juega una
  franquicia a la vez y no hay datos previos con los que ponderar un
  sorteo, así que un agrupamiento fijo es la simplificación razonable (se
  puede revisar si se pide lo contrario).
- **Fase de grupos**: el generador de calendario deja de marcar como
  "torneo" una ventana de fechas al azar y en su lugar reserva, para cada
  equipo, 4 partidos concretos contra sus 4 rivales de grupo (2 en casa, 2
  fuera), reflejados con `esTorneoTemporada = true`. Estos partidos siguen
  contando para el récord de temporada regular (ya lo hacían).
- **Clasificación a cuartos (8 equipos)**: cuando termina la fase de
  grupos (todas las fechas de grupo ya jugadas en los 30 equipos), se
  calculan:
  - 6 cabezas de grupo (mejor récord de sus 4 partidos de grupo; empate
    por diferencia de puntos en esos mismos partidos).
  - 2 comodines: el mejor segundo puesto de cada conferencia, comparando
    solo entre los tres segundos de esa conferencia (mismo criterio de
    desempate).
- **Eliminatorias**: cuartos (4 partidos, 2 por conferencia) → semifinal (2
  partidos, 1 por conferencia) → final (1 partido, cruzada) — conferencias
  separadas hasta la final, exactamente igual que el bracket de playoffs
  real que ya existe. Se implementa con una tabla nueva `SeriesTorneo` (
  mismo shape que `SeriesPlayoffs`, `victoriasNecesarias = 1` siempre) y un
  `torneo_repository.dart` con las mismas operaciones que ya existen para
  los playoffs (`sembrar`, `simularPartidoDeSerie`,
  `simularRondaCompleta`/`simularTodo`).
- Cuartos y semifinal **sí cuentan** para la temporada regular (se reflejan
  también como partidos normales en `PartidosCalendario` del equipo,
  marcados `esTorneoTemporada = true`); la final **no cuenta** (partido
  aparte, solo decide el título de la Copa).
- El campeón se sigue guardando en `HistorialCampeones` (`tipo: 'ist'`).

## 8. Estadísticas también en partidos de series (playoffs y Cup)

Ahora mismo `simularPartidoDeSerie` calcula un `Boxscore` pero lo tira —
solo persiste el marcador agregado de la serie. Para que "meterte a ver
las estadísticas" funcione igual que en temporada regular:

- Se guarda el `Boxscore` de cada partido de serie jugado (playoffs o Cup)
  en una tabla nueva ligera (id de serie + índice de partido + el boxscore
  serializado o sus columnas ya desglosadas, reusando el mismo shape que
  usa `Boxscore` de `sim_engine`).
- `PlayoffsScreen` (y la pantalla equivalente de la Cup) dejan tocar un
  partido ya jugado de una serie para abrir `BoxscoreScreen` con sus
  datos, igual que ya se puede con los partidos de temporada regular.

## 9. Bracket: nombres de ronda en vez de "Pendiente", simular ronda completa

- `_CajaSerie` dejar de mostrar la etiqueta genérica "Pendiente" para las
  cajas todavía no resueltas: en su lugar, cada columna usa el nombre real
  de su ronda ("Primera ronda", "Semifinal de conferencia", "Final de
  conferencia", "Final NBA").
- `PlayoffsScreen` (y el panel de playoffs del Calendario) añaden un botón
  "Simular ronda completa" además de "Simular partido": resuelve todos los
  partidos de la ronda actual (la tuya y las demás en curso) de una vez.
- Cuando tu serie actual termina y tu siguiente rival todavía no está
  decidido (el resto del bracket no ha llegado a esa ronda), en vez del
  texto estático "Esperando al resto del bracket" aparece un botón
  "Simular el resto de la ronda", que resuelve las series que faltan de esa
  ronda y — en cuanto se pueda — genera tu próximo partido, encadenando
  así hasta la final sin más que pulsar ese botón las veces que haga falta.

## 10. Contraste en modo oscuro

- El bloque "Lesiones activas ahora mismo" de `ResumenSimulacionScreen"
  tiene el fondo fijo en `Colors.red.shade50` (un rosa muy claro) mientras
  el texto de cada lesión no fija color y hereda el color por defecto del
  tema — en modo oscuro ese color por defecto es claro, así que queda
  texto claro sobre fondo casi blanco: ilegible. Se cambia el fondo a un
  rojo translúcido que se adapta al tema (mismo patrón que ya se usa para
  el verde/rojo de victoria/derrota) y se fija un color de texto con
  contraste garantizado en ambos modos.

## Verificación

- `flutter analyze` / `dart analyze` limpios en `sim_engine` y
  `manager_nba`.
- `sim_engine`: tests de que no hay empates posibles y de que las
  prórrogas sólo ocurren cuando hace falta (raras más allá de la segunda).
- `manager_nba`: tests de la nueva siembra de la Cup (grupos, cabezas de
  grupo, comodines, cuartos/semis/final), de que las cuartos y semis suman
  al récord de temporada regular y la final no, de la media de equipo con
  5 jugadores, y de que un partido de serie (playoffs o Cup) expone su
  boxscore.
- Verificación manual en `flutter run -d windows`: menú de inicio con los
  tres botones, alineación automática, un partido forzado a prórroga,
  bracket de la Cup completo hasta el campeón, y contraste de lesiones en
  modo oscuro.

## Fase 4b — ronda de arreglos tras probar la Fase 4 de verdad

Segunda tanda de feedback jugando una partida real, con capturas y una
corrección importante de diseño sobre cómo debía funcionar la NBA Cup.

- **Contraste en el calendario (modo oscuro)**: mismo patrón que el punto
  10 pero en `_CeldaDia` (`calendario_screen.dart`) — fondos fijos
  (`green/red.shade100`, `blue.shade50`) con texto sin color explícito.
  Arreglado igual: fondos translúcidos + `colorScheme.onSurface`, y el
  nombre del rival sube de 10 a 12sp.
- **`StartMenuScreen` no se enteraba de una franquicia creada más tarde**:
  `_equipoExistenteFuture` se calculaba una vez en `initState` y nunca se
  releía; volver atrás hasta esa misma instancia (p. ej. desde el menú
  principal) dejaba "Continuar" deshabilitado como si la partida no
  existiera — y si ahí se pulsaba "Nueva partida", como creía que no había
  franquicia previa, se saltaba el borrado de `RotacionJugador` del equipo
  anterior. Arreglado con `RouteObserver`/`RouteAware`
  (`main.dart#routeObserver`, `didPopNext` en `StartMenuScreen`), que
  recarga el estado cada vez que la pantalla vuelve a ser visible.
- **Crash "Null check operator" al crear la alineación de un equipo
  nuevo**: consecuencia directa del bug anterior — con `RotacionJugador`
  contaminada por el equipo previo, `_SelectorEstrellas` intentaba
  ordenar por `jugadoresPorId[id]!.nombreFicticio` con un `id` que no
  pertenecía a la plantilla actual. Arreglado en las dos puntas: la causa
  (arriba) y, como defensa, `_cargarPlantillaYRotacion` ahora ignora
  cualquier fila de `RotacionJugador` cuyo `jugadorId` no esté en la
  plantilla del equipo que se está configurando.
- **Tasas de lesión bajadas a la mitad** (`lesiones_repository.dart`):
  0.0008/0.008 → 0.0004/0.004, tras feedback de que salían demasiadas
  jugando una temporada de verdad. El bloque "Lesiones activas ahora
  mismo" en sí se comprobó con un test dedicado y renderiza bien cuando
  hay datos — no era un bug de UI, solo de frecuencia.
- **Aviso de campeón**: al decidirse la Final NBA (playoffs) o la Final de
  la NBA Cup, ahora sale un diálogo explícito ("¡Tenemos campeón!"), no
  solo el banner pasivo del bracket — se dispara desde los tres sitios
  donde se puede completar la simulación (`PlayoffsScreen`, `TorneoScreen`
  y el panel de playoffs integrado en `CalendarioScreen`), con guardas
  para no repetirlo si ya se había visto.
- **Rediseño de cuándo "cuentan" los partidos de la NBA Cup**: el diseño
  original de la Fase 4 (partido 56) dejaba cuartos y semifinal como
  series que había que ir a simular a mano a una pantalla aparte. El
  usuario aclaró que eso está mal: cuartos y semifinal deben comportarse
  como un partido normal de temporada (sin visita especial a ninguna
  pantalla), y solo la Final debe quedar como algo aparte que no cuenta
  para el récord. Cambio: en cuanto `sembrarCuartosDeTorneoSiToca` siembra
  los 4 cuartos, resuelve también cuartos y semifinal automáticamente en
  el momento (usando la rotación real del usuario si le toca jugar),
  dejando pendiente solo la Final en `TorneoScreen`. Se apoya en el campo
  `fase` de `PartidosCalendario` (ya existía sin usarse) para que
  `temporadaRegularCompleta` siga contando solo los 82 partidos
  originales del calendario y no se dispare antes de tiempo por las
  victorias/derrotas extra de la Cup.
- Nuevos tests: `resumen_lesiones_screen_test.dart` (el bloque de lesiones
  se muestra cuando hay datos), ampliación de `start_menu_screen_test.dart`
  (recarga al volver atrás), ampliación de `playoffs_screen_test.dart`
  (diálogo de campeón), reescritura de `torneo_temporada_test.dart` y
  nuevo `torneo_screen_test.dart` para la resolución automática de
  cuartos/semis.

## Fase 5 — segunda ronda de feedback jugando de verdad

Seis cosas que salieron probando varias temporadas seguidas:

1. **Trofeos que no eran tuyos.** `HistorialCampeones` guardaba todos los
   títulos, los ganase quien los ganase, y `TeamSelectorScreen` los pintaba
   todos: al empezar una partida nueva aparecían equipos "con palmarés" que
   nunca habías dirigido. La tabla gana `logradoPorUsuario`, que se rellena
   comparando el campeón con tu franquicia activa (`registrarCampeon` en el
   nuevo `campeones_repository.dart`); el selector solo enseña los tuyos.
   Los de la CPU se siguen guardando, simplemente no cuentan como logro.

2. **La Final de la NBA Cup, sin salir del calendario.** Antes la Final
   quedaba pendiente en una pantalla aparte que además no se desbloqueaba
   hasta reiniciar el juego. Ahora, al sembrarse el cuadro:
   - si eres finalista, la Final se te programa como un día más del
     calendario (`PartidosCalendario.fase = 'copa_final'`, en el primer día
     libre tras la fase de grupos) y se juega simulando hasta ahí; no suma
     ni victoria ni estadísticas, y tampoco cuenta para dar por terminada
     la temporada regular;
   - si no lo eres, se juega sola y lo único que ves es el aviso del
     campeón, con un botón para abrir el boxscore de esa Final.
   `TorneoScreen` pasa a ser una pantalla de consulta (cuadro + resultados
   + estadísticas), sin botones de simular. `HomeHubScreen` se vuelve
   `StatefulWidget` con `RouteAware` para que lo que se desbloquea mientras
   juegas aparezca al volver, sin reiniciar.

3. **El calendario se quedaba clavado en octubre.** `Scrollable.ensureVisible`
   sobre el `GlobalKey` del mes objetivo no hacía nada porque los meses aún
   no renderizados no tienen contexto. La temporada son ~9 meses: se
   construyen todos (`scrollCacheExtent`) y el salto al mes pendiente
   funciona tras simular día, semana o mes.

4. **Los premios siempre para los mismos.** La simulación era casi
   determinista, así que el MVP y el Mejor Defensor salían idénticos
   temporada tras temporada. Nueva tabla `FormaTemporadaJugador`: un
   multiplicador por jugador sorteado al crear la franquicia (gaussiano,
   sigma 0.10, acotado a 0.78-1.22) que el motor aplica a su rendimiento
   (`JugadorEnPartido.factorForma`, junto con la penalización fuera de
   posición). Además el Mejor Defensor deja de ser "el `atrDefensa` más
   alto" y pasa a combinar defensa, forma, rebotes y récord del equipo.

5. **Cruces de playoffs confusos.** La lógica ya era la real (1-8 con 4-5,
   2-7 con 3-6) pero el bracket dibujaba la primera ronda en orden de seed,
   así que juntaba visualmente series que no se cruzan y hacía esperar un
   rival equivocado. El orden vertical pasa a ser el del cruce real.

6. **10 vs 12 jugadores.** La CPU repartía minutos entre 12 jugadores y tú
   entre 10. Curva igualada a 10 (5 titulares + 5 suplentes, 240 minutos).

Verificación: `flutter analyze` limpio en app y `sim_engine`, 61 tests de
`manager_nba` y 14 de `sim_engine` en verde. Tests nuevos:
`campeones_repository_test.dart`, `forma_y_premios_test.dart`,
`alineacion_automatica_test.dart`, el cruce de semifinales en
`playoffs_repository_test.dart`, y reescritura de
`torneo_temporada_test.dart` / `torneo_screen_test.dart` para el nuevo
flujo de la Final.

## Fase 5b — arreglos tras la primera sesión de prueba

- **Bug gordo: la navegación se rompía entera.** `didPopNext` del menú
  principal hacía `setState(() => _future = _cargar())`, y con cuerpo de
  flecha el valor de la asignación es el propio `Future`, que `setState` no
  admite. La excepción saltaba dentro de la notificación del
  `RouteObserver`, dejando el `Navigator` con `_debugLocked` puesto: a
  partir de ahí ni volver al menú ni abrir el resumen de simulación —
  justo el "no me deja volver atrás y al simular ya no sale nada".
  Arreglado con cuerpo de bloque, y con un test que lo reproduce
  (`home_hub_screen_test.dart`).

- **Segundas posiciones.** El dataset solo trae una posición por jugador
  (y un único caso con dos), así que a cada uno se le deriva la contigua
  según su juego: si reparte más que rebotea tira hacia fuera (un escolta
  que también hace de base), si rebotea más tira hacia dentro. Nueva
  columna `Jugadores.posicionSecundaria` y `posiciones.dart` con la
  derivación y el factor de puesto.

- **La penalización posicional pesaba demasiado.** Ahora va graduada: 1.0
  en su puesto natural, 0.96 en el segundo, 0.9 fuera de los dos (antes
  era 0.8 sin matices). Y sobre todo, la CPU ya se alinea por puestos
  como tú: antes cogía a sus mejores por media sin penalización ninguna,
  así que partías siempre en desventaja.

- **Cambiar un jugador de puesto sin bailes raros.** En la pantalla de
  alineación ya se puede elegir a alguien que está en otro hueco: los dos
  se intercambian. Antes había que vaciar el hueco primero.

- **Realismo de la anotación con rotaciones de 10.** Al pasar de 12 a 10
  jugadores, los mismos 112 puntos se reparten entre menos gente y los
  primeros anotadores se iban a 36-43 de media. La causa de fondo era que
  escalar los `pts_pg` reales por `minutos/36` cuenta dos veces la
  reducción de los suplentes (sus promedios reales ya reflejan que juegan
  poco), así que la suma de "puntos esperados" del equipo se quedaba muy
  por debajo de lo que anota y al normalizar subía todo el mundo. Nuevo
  `PesosAtributos.pesoFijoDeMinutos`: el escalado deja de ser proporcional
  puro. Resultado medido en 5 temporadas completas: máximo 31-35 de media
  y 2-6 jugadores por encima de 30, como una NBA real. De paso, la horquilla
  del estado de forma se modera a 0.84-1.16 (sigma 0.07), que sigue siendo
  de sobra para mover los premios.

Verificación: `flutter analyze` limpio, 68 tests de `manager_nba` y 14 de
`sim_engine` en verde. Tests nuevos: `posiciones_test.dart`,
`home_hub_screen_test.dart`, `roster_config_screen_test.dart`.

## Fase 5c — All-Star, defensor del año y contraste

- **All-Star de verdad.** Antes el fin de semana de las estrellas era solo
  un `SnackBar`. Ahora se juega un partido Este vs Oeste con los 10 mejores
  de cada conferencia — elegidos por lo que están haciendo *esta* temporada
  (pts + ast + reb por partido), no por su media del dataset — cubriendo
  los 5 puestos, y salta un aviso con el resultado y la opción de ver el
  boxscore o seguir simulando. No cuenta para nada: ni récord, ni
  estadísticas, ni lesiones. Se guarda en `BoxscoresSerie` con origen
  `allstar`, así que no hace falta esquema nuevo.

- **Mejor Defensor con sentido.** Salía Doncic: el peso de los rebotes y el
  del estado de forma juntos podían tapar la diferencia de `atrDefensa`.
  Ahora la forma cuenta la mitad en defensa que en ataque y los rebotes
  pesan un tercio de lo que pesaban, así que el premio lo decide la
  capacidad defensiva real (que es donde viven robos, tapones y ayudas, que
  el boxscore simulado no registra). Test nuevo: un anotador reboteador con
  defensa mediocre no gana el premio ni con el mejor año de forma posible.

- **Campeón: mensaje distinto si ganas tú.** `mostrarCampeonDecidido` pasa
  de ser un `AlertDialog` de texto plano a un diálogo con cabecera en los
  colores del campeón, trofeo y mensaje de enhorabuena cuando el equipo es
  el tuyo. El banner del bracket se unifica en `BannerCampeon`.

- **Contraste con colores fijos.** Nuevo `shared/contraste.dart`:
  `textoSobre(fondo)` elige blanco o negro según el fondo, y
  `colorLegibleComoTexto` aclara u oscurece un color de equipo lo justo
  para que se lea sobre el fondo del tema. Aplicado al banner de campeón
  (era amarillo con letra gris, ilegible en oscuro), a las cabeceras de
  equipo del boxscore y a las `AppBar` que van con el color del equipo.

- **Media en la alineación.** Los huecos de titular/suplente muestran ahora
  la media del jugador junto a sus posiciones.

Sin cambios de esquema: la partida en curso se conserva. Verificación:
`flutter analyze` limpio, 71 tests de `manager_nba` y 14 de `sim_engine`.

## Fase 6 — carreras largas: el paso de una temporada a la siguiente

Objetivo: poder dirigir al mismo equipo 25 temporadas (o las que sean) sin
que la liga se rompa. El dato que lo condicionaba: de los 582 jugadores
utilizables del dataset, tras 15 temporadas quedan 120 en activo y tras 25
no queda **ninguno**. Sin generar jugadores nuevos, la carrera se agota
sola hacia la temporada 10-12.

**Reloj de la carrera.** Nueva tabla `Temporada` (número + año natural de
inicio). `HistorialCampeones` gana `temporada`, y se añaden
`HistorialTemporadaEquipo` e `HistorialPremios` para que los récords y
premios de cada año sobrevivan al cambio de temporada (los del año en curso
se borran).

**Envejecimiento** (`progresion_repository.dart`). Cada cambio de año: +1 a
todos; quien pasa de su `edadRetiro` se retira (no se borra — se marca
`retirado` y pasa al equipo `RET`, para que los premios históricos sigan
resolviendo su nombre); los menores de 27 progresan hacia su potencial (un
salto proporcional a lo que les falta, así un proyecto explota y un jugador
ya hecho apenas mejora); entre 27 y 30 se mueven poco; a partir de 31
declinan, más despacio cuanto mayor sea su `factorLongevidad`. Las medias
por partido (pts/ast/reb) se mueven en la misma proporción que la media.

**Draft y jugadores generados** (`draft_repository.dart`). Cada año se
genera una clase de 60 prospectos con la calidad decayendo según el puesto
(el número 1 llega listo y con techo de estrella; el último es un proyecto),
y se reparte en orden inverso al récord final. Además se garantiza que
ninguna plantilla se quede corta: se rellena hasta 13 jugadores, se asegura
que cada puesto tenga al menos dos jugadores cómodos (natural o segunda
posición) y se recorta a 18 sin dejar nunca un puesto descubierto — sin ese
tope, +2 de draft frente a ~1,5 retiradas por equipo hinchaba las
plantillas hasta 35 en 25 temporadas.

**Cambio de temporada** (`nueva_temporada_repository.dart`). Solo se puede
cuando la Final NBA tiene ganador. Archiva, envejece, celebra el draft,
borra lo que es "de esta temporada" (estadísticas, lesiones, playoffs, NBA
Cup, calendario), sortea la forma nueva, genera el calendario del año
siguiente y deja hecha una alineación automática (la rotación anterior
podía tener retirados). Empezar una partida nueva reimporta el dataset
original, porque tras una carrera larga los jugadores están envejecidos y
mezclados con generados.

**UI.** Con el campeón decidido, el panel de playoffs del Calendario ofrece
"Empezar la siguiente temporada", que lleva a `PretemporadaScreen`:
retiradas propias y de la liga, quién ha subido y quién ha bajado, tus
elecciones del draft y el top de la clase.

**Verificación.** Test de 25 temporadas encadenadas (11 s): al final siguen
siendo 30 equipos, con plantillas de 13-18 jugadores, los 5 puestos
cubiertos con dos jugadores cómodos, nadie en activo pasado de su edad de
retiro, nombres únicos y el calendario en 82 partidos. Deriva de calidad
medida cada 5 temporadas: la media de la liga se queda en ~76 y el top-10
entre 91 y 98, sin aplanarse (para eso hubo que subir el fin del
crecimiento de los 25 a los 27 años: con 25, los prospectos se quedaban
4-5 puntos por debajo de su potencial y el techo de la liga bajaba solo).
`flutter analyze` limpio, 73 tests de `manager_nba` y 14 de `sim_engine`.

## Fase 7a — legado: retiradas, Hall of Fame y camisetas

Primera de las tres tandas del bloque de "legado". Todo lo que hace falta
para que una carrera de 25 temporadas deje poso.

**Dorsales.** El dataset no los trae: se reparten al crear la franquicia y
después de cada draft (`dorsales_repository.dart`), únicos dentro del
equipo y saltándose los números que esa franquicia haya retirado.

**Carrera de cada jugador.** Nueva tabla `HistorialEstadisticasJugador`:
una fila por jugador y temporada (equipo, media, partidos, puntos,
asistencias, rebotes), archivada al cerrar el año *antes* de envejecer a
nadie (si no, se guardaría el equipo y la media equivocados).
`carrera_repository.dart` reconstruye con eso las etapas por equipo —
agrupando temporadas consecutivas, de forma que volver años después cuenta
como una etapa distinta— y cruza premios y campeonatos para saber qué ganó
y con quién.

**Pantalla de retirados.** Al cerrar la temporada: todos los que cuelgan
las botas, con la media exacta con la que se retiran y de dónde (su equipo,
o "Agencia libre" si acabó sin equipo). De los tuyos se entra a su
trayectoria y se decide allí mismo si retirarle la camiseta.

**Hall of Fame.** Puntuación de carrera con premios (MVP 25, DPOY 12,
quintetos 10/5...), anillos (8), pico de nivel por encima de 85 y
producción escalada por años, con un mínimo de 6 temporadas. Umbral
calibrado midiendo 15 temporadas simuladas: con 70 entraban 4 de 464
retirados (realista pero el salón se quedaba vacío años enteros); con 55
entran ~11, alrededor de uno por temporada. Los equipos de la CPU también
retiran la camiseta de sus jugadores de nivel Hall of Fame, así que el
listado de la liga no es solo tuyo.

**Camisetas retiradas.** Pantalla con las 30 franquicias, tu equipo
primero, cada dorsal con su nombre y la temporada en que se retiró;
tocando cualquiera se abre la carrera de ese jugador.

**Bug encontrado por el test de 25 temporadas.** El relleno de plantillas
comparaba los nombres generados solo contra los jugadores *en activo*, así
que a partir de la temporada ~20 empezaba a reutilizar nombres de
retirados (2 duplicados en 2085). Ahora se compara contra todos.

Verificación: `flutter analyze` limpio, 77 tests de `manager_nba` y 14 de
`sim_engine`. Tests nuevos en `legado_test.dart`: dorsales únicos, dorsal
retirado que no se reutiliza en 6 temporadas, medias de carrera que cuadran
con lo archivado (y etapas sin solaparse) y un Hall of Fame que solo admite
retirados con 6+ temporadas y menos del 25% del total.

## Fase 7b — draft jugable, dorsales reales y leyendas en el Hall of Fame

**Draft turno a turno.** El cambio de temporada se parte en dos
(`cerrarTemporada` y `finalizarPretemporada`) para que el draft quepa en
medio y lo puedas jugar. La clase generada espera en un "pool"
(`equipoProspectos`, un código de equipo que no es franquicia) y el estado
—orden de los 60 turnos e índice actual— vive en la tabla `DraftEnCurso`,
así que un draft a medias sobrevive a cerrar el juego. `DraftScreen`
resuelve las elecciones de la CPU y se para en seco en tu turno, listando
los disponibles con posición, edad, media y potencial; se puede ordenar por
potencial o por media (arriba o abajo — la lista por defecto va de mejor a
peor, que es lo cómodo para elegir). Hay botón para que la CPU elija por ti
si no te apetece. `empezarNuevaTemporada` sigue existiendo como atajo que
lo resuelve todo automáticamente (lo usan los tests).

La CPU ficha al mejor disponible pesando más el potencial que la media
(en el draft se ficha por lo que puede llegar a ser), con un empujón
pequeño a quien le tape un hueco de plantilla: entre dos parecidos coge al
que necesita, pero no renuncia a un proyecto de estrella por cubrir una
posición. Los prospectos que nadie elige acaban en la agencia libre.

**Códigos de equipo especiales** centralizados en `equipos_especiales.dart`
(`FA`, `RET`, `DRAFT`) con `esFranquicia`, en vez de comparar contra `'FA'`
suelto por media docena de sitios.

**Dorsales reales.** El dataset no trae números y no hay forma fiable de
sacar los 582, así que se fijan a mano los de ~80 jugadores reconocibles
(LeBron 23, Curry 30, Durant 35, Jokić 15, Antetokounmpo 34, Dončić 77,
Shai 2...) enlazando por `nombre_real`, y el resto se sortea entre los
libres. Los reales se reparten primero, para que un sorteo no le quite el
suyo a nadie.

**Leyendas en el Hall of Fame.** Problema real: el juego solo sabe de lo
que ha simulado, así que LeBron —que se retira dos temporadas después de
empezar tu partida— nunca entraría. Se añaden a `Jugadores` dos campos
calculados al importar: `temporadasPrevias` (deducidas del año de draft, o
de la edad si falta) y `prestigioPrevio`, que solo cuenta lo que pasa de 82
de media multiplicado por esos años. Con eso LeBron (69), Curry (66) y
Durant (57) llegan con el pase hecho; a Antetokounmpo (55) y Jokić (48) les
basta con seguir rindiendo; Dončić, Shai o Tatum lo construyen jugando. El
mínimo de 6 temporadas ahora cuenta también las previas. Test que lo fija:
tras 10 temporadas, LeBron, Curry, Durant y Antetokounmpo están dentro.

**Bug arreglado:** `playoffs_screen_test` daba por hecho que DEN no era
campeón, pero el fixture no lo garantizaba y el diálogo tiene una versión
distinta cuando ganas tú. Ahora se le da a DEN el peor récord de la liga de
forma explícita.

Verificación: `flutter analyze` limpio, 85 tests de `manager_nba` y 14 de
`sim_engine`. Tests nuevos en `draft_test.dart` (turnos, parada en tu
turno, criterio de la CPU en los dos sentidos, prospectos sobrantes a la
agencia libre, y el cambio de año partido en dos).

## Fase 8 — datos reales y mercado (contratos, agencia libre, traspasos)

**Datos reales.** Scrapeados con el navegador integrado desde
Basketball-Reference (contratos 2026-27) y RealGM (dorsales y plantillas
actuales) y cruzados con el dataset por `nombre_real`, normalizando acentos,
puntuación y sufijos (Jr./III). Cobertura sobre los 582 jugadores: 398
dorsales, 397 contratos y 420 equipos confirmados (83 cambios de equipo).
Lo que falta se deduce: `salarios.dart` estima el sueldo con una curva
convexa calibrada contra la escala real (mínimo 2,3M, titular 20-30M,
máximo 62,6M).

Tres cosas que aparecieron al aplicarlo:
- Basketball-Reference lista **filas duplicadas** por dinero muerto de
  contratos rescindidos (Lillard, Beal): se toma el salario mayor por
  nombre, que es el contrato de verdad.
- **Dorsales que chocan**: al mover jugadores de equipo, uno puede llegar
  con el número de su franquicia real y pisar al que ya lo llevaba. Se
  detecta, se queda el de mejor media y al otro se le sortea uno libre.
- Hay **contratos por debajo del mínimo del convenio** (acuerdos parciales,
  Ricky Rubio 424.672): son reales, no errores.

Con los equipos reales las plantillas quedaban de 14 a 26, así que al crear
la franquicia se recorta a 18. La lista de dorsales a mano se borró: los
scrapeados son más fiables (Durant lleva el 7 en Houston, no el 35).

**Contratos** (`contratos_repository.dart`). `salario` y `aniosContrato`
por jugador; al cerrar la temporada se descuenta un año a todos y los 29
equipos de la CPU resuelven sus vencimientos solos. Tope salarial de 220M:
por encima solo se ficha por el mínimo. Detalle que pilló un test:
`puedeAsumir` necesita saber qué salario se libera a la vez, porque si no
renovar a tu propia estrella contaba su sueldo dos veces y era imposible.

**Renovaciones.** Hasta 3 ofertas por jugador. Acepta según lo que ofreces
frente a su valor de mercado (por debajo del 75% no hay trato, alrededor de
su precio es probable, por encima casi seguro), con ajustes por los años
del contrato y por el enfado acumulado. Una oferta insultante penaliza
doble, así que tirar bajo "a ver si cuela" sale caro.

**Agencia libre.** Mercado con el precio de cada uno, fichaje respetando el
tope y un paso obligatorio en pretemporada: no se puede empezar la
temporada con la plantilla por debajo del mínimo o con un puesto sin
recambio. Botón de completar con contratos mínimos, y una red de seguridad
que genera jugadores si el mercado se ha quedado seco.

**Traspasos.** La CPU valora nivel, edad, proyección y contrato (cobrar por
encima de lo que rindes resta), y rechaza si no le sale a cuenta, si le
rompe la plantilla o si no le cabe bajo el tope. El tope también te frena a
ti: no se puede usar un traspaso para saltárselo.

**Flujo de pretemporada** ahora: retiradas → Hall of Fame → renovaciones →
draft → agencia libre → resumen.

Verificación: `flutter analyze` limpio, 101 tests de `manager_nba` y 14 de
`sim_engine`. Nuevos: `datos_reales_test.dart` (dorsales/salarios/equipos
reales, escala salarial, plantillas dentro de límites) y `mercado_test.dart`
(vencimientos, negociación con enfado, tope, agencia libre y traspasos en
los dos sentidos).

---

# Fase 9: picks traspasables, buscador automático y mercado vivo

Cuatro piezas para que los traspasos dejen de ser una pantalla aislada y se
conviertan en un mercado que funciona solo.

## Picks de draft (`picks_repository.dart`, tabla `PicksDraft`)

Cada equipo arranca con sus dos elecciones de los próximos cuatro drafts
(`aniosDePicksFuturos`). Un pick guarda de quién era en origen
(`equipoOriginal`, que decide en qué puesto cae, porque el orden lo marca su
clasificación) y quién lo tiene ahora (`equipoActual`).

`iniciarDraft` ya no reparte turnos por clasificación a secas: resuelve el
dueño de cada hueco a través de la tabla de picks. `finalizarDraft` los marca
como gastados y abre un año nuevo al final del horizonte, así que siempre hay
cuatro drafts por delante que negociar.

`valorDePick` los pone en la misma escala que `valorDeTraspaso`: se estima el
puesto en que va a caer (por la fuerza actual de la plantilla de origen), se
proyecta el jugador que sale de ese puesto con la misma curva que usa
`generarClaseDeDraft`, y se le aplica un descuento por riesgo (0.45) y otro
por espera (0.88 por año). Con eso un pick alto de un equipo malo vale como
un titular sólido y un segunda ronda apenas mueve la aguja.

## Buscador automático (`traspasos_repository.dart`)

Se refactorizó la evaluación en dos capas: `MercadoDeTraspasos` es una foto
de la liga cargada de una vez, y `evaluarEnMercado` es puro cálculo en
memoria. Hace falta porque el buscador evalúa decenas de miles de
combinaciones y con una consulta por cada una sería inviable.

- `buscarSalidaPara`: recorre los 29 equipos y de cada uno devuelve el
  paquete más valioso que aún le sale a cuenta darte por tu jugador.
- `buscarFichajeDe`: al revés, las combinaciones de tu plantilla y tus picks
  que bastarían para llevarte al suyo, de la más barata a la más cara y sin
  repetir pieza principal.

Los paquetes son de hasta tres activos por lado, jugadores y picks
mezclados. Todo lo que sale del buscador está ya aprobado por el rival: al
elegirlo se cierra directamente.

Además la evaluación ahora mira también **tu** plantilla resultante, no solo
la del rival. Con una diferencia importante: para el rival es un veto, para
ti es solo un aviso (`RespuestaTraspaso.aviso`). Si quieres vaciar un puesto
y taparlo después en la agencia libre, es tu equipo. La mesa de traspasos
pinta el aviso en ámbar y pide confirmación antes de cerrar; el buscador
automático usa el veto, porque no tiene sentido que te proponga él solo
paquetes que te dejan cojo.

## Traspasos entre equipos de la CPU (`traspasos_cpu_repository.dart`)

En cada pretemporada la liga se mueve sola. No por valor —eso sería un
equipo regalándole un jugador a otro— sino **por encaje**: se mide el nivel
de cada puesto (la media de los dos que jugarían ahí), se comparan con la
media del propio equipo, y se cruzan excedentes con carencias. A suelta a su
tercer alero, B a su tercer base, los dos mejoran y el saldo de valor queda
parejo (tolerancia del 20%).

Contar cabezas no valía: con las segundas posiciones casi todos los equipos
tienen cuatro o más jugadores "cómodos" en cada puesto. Hay que medir nivel.

Cada equipo entra como mucho en un intercambio por pretemporada, así que
todos los cálculos se hacen sobre la misma foto. Salen entre 7 y 9
movimientos por año, de jugadores de rotación. Se listan en la pantalla de
pretemporada ("Movimientos en la liga").

## Ofertas entrantes (`ofertas_repository.dart`, tabla `OfertasTraspaso`)

Mientras simulas, los otros equipos también trabajan. La probabilidad va con
el tramo simulado (un día casi nunca, un mes bastante a menudo) y hay un tope
de tres ofertas esperando. El equipo que la manda se elige entre los que de
verdad necesitan ese puesto.

Lo que te llega es un paquete que ese equipo aceptaría si se lo propusieras
tú (sale del propio buscador), así que aceptarlo no puede acabar en un "pues
ahora que lo pienso, no". Las ofertas que se quedan obsoletas —el jugador se
fue, el pick se gastó— se limpian solas al leerlas.

Al terminar de simular sale el aviso y se va a `OfertasScreen` sin salir del
calendario, igual que con el campeón de la Cup. En el menú principal hay una
entrada "Ofertas recibidas" con contador.

## Verificación

`flutter analyze` limpio, **117 tests de `manager_nba`** y 14 de
`sim_engine`. Nuevo `traspasos_avanzados_test.dart`: generación y horizonte
de picks, valoración (peor equipo > mejor, 1ª > 2ª, cercano > lejano), el
draft respetando al dueño del pick, picks dentro de un traspaso, los dos
buscadores (proposiciones válidas y ejecutables, orden de menos a más caro),
los traspasos de la CPU sin romper plantillas, y el ciclo completo de una
oferta entrante.

Esquema en la versión 17 — al abrir la app **hay que empezar partida nueva**.

---

# Caza de bugs y lavado de cara

## Bugs encontrados y arreglados

Se montó una prueba de estrés que juega una temporada entera traspasando
gente cada ocho partidos y aceptando ofertas por el camino
(`temporada_con_mercado_test.dart`). Salieron tres cosas:

1. **Traspasar a un titular a mitad de temporada reventaba la partida.** La
   rotación guardada seguía apuntando al que se había ido, y
   `construirEquipoUsuarioParaFecha` hacía `plantillaPorId[id]!` sobre un
   nulo: "Null check operator used on a null value" al simular el siguiente
   partido, sin forma de seguir jugando.

   Arreglo en tres capas: `repararRotacion` conserva las filas válidas —tus
   minutos y tus roles de estrella no se tocan— y rellena solo los huecos con
   el mejor del puesto; `sanearTrasMovimientoDePlantilla` es el punto único
   por el que pasan traspasos, fichajes y ofertas aceptadas; y el montaje de
   alineación trata a un jugador que ya no está como no disponible (igual que
   un lesionado) en vez de reventar.

2. **Quien llegaba en un traspaso se quedaba sin dorsal** hasta la
   pretemporada siguiente, porque el reparto de números solo corría al crear
   la franquicia y al cerrar el draft. Ahora corre en el mismo saneo.

3. **Los traspasos podían dejarte con más de 18 jugadores**, saltándose el
   tope de plantilla que sí respeta el resto del juego. Se añadió la
   comprobación a `plantillaRota`, con la regla de "no empeorar": a un equipo
   que ya venga pasado de tope no se le prohíbe un uno por uno que lo deja
   igual.

También se añadió `integridad_test.dart`: diez temporadas seguidas con el
mercado vivo y, al final, se comprueban plantillas dentro de límites, cinco
puestos con recambio, dorsales únicos, masa salarial, horizonte de picks
intacto y sin dueños fantasma, nombres únicos y nadie en un equipo que no
existe.

## Visual

- **Menú principal**: cabecera con degradado de los colores del equipo, logo,
  código y ciudad, temporada, récord, partidos jugados y masa salarial (en
  rojo si te pasas del tope). Los accesos van agrupados en secciones
  (Mercado / Competición / Legado), cada uno con su icono en un cuadro de
  color propio, y las ofertas pendientes salen con contador rojo.
- **Clasificación, equipos**: logo y nombre completo en vez del código
  pelado, barra de porcentaje de victorias con el color del equipo, columnas
  de V-D, % y partidos de diferencia con el líder, tu equipo resaltado con
  una banda lateral, y las líneas que marcan el corte de playoffs (6º) y del
  play-in (10º).
- **Clasificación, jugadores**: selector de PTS/AST/REB como botones
  segmentados en vez de un desplegable, logo del equipo, medallas de oro,
  plata y bronce para el podio y las tres estadísticas en columnas
  alineadas, con la que ordena destacada.

Verificación: `flutter analyze` limpio, **121 tests de `manager_nba`** y 14
de `sim_engine`. Nuevo test de que el menú principal cabe y se recorre entero
en una pantalla de 360x640 sin desbordes.

---

# Fase 10 (en curso): tanda grande de feedback

Lista larga de ~23 puntos de feedback tras probar la app. Se trabaja por
fases dentro de la misma sesión; cada tarea se cierra con
`flutter analyze` limpio y su propio test.

## Hecho hasta ahora

- **Philadelphia**: apodo cambiado de "75ers" a "67ers".
- **Nombres de draft**: las listas de nombres/apellidos generados eran
  literalmente estrellas reales con una o dos letras cambiadas (Doncik,
  Jokik, Antetokunmo, Wembanyema, Bogdanovik...). Reescritas de cero con
  nombres inventados propios, repartidos por origen con pesos 70% EEUU /
  24% Europa / 6% África (`_origenSorteado` en `draft_repository.dart`).
- **Potencial oculto**: ya no se ve el número en agencia libre ni vistas
  generales; en el Draft se ve como escala de 1 a 5 estrellas
  (`potencial_estrellas.dart`).
- **Contador redundante**: quitado "Jugados X/82" del hub (va integrado en
  la etiqueta del récord).
- **Bug Rookie del Año**: usaba `edad <= 21` como proxy de "es rookie", así
  que un jugador podía ganarlo varias temporadas mientras siguiera siendo
  joven. Ahora exige que sea su primera temporada jugada de verdad (sin fila
  previa en `HistorialEstadisticasJugador` y `temporadasPrevias == 0`).
- **Navegación directa al menú**: nuevo `shared/navegacion.dart` con rutas
  con nombre (`RutasPrincipales.hub`/`calendario`) y `volverAlMenuPrincipal`/
  `volverAlCalendario`, que hacen `popUntil` en vez de acumular pantallas.
  Botón de casa en Premios y Resumen de simulación.
- **Fichaje de agente libre como negociación**: nueva `ofrecerContratoFichaje`
  en `agencia_libre_repository.dart`, con el mismo tira y afloja que una
  renovación (hasta 3 ofertas, `probabilidadDeAceptar` extraída como función
  compartida en `contratos_repository.dart`). El botón "Fichar" de toda la
  vida se sustituye por un diálogo de oferta (sueldo + años), igual que
  Renovaciones. El botón de "Completar con contratos mínimos" (atajo
  automático) no se toca.
- **Aviso de agencia libre lleva al sitio correcto**: el diálogo de fecha
  límite mostraba siempre "Ir a Traspasos" aunque la fecha límite cruzada
  fuera la de agencia libre. Ahora `esFechaLimiteDeAgenciaLibre` decide texto
  y destino.
- **Ver plantilla desde Draft/Agencia libre**: icono en la AppBar de ambas
  pantallas que abre `RosterConfigScreen` en modo consulta (mismo patrón que
  desde el menú) sin perder el paso obligatorio de pretemporada.
- **Variedad de marcador**: los partidos entre equipos de nivel medio
  apenas se movían de ~224 puntos totales porque cada equipo tiraba su
  propio ruido independiente, que tendía a compensarse. Se añadió un
  "ritmo" de partido (`PesosAtributos.sigmaRitmo`, sorteado una vez y
  compartido entre los dos equipos) que ahora sube o baja el marcador de
  los dos a la vez: hay partidos de anotación claramente baja (<200) y
  claramente alta (>250), no solo variación de un par de puntos.

## Nota sobre tests de UI

Dos pantallas (`AgenciaLibreScreen`, `DraftScreen`) hacen que
`tester.pumpAndSettle()` (y hasta `tester.pump()` suelto) se quede colgado
sin motivo aparente en el entorno de test — investigado sin encontrar la
causa raíz dentro del tiempo razonable, así que su verificación de "ver
plantilla" se apoya en `flutter analyze` + revisión manual del cambio (un
patrón ya usado con éxito en otro sitio de la app) en vez de un test de
widgets. Si se retoma, aislar con `tester.pump()` acotado en vez de
`pumpAndSettle` y comprobar primero si el bloqueo viene de NativeDatabase
FFI dentro de la zona fake-async del test.

## Pendiente

Quedan 16 tareas: Legado unificado, clic en clasificación, contraofertas,
picks visibles en "Tu equipo", pantalla de traspasos de 3 columnas (+ bug
de masa salarial con Jaylen Brown), lesiones con vuelta automática al rol,
bracket visual de NBA Cup, rediseño de All-Star (titulares reales + MVP +
Rising Stars + votación), bracket de playoffs con Play-In resuelto,
celebración de campeón + MVP de Finales, retirada automática de camisetas
de leyendas + carrera completa del retirado, curva de declive más suave, y
slots de guardado.

## Más hecho en esta misma tanda

- **Lesiones leves vs graves de verdad**: antes cualquier lesión (leve o
  grave) dejaba al jugador completamente fuera de la alineación. Ahora solo
  la grave le saca del partido (`jugadoresFueraDeJuegoEn`); una leve le deja
  jugar sus minutos normales pero con el rendimiento penalizado
  (`factorRendimientoLesionLeve = 0.82`, combinado con el estado de forma vía
  `factoresLesionLeveEn`). Se verificó además que la vuelta automática al
  puesto titular/suplente al recuperarse ya funcionaba (la rotación guardada
  nunca deja de decir quién es titular; solo se reevalúa la disponibilidad
  cada partido), así que no hacía falta tocar nada ahí.
- **Curva de declive de veteranos**: la caída de UN año se multiplicaba por
  los años acumulados en declive sin límite, así que una estrella que
  seguía jugando a los 38-40 podía perder 10-13 puntos de golpe en una sola
  temporada. Ahora la intensidad del declive se estabiliza a partir de los
  ~6 años (`min(anosDeDeclive, 6)`), así que un veterano longevo sigue
  bajando pero nunca a un ritmo disparado.
- **Picks visibles en "Tu equipo"**: icono en la AppBar de
  `RosterConfigScreen` que abre una hoja con tus elecciones de draft
  vivas.
- **Clasificación clicable**: tocar un equipo abre su plantilla completa
  (`EquipoDetalleScreen`); tocar un jugador —desde la plantilla de un
  equipo o desde los líderes de estadísticas— abre su ficha (stats de la
  temporada, contrato y, si no es tuyo, un botón "Intentar traspasar" que
  llama al mismo buscador automático de la mesa de traspasos). Se extrajo
  `HojaDePropuestas` a `shared/` para no duplicarla.

Verificación: `flutter analyze` limpio, **136 tests de `manager_nba`** y 16
de `sim_engine`.

## Pendiente (10 de 23)

`#97` Legado unificado, `#105` contraofertas, `#107` traspasos de 3
columnas + bug de masa salarial con Jaylen Brown, `#109` bracket visual de
NBA Cup, `#110` rediseño de All-Star (titulares reales + MVP + Rising Stars
+ votación), `#112` bracket de playoffs con Play-In resuelto, `#114`
celebración de campeón + MVP de Finales, `#115` retirada automática de
camisetas de leyendas + carrera completa del retirado, `#117` slots de
guardado.

---

## Checkpoint — tanda de los puntos grandes

Hechos en esta tanda (todo verificado con `flutter analyze` limpio y la
suite entera en verde: 167 tests):

### #107 — Mesa de traspasos de tres columnas y encaje salarial

El bug de "traspasar por Jaylen Brown rompe el tope" no era un fallo de
cálculo: **media liga arranca por encima del tope** (los sueldos reales
suman 216M de media por equipo y el tope está en 220M; CLE llega a 286M),
así que la regla de "no puedes pasarte del tope" bloqueaba cualquier
operación con un sueldo grande dentro. Se ha cambiado por la regla real de
la NBA (`encajeSalarialRoto` en `traspasos_repository.dart`): si acabas por
debajo del tope todo vale; si te quedas por encima, solo puedes recibir
hasta un 125% de lo que sueltas (+5M de colchón).

Además el motor de traspasos se ha generalizado a N equipos:
`MovimientoDeTraspaso` (activo + destino), `evaluarMultipleEnMercado`,
`evaluarTraspasoMultiple` y `ejecutarTraspasoMultiple`. `evaluarEnMercado`
(dos equipos) ahora delega en él, así que hay un único camino de código.
`BalanceDeEquipo` expone, equipo a equipo, lo que entra y sale de dinero y
de valor.

`TraspasosScreen` reescrita: tu columna + rival + tercero opcional, con
selector de destino por pieza (flecha que rota) cuando hay tres equipos, y
masa salarial en vivo en la cabecera de cada columna.

### #110 — Fin de semana de las estrellas

- Convocatoria = los 10 mejores de cada conferencia **por lo que están
  haciendo esta temporada**, sin cuotas por puesto; titulares = los 5
  primeros. Los puestos del quinteto se reparten por afinidad
  (`_repartirPuestos`).
- Bug de fondo arreglado: se mezclaban dos escalas (valoración de
  temporada ~20-70 y media del dataset 60-99) en la misma lista, así que
  alguien haciendo la temporada de su vida se caía de la convocatoria. Con
  temporada empezada manda el rendimiento y punto.
- MVP del All-Star y **Rising Stars** (novatos vs. sophomores) con su
  propio MVP. Ambos se guardan como `TipoPremio` nuevos — sin tocar el
  esquema, así que **no hace falta partida nueva**. `calcularPremios` ya no
  vacía la tabla entera, solo sus propios premios.
- Nueva pantalla `AllStarScreen` con la votación en directo (recuento
  animado, votos deterministas derivados de la valoración), resultado de
  los dos partidos y sus MVP. Entrada propia en el menú.

### #112 / #114 — Playoffs

- `playInPendiente` y `seriesJugablesAhora`: solo se puede jugar la ronda
  más baja pendiente, así que el 3-6 y el 4-5 ya no se pueden jugar antes
  de que el play-in decida quién es el 7 y el 8.
- Bracket con cabecera de conferencia (Oeste / trofeo / Este) y nombre de
  ronda por columna; play-in en dos columnas por conferencia diciendo qué
  se juega en cada partido.
- `mvpDeLasFinales`: mejor del campeón agregando los boxscores de la serie,
  con sus medias.
- Diálogo de campeón: "Campeones de la NBA 2027-28" (nombre completo +
  temporada), confeti (`shared/confeti.dart`, `CustomPainter`, sin
  dependencias), vibración y tarjeta del MVP de Finales. Botón "Siguiente
  temporada" dentro del propio bracket — el cambio de año se ha extraído a
  `features/temporada/cambio_de_temporada.dart` para no duplicarlo.

### #109 — NBA Cup

Mismo tratamiento visual: cuadro real con conferencias separadas y la Final
en el centro, en vez de la lista de texto.

### #117 — Ranuras de guardado

Tres partidas en paralelo, **una base de datos por ranura**
(`manager_nba_slot1.sqlite`...). `domain/slots_repository.dart` define
`AlmacenDeSlots` con dos implementaciones: en disco (la app) y en memoria
(los tests, que si no dependerían de `path_provider`). Los ajustes viven en
su propio fichero, así que sobreviven a borrar cualquier partida. La
partida de las versiones anteriores se rescata sola: `manager_nba.sqlite`
pasa a ser la ranura 1 al arrancar.

`StartMenuScreen` es ahora el menú de partidas: cada ranura enseña equipo,
temporada, récord y anillos, con Continuar / Borrar, o "Empezar" si está
vacía.

### Pendiente

- #97 Unificar Hall of Fame y Camisetas Retiradas en "Legado".
- #105 Contraofertar una oferta recibida.
- #115 Retirada automática de camisetas de leyendas reales + ver carrera
  completa del retirado.

### #97 / #115 — Legado

Una sola entrada de menú, "Legado", con dos pestañas (Hall of Fame y
Camisetas retiradas). Los cuerpos se han extraído a `HallDeLaFamaBody` y
`CamisetasRetiradasBody` para que las pantallas sueltas —el Hall of Fame
del cambio de año, con su botón Continuar— sigan funcionando igual.
Camisetas retiradas se abre filtrada por tu equipo, con desplegable para
ver cualquier otro o la liga entera.

Retirada automática de leyendas reales: `domain/leyendas.dart` mapea 41
nombres reales del dataset a las franquicias con las que hicieron historia
(Chris Paul → LAC/NOP, Westbrook → OKC, Klay → GSW...). Al retirarse, la
camiseta la retira esa franquicia aunque acabaran jugando en otra, y sin
exigirles currículum dentro del juego — ya se lo ganaron antes. Hay un test
que verifica que los 41 nombres existen tal cual en el dataset: si alguno
se escribiera mal, la retirada no se dispararía nunca y nadie se enteraría.

Carrera completa del retirado: `leerCarreraParaFicha` (a diferencia de
`leerCarrera`, que es la que puntúa el Hall of Fame) devuelve la carrera
aunque no se haya archivado ninguna temporada. La ficha enseña un bloque
"Antes de tu partida" con las temporadas previas y su producción de
referencia, separado de lo simulado — de aquellos años no hay boxscores y
mezclarlo sería inventarse unas medias de carrera.

### #105 — Contraofertas

"Contraofertar" en una oferta recibida abre la mesa de traspasos con las
piezas ya puestas (`PropuestaDePartida`), evaluada de entrada, para quitar,
añadir o meter a un tercer equipo. La oferta original se queda en la
bandeja por si la contrapropuesta no cuaja.

**Estado: los 23 puntos del feedback están cerrados.** 176 tests en la app
+ 16 en `sim_engine`, `flutter analyze` y `dart analyze` limpios.

### Palmarés global entre partidas (post-slots)

Al añadir las ranuras de guardado, `HistorialCampeones` había pasado a vivir
dentro del fichero de cada ranura — así que los trofeos del selector de
equipos dejaban de verse si cambiabas de partida o borrabas una. El usuario
confirmó que eso no era lo que quería: el palmarés es un logro tuyo, no de
la ranura.

Arreglado con doble escritura en `registrarCampeon`
(`campeones_repository.dart`):
- En la propia partida, sin cambios — de ahí sigue saliendo el anillo que
  se le apunta a un jugador concreto en su carrera (`carrera_repository.dart`),
  algo que solo tiene sentido dentro de la línea de tiempo de esa ranura
  (por eso NO se ha tocado ni `carrera_repository.dart` ni el recuento de
  títulos por ranura en `slots_repository.dart`).
- En el registro compartido (`abrirAjustes()`, el mismo fichero que ya
  guardaba tema/idioma): de ahí sale `equiposConTituloDelUsuario`, que es
  lo único que de verdad tenía que dejar de depender de la ranura.

`AlmacenDeSlotsEnDisco.ajustes()` pasa a cachear la instancia (antes abría
una conexión nueva cada vez).

Efecto colateral importante: `registrarCampeon` se dispara en cuanto se
resuelve un campeón de la NBA o de la NBA Cup, algo a lo que puede llegar
*cualquier* test que simule un tramo de temporada lo bastante largo — no
solo los que prueban playoffs. En vez de parchear cada archivo de test uno
a uno, se ha añadido `test/flutter_test_config.dart` (el hook que Flutter
reconoce automáticamente): sustituye el almacén por uno en memoria para
toda la suite antes de que corra ningún test, sin tener que tocar los
demás archivos. Los tests que sí necesitan aislar el palmarés entre sí
(campeones_repository_test, carrera_larga_test, legado_test,
playoffs_repository_test, torneo_temporada_test, playoffs_screen_test)
siguen creando su propio `AlmacenDeSlotsEnMemoria` en su `setUp`, que
sustituye al de la config global solo por la duración de ese test.

Verificado: `flutter analyze` limpio, 177 tests en verde (176 + 1 nuevo
sobre la independencia partida/palmarés), `dart analyze` de sim_engine sin
tocar y limpio.

### Legado real: camisetas retiradas y Hall of Fame de verdad

El usuario pasó dos datasets reales (`retired_numbers.json`: 232 filas de
las 30 franquicias; `hof_players_simple.json`: 155 miembros del Hall of
Fame real con G/PTS/TRB/AST de carrera). Copiados a `assets/data/` y
declarados en `pubspec.yaml`.

`domain/legado_historico_repository.dart` — `importarLegadoHistoricoSiHaceFalta(db)`,
idempotente, sin tocar el esquema:
- Filtra las 232 filas de camisetas a las 215 con un número de verdad
  (descarta "-" — honores sin camiseta, directivos/locutores— y valores
  como "432"/"1223" que son victorias de entrenador coladas por el campo
  del número; "00" se trata como el dorsal 0). Verificado con test que
  cuenta exactamente 215.
- Cada fila histórica se guarda con `jugadorId` **negativo** — nunca hay
  simulación detrás, y un negativo no puede colisionar jamás con un
  `Jugadores.id` real (siempre autoincremental positivo). `leerCarreraParaFicha`
  ya sabía degradar con elegancia un id que no existe (de la tanda
  anterior), así que la ficha de una leyenda real no se rompe, solo
  enseña "no hay estadísticas simuladas" (mensaje distinto ahora,
  `esHistoriaReal`, de "no llegó a completar ninguna temporada").
- Sentinelas sin tocar el esquema: `CamisetasRetiradas.temporada = 0`
  marca "historia real" (ninguna temporada jugada de verdad vale nunca 0);
  `HallDeLaFama.temporadaIngreso` negativo codifica el año real de
  ingreso (1959-2026, siempre fuera del rango positivo de temporadas de
  cualquier partida). Ambas pantallas (`camisetas_retiradas_screen.dart`,
  `hall_fama_screen.dart`) distinguen el caso al pintar el subtítulo.
- `nuevaFranquicia` ahora borra solo camisetas/HOF con `jugadorId >= 0`
  (logros de la partida anterior): lo real sobrevive a "empezar de cero"
  en la misma ranura, tal y como sobrevivía ya `HistorialCampeones`.
- Se llama desde `start_menu_screen.dart` en los dos puntos de entrada a
  una ranura (`_continuar` y `_empezarEn`), así que también hace de
  backfill silencioso para partidas ya creadas antes de este cambio.

**Bloqueo de números retirados** (lo que pedía el usuario explícitamente):
`dorsales_repository.dart` gana `liberarDorsalesDeNumerosRetirados`,
llamada al principio de `asignarDorsalesQueFalten` (junto al ya existente
`_liberarDorsalesDuplicados`): dejar sin dorsal a cualquier jugador activo
que lleve puesto un número que su equipo tenga retirado — real o ganado
dentro de la partida — antes de repartir. Como `asignarDorsalesQueFalten`
ya se llamaba al crear franquicia, tras el draft, y tras cualquier
movimiento de plantilla (`sanearTrasMovimientoDePlantilla`), la garantía
se propaga sola a todos esos sitios. Además `retirarCamiseta` (camisetas_repository.dart)
llama a `asignarDorsalesQueFalten` justo después de insertar, para que
una colisión se resuelva en el acto y no solo en el siguiente movimiento
de plantilla.

Verificado con 8 tests nuevos (`test/legado_historico_test.dart`): conteo
exacto de filas válidas, jugadorId negativo, año codificado, idempotencia,
reasignación inmediata ante colisión (tanto al importar como al retirar
una camiseta en directo dentro de la partida), y que `nuevaFranquicia`
conserva lo real y borra solo lo de la partida anterior.

**185 tests en verde** (177 + 8), `flutter analyze` limpio, `sim_engine`
sin tocar.

## Tanda de bugs y mejoras de `lista_bugs_mejoras.txt` (21 puntos)

Tras probar la app en Windows. Los tres bugs de fondo resultaron ser de
arquitectura, no de la funcionalidad que los delataba:

1. **Pantallas en blanco / "camisetas retiradas vacío"**. El
   `DropdownMenuItem` del selector de franquicia metía un `Flexible` en su
   `Row`. El desplegable mide sus opciones con anchura infinita, y un hijo
   con flex bajo constraints no acotadas revienta el layout — y con él la
   pantalla entera. Solo se disparaba cuando el desplegable tenía equipos
   que listar, es decir justo desde que se importaron las 215 camisetas
   reales (antes `porEquipo.isEmpty` cortaba antes de construirlo). El dato
   siempre estuvo bien: se verificó leyendo los `.sqlite` de las tres
   ranuras del usuario.

2. **Pestañas colgadas / masa salarial a 0**. Futuros creados dentro de
   `build`. El Hall of Fame era el caso extremo: un `FutureBuilder` por
   miembro, cada uno con cuatro consultas (una recorriendo el palmarés
   entero), 155 miembros = más de 600 consultas por repintado, saturando la
   única conexión de la base de datos y dejando colgada cualquier otra
   pantalla que pidiera datos a la vez. Se añadió `leerCarrerasParaFichas`
   (4 consultas en total) y se pasaron Hall of Fame y Premios a un único
   futuro cacheado con los errores a la vista.

3. **"Simular mes se cuelga"**. `repararRotacion` daba minutos fijos al
   sustituto cuando solo se iba media pareja de un puesto, así que con un
   reparto personalizado la rotación dejaba de sumar 240 y `EquipoPartido`
   lanzaba una excepción no capturada.

Otros cambios de fondo: reparto de alineación en tres pasadas
(`repartirPorPuestos`), que quita el problema de que el recorrido PG->C
dejara al pívot titular siendo el peor del equipo; el 1 y el 2 de playoffs
sembrados desde el primer día con el rival "Por definir"; y la simulación
avanzando por etapas semanales para poder pararse ante una oferta.

Pendiente: el punto 15 (qué leyenda retira número en qué equipo) espera la
lista del usuario, y el 20 (caída de estadísticas) necesita un caso concreto
—jugador y temporada— porque la fórmula actual ya tiene un tope de ~8 puntos
por temporada.

---

# Fase 7 — Móvil y tablet, sin perder el escritorio

## Contexto

Hasta aquí todo se ha construido y verificado contra una ventana de
Windows: en este mismo documento no aparecía la palabra móvil ni una sola
vez, y cada bloque de verificación decía `flutter run -d windows`. El
objetivo real es jugarlo también en iPhone y iPad, así que toca una pasada
de adaptación.

El punto de partida, medido: de las **31 pantallas, solo 3** tenían lógica
adaptable (traspasos, playoffs y Hall of Fame). La capa de datos, en
cambio, ya es portable tal cual — drift, `sqlite3_flutter_libs` y
`path_provider` funcionan igual en Android y en iOS, y el motor de
simulación es Dart puro.

Se adapta, no se bifurca: **una sola app** que se reordena según el ancho
disponible. Nada de una versión de móvil y otra de PC.

## Los cuatro tamaños

Un único sitio donde se decide (`lib/shared/pantalla.dart`), para que
ninguna pantalla invente su propio corte:

- **compacto** (< 600): teléfono en vertical. Una columna, todo apilado.
- **medio** (600-1023): teléfono apaisado y tablet pequeña. Dos columnas.
- **amplio** (>= 1024): tablet grande y escritorio. Lo de ahora.

## Lo que hay que arreglar

1. **Playoffs**: el bracket se dibuja con `Stack`/`Positioned` sobre un
   lienzo ancho fijo. En un teléfono no se ve nada. En compacto pasa a
   lista por rondas; de medio para arriba sigue el bracket de siempre.
2. **Boxscore**: `DataTable` de 7 columnas, que se desborda en estrecho.
3. **Traspasos**: tres columnas en paralelo; ya cae a scroll horizontal,
   pero apretadísimo en un móvil.
4. **Calendario**: rejilla de 7 columnas por mes.
5. **Densidad táctil**: `ListTile(dense: true)` e `IconButton` de 18px por
   todas partes — cómodos con ratón, pequeños para un dedo. Los mínimos de
   48px solo se aplican en compacto y medio: en escritorio la densidad alta
   es una ventaja, no un defecto.

## Verificación

Además de `flutter analyze` y la suite entera, un test nuevo
(`adaptacion_movil_test.dart`) que monta las pantallas principales a
390x844 (iPhone), 820x1180 (iPad) y 1600x900 (escritorio) y comprueba que
ninguna desborda. Los desbordes de Flutter salen como excepción en test,
así que sirven de red de verdad y no de foto que hay que mirar a mano.

## Resultado de la Fase 7

Hecho: helper de tamaños (`lib/shared/pantalla.dart`, cortes 600/1024),
playoffs por conferencia en compacto con selector que arranca en la tuya,
boxscore con tabla propia en estrecho, celda de calendario sin la
abreviatura del día, mesa de traspasos a dos columnas (el tercer equipo
baja a botón) y densidad táctil aplicada **desde el tema** en
`main.dart` — `minTileHeight` se aplica aunque el widget traiga
`dense: true`, así que sube el alto de todas las filas sin tocar 31
pantallas una por una.

Dos desbordes que el test nuevo cazó y que existían de antes: el aviso
"Esperando al Play-In" se salía 39px de su caja en el bracket (también en
escritorio, porque la caja tiene ancho fijo) y la celda del calendario se
salía 10px en un teléfono.

Verificación: 298 tests, de los cuales 30 son de adaptación.
