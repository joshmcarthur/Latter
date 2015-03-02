require 'spec_helper'

describe Alert do

  subject do
    FactoryGirl.build(:alert)
  end

  it "should create a valid example" do
    expect {
      subject.save!
    }.to_not raise_error
  end

  it "should not create an invalid example" do
    subject.category = 'nothing'
    expect {
      subject.save!
    }.to raise_error
  end

  describe "saving" do
    it "should set an default activation date" do
      subject.save
      expect(subject.activate_at).to be_within(5.seconds).of(DateTime.current)
    end

    it "should not set an activation date if one is already assigned" do
      date = DateTime.yesterday
      subject.activate_at = date
      subject.save
      expect(subject.activate_at).to eq date
    end

    it "should set a default expiry date" do
      subject.expire_at = nil
      subject.save
      expect(subject.expire_at).to be_within(5.seconds).of(DateTime.current + 1.day)
    end

    it "should not set an expiry date if one is already assigned" do
      date = DateTime.yesterday
      subject.expire_at = date
      subject.save
      expect(subject.expire_at).to eq date
    end
  end

  describe "scopes" do
    it "should find an active alert" do
      subject.save!
      expect(Alert.current).to include subject
    end

    it "should not find an active alert" do
      subject.expire_at = DateTime.current
      subject.save!

      sleep 1

      expect(Alert.current.include?(subject)).to be_falsey
    end
  end
end
