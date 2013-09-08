Meteor.publish 'users', ->
  Users.publish @userId

Meteor.publish 'rooms', ->
  Rooms.publish @userId

Meteor.publish 'public_game_views', ->
  GameStates.publish_public_views @userId

Meteor.publish 'chats', (room_ids) ->
  Chats.publish @userId, room_ids

Meteor.publish 'game_states', (room_ids) ->
  GameStates.publish @userId, room_ids


Meteor.methods
  'create_game': (config) ->
    UGLICore.create_game @userId, config

  'heartbeat': ->
    Users.heartbeat @userId

  'join_game': (room_id) ->
    if Rooms.get(room_id).is_game
      Rooms.join_room @userId, room_id

  'leave_game': (room_id) ->
    if Rooms.get(room_id).is_game
      Rooms.leave_room @userId, room_id

  'send_chat': (room_id, message) ->
    Chats.send_chat @userId, room_id, message

  'send_game_message': (room_id, message) ->
    UGLICore.handle_message @userId, room_id, message
