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

  end
  
  it { should respond_to (:awards) } 
  it { should respond_to (:players) }
  
  it "creates a valid badge type given valid attributes" do
    subject.save
    subject.should be_persisted
  end

  it "does not create a valid badge type given invalid attributes" do
    subject.name = ""
    subject.save
    subject.should_not be_persisted
  end

  it "should be correctly awarded and verified as awarded_to? in the model" do

    subject.save
    subject.awarded_to?(@player1).should be_false
    @player1.award!(subject)
    subject.awarded_to?(@player1).should be_true
  end

  it "should have the award_rule correctly tested" do

    subject.award_rule = { :challenger_name_eq => "Player1"}
    subject.save
    subject.qualifies?(@player1).should be_true
  end 

  
end
