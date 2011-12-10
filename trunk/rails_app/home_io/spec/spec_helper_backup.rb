require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # http://stackoverflow.com/questions/7425490/silence-rails-schema-load-for-spork
  ActiveRecord::Schema.verbose = false
  load "#{Rails.root}/db/schema.rb"

  # CAPYBARA
  require 'capybara/rspec'
  # uses FF
  Capybara.default_driver = :selenium
  # uses something internal
  #Capybara.javascript_driver = :webkit

  # DB CLEANER
  require 'database_cleaner'
  DatabaseCleaner.strategy = :truncation

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    #config.use_transactional_fixtures = true
    config.use_transactional_fixtures = false

    config.before(:each) do
      #DatabaseCleaner.start
      #ActiveRecord::Migrator.up('db/migrate') # if in memory DB is used, need some fixes, reload models
    end

    #config.after(:each) do
    #  DatabaseCleaner.clean
    #end

  end

  DatabaseCleaner.start
end

Spork.each_run do
  # This code will be run each time you run your specs.
  #require 'factory_girl_rails'
  #Dir[Rails.root.join("spec/factories/*.rb")].each { |f| require f }
  #ActiveRecord::Migrator.up('db/migrate') # if in memory DB is used, need some fixes, reload models
  # DatabaseCleaner.start # this was here
  DatabaseCleaner.clean # this wasn't here'

  FactoryGirl.factories.clear
  FactoryGirl.find_definitions
end

Spork.after_each_run do
  DatabaseCleaner.clean
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#

