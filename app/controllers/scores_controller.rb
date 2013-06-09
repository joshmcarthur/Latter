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
        sync_update @game.challenged
        sync_update @game.challenger
        format.html { redirect_to root_path, notice: I18n.t('game.complete.saved') }
        format.js { render }
        format.json  { render :template => 'games/show' }
      else
        render :action => "new"
      end
    end
  end
end
