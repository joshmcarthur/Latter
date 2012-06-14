class AddConfirmableToPlayers < ActiveRecord::Migration
  def change
    change_table :players do |t|
      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
    end

    add_index :players, :confirmation_token, :unique => true
  end
end
