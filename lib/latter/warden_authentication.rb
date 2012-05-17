require 'warden'
require_relative '../../models/user'

Warden::Manager.serialize_into_session { |player| player.id }
Warden::Manager.serialize_from_session { |id| Player.get(id) }


Warden::Manager.before_failure do |env, opts|
  # Sinatra is very sensitive to the request method
  # since authentication could fail on any type of method, we need
  # to set it for the failure app so it is routed to the correct block
  env['REQUEST_METHOD'] = "POST"
end

Warden::Strategies.add(:password) do
  def valid?
    params['email'] || params['password']
  end

  def authenticate!
    player = Player.authenticate(params['email'], params['password'])
    player.nil? ? fail!("Could not log in") : success!(player)
  end
end
