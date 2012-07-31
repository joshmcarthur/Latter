require 'spec_helper'

describe Award do

    let(:player) { FactoryGirl.create(:player) }
    let(:badge) { FactoryGirl.create(:badge) }
    let(:award) { player.awards.build(badge_id: badge.id) }

    subject { award }

    it "An award should be able to be assigned to a player" do
      award.should be_valid
    end
  
    describe "when player id is not present" do
      before { award.player_id = nil }
      it { should_not be_valid }
    end

    describe "when badge id is not present" do
      before { award.badge_id = nil }
      it { should_not be_valid }
    end
  
    describe "default award_date should be set correctly" do
       award.award_date.should eq award.created_at.to_date
    end 
    
end
