class Player < Elo::Player
  include DataMapper::Resource
  include BCrypt
  include Gravtastic

  property :id, Serial
  property :name, String, :required => true
  property :email, String, :required => true, :unique_index => true
  property :encrypted_password, String, :length => 255, :required => true
  property :rating, Integer, :required => true, :default => Elo.config.default_rating
  property :pro, Boolean, :required => true, :default => false
  property :starter, Boolean, :required => true, :default => true


  attr_accessor :password, :password_confirmation

  has_gravatar
  has n, :challenger_games, 'Game', :child_key => [:challenger_id], :parent_key => [:id]
  has n, :challenged_games, 'Game', :child_key => [:challenged_id], :parent_key => [:id]

  validates_with_block do
    if self.password != self.password_confirmation
      [false, "Password and password confirmation must match."]
    else
      [true]
    end
  end

  before :valid? do
    self.encrypted_password = Password.create(self.password) if self.password
  end

  def games
    challenger_games + challenged_games
  end

  def games_count(status = :total)
    challenger_condition = ["complete = 't'"]
    challenged_condition = ["complete = 't'"]

    case status
    when :won
      challenger_condition += ["result = 1.0"]
      challenged_condition += ["result != 1.0"]
    when :lost
      challenger_condition += ["result != 1.0"]
      challenged_condition += ["result = 1.0"]
    end

    count =  challenger_games.count(:conditions => [challenger_condition.join(" AND ")])
    count += challenged_games.count(:conditions => [challenged_condition.join(" AND ")])
    count
  end

  def played(game)
    self.rating = game.ratings[self].new_rating
    self.pro    = true if pro_rating?
    self.save
  end

  def ranking
    Player.all(:order => :rating.desc).index(self) + 1
  end

  def winning_percentage(return_string = true)
    return_string ? "50%" : 50
  end

  def result_of(game)
    if game.winner?(self)
      "won"
    else
      "lost"
    end
  end

  def in_progress_games(other_player)
    Game.all(:challenged => self, :challenger => other_player) +
      Game.all(:challenged => other_player, :challenger => self) &
        Game.all(:complete => false)
  end

  def self.authenticate(email, password)
    player = Player.get(:email => email)
    Password.new(player.encrypted_password).is_password? password if player
  end

end
