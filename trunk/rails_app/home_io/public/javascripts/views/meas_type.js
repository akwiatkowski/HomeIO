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
        //$(this.el).html(JST.document({ model: this.model }));
        //out += JST.document({ model: item });
      });
      out += "</ul>";
    } else {
      out = "<h3>No meas types! <a href='#new'>Create one</a></h3>";
    }
    $(this.el).html(out);
    $('#app').html(this.el);
  }
});