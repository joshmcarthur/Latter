class RenameImageUrlOnBadges < ActiveRecord::Migration
  def up
  	rename_column :badges, :imageURL, :image_url
  end

  def down
  	rename_column :badges, :image_url, :imageURL
  end
end
