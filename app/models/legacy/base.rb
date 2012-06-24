class Legacy::Base < ActiveRecord::Base
  establish_connection "legacy"

end
