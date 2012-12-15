class Overseer < ActiveRecord::Base
  has_many :overseer_parameters
  belongs_to :user
end
