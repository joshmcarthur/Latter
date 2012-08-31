require 'spec_helper'

describe "Badges" do

  before do
    @badge1 = FactoryGirl.create(:badge)
    @badge2 = FactoryGirl.create(:badge)
    @badge3 = FactoryGirl.create(:badge)
   
    @player = FactoryGirl.create(:player, name: "a player", email:"aplayer@sample.com")

    @player.badges << @badge1
    @player.badges << @badge2
    
    sign_in(@player)
  end

  it "should all be shown in the badges index" do
    visit badges_path
    Badge.all.each do |item|
      page.should have_selector("td", text: item.name)
    end
  end

  it "should display in the players' panel in the players list" do
    visit players_path

    @player.badges.each do |item|
      page.should have_xpath("//img[@src='"+item.image_url+"']" )
    end
  end
  
  it "should display on the players' profile page" do
    visit player_path(@player)

    @player.badges.each do |item|
      page.should have_xpath("//img[@src='"+item.image_url+"']" )
    end
  end

end