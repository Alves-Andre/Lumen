// Service worker do Lumen: deixa o Web App abrir sem internet.
//
// * Página, inicialização e código do app: rede primeiro (com limite de
//   tempo), cache como reserva. Assim uma versão nova publicada chega na
//   próxima abertura, e sem internet o app abre com a última versão.
// * Demais arquivos do site (motor gráfico, banco, ícones): cache primeiro,
//   atualizado em segundo plano.
// * Fontes do Google: cache primeiro (o Flutter as baixa sob demanda).
// * Supabase e demais domínios: nunca passam pelo cache.
'use strict';

const CACHE = 'lumen-v1';

const PRECACHE = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'sqlite3.wasm',
  'drift_worker.js',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/assets/branding/lumen_mark.png',
  'icons/Icon-192.png',
  'icons/apple-touch-icon.png',
];

// Arquivos que mudam a cada versão publicada.
const NETWORK_FIRST = ['/', '/index.html', '/flutter_bootstrap.js', '/main.dart.js', '/manifest.json', '/version.json'];

const FONT_HOSTS = ['fonts.gstatic.com', 'fonts.googleapis.com'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE);
      // Um arquivo que falhe não impede a instalação.
      await Promise.all(PRECACHE.map((url) => cache.add(new Request(url, { cache: 'reload' })).catch(() => {})));
      await self.skipWaiting();
    })(),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      for (const key of await caches.keys()) {
        if (key !== CACHE) await caches.delete(key);
      }
      await self.clients.claim();
    })(),
  );
});

function scopePath(url) {
  const scope = new URL(self.registration.scope).pathname;
  const path = url.pathname.startsWith(scope) ? url.pathname.slice(scope.length - 1) : url.pathname;
  return path || '/';
}

async function networkFirst(request) {
  const cache = await caches.open(CACHE);
  try {
    const response = await Promise.race([
      fetch(request),
      new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), 4000)),
    ]);
    if (response.ok) cache.put(request, response.clone());
    return response;
  } catch (e) {
    const cached = await cache.match(request, { ignoreSearch: true });
    if (cached) return cached;
    if (request.mode === 'navigate') {
      const index = await cache.match('index.html');
      if (index) return index;
    }
    throw e;
  }
}

async function cacheFirst(event, { revalidate }) {
  const request = event.request;
  const cache = await caches.open(CACHE);
  const cached = await cache.match(request, { ignoreSearch: true });
  const download = () =>
    fetch(request)
      .then((response) => {
        if (response.ok || response.type === 'opaque') cache.put(request, response.clone());
        return response;
      })
      .catch(() => undefined);
  if (cached) {
    // Atualiza em segundo plano (vale na próxima abertura).
    if (revalidate) event.waitUntil(download());
    return cached;
  }
  return (await download()) ?? Response.error();
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);

  if (url.origin === self.location.origin) {
    if (request.mode === 'navigate' || NETWORK_FIRST.includes(scopePath(url))) {
      event.respondWith(networkFirst(request));
    } else {
      event.respondWith(cacheFirst(event, { revalidate: true }));
    }
    return;
  }

  if (FONT_HOSTS.includes(url.hostname)) {
    event.respondWith(cacheFirst(event, { revalidate: false }));
  }
  // Supabase e outros domínios: segue direto para a rede.
});
