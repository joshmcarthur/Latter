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

  it "should not create a challenge when an inverse one is already in progress" do
    @challenge.save
    @inverse_challenge = Factory(:challenge, :to_player => @challenge.from_player, :from_player => @challenge.to_player)

    @inverse_challenge.valid?
    @inverse_challenge.should_not be_valid
  end

  it "should create an activity when a challenge is created" do
    challenge_attributes = Factory.attributes_for(:challenge)
    Activity.should_receive(:new_challenge).with(an_instance_of(Challenge))
    Challenge.create(challenge_attributes)
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
      Player.should_receive(:recalculate_rankings)

      @challenge.set_score_and_winner(
        :from_player_score => 15,
        :to_player_score => 6
      )
    end

    it "should add an activity item when a challenge is completed" do
      Activity.should_receive(:completed_challenge).with(an_instance_of(Challenge))
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
