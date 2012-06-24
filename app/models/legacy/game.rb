class Legacy::Game < ActiveRecord::Base
  establish_connection "legacy"

  def to_model
    game = ::Game.new(
      :challenger => ::Player.find_by_email(Legacy::Player.find(self.challenger_id).email),
      :challenged => ::Player.find_by_email(Legacy::Player.find(self.challenged_id).email),
      :complete => true,
      :score => self.score,
      :result => self.result
    )
    game.winner = game.result == 1.0 ? game.challenger : game.challenged
    game.save!
  end
end
