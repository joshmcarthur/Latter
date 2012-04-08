require 'spec_helper'

describe Player do
  before(:all) do
    @player = all_players.first
    @game = Factory.create(
      :game,
      :challenger => @player,
      :winner => @player,
      :challenged => all_players.last,
      :complete => true
    )
  end

  it "should require an email address and name" do
    @player.email = ""
    @player.name = ""
    @player.valid?.should be_false
    @player.reload
  end


  it "should return in progress games where the player is the gamer" do
    @other_player = Factory.create(:player)
    @game = Factory.create(:game, :challenger => @player, :challenged => @other_player, :complete => false)
    @player.in_progress_games(@other_player).first.id.should eq(@game.id)
  end

  it "should return in progress games where the player is the defender" do
    @other_player = Factory.create(:player)
    @game = Factory.create(:game, :challenged => @player, :challenger => @other_player, :complete => false)
    @player.in_progress_games(@other_player).first.id.should eq(@game.id)
  end

  it "should have a gravatar" do
    @player.gravatar_url.should include("gravatar.com")
  end
end

