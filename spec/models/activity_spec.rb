# == Schema Information
#
# Table name: activities
#
#  id         :integer          not null, primary key
#  message    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

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

  it "creates an activity for an awarded badge" do
    award = FactoryGirl.build(:award)
    award.badge = FactoryGirl.create(:badge)
    award.player = FactoryGirl.create(:player)
    awarded_badge = "#{award.player.name} was awarded the #{award.badge.name} badge."
    Activity.should_receive(:create).with({:message => awarded_badge}).at_least(1).times.and_return(true)
    award.save!
  end

  it "creates an activity for a new game" do
    game_attributes = FactoryGirl.attributes_for(:game)
    new_game = "#{game_attributes[:challenger].name} challenged #{game_attributes[:challenged].name}."
    Activity.should_receive(:create).with({:message => new_game}).at_least(1).times.and_return(true)
    Game.create(game_attributes)
  end

  it "creates an activity for a completed game" do
    game = FactoryGirl.build(:game)
    game.complete!({
      :challenger_score => 21,
      :challenged_score => 10
    })
    completed_game = "#{game.challenger.name} completed their game against #{game.challenged.name} and won! (#{game.score})"
    Activity.should_receive(:create).with({:message => completed_game}).at_least(1).times.and_return(true)
    Activity.completed_game(game)
  end
end
