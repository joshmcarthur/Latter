class Award < ActiveRecord::Base
  
  after_create :set_award_date
  

  validates_presence_of :badge_id, :player_id
  
  belongs_to :badge
  belongs_to :player, :touch => true

  after_create :create_activity
  
  attr_accessible :badge_id, :player_id, :award_date, :badge
  
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
