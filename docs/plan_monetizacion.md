# Plan de monetización

**Estado**: diseño acordado. Escrito el 2026-08-21; paso 1 (la capa de
permisos) implementado el 2026-08-22 en `lib/domain/permisos.dart`, con
`test/permisos_test.dart`. Del 2 en adelante, sin empezar.

Decidido con el usuario:

* **Android primero**, iOS quizá después, **Steam** más adelante.
* **Una sola app** con compra dentro, no dos fichas de tienda.
* Se bloquean en la versión gratuita: **patrocinadores**, **ranuras de
  guardado** y **simular la temporada entera de golpe**. La lista se
  ajustará (hay modos de juego en mente), así que tiene que ser fácil de
  cambiar.

---

## Lo primero: por qué esto obliga a salir de la web

Hoy el juego es una web en GitHub Pages, y ahí el modelo no existe:

| Lo que hace falta | En web | En Android |
| --- | --- | --- |
| Vídeo recompensado | No existe (AdMob es solo móvil) | AdMob, de serie |
| Cobrar una vez | Pasarela y licencias propias | `in_app_purchase`, de serie |
| Anuncio entre pantallas | AdSense, poco rendimiento | AdMob, de serie |

La web se queda como **demo**: sirve para que alguien pruebe el juego sin
instalar nada, y desde ahí se enlaza a la tienda. No se monetiza.

## Y por qué NO son dos copias del código

Dos carpetas se separan solas: arreglas un bug y hay que acordarse de
arreglarlo dos veces. En un mes ya no son el mismo juego.

Se hace con **una base de código y un interruptor de compilación**. Dos
artefactos, un solo sitio donde vive la lógica:

```
flutter build appbundle --dart-define=EDICION=gratis   -> Play (con anuncios)
flutter build windows                                  -> Steam / build interna
flutter run                                            -> desarrollo, todo abierto
```

En Steam no hay anuncios ni compras: ese build sale ya con todo
desbloqueado. Por eso "completa" tiene que poder venir **de la
compilación** y no solo de haber pagado.

**El que pide algo raro es el gratuito, no el completo.** La primera
versión de este plan lo tenía al revés —`appbundle` a secas salía gratis—,
y eso choca con la regla de más abajo de que el valor por defecto sea
`completa`: si el defecto fuera `gratis`, los 576 tests y `flutter run`
verían el juego capado y habría que tocarlos todos. Y puestos a
equivocarse en un build, es preferible que a alguien se le abra de más a
que quien ha pagado se quede fuera.

---

## La arquitectura: permisos, no ediciones

La tentación es preguntar `if (esGratis)` por todo el juego. Eso es lo que
hay que evitar: cuando dentro de dos meses se añada un modo de juego
nuevo a la lista de bloqueados, habría que buscar todos esos `if`.

En su lugar, **una lista de funciones y quién las tiene**:

```dart
enum Funcion { patrocinadores, ranurasExtra, simularTemporadaEntera }
```

Y tres fuentes de permisos que se suman:

1. **La compilación.** `EDICION=completa` (Steam, builds internas) lo
   desbloquea todo. Es también el valor por defecto, para que
   `flutter run` y los 576 tests actuales sigan viendo el juego entero
   sin tocar ni una línea de test.
2. **La compra.** Un pago único que desbloquea todo para siempre en esa
   cuenta de Google.
3. **El desbloqueo temporal.** Lo que da un vídeo recompensado: dura
   **una temporada**.

Añadir un modo de juego a la lista de bloqueados será, entonces, una
entrada nueva en el enum y una línea en la tabla.

### Las dos piezas que tocan Google, aisladas

Ni la lógica del juego ni los tests pueden depender de AdMob. Dos puertos
con implementación de mentira por defecto:

* `Anuncios` — `mostrarInterstitial()`, `mostrarRecompensado()`.
* `Tienda` — `comprarCompleta()`, `restaurarCompra()`.

La implementación real (AdMob, Play Billing) se enchufa en `main.dart`
solo en el build de Android. Todo lo demás del juego habla con el puerto.
Es lo mismo que ya se hizo con `almacenDeSlots`, que tiene versión de
disco y versión en memoria para los tests.

---

## Cómo se juega gratis

### Los anuncios

**Un interstitial al pasar de temporada**, y solo ahí. Es el final de una
etapa larga —el momento natural de cortar— y es una vez cada varias horas
de juego, no una interrupción constante.

Reglas que hay que respetar sí o sí:

* Nunca encima de un diálogo ni a mitad de una decisión.
* Después de que la transición termine, no antes.
* Uno por cambio de temporada. Nunca dos seguidos.

### Los patrocinadores

En la versión gratuita la pantalla sale con los cuatro bloqueados y **un
vídeo los desbloquea todos para esa temporada**.

Un vídeo por cada patrocinador sería peor diseño, y no por ser más
pesado: la gracia de esa pantalla es **elegir** entre cuatro que piden
cosas distintas (ver `compromisoPorCategoria`). Si cada uno costara su
propio vídeo, lo óptimo sería ver los cuatro y volvería a no haber
decisión — justo el problema que se arregló al añadir los compromisos.

Un vídeo, la decisión entera, esa temporada. Y como los patrocinadores ya
se reeligen cada año, el bucle sale solo.

### Lo demás

| Función | Gratis | Completa |
| --- | --- | --- |
| Ranuras de guardado | 1 | 3 |
| Simular la temporada entera de golpe | No | Sí |
| Patrocinadores | Un vídeo por temporada | Siempre |
| Anuncios | Al pasar de temporada | Ninguno |

Las tres son bloqueos suaves a propósito: el que juega gratis tiene el
juego **entero**, no una demo. Lo que se compra es ventaja y comodidad.

---

## Lo que hay que hacer antes de publicar (y no es código)

Esto suele pillar a la gente por sorpresa:

1. **Consentimiento de la UE (UMP).** Con tráfico europeo —y el juego se
   hace en España— el formulario de consentimiento de Google es
   **obligatorio** antes de pedir el primer anuncio. Sin eso, AdMob no
   sirve anuncios personalizados y se incumple el RGPD.
2. **Política de privacidad.** Play la exige para cualquier app con
   anuncios. Hace falta una URL pública: puede vivir en el mismo GitHub
   Pages que ya existe.
3. **Formulario de seguridad de los datos** en Play Console, declarando
   qué recoge el SDK de anuncios.
4. **Clasificación de contenido y público objetivo.** Si se marca que
   puede interesar a menores, entran reglas mucho más estrictas de
   anuncios. Un manager de baloncesto normalmente se declara para público
   general.
5. **Cuenta de desarrollador de Play**: 25 $ una vez.
6. **Los nombres reales.** Ya se evitan escudos y apodos reales a
   propósito (ver `equipos_info.dart`), y eso hay que mantenerlo: publicar
   en una tienda es justo cuando alguien puede mirarlo con lupa.

## Orden de trabajo propuesto

1. ~~**La capa de permisos** (Dart puro, con tests). No depende de tener
   cuenta de AdMob ni de Play: se puede hacer ya.~~ **Hecho** (2026-08-22):
   `Funcion`, `Edicion`, `Permisos` y la global `permisos`, con diez tests.
   Nadie la consulta todavía: eso es el paso 3.
2. **Los puertos** `Anuncios` y `Tienda`, con implementación de mentira.
3. **Enchufar los tres bloqueos** a la capa de permisos.
4. **La pantalla de compra** y el aviso de "esto es de la versión
   completa".
5. **AdMob y Play Billing de verdad**, cuando existan las cuentas.
6. **Publicar** con lo de la lista de arriba resuelto.

Los pasos 1-4 son la mitad del trabajo y no dependen de nadie.
