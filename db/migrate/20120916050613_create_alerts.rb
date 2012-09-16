class CreateAlerts < ActiveRecord::Migration
  def change
    create_table :alerts do |t|
      t.string :title
      t.text :message, :null => false
      t.datetime :expire_at
      t.datetime :activate_at, :null => false
      t.string :category, :null => false, :default => 'info'
    end
  end
end
