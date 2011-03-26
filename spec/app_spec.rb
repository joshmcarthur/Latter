require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Latter Players" do
  
  before(:each) do
    Player.destroy
    @player_attributes = {
      :name => "Jack Black",
      :email => "jack@example.org"
    }
    
    @player = Player.create(@player_attributes)
  end

  
  it 'should return a list of players' do
    get '/players' 
    last_response.should be_ok
    last_response.body.include?("Player").should == true
  end
  
  it 'should create a player given valid attributes' do
    Player.destroy
    post '/player', :player => @player_attributes
    last_response.status.should == 302
    Player.all.length.should == 1
  end  
  
  it 'should not create a player given invalid attributes' do
    Player.destroy
    post '/player', :player => @player_attributes.merge(:name => "")
    last_response.status.should == 400
    Player.all.length.should == 0
  end
  
  it 'should update a player' do
    post "/player/#{@player.id}", :player => @player_attributes.merge(:name => "Joe Bloggs")
    last_response.status.should == 302
    Player.first.name.should == "Joe Bloggs"
  end
  
  it 'should not update a player with invalid attributes' do
    post "/player/#{@player.id}", :player => @player_attributes.merge(:name => "Joe Bloggs", :email => nil)
    last_response.status.should == 400
    Player.first.name.should == @player_attributes[:name]
  end
  
  it 'should delete a player' do
    post "/player/#{@player.id}/delete"
    last_response.status.should == 302
    Player.all.length.should == 0
  end
  
end

describe "Latter - Challenges" do
  before(:each) do
    Player.destroy
    Challenge.destroy
    
    Player.create(:name => "Jack Black", :email => "jack@example.org")
    Player.create(:name => "Joe Bloggs", :email => "joe@example.org")
   
    @challenge_attributes = {:from_player_id => Player.all[0].id, :to_player_id => Player.all[1].id}
    @challenge = Challenge.create @challenge_attributes
  end
  
  it 'should return a list of challenges' do
    get '/challenges'
    last_response.should be_ok
    last_response.body.include?("Challenges").should == true
  end  
  
  it 'should create a challenge' do
    Challenge.destroy
    post "/challenge", :challenge => @challenge_attributes
    last_response.status.should == 302
    Challenge.all.length.should == 1
    Challenge.first.completed.should == false
  end
  
  it 'should update a challenge once' do
    post "/challenge/#{@challenge.id}/update", :challenge => {
      :winner_id => Player.first.id, :score => '21-10'
    }
    
    last_response.status.should == 302
    Challenge.first.completed.should == true 
    Challenge.first.winner.should == Player.first
    Challenge.first.score.should == "21-10"
  end
  
  it 'should not be able to update the challenge subsequent times' do
    post "/challenge/#{@challenge.id}/update", :challenge => {
      :winner_id => Player.first.id, :score => '21-10'
    }
    
    post "/challenge/#{@challenge.id}/update", :challenge => {
      :winner_id => Player.all[1].id, :score => '10-21'
    }
    
    last_response.status.should == 400
  end
  
  it 'should return a 404 error if an object cannot be found' do
    post "/challenge/9999/update"
    last_response.status.should == 404
  end
end  
