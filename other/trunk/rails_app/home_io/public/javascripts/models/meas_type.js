var MeasType = Backbone.Model.extend({
  url : function() {
    var base = 'meas_types';
    if (this.isNew()) return base + ".json";
    return base + (base.charAt(base.length - 1) == '/' ? '' : '/') + this.id + ".json";
  }
});
