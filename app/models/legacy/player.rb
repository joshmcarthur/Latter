class Legacy::Player < ActiveRecord::Base

  establish_connection "legacy"

  def to_model
    ::Player.create!({
      :name => self.name,
      :email => self.email,
      :rating => self.rating,
      :pro => false,
      :starter => true
    })
  end

end
