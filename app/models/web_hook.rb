class WebHook < ActiveRecord::Base

  scope :for, lambda { |event_type| where(:event => event_type) }

  validates_presence_of :destination, :event
  validates_inclusion_of :event, :in => %w( game_created game_completed ) 
  validates_uniqueness_of :destination, :scope => :event

  def post!(object)
    Thread.new do
      Net::HTTP.post_form(URI.parse(self.destination), object.as_json)
    end
  end
end
