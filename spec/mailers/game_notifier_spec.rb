require "spec_helper"

describe GameNotifier do

  let(:game) { FactoryGirl.create(:game) }

  describe "#new_game" do
    before :each do
      @mail = GameNotifier.new_game(game)
    end

    it "should send the email to the challenged player" do
      @mail.to.should eq [game.challenged.email]
    end

    it "should contain the challenged and challenger player names" do
      @mail.body.should include game.challenged.name
      @mail.body.should include game.challenger.name
    end
  end

  describe "#completed_game" do
    before :each do
      @game = game
      @game.winner = @game.challenger
      @game.result = 1.0
      @game.score = "21 : 15"
      @game.complete = true

      @mail = GameNotifier.completed_game(@game)
    end

    it "should send the email to both players" do
      @mail.to.should eq [@game.challenged.email, @game.challenger.email]
    end

    it "should not send email to a player who has opted out" do
      @game.challenger.wants_challenge_completed_notifications = false
      @mail = GameNotifier.completed_game(@game)
      @mail.to.should_not include @game.challenger.email
    end

    it "should not send email if both players have opted out" do
      @game.challenger.wants_challenge_completed_notifications = false
      @game.challenged.wants_challenge_completed_notifications = false

      GameNotifier.should_not_receive(:mail)
      @mail = GameNotifier.completed_game(@game)
    end

    it "should contain both scores" do
      @mail.body.should include "21"
      @mail.body.should include "15"
    end

    it "should identify the winner" do
      @mail.body.should include "#{@game.challenger.name} won"
    end
  end
end
