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
      @game.complete!(
        'challenger_score' => 15,
        'challenged_score' => 6
      )
      @game = Game.get(@game.id)
    end

    it "should complete a game" do
      @game.score.should eq("15 : 6")
      @game.winner.should eq(@game.challenger)
      @game.complete.should be_true
    end

    it "should add an activity item when a game is completed" do
      Activity.should_receive(:completed_game).with(an_instance_of(Game))
      @game.complete!(
        'challenger_score' => 6,
        'challenged_score' => 15
      )
    end

    it "should correctly identify the winner" do
      @game.winner?(@game.challenger).should be_true
    end

    it "should correctly identify the loser" do
      @game.loser?(@game.challenged).should be_true
    end

    it "should return the correct score for each player" do
      @game.score_for(@game.challenger).should eq 15
      @game.score_for(@game.challenged).should eq 6
    end

  end
end
