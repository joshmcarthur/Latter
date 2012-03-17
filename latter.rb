
class Latter < Sinatra::Base
  # Setup our root paths
  set :root, File.dirname(__FILE__)
  Dir[File.join(settings.root, 'models', '*.rb')].each { |rb| require rb }
  enable :sessions
  enable :static

  configure :test do
    PONY_OPTIONS = {
      :method => :test,
    }
    DataMapper.setup(:default, "sqlite3::memory:")
    set :host, 'http://localhost:9292'
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
  end

  configure do
    DataMapper.auto_upgrade!
  end

  before do
    authenticate! if authenticate?(request)
  end


  get '/' do
    current_player ? redirect('/players') : redirect('/login')
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
    @players = Player.all.sort_by { |player| player.ranking}
    haml :"players/index"
  end

  get '/players/new' do
    @player = Player.new
    haml :"players/form"
  end

  get '/player/:id/edit' do
    @player = Player.get(params[:id])
    not_found?(@player)

    haml :"players/form"
  end

  post '/player/:id/update' do
    @player = Player.get(params[:id])
    not_found?(@player)

    @player.update!(params[:player]) ? redirect("/player/#{@player.id}") : haml(:"players/form")
  end

  get '/player/:id' do
    @player = Player.get(params[:id])
    not_found?(@player)

    haml :"players/show"
  end

  post '/player' do
    @player = Player.create(params[:player])
    @player.saved? ? redirect("/player/#{@player.id}") : error(400, I18N[:record_not_saved])
  end

  post '/player/:id' do
    @player = Player.get(params[:id])
    not_found?(@player)

    updated = @player.update! params[:player]
    updated ? redirect("/player/#{params[:id]}") : error(400, I18N[:record_not_saved])
  end

  post '/player/:id/delete' do
    @player = Player.get(params[:id])
    not_found?(@player)

    @player.destroy
    redirect '/players'
  end

  get '/player/:id/challenge' do
    @challenge = Challenge.create(
      :completed => false,
      :from_player_id => current_player.id,
      :to_player_id => params[:id]
    )

    send_mail(
      :to => @challenge.to_player.email,
      :from => @challenge.from_player.email,
      :subject => "You've been challenged!",
      :template => 'new_challenge',
      :locals => {
        :host => settings.host,
        :challenge => @challenge
      }
    )

    content_type 'application/javascript'
    erb :"challenges/create"
  end

  get '/challenge/:id/complete' do
    @challenge = Challenge.get(params[:id])
    content_type 'application/javascript'
    erb :"challenges/complete"
  end

  post '/challenge/:id/complete' do
    @challenge = Challenge.get(params[:id])
    not_found?(@challenge)

    @challenge.set_score_and_winner(
      :from_player_score => params[:challenge][:from_player_score],
      :to_player_score => params[:challenge][:to_player_score]
    )
    @challenge.completed = true
    @challenge.save

    send_mail(
      :to => [@challenge.to_player.email, @challenge.from_player.email],
      :from => @challenge.from_player.email,
      :subject => "Challenge completed!",
      :template => 'challenge_updated',
      :locals => {
        :host => settings.host,
        :challenge => @challenge
      }
    )

    redirect '/'
  end

  get '/challenges' do
    @challenges = Challenge.all(:order => [:completed.desc, :created_at.desc])
    haml :"challenges/index"
  end

  get '/activities.json' do
    content_type["text/json"]
    @activities = Activity.all(
      :created_at => headers['Last-Modified']
    )

    @activities = Activity.all(
      :order => 'created_at DESC',
      :limit => 5
    ) if @activities.empty?

    @activities.to_json
  end


  def send_mail(options)
    begin
      Pony.mail(
        :to => options[:to],
        :from => options[:from],
        :subject => options[:subject],
        :html_body => erb(:"mail/#{options[:template]}", :locals => options[:locals], :layout => false),
        :via => PONY_OPTIONS[:method],
        :via_options => PONY_OPTIONS
      )
    rescue

    end
  end

  def not_found?(klass = nil)
    error(404, "Record not found") unless klass
  end

  helpers do
    def challenge_status_of(player, challenge)
      html_class = ""
      return html_class unless challenge.completed?
      if challenge.winner?(player)
        html_class = "winner"
      elsif challenge.loser?(player)
        html_class = "loser"
      elsif challenge.drawer?(player)
        html_class = "drawer"
      end

      html_class
    end

    def current_player
      @current_player ||= Player.get(session[:player_id])
    end
  end

  def authenticate!
    redirect '/' unless current_player
  end

  def authenticate?(request)
    path = request.path
    case path
    when /\A\/\Z/
      return false
    when /\A\/login\Z/
      return false
    end

    return true
  end
end
