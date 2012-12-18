require 'spec_helper'

describe BadgesController do
  login_player

  let(:badge) { FactoryGirl.create(:badge) }

  describe "GET index" do
    before do
      get :index
    end

    it "should assign all badges to @badges" do
      assigns(:badges).should eq Badge.all
    end

    it "should render the view" do
      response.should render_template :index
    end
  end

  describe "GET show" do
    before do
      get :show, :id => badge.id
    end

    it "should assign the badge to @badge" do
      assigns(:badge).should eq badge
    end

    it "should render the view" do
      response.should render_template :show
    end
  end
end