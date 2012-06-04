class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :challenger, :null => false
      t.references :challenged, :null => false
      t.boolean :complete, :null => false, :default => false
      t.float :result
      t.string :score

      t.timestamps
    end

    add_index :games, :challenger_id
    add_index :games, :challenged_id
    add_index :games, [:challenger_id, :challenged_id]
    add_index :games, :complete
  end
end
