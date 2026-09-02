# Hoja de ruta hacia el lanzamiento

**Qué es este fichero.** `plan.md` es el diario de sesión a sesión —
larguísimo, con el detalle técnico de cada arreglo. Este es lo contrario:
corto, se actualiza en vez de crecer, y sirve para dos cosas —que puedas
ver de un vistazo cómo va el progreso hacia lanzarlo de verdad, y que yo
tenga de dónde tirar cuando no sepas qué pedirme. El detalle de "por qué"
de cada cosa vive en `plan.md`; aquí solo el estado.

**Meta acordada (24 de agosto de 2026):** app nativa en tiendas — Android
primero, Steam después, iOS más adelante (bloqueado por un motivo real,
ver abajo). Es la misma prioridad que ya estaba escrita en
`plan_monetizacion.md` desde el 21 de agosto.

---

## Dónde estamos hoy

- **Jugable ahora mismo**: [jokar77.github.io/manager-nba](https://jokar77.github.io/manager-nba/)
  (web/PWA, instalable desde el móvil). Se publica sola en cada `git push`
  a `main`.
- **Dos modos, no uno.** Desde el 25 de agosto de 2026 el juego tiene
  también **Modo Carrera** (controlas a un único jugador, de los 16 años
  al retiro, en vez de una franquicia entera) — mismo enlace, botón
  "Modo Jugador" en el menú de inicio. Su propio estado y detalle técnico
  vive en `plan_modo_carrera.md`; aquí solo cuenta para el roadmap de
  lanzamiento porque comparte plataforma, tiendas y el mismo aviso legal
  de nombres/equipos parecidos a los reales (ver más abajo).
- **717 tests**, todos verdes. `dart analyze` limpio (o `flutter analyze`
  si no está teniendo un problema de sesión propio del analizador, ajeno
  al código).
- **7 idiomas** completos (interfaz y guion de eventos narrativos).
- **Monetización**: la capa de permisos, los puertos de anuncios/compra,
  los tres bloqueos de la versión gratuita, y ya también la pantalla de
  comprar la versión completa están hechos y probados
  (`plan_monetizacion.md`, pasos 1-4). Lo que falta son las cuentas reales
  de Google — pasos 5-6, ver más abajo.
- **El código ya compila para las tres plataformas de escritorio y las
  dos móviles** (carpetas `android/`, `ios/`, `windows/`, `linux/`,
  `macos/` ya existen y tienen bundle ID propio, no el de plantilla) —
  lo que falta no es "hacer que compile", es todo lo que rodea a
  publicarlo de verdad en cada tienda.

---

## El camino a cada tienda

### Android (Play Store) — el primero, y el que menos bloqueado está

Ya se puede compilar desde este PC (`flutter build appbundle
--dart-define=EDICION=gratis`). Lo que falta:

- [x] Pantalla de "comprar la versión completa" (paso 4 de
      `plan_monetizacion.md` — hecho el 26 de agosto de 2026:
      `lib/features/tienda/comprar_screen.dart` + el aviso reusable de
      función bloqueada, enlazados desde la ranura de guardado bloqueada).
- [ ] Cuentas y SDKs reales: AdMob y Play Billing (paso 5). Necesita que
      tengas las cuentas creadas — **esto es tuyo, no lo puedo crear yo**.
- [ ] **Cuenta de desarrollador de Google Play**: 25 $, pago único. Tuyo.
- [ ] Formulario de consentimiento UE (UMP) — obligatorio con tráfico
      europeo, antes del primer anuncio.
- [x] Política de privacidad publicada — hecho el 27 de agosto de 2026,
      [jokar77.github.io/manager-nba/privacidad.html](https://jokar77.github.io/manager-nba/privacidad.html)
      (borrador: falta el email de contacto y la revisión legal, ver
      backlog más abajo).
- [ ] Formulario de seguridad de datos y clasificación de contenido en
      Play Console.
- [ ] Firma de release (keystore) y probarlo en un Android de verdad.
- [ ] Capturas de pantalla, icono de tienda, descripción.

### Steam (Windows/Mac/Linux escritorio) — el segundo, y compilable ya

`flutter build windows` ya funciona desde este mismo PC, con
`EDICION=completa` (sin anuncios ni compras: en Steam sale todo
desbloqueado de fábrica, como ya decidiste en su momento).

- [ ] Cuenta de Steamworks: **100 $, pago único**. Tuyo.
- [ ] Página de tienda (capturas, descripción, precio).
- [ ] Subir el build con SteamPipe (documentado por Valve, no complicado).
- [ ] Revisión de Valve — bastante más ligera que la de Apple/Google.

### iOS (App Store) — bloqueado por un motivo real, no de código

**No se puede compilar para iOS desde Windows.** Xcode —lo único que
firma y compila apps de iOS— solo existe en macOS. No es un bug ni algo
que se arregle con más tiempo: es una limitación de la plataforma.

Opciones, y las dos son decisión tuya:

1. Conseguir acceso a un Mac (propio, prestado, o alquilado por horas —
   hay servicios tipo MacinCloud). Desde ahí, compilar e instalar
   directamente o repartir por TestFlight.
2. Un servicio de CI en la nube que compila iOS sin que tengas Mac
   (Codemagic, Xcode Cloud). Tiene coste mensual y hay que configurarlo,
   pero es real y lo usa bastante gente sin Mac.

Sin uno de los dos, iOS se queda parado pase lo que pase con el código.

---

## Aviso serio, antes de publicar en cualquier tienda pública

Hasta ahora el juego se ha repartido por enlace directo, entre amigos.
Salir a una tienda pública (buscable, con miles de usuarios potenciales)
es una exposición distinta, y hay una cosa que no puedo resolver yo por
ti: **el juego usa nombres de jugador ficticios muy parecidos a los
reales (cambiando 1-2 letras) y estadísticas/eventos que imitan la NBA
de verdad.** Ya se ha tenido cuidado —apodos de equipo también
ligeramente cambiados, sin escudos ni logos reales— precisamente porque
esto importa, pero antes de una publicación pública y monetizada
conviene que un abogado (o al menos una búsqueda seria de casos
parecidos: apps de manager de fantasía, "name and likeness") lo revise.
No es algo que yo pueda garantizar por escrito de código; es una
decisión de riesgo que solo puedes tomar tú con esa información.

Esto afecta a **los dos modos por igual**: Modo Carrera te draftea a un
equipo de los mismos 30 con apodos ligeramente cambiados, así que
cualquier revisión legal antes de publicar en tienda tiene que cubrir
ambos, no solo el modo Franquicia original.

---

## Lo que falta del JUEGO en sí (no de la tienda), pendiente de ti

Estas son bloqueos de contenido, no de plataforma — importan para
cualquiera de las tres tiendas:

1. **El icono del iPhone sigue sin diagnosticar.** Hace falta que abras
   `https://jokar77.github.io/manager-nba/estado.html` desde el propio
   icono (no desde Safari) y me digas qué pone.
2. **El chino puede verse en cuadraditos en la web** — sin comprobar
   todavía en un móvil de verdad con el idioma puesto en chino. (En
   nativo esto probablemente no aplique igual: Android/iOS cogen la
   fuente del sistema, no dependen de CanvasKit.)
3. **Puntos 7 y 17 de la "lista parte 11"** (ofertas de la CPU poco
   realistas / el Play-In no desaparece al terminar): investigados a
   fondo, código correcto a simple vista — necesito un ejemplo concreto
   tuyo (jugadores, contratos, o cuándo lo viste) para seguir.
4. **Copia de seguridad de partidas**: aparcado hasta ahora porque hoy
   solo vive en el navegador del móvil. En nativo cambia la ecuación —
   los ficheros viven en el propio dispositivo, más parecido a cualquier
   otro juego— pero conviene decidir explícitamente si hace falta
   exportar/importar antes de publicar, no dejarlo caer.

---

## Backlog para cuando no sepas qué pedirme

Por si en algún momento no tienes nada concreto en mente, esto es lo
próximo con más valor, de más a menos prioritario:

1. ~~La pantalla de "comprar la versión completa".~~ Hecho el 26 de
   agosto de 2026, ver más arriba.
2. ~~Seguir modernizando pantallas con el estilo antiguo~~ (sin
   `PanelCortado`, `FilaDeJugador`/`SeparadorSeccion` ni los tokens de
   `Estilo.de(context)`). **Cerrado el 2 de septiembre de 2026.** El 26 de
   agosto de 2026 se hicieron 9 en dos pases:
   `clasificacion/equipo_detalle_screen.dart`, `premios/premios_screen.dart`,
   `temporada/pretemporada_screen.dart`, `torneo/torneo_screen.dart`,
   `mercado/ofertas_screen.dart`, `mercado/entrenador_screen.dart`,
   `temporada/resumen_temporada_screen.dart`, `playoffs/playoffs_screen.dart`
   y `temporada/draft_screen.dart`. El resto de la lista original resultaron
   ser falsos positivos (sin listas de jugadores/equipos con media) salvo
   estas dos, cerradas el 2 de septiembre:
   - `mercado/traspasos_screen.dart` — hecho el 2 de septiembre de 2026,
     pero con alcance reducido a propósito: se modernizó toda la
     tipografía y el color (a `titular`/`rotulo`/`Estilo.de(context)`, y
     los tres avisos de banner a `PanelCortado` con un `_Aviso` reusable)
     dejando intactos `ListTile`/`CheckboxListTile`/`DropdownButton` — son
     la mesa de 3 columnas con buscador automático y hoja modal, y
     cambiarles el tipo de widget seguía siendo más riesgo de romper
     interacción del que compensaba. Backlog punto 2 ya cerrado del todo.
   - ~~`temporada/camisetas_nuevas_screen.dart` y
     `temporada/retirados_screen.dart`~~ — hecho el 2 de septiembre de
     2026 (`Card`→`PanelCortado`, tipografía a `titular`/`rotulo`/`cifra`,
     título de sección a `SeparadorSeccion`).
3. Medir el equilibrio del mercado (jugarlo vs. no jugarlo) con más
   semillas todavía — hoy solo se ha reforzado un test de regresión, no
   se ha hecho la medición fina que pedía `plan.md`.
4. ~~Política de privacidad: un borrador inicial.~~ Hecho el 27 de
   agosto de 2026: `app/manager_nba/web/privacidad.html`, publicada en
   [jokar77.github.io/manager-nba/privacidad.html](https://jokar77.github.io/manager-nba/privacidad.html).
   Falta rellenar el email de contacto (queda un `[TU EMAIL DE
   CONTACTO]` a propósito, ver `plan.md`) y la revisión legal de la que
   ya se habla más arriba.

---

## Cómo se mantiene esto

Cada vez que se cierre algo de esta lista, lo marco aquí (tachado o
`[x]`) y muevo el detalle técnico a `plan.md`, igual que ya se hace con
la Lista de bugs. Este fichero se queda corto a propósito — si empieza a
crecer sin parar, ha dejado de servir para lo que es.
