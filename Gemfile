source 'http://rubygems.org'

#backend
# redis with pure C driver
gem "hiredis"
gem 'redis', :require => ["redis/connection/hiredis", "redis"]

# cron-like stuff
gem "rufus-scheduler"

# DB
gem 'pg'
gem 'sqlite3'

# https://github.com/brianmario/yajl-ruby
gem 'yajl-ruby'

# parts of HomeIO
gem 'weather_fetcher'
gem 'home_io_meas_receiver'

# ;)
gem 'colorize'

# webapp
gem 'rails'
gem 'thin'
gem 'execjs'
gem 'jquery-rails'
gem 'haml'
gem 'haml-rails'
gem 'inherited_resources'
gem 'has_scope'
gem 'responders'
gem 'kaminari'
gem 'sorted'
gem 'simple_form'
gem 'devise'
gem 'cancan'
gem 'high_voltage'
gem 'navigasmic'
gem 'simple_show_helper'
gem 'jquery-rails'
gem 'configatron'

# bootstrap stuff
gem 'libv8', '~> 3.11.8'
gem "therubyracer"
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "twitter-bootstrap-rails"

# js graphs
gem "nvd3-rails", git: "git@github.com:adeven/nvd3-rails.git", submodules: true

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end


group :development do
  #backend
  gem 'pry'

  gem "rdoc"
  gem "rspec"
  gem "bundler"
  gem "simplecov"

  #webapp
  gem 'nifty-generators'
  gem 'pry-rails'
  # webconsole
  gem 'rack-webconsole-pry', :require => 'rack-webconsole'
end

group :development, :test do
  #gem 'itslog', git: "https://github.com/elle/itslog"
  gem 'rspec-rails', '>= 2.6.1.beta1'
  gem 'rails_best_practices'
end

group :test do
  gem "mocha", :require => false
  gem 'factory_girl' #, ">= 1.1.beta1"
  gem 'capybara', ">= 0.4.1.2"
  gem 'database_cleaner', '>= 0.6.7'
  gem 'spork'
end