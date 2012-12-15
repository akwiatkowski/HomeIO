var MeasArchive = Backbone.Model.extend({
  url : function() {
    var base = 'meas_types/' + this.meas_type_id + '/meas_archives';
    if (this.isNew()) return base + ".json";
    return base + (base.charAt(base.length - 1) == '/' ? '' : '/') + this.id + ".json";
  }
});
