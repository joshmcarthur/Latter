require 'spec_helper'
require 'net/http'

describe WebHook do
  subject do
    FactoryGirl.build(:web_hook)
  end

  it { should validate_presence_of(:destination) }
  it { should validate_presence_of(:event) }
  it { should validate_uniqueness_of(:destination).scoped_to(:event) }
  it { should allow_value('game_completed').for(:event) }
  it { should_not allow_value('test').for(:event) }

  describe "#post!" do
    it "should use Net::HTTP to post the object as JSON" do
      Net::HTTP.should_receive(:post_form).with(URI.parse(subject.destination), subject.as_json)
      subject.post!(subject)
    end
  end
end
