require 'spec_helper'

describe Award do

    let(:player) { FactoryGirl.create(:player) }
    let(:badge) { FactoryGirl.create(:badge) }
    let(:award) { FactoryGirl.create(:award, badge_id:badge, player_id:player) }
    let(:datetoday) { Date.new(2011,1,1) }
    let(:datedaward) { FactoryGirl.create(:award, badge_id:badge, player_id:player, award_date:datetoday) }

    subject { award }

    it "should be able to be assigned to a player" do
      award.should be_valid
    end
  
    it "should have a correct default award_date" do
       award.award_date.should eq award.created_at.to_date
    end
    
      it "should have a correctly specified award_date" do
         datedaward.award_date.should eq datetoday
      end
  
    describe "when player id is not present" do
      before { award.player_id = nil }
      it { should_not be_valid }
    end

    describe "when badge id is not present" do
      before { award.badge_id = nil }
      it { should_not be_valid }
    end
  
end
