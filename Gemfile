source :rubygems

gem 'sinatra'
gem 'data_mapper'
gem 'dm-aggregates'
gem 'dm-observer'
gem 'dm-migrations'
gem 'dm-validations'
gem 'dm-sqlite-adapter'
gem 'haml'
gem 'gravtastic'
gem 'pony'
gem 'elo'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'warden'

group :production do
  gem 'dm-postgres-adapter'
end

group :guard do
  gem 'guard', '1.0.1'
  gem 'guard-bundler', '0.1.3'
  gem 'guard-rspec', '0.6.0'
  gem 'growl', '1.0.3'
end

group :development do
  gem 'ruby-debug19'
  gem 'taps', :git => 'https://github.com/joshmcarthur/taps.git'
  gem 'heroku'
end

group :development, :test do
  gem 'data_objects'
  gem 'do_sqlite3'
  gem 'simplecov', :require => false
  gem 'rspec', '=2.4.0'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'rack-test', :require => 'rack/test'
  gem 'factory_girl'
	gem 'awesome_print'
end
