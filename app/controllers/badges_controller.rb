class BadgesController < ApplicationController
  before_filter :authenticate_player!

  def index
    @badges = Badge.all
  end

  def show
    @badge = Badge.find(params[:id])
  end
end