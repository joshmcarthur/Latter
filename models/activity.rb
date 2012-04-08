class Activity
  include DataMapper::Resource

  property :id, Serial, :required => true
  property :message, Text, :required => true
  property :created_at, DateTime, :default => lambda { |record, property| Time.now }

  def self.completed_game(game)

    result = game.winner?(game.challenger) ? "won!" : "lost!"
    message = "#{game.challenger.name} completed their game against #{game.challenged.name} and #{result} (#{game.score})"
    self.create(:message => message)
  end

  def self.new_game(game)
    message = "#{game.challenger.name} challenged #{game.challenged.name}."
    self.create(:message => message)
  end
end
