class BadgesController < ApplicationController
before_filter :authenticate_player!

caches_action :index, 
	:expires_in => 60.minutes,
	:cache_path => Proc.new { |controller|
		controller.params.merge(:last_modified => Badge.last.try(:created_at))
	}

 def index
   @badges = Badge.all
 end
 
end
