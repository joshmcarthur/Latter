class AddWinnerToGame < ActiveRecord::Migration
  def change
    change_table :games do |t|
      t.references :winner
    end
  end
end
