Meteor.startup ->
  Meteor.users.remove {'profile.guest': true}
  core = new UGLICore


  Meteor.publish 'current_room', ->
    (Rooms.publish_current_room @userId) if @userId?

  Meteor.publish 'game_rooms', ->
    do Rooms.publish_game_rooms

  Meteor.publish 'chats', (room_id) ->
    (core.publish_chats @userId, room_id) if @userId?


  Meteor.users.find({"status.online": true}).observe
    added: core.add_user.bind(core)
    removed: core.drop_user.bind(core)


  Meteor.methods
    'create_game': (config) ->
      (core.create_game @userId, config) if @userId?

    'create_singleplayer_game': ->
      (core.create_singleplayer_game @userId) if @userId?

    'join_game': (room_id) ->
      (core.join_game @userId, room_id) if @userId?

    'leave_game': (room_id, autoremove) ->
      (core.leave_game @userId, room_id, autoremove) if @userId?

    'start_game': (room_id) ->
      (core.start_game @userId, room_id) if @userId?

    'send_chat': (room_id, message) ->
      (core.send_chat @userId, room_id, message) if @userId?

    'send_game_message': (room_id, message) ->
      (core.send_game_message @userId, room_id, message) if @userId?

    'send_feedback_email': (options) ->
      check options, {email: String, subject: String, text: String}
      options.to = 'kshaunak+ugli@gmail.com'
      Email.send options

    'get_high_scores': (game_type) ->
      GameRecords.get_high_scores game_type, @userId
