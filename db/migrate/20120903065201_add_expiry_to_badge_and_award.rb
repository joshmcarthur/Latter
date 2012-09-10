class AddExpiryToBadgeAndAward < ActiveRecord::Migration
  def change
  	 add_column :badges, :expire_in_days, :integer, :default => 0
  	 add_column :awards, :expiry, :datetime
  end
end
