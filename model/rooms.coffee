# This collection stores data about rooms, which can be lobbies, singleplayer
# games, or multiplayer games. A room is a lobby if and only if game is false.
#   name: string
#   game_state: either false, or a dict with the following keys:
#     public_view: Object
#     private_views: Object
#   players: [string]

class @Rooms extends Collection
  @set_schema
    name: 'games'
    fields: [
      'name',
      'game',
      'players',
    ]

  @create_room: (name, game, players) ->
    # Create a new room and return its id.
    check name, String
    check players, [String]
    @insert {name: name,  game: game, players: players}

  @update_room: (room_id, name, game, players) ->
    check room_id, String
    check name, String
    check players, [String]
    @update {_id: room_id}, {$set: {name: name, game: game, players: players}}
