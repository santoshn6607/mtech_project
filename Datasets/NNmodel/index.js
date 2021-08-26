


async function createDB(tf) {
  const model = await tf.loadLayersModel('/NNmodel/tfjs_model/model.json');
  await model.save('indexeddb://report-exec-time-model');
}


// Register service worker to control making site work offline

if ('serviceWorker' in navigator) {
  navigator.serviceWorker
    .register('sw.js')
    //createDB(tf)
    .then(() => {
      console.log('Service Worker Registered');
      createDB(tf);
    });
}

/*
      if ( 'serviceWorker' in navigator ) {
        navigator.serviceWorker.register('sw.js').then(function(registration) {
          // Registration was successful
          console.log('ServiceWorker registration successful with scope: ', registration.scope);
        createDB(tf);
           }).catch(function(err) {
          // registration failed :(
          console.log('ServiceWorker registration failed: ', err);
        });

        //Listen for claiming of our ServiceWorker
        navigator.serviceWorker.addEventListener('controllerchange', function() {
          console.log( 'Service worker status changed: ', this.controller.state );
          // Listen for changes in the state of our ServiceWorker
          navigator.serviceWorker.controller.addEventListener('statechange', function() {
            // If the ServiceWorker becomes "activated", let the user know they can go offline!
            if (this.state === 'activated') {
                window.location.reload( true );
            }
          });
        });

      } else  if ('applicationCache' in window) {
        var iframe = document.createElement('iframe');
        iframe.style.display = 'none';
        iframe.src = 'load-appcache.html';
        document.body.appendChild(iframe);

        //Check if a new cache is available on page load.
        window.addEventListener('load', function( ) {
          window.applicationCache.addEventListener('updateready', function( ) {
            if (window.applicationCache.status === window.applicationCache.UPDATEREADY) {
                window.applicationCache.swapCache();
                window.location.reload( true );
            } else {
              // Manifest didn't changed. Nothing new to server.
            }
          }, false);

        }, false);

      }
*/



// Code to handle install prompt on desktop

let deferredPrompt;
const addBtn = document.querySelector('.add-button');
addBtn.style.display = 'none';

window.addEventListener('beforeinstallprompt', (e) => {
  // Prevent Chrome 67 and earlier from automatically showing the prompt
  e.preventDefault();
  // Stash the event so it can be triggered later.
  deferredPrompt = e;
  // Update UI to notify the user they can add to home screen
  addBtn.style.display = 'block';

  addBtn.addEventListener('click', () => {
    // hide our user interface that shows our A2HS button
    addBtn.style.display = 'none';
    // Show the prompt
    deferredPrompt.prompt();
    // Wait for the user to respond to the prompt
    deferredPrompt.userChoice.then((choiceResult) => {
      if (choiceResult.outcome === 'accepted') {
        console.log('User accepted the home page prompt');
      } else {
        console.log('User dismissed the home page  prompt');
      }
      deferredPrompt = null;
    });
  });
});
