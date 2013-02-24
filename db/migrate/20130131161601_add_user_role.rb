class AddUserRole < ActiveRecord::Migration
  def up
    add_column :users, :role, :string, default: 'user'

    User.reset_column_information
    User.all.each do |u|
      u.role = 'admin' if u.admin
      u.save
    end

    remove_column :users, :admin
  end

  def down
    remove_column :users, :role
    add_column :users, :admin, :boolean, default: false
  end
end
