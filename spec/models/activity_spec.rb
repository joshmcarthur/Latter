require 'spec_helper'

describe Activity do
  it "should require a message" do
    activity = Activity.new
    activity.should_not be_valid
    activity.message = "Test Message"
    activity.should be_valid
  end

  it "should generate a message for a completed game" do
    game = Factory(:game)
    game.complete!({
      'challenger_score' => 21,
      'challenged_score' => 10
    })
    completed_game = "#{game.challenger.name} completed their game against #{game.challenged.name} and won! (#{game.score})"
    Activity.should_receive(:create).with({:message => completed_game}).and_return(true)
    Activity.completed_game(game)
  end

  it "should generate a message for a new game" do
    game_attributes = FactoryGirl.attributes_for(:game)
    new_game = "#{game_attributes[:challenger].name} challenged #{game_attributes[:challenged].name}."
    Activity.should_receive(:create).with({:message => new_game}).and_return(true)
    Game.create(game_attributes)
  end
end
