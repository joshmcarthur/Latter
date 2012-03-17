require 'spec_helper'

describe "Mailing" do
  before(:all) do
    Pony.stub!(:deliver)
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
    get "/player/#{@opponent.id}/challenge"
  end

  it "should send a completed challenge notification" do
    Pony.should_receive(:deliver) do |mail|
      mail.to.should contain([@opponent.email, @current_player.email])
      mail.from.should contain(@current_player.email)
      mail.subject.should eq("Challenge completed!")
      mail.body.should_not be_empty
    end
    post "/challenge/#{Challenge.last.id}/complete", {
      :challenge => {
        :from_player_score => 15,
        :to_player_score => 6
      }
    }
  end
end


