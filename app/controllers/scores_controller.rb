class ScoresController < ApplicationController
  before_filter :authenticate_player!

  # GET /games/1/score/new
  def new
    @game = current_player.games.find(params[:game_id])
    respond_to do |format|
      format.html { render }
      format.js   { render }
    end
  end

  # POST /games/1/score
  def create
    @game = current_player.games.find(params[:game_id])
    @game.complete!(params[:game])

    respond_to do |format|
      if @game.complete?
        format.html { redirect_to root_path, notice: I18n.t('game.complete.saved') }
        format.js { render }
        format.json  { render :template => 'games/show' }
      else
        format.html { redirect_to root_path, alert: I18n.t('game.complete.unsaved') }
        format.js { render "new" }
      end
    end
  end

  private

    def score_params
      params.require(:game).permit(:challenged_score, :challenger_score)
    end
end
