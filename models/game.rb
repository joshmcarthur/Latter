class Game < Elo::Game
  include DataMapper::Resource

  property :id, Serial
  property :challenger_id, Integer, :required => true
  property :challenged_id, Integer, :required => true
  property :complete, Boolean, :required => true, :default => false
  property :result, Float
  property :score, String
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :challenger, 'Player'
  belongs_to :challenged, 'Player'

  before :create do
    Activity.new_game(self)
  end

  validates_with_block do
    # Find the inverse of this game
    game = Game.first(
      :complete => false,
      :challenger => self.challenged,
      :challenged => self.challenger
    )

    # If it exists, this game is invalid
    if game
      [false, 'A game is already in progress between these two players']
    else
      [true]
    end
  end

  # Elo::Game uses :one and :two to reference players
  alias :one :challenger
  alias :two :challenged

  # The below is from the Elo source code - we need to override it
  # to properly set the database attribute
  # Every time a result is set, it tells the Elo::Player
  # objects to update their scores.
  def result=(result)
    super(result).tap do
      calculate
    end
  end
  alias process_result result=


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
    self.save
    Activity.completed_game(self)

    self
  end

  def score_for(player)
    self.winner?(player) ? self.score.split(' : ')[0].strip.to_i : self.score.split(' : ')[1].strip.to_i
  end

  def winner?(other_player)
    # If result is 1.0, then the challenger won
    other_player == self.winner
  end

  def winner
    self.result == 1.0 ? self.challenger : self.challenged
  end

  def loser?(other_player)
    !self.winner?(other_player)
  end

end
