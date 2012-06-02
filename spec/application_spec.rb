require 'spec_helper'

describe "Application", :type => :request do
  before(:all) do
    @player = all_players.first
  end

  describe "Access control" do
    before(:each) do
      visit '/logout'
    end

    it "should require login" do
      visit "/players/#{@player.id}"
      current_path.should eq("/login")
    end

    it "should login a valid user", :js => true do
      visit '/login'
      fill_in 'email', :with => @player.email
      fill_in 'password', :with => @player.password
      click_button 'Login'
      current_path.should_not eq("/login")
    end

    it "should not login an invalid user" do
      visit "/login"
      fill_in "email", :with => "user@fake.com"
      fill_in "password", :with => "password"
      click_button 'Login'
      current_path.should eq('/login')
    end
  end

  describe "Logged in" do
    before(:each) do
      visit "/logout"
      visit "/login"
      fill_in "email", :with => @player.email
      fill_in "password", :with => @player.password
      click_button "Login"
    end

    it "should load a list of players" do
      visit '/players'
      current_path.should eq("/players")
      all('.player').should have(Player.count).things
    end

    it "should allow a new player to be created" do
      @new_player = FactoryGirl.build(:player)
      visit "/players/new"
      fill_in 'player[name]', :with => @new_player.name
      fill_in 'player[email]', :with => @new_player.email
      fill_in 'player[password]', :with => @new_player.password
      fill_in 'player[password_confirmation]', :with => @new_player.password
      click_on 'Save'
      page.should have_content(@new_player.name)
    end

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

      fill_in 'game[challenger_score]', :with => 15
      fill_in 'game[challenged_score]', :with => 6
      click_button 'Submit Score'

      page.should_not have_content 'Enter Score'
    end

    it "should list games" do
      visit "/games"
      all('.game').should_not be_empty
    end

    it "should display a profile page for a player" do
      visit "/player/#{@player.id}"
      page.should have_content(@player.name)
    end

    it "should show an edit page for the current player" do
      visit '/player/edit'
      page.should have_content @player.name
    end

    it "should update the player" do
      visit '/player/edit'
      fill_in 'player[email]', :with => 'testing@latter.dev'
      fill_in 'player[current_password]'
      fill_in 'player[password]', :with => @player.password
      fill_in 'player[password_confirmation]', :with => @player.password
      click_button 'Save'

      # We need to wait for the application to process and save the record
      sleep 1

      @player.reload
      @player.email.should eq "testing@latter.dev"
    end

    it "should not update the player if their password is not provided"

    it "should open the live stream modal", :js => true do
      visit '/players'
      click_link 'Watch'
      page.should have_selector '.modal#live_stream'
    end

    it "should close the live stream modal and delete the node", :js => true do
      visit '/players'
      click_link 'Watch'
      page.should have_selector '.modal#live_stream'
      within '.modal#live_stream' do
        click_button 'x'
      end

      page.should_not have_selector '.modal#live_stream'
    end

    it "should logout" do
      visit '/logout'
      visit '/games' # <- This page needs a login
      current_path.should eq '/login'
    end
  end

  describe "Logged out" do
    it "can access the players index" do
      visit '/players'
      page.should have_selector('.players')
    end

    it "cannot access a players page" do
      visit "/players/#{@player.id}"
      current_path.should eq "/login"
    end

    it "cannot see a list of games" do
      visit "/games"
      current_path.should eq "/login"
    end

    it "cannot create a challenge" do
      post "/players/#{@player.id}/challenge"
      last_response.should be_redirect
    end
  end

  describe "Activity Stream" do
    before(:all) do
      logout
      login_as(all_players.first)
      @activities = []
      5.times do
        @activities << FactoryGirl.create(:activity)
        sleep 1
      end
    end

    it "should fetch the five most recent activities" do
      get '/activities.json'
      JSON.parse(last_response.body).should have(5).things
    end

    it "should return activities with valid information" do
      get '/activities.json'
      JSON.parse(last_response.body).first['message'].should match(/Message/)
    end

    it "should allow passing in a last modified date to filter activities" do
      get '/activities.json', :modified_since => @activities[2..-1].first.created_at
      last_response.body.should eq @activities[3..-1].to_json
    end
  end

  describe "Pages" do
    before :each do
      logout
      login_as(all_players.first)
    end

    it "should get the 'about' page" do
      get '/pages/rules'
      last_response.should be_ok
    end

    it "should not allow POST requests to pages" do
      post '/pages/rules'
      last_response.status.should be 404
    end

    it "should 404 when a page is not found" do
      get '/pages/fake'
      last_response.status.should be 404
    end

  end

  describe "Players" do
    it "should show each players points", :js => true do
      visit '/players'
      within '.players .player:first' do
        page.should have_content "Points: #{all_players.first.ranking}"
      end
    end
  end

  describe "Statistics" do
    before(:each) do
      visit "/logout"
      visit "/login"
      fill_in "email", :with => @player.email
      fill_in "password", :with => @player.password
      click_button "Login"
    end

    it "should show table of users", :js => true do
      visit '/statistics'
      page.should have_selector('table#statistics tbody tr')
    end
  end

  describe "Misc" do
    it "sets a host" do
      Latter.settings.host.should eq "http://latter.dev"
    end

    it "sets a database" do
      DataMapper.repository(:default).adapter.options[:path].should eq ":memory:"
    end

    it "sets mailing options" do
      Latter::PONY_OPTIONS.should be_a(Hash)
    end
  end
end
