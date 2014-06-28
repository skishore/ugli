Template.game_list.games = ->
  result = []
  for i in [0...10]
    result.push {
      name: RoomNames.data[i]
      creator: 'skishore'
      rules: 'Sprint 100-200'
      state: 'Waiting'
      num_players: 3
      max_players: 4
    }
  result
