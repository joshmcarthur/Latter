require 'spec_helper'

describe Game do
  before(:each) do
    @game = Factory(:game)
  end

  it "should create a game given valid attributes" do
    @game.save.should be_true
  end

  it "should not create a game with invalid attributes" do
    @game.challenger = nil
    @game.save.should_not be_true
  end

  it "should not create a game when an inverse one is already in progress" do
    @game.save
    @inverse_game = Factory(:game, :challenged => @game.challenger, :challenger => @game.challenged)

    @inverse_game.valid?
    @inverse_game.should_not be_valid
  end

  it "should create an activity when a game is created" do
    game_attributes = Factory.attributes_for(:game)
    Activity.should_receive(:new_game).with(an_instance_of(Game))
    Game.create(game_attributes)
  end

  describe "completion" do
    before(:each) do
      @game.set_score_and_winner(
        :challenger_score => 15,
        :challenged_score => 6
      )
      @game.completed = true # This is normally set from the controller
      @game.save
    end

    it "should complete a game" do
      @game.score.should eq("15 : 6")
      @game.winner.should eq(@game.challenger)
      @game.completed.should be_true
    end

    it "should recalculate the ranking of all players when a game is completed" do
      Player.should_receive(:recalculate_rankings)

      @game.set_score_and_winner(
        :challenger_score => 15,
        :challenged_score => 6
      )
    end

    it "should add an activity item when a game is completed" do
      Activity.should_receive(:completed_game).with(an_instance_of(Game))
      @game.set_score_and_winner(
        :challenger_score => 15,
        :challenged_score => 6
      )
    end

    it "should correctly identify the winner" do
      @game.winner?(@game.challenger).should be_true
    end

    it "should correctly identify the loser" do
      @game.loser?(@game.challenged).should be_true
    end
    it "should correctly identify a drawer" do
      @game.set_score_and_winner(
        :challenger_score => 10,
        :challenged_score => 10
      )
      @game.drawer?(@game.challenger).should be_true
      @game.drawer?(@game.challenged).should be_true
    end

    it "should correctly calculate the winning margin" do
      @game.set_score_and_winner(
        :challenger_score => 21,
        :challenged_score => 10
      )
      @game.winning_margin.should == 11
    end
  end
end
