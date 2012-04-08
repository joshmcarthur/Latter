class Game < Elo::Game
  include DataMapper::Resource

  property :id, Serial
  property :challenger_id, Integer, :required => true
  property :challenged_id, Integer, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :result, Float
  property :score, String

  belongs_to :challenger, 'Player'
  belongs_to :challenged, 'Player'

  before :create do
    Activity.new_game(self)
  end

  # Elo::Game uses :one and :two to reference players
  alias :one :challenger
  alias :two :challenged


  def complete!(scores = {})
    raise "Missing scores" unless scores.has_key?('challenger_score') and scores.has_key?('challenged_score')
    if scores['challenger_score'].to_i > scores['challenged_score'].to_i
      self.winner = challenger
      self.loser = challenged
      self.score = [scores['challenger_score'].to_i, scores['challenged_score'].to_i].join(' : ')
    else
      self.winner = challenged
      self.loser = challenger
      self.score = [scores['challenged_score'].to_i, scores['challenger_score'].to_i].join(' : ')
    end

    self.complete = true
    raise "Record invalid" unless self.valid?
  end

  def winner?(other_player)
    # If result is 1.0, then the challenger won
    self.result == 1.0 && other_player == self.challenger
  end

  def loser?(other_player)
    !self.winner?(other_player)
  end

end
