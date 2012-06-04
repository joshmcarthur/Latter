require 'spec_helper'

describe Player do

  subject do
    FactoryGirl.build(:player)
  end

  it "should create a valid player"
  it "should not create an invalid player"

  describe "Gravatar" do
    it "should have a gravatar url"
  end

  describe "Associations" do
    it "should have challenged games"
    it "shoudl have challenger games"
    it "should have won games"
    it "should show all completed games"
    it "should show all games"
    it "shoudl return in progress games"
  end

  describe "Pro rating" do
    it "should be pro if rating is over the threshold"
    it "should not be pro if rating is not over the threshold"
  end

  describe "Starter rating" do
    it "should be a starter if the player has played less than 30 games"
    it "should not be a starter if the player has played more than 30 games"
  end

  describe "K Factor" do
    it "should return the correct k-factor for a pro player"
    it "should return the correct k-factor for a starter player"
    it "should return the default k-factor otherwise"
  end

end
