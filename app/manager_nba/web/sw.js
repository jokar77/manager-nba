// Service worker de Manager NBA.
//
// Está escrito a mano y no generado por Flutter a propósito: en la versión
// que usa el proyecto, `flutter build web` deja un `flutter_service_worker.js`
// VACÍO (0 bytes), así que la app no guardaba nada y sin cobertura no
// arrancaba. Con este, el juego se descarga una vez y a partir de ahí
// funciona en el metro, en un avión o sin datos.
//
// Todo lo que necesita el juego es local: la simulación corre en tu
// dispositivo y la base de datos vive en el navegador (ver
// data/database/almacenamiento_web.dart). No hay servidor que consultar, así
// que "sin conexión" es el modo normal, no un apaño.
//
// SUBIR ESTO EN CADA PUBLICACIÓN QUE CAMBIE EL JUEGO. No solo al tocar
// ficheros de web/: `main.dart.js` es el juego entero compilado y está en
// la lista de precarga de aquí abajo, así que cambia con cualquier línea de
// Dart. Y como `guardarLoQueFalte` no vuelve a pedir lo que ya tiene
// guardado (a propósito: es lo que permite completar una caché a medias sin
// descargarlo todo otra vez), sin subir la versión los que ya tengan el
// juego se quedarían con el código viejo PARA SIEMPRE.
//
// Al subirla, el `activate` borra las cachés viejas y la nueva se llena de
// cero, así que no quedan mezclados ficheros de dos compilaciones.
const CACHE = 'manager-nba-v9';

// Lo imprescindible para arrancar y jugar. Se descarga entero al instalar,
// de una vez, para que baste con abrir el juego UNA vez con conexión.
const ESENCIALES = [
  './',
  'index.html',
  'manifest.json',
  'favicon.png',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',

  // El motor de dibujo. Va la copia local (por eso se compila con
  // --no-web-resources-cdn): la de gstatic.com no se puede descargar sin
  // conexión, y sin ella la pantalla se queda en blanco.
  //
  // VAN LAS DOS VARIANTES, y no es por si acaso. Flutter compila con
  // `renderer: canvaskit` y elige en caliente: los navegadores basados en
  // Chromium (Chrome, Edge, Android) piden `canvaskit/chromium/`, y el
  // resto —Safari, o sea el iPhone— pide `canvaskit/` a secas. Como el
  // service worker no sabe quién le va a tocar, guarda las dos.
  //
  // Aquí estaba el fallo que dejaba el juego inservible sin conexión:
  // solo se guardaba la variante genérica, así que en Chrome y en Android
  // el motor de dibujo NO estaba en la caché y la pantalla se quedaba en
  // blanco. Se vio sirviendo el sitio en local y mirando qué pedía de
  // verdad el navegador, no leyendo la lista.
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/chromium/canvaskit.js',
  'canvaskit/chromium/canvaskit.wasm',

  // SQLite compilado a WebAssembly y su worker: son la base de datos.
  'sqlite3.wasm',
  'drift_worker.js',

  // Los datos del juego: las plantillas, las carreras reales, el Hall of
  // Fame y las camisetas. Sin esto no se puede ni empezar una partida.
  'assets/AssetManifest.bin.json',
  'assets/AssetManifest.bin',
  'assets/FontManifest.json',
  'assets/NOTICES',
  'assets/fonts/MaterialIcons-Regular.otf',
  // La pide el arranque siempre, y tampoco estaba: sin ella el primer
  // pintado sin conexión se queda esperando una fuente que no llega.
  'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  'assets/assets/data/jugadores.json',
  'assets/assets/data/entrenadores.json',
  'assets/assets/data/datos_reales.json',
  'assets/assets/data/legado_real_scoring.json',
  'assets/assets/data/hof_players_simple.json',
  'assets/assets/data/retired_numbers.json',
  'assets/assets/data/camisetas_futuras.json',

  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'icons/Icon-maskable-192.png',
  'icons/Icon-maskable-512.png',
];

// Guarda lo que falte de ESENCIALES y devuelve lo que no se pudo traer.
//
// Uno a uno y sin rendirse al primer fallo: `cache.addAll` es atómico, así
// que un solo 404 (un icono que se renombre, un asset que se quite) tiraría
// la instalación entera y dejaría el juego sin caché ninguna. Es mejor
// guardar 24 de 25 ficheros que ninguno.
//
// Lo que ya está guardado no se vuelve a pedir, así que llamar a esto de
// más es barato: son 28 consultas a la caché local y ni una a la red.
async function guardarLoQueFalte(cache) {
  const fallidos = [];
  await Promise.all(
    ESENCIALES.map(async (ruta) => {
      if (await cache.match(ruta)) return;
      try {
        await cache.add(new Request(ruta, {cache: 'reload'}));
      } catch (e) {
        fallidos.push(ruta);
      }
    })
  );
  return fallidos;
}

// Que la instalación tolere fallos estaba bien; que no volviera a intentarlo
// nunca, no. Si la primera vez que se abre el juego hay mala cobertura —o se
// añade a la pantalla de inicio del iPhone, que arranca con su propia caché
// vacía, aparte de la de Safari— la caché se quedaba incompleta PARA
// SIEMPRE: unos ficheros se servían y otros no, y el juego funcionaba a
// medias sin forma de arreglarse solo.
//
// Con esto, cada vez que abres el juego con conexión se completa lo que
// falte. La bandera evita lanzar diez repasos a la vez; como el service
// worker se puede parar y arrancar en cualquier momento, se vuelve a
// comprobar en cada arranque, que es justo lo que se quiere.
let repasando = false;
async function completarPrecargaSiFalta() {
  if (repasando) return;
  // Sin conexión no hay nada que completar, y sí mucho que estropear: cada
  // fichero que falte serían 29 peticiones que se quedan colgadas hasta que
  // el sistema las corta, en cada apertura del juego. Justo cuando peor
  // viene, que es jugando sin datos.
  if (!self.navigator.onLine) return;
  repasando = true;
  try {
    const cache = await caches.open(CACHE);
    const fallidos = await guardarLoQueFalte(cache);
    if (fallidos.length) {
      console.warn('[sw] sigue faltando por guardar:', fallidos);
    }
  } finally {
    repasando = false;
  }
}

self.addEventListener('install', (evento) => {
  evento.waitUntil(
    caches.open(CACHE).then(async (cache) => {
      await guardarLoQueFalte(cache);
      self.skipWaiting();
    })
  );
});

self.addEventListener('activate', (evento) => {
  evento.waitUntil(
    (async () => {
      const nombres = await caches.keys();
      await Promise.all(
        nombres.filter((n) => n !== CACHE).map((n) => caches.delete(n))
      );
      await self.clients.claim();
    })()
  );
});

self.addEventListener('fetch', (evento) => {
  const peticion = evento.request;

  // Solo GET: no tiene sentido cachear otra cosa, y el navegador se queja
  // si se intenta guardar un POST.
  if (peticion.method !== 'GET') return;

  // Nada de otros dominios: la app no llama a ninguno, y si algún día lo
  // hiciera no querríamos servirlo de una caché vieja.
  const url = new URL(peticion.url);
  if (url.origin !== self.location.origin) return;

  // Navegar (abrir la app, recargar, volver desde la pantalla de inicio del
  // iPhone) siempre resuelve al index: es una sola página, y sin esto una
  // recarga sin conexión daría el dinosaurio.
  if (peticion.mode === 'navigate') {
    // Abrir el juego es el momento bueno para repasar la caché: si la
    // instalación se quedó a medias (mala cobertura, o el primer arranque
    // desde la pantalla de inicio del iPhone), aquí se completa sola.
    evento.waitUntil(completarPrecargaSiFalta());

    // Antes esto devolvía `index.html` a SECAS para cualquier navegación, y
    // se tragaba las páginas propias: con el modo sin conexión instalado,
    // abrir `estado.html` te daba el juego. Ahora se busca primero la página
    // pedida —en la caché y en la red— y solo se cae al index cuando de
    // verdad no existe, que es lo que hace falta para que una ruta cualquiera
    // del juego siga abriendo el juego.
    evento.respondWith((async () => {
      const guardada = await caches.match(peticion);
      if (guardada) return guardada;
      try {
        const red = await fetch(peticion);
        if (red && red.ok) {
          const copia = red.clone();
          caches.open(CACHE).then((cache) => cache.put(peticion, copia));
          return red;
        }
      } catch (e) {
        // Sin conexión: se resuelve abajo con el index.
      }
      return (await caches.match('index.html')) || fetch(peticion);
    })());
    return;
  }

  // El resto: primero la caché —así va rápido y funciona sin datos— y si no
  // está, se pide a la red y se guarda para la próxima. Esto es lo que
  // recoge lo que no esté en la lista de esenciales (fuentes de CanvasKit,
  // shaders, lo que sea) en cuanto se usa una vez con conexión.
  evento.respondWith(
    caches.match(peticion).then((guardada) => {
      if (guardada) return guardada;
      return fetch(peticion)
        .then((respuesta) => {
          if (respuesta && respuesta.ok) {
            const copia = respuesta.clone();
            caches.open(CACHE).then((cache) => cache.put(peticion, copia));
          }
          return respuesta;
        })
        .catch(() => guardada);
    })
  );
});
