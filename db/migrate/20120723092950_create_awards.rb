class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
      t.integer :player_id
      t.integer :badge_id

      t.timestamps
    end
    
    add_index :awards, :badge_id
    add_index :awards, :player_id
    
  end
end
