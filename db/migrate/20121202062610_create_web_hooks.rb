class CreateWebHooks < ActiveRecord::Migration
  def change
    create_table :web_hooks do |t|
      t.string :destination, :limit => 300
      t.string :event, :limit => 10

      t.timestamps
    end

    add_index :web_hooks, [:destination, :event], :unique => true
  end
end
