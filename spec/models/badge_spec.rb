require 'spec_helper'

describe Badge do
  
  subject do
     FactoryGirl.build(:badge)
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
  
end
