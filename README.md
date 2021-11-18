# Implementing PWA Neural Network predictor
Implementing machine learning as a PWA (October 2021)<br  />
The folder NNModel contains all the components required for the pneumonia PWA<br  />

Move whole folder to an Apache web server to run the PWA<br  />
It can also be run from https://stats.mrc.gm/NNmodel<br  />

Folder NNmodel contains:<br  />

folder icon - icon images used by PWA for Android and iOS<br  />
folder tfjs_model - contains the web-based tensorflow neural network (group1-shard1of1.bin and model.json)<br  />
These were created using the tensor flow javascript converter <br />tensorflowjs_converter --input_format=keras M_99_test.h5 tfjs_model<br  />
The file M_99_test.h5 is the tensorflow neural network model that was created in R - this can also be loaded in R and used to predict<br  />

Main files<br  />
index.html - web page<br  />
index.js - loads the service workers<br  />
manifest.webmanifest - PWA meta data<br  />
sw.js - service workers for offline functionality<br  />

Javascript tensorflow library<br  />
tf.min.js<br  />
tf.min.js.map<br  />

CSS files<br  />
datastyle.css<br  />
noscripts.css<br  />
style.css<br  />

Contaact djeffries@mrc.gm<br  />
