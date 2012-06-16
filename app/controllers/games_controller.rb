
class GamesController < ApplicationController
  before_filter :authenticate_player!
  respond_to :html, :js, :json

  # GET /games
  # GET /games.json
  def index
    @games = Game.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game = Game.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @game }
    end
  end

  # POST /games
  # POST /games.json
  def create
    @game = current_player.challenger_games.new.tap do |game|
      game.challenged = Player.find(params[:game][:challenged_id]) rescue nil
    end

    respond_to do |format|
      if @game.save
        format.html { redirect_to Player, notice: 'Game was successfully created.' }
        format.js   { render }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = current_player.games.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end
end
