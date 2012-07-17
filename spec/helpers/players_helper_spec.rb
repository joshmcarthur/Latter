require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the PlayersHelper. For example:
#
# describe PlayersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe PlayersHelper do
  before :each do
    @player = FactoryGirl.build(:player)
  end

  describe "#trend" do
    it "should render a title if the player is improving" do
      @player.should_receive(:trend).and_return(:up)
      helper.trend(@player).should include "Improving"
    end

    it "should render a title if the player is worsening" do
      @player.should_receive(:trend).and_return(:down)
      helper.trend(@player).should include "Worsening"
    end

    it "should not render anything if the player trend has not changed" do
      @player.should_receive(:trend).and_return(:same)
      helper.trend(@player).should be_blank
    end
  end
end
