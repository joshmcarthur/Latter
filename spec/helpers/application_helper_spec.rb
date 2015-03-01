require 'spec_helper'
require 'ostruct'

describe ApplicationHelper do

  describe "#cache_key_for" do
    before :all do
      @object = FactoryGirl.create(:player)
      @version = Latter::Application.config.version
    end

    it "should return a cache key for an object" do
      expect(cache_key_for(@object)).to eq [@version, @object, :en]
    end

    it "should return a cache key for an object with a scope" do
      expect(cache_key_for(@object, "profile")).to eq [@version, @object, "profile", :en]
    end

    it "should return a different cache key when the application version is changed" do
      expect(Latter::Application.config).to receive(:version).and_return "vX"
      expect(cache_key_for(@object)).not_to eq [@version, @object, :en]
    end
  end

  describe "#valid_html_badge" do
    before { helper.stub(request: OpenStruct.new(original_url: 'http://test.dev')) }
    subject { helper.valid_html_badge }

    it { expect(subject).to include "validator.w3.org" }
    it { expect(subject).to include Rack::Utils.escape("http://test.dev") }
    it { expect(subject).to include "<img" }
    it { expect(subject).to include "html5_badge.svg" }
  end

  describe "#travis_badge" do
    before { Latter::Application.config.travis_ci_id = "joshmcarthur/Latter" }
    subject { helper.travis_badge }
    it { expect(subject).to include "href=\"https://travis-ci.org/joshmcarthur/Latter\"" }
  end

  describe "#application_version" do
    subject { helper.application_version }
    it { expect(subject).to include "class=\"label\"" }
  end

end
