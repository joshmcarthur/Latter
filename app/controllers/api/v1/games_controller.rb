class Api::V1::GamesController < API::V1::BaseController
  def index
    @games = Rails.cache.fetch "api-v1-#{player.id}-games", :expires_in => 1.minute do
      player.games.complete.order(:updated_at)
    end

    respond_to do |format|
      format.json { render }
    end
  end

  def player
    @player ||= Player.find(params[:player_id])
  end
end
