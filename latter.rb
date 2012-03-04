
class Latter < Sinatra::Base
  # Setup our root paths
  set :root, File.dirname(__FILE__)
  Dir[File.join(settings.root, 'models', '*.rb')].each { |rb| require rb }
  enable :sessions
  enable :static

  configure :test do
    DataMapper.setup(:default, "sqlite3::memory")
    DataMapper.auto_upgrade!
  end



  configure :production do
    PONY_SMTP_OPTIONS = {
      :address => "smtp.sendgrid.net",
      :port => '25',
      :authentication => :plain,
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :domain => ENV['SENDGRID_DOMAIN']
    }
  end

  configure do
    DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/latter.db.sqlite3")
    DataMapper.auto_upgrade!
  end

  before do
    current_player
    authenticate! if authenticate?(request)
  end


  get '/' do
    current_player ? redirect('/players') : haml(:"auth/login")
  end

  post '/login' do
    if current_player = Player.first(:email => params[:email].downcase)
      session[:player_id] = current_player.id
      redirect '/players'
    else
      haml :"auth/login"
    end
  end

  get '/logout' do
    session[:player_id] = nil
    redirect '/'
  end

  get '/players' do
    @players = Player.all.sort { |a,b| b.total_wins <=> a.total_wins }
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

    redirect '/'
  end

  get '/challenges' do
    @challenges = Challenge.all(:order => [:completed.desc, :created_at.desc])
    haml :"challenges/index"
  end


  post '/challenge' do
    @challenge = Challenge.new
    @challenge.from_player = Player.get(params[:challenge][:from_player_id])
    @challenge.to_player = Player.get(params[:challenge][:to_player_id])
    @challenge.completed = false
    if @challenge.save
      send_mail(
        :to => @challenge.to_player.email,
        :from => @challenge.from_player.email,
        :subject => "New Challenge on Latter",
        :template => 'new_challenge',
        :object => @challenge
      )
      redirect '/challenges'
    else
      redirect '/challenge/new'
    end
  end

  post '/challenge/:id/update' do
    @challenge = Challenge.get(params[:id])
    not_found?(@challenge)

    @challenge.completed? ? (error(400, I18N[:challenge_can_only_be_updated_once])) : nil

    @challenge.set_score_and_winner(
      :from_player_score => params[:challenge][:from_player_score],
      :to_player_score => params[:challenge][:to_player_score]
    )
    @challenge.completed = true
    if @challenge.save
      send_mail(
        :to => @challenge.to_player.email,
        :from => @challenge.from_player.email,
        :subject => "Updated Challenge on Latter",
        :template => "challenge_updated",
        :object => @challenge
      )
      redirect '/challenges'
    else
      redirect "/challenge/#{@challenge.id}/edit"
    end
  end


  def send_mail(options)
    @object = options[:object]
    Pony.mail(
      :to => options[:to],
      :from => options[:from],
      :subject => options[:subject],
      :html_body => haml(:"mail/#{options[:template]}", :layout => false),
      :via => :smtp,
      :via_options => PONY_SMTP_OPTIONS
    )
  end

  def not_found?(object)
    error(404, I18N[:record_not_found]) unless object
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
