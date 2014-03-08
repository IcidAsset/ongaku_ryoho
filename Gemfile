source 'http://rubygems.org'

ruby '2.0.0'

gem 'rails', '3.2.16'
gem 'puma', '~> 2.7'

gem 'pg'
gem 'redis'
gem 'sidekiq'
gem 'sorcery', '~> 0.8'
gem 'closure-compiler'
gem 's3'

gem 'activerecord-postgres-hstore', '~> 0.7'
gem 'oj', '~> 2.5'
gem 'slim', '~> 1.3'

group :assets do
  gem 'sass', '3.2.13'
  gem 'sass-rails', '3.2.6'
  gem 'coffee-rails', '3.2.2'
  gem 'compass-rails', '1.1.3'
  gem 'animation'
end

group :test, :development do
  gem 'minitest-rails', '~> 0.9'
  gem 'quiet_assets'
  gem 'foreman'
end

group :test do
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails', '~> 4.3'
  gem 'turn', require: false
end

group :production do
  gem 'dalli'
  gem 'memcachier'
  gem 'heroku-deflater'
  gem 'newrelic_rpm'
end
