source 'http://rubygems.org'

ruby '2.0.0'

gem 'rails', '3.2.14'
gem 'puma', '~> 2.0'

gem 'pg'
gem 'redis'
gem 'sucker_punch', '~> 1.0'
gem 'sorcery', '~> 0.8'
gem 'closure-compiler'
gem 's3'

gem 'activerecord-postgres-hstore', '~> 0.7'
gem 'oj', '~> 2.1'
gem 'slim', '~> 1.3'

group :assets do
  gem 'sass', '3.2.9'
  gem 'sass-rails', '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'compass-rails', '~> 1.0.3'
  gem 'animation'
end

group :test, :development do
  gem 'minitest-rails', '~> 0.9'
  gem 'quiet_assets'
end

group :test do
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails', '~> 4.2'
  gem 'turn', require: false
end

group :production do
  gem 'dalli'
  gem 'memcachier'
  gem 'heroku-deflater'
  gem 'newrelic_rpm'
end
