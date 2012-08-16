require 'spec_helper'

describe Game do
  subject do
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

  it "should not create a game when an inverse one is already in progress" do
    subject.save
    expect {
      FactoryGirl.create(:game, :challenged => subject.challenger, :challenger => subject.challenged)
    }.to raise_exception
  end

  it "should re-calculate the player scores when a result is set" do
    subject.should_receive(:calculate)
    subject.result = 1.0
  end

  describe "calculation" do
    it "should update each player" do
      subject.challenger.should_receive(:played, :with => subject)
      subject.challenged.should_receive(:played, :with => subject)
      subject.result = 1.0
    end
  end

  describe "activities" do
    it "should make a new challenge activity when the game is created" do
      Activity.should_receive(:new_game).with(subject).at_least(1).times
      subject.save
    end

    it "should make a completed game activity when the game is completed" do
      Activity.should_receive(:completed_game).with(subject)
      subject.complete! :challenger_score => 15, :challenged_score => 6
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
    before :each do
      subject.complete! :challenger_score => 15, :challenged_score => 6
      subject.reload
    end

    it "should complete a game" do
      subject.score.should eq "15 : 6"
      subject.winner.should eq subject.challenger
      subject.should be_complete
    end

    it "should save the correct game result" do
      subject.result.should eq 1.0
    end

    it "should correctly identify the winner" do
      subject.winner?(subject.challenger).should be_true
    end

    it "should correctly identify the loser" do
      subject.loser?(subject.challenged).should be_true
    end

    it "should return the correct score for each player" do
      subject.score_for(subject.challenger).should eq 15
      subject.score_for(subject.challenged).should eq 6
    end

    it "should create ratings for each player" do
      subject.ratings.length.should eq 2
    end

    it "should save the change in rating for the challenged player" do
      subject.challenger_rating_change.should eq subject.send(:challenger_rating).send(:change)
    end

    it "should save the change in rating for the challenger player" do
      subject.challenged_rating_change.should eq subject.send(:challenged_rating).send(:change)
    end
  end
end
