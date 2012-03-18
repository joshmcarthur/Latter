require 'spec_helper'

describe Activity do
  it "should require a message" do
    activity = Activity.new
    activity.should_not be_valid
    activity.message = "Test Message"
    activity.should be_valid
  end

  it "should generate a message for a completed challenge" do
    challenge = Factory(:challenge)
    challenge.set_score_and_winner({
      :from_player_score => 21,
      :to_player_score => 10
    })
    completed_challenge = "#{challenge.from_player.name} completed their challenge against #{challenge.to_player.name} and won! (#{challenge.score})"
    Activity.should_receive(:create).with({:message => completed_challenge}).and_return(true)
    Activity.completed_challenge(challenge)
  end

  it "should generate a message for a new challenge" do
    challenge_attributes = Factory.attributes_for(:challenge)
    new_challenge = "#{challenge_attributes[:from_player].name} challenged #{challenge_attributes[:to_player].name}."
    Activity.should_receive(:create).with({:message => new_challenge}).and_return(true)
    Challenge.create(challenge_attributes)
  end
end
