class AddUserAdminFlag < ActiveRecord::Migration
  def self.up
    add_column :users, :admin, :boolean, :default => false, :null => false

    # first registered user become admin
    if defined? User
      u = User.first
      u.update_attribute( :admin, true ) unless u.nil?
    end
  end

  def self.down
    remove_column :users, :admin
  end
end
