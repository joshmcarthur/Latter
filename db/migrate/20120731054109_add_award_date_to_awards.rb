class AddAwardDateToAwards < ActiveRecord::Migration
  def change
    add_column :awards, :award_date, :date
  end
end
