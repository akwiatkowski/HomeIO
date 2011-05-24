# Custom archive parameters

class HomeArchive < ActiveRecord::Base
  belongs_to :home_archive_type
  belongs_to :user

  default_scope :order => 'time DESC'
end
