# == Schema Information
#
# Table name: alerts
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  message     :text             not null
#  expire_at   :datetime
#  activate_at :datetime         not null
#  category    :string(255)      default("info"), not null
#

class Alert < ActiveRecord::Base
  attr_accessible :title, :activate_at, :expire_at, :message, :category

  validates_presence_of :activate_at, :message, :category
  validates_inclusion_of :category, :in => ['info', 'error', 'warning']

  before_validation :default_activate_at, :on => :create

  scope :current, proc { where('? >= activate_at AND (? <= expire_at OR expire_at IS NULL)', DateTime.now, DateTime.now) }

  private

  def default_activate_at
    self.activate_at = DateTime.now unless self.activate_at.present?
  end
end
