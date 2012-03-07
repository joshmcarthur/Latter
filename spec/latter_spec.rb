require 'spec_helper'
include Rack::Test::Methods

def login_as(player)
  post '/login', {:email => player.email}
end

def logout
  get '/logout'
end

describe Latter do
  before(:all) do
    @players = FactoryGirl.create_list(:player, 5)
  end

  describe Player do
    before(:all) do
      @player = @players.first
      @challenge = Factory.create(
        :challenge,
        :from_player => @player,
        :winner => @player,
        :to_player => @players.last,
        :completed => true
      )
    end

    it "should require an email address and name" do
      @player.email = ""
      @player.name = ""
      @player.valid?.should be_false
      @player.reload
    end

    it "should calculate a ranking" do
      # We should be numero uno
      @player.ranking.should eq(1)
      @player.ranking.should eq(1)
      # ....and no one else should be
      (@players - [@player]).each do |player|
        player.ranking.should_not eq(1)
      end
    end

    it "should refresh the cache of a ranking" do
      2.times do
        challenge = Factory.create(
          :challenge
        )

        challenge.set_score_and_winner(
          :from_player_score => 21,
          :to_player_score => 19
        )
      end

      @player.reload
      @player.ranking.should_not eq(1)
    end

    it "should calculate a winning percentage" do
      @player.winning_percentage.to_i.should be > 1
    end
    it "should have a gravatar" do
      @player.gravatar_url.should include("gravatar.com")
    end
  end

  describe Challenge do
    before(:all) do
      @challenge = Factory.create(
        :challenge,
        :from_player => Factory.create(:player),
        :to_player => Factory.create(:player)
      )
    end

    it "should create a challenge given valid attributes" do
      @challenge.save.should be_true
    end

    it "should not create a challenge with invalid attributes" do
      @challenge.from_player = nil
      @challenge.save.should_not be_true
    end

    describe "completion" do
      before(:each) do
        @challenge.set_score_and_winner(
          :from_player_score => 15,
          :to_player_score => 6
        )
        @challenge.completed = true # This is normally set from the controller
        @challenge.save
      end

      it "should complete a challenge" do
        @challenge.score.should eq("15 : 6")
        @challenge.winner.should eq(@challenge.from_player)
        @challenge.completed.should be_true
      end

      it "should correctly identify the winner" do
        @challenge.winner?(@challenge.from_player).should be_true
      end

      it "should correctly identify the loser" do
        @challenge.loser?(@challenge.to_player).should be_true
      end
      it "should correctly identify a drawer" do
        @challenge.set_score_and_winner(
          :from_player_score => 10,
          :to_player_score => 10
        )
        @challenge.drawer?(@challenge.from_player).should be_true
        @challenge.drawer?(@challenge.to_player).should be_true
      end
    end
  end

  describe "Mailing" do
    before(:all) do
      Pony.stub!(:deliver)
      @current_player = Factory.create(:player)
      @opponent = Factory.create(:player)

      login_as @current_player
    end

    after(:all) do
      logout
    end

    it "should send a new challenge notification" do
      Pony.should_receive(:deliver) do |mail|
        mail.to.should contain(@opponent.email)
        mail.from.should contain(@current_player.email)
        mail.subject.should eq("You've been Challenged!")
        mail.body.should_not be_empty
      end
      get "/player/#{@opponent.id}/challenge"
    end

    it "should send a completed challenge notification" do
      Pony.should_receive(:deliver) do |mail|
        mail.to.should contain([@opponent.email, @current_player.email])
        mail.from.should contain(@current_player.email)
        mail.subject.should eq("Challenge completed!")
        mail.body.should_not be_empty
      end
      post "/challenge/#{Challenge.last.id}/complete", {
        :challenge => {
          :from_player_score => 15,
          :to_player_score => 6
        }
      }
    end
  end

  describe "Application", :type => :request do
    before(:all) do
      @player = @players.first
    end
    describe "Access control" do
      before(:each) do
        logout
      end

      it "should require login" do
        visit '/'
        current_path.should eq("/login")
      end

      it "should login a valid user" do
        visit '/login'
        fill_in 'email', :with => @player.email
        click_on 'Login'
        current_path.should_not eq("/login")
      end

      it "should not login an invalid user" do
        visit "/login"
        fill_in "email", :with => "user@fake.com"
        click_on 'Login'
        current_path.should eq('/login')
      end
    end

    describe "Logged in" do
      before(:each) do
        visit "/logout"
        visit "/login"
        fill_in "email", :with => @player.email
        click_on "Login"
      end

      it "should load a list of players" do
        visit '/players'
        current_path.should eq("/players")
        all('li.player').should have(Player.count).things
      end

      it "should allow a new player to be created" do
        @new_player = Factory.build(:player)
        visit "/players/new"
        fill_in 'player[name]', :with => @new_player.name
        fill_in 'player[email]', :with => @new_player.email
        click_on 'Save'
        page.should have_content(@new_player.name)
      end

      #FIXME our CI can't run Selenium specs....
      it "should create a challenge", :js => true do
        visit "/players"
        within '.player:last-child' do
          click_link 'Challenge'
          page.should have_content 'Enter Score'
        end
      end

      it "should complete a challenge", :js => true do
        visit "/players"
        page.should have_content("Enter Score")
        within '.player:last-child' do
          click_link 'Enter Score'
        end

        fill_in 'challenge[from_player_score]', :with => 15
        fill_in 'challenge[to_player_score]', :with => 6
        click_button 'Submit Score'

        page.should_not have_content 'Enter Score'
      end

      it "should list challenges" do
        visit "/challenges"
        all('.challenge').should_not be_empty
      end

      it "should display a profile page for a player" do
        visit "/player/#{@player.id}"
        page.should have_content(@player.name)
      end
    end
  end
end
