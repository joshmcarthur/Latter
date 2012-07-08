class Activity < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  attr_accessible :message

  validates_presence_of :message

  def self.completed_game(game)
    result = game.winner?(game.challenger) ? "won!" : "lost!"
    message = "#{game.challenger.name} completed their game against #{game.challenged.name} and #{result} (#{game.score})"
    self.create(:message => message)
  end

  def self.new_game(game)
    message = "#{game.challenger.name} challenged #{game.challenged.name}."
    self.create(:message => message)
  end

  # Override the json representation of this object to include the time_ago method result
  def as_json(args)
    super(args.merge(:methods => 'time_ago'))
  end


  # Public - Return how long ago this activity occurred in a nice format
  #
  # Returns a string representing the human time elapsed (e.g. 1 day ago)
  def time_ago
    I18n.t('activities.attributes.time_ago', :distance => distance_of_time_in_words_to_now(self.created_at))
  end
end
