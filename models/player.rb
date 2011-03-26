class Player
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :required => true
  property :email, String, :required => true
  
  has n, :won_challenges, 'Challenge', :child_key => [:winner_id]
  has n, :initiated_challenges, 'Challenge', :child_key => [:from_player_id]
  has n, :challenged_challenges, 'Challenge', :child_key => [:to_player_id]
  
  def challenges
    initiated_challenges + challenged_challenges
  end
  
  def total_wins
    self.won_challenges.length
  end
end
