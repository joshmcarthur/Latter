require 'spec_helper'

describe Game do
  subject(:game) do
    FactoryGirl.build(:game)
  end


  it "should create a game given valid attributes" do
    subject.save
    subject.should be_persisted
  end

  it "should not create a game given invalid attributes" do
    subject.challenger = nil
    subject.should_not be_persisted
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
    new_game.should_not be_valid
    new_game.errors[:base].should_not be_empty
  end

  it "should allow saving the game once the previous game is complete" do
    subject.save
    subject.complete!({challenged_score: 21, challenger_score: 10})
    new_game = FactoryGirl.build(:game, :challenger => subject.challenger, :challenged => subject.challenged)
    new_game.should be_valid
  end

  it "should not create a game when the challenger and challenged players are the same" do
    subject.challenger = subject.challenged
    subject.should_not be_valid
    subject.errors[:challenger].should_not be_blank
  end

  it "should re-calculate the player scores when a result is set" do
    subject.should_receive(:calculate)
    subject.result = 1.0
  end

  describe "complete scope" do
    it { subject.save; Game.complete.should_not include subject }
    it { subject.complete = true; subject.save; Game.complete.should include subject }
  end

  describe "calculation" do
    it "should update each player" do
      subject.challenger.should_receive(:played, :with => subject)
      subject.challenged.should_receive(:played, :with => subject)
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
      @challenged.rating.should eq @before_challenged_score
      @challenger.rating.should eq @before_challenger_score
    end

    it "should rollback correctly when the challenged won" do
      subject.complete! :challenger_score => 15, :challenged_score => 21
      subject.rollback!

      @challenger.reload
      @challenged.reload
      @challenged.rating.should eq @before_challenged_score
      @challenger.rating.should eq @before_challenger_score
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
      expect { subject }.to change(game, :complete?).to be_true
    end

    it "should save the correct game result" do
      expect { subject }.to change(game, :result).to 1.0
    end

    it "should correctly identify the winner" do
      subject
      game.winner?(game.challenger).should be_true
    end

    it "should correctly identify the loser" do
      subject
      game.loser?(game.challenged).should be_true
    end

    it "should return the correct score for each player" do
      subject
      game.score_for(game.challenger).should eq 15
      game.score_for(game.challenged).should eq 6
    end

    it "should create ratings for each player" do
      subject
      game.ratings.length.should eq 2
    end

    it "should save the change in rating for the challenged player" do
      subject
      game.challenger_rating_change.to_d.should eq game.send(:challenger_rating).send(:change).to_d
    end

    it "should save the change in rating for the challenger player" do
      subject
      game.challenged_rating_change.to_d.should eq game.send(:challenged_rating).send(:change).to_d
    end

    it "should log the game completion as an activity" do
      game.save! # This needs to be done to ensure that only one activity gets created
      expect { subject }.to change(PublicActivity::Activity, :count).by(1)
    end

  end
end
