# This collection stores data about rooms, which can be lobbies,
# singleplayer games, or multiplayer games.
#   name: string
#   user_ids: [user _ids]
#   is_game: bool
#   active: bool
#   created: ts
# privates and invites fields to come soon.

class @Rooms extends Collection
  @collection = new Meteor.Collection 'rooms'
  @fields = [
    'name',
    'user_ids',
    'is_game',
    'active',
    'created',
  ]
  if Meteor.isServer
    @collection._ensureIndex 'name', unique: true
    @collection._ensureIndex 'active'

  @publish: (user_id) ->
    check user_id, String
    @find active: true

  @create_room: (name, is_game) ->
    # Create a new game room with no initial game state. Return its _id.
    check name, String
    check is_game, Boolean
    @insert
      name: name
      user_ids: []
      is_game: is_game

  @get_lobby = ->
    lobby = @findOne(name: Common.lobby_name)
    if not lobby? and Meteor.isServer
      @create_room Common.lobby_name, false
      lobby = @findOne(name: Common.lobby_name)
    lobby

  @get_user_rooms = (user_id) ->
    check user_id, String
    @find(active: true, user_ids: user_id).fetch()

  @join_room = (user_id, room_id) ->
    # Have a user join a room. Notify the UGLI server if a game is being played.
    check user_id, String
    check room_id, String
    user = Users.get user_id
    room = Rooms.get room_id
    if user? and room? and user_id not in room.user_ids
      if room.is_game
        UGLICore.call_state_mutator room_id, ((game) ->
          if game? and user.username not of game.players
            game._add_user user
        ), -> @update {_id: room_id}, $addToSet: 'user_ids': user_id
      else
        @update {_id: room_id}, $addToSet: 'user_ids': user_id

  @leave_room = (user_id, room_id) ->
    # Have a user leave a room. Notify the UGLI server if a game is being played.
    check user_id, String
    check room_id, String
    user = Users.get user_id
    room = Rooms.get room_id
    if user? and room? and user_id in room.user_ids
      if room.is_game
        UGLICore.call_state_mutator room_id, ((game) ->
          if game? and user.username of game.players
            game._remove_user user
        ), -> @update {_id: room_id}, $pull: 'user_ids': user_id
      else
        @update {_id: room_id}, $pull: 'user_ids': user_id

  @boot_user = (user_id) ->
    for room in @find({user_ids: user_id}, fields: _id: 1).fetch()
      @leave_room(user_id, room._id)

  @boot_users = (user_ids) ->
    for user_id in user_ids
      @boot_user(user_id)

  @cleanup_all_game_rooms = ->
    # Clean up all game rooms. This method is called on server startup.
    @cleanup active: true, is_game: true

  @cleanup_orphaned_rooms = (idle_timeout) ->
    # Clean up orphaned game rooms (that is, games that have existed for
    # idle_timeout ms without a game state) inactive.
    game_states = GameStates.find({active: true}, fields: room_id: 1).fetch()
    active_room_ids = _.uniq(game_state.room_id for game_state in game_states)
    idle_time = new Date().getTime() - idle_timeout
    clause =
      active: true
      is_game: true
      _id: $not: $in: active_room_ids
      created: $lt: idle_time
    @cleanup clause
