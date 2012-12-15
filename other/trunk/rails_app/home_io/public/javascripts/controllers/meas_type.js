App.Controllers.MeasType = Backbone.Controller.extend({
  routes: {
    "meas_types/:id":           "show",
    "":                         "index",
    "meas_types_current":       "current"
  },

  show: function(id) {
    var meas_type = new MeasType({ id: id });
    meas_type.fetch({
      success: function(model, resp) {
        new App.Views.MeasTypeShow({ meas_type: meas_type });
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
        new App.Views.MeasTypeIndex({ meas_types: meas_types });
      } else {
        new Error({ message: "Error loading meas types." });
      }
    });
  },

  current: function() {
    $.getJSON('/meas_types/current.json', function(data) {
      if (data) {
        var meas_types = _(data).map(function(i) {
          return new MeasArchive(i);
        });
        new App.Views.Index({ meas_types: meas_types });
      } else {
        new Error({ message: "Error loading meas types." });
      }
    });
  }

});