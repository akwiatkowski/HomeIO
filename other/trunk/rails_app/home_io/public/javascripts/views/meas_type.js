App.Views.MeasTypeIndex = Backbone.View.extend({
  initialize: function() {
    this.meas_types = this.options.meas_types;
    this.render();
  },

  render: function() {
    if (this.meas_types.length > 0) {
      //var out = "<h3><a href='#new'>Create New</a></h3><ul>";
      var out = "<ul>";
      _(this.meas_types).each(function(item) {
        out += "<li><a href='#meas_types/" + item.id + "'>" + item.escape('name') + "</a></li>";
        //$(this.el).html(JST.document({ model: this.model }));
        //out += JST.document({ model: item });
      });
      out += "</ul>";
    } else {
      out = "<h3>No meas types! <a href='#new'>Create one</a></h3>";
    }

    // current measurements
    out += "<a href='#meas_types_current'>Current</a></li>";

    $(this.el).html(out);
    $('#app').html(this.el);
  }
});

App.Views.MeasTypeShow = Backbone.View.extend({
  initialize: function() {
    this.meas_type = this.options.meas_type;
    this.render();
  },

  render: function() {
    if (this.meas_type != null) {
      var out = "<h3>" + this.meas_type.id + "</h3><br/>";
      out += "Unit " + this.meas_type.escape('unit') + "<br/>";
      out += "Name " + this.meas_type.escape('name') + "<br/>";
      out += "Id " + this.meas_type.id + "<br/>";
      //out += "</ul>";
    } else {
      out = "<h3>No meas types!</h3>";
    }
    $(this.el).html(out);
    $('#meas_type').html(this.el);
  }
});