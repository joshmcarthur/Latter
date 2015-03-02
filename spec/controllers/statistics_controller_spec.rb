require 'spec_helper'

describe StatisticsController do

  login_player

  describe "GET index" do
    it "should assign statistics to @data" do
      get :index
      expect(assigns(:data).symbolize_keys).to eq Game.statistics
    end

    it "should render the index template" do
      get :index
      expect(response).to render_template 'index'
    end
  end

end
