require 'spec_helper'

describe "Authentication" do
  
  let(:player) { FactoryGirl.create(:player, :confirmed_at => nil, :changed_password => false) }
  let(:logged_in_player) do
    player.confirmed_at = Time.now
    player.changed_password = true
    player.save!

    player
  end

  it "should log in a player" do

    visit new_player_session_path
    fill_in 'player_email', :with => logged_in_player.email
    fill_in 'player_password', :with => logged_in_player.password
    click_on 'Sign in'

    page.should have_content 'Log out'
  end

  it "should require a player confirm their account before logging in" do
    visit new_player_session_path
    fill_in 'player_email', :with => player.email
    fill_in 'player_password', :with => player.password
    click_on 'Sign in'

    current_path.should eq new_player_session_path
    page.should have_content I18n.t('devise.failure.unconfirmed')
  end

  it "should require a player change their password when first logging in" do
    player.confirmed_at = Time.now
    player.save

    visit new_player_session_path
    fill_in 'player_email', :with => player.email
    fill_in 'player_password', :with => player.password
    click_on 'Sign in'

    current_path.should eq edit_player_password_path
  end

  it "should log the player in after changing password for the first time" do
    player.confirmed_at = Time.now
    player.save

    visit new_player_session_path
    fill_in 'player_email', :with => player.email
    fill_in 'player_password', :with => player.password
    click_on 'Sign in'

    fill_in 'player_password', :with => 'test123'
    fill_in 'player_password_confirmation', :with => 'test123'
    click_on 'Change Password'

    current_path.should eq root_path
    page.should have_content 'Log out'
  end

  it "should log out a player" do
    visit new_player_session_path
    fill_in 'player_email', :with => logged_in_player.email
    fill_in 'player_password', :with => logged_in_player.password
    click_on 'Sign in'

    page.should have_content 'Log out'
    click_on 'Log out'

    page.should have_content 'Log in'
  end
end
