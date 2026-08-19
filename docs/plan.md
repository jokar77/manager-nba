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
- `gh` CLI NO está instalado; `git` sí (2.55). **El push lo hace el usuario
  a mano** porque necesita autenticarse: hay que darle los comandos en
  bloques separados (PowerShell 5.1 **no admite `&&`**).
- Verificación local: `flutter analyze` limpio en los dos paquetes,
  **364 tests** de la app + **19** de `sim_engine`, y `flutter build web`
  correcto.

## ESTADO DE LA PUBLICACIÓN

Último commit publicado: **`f8abae8`** ("Entrenadores con contrato y el
juego en siete idiomas"), en verde.

Ya commiteados y verificados: los eventos narrativos (punto 23), con lo
que la lista parte 11 queda en **23 de 24**. Verificado en local:
`flutter analyze` limpio en los dos paquetes, **414 tests** de la app +
**19** de `sim_engine` en verde, y `flutter build web` correcto.
`web/sw.js` en **`CACHE = manager-nba-v9`**.

**El único punto que queda de la parte 11 es el 16** (bracket de playoffs
diminuto en móvil): aparcado a propósito porque cambiar cómo escala el
bracket sin poder ver una captura real sería adivinar a ciegas — este
entorno no compone imagen, así que no hay manera de comprobar el resultado
sin que el usuario mire su móvil.

**Esquema de base de datos en la 23**, con migración aditiva (tabla
`EfectosDeEvento` + columna `Temporada.eventosVistos`): las partidas
guardadas siguen intactas y simplemente empiezan sin ningún efecto activo,
que es el estado correcto.

Última publicación CONFIRMADA en verde: `9035f88` (caché v6). Si `f8abae8`
salió verde, la web ya lleva el dinero de los entrenadores y los idiomas.

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
5. **Faltan ~350 textos por traducir**, todo lo que no sea el menú de
   inicio, Ajustes, el menú principal y la pantalla de Entrenador. La
   infraestructura está y añadir una clave es trivial; es trabajo largo, no
   difícil.

### Lo que NO se ha podido verificar nunca en esta máquina

El panel del navegador de este entorno **no compone imagen**, así que no hay
capturas ni clics reales: `computer{action:"screenshot"}` da siempre
"the Browser pane is not displayed". Todo lo visual se ha verificado con
tests de widget a tres tamaños (`test/adaptacion_movil_test.dart`), que
detectan desbordes de layout pero no si algo se ve feo o si una fuente
falta. Cuando algo dependa de verlo, hay que pedírselo al usuario.

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
| 16 | Bracket de playoffs en móvil: se ve diminuto, tiene que ajustarse a la pantalla | |
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
que un test que simule 82 partidos de verdad todavía puede variar. De
cuatro tandas completas seguidas, tres salieron verdes y una cayó. Es
mucho mejor que antes pero no está cerrado.

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

## Idiomas (empezado, a medias)

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

Traducidos: el menú de inicio, Ajustes, el menú principal completo y la
pantalla de Entrenador. **El resto de pantallas siguen en castellano** —
calendario, plantilla, traspasos, draft, Legado, playoffs, premios... Son
unos 350 textos más de los 414 que hay en total (medidos con
`grep -rhoE "'[^']{4,}'" lib/features lib/shared`).

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

## CUIDADO al tocar `schemaVersion` (ya arreglado, pero hay que mantenerlo)

`app_database.dart` está en `schemaVersion => 21`. **Hasta la 20 la
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
**v5 (lista parte 10)**.

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
