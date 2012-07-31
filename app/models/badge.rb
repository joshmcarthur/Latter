class Badge < ActiveRecord::Base
  
  attr_accessible :description, :imageURL, :name
  
  validates_presence_of :name, :imageURL
  
  has_many :awards, dependent: :destroy
  has_many :players, through: :awards
  
end
