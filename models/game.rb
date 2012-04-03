class Game < Elo::Game
  include DataMapper::Resource

  property :id, Serial
  property :challenger_id, Integer, :required => true
  property :challenged_id, Integer, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :result, Float

  belongs_to :challenger, 'Player'
  belongs_to :challenged, 'Player'

  # Elo::Game uses :one and :two to reference players
  alias :one :challenger
  alias :two :challenged


  def complete!(scores = {})
    raise "Missing scores" unless scores.has_key?('challenger_score') and scores.has_key?('challenged_score')
    if scores['challenger_score'].to_i > scores['challenged_score'].to_i
      self.winner = challenger
      self.loser = challenged
    else
      self.winner = challenged
      self.loser = challenger
    end

    self.complete = true
    raise "Record invalid" unless self.valid?
  end
end
