class Award < ActiveRecord::Base
  
  after_create :set_award_date
  
  attr_accessible :badge_id, :player_id, :award_date

  validates_presence_of :badge_id, :player_id
  
  belongs_to :badge  
  belongs_to :player 
  
  private
  
    def set_award_date
      
      if self.award_date == nil
         self.award_date = self.created_at.to_date
      end
      
    end
  
end
