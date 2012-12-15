class CreateOverseers < ActiveRecord::Migration
  def self.up
    create_table :overseers do |t|
      t.string :name, :null => false
      t.string :klass, :null => false
      t.boolean :active, :null => false, :default => false

      # which user created it
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :overseers
  end
end
