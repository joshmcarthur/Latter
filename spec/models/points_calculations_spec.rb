require 'spec_helper'

describe "Points" do
  before(:each) do
    @game = Factory(:game)
    # Stub out from player's winning percentage to 50%
    @game.challenger.stub!(:winning_percentage).with(false).and_return(50)
  end
  it "should award points for a win" do
    @game.set_score_and_winner(
      :challenger_score => 21,
      :challenged_score => 19
    )
    @game.complete = true
    @game.save
    # #FIXME - I'm not sure if this is the best approach - it would
    # be better if we had hard numbers here
    @game.challenger.points.should == 1.5 # <- Player::WIN_POINTS * @game.challenger.winning_percentage(false)
  end

  it "should award bonus points for a thrashing" do
    @game.set_score_and_winner(
      :challenger_score => 21,
      :challenged_score => 9
    )
    @game.complete = true
    @game.save
    @game.challenger.points.should == 2.0 # <- Player::WIN_POINTS + Player::THRASH_POINTS * @game.challenger.winning_percentage(false)
  end

  it "should award consolation points for a near loss" do
    @game.set_score_and_winner(
      :challenger_score => 21,
      :challenged_score => 19
    )
    @game.complete = true
    @game.save
    @game.challenged.points.should == 0 # <- Player::CONSOLATION_POINTS * @game.challenger.winning_percentage(false)
  end

  it "should only count recent matches" do
    challenger = Factory.create(:player)
    challenged = Factory.create(:player)
    2.times do
      game = Factory.create(:game)
      game.challenger = challenger
      game.challenged = challenged
      game.set_score_and_winner(
        :challenger_score => 21,
        :challenged_score => 17
      )
      game.complete = true
      game.save
      game.created_at = Date.today - (Player::POINT_TIME_LIMIT + 3).to_i
      game.save
    end
    2.times do
      game = Factory.create(:game)
      game.challenger = challenger
      game.challenged = challenged
      game.set_score_and_winner(
        :challenger_score => 21,
        :challenged_score => 17
      )
      game.complete = true
      game.save
    end
    challenger.points.should == 6.0 # <- (2 * Player::WIN_POINTS) * @game.challenger.winning_percentage(false)
  end
end

