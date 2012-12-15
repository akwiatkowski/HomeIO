class Overseer < ActiveRecord::Base
  has_many :overseer_parameters
  belongs_to :user

  def disable
    r = BackendProtocol.disable_overseer(self)
    r
  end

  def enable
    r = BackendProtocol.enable_overseer(self)
    r
  end

end
