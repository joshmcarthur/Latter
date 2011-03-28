class Challenge
  include DataMapper::Resource
  SCORE_JOINER = " : "
  
  property :id, Serial, :required => true
  property :from_player_id, Integer, :required => true
  property :from_player_name, String
  property :to_player_id, Integer, :required => true
  property :to_player_name, String
  property :completed, Boolean, :required => true, :default => false
  property :winner_id, Integer
  property :score, String
  property :created_at, DateTime, :default => lambda { |record, property| Time.now }
  
  belongs_to :from_player, Player, :child_key => [:from_player_id]
  belongs_to :to_player, Player, :child_key => [:to_player_id]
  belongs_to :winner, Player, :child_key => [:winner_id]
  
  before :save, :name_players
  
  validates_with_block do
    if self.from_player && self.to_player
      if self.from_player == self.to_player
        [false, "A Player can't play themselves, that's just sad!"]
      else
        true
      end
    end
  end
  
  def name_players
    self.from_player_name = self.from_player.name if self.from_player
    self.to_player_name = self.to_player.name if self.to_player
  end
  
  def set_score_and_winner(options)
    return unless options && options[:from_player_score] && options[:to_player_score]
    from_score, to_score = options[:from_player_score].to_i, options[:to_player_score].to_i
    
    if from_score > to_score
      self.winner = self.from_player
    elsif from_score < to_score
      self.winner = self.to_player
    end
    self.score = [from_score.to_s, to_score.to_s].join(SCORE_JOINER)
  end    
end
