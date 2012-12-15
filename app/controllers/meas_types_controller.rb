class MeasTypesController < InheritedResources::Base
  load_and_authorize_resource
  has_scope :page, default: 1, if: Proc.new{ |r| r.request.format == 'html'}
  has_scope :sorted, as: :sort, default: 'name_asc'
end
