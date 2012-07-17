require 'spec_helper'

describe StatisticsController do

  login_player

  describe "GET index" do
    it "should assign statistics to @data" do
      get :index
      assigns(:data).symbolize_keys.should eq Game.statistics
    end

    it "should render the index template" do
      get :index
      response.should render_template 'index'
    end
  end

end
