# ESTADO ACTUAL (leer esto primero)

**El juego está PUBLICADO y jugable en:**

```
https://jokar77.github.io/manager-nba/
```

- **Repositorio:** `https://github.com/jokar77/manager-nba` (público, rama
  `main`). El usuario es `jokar77`.
- **Publicación automática:** cada `git push` dispara
  `.github/workflows/publicar.yml`, que compila, pasa los tests y despliega
  en GitHub Pages. Si los tests fallan NO se publica.
- En Settings → Pages, *Source* está en **GitHub Actions** (ya configurado).
- `gh` CLI NO está instalado; `git` sí (2.55). **`git push origin main`
  funciona desde aquí** (las credenciales están guardadas): en la sesión
  del 19 de agosto de 2026 se subieron cinco commits sin que el usuario
  tuviera que hacer nada. La nota antigua decía que lo tenía que hacer él
  a mano; ya no hace falta técnicamente.
- **PERO NO SE SUBE NADA SIN QUE LO PIDA.** Instrucción expresa del
  usuario (20 de agosto de 2026): *"cada vez que hagas algo no lo subas al
  git, déjamelo dicho y yo decido si subirlo o no"*. O sea: se hace el
  trabajo, se verifica, se deja en el árbol de trabajo y **se le cuenta
  qué hay**. Ni `git commit` ni `git push` por iniciativa propia.
- Verificación local: `flutter analyze` limpio en los dos paquetes,
  **428 tests** de la app + **19** de `sim_engine`, y `flutter build web`
  correcto.
- PowerShell 5.1 **no admite `&&`**; el Bash de Git sí. Los dos están
  disponibles y se usa el que convenga.

## EN CURSO — Lista 15, punto 1 CERRADO con datos reales; punto 2 hecho; verificando

Sesión del 24 de agosto de 2026, continuación directa de la de ayer.

### La clase de draft 2026 ya tiene datos reales (cierra el hueco de Rising Stars)

El usuario pasó `Draft_2K27_Orden_Real_Atributos_Generados.csv` (60
prospectos: Pick, Jugador, Equipo, Posicion, Altura, Dorsal, Media_OVR,
Potencial, Ataque, Defensa) y pidió aplicarlo al juego cambiándoles el
nombre 1-2 letras — el mismo tratamiento que ya llevan el resto de
jugadores reales del dataset (`nombre_ficticio` vs `nombre_real`, ver
`preparar_datos_nba_v27.py`, función `generar_nombre_parecido` /
`mutar_palabra` / tabla `SUSTITUCIONES`).

De los 60, **59 ya existían** en `jugadores.json` como placeholders con
`draft_year: 2026` pero con `atr_tiro3`/`atr_ataque`/`atr_defensa`/
`pts_pg`/`ast_pg`/`trb_pg`/`factor_longevidad` a `null` — por eso el
import los descartaba (`_camposObligatorios` en `jugadores_importer.dart`)
y por eso Rising Stars se quedó sin clase de novatos de verdad (ver la
sesión de ayer). El otro (**Chris Cenac Jr.**) no tenía placeholder y se
creó de cero.

Aplicado con un script de Node (Python no está instalado aquí):
`C:\Users\nanot\AppData\Local\Temp\claude\...\scratchpad\aplicar_rookies_2026.js`
(en el scratchpad de la sesión, no en el repo). Qué hace:

- **De la CSV, tal cual**: `media` (Media_OVR), `potencial`, `atr_ataque`
  (Ataque), `atr_defensa` (Defensa), `posicion` (el combo "PG / SG" tal
  cual — `normalizarPosicion`/`posicionSecundariaDeclarada` en
  `jugador_mapping.dart`/`posiciones.dart` ya saben partirlo por `/`),
  `equipo` (remapeando 3 códigos: CSV usa BKN/CHA/PHX, el juego usa
  BRK/CHO/PHO — el resto de códigos ya coincidían).
- **Ya estaban bien puestos** (no se tocan): `edad` (19), `edad_retiro`
  (36), `draft_year` (2026) — los 59 placeholders ya los traían así.
- **Estimados, a falta de partidos NBA reales que medir** (el CSV no trae
  esto): `atr_tiro3`, `pts_pg`, `ast_pg`, `trb_pg` — interpolación lineal
  a trozos desde `Ataque`/`Defensa`, con un factor por puesto (un base más
  rebotador y menos asistente que un base, etc.). `factor_longevidad`
  fijo a `1.0` (la moda de la distribución triangular que usa el script
  de Python para todo el mundo). Documentado en el propio script y en el
  comentario de `_camposObligatorios`.
- **`nombre_ficticio`**: regenerado para los 60 con un puerto a Node de
  `generar_nombre_parecido`/`mutar_palabra`/`SUSTITUCIONES` (mismo
  algoritmo, mismas sustituciones de letra — `a↔e`, `o↔u`, `s↔z`, etc.,
  2 letras cambiadas repartidas entre nombre y apellido según su
  longitud). RNG sembrada por el nombre real (no `Math.random()`), para
  que sea reproducible. Antes de este cambio los 59 placeholders tenían
  `nombre_ficticio == nombre_real` sin ofuscar — se quedaban así porque
  nunca habían pasado por `aplicar_nombres_parecidos` al no tener
  atributos con los que jugar.

Subido también `jugadoresUtilizablesDelDataset` de 586 a **646** en
`jugadores_importer.dart` (ahora los 646 jugadores del asset pasan el
filtro; antes 60 se quedaban fuera). Ver el test
`jugadores_importer_test.dart` que compara esta constante contra el
asset de verdad.

Verificado con Node antes de escribir: 59 matches exactos + 1 sin match
(Chris Cenac Jr.) contra los 59 placeholders `draft_year: 2026`; cero
`nombre_ficticio` repetidos en los 646 tras el cambio; el JSON
reserializado con `JSON.stringify(data, null, 2)` es byte a byte idéntico
al original antes de tocar nada (mismo indentado/orden de claves), así
que el diff que queda es solo el cambio real de valores + la fila nueva
de Chris Cenac Jr. al final del array.

### Lista 15, punto 2: los eventos ya nombran al jugador exacto

`lib/domain/eventos_narrativos.dart`: nuevo enum `RolDeProtagonista`
(`estrella`, `joven`, `veterano`, `titular`, `cualquiera`) y campo
`protagonista` en `EventoNarrativo`, puesto en los 6 eventos que de
verdad hablan de un jugador concreto: `estrella_pide_descanso`,
`joven_pide_minutos`, `veterano_de_vestuario`, `rumor_de_traspaso`,
`jugador_llega_tarde`, `metida_de_pata_en_redes`. El resto (vestuario en
general) se queda sin protagonista, tal cual.

`lib/domain/eventos_narrativos_repository.dart`: `nombreDelProtagonista`
busca en **tu rotación guardada de 10** (`db.rotacionJugador` — "los 10
que están participando" de la lista de bugs) según el rol: la estrella
marcada de más media, un joven (≤23) al azar, el más veterano de la
rotación, un titular al azar, o cualquiera de los 10. Null si el evento
no habla de nadie o si la rotación no está completa (no debería pasar en
partida real — no se puede jugar sin rotación completa — pero un test
puede montar un evento suelto sin rotación, y no revienta por eso).

Guion (`i18n/eventos_{es,en,fr,pt,de,it,zh}.dart`): sustituido el sujeto
genérico ("tu mejor jugador", "un veterano", "uno de tus titulares") por
un hueco `{jugador}` en el título y, donde el texto lo repetía de forma
explícita, también en el planteamiento. `TextosDeEventos.conNombre(texto,
nombre)` hace el reemplazo; `jugadorGenerico` por idioma es el respaldo
si no hay nadie que nombrar (no debería darse nunca en partida real).

`evento_narrativo_dialog.dart`: `plantearEvento`/`contarConsecuencia`
reciben ahora `nombreProtagonista` opcional y lo aplican a título, texto
y etiquetas de opción. Aprovechado también para la segunda parte del
punto 2 ("las consecuencias deben expresarse claras"): `_FilaDeEfecto`
ahora enseña el **porcentaje real** del efecto (`+1%`/`-2%`, el mismo
número que mueve `multiplicadorDeEventos`) además de la etiqueta y los
partidos — antes solo había un icono de flecha y un texto sin ningún
número. Se optó por esto y NO por convertir el efecto en puntos de
`media` del jugador (el ejemplo literal de la lista, "+1/+2 media"):
el sistema de eventos es deliberadamente de equipo, no por jugador (ver
el bloque de comentarios largo al principio de `eventos_narrativos.dart`
sobre por qué — 3,7 victorias por cada 1%, y por qué un efecto por
jugador rompería ese equilibrio ya medido). Si el usuario de verdad
quiere puntos de `media` por jugador en vez de porcentaje de equipo, eso
es un rediseño de la mecánica, no un arreglo de UI, y merece hablarlo
antes de tocarlo.

Test nuevo: `eventos_narrativos_test.dart`, grupo "protagonista de un
evento" (sin rol → null; sin rotación completa → null sin reventar; con
rotación completa, cada rol saca a alguien de los 10, y la estrella/el
veterano son exactamente los que tocan por media/edad).

### mercado_test.dart: un efecto colateral inesperado del CSV, ya arreglado

Al aplicar el CSV, `flutter test` completo sacó 2 fallos nuevos además de
confirmar que Rising Stars ya volvía a verde:

1. **`jugadores_importer_test.dart`**: el test `'importa el dataset real,
   descartando jugadores sin atributos...'` asumía que SIEMPRE se
   descartaban prospectos (`expect(filas.length, lessThan(645))`) — ya no
   es verdad, los 646 pasan el filtro ahora. Reescrito para documentar el
   antes/después y comprobar un caso concreto (Cameron Boozer entra,
   `draftYear=2026`, `temporadasPrevias=0`) en vez de un recuento vago.
2. **`mercado_test.dart`**, el test de "no hay renovación posible": dejaba
   a Boston pegado exactamente al tope (12M por cabeza al resto de la
   plantilla) para que renovar a su estrella no cupiera. Investigado a
   fondo (con prints temporales en `contratos_repository.dart`, quitados
   después): NO era un bug de lógica, sino que el margen de 12M por
   cabeza dependía de CUÁNTOS jugadores tuviera Boston — con más
   jugadores en plantilla (los 2 nuevos rookies reales de Boston, Chris
   Cenac Jr. y Dillon Mitchell) el hueco bajo el tope pasó a depender de
   una carambola: `resolverVencimientosDeLaCpu` reparte un único
   `Random` entre las 29 CPU antes de llegar a Boston, y con la
   plantilla de Denver también creciendo (2 rookies reales más), un
   jugador de Denver (Tim Hardaway Jr.) pasó de caber a no caber bajo SU
   tope, lo que le quita una tirada de aleatoriedad a él y desplaza en
   uno el resto de la secuencia compartida — y esa carambola, muchos
   jugadores después, cambiaba si a Tatum le tocaba una oferta que sí
   encajaba. Arreglado subiendo el sueldo forzado de "el resto del
   equipo" de 12M a **20M por cabeza**: con eso el equipo está tan por
   encima del tope que no cabe NADA, pase lo que pase antes en el reparto
   de los otros 28 equipos ni cuánto le ofrezcan de más o de menos a la
   estrella por el azar. Comentario nuevo en el test explicando el porqué
   (para que el próximo cambio de dataset no vuelva a tropezar con esto).

### Verificación final: todo en verde

`flutter analyze .` limpio y `flutter test --no-pub` (suite completa):
**676 tests, 0 fallos.** Confirmado tras aplicar el CSV de rookies 2026 y
arreglar los dos tests de arriba.

### Lista 15, punto 3: quitado el botón duplicado de "Temporada entera"

`lib/features/hub/home_hub_screen.dart`: la tarjeta de próximo partido ya
no lleva el botón "Temporada entera" — solo "Simular 1 partido". El botón
vivía aquí de cuando el Calendario todavía no tenía el suyo propio (a la
derecha de su barra de saltos, desde la sesión del 23 de agosto); con los
dos a la vez sobraba uno, y el que se queda es el del Calendario, que es
donde de verdad se ve avanzar la simulación.

De paso, limpieza de lo que solo usaba ese botón: `_TarjetaProximoPartido`
perdió `onSimularTemporadaEntera`/`temporada`/`_puedeTemporadaEntera`;
`_abrirCalendario` volvió a no tener parámetros; y en
`calendario_screen.dart`, `simularTemporadaAlAbrir` (el "arranca solo al
abrir" que solo pedía este botón) y todo lo que dependía de él
(`_yaSimuloLaTemporada`, `_simularTemporadaSiTocaAlAbrir`) — nadie más lo
usaba, así que se quitó en vez de dejarlo muerto.

Tests: quitados los 4 de `simular_temporada_entera_test.dart` que
probaban el botón del hub (ya no existe); añadido uno de regresión en
`tarjeta_proximo_partido_test.dart` que comprueba que "TEMPORADA ENTERA"
ya NO aparece en la tarjeta. Los tests de la barra del Calendario (grupo
"la barra de saltos del calendario", mismo fichero) siguen intactos, no
dependían de esto.

Verificado: `flutter analyze .` limpio, y la suite completa
(`flutter test --no-pub`) en verde. Probado también arrancando
`flutter run -d web-server` (vía `.claude/launch.json`) y cargando la
app en el navegador — sin errores de consola; no se pudo tomar captura
porque el panel de Browser no estaba visible en esta sesión, así que la
confirmación de que el botón ya no aparece se apoya en el test de
regresión de arriba, no en una captura.

### Lista 15, punto 4: el calendario se desplaza solo mientras se simula

Antes, `_scrollearAlMesActual()` solo se llamaba al abrir la pantalla y
al TERMINAR de simular (todo el tramo de golpe): mientras la simulación
estaba en marcha, la vista se quedaba clavada en el mes donde se tocó
"simular", aunque el marcador ya llevara semanas de ventaja.

`lib/features/calendario/calendario_screen.dart`: nuevo `_scrollearAFecha
(DateTime fecha)`, que generaliza el `ensureVisible` que ya existía
(`_scrollearAlMesActual` ahora es un caso particular suyo). Se engancha
en el propio callback `onProgreso` de `_simularHasta`: cada vez que
avanza el progreso (una vez por tramo semanal, no por partido —ver el
paceo arreglado en la sesión del 23 de agosto), se desplaza al mes del
ÚLTIMO partido ya resuelto (`hastaAhora.last.fecha`) — es el único dato
que avanza en tiempo real durante la simulación, porque `_partidos` (la
lista que pinta el calendario) no se refresca hasta que el tramo entero
termina.

**Sin test de UI para el desplazamiento en vivo**, a propósito: el propio
fichero de la barra de progreso (`barra_progreso_simulacion_test.dart`)
ya deja anotado que capturar un fotograma intermedio de una simulación
real es una carrera que no se puede hacer determinista aquí, y el mismo
problema aplicaría a comprobar "a media simulación ya se ve un mes más
allá" por captura de pantalla. Lo que SÍ está cubierto: que `onProgreso`
llega varias veces con datos reales que avanzan en el tiempo (test "el
primer tramo pacea semana a semana" en `simular_temporada_entera_test.dart`,
sin tocar), y que `Scrollable.ensureVisible` con esta misma clave de mes
ya funciona (los tests de "son tres saltos..." y compañía). Verificado a
mano con `flutter analyze .` limpio y la suite completa en verde; no se
pudo probar visualmente en el navegador por la misma razón que el punto
3 (el panel de Browser no está visible en esta sesión).

### Lista 15, punto 5: el botón "Temporada" ya no se desborda

`_BotonesAvanceRapido` ya recortaba "Simular 1 semana"/"Simular 1 mes" a
"1 SEMANA"/"1 MES" en compacto (móvil), pero el tercer botón se quedaba
siempre con el texto largo, `textos.simularTemporadaEntera`
("Temporada entera") — mucho más largo que los otros dos, y en un botón
de solo 1/3 de la fila más el icono de candado/avance, eso le hacía
falta 2 líneas dentro de una altura fija de 44px: de ahí el desborde.

Arreglado con el mismo tratamiento que los otros dos: en compacto usa
`textos.temporada` ("Temporada", sin "entera") — una clave que YA
existía traducida en los 7 idiomas (se usa en otras pantallas para
"Temporada X") pero no estaba enganchada a ningún texto de UI todavía,
así que no hizo falta traducir nada nuevo.

Actualizados los 4 usos de `find.text('TEMPORADA ENTERA')` en
`simular_temporada_entera_test.dart` (grupo "la barra de saltos del
calendario", que monta a 390px = compacto) a `find.text('TEMPORADA')`.
Verificado: `flutter analyze .` limpio, la suite completa en verde, y de
paso `adaptacion_movil_test.dart` ya trae desde antes una comprobación
general de que el Calendario no desborda en los tres tamaños (iPhone,
iPad, escritorio) — sigue en verde con el cambio.

### Lista 15, punto 6: el selector de estrella/roles ya enseña la media

`_SelectorEstrellas` en `lib/features/roster/roster_config_screen.dart`:
cada desplegable ordenaba a los candidatos por `nombreFicticio` sin
enseñar ninguna media — elegir estrella de ataque era mirar apellidos y
adivinar. Cada uno de los tres desplegables ahora añade la media que le
toca al nombre de cada opción: el de ataque enseña `atrAtaque`, el de
defensa `atrDefensa`, y el de sexto hombre las dos (no se especializa en
ninguna). Con `textos.ataque`/`textos.defensa` — palabras que ya existían
traducidas en los 7 idiomas (se usan en otra pantalla de esta misma
pantalla, la ficha del quinteto) — así que tampoco hizo falta traducir
nada nuevo. El orden sigue siendo alfabético: lo que pedía la lista era
enseñar la media, no reordenar por ella.

**Efecto colateral encontrado y arreglado**: el texto más largo
("Fulano · Ataque 80" en vez de solo "Fulano") rompió
`flujo_completo_test.dart`, que elegía un candidato buscando su nombre
`skipOffstage: false` (para alcanzar los tres desplegables aunque
estuvieran cerrados) y cogiendo el primero. Con el nombre solo, el texto
coincidía sin querer entre los tres campos (mismo `candidatos` para
ataque y defensa) y esa coincidencia hacía que `.last` cayera siempre en
el desplegable recién abierto, que es justo lo que hacía falta. Al dejar
de coincidir (cada campo trae su propia media), `.first` empezó a coger
el candidato de un campo YA CERRADO —que sigue enseñando su elegido
aunque esté cerrado— en vez del que está de verdad abierto. Arreglado
buscando solo entre los `DropdownMenuItem` visibles en pantalla
(`skipOffstage` por defecto) y cogiendo el ÚLTIMO, que es siempre el del
menú recién abierto. Diagnosticado con prints temporales (quitados
después) que confirmaron el mecanismo exacto antes de tocar nada.

También se fijó `maxLines: 1` en el texto de cada opción del desplegable
(antes no estaba explícito): con el texto más largo, sin fijarlo a una
línea intentaba partirse en dos dentro de la fila de altura fija del
desplegable.

Verificado: `flutter analyze .` limpio y la suite completa
(`flutter test --no-pub`, 672 tests) en verde.

### Lista 15, punto 7: las historias de patrocinadores ya no se cortan (casi nunca)

`_TarjetaDeOferta` en `lib/features/temporada/patrocinadores_screen.dart`
recortaba `p.historia` a `maxLines: 2` a propósito (comentario original:
"con tres ofertas desplegadas, la historia entera dejaba la comparación
fuera de pantalla"). Contado con Node sobre `catalogoPatrocinadores` en
`lib/domain/patrocinadores.dart` (386 patrocinadores): 153 de 386 están
escritos en 3 líneas de fuente, así que con el tope en 2 la MAYORÍA se
cortaba, no una minoría.

Subido a `maxLines: 3`: con eso se leen enteras 382 de las 386 (solo 4,
las historias más largas del catálogo, siguen recortándose — la
excepción, no la norma). La pantalla ya scrollea con las categorías
desplegadas, así que una línea más no saca nada de la pantalla; el
razonamiento original sobre "dejar la comparación fuera de pantalla" no
aplicaba tal cual.

Sin tests que tocar: nada comprobaba el `maxLines` exacto. Verificado
con `flutter analyze .` limpio y la suite completa en verde (672 tests),
incluyendo `adaptacion_movil_test.dart` (que ya vigila que ninguna
pantalla desborde en los tres tamaños).

### Lista 15, punto 8: "bebida oficial" ya no promete lo que no es

Contado el catálogo (`categoria: 'bebida'`, 100 marcas): panaderías,
restaurantes, BBQ, tiendas de aperitivos y cadenas de comida son la
mayoría — cerveceras/cafeterías/refrescos son las menos. "Bebida
oficial" prometía una categoría que en el 90% de los casos no era eso.

Cambiado `patrocinioBebidaLabel` (7 idiomas) a algo que cubre lo que de
verdad hay: ES "Patrocinador de comida y bebida", EN "Food & beverage
sponsor", el resto en el mismo espíritu por idioma. De paso, esta
categoría era la única con el patrón "X oficial" en vez de "Patrocinador
de/del X" que usan las otras tres (estadio/camiseta/ocio) — ahora las
cuatro siguen el mismo patrón. Se dejó el identificador Dart
(`patrocinioBebidaLabel`) y la clave interna (`'bebida'` en
`categoriasPatrocinio`) tal cual: lo que pedía la lista era el nombre en
pantalla, no el identificador interno.

### Lista 15, punto 9: menos repetición año a año en la rotación

`ofertasDe` en `lib/domain/patrocinadores.dart` desplazaba la ventana de
tres ofertas de una en una cada temporada. La nota de la clase dice que
la cantera es "de once a quince marcas", pero eso es el total POR
CIUDAD, repartido entre las cuatro categorías — la cantera que de
verdad importa aquí (ciudad × categoría) es mucho más pequeña: 4
candidatas es lo más común (medido con un script de diagnóstico sobre
las 116 canteras). Con desplazamiento de 1, dos de las tres ofertas de
este año SIEMPRE volvían a salir el año que viene, sin importar el
tamaño de la cantera.

Arreglado desplazando la ventana entera (de tres en tres) en vez de una
en una — pero con un límite real que hay que decir sin adornos: **con
solo 4 candidatas (el caso más común), dos de tres siguen repitiendo
igual que antes.** No es que el arreglo se quedara corto: con 4
candidatas solo hay 4 combinaciones posibles de "3 de 4", y dos
combinaciones distintas cualesquiera comparten al menos 2 por narices
(principio del palomar) — ningún desplazamiento lo evita. Donde SÍ hay
margen, el arreglo lo agota entero: con 5 candidatas el solape baja de 2
a 1 (el mínimo posible), y con 6 o más baja a 0 (tres marcas
completamente distintas cada año). Verificado con un script de
diagnóstico temporal (quitado después) que confirmó el solape exacto por
tamaño de cantera antes de escribir el test de verdad.

Test nuevo en `patrocinadores_test.dart`: para toda cantera con más de
tres candidatas, el solape entre un año y el siguiente es EXACTAMENTE
`max(0, 6 - tamaño_de_la_cantera)` — el mínimo matemático, no una cota
floja. Si de verdad hace falta menos repetición en las canteras de 4 (la
mayoría), la palanca ya no está en esta función: hay que ampliar el
catálogo (`tool/generar_patrocinadores.dart`, fuera del alcance de hoy).

### Lista 15, punto 10: el vídeo sigue haciendo falta con contratos plurianuales

Antes de este arreglo, un patrocinio de varios años (firmado en la
versión gratuita, tras ver el vídeo una vez) seguía dando su margen de
tope salarial TODOS los años del contrato sin volver a pedir nada: el
vídeo desbloqueaba `Funcion.patrocinadores` solo esa temporada
(`Permisos.desbloquearPorVideo`, ver `permisos.dart`), pero
`bonusSalarialDePatrocinadores` en `patrocinadores_repository.dart`
sumaba el bonus de cualquier contrato vivo sin mirar el permiso — el
contrato en sí no caduca hasta que `aniosRestantes` llega a 0
(`caducarPatrocinios`), así que una vez visto el vídeo al firmar, el
resto de temporadas del contrato eran gratis.

Arreglado añadiendo la comprobación de permiso al principio de
`bonusSalarialDePatrocinadores`: lee la temporada actual directamente de
`db.temporada` (una consulta mínima inline, no un import de
`nueva_temporada_repository.dart` — ese fichero ya importa
`patrocinadores_repository.dart` para `caducarPatrocinios`, así que
importarlo al revés crearía un ciclo) y, si
`permisos.puede(Funcion.patrocinadores, temporada: temporadaActual)` es
falso, devuelve 0 sin tocar los contratos. El contrato sigue vivo en la
base de datos —`leerPatrociniosActivos`/`aniosRestantes` no cambian—,
solo se retiene el margen de esa temporada hasta que se desbloquee de
nuevo (vídeo, compra o edición completa).

Test nuevo en `bloqueos_version_gratuita_test.dart` (`'un contrato de
varios años deja de dar su margen si no se ha vuelto a ver el vídeo esta
temporada'`): firma una oferta de 4 años en edición gratuita sin ver el
vídeo → bonus 0; ve el vídeo → bonus completo; simula el paso de
temporada con un `Permisos` nuevo (el desbloqueo por vídeo dura una sola
temporada) → el contrato sigue en `leerPatrociniosActivos` pero el bonus
vuelve a 0. Verificado con `flutter analyze` limpio y la suite completa:
**674 tests, todos verdes**.

### Qué falta

1. Commitear en local (sin push) todo lo de hoy.
2. Seguir con el punto 11 de la lista 15 (contrato con 1 año restante
   debe decir "1 año", no "último año").

### Antecedente: la causa del bug de rookies (sesión del 23 de agosto)

Resumen rápido, por si hace falta releer el porqué. El código que decide
quién es rookie (`premios_repository.dart`, `allstar_repository.dart`) ya
estaba bien — descalifica a quien tiene fila en
`historialEstadisticasJugador`. El bug real estaba en el DATO de partida:
`_temporadasPrevias` en `jugadores_importer.dart` estima por edad
(`edad - 20`) cuando falta `draft_year`, y 292 de 645 jugadores lo tenían
a `null` porque el Kaggle del que sale (`draft_history.csv`) no llega a
las clases de draft recientes. Cooper Flagg (19 años) salía en 0
temporadas previas, colándose como rookie real. Se parcheó `draft_year`
a mano para 46 nombres de lotería/primera ronda 2024-2025 (ver el test
`datos_reales_test.dart`), dejando aparte a propósito el resto de
`null`s por falta de certeza en la fecha exacta. Aday Mara (el ejemplo
del usuario) no servía de contraejemplo porque ni se importaba — y esa
investigación fue justo lo que llevó al punto 1 de hoy: sin el CSV de
rookies reales, el juego se quedaba sin ninguna clase de novato jugable.

### Resto de la lista 15: sin empezar (puntos 3 al 11)

## Lista bugs/mejora 15 (a 2026-08-23, de `lista_bugs_cambios_nba_manager_15.txt`)

Por orden de más a menos importante. **Puntos 1 al 10 hechos** (ver la
sección "EN CURSO" al principio del fichero para el detalle); 11, sin
empezar.

1. ~~**Bug rookies/clases**~~ HECHO. Corregido `draft_year` a mano para
   la clase 2024-2025 y completada con datos reales la clase 2026 (ver
   arriba). `lib/domain/premios_repository.dart` y
   `lib/domain/draft_repository.dart` ya usaban bien el historial
   simulado; el bug era el dato de partida en `jugadores_importer.dart`.
2. ~~**Eventos aleatorios**~~ HECHO. Los eventos que hablan de un jugador
   concreto dicen su nombre (sacado de tu rotación de 10), y cada efecto
   enseña su porcentaje real. Ver `lib/domain/eventos_narrativos.dart` y
   `lib/features/temporada/evento_narrativo_dialog.dart`.
3. ~~**Pantalla principal**~~ HECHO. Quitado el botón "Temporada entera"
   de la tarjeta de próximo partido en `lib/features/hub/home_hub_screen.dart`
   (duplicaba el que ya vive a la derecha de la barra del Calendario, ver
   la sesión del 23 de agosto) — de paso se limpió el mecanismo de
   "abrir el Calendario ya simulando" que solo él usaba
   (`simularTemporadaAlAbrir` en `calendario_screen.dart`, ahora muerto).
4. ~~**Calendario, simulación**~~ HECHO. `_scrollearAFecha` se engancha
   al `onProgreso` de `_simularHasta` y sigue al último partido resuelto
   mientras dura la simulación, no solo al terminar.
   `lib/features/calendario/calendario_screen.dart`.
5. ~~**Calendario, UI**~~ HECHO. En compacto usa `textos.temporada`
   ("Temporada") en vez del texto largo — mismo tratamiento que
   "1 semana"/"1 mes". `_BotonesAvanceRapido`, mismo fichero que el 4.
6. ~~**Elegir estrella/roles**~~ HECHO. Cada opción del desplegable trae
   ahora la media que toca (ataque/defensa/las dos para el sexto
   hombre). `_SelectorEstrellas` en
   `lib/features/roster/roster_config_screen.dart`; el orden sigue
   alfabético, no se pidió cambiarlo.
7. ~~**Patrocinadores, texto**~~ HECHO. `maxLines` de 2 a 3 en la
   historia de `_TarjetaDeOferta` — con 2 se cortaba la mayoría (153 de
   386 en el catálogo necesitan 3), con 3 solo 4 casos extremos siguen
   recortándose. `lib/features/temporada/patrocinadores_screen.dart`.
8. ~~**Patrocinador "bebida oficial"**~~ HECHO. `patrocinioBebidaLabel`
   (7 idiomas) pasa a "Patrocinador de comida y bebida"/"Food & beverage
   sponsor"/etc., que es lo que de verdad hay en esa categoría (100
   marcas, mayoría restaurantes/panaderías/BBQ, minoría cerveceras/cafés).
9. ~~**Patrocinadores, repetición**~~ HECHO (con un límite real, no
   maquillado). `ofertasDe` ahora desplaza la ventana de tres ofertas de
   tres en tres, no de una en una — con eso el solape año a año baja al
   mínimo matemático posible para cada tamaño de cantera (0 con 6+
   candidatas, 1 con 5). Con exactamente 4 candidatas —el tamaño más
   común de verdad, no las "11-15" de la nota de la clase, que son por
   ciudad y no por categoría— dos de tres siguen repitiendo: con solo 4
   combinaciones posibles de "3 de 4", es matemáticamente inevitable
   (principio del palomar), no un fallo del arreglo.
10. ~~**Patrocinadores, anuncios/vídeos**~~ HECHO.
    `bonusSalarialDePatrocinadores` ahora exige
    `permisos.puede(Funcion.patrocinadores, temporada: actual)` antes de
    sumar el bonus: un contrato plurianual sigue vivo pero deja de dar
    margen en cuanto pasa una temporada sin volver a ver el vídeo (o
    comprar/completa). `lib/domain/patrocinadores_repository.dart`.
11. **Traspasos, contrato**: cuando a un jugador le queda 1 año de
    contrato, debe decir "1 año" y no "último año".

Los puntos 3, 4 y 5 tocan pantallas ya tocadas esta misma semana
(hub/calendario); conviene mirarlos juntos. Los puntos 7, 8, 9 y 10 son
todos de patrocinadores y también conviene agruparlos.

## RESUELTO: «temporada entera» se plantaba en el partido 53 de 82 (23 de agosto de 2026)

El lead que quedó abierto en la sesión anterior, encontrado y arreglado.

### La causa

En `simularHastaConDialogo` (`lib/features/calendario/simulacion_ui.dart`),
el bucle avanza en etapas de una semana **a propósito** —es lo que deja que
una oferta de noviembre te pare en noviembre, no al final de todo—. Pero:

```dart
DateTime? cursor;  // arrancaba en null
...
final metaParcial = cursor == null || ...
    ? diaObjetivo      // <- SIEMPRE esto en la primera vuelta
    : cursor.add(pasoDeParada);
```

Con `cursor == null`, la condición del ternario era verdadera **siempre**
en la primera vuelta, sin importar lo lejos que estuviera `diaObjetivo`.
"Simular temporada entera" apuntaba a abril, y la primera —y única—
llamada a `simularTramo` intentaba todo el camino de una tacada. Solo paró
donde paró (partido 53) porque ahí se topó con la fecha límite de
traspasos, el primer freno real que encontró en meses.

Consecuencia práctica, que es justo lo que pedía el usuario arreglar: una
oferta o un evento de una semana intermedia **no paraba la simulación
ahí**. Se amontonaba dentro de ese único tramo gigante y se resolvía al
final (o no se resolvía, si el freno real llegaba antes).

### El arreglo

Sembrar `cursor` con la fecha actual de la liga (`fechaActualDeLaLiga(db)`)
en vez de `null`. Con eso la primera vuelta pacea exactamente igual que
todas las demás: como mucho una semana, nunca de golpe hasta el final.

Confirmado con un test que llama a `simularHastaConDialogo` directamente y
cuenta cuántas veces se invoca `onProgreso` en diez días: antes, una vez
(todo junto); ahora, dos (una por semana).

### Cómo se encontró, para la próxima vez que algo así se atasque

Instrumentar con `print` no basta si el sitio equivocado se instrumenta:
las primeras rondas de prints en el bucle de `simularHastaConDialogo` no
mostraban nada, porque el problema no estaba ahí — estaba en que la
condición del ternario tomaba la rama de "todo de una vez" antes siquiera
de llegar al cuerpo del bucle. Lo que lo destapó fue un print en la
entrada misma de la función, seguido de uno en cada vuelta con el
contenido completo del `ResultadoTramo` (`simulados.length`,
`eventoBloqueante?.tipo`).

Y una vez arreglado el paceo, apareció un problema de comprobación
distinto: el diálogo de campeón de la Copa (`campeon_dialog.dart`) pinta
sus botones ("Cerrar", "Ver estadísticas") **sin pasarlos por `mayus()`**,
a diferencia de todos los `BotonDialogo*` de `estilo.dart`. Un test que
busca `find.text('CERRAR')` no lo encuentra; hace falta buscar también
`'Cerrar'` tal cual. Costó un rato de más.

### Tests nuevos

- `el primer tramo pacea semana a semana, sin tragarse el mes entero de
  golpe` — llama a `simularHastaConDialogo` directamente con un rango de
  diez días y exige más de una llamada a `onProgreso`. Es la prueba de
  regresión de este bug concreto.
- `«temporada entera» simula la liga regular sin tocar el play-in ni los
  playoffs` — reescrita a nivel de repositorio (mismo patrón que
  `temporada_con_mercado_test.dart`: contestar "seguir simulando" es
  simplemente ignorar el evento bloqueante y seguir), para no depender de
  toda la maraña de diálogos de la UI.
- El test existente `con la versión completa, el botón simula el año
  entero` necesitó un ayudante nuevo, `_avanzarUnDialogoSiHay`, que
  contesta cualquier diálogo que aparezca en el camino (fecha límite,
  oferta, All-Star, campeón) con la opción de **seguir**, nunca la que
  navega a otra pantalla — con el paceo corregido, una simulación larga
  cruza con más de uno.

### Estado

`flutter analyze` limpio en los dos paquetes. **672 tests en verde** en la
app y 21 en `sim_engine`. `flutter build web` correcto.

## RESUELTO más abajo: «temporada entera» se planta en el partido 53 de 82

~~**Sin resolver.**~~ Arreglado en la sesión siguiente, el 23 de agosto de
2026. Ver *"RESUELTO: «temporada entera» se plantaba en el partido 53 de
82"* más arriba en este mismo fichero, con la causa, el arreglo y los
tests. Se deja el análisis original tal cual quedó porque documenta bien
lo que se descartó por el camino.

Al pulsar «Temporada entera» en el calendario, la simulación llega al
partido **53 de 82** y se para sola. **No hay ningún diálogo esperando**
—se comprobó volcando todos los textos en pantalla en ese momento: solo se
ve el calendario— y `_simulando` vuelve a false, o sea que
`simularHastaConDialogo` ha retornado por su cuenta.

Hay que volver a darle al botón para seguir. No es un cuelgue, pero sí es
"el botón no hace lo que dice".

### Lo que se descartó

- **No es el objetivo.** `_simularTemporadaEntera` apunta a
  `_partidos.last.fecha`, y `leerPartidos` ordena por fecha ascendente, así
  que el destino es el último partido de verdad.
- **No es el diálogo de la fecha límite.** Se llegó a sospechar y se probó
  contestándole «SEGUIR SIMULANDO» desde el test; el finder no encuentra
  nada porque no hay diálogo.
- **No es la etapa sin partidos.** La hipótesis era que el parón del
  All-Star dejaba un tramo vacío y la condición
  `quedaCamino && tramo.simulados.isNotEmpty` cortaba el lote. Se probó a
  adelantar el cursor a `metaParcial` cuando el tramo no avanza: **el
  resultado no cambia**, se sigue parando en 53. El arreglo se revirtió por
  eso — no se deja en el árbol un cambio que no arregla nada.

### Por dónde seguir

Instrumentar las salidas de `simularHastaConDialogo` (`lib/features/
calendario/simulacion_ui.dart`, hay dos `break` sueltos más los de
`!context.mounted`) y ver por cuál sale de verdad. Quedan por mirar la rama
de ofertas entrantes y `_avisarSiHuboAllStar`.

**Ojo con los tests de esta zona**: los rótulos de botones y de botones de
diálogo van en MAYÚSCULAS (`mayus` en `shared/estilo.dart`), así que
`find.text('Seguir simulando')` no encuentra nada. Es
`find.text('SEGUIR SIMULANDO')`. Se perdió un rato con eso.

## Lo que sí se comprobó de «temporada entera» (23 de agosto de 2026)

Lo que pidió el usuario, con test cada cosa:

1. **Para en los eventos.** Ya funcionaba: `simularHastaConDialogo` avanza
   en etapas de una semana y en cada una mira ofertas entrantes, eventos de
   vestuario, All-Star, Copa y fechas límite. Lo de las fechas límite abre
   diálogo y espera respuesta.
2. **No juega el play-in ni los playoffs.** Test nuevo: se simula el año y
   se comprueba que **ninguna serie del cuadro tiene un solo partido
   jugado**. El play-in y el bracket salen del panel de playoffs, siempre
   porque el jugador lo pide.

### Estado

`flutter analyze` limpio en los dos paquetes. **671 tests en verde**.

## La barra del calendario, reordenada (23 de agosto de 2026)

Antes: `[Simular 1 partido] [1 semana] [1 mes]`.
Ahora: `[1 semana] [1 mes] [Temporada entera]`.

**Fuera "Simular 1 partido"**, y no es un olvido: el partido siguiente se
simula desde la tarjeta del menú, que además enseña contra quién juegas.
Tenerlo también aquí era el mismo botón dos veces, y le quitaba sitio a los
saltos que sí son propios del calendario.

**Dentro "Temporada entera", a la derecha del todo.** El orden queda de
menos a más, y el salto más gordo —el único que puede acabar el año de un
toque— el último, no pegado a los otros dos.

Ya existía la función: era el botón del menú, que traía aquí y arrancaba
solo (`simularTemporadaAlAbrir`). Lo que faltaba era poder lanzarlo **desde
el propio calendario**, que es donde uno está cuando quiere acabar el año.
Ahora `_simularTemporadaSiTocaAlAbrir` delega en `_simularTemporadaEntera`,
así que el camino es el mismo por los dos lados.

Respeta el bloqueo de la versión gratuita: sale con candado y no simula,
igual que el del menú. Se enseña igualmente en vez de esconderlo — esconder
lo bloqueado deja sin ver lo que se está ofreciendo.

Para saber si está desbloqueado hace falta el número de temporada (el vídeo
recompensado abre la función durante una temporada y solo esa), así que el
calendario ahora lo lee en `_recargarDatos`. Mientras no ha cargado, el
botón sale bloqueado: es el lado seguro.

## Limpieza: 205 líneas de textos que no usaba nadie (23 de agosto de 2026)

Al quitar "Simular 1 partido" quedó huérfana su etiqueta compacta
(`unPartido`). Eso llevó a barrer el fichero entero, y había más: **siete
claves declaradas en `Textos` y traducidas a los siete idiomas que no
llamaba nadie**.

`unPartido`, `alineacionDeEquipo`, `ataqueYDefensaTitulo`,
`huecoConJugador`, `posicionEdadMedia`, `subtituloRenovacion` y
`totalPatrociniosLabel` — 205 líneas entre la clase abstracta y las siete
implementaciones.

Cómo se buscaron, por si hay que repetirlo: sacar los nombres de las claves
de `textos.dart` y comprobar cuáles no aparecen en ningún `.dart` de fuera
de `lib/i18n/`. Después de la limpieza no queda ninguna.

Duele poco quitarlas y ahorra bastante: cada clave que sobra es una línea
que traducir siete veces la próxima vez que alguien añada un idioma.

### Estado

`flutter analyze` limpio en los dos paquetes. **670 tests en verde**,
cuatro más: que el botón de un partido ya no está, que los tres saltos van
en orden con «temporada» a la derecha, que en la gratuita sale con candado
y no simula, y que con la completa simula el año.

`flutter build web` correcto. `web/sw.js` sigue en `manager-nba-v13`, que
cubre todo lo de hoy porque no se ha publicado nada entre medias.

**La comprobación visual sigue pendiente**: el panel del navegador no se
puede mostrar en esta sesión.

## Los tres roles pasan a ser obligatorios, y el botón lo dice (23 de agosto de 2026)

Va justo detrás de plegar la banda, y es su consecuencia: si algo es
obligatorio y además está doblado, hace falta que el juego señale dónde.

### El botón ya no está muerto

Antes salía deshabilitado mientras faltara algo. Un botón apagado tiene un
problema que se ve en cuanto alguien lo usa: **no explica qué falta**. Se
queda gris y el jugador se queda mirándolo.

Ahora **siempre responde**, y cuando no se puede guardar dice por qué:

| Qué falta | Qué pasa al pulsar |
| --- | --- |
| Huecos de la alineación | Aviso: completa la alineación |
| Alguno de los tres roles | Aviso + **la banda se abre sola y parpadea** |
| Nada | Guarda |

El orden importa y no es casual: los roles se piden **después** de los diez
huecos, porque el sexto hombre sale de los suplentes y sin alineación no
hay suplentes de los que sacarlo.

### El aviso: abrir y parpadear

Abrir la banda es la mitad del aviso. Parpadear una banda plegada diría
"aquí hay algo" sin dejar verlo ni arreglarlo, así que primero se abre y
después se resalta: el fondo se tiñe hacia el color de aviso y la línea de
arriba engorda, dos idas y vueltas en 900 ms.

El parpadeo es **finito a propósito**. Un `repeat()` deja colgado a
`pumpAndSettle` en los tests, y en pantalla sería un semáforo.

Y la señal es un **contador**, no un `bool`. Con un booleano el segundo
intento no cambiaría nada y no volvería a parpadear — justo cuando quien lo
necesita es alguien que no se enteró la primera vez. Hay un test para eso.

### Claves estables en los tres desplegables

`claveRolAtaque`, `claveRolDefensa` y `claveRolSextoHombre`, misma idea que
las de `_HuecoJugador`: la etiqueta que se ve cambia con el idioma, la
clave no.

Aquí hacían falta además por un motivo técnico que costó encontrar:
**señalar uno de los tres por posición no funciona**. Un finder indexado
(`.at(i)`) revienta dentro de `tap`, que por debajo busca el `View` que
contiene al widget y le aplica el mismo índice — y `View` solo hay uno.

### Y otro que costó más: `ensureVisible` cambiaba de pestaña

En los tests, `ensureVisible` sobre el desplegable de más a la derecha
hacía **desaparecer la banda entera**. No es un bug de la banda: la banda
es un pie fijo y ya está a la vista, pero `ensureVisible` sube buscando un
`Scrollable` y el primero que encuentra es el `PageView` del `TabBarView`.
Lo centraba cambiando de pestaña.

Queda apuntado porque volverá a pasar: **en esta pantalla, nada de
`ensureVisible` sobre lo que esté fuera del `ListView` de los puestos.**

### Estado

`flutter analyze` limpio en los dos paquetes. **666 tests en verde**, cinco
más. `flutter build web` correcto; `web/sw.js` sigue en `manager-nba-v13`,
que ya cubre todo lo de hoy porque no se ha publicado nada entre medias.

`flujo_completo_test.dart` ahora elige los tres roles antes de empezar la
temporada, que es lo que hay que hacer de verdad desde este cambio.

**La comprobación visual sigue pendiente**: el panel del navegador no se
puede mostrar en esta sesión, así que el parpadeo está probado por sus
efectos (la banda se abre, el aviso sale, no se guarda), no mirándolo.

## La banda de roles se pliega en móvil (23 de agosto de 2026)

Punto **1 de la lista 14**, el último que quedaba. Con esto la lista 14 está
entera.

Los tres selectores de rol —estrella de ataque, estrella de defensa y sexto
hombre— viven en una banda fija encima del botón de guardar, en la pestaña
de Alineación. En pantalla estrecha se apilaban en columna y ocupaban
**270 px de forma permanente**, por tres cosas que se tocan una vez al
montar el equipo y no se vuelven a mirar.

Ahora en estrecho la banda se pliega: **43 px**, medido en un iPhone
vertical (390×844). Son **227 px libres, un 27% de la pantalla**, que van a
la lista de puestos, que es lo que sí se toca.

### Plegada tiene que decir lo mismo

Si al plegar se pierde la información, no es plegar: es esconder. La línea
de resumen enseña los tres roles con su icono de color y el **apellido** de
quien lo lleva, o un guion si no hay nadie:

```
🔥 Jukić      🛡 Gordon      ⚡ Braun            ⌃
```

El apellido y no el nombre entero porque tres nombres completos no caben en
una línea de móvil, y si no caben hay que ponerlos en columna — que es justo
lo que se estaba evitando. Los nombres del dataset son «Nombre Apellido»,
así que la última palabra sirve.

Los iconos se quedan sin etiqueta escrita por falta de sitio, pero **no sin
nombre**: cada uno lleva su `Semantics` con el rol entero y a quién lo
lleva, para quien use lector de pantalla. Desplegada sí caben las etiquetas
completas.

### Arranca plegada, y se puede

Los tres roles son **opcionales**: guardar solo pide titular y suplente en
los cinco puestos (`_rotacionCompleta`), y «Alinear automáticamente» los
rellena solo. Así que empezar plegado no bloquea a nadie, ni siquiera en el
onboarding.

### En escritorio no se pliega

Ahí los tres caben en fila y no le quitan sitio a nada, así que se quedan
siempre desplegados, sin banda ni flecha. El corte es el mismo
`_anchoMinimoParaTresSelectores` (520 px) que ya decidía entre fila y
columna.

### Estado

`flutter analyze` limpio en los dos paquetes. **661 tests en verde**, seis
más: `banda_de_roles_test.dart`, que mide el alto plegada contra desplegada
y exige que ahorre más de la mitad.

**La comprobación visual sigue pendiente**: el panel del navegador no se
puede mostrar en esta sesión, así que lo medido es el alto real de los
widgets, no una captura.

## Patrocinadores: tres ofertas por categoría y contratos de varios años (23 de agosto de 2026)

Puntos **3 y 4 de la lista 14**, hechos juntos porque son el mismo sitio.
Antes cada categoría era un interruptor: una marca, un dinero fijo, y se
apagaba sola al acabar el año. Ahora cada categoría se **despliega** y
enseña hasta tres ofertas de marcas distintas de tu ciudad, cada una con su
dinero al año y sus años de contrato.

### Por qué el contrato largo paga MENOS al año

Es lo único que hace que exista la decisión. Si el de cuatro años pagara
más, se firmaría siempre el de cuatro y las otras dos tarjetas serían
decorado. Al revés:

| Duración | Paga al año |
| --- | --- |
| 1 año | ×1,35 sobre el base de la categoría |
| 2 años | ×1,05 |
| 4 años | ×0,82 |

El corto es dinero YA para fichar este verano; el largo es tranquilidad
barata. Y lo que inclina la balanza es que **el nivel de las ofertas se
mueve de un año a otro** (×0,85 a ×1,15): firmar cuatro años cuando el
verano viene bueno es protegerse de los veranos malos. Sin esa variación,
esperar no costaría nada y nadie firmaría largo jamás.

**Un test cazó un fallo de diseño aquí.** El factor que movía el dinero
dependía de la MARCA y valía ±15%, y eso se comía la diferencia entre 1,35
y 1,05: en Boston/ocio, el contrato de un año llegó a pagar 1.150.000 y el
de dos 1.200.000. O sea el largo pagando más — la decisión desaparecida.
Arreglado separando los factores: el nivel del año es **compartido por las
tres ofertas** de una categoría (así el orden está garantizado por
construcción, no por suerte) y a la marca le queda un empujón de ±4%,
demasiado pequeño para invertir nada.

### Hasta tres, no siempre tres

Ocho de las 116 canteras —ciudad × categoría— tienen menos de tres marcas
porque la hoja de esa ciudad no traía más de ese tipo: Charlotte, Cleveland
y Milwaukee en *camiseta*, Nueva York en *estadio* y en *bebida*. Ahí salen
las que hay. No se fuerza a tres repitiendo marca: tres tarjetas con el
mismo logo se leen como un bug.

### Los contratos, en la base (esquema 29)

`PatrociniosActivos` gana tres columnas: `clave` (qué marca), `bonusAnual`
(lo que prometió) y `aniosRestantes`.

Es una **cuenta atrás y no una temporada final**, y eso es deliberado: la
pantalla de patrocinadores corre ANTES de que suba el número de temporada
(`finalizarPretemporada`), así que cualquier cuenta con números absolutos
se equivoca en uno. Bajando de uno en uno al cerrar el año no hay
off-by-one posible.

`cerrarTemporada` ya no llama a `limpiarPatrocinios` sino a
**`caducarPatrocinios`**: descuenta un año a todo y borra lo que se acaba.
Lo que sobreviva sale con **candado** en la pantalla del año siguiente — ni
se cambia de marca ni se rompe. Eso es exactamente lo que compraste al
firmar largo. Y su compromiso de vestuario se paga **todos** los años que
dure, que es la otra cara del trato.

Las tres columnas son nullable **solo por la migración**. Una partida
guardada con la versión anterior tiene filas sin contrato; se leen como lo
que eran (el bonus fijo de su categoría, un año) y caducan solas en el
primer cierre. Toda esa normalización vive en un único sitio,
`_contratoDeFila`.

**No hay tests de migración en el proyecto** —ni para la 24 ni para la 28—
así que no se montó un arnés entero. Sí se cubrió lo que de verdad puede
romperse: cinco tests que meten una fila «vieja» a mano y comprueban que se
lee, que da su margen, que caduca y que se puede firmar encima.

### Qué se puede tocar y qué no

Un contrato heredado sale con candado. Uno que firmes **en esa misma
pretemporada** se puede cambiar mientras no pulses Continuar. La pantalla
lo distingue con un `Set` en memoria (`_firmadosAhora`) y no con una
columna más: en cuanto sales de la pantalla deja de ser reciente, que es
exactamente lo que significa.

Solo se despliega **una categoría a la vez**. Con las cuatro abiertas son
doce tarjetas con su historia cada una, y en un móvil eso es scroll
infinito donde nadie compara nada.

### Efectos secundarios

- `patrocinadorDe` y `patrocinadoresDeTemporada` ya no existen: los
  sustituyen `ofertasDe`, `ofertasDeTemporada` y `patrocinadorPorClave`
  (para volver a saber quién era una marca firmada hace tres años).
- El margen sale de lo que se **guardó al firmar**, no del catálogo de hoy:
  un contrato de cuatro años paga lo que prometió aunque las ofertas de
  este verano sean otras.
- Dos textos nuevos en los siete idiomas (`alAnioSufijo`,
  `sinPatrocinioFirmado`) y `explicacionPatrocinadores` reescrito. La
  duración reutiliza `anios(n)`, que ya estaba.
- `web/sw.js` sigue en `manager-nba-v13`: se subió antes en esta misma
  sesión y no se ha publicado nada entre medias, así que cubre las dos
  tandas de cambios.

### Estado

`flutter analyze` limpio en los dos paquetes. **655 tests en verde** en la
app y **21** en `sim_engine`. Nada subido a git.

**Una vuelta de cinco falló un test que no se pudo identificar ni
reproducir** (las otras cuatro, verdes). Encaja con el residuo que ya
estaba apuntado más abajo: `simularTramo` —la temporada regular— sigue sin
aceptar semilla, así que un test que simule 82 partidos de verdad todavía
puede variar. No es de este trabajo.

## Patrocinadores con marca propia: 386 empresas y rotación anual (23 de agosto de 2026)

La pantalla de patrocinadores era la misma cada pretemporada: cuatro
empresas fijas por equipo, escritas a mano, con un icono genérico de
Material por toda cara. Ahora cada ciudad tiene una **cantera de once a
quince marcas propias con su logo**, y cada temporada se firma la
siguiente de la lista en cada categoría.

**La decisión del juego NO cambia.** Siguen siendo cuatro categorías con
sus mismos bonus y sus mismos compromisos, y sigue tratándose de elegir
*cuáles* de las cuatro firmas. Lo que cambia es que el año que viene el
pabellón lo paga otra empresa, así que la pantalla deja de repetirse.

### De dónde salen los datos

| Fichero | Qué |
|---|---|
| `docs/patrocinadores_hojas.tsv` | 386 filas: equipo, número, nombre e historia |
| `docs/patrocinadores_categorias.tsv` | En cuál de las cuatro categorías cae cada una |
| `app/manager_nba/assets/logos/` | 386 JPG, `ATL_01.jpg`, uno por fila |
| `docs/logos_con_marca_real/` | Los 50 descartados por llevar marca real. **Fuera de `assets/`**, no entran en la compilación |
| `recortar_logos_patrocinadores.ps1` | Recorta las hojas de contacto 5×3 en imágenes sueltas |

El catálogo de `lib/domain/patrocinadores.dart` **se genera**, no se
escribe a mano. Debajo de la línea `// === CATÁLOGO GENERADO ===` manda el
script; todo lo de arriba es a mano y se respeta:

```
cd app/manager_nba
dart run tool/generar_patrocinadores.dart
```

Está en Dart y no en Python como los otros scripts de datos del repo
**porque en esta máquina Python no está instalado** (solo los alias de la
Microsoft Store, que no ejecutan nada). Quien pueda compilar el juego ya
tiene el SDK de Dart.

El generador aborta si una fila no tiene categoría o si le falta el logo,
y avisa de los logos que no salen en ninguna fila — peso muerto dentro del
`.apk`.

### Las cuatro categorías, ensanchadas

Las marcas del TSV son mucho más variadas que las cuatro de antes: hay
tecnológicas, textiles, fundiciones, navieras y productoras. Se
ensancharon las definiciones sin tocar el diseño:

- **estadio** — energía, infraestructura, industria pesada, obra
- **camiseta** — banca, finanzas, tecnología, moda (el patrocinio visible)
- **bebida** — alimentación y bebida
- **ocio** — transporte, parques, turismo, cultura, medios

Con eso las 29 hojas tienen candidato en las cuatro. **Tres ciudades se
quedan con una sola marca en alguna categoría** —Charlotte, Cleveland y
Milwaukee en *camiseta*, Nueva York en *estadio* y en *bebida*— porque su
hoja no traía más de ese tipo. Ahí esa categoría no rota. El test lo
contempla a propósito (`if (cuantas < 2) continue`), no es un descuido.

### La rotación no lleva semilla guardada

`patrocinadorDe(equipo, categoria, temporada:)` recorre la cantera **en
orden** y da la vuelta al llegar al final. El desplazamiento inicial sale
de un FNV-1a de `equipo|categoria`.

Es a propósito que no sea un sorteo: la partida se guarda solo con el
número de temporada, sin ninguna semilla de patrocinio. Con una fórmula
que depende solo de (equipo, categoría, temporada), **cargar una partida
vieja devuelve exactamente los patrocinadores que tenía**. Un `Random`
habría que guardarlo, y sería una migración de base de datos para nada.

El hash está escrito a mano y no se usa `String.hashCode`: el de Dart
**no** está garantizado entre versiones ni entre plataformas, y hace falta
que el patrocinador de la temporada 12 sea el mismo en el móvil, en la web
y dentro de tres versiones.

### Los Ángeles

El TSV trae una sola hoja `LA` con 14 marcas, pero el juego tiene LAC y
LAL. **Comparten ciudad y comparten cantera**; no se duplicaron las
entradas. Los separa la semilla, que lleva el código del equipo y no el de
la hoja: el mismo año cada uno firma una marca distinta. Lo vigila un
test.

### Efectos secundarios que salieron por el camino

- **`bonusSalarialDePatrocinadores` y `aplicarCompromisosDePatrocinio`
  perdieron el parámetro `equipoUsuario`.** No lo usaban: el bonus y el
  compromiso son fijos por categoría, no por marca. Era un parámetro que
  mentía sobre lo que hacía la función.
- **Un nombre real colado**: `Clutch City Coffee` (Houston) decía en su
  historia *"ganado por los Rockets"*. Reescrito. El resto de guiños
  —Hornet Honey, Panther Paw, Bronco Bronze, Thunderhead, MagicHour— son
  al emblema o al clima de la ciudad, no a un equipo, y sus textos no
  nombran a nadie.
- **`web/sw.js` sube a `manager-nba-v13`.** Los 386 logos **no** van en la
  lista de precarga: son 4,7 MB que dispararían la primera descarga de 17
  a casi 22, y en una partida solo se miran cuatro por temporada. Los
  recoge la regla de caché-primero-red-después la primera vez que se abre
  la pantalla con conexión. Sin conexión y sin haberla abierto nunca, la
  tarjeta cae al icono de su categoría (`errorBuilder` de
  `_LogoDePatrocinador`).

### El repo ya NO vive en OneDrive

`flutter test` fallaba a ratos con *"Flutter failed to delete a directory at
ios/Flutter/ephemeral/Packages/.packages"*. No era el código: OneDrive
convierte esos enlaces en puntos de reanálisis de solo lectura y Flutter no
puede borrarlos. Los 1.360 ficheros del repo eran **todos** puntos de
reanálisis de OneDrive.

Se movió el proyecto:

```
C:\Users\nanot\OneDrive\Documents\manager-nba   ->   C:\src\manager-nba
```

`C:\src` porque ahí está ya el SDK (`C:\src\flutter`). Se copió con
robocopy dejando fuera `build/` y `.dart_tool/`, que Flutter rehace solo:
914 ficheros, 13,6 MB, cero errores. Comprobado antes de tocar nada:
`git fsck` limpio, el mismo `git status` fichero a fichero que el original,
y los tests en verde en la ubicación nueva — ya sin tener que borrar los
`ephemeral` a mano.

**La carpeta vieja de OneDrive sigue ahí, intacta**, a la espera de que el
usuario diga si se borra.

**Lo que se pierde: la copia de seguridad automática de OneDrive.** Con
todo el trabajo de las últimas sesiones **sin subir a git**, ahora mismo
esto vive en un solo disco. Conviene commitear.

**Cuidado al tener dos copias a la vez.** En la sesión del 23 de agosto se
perdió un rato de trabajo en este mismo fichero por copiar OneDrive →
`C:\src` DESPUÉS de haber editado el de `C:\src`: el `cp` se llevó por
delante las ediciones nuevas. Comparar los md5 después de copiar no detecta
nada — claro que salen iguales, acabas de sobrescribir uno con el otro.
Ahora que el repo vive solo en `C:\src`, no hay dos copias que sincronizar.

### La vista previa ya no depende de Python

`.claude/launch.json` lanzaba `python -m http.server` y **Python no está
instalado en esta máquina** (solo los alias de la Microsoft Store, que no
ejecutan nada), así que la vista previa nunca arrancaba. Ahora usa
`tool/servidor_web.js`, un servidor estático de Node sin dependencias —
Node sí está (v24).

Sirve `app/manager_nba/build/web` en `http://127.0.0.1:8080`. Hace tres
cosas que el de Python no hacía bien:

- **Tipos MIME correctos** para `.wasm` y `.js`. El navegador rechaza
  CanvasKit y SQLite si llegan con el tipo equivocado.
- **Cualquier ruta cae al `index.html`**, que es lo que espera el
  enrutador de Flutter.
- **`Cache-Control: no-store`**, para que `main.dart.js` y el service
  worker no se queden pegados entre compilaciones.

Sigue haciendo falta compilar antes, igual que con el de antes:

```
cd app/manager_nba
flutter build web --release --no-web-resources-cdn --pwa-strategy=none
```

Comprobado sirviendo el build de verdad: `index.html`, `main.dart.js`
(4,1 MB), `sqlite3.wasm` (748 KB) y `assets/assets/logos/DEN_05.jpg` todos
200 con su tipo, y una ruta inventada cayendo al index. La app arranca en
el navegador.


### Estado

`flutter analyze` limpio en `lib/` y en `test/`. **633 tests en verde**,
doce más que antes: el catálogo nuevo, el logo de cada tarjeta y la
rotación entre temporadas. Nada subido a git.

## Lo hecho el 19 de agosto de 2026 (la sesión más reciente)

Cinco commits, todos subidos a `main`. De más antiguo a más nuevo:

| Commit | Qué |
|---|---|
| `1fd38ec` | Traduce a los siete idiomas **todas** las pantallas que quedaban (~30 ficheros, +300 claves) |
| `af0e0b5` | Kyrie Irving y otras tres estrellas que faltaban del dataset + el Hall of Fame de los recién inducidos |
| `2bd954d` | Bracket de playoffs legible en móvil (punto 16 de la lista parte 11) |
| `cb82e7f` | Eventos narrativos: el dinero como segundo eje de decisión |
| `6cf8638` | Kyrie también en las partidas ya empezadas + **caché a v10** |

Cada uno tiene su sección propia más abajo con el porqué. Los tres
detalles que más fácil se pierden:

1. **La caché estaba en v9 con cuatro commits ya publicados.** Nadie con
   el juego instalado había recibido nada. Es la razón de que el usuario
   dijera "sigue sin estar Irving en Dallas" cuando el dataset ya lo
   tenía. Ver "Subir `CACHE` en CADA publicación".
2. **Las partidas ya empezadas no releen el dataset.** Ver "Cambiar los
   DATOS no llega a las partidas ya empezadas".
3. **La lista parte 11 queda entera.** Los puntos 7 y 17 no esperan
   trabajo, esperan un ejemplo concreto del usuario.

## ESTADO DE LA PUBLICACIÓN

Publicando **`manager-nba-v10`**, que se lleva de una tacada todo lo que
había commiteado sin publicar: los eventos narrativos (punto 23), las
traducciones de las pantallas que quedaban, Kyrie y los otros tres
lesionados que faltaban del dataset, el Hall of Fame de los recién
inducidos, el bracket de móvil (punto 16) y el dinero como segundo eje de
los eventos.

**Cuidado con esto, que casi se cuela:** la versión de `sw.js` se había
quedado en `v9` desde los eventos narrativos, y encima había CUATRO
commits que cambian el juego. Como `guardarLoQueFalte` no vuelve a pedir
lo que ya tiene, cualquiera con el juego ya cacheado habría seguido
viendo la versión vieja — con todo el trabajo publicado y sin que se
notara nada. El aviso en mayúsculas de `web/sw.js` está por algo: **subir
la versión es parte de publicar, no un detalle**.

Con la lista parte 11 entera: los únicos dos que siguen abiertos (7 y 17)
están a la espera de un ejemplo concreto del usuario, no de trabajo.
Verificado en local: `flutter analyze` limpio, **428 tests** de la app +
**19** de `sim_engine` en verde, y `flutter build web` correcto.

**Último commit subido: `6cf8638`** ("Kyrie tambien en las partidas ya
empezadas, y sube la cache a v10"). Queda por confirmar que su despliegue
salió verde — se comprueba con la API de Actions, ver más abajo.

**Lo que hay que decirle al usuario para que lo vea**: recargar con
**Ctrl+Shift+R** (o cerrar y reabrir el icono) para que el navegador coja
la v10. Y si su carrera va por la temporada 1, Kyrie y los otros tres
aparecen solos al continuarla; si va más avanzada, hace falta empezar una
partida nueva (el porqué, en la sección de Kyrie).

**El 16 (bracket diminuto en móvil) ya está hecho**, y sin necesitar la
captura que se estaba esperando: se podía MEDIR. El cuadro mide 714 de
ancho y se encogía siempre hasta caber, o sea al 51% en un móvil de 390,
con los nombres de 11px dibujados a 6. Ahora solo se encoge si el recorte
es pequeño (hasta `_escalaMinima = 0.9`); por debajo se queda a tamaño
real y se arrastra en horizontal.

La lección: el test que vigilaba esta pantalla comprobaba que el cuadro
**cupiera**, y por eso el bug vivía ahí tan tranquilo — cabía, sí, pero
ilegible. Ahora mide la ESCALA a la que se dibuja, que es lo que de verdad
se reportó. Probado contra el código viejo, falla con el mensaje "el
cuadro se ha encogido al 51%".

**Esquema de base de datos en la 23**, con migración aditiva (tabla
`EfectosDeEvento` + columna `Temporada.eventosVistos`): las partidas
guardadas siguen intactas y simplemente empiezan sin ningún efecto activo,
que es el estado correcto.

Última publicación CONFIRMADA en verde: `9035f88` (caché v6). Todo lo de
`f8abae8` en adelante está subido pero **sin confirmar run a run**; como
la caché iba en v9 hasta ahora, en la práctica nadie con el juego ya
instalado había recibido nada de eso. La v10 es la que lo entrega todo.

### Cómo comprobar si una publicación fue bien

**La página de Actions leída desde fuera MIENTE.** Al diagnosticar esto se
perdió un buen rato: decía que los 7 envíos habían ido bien cuando dos
habían fallado. La fuente fiable es la API, que es pública:

```
https://api.github.com/repos/jokar77/manager-nba/actions/runs?per_page=10
```

Y para saber POR QUÉ falló uno, sin `gh` instalado:

1. `.../actions/runs/{id}/jobs` → qué paso falló.
2. `.../check-runs/{job_id}/annotations` → el mensaje.

Con eso se distinguen los dos tipos de fallo, que se arreglan distinto:

- **Sale "344 tests passed, 1 failed"** → un test concreto. Si es uno de los
  que simulan temporadas, sospechar de un umbral frágil antes que del
  cambio que se acaba de subir (ver más abajo).
- **Solo sale "Process completed with exit code 1"**, sin recuento → ni
  siquiera llegó a ejecutar los tests: **no compilaba**. Casi siempre
  significa que el commit se hizo con el trabajo a medias.

### Historial de rojos (y qué enseñó cada uno)

| Commit | Causa | Lección |
|---|---|---|
| `aaa317a`, `bc5dda8` | Test de realismo inestable | Umbral mal planteado, ya arreglado |
| `b0c62a2` | No compilaba | Se commiteó a media edición |

**Los tres se podrían haber evitado esperando a que el trabajo estuviera
terminado y verificado antes de hacer `git add -A`.** No es un problema de
git ni de concurrencia: `git add -A` se lleva lo que haya en la carpeta en
ese instante, y si está a medias, sube la mitad.

Un rojo no rompe nada: GitHub compila antes de publicar, así que la web
sigue con la versión anterior y basta con volver a subir cuando esté.

## Lo que queda abierto

1. **El icono del iPhone sigue funcionando mal y NO está diagnosticado.**
   Se verificó que la web publicada está bien (los 12 ficheros críticos dan
   200 y sirve la versión correcta), así que el problema está en el
   dispositivo. Se le pidió al usuario que abra
   `https://jokar77.github.io/manager-nba/estado.html` **desde el icono** y
   diga qué pone. **Esa respuesta no ha llegado todavía**: es el siguiente
   dato que hace falta, y sin él cualquier arreglo sería adivinar.
2. **No hay copia de seguridad de partidas.** Viven solo en el navegador
   del móvil. El usuario decidió **aparcarlo** porque el plan es sacar el
   juego como app nativa en el futuro. Aviso asociado: **borrar el icono en
   iOS puede borrar la partida**; los botones de reparar de `estado.html`
   sí son seguros (solo tocan la caché de ficheros).
3. El equilibrio entre jugar el mercado y no jugarlo quedó en ~8 victorias,
   medido con **una sola semilla**. Sirve para decir que la espiral
   desapareció, no que el equilibrio esté fino. Haría falta medir con
   varias semillas.
4. **El chino puede verse en cuadraditos en la web, y NO está comprobado.**
   Ver la sección de idiomas. Hace falta que el usuario lo abra en su móvil,
   ponga chino y diga si se lee. Es el dato que decide si hay que empaquetar
   una fuente CJK de varios MB o no hay nada que hacer.
5. **Las pantallas ya están traducidas las siete** (se hizo en `1fd38ec`:
   unas 30 pantallas y más de 300 claves nuevas). Lo que queda sin
   traducir es **el catálogo de eventos narrativos**
   (`lib/domain/eventos_narrativos.dart`): unas 250 líneas de texto
   narrativo — títulos, planteamientos y consecuencias de los 12 eventos.
   Quien juegue en otro idioma verá esos diálogos en castellano. Es
   trabajo largo, no difícil, y el usuario ya sabe que está pendiente.
6. **Los puntos 7 y 17 de la lista parte 11** siguen abiertos pero NO por
   falta de trabajo: se investigaron y el código parece correcto. El 7
   (ofertas de la CPU poco realistas) necesita que el usuario mande una
   oferta concreta con sus jugadores y contratos; el 17 (que el Play-In
   desaparezca al terminar) necesita que diga cuándo lo vio mal.

### Lo que NO se ha podido verificar nunca en esta máquina

El panel del navegador de este entorno **no compone imagen**, así que no hay
capturas ni clics reales: `computer{action:"screenshot"}` da siempre
"the Browser pane is not displayed". Todo lo visual se ha verificado con
tests de widget a tres tamaños (`test/adaptacion_movil_test.dart`), que
detectan desbordes de layout pero no si algo se ve feo o si una fuente
falta. Cuando algo dependa de verlo, hay que pedírselo al usuario.

## Eventos narrativos, segunda vuelta: el dinero como segundo eje (hecho)

Petición: que los eventos tengan decisiones de verdad — un acto
publicitario que dé margen salarial a cambio de cansar a la plantilla, o
que rechazarlo dé energía; una cena que si la rechazas empeore algo pero
mejore otra cosa.

**El problema de fondo era que solo había un eje.** Todos los eventos
cambiaban rendimiento por rendimiento, así que en el fondo siempre
planteaban la misma pregunta. Ahora `OpcionDeEvento` tiene también
`bonusSalarial`: margen de tope salarial que entra (un patrocinio) o sale
(una multa). Eso hace que la respuesta correcta dependa de algo que el
diálogo no sabe —si te falta espacio para fichar o no—, que es justo lo
que convierte una elección en una decisión.

**Calibrado contra el salario mínimo, no contra el tope.** La primera
idea era 1M, pero a esa escala el dinero es decorativo: el mínimo son
2,3M, así que 1M no desbloquea ni un fichaje — sube un número en una
pantalla y no cambia ninguna decisión. Las magnitudes quedan en 3M ("te
da para un jugador de rotación") y 6M ("un suplente de nivel"), con una
multa de 4M. Hay un test que lo vigila: ningún bonus positivo puede bajar
del salario mínimo.

**Tres opciones no hacían absolutamente nada** ("Ahora no toca", "No
entrar al trapo", "A entrenar, que es lo que toca"): sin efectos y sin
dinero, o sea botones de cerrar el diálogo. Todas tienen ya su
contrapartida en los dos sentidos — rechazar la cena, por ejemplo, da
piernas frescas ahora y deja el grupo más frío después.

Catálogo: de 10 eventos y 23 opciones a **12 y 29**, ninguna sin
consecuencias.

**El test que vigila esto hubo que replantearlo, y el primer intento
estaba mal.** La idea inicial fue pedir que ninguna opción "dominara" a
las demás (no ser peor en nada y mejor en algo). Es imposible de cumplir:
con un solo eje siempre hay una opción con el mejor balance neto, y
exigir que no la haya solo se satisface empatándolo todo, que es peor
diseño. Lo que se comprueba ahora es lo que de verdad importa: **la mejor
opción en la pista tiene que pagar en algún sitio**, o con efectos
negativos propios o renunciando a dinero que otra opción sí daba. Con esa
regla, el acto publicitario pasa (rechazarlo es lo mejor para las piernas
pero renuncia a 6M) y la cena también (la noche larga es la mejor pero
cansa).

El dinero se enseña en el diálogo de consecuencia con su propia fila. Es
el único efecto que NO se nota en la pista: sin decirlo ahí, el usuario
se enteraría semanas después al ir a fichar y sin poder relacionarlo con
la decisión.

Esquema: columna `Temporada.bonusSalarial` (migración aditiva, versión
24). Se acumula entre eventos, lo suma `espacioSalarial` **solo al equipo
del usuario** —los otros 29 no toman estas decisiones— y se borra en el
cambio de año, como el resto de efectos.

**Pendiente**: el catálogo sigue estando solo en castellano. Es contenido
narrativo largo (unas 250 líneas de texto), así que no entró en la tanda
de traducción de las pantallas; queda como trabajo aparte.


## Lista corta: Kyrie y el Hall of Fame (hecho)

Fuente: `bugs_prioridad_alta_kyrie_hof.txt`.

**1 — Kyrie Irving no aparecía en su equipo. Y no era solo Kyrie.**

La causa está en el pipeline de datos, no en la app.
`preparar_datos_nba_v27.py` construye `jugadores.json` a partir de las
estadísticas **de la temporada 2025-26** (`cargar_stats(temporada_objetivo
=2026, minimo_partidos=15)`). Quien se perdió el año ENTERO por lesión
grave no tiene fila en el CSV de origen, así que desaparece del juego: ni
en `jugadores.json` ni en `datos_reales.json` (dorsales y salarios), que
sale del mismo volcado.

Buscando el patrón aparecieron **cuatro**, y los cuatro son exactamente el
mismo caso — se rompieron y no jugaron un solo partido:

| Jugador | Equipo | Lesión |
|---|---|---|
| Kyrie Irving | DAL | cruzado, marzo 2025 |
| Damian Lillard | POR | Aquiles, abril 2025 |
| Tyrese Haliburton | IND | Aquiles, Finales 2025 |
| Fred VanVleet | HOU | cruzado, septiembre 2025 |

Añadidos a mano al dataset. **Sus atributos no se pusieron a ojo**: se
derivan del propio dataset con el script
`anadir_jugadores_lesionados.py` (en la raíz, al lado del pipeline; es
idempotente, si vuelves a lanzarlo no los duplica), que
1. reconstruye `atr_ataque` de su fórmula real (`pts + ast*1,5`, escalado),
   usando la mediana de los 15 jugadores con producción más parecida — no
   una interpolación entre vecinos, porque la curva tiene picos sueltos
   (Trae Young marca 98 con un bruto de 32,4, entre gente de 92) y caer al
   lado de uno se lo lleva entero;
2. saca `atr_defensa` y `atr_tiro3` por comparables del mismo puesto, que
   es lo que se puede hacer: sus entradas (robos, tapones, % de triple) no
   están en el JSON y no hay forma de reconstruirlas;
3. compone la media con los pesos reales del pipeline (0,55 / 0,40 / 0,05)
   y el potencial con su tabla por edad.

El método **se valida a sí mismo con leave-one-out** sobre 120 jugadores
que ya están: error mediano de media **8 puntos**, p90 de 23. Ese error es
el suelo del método y viene de defensa y triple, que no se pueden
reconstruir. La producción de partida es la de su última temporada sana
(2024-25), que es justo lo que el juego usa como referencia cuando no hay
temporada simulada.

Dónde quedan: Lillard #21 de la liga, Kyrie #45, Haliburton #46,
VanVleet #110. **Ojo**: son estimaciones, no datos reales de 2025-26 —
esos no existen porque no jugaron.

Vigilado por un test nuevo en `jugadores_importer_test.dart` que
comprueba que los cuatro siguen en su equipo, para que una regeneración
del dataset no los vuelva a dejar fuera en silencio.

**Añadirlo al dataset no bastaba, y esto es lo importante.** Después de
publicarlo, Kyrie seguía sin aparecer en Dallas. Dos causas encadenadas,
las dos del tipo "el arreglo estaba bien pero no llegaba":

1. **La caché.** `web/sw.js` seguía en `v9` mientras se publicaban cuatro
   commits. Como `guardarLoQueFalte` no vuelve a pedir lo que ya tiene
   guardado, el navegador conservaba el `jugadores.json` viejo. Subir la
   versión del service worker es PARTE de publicar, no un detalle.
2. **Las partidas ya empezadas nunca releen el dataset.**
   `importarJugadoresSiHaceFalta` se sale en cuanto ve la tabla con datos,
   y al continuar partida no se llama con `forzar`. O sea que una carrera
   en marcha no vería jamás a un jugador añadido después, por muchas
   actualizaciones que le llegaran.

Lo segundo se arregla con `anadirJugadoresQueFaltenDelDataset`, al lado de
los backfills que ya había para el legado real y los entrenadores. **Solo
en la primera temporada**: más adelante la liga ya no se parece al
dataset —todos han envejecido, alguno se ha retirado, ha habido
traspasos— y meter ahí a alguien con la edad y la media del asset
original no sería restaurar lo que faltaba, sería inventarse un fichaje
con cinco años menos de los que le tocan. Si tu carrera va por la
temporada 4, la forma de tenerlos es empezar una partida nueva.

Los dos tests que lo vigilan reproducen el caso de verdad: borran a Kyrie
de una partida ya importada, comprueban que **el import normal NO lo
arregla** (que es el bug) y que el backfill sí, sin duplicar al llamarlo
dos veces.

**Y el primer intento del relleno estaba mal hecho**, que lo cazó el test
de `start_menu_screen`: leía y parseaba los 300 KB del asset en CADA
"continuar partida". El test pasó de tardar segundos a colgarse diez
minutos, y eso no era una molestia del test — era el aviso de que se
había metido un peaje en el arranque de todas las partidas para atrapar
un caso que se da una vez en la vida de cada una.

Arreglado con la misma forma que ya usaban los otros backfills de esa
pantalla: **comprobar barato antes de leer**. Una cuenta de filas contra
`jugadoresUtilizablesDelDataset` (586) y, si cuadra, no se toca el asset.
La constante tiene su propio test contra el JSON de verdad, porque si se
desfasa el relleno deja de dispararse en silencio: no falla nada, solo
que las partidas viejas se vuelven a quedar sin los jugadores nuevos.

**¿Faltaba alguien más?** Se barrió de dos formas, y no: (1) cruzando
`datos_reales.json` (444 jugadores con equipo y salario reales) contra el
dataset, cero ausencias; (2) mirando a quién descarta el filtro del
importador por traer campos a null: son 59 y **todos tienen 19 años** —
son los prospectos del draft de 2026 (Dybantsa, Caleb Wilson, Nate
Ament...), que todavía no han jugado en la NBA y se excluyen a propósito.
Los cuatro lesionados eran el conjunto completo.

**2 — Hall of Fame: al recién inducido, solo el año.**

La pantalla de anuncio de fin de temporada ya lo hacía bien. El que
fallaba era la lista grande (`_FilaMiembro`): a un recién inducido le
ponía debajo una segunda línea con temporadas y promedios. Y es justo el
caso peor, porque alguien que entra DENTRO de tu partida puede no tener
promedios archivados todavía — de ahí el "21 temporadas · 0.0 pts · 0.0
ast" que se reportó en el punto 11 de la lista anterior y que se dio por
cerrado sin estarlo del todo.

Ahora la segunda línea se salta cuando `esNuevo`. El test nuevo en
`legado_pantallas_test.dart` **se probó contra el código viejo y falla**,
así que pilla el bug de verdad y no pasa por vacío (monta un inducido con
temporadas archivadas a propósito: las leyendas reales importadas no
tienen carrera guardada y con ellas el test no probaría nada).


## Lista parte 11 — EN CURSO (lo que se está haciendo ahora)

Fuente: `lista_bugs_mejoras_parte11.txt` (24 puntos, ordenados por el
usuario de más a menos importante) + dos capturas del móvil (bracket de
playoffs y Hall of Fame). **No olvidar ninguno.**

Marcar aquí según se vayan cerrando.

| # | Qué | Estado |
|---|---|---|
| 1 | Ajustes dentro de la partida (idioma, modo oscuro) no aplican de verdad; deben afectar a toda la app, menús incluidos | HECHO |
| 2 | Sin entrenador debe abrirse la agencia DE ENTRENADORES, no la normal. Fichar por el mínimo, y tener entrenador obligatorio para seguir (como la plantilla mínima) | HECHO |
| 3 | Poder fichar a un entrenador con contrato: acepta o rechaza | HECHO |
| 4 | Al elegir equipo en partida nueva, enseñar también el entrenador | HECHO |
| 5 | Alineación automática con doble posición: debe jugar el de más media (bug: escolta de 79 titular por delante de un base-escolta de 85) | HECHO |
| 6 | Al pulsar un jugador (fichaje, alineación…) enseñar su media de ataque y defensa. En alineación, además, el ataque/defensa del equipo | HECHO |
| 7 | Las ofertas de la CPU no son realistas: revisar lógica y valor de los contratos | INVESTIGADO: no se encontró bug, ver nota abajo. Pendiente de un ejemplo concreto |
| 8 | Al enseñar una oferta, verse el contrato (3 años, 40M…) | HECHO |
| 9 | Menú principal: año real (2030/31) en vez de "temporada 5" | HECHO |
| 10 | El All-Star ha dejado de avisar durante la simulación | HECHO |
| 11 | Hall of Fame: los nuevos inducidos deben decir "Entró en 2027". Además en la captura sale **"Chlis Peul · 21 temporadas · 0.0 pts · 0.0 ast"** → estadísticas a cero | HECHO |
| 12 | Si un jugador ya tiene la camiseta retirada en otro equipo, poder retirarla también en mi franquicia | HECHO |
| 13 | En el historial de un jugador que pasó por mi equipo, incluir trofeos/anillos ganados DENTRO de la partida, no solo los reales | HECHO |
| 14 | Retiros: quitar el texto "resto de la liga" | HECHO |
| 15 | NBA Cup: el mensaje debe decir que ganas la Cup, no un anillo. El aviso de la final, más pequeño | HECHO |
| 16 | Bracket de playoffs en móvil: se ve diminuto, tiene que ajustarse a la pantalla | HECHO |
| 17 | Bracket: el Play-In debe desaparecer al terminar | YA ESTABA: `playoffs_screen.dart:232` lo esconde en cuanto todas sus series tienen ganador. Falta que el usuario diga cuándo lo vio |
| 18 | Avisos de lesión con el icono de cruz blanca sobre rojo | HECHO |
| 19 | Variación realista de puntos por partido (30 un día, 20 otro) | HECHO |
| 20 | Espacios salariales mal: en la temporada 5-6 se tienen cinco titulares de +90 y aún sobran 10M | HECHO (ver "Puntos 20 y 22" más abajo; la fila se quedó sin marcar) |
| 21 | Igual que el 12, visto desde el retiro | HECHO (mismo arreglo) |
| 22 | Las medias suben demasiado al avanzar temporadas; el potencial no puede alcanzarse siempre | HECHO |
| 23 | Eventos narrativos aleatorios con decisión y consecuencias (cena de equipo = más química, menos energía) | HECHO |
| 24 | Si mi equipo ha ganado títulos, que salgan en la cabecera del equipo | HECHO |

### Lo hecho en esta tanda, con el porqué

**1 — Ajustes que no aplicaban.** Eran DOS fallos encadenados, no uno:
`home_hub_screen.dart` abría `AjustesScreen(db: db)` pasándole la base de
datos de LA PARTIDA (el idioma se guardaba donde nadie lo lee) y sin
notificadores (nada se repintaba). Arreglado quitándole a la pantalla todos
los parámetros: ahora coge la base con `abrirAjustes()` y los notificadores
globales de `lib/shared/preferencias.dart`, así que da igual desde dónde se
abra. Con el fallo delante era imposible construirla mal desde un sitio y
bien desde otro. Tests en `test/ajustes_screen_test.dart`.

**2 y 3 — Entrenadores.** Ahora se puede fichar a un entrenador que ya
dirige a otro equipo. La prima por robarlo (`primaPorTenerEquipo = 2.0`)
está MEDIDA sobre el asset, no estimada: con ella al mejor de la liga
(media 90) solo le valen 6 de los 30 proyectos y el dinero no le mueve
—ya cobra el techo de 18M—, mientras que a uno del montón se lo lleva
cualquiera. Sin prima, pagando el máximo se lo llevaba cualquiera de los
30 y la decisión desaparecía. Al equipo al que se lo quitas le buscan
sustituto en el acto (si no, dejabas a un rival sin entrenador meses, que
es una ventaja gratis e invisible).

Y tener entrenador es obligatorio para jugar, como la plantilla mínima:
la pretemporada abre la agencia DE ENTRENADORES antes que la de jugadores,
y simular con el banquillo vacío te manda ahí. Siempre hay salida —
`ficharEntrenadorPorElMinimo` no puede fallar: si nadie acepta genera
entrenadores nuevos, y si aun así nadie acepta firma igual. Devolver un
"no ha podido ser" dejaría al usuario encerrado en una pantalla
obligatoria.

**5 — La alineación automática.** Bug real y encontrado, no un ajuste de
gusto. `repartirPorPuestos` llenaba los DIEZ huecos (titulares y suplentes)
en una sola pasada en orden de valor, sin distinguir titular de suplente.
Con un base de 90 ya colocado, la siguiente mejor pareja de un base-escolta
de 85 era "base SUPLENTE" y ahí caía, antes de que a nadie le llegara el
turno del puesto de escolta titular — que se quedaba un 79. Exactamente lo
reportado. Ahora se reparte por niveles: primero los cinco titulares,
después los suplentes. **El test nuevo se probó contra el código viejo y
falla**, así que pilla el bug de verdad.

**6 — Ataque y defensa a la vista.** Widget compartido
(`lib/shared/medias_jugador.dart`) con las dos etiquetas de colores, ya
puesto en la ficha de equipo de partida nueva y en la alineación, donde
además se ve el ataque/defensa del quinteto y de la rotación entera.

**15 — NBA Cup.** El diálogo de campeón es el mismo para la NBA y para la
Cup, y decía "el anillo es vuestro" en los dos casos. Ahora
`daAnillo: false` para la Cup. Y el aviso de jugar la final ya es más
pequeño: pasó de diálogo a una barra de abajo de 6 segundos
(`_avisarFinalDeCopaProgramada` en `simulacion_ui.dart`), porque es una
FECHA que apuntar, no una decisión que tomar. El "falta" que ponía aquí
era texto viejo: la parte que faltaba se hizo en la misma tanda.

**18 — Icono de lesión.** `lib/shared/icono_lesion.dart`: cruz blanca sobre
cuadro rojo, con su propio fondo para que se vea igual en claro y en
oscuro.


**10 — El All-Star había dejado de avisar, y la causa es de las buenas.**
El aviso comprobaba si la fecha del All-Star caía entre el primer y el
último **partido jugado** de cada etapa de simulación. Pero el All-Star es
precisamente el fin de semana en el que NO se juega. Desde que la
simulación avanza por etapas de siete días (para poder pararse en las
ofertas), el parón entero cae en el hueco entre los partidos de una etapa y
los de la siguiente, así que no quedaba dentro del rango de ninguna de las
dos y no lo detectaba nadie. Y una etapa que cayera entera dentro del parón
venía con la lista de partidos vacía y se salía por la primera línea.

Peor de lo que parecía: como el partido de las estrellas se juega DENTRO
de esa función, el All-Star no es que no avisara — es que no se jugaba
nunca. Ahora se compara con la META de la etapa, que avanza aunque no se
juegue nada, y se comprueba aparte si ya estaba jugado. La comparación está
suelta en `allStarYaAlcanzado` para poder probarla
(`test/allstar_aviso_test.dart`) sin montar diálogos.

**8 — Contratos a la vista.** En las ofertas recibidas y en la pantalla de
traspasos, cada jugador enseña ahora los años que le quedan además del
sueldo: 40M con un año por delante y 40M con cinco son operaciones
completamente distintas.

**24 — Palmarés en la cabecera.** Anillos y NBA Cups de ESTA carrera (no el
palmarés compartido entre partidas, que es otra cosa y ya salía en el
selector de equipos).

**19 — Variación de puntos, medida.** El ruido de anotación era uniforme de
±15% sobre el peso, y daba una desviación típica de **4,0 puntos** por
partido. La NBA real anda por 7-8. Peor aún: de 2.000 partidos de un
anotador de 32 de media, solo **UNO** bajaba de 20 puntos. Una estrella que
nunca tiene una mala noche no es un jugador, es una media.

Cambiado a ruido gaussiano con `sigmaRuidoAnotacion`, calibrado en dos
pasadas (0,42 daba 11,0 y partidos de 71 puntos; 0,27 da **7,54**). Ahora
de esos 2.000 partidos, 132 bajan de 20 y el percentil 90 está en 41.

Efecto secundario que hubo que arreglar: el test de que "la estrella anota
más que su compañero" comparaba medias con **80 partidos**, y con el ruido
nuevo 80 no separan la señal (salió 22,63 contra 22,70). Subido a 800, con
la cuenta del error típico escrita en el propio test.

**12 y 21 — La camiseta retirada.** Era una línea: la consulta que decide
si a un jugador "ya se le retiró la camiseta" no filtraba por equipo. Así
que a cualquiera que tuviera una camiseta colgada en otra franquicia —cosa
que pasa sola con las leyendas reales— no se te ofrecía retirársela en la
tuya.

**13 — Trofeos de la partida en el historial.** Las etapas de la carrera
REAL listaban anillos y MVPs; las de tu partida se construían con
`trofeos: const []`, siempre vacío. Un jugador que ganaba dos anillos
contigo aparecía en su historial como si hubiera pasado sin pena ni gloria.

### La causa raíz de los tests inestables, encontrada

Tres "tests inestables" distintos y todos apuntaban al mismo sitio:

1. **Una carrera por un fichero compartido.** `almacenDeSlots` vale por
   defecto el almacén EN DISCO. Cualquier test que simule playoffs acaba
   llamando a `registrarCampeon` → `abrirAjustes()`, que abre el fichero
   `manager_nba_ajustes.sqlite` de verdad. Y `flutter test` ejecuta varios
   ficheros A LA VEZ en procesos distintos: dos que simularan playoffs se
   ponían a escribir en el mismo fichero. De ahí el síntoma que despistaba
   —pasa 8 de 8 veces solo, cae en la tanda completa—. Arreglado con
   `test/flutter_test_config.dart`, que deja el almacén en memoria para
   TODOS los ficheros de test sin tener que acordarse en cada uno.
2. **Los playoffs no aceptaban semilla.** `simularPartidoDeSerie` llamaba a
   `simularPartido` sin `seed`, así que un test con `Random(20260805)` bien
   visible arriba NO era repetible. Ahora `simularPartidoDeSerie` y
   `simularPlayoffsCompletos` aceptan `semilla`, y los tres tests que
   cierran temporadas la pasan.

Queda residuo: la temporada regular (`simularTramo`) sigue sin semilla, así
que un test que simule 82 partidos de verdad todavía puede variar.

3. **Tercera fuga, encontrada el 20 de agosto de 2026: el propio import.**
   Un rojo en CI (`d5e1f19`, "427 tests passed, 1 failed") en un commit que
   SOLO tocaba `docs/plan.md` — o sea, el mismo código que había salido
   verde en el commit anterior. Eso ya dice que es inestabilidad, no
   regresión.

   El culpable era `tu_equipo_no_se_descuelga_test.dart`. Sembraba
   `Random(11)` bien a la vista arriba y le pasaba la semilla a los
   playoffs... pero llamaba a `importarJugadoresSiHaceFalta(db)` **sin
   semilla**, y ese import echa a suertes la edad de retiro de los 586
   jugadores con un `Random()` pelado (a propósito: cada partida tiene sus
   propias retiradas, hay un test que lo exige). Así que en cada ejecución
   se retiraba gente distinta, la agencia libre quedaba distinta, y la
   comprobación de "tu oficina no te ha fichado una estrella sola" caía a
   veces.

   **Medido antes y después**, que es lo único que vale con un test
   inestable: 5 vueltas antes → 1 fallo. 8 vueltas después de pasarle la
   semilla al import → 0 fallos.

**Cómo diagnosticar el siguiente.** Los tres casos han sido la misma forma:
*el test siembra una semilla bien visible y aun así varía, porque algo del
camino no la recibe*. Para encontrar qué:

```
# tests que siembran algo pero importan sin semilla
for f in $(grep -rl "Random(" test/*.dart); do
  grep -q "importarJugadoresSiHaceFalta(db)" "$f" && basename "$f"
done
```

Salen 17 ficheros, y **no** hay que tocarlos todos: la mayoría no dependen
de qué jugadores se retiren. Se arregla el que se demuestre que falla,
repitiéndolo en bucle 5-10 veces antes y después. Cambiar 17 ficheros "por
si acaso" es justo el tipo de cambio que no se puede verificar.

Y una regla que sale de aquí: **una semilla visible en un test no garantiza
nada**. Si el test llama a algo que crea su propio `Random()` por dentro, la
semilla es decorativa.

### Puntos 20 y 22 — salarios y progresion, medidos y arreglados

**Medido antes de tocar nada**: el numero 1 del draft cobraba una mediana
de **3,2M** en su primer ano de rookie. El numero 1 REAL cobra **~12,5M**.
La causa: el sueldo de rookie se calculaba con `salarioEstimado(media,
edad)`, que mira la media del dia del draft (72-76 para casi cualquier
numero 1, porque un chaval de 19 anos nunca trae una media alta) y la
descuenta un 45% por ser menor de 22 anos. El PUESTO del draft —lo que de
verdad fija el sueldo de un rookie en la NBA real— no entraba para nada en
la cuenta.

Con eso, un equipo que draftea bien paga a sus futuras estrellas como si
fueran suplentes durante 4 anos seguidos, y eso es justo el "cinco
titulares 90+ y sobran 10M" que se reporto: no es que el tope este mal,
es que las nominas de los buenos rookies no reflejan lo que valen.

Arreglado con `salarioDeRookiePrimeraRonda(posicionRelativa)` en
`salarios.dart`: una curva concava calibrada contra la escala real
(12,5M en el numero 1, bajando hacia el minimo al final de la ronda).
Medido tras el arreglo: el numero 1 cobra exactamente 12,5M. La segunda
ronda sigue con `salarioEstimado` (ahi no hay escala real que seguir, son
contratos de minimo negociado).

**Punto 22, tambien medido**: el crecimiento de un joven nunca podia
fallar. El salto anual siempre era positivo (22%-48% del margen que
falta), sin ni una sola temporada de estancamiento posible antes de los
27 anos. Con hasta 8 veranos de margen, el numero 1 del draft llegaba a
90+ de media dentro de su contrato de rookie el 20% de las veces — no es
una barbaridad por si solo, pero el mecanismo en si no dejaba lugar a que
un proyecto se frenara, que es literalmente lo que se pidio arreglar
("el potencial no puede alcanzarse siempre").

Anadida `probabilidadDeEstancarse = 0.16`: cada verano, con esa
probabilidad, un joven no mejora nada ese ano (no es un castigo aparte,
es la misma tirada de siempre saliendo a cero). Con esto el numero 1 baja
a 90+ en rookie el 18% de las veces — el efecto es mayor cuanto mas largo
el horizonte (afecta mas a una carrera de 6-8 anos que a una ventana de
4). Medido tambien que la liga sigue sana: 6 temporadas simuladas de
golpe, cuenta de jugadores 90+ estable (25-37 de ~600), nadie se queda sin
estrellas.

**Efecto colateral que hizo falta arreglar**: un test de entrenadores
comparaba el crecimiento de un jugador con UNA sola semilla fija
(`Random(7)`), y esa semilla concreta caia justo en el nuevo estanco —
comparaba 65 contra 65 y fallaba. Arreglado promediando sobre 20 semillas
en vez de fiarse de una sola tirada, que es la misma leccion que ya
aparece en varios sitios de este documento: una tirada suelta no prueba
nada, hace falta promediar.

### Punto 7 — investigado a fondo, sin bug encontrado

Se generaron ofertas de la CPU de verdad (nombres, medias, edades,
contratos, picks) y se revisaron a mano. Los numeros cuadran: un jugador
caro para lo que rinde vale menos en el mercado (`ajusteContrato`), un
joven barato vale mas, los picks se valoran con una curva razonable
(un pick alto de un equipo malo vale como un titular, uno tardio apenas
mueve la aguja), y cada equipo de la CPU solo acepta si sale ganando
(`margenExigido`) sin romper su tope salarial. Los paquetes que salieron
—una estrella hecha + picks por un jugador caro e infravalorado,
dos piezas de rotacion por un jugador barato y productivo— se leen como
ofertas de verdad.

No se ha encontrado un defecto concreto que arreglar. Es posible que la
calibracion de salarios (puntos 20 y 22, arriba) mejore tambien la
sensacion aqui, porque las ofertas se construyen sobre esos mismos
contratos. Queda pendiente de que el usuario mande un ejemplo concreto
—una oferta real que le pareciera absurda— la proxima vez que le pase:
inventar un arreglo sin ese dato es el mismo error que ya se ha pagado
varias veces en este proyecto (ver la seccion de tests inestables).

## Punto 23 — Eventos narrativos (hecho)

Cosas que pasan alrededor del equipo durante la temporada, con una decisión
que tiene consecuencias de verdad en la pista. El ejemplo que pidió el
usuario ("cena de equipo = más química, menos energía") está tal cual en el
catálogo, con esos dos efectos y esos dos signos.

**Cómo está montado.** Tres piezas:

- `lib/domain/eventos_narrativos.dart` — Dart puro: el catálogo (10
  eventos), las condiciones de cuándo puede salir cada uno y los topes. Sin
  base de datos, así que se puede probar entero sin montar una partida.
- `lib/domain/eventos_narrativos_repository.dart` — disparar, resolver,
  leer lo activo y gastarlo partido a partido.
- `lib/features/temporada/evento_narrativo_dialog.dart` — el diálogo de
  decisión, el de consecuencia y la tarjeta del menú principal.

**Dónde se engancha.** Un solo sitio:
`construirEquipoUsuarioParaFecha` es el único punto por el que pasa tu
equipo para jugar CUALQUIER competición (liga, playoffs y NBA Cup), así que
multiplicando ahí el estado de forma por el efecto de vestuario se nota en
las tres sin tener que acordarse de engancharlo en cada una. Y solo ahí:
los eventos son decisiones tuyas y los otros 29 equipos no las tienen.

**Cuántos por temporada.** `maxEventosPorTemporada = 5`, a petición
expresa del usuario ("que no me salgan más de 5 x temporada"). Con
`probabilidadDeEventoPorPartido = 0,035` salen de media unos 2,9 por
temporada de 82 partidos, así que el tope de 5 es el que manda y quedarse
en el tope es raro, no lo normal.

**La calibración, medida (y la primera versión estaba muy pasada).** Se
simularon temporadas completas de 82 partidos con un efecto fijo puesto
todo el año:

| factor | victorias de 82 |
|---|---|
| 0,96 | 32,8 |
| 1,00 | 49,4 |
| 1,04 | 62,6 |

O sea **3,7 victorias por cada 1%**. La simulación es muy sensible al
rendimiento de equipo (ya se sabía, ver el arrastre de la forma en
`forma_repository.dart`), así que los ±4% que se habían puesto a ojo hacían
que UNA respuesta de un diálogo valiera más que todo el sistema de
entrenadores junto (5,6 victorias del mejor al peor). Recalibrado a ±2%
como máximo y tope duro en ±3%: el efecto más fuerte del catálogo vale
~1,1 victorias, y una temporada de decisiones buenas frente a una de
decisiones malas anda por las 4. Se nota, pero por debajo del entrenador,
que es como tiene que ser.

**El test que más ha servido.** `ninguna opción es gratis`: comprueba que
dentro de cada evento la opción con más ganancia acumulada tenga también
algún inconveniente. **Cazó cinco fallos de diseño propios** —eventos donde
una respuesta era todo ventajas y por tanto no había nada que decidir— y
los cinco se arreglaron cambiando el EVENTO, no el test.

### El "test inestable" que resultó no serlo

`premios_repository_test.dart` llevaba tiempo cayendo de vez en cuando en
la tanda completa y pasando siempre en solitario. Se había apuntado como
aleatoriedad de la simulación. **No lo era**: pidiendo el informe expandido
(`flutter test --reporter expanded`) se vio que no fallaba ninguna
aserción — era un `TimeoutException` a los 30 segundos.

Ese test simula DOS temporadas de 82 partidos, unos 27 segundos él solo, y
el tope por defecto de `flutter test` son 30. Llevaba desde siempre justo
al borde. Arreglado poniéndole 5 minutos, como ya tienen los otros tests
que simulan temporadas.

Lección: **en el resumen de la tanda un timeout se ve exactamente igual que
una aserción rota**. Si un test "falla sin decir qué esperaba", pedir el
informe expandido antes de buscar la causa en el código.

De paso se abarató el coste por partido de los efectos: la primera versión
abría una transacción y hacía dos sentencias en cada partido tuyo. Ahora es
una sola sentencia sin transacción (las filas agotadas se limpian al
resolver el siguiente evento y al pasar de año, que son momentos donde da
igual lo que cueste). La tanda completa bajó de 3:51 a 2:22.

### Segundo test inestable encontrado (y por qué se repite el error)

`la_liga_no_se_queda_sin_anotadores_test.dart` falló en la tanda completa y
pasó al ejecutarlo solo. Investigado en vez de reintentar:

**El test PARECE determinista y no lo es.** Lleva un `Random(20260805)`
bien visible arriba, pero `simularPlayoffsCompletos` llama a
`simularPartido` **sin semilla** (`playoffs_repository.dart` → `Random()`
real). O sea que la semilla controla los récords inventados y el verano,
pero no los playoffs, y quince veranos encadenados amplifican esa
diferencia.

**Y los listones estaban pegados al borde.** Medido con 8 ejecuciones
(`zz_diag_anotadores_test.dart`, ya borrado), antes y después del arreglo
de la alineación automática, para saber de quién era la culpa:

| Lo que vigila | Código viejo | Con el arreglo | La regresión | Listón que había |
|---|---|---|---|---|
| Mejor anotador | 26,4 – 28,2 | 26,4 – 28,9 | 21,4 | > 26,0 |
| Anotadores de 25+ | **6 – 11** | **4 – 15** | 0 | >= 6 |

Las dos cosas son ciertas a la vez y conviene no quedarse con solo una:

1. **El listón ya estaba mal puesto.** Con el código viejo el mínimo
   medido era exactamente 6, que es el listón: con solo 8 muestras eso
   significa que el mínimo real está por debajo y que el test iba a fallar
   tarde o temprano igualmente.
2. **Y el arreglo de la alineación lo empeoró**, porque ensancha el
   reparto (de 6-11 a 4-15). No es que haya menos estrellas —la media
   SUBE, de 8,3 a 9,4, y el mejor anotador se queda igual—: es que ahora
   los minutos de titular van más consistentemente al que de verdad
   rinde más, y eso hace que cada partida diverja más de las otras.

Listones movidos a 25,0 y 3, que es el hueco entre lo sano y la
regresión.

**Es el mismo error que ya se cometió** en
`realismo_estadisticas_test.dart` (ver más abajo). La lección, ahora por
segunda vez: **un umbral hay que ponerlo en el hueco entre la distribución
sana y la regresión que vigila, no "un poco por debajo de lo que salió una
vez"**. Y para saber dónde está ese hueco hay que MEDIR las dos cosas, no
solo mirar el valor de una ejecución.

(Nota de cuando esto se escribió: en ese momento la simulación de playoffs
no aceptaba semilla. Ya se arregló — ver "La causa raíz de los tests
inestables, encontrada", más abajo — y el residuo que queda es al revés:
ahora es la temporada REGULAR la que no acepta semilla.)


## Entrenadores (hecho)

Los 30 entrenadores reales de la 2025-26 con nombre ficticio, más 10 libres
en el mercado. **El dataset de Kaggle NO servía**: su tabla `team_details`
trae entrenadores, pero de 2023 y solo de 27 equipos. La lista se sacó de
dos rankings independientes de la 2025-26 (CBS y Bleacher Report), que
coinciden en los 30 nombres; las medias salen de promediar los dos puestos.

Cada uno tiene tres facetas 0-99: **ataque** y **defensa** se notan en cada
partido (van sumadas al rating de equipo en `sim_engine`), y **desarrollo**
se nota en verano (acelera o frena lo que crecen los jóvenes).

### El dinero del banquillo

El sueldo del entrenador **cuenta en la masa salarial de la franquicia** y
compite con los jugadores contra el mismo tope. Por eso `topeSalarial` está
en 240M y no en los 220M reales de la NBA: son los 220M más 20M de margen
para el banquillo.

Ese margen no es un capricho, sale de medir el dataset. Con el tope pelado
de 220M hay **seis equipos que empiezan la partida por encima** (PHI -26M,
DEN -22M, GSW -16M, más ORL, MIN y NYK) y trece más con menos de 18M de
aire. Como la regla es "pasado de tope, solo se ficha por el mínimo", esos
seis se habrían quedado con los peores entrenadores de la liga siendo los
mejores equipos. **Si alguna vez se quiere endurecer, se baja
`topeSalarial`**: cuanto más cerca de 220M, más duele fichar entrenador.

Lo demás del modelo económico:

- La escala de sueldos sale de los reales: 18M el mejor pagado, ~8M uno
  asentado, 2M el suelo del oficio. Curva convexa, como la de jugadores.
- **Despedir no ahorra nada**: al que echas le sigues pagando los años que
  le quedaban y ese finiquito sigue contando en la masa salarial. Es lo que
  convierte un despido en una decisión cara.
- **Pasado de tope solo se firma por el mínimo**, igual que con jugadores.
  Vale para ti y para la CPU — sin esa válvula las seis franquicias pasadas
  de tope se habrían quedado sin banquillo para siempre.
- La negociación es **determinista**, al revés que la de jugadores: un
  entrenador se ficha una vez al año, y que eso se resolviera con un dado
  dejaría al usuario sin saber si le faltó dinero, proyecto o suerte.
- El dinero tapa como mucho **4 puntos** de falta de proyecto. Sin ese tope
  bastaría subir el deslizador para llevarte al mejor entrenador de la liga
  a la peor plantilla.

Lo que hay que saber para no romperlo:

- **La escala está centrada, no es un bonus.** Un entrenador de 76 (la media
  medida del asset) aporta exactamente 0, igual que no tener ninguno. Por eso
  despedir a alguien no es un castigo automático y es una decisión de verdad.
- **Vale 5,6 victorias de 82 del mejor al peor**, medido sobre 40.000
  partidos entre plantillas idénticas. Está anotado en el comentario de
  `PesosAtributos.maxAporteEntrenador` junto a la tabla de medidas. Subirlo
  convertiría el juego en "ficha al mejor entrenador y olvida la plantilla".
- **La barrera para fichar es el nivel de tu equipo, no el dinero** (el tope
  salarial solo cuenta jugadores). Las constantes de `entrenadores.dart`
  salen de MEDIR el dataset: las medias de los cinco mejores de los 30
  equipos van de 82 a 90, con mediana 85. Toda la liga cabe en 8 puntos, así
  que la exigencia se mueve despacio a propósito.
- **Trampa que ya mordió una vez:** al empezar la temporada todos van 0-0.
  Contar eso como "una temporada de 0 victorias" dejaba a la liga entera por
  debajo de lo que pide cualquiera y en el año 1 no firmaba nadie por nadie.
  Sin partidos jugados el récord no cuenta (ver `_tironDelRecord`).
- **Tu banquillo no lo toca el verano.** La CPU despide a los suyos con menos
  de 28 victorias (55% de probabilidad); a ti solo puede pasarte que el tuyo
  se retire, y te lo dice el resumen de pretemporada.
- El récord del entrenador **no se guarda partido a partido**: es el de su
  equipo (`ResultadoTemporada`), y se acumula a su carrera una vez por
  verano. Llevarlo aparte serían dos consultas más en cada uno de los ~2.500
  partidos de un año, para acabar con dos cuentas que pueden separarse.

El mercado no se seca: hay 58 entrenadores en el asset (30 reales con
equipo, 10 reales libres y 18 inventados de nivel bajo-medio) y cuando la
lista de libres baja de 12 se generan más, con el mismo generador de nombres
que los rookies del draft. Los generados son de primer trabajo, nivel ~60:
los buenos se hacen ganando partidos, no se fabrican.

Lo que se dejó fuera y sería lo siguiente: el premio de Entrenador del Año,
que el entrenador afecte a las lesiones o a la química, y una pantalla de
"palmarés de entrenadores" para ver sus carreras.

### Un bug gordo que salió por el camino

`completarPlantillaConElMinimo` (la red que evita que te quedes sin
plantilla) **podía regalarte un jugador de 87 por el salario mínimo**: al
filtrar por un puesto vacante, si el único agente libre que lo cubría era
una estrella, se la firmaba. Salía en 2 de cada 6 partidas simuladas. Ahora
esa vía no firma a nadie de 82 o más, y si un puesto solo lo cubre una
estrella se deja sin cubrir — jugar a alguien fuera de posición cuesta un
10%, regalar un 87 desequilibra la partida.

## Idiomas (las pantallas, hechas; el catálogo de eventos, no)

El juego habla **siete idiomas**: español, inglés, francés, portugués de
Brasil, alemán, italiano y chino simplificado. El selector está en Ajustes,
se guarda en la columna `idioma` que ya existía y repinta la app entera al
momento.

Cómo está montado, y por qué así: `lib/i18n/textos.dart` es una **clase
abstracta** con un `part` por idioma, no los ficheros `.arb` que trae
Flutter. La razón es que aquí **el compilador vigila**: si se añade un texto
y falta en un idioma, `flutter analyze` falla y no se publica. Con `.arb`, lo
que falte sale en tiempo de ejecución delante del usuario.

**Añadir un texto:** se pone en `Textos` y el analizador señala los siete
sitios donde falta. **Añadir un idioma:** clase nueva, entrada en `Idioma` y
en `textosDe`.

Hay un test (`test/idiomas_test.dart`) que además pilla el otro fallo típico:
dejar la cadena en castellano copiada y pegada. Si más de un 25% de los
textos de un idioma coinciden con el castellano, salta.

### Lo que falta y cómo seguir

**Las pantallas ya están todas traducidas** (commit `1fd38ec`): unas 30
ficheros de `lib/features` y `lib/shared`, más de 300 claves nuevas. Se
comprobó con un barrido `grep` sobre los dos directorios y lo único que
queda son identificadores internos ('Este', 'Oeste', 'Final'), que no son
texto de interfaz.

**Lo que SIGUE en castellano es el catálogo de eventos narrativos**
(`lib/domain/eventos_narrativos.dart`): unas 250 líneas con los títulos,
planteamientos, etiquetas de opción y consecuencias de los 12 eventos.
Quien juegue en otro idioma verá esos diálogos en español. No entró en la
tanda de pantallas porque es contenido narrativo largo, no etiquetas: la
receta de abajo sirve igual, pero son textos de varias frases y conviene
tratarlos como una tarea propia. El usuario ya sabe que está pendiente y
no lo ha pedido todavía.

La receta de abajo es la que se usó para las pantallas y funciona.

La receta para cada pantalla, que ya está rodada:

1. Añadir los `String get ...` a `Textos` en `lib/i18n/textos.dart`.
2. `flutter analyze` → dice los siete ficheros donde falta cada uno.
3. Rellenarlos. Los nombres de las claves están en castellano a propósito
   (`tuEquipo`, `masaSalarial`): el código del juego está en castellano y
   mezclar idiomas en los identificadores se lee peor que la incoherencia.
4. En la pantalla, `final textos = t(context);` al principio del `build` y
   sustituir los literales.
5. Añadir las claves nuevas a la lista `todos()` de
   `test/idiomas_test.dart`, que es lo que detecta las traducciones a medias.

**Dos trampas con las que ya se ha tropezado:**

- Un widget aparte (no el `build` de la pantalla) no ve el `textos` local:
  hay que llamar a `t(context)` allí también.
- `t(context)` es una llamada a método, así que **rompe cualquier `const`**
  que lo envuelva. Hay que quitar el `const` del padre y ponerlo en los
  hijos que sigan siéndolo.

**Si se generan las claves con un script de Python** (que es como se
hicieron las 300 de golpe, y merece la pena), hay dos bugs que salieron
y que no dan la cara al compilar — el código compila y el texto sale mal
en pantalla:

- **`\$` en vez de `$`.** En Python `"\$"` no es un escape reconocido y
  pasa tal cual al Dart generado, donde `\$` significa "un dólar
  literal": la interpolación deja de funcionar y al usuario le sale
  `$nombre` escrito. Llegó a haber ~150 así. Se detecta con
  `grep -c '\\\$' lib/i18n/textos_*.dart` (tiene que dar 0 en los siete).
- **Apóstrofes sin escapar** en francés e italiano (`l'année`,
  `all'anno`) cierran el literal de Dart antes de tiempo. Aquí sí falla
  el análisis, pero con errores de sintaxis desconcertantes.

La solución para los dos: **una función que construya el literal Dart**
en vez de escribirlo a mano, escapando `\`, `'` y los saltos de línea, y
pasarle el texto plano. Con eso desaparecen ambos.

Y merece la pena montar un test desechable que llame a TODAS las claves
nuevas con parámetros en los siete idiomas y compruebe que no queda
ningún `$` sin interpolar; se ejecuta, se confirma y se borra.

Criterio de traducción: los términos NBA que la prensa de cada país deja en
inglés (playoffs, All-Star, NBA Cup, trade en alemán) se dejan tal cual.
Traducirlos suena más raro que el original. El portugués es de Brasil
("basquete", "técnico", "elenco"), que es donde se juega.

### AVISO: el chino puede salir en cuadraditos en la web

El juego se compila con `--no-web-resources-cdn` para funcionar sin
conexión, así que CanvasKit **no puede descargarse las fuentes CJK de Google
al vuelo**. La fuente por defecto (Roboto) no tiene glifos chinos.

- En **Android e iOS** los coge del sistema: debería verse bien.
- En **la web** hay que comprobarlo en un navegador de verdad. Si salen
  cuadraditos, la solución es empaquetar una fuente con glifos chinos
  (Noto Sans SC subseteada) y declararla en `pubspec.yaml`. Son varios MB,
  así que conviene cargarla solo cuando el idioma sea chino.

**Esto no está comprobado todavía.**

## Cosas que el juego NO tiene (por si se pide)

Copia de seguridad (exportar/importar), finanzas del club (solo hay tope
salarial: ni ingresos ni taquilla), staff más allá del entrenador, química de
vestuario, ojeadores con incertidumbre real, y el selector de **idioma en
Ajustes está deshabilitado** (es un placeholder).

## Cambiar los DATOS no llega a las partidas ya empezadas

Hermana de la sección del `schemaVersion`, y se aprendió con Kyrie: hay
**dos** formas de que un arreglo no llegue al usuario, y las dos son
silenciosas.

Los importadores del arranque siguen todos el mismo patrón: *si la tabla
ya tiene datos, no hago nada*. Es correcto —volver a importar pisaría una
carrera en marcha— pero significa que **añadir algo al dataset solo lo ven
las partidas nuevas**. Las que ya existen no vuelven a mirar el asset
jamás.

Cuando un cambio de datos tenga que llegar también a las partidas en
curso, hay que escribir un relleno explícito, como
`anadirJugadoresQueFaltenDelDataset` o `importarLegadoHistoricoSiHaceFalta`.
Y con dos cuidados:

1. **Comprobar barato antes de leer el asset.** Estos rellenos corren en
   CADA "continuar partida". El primer intento del de jugadores parseaba
   300 KB en cada arranque y el test de `start_menu_screen` pasó de tardar
   segundos a colgarse diez minutos. Ahora compara una cuenta de filas
   contra `jugadoresUtilizablesDelDataset` y solo lee si no cuadra.
2. **Pensar hasta cuándo tiene sentido.** El de jugadores solo actúa en la
   primera temporada: después la liga ya no se parece al dataset (todos
   han envejecido, ha habido traspasos) y meter a alguien con la edad del
   asset original no sería restaurar lo que faltaba, sería inventarse un
   fichaje con cinco años menos de los que le tocan.

## CUIDADO al tocar `schemaVersion` (ya arreglado, pero hay que mantenerlo)

`app_database.dart` está en `schemaVersion => 24` (21 entrenadores, 22
contratos de entrenador, 23 eventos narrativos, **24 `Temporada.bonusSalarial`**
para el dinero de los eventos). **Hasta la 20 la
migración borraba todas las tablas y las recreaba** — el comentario decía
"sin usuarios reales todavía", y eso dejó de ser verdad hace tiempo: el
usuario y sus amigos tienen partidas en marcha.

Al añadir los entrenadores se cambió por una migración de verdad:

```dart
onUpgrade: (m, from, to) async {
  if (from < 20) { /* camino destructivo, solo para bases prehistóricas */ }
  if (from < 21) await m.createTable(entrenadores);   // aditivo
}
```

**La regla a partir de aquí: cada salto de versión se escribe a mano y es
ADITIVO** — crear tablas o columnas nuevas, nunca borrar lo que ya está. Si
alguna vez hiciera falta un cambio que no se puede hacer así, hay que
preguntárselo al usuario antes, porque cuesta partidas.

Cambiar `assets/data/*.json` NO tiene ese problema: se leen al importar, así
que una partida en curso conserva los datos viejos y el cambio entra en las
partidas nuevas.

## Cómo verificar (los comandos que se usan aquí)

Todo desde `app/manager_nba`:

```
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn --pwa-strategy=none --base-href "/manager-nba/"
```

Los dos flags del build no son opcionales: ver la sección del port a WASM.

**En Git Bash (Windows) el `--base-href` hay que protegerlo**, o el shell
convierte `/manager-nba/` en una ruta de Windows y el build se para con
`Received a --base-href value of "C:/Program Files/Git/manager-nba/"`:

```
MSYS_NO_PATHCONV=1 flutter build web --release ... --base-href "/manager-nba/"
```

Lo mismo pasa con cualquier argumento que empiece por `/`.

**Otras dos trampas del entorno**, ya pagadas varias veces:

- **No lanzar dos `flutter test` a la vez.** El segundo muere con
  `Flutter failed to delete file at ...\build\native_assets\windows\
  sqlite3.dll`. No es un problema de permisos: es que el otro proceso
  tiene el DLL abierto. Si sale ese error, comprobar con
  `Get-Process dart,flutter_tester` antes de tocar nada.
- **Los scripts de Python van con `python -X utf8 <ruta>`** y con la ruta
  como ARGUMENTO. Metida dentro de un heredoc, una ruta estilo
  `/c/Users/...` no la entiende el Python de Windows y el script falla
  sin escribir nada, en silencio. Escribir los scripts con la herramienta
  de ficheros, no con heredocs.

**Para probar el service worker de verdad** (que es la única forma de
pillar los bugs de "sin conexión"), hace falta servir el sitio **bajo la
ruta real** `/manager-nba/`, porque el `base href` va con ella. `python`
está instalado; `node` no. La receta:

1. Compilar con el `--base-href` de arriba.
2. Copiar `build/web` a `<scratch>/sitio/manager-nba`.
3. `python -m http.server 8099 --bind 127.0.0.1 --directory <scratch>/sitio`
4. Abrir `http://localhost:8099/manager-nba/`.
5. Para la prueba sin conexión: **matar el servidor** y recargar. Si el
   juego arranca, funciona de verdad.

Sirve también para `estado.html`. Dos bugs del service worker se
encontraron así, y ninguno se habría visto leyendo el código.

### Tests que simulan temporadas: cuidado con los umbrales

`realismo_estadisticas_test.dart` y compañía simulan temporadas enteras
**con azar real, sin semilla**, a propósito. Eso obliga a una disciplina al
poner cualquier umbral, porque `flutter test` corre en cada `git push` y un
test que falla 1 de cada 7 veces **bloquea la publicación** sin que nada esté
roto (pasó de verdad: dos envíos seguidos en rojo).

La regla que salió de ahí:

1. **Antes de poner un número, medir el estadístico muchas veces.** No
   estimarlo. Los dos umbrales que fallaron estaban puestos a ojo.
2. **Preferir estadísticos agregados a extremos.** La dispersión del % de
   victorias promedia 30 equipos y se mueve ±0,019; el récord del PEOR
   equipo se mueve entre 0,085 y 0,293. Un umbral sobre el segundo no puede
   distinguir "mala suerte" de "motor roto", porque las dos distribuciones
   se solapan.
3. **Comprobar que el test sigue fallando con el código malo.** Se restauran
   las constantes de la regresión (aquí: `sensibilidadAlRating = 1.0` y
   `sigmaRuidoMarcador = 5.5`), se ejecuta, y tiene que saltar. Si no salta,
   se ha aflojado de más y ya no vigila nada.
4. **Y que ya no falla con el bueno**, repitiéndolo tantas veces como haga
   falta para superar el ritmo de fallo que tenía (aquí, 14 pasadas).

Si algún día vuelve a salir un aspa roja con "N tests passed, 1 failed", el
primer sospechoso es este tipo de test, no el cambio que se acaba de subir.

## Hecho el 4-5 de agosto de 2026

**Almacenamiento persistente: HECHO.** `web/index.html` pide
`navigator.storage.persist()` al arrancar (solo si no lo tiene ya). Sin
esto Safari podía borrar los datos de una web que llevara semanas sin
abrirse y llevarse por delante una partida de diez temporadas. iOS lo
concede sin preguntar cuando la web está añadida a la pantalla de inicio;
si el navegador dice que no, se avisa por consola y se sigue jugando.

### Subir `CACHE` en CADA publicación (la trampa que más se olvida)

`web/sw.js` tiene `const CACHE = 'manager-nba-vN'`. **Hay que subir ese
número en toda publicación que cambie el juego, no solo al tocar `web/`.**

El motivo es `main.dart.js`: es el juego entero compilado, está en la lista
de precarga del service worker, y cambia con cualquier línea de Dart. Como
`guardarLoQueFalte` no vuelve a pedir lo que ya está guardado —a propósito,
es lo que permite completar una caché a medias sin descargar 17 MB otra
vez— sin subir la versión los que ya tengan el juego **se quedan con el
código viejo para siempre**: la web se actualiza en GitHub Pages y ellos no
ven ni un cambio.

Al subirla, el `activate` borra las cachés viejas y la nueva se llena de
cero, así que tampoco quedan mezclados ficheros de dos compilaciones.

Histórico: v1 (publicación inicial) → v2 (almacenamiento persistente) →
v3 (lista parte 9) → v4 (curva de estadísticas + página de estado) →
v5 (lista parte 10) → ... → v9 (eventos narrativos) →
**v10 (traducciones + Kyrie + bracket móvil + dinero en los eventos)**.

**Y volvió a pasar, con este aviso ya escrito.** Entre la v9 y la v10 se
subieron CUATRO commits que cambiaban el juego sin tocar el número. El
usuario lo detectó de la única forma en que se detecta: "sigue sin estar
Irving en Dallas". Todo estaba bien —el dataset, el build, el
despliegue— y aun así no le llegaba nada.

Por qué se escapa tan fácil: al arreglar un bug se piensa en el bug, y
`sw.js` no aparece por ningún lado en ese trabajo. **La regla práctica:
subir la versión NO es el último paso de tocar `web/`, es el primer paso
de publicar.** Si se ha cambiado una línea de Dart desde la última
publicación, hay que subirla.

**README:** el enlace ya apunta a `https://jokar77.github.io/manager-nba/`
(antes tenía el marcador `USUARIO/REPOSITORIO`).

### Página de diagnóstico: `web/estado.html`

Cuando el usuario dice "en el icono va mal" no hay forma de mirar su
iPhone, y adivinar sale caro. Esta página se abre en
`https://jokar77.github.io/manager-nba/estado.html` y dice en cristiano
qué tiene guardado ese dispositivo: si está abierto desde el icono o desde
Safari (en iOS son **cachés distintas**), si el modo sin conexión está
instalado, qué versión, cuántos ficheros hay guardados, **cuáles de los
críticos faltan**, si la partida está protegida de borrado y cuánto ocupa.
Arriba del todo, un veredicto de una línea.

Trae dos botones de reparación: uno borra la caché y recarga, y otro
además desregistra el service worker (el "a fondo"). **Ninguno toca las
partidas**, que viven en otro sitio.

Encontró dos bugs del service worker el mismo día que se escribió:

1. **Cualquier navegación devolvía `index.html`.** Con el modo sin
   conexión instalado, abrir `estado.html` te daba el juego. Ahora se
   busca primero la página pedida (caché y luego red) y solo se cae al
   index cuando de verdad no existe — que es lo que hace falta para que
   una ruta cualquiera siga abriendo el juego. Verificado con el servidor
   apagado: `estado.html` se abre, `/una/ruta/inventada` cae al juego, y
   el juego arranca igual.
2. **El repaso de la caché se lanzaba también sin conexión.** Cada
   fichero que faltara eran peticiones colgadas hasta que el sistema las
   cortaba, en cada apertura, justo cuando peor viene. Ahora solo se
   repasa si `navigator.onLine`.

Esta publicación **no sube `CACHE`** a propósito: la lista de precarga y
`main.dart.js` no cambian, solo la lógica del service worker (que se
reinstala sola al cambiar el fichero). Subirla haría que todo el mundo se
volviera a bajar 17 MB para nada.

### La liga se quedaba sin anotadores (arreglado)

Encontrado midiendo 15 veranos seguidos. Las **medias** aguantan, pero los
**puntos** se hunden:

| | mejor anotador | jugadores >25 pts | medias 90+ |
|---|---|---|---|
| T1 | 33,5 | 16 | 20 |
| T7 | 32,8 | 8 | 34 |
| T10 | 29,1 | 4 | 30 |
| T13 | 26,0 | 1 | 29 |
| **T16** | **21,4** | **0** | 26 |

A los quince años hay 26 jugadores de media 90+ y **ninguno pasa de 21,4
puntos**. Superestrellas que anotan como suplentes.

**Causa (dos fallos que se refuerzan):**

1. `_ptsDe(media) = (media - 48) * 0.34` en `draft_repository.dart` es
   **lineal y topada en 18**. Un prospecto de media 90 nace con 14,3
   puntos —un 90 real anota ~28— y ninguno puede pasar de 18 nunca.
2. `envejecerLiga` escala `ptsPg` por `nuevaMedia / media`, que también es
   lineal. Un rookie de 65 con 5,8 puntos que llega a 95 acaba con 8,5.

La relación entre media y puntos es **convexa** (como la salarial: entre un
70 y un 80 hay poca diferencia, entre un 85 y un 95 hay muchísima), y
escalarla linealmente no puede reproducirla. Los jugadores del dataset real
sí tienen puntos coherentes; según se retiran y los sustituyen los
generados, el techo anotador de la liga se desploma.

**Arreglo.** `lib/domain/curva_estadisticas.dart`, nueva. Es la curva medida
en el dataset real, sin ajustar ninguna fórmula elegante: se interpolan los
datos. Una curva inventada que pasara "cerca" sería más bonita y menos
fiel, y aquí hace falta fidelidad.

| media | 67  | 72  | 77  | 82   | 87   | 92   | 97   |
|-------|-----|-----|-----|------|------|------|------|
| pts   | 3,4 | 4,4 | 7,8 | 13,3 | 19,6 | 25,2 | 28,2 |

Asistencias y rebotes igual, multiplicados por el puesto (un base reparte
un 72% más que el jugador medio de su nivel; un pívot coge un 52% más
rebotes). Los dos sitios rotos pasan a usarla:

- `envejecerLiga` mueve al jugador **por la curva**: calcula su estilo
  (`ptsPg / puntosTipicos(mediaVieja)`) y lo aplica al nivel nuevo. Así se
  le conserva la personalidad —quien anota más de lo normal para su nivel
  lo sigue haciendo— y si su media no cambia, el número no se mueve ni un
  decimal.
- El generador del draft nace justo en la curva, sin tope de 18.

**El tope del estilo se calibró midiendo, no a ojo.** Con el primer valor
probado (2,0) apareció un jugador de **43,7 puntos** en la séptima
temporada. Con 1,5 —que es donde andan los más atípicos del dataset— y un
techo duro de 34 (el máximo real es 33,5), desaparece.

**Resultado, 15 veranos con la misma semilla:**

| | T1 | T4 | T7 | T10 | T13 | T16 |
|---|---|---|---|---|---|---|
| mejor anotador ANTES | 33,5 | — | 32,8 | 29,1 | 26,0 | **21,4** |
| mejor anotador AHORA | 33,5 | 32,7 | 33,3 | 33,3 | 29,6 | **28,2** |
| jugadores >25 ANTES | 16 | — | 8 | 4 | 1 | **0** |
| jugadores >25 AHORA | 16 | 28 | 35 | 26 | 15 | **18** |

Y comprobado también en la **anotación simulada de verdad** (no el prior),
jugando seis temporadas completas: el top-5 se queda entre 27 y 34 puntos
por partido, con 8-13 jugadores por encima de 25 cada año. Sin deriva.

Regresión en `la_liga_no_se_queda_sin_anotadores_test.dart`, con las dos
caras (que no se hunda y que no se dispare) más tres tests rápidos de la
curva: que sea convexa, que un jugador sin cambio de media conserve sus
números exactos, y que los puestos se diferencien. **Comprobado que falla
con el código viejo** (22,4 puntos contra el umbral de 26).

Con esto **`CACHE` sube a `manager-nba-v4`**: cambia `main.dart.js`.

### Lista parte 10 (terminada)

**P10-1 · Bracket de playoffs.** Ya estaba hecho en la parte 9 (vertical,
entero en móvil, Play-In que desaparece al resolverse). Se le añade que la
Final NBA decidida se corone **en el propio cuadro** —borde y fondo
dorados— en vez de saberse solo por el banner de arriba.

**P10-2 · El confeti se quedaba colgado.** `avance = (t - retraso) *
velocidad`: un papelillo con retraso 0,35 y velocidad 0,75 terminaba la
animación con avance **0,49**, o sea a media pantalla. Y como el
desvanecido solo entra a partir de 0,85, ni siquiera se difuminaba: se
quedaba clavado mientras el diálogo siguiera abierto. Ahora el avance se
mide sobre el trozo que le queda a CADA papelillo (`(t - retraso) / (1 -
retraso) * velocidad`, con velocidad ≥ 1), así que todos llegan abajo antes
de que se pare el reloj.

**P10-3 · El año de ingreso en la lista de nuevos del Hall of Fame.** El
año estaba en el código pero la pantalla se pintaba antes de que cargara
la temporada, y en ese primer fotograma caía al texto sin año. Eran dos
`FutureBuilder` anidados que dibujaban con lo que hubiera. Ahora se espera
a tener las dos cosas, como hace la lista grande.

**P10-4 · Posiciones mal asignadas.** Dos fallos distintos.

*El dato.* El volcado de Kaggle (`data/draft/nba.sqlite`, solo en disco
local) trae posiciones reales en `common_player_info.position`. A nivel
grueso el dataset solo fallaba en 14 de 248 emparejados, pero el detalle
estaba mal: Tatum figuraba como `PF` cuando la fuente dice
**Forward-Guard**. Se aplicaron **25 correcciones con fuente** a
`jugadores.json` usando solo las etiquetas inequívocas
(`Guard-Forward`→SG, `Forward-Guard`→SF, `Forward-Center`→PF,
`Center-Forward`→C, `Center`→C): Tatum→SF, Mobley y Holmgren→C, Sabonis y
Jaren Jackson→PF, Mikal Bridges→SG... Las ambiguas (`Guard` o `Forward` a
secas) se dejan como están: no hay dato para afinarlas y no se inventan.

*La regla.* `derivarPosicionSecundaria` comparaba `astPg > trbPg` **en
absoluto**, que en la práctica preguntaba "¿es base?": en la NBA casi todo
el mundo rebotea más de lo que asiste. Medido sobre los 641 jugadores, de
los que pueden tirar hacia los dos lados **332 se iban hacia dentro y solo
45 hacia fuera** — 4 de 123 aleros pasaban a escolta. Ahora se compara con
lo típico de su puesto y su nivel (usando `curva_estadisticas.dart`), y el
reparto queda **153 fuera / 237 dentro**. Tatum sale **SF/PF**.

Los prospectos del draft necesitan otra regla: nacen justo en la curva, así
que compararlos por asistencias y rebotes daría siempre empate y todas las
hornadas saldrían escoradas al mismo lado. Se usa su perfil sorteado (quien
tira de tres se abre, quien defiende tira hacia dentro).

**Efecto colateral que hubo que resolver.** Al cambiar las posiciones, la
alineación automática de Denver sacó a Strawther (76, escolta) de pívot
suplente por delante de Nnaji (71, PF/C): 76 × 0,9 = **68,40** contra 71 ×
0,96 = **68,16**. El algoritmo hacía lo que dice su documentación, pero
decidir el pívot suplente por **0,24 puntos** es decidirlo por ruido. Se
añade `margenDeComodidadAlRepartir` (1 punto de media, solo al repartir la
alineación — la simulación no se toca): un empate técnico se resuelve a
favor de quien juega ahí de verdad, y el de fuera sigue ganando el puesto
cuando es de verdad mejor. El test que codificaba la política vieja se
actualizó conservando lo que protegía (que no se siente a un 86 detrás de
un 65).

**Ojo con las partidas en curso:** las posiciones se leen al importar, así
que una partida ya empezada conserva las viejas. El arreglo entra en las
partidas nuevas.

### Lista parte 9 (terminada)

**P9-1 · Fin de temporada: clasificación en vez de la lista de partidos.**
La pestaña del medio del resumen enseñaba los 82 partidos uno a uno; ahora
enseña la clasificación de los 30 equipos, por conferencias, con tu equipo
resaltado y la línea de corte de playoffs (8) y play-in (10). La lista de
partidos no contaba nada que no hubieras visto ya según se jugaban.
`EquipoEnLaClasificacion` en `resumen_temporada_repository.dart`, calculada
con el mismo criterio que el puesto que ya salía arriba (por porcentaje, y
por nombre para desempatar). Regresión en `resumen_temporada_test.dart`:
30 filas, 15 por conferencia, ordenadas, y el puesto de la cabecera
coherente con la tabla.

**P9-2 · Playoffs: el Play-In desaparece y el cuadro pasa a vertical.**
El panel del Play-In se oculta en cuanto se resuelve —cumplida su función
solo empujaba el bracket hacia abajo— y sus resultados quedan igualmente
a la vista en las cabezas de serie del cuadro.

El bracket ahora va de arriba abajo: el Oeste baja de la primera ronda a
su final de conferencia, el Este sube desde abajo y las dos mitades se
encuentran en la Final NBA del centro. **No es solo estética:** en
horizontal el cuadro necesitaba 1400 píxeles de ancho y en un móvil de 390
quedaba al 28%; girado mide 714, o sea el 55%. El scroll vertical de la
pantalla se encarga del alto. Se conserva el `InteractiveViewer` para
pellizcar, pero en tablet ya cabe sin encoger.

Dos avisos para quien toque esto:

- El cuadro lleva `ValueKey('cuadro-playoffs')` **porque los tests lo
  necesitan**: si cabe sin encoger no se crea el `InteractiveViewer`, así
  que buscar ese widget para medirlo (como hacía `adaptacion_movil_test`)
  falla con "Bad state: No element" en tablet.
- Al ocultar el Play-In se pierde el único camino de la UI de playoffs
  hacia el boxscore de un partido único. Esa bifurcación de
  `abrirEstadisticasDeSerie` la sigue usando la NBA Cup, así que su test se
  reescribió llamando al helper directamente en vez de borrarlo.

**P9-3 · Retiros: la edad de cada retirado.** `CambioDeJugador` gana
`edad` (la de después de cumplir años, que es con la que de verdad se
retira). Se muestra en la pantalla de retirados y en el resumen de
pretemporada. Regresión en `progresion_repository_test.dart`, que además
comprueba que esa edad coincide con la que queda guardada en la base de
datos.

### Tests flaky: uno arreglado, otro asumido

**`premios_repository_test` ("no puede repetir como Rookie del Año"):
ARREGLADO.** Cayó en tres pasadas completas de las últimas cinco, así que
tocaba mirarlo. Pasaba 4/4 en solitario y fallaba en la suite, lo que
parecía un problema de aislamiento — pero no: el andamiaje del test exigía
que un novato sintético **ganara** el ROY en la temporada 1, y ese premio
se pondera por victorias del equipo (P3-3) sobre una simulación sin
semilla. Un rookie del dataset en un equipo de 60 victorias podía
adelantarle sin que nada estuviera roto.

Ahora comprueba el mecanismo real y determinista: en la temporada 1 no
tiene nada archivado en `HistorialEstadisticasJugador` (es rookie) y en la
2 sí (ya no puede serlo). El fondo del test —que la elegibilidad no use la
edad como atajo— queda igual de cubierto. 3/3 en solitario.

**`realismo_estadisticas_test` (reparto de récords de la liga): se asume.**
Simula una temporada entera **sin semilla a propósito** (está escrito en el
propio test) y comprueba que el mejor no gane el 88% ni el peor baje del
10%. Medido tras los cambios de la parte 10: 5/5 en solitario, y un fallo
suelto en una pasada completa. Es el precio de medir realismo sobre una
temporada de verdad; si empezara a caer a menudo, lo que hay que subir es
la muestra, no tocar el juego.

### "Mi equipo es mejor y me hacen 27-55": era el sorteo de forma

Reportado así: *"jugando con los Knicks me hacen poquísimas victorias pero
en otra partida ganan ellos el anillo, y con OKC he hecho 27-55"*.

**Lo obvio se descartó primero, con números.** Simulando 8 temporadas
completas del mismo equipo llevado por el usuario y llevado por la CPU:

| | lo llevas tú | lo lleva la CPU |
|---|---|---|
| NYK | 54,6 victorias | 52,5 |
| OKC | 49,6 | 51,3 |

El `top8` era idéntico en los dos brazos, o sea la misma plantilla. **No
hay ninguna desventaja por ser tu equipo** (+2,1 y −1,6: ruido).

**Lo que sí había era demasiado azar.** Diez temporadas del mismo equipo
con la misma plantilla daban 43, 43, 44, 44, 46, 48, 50, 55, 62 y 64
victorias: desviación 7,9, contra un suelo binomial irreducible de 4,4.
Descomponiendo la varianza:

| | desviación de victorias | r con la forma |
|---|---|---|
| con forma | 7,9 | **0,78** |
| forma a 1.0 para todos | 5,1 | — |
| suelo binomial | 4,4 | — |

El sorteo de forma explicaba el **61%** de la temporada (r²=0,61) y aportaba
él solo ±6 victorias. Las lesiones quedaron descartadas: 3 de media por
equipo y correlación inconsistente entre tandas (−0,54 y +0,38 con n=10).

**Causa.** La forma se sorteaba por jugador con sigma 0,07, pero los diez
sorteos de una rotación **se sumaban**: la forma media de un equipo se
desviaba 0,027, y ese 2,7% de fuerza colectiva valía esas ±6 victorias.

**Arreglo** (`_arrastreDeEquipo = 0.35` en `forma_repository.dart`): se
sortea igual que antes y después se le devuelve a cada equipo el 65% de la
suerte colectiva que le había tocado. La variedad individual queda intacta
—sigma por jugador 0,070 → 0,067, o sea el MVP sigue cambiando— y lo que
desaparece es el arrastre de equipo. No se centra del todo a propósito: un
equipo puede tener un buen año o uno gris, como en la NBA.

Medido después: desviación 7,9 → **5,7**, forma de equipo 0,0268 →
**0,0114**, r 0,78 → **0,53**. Sin forma sale 4,4 con un suelo de 4,5, o
sea que lo que queda ya es el azar irreducible de los partidos.

Regresión en `forma_y_premios_test.dart`, midiendo el sorteo directamente
(rápido y sin ruido de partidos) por los dos lados: la desviación por
equipo por debajo de 0,016 y la individual por encima de 0,055.
**Comprobado que falla con el código viejo** (daba 0,0222).

### El juego no funcionaba sin conexión (dos bugs del service worker)

Reportado así: *"si agrego el juego a la pantalla de inicio no va sin
internet y va fatal casi no funciona, pero desde Safari normal sí va"*.
Eran dos fallos distintos, y el segundo solo se ve **sirviendo el sitio y
mirando qué pide el navegador de verdad**, no leyendo la lista.

**1. La lista de precarga no coincidía con lo que el juego carga.**
Sirviendo la compilación en local bajo `/manager-nba/` y leyendo las
peticiones reales, el arranque pide:

- `canvaskit/chromium/canvaskit.wasm` + `.js` — **no estaban en la lista**
- `assets/packages/cupertino_icons/assets/CupertinoIcons.ttf` — **tampoco**

y en cambio se precargaban `skwasm.js` + `skwasm.wasm` (3,6 MB) que **no
se piden nunca**, porque el build fija `renderer: canvaskit`.

Flutter elige la variante del motor en caliente: los navegadores basados
en Chromium piden `canvaskit/chromium/`, el resto —Safari, o sea el
iPhone— `canvaskit/` a secas. Como el service worker no puede saber quién
le tocará, **ahora van las dos**. Es el motor de dibujo: sin él en caché,
sin conexión la pantalla se queda en blanco. Comprobado directamente en
Chromium; para Safari se cubre por la otra variante.

**2. Una instalación a medias era permanente.** El `install` guardaba los
ficheros uno a uno y se saltaba los que fallaran (a propósito: mejor 24 de
25 que ninguno), pero **no volvía a intentarlo jamás**. Si la primera vez
pillaba mala cobertura —o era el primer arranque desde la pantalla de
inicio del iPhone, que tiene su propia caché vacía, aparte de la de
Safari— la caché se quedaba incompleta para siempre: unos ficheros se
servían y otros no. Eso es literalmente "va fatal, casi no funciona".
Ahora cada vez que se abre el juego con conexión se completa lo que falte
(`completarPrecargaSiFalta`, enganchado al `fetch` de navegación).

**Verificado de verdad:** borrando service worker y cachés, recargando,
**matando el servidor** y recargando otra vez → los 9 ficheros críticos se
sirven con 200, el motor de Flutter arranca (`flutterView` presente,
`_flutter` inicializado) y **cero errores en consola**.

Un aviso que no es un bug y conviene recordar: **en iOS, la app de la
pantalla de inicio tiene su propia caché, separada de Safari.** Haber
cargado el juego en Safari no sirve de nada para el icono. Hay que abrirlo
**una vez desde el icono y con conexión**.

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


## Fase 8: rediseño con aire de videojuego (menú principal y plantilla)

Encargo: *"hay que hacerlo más parecido a los menús y niveles del 2K"*, y
después de ver dos direcciones maquetadas: **dirección A ("Marcador")**, y
que **se pueda elegir entre modo claro y oscuro**.

Las maquetas están en `docs/diseno/`, con su propio README. Se hicieron
para el lienzo de Claude Design, que no se pudo montar porque **esta
máquina no tiene Node.js**; en su lugar hay un script de Python que las
junta en una página. Esa página (`vista-previa.html`) NO se guarda: es un
fichero derivado y está en `.gitignore`, se regenera con
`python docs/diseno/construir_vista.py`.

**Son un registro histórico, no la especificación.** La interfaz de verdad
es el código, y se separó de las maquetas en varias cosas (la barra sin
flecha, la regla de mayúsculas, los colores de placa corregidos por
contraste). El README de la carpeta lo dice en la primera línea, para que
nadie las lea como si mandaran.

### El sistema de diseño vive en un sitio

`lib/shared/estilo.dart`: la clase `Estilo` con las dos paletas
(`Estilo.oscuro` y `Estilo.claro`, y `Estilo.de(context)` elige), más las
piezas que se repiten — `PanelCortado` y `EsquinaCortada` (la esquina
inferior derecha en diagonal, que es lo que hace que un panel se lea como
de videojuego y no como una tarjeta de Material), `PlacaEquipo`,
`PlacaMedia`, `MonogramaFantasma`, `CunaEsquina`, `SeparadorSeccion`, y los
estilos de texto `rotulo` / `titular` / `cifra`.

**El claro no es el oscuro invertido.** Lo que se conserva es la estructura
(los cortes, las mayúsculas, la franja del marcador) y lo que cambia es el
suelo y la tinta. La cabecera de equipo se queda con el color del club en
los dos modos, porque eso es identidad y no decoración.

### Decisiones que conviene no deshacer sin querer

- **Las mayúsculas están en la cadena, no en el estilo.** Flutter no tiene
  el `text-transform` de CSS. Se hace con `mayus()` en un solo sitio para
  poder deshacerlo de una vez. Efecto secundario: `find.text('Calendario')`
  dejó de encontrar nada, y hubo que tocar cuatro ficheros de test.
- **`acentoDeEquipo(primario, secundario)`** en `shared/contraste.dart`: el
  segundo color del club sobre el primero es lo natural (el oro de Denver
  sobre su azul), pero hay equipos con los dos colores parecidos o negro
  sobre azul marino. Si el contraste no llega a 2.2 se cae al blanco/negro.
- **La fila de cinco puestos de la alineación depende del ancho real
  (`_anchoMinimoParaCincoPuestos = 1190`), no del tramo de pantalla.** Una
  ventana de 1024 ya cuenta como `amplio`, pero ahí las cinco columnas
  salen a 190 px y las etiquetas ATA/DEF no caben. Es la excepción
  razonada a la norma de `shared/pantalla.dart` de no inventarse cortes.
- **Cada hueco de la alineación lleva `ValueKey('hueco-POS-titular')` y su
  nombre `ValueKey('nombre-POS-titular')`.** Los tests se agarraban antes a
  `ListTile` y al texto "Titular: X (POS, media)"; con el rediseño eso
  desapareció. Las claves no cambian ni con el idioma ni con el maquetado.

### Lo que el test nuevo cazó

`test/tema_claro_y_oscuro_test.dart` monta las dos pantallas en los dos
modos y a los tres tamaños (12 combinaciones) y, además, **comprueba el
contraste WCAG de las dos paletas con números**, componiendo antes los
colores semitransparentes sobre su fondo.

Encontró dos fallos que a ojo no se ven: en modo claro, el verde
(`#23A366`) y el gris (`#6F7B8C`) de las placas de media daban 3,2 y 4,3 de
contraste con el blanco de encima, por debajo del 4,5 que pide la norma
para texto pequeño. Se oscurecieron a `#127A48` y `#5A6675`.

### Lo que NO se hizo, y por qué

- ~~No hay tipografía condensada.~~ **Hecho después:** Saira Condensed
  empaquetada (ver más abajo).
- **Solo dos pantallas de una veintena.** (Ampliado después: ver más
  abajo.) Dentro de la propia plantilla, la pestaña de Estadísticas y la
  hoja de picks siguen con `ListTile`.
- **No se añadió la tarjeta de "próximo partido"** arriba del menú. Encaja
  sola en este estilo, pero es contenido nuevo y no un cambio de aspecto.

Verificación: `flutter analyze` limpio y **446 tests en verde** (18 nuevos).

### Segunda tanda: el camino entero hasta el partido

Con la dirección ya elegida, el rediseño se llevó a las cuatro pantallas
que faltaban para que no se rompiera el hilo:

| Pantalla | Qué cambia |
|---|---|
| Menú de inicio | Título alineado a la izquierda con filete de marca, balón gigante de fondo, y las tres ranuras como fichas con la franja del club |
| Elegir equipo | De lista de 30 filas iguales a **rejilla de fichas** (2/3/5 columnas), cada una con su color, su monograma y la media del quinteto como placa |
| Vista previa del club | Cabecera de identidad con la media al lado, entrenador en su franja y plantilla con placa por jugador |
| Calendario | Barra de título del club, botones de avance perfilados, cabecera de mes con el separador de sección y celda de día con **filo de color arriba** (verde ganado, rojo perdido, color de tu club por jugar) |

Piezas nuevas del sistema, para no repetirlas por pantalla:

- **`BotonPrincipal` y `BotonPerfilado`**. Por dentro son el `FilledButton`
  y el `OutlinedButton` de Material con `BeveledRectangleBorder` de radio en
  una sola esquina — eso da la diagonal del diseño de forma nativa, recorta
  bien el chapoteo del InkWell (cosa que un `ClipPath` por fuera no hace) y
  conserva foco con teclado, estado apagado y semántica. Lo único propio es
  la forma y la letra.
- **`BarraDeTitulo`**: la franja con el color del club. No es un
  `PreferredSizeWidget` a propósito — va como primer hijo de un `Column` y
  no en `Scaffold.appBar`, porque debajo suele ir pegada otra franja (el
  marcador, las pestañas) y con el AppBar quedaban separadas.
- **`Estilo.marca`**: el acento del juego para las pantallas que todavía no
  tienen club (inicio y elección de equipo). Dentro de una franquicia manda
  el color del club.

Un arreglo que salió por el camino: los días pasados del calendario se
apagaban echándoles negro por encima, lo que en **modo claro los hacía
resaltar en vez de apagarlos**. Ahora se apagan hacia el fondo de la
pantalla, que funciona en los dos modos.

Verificación: `flutter analyze` limpio y **470 tests en verde**, 36 de ellos
de temas (las seis pantallas × dos modos × tres tamaños, más el contraste
de las paletas medido con números).

### Lo que sigue sin rediseñar (al cierre de la segunda tanda)

Se completó después: ver las tandas de abajo.

### Tercera tanda: la tipografía y el tema global

**La tipografía va empaquetada, no descargada.** `assets/fonts` con Saira
Condensed en dos pesos (700 y 800, los únicos que se usan), 190 KB, licencia
SIL OFL incluida al lado. Descargarla en tiempo de ejecución habría metido
una dependencia de red en un juego que se puede jugar sin conexión, y un
parpadeo de fuente en la primera pantalla.

**Y hay que cargarla a mano en los tests.** `flutter test` NO carga las
fuentes del `pubspec.yaml`: mide con una de relleno. Como el diseño se
apoya en que la letra es estrecha —los titulares en mayúsculas solo caben
por eso—, los tests de desborde estaban comprobando una pantalla que no es
la que se publica. Se arregla con `cargarTipografiaDelJuego()`
(`test/tipografia_de_prueba.dart`) en el `setUpAll` de los dos tests que
miden sitio. Lo mismo con el tema: ahora montan `temaDeApp(brillo)` y no un
`ThemeData` genérico.

**El tema global es lo que unifica las pantallas que no se han rehecho.**
`temaDeApp(Brightness)` en `estilo.dart` construye el `ThemeData` desde la
misma paleta: suelo, grises, letra condensada en los títulos y esquina
cortada en botones, tarjetas, diálogos y chips. Las ~18 pantallas que
todavía no están rediseñadas a mano heredan de ahí, así que hablan el mismo
idioma mientras les llega el turno, en vez de quedarse con el Material de
fábrica al lado de las que sí lo están.

**El escudo cuadrado, de un solo cambio.** `EquipoLogo` (el círculo) se
reescribió por dentro para delegar en `PlacaEquipo`. Eran 29 sitios que lo
pintaban; tocar la pieza y no las 29 pantallas es lo que evita que
convivan dos escudos distintos según por dónde llegues. Por debajo de 24 px
la placa se queda sin el código del equipo: a ese tamaño saldría a 8 px.

Piezas compartidas nuevas: `FilaDeJugador` (`shared/ficha_jugador.dart`),
que es la fila con placa de media que repetían agencia libre, draft,
traspasos y ofertas; y `barraDeClub()` (`shared/barra_de_club.dart`), que
mete la barra del club en el hueco `appBar:` de un `Scaffold` con una sola
línea.

Rediseñadas a fondo en esta tanda: **clasificación**, **playoffs**,
**agencia libre**, **draft**, **premios**, **NBA Cup**, **ofertas**,
**traspasos**, **entrenador** y **legado**.

Un fallo que cazó el test al ampliarlo: la cabecera de la clasificación
fingía la alineación de sus columnas con espacios (`'V-D    %    DIF'`), así
que al cambiar los anchos de las filas quedó descuadrada **y desbordaba 41
px en un móvil**. Ahora cabecera y filas comparten las mismas constantes de
ancho.

Verificación: `flutter analyze` limpio y **500 tests en verde**, 72 de ellos
de temas (once pantallas × dos modos × tres tamaños, con la fuente y el tema
de verdad, más el contraste de las paletas medido con números).

### Cuarta tanda: lo que quedaba

Rediseñadas a fondo: **resumen de simulación**, **boxscore**, **resumen de
temporada**, **camisetas retiradas**, **detalle de equipo**,
**renovaciones**, **retirados**, **Hall of Fame**, **All-Star** y **líderes
históricos**.

Dos decisiones de fondo:

- **El boxscore tenía dos tablas** —`DataTable` de Material en ancho y una
  hecha a mano en estrecho— porque `DataTable` reparte el ancho según lo que
  ocupe cada celda y con un nombre largo se salía en un teléfono. Ahora es
  una sola para todos los anchos: además de caber siempre, la de Material
  era de lo poco que seguía teniendo aspecto de Material.
- **En las listas, ganador y perdedor ya no se distinguen por el grosor de
  la letra sino por la tinta.** La condensada va gruesa en los dos pesos que
  se empaquetan, así que "negrita contra normal" no se notaba. Afecta al
  marcador del boxscore, al bracket de playoffs, al All-Star y a los líderes
  históricos, y obligó a reescribir lo que comprobaba
  `boxscore_screen_test`: el test pasa a vigilar la intención (que el
  marcador NO se pinte de verde, y que ganador y perdedor se distingan) en
  vez del mecanismo concreto.

Un detalle que salió en los tests y conviene recordar: **el monograma
gigante de la barra de club es un `Text` de verdad**, así que
`find.text('DEN')` encuentra dos. Los tests que buscan un código de equipo
dentro de una pantalla tienen que acotar el ámbito
(`find.descendant(of: find.byType(ListView), ...)`).

Verificación: `flutter analyze` limpio y **506 tests en verde**, 78 de ellos
de temas.

### Estado del rediseño

**A fondo (26 pantallas):** inicio, elegir equipo, vista previa de club,
alineación, menú principal, calendario, clasificación, playoffs, agencia
libre, draft, premios, NBA Cup, ofertas, traspasos, entrenador, legado,
resumen de simulación, boxscore, resumen de temporada, camisetas retiradas,
detalle de equipo, renovaciones, retirados, Hall of Fame, All-Star y líderes
históricos.

**Solo con el tema global:** (ninguna, se completaron después — ver la
quinta tanda).

### Quinta tanda: el rediseño queda completo

Ya **no queda ni un `AppBar` de Material** en el juego. Lo que faltaba:

- La tarjeta de eventos de vestuario (`evento_narrativo_dialog.dart`), que
  se ve dentro del menú principal, y el propio diálogo de decisión.
- Las seis pantallas de paso obligatorio del verano (renovaciones, draft,
  retirados, pretemporada, camisetas nuevas, agencia libre en modo trámite).
- La ficha de carrera de un jugador, All-Star, Hall of Fame, ajustes y los
  boxscores de una serie.

Piezas de sistema que hicieron falta para poder cerrarlo:

- **`conVolver` en las barras.** Los pasos obligatorios del cambio de
  temporada llevaban `automaticallyImplyLeading: false` justo para que no
  hubiera flecha de volver: la ruta SÍ se puede descartar, así que una
  flecha te dejaría escaparte de algo que el juego da por hecho. Sin este
  parámetro, cambiar esas barras habría sido un cambio de comportamiento
  disfrazado de cambio de aspecto.
- **`BarraNeutraAppBar`**, para las pantallas que no son de un club (Hall of
  Fame, All-Star, ajustes, la ficha de un jugador): misma forma, pero con el
  acento del juego en vez del color de un equipo.
- **`BackButton` de Flutter en vez de un `IconButton` a mano.** Trae el
  tooltip ya traducido, el icono de cada plataforma y el `maybePop` de
  serie; y además es lo que busca `tester.pageBack()`, que fue como se
  descubrió.

### Dónde NO van las mayúsculas

Se corrigió un error de la tanda anterior: las **etiquetas de las opciones
de un evento narrativo** salían en mayúsculas, y son frases del guion
("Aceptar la cena del equipo"), no rótulos de interfaz. Lo mismo con el
título del evento. Los botones tienen ahora un parámetro `mayusculas` (por
defecto true) para poder decirlo.

La regla, para no volver a equivocarse: **mayúsculas en los rótulos de
interfaz** (destinos del menú, títulos de pantalla, cabeceras de columna,
nombres propios de club y de jugador) y **caja normal en la prosa** (textos
de evento, avisos, explicaciones).

Verificación: `flutter analyze` limpio, **506 tests en verde** y la web
compila. Los únicos restos de Material son los `AlertDialog`, que heredan
del tema la esquina cortada, el panel y la letra condensada del título.

## Pendiente en el rediseño (a 2026-08-20)

El rediseño en sí está **completo**: no queda ningún `AppBar` de Material,
506 tests en verde, `flutter analyze` limpio, la web compila. Lo que sigue
abierto es más pequeño:

1. ~~Los `AlertDialog` no se han rehecho a mano.~~ **Hecho después:** ver
   la sexta tanda, más abajo.
2. ~~No hay ninguna pantalla nueva de contenido.~~ **Hecho después:** la
   tarjeta de próximo partido, ver la sexta tanda.
3. **Verificación solo automática, nunca visual.** Todo lo anterior se
   comprobó con `flutter analyze`, la suite de tests (incluida
   `tema_claro_y_oscuro_test.dart`, que mide contraste WCAG con números) y
   que la web compila sin errores de consola. **Nadie ha mirado la
   interfaz con sus propios ojos todavía** — ni en el navegador de esta
   sesión (los screenshots no funcionan aquí) ni en un dispositivo real.
   Es el hueco más importante: los tests atrapan desbordes y contraste,
   pero no dicen si algo "se ve raro".
4. **`docs/diseno/`** son solo un registro histórico de las dos direcciones
   que se compararon al principio (ver su README) — no hay trabajo
   pendiente ahí, pero conviene no confundirlas con la especificación.

## Pendiente del proyecto en general (no es del rediseño)

Estos son anteriores al rediseño y siguen sin resolver:

- **El icono del iPhone** sigue sin diagnosticar: hace falta que el usuario
  abra `https://jokar77.github.io/manager-nba/estado.html` **desde el
  icono** y diga qué pone.
- **El chino puede verse en cuadraditos en la web**, sin comprobar: hace
  falta que el usuario lo pruebe en su móvil con el idioma en chino.
- **No hay copia de seguridad de partidas** (aparcado a propósito: el plan
  es sacar el juego como app nativa).
- ~~El catálogo de eventos narrativos (`lib/domain/eventos_narrativos.dart`,
  ~250 líneas) sigue solo en castellano.~~ **Hecho el 2026-08-21**, ver
  "Eventos narrativos traducidos" al final.
- Ítem 7 de la lista de bugs (ofertas de la CPU poco realistas):
  investigado, no se encontró fallo — pendiente de un ejemplo concreto del
  usuario para poder reproducirlo.

## Sexta tanda: diálogos, tarjeta de próximo partido, y dos bugs de camino

### Un bug de despliegue que no era del rediseño

Al publicar el rediseño (`75bdb8c`) **se me olvidó subir la versión de
caché del service worker**. El propio `sw.js` lo advierte en mayúsculas en
un comentario, y me lo salté igual: sin subir `CACHE`, quien ya tuviera el
juego guardado se queda con el código viejo para siempre, porque no hay
motivo para que el navegador pida nada nuevo. Se notó porque el usuario
veía el rediseño en el ordenador (sesión sin caché previa) pero **el
iPhone seguía enseñando el juego de antes** — no es que no cargara, es que
cargaba lo de siempre.

Arreglado en `f243cfe`: caché a `v11`, y de paso la tipografía Saira
Condensed añadida a la lista de precarga (se me había quedado fuera).
Verificado sirviendo la compilación real en local antes de publicar: los
cuatro ficheros nuevos existen exactamente en las rutas que pide el
service worker (`assets/assets/fonts/...`, con el mismo doble `assets/`
que ya usaba `jugadores.json` — a la primera lo puse mal, sin el prefijo
doblado, y el propio chequeo lo cazó antes de subir nada).

### Los 17 `AlertDialog` del juego

Todos pasan ahora por dos piezas nuevas: `BotonDialogoPrincipal` y
`BotonDialogoSecundario` (`shared/estilo.dart`). Por dentro siguen siendo
`FilledButton`/`TextButton` de Material — el tamaño se deja al de Material
a propósito, porque una fila de acciones de diálogo es compacta y pegada a
la esquina, no un botón a todo lo ancho como los de una pantalla — y lo
único que añaden es la mayúscula, que el tema no puede forzar por sí solo
porque depende del texto de cada `Text`.

Las acciones destructivas ("Borrar", "Despedir") usan `Estilo.de(context).mal`
en vez de `Theme.of(context).colorScheme.error`, para que el rojo sea
exactamente el mismo en todo el juego.

**Confirmado el error de la tanda anterior sobre mayúsculas**, con un caso
más: el nombre de un entrenador en su diálogo de oferta (`Text(e.nombreFicticio)`)
es un nombre propio — como los de club y jugador, va en mayúsculas — y se
me había quedado sin tocar.

### La tarjeta de próximo partido

Va lo primero en el menú principal, antes que la de efectos de vestuario:
rival, si es en casa o fuera, la fecha, y un botón para simular sin salir
del hub. Solo se enseña si hay un partido pendiente — con la temporada
regular completa, o durante playoffs (que no tienen fila en
`PartidosCalendario`), desaparece sola, igual que la de efectos.

Reutiliza el mismo camino que "Simular 1 partido" del Calendario
(`simularHastaConDialogo`), sin diálogo de confirmación: apunta a un único
partido concreto y no hay nada que decidir. Si el partido se juega de
verdad, empuja directo a `ResumenSimulacionScreen`, como en cualquier otro
sitio del juego.

**Un bug real, cazado por el test que se escribió para esta tarjeta y no
por mí mirando el código:** el callback `onSimulado`, que recarga el
estado del hub tras simular, estaba escrito `setState(() => _estadoFuture
= _cargarEstado())`. La flecha hace que el argumento de `setState` sea el
valor de la propia asignación —el `Future` de `_cargarEstado()`—, y
`setState` revienta con "callback argument returned a Future". Es
exactamente el fallo que el comentario de `didPopNext`, dos pantallas más
abajo en el mismo fichero, ya advertía por escrito. Lo arreglé mal la
primera vez (puse el cuerpo del callback *externo* en bloque, pero dejé la
flecha en el que se le pasa a `setState` por dentro) y el test lo volvió a
cazar. Arreglado copiando el patrón exacto de `didPopNext`: bloque también
dentro de `setState`.

Cuatro claves de i18n nuevas en los siete idiomas (`proximoPartidoTitulo`,
`enCasaLabel`, `fueraLabel`, `vsAbreviatura`). Al escribirlas se rompió el
fichero francés por un apóstrofe sin escapar (`'À l'extérieur'`) — se
evitó el problema pasando esa cadena a comillas dobles en vez de pelearse
con el escape.

Test nuevo dedicado, `tarjeta_proximo_partido_test.dart`: que la tarjeta
enseña el rival y el rótulo correcto de casa/fuera, que desaparece sin
partidos pendientes, y que tocar "Simular" de verdad simula y actualiza el
récord sin salir del menú (comparando el número de partidos jugados antes
y después, no una cifra fija).

Verificación: `flutter analyze` limpio, **509 tests en verde** (3 nuevos de
la tarjeta) y la web compila.

## Lista bugs/mejora 12 (a 2026-08-20, de `lista_bugs_mejora_12.txt`)

Por orden de más a menos importante:

1. **Ofertas de traspaso**: cuando llega una oferta por un jugador, quitar
   las estadísticas de la temporada (puntos, asistencias, rebotes) de la
   vista asociada a esa oferta.
2. **Barra de simulación**: sustituir la barra horizontal indeterminada por
   una barra de progreso segmentada. Partido a partido: cada segmento en
   verde o rojo según victoria/derrota. Temporada completa: 82 segmentos
   que se rellenan progresivamente.
3. **Calendario**: en la celda de cada día, solo el número del día; quitar
   el sufijo/prefijo que solo aparece en el ordenador (no en el móvil).
4. **UI equipos/medias**: el color del cuadradito de media debe ser
   siempre el mismo, independientemente de la media. Los nombres de las
   ciudades deben mantener color legible en modo claro y oscuro.
5. **Tema por defecto**: modo oscuro al abrir el juego por primera vez,
   salvo que ya exista una preferencia guardada (si la última vez se dejó
   en claro, se respeta).
6. **Vista de escritorio**: la información del equipo aparece a la
   izquierda; tiene que ir arriba, como en el móvil.

## Lista bugs/mejora 12: los seis puntos, completos (a 2026-08-20)

Los seis puntos de `lista_bugs_mejora_12.txt` (registrada más arriba) están
hechos, con `flutter analyze` limpio y la suite completa en verde (512
tests). **Nada de esto está commiteado** — sigue en el árbol de trabajo,
esperando la instrucción de subir.

### Punto 1 — ofertas de traspaso sin estadísticas

La firma de `lineaJugadorOferta` en los siete idiomas perdió
`pts`/`ast`/`reb`; ahora es `(nombre, posicion, media, contrato)`. Cambiado
el único sitio que la llama, `_lineaJugador` en `ofertas_screen.dart`.

### Punto 2 — barra de progreso segmentada

- `BarraProgresoSimulacion` en `lib/shared/estilo.dart`: una fila de
  `Expanded` (uno por partido), verde/rojo para los ya resueltos, gris
  (`e.lineaFuerte`) para los pendientes. No depende del ancho — cabe igual
  82 segmentos que 1.
- `simularHastaConDialogo` (`lib/features/calendario/simulacion_ui.dart`)
  gana un parámetro opcional `onProgreso` que se llama tras cada tramo
  semanal con lo acumulado hasta ese punto. **La granularidad real es por
  semana, no por partido individual** — no hay enganche al motor de
  simulación para saber cuándo se resuelve cada partido suelto dentro de
  un tramo, así que la barra avanza a saltos (uno por semana simulada), no
  partido a partido de verdad. Decisión a propósito para no reescribir el
  bucle de simulación (una única transacción por tramo) — documentado en
  el comentario del propio parámetro.
- Nueva función `partidosPendientesHasta(partidos, diaObjetivo)` en
  `simulacion_ui.dart`, para saber de antemano cuántos segmentos pintar.
- Conectado en `calendario_screen.dart` y `resumen_simulacion_screen.dart`.
  **No** se ha tocado la tarjeta de próximo partido del hub — ahí siempre
  es 1 solo partido, y un "segmento" no aporta nada.
- `test/barra_progreso_simulacion_test.dart`: tres tests, los tres en
  verde. El tercero (tocar "1 SEMANA" en el Calendario) NO comprueba el
  fotograma a medio simular porque es una carrera con la base en memoria
  (a veces la simulación de la semana entera resuelve dentro de un solo
  `pump()`, a veces no) — solo se comprueban invariantes deterministas:
  la barra no está antes de simular, no está después de asentarse, y el
  récord de victorias+derrotas subió.

### Punto 3 — celda del calendario sin sufijo en escritorio

`_CeldaDia` en `calendario_screen.dart` pintaba, en tamaño no compacto
(escritorio/tablet ancho), `"$dia ${diaSemanaAbrev}"` — el nombre del día
repetido junto al número, cuando ya está en la cabecera de la columna.
Ahora siempre pinta solo `"$dia"`, en cualquier tamaño.

### Punto 4 — color uniforme de la placa de media + legibilidad de ciudad

- `Estilo` perdió el sistema de tramos (`TramoDeMedia`, `tramos`,
  `placaDeMedia`) y ganó dos campos fijos, `placaFondo`/`placaTexto`, uno
  por tema. `PlacaMedia` los usa directamente: el cuadradito de media
  tiene ahora el mismo color siempre, sea cual sea la cifra dentro.
  `test/tema_claro_y_oscuro_test.dart` actualizado al nuevo API.
- Nombre de ciudad ilegible: en `team_selector_screen.dart`, el texto de
  la ciudad usaba `acentoDeEquipo(...)` — pensado para leerse ENCIMA del
  color primario del club (la franja de arriba de la tarjeta) — pero el
  texto en sí vive más abajo, sobre el panel neutro de la tarjeta. Un
  segundo color de club oscuro se perdía en modo oscuro y uno claro en
  modo claro. Cambiado a `colorLegibleComoTexto(info.colorSecundario,
  context)`, que sí ajusta legibilidad contra el tema activo (ya existía
  y se usa igual en `home_hub_screen.dart`/`clasificacion_screen.dart`).
  Los demás sitios que usan `acentoDeEquipo` para el nombre de ciudad
  (`home_hub_screen.dart`, `team_preview_screen.dart`,
  `roster_config_screen.dart`) están bien tal cual: ahí el texto sí va
  encima de la franja de color primario, que es para lo que está pensada
  esa función.

### Punto 5 — modo oscuro por defecto

`leerModoOscuro` (`ajustes_repository.dart`) devolvía `false` cuando no
había fila de ajustes guardada (primera vez). Ahora devuelve `true`. La
columna `modoOscuro` en `tables.dart` también cambió su `withDefault` a
`true`, para que una fila creada indirectamente (p. ej. al guardar solo el
idioma, sin haber tocado nunca el tema) no cuele un `false` por el
default SQL de la tabla en vez del nuevo default de la app — ambos
tienen que coincidir. En cuanto hay una preferencia explícita guardada
(`guardarModoOscuro`), esa manda, sea clara u oscura.
`test/ajustes_screen_test.dart` actualizado: el test que tocaba el switch
esperaba que arrancara en claro y pasara a oscuro con un toque; ahora
arranca en oscuro (nada guardado) y un toque lo deja en claro.

### Punto 6 — layout de escritorio: identidad arriba, no a la izquierda

`_anchoDeEscritorio` en `home_hub_screen.dart` ponía la identidad del
club (`_PanelIdentidad`) en una columna fija de 396px a la izquierda, con
el menú a la derecha. Ahora usa `_CabeceraEquipo` — el mismo widget que ya
usa el layout de móvil/tablet — arriba de un único `CustomScrollView`,
igual que en móvil pero con más columnas por fila en las rejillas (4/3 en
vez de 2-4/1-2). `_PanelIdentidad`, `_MarcadorVertical` y `_BotonFantasma`
quedaron sin ningún uso tras el cambio y se borraron enteros (eran
exclusivos de ese layout de columna).

### Verificación

`flutter analyze` limpio y `flutter test` completo en verde (512 tests,
confirmado dos veces tras los seis puntos). No se pudo hacer una
comprobación visual con capturas de pantalla en el navegador de
previsualización en esta sesión —la herramienta de captura no compone
frames cuando el panel del navegador no está siendo mostrado activamente
al usuario, algo fuera de mi control en un turno automático—, así que la
verificación de estos dos cambios de layout (puntos 3 y 6) se apoya en
`tema_claro_y_oscuro_test.dart`, que monta tanto `CalendarioScreen` como
`HomeHubScreen` en modo claro y oscuro y en los tres tamaños (móvil,
tablet, escritorio 1600×900) comprobando que no haya overflow ni
excepciones, más la revisión directa del código. Queda pendiente que el
usuario le eche un ojo en `flutter run` cuando pueda.

### Nota sobre el falso cuelgue de `CalendarioScreen` (ya resuelto)

Antes de terminar estos cuatro puntos, un test de diagnóstico pareció
demostrar un cuelgue infinito real de `CalendarioScreen` al montarlo con
una franquicia recién creada (`pumpAndSettle()` que no terminaba nunca).
**Era ruido del entorno, no un bug del calendario.** Cortar `flutter test`
varias veces con timeouts de shell en vez de matar el proceso por PID
había dejado procesos `dart.exe`/`flutter_tester.exe` huérfanos
acumulados, uno de los cuales tenía bloqueado `sqlite3.dll`. Comprobado
con `Get-Process`: CPU acumulada casi cero pese a minutos de "cuelgue"
(síntoma de bloqueo, no de trabajo lento), y tras matar los procesos
huérfanos y repetir exactamente la misma prueba en un entorno limpio,
todo terminó en 2-3 segundos sin ningún cuelgue. El fallo real y rápido
que sí apareció después en el test 3 de `barra_progreso_simulacion_test`
era una carrera de la propia base en memoria (ver punto 2, arriba), ya
arreglada.

### Aviso operativo: procesos huérfanos de `flutter test` en Windows

Pasó dos veces en esta sesión: si se corta un `flutter test` con un
timeout externo (del propio Bash tool o de un `timeout` de shell) en vez
de dejar que termine o usar `run_in_background`, en Windows puede dejar
`dart.exe` y/o `flutter_tester.exe` vivos de fondo, y uno de ellos se
queda con `build
ative_assets\windows\sqlite3.dll` bloqueado. El
síntoma es "Flutter failed to delete file at ...sqlite3.dll" al arrancar
el SIGUIENTE `flutter test`, aunque ese test no tenga nada que ver.

**El arreglo es siempre el mismo:**
```
tasklist //FI "IMAGENAME eq dart.exe"
tasklist //FI "IMAGENAME eq flutter_tester.exe"
taskkill //F //PID <el que aparezca>
```
Y si hay que cortar un test que parece colgado, mejor lanzarlo con
`run_in_background: true` y matarlo por PID después de confirmarlo, no
con un `timeout` de shell que corta el proceso padre pero no siempre
arrastra al hijo.

### Siguiente paso al retomar

La lista `lista_bugs_mejora_12.txt` está completa (los seis puntos, ver
arriba). Lo que queda es del usuario, no del código:

1. Probar de verdad en `flutter run` — sobre todo los puntos 3 y 6
   (cambios de layout), que no se pudieron verificar con captura de
   pantalla en esta sesión.
2. Decidir si se sube. Si sí: `git add` de los ficheros de abajo y
   commit; si el mensaje debe repartirse en varios commits (uno por
   punto, por ejemplo) o ir todo junto, es decisión del usuario.

### Ficheros modificados por la lista 12

Superado por la lista 13, que sigue trabajando sobre el mismo árbol sin
commitear. Ver el listado completo y actualizado de ficheros al final de
este documento, en "Ficheros modificados ahora mismo (listas 12 y 13,
sin commitear)".

Último commit subido: `2b1ae0d` ("Diálogos con el estilo del rediseño y
tarjeta de próximo partido"). Todo lo de arriba es posterior y no se ha
subido.

## Lista bugs/mejora 13 (a 2026-08-20, de `lista_bugs_cambios_nba_manager_13.txt`)

Por orden de más a menos importante:

1. **Traspasos, restricciones reales**: un jugador recién fichado no puede
   ser traspasado inmediatamente. Informarse y aplicar las restricciones
   de tiempo reales de la NBA.
2. **Hall of Fame (entrada)**: en la lista, junto al nombre solo el año de
   entrada — nada de temporadas ni promedios ahí (eso va dentro de la
   ficha del jugador).
3. **Ofertas de traspaso manuales**: al buscar un traspaso a mano, debe
   verse la misma información que en una oferta automática de la máquina.
4. **Agencia libre**: quitar el botón "Todos" visible; por defecto se
   muestran todos al entrar, y si se selecciona una posición y luego se
   quita, vuelve solo a "todos". Además, el texto de los botones de
   posición más corto para que el botón de pagar/negociar se vea claro.
5. **Sexto hombre**: añadir su selección, igual que ya existe para
   estrella de ataque y estrella defensiva.
6. **Pantalla "se retiran"**: simplificar el texto — quitar frases largas
   tipo "se retira con 43 años" y dejar solo "43 años".
7. **Estadísticas de jugador**: quitar ataque/defensa individual de cada
   jugador; solo se mantiene el ataque/defensa general del equipo.
8. **Simulación pausada + ofertas**: al terminar de revisar todas las
   ofertas que pausaron la simulación, la ventana se cierra sola y vuelve
   al Calendario.
9. **Patrocinios**: reducir el dinero ofrecido en los popups (6M o 3M es
   demasiado).
10. **Salarios de jugadores**: ajustar lo que piden en los contratos — no
    es normal que jugadores de media alta pidan tan poco dinero.
11. **All-Star**: rediseñar los logos de equipo del All-Star, las letras
    no caben dentro del logo actual.

## Lista bugs/mejora 13: los once puntos, completos (a 2026-08-21)

Los once puntos de arriba están hechos, con `flutter analyze` limpio en los
dos paquetes (app + sim_engine) y la suite completa en verde. **Nada de
esto está commiteado** — sigue en el árbol de trabajo, esperando permiso
para subir.

### Punto 1 — restricciones reales de traspaso

Se ha modelado UNA restricción real de la NBA, la que de verdad se nota al
jugar: un agente libre recién fichado no se puede traspasar hasta pasados
tres meses (regla real: tres meses desde la firma). No se ha intentado
modelar el reglamento entero de traspasos de la NBA (derechos de tanteo,
sign-and-trade, la regla de los mayores de 38, etc.) — es un reglamento
enorme y la mayoría de esas reglas nunca se notarían jugando.

- `Jugadores` gana `fechaFichaje` (nullable; null = nunca ha fichado como
  agente libre, así que sin restricción — importados, drafteados y
  renovados con su propio equipo se quedan así). Schema 24→25.
- Nuevo fichero `lib/domain/restriccion_de_fichaje.dart`:
  `diasMinimosTrasFichaje = 90` y `restriccionDeFichajeReciente(jugador,
  fechaActual)`.
- `MercadoDeTraspasos` (traspasos_repository.dart) gana `fechaActual`,
  cargada una vez con el resto del mercado. La restricción se comprueba
  dentro de `evaluarMultipleEnMercado`, en el mismo punto donde se resuelve
  cada jugador del movimiento — así cubre a la vez la mesa de traspasos
  manual, el buscador automático y las ofertas entrantes de la CPU (todas
  pasan por ahí). También se añadió a `traspasos_cpu_repository.dart` (los
  intercambios que la CPU cierra sola en pretemporada).
- `agencia_libre_repository.dart` rellena `fechaFichaje` en `ficharAgenteLibre`
  y en la rama aceptada de `ofrecerContratoFichaje`, con la fecha de LA
  LIGA (`fechaActualDeLaLiga`, no `DateTime.now()`).
- Tests en `test/traspasos_avanzados_test.dart` (grupo nuevo "restricción de
  fichaje reciente"): bloqueo antes de los 3 meses, vía libre después, y
  que fichar por agencia libre dispara la restricción de inmediato.

### Punto 2 — Hall of Fame: solo el año

`_FilaMiembro` en `hall_fama_screen.dart` ya no pinta una segunda línea con
temporadas/promedios — solo el año de entrada, siempre, tenga o no carrera
archivada. Los números siguen a un toque, en la ficha
(`CarreraJugadorScreen`). Se borró `_tieneNumeros` (sin uso) y el método de
i18n `statsCarreraSufijo` de los 8 idiomas (sin uso tras el cambio). Test
de `legado_pantallas_test.dart` reescrito para la nueva regla (antes solo
comprobaba el caso "recién inducido"; ahora comprueba que NADIE lleva
promedios en la lista).

### Punto 3 — ofertas manuales = misma información que las automáticas

`HojaDePropuestas` (el buscador automático de traspasos) mostraba nombre +
posición + media + EDAD (`jugadorConFicha`); las ofertas entrantes de la
CPU mostraban nombre + posición + media + CONTRATO (`lineaJugadorOferta`).
Se unificó todo en el segundo formato (contrato, no edad — es lo que de
verdad hace falta para juzgar un traspaso, según ya explicaba el propio
comentario de `ofertas_screen.dart`). Nueva función compartida
`contratoEnUnaLinea` en `lib/shared/hoja_de_propuestas.dart`, usada por los
dos sitios. Se borró `jugadorConFicha` de los 8 idiomas (sin uso).

### Punto 4 — Agencia Libre: sin botón "Todos" y texto más corto

- `_Filtros` ya no tiene el chip "Todos": sin filtro ya se ven todos por
  defecto, y tocar un puesto ya seleccionado lo destoca (`onPosicion(posicion
  == p ? null : p)`) en vez de necesitar un botón aparte.
- El filtro "Que pueda pagar" se acortó a una palabra en los 7 idiomas
  (ES "Asequible", EN "Affordable", etc.) para que la fila entera de chips
  quepa sin cortarse.
- Se borró `todosFiltro` de los 8 idiomas (sin uso).
- Test nuevo `test/agencia_libre_filtros_test.dart`. Ojo con la lección
  aprendida aquí: la lista de agentes libres es un `ListView`, así que
  contar `find.byType(FilaDeJugador)` solo cuenta lo que cabe en el
  viewport, no el total filtrado — el test se reescribió para leer el
  contador de texto ("N de 100 agentes libres (hay filtros puestos)"), que
  sí refleja el estado real.

### Punto 5 — sexto hombre

Se ha añadido igual que estrella de ataque/defensa, pero restringido a
suplentes (un titular no puede ser sexto hombre por definición):

- `RotacionJugador` gana `esSextoHombre`. Schema 25→26.
- `sim_engine`: `JugadorEnPartido.esSextoHombre`, `EquipoPartido` valida
  como mucho uno, y en `_statsEquipo` (simulador_partido.dart) da el MISMO
  empujón individual al reparto de puntos que la estrella de ataque
  (`multiplicadorEstrellaIndividual`, con un `||` para no doblar el efecto
  si coincidiera con la estrella) — sin tocar el rating de equipo, que es
  cosa de las estrellas, no del sexto hombre.
- `generarRotacionAutomatica` (franquicia_repository.dart) elige como
  sexto hombre al mejor de los 5 suplentes, igual que ya elegía a las dos
  estrellas entre titulares y suplentes — así los 29 equipos de la CPU
  también salen con el suyo (`generarAlineacionAutomatica` en
  `alineacion_automatica.dart`, actualizado igual).
  `repararRotacion` conserva la designación solo si el jugador sigue
  siendo suplente tras el arreglo.
- UI: `_SelectorEstrellas` en `roster_config_screen.dart` gana un tercer
  desplegable (options = solo suplentes), con su propio color
  (`colorSextoHombre`, morado) y se apilan en vertical en pantallas
  estrechas (`LayoutBuilder`, antes 2 columnas fijas).
- Tests: `sim_engine/test/simulacion_test.dart` (rechaza más de uno; anota
  más que un compañero igual), `test/franquicia_repository_test.dart`
  (siempre suplente, siempre el mejor de los 5, viaja hasta
  `construirEquipoUsuarioParaFecha`), `test/sexto_hombre_test.dart`
  (widget: alinear automáticamente + guardar lo deja en la rotación).
- Bug encontrado y arreglado de camino: `generarRotacionAutomatica` dejaba
  `esSextoHombre` AUSENTE (no `false`) en la fila del titular — leer
  `.value` sobre un campo ausente revienta con "type 'Null' is not a
  subtype of type 'bool'". Ahora va explícito a `false`.

### Punto 6 — pantalla "se retiran": solo la edad

`_FilaRetirado` en `retirados_screen.dart` ya no usa
`seRetiraConEdadYMedia` (borrado de los 8 idiomas): ahora compone el
detalle a mano con la función que YA existía para esto,
`t(context).edadJugador(cambio.edad)` — "$procedencia · $edad años$aviso".
La media no se repite en texto: ya sale como placa al lado (`FilaDeJugador`),
tal y como decía el propio comentario del código.

### Punto 7 — sin ataque/defensa individual de jugador

Se borró la clase `MediasAtaqueDefensa` entera de `medias_jugador.dart`
(colorAtaque/colorDefensa/mediasDe se quedan — los usa la franja de
equipo). Sus tres usos (`agencia_libre_screen.dart`,
`roster_config_screen.dart`, `team_preview_screen.dart`) se simplificaron
para no mostrar ATA/DEF de cada jugador. El ataque/defensa de EQUIPO
(`_FranjaAtaqueDefensa` en roster_config_screen.dart) no se ha tocado —
sigue mostrando la media del quinteto y de la rotación entera, que es lo
que pedía conservar el punto.

Ojo: `atrAtaque`/`atrDefensa` de ENTRENADOR (`entrenador_screen.dart`,
`team_preview_screen.dart`) es un concepto distinto (estilo de entrenador)
y no se ha tocado — el punto habla de jugadores, no de entrenadores.

### Punto 8 — la bandeja de ofertas se cierra sola

`OfertasScreen` gana `cierraSolaAlVaciarse` (default `false`, para no
cambiar el comportamiento de "Ofertas recibidas" desde el menú — ahí es
una consulta voluntaria y no debe echarte fuera si vacías la bandeja).
Activado a `true` solo en la llamada desde `simulacion_ui.dart`
(`_avisarDeOfertasEntrantes`), que es la que pausa la simulación. Al
resolver la última oferta pendiente en una recarga (no en la carga
inicial: `_ofertas != null` marca que ya hubo una carga antes), hace
`Navigator.pop()` solo. Test nuevo
`test/ofertas_cierre_automatico_test.dart`, con las dos variantes
(cierra sola / no cierra sola) montadas sobre una navegación real para
poder comprobar qué pantalla queda encima.

### Punto 9 — patrocinios: menos dinero

Bajado dos veces por feedback directo. Primera pasada: `_bastanteDinero`
6M→4M y `_algoDeDinero` 3M→2,5M. El usuario pidió bajarlo más (a
2026-08-21): ahora `_bastanteDinero`=3M y `_algoDeDinero`=1,5M —por debajo
del salario mínimo (2,3M) a propósito, el dinero de un patrocinio es sabor
de un diálogo, no algo pensado para desbloquear un fichaje por sí solo.
Afecta a `acto_publicitario` (el patrocinio en sí) y de paso a
`partido_benefico`, que reutiliza las mismas constantes.
`_multaFuerte` (-4M) no se ha tocado: el punto hablaba de dinero OFRECIDO,
no de multas.

El segundo bajón rompió un test que asumía justo lo contrario
(`el dinero de un evento da al menos para un contrato mínimo`, en
`test/eventos_narrativos_test.dart`): esa era la regla vieja, y ahora es
al revés a propósito. Reescrito como
`el dinero de un evento es un extra puntual, no una fortuna` — comprueba
que nadie se ha ido de madre por ARRIBA (`<= salarioMinimo * 2`), no que
llegue a un mínimo.

### Punto 10 — salarios: el bug real estaba en el descuento por edad

Antes de tocar nada se comprobó con un test de diagnóstico contra el
dataset real qué pedían de verdad los jugadores top: los VETERANOS de
media alta ya piden mucho (Doncic 98 → 70M, el techo). El bug de verdad
estaba en jugadores JÓVENES de media alta: `salarioEstimado` aplicaba un
descuento por edad (0,45x a 22 años o menos, 0,7x a 23-24) pensado para
"todavía en contrato de rookie", pero se aplicaba igual a un chaval de 22
años que YA es una media de 87 — un jugador así pedía 14,8M, MENOS que un
rotación cualquiera de 30 años con 75 de media. Subidos a 0,65x/0,85x en
`salarios.dart`: el descuento se mantiene (un veterano igual sigue
cobrando más que un joven) pero ya no se desmiente a sí mismo. Test nuevo
en `test/datos_reales_test.dart` que fija exactamente este caso: un 22
años de 87 tiene que pedir más que un 30 años de 75.

Se intentó primero bajar el umbral de "a partir de aquí es una estrella y
no te la regalan por el mínimo" (`_mediaDeEstrellaQueFichasTu`, agencia
libre) de 82 a 78, pensando que el problema estaba ahí — pero
`test/tu_equipo_no_se_descuelga_test.dart` (cinco veranos sin tocar nada
tienen que dejarte mediocre, no hundido) empezó a fallar: ese umbral está
calibrado a propósito para que la red de seguridad de "completar plantilla
con el mínimo" pueda rescatar tu equipo si lo abandonas. Revertido sin
tocar — el bug real estaba en otro sitio, como se ve arriba.

### Punto 11 — logos del All-Star: el texto ya se encoge para caber

`PlacaEquipo` (estilo.dart), el escudo compartido de todo el juego, pinta
el `codigo` tal cual como texto a tamaño fijo. Para las 30 franquicias
siempre son 3 letras y cabía de sobra, pero el All-Star reutiliza el MISMO
widget para sus "equipos" especiales (Este, Oeste, Novatos, Sophomores —
ver `equipos_info.dart`), cuyo "código" es la palabra entera: "Sophomores"
se salía del escudo por completo. Envuelto en un `FittedBox(fit:
BoxFit.scaleDown)` con un pelín de padding: los códigos de 3 letras no
cambian (ya cabían, FittedBox no los toca), y cualquier palabra más larga
se encoge lo justo para caber. Test nuevo `test/placa_equipo_test.dart`.

### Verificación

`flutter analyze` limpio en `app/manager_nba` y en `app/packages/sim_engine`.
`dart run build_runner build` corrido dos veces (schema 24→25 por el punto
1, 25→26 por el punto 5) sin conflictos. Suite completa de la app y de
sim_engine en verde.

### Ficheros modificados (listas 12, 13 y patrocinadores)

Ver el listado completo y actualizado al final de este documento — se
quedó desfasado aquí en cuanto se sumó el sistema de patrocinadores, así
que no se duplica.

Último commit subido: `2b1ae0d` ("Diálogos con el estilo del rediseño y
tarjeta de próximo partido"). Todo lo de arriba es posterior y no se ha
subido. Nada se sube sin que el usuario lo pida explícitamente.

## Patrocinadores (a 2026-08-21, pedido fuera de las dos listas)

Sistema nuevo, no de ninguna lista de bugs: el usuario dejó una carpeta en
el escritorio (`Desktop/MANAGER NBA/`) con un PDF de historias de marca
ficticias para 20 ciudades (15 patrocinadores por ciudad, con nombre, año
de fundación y anécdota) y una hoja de logos por ciudad (imagen única de
15 logos juntos por ciudad — no son assets recortables uno a uno, así que
no se han usado como imagen; el juego sigue sin bitmaps, todo vectorial/
iconos como el resto del rediseño). Se pidió: patrocinadores que se eligen
al principio de cada temporada, dan millones para la masa salarial, y se
pueden elegir varios a la vez (el del estadio, el de las camisetas, el del
parque, etc.).

### Diseño

Cuatro categorías fijas por equipo (`estadio`, `camiseta`, `bebida`,
`ocio`), un candidato por categoría — la decisión real es QUÉ categorías
activas, no con quién de cada una (más simple que modelar pujas entre 15
empresas por ciudad, y ya cumple "puedes elegir varios patrocinadores").
Bonus fijo por categoría (no por empresa): estadio 2,5M, camiseta 3M,
bebida 1,5M, ocio 1M — hasta 8M/temporada si activas las cuatro. Se
reeligen cada año, no se heredan solos.

- `lib/domain/patrocinadores.dart`: catálogo const, 120 entradas (30
  equipos × 4 categorías). Los 21 equipos de las 20 ciudades que cubre el
  PDF (Los Ángeles reparte su lista entre LAL y LAC) usan datos reales del
  PDF; los 9 que quedan fuera (ATL, BOS, BRK, CHI, CHO, DAL, DEN, DET,
  OKC) llevan cuatro patrocinadores inventados en la sesión, mismo estilo
  (nombre, año, anécdota atada a un sitio real de la ciudad). Las
  historias se quedan en español — mismo criterio ya aplicado a
  `eventos_narrativos.dart`, que sigue pendiente de traducir.
- Tabla nueva `PatrociniosActivos` (categoria, sin columna de equipo — es
  siempre el tuyo, igual que `RotacionJugador`). Schema 26→27.
- `lib/domain/patrocinadores_repository.dart`: leer/activar-desactivar/
  bonus/limpiar. El bonus se sube a `espacioSalarial`
  (`contratos_repository.dart`), acumulado con el de los eventos
  narrativos, no en su lugar.
- Se limpian en `nuevaFranquicia` (equipo nuevo) y en
  `empezarNuevaTemporada` (cada cambio de año) — hay que volver a
  elegirlos siempre.
- Pantalla nueva `PatrocinadoresScreen`
  (`lib/features/temporada/patrocinadores_screen.dart`): cuatro tarjetas
  con interruptor, nombre, año, historia y el bonus de esa categoría, más
  el margen total abajo. Enganchada en `cambio_de_temporada.dart` justo
  después del Hall of Fame y ANTES de renovaciones (el margen tiene que
  estar puesto antes de decidir en qué gastarlo), y en
  `start_menu_screen.dart` para el año 1, después de guardar la rotación
  inicial y antes de entrar al hub.
- i18n: el título, la explicación y las cuatro etiquetas de categoría
  están en los 8 idiomas. Los nombres y las historias de las empresas, no
  (ver nota de arriba).

### Bug real encontrado con los tests, no a ojo

`alternarPatrocinio` usaba `insertOnConflictUpdate`, que en drift hace el
upsert sobre la CLAVE PRIMARIA (`id`, autoincremental) y no sobre la
columna con la restricción UNIQUE (`categoria`) — con un `id` nuevo cada
vez, el conflicto de verdad (dos filas con la misma categoría) nunca lo
detectaba el upsert y saltaba como error de SQLite en vez de actualizar.
Arreglado borrando la fila de esa categoría antes de insertar, en vez de
confiar en el upsert. Lo cazó el segundo test que activaba la misma
categoría dos veces seguidas — exactamente lo que hace un usuario real al
tocar un interruptor, cambiar de opinión, y tocarlo otra vez.

También se rompió `test/flujo_completo_test.dart` (el test de extremo a
extremo: menú → onboarding → alineación → calendario → simulación), que
no sabía que ahora hay una pantalla nueva de por medio entre guardar la
rotación inicial y llegar al menú principal. Arreglado añadiendo el paso
que faltaba: esperar a "Patrocinadores" y tocar "Continuar" sin elegir
ninguno, antes de seguir esperando a "CALENDARIO". Recordatorio para la
próxima vez que se toque el flujo de onboarding: este test cubre el
camino entero de verdad, así que cualquier pantalla nueva insertada ahí
hay que enseñársela a él también.

### Verificación

`flutter analyze` limpio. Tests nuevos: `test/patrocinadores_test.dart`
(el catálogo: los 30 equipos reales tienen las cuatro categorías, ni
repetidas ni de más, sin historias vacías, sin años absurdos),
`test/patrocinadores_repository_test.dart` (activar/desactivar, el bonus
suma bien, llega a `espacioSalarial` solo para tu equipo, se limpia en
franquicia nueva), `test/patrocinadores_screen_test.dart` (las cuatro
tarjetas se ven, activar/desactivar por la UI persiste de verdad —
incluido el caso que cazó el bug de arriba). Suite completa de la app
corriendo para confirmar que no rompe nada del resto.

### Ficheros modificados ahora mismo (listas 12, 13 y patrocinadores — sin commitear)

```
 M app/manager_nba/lib/data/database/app_database.dart
 M app/manager_nba/lib/data/database/app_database.g.dart
 M app/manager_nba/lib/data/database/tables.dart
 M app/manager_nba/lib/domain/agencia_libre_repository.dart
 M app/manager_nba/lib/domain/ajustes_repository.dart
 M app/manager_nba/lib/domain/contratos_repository.dart
 M app/manager_nba/lib/domain/eventos_narrativos.dart
 M app/manager_nba/lib/domain/franquicia_repository.dart
 M app/manager_nba/lib/domain/nueva_temporada_repository.dart
 M app/manager_nba/lib/domain/salarios.dart
 M app/manager_nba/lib/domain/traspasos_cpu_repository.dart
 M app/manager_nba/lib/domain/traspasos_repository.dart
 M app/manager_nba/lib/features/calendario/calendario_screen.dart
 M app/manager_nba/lib/features/calendario/resumen_simulacion_screen.dart
 M app/manager_nba/lib/features/calendario/simulacion_ui.dart
 M app/manager_nba/lib/features/hub/home_hub_screen.dart
 M app/manager_nba/lib/features/inicio/start_menu_screen.dart
 M app/manager_nba/lib/features/mercado/agencia_libre_screen.dart
 M app/manager_nba/lib/features/mercado/ofertas_screen.dart
 M app/manager_nba/lib/features/partido/alineacion_automatica.dart
 M app/manager_nba/lib/features/roster/roster_config_screen.dart
 M app/manager_nba/lib/features/roster/team_preview_screen.dart
 M app/manager_nba/lib/features/roster/team_selector_screen.dart
 M app/manager_nba/lib/features/temporada/cambio_de_temporada.dart
 M app/manager_nba/lib/features/temporada/hall_fama_screen.dart
 M app/manager_nba/lib/features/temporada/retirados_screen.dart
 M app/manager_nba/lib/i18n/textos.dart (+ los 7 idiomas)
 M app/manager_nba/lib/shared/estilo.dart
 M app/manager_nba/lib/shared/hoja_de_propuestas.dart
 M app/manager_nba/lib/shared/medias_jugador.dart
 M app/manager_nba/test/ajustes_screen_test.dart
 M app/manager_nba/test/datos_reales_test.dart
 M app/manager_nba/test/eventos_narrativos_test.dart
 M app/manager_nba/test/flujo_completo_test.dart
 M app/manager_nba/test/franquicia_repository_test.dart
 M app/manager_nba/test/legado_pantallas_test.dart
 M app/manager_nba/test/tema_claro_y_oscuro_test.dart
 M app/manager_nba/test/traspasos_avanzados_test.dart
 M app/packages/sim_engine/lib/src/models/equipo_partido.dart
 M app/packages/sim_engine/lib/src/models/jugador_en_partido.dart
 M app/packages/sim_engine/lib/src/simulacion/simulador_partido.dart
 M app/packages/sim_engine/test/simulacion_test.dart
 M docs/plan.md
?? app/manager_nba/lib/domain/patrocinadores.dart
?? app/manager_nba/lib/domain/patrocinadores_repository.dart
?? app/manager_nba/lib/domain/restriccion_de_fichaje.dart
?? app/manager_nba/lib/features/temporada/patrocinadores_screen.dart
?? app/manager_nba/test/agencia_libre_filtros_test.dart
?? app/manager_nba/test/barra_progreso_simulacion_test.dart
?? app/manager_nba/test/ofertas_cierre_automatico_test.dart
?? app/manager_nba/test/patrocinadores_repository_test.dart
?? app/manager_nba/test/patrocinadores_screen_test.dart
?? app/manager_nba/test/patrocinadores_test.dart
?? app/manager_nba/test/placa_equipo_test.dart
?? app/manager_nba/test/sexto_hombre_test.dart
```

## Eventos narrativos traducidos (a 2026-08-21)

Los "mensajes espontáneos con opciones" — los eventos de vestuario que
saltan durante la simulación — estaban **solo en castellano**, y era el
último trozo de interfaz sin traducir. Ahora están en los siete idiomas.

### El problema de meterlos en `Textos`

El resto de la interfaz vive en `lib/i18n/textos.dart`: una clase abstracta
con un método por texto, precisamente para que el compilador cante si a un
idioma le falta algo. Con el guion de los eventos eso no valía: son **~150
frases** (12 títulos, 12 planteamientos, 30 etiquetas de botón, 30
consecuencias y 42 nombres de efecto). Como métodos abstractos habrían
dejado `Textos` tres veces más larga que todo el resto junto, que es donde
se busca de verdad cuando falta un rótulo.

### Cómo quedó

**El catálogo se quedó sin texto.** `lib/domain/eventos_narrativos.dart`
son ahora solo claves, condiciones y números:

```dart
OpcionDeEvento(
  clave: 'noche_larga',
  efectos: [EfectoDeEvento(clave: 'buen_rollo', factor: _muchoMejor, ...)],
)
```

Eso resuelve de paso un problema que habría aparecido enseguida: si el
guion viviera ahí, cada evento nuevo habría que escribirlo siete veces en
medio de la lógica, y un ajuste de equilibrio (subir un factor, acortar una
racha) obligaría a tocar los siete sitios donde solo cambia una palabra.

**El guion vive aparte**, en `lib/i18n/textos_eventos.dart` más un fichero
por idioma (`eventos_es.dart`, `eventos_en.dart`, ...), enganchado a
`Textos` con un solo miembro nuevo (`TextosDeEventos get eventos`).

**Quién vigila qué**, ya que un mapa no lo puede comprobar el analizador:

- El **compilador** sigue obligando a que cada idioma implemente los dos
  mapas. Un idioma nuevo no compila hasta que estén.
- Un **test nuevo** (`test/eventos_traducidos_test.dart`, 30 casos)
  comprueba lo que el mapa no: que cada evento, cada opción de cada evento
  y cada etiqueta de efecto existan en los siete idiomas; que no sobre
  texto traducido que el catálogo ya no menciona (eso sería una errata en
  una clave, y el texto bueno no se encontraría nunca); y que ningún idioma
  se haya quedado copiado del español a medias.

### La base de datos: los efectos ya no guardan el texto

`EfectosDeEvento` guardaba la etiqueta ya escrita ("Buen rollo en el
vestuario"). Con eso, cambiar de idioma a mitad de temporada dejaba los
efectos activos en el idioma anterior. Ahora se guarda `claveEfecto` y se
traduce al pintar.

Esquema **27 → 28**, aditiva y nullable, como manda la regla desde la 20:
una partida en curso no pierde nada. Las filas viejas no tienen clave —no
hay forma de adivinar a qué efecto del catálogo correspondían—, así que
siguen enseñando su etiqueta guardada, en español; se agotan en unos
partidos y el problema desaparece solo. La columna `etiqueta` se sigue
escribiendo en español como respaldo legible al mirar la base a mano.

### Verificación

- `flutter analyze` limpio.
- Los tres ficheros de eventos: **64 tests en verde** (30 son los de
  traducción, 7 idiomas × 4 comprobaciones más los dos generales).
- Suite completa en verde.

### Ficheros

## Ocho eventos narrativos nuevos (a 2026-08-21)

Con doce eventos y un tope de cinco por temporada, en tres años de carrera
ya los habías visto todos. Estos ocho suben el catálogo a **veinte**.

Separar el guion del catálogo (ver la sección anterior) hizo que esto
costara lo que tenía que costar: el evento se define una vez con sus
claves, sus condiciones y sus números, y luego solo hay que escribirlo.

### Qué cubren que no cubría ninguno de los doce

Los doce primeros eran casi todos de vestuario. Estos meten a los otros
actores del club:

| Evento | Cuándo sale | El eje de la decisión |
| --- | --- | --- |
| `rumor_de_traspaso` | ≥20 partidos | Tranquilizarle relaja al vestuario entero, y eso también quita presión |
| `tanking_de_la_directiva` | vaMal y ≥55 partidos | Dinero y draft contra no dejarte ir |
| `jugador_llega_tarde` | ≥10 partidos | Disciplina contra el ambiente |
| `camiseta_de_una_leyenda` | ≥25 partidos | Taquilla y ciudad contra el día de partido |
| `entrenador_pide_mando` | con entrenador, ≥12 | Rendimiento ahora contra el control del banquillo |
| `metida_de_pata_en_redes` | ≥8 partidos | Defenderle sale caro: la multa la paga el club |
| `precio_de_las_entradas` | vaBien y ≥25 | Dinero contra el ambiente del pabellón |
| `nutricionista` | ≥6 partidos | Gasto ahora contra plantilla mejor a la larga |

El de la directiva y el draft es el que mejor usa el segundo eje: perder a
propósito **paga** y además mejora la elección del draft (que el diálogo no
modela), así que la respuesta depende de si te has creído que este año
todavía se puede.

### Una constante de dinero nueva

`_gastoModerado` (−2M): no es lo mismo una multa que un gasto. La multa
castiga una decisión; el gasto es lo que cuesta algo que has decidido
pagar, y por eso duele menos que hacer el ridículo en público (−4M).

### Verificación

Las reglas de diseño del catálogo son tests, no buenas intenciones, y los
ocho pasan por ellas: ninguna opción se queda sin consecuencia, la mejor de
cada evento paga en piernas o en dinero, y ningún efecto se sale de los
topes medidos. **65 tests en verde** entre los tres ficheros de eventos —
las comprobaciones de traducción son ahora 7 idiomas × 20 eventos.

## Los patrocinadores no hacían nada (a 2026-08-21)

Bug de verdad, encontrado revisando el sistema que se había hecho unas
horas antes: **en una partida ya empezada, los patrocinadores no servían
para nada.**

### Qué pasaba

El cambio de temporada llama a las pantallas por pasos. La de
patrocinadores es el paso **2c**. Pero `finalizarPretemporada` —el paso
**4.5**— llamaba a `limpiarPatrocinios`.

O sea: el juego te hacía elegir patrocinadores, y los borraba dos pasos
después, antes de dejarte gastar el margen en la agencia libre. El margen
llegaba a cero justo donde tenía que servir de algo.

No lo cazó ningún test porque los que había miraban el repositorio por
separado, y `flujo_completo_test.dart` solo pasa por el camino de la
PRIMERA temporada, donde `finalizarPretemporada` no corre después de la
pantalla. Es el punto ciego típico: cada pieza bien y el orden mal.

**El arreglo**: limpiar en `cerrarTemporada`, que corre ANTES de elegir.
De paso se movió también `limpiarEventosDeLaTemporada`, que tenía la misma
trampa esperando. Test nuevo:
`test/patrocinadores_sobreviven_al_cambio_test.dart`, escrito primero para
verlo fallar.

### Y ya puestos: no eran una decisión

Cuatro interruptores que solo dan dinero tienen una respuesta óptima
obvia —encenderlos los cuatro— así que aquello era un botón de cobrar 8M,
no una pantalla de decisiones. Es justo lo que prohíbe la regla de diseño
número 1 de `eventos_narrativos.dart`, escrita para el otro sistema:

> *Toda opción tiene un coste o no es una decisión.*

Ahora cada patrocinio **pide algo a cambio**, como efecto de vestuario de
los primeros partidos, y se ve en su tarjeta al lado del dinero (un coste
que se descubre después de firmar no es una decisión, es una trampa):

| Patrocinio | Paga | Pide |
| --- | --- | --- |
| Camiseta | 3,0M | Días de medios, −2% × 6 partidos |
| Estadio | 2,5M | El pabellón con otro nombre, −1% × 12 |
| Bebida | 1,5M | Compromisos de marca, −1% × 6 |
| Ocio | 1,0M | Trabajo con la ciudad, **+1% × 6** |

Las magnitudes **no** son proporcionales al dinero a propósito: si lo
fueran, la respuesta volvería a ser aritmética (firmar por orden de ratio)
y seguiría sin haber nada que pensar. Así, el de ocio casi no paga pero
suma, y la respuesta correcta depende de algo que la pantalla no sabe: si
te falta espacio para fichar o no.

Los compromisos van a la misma tabla que los efectos de los eventos —para
el jugador es un efecto de vestuario más, venga de una cena de equipo o de
un contrato de camiseta— y se aplican al confirmar, no al tocar cada
interruptor: así puedes probar combinaciones sin dejar rastro. Es
idempotente, y solo borra sus propias filas (`clave = 'patrocinio'`), así
que una bronca de vestuario que estuviera corriendo no se ve afectada.

### Verificación

`flutter analyze` limpio y **47 tests** entre los cuatro ficheros de
patrocinadores y traducción, incluidos los dos que fallaban antes del
arreglo. Suite completa en verde.

```
 M app/manager_nba/lib/data/database/app_database.dart
 M app/manager_nba/lib/data/database/app_database.g.dart
 M app/manager_nba/lib/data/database/tables.dart
 M app/manager_nba/lib/domain/agencia_libre_repository.dart
 M app/manager_nba/lib/domain/ajustes_repository.dart
 M app/manager_nba/lib/domain/contratos_repository.dart
 M app/manager_nba/lib/domain/eventos_narrativos.dart
 M app/manager_nba/lib/domain/eventos_narrativos_repository.dart
 M app/manager_nba/lib/domain/franquicia_repository.dart
 M app/manager_nba/lib/domain/nueva_temporada_repository.dart
 M app/manager_nba/lib/domain/salarios.dart
 M app/manager_nba/lib/domain/traspasos_cpu_repository.dart
 M app/manager_nba/lib/domain/traspasos_repository.dart
 M app/manager_nba/lib/features/calendario/calendario_screen.dart
 M app/manager_nba/lib/features/calendario/resumen_simulacion_screen.dart
 M app/manager_nba/lib/features/calendario/simulacion_ui.dart
 M app/manager_nba/lib/features/hub/home_hub_screen.dart
 M app/manager_nba/lib/features/inicio/start_menu_screen.dart
 M app/manager_nba/lib/features/mercado/agencia_libre_screen.dart
 M app/manager_nba/lib/features/mercado/ofertas_screen.dart
 M app/manager_nba/lib/features/partido/alineacion_automatica.dart
 M app/manager_nba/lib/features/roster/roster_config_screen.dart
 M app/manager_nba/lib/features/roster/team_preview_screen.dart
 M app/manager_nba/lib/features/roster/team_selector_screen.dart
 M app/manager_nba/lib/features/temporada/cambio_de_temporada.dart
 M app/manager_nba/lib/features/temporada/evento_narrativo_dialog.dart
 M app/manager_nba/lib/features/temporada/hall_fama_screen.dart
 M app/manager_nba/lib/features/temporada/retirados_screen.dart
 M app/manager_nba/lib/i18n/textos.dart
 M app/manager_nba/lib/i18n/textos_de.dart
 M app/manager_nba/lib/i18n/textos_en.dart
 M app/manager_nba/lib/i18n/textos_es.dart
 M app/manager_nba/lib/i18n/textos_fr.dart
 M app/manager_nba/lib/i18n/textos_it.dart
 M app/manager_nba/lib/i18n/textos_pt.dart
 M app/manager_nba/lib/i18n/textos_zh.dart
 M app/manager_nba/lib/shared/estilo.dart
 M app/manager_nba/lib/shared/hoja_de_propuestas.dart
 M app/manager_nba/lib/shared/medias_jugador.dart
 M app/manager_nba/test/ajustes_screen_test.dart
 M app/manager_nba/test/datos_reales_test.dart
 M app/manager_nba/test/evento_narrativo_dialog_test.dart
 M app/manager_nba/test/eventos_narrativos_test.dart
 M app/manager_nba/test/flujo_completo_test.dart
 M app/manager_nba/test/franquicia_repository_test.dart
 M app/manager_nba/test/legado_pantallas_test.dart
 M app/manager_nba/test/tema_claro_y_oscuro_test.dart
 M app/manager_nba/test/traspasos_avanzados_test.dart
 M app/packages/sim_engine/lib/src/models/equipo_partido.dart
 M app/packages/sim_engine/lib/src/models/jugador_en_partido.dart
 M app/packages/sim_engine/lib/src/simulacion/simulador_partido.dart
 M app/packages/sim_engine/test/simulacion_test.dart
 M docs/plan.md
?? app/manager_nba/lib/domain/patrocinadores.dart
?? app/manager_nba/lib/domain/patrocinadores_repository.dart
?? app/manager_nba/lib/domain/restriccion_de_fichaje.dart
?? app/manager_nba/lib/features/temporada/patrocinadores_screen.dart
?? app/manager_nba/lib/i18n/eventos_de.dart
?? app/manager_nba/lib/i18n/eventos_en.dart
?? app/manager_nba/lib/i18n/eventos_es.dart
?? app/manager_nba/lib/i18n/eventos_fr.dart
?? app/manager_nba/lib/i18n/eventos_it.dart
?? app/manager_nba/lib/i18n/eventos_pt.dart
?? app/manager_nba/lib/i18n/eventos_zh.dart
?? app/manager_nba/lib/i18n/textos_eventos.dart
?? app/manager_nba/test/agencia_libre_filtros_test.dart
?? app/manager_nba/test/barra_progreso_simulacion_test.dart
?? app/manager_nba/test/eventos_traducidos_test.dart
?? app/manager_nba/test/ofertas_cierre_automatico_test.dart
?? app/manager_nba/test/patrocinadores_repository_test.dart
?? app/manager_nba/test/patrocinadores_screen_test.dart
?? app/manager_nba/test/patrocinadores_test.dart
?? app/manager_nba/test/placa_equipo_test.dart
?? app/manager_nba/test/sexto_hombre_test.dart
```

Último commit subido: `2b1ae0d` ("Diálogos con el estilo del rediseño y
tarjeta de próximo partido"). Todo lo de arriba —las listas 12 y 13
enteras, el sistema de patrocinadores y la traducción de los eventos
narrativos— es posterior y no se ha subido. Nada se sube sin que el
usuario lo pida explícitamente.

## El aviso del campeón se desbordaba en el móvil (a 2026-08-22)

Quedaba apuntado como "fallo encontrado de paso, sin arreglar" al final
del paso 3 de `plan_monetizacion.md`. Ya está arreglado.

**Qué pasaba.** El diálogo de campeón (`shared/campeon_dialog.dart`, el
que sale con la NBA Cup y con el anillo) ponía sus dos botones en un
`Row` a secas. Un `Row` no dobla: lo que no cabe se sale por la derecha
con las rayas amarillas y negras. Medido:

| Caso | Ancho disponible | Se salía |
| --- | --- | --- |
| Campeón otro equipo, móvil de 390 px | 290 px | 92 px |
| **Campeón tú**, móvil de 390 px | 290 px | **205 px** |
| **Campeón tú**, tablet y escritorio | 400 px | **95 px** |

O sea: era peor de lo apuntado. El aviso de "has ganado tú" lleva un
botón más largo (*¡A celebrarlo!* en vez de *Cerrar*) y **se salía en
todos los tamaños**, escritorio incluido, no solo en móviles.

**El arreglo.** `OverflowBar` en lugar de `Row`, que es exactamente lo
que llevan por dentro los `AlertDialog` del resto del juego: si los dos
botones no caben de lado, se apilan en vertical. Una línea de widget, sin
tocar textos ni tamaños.

**Por qué no lo había cazado nadie.** A ese diálogo solo se llega
simulando hasta diciembre (la Cup) o hasta el final de los playoffs, y
ningún test recorría tanto en una pantalla estrecha.
`simular_temporada_entera_test.dart` sí lo cruzaba, pero se había escrito
a 1000 px justamente para esquivarlo; ahora corre a 390 px como los
demás.

**Dos lecciones para los tests de layout**, las dos aprendidas aquí en
verde-que-mentía:

* **Un desborde se canta al pintar, no al medir.** Mientras dura la
  animación de entrada el diálogo va con opacidad 0, y a opacidad 0
  Flutter se salta el pintado entero. La primera versión de
  `dialogo_campeon_test.dart` paraba de avanzar fotogramas en cuanto
  encontraba el texto —todavía en mitad de la animación— y pasaba en
  verde con el `Row` roto. Hay que dejar que el diálogo termine de
  aparecer.
* **Un test que no comprueba que el diálogo se abrió no comprueba nada.**
  Cuando el campeón eres tú, el aviso se abre *después* de un
  `await HapticFeedback.heavyImpact()`, y en un test nadie contesta a ese
  canal de plataforma: el `await` se queda colgado y el diálogo no
  existe. El test pasaba sin haber mirado una sola pantalla. Se arregla
  con un contestador de mentira en `SystemChannels.platform` y con un
  `expect` de que el diálogo está ahí.

~~Y de paso: `flutter test` a secas no funciona en este equipo. El proyecto
vive dentro de OneDrive, `pub get` regenera
`ios/Flutter/ephemeral/Packages/.packages` (y el de `macos`), OneDrive las
bloquea antes de que Flutter pueda borrarlas y la orden muere ahí.
Borrarlas a mano no vale, vuelven. Se corre **`flutter test --no-pub`**.~~
**Ya no hace falta** (23 de agosto de 2026): el repo se sacó de OneDrive a
`C:\src\manager-nba` y `flutter test` a secas funciona. Ver *"El repo ya
NO vive en OneDrive"* arriba.

## Lista bugs/mejora 14 (a 2026-08-22, de `lista_bugs_cambios_nba_manager_14.txt`)

Por orden de más a menos importante:

1. ~~**UI alineación/roles**: la sección de "elegir estrella" y similares
   ocupa demasiado espacio en pantalla. Rediseñarla para que sea mucho
   más compacta.~~ **HECHO** el 23 de agosto de 2026: en móvil la banda de
   roles se pliega, de 270 px a 43. Ver *"La banda de roles se pliega en
   móvil"* arriba.

**La lista 14 está entera.**
2. ~~**Patrocinadores, logos**: usar los logos/fotos de patrocinadores que
   ya pasó el usuario, en vez de placeholders o diseño genérico.~~
   **HECHO** el 23 de agosto de 2026: 386 marcas con su logo, ver
   *"Patrocinadores con marca propia"* arriba.
3. ~~**Patrocinadores, opciones**: en cada tipo de patrocinio debe abrirse
   un desplegable/selector con 3 opciones distintas.~~ **HECHO** el 23 de
   agosto de 2026: cada categoría se despliega con hasta tres ofertas de
   marcas distintas de su ciudad. Ocho canteras de las 116 dan para menos
   de tres y ahí salen las que hay.
4. ~~**Patrocinadores, ofertas**: cada opción debe mostrar cantidades de
   dinero diferentes y duraciones de contrato diferentes (años
   distintos).~~ **HECHO** el 23 de agosto de 2026: uno, dos o cuatro
   años, y cuanto más largo menos paga al año. Con contratos de verdad en
   la base (esquema 29) que caducan solos.

Los puntos 2, 3 y 4 se hicieron juntos, que era lo que convenía: son el
mismo sitio (`features/temporada/patrocinadores_screen.dart` y
`domain/patrocinadores.dart`). Ver *"Patrocinadores: tres ofertas por
categoría y contratos de varios años"* arriba.

~~**Pendiente de que lo dé el usuario**: los logos del punto 2.~~ Ya
están, en `app/manager_nba/assets/logos/`.
