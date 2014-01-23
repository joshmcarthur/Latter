require 'spec_helper'

describe Award do

    let(:player) { FactoryGirl.create(:player) }
    let(:badge) { FactoryGirl.create(:badge) }
    let(:expiring_badge) {FactoryGirl.create(:badge, :expire_in_days => 1, :allow_duplicates => true)}
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

    it "should not be listed after it has expired" do
       player.award!(expiring_badge,2.days.ago)
       player.badges.should_not include expiring_badge
    end

     it "should be listed before it has expired" do
       player.award!(expiring_badge,0.days.ago)
       player.badges.should include expiring_badge
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
