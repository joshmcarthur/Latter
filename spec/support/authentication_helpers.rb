include Rack::Test::Methods

def logout
  get 'logout'
end

def login_as(player)
  post '/login', { :email => player.email, :password => player.password }
end
