class AddWantsChallengeCompletedNotificationsToPlayers < ActiveRecord::Migration
  def change
    add_column :players,
      :wants_challenge_completed_notifications,
      :boolean,
      :default => true,
      :null => false
  end
end
