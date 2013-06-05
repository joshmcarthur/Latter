json.array! @games do |game|
  json.challenger do
    if game.challenger
      json.partial!("api/v1/players/player", player: game.challenger)
    else
      json.nil!
    end
  end

  json.challenged do
    if game.challenged
      json.partial!("api/v1/players/player", player: game.challenged)
    else
      json.nil!
    end
  end

  json.winner_id game.winner_id
  json.score game.score

end