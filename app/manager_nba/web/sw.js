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
// Al cambiar de versión hay que subir CACHE: el activate borra las cachés
// viejas y así una actualización no deja mezclados ficheros de dos builds.
const CACHE = 'manager-nba-v2';

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
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/skwasm.js',
  'canvaskit/skwasm.wasm',

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
  'assets/assets/data/jugadores.json',
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

self.addEventListener('install', (evento) => {
  evento.waitUntil(
    caches.open(CACHE).then(async (cache) => {
      // Uno a uno y sin rendirse al primer fallo: `cache.addAll` es atómico,
      // así que un solo 404 (un icono que se renombre, un asset que se
      // quite) tiraría la instalación entera y dejaría el juego sin caché
      // ninguna. Es mejor guardar 24 de 25 ficheros que ninguno.
      await Promise.all(
        ESENCIALES.map((ruta) =>
          cache.add(new Request(ruta, {cache: 'reload'})).catch((e) => {
            console.warn('[sw] no se pudo guardar', ruta, e);
          })
        )
      );
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
    evento.respondWith(
      caches.match('index.html').then((r) => r || fetch(peticion))
    );
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
