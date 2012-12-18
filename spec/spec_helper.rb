require 'spork'

Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails' do
      add_filter '.bundle'
    end
  end

  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rails'
  Dir[Rails.root.join('spec', 'support', '*.rb')].each { |f| require f }

  RSpec.configure do |config|
    config.include Devise::TestHelpers, :type => :controller
    config.extend ControllerMacros, :type => :controller

    config.mock_with :rspec

    config.before(:suite) do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.use_transactional_fixtures = false

  end
end

Spork.each_run do
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}

  Dir["#{Rails.root}/spec/support/**/*.rb"].each { |f| load f}
end

