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
      expect(@player).to receive(:trend).and_return(:up)
      expect(helper.trend(@player)).to include "Improving"
    end

    it "should render a title if the player is worsening" do
      expect(@player).to receive(:trend).and_return(:down)
      expect(helper.trend(@player)).to include "Worsening"
    end

    it "should not render anything if the player trend has not changed" do
      expect(@player).to receive(:trend).and_return(:same)
      expect(helper.trend(@player)).to be_blank
    end
  end

  describe "#distance_of_last_game_for" do
    it "should return the correct time representation of the last game" do
      game = FactoryGirl.build(:game, :updated_at => DateTime.now - 1.hour, :challenged => @player)
      game.complete!(:challenged_score => 21, :challenger_score => 15)

      expect(helper.distance_of_last_game_for(@player)).to match "about 1 hour"
    end

    it "should handle the player having no games" do
      expect {
        helper.distance_of_last_game_for(@player)
      }.to_not raise_error
    end
  end
end
