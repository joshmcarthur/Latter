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

  describe "#valid_html_badge" do
    before { helper.stub(request: OpenStruct.new(original_url: 'http://test.dev')) }
    subject { helper.valid_html_badge }

    it { subject.should include "validator.w3.org" }
    it { subject.should include Rack::Utils.escape("http://test.dev") }
    it { subject.should include "<img" }
    it { subject.should include "html5_badge.svg" }
  end

  describe "#travis_badge" do
    before { Latter::Application.config.travis_ci_id = "joshmcarthur/Latter" }
    subject { helper.travis_badge }
    it { subject.should include "href=\"https://travis-ci.org/joshmcarthur/Latter\"" }
  end

  describe "#application_version" do
    subject { helper.application_version }
    it { subject.should include "class=\"label\"" }
  end

end
