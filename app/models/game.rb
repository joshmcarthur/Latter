class Game < ActiveRecord::Base

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
  validate :in_progress_game_does_not_exist?, :on => :create
  validate :challenger_and_challenged_are_not_the_same

  scope :complete, -> { where(:complete => true) }

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

    self.set_rating_changes

    self.save!

    GameNotifier.completed_game(self).deliver!
    Activity.completed_game(self)

    # Check all badges to see whether this result awards badges
    self.award_badges

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

  # Public - Find game counts for the last 3 months, by week
  #
  # Uses a PostgreSQL date technique to efficiently query counts
  # from the database.
  #
  # Returns a hash of counts
  def self.statistics
    @by_week = Game.select("DATE_TRUNC('week', created_at) AS week, count(*) AS games").
      group('week').
      order('week').
      where(:complete => true).
      where('created_at > ?', DateTime.now.beginning_of_month)

    @by_day = Game.select("DATE_TRUNC('day', created_at) AS day, count(*) AS games").
      group('day').
      order('day').
      where(:complete => true).
      where('created_at > ?', DateTime.now.beginning_of_week)

    @by_challenger = Game.group('challenger_id').
      count.
      map do |player_id, count|
        [Player.select('name').find(player_id).name, count] rescue nil
      end.
      compact

    @by_challenged = Game.group('challenged_id').
      count.
      map do |player_id, count|
        [Player.select('name').find(player_id).name, count] rescue nil
      end.
      compact

    {
      :by_week => @by_week,
      :by_day  => @by_day,
      :by_challenger => @by_challenger,
      :by_challenged => @by_challenged
    }
  end

  # Public: Determine whether this game can be rolled back.
  #
  # The game may only be rolled back if the game is in the last 3
  # games each player played, and if both of the score change attributes
  # are set (since they can't be retrofitted to existing records)
  #
  # Returns true if the game CAN be rolled back, or false if not
  def can_rollback?
    return false unless challenged_rating_change && challenger_rating_change
    return challenged.games.limit(1).include?(self) || challenger.games.limit(1).include?(self)
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

  # Check the challenger and challenged players for new badge awards
  def award_badges
    Badge.all.each do |the_badge|
      [challenger,challenged].each do |the_player|
        if the_badge.qualifies?(the_player)
          the_player.award!(the_badge)
        end
       end
    end
  end

  # Public: Rollback this game.
  #
  # This method applies the score changes back to the players, before
  # destroying the game. It effectively 'reverses' any points changes
  # that this game resulted in
  #
  # Returns the destroyed game
  def rollback!
    if self.challenged_rating_change and self.challenger_rating_change

      if self.winner?(self.challenged)
        self.challenged.rating += -self.challenged_rating_change.round
        self.challenger.rating += self.challenger_rating_change.round.abs + 1
      else
        self.challenger.rating += -self.challenger_rating_change.round
        self.challenged.rating += self.challenged_rating_change.round.abs + 1
      end

      self.challenged.save
      self.challenger.save
    end

    self.destroy
  end

  protected

  # Protected - Set the change in ratings for each player, so that
  # the game may be rolled back if necessary.
  def set_rating_changes
    self.challenged_rating_change = self.challenged_rating.send(:change)
    self.challenger_rating_change = self.challenger_rating.send(:change)
  end

  # Protected - Build a rating object for the challenging player
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

  # Protected - Build a rating object for the challenged player
  # See Game#challenger_rating
  def challenged_rating
    Rating.new(
      :result => (1.0 - result),
      :old_rating => challenged.rating,
      :other_rating => challenger.rating,
      :k_factor => challenged.k_factor
    )
  end

  private

  # Private - Ensures that the challenger is not challenging themselves to boost their
  # score. This is not possible from the webview, but is possible via the API
  #
  # Adds an error message if the challenger and challenged is the same,
  # returns boolean flag indicating whether the validation passed or failed.
  def challenger_and_challenged_are_not_the_same
    if challenger == challenged
      errors.add(:challenger, :same_as_challenged)
      return false
    else
      return true
    end
  end

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

  # Private: Checks for the existence of a game already in progress.
  #
  # Any given player can only have one challenge with another player
  # on at any one time. This validation enforces this rule by performing a database
  # query, looking for incomplete games with this model's challenger and challenged players.
  #
  # If a matching record is found, this record is invalid and an error message is added to the
  # base object. Returns false.
  #
  # If a matching record is not found, this record is valid - returns true.
  def in_progress_game_does_not_exist?
    if self.challenger && self.challenged
      Game.where(
        :complete => false,
        :challenger_id => self.challenger.id,
        :challenged_id => self.challenged.id
      ).first.nil? ? true : errors.add(:base, :in_progress_game); false
    end
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
