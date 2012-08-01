class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
      t.references :player
      t.references :badge

      t.timestamps
    end
  end
end
