class BadgesController < ApplicationController
  before_filter :authenticate_player!

  caches_action :index, 
  :cache_path => Proc.new { |controller|
    controller.params.merge(:last_modified => Badge.last.try(:created_at))
  }

  def index
    @badges = Badge.all
  end

  def show
    @badge = Badge.find(params[:id])
  end
end