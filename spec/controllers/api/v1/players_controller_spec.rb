require 'spec_helper'

describe Api::V1::PlayersController do
  let(:players) { FactoryGirl.build_list(:player, 25) }
  let(:player) { FactoryGirl.create(:player, :authentication_token => "123abc") }

  def valid_attributes
    {:auth_token => player.authentication_token, :format => :json}
  end

  before do
    Player.stub(:order).and_return(players)
  end

  describe "GET show" do
    context "logged in" do
      before do
        player
        get :show, valid_attributes
      end

      it { response.should be_ok }
      it { response.content_type.should eq "application/json" }
      it { assigns(:player).should eq controller.current_player }
      it { response.should render_template :show }
    end
  end

  describe "GET index" do
    context "logged in" do
      before do
        player
        get :index, valid_attributes
      end

      it { response.should be_ok }
      it { response.content_type.should eq "application/json" }
      it { assigns(:players).should have(25).players }
    end

    context "not logged in" do
      before do
        get :index, {:format => :json }
      end

      it { response.should_not be_ok }
      it { assigns(:players).should be_nil }
    end
  end
end
