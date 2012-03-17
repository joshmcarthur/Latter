require 'spec_helper'

describe Challenge do
  before(:each) do
    @challenge = Factory(:challenge)
  end

  it "should create a challenge given valid attributes" do
    @challenge.save.should be_true
  end

  it "should not create a challenge with invalid attributes" do
    @challenge.from_player = nil
    @challenge.save.should_not be_true
  end

  describe "completion" do
    before(:each) do
      @challenge.set_score_and_winner(
        :from_player_score => 15,
        :to_player_score => 6
      )
      @challenge.completed = true # This is normally set from the controller
      @challenge.save
    end

    it "should complete a challenge" do
      @challenge.score.should eq("15 : 6")
      @challenge.winner.should eq(@challenge.from_player)
      @challenge.completed.should be_true
    end

    it "should recalculate the ranking of all players when a challenge is completed" do
      players = Player.all
      players.each { |p| p.should_receive(:ranking).with(true) }
      Player.should_receive(:all).and_return(players)

      @challenge.set_score_and_winner(
        :from_player_score => 15,
        :to_player_score => 6
      )
    end

    it "should correctly identify the winner" do
      @challenge.winner?(@challenge.from_player).should be_true
    end

    it "should correctly identify the loser" do
      @challenge.loser?(@challenge.to_player).should be_true
    end
    it "should correctly identify a drawer" do
      @challenge.set_score_and_winner(
        :from_player_score => 10,
        :to_player_score => 10
      )
      @challenge.drawer?(@challenge.from_player).should be_true
      @challenge.drawer?(@challenge.to_player).should be_true
    end

    it "should correctly calculate the winning margin" do
      @challenge.set_score_and_winner(
        :from_player_score => 21,
        :to_player_score => 10
      )
      @challenge.winning_margin.should == 11
    end
  end
end
