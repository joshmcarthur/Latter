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
      all('.player').should have(Player.count).things
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
