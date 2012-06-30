class ActivityController < ApplicationController
  before_filter :authenticate_player!
  respond_to :json

  def index
    scope = params[:modified_since] ?
             Activity.where('created_at < ?',  DateTime.parse(params[:modified_since])) : Activity.limit(25)
    respond_with scope
  end

end
