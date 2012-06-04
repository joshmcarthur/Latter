class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.text :message, :null => false
      t.timestamps
    end
  end
end
