class ActivityController < ApplicationController
  before_filter :authenticate_player!
  respond_to :json

  def index
    scope = params[:last] ?
             Activity.where('id > ?', params[:last]) : Activity

    respond_with scope.order('created_at DESC').limit(10)
  end

end
