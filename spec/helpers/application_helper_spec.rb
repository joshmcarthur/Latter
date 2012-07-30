require 'spec_helper'

describe ApplicationHelper do

  describe "#cache_key_for" do
    before :all do
      @object = FactoryGirl.create(:player)
      @version = Latter::Application.config.version
    end

    it "should return a cache key for an object" do
      cache_key_for(@object).should eq [@version, @object, :en]
    end

    it "should return a cache key for an object with a scope" do
      cache_key_for(@object, "profile").should eq [@version, @object, "profile", :en]
    end

    it "should return a different cache key when the application version is changed" do
      Latter::Application.config.should_receive(:version).and_return "vX"
      cache_key_for(@object).should_not eq [@version, @object, :en]
    end
  end
end
