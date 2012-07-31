class Award < ActiveRecord::Base
  attr_accessible :badge_id, :player_id

  validates_presence_of :badge_id, :player_id
  
  belongs_to :badge  
  belongs_to :player 
  
end
