require 'spec_helper'

describe "Points" do
  before(:each) do
    @challenge = Factory(:challenge)
    # Stub out from player's winning percentage to 50%
    @challenge.from_player.stub!(:winning_percentage).with(false).and_return(50)
  end
  it "should award points for a win" do
    @challenge.set_score_and_winner(
      :from_player_score => 21,
      :to_player_score => 19
    )
    @challenge.completed = true
    @challenge.save
    # #FIXME - I'm not sure if this is the best approach - it would
    # be better if we had hard numbers here
    @challenge.from_player.points.should == 150 # <- Player::WIN_POINTS * @challenge.from_player.winning_percentage(false)
  end

  it "should award bonus points for a thrashing" do
    @challenge.set_score_and_winner(
      :from_player_score => 21,
      :to_player_score => 9
    )
    @challenge.completed = true
    @challenge.save
    @challenge.from_player.points.should == 200 # <- Player::WIN_POINTS + Player::THRASH_POINTS * @challenge.from_player.winning_percentage(false)
  end

  it "should award consolation points for a near loss" do
    @challenge.set_score_and_winner(
      :from_player_score => 21,
      :to_player_score => 19
    )
    @challenge.completed = true
    @challenge.save
    @challenge.to_player.points.should == 0 # <- Player::CONSOLATION_POINTS * @challenge.from_player.winning_percentage(false)
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
    from_player.points.should == 600 # <- (2 * Player::WIN_POINTS) * @challenge.from_player.winning_percentage(false)
  end
end

