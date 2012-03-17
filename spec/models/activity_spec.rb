require 'spec_helper'

describe Activity do
  it "should require a message" do
    activity = Activity.new
    activity.should_not be_valid
    activity.message = "Test Message"
    activity.should be_valid
  end
end
