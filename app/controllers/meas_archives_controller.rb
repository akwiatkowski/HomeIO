class MeasArchivesController < InheritedResources::Base
  load_and_authorize_resource
  nested_belongs_to :meas_type, optional: true

  has_scope :page, default: 1, if: Proc.new{ |r| r.request.format == 'html'}
  has_scope :meas_type_id
end
