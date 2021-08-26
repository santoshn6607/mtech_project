/* global self, caches, fetch */
'use strict'

var cachename = 'fox-store'
var urlstocache = [
      'index.html',
      'index.js',
      'sw.js',
      'tf.min.js',
      'style.css',
      'datastyle.css',
      'noscript.css',
      'icon/MRClogomed.png',
];


/*
async function createDB(tf){
  const model = await tf.loadLayersModel('/NNmodel/tfjs_model/model.json');
  await model.save('indexeddb://report-exec-time-model');
}



self.addEventListener('activate', function(event) {
  event.waitUntil(
    createDB(tf)
  );
});
*/

// install/cache page assets
self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(cachename)
      .then(function (cache) {
        console.log('cache opened')
        return cache.addAll(urlstocache)
      })
  )
})

// intercept page requests
self.addEventListener('fetch', function (event) {
  console.log(event.request.url)
  event.respondWith(
    caches.match(event.request).then(function (response) {
      // serve requests from cache (if found)
      return response || fetch(event.request)
    })
  )
})

// service worker activated, remove outdated cache
self.addEventListener('activate', function (event) {
  console.log('worker activated')
    event.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(
        keys.filter(function (key) {
          // filter old versioned keys
          return key !== cachename
        }).map(function (key) {
          return caches.delete(key)
        })
      )
    })
  )
})
