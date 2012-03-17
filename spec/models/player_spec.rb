require 'spec_helper'

describe Player do
  before(:all) do
    @player = all_players.first
    @challenge = Factory.create(
      :challenge,
      :from_player => @player,
      :winner => @player,
      :to_player => all_players.last,
      :completed => true
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

  it "should let a player close to another challenge them" do
    @closest_player = all_players.select { |p| p.ranking == 2 }.first
    @closest_player.can_challenge?(@player).should be_true
  end

  it "should not let a player far away from another challenge them" do
    @furtherest_player = all_players.select { |p| p.ranking == 3 }.first
    @furtherest_player.can_challenge?(@player).should_not be_true
  end

  it "should refresh the cache of a ranking" do
    2.times do
      challenge = Factory.create(
        :challenge,
        :from_player => all_players.last,
        :to_player => @player
      )

      challenge.set_score_and_winner(
        :from_player_score => 21,
        :to_player_score => 1
      )
      challenge.completed = true
      challenge.save
    end

    @player.reload

    @player.ranking.should_not eq(1)
  end

  it "should return in progress challenges where the player is the challenger" do
    @other_player = Factory.create(:player)
    @challenge = Factory.create(:challenge, :from_player => @player, :to_player => @other_player, :completed => false)
    @player.in_progress_challenges(@other_player).first.id.should eq(@challenge.id)
  end

  it "should return in progress challenges where the player is the defender" do
    @other_player = Factory.create(:player)
    @challenge = Factory.create(:challenge, :to_player => @player, :from_player => @other_player, :completed => false)
    @player.in_progress_challenges(@other_player).first.id.should eq(@challenge.id)
  end

  it "should calculate a winning percentage" do
    @player.winning_percentage.to_i.should be > 1
  end
  it "should have a gravatar" do
    @player.gravatar_url.should include("gravatar.com")
  end
end

