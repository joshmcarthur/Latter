class Player < Elo::Player
  include DataMapper::Resource
  include Gravtastic

  property :id, Serial
  property :name, String, :required => true
  property :email, String, :required => true, :unique_index => true
  property :rating, Integer, :required => true, :default => Elo.config.default_rating
  property :pro, Boolean, :required => true, :default => false
  property :starter, Boolean, :required => true, :default => true


  has_gravatar
  has n, :challenger_games, 'Game', :child_key => [:challenger_id], :parent_key => [:id]
  has n, :challenged_games, 'Game', :child_key => [:challenged_id], :parent_key => [:id]

  def games
    challenger_games + challenged_games
  end

  def played(game)
    self.rating = game.ratings[self].new_rating
    self.pro    = true if pro_rating?
    self.save
  end

  def ranking
    Player.all(:order => :rating.desc).index(self) + 1
  end
end
