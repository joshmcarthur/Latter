class API::V1::BaseController < ActionController::Base
  before_filter :authenticate_player!
  before_filter :default_format
  respond_to :json

  private

  def default_format
    request.format = :json unless params[:format]
  end
end