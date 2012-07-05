class Game < ActiveRecord::Base

  attr_accessible :complete, :result, :score, :challenger, :challenged, :challenged_id

  belongs_to :challenger, :class_name => 'Player', :touch => true
  belongs_to :challenged, :class_name => 'Player', :touch => true
  belongs_to :winner,     :class_name => 'Player'

  # Make player associations accessible to Elo
  alias :one :challenger
  alias :two :challenged

  # Add accessors to temporarily hold scores for players
  attr_accessor :challenger_score
  attr_accessor :challenged_score

  validates_presence_of :challenger, :challenged
  validates_associated  :challenger, :challenged
  validates_inclusion_of :complete, :in => [true, false]
  validates_format_of :score, :with => /\A[\d]+[\s]*:[\s]*[\d]+\Z/, :allow_nil => true
  validates_numericality_of :result, :minimum => -1.0, :maximum => 1.0, :allow_nil => true
  validate :inverse_game_does_not_exist?

  # Add a new game activity after a game is created
  after_create :notify_player, :log_activity

  # Public - result setter
  #
  # Every time a result is set, it tells the Player
  # objects to update their scores.
  #
  # result - The numerical result of the game - -1 = loss, 0 = draw, 1 = win
  #
  # Returns the set result
  def result=(result)
    super(result).tap do
      calculate
    end
  end

  # Public - calculate player rankings
  #
  # This method sends a method call to each player
  # to calculate their own score, and update them
  # selves accordingly.
  #
  # Returns the calculated game object
  def calculate
    if result
      [challenger, challenged].each do |player|
        player.send(:played, self)
      end
    end

    self
  end

  # Public - Complete a game between two players
  #
  # This method accepts a hash of player scores, and uses these
  # scores to calculate the result of the game, set the winner
  # and loser of the game, and updates the players
  #
  # scores - a hash of scores from params.
  #          expects :challenger_score and :challenged_score keys to be present
  #
  # Returns the completed game
  def complete!(scores = {})
    return false unless scores and scores.has_key?(:challenger_score) and scores.has_key?(:challenged_score)

    if scores[:challenger_score].to_i > scores[:challenged_score].to_i
      self.winner = challenger
      self.result = 1.0

      self.score = [scores[:challenger_score], scores[:challenged_score]].join ' : '
    else
      self.winner = challenged
      self.result = 0.0

      self.score = [scores[:challenged_score], scores[:challenger_score]].join ' : '
    end

    self.complete = true
    self.save!

    GameNotifier.completed_game(self).deliver!
    Activity.completed_game(self)

    self
  end

  # Public - Returns the score for a particular player in a game
  #
  # player - the player to find the score for
  #
  # Returns an integer score
  def score_for(player)
    score_components = self.score.split(/\s*:\s*/).map { |s| s.strip.to_i }
    self.winner?(player) ? score_components[0] : score_components[1]
  end

  # Public - Check whether a particular player won the game
  #
  # The winning status of a given player is worked out
  # by checking the result of the game - this value is a
  # numerical value between -1 and 1 that determines which
  # player won the game
  #
  # player - the player to check for winning
  #
  # Returns true if the given player won, or false if not
  def winner?(other_player)
    other_player == self.winner
  end

  # Public - Check whether a given player lost the game
  #
  # This method performs the inverse of Player#winner?
  #
  # Returns true if the given player lost or false if not
  def loser?(other_player)
    !winner?(other_player)
  end


  # Public - Return the winner of a game
  #
  # This method inspects the value of the game result
  # and returns the winner of the game. The result is
  # one of either -1, 0, or 1. If the result is -1, then
  # the challenged player won. If the result is 0, then the
  # game was a draw. If the result is 1, then the challenger won.
  def winner
    self.result == 1.0 ? self.challenger : self.challenged
  end

  # Public - Return the loser of a game
  #
  # This method returns the loser of the game, and operates
  # in the inverse way to the winner method.
  #
  # Returns the loser of the game
  def loser
    self.result != 1.0 ? self.challenger : self.challenged
  end

  # Public - Return the ratings for each player in the game
  #
  # Returns a hash structure containing players and their ratings:
  # {
  #   challenger => challenger rating,
  #   challenged => challenged rating
  # }
  def ratings
    {
      challenger => challenger_rating,
      challenged => challenged_rating
    }
  end

  # Public - Return a string representation of the game
  #
  # Returns a string in the format id-player 1 name-vs-player 2 name
  def to_param
    "#{self.id}-#{self.challenger.name.parameterize}-vs-#{self.challenged.name.parameterize}"
  end

  private

  # Private - Checks for the existence of an inverse game
  # and does not allow a game to be created if this is the case.
  #
  # This validation block ensures that one player cannot challenge
  # the other, if the other has already challenged them.
  #
  # Returns true if an inverse game does not exist, and false
  # if a game does already exist
  def inverse_game_does_not_exist?
    if self.challenger and self.challenged
      game = Game.where(
        :complete => false,
        :challenger_id => self.challenged.id,
        :challenged_id => self.challenger.id
      ).first

      game.nil? ? true : errors.add(:base, I18n.t('game.errors.game_in_progress')); false
    end
  end

  # Private - Build a rating object for the challenging player
  #
  # The rating is used to calculate the ranking for each player
  #
  # Returns a rating object
  def challenger_rating
    Rating.new(
      :result => result,
      :old_rating => challenger.rating,
      :other_rating => challenged.rating,
      :k_factor => challenger.k_factor
    )
  end

  # Private - Build a rating object for the challenged player
  def challenged_rating
    Rating.new(
      :result => (1.0 - result),
      :old_rating => challenged.rating,
      :other_rating => challenger.rating,
      :k_factor => challenged.k_factor
    )
  end

  # Private - Notify the challenged player that they have a pending game
  def notify_player
    GameNotifier.new_game(self).deliver!
  end

  # Private - Log the 'created game' activity
  #
  def log_activity
    Activity.new_game(self)
  end

end
