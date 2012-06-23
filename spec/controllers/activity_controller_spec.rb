require 'spec_helper'

describe ActivityController do

  login_player

  describe "GET index" do
    it "should get a list of activities back" do
      activities = FactoryGirl.create_list(:activity, 5).sort_by(&:created_at)
      get :index, :format => :json
      response.body.should eq activities.to_json
    end
  end

end
