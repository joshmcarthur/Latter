class Api::V1::PlayersController < API::V1::BaseController
  def index
    @players = Rails.cache.fetch "api-v1-players", :expires_in => 1.minute do
      Player.order(:rating)
    end

    respond_to do |format|
      format.json { render }
    end
  end
end
