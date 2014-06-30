# This collection stores data about rooms, which can be lobbies, singleplayer
# games, or multiplayer games. A room is a lobby if and only if game is false.
#   name: string
#   summary: for games, a dict with the following keys:
#     description: string
#     host: string
#     max_players: number
#   game: for games, a dict with the following keys:
#     public_view: Object
#     private_views: Object
#   players: [string] of sorted player names
#   state: string
#   user_ids: [_id] of users in this room

class @Rooms extends Collection
  @set_schema
    name: 'rooms'
    fields: [
      'name',
      'summary',
      'game',
      'players',
      'state',
      'user_ids',
    ]
    indices: [
      {columns: state: 1},
      {columns: user_ids: 1},
    ]

  @create_test_data: ->
    for i in [0...100]
      @insert
        name: RoomNames.data[i]
        summary:
          description: 'Sprint 100-200'
          host: 'wuthefwasthat'
          max_players: 4
        game: {}
        players: ['wuthefwasthat', 'skishore', 'paulfc']
        state: RoomState.WAITING
        user_ids: []

  @publish_current_room: (user_id) ->
    check user_id, String
    fields = {name: 1, 'game.public_view': 1, players: 1, summary: 1}
    fields["game.private_views.#{user_id}"] = 1
    @find {user_ids: user_id}, fields

  @publish_game_rooms: ->
    @find {state: '$ne': RoomState.LOBBY}, {name: 1, summary: 1, players: 1}

  @create_lobby: ->
    # Create a lobby room and return its id.
    @create_room Common.lobby_name, false, false, RoomState.LOBBY

  @create_room: (name, game, summary, state) ->
    # Create a room and return its id.
    @insert {
      name: name
      summary: summary
      game: game
      players: []
      state: state
      user_ids: []
    }

  @update_room: (room_id, name, game, users) ->
    players = (user.name for user in users)
    do players.sort
    user_ids = (user._id for user in users)

    check room_id, String
    check name, String
    check players, [String]
    check user_ids, [String]

    update =
      name: name
      game: game
      players: players
      user_ids: user_ids
    if game
      update['summary.host'] = if users.length > 0 then users[0].name else '-'
    @update {_id: room_id}, $set: update
