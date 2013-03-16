source "http://rubygems.org"

gem "rails", "3.2.12"
gem "puma"

gem "pg"
gem "redis"
gem "sidekiq", "~> 2.8"
gem "sorcery", "~> 0.8"

gem "activerecord-postgres-hstore", "~> 0.7"

group :assets do
  gem "sass-rails", "~> 3.2.6"
  gem "coffee-rails", "~> 3.2.2"
  gem "compass-rails", "~> 1.0.3"
  gem "uglifier", ">= 1.3.0"
end

gem "slim", "~> 1.3"

group :test, :development do
  gem "minitest-rails", "~> 0.5"
end

group :test do
  gem "shoulda-matchers", require: false
  gem "factory_girl_rails", "~> 3.0"
  gem "turn", require: false
end
