class UserTask < ActiveRecord::Migration
  def up
    create_table :user_tasks do |t|
      t.references :user
      t.references :delayed_job

      t.text :params
      t.string :klass
    end
  end

  def down
    drop_table :user_tasks
  end
end
