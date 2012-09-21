# == Schema Information
#
# Table name: awards
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  badge_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  award_date :datetime
#  expiry     :datetime
#

class Award < ActiveRecord::Base
  
  # default_scope to ignore expired awards
  default_scope lambda { where('expiry >= ? or expiry is null', DateTime.now.midnight) }

  after_create :set_award_date

  validates_presence_of :badge_id, :player_id
  
  belongs_to :badge
  belongs_to :player, :touch => true

  after_create :create_activity
  
  attr_accessible :badge_id, :player_id, :award_date, :expiry, :badge
  
  private

    def create_activity
      Activity.awarded_badge(self)
    end
  
    def set_award_date
      if self.award_date.blank?
         self.award_date = self.created_at
         self.save
      end
    end
  
end
