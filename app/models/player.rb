class Player < ActiveRecord::Base

  PRO_K_FACTOR = 10
  STARTER_K_FACTOR = 25
  DEFAULT_K_FACTOR = 15

  # 30 games
  STARTER_BOUNDARY = 30

  # Rating
  PRO_RATING_BOUNDARY = 2400

  include Gravtastic

  has_gravatar
  devise :database_authenticatable,
         :confirmable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  before_validation :set_default_password, :on => :create

  attr_accessible :email,
    :password,
    :password_confirmation,
    :wants_challenge_completed_notifications,
    :remember_me,
    :name,
    :rating,
    :pro,
    :starter

  validates_presence_of :name, :allow_blank => false
  validates_numericality_of :rating, :minimum => 0
  validates_inclusion_of :pro, :starter, :in => [true, false, nil]

  has_many :challenged_games, :class_name => 'Game', :foreign_key => 'challenged_id'
  has_many :challenger_games, :class_name => 'Game', :foreign_key => 'challenger_id'
  has_many :won_games, :class_name => 'Game', :foreign_key => 'winner_id'

  # Public - Return all games that a player has participated in
  #
  # Returns an array of games where the player was either a challenger or
  # was challenged
  def games(complete = nil)
    games_scope = Game.where('challenger_id = ? OR challenged_id = ?', self.id, self.id)
    games_scope.where('complete = ?', complete) if complete

    games_scope
  end

  # Public - Return the ranking of a player
  #
  # This method leverages the rating of a player to order all players
  # and returns an array index of the ordering, plus one.
  # This value can then be used to display the player's position
  # in the ladder.
  def ranking
    Player.order('rating DESC').select(:id).map(&:id).index(self.id) + 1
  end

  # Public - A hook called by devise after a password reset
  #
  # We use this method to update our own password_changed? boolean
  # if the record is not new (i.e. someone hasn't just registered or something),
  # and the encrypted_password field has changed. We then delegate the action
  # up to super.
  #
  def after_password_reset
    if !self.new_record? and self.encrypted_password_changed?
      self.changed_password = true
    end

    super
  end


  # Public - Calculate whether this player is a rookie
  #
  # Returns true if the player is a rookie, or false if not
  def starter?
    games_played < Player::STARTER_BOUNDARY
  end

  # Public - Calculate whether this player is a pro player
  #
  # Returns true if the player is a pro, or false if not
  def pro_rating?
    rating >= Player::PRO_RATING_BOUNDARY
  end

  # Public - Return games that are in progress with another player
  #
  # This method returns an array of games that are in progress
  # with a given player. It uses the existing games query to
  # build upon this and return results.
  #
  # other_player - the Player object to find in progress games with
  #
  # Returns an array of games that are in progress between this player
  # and another player
  def in_progress_games(other_player)
    games.where(
      'complete = ? AND (challenger_id = ? OR challenged_id = ?)',
      false,
      other_player.id,
      other_player.id
    )
  end


  # Public - Return the number of games played by this player
  #
  # Returns an integer count of games played by the player
  # (complete, challenger and challenged)
  def games_played
    games.size
  end

  # Public - Calculate the k-factor for the player
  #
  # Applies a basic k-factor calculation to the player
  # to arrive at a magical number. This number
  # is used to weigh a players result against how
  # developed the player is.
  #
  # Returns a decimal number representing that players
  # k-factor
  def k_factor
    if pro? or pro_rating?
      Player::PRO_K_FACTOR
    elsif starter?
      Player::STARTER_K_FACTOR
    else
      Player::DEFAULT_K_FACTOR
    end
  end

  private

  # Private - Set a default password for the user
  #
  # Because only existing players can add new players, we want to
  # avoid the situation where a player adds a new player, and then has to
  # think up a password, enter it, and then say "your password is x".
  #
  # Instead, we set a default secure password to the account, and then
  # get them to set their password the first time they log in
  # (see ApplicationController)
  def set_default_password
    Devise.friendly_token[0..20].tap do |pass|
      self.password = pass
      self.password_confirmation = pass
    end
  end

  # Private - Update player ratings based on the result
  # of a game
  #
  # This method is not part of the public Player API, but
  # is called by the Game class when a game is completed
  # and scores have been calculated.
  #
  # game - The completed, score-calculated game to
  #        use when updating the player
  #
  # Returns the player instance
  def played(game)
    self.rating = game.ratings[self].new_rating
    self.pro = true if pro_rating?
    self.save

    self
  end

end
