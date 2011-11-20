def in_memory_database?
  ENV["RAILS_ENV"] == "test" and
    ENV["IN_MEMORY_DB"] and
    Rails::Configuration.new.database_configuration['test-in-memory']['database'] == ':memory:'
end

if in_memory_database?
  puts "connecting to in-memory database ..."
  ActiveRecord::Base.establish_connection(Rails::Configuration.new.database_configuration['test-in-memory'])
  puts "building in-memory database from db/schema.rb ..."
  load "#{Rails.root}/db/schema.rb" # use db agnostic schema by default
  #  ActiveRecord::Migrator.up('db/migrate') # use migrations
end