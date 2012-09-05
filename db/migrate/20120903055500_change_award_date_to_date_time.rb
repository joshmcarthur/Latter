class ChangeAwardDateToDateTime < ActiveRecord::Migration
  def up
  	change_column(:awards, :award_date, :datetime)
  end

  def down
  	change_column(:awards, :award_date, :date)
  end
end
