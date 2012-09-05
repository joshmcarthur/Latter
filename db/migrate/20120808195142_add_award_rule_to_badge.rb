class AddAwardRuleToBadge < ActiveRecord::Migration
  def change
  	add_column :badges, :award_rule, :text
  end
end
