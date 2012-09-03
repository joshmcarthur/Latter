require 'spec_helper'

describe Award do

    let(:player) { FactoryGirl.create(:player) }
    let(:badge) { FactoryGirl.create(:badge) }
    let(:award) { player.award!(badge) }
    let(:datelastmonth) { 1.month.ago }
    let(:datedaward) { player.award!(badge, datelastmonth) }

    subject { award }

    it "should be able to be assigned to a player" do
      award.should be_valid
    end
  
    it "should have a correct default award_date" do
       award.award_date.should eq award.created_at
    end
    
    it "should have a correctly specified award_date" do
       datedaward.award_date.should eq datelastmonth
    end

    it "should have a correctly specified expiry" do
    
    end
  
    describe "when player id is not present" do
      before { award.player_id = nil }
      it { should_not be_valid }
    end

    describe "when badge id is not present" do
      before { award.badge_id = nil }
      it { should_not be_valid }
    end

    it "should create an activity when the record is saved" do
      Activity.should_receive(:awarded_badge).with(award).at_least(1).times
      award.save
    end
    
end
