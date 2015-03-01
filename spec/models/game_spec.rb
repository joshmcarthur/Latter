require 'spec_helper'

describe Game do
  subject(:game) do
    FactoryGirl.build(:game)
  end


  it "should create a game given valid attributes" do
    subject.save
    expect(subject).to be_persisted
  end

  it "should not create a game given invalid attributes" do
    subject.challenger = nil
    expect(subject).not_to be_persisted
  end

  it "should create an activity when a game is created" do
    expect { subject.save }.to change(PublicActivity::Activity, :count).by(1)
  end

  it "should not create a game when an inverse one is already in progress" do
    subject.save
    expect {
      FactoryGirl.create(:game, :challenged => subject.challenger, :challenger => subject.challenged)
    }.to raise_exception
  end

  it "should not create a game when an identical one is already is progress" do
    subject.save
    new_game = FactoryGirl.build(:game, :challenger => subject.challenger, :challenged => subject.challenged)
    expect(new_game).not_to be_valid
    expect(new_game.errors[:base]).not_to be_empty
  end

  it "should allow saving the game once the previous game is complete" do
    subject.save
    subject.complete!({challenged_score: 21, challenger_score: 10})
    new_game = FactoryGirl.build(:game, :challenger => subject.challenger, :challenged => subject.challenged)
    expect(new_game).to be_valid
  end

  it "should not create a game when the challenger and challenged players are the same" do
    subject.challenger = subject.challenged
    expect(subject).not_to be_valid
    expect(subject.errors[:challenger]).not_to be_blank
  end

  it "should re-calculate the player scores when a result is set" do
    expect(subject).to receive(:calculate)
    subject.result = 1.0
  end

  describe "complete scope" do
    it { subject.save; expect(Game.complete).not_to include subject }
    it { subject.complete = true; subject.save; expect(Game.complete).to include subject }
  end

  describe "calculation" do
    it "should update each player" do
      expect(subject.challenger).to receive(:played).with(subject)
      expect(subject.challenged).to receive(:played).with(subject)
      subject.result = 1.0
    end
  end

  describe "rollback" do
    before :each do
      subject.save!

      @challenged = subject.challenged
      @challenger = subject.challenger

      @before_challenger_score = @challenger.rating
      @before_challenged_score = @challenged.rating
    end

    it "should rollback correctly when the challenger won" do
      subject.complete! :challenger_score => 21, :challenged_score => 15
      subject.rollback!

      @challenger.reload
      @challenged.reload
      expect(@challenged.rating).to eq @before_challenged_score
      expect(@challenger.rating).to eq @before_challenger_score
    end

    it "should rollback correctly when the challenged won" do
      subject.complete! :challenger_score => 15, :challenged_score => 21
      subject.rollback!

      @challenger.reload
      @challenged.reload
      expect(@challenged.rating).to eq @before_challenged_score
      expect(@challenger.rating).to eq @before_challenger_score
    end
  end

  describe "completion" do
    subject { game.complete!(challenger_score: 15, challenged_score: 6); }

    it "should set the score" do
      expect { subject }.to change(game, :score).to("15 : 6")
    end

    it "should set the winner" do
      expect { subject }.to change(game, :winner).to(game.challenger)
    end

    it "should mark the game as complete" do
      expect { subject }.to change(game, :complete?).to be_truthy
    end

    it "should save the correct game result" do
      expect { subject }.to change(game, :result).to 1.0
    end

    it "should correctly identify the winner" do
      subject
      expect(game.winner?(game.challenger)).to be_truthy
    end

    it "should correctly identify the loser" do
      subject
      expect(game.loser?(game.challenged)).to be_truthy
    end

    it "should return the correct score for each player" do
      subject
      expect(game.score_for(game.challenger)).to eq 15
      expect(game.score_for(game.challenged)).to eq 6
    end

    it "should create ratings for each player" do
      subject
      expect(game.ratings.length).to eq 2
    end

    it "should save the change in rating for the challenged player" do
      subject
      expect(game.challenger_rating_change.to_f).to eq game.send(:challenger_rating).send(:change).to_f
    end

    it "should save the change in rating for the challenger player" do
      subject
      expect(game.challenged_rating_change.to_f).to eq game.send(:challenged_rating).send(:change).to_f
    end

    it "should log the game completion as an activity" do
      game.save! # This needs to be done to ensure that only one activity gets created
      expect { subject }.to change(PublicActivity::Activity, :count).by(1)
    end

  end
end
