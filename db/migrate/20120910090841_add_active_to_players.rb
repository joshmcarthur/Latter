class AddActiveToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :active, :boolean, :default => true, :null => false
    add_index :players, :active
  end
end
