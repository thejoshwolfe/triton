(function() {
  var App = require("./lib/app");
  var app  = new App();
  app.run(process.env.PORT || 8000);
})()
