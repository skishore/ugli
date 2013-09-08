Meteor.setInterval (->
  # Mark idle users and delete empty game rooms and their chats.
  Users.mark_idle_users Common.idle_timeout
  Rooms.cleanup_orphaned_rooms Common.idle_timeout
  Chats.cleanup_orphaned_chats()

  # Push notifications for game updates that were missed earlier.
  UGLICore.save_latest_states()

  # Clean up orphaned or old game states.
  GameStates.cleanup_orphaned_states()
  GameStates.cleanup_old_states()
), Common.idle_timeout

Meteor.startup ->
  Rooms.cleanup_all_game_rooms()
  Chats.cleanup {}
