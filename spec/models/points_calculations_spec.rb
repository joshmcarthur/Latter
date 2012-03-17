require 'spec_helper'

describe "Points" do
  before(:each) do
    @challenge = Factory(:challenge)
  end
  it "should award points for a win" do
    @challenge.set_score_and_winner(
      :from_player_score => 21,
      :to_player_score => 19
    )
    @challenge.completed = true
    @challenge.save
    @challenge.from_player.points.should == Player::WIN_POINTS
  end

  it "should award bonus points for a thrashing" do
    @challenge.set_score_and_winner(
      :from_player_score => 21,
      :to_player_score => 9
    )
    @challenge.completed = true
    @challenge.save
    @challenge.from_player.points.should == Player::WIN_POINTS + Player::THRASH_POINTS
  end

  it "should award consolation points for a near loss" do
    @challenge.set_score_and_winner(
      :from_player_score => 21,
      :to_player_score => 19
    )
    @challenge.completed = true
    @challenge.save
    @challenge.to_player.points.should == Player::CONSOLATION_POINTS
  end

  it "should only count recent matches" do
    from_player = Factory.create(:player)
    to_player = Factory.create(:player)
    2.times do
      challenge = Factory.create(:challenge)
      challenge.from_player = from_player
      challenge.to_player = to_player
      challenge.set_score_and_winner(
        :from_player_score => 21,
        :to_player_score => 17
      )
      challenge.completed = true
      challenge.save
      challenge.created_at = Date.today - (Player::POINT_TIME_LIMIT + 3).to_i
      challenge.save
    end
    2.times do
      challenge = Factory.create(:challenge)
      challenge.from_player = from_player
      challenge.to_player = to_player
      challenge.set_score_and_winner(
        :from_player_score => 21,
        :to_player_score => 17
      )
      challenge.completed = true
      challenge.save
    end
    from_player.points.should == (2 * Player::WIN_POINTS)
  end
end

