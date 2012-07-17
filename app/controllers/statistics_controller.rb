class StatisticsController < ApplicationController
  before_filter :authenticate_player!
  caches_action :index, :expires_in => 60.minutes

  respond_to :html, :json

  def index
    @data = Game.statistics

    respond_with @data
  end
end
