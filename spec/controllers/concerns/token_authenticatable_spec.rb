require 'spec_helper'

describe TokenAuthenticatable, type: :controller do
  let(:player) { FactoryGirl.create(:player) }

  controller(ApplicationController) do
    include TokenAuthenticatable

    def show
      render nothing: true, status: 200
    end
  end

  before do
    routes.draw { get "show" => "anonymous#show" }
  end

  it "should sign the player in if a valid token is provided" do
    get :show, auth_token: player.authentication_token
    expect(response).to be_success
  end

  it "should not sign the player in if an invalid token is provided" do
    get :show
    expect(response).not_to be_success
  end
end

