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


var MeasType = Backbone.Model.extend({
  url : function() {
    var base = 'meas_types';
    if (this.isNew()) return base + ".json";
    return base + (base.charAt(base.length - 1) == '/' ? '' : '/') + this.id + ".json";
  }
});

App.Controllers.MeasType = Backbone.Controller.extend({
  routes: {
    "meas_types/:id":           "show",
    "":                         "index"
  },

  show: function(id) {
    var doc = new MeasType({ id: id });
    doc.fetch({
      success: function(model, resp) {
        new App.Views.Show({ model: doc });
      },
      error: function() {
        new Error({ message: 'Could not find that meas type.' });
        window.location.hash = '#';
      }
    });
  },

  index: function() {
    $.getJSON('/meas_types.json', function(data) {
      if (data) {
        var meas_types = _(data).map(function(i) {
          return new MeasType(i);
        });
        new App.Views.Index({ meas_types: meas_types });
      } else {
        new Error({ message: "Error loading meas types." });
      }
    });
  }

});

App.Views.Index = Backbone.View.extend({
    initialize: function() {
      this.meas_types = this.options.meas_types;
      this.render();
    },

    render: function() {
      if (this.meas_types.length > 0) {
        var out = "<h3><a href='#new'>Create New</a></h3><ul>";
        _(this.meas_types).each(function(item) {
        out += "<li><a href='#meas_types/" + item.id + "'>" + item.escape('name') + "</a></li>";
      });
      out += "</ul>";
    } else {
      out = "<h3>No meas types! <a href='#new'>Create one</a></h3>";
    }
    $(this.el).html(out);
    $('#app').html(this.el);
  }
});


