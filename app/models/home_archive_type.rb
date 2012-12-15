class HomeArchiveType < ActiveRecord::Base
  has_many :home_archives
  attr_accessible :name
end
