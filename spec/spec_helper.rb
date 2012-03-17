require 'bundler/setup'
Bundler.require

# Require RSpec helpers
require 'capybara/rspec'
require 'rack/test'
require 'factory_girl'

# Load FactoryGirl definitions
FactoryGirl.find_definitions

# Require application
require File.join(File.dirname(__FILE__), '..', 'latter')

# Require supporting files
Dir[File.join(File.dirname(__FILE__), 'support', '*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.before(:all)  do
    Capybara.app = Latter
    DataMapper.auto_migrate!

    # Make sure we are testing in a sandbox by deleting
    # existing Players and Challenges
    Player.destroy
    Challenge.destroy
  end
end

def app
  Latter
end
