class DestroyAllUsers2 < ActiveRecord::Migration
  def up
    #drop_table :users # not working, why :( ?
    execute 'drop table users;'
  end

  def down
    create_table :users
  end

end
