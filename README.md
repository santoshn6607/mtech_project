# implement-model
Implementing machine learning as a PWA (October 2021)
The folder NNModel contains all the components required for the pneumonia PWA
Move whole folder to an Apache web server to run the PWA
It can also be run from https://stats.mrc.gm/NNmodel

Folder NNmodel contains:

folder icon - icon images used by PWA for Android and iOS
folder tfjs_model - contains the web-based tensorflow neural network (group1-shard1of1.bin and model.json)
These were created using the tensor flow javascript converter tensorflowjs_converter --input_format=keras M_99_test.h5 tfjs_model
The file M_99_test.h5 is the tensorflow neural network model that was created in R - this can also be loaded in R and used to predict

Main files
index.html - web page
index.js - loads the service workers
manifest.webmanifest - PWA meta data
sw.js - service workers for offline functionality

Javascript tensorflow library
tf.min.js
tf.min.js.map

CSS files
datastyle.css
noscripts.css
style.css

Contaact djeffries@mrc.gm 
