require 'bundler/setup'
Bundler.require
require 'capybara/rspec'
require 'rack/test'
require 'factory_girl'
FactoryGirl.find_definitions

require File.join(File.dirname(__FILE__), '..', 'latter')

set :environment, :test

RSpec.configure do |conf|
  conf.before(:all) do
    Capybara.app = Latter
  end
end

def app
  Latter
end
