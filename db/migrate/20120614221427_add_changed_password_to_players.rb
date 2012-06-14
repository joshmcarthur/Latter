class AddChangedPasswordToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :changed_password, :boolean, :default => false, :null => false
  end
end
