# Manager NBA

Un manager de baloncesto: diriges una franquicia temporada tras temporada.
Alineaciones, traspasos, agencia libre, draft, playoffs, Hall of Fame y
camisetas retiradas. Sin animaciones de partido — esto va de decisiones y
de ver cómo envejece tu plantilla.

Se juega en el **móvil, en la tablet y en el PC**: es una sola app que se
reordena según el ancho disponible.

## Jugar

👉 **[Abrir el juego](https://USUARIO.github.io/REPOSITORIO/)**
*(cambia esa dirección por la tuya cuando publiques)*

**En el iPhone:** ábrelo con **Safari** (Chrome en iOS no sabe instalar
webs), toca Compartir → *Añadir a pantalla de inicio*. Se queda con su
icono y **funciona sin conexión**: en el metro, en un avión o sin datos.

**En Android:** Chrome ofrece "Instalar aplicación" solo.

La primera vez se descargan unos 17 MB. Después, nada.

Cada persona tiene su propia partida, guardada en su dispositivo. No hay
cuentas ni servidor: la simulación entera corre en tu móvil y no se sube
nada a ningún sitio.

## Cómo está montado

| Carpeta | Qué hay |
|---|---|
| `app/manager_nba` | La app Flutter: pantallas, base de datos y reglas de la liga |
| `app/packages/sim_engine` | El motor de simulación, en Dart puro y sin dependencias de Flutter |
| `app/manager_nba/assets/data` | Plantillas, carreras reales, Hall of Fame y camisetas |
| `docs/plan.md` | La bitácora del proyecto: qué se hizo, por qué, y qué se descartó |

Los datos salen de un dataset público de la NBA. Los nombres de jugadores y
equipos están cambiados a propósito.

## Compilar

```bash
cd app/manager_nba
flutter pub get
flutter test
```

Para web, los dos flags no son opcionales:

```bash
flutter build web --release --no-web-resources-cdn --pwa-strategy=none
```

`--no-web-resources-cdn` mete CanvasKit en el propio sitio en vez de
bajarlo de `gstatic.com` — sin él, la app no arranca sin conexión.
`--pwa-strategy=none` evita que Flutter registre su service worker vacío,
que compite con el de `web/sw.js`.

Publicar es automático: cada push a `main` dispara
`.github/workflows/publicar.yml`, que compila y actualiza la web. Si los
tests fallan, no se publica.

Al tocar `web/sw.js` hay que subir la versión de `CACHE`
(`manager-nba-v1` → `-v2`) o los navegadores se quedarán con la copia vieja.
