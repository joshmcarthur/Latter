class Latter < Sinatra::Base
  # Setup our root paths
  set :root, File.dirname(__FILE__)
  Dir[File.join(settings.root, 'models', '*.rb')].each { |rb| require rb }

  use Rack::Session::Cookie,  :key => 'latter_session',
    :path => '/',
    :secret => ENV['SESSION_SECRET']

  enable :static

  configure :test do
    PONY_OPTIONS = {
      :method => :test,
    }
    DataMapper.setup(:default, "sqlite3::memory:")
    set :host, 'http://latter.dev'
  end

  configure :development do
    PONY_OPTIONS = {
      :method => :smtp,
      :address => "localhost",
      :port => 1025,
      :domain => "localhost"
    }
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/latter.db.sqlite3")
    set :host, 'http://localhost:9292'
  end

  configure :production do
    PONY_OPTIONS = {
      :method => :smtp,
      :address => "smtp.sendgrid.net",
      :port => '587',
      :authentication => :plain,
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :domain => ENV['SENDGRID_DOMAIN']
    }
    DataMapper.setup(:default, ENV['DATABASE_URL'])
    set :host, ENV['HOST']
    set :session_secret, ENV['SESSION_SECRET']
  end

  configure do
    DataMapper.auto_upgrade!

    Elo.configure do |config|
      # Every player starts with a rating of 1000
      config.default_rating = 1000
      # A player is considered a pro, when he/she has more than 2400 points
      config.pro_rating_boundry = 2400
      # A player is considered a new, when he/she has played less than 30 games
      config.starter_boundry = 30
    end
  end

  before do
    authenticate! if authenticate?(request)
  end


  get '/' do
    redirect('/players')
  end

  get '/statistics' do
    @players = Player.all(:order => :rating.desc)
    haml :"statistics/show"
  end

  get '/pages/:slug' do
    haml :"pages/#{params[:slug]}"
  end

  get '/login' do
    haml :"auth/login"
  end

  post '/login' do
    if current_player = Player.first(:email => params[:email].downcase)
      session[:player_id] = current_player.id
      redirect '/players'
    else
      redirect '/login'
    end
  end

  get '/logout' do
    session[:player_id] = nil
    redirect '/'
  end

  get '/players' do
    @players = Player.all(:order => :rating.desc)
    haml :"players/index"
  end

  get '/players/new' do
    @player = Player.new
    haml :"players/form"
  end

  get '/player/edit' do
    @player = current_player
    haml :"players/form"
  end

  post '/player/update' do
    @player = current_player
    @player.update!(params[:player]) ? redirect("/player/#{@player.id}") : haml(:"players/form")
  end

  get '/player/:id' do
    @player = Player.get(params[:id])
    #not_found?(@player)

    haml :"players/show"
  end

  post '/player' do
    @player = Player.create(params[:player])
    @player.saved? ? redirect("/player/#{@player.id}") : error(400, I18N[:record_not_saved])
  end


  post '/player/:id/challenge' do
    @game = Game.create(
      :challenger => current_player,
      :challenged => Player.get(params[:id])
    )

    send_mail(
      :to => @game.challenged.email,
      :from => @game.challenger.email,
      :subject => "You've been challenged!",
      :template => 'new_game',
      :locals => {
        :host => settings.host,
        :game => @game
      }
    )

    content_type 'application/javascript'
    erb :"games/create"
  end

  get '/games/:id/complete' do
    @game = Game.get(params[:id])
    content_type 'application/javascript'
    erb :"games/complete"
  end

  post '/games/:id/complete' do
    @game = Game.get(params[:id])
    #not_found?(@game)

    @game.complete!(params[:game])

    send_mail(
      :to => [@game.challenged.email, @game.challenger.email],
      :from => @game.challenger.email,
      :subject => "Challenge completed!",
      :template => 'game_completed',
      :locals => {
        :host => settings.host,
        :game => @game
      }
    )

    redirect '/'
  end

  get '/games' do
    @games = Game.all(:order => [:complete.desc, :created_at.desc])
    haml :"games/index"
  end

  get '/activities.json' do
    content_type :json
    if params[:modified_since]
      filter = { :created_at.gt => Time.parse(params[:modified_since]) }
    else
      filter = { :order => :created_at.desc, :limit => 5 }
    end

    Activity.all(filter).to_json
  end


  def send_mail(options)
    Pony.mail(
      :to => options[:to],
      :from => options[:from],
      :subject => options[:subject],
      :html_body => erb(:"mail/#{options[:template]}", :locals => options[:locals], :layout => false),
      :via => PONY_OPTIONS[:method],
      :via_options => PONY_OPTIONS
    )
  end

  def not_found?(klass = nil)
    error(404, "Record not found") unless klass
  end

  helpers do
    def current_player
      @current_player ||= Player.get(session[:player_id])
    end

    def game_in_progress?(other_player)
      return nil unless other_player.is_a?(Player)

      # Try and find a game between the current player and the previous
      # player
      current_player.in_progress_games(other_player).first
    end
  end

  def authenticate!
    redirect '/login' unless current_player
  end

  def authenticate?(request)
    path = request.path
    case path
    when /\A\/\Z/
      return false
    when /\A\/players\Z/
      return false
    when /\A\/login\Z/
      return false
    end

    return true
  end
end
