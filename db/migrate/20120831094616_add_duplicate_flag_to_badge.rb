class AddDuplicateFlagToBadge < ActiveRecord::Migration
  def change
  		add_column :badges, :allow_duplicates, :boolean, :default => false
  end
end
