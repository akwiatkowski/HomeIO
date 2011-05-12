class CreateMemos < ActiveRecord::Migration
  def self.up
    create_table :memos do |t|
      t.string :title
      t.text :text
      t.integer :user_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :memos
  end
end
