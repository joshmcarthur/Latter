class StatisticsController < ApplicationController
  before_filter :authenticate_player!
  respond_to :html, :json

  def index
    @data = Game.statistics

    respond_with @data
  end
end
