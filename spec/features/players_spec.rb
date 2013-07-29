require 'spec_helper'

describe "Players" do
  
  before do
     @player1 = FactoryGirl.create(:player)
     @player2 = FactoryGirl.create(:player)
  end
  
  it "should all be shown on the players page before and after logging in" do
    visit players_path
    
    Player.all.each do |item|
      page.should have_selector("h3", :text => item.name )
    end
    
    sign_in(@player1)
    
    Player.all.each do |item|
      page.should have_selector("h3", :text => item.name )
    end
    
  end
    
end


