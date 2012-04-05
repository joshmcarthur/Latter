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

  it "should calculate a ranking" do
    # We should be numero uno
    Player.recalculate_rankings
    @player.ranking.should eq(1)
    # ....and no one else should be
    (all_players - [@player]).each do |player|
      player.ranking.should_not eq(1)
    end
  end

  it "should let a player close to another game them" do
    @closest_player = all_players.select { |p| p.ranking == 2 }.first
    @closest_player.can_game?(@player).should be_true
  end

  it "should not let a player far away from another game them" do
    @furtherest_player = all_players.select { |p| p.ranking == 3 }.first
    @furtherest_player.can_game?(@player).should_not be_true
  end

  it "should refresh the cache of a ranking" do
    2.times do
      game = Factory.create(
        :game,
        :challenger => all_players.last,
        :challenged => @player
      )

      game.set_score_and_winner(
        :challenger_score => 21,
        :challenged_score => 1
      )
      game.complete = true
      game.save
    end

    @player.reload

    @player.ranking.should_not eq(1)
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

  it "should calculate a winning percentage" do
    @player.winning_percentage.to_i.should be > 1
  end
  it "should have a gravatar" do
    @player.gravatar_url.should include("gravatar.com")
  end
end

