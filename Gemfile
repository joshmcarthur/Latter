source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '~> 4.0'
gem 'pg'
gem 'unicorn'
gem 'dalli'
gem 'jbuilder'
gem 'elo'
gem 'gravtastic'
gem 'devise', '3.0.0.rc'
gem 'kaminari'
gem 'ransack', github: 'ernie/ransack', ref: 'rails-4'
gem 'coffee-rails'
gem 'uglifier'
gem 'jquery-rails'
gem "sass-rails"
gem 'bootstrap-sass', '~> 2.3.2.1'
gem 'font-awesome-rails'

group :development, :test do
  gem 'rspec-rails'
end

group :development do
  gem 'dotenv-rails'
  gem 'foreman'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  # DRb server for testing frameworks
  gem 'spork', '1.0.0rc'
  gem 'simplecov', :require => false
end

group :production do
  gem 'rails_12factor'
end

