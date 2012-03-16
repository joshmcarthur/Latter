require File.join(File.dirname(__FILE__), 'player')

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
  property :from_player_score, Integer
  property :to_player_score, Integer
  property :created_at, DateTime, :default => lambda { |record, property| Time.now }

  belongs_to :from_player, Player, :child_key => [:from_player_id]
  belongs_to :to_player, Player, :child_key => [:to_player_id]
  belongs_to :winner, Player, :child_key => [:winner_id]

  before :save, :name_players

  validates_with_block do
    if self.from_player and self.to_player
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

  def winner?(player)
    self.winner == player
  end

  def loser?(player)
    !self.winner?(player)
  end

  def drawer?(player)
    self.completed and self.winner_id.nil?
  end

  def score
    [from_player_score.to_s, to_player_score.to_s].join(SCORE_JOINER)
  end
  
  def winning_margin
    (from_player_score.to_i - to_player_score.to_i).abs
  end

  def set_score_and_winner(options)
    from_score, to_score = options[:from_player_score].to_i, options[:to_player_score].to_i

    self.from_player_score = from_score
    self.to_player_score = to_score

    if from_score > to_score
      self.winner = self.from_player
    elsif from_score < to_score
      self.winner = self.to_player
    else
      self.winner = nil
    end
    
    Player.recalculate_rankings

    self
  end
end
