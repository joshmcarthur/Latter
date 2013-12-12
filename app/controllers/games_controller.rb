
class GamesController < ApplicationController
  before_filter :authenticate_player!
  respond_to :html, :js, :json

  # GET /games
  # GET /games.json
  def index
    @games = Game\
      .includes(:challenged, :challenger)\
      .where(:complete => params.fetch(:complete, true))\
      .order('created_at DESC')\
      .page(params[:page])\

    respond_to do |format|
      format.html { render stream: true }
      format.json { render :index }
    end if stale?(last_modified: @games.maximum(:updated_at))
  end


  # POST /games
  # POST /games.json
  def create
    @game = current_player.challenger_games.new.tap do |game|
      game.challenged = Player.find(game_params[:challenged_id]) rescue nil
    end

    respond_to do |format|
      if @game.save
        format.html { redirect_to Player, notice: I18n.t('game.new.success') }
        format.js   { render }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { redirect_to root_path, :alert => I18n.t('game.new.failure') }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = current_player.games.find(params[:id])
    @game.rollback!

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end

  private

    def game_params
      params.require(:game).permit(:challenged_id)
    end
end
