source 'http://rubygems.org'

ruby '2.0.0'

gem 'rails', '3.2.13'
gem 'puma', '~> 2.0'

gem 'pg'
gem 'redis'
gem 'sidekiq', '~> 2.12'
gem 'sorcery', '~> 0.8'
gem 'newrelic_rpm'

gem 'activerecord-postgres-hstore', '~> 0.7'
gem 'patron', '~> 0.4'
gem 'oj', '~> 2.0'

group :assets do
  gem 'sass-rails', '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'compass-rails', '~> 1.0.3'
  gem 'uglifier', '>= 1.3.0'
  gem 'animation'
end

gem 'slim', '~> 1.3'

group :test, :development do
  gem 'minitest-rails', '~> 0.9'
end

group :test do
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails', '~> 4.2'
  gem 'turn', require: false
end
