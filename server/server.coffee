Meteor.startup ->
  core = new UGLICore


  Meteor.publish 'current_room', ->
    Rooms.publish_current_room @userId

  Meteor.publish 'game_rooms', ->
    do Rooms.publish_game_rooms

  Meteor.publish 'chats', (room_id) ->
    core.publish_chats @userId, room_id


  Meteor.users.find({"status.online": true}).observe
    added: core.add_user.bind(core)
    removed: core.drop_user.bind(core)


  Meteor.methods
    'create_game': (config) ->
      core.create_game @userId, config

    'join_game': (room_id) ->
      core.join_game @userId, room_id

    'leave_game': (room_id) ->
      core.leave_game @userId, room_id

    'start_game': (room_id) ->
      core.start_game @userId, room_id

    'send_chat': (room_id, message) ->
      core.send_chat @userId, room_id, message

    'send_game_message': (room_id, message) ->
      core.handle_message @userId, room_id, message
