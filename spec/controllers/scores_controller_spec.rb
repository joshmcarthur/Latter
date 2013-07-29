require 'spec_helper'

describe ScoresController do

  let(:player) { FactoryGirl.create(:player) }
  let(:game) { FactoryGirl.create(:game, :challenger => player) }
  let(:score_attributes) { {:game => {:challenged_score => 21, :challenger_score => 15 } } }

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
      it "should assign the game as @game" do
        post :create, {:game_id => game.id}.merge(score_attributes)
        assigns(:game).should eq game
      end

      it "should render the create template if requesting with JS" do
        post :create, {:format => 'js', :game_id => game.id}.merge(score_attributes)
        response.should render_template 'create'
      end

      it "should redirect to the main players page with a flash message if requesting with HTML" do
        post :create, {:game_id => game.id}.merge(score_attributes)
        response.should redirect_to root_path
        flash[:notice].should eq I18n.t('game.complete.saved')
      end
    end

    describe "failure" do
      it "should assign the game as @game" do
        post :create, {:game_id => game.id}
        assigns(:game).should eq game
      end

      it "should render the new template if requesting with JS" do
        post :create, {:format => 'js', :game_id => game.id}
        response.should render_template "new"
      end

      it "should redirect to the main players page with a flash message if requesting with HTML" do
        post :create, {:game_id => game.id}
        response.should redirect_to root_path
        flash[:alert].should eq I18n.t('game.complete.unsaved')
      end
    end
  end
end
