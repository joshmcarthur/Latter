class Api::V1::GamesController < API::V1::BaseController
  def index
    @games = Game.where(:complete => params.fetch(:complete, true))
                 .includes(:challenged, :challenger)
                 .order(:updated_at)
                 .page(params[:page])
                 .per(params[:per_page] || 100)


    respond_to do |format|
      format.json { render }
    end
  end

  def player
    @player ||= Player.find(params[:player_id])
  end
end
