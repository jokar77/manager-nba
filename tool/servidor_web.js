// Sirve `app/manager_nba/build/web` en http://127.0.0.1:8080.
//
// Sustituye al `python -m http.server` que había antes en
// `.claude/launch.json`: en esta máquina Python NO está instalado —solo los
// alias de la Microsoft Store, que no ejecutan nada— así que la vista
// previa no arrancaba. Node sí está, y viene con todo lo que hace falta:
// esto no instala ni una dependencia.
//
// Antes de lanzarlo hay que compilar, igual que con el de antes:
//
//     cd app/manager_nba
//     flutter build web --release --no-web-resources-cdn --pwa-strategy=none
//
// Los dos flags no son opcionales; el porqué está en el README.
const http = require('http');
const fs = require('fs');
const path = require('path');

const RAIZ = path.join(__dirname, '..', 'app', 'manager_nba', 'build', 'web');
const PUERTO = 8080;

// Los tipos que sirve el juego. `.wasm` y `.js` importan de verdad: son
// CanvasKit y SQLite, y el navegador los rechaza si llegan con el tipo
// equivocado.
const TIPOS = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm',
  '.css': 'text/css; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.bin': 'application/octet-stream',
};

if (!fs.existsSync(path.join(RAIZ, 'index.html'))) {
  console.error(`No hay nada compilado en ${RAIZ}.`);
  console.error('Compila primero:');
  console.error('  cd app/manager_nba');
  console.error('  flutter build web --release --no-web-resources-cdn '
    + '--pwa-strategy=none');
  process.exit(1);
}

http
  .createServer((peticion, respuesta) => {
    const pedido = decodeURIComponent(peticion.url.split('?')[0]);
    // Sin esto, un `..` en la URL sacaría ficheros de fuera de build/web.
    const destino = path.join(RAIZ, path.normalize(pedido).replace(/^[\/]+/, ''));
    if (!destino.startsWith(RAIZ)) {
      respuesta.writeHead(403).end('Fuera de sitio');
      return;
    }

    let fichero = destino;
    if (!fs.existsSync(fichero) || fs.statSync(fichero).isDirectory()) {
      const indice = path.join(fichero, 'index.html');
      // Una ruta del juego que no sea un fichero cae al index, que es lo
      // que espera el enrutador de Flutter.
      fichero = fs.existsSync(indice) ? indice : path.join(RAIZ, 'index.html');
    }

    fs.readFile(fichero, (error, datos) => {
      if (error) {
        respuesta.writeHead(404).end('No está');
        return;
      }
      respuesta.writeHead(200, {
        'Content-Type': TIPOS[path.extname(fichero).toLowerCase()]
          || 'application/octet-stream',
        // El service worker y `main.dart.js` se quedan pegados entre
        // compilaciones si el navegador los cachea. En desarrollo estorba.
        'Cache-Control': 'no-store',
      });
      respuesta.end(datos);
    });
  })
  .listen(PUERTO, '127.0.0.1', () => {
    console.log(`Manager NBA en http://127.0.0.1:${PUERTO}`);
  });
