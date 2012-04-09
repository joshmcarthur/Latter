require 'spec_helper'

describe "Mailing" do
  before(:all) do
    Pony.stub!(:deliver)
    Factory.create(:game)
    @current_player = Factory.create(:player)
    @opponent = Factory.create(:player)

    login_as @current_player
  end

  after(:all) do
    logout
  end

  it "should send a new challenge notification" do
    Pony.should_receive(:deliver) do |mail|
      mail.to.should contain(@opponent.email)
      mail.from.should contain(@current_player.email)
      mail.subject.should eq("You've been Challenged!")
      mail.body.should_not be_empty
    end
    post "/player/#{@opponent.id}/challenge"
  end

  it "should send a completed challenge notification" do
    Pony.should_receive(:deliver) do |mail|
      mail.to.should contain([@opponent.email, @current_player.email])
      mail.from.should contain(@current_player.email)
      mail.subject.should eq("Challenge completed!")
      mail.body.should_not be_empty
    end
    post "/games/#{Game.last.id}/complete", {
      :game => {
        :challenger_score => 15,
        :challenged_score => 6
      }
    }
  end
end


