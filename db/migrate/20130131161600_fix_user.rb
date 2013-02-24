class FixUser < ActiveRecord::Migration
  def change
    # https://github.com/plataformatec/devise/wiki/How-To:-Upgrade-to-Devise-2.0-migration-schema-style
    add_column :users, :authentication_token, :string
  end
end
