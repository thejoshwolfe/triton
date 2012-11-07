(function() {
  require("coffee-script");
  var App = require("./server/app");
  
  var app  = new App();
  app.run(process.env.PORT || 24139);
})()