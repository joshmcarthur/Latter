json.array! @players do |player|
  json.partial!('player', player: player)
end