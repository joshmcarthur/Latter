class BadgesController < ApplicationController
before_filter :authenticate_player!
 # caches_action :index, :expires_in => 60.minutes

 def index
   @badges = Badge.all
 end
 
end
