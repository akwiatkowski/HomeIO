source 'http://rubygems.org'

# redis with pure C driver
gem "hiredis"
gem 'redis', :require => ["redis/connection/hiredis", "redis"]

# cron-like stuff
gem "rufus-scheduler"

# stuff from rails
gem 'activerecord'
gem 'pg'
#gem 'sqlite3'

# https://github.com/brianmario/yajl-ruby
gem 'yajl-ruby'

# parts of HomeIO
gem 'weather_fetcher'
gem 'home_io_meas_receiver'

# ;)
gem 'colorize'

group :development do
  gem 'pry'

  gem "rdoc"
  gem "rspec"
  gem "bundler"
  gem "jeweler"
  gem "simplecov"
end