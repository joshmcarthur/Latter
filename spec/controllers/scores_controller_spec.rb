require 'spec_helper'

describe ScoresController do

  let(:player) { FactoryGirl.create(:player) }
  let(:game) { FactoryGirl.create(:game, :challenger => player) }

  before :each do
    sign_in player
  end

  describe "GET /games/1/score/new" do
    it "should assign the game as @game" do
      get :new, :game_id => game.id
      assigns(:game).should eq game
    end

    it "should render an HTML template" do
      get :new, :game_id => game.id, :format => :html
      response.should render_template('scores/new')
    end

    it "should render a JS template" do
      get :new, :game_id => game.id, :format => :js
      response.should render_template('scores/new')
    end
  end

  describe "POST /games/1/score" do
    describe "success" do
      it "should assign the game as @game"
      it "should render the create template if requesting with JS"
      it "should redirect to the main players page with a flash message"
    end

    describe "failure" do
      it "should render the new template"
    end
  end
end
