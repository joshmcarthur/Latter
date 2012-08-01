class Badge < ActiveRecord::Base
  
  attr_accessible :description, :image_url, :name
  
  validates_presence_of :name, :image_url
  
  has_many :awards, dependent: :destroy
  has_many :players, through: :awards
  
end
