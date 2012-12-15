// http://www.jamesyu.org/2011/01/27/cloudedit-a-backbone-js-tutorial-by-example/
// http://www.jamesyu.org/2011/02/09/backbone.js-tutorial-with-rails-part-2/

var App = {
  Views: {},
  Controllers: {},
  init: function() {
    new App.Controllers.MeasType();
    Backbone.history.start();
  }
};
