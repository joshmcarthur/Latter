json.player do
  json.partial! "api/v1/players/player", :player => @player
end