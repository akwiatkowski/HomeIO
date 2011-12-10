class AddUserAdminFlag2 < ActiveRecord::Migration
  def up
    add_column :users, :admin, :boolean, :default => false, :null => false

    # first registered user become admin
    if defined? User
      u = User.order('id ASC').first
      u.update_attribute( :admin, true ) unless u.nil?
    end
  end

  def down
    remove_column :users, :admin
  end
end
