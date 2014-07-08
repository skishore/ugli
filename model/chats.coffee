# This collection stores messages that are local to a room:
#   room_id: room _id
#   sender: string, empty if this is a log message
#   message: string
#   created: creation timestamp

class @Chats extends Collection
  @cleanup_time = 4*3600*1000
  @set_schema
    name: 'chats'
    fields: [
      'room_id',
      'sender',
      'message',
      'created',
    ]
    indices: [
      {columns: room_id: 1},
    ]

  @publish: (lobby_id, room_id) ->
    check lobby_id, String
    if room_id?
      check room_id, String
      @find {room_id: $in: [lobby_id, room_id]}
    else
      @find {room_id: lobby_id}

  @send_chat: (room_id, sender, message) ->
    check room_id, String
    check sender, String
    check message, String
    @insert
      room_id: room_id
      sender: sender
      message: message
      created: new Date().getTime()

  @set_cleanup_timer: ->
    Meteor.setInterval (=>
      cutoff = new Date().getTime() - @cleanup_time
      @remove {created: $lt: cutoff}
    ), @cleanup_time
