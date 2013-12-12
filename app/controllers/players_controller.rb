
class PlayersController < ApplicationController
  before_filter :authenticate_player!, :except => :index

  # GET /players
  # GET /players.json
  def index
    @players = Player
              .includes(:challenged_games, :challenger_games, :won_games)
              .order('rating DESC')

    respond_to do |format|
      format.html { render stream: true }
      format.json { render }
    end if stale?(last_modified: @players.maximum(:updated_at))
  end

  def current
    head :bad_request and return unless request.format == :json

    @player = current_player

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :show }
    end
  end

  # GET /players/1
  # GET /players/1.json
  def show
    @player = Player.find(params[:id])

    respond_to do |format|
      format.html { render stream: true }
      format.json { render }
    end if stale?(@player)
  end

  # GET /players/new
  # GET /players/new.json
  def new
    @player = Player.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @player }
    end
  end

  # GET /players/1/edit
  def edit
    @player = current_player
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to Player, notice: I18n.t('player.create.success') }
        format.json { render json: @player, status: :created, location: @player }
      else
        format.html { render action: "new" }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /players/1
  # PUT /players/1.json
  def update
    @player = current_player

    respond_to do |format|
      if @player.update_with_password(player_params)
        format.html { redirect_to Player, notice: I18n.t('player.update.success') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    def player_params
      params.require(:player).permit(
        :email,
        :password,
        :password_confirmation,
        :wants_challenge_completed_notifications,
        :name
      )
    end

end
