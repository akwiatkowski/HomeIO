class PostDeviceMigration < ActiveRecord::Migration
  def up
    add_foreign_key :home_archives, :users, :dependent => :restrict
  end

  def down
    remove_foreign_key :home_archives, :users
  end
end
