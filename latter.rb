require 'bundler/setup'

require 'sinatra'
require 'haml'
require 'pony'

require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-observer'


APP_DIR = File.expand_path(File.dirname(__FILE__))
PUBLIC_DIR = File.join(APP_DIR, 'public')
MODELS_DIR = File.join(APP_DIR, 'models')

MAIL_FROM = "updates@latter.joshmcarthur.me"

require File.join(MODELS_DIR, 'player.rb')
require File.join(MODELS_DIR, 'challenge.rb')

set :root, File.dirname(__FILE__)
enable :sessions
enable :static


##### Latter: A Table Tennis Ladder ############

I18N = {
  :record_not_found => "Record not found",
  :record_not_saved => "Record could not be saved. Please check data and try again."
}

######### Configuration #########
configure :test do
  DataMapper.setup(:default, "sqlite3::memory")
  DataMapper.auto_upgrade!
end

configure do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/latter.db.sqlite3")
  DataMapper.auto_upgrade!
end

before do
  current_player!
  authenticate! unless request.path =~ /\A\/\Z/ || request.path =~ /\A\/login\Z/
end


get '/' do
  redirect '/players' and return if @current_player
  haml :"auth/login"
end

post '/login' do
  @current_player = Player.first(:email => params[:email].downcase)
  if @current_player
    session[:player_id] = @current_player.id
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

get '/player/new' do
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
  puts params
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

get '/challenges' do
  @challenges = Challenge.all
  haml :"challenges/index"
end


get '/challenge/new' do
  haml :"challenges/form"
end

get '/challenge/:id/edit' do
  @challenge = Challenge.get(params[:id])
  not_found?(@challenge)
  
  haml :"challenges/form"
end

get '/challenge/:id' do
  @challenge = Challenge.get(params[:id])
  not_found?(@challenge)

  haml :"challenges/show"
end

post '/challenge' do
  @challenge = Challenge.new
  @challenge.from_player = Player.get(params[:challenge][:from_player_id])
  @challenge.to_player = Player.get(params[:challenge][:to_player_id])
  @challenge.completed = false
  @challenge.save ? redirect('/challenges') : send_mail(:to => @challenge.to_player.email, :subject => "New Challenge on Latter", :template => 'new_challenge') && redirect('/challenge/new')
end

post '/challenge/:id/update' do
  @challenge = Challenge.get(params[:id])
  not_found?(@challenge)

  @challenge.completed? ? (error(400, I18N[:challenge_can_only_be_updated_once])) : nil
  
  @challenge.set_score_and_winner(:from_player_score => params[:challenge][:from_player_score],
    :to_player_score => params[:challenge][:to_player_score]
  )
  
  @challenge.score = params[:challenge][:score]
  @challenge.completed = true
  challenge_updated = @challenge.save
  challenge_updated ? send_mail(:to => @challenge.to_player.email, :subject => "Updated Challenge on Latter", :template => 'challenge_updated') && redirect('/challenges') : redirect('/challenge/edit')
end


def new_mail(options)
  Pony.mail(
    :to => options[:to],
    :from => MAIL_FROM,
    :subject => options[:subject],
    :body => haml(:"mail/#{options[:template]}"),
    :via => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '25',
      :authentication => :plain,
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :domain => ENV['SENDGRID_DOMAIN']
    }
  )
end

def not_found?(object)
  error(404, I18N[:record_not_found]) unless object
end

def current_player!
  @current_player ||= Player.get(session[:player_id])
end

def authenticate!
  redirect '/' unless @current_player
end

