class Badge < ActiveRecord::Base
  
  attr_accessible :description, :image_url, :name
  
  validates_presence_of :name, :image_url

  serialize :award_rule
  
  has_many :awards, :dependent => :destroy
  has_many :players, :through => :awards
  
  # Check to see if this badge has been awarded to a player
  def awarded_to?(player)
  	if player.awards.where(badge_id: self.id).count > 0
  		return true
  	else
  		return false
  	end
  end

  # Check whether a player is eligible to receive this badge
  def gained_by?(player)
      @validate = Player.search(self.award_rule)
      if @validate.count > 0 then
        return true
      else
        return false
      end
  end

end
