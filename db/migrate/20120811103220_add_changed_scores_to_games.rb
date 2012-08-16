class AddChangedScoresToGames < ActiveRecord::Migration
  def change
    add_column :games, :challenger_rating_change, :decimal
    add_column :games, :challenged_rating_change, :decimal
  end
end
