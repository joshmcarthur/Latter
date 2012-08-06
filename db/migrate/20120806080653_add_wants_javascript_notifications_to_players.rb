class AddWantsJavascriptNotificationsToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :wants_javascript_notifications, :boolean, :default => true, :null => false
  end
end
