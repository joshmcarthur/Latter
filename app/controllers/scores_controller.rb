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
      if @game.save
        format.html { redirect_to @game, notice: 'Game was completed.' }
        format.js   { render }
      else
        format.html { render action: "index" }
        format.js   { render }
      end
    end
  end
end
