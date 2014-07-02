# This collection stores data about rooms, which can be lobbies, singleplayer
# games, or multiplayer games. A room is a lobby if and only if game is false.
#   name: string
#   summary: for games, a dict with the following keys:
#     description: string
#     explanation: string
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

  @publish_current_room: (user_id) ->
    check user_id, String
    fields = {name: 1, 'game.public_view': 1, players: 1, summary: 1}
    fields["game.private_views.#{user_id}"] = 1
    @find {user_ids: user_id}, fields

  @publish_game_rooms: ->
    @find {state: '$ne': RoomState.LOBBY}, {name: 1, summary: 1, players: 1}

  @save_room: (room) ->
    data = name: room.name
    data.game = (if room.game then (do room.game._get_views) else false)
    data.players = do (user.name for user in room.users).sort
    data.state = room.state
    data.user_ids = (user._id for user in room.users)

    if room.summary
      room.summary.host = room.users[0]?.name or '-'
    data.summary = room.summary

    if room._id? then (@update {_id: room._id}, $set: data) else (@insert data)
