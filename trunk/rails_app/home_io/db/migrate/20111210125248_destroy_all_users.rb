class DestroyAllUsers < ActiveRecord::Migration
  def up
    HomeArchive.delete_all
    remove_foreign_key :home_archives, :users
  end

  def down
    add_foreign_key :home_archives, :users, :dependent => :restrict
  end
end
