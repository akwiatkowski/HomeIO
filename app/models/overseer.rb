class Overseer < ActiveRecord::Base
  belongs_to :user

  set_inheritance_column :sti_type
  serialize :params, Hash

  attr_accessible :name, :params

  after_save :send_to_backend

  def send_to_backend
    HomeIoServer::RedisProxy.publish('admin', { overseer: self.attributes, update: true })
  end

end
