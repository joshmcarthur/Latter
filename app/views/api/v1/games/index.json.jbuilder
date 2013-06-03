json.array! @games do |game|
  json.challenger do
   json.partial!("api/v1/players/player", player: game.challenger)
 end

  json.challenged do
    json.partial!("api/v1/players/player", player: game.challenged)
  end

  json.winner_id game.winner_id
  json.score game.score

end