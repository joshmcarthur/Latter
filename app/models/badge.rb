class Badge < ActiveRecord::Base

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
  #
  # The hash of conditions is from Badge.award_rule
  #
  # An award_rule_count of > 0 means award the badge if more than
  # award_rule_count results are returned.
  #
  # A negative award rule means the badge should be awarded if
  # less than the absolute value of the award_rule_count is returned
  # i.e. specified the operator and the value
  #
  # A zero award_rule_count means award the badge if any matches
  # are found to the condition regardless of number.
  #
  # If a created_at_gt parameter is in the award_rule then we
  # treat it as a number of hours prior to the current time
  # and substitute in the correct date value
  #
  def qualifies?(player)

      return false if self.award_rule.nil?

      @award_rule = self.award_rule.dup

      # swap the created_at parameter to a date offset assumed to be in hours

      if @award_rule[:created_at_gt].present?
         @date_offset = @award_rule[:created_at_gt].to_i
         @award_rule[:created_at_gt] = DateTime.now.ago(@date_offset*60*60)
      end

      award_count = self.award_rule_count

      result_count = player.games.search(@award_rule).result.count
      qualifies = false

      if award_count < 0
          qualifies = true if result_count < (-award_count)
      elsif award_count > 0
          qualifies = true if result_count > award_count
      else
          qualifies = true if result_count > 0
      end

      qualifies

  # rescue

      # return false

  end

end
