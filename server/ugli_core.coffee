# TODO(skishore): The server should pass usernames to the context
# instead of user_ids using something like this code:
#
#   users = Users.find(_id: $in: room.user_ids)
#   if users.length != room.user_ids.length
#     throw "Missing users w/ user_ids in #{room.user_ids}"
#   players = (user.username for user in users)
#
# TODO(skishore): In addition, UGLICore should implement notifications for when
# players join and leave a game, and it should also have fallback notifications
# when a room context is created and these calls were missed.

class @UGLICore
  @verbose = false

  @create_room_context: (room_id) ->
    # Return a [context, index] pair. The index is the current state index.
    console.log('create_room_context', room_id) if @verbose
    room = Rooms.findOne _id: room_id
    if not room?
      throw "Room #{room_id} is not ready"
    game_state = GameStates.get_current_state room_id
    [
      new UGLIContext room.user_ids, room.rules, game_state?.state
      if game_state? then game_state.index else -1
    ]

  @call_state_mutator = (room_id, callback) ->
    console.log('call_state_mutator', room_id) if @verbose
    [context, index] = UGLICore.create_room_context room_id
    callback context
    views = context._get_views()
    if GameStates.update_game_state room_id, index, context.state, views
      context._after_save room_id

  @create_game: (user_id, rules) ->
    console.log('create_game', user_id, rules) if @verbose
    user = Users.findOne(_id: user_id)
    name = "#{user.username}'s game ##{Common.get_uid()}"
    room_id = Rooms.create_room name, [user_id], rules
    @call_state_mutator room_id, (context) ->
      Common.ugli_server.initialize_state context

  @handle_client_message: (room_id, user_id, message) ->
    console.log('handle_client_message', room_id, user_id, message) if @verbose
    # TODO(skishore): We should check if the user is in the room here...
    @call_state_mutator room_id, (context) ->
      Common.ugli_server.handle_client_message context, user_id, message
