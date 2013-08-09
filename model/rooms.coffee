# This collection stores data about rooms, which can be lobbies,
# singleplayer games, or multiplayer games.
#   name: string
#   user_ids: [user _ids]
#   is_game: bool
#   created: ts
#   active: bool
# privates and invites fields to come soon.

class @Rooms extends Collection
  @collection = new Meteor.Collection 'rooms'
  @fields = [
    'name',
    'user_ids',
    'is_game',
    'created',
    'active',
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
      created: new Date().getTime()
      active: true

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
        UGLICore.call_state_mutator room_id, (context) ->
          if Common.ugli_server.join_game context, user.username
            context._add_user user
            Rooms.update({_id: room_id}, $addToSet: 'user_ids': user_id)
      else
        @update({_id: room_id}, $addToSet: 'user_ids': user_id)

  @leave_room = (user_id, room_id) ->
    # Have a user leave a room. Notify the UGLI server if a game is being played.
    check user_id, String
    check room_id, String
    user = Users.get user_id
    room = Rooms.get room_id
    if user? and room? and user_id in room.user_ids
      if room.is_game
        UGLICore.call_state_mutator room_id, (context) ->
          Common.ugli_server.leave_game context, user.username
          context._remove_user user
      @update({_id: room_id}, $pull: 'user_ids': user_id)

  @boot_user = (user_id) ->
    for room in @find({user_ids: user_id}, fields: _id: 1).fetch()
      @leave_room(user_id, room._id)

  @boot_users = (user_ids) ->
    for user_id in user_ids
      @boot_user(user_id)

  @mark_all_games_idle = ->
    # Marks all game rooms inactive.
    #
    # If Common.keep_history is false, removes these rooms instead.
    clause = active: true, is_game: true
    if Common.keep_history
      @update clause, $set: $active: false
    else
      @remove clause

  @mark_orphaned_games_idle = (idle_timeout) ->
    # Marks orphaned game rooms (that is, games that have existed for
    # idle_timeout ms without a game state) inactive.
    #
    # If Common.keep_history is false, removes these rooms instead.
    game_states = GameStates.find(active: true).fetch()
    active_room_ids = _.uniq(game_state.room_id for game_state in game_states)
    clause = active: true, is_game: true, _id: $not: $in: active_room_ids
    if Common.keep_history
      @update clause, $set: $active: false
    else
      @remove clause
