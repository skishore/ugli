# This collection stores data about rooms, which can be lobbies, singleplayer
# games, or multiplayer games. A room is a lobby if and only if game is false.
#   name: string
#   game_state: either false, or a dict with the following keys:
#     public_view: Object
#     private_views: Object
#   players: [string]
#   user_ids: [_id] of users in this room

class @Rooms extends Collection
  @set_schema
    name: 'rooms'
    fields: [
      'name',
      'game',
      'players',
      'user_ids',
    ]
    indices: [
      {columns: user_ids: 1},
    ]

  @publish: (user_id) ->
    fields = {name: 1, 'game.public_view': 1, players: 1}
    fields["game.private_views.#{user_id}"] = 1
    @find {user_ids: user_id}, fields

  @create_room: (name, game) ->
    # Create a new room and return its id.
    check name, String
    @insert {name: name,  game: game, players: [], user_ids: []}

  @update_room: (room_id, name, game, users) ->
    players = (user.name for user in users)
    do players.sort
    user_ids = (user._id for user in users)

    check room_id, String
    check name, String
    check players, [String]
    check user_ids, [String]

    @update {_id: room_id},
      $set: {
        name: name
        game: game
        players: players
        user_ids: user_ids
      }
