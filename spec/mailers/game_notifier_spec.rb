require "spec_helper"

describe GameNotifier do

  let(:game) { FactoryGirl.create(:game) }

  describe "#new_game" do
    before :each do
      @mail = GameNotifier.new_game(game)
    end

    it "should send the email to the challenged player" do
      expect(@mail.to).to eq [game.challenged.email]
    end

    it "should contain the challenged and challenger player names" do
      expect(@mail.body).to include game.challenged.name
      expect(@mail.body).to include game.challenger.name
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
      expect(@mail.to).to eq [@game.challenged.email, @game.challenger.email]
    end

    it "should not send email to a player who has opted out" do
      @game.challenger.wants_challenge_completed_notifications = false
      @mail = GameNotifier.completed_game(@game)
      expect(@mail.to).not_to include @game.challenger.email
    end

    it "should not send email if both players have opted out" do
      @game.challenger.wants_challenge_completed_notifications = false
      @game.challenged.wants_challenge_completed_notifications = false

      expect(GameNotifier).not_to receive(:mail)
      @mail = GameNotifier.completed_game(@game)
    end

    it "should contain both scores" do
      expect(@mail.body).to include "21"
      expect(@mail.body).to include "15"
    end

    it "should identify the winner" do
      expect(@mail.body).to include "#{@game.challenger.name} won"
    end
  end
end
