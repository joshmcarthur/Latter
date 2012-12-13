require 'spec_helper'

describe ActivityController do

  login_player
  let(:activities) { FactoryGirl.create_list(:activity, 11).sort_by(&:created_at).reverse }

  describe "GET index" do
    it "should get a list of activities back" do
      activities
      get :index, :format => :json

      # Should only include ten items
      response.body.should eq activities[0..-2].to_json
    end

    it "should allow filtering activities after a certain point" do
      activities
      get :index, :format => :json, :last => activities[1].id

      # Should only include the last item
      response.body.should eq [activities.first].to_json
    end

    it "should allow token authentication to get a list of activities" do
      sign_out :player
      activities
      get :index, :format => :json, :auth_token => FactoryGirl.create(:player).authentication_token
    end
  end
end
