require 'spec_helper'

describe BadgesController do
  login_player

  let(:badge) { FactoryGirl.build_stubbed(:badge) }
  before { allow(Badge).to receive_messages(find: badge) }

  describe "GET index" do
    before do
      get :index
    end

    it "should assign all badges to @badges" do
      expect(assigns(:badges)).to eq Badge.all
    end

    it "should render the view" do
      expect(response).to render_template :index
    end
  end

  describe "GET show" do
    before do
      get :show, :id => badge.id
    end

    it "should assign the badge to @badge" do
      expect(assigns(:badge)).to eq badge
    end

    it "should render the view" do
      expect(response).to render_template :show
    end
  end
end