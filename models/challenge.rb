class Challenge
  include DataMapper::Resource
  
  property :id, Serial, :required => true
  property :from_player_id, Integer, :required => true
  property :to_player_id, Integer, :required => true
  property :completed, Boolean, :required => true, :default => false
  property :winner_id, Integer
  property :score, String
  
  belongs_to :from_player, Player, :child_key => [:from_player_id]
  belongs_to :to_player, Player, :child_key => [:to_player_id]
  belongs_to :winner, Player, :child_key => [:winner_id]
  
end
