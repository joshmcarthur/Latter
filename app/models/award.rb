class Award < ActiveRecord::Base

  # default_scope to ignore expired awards
  default_scope -> { where('expiry >= ? or expiry is null', DateTime.now.midnight) }

  after_create :set_award_date

  validates_presence_of :badge_id, :player_id

  belongs_to :badge
  belongs_to :player, :touch => true

  after_create :create_activity

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
