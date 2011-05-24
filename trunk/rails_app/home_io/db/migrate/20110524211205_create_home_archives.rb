class CreateHomeArchives < ActiveRecord::Migration
  def self.up
    User.transaction do
      create_table :home_archives do |t|
        t.datetime :time
        t.float :value

        t.references :user
        t.references :home_archive_type

        t.timestamps
      end

      # foreign key to user
      add_foreign_key :home_archives, :users, :dependent => :restrict
    end

  end

  def self.down
    User.transaction do
      remove_foreign_key :home_archives, :users
      drop_table :home_archives
    end
  end
end
