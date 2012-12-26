class Overseer < ActiveRecord::Base
  belongs_to :user

  set_inheritance_column :sti_type
  serialize :params, Hash

  attr_accessible :name, :params
end
