require 'spec_helper'

describe Activity do
  subject do
    FactoryGirl.build(:activity)
  end

  it "creates a valid object given valid attributes" do
    subject.save
    subject.should be_persisted
  end

  it "does not create a valid object given invalid attributes" do
    subject.message = ""
    subject.save
    subject.should_not be_persisted
  end

  it "creates an activity for a new game" do
    game_attributes = FactoryGirl.attributes_for(:game)
    new_game = "#{game_attributes[:challenger].name} challenged #{game_attributes[:challenged].name}."
    Activity.should_receive(:create).with({:message => new_game}).and_return(true)
    Game.create(game_attributes)
  end

  it "creates an activity for a completed game" do
    game = FactoryGirl.build(:game)
    game.complete!({
      :challenger_score => 21,
      :challenged_score => 10
    })
    completed_game = "#{game.challenger.name} completed their game against #{game.challenged.name} and won! (#{game.score})"
    Activity.should_receive(:create).with({:message => completed_game}).and_return(true)
    Activity.completed_game(game)
  end
end
