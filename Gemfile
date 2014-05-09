source 'http://rubygems.org'

ruby '2.1.2'

gem 'rails', '3.2.17'
gem 'puma', '~> 2.8'

gem 'pg', '~> 0.17'
gem 'redis', '~> 3.0'
gem 'sidekiq', '~> 3.0'
gem 'sorcery', '~> 0.8'
gem 'closure-compiler', '~> 1.1'
gem 's3', '~> 0.3'

gem 'activerecord-postgres-hstore', '~> 0.7'
gem 'oj', '~> 2.5'
gem 'slim', '~> 1.3'

group :assets do
  gem 'sass', '3.2.15'
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
  gem 'rails_12factor'
end
