require 'spec_helper'

describe Api::V1::GamesController do
  let(:player) { FactoryGirl.create(:player, :authentication_token => "123abc") }
  let(:games) { FactoryGirl.create_list(:game, 5, :complete => true) }

  def valid_attributes
    {:auth_token => player.authentication_token, :format => :json, :player_id => player.id}
  end

  describe "GET index" do
    context "logged in" do
      before do
        player
        games
        get :index, valid_attributes
      end

      it { response.should be_ok }
      it { response.content_type.should eq "application/json" }
      it { assigns(:games).should have(5).games }
    end

    context "not logged in" do
      before do
        get :index, valid_attributes.except(:auth_token)
      end

      it { response.should_not be_ok }
      it { assigns(:games).should be_nil }
    end
  end
end
