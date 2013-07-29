class Activity < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  validates_presence_of :message

  def self.completed_game(game)
    result = game.winner?(game.challenger) ? I18n.t('game.result.won') : I18n.t('game.result.lost')
    message = I18n.t(
      'activities.game_complete',
      :challenger => game.challenger.name,
      :challenged => game.challenged.name,
      :result => result,
      :score => game.score
    )
    self.create(:message => message)
  end

  def self.new_game(game)
    message = I18n.t('activities.new_game', :challenger => game.challenger.name, :challenged => game.challenged.name)
    self.create(:message => message)
  end

  def self.awarded_badge(award)
    message = I18n.t('activities.awarded_badge', :player => award.player.name, :name => award.badge.name)
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
