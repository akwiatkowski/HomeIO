class HomeArchiveType < ActiveRecord::Migration
  def self.up
    HomeArchive.transaction do
      create_table :home_archive_types do |t|
        t.string :name
        t.timestamps
      end

      # foreign key to user
      add_foreign_key :home_archives, :home_archive_types, :dependent => :restrict
    end
  end

  def self.down
    HomeArchive.transaction do
      remove_foreign_key :home_archives, :home_archive_types
      drop_table :home_archive_types
    end
  end
end
