require 'spec_helper'

describe Badge do

  subject do
     FactoryGirl.build(:badge)
  end

  before do
    @player1 = FactoryGirl.build(:player, :name => "Player1")
    @player2 = FactoryGirl.build(:player, :name => "Player2")

    @player1.save
    @player2.save

    FactoryGirl.create(:game, :challenger => @player1, :challenged => @player2 )
    FactoryGirl.create(:game, :challenger => @player1)
  end

  it { is_expected.to respond_to(:awards) }
  it { is_expected.to respond_to(:players) }

  it "creates a valid badge type given valid attributes" do
    subject.save
    expect(subject).to be_persisted
  end

  it "does not create a valid badge type given invalid attributes" do
    subject.name = ""
    subject.save
    expect(subject).not_to be_persisted
  end

  it "should be able to be awarded and verified as awarded_to? in the model" do
    subject.save
    expect(subject.awarded_to?(@player1)).to be_falsey
    @player1.award!(subject)
    expect(subject.awarded_to?(@player1)).to be_truthy
  end

  it "should qualify correctly a badge for condition with no numeric component" do
    subject.award_rule = {:challenger_name_eq => "Player1"}
    expect(subject.qualifies?(@player1)).to be_truthy
  end

  it "should qualify correctly a badge for greater than n condition" do
    subject.award_rule = { :challenger_name_eq => "Player1"}
    subject.award_rule_count = 1 # more than one challenged game
    expect(subject.qualifies?(@player1)).to be_truthy

    subject.award_rule_count = 3 # more than three challenged games
    expect(subject.qualifies?(@player1)).to be_falsey
  end

  it "should qualify correctly for a badge for less than n condition" do
    subject.award_rule = { :challenger_name_eq => "Player1"}
    subject.award_rule_count = -5 # less than 5 challenged games
    expect(subject.qualifies?(@player1)).to be_truthy

    subject.award_rule = { :challenger_name_eq => "Player1"}
    subject.award_rule_count = -2 # less than 2 challenged games
    expect(subject.qualifies?(@player1)).to be_falsey
  end

  it "should set the award date correctly if specified" do
    subject.save
    @player1.award!(subject,1.week.ago)
    expect(subject.awarded_to?(@player1)).to be_truthy
    expect(subject.awards.where(:player_id => @player1.id).first.award_date < 6.days.ago).to be_truthy
  end

end
