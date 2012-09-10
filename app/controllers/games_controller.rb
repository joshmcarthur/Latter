
class GamesController < ApplicationController
  before_filter :authenticate_player!
  caches_action :index,
    :expires_in => 5.minutes,
    :cache_path => proc { |c| c.params }

  respond_to :html, :js, :json

  # GET /games
  # GET /games.json
  def index
    @games = Game\
      .includes(:challenged, :challenger)\
      .where(:complete => true)\
      .order('created_at DESC')\
      .page(params[:page])\

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
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
        format.html { redirect_to Player, notice: I18n.t('game.new.success') }
        format.js   { render }
        format.json { render json: @game, status: :created, location: @game }
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

  # POST /gamesearch
  # parameters are: 
  # :q => the ransack search query
  # :player => the player whose games to search
  # :dateoffset => the date range to filter (hours prior to the current time)

  def search

    if params[:q].present?

      # get the player parameter
      @player = Player.find(params[:q][:player])
      
      # swap the created_at parameter to a date offset (hours)
      @date_offset = params[:q][:created_at_gt].to_i
      params[:q][:created_at_gt] = DateTime.now.ago(@date_offset*60*60)
      # params[:q].merge!(:created_at_gt => DateTime.now.ago(60*60*24*@dateoffset))

    else
      # set defaults
        @player = Player.first
    end

    @search = @player.games.search(params[:q])
    # @search = Game.search(params[:q])
    @games  = params[:distinct].to_i.zero? ? @search.result : @search.result(distinct: true)
    respond_with @games
    
  end


end
