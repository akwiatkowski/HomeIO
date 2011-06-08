App.Controllers.MeasType = Backbone.Controller.extend({
  routes: {
    "#meas_types/:id":           "show",
    "":                         "index",
    "meas_types_current":       "current"
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
  },

  current: function() {
    $.getJSON('/meas_types/current.json', function(data) {
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