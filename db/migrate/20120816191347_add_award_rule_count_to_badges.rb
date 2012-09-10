class AddAwardRuleCountToBadges < ActiveRecord::Migration
  def change
  	add_column :badges, :award_rule_count, :integer, :default => 0
  end
end
