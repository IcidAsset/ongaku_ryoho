source "http://rubygems.org"

gem "rails", "3.2.9"
gem "puma"

gem "pg"
gem "sidekiq"
gem "sorcery"

group :assets do
  gem "sass-rails",    "~> 3.2.5"
  gem "coffee-rails",  "~> 3.2.2"
  gem "compass-rails", "~> 1.0.0"
  gem "uglifier",      ">= 1.0.3"
end

gem "slim"

group :test, :development do
  gem "minitest-rails"
end

group :test do
  gem "shoulda-matchers", require: false
  gem "factory_girl_rails", "~> 3.0"
  gem "turn", require: false
end
